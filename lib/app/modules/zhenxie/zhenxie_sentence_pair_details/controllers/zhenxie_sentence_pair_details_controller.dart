import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/mixins/mixins.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../theme/theme.dart';
import '../../../../routes/tag_routes.dart';
import '../views/zhenxie_edit_pair_sentence_dialog.dart';

class ZhenxieSentencePairDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxieSentencePairDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_SENTENCE_PAIR_DETAILS;

  @override
  String get breadcrumbTitle => '句间配链详情';

  // 传进来的参数
  String? nid;
  /// 是否是管理端入口打开
  bool isManagement = false;

  final Rx<SentencePairEntity> pairDetail = SentencePairEntity().obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      isManagement = Get.arguments['isManagement'] ?? false;
      nid = Get.arguments['nid'];
      getPairDetail();
    }
  }

  Future<void> getPairDetail() async{
    if(nid == null) return;
    try {
      ToastUtils.showLoading();
      SentencePairEntity? list = await LanguageConsoleRequest.getSentencePairDetails(nid!);
      if(list == null) return;
      pairDetail.value = list;

    } finally{
      ToastUtils.hideLoading();
    }
  }



  /// 编辑名称说明
  Future<void> editNameDesc(BuildContext context) async{
    if(nid == null) return;

    EditNameDescDialogResult? res = await EditNameDescDialog.show(
      context: context,
      name: pairDetail.value.name,
      description: pairDetail.value.description,
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

      SentencePairEntity? resp = await LanguageConsoleRequest.editSentencePair(
        nid: nid!,
        data: reqData,
      );
      if(resp == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      pairDetail.value = resp;
    } finally {
      ToastUtils.hideLoading();
    }

  }

  /// 编辑对句
  Future<void> editPairSentence(BuildContext context) async{
    await ZhenxieEditPairSentenceDialog.show(context: context);
  }

  /// 打开棋盘
  Future<void> toForkDetails(SentencePairForkEntity fork) async{
    if(fork.nid == null) return;
    TagRoutes.toNamed(
      Routes.ZHENXIE_SENTENCE_PAIR_FORK_DETAILS,
      arguments: {
        "nid": fork.nid,
        "isManagement": isManagement,
      },
    );
  } 



  /// 例句句子组上下架
  Future<void> exampleSentenceGroupShelf(SentencePairSentenceRealizationEntity? example) async {
    if(example == null) return;
    if(example.realizationSetId == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": example.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
      };
      bool resp = await LanguageConsoleRequest.zhenxieExampleAccess(
        uid: example.realizationSetId!,
        data: reqData,
      );
      if(!resp) return;
      ToastUtils.showToast(text: "${example.isNormal ? "下架" : "上架"}成功", type: ToastType.success);
      example.access = example.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      pairDetail.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 删除句组
  Future<void> exampleSentenceGroupDelete(BuildContext context, SentencePairSentenceRealizationEntity? example) async {
    if(example == null) return;
    if(example.realizationSetId == null) return;
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
        uid: example.realizationSetId!,
        data: reqData,
      );
      if(!resp) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      getPairDetail();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 句子上下架
  Future<void> exampleSentenceShelf(SentencePairSentenceBriefEntity? sentence) async{
    if(sentence == null) return;
    if(sentence.sentenceId == null) return;
    bool isNormal = sentence.isNormal == true;
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
      sentence.access = isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      pairDetail.refresh();
      
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
    } catch (_) {
      ToastUtils.showToast(text: "${isNormal ? "下架" : "上架"}失败");
    } finally{
      ToastUtils.hideLoading();
    }
  }




}
