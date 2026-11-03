



import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/stores/stores.dart';
import '../../../../utils/utils.dart';

class ManageMessageController extends GetxController{

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  
  final ScrollController scrollController = ScrollController();
  int totalCount = 0;
  int offset = 0;
  int limit = 50;
  final RxBool loading = true.obs;
  final RxList<PushMessageEntity> messageList = <PushMessageEntity>[].obs;
  /// 当前未读消息数量
  final RxInt unreadCount = 0.obs;


  @override
  void onInit() {
    super.onInit();
    if(UserStore.to.isLogin){
      scrollController.addListener(scrollControllerListener);
    }
  }


  void scrollControllerListener(){
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100 && !scrollController.position.outOfRange) {
      if ((offset + limit) < totalCount && !loading.value) {
        loading.value = true;
        offset += limit;
        getMessageList();
      }
    }
  }

  Future<void> initData() async{
    offset = 0;
    totalCount = 0;
    messageList.clear();
    await getMessageList();
  }

  /// 打开抽屉
  void openEndDrawer(BuildContext context){
    Scaffold.of(context).openEndDrawer();
    initData();
  }

  /// 获取初始消息列表
  Future<void> getInitMessageList({bool isNotification = true}) async{
    try {
      Map<String, dynamic> parameters = {
        "offset": 0,
        "limit": 100,
        "order": "-uid",
        "category": "MANAGE",
      };
      ListResponseEntity<PushMessageEntity>? res = await AccountUtil.getInitMessageList(parameters: parameters);
      if(res == null) return;
      unreadCount.value = res.unreadCount??0;
      List<PushMessageEntity> datas = res.datas??[];
      if(datas.isEmpty) return;

      if(!isNotification) return;

      // 上报消息 已经弹出了
      MqttNotificationMessage.instance.reportAlready(datas);

      // 模态弹窗消息
      List<PushMessageEntity> modalList = [];
      // 其他队列消息
      List<PushMessageEntity> queueList = [];

      for (var element in datas) {
        if(element.uid == null) continue;
        if(element.display == 4){
          modalList.add(element);
        }else{
          queueList.add(element);
        }
      }
      MqttNotificationMessage.instance.showModal(modalList);
      Mqtt5ClientUtils.instance.manualSetMessage(queueList);

    } catch (_) {}
  }

  Future<void> getMessageList() async{
    try {
      loading.value = true;

      Map<String, dynamic> parameters = {
        "offset": offset,
        "limit": limit,
        "order": "-uid",
        "category": "MANAGE",
      };

      ListResponseEntity<PushMessageEntity>? res = await AccountUtil.getMessageList(parameters: parameters);
      if(res == null) return;
      totalCount = res.count??0;
      messageList.addAll(res.datas??[]);

    } finally{
      loading.value = false;
    }
  }

  /// 读消息
  Future<void> readMessage(PushMessageEntity message) async{
    if(message.read == 1) return;
    if(message.uid == null) return;
    try {
      bool res = await AccountUtil.readMessage([message.uid!]);
      if(!res) return;
      message.read = 1;
      messageList.refresh();
      getInitMessageList();
    } catch (_) {
      
    }
  }

  /// 一键已读
  Future<void> allReadMessage() async{
    try {
      loading.value = true;
      Map<String, dynamic> parameters = {
        "category": "MANAGE",
      };
      bool res = await AccountUtil.readAllMessage(parameters: parameters);
      if(!res) return;
      for (var element in messageList) {
        element.read = 1;
      }
      messageList.refresh();
      getInitMessageList();
      ToastUtils.showToast(text: "已将所有消息标记为已读", type: ToastType.success);
    } finally{
      loading.value = false;
    }
  }

    /// 查看详情
  Future<void> toDetils(PushMessageEntity message, {void Function(PushMessageEntity message)? onPageBack}) async{
    // 先关闭抽屉
    Get.back();

    readMessage(message);

    if(message.jump != null){
      await JumpPageUtils.jumpPage(message);
      onPageBack?.call(message);
    }else if((message.content??"").isNotEmpty){
      MqttNotificationToast.showModal(messages: [message]);
    }

    // if(message.content?.isEmpty == true && message.jump != null){
    //   await JumpPageUtils.jumpPage(message);
    //   onPageBack?.call(message);
    // }else if(message.content?.isNotEmpty == true){
    //   MqttNotificationToast.showModal(messages: [message]);
    // }

  }

  @override
  void dispose() {
    super.dispose();
    scrollController.removeListener(scrollControllerListener);
  }

}
