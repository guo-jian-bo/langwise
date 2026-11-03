import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../elements/utils/elements_page_utils.dart';
import '../../../../common/ass_edit_widgets/models/ass_waveform_dialogue_model.dart';
import '../../../../utils/utils.dart';

class ManageReviewAssDetilsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageReviewAssDetilsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_REVIEW_ASS_DETILS;

  @override
  String get breadcrumbTitle => '编辑字幕';

  /// 页面参数
  int? assTaskId;
  /// 页面参数 如果不为null 则此页面为编辑字幕
  int? assId;
  /// 是否隐藏添加句子按钮
  bool hideAddSentence = true;

  /// 当前任务详情。
  final Rx<AssTaskEntityList> assData = AssTaskEntityList().obs;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      assTaskId = Get.arguments['assTaskId'];
      assId = Get.arguments['assId'];
      final dynamic hideAddSentenceArg = Get.arguments['hideAddSentence'];
      if (hideAddSentenceArg is bool) {
        hideAddSentence = hideAddSentenceArg;
      } 
      getDataDetils();
      
    }
  }

  /// 获取任务详情，并在成功后解析当前任务的 ASS 数据。
  Future<void> getDataDetils() async {
    if (assTaskId == null && assId == null) return;
    try {
      ToastUtils.showLoading();
      
      AssTaskEntityList? res;

      if(assId != null){ // 不为null为编辑字幕 需要请求管理端接口
        final Map<String, dynamic> reqData = <String, dynamic>{
          "assId": assId,
        };
        res = await LanguageConsoleRequest.getAssDatils(data: reqData);
      }else{
        final Map<String, dynamic> reqData = <String, dynamic>{
          "assTaskId": assTaskId,
        };
        res = await LanguageUtil.getAssDatils(data: reqData);
      }

      if (res == null) return;
      assData.value = res;
    } finally {
      ToastUtils.hideLoading();
    }
  }


  /// 预览字幕
  Future<void> previewAss(BuildContext context) async{

    /// 是否是管理端的标识 随机UUID
    String traceAdminHeader = const Uuid().v4();

    ElementsPageUtils.jumpElementsPage(
      contentId: assData.value.contentId,
      contentType: assData.value.contentType,
      semanticId: null,
      styleId: null,
      dialect: null,
      isManagement: true,
      traceAdminHeader: traceAdminHeader,
      contents: [
        {"contentId": assData.value.contentId, "contentType": assData.value.contentType},
      ],
    );
  }

  /// 保存字幕编辑
  Future<void> saveEditAss(AssEditorChangeResult value) async{
    // final AssTaskEntityList data = assData.value;
    // data.ass = value.ass;
    // data.translate = value.translateAss == null || value.translateAss!.trim().isEmpty
    //     ? null
    //     : <LanguageText>[
    //         LanguageText(lang: 'zh', text: value.translateAss),
    //       ];
    // data.content = value.dialogueList
    //     .map((item) => (item.text ?? '').trim())
    //     .where((item) => item.isNotEmpty)
    //     .join('\n');

    if(assData.value.assId == null) return;

    try {
      Map<String, dynamic> reqData = {
        "assId": assData.value.assId,
        "ass": value.ass,
      };
      bool res = await LanguageUtil.assReviewAssEdit(data: reqData);
      if(!res) return;
    } finally{
      
    }
  }

  /// 删除并新建
  Future<void> assReviewDeleteCreateAlign(BuildContext context) async{

    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "删除并新建",
      content: "确定删除此任务并重新创建吗？",
    );
    if(!ask) return;

    try {
      ToastUtils.showLoading();

      String? res;
      if(assData.value.mediaTypeEnum == ResourceTypeEnum.audio){
        Map<String, dynamic> reqData = {
          "assTaskId": assData.value.taskId,
        };
        res = await LanguageConsoleRequest.assReviewCreateAudioAlign(data: reqData);
      }else{
        Map<String, dynamic> reqData = {
          "assTaskId": assData.value.taskId,
        };
        res = await LanguageConsoleRequest.assReviewCreateVideoAlign(data: reqData);
      }
      
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 新建字幕
  Future<void> assReviewCreateAlign() async{

    try {
      ToastUtils.showLoading();

      String? res;
      if(assData.value.mediaTypeEnum == ResourceTypeEnum.audio){
        Map<String, dynamic> reqData = {
          "audioUid": assData.value.mediaUid,
        };
        res = await LanguageConsoleRequest.assReviewCreateAudioAlign(data: reqData);
      }else{
        Map<String, dynamic> reqData = {
          "videoUid": assData.value.mediaUid,
        };
        res = await LanguageConsoleRequest.assReviewCreateVideoAlign(data: reqData);
      }
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 新建翻译
  Future<void> assReviewCreateTranslate() async{
    if(assData.value.assId == null)  return ToastUtils.showToast(text: "请先审核字幕");

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "assId": assData.value.assId,
      };
      String? res = await LanguageConsoleRequest.assReviewCreateTranslate(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 字幕定稿
  Future<void> finalDraftAss(BuildContext context) async{
    bool askRes = await AskDialog.showUserAsk(
      context: context, 
      title: "温馨提示",
      content: "您确定要将此字幕定稿吗？",
    );

    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": assData.value.assRelationId,
      };
      bool res = await LanguageConsoleRequest.finalDraftAss(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "定稿成功", type: ToastType.success);
      assData.value.assLocked = true;
      assData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 字幕取消定稿
  Future<void> cancelFinalDraftAss(BuildContext context) async{
    bool askRes = await AskDialog.showUserAsk(
      context: context, 
      title: "温馨提示",
      content: "您确定要取消字幕定稿吗？",
    );

    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": assData.value.assRelationId,
      };
      bool res = await LanguageConsoleRequest.unlockDraftAss(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "取消定稿成功", type: ToastType.success);
      assData.value.assLocked = false;
      assData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 删除任务
  Future<void> deleteTask(BuildContext context) async{
    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "删除任务",
      content: "确定删除此任务吗？",
    );
    if(!ask) return;
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqDtaa = {
        "assTaskId": assData.value.taskId,
      };
      bool res = await LanguageConsoleRequest.assReviewDeleteTask(data: reqDtaa);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      Get.back(result: true);

    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 放弃任务
  Future<void> assReviewAbandon(BuildContext context) async{
    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "删除任务",
      content: "确定放弃此任务吗？",
    );
    if(!ask) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "assTaskId": assData.value.taskId,
      };
      bool res = await LanguageUtil.assReviewAbandon(data: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "放弃成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 审核通过
  Future<void> assReviewAssApprove(BuildContext context) async{
    if(assData.value.hasAssApprove == true){
      bool ask = await AskDialog.showUserAsk(
        context: context,
        title: "温馨提示",
        content: "当前知识点已有审核通过的字幕，是否替换？",
      );
      if(!ask) return;
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "assTaskId": assData.value.taskId,
      };
      bool res = await LanguageUtil.assReviewAssApprove(data: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "审核成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  


  @override
  void onClose() {
    super.onClose();
  }
}
