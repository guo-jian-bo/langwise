



import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/public_controller/manage_sandbox_controller.dart';
import '../../../../common/stores/stores.dart';
import '../../../../utils/utils.dart';

class MessageController extends GetxController{
  
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

  /// 获取初始消息列表
  Future<void> getInitMessageList({bool isNotification = true}) async{
    if(ManageSandboxController.to.isSimulate) return;
    try {
      Map<String, dynamic> parameters = {
        "offset": 0,
        "limit": 100,
        "order": "-uid",
        "category": "SYSTEM",
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
        if(element.content?.isEmpty == true) continue;
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
        "category": "SYSTEM",
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
    // testMessage();
    // return;
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
        "category": "SYSTEM",
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
  Future<void> toDetils(PushMessageEntity message) async{
    // 先关闭抽屉
    Get.back();

    readMessage(message);
    if((message.content??"").isNotEmpty){
      MqttNotificationToast.showModal(messages: [message]);
    } else if((message.content??"").isEmpty && message.jump != null){
      await JumpPageUtils.jumpPage(message);
    } 
  }

  @override
  void onClose() {
    try {
      scrollController.removeListener(scrollControllerListener);
    } catch (_) {}
    super.onClose();
  }

  /// 测试消息
  void testMessage(){
    String mdText = '''# 🎉 欢迎来到《乃师》！送你一份见面礼。

## Hi 新同学，很兴遇见你！

送你 **Max 会员**，全场会员功能都为你敞开。  
感受情景化学习英语的乐趣，走进 **「甄听」** 与 **「甄读」** 的世界，  
让语言在真实语境中自然生长。

趁这个机会，尽情探索吧。  
**乃师** 陪你，让每天都有新收获。

### 在以下页面可以看到会员时长：
![我的](https://openpic.timelywise.cn/knowledge/semantic/sbKNJZaMTr8Pv3m5PoCi1FL0AgItUQNggEwJCH1zc0ZsKYCv.png)
![会员时长](https://openpic.timelywise.cn/knowledge/semantic/lSOeIxbYv86ZmzigMg2cn74vxWhSA4MewXFCC0pyIp2icE0n.png)

---

🔗 **相关推荐**：[**乃师**](https://timelywise.cn/) —— 用科学和智能重新定义语言学习体验''';  


    MqttNotificationMessage.instance.showModal([
      PushMessageEntity(
        uid: 1,
        title: "测试消息",
        content: mdText,
        contentType: "md",
        display: 4,
        report: false,
      ),
      PushMessageEntity(
        uid: 2,
        title: "测试消息",
        content: "我是测试消息我是测试消息我是测试消息",
        display: 4,
        report: false,
      ),
    ]);

    Mqtt5ClientUtils.instance.manualSetMessage([
      PushMessageEntity(
        uid: 1,
        title: "测试消息",
        content: "我是测试消息我是测试消息我是测试消息",
        display: 1,
        jump: PushMessageEntityJump(),
        report: false,
        displayOperate: 1,
      ),
      PushMessageEntity(
        uid: 2,
        title: "测试消息",
        content: "我是测试消息我是测试消息我是测试消息",
        display: 1,
        report: false,
      ),  
    ]);

  }



}
