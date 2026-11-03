import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lib_common/common.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:typed_data/typed_buffers.dart';

import '../../common/entities/entities.dart';
import '../../common/enum/enum.dart';
import '../../common/https/https.dart';
import '../../common/public_controller/manage_sandbox_controller.dart';
import '../../common/stores/stores.dart';
import '../../common/values/values.dart';
import '../../log_widget.dart';
import '../utils.dart';

/// MQTT5 长连接工具类。
///
/// 职责：
/// 1. 拉取业务服务端下发的 MQTT 连接凭证。
/// 2. 建立 MQTT TCP 连接。
/// 3. 订阅当前消息系统约定的用户、群组和广播 Topic。
/// 4. 将收到的 MQTT 消息解析为 `PushMessageEntity` 并对外分发。
class Mqtt5ClientUtils {

  /// 固定重连间隔秒数。
  static const int _reconnectIntervalSeconds = 5;

  /// 最大重连次数
  static const int _maxReconnectAttempts = 10;

  factory Mqtt5ClientUtils() => _getInstance();

  static Mqtt5ClientUtils get instance => _getInstance();

  static Mqtt5ClientUtils? _instance;

  /// 当前持有的 MQTT 客户端实例。
  MqttServerClient? _client;

  /// 最近一次从服务端获取到的 MQTT 连接凭证。
  MqttTokenEntity? _mqttTokenEntity;

  /// 是否正处于连接流程中，避免并发重复发起连接。
  bool _isConnecting = false;

  /// 是否为业务主动要求断开。
  ///
  /// 为 `true` 时，不应再触发自动重连。
  bool _manualDisconnectRequested = false;

  /// 当前累计的重连次数。
  ///
  /// 用于计算指数退避时间。
  int _reconnectAttempt = 0;

  /// 延迟重连定时器。
  Timer? _reconnectTimer;

  Timer? _heartbeatTimer;

  /// MQTT 消息订阅流监听。
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _updatesSubscription;

  /// 对外分发推送消息的广播流。
  final StreamController<PushMessageEntity> _messageStreamController = StreamController<PushMessageEntity>.broadcast();

  /// 已处理消息 uid 集合，用于幂等去重。
  final Set<String> _messageUidSet = <String>{};

  Stream<PushMessageEntity> get messageStream => _messageStreamController.stream;

  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;

  static Mqtt5ClientUtils _getInstance() {
    _instance ??= Mqtt5ClientUtils._internal();
    return _instance!;
  }

  Mqtt5ClientUtils._internal();

  /// 初始化 MQTT 连接。
  ///
  /// 仅在用户已登录、当前未处于连接中、且尚未连接成功时执行。
  Future<void> initMqtt() async {
    // 模拟登录情况下 不连接
    if(ManageSandboxController.to.isSimulate) return;
    if (!UserStore.to.isLogin || _isConnecting || isConnected) {
      debugPrint('[MQTT] 跳过初始化: isLogin=${UserStore.to.isLogin}, isConnecting=$_isConnecting, isConnected=$isConnected');
      return;
    }
    _manualDisconnectRequested = false;
    _isConnecting = true;
    try {
      debugPrint('[MQTT] 开始初始化');
      final MqttTokenEntity? info = await getMqttClientToken();
      if (info == null) {
        debugPrint('[MQTT] 初始化失败: token is null');
        return;
      }

      if (!_checkMqttToken(info)) {
        debugPrint('[MQTT] 初始化失败: token 无效 host=${info.host} port=${info.port} clientId=${info.clientId} username=${info.username}');
        return;
      }

      // 每次重建连接前先清理旧连接和旧订阅监听，避免重复接收消息。
      await _closeClient(markAsManualDisconnect: false);
      
      _mqttTokenEntity = info;
      debugPrint('[MQTT] 准备创建客户端 host=${info.host} port=${info.port ?? 1883} clientId=${info.clientId} username=${info.username} groups=${info.groups}');
      final MqttServerClient client = MqttServerClient(info.host!, info.clientId ?? '');
      client.logging(on: false);
      client.port = info.port ?? 1883;
      client.keepAlivePeriod = 30;
      client.autoReconnect = false;
      client.resubscribeOnAutoReconnect = false;
      client.onConnected = _onConnected;
      client.onDisconnected = _onDisconnected;
      client.onSubscribed = _onSubscribed;
      client.connectionMessage = MqttConnectMessage().withClientIdentifier(info.clientId ?? '').startClean();
      _client = client;
      debugPrint('[MQTT] 开始连接...');
      await client.connect('${info.username ?? ''}', info.password ?? '');
      if (!isConnected) {
        debugPrint('[MQTT] 连接失败: state=${_client?.connectionStatus?.state}');
        await _closeClient(markAsManualDisconnect: false);
        _scheduleReconnect();
        return;
      }
      // 连接成功后先开始监听消息，再执行订阅。
      debugPrint('[MQTT] 连接成功');
      _listenMessages();
      _subscribeTopics();
    } on Exception catch (e, stackTrace) {
      debugPrint('[MQTT] 连接异常: $e');
      ErrorLogUtils.to.logError(e, stackTrace);
      await _closeClient(markAsManualDisconnect: false);
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  /// 手动设置消息
  void manualSetMessage(List<PushMessageEntity> messages){
    if(messages.isEmpty) return;

    List<PushMessageEntity> filterMessages = [];
    for(int i = 0; i < messages.length; i++){
      int? uid = messages[i].uid;
      if(uid == null) continue;
      if(_messageUidSet.contains(uid)) continue;
      _messageUidSet.add(uid.toString());
      messages[i].report = false;
      filterMessages.add(messages[i]);
    }

    if (!_messageStreamController.isClosed) {
      debugPrint('[MQTT] 手动分发: ${filterMessages.length}');

      for (var element in filterMessages) {
        _messageStreamController.add(element);
      }
      
    }
  }

  /// 获取 MQTT 连接信息。
  ///
  /// 返回的数据包含 broker 地址、端口、认证信息以及群组列表。
  Future<MqttTokenEntity?> getMqttClientToken() async {
    try {
      debugPrint('[MQTT] 开始获取客户端 token');
      final MqttTokenEntity? info = await AccountUtil.getMqttClientToken();
      if (info == null) {
        debugPrint('[MQTT] 获取 token 结果为空: null');
        return null;
      }
      debugPrint('[MQTT] 获取 token 成功 host=${info.host} port=${info.port} clientId=${info.clientId} username=${info.username} groups=${info.groups}');
      return info;
    } on Exception catch (e, stackTrace) {
      debugPrint('[MQTT] 获取 token 异常: $e');
      ErrorLogUtils.to.logError(e, stackTrace);
      return null;
    }
  }

  /// 主动断开 MQTT 连接并清理消息监听。
  Future<void> disconnect() async {
    debugPrint('[MQTT] 收到手动断开请求');
    _cancelReconnectTimer();
    _reconnectAttempt = 0;
    _manualDisconnectRequested = true;
    await _closeClient(markAsManualDisconnect: true);
  }

  /// 关闭当前客户端并释放订阅监听。
  ///
  /// [markAsManualDisconnect] 为 `true` 时表示本次断开是业务主动行为，
  /// 后续断开回调不应触发自动重连。
  Future<void> _closeClient({required bool markAsManualDisconnect}) async {
    _manualDisconnectRequested = markAsManualDisconnect;
    _stopHeartbeatTimer();
    await _updatesSubscription?.cancel();
    _updatesSubscription = null;
    if (_client != null) {
      debugPrint('[MQTT] 正在关闭客户端, manual=$markAsManualDisconnect');
      _client!.disconnect();
      _client = null;
    }
  }

  /// 安排一次延迟重连。
  ///
  /// 固定每 5 秒重连一次，最多重连 10 次。
  ///
  /// 同时会避免：
  /// - 手动断开后继续重连
  /// - 已连接状态重复重连
  /// - 已存在定时器时重复创建
  /// - 正在连接过程中再次发起连接
  void _scheduleReconnect() {
    if (_manualDisconnectRequested || !UserStore.to.isLogin || isConnected || _isConnecting) {
      debugPrint('[MQTT] 跳过重连: manual=$_manualDisconnectRequested, isLogin=${UserStore.to.isLogin}, isConnected=$isConnected, isConnecting=$_isConnecting');
      return;
    }
    if (_reconnectTimer?.isActive ?? false) {
      debugPrint('[MQTT] 已存在重连任务');
      return;
    }
    if (_reconnectAttempt >= _maxReconnectAttempts) {
      debugPrint('[MQTT] 已达到最大重连次数: $_reconnectAttempt');
      return;
    }
    _reconnectAttempt += 1;
    debugPrint('[MQTT] 安排重连任务 attempt=$_reconnectAttempt delay=${_reconnectIntervalSeconds}s');
    _reconnectTimer = Timer(const Duration(seconds: _reconnectIntervalSeconds), () {
      _reconnectTimer = null;
      if (_manualDisconnectRequested || !UserStore.to.isLogin || isConnected || _isConnecting) {
        debugPrint('[MQTT] 定时器触发时取消重连: manual=$_manualDisconnectRequested, isLogin=${UserStore.to.isLogin}, isConnected=$isConnected, isConnecting=$_isConnecting');
        return;
      }
      debugPrint('[MQTT] 重连定时器触发');
      initMqtt();
    });
  }

  /// 取消当前待执行的重连定时器。
  void _cancelReconnectTimer() {
    debugPrint('[MQTT] 取消重连定时器');
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _startHeartbeatTimer() {
    _stopHeartbeatTimer();
    final int keepAlivePeriod = _client?.keepAlivePeriod ?? 0;
    if (keepAlivePeriod <= 0) {
      return;
    }
    debugPrint('[MQTT] 启动心跳监控 keepAlivePeriod=${keepAlivePeriod}s');
    LogManager().addLog('[MQTT] 启动心跳监控 keepAlivePeriod=${keepAlivePeriod}s');
    _heartbeatTimer = Timer.periodic(Duration(seconds: keepAlivePeriod), (Timer timer) {
      final MqttConnectionState? state = _client?.connectionStatus?.state;
      if (_manualDisconnectRequested || !isConnected) {
        debugPrint('[MQTT] 心跳监控停止 manual=$_manualDisconnectRequested state=$state');
        LogManager().addLog('[MQTT] 心跳监控停止 manual=$_manualDisconnectRequested state=$state');
        timer.cancel();
        _heartbeatTimer = null;
        return;
      }
      debugPrint('[MQTT] 心跳检查 isConnected=$isConnected state=$state reconnectAttempt=$_reconnectAttempt');
      LogManager().addLog('[MQTT] 心跳检查 isConnected=$isConnected state=$state reconnectAttempt=$_reconnectAttempt');
    });
  }

  void _stopHeartbeatTimer() {
    if (_heartbeatTimer == null) {
      return;
    }
    debugPrint('[MQTT] 关闭心跳监控');
    LogManager().addLog('[MQTT] 关闭心跳监控');
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// 校验 MQTT 连接所需的关键字段是否完整。
  bool _checkMqttToken(MqttTokenEntity info) {
    if ((info.host ?? '').isEmpty) {
      return false;
    }
    if ((info.clientId ?? '').isEmpty) {
      return false;
    }
    if ((info.password ?? '').isEmpty) {
      return false;
    }
    if (info.username == null) {
      return false;
    }
    return true;
  }

  /// 监听 broker 推送的 MQTT 消息。
  ///
  /// 收到消息后会：
  /// 1. 解析 payload JSON。
  /// 2. 转换为 `PushMessageEntity`。
  /// 3. 基于 `uid` 做幂等去重。
  /// 4. 通过广播流分发给上层业务。
  void _listenMessages() {
    _updatesSubscription?.cancel();
    final MqttServerClient? client = _client;
    if (client == null) return;

    _updatesSubscription = client.updates.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      if (messages.isEmpty) return;

      try {
        final MqttPublishMessage publishMessage = messages.first.payload as MqttPublishMessage;
       
        final String payload = MqttUtilities.bytesToStringAsString(publishMessage.payload.message!);
        // 应该在收到消息的时候清除无用的Retain消息
        final bool isRetained = publishMessage.header?.retain ?? false;

        final dynamic json = jsonDecode(payload);

        String? topic = publishMessage.variableHeader?.topicName;
        debugPrint('[MQTT] 收到消息原文: retain: $isRetained topicName: ${topic??''} payload: $payload');

        // if(isRetained) return; // Retained 消息不处理

        if (topic != null) {
          final Uint8Buffer emptyPayload = Uint8Buffer();
          int messageId = client.publishMessage(topic, MqttQos.atMostOnce, emptyPayload, retain: true);
          debugPrint('[MQTT] 清除 Retained 消息: $topic $messageId');
        }

        if (json is! Map) {
          debugPrint('[MQTT] 忽略消息: payload 不是 map');
          return;
        }
        final PushMessageEntity message = PushMessageEntity.fromJson(Map<String, dynamic>.from(json));
        final String uid = '${message.uid ?? ''}';
        debugPrint('[MQTT] 消息解析完成: uid=${message.uid} module=${message.module} category=${message.category} title=${message.title}');
        LogManager().addLog("[MQTT] ------------- 接收到消息：${message.toJson()}");
        // 业务消息以 uid 作为唯一标识，避免重复弹消息或重复插入列表。
        if (uid.isNotEmpty && _messageUidSet.contains(uid)) return;
        if (uid.isNotEmpty) {
          _messageUidSet.add(uid);
        }
        if (!_messageStreamController.isClosed) {
          debugPrint('[MQTT] 消息已分发: uid=$uid');
          _messageStreamController.add(message);
        }
      } on Exception catch (e, stackTrace) {
        debugPrint('[MQTT] 消息解析异常: $e');
        ErrorLogUtils.to.logError(e, stackTrace);
      }
    });
  }

  /// 订阅当前用户可接收的全部 Topic。
  void _subscribeTopics() {
    final MqttServerClient? client = _client;
    final MqttTokenEntity? info = _mqttTokenEntity;
    if (client == null || info == null || !isConnected) {
      debugPrint('[MQTT] 跳过订阅: client=$client info=$info isConnected=$isConnected');
      return;
    }
    List<String> topics = _buildTopics(info);

    // 1. 创建订阅选项
    var option = MqttSubscriptionOption();
    // 设置 QOS 级别 (可选)
    option.maximumQos = MqttQos.atMostOnce; 
    // 关键点：设置为只在全新订阅时才下发 Retain 消息
    option.retainHandling = MqttRetainHandling.doNotSendRetained; 
    List<MqttSubscription> subscriptions = [];
    for (final String topic in topics) {
      subscriptions.add(MqttSubscription(MqttSubscriptionTopic(topic), option));
    }
    debugPrint('[MQTT] 订阅主题: $topics');
    client.subscribeWithSubscriptionList(subscriptions);
  }

  /// 构建 MQTT 订阅 Topic 列表。
  ///
  /// 当前按文档先订阅 3 个模块：
  /// - user_center
  /// - learning
  /// - activity
  ///
  /// 同时覆盖 3 类消息来源：
  /// - 用户私有消息
  /// - 用户所属群组消息
  /// - 全局广播消息
  List<String> _buildTopics(MqttTokenEntity info) {
    final List<String> topics = <String>[];
    final String username = '${info.username ?? ''}';
    final List<String> modules = <String>[
      NotificationModuleEnum.activity.code,
      NotificationModuleEnum.system.code,
      NotificationModuleEnum.manage.code,
      NotificationModuleEnum.task.code,
      NotificationModuleEnum.reward.code,
    ];

    
    String buildType = StorageUtil().getString(STORAGE_HTTP_ENV_KEY);
    if (buildType.isEmpty) buildType = HttpEnvKey.pro;
    String env = buildType == HttpEnvKey.pro ? 'prod' : 'dev';

    if (username.isNotEmpty) {
      for (final String module in modules) {
        topics.add('langwise/$env/user/$username/$module');
      }
    }
    topics.add('langwise/$env/user/broadcast/${NotificationModuleEnum.task.code}');
    
    // for (final String group in info.groups ?? <String>[]) {
    //   if (group.isEmpty) {
    //     continue;
    //   }
    //   for (final String module in modules) {
    //     topics.add('langwise/dev/group/$group/$module');
    //   }
    // }
    // for (final String module in modules) {
    //   topics.add('langwise/dev/user/broadcast/$module');
    // }
    // 去重后返回，避免同一 Topic 被重复订阅。
    return topics.toSet().toList();
  }

  /// MQTT 连接成功回调。
  void _onConnected() {
    debugPrint('[MQTT] 连接成功回调');
    LogManager().addLog('[MQTT] 连接成功回调');
    _cancelReconnectTimer();
    _startHeartbeatTimer();
    _reconnectAttempt = 0;
    _manualDisconnectRequested = false;
  }

  /// MQTT 断开连接回调。
  void _onDisconnected() {
    debugPrint('[MQTT] 断开连接回调 manual=$_manualDisconnectRequested');
    LogManager().addLog('[MQTT] 断开连接回调 manual=$_manualDisconnectRequested');
    _stopHeartbeatTimer();
    if (_manualDisconnectRequested) {
      return;
    }
    _scheduleReconnect();
  }

  /// MQTT 订阅成功回调。
  void _onSubscribed(MqttSubscription subscription) {
    debugPrint('[MQTT] 订阅成功: $subscription');
  }
}