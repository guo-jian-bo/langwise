import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/mixins/mixins.dart';
import '../../../../../../../common/public_controller/config_controller.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/tag_routes.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../elements/elements_word_detils/views/elements_word_detils_view.dart';

class ManageWordMorphologyTreeController extends GetxController with DualBreadcrumbMixin {
  final String tag;
  ManageWordMorphologyTreeController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_WORD_MORPHOLOGY_TREE;

  @override
  String get breadcrumbTitle => '构词树';

  String? morphemeNid;
  int? wordId;
  bool isUserSide = false;
  bool useElementsTreeApi = false;

  final Rx<WordMorphologyTreeEntity> detail = WordMorphologyTreeEntity().obs;

  final RxBool isLoading = false.obs;
  final RxBool isCanvasInfoExpanded = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      morphemeNid = Get.arguments['morphemeNid']?.toString();
      wordId = int.tryParse(Get.arguments['wordId']?.toString() ?? '');
      final dynamic isUserSideValue = Get.arguments['isUserSide'];
      isUserSide = isUserSideValue == true || isUserSideValue?.toString() == 'true';
      final String directKey = Get.arguments['key']?.toString() ?? '';
      if (wordId == null && directKey.isNotEmpty) {
        wordId = int.tryParse(directKey);
      }
      useElementsTreeApi = isUserSide || ((morphemeNid ?? '').isEmpty && wordId != null);
      if (useElementsTreeApi && wordId != null) {
        morphemeNid = 'tree';
      }
    }
    initBreadcrumb(tag);
    getDetails();
  }

  Future<void> getDetails() async {
    if ((morphemeNid ?? '').isEmpty || wordId == null) return;
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      WordMorphologyTreeEntity? res;
      if (useElementsTreeApi) {
        res = await ElementsRequest.getWordMorphologyTree(key: wordId!);
      } else {
        res = await LanguageConsoleRequest.queryWordMorphologyTree(
          morphemeNid: morphemeNid!,
          key: wordId!,
        );
      }
      if (res == null) return;
      detail.value = res;
      isCanvasInfoExpanded.value = true;
      updateBreadcrumbTitle("${res.content ?? ''} · 构词树");
    } finally {
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  void collapseCanvasInfoWidget() {
    if (!isCanvasInfoExpanded.value) return;
    isCanvasInfoExpanded.value = false;
  }

  void toggleCanvasInfoExpanded() {
    isCanvasInfoExpanded.value = !isCanvasInfoExpanded.value;
  }

  String getLangText(List<LanguageText?>? values, String lang) {
    if (values == null || values.isEmpty) return '';
    for (int i = 0; i < values.length; i++) {
      if (values[i]?.lang == lang) {
        return values[i]?.text ?? '';
      }
    }
    return '';
  }

  String getPreferredText(List<LanguageText?>? values) {
    String zh = getLangText(values, 'zh');
    if (zh.isNotEmpty) return zh;
    return getLangText(values, 'en');
  }

  String getDescription() {
    return getPreferredText(detail.value.descriptions);
  }

  LanguageConfigColorEntityInfo? getMorphemeTypeConfig(String? code) {
    if (code == null || code.isEmpty) return null;
    List<LanguageConfigColorEntityInfo?> morphemeTypes = Get.find<ConfigController>().colorConfigs.value.morphemeTypes ?? [];
    for (int i = 0; i < morphemeTypes.length; i++) {
      if (morphemeTypes[i]?.code?.toLowerCase() == code.toLowerCase()) {
        return morphemeTypes[i];
      }
    }
    return null;
  }

  String getMorphemeTypeTitle(String? code) {
    return getMorphemeTypeConfig(code)?.title ?? '';
  }

  Color? getMorphemeTypeTextColor(String? code) {
    return ColorUtils.parseColor(getMorphemeTypeConfig(code)?.color?.textColor);
  }

  LanguageConfigColorModel? getPosConfig(String? code) {
    return StatusUtils.getConfigColor(Get.find<ConfigController>().colorConfigs.value.pos, code);
  }

  String getPosTitle(String? code) {
    return getPosConfig(code)?.title ?? '';
  }

  Color? getPosTextColor(String? code) {
    return getPosConfig(code)?.color?.textColor;
  }
    Color? getPosBorderColor(String? code) {
    return getPosConfig(code)?.color?.borderColor;
  }

  void jumpToFamilyPage(WordMorphologyTreeBranchEntity branch) {
    if ((branch.type ?? '').toLowerCase() == 'root') {
      String branchKey = branch.key ?? '';
      if (branchKey.isEmpty) return;
      TagRoutes.toNamed(
        Routes.MANAGE_WORD_MORPHOLOGY_DETAILS,
        arguments: {
          'key': branchKey,
          'isUserSide': isUserSide,
        },
      );
      return;
    }
    String familyMorphemeNid = branch.morphemeNid ?? '';
    if (familyMorphemeNid.isEmpty) return;
    TagRoutes.toNamed(
      Routes.MANAGE_WORD_MORPHOLOGY_DETAILS,
      arguments: {
        'morphemeNid': familyMorphemeNid,
        'isUserSide': isUserSide,
      },
    );
  }

  void jumpToWordDetail(int? contentId) {
    if (contentId == null) return;
    ElementsWordDetilsView.to(
      arguments: {
        'contentId': contentId,
      },
      tag: '${Routes.EN_WORD_DETAIL}_${contentId}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
