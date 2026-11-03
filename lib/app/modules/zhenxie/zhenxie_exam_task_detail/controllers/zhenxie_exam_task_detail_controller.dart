import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/entities/card_public_entity.dart';
import 'package:langwise/common/entities/language_config_color_entity.dart';
import 'package:langwise/common/https/zhenxie.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/theme/theme_utils.dart';
import 'package:langwise/utils/utils.dart';

import '../../zhenxie_exam/models/zhenxie_exam_models.dart';

class ZhenxieExamTaskDetailController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;

  ZhenxieExamTaskDetailController({
    required this.tagText,
  });

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_EXAM_TASK_DETAIL;

  @override
  String get breadcrumbTitle => '真题详情';

  int? uid;

  final RxBool isLoading = true.obs;
  final RxBool isNotData = false.obs;
  final Rxn<ZhenxieExamTaskDetailData> detailData = Rxn<ZhenxieExamTaskDetailData>();

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText, title: '真题详情');
    final dynamic arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      uid = (arguments['uid'] as num?)?.toInt() ?? int.tryParse(arguments['uid']?.toString() ?? '');
    } else if (arguments is Map) {
      uid = int.tryParse(arguments['uid']?.toString() ?? '');
    }
    initPage();
  }

  Future<void> initPage() async {
    if (uid == null) {
      isLoading.value = false;
      isNotData.value = true;
      return;
    }
    isLoading.value = true;
    ToastUtils.showLoading();
    try {
      final Map<String, dynamic>? response = await ZhenxieRequest.getExamTaskDetail(
        parameters: <String, dynamic>{'uid': uid},
      );
      if (response == null) {
        isNotData.value = true;
        return;
      }
      detailData.value = ZhenxieExamTaskDetailData.fromJson(response);
      isNotData.value = detailData.value == null;
    } finally {
      ToastUtils.hideLoading();
      isLoading.value = false;
    }
  }

  String buildZhText(List<LanguageText> texts) {
    return pickLocalizedText(texts.map((item) => item.toJson()).toList());
  }

  String buildRegionText(List<ZhenxieExamTaskLabelData> regions) {
    return regions.map((item) => buildZhText(item.name)).where((item) => item.isNotEmpty).join(' · ');
  }

  String buildRegionTextByTask(ZhenxieExamTaskCardData task) {
    return buildRegionText(task.regions);
  }

  String buildFamilyText(ZhenxieExamTaskCardData task) {
    return buildZhText(task.family.name);
  }

  String buildMilestoneText(ZhenxieExamTaskCardData task) {
    return buildZhText(task.milestoneName);
  }

  String buildStageText(ZhenxieExamTaskCardData task) {
    return buildZhText(task.stage.name);
  }

  List<String> buildTopicTexts(ZhenxieExamTaskCardData task) {
    return task.topics.map((item) => buildZhText(item.name)).where((item) => item.isNotEmpty).toList();
  }

  List<String> buildVisibleRequiredPoints(ZhenxieExamTaskCardData task) {
    return task.requiredPoints.take(3).toList();
  }

  LanguageConfigColorEntityThemeColors? findMilestoneThemeColors(String code) {
    final ZhenxieExamTaskColorData? colorData =
        detailData.value?.milestoneColors.firstWhereOrNull((item) => item.code == code);
    if (colorData == null) return null;
    return findCurrentThemeColors(colorData.colors);
  }

  LanguageConfigColorEntityThemeColors? findFamilyThemeColors(String code) {
    final ZhenxieExamTaskColorData? colorData =
        detailData.value?.familyColors.firstWhereOrNull((item) => item.code == code);
    if (colorData == null) return null;
    return findCurrentThemeColors(colorData.colors);
  }

  LanguageConfigColorEntityThemeColors? findCurrentThemeColors(List<LanguageConfigColorEntityThemeColors> colors) {
    for (final LanguageConfigColorEntityThemeColors item in colors) {
      if (ThemeUtils.isCurrentTheme(item.theme ?? '')) return item;
    }
    final String themeKey = ThemeUtils.isCurrentTheme(AppThemeKey.light.value) ? AppThemeKey.light.value : AppThemeKey.dark.value;
    return colors.firstWhereOrNull((item) => (item.theme ?? '').toUpperCase() == themeKey);
  }

  Future<void> openTaskDetail(int taskUid) async {
    if (uid == taskUid) return;
    uid = taskUid;
    await initPage();
  }

  Future<void> openTaskList() async {
    final ZhenxieExamTaskDetailData? detail = detailData.value;
    if (detail == null) return;
    final Map<String, dynamic> arguments = <String, dynamic>{};
    if (detail.milestone.isNotEmpty) {
      arguments['milestone'] = detail.milestone;
    }
    if (detail.family.code.isNotEmpty) {
      arguments['familyNid'] = detail.family.code;
    }
    await TagRoutes.toNamed(
      Routes.ZHENXIE_EXAM_TASKS,
      arguments: arguments,
    );
  }
}
