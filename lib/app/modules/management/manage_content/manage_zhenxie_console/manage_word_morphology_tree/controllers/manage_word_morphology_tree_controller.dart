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

class ManageWordMorphologyTreeController extends GetxController with DualBreadcrumbMixin, PageRefreshAwareMixin {
  final String tag;
  ManageWordMorphologyTreeController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_WORD_MORPHOLOGY_TREE;

  @override
  String get breadcrumbTitle => '构词树';

  String? morphemeNid;
  int? wordId;
  bool isManagement = true;
  bool useElementsTreeApi = false;

  final Rx<WordMorphologyTreeEntity> detail = WordMorphologyTreeEntity().obs;
  final ConfigController configController = Get.find<ConfigController>();

  final RxBool isLoading = false.obs;
  final RxBool isCanvasInfoExpanded = true.obs;
  final RxInt canvasResetToken = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      morphemeNid = Get.arguments['morphemeNid']?.toString();
      wordId = int.tryParse(Get.arguments['wordId']?.toString() ?? '');
      final dynamic isManagementValue = Get.arguments['isManagement'];
      if (isManagementValue != null) {
        isManagement = isManagementValue == true || isManagementValue?.toString() == 'true';
      }
      final String directKey = Get.arguments['key']?.toString() ?? '';
      if (wordId == null && directKey.isNotEmpty) {
        wordId = int.tryParse(directKey);
      }
      useElementsTreeApi = !isManagement;
    }
    initBreadcrumb(tag);
    getDetails();
  }

  @override
  Future<void> onReturnPageRefresh(String? key) async{
    await getDetails(showLoading: false);
  }

  Future<void> getDetails({bool showLoading = true}) async {
    if (wordId == null) return;
    if (!useElementsTreeApi && (morphemeNid ?? '').isEmpty) return;
    try {
      if (showLoading) {
        isLoading.value = true;
        ToastUtils.showLoading();
      }
      WordMorphologyTreeEntity? res = await _requestTreeDetail();
      if (_isEmptyTreeDetail(res)) {
        if (isManagement) {
          ToastUtils.showManageToast(text: '构词树加载失败');
        } else {
          ToastUtils.showToast(text: '构词树加载失败');
        }
        return;
      }
      detail.value = res!;
      isCanvasInfoExpanded.value = true;
    } finally {
      isLoading.value = false;
      if (showLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  Future<WordMorphologyTreeEntity?> _requestTreeDetail() async {
    if (useElementsTreeApi) {
      return await ElementsRequest.getWordMorphologyTree(
        key: wordId!,
      );
    }
    return await LanguageConsoleRequest.queryWordMorphologyTree(
      morphemeNid: morphemeNid!,
      key: wordId!,
    );
  }

  bool _isEmptyTreeDetail(WordMorphologyTreeEntity? value) {
    if (value == null) return true;
    if ((value.content ?? '').isNotEmpty) return false;
    if (value.branches?.isNotEmpty == true) return false;
    if (value.descriptions?.isNotEmpty == true) return false;
    return true;
  }

  void collapseCanvasInfoWidget() {
    if (!isCanvasInfoExpanded.value) return;
    isCanvasInfoExpanded.value = false;
  }

  void toggleCanvasInfoExpanded() {
    isCanvasInfoExpanded.value = !isCanvasInfoExpanded.value;
  }

  void requestCanvasReset() {
    canvasResetToken.value++;
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
    List<LanguageConfigColorEntityInfo?> morphemeTypesTags = Get.find<ConfigController>().colorConfigs.value.morphemeTypesTags ?? [];
    for (int i = 0; i < morphemeTypesTags.length; i++) {
      if (morphemeTypesTags[i]?.code?.toLowerCase() == code.toLowerCase()) {
        return morphemeTypesTags[i];
      }
    }
    return null;
  }

  String getMorphemeTypeTitle(String? code) {
    return getMorphemeTypeConfig(code)?.title ?? '';
  }

  Color? getMorphemeTypeTextColor(String? code) {
    final LanguageConfigColorEntityThemeColors? themeColors =
        StatusUtils.resolveThemeColors(getMorphemeTypeConfig(code));
    return themeColors?.textColorC ?? themeColors?.colorC;
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
          'isManagement': isManagement,
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
        'isManagement': isManagement,
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
