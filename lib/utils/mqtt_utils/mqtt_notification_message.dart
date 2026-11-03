
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/application/controllers/message_controller.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:lib_common/common.dart';

import '../../app/modules/management/controllers/management_message_controller.dart';
import '../../common/entities/entities.dart';
import '../../common/https/https.dart';
import '../../common/values/values.dart';
import '../utils.dart';
import 'mqtt_category_code.dart';
import 'mqtt_unified_business.dart';

/// mqtt 通知消息的分发
class MqttNotificationMessage extends GetObserver{

  factory MqttNotificationMessage() => _getInstance();

  static MqttNotificationMessage get instance => _getInstance();

  static MqttNotificationMessage? _instance;

  static MqttNotificationMessage _getInstance() {
    _instance ??= MqttNotificationMessage._internal();
    return _instance!;
  }

  MqttNotificationMessage._internal();

  /// 页面黑名单（如果当前路由是黑名单内的 就不弹消息 等黑名单的页面消息 就把队列中的消息没隔1秒弹出，可能需要监听路由跳转）
  final List<String> blacklistRouteList = [
    Routes.PRACTICE_QUESTIONS,
    Routes.PRACTICE_QUESTIONS_EVAL,
    Routes.PRACTICE_QUESTIONS_REVIEW,
  ];

  /// 消息监听
  StreamSubscription<PushMessageEntity>? _messageSub;

  /// 业务code消息监听 如果有跳转页面也会有消息
  final StreamController<PushMessageServiceEnitiy> _messageByCodeStreamController = StreamController<PushMessageServiceEnitiy>.broadcast();

  /// 消息队列 储存消息的地方 如果有多个消息 每隔1秒弹出一个 
  final List<PushMessageEntity> _messageQueue = [];

  /// 是否暂停发送消息
  bool _isPaused = false;

  /// 队列消费定时器，用于控制消息按固定间隔依次弹出
  Timer? _messageTimer;

  /// 监听mqtt消息
  void listenMqttMessage(){
    if(_messageSub != null) return;
    dispose();
    _messageSub = Mqtt5ClientUtils.instance.messageStream.listen(_messageProcessing);
  }

  /// 消息处理
  Future<void> _messageProcessing(PushMessageEntity data) async {
    
    _messageByCodeStreamController.add(PushMessageServiceEnitiy(message: data, isBackPage: false));

    if(data.category == MqttCategoryCode.task){
      // 根据code处理统一逻辑
      MqttUnifiedBusiness.byTask(data);
      return;
    }

    //  其他消息 添加到队列内
    _messageQueue.add(data);
    // 如果当前路由是黑名单内的 就不弹消息 等黑名单的页面退出 就把队列中的消息每隔1秒弹出
    if (_isPaused) return;
    _startDispatchMessage();
  }

  /// 弹出Banner
  void showBanner(PushMessageEntity entity){
    MqttNotificationToast.showToast(
      message: entity,
      onPageBack: (result) {
        _messageByCodeStreamController.add(PushMessageServiceEnitiy(
          message: entity, 
          isBackPage: true,
          backPageResult: result,
        ));
      },
    );
  }

  /// 弹出模态框
  void showModal(List<PushMessageEntity> messages){
    if(messages.isEmpty) return;
    MqttNotificationToast.showModal(messages: messages);
  }

  /// 弹出Toast
  void showToast(PushMessageEntity entity){
    if(entity.title == null) return;
    ToastUtils.showToast(text: entity.title!, type: ToastType.info);
  }

  /// 刷新消息列表
  void refreshMessageList(PushMessageEntity entity){
    if(entity.categoryIsManage){
      bool isRegisteredManage = Get.isRegistered<ManageMessageController>();
      if(isRegisteredManage){
        Get.find<ManageMessageController>().getInitMessageList(isNotification: false);
      }
    }else{
      bool isRegistered = Get.isRegistered<MessageController>();
      if(isRegistered) {
        Get.find<MessageController>().getInitMessageList(isNotification: false);
      }
    }
  }

  /// 弹出消息后需要上报给服务端
  void reportAlready(List<PushMessageEntity> messages){
    if(messages.isEmpty) return;
    
    List<int> uids = [];
    for (var element in messages) {
      if(element.uid == null) continue;
      if(element.report == false) continue;
      uids.add(element.uid!);
    }
    AccountUtil.reportAlreadyShowMessage(uids);
  }

  /// 根据业务code获取消息监听
  /// 
  /// [codes] 业务code列表
  /// [whereBackPage] 是否监听跳转页面返回的消息
  /// [onData] 消息回调
  StreamSubscription<PushMessageServiceEnitiy> listenByCode({
    required List<String> codes, 
    bool whereBackPage = false, 
    required void Function(PushMessageServiceEnitiy message) onData,
  }){
    if(whereBackPage){
      return _messageByCodeStreamController.stream.where((message) => codes.contains(message.message.code)).listen(onData);
    }else{
      return _messageByCodeStreamController.stream.where((message) => codes.contains(message.message.code) && !message.isBackPage).listen(onData);
    }
    
  }

  /// 开始消费消息队列
  ///
  /// 规则：
  /// 1. 暂停状态下不消费
  /// 2. 队列为空时不消费
  /// 3. 已存在定时器时不重复启动
  void _startDispatchMessage() {
    if (_isPaused || _messageQueue.isEmpty || _messageTimer != null) return;
    if (_messageQueue.isEmpty || _isPaused) return;
    _messageTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused || _messageQueue.isEmpty) {
        _stopDispatchMessage();
        return;
      }
      
      // 从队列头部取出一条消息并执行分发
      final PushMessageEntity entity = _messageQueue.removeAt(0);
      _dispatchMessage(entity);

      if (_messageQueue.isEmpty) {
        _stopDispatchMessage();
      }
    });
  }

  /// 根据 display 字段分发不同的展示方式
  ///
  /// `0`: 只有红点
  /// `1`: 顶部 Banner
  /// `2`: Toast
  /// `4`: 弹窗 Modal
  void _dispatchMessage(PushMessageEntity entity) {
    final int display = entity.display ?? 1; //TODO: 临时注释
    reportAlready([entity]);

    refreshMessageList(entity);

    if(!getManageMessageShow(entity)) return;

    if(display == 0){
      
    }else if(display == 1){
      showBanner(entity);
    }else if(display == 2){
      showToast(entity);
    }else if(display == 4){
      showModal([entity]);
    }
  }

  /// 管理端消息的设置
  bool getManageMessageShow(PushMessageEntity entity){
    if(entity.categoryIsManage){
      bool show = StorageUtil().getBool(MANAGE_MESSAGE_SHOW_KEY);
      return show;
    }
    return true;
  }

  /// 停止消费消息队列
  void _stopDispatchMessage() {
    _messageTimer?.cancel();
    _messageTimer = null;
  }

  /// 销毁监听
  void dispose(){
    _messageSub?.cancel();
    _messageSub = null;
    _stopDispatchMessage();
  }

  /// 检查路由
  void _checkRoute(String? routeName) {
    print("------------- $routeName");
    if(routeName == null) return;
    // 如果当前路由命中黑名单，则暂停弹窗，只缓存消息
    if (blacklistRouteList.contains(routeName)) {
      _isPaused = true;
      _stopDispatchMessage();
    } else {
      // 离开黑名单页面后，恢复队列消费
      _isPaused = false;
      _startDispatchMessage();
    }
  }

  /// 监听路由进入
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _checkRoute(route.settings.name);
  }

  /// 监听路由返回（比如从做题页面退回，需要恢复推送）
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _checkRoute(previousRoute?.settings.name);
  }

}