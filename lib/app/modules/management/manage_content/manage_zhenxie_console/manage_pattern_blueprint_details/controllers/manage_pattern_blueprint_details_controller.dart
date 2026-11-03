import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../elements/utils/elements_page_utils.dart';
import '../../../../utils/utils.dart';
import '../../../../dialog/manage_edit_name_desc_dialog.dart';
import '../views/manage_pattern_edit_represent_dialog.dart';

class ManagePatternBlueprintDetailsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManagePatternBlueprintDetailsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_PATTERN_BLUEPRINT_DETAILS;

  @override
  String get breadcrumbTitle => '句型蓝图详情';

  /// 传进来的参数
  String? nid;

  final Rx<PatternBlueprintEntity> patternBlueprint = PatternBlueprintEntity().obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      nid = Get.arguments["nid"];
      getDetatils();
    }
  }

  /// 查询详情
  Future<void> getDetatils() async {
    if (nid == null) return;
    try {
      ToastUtils.showLoading();
      PatternBlueprintEntity? res = await LanguageConsoleRequest.queryPatternBlueprint(nid!);
      if (res == null) return;
      patternBlueprint.value = res;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 编辑名称说明
  Future<void> editNameDesc(BuildContext context) async {
    if(nid == null) return;

    ManageEditNameDescDialogResult? res = await ManageEditNameDescDialog.show(
      context: context,
      name: patternBlueprint.value.name,
      description: patternBlueprint.value.description,
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

      PatternBlueprintEntity? resp = await LanguageConsoleRequest.editPatternBlueprint(
        nid: nid!,
        data: reqData,
      );
      if(resp == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      patternBlueprint.value = resp;
    } finally {
      ToastUtils.hideLoading();
    }

  }

  /// 编辑代表句
  Future<void> editRepresent(BuildContext context) async {
    if(nid == null) return;
    List<PatternBlueprintSentenceBriefEntity?> sentenceRealizationList = patternBlueprint.value.sentenceRealizationList??[];
    PatternBlueprintEntity? resp = await ManagePatternEditRepresentDialog.show(
      context: context,
      nid: nid!,
      sentenceRealizationList: sentenceRealizationList,
    );
    if(resp == null) return;
    patternBlueprint.value = resp;
  }

  /// 槽位详情
  Future<void> slotDetails(BuildContext context, SentenceSlotMapItemEntity item) async {
    await PatternSlotDetailsDialog.show(context: context, item: item);
  }

  /// 槽位例句说明
  Future<void> slotSentenceExample(
    BuildContext context,
    PatternBlueprintSentenceBriefSegmentEntity segment,
    PatternBlueprintSentenceBriefEntity? item,
  ) async {
    await SlotSentenceExampleDialog.show(
      context: context,
      segment: segment,
      nid: nid??"",
      sentenceId: item?.sentenceId,
    );
  }

  /// 拓展学习
  Future<void> expandLearning(PatternBlueprintSentenceBriefEntity? item) async {
    ElementsPageUtils.jumpElementsPage(
      contentId: item?.sentenceId, 
      contentType: KnowledgeTypeEnum.EN_SENTENCE.value, 
      semanticId: null, 
      content: item?.content,
      styleId: null, 
      dialect: null,
    );
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
