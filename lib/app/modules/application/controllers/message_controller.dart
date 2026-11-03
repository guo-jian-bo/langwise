



import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
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
    if(message.jump != null){
      await JumpPageUtils.jumpPage(message);
    }else{
      MqttNotificationToast.showModal(messages: [message]);
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.removeListener(scrollControllerListener);
  }

  /// 测试消息
  void testMessage(){
    String mdText = '''# Markdown 样式测试文档

## 1. 标题级别
# H1 标题
## H2 标题
### H3 标题
#### H4 标题
##### H5 标题
###### H6 标题

## 2. 文本样式
- *斜体文本* 或 _斜体文本_
- **粗体文本** 或 __粗体文本__
- ***粗斜体文本*** 或 ___粗斜体文本___
- ~~删除线文本~~
- <u>下划线文本</u> (HTML 标签)
- 上标：X<sup>2</sup>
- 下标：H<sub>2</sub>O
- `行内代码`

## 3. 列表

### 无序列表
- 项目 1
- 项目 2
  - 嵌套项目 2.1
  - 嵌套项目 2.2
- 项目 3

### 有序列表
1. 第一项
2. 第二项
   1. 嵌套 2.1
   2. 嵌套 2.2
3. 第三项

### 任务列表
- [x] 已完成任务
- [ ] 未完成任务
- [ ] 待办事项

## 4. 链接
[普通链接](https://www.example.com)
[带标题的链接](https://www.example.com "鼠标悬停显示")
<https://直接链接.com>
[相对链接](./另一个文件.md)

## 5. 图片
![](https://picsum.photos/200/150 "图片标题")
[![带链接的图片](https://picsum.photos/100/50)](https://example.com)

## 6. 引用块
> 这是一级引用
> > 这是嵌套引用
> > > 这是三级引用
>
> 返回一级引用

## 7. 代码块

### 行内代码
使用 `console.log('Hello World')` 输出内容。

### 围栏代码块
```javascript
// JavaScript 示例
function greet(name) {
    return `Hello, \${name}!`;
}
console.log(greet("Markdown"));''';  


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

    // Mqtt5ClientUtils.instance.manualSetMessage([
    //   PushMessageEntity(
    //     uid: Random().nextInt(1000),
    //     title: "测试消息",
    //     content: "我是测试消息我是测试消息我是测试消息",
    //     display: 1,
    //     jump: PushMessageEntityJump(),
    //     report: false,
    //     displayOperate: 1,
    //   ),
    //   PushMessageEntity(
    //     uid: Random().nextInt(1000),
    //     title: "测试消息",
    //     content: "我是测试消息我是测试消息我是测试消息",
    //     display: 1,
    //     report: false,
    //   ),  
    // ]);

  }



}
