import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:langwise/common/stores/user.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../common/entities/entities.dart';
import '../common/https/https.dart';
import '../log_widget.dart';
import 'utils.dart';

class WebSocketMessageCmd {
  /// 心跳
  static const String heartbeat = "HEARTBEAT";

  /// 通知
  static const String notification = "NOTIFICATION";

  static const Map<String, String> cmdMap = {
    "HEARTBEAT": "心跳",
    "NOTIFICATION": "通知",
  };
}

class WebSocketMessageModule {
  /// 查询
  static const String question = "QUESTION";
}

class WebsocketUtils {
  factory WebsocketUtils() => _getInstance();

  static WebsocketUtils get instance => _getInstance();

  static WebsocketUtils? _instance;

  static late WebSocketChannel _channel;

  /// 重连计数器
  static int _reconnectAttempts = 0;

  /// 最大重连次数
  static const int _maxReconnectAttempts = 100;

  StreamController<PushMessageEntity> websocketStreamController = StreamController<PushMessageEntity>.broadcast();

  static WebsocketUtils _getInstance() {
    _instance ??= WebsocketUtils._internal();
    return _instance!;
  }

  WebsocketUtils._internal() {
    initWebSocket();
  }

  /// 初始化WebSocket
  Future<void> initWebSocket() async {
    // if (Platform.isAndroid || Platform.isIOS) return;

    Uri? wsUrl = await _getWebSocketUrl();
    if (wsUrl == null) return;

    _channel = IOWebSocketChannel.connect(
      wsUrl,
      pingInterval: const Duration(seconds: 10),
    );
    try {
      await _channel.ready;
    } on SocketException catch (e) {
      LogManager().addLog("WebSocket -------------  连接失败 $e");
      return;
    } on WebSocketChannelException catch (e) {
      LogManager().addLog("WebSocket -------------  连接失败 $e");
      return;
    }

    LogManager().addLog("WebSocket -------------  连接成功");
    _reconnectAttempts = 0; // 重置重连计数器

    _channel.stream.listen(
      (message) => _handleMessage(message),
      onError: (error) => _handleError(error),
      onDone: () => _handleDone(),
    );
  }

  /// 处理接收到的消息
  Future<void> _handleMessage(dynamic message) async {
    print("WebSocket -------------  接收消息: $message");
    LogManager().addLog("WebSocket -------------  接收消息: $message");
    Map<String, dynamic> messageMap = jsonDecode(message);
    WebsocketMessageEntity websocketMessageEntity = WebsocketMessageEntity.fromJson(messageMap);
    if (websocketMessageEntity.cmd == null) return;
    if (websocketMessageEntity.cmd == WebSocketMessageCmd.heartbeat) return;
    if (websocketMessageEntity.notificationId == null) return;
    if (websocketMessageEntity.content == null) return;
    String? content = websocketMessageEntity.content;
    if (content == null) return;
    Map<String, dynamic> contentMap = jsonDecode(content);
    PushMessageEntity pushMessageEntity = PushMessageEntity.fromJson(contentMap);
    // 如果是用户端 那么安卓和ios不发通知，因为用户端的通知是在极光那边发的
    // if (pushMessageEntity.category == JumpPageUtils.manageType && (Platform.isAndroid || Platform.isIOS)) {
    //   return;
    // }
    websocketStreamController.add(pushMessageEntity);

    LocalNotificationUtils().showLocalNotification(
      id: websocketMessageEntity.notificationId!,
      title: pushMessageEntity.title ?? "",
      body: pushMessageEntity.content ?? "",
      payload: jsonEncode(pushMessageEntity.toJson()),
    );
    await JumpPageUtils.jumpPage(pushMessageEntity);
  }

  void _handleError(dynamic error) {
    LogManager().addLog("WebSocket -------------  WebSocket错误 $error");
    _scheduleReconnect();
  }

  void _handleDone() {
    print('WebSocket连接关闭');
    LogManager().addLog("WebSocket -------------  链接关闭");
    _scheduleReconnect();
  }

  /// 重连
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) return;

    _reconnectAttempts++;
    LogManager().addLog("WebSocket -------------  尝试重连 ($_reconnectAttempts/$_maxReconnectAttempts)...");

    Future.delayed(const Duration(seconds: 3), () {
      return initWebSocket();
    });
  }

  /// 获取WebSocketChannel链接uri
  Future<Uri?> _getWebSocketUrl() async {
    bool experience = LockUtils.checkExperienceAppStorage();
    if (experience) return null;
    if(!UserStore.to.isLogin) return null;
    WebsockeInfotEntity? websockeInfotEntity = await AccountUtil.getWebSocketInfo();
    if (websockeInfotEntity == null) return null;
    if (websockeInfotEntity.token == null) return null;
    if (websockeInfotEntity.host == null) return null;
    if (websockeInfotEntity.port == null) return null;
    if (websockeInfotEntity.userId == null) return null;
    if (websockeInfotEntity.protocol == null) return null;
    String protocol = websockeInfotEntity.protocol!;
    String host = websockeInfotEntity.host!;
    int port = websockeInfotEntity.port!;
    Uri wsUrl = Uri.parse('$protocol://$host:$port/hub/wise/ws/socket');
    final params = <String, String>{
      'userId': websockeInfotEntity.userId.toString(),
      'token': websockeInfotEntity.token!,
    };
    wsUrl = wsUrl.replace(queryParameters: params);
    LogManager().addLog("WebSocket -------------  获取链接地址: $wsUrl");
    print("wsUrl: $wsUrl");
    return wsUrl;
  }

  /// 关闭WebSocket
  Future<void> closeWebSocket() async {
    try {
      await websocketStreamController.close();
      await _channel.sink.close(status.normalClosure);
      _instance = null;
    } catch (_) {}
  }
}
