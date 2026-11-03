import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/home_card_code.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../../../routes/tag_routes.dart';
import '../../model/speciaity_default_phonics_model.dart';
import '../../../../../common/entities/speciaity_phonics_model.dart';

class PhonicsCourseController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  PhonicsCourseController({this.tagText = ''});

  @override
  String get breadcrumbRoute => Routes.PHONICS_COURSE;

  @override
  String get breadcrumbTitle => "发音课";

  /// 课程id
  int? courseId;

  /// 是否是选择模块 如果是那么携带参数返回上一层
  bool isSelectModule = false;

  /// 是否显示选择单元
  bool showUnit = false;

  /// 是否从今日计划来
  bool createStudyPlan = false;

  /// 是否选中当前模块
  bool isSelectThisModule = true;

  final GlobalKey firstModuleKey = GlobalKey();

  final ScrollController scrollController = ScrollController();

  /// 课程数据
  final Rx<PhonicsCourseEntity> courseData = PhonicsCourseEntity().obs;

  /// 等级列表
  final RxList<PhonicsCourseLevelList> levelDatas =
      <PhonicsCourseLevelList>[].obs;

  Future<void> configureCourse({
    required int courseId,
    bool isSelectModule = false,
    bool showUnit = false,
    bool isSelectThisModule = true,
    bool createStudyPlan = false,
    bool force = false,
  }) async {
    final bool isSameCourse = this.courseId == courseId;
    final bool isSameConfig = this.isSelectModule == isSelectModule &&
        this.showUnit == showUnit &&
        this.isSelectThisModule == isSelectThisModule &&
        this.createStudyPlan == createStudyPlan;

    this.courseId = courseId;
    this.isSelectModule = isSelectModule;
    this.showUnit = showUnit;
    this.isSelectThisModule = isSelectThisModule;
    this.createStudyPlan = createStudyPlan;

    if (!force && isSameCourse && isSameConfig && levelDatas.isNotEmpty) {
      return;
    }
    await getLevelDatas(isScroll: true);
  }

  @override
  void onInit() {
    super.onInit();
    if (tagText.isNotEmpty) {
      initBreadcrumb(tagText);
    }
    final Map<String, dynamic> args =
        (Get.arguments is Map<String, dynamic>)
            ? Get.arguments as Map<String, dynamic>
            : <String, dynamic>{};
    final int? argsCourseId = args['courseId'];
    if (argsCourseId != null) {
      configureCourse(
        courseId: argsCourseId,
        isSelectModule: args['isSelectModule'] ?? false,
        showUnit: args['showUnit'] ?? false,
        isSelectThisModule: args['isSelectThisModule'] ?? true,
        createStudyPlan: args['createStudyPlan'] ?? false,
      );
      return;
    }
    if (args['useDefaultCourse'] == true) {
      _loadDefaultCourse();
    }
  }

  Future<void> _loadDefaultCourse() async {
    try {
      ToastUtils.showLoading();
      final HomeCardEntity? homeCardEntity =
          await SpecialtyRequest.getHomeCardList();
      if (homeCardEntity == null) return;
      final int? defaultCourseId =
          _extractDefaultCourseId(homeCardEntity.items ?? const []);
      if (defaultCourseId == null) return;
      await configureCourse(courseId: defaultCourseId);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  int? _extractDefaultCourseId(List<HomeCardEntityItems?> items) {
    for (final HomeCardEntityItems? item in items) {
      if (item?.code != HomeCardCode.phonicsCourse) continue;
      final List<dynamic>? list = item?.list;
      if (list == null) continue;
      for (final dynamic raw in list) {
        if (raw == null || raw is! Map<String, dynamic>) continue;
        final SpeciaityPhonicsModel model = SpeciaityPhonicsModel.fromJson(raw);
        final int? courseId = model.data?.courseId;
        if (courseId != null) return courseId;
      }
    }
    for (final HomeCardEntityItems? item in items) {
      if (item?.code != HomeCardCode.phonicsInitCourse) continue;
      final List<dynamic>? list = item?.list;
      if (list == null) continue;
      for (final dynamic raw in list) {
        if (raw == null || raw is! Map<String, dynamic>) continue;
        final SpeciaityDefaultPhonicsModel model =
            SpeciaityDefaultPhonicsModel.fromJson(raw);
        for (final module in model.data?.moduleInfoList ?? const []) {
          final int? courseId = module?.courseId;
          if (courseId != null) return courseId;
        }
      }
    }
    return null;
  }

  Future<void> getLevelDatas({bool isScroll = false}) async {
    if (courseId == null) return;
    try {
      ToastUtils.showLoading();
      PhonicsCourseEntity? entity =
          await SpecialtyRequest.getPhonicsCourse(courseId);
      if (entity == null) return;
      courseData.value = entity;

      List<PhonicsCourseLevelList?> levelList = entity.levelList ?? [];
      levelDatas.clear();
      for (PhonicsCourseLevelList? item in levelList) {
        if (item == null) continue;
        levelDatas.add(item);
      }
    } finally {
      ToastUtils.hideLoading();
    }

    if (isScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToThisModule();
      });
    }
  }

  /// 滚动到当前模块的位置
  Future<void> scrollToThisModule() async {
    if (!isSelectThisModule) return;

    // 1) 前置校验：课程ID必须存在，且等级数据非空
    if (courseId == null) return;
    if (levelDatas.isEmpty) return;

    // 2) 等待首个模块渲染完成（用于获取单个模块的尺寸）
    //    这里使用延迟保证首个模块的 RenderBox 已经可用
    await Future.delayed(const Duration(milliseconds: 400));

    // 3) 获取首个模块的尺寸，作为网格单项高度的参考
    final RenderBox? firstModule =
        firstModuleKey.currentContext?.findRenderObject() as RenderBox?;
    if (firstModule == null) return;

    // 4) 网格与粘性头相关参数（保持与视图中的设置一致）
    const int columns = 6; // SliverGrid 每行展示的列数
    final double stickyHeaderHeight = 90.wMin; // 每个等级的粘性头部高度
    final double gridTopPadding = 10.wMin; // 等级内网格顶部内边距
    final double gridBottomPadding = 56.wMin; // 等级内网格底部内边距
    final double mainAxisSpacing = 24.wMin; // 网格行间距
    final double moduleHeight = firstModule.size.height; // 单个模块高度

    // 5) 查找“当前模块”的所在等级和模块索引
    int targetLevelIndex = -1;
    int targetModuleIndex = -1;
    for (int levelIndex = 0; levelIndex < levelDatas.length; levelIndex++) {
      List<PhonicsCourseLevelListModuleList?> moduleList =
          levelDatas[levelIndex].moduleList ?? [];
      for (int moduleIndex = 0;
          moduleIndex < moduleList.length;
          moduleIndex++) {
        final bool isCurrent = moduleList[moduleIndex]?.current == true;
        if (isCurrent) {
          targetLevelIndex = levelIndex;
          targetModuleIndex = moduleIndex;
          break;
        }
      }
      if (targetLevelIndex != -1) break;
    }
    // 如果没有找到任何标记为 current 的模块，则不滚动
    if (targetLevelIndex == -1 || targetModuleIndex == -1) return;

    // 6) 计算目标等级之前的累计滚动高度（逐级累加）
    double precededHeight = 0; // 目标等级之前的总高度
    for (int l = 0; l < targetLevelIndex; l++) {
      final int count = (levelDatas[l].moduleList ?? []).length;

      // 行数：按列数取整（ceil）
      final int rowCount = (count / columns).ceil();

      // 该等级内的网格内容高度（不包含内边距与粘性头）
      final double gridContentHeight = rowCount * moduleHeight;

      // 行间距高度：行数大于0时才有 (rows - 1) 个间距
      final double gridSpacingHeight =
          rowCount > 0 ? (rowCount - 1) * mainAxisSpacing : 0;

      // 该等级的网格总高度（包含上下内边距）
      final double gridTotalHeight = gridTopPadding +
          gridContentHeight +
          gridSpacingHeight +
          gridBottomPadding;

      // 该等级的整体高度（粘性头 + 网格）
      final double levelTotalHeight = stickyHeaderHeight + gridTotalHeight;

      // 累计到目标等级之前的总高度
      precededHeight += levelTotalHeight;
    }

    // 7) 计算目标等级内的偏移（定位到目标模块所在的行）
    //    行号：从0开始，使用 floor 获取所在行
    final int targetRowIndex = (targetModuleIndex / columns).floor();

    // 行顶部相对于该等级网格顶部的偏移（不含粘性头）
    final double rowTopWithinGrid =
        gridTopPadding + (targetRowIndex * (moduleHeight + mainAxisSpacing));

    // 8) 组合最终滚动偏移量：
    //    - precededHeight：目标等级之前的高度
    //    - rowTopWithinGrid：目标等级内到目标行顶部的高度
    double scrollOffset = precededHeight + rowTopWithinGrid;

    // 限制滚动偏移最大/最小值，避免越界滚动
    if (scrollController.hasClients) {
      final double maxExtent = scrollController.position.maxScrollExtent;
      if (scrollOffset < 0) scrollOffset = 0;
      if (scrollOffset > maxExtent) scrollOffset = maxExtent;
    } else {
      // 还没有绑定到滚动视图时仅做下限保护，避免负值
      if (scrollOffset < 0) scrollOffset = 0;
    }

    scrollController.animateTo(
      scrollOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  Future<void> toModulePage(
      BuildContext context,
      PhonicsCourseLevelList levelData,
      PhonicsCourseLevelListModuleList? moduleData) async {
    if (courseId == null) return;
    if (moduleData == null) return;
    if (moduleData.moduleId == null || levelData.levelId == null) return;

    int? unitId;
    String? unitName;
    int? difficulty;
    if (showUnit) {
      dynamic res = await TagRoutes.toNamed(
        Routes.COURSE_LEVEL_SELECT_UNIT,
        arguments: {
          "courseId": courseId,
          "levelId": levelData.levelId,
          "moduleId": moduleData.moduleId,
          "subTitle":
              "已选${courseData.value.name ?? ''} > ${moduleData.name ?? ''}",
        },
      );

      if (res == null) return;
      CourseLevelModuleUnitEntityUnits? unit = res;
      if (unit == null) return;
      unitId = unit.unitId;
      unitName = unit.unitName;
      difficulty = unit.difficulty;
    }

    if (!isSelectModule) {
      await TagRoutes.toNamed(
        Routes.OFFICIAL_COURSE_DETAILS,
        arguments: {
          "courseId": courseId,
          "levelId": levelData.levelId,
          "moduleId": moduleData.moduleId,
        },
      );
      return;
    }

    Get.back(result: {
      "courseId": courseId,
      "courseName": courseData.value.name,
      "moduleId": moduleData.moduleId,
      "moduleName": moduleData.name,
      "levelId": levelData.levelId,
      "levelName": levelData.name,
      "unitId": unitId,
      "unitName": unitName,
      "difficulty": difficulty,
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
