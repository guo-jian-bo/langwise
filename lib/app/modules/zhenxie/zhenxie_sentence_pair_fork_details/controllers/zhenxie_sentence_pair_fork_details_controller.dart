import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/mixins/mixins.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';

class ZhenxieSentencePairForkDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxieSentencePairForkDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_SENTENCE_PAIR_FORK_DETAILS;

  @override
  String get breadcrumbTitle => '句间配链分叉详情';

  // 传进来的参数
  String? nid;
  /// 是否是管理端入口打开
  bool isManagement = false;

  final Rx<SentenceForkEntity> forkDetail = SentenceForkEntity().obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      isManagement = Get.arguments['isManagement'] ?? false;
      nid = Get.arguments['nid'];
      getForkDetail();
    }
  }

  /// 刷新单个配对数据
  Future<void> getForkDetail() async{
    if(nid == null) return;
    if(nid == null) return;
    try {
      ToastUtils.showLoading();
      SentenceForkEntity? list = await LanguageConsoleRequest.getSentenceForkDetails(nid!);
      if(list == null) return;
      forkDetail.value = list;

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 例句句子组上下架
  Future<void> exampleSentenceGroupShelf(SentenceForkSentenceRealizationEntity? example) async {
    if(example == null) return;
    if(example.uid == null) return;
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
      forkDetail.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 删除句组
  Future<void> exampleSentenceGroupDelete(BuildContext context, SentenceForkSentenceRealizationEntity? example) async {
    if(example == null) return;
    if(example.uid == null) return;
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
      getForkDetail();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 句子上下架
  Future<void> exampleSentenceShelf(SentenceForkSentenceBriefEntity? sentence) async{
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
      forkDetail.refresh();
      
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
    } catch (_) {
      ToastUtils.showToast(text: "${isNormal ? "下架" : "上架"}失败");
    } finally{
      ToastUtils.hideLoading();
    }
  }

}
