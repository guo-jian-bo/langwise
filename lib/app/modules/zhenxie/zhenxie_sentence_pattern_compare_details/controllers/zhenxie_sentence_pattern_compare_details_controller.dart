import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/mixins/mixins.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../theme/theme.dart';
import '../views/zhenxie_edit_compare_group_dialog.dart';

class ZhenxieSentencePatternCompareDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxieSentencePatternCompareDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_SENTENCE_PATTERN_COMPARE_DETAILS;

  @override
  String get breadcrumbTitle => '句型对照详情';

  // 传进来的参数
  /// 句型对照详情
  final Rx<SentencePatternCompareEntity> detailData = SentencePatternCompareEntity().obs;
  /// nid
  String? nid;
  /// 是否是管理端入口打开
  bool isManagement = false;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      isManagement = Get.arguments["isManagement"] ?? false;
      nid = Get.arguments["nid"];
      getDetailData();
    }
  }

  /// 获取详情数据
  Future<void> getDetailData() async{
    if(nid == null) return;
    try {
      ToastUtils.showLoading();
      SentencePatternCompareEntity? res = await LanguageConsoleRequest.getSentencePatternCompareDetails(nid!);
      if(res == null) return;
      detailData.value = res;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 编辑名称说明
  Future<void> editNameDesc(BuildContext context) async{
    if(detailData.value.nid == null) return;

    EditNameDescDialogResult? res = await EditNameDescDialog.show(
      context: context,
      name: detailData.value.name,
      description: detailData.value.description,
    );
    if(res == null) return;
    try {
      ToastUtils.showLoading();
      List<Map<String, dynamic>> nameList = [];
      List<Map<String, dynamic>> descriptionList = [];
      res.name?.forEach((e) {
        nameList.add(e?.toJson()??{});
      });
      res.description?.forEach((e) {
        descriptionList.add(e?.toJson()??{});
      });

      Map<String, dynamic> reqData = {
        "name": nameList,
        "description": descriptionList,
      };

      SentencePatternCompareEntity? resp = await LanguageConsoleRequest.editSentencePatternCompare(
        nid: detailData.value.nid!,
        data: reqData,
      );
      if(resp == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      detailData.value = resp;
      detailData.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 编辑对照组
  Future<void> editCompareGroup(BuildContext context) async{
    await ZhenxieEditCompareGroupDialog.show(
      context: context,
      detailData: detailData.value,
    );
    await getDetailData();
  }

  /// 例句句子组上下架
  Future<void> exampleSentenceGroupShelf(SentencePatternCompareSentenceRealizationSetEntity? example) async {
    if(example == null) return ToastUtils.showToast(text: "对照信息为空");
    if(example.uid == null) return ToastUtils.showToast(text: "对照信息uid为空");
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": example.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
      };
      bool resp = await LanguageConsoleRequest.zhenxieExampleAccess(
        uid: example.uid!,
        data: reqData,
      );
      if(!resp) return;
      ToastUtils.showToast(text: "${example.isNormal ? "下架" : "上架"}成功", type: ToastType.success);
      example.access = example.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      detailData.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 删除句组
  Future<void> exampleSentenceGroupDelete(BuildContext context, SentencePatternCompareSentenceRealizationSetEntity? example) async {
    if(example == null) return ToastUtils.showToast(text: "对照信息为空");
    if(example.uid == null) return ToastUtils.showToast(text: "对照信息uid为空");
    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确认删除句子吗？",
      defineColor: AppTheme.cSurfaceError.color,
    );
    if(!ask) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": AccessEnum.DELETED.value,
      };
      bool resp = await LanguageConsoleRequest.zhenxieExampleAccess(
        uid: example.uid!,
        data: reqData,
      );
      if(!resp) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      getDetailData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 句子上下架
  Future<void> exampleSentenceShelf(SentencePatternCompareSentenceBindingEntity? sentence) async{
    if(sentence == null) return ToastUtils.showToast(text: "句子为空");
    if(sentence.sentenceId == null) return ToastUtils.showToast(text: "句子uid为空");
    bool isNormal = sentence.sentenceStruct?.isNormal == true;
    try {
      ToastUtils.showLoading();
      final response = await SentenceUtil.editSentence(
        uid: sentence.sentenceId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            "access": isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
            "hasVideo": true,
          },
        ),
      );
      if(response.data == null) {
        ToastUtils.showToast(text: response.message ?? "${isNormal ? "下架" : "上架"}失败");
        return;
      }
      ToastUtils.showToast(text: "${isNormal ? "下架" : "上架"}成功", type: ToastType.success);
      sentence.sentenceStruct?.access = isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      detailData.refresh();
      
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
    } catch (_) {
      ToastUtils.showToast(text: "${isNormal ? "下架" : "上架"}失败");
    } finally{
      ToastUtils.hideLoading();
    }
  }



}
