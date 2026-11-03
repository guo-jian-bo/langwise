import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../../../common/manage_select_employee_dialog.dart';
import '../models/manage_sub_channel_model.dart';

class ManageChannelCreateController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageChannelCreateController({required this.tag});

  /// 页面初始表单快照，用于判断是否存在未保存内容
  String _initialFormSnapshot = "";

  @override
  String get breadcrumbRoute => Routes.MANAGE_CHANNEL_CREATE;

  @override
  String get breadcrumbTitle => '新建一级渠道';

  // 传进来的参数
  /// 渠道uid 如果不为null则为编辑
  int? channelUid;

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();

  /// 一级渠道名称 输入框
  final TextEditingController channelNameController = TextEditingController();

  /// 一级渠道code 输入框
  final TextEditingController channelCodeController = TextEditingController();

  /// 唯一ID 输入框
  final TextEditingController uniqueIdController = TextEditingController();

  /// 描述 输入框
  final TextEditingController descriptionController = TextEditingController();

  /// 是否启用 切换按钮
  final RxBool isEnable = true.obs;

  /// 二级渠道列表
  final RxList<ManageSubChannelModel> subChannelList = <ManageSubChannelModel>[].obs;


  @override
  void onInit() {
    super.onInit();
    _initialFormSnapshot = _getFormSnapshot();
    if(Get.arguments != null){
      channelUid = Get.arguments["channelUid"];
      getChannelDetail();
    }
    initBreadcrumb(tag, title: channelUid == null ? "新建一级渠道" : "编辑一级渠道");
  }


  /// 查询渠道详情
  Future<void> getChannelDetail() async{
    if(channelUid == null) return;
    try {
      ToastUtils.showLoading();
      ManageChannelEntity? channel = await AccountConsoleRequest.getChannelDetail(channelUid: channelUid!);
      if(channel == null) return;
      channelNameController.text = channel.name??"";
      channelCodeController.text = channel.code??"";
      uniqueIdController.text = channel.uid?.toString()??"";
      descriptionController.text = channel.description??"";
      isEnable.value = channel.access == AccessEnum.NORMAL.value;
      List<ManageChannelEntityChildren> subChannelListData = channel.children??[];

      for(int i = 0; i < subChannelListData.length; i++){
        subChannelList.add(ManageSubChannelModel(
          child: subChannelListData[i],
          subChannelNameController: TextEditingController(text: subChannelListData[i].name??""),
          remarkController: TextEditingController(text: subChannelListData[i].remark??""),
          subChannelCodeController: TextEditingController(text: subChannelListData[i].code??""),
          isEnable: subChannelListData[i].access == AccessEnum.NORMAL.value,
          ownerId: subChannelListData[i].ownerId,
          ownerName: subChannelListData[i].ownerName,
          key: GlobalKey(),
        ));
      }

      // 编辑态详情加载完成后，更新初始快照，避免误判为“已修改”
      _initialFormSnapshot = _getFormSnapshot();

    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 启用/停用一级渠道
  void toggleEnable() {
    isEnable.value = !isEnable.value;
  }

  /// 添加二级渠道
  void addSubChannel() {
    subChannelList.add(ManageSubChannelModel(
      subChannelNameController: TextEditingController(),
      remarkController: TextEditingController(),
      subChannelCodeController: TextEditingController(),
      key: GlobalKey(),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });

  }

  /// 删除二级渠道
  void removeSubChannel(int index) {
    subChannelList.removeAt(index);
  }

  /// 切换二级渠道的启用状态
  void toggleSubChannelEnable(ManageSubChannelModel subChannel) {
    subChannel.isEnable = !subChannel.isEnable;
    subChannelList.refresh();
  }

  /// 选择二级渠道负责人
  Future<void> selectResponsiblePerson(BuildContext context, ManageSubChannelModel subChannel) async {
    ManageUserRoleEntity? res = await ManageSelectEmployeeDialog.show(context: context, title: "选择负责人");
    if(res == null) return;
    subChannel.ownerId = res.userId;
    subChannel.ownerName = res.realName;
    subChannelList.refresh();
    
  }


  /// 获取当前表单快照，用于新建未保存和编辑已修改判断
  String _getFormSnapshot() {
    return {
      "name": channelNameController.text,
      "code": channelCodeController.text,
      "description": descriptionController.text,
      "access": isEnable.value,
      "children": subChannelList.map((item) {
        return {
          "uid": item.child?.uid,
          "name": item.subChannelNameController.text,
          "ownerId": item.ownerId,
          "ownerName": item.ownerName,
          "remark": item.remarkController.text,
          "code": item.subChannelCodeController.text,
          "access": item.isEnable,
        };
      }).toList(),
    }.toString();
  }

  /// 返回页面前检查是否存在未保存内容
  Future<void> onBackPage(BuildContext context) async {
    if(_initialFormSnapshot == _getFormSnapshot()) {
      Get.back();
      return;
    }
    bool? askRes = await AskDialog.showUserCancelAsk(
      context: context,
      title: "还未保存",
      content: "当前内容还未保存，确认退出吗？",
    );
    if(askRes == true) {
      Get.back();
    }
  }


  /// 删除渠道
  Future<void> deleteChannel(BuildContext context) async{
    if(channelUid== null) return ToastUtils.showToast(text: "渠道uid为空");
    bool? askRes = await AskDialog.showUserCancelAsk(
      context: context,
      title: "确认删除",
      content: "确认删除 ${channelNameController.text} 渠道吗？",
    );
    if(askRes != true) return;
    try {
      ToastUtils.showLoading();
      bool isSuccess = await AccountConsoleRequest.deleteChannel(uid: channelUid!);
      if(!isSuccess) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      Get.back(result: -1);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 组装参数
  Map<String, dynamic>? getReqData(){
    if(channelNameController.text.isEmpty){
      ToastUtils.showToast(text: "请输入一级渠道名称");
      scrollController.animateTo(
        scrollController.position.minScrollExtent, 
        duration: Duration(milliseconds: 200), 
        curve: Curves.ease,
      );
      return null;
    }

    if(channelCodeController.text.isEmpty){
      ToastUtils.showToast(text: "请输入一级渠道code");
      scrollController.animateTo(
        scrollController.position.minScrollExtent, 
        duration: Duration(milliseconds: 200), 
        curve: Curves.ease,
      );
      return null;
    }

    List<Map<String, dynamic>> subChannelListData = [];
    for (int i = 0; i < subChannelList.length; i++){
      if(subChannelList[i].subChannelNameController.text.isEmpty){
        ToastUtils.showToast(text: "请输入二级渠道名称");
        BuildContext? ctx = subChannelList[i].key.currentContext;
        if(ctx == null) return null;
        // 滚动到该表单项
        Scrollable.ensureVisible(ctx, duration: Duration(milliseconds: 200), alignment: 0.13);
        return null;
      }
      if(subChannelList[i].subChannelCodeController.text.isEmpty){
        ToastUtils.showToast(text: "请输入二级渠道code");
        BuildContext? ctx = subChannelList[i].key.currentContext;
        if(ctx == null) return null;
        // 滚动到该表单项
        Scrollable.ensureVisible(ctx, duration: Duration(milliseconds: 200), alignment: 0.13);
        return null;
      }

      Map<String, dynamic> subMap = {
        "name": subChannelList[i].subChannelNameController.text,
        "ownerId": subChannelList[i].ownerId,
        "ownerName": subChannelList[i].ownerName,
        "remark": subChannelList[i].remarkController.text,
        "code": subChannelList[i].subChannelCodeController.text,
        "access": isEnable.value ? AccessEnum.NORMAL.value : AccessEnum.INTERNAL.value,
      };
      if(subChannelList[i].child != null){
        subMap['uid'] = subChannelList[i].child?.uid;
      }
      subChannelListData.add(subMap);
    }

    Map<String, dynamic> data = {
      "name": channelNameController.text,
      "code": channelCodeController.text,
      "description": descriptionController.text,
      "access": isEnable.value ? AccessEnum.NORMAL.value : AccessEnum.INTERNAL.value,
      "children": subChannelListData,
    };

    return data;
  }

  /// 创建一级渠道
  Future<void> createChannel() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic>? data = getReqData();
      if(data == null) return;
      ManageChannelEntity? channelEntity = await AccountConsoleRequest.createChannel(data: data);
      if(channelEntity == null) return;
      ToastUtils.showToast(text: "创建成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 编辑渠道
  Future<void> editChannel() async{
    if(channelUid == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic>? data = getReqData();
      if(data == null) return;
      ManageChannelEntity? channelEntity = await AccountConsoleRequest.editChannel(uid: channelUid!, data: data);
      if(channelEntity == null) return;
      ToastUtils.showToast(text: "编辑成功", type: ToastType.success);
      Get.back(result: channelEntity);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
