import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:json_editor_2/json_editor.dart';
import 'package:langwise/common/widgets/widgets.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../enums/enums.dart';
import '../../../../utils/utils.dart';
import '../../../common/manage_select_ticket_dialog.dart';
import '../views/manage_notice_temp_create_full_md_dialog.dart';


class ManageNoticeTempCreateController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageNoticeTempCreateController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_NOTICE_TEMP_CREATE;

  @override
  String get breadcrumbTitle => '新建通知模版';

  // 传来进来的参数
  NotifyTempEntity? noticeTemp;

  /// 是否启用
  final RxBool isEnable = true.obs;

  /// 模版名称 输入框
  final TextEditingController tempNameController = TextEditingController();

  /// 模版消息类型列表
  final RxList<NotifyTempTypeEntity> notifyTempTypeList = <NotifyTempTypeEntity>[].obs;

  /// 分组
  final RxString notifyTempType = ''.obs;

  /// 选择的工单模版
  final Rx<ManageTicketTempEntity?> selectedTicketTemp = Rx(null);

  /// Push 标题 输入框
  final TextEditingController pushTitleController = TextEditingController();

  /// Push 内容 输入框
  final TextEditingController pushContentController = TextEditingController();

  /// 通知内容类型
  final Rx<NoticeContentTypeEnum> noticeContentType = NoticeContentTypeEnum.md.obs;

  /// Markdown 编辑 输入框
  final TextEditingController markdownController = TextEditingController();
  /// Markdown 预览
  final RxString markdownPreview = ''.obs;

  /// 选择的跳转配置
  final Rx<AppRoutesGroupData?> selectedJumpType = Rx(null);
  /// 跳转参数 Json 编辑器
  final RichTextEditingController jsonEditorController = RichTextEditingController();

  /// H5链接 输入框
  final TextEditingController h5LinkController = TextEditingController();
  /// H5是否竖屏
  final RxBool isH5Portrait = false.obs;
  /// H5是否跳转外部浏览器
  final RxBool isH5OpenExternalBrowser = false.obs;


  

  @override
  void onInit() {
    super.onInit();
    if(Get.arguments != null){
      noticeTemp = Get.arguments['noticeTemp'];
    }
    initBreadcrumb(tag, title: noticeTemp != null ? "编辑通知模版": "新建通知模版");
    setEditInfo();
    getNotifyTempType();
  }

  /// 设置编辑信息
  void setEditInfo(){
    if(noticeTemp == null) return;
    isEnable.value = noticeTemp!.access == AccessEnum.NORMAL.value;
    tempNameController.text = noticeTemp!.name??"";
    if(noticeTemp!.type != null){
      notifyTempType.value = noticeTemp!.type??"";
    }
    pushTitleController.text = noticeTemp!.notifyTitle??"";
    pushContentController.text = noticeTemp!.notifyDesc??"";
    noticeContentType.value = NoticeContentTypeEnum.fromValue(noticeTemp!.notifyContentType) ?? NoticeContentTypeEnum.md;
    markdownController.text = noticeTemp!.notifyContent??"";
    markdownPreview.value = noticeTemp!.notifyContent??"";
    selectedTicketTemp.value = ManageTicketTempEntity(
      uid: noticeTemp!.typeContentId,
      // TODO: 缺少工单模版名称
    );

    final PushMessageEntityJump? jump = noticeTemp!.notifyJump;
    if(jump == null) return;
    final String? code = jump.code;
    if(code == null || code.isEmpty) return;

    final AppRoutesGroupData? jumpType = _findJumpTypeByCode(code);
    final AppRoutesGroupData resolvedJumpType = jumpType ?? AppRoutesGroupData(appCode: code, title: code);
    switchJumpType(resolvedJumpType);

    if(code == AppRoutesCode.webView){
      final Map<String, dynamic> params = jump.params ?? <String, dynamic>{};
      h5LinkController.text = params["url"]?.toString() ?? "";
      isH5Portrait.value = params["portrait"] == true;
      isH5OpenExternalBrowser.value = params["openExternalBrowser"] == true;
      return;
    }

    final Map<String, dynamic>? params = jump.params;
    if(params == null || params.isEmpty){
      jsonEditorController.clear();
      return;
    }
    if(jumpType?.params == null || jumpType!.params!.isEmpty) return;
    jsonEditorController.text = jsonEncode(params);
    
    
  }

  AppRoutesGroupData? _findJumpTypeByCode(String code){
    return AppRoutesGroup.webViewMap[code] ??
        AppRoutesGroup.learningMap[code] ??
        AppRoutesGroup.contentMap[code] ??
        AppRoutesGroup.userMap[code];
  }


  /// 获取模版消息类型列表
  Future<void> getNotifyTempType() async{
    List<NotifyTempTypeEntity>? list = await AccountConsoleRequest.getNotifyTempType();
    if(list == null) return;
    notifyTempTypeList.value = list;
    if(list.isEmpty) return;

    if(noticeTemp != null) return;
    notifyTempType.value = list.first.type??"";
  }

  /// 选择工单模版
  Future<void> selectWorkOrderTemp(BuildContext context) async{
    ManageTicketTempEntity? res = await ManageSelectTicketDialog.show(
      context: context,
      defaultTicketTemp: selectedTicketTemp.value,
    );
    if(res == null) return;
    selectedTicketTemp.value = res;
  }


  /// 显示大编辑器
  Future<void> showFullMdDialog(BuildContext context) async{
    String? res = await ManageNoticeTempCreateFullMdDialog.show(
      context: context, 
      markdownText: markdownController.text,
      noticeContentType: noticeContentType.value,
    );
    if(res == null) return;
    markdownController.text = res;
    markdownPreview.value = res;
  }


  /// 切换跳转类型
  void switchJumpType(AppRoutesGroupData? value){
    selectedJumpType.value = value;
    h5LinkController.clear();
    isH5Portrait.value = false;
    isH5OpenExternalBrowser.value = false;
    jsonEditorController.clear();
    if(value?.appCode == null) return;
    if(value?.appCode == AppRoutesCode.webView) return;
    if(value?.params == null) {
      jsonEditorController.clear();
      return;
    }
    if(value?.params == null) return;

    jsonEditorController.text = _buildJumpParamsElement(value?.params).toString();
  }

  /// 构建跳转参数编辑器数据
  JsonElement _buildJumpParamsElement(List<AppRoutesGroupParamData>? params) {
    return JsonElement(
      valueType: JsonElementValueType.map,
      value: (params ?? <AppRoutesGroupParamData>[]).map(_buildParamJsonElement).toList(),
    );
  }

  /// 构建单个跳转参数节点
  JsonElement _buildParamJsonElement(AppRoutesGroupParamData param) {
    final dynamic value = _normalizeJumpParamValue(param.value);
    final JsonElementValueType valueType = _getJsonElementValueType(value);

    if (valueType == JsonElementValueType.map) {
      return JsonElement(
        key: param.key,
        comment: param.hintText,
        valueType: JsonElementValueType.map,
        value: _buildMapChildren(value as Map).toList(),
      );
    }

    if (valueType == JsonElementValueType.array) {
      return JsonElement(
        key: param.key,
        comment: param.hintText,
        valueType: JsonElementValueType.array,
        value: _buildListChildren(value as List).toList(),
      );
    }

    return JsonElement(
      key: param.key,
      comment: param.hintText,
      valueType: valueType,
      value: value,
    );
  }

  /// 构建 Map 类型的子节点
  Iterable<JsonElement> _buildMapChildren(Map<dynamic, dynamic> value) {
    return value.entries.map((entry) {
      return _buildJsonElementByValue(
        key: entry.key.toString(),
        value: entry.value,
      );
    });
  }

  /// 构建 List 类型的子节点
  Iterable<JsonElement> _buildListChildren(List<dynamic> value) {
    return value.map((item) {
      return _buildJsonElementByValue(value: item);
    });
  }

  /// 根据值构建 Json 节点
  JsonElement _buildJsonElementByValue({
    String? key,
    dynamic value,
    String? comment,
  }) {
    value = _normalizeJumpParamValue(value);
    final JsonElementValueType valueType = _getJsonElementValueType(value);
    if (valueType == JsonElementValueType.map) {
      return JsonElement(
        key: key,
        comment: comment,
        valueType: JsonElementValueType.map,
        value: _buildMapChildren(value as Map).toList(),
      );
    }
    if (valueType == JsonElementValueType.array) {
      return JsonElement(
        key: key,
        comment: comment,
        valueType: JsonElementValueType.array,
        value: _buildListChildren(value as List).toList(),
      );
    }
    return JsonElement(
      key: key,
      comment: comment,
      valueType: valueType,
      value: value,
    );
  }

  /// 归一化跳转参数值
  dynamic _normalizeJumpParamValue(dynamic value) {
    if (value == null) return null;
    return value;
  }

  /// 获取 Json 节点值类型
  JsonElementValueType _getJsonElementValueType(dynamic value) {
    if (value is num) return JsonElementValueType.numeric;
    if (value is bool) return JsonElementValueType.bool;
    if (value is Map) return JsonElementValueType.map;
    if (value is List) return JsonElementValueType.array;
    return JsonElementValueType.string;
  }

  /// 组装参数
  Map<String, dynamic>? getReqData(){
    if(tempNameController.text.isEmpty) {
      ToastUtils.showToast(text: "请输入模版名称");
      return null;
    }
    if(notifyTempType.value.isEmpty) {
      ToastUtils.showToast(text: "请选择分组");
      return null;
    }
    if(notifyTempType.value == "wordAssistance"){
      if(selectedTicketTemp.value == null){
        ToastUtils.showToast(text: "请选择工单模版");
        return null;
      }
    }

    if(pushTitleController.text.isEmpty) {
      ToastUtils.showToast(text: "请输入Push标题");
      return null;
    }
    if(pushContentController.text.isEmpty) {
      ToastUtils.showToast(text: "请输入Push内容");
      return null;
    }
    if(selectedJumpType.value?.appCode == AppRoutesCode.webView){
      if(h5LinkController.text.isEmpty){
        ToastUtils.showToast(text: "请输入H5链接地址");
        return null;
      }
    }

    Map<String, dynamic>? notifyJump;
    if(selectedJumpType.value?.appCode == AppRoutesCode.webView){
      // if(!GetUtils.isURL(h5LinkController.text)){
      //   ToastUtils.showToast(text: "请输入正确的H5链接");
      //   return null;
      // }
      notifyJump = {
        "code": AppRoutesCode.webView,
        "params": {
          "url": h5LinkController.text,
          "portrait": isH5Portrait.value,
          "openExternalBrowser": isH5OpenExternalBrowser.value,
        },
      };
    }else if(selectedJumpType.value?.appCode != null){
      notifyJump = {
        "code": selectedJumpType.value?.appCode,
        "params": _getJumpParamsJson(),
      };
    }

    Map<String, dynamic> data = {
      "name": tempNameController.text,
      "type": notifyTempType.value,
      "notifyTitle": pushTitleController.text,
      "notifyDesc": pushContentController.text,
      "notifyContentType": noticeContentType.value.value,
      "notifyContent": markdownController.text,
      "access": isEnable.value ? AccessEnum.NORMAL.value : AccessEnum.INTERNAL.value,
      "notifyJump": notifyJump,
    };

    if(selectedTicketTemp.value != null && notifyTempType.value == "wordAssistance"){
      data["typeContentId"] = selectedTicketTemp.value?.uid;
    }

    return data;
  }

  /// 获取跳转参数 Json
  Map? _getJumpParamsJson() {
    try {
      final String jsonText = jsonEditorController.text.trim();
      if (jsonText.isEmpty) return null;
      JsonElement jsonElement = JsonElement.fromString(jsonText);
      final Object value = jsonElement.toObject();
      if (value is Map) return _stringKeyMap(value);
      if (value is List) return _mergeListMapToMap(value);
      return null;
    } catch (_) {
      ToastUtils.showToast(text: "跳转参数 JSON 格式错误");
      return null;
    }
  }

  Map<String, dynamic> _stringKeyMap(Map<dynamic, dynamic> map) {
    final Map<String, dynamic> result = <String, dynamic>{};
    map.forEach((dynamic key, dynamic value) {
      result[key.toString()] = value;
    });
    return result;
  }

  Map<String, dynamic>? _mergeListMapToMap(List<dynamic> list) {
    if (list.isEmpty) return <String, dynamic>{};
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final dynamic item in list) {
      if (item is! Map) return null;
      result.addAll(_stringKeyMap(item));
    }
    return result;
  }

  /// 删除模版
  Future<void> deleteNoticeTemp(BuildContext context) async{
    if(noticeTemp?.uid == null) return ToastUtils.showToast(text: "模版uid为空");
    bool? askRes = await AskDialog.showUserCancelAsk(
      context: context,
      title: "确认删除",
      content: "确认删除 ${noticeTemp?.name}  模版吗？",
    );
    if(askRes != true) return;

    try {
      ToastUtils.showLoading();
      if(noticeTemp == null) return;
      await AccountConsoleRequest.deleteNoticeTemp(uid: noticeTemp!.uid!);
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      Get.back(result: -1);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 创建通知模版
  Future<void> createNoticeTemp() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic>? data = getReqData();
      if(data == null) return;
      NotifyTempEntity? res = await AccountConsoleRequest.createNoticeTemp(data: data);
      if(res == null) return;
      ToastUtils.showToast(text: "创建成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 编辑通知模版
  Future<void> editNoticeTemp() async{
    if(noticeTemp?.uid == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic>? data = getReqData();
      if(data == null) return;
      NotifyTempEntity? res = await AccountConsoleRequest.editNoticeTemp(uid: noticeTemp!.uid!, data: data);
      if(res == null) return;
      ToastUtils.showToast(text: "编辑成功", type: ToastType.success);
      Get.back(result: res);
    } finally{
      ToastUtils.hideLoading();
    }
  }




  @override
  void onClose() {
    tempNameController.dispose();
    pushTitleController.dispose();
    pushContentController.dispose();
    markdownController.dispose();
    jsonEditorController.dispose();
    h5LinkController.dispose();
    super.onClose();
  }
}
