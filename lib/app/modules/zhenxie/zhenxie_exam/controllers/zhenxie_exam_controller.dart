import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/language_config_color_entity.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/common/https/zhenxie.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/theme/theme_utils.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../models/zhenxie_exam_models.dart';

/// 考点首页控制器。
/// 当前页只对齐 `GET /languages/write/zhenxie/exam/home` 的返回，不再读取本地 mock 快照。
class ZhenxieExamController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;

  ZhenxieExamController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_EXAM;

  @override
  String get breadcrumbTitle => '考点';

  /// 当前展示的考段。
  final RxString currentStage = ZhenxieExamStage.xiaoshengchu.code.obs;

  /// 首页接口加载态。
  final RxBool isLoading = false.obs;

  /// 首页原始数据，按 stage 缓存。
  final RxMap<String, ZhenxieExamHomeData> homeDataMap = <String, ZhenxieExamHomeData>{}.obs;

  /// 以下字段仅保留给更深层页面编译期兼容，当前首页/详情页已不再依赖。
  final RxList<ZhenxieExamReportModel> reportList = <ZhenxieExamReportModel>[].obs;
  ZhenxieExamReportModel? overallReport;
  final RxList<ZhenxieExamTaskModel> taskList = <ZhenxieExamTaskModel>[].obs;
  final RxList<ZhenxieExamTopicModel> topicList = <ZhenxieExamTopicModel>[].obs;
  final RxList<ZhenxieExamRegionModel> regionList = <ZhenxieExamRegionModel>[].obs;
  final RxList<ZhenxieExamGenreModel> genreList = <ZhenxieExamGenreModel>[].obs;
  final RxList<ZhenxieExamFamilyModel> familyList = <ZhenxieExamFamilyModel>[].obs;
  final RxList<ZhenxieExamStageNodeModel> stageNodeList = <ZhenxieExamStageNodeModel>[].obs;
  final RxList<ZhenxieExamBlueprintModel> blueprintList = <ZhenxieExamBlueprintModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (tagText.isNotEmpty) {
      initBreadcrumb(tagText);
    }
    final String? stage = Get.arguments?['stage']?.toString();
    if (ZhenxieExamStage.isValid(stage)) {
      currentStage.value = stage!;
    }
    loadHomeData();
  }

  /// 拉取当前考段首页数据。
  Future<void> loadHomeData({String? stage, bool force = false}) async {
    final String targetStage = stage ?? currentStage.value;
    if (!force && homeDataMap[targetStage] != null) {
      if (targetStage != currentStage.value) currentStage.value = targetStage;
      return;
    }
    isLoading.value = true;
      ToastUtils.showLoading();
    
    try {
      final Map<String, dynamic>? response = await ZhenxieRequest.getExamHomeData(
        parameters: <String, dynamic>{'stage': targetStage},
      );
      if (response == null) return;
      homeDataMap[targetStage] = ZhenxieExamHomeData.fromJson(response);
      currentStage.value = targetStage;
    } finally {
      ToastUtils.hideLoading();
      isLoading.value = false;
    }
  }

  /// 切换当前考段并重新请求首页接口。
  Future<void> switchStage(String stage) async {
    if (!ZhenxieExamStage.isValid(stage) || stage == currentStage.value) return;
    await loadHomeData(stage: stage);
  }

  ZhenxieExamHomeData? findCurrentHomeData() {
    return homeDataMap[currentStage.value];
  }

  ZhenxieExamHomeBlockData? findCurrentBlock(String code) {
    return findCurrentHomeData()?.blocks.firstWhereOrNull((item) => item.code == code);
  }

  List<ZhenxieExamHomeStageData> buildStageList() {
    final ZhenxieExamHomeData? current = findCurrentHomeData();
    if (current != null && current.stages.isNotEmpty) return current.stages;
    for (final ZhenxieExamHomeData item in homeDataMap.values) {
      if (item.stages.isNotEmpty) return item.stages;
    }
    return const <ZhenxieExamHomeStageData>[];
  }

  ZhenxieExamHomeStageData? findStageData(String stage) {
    return buildStageList().firstWhereOrNull((item) => item.stage == stage);
  }

  LanguageConfigColorEntityThemeColors? findCurrentThemeColors(List<LanguageConfigColorEntityThemeColors> colors) {
    for (final LanguageConfigColorEntityThemeColors item in colors) {
      if (ThemeUtils.isCurrentTheme(item.theme ?? '')) return item;
    }
    final String themeKey = ThemeUtils.isCurrentTheme(AppThemeKey.light.value) ? AppThemeKey.light.value : AppThemeKey.dark.value;
    return colors.firstWhereOrNull((item) => (item.theme ?? '').toUpperCase() == themeKey);
  }

  String buildBlockTitleText(String code) {
    final ZhenxieExamHomeBlockData? block = findCurrentBlock(code);
    return pickLocalizedText(block?.title.map((text) => text.toJson()).toList());
  }

  int buildStageTaskCount(String stage) {
    final ZhenxieExamHomeData? homeData = findCurrentHomeData();
    if (homeData == null) return 0;
    return homeData.stages.firstWhereOrNull((item) => item.stage == stage)?.taskCount ?? 0;
  }

  /// 深层页面仍有旧引用，当前页已不再依赖。
  List<ZhenxieExamTaskModel> tasksOfStage(String stage) {
    return taskList.where((item) => item.milestone == stage).toList();
  }

  List<ZhenxieExamTaskModel> buildCurrentTaskList() {
    return tasksOfStage(currentStage.value);
  }

  ZhenxieExamReportModel? findCurrentReport() {
    return reportList.firstWhereOrNull((item) => item.nid == currentStage.value);
  }

  String? coverAssetForBlueprint(String blueprintNid) => null;

  String buildHeadlineText() {
    return findCurrentHomeData()?.headline ?? '';
  }

  String buildMetaText() {
    return findCurrentHomeData()?.summary?.summaryText ?? '';
  }

  String buildGenreHeadline() {
    final ZhenxieExamHomeBlockData? block = findCurrentBlock('genres');
    return pickLocalizedText(block?.description.map((text) => text.toJson()).toList());
  }

  String buildTopicHeadline() {
    final ZhenxieExamHomeBlockData? block = findCurrentBlock('topics');
    return pickLocalizedText(block?.description.map((text) => text.toJson()).toList());
  }

  String buildGoalHeadline() {
    final ZhenxieExamHomeBlockData? block = findCurrentBlock('goals');
    return pickLocalizedText(block?.description.map((text) => text.toJson()).toList());
  }

  String buildLadderHeadline() {
    final ZhenxieExamHomeBlockData? block = findCurrentBlock('ladder');
    return pickLocalizedText(block?.description.map((text) => text.toJson()).toList());
  }

  ZhenxieExamCompareLegendData? findGoalLegend(String groupCode) {
    if (groupCode.isEmpty) return null;
    final ZhenxieExamHomeBlockData? block = findCurrentBlock('goals');
    return block?.legends.firstWhereOrNull((item) => item.code == groupCode);
  }
}
