import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/common/widgets/custom_button/LWCircularButton.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../bindings/official_course_details_level_binding.dart';
import '../controllers/official_course_details_level_controller.dart';

class OfficialCourseDetailsLevelView extends GetView<OfficialCourseDetailsLevelController> {
  final String tagText;
  const OfficialCourseDetailsLevelView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => OfficialCourseDetailsLevelView(tagText: tag),
      binding: OfficialCourseDetailsLevelBinding(tagText: tag),
      routeName: Routes.OFFICIAL_COURSE_DETAILS_LEVEL,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: AppTheme.cBgPrimary,
        body: Stack(children: [
          Column(
            children: [
              _buildTitleWidget(context),
              Expanded(child: Obx(() {
                if (controller.isPageLoading.value) {
                  return const SizedBox.shrink();
                }
                if (controller.levels.isEmpty) {
                  return _buildEmptyState(context);
                }
                if (_isAllModuleListsEmpty()) {
                  return _buildEmptyState(context);
                }
                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    controller: controller.scrollController,
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: EdgeInsets.fromLTRB(
                      100.wMin,
                      16.wMin,
                      100.wMin,
                      constraints.maxHeight * 0.55,
                    ),
                    child: Column(
                      children: [
                        ...List.generate(controller.visibleLevels.length, (index) {
                          final level = controller.visibleLevels[index];
                          return _buildLevelSection(context, level);
                        }),
                      ],
                    ),
                  ),
                );
              })),
            ],
          ),
          Obx(() {
            if (controller.levels.isEmpty || _isAllModuleListsEmpty()) {
              return const SizedBox.shrink();
            }
            return Positioned(
              bottom: 45.wMin,
              left: 45.wMin,
              right: 45.wMin,
              child: _buildBottomLevelBar(context),
            );
          }),
          if (controller.isFromStudyPlan != true && controller.isFromCustomCourse == true)
            Positioned(
              right: 16.wMin,
              bottom: 160.wMin,
              child: _buildRightToggleButton(context),
            ),
        ]),
      );
    });
  }

  bool _isAllModuleListsEmpty() {
    return controller.visibleLevels.isEmpty;
  }

  Widget _buildEmptyState(BuildContext context) {
    final bool canEditCourse = controller.isFromCustomCourse == true;
    return NotDataWidget(
      message: canEditCourse ? '开始打造你的专属教材库' : '当前课程暂时还没有关卡内容哦',
      buttonText: canEditCourse ? '立即添加教材' : null,
      onButton: canEditCourse
          ? () {
              controller.editCourse(context);
            }
          : null,
    );
  }

  Widget _buildTitleWidget(BuildContext context) {
    return BreadcrumbWidget(
      actionWidget: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildColorInfoItemWidget("舒适区", StudyZoneEnum.comfort),
            SizedBox(width: 20.wMin),
            _buildColorInfoItemWidget("学习区", StudyZoneEnum.study),
            SizedBox(width: 20.wMin),
            _buildColorInfoItemWidget("困难区", StudyZoneEnum.panic),
            SizedBox(width: 20.wMin),
            _buildColorInfoItemWidget("未定级", null),
          ],
        ),
      ),
    );
  }

  Widget _buildColorInfoItemWidget(String title, String? studyZoneEnum) {
    Color? color = StatusUtils.getStudyZoneColor(studyZoneEnum) ?? AppTheme.cTextPrimary.color;
    return Row(
      spacing: 4.wMin,
      children: [
        Container(
          width: 10.wMin,
          height: 10.wMin,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 26.wMin,
            color: color,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }

  Widget _buildLevelSection(BuildContext context, CourseLevelTreeLevel level) {
    final modules = controller.getDisplayableModules(level);
    if (modules.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLevelHeader(
          levelId: level.levelId ?? -1,
          levelName: level.name ?? '',
          levelTier: level.tier,
          studyZone: level.studyZone,
        ),
        SizedBox(height: controller.moduleHeaderGap),
        _buildModuleGrid(context, level, modules),
        SizedBox(height: controller.moduleItemGap),
      ],
    );
  }

  Widget _buildModuleGrid(
    BuildContext context,
    CourseLevelTreeLevel level,
    List<CourseLevelTreeModule> modules,
  ) {
    return Obx(() {
      final expandedModuleId = controller.expandedModuleId.value;
      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = controller.moduleGridCrossAxisCount;
          final horizontalSpacing = controller.moduleGridCrossAxisSpacing;
          final verticalSpacing = controller.moduleGridMainAxisSpacing;
          final cardWidth =
              (constraints.maxWidth - (crossAxisCount - 1) * horizontalSpacing) / crossAxisCount;
          final rowCount = (modules.length / crossAxisCount).ceil();
          return Column(
            children: List.generate(rowCount, (rowIndex) {
              final start = rowIndex * crossAxisCount;
              final end = math.min(start + crossAxisCount, modules.length);
              final rowModules = modules.sublist(start, end);
              final expandedIndex =
                  rowModules.indexWhere((item) => item.moduleId == expandedModuleId);
              return Padding(
                padding: EdgeInsets.only(bottom: rowIndex == rowCount - 1 ? 0 : verticalSpacing),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(crossAxisCount * 2 - 1, (index) {
                        if (index.isOdd) {
                          return SizedBox(width: horizontalSpacing);
                        }
                        final columnIndex = index ~/ 2;
                        if (columnIndex >= rowModules.length) {
                          return SizedBox(width: cardWidth);
                        }
                        final module = rowModules[columnIndex];
                        return SizedBox(
                          width: cardWidth,
                          child: buildModuleCard(
                            context,
                            level,
                            module,
                            isExpanded: module.moduleId == expandedModuleId,
                          ),
                        );
                      }),
                    ),
                    if (expandedIndex != -1) ...[
                      SizedBox(height: 14.wMin),
                      _buildExpandedUnitPanel(
                        context,
                        level,
                        rowModules[expandedIndex],
                        expandedColumnIndex: expandedIndex,
                        cardWidth: cardWidth,
                        horizontalSpacing: horizontalSpacing,
                      ),
                    ],
                  ],
                ),
              );
            }),
          );
        },
      );
    });
  }

  Widget _buildLevelHeader({
    required int levelId,
    required String levelName,
    required int? levelTier,
    required String? studyZone,
  }) {
    final bool isRecommended = controller.showRecommend && controller.courseLevelTree.value.studyTier != null && controller.courseLevelTree.value.studyTier == levelTier;
    final Color titleColor = StatusUtils.getStudyZoneColor(studyZone) ?? StatusUtils.getStudyZoneColor(null) ?? AppTheme.cTextPrimary.color;
    return SizedBox(
      key: controller.getLevelHeaderKey(levelId),
      height: controller.moduleHeaderHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (isRecommended) ...[
              SvgPicture.asset(
                'assets/svg/public/recommendStart.svg',
                width: 105.wMin,
                height: 36.wMin,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 10.wMin),
            ],
            Expanded(
              child: Text(
                levelName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 32.wMin,
                  color: titleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildModuleCard(
    BuildContext context,
    CourseLevelTreeLevel level,
    CourseLevelTreeModule? module, {
    required bool isExpanded,
  }) {
    if (module == null) return const SizedBox.shrink();
    final double modProgress = controller.getModuleProgress(module);
    final int unitCount = module.units?.whereType<CourseLevelTreeUnit>().length ?? 0;
    final BorderSide borderSide = BorderSide(
      color: isExpanded ? AppTheme.cBgBrand : AppTheme.cBorderSecondary,
      width: isExpanded ? 2.wMin : 1.wMin,
    );
    final moduleCard = TapScaleWidget(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerElevated,
          borderRadius: BorderRadius.circular(20.wMin),
          border: Border.fromBorderSide(borderSide),
          boxShadow: isExpanded
              ? [
                  BoxShadow(
                    color: AppTheme.cBgBrand.withValues(alpha: 0.16),
                    blurRadius: 20.wMin,
                    spreadRadius: 0,
                    offset: Offset(0, 8.wMin),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(16.wMin),
          child: Column(
            children: [
              SizedBox(
                height: controller.moduleCardBaseHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModuleCover(level, module, modProgress),
                    SizedBox(width: 16.wMin),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.name ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 32.wMin,
                              color: AppTheme.cTextPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 12.wMin),
                          if ((module.tierMappings?.isNotEmpty ?? false))
                            SizedBox(
                              height: 48.wMin,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  spacing: 6.wMin,
                                  children: List.generate(module.tierMappings?.length ?? 0, (idx) {
                                    final themeTextEntity = module.tierMappings?[idx];
                                    final style =
                                        StyleUtils.getCurrentThemeText(themeTextEntity?.style);
                                    final bgColor = ColorUtils.parseColor(style?.backgroundColor);
                                    return Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(8.wMin),
                                      ),
                                      child: StyleUtils.getText(themeTextEntity),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          SizedBox(height: 10.wMin),
                          Expanded(
                            child: Text(
                              module.description ?? "",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20.wMin,
                                color: AppTheme.cTextSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.wMin),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppTheme.cBorderSecondary.withValues(alpha: 0.7),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 16.wMin,
                        children: [
                          ...List.generate(module.knowledgeCounts?.length ?? 0, (i) {
                            return _buildTextRowWidget(module.knowledgeCounts?[i], i);
                          }),
                          if (unitCount > 0)
                            _buildUnitCountWidget(
                              index: module.knowledgeCounts?.length ?? 0,
                              unitCount: unitCount,
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16.wMin),
                  _buildExpandUnitButton(
                    isExpanded: isExpanded,
                    onTap: () {
                      controller.toggleModuleExpanded(module.moduleId);
                    },
                  ),
                ],
              ),
              SizedBox(height: 14.wMin),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99.wMin),
                      child: Container(
                        height: 6.wMin,
                        color: AppTheme.cBlackAlpha10,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (modProgress / 100).clamp(0, 1),
                          child: Container(color: AppTheme.cBgBrand),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.wMin),
                  Text(
                    "${modProgress.toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: 22.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    final targetModuleId = module.moduleId;
    if (targetModuleId == null) return moduleCard;
    return KeyedSubtree(
      key: controller.getModuleKey(targetModuleId),
      child: moduleCard,
    );
  }

  Widget _buildModuleCover(
    CourseLevelTreeLevel level,
    CourseLevelTreeModule module,
    double progress,
  ) {
    return TapScaleWidget(
      onTap: () {
        final unit = module.units?.whereType<CourseLevelTreeUnit>().firstOrNull;
        if (unit == null || unit.unitId == null) return;
        controller.onUnitTap(level, module, unit);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.wMin),
        child: Container(
          clipBehavior: Clip.hardEdge,
          width: 220.wMin,
          height: controller.moduleCardBaseHeight,
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceLayerBase,
            border: Border.all(color: AppTheme.cBorderSecondary.color),
            borderRadius: BorderRadius.circular(20.wMin),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: _LazyVisibilityImage(
                  visibilityKey: 'module_${module.moduleId}_${module.coverUrl ?? ''}',
                  imageBuilder: () => CachedImageWidget(
                    module.coverUrl ?? "",
                    placeholder: buildLoadingWidget(),
                    errorWidget: buildEmptyWidget(),
                  ),
                  placeholder: buildLoadingWidget(),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(14.wMin, 12.wMin, 14.wMin, 12.wMin),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.72),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99.wMin),
                          child: Container(
                            height: 6.wMin,
                            color: AppTheme.cBlackAlpha20,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (progress / 100).clamp(0, 1),
                              child: Container(color: AppTheme.cBgBrand),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.wMin),
                      Text(
                        "${progress.toStringAsFixed(0)}%",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandUnitButton({
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.02,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cBgBrand.withValues(alpha: isExpanded ? 0.18 : 0.08),
          borderRadius: BorderRadius.circular(999.wMin),
          border: Border.all(
            color: isExpanded ? AppTheme.cBgBrand : AppTheme.cBorderDark,
            width: 1.wMin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isExpanded ? "收起 Unit" : "展开 Unit",
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cBgBrand,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8.wMin),
            AnimatedRotation(
              duration: const Duration(milliseconds: 180),
              turns: isExpanded ? 0.5 : 0,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 24.wMin,
                color: AppTheme.cBgBrand,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedUnitPanel(
    BuildContext context,
    CourseLevelTreeLevel level,
    CourseLevelTreeModule module, {
    required int expandedColumnIndex,
    required double cardWidth,
    required double horizontalSpacing,
  }) {
    final pointerCenterX =
        (expandedColumnIndex * (cardWidth + horizontalSpacing)) + (cardWidth / 2);
    final double notchWidth = 72.wMin;
    final double notchHeight = 18.wMin;
    final double panelRadius = 20.wMin;
    final double innerPadding = 14.wMin;
    return CustomPaint(
      painter: _TopNotchedPanelPainter(
        color: AppTheme.cSurfaceLayerElevated,
        borderColor: AppTheme.cBgBrand,
        radius: panelRadius,
        notchCenterX: pointerCenterX,
        notchWidth: notchWidth,
        notchHeight: notchHeight,
        borderWidth: 1.5.wMin,
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          innerPadding,
          innerPadding + notchHeight,
          innerPadding,
          innerPadding,
        ),
        child: _buildUnitGrid(context, level, module),
      ),
    );
  }

  Widget _buildUnitGrid(BuildContext context, CourseLevelTreeLevel level, CourseLevelTreeModule module) {
    final units = module.units ?? [];
    if (units.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: controller.unitGridCrossAxisCount,
        crossAxisSpacing: controller.unitGridCrossAxisSpacing,
        mainAxisSpacing: controller.unitGridMainAxisSpacing,
      ),
      itemCount: units.length,
      itemBuilder: (context, index) {
        final unit = units[index];
        if (unit == null) return const SizedBox.shrink();
        final zhTitle = _preferZh(unit.unitTitle) ?? unit.unitName ?? '';
        final isComplete = (unit.progress ?? 0) >= 1 || (unit.progress ?? 0) >= 100;
        final displayProgress = (unit.progress ?? 0);
        final pct = displayProgress > 1 ? displayProgress : displayProgress * 100;
        return TapScaleWidget(
          onTap: () {
            controller.onUnitTap(level, module, unit);
          },
          sclae: 1.01,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              border: Border.all(
                color: isComplete ? AppTheme.cFeedbackSuccessBorder : AppTheme.cBorderSecondary,
                width: isComplete ? 2 : 1.2,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _LazyVisibilityImage(
                  visibilityKey: 'unit_${unit.unitId}_${unit.unitCoverUrl ?? ''}',
                  imageBuilder: () => CachedImageWidget(
                    unit.unitCoverUrl ?? "",
                    fadeInDuration: Duration.zero,
                    placeholder: buildLoadingWidget(),
                    errorWidget: buildEmptyWidget(),
                  ),
                  placeholder: buildLoadingWidget(),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                if (isComplete)
                  Positioned(
                    top: 8.wMin,
                    right: 8.wMin,
                    child: Container(
                      width: 26.wMin,
                      height: 26.wMin,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cFeedbackSuccessBorder,
                      ),
                      child: Icon(Icons.check, size: 16.wMin, color: Colors.white),
                    ),
                  ),
                Positioned(
                  left: 10.wMin,
                  right: 10.wMin,
                  bottom: 10.wMin,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zhTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 23.wMin,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 40.wMin,
                        child: Text(
                          unit.description ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            height: 1.2,
                            fontSize: 14.wMin,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(99.wMin),
                              child: Container(
                                height: 6.wMin,
                                color: AppTheme.cBlackAlpha20,
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (pct / 100).clamp(0, 1),
                                  child: Container(
                                    color: isComplete ? AppTheme.cFeedbackSuccessText.color : AppTheme.cBgBrand,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.wMin),
                          Text(
                            "${pct.toStringAsFixed(0)}%",
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _preferZh(List<LanguageText?>? texts) {
    if (texts == null) return null;
    for (final t in texts) {
      if (t == null) continue;
      if (t.lang == 'zh') return t.text;
    }
    return texts.first?.text;
  }

  Widget _buildBottomLevelBar(BuildContext context) {
    return Obx(() {
      final levels = controller.visibleLevels;
      if (levels.isEmpty) return const SizedBox.shrink();
      final activeId = controller.activeLevelId.value;
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999.wMin),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.wMin, sigmaY: 4.wMin),
            child: Container(
              height: 80.wMin,
              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cSurfaceSearchBackground.color,
                borderRadius: BorderRadius.circular(999.wMin),
                border: Border.all(
                  color: AppTheme.cBorderDark.color,
                  width: 1.wMin,
                ),
              ),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  key: controller.levelTabViewportKey,
                  controller: controller.levelTabScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(levels.length, (i) {
                      final item = levels[i];
                      final text = item.name ?? "Level ${i + 1}";
                      final isActive = item.levelId == activeId;
                      return Padding(
                        padding: EdgeInsets.only(right: i == levels.length - 1 ? 0 : 12.wMin),
                        child: LWCircularButtonWidget(
                          key: item.levelId == null ? null : controller.getLevelTabKey(item.levelId!),
                          text: text,
                          isAction: isActive,
                          color: AppTheme.cLevelA2Text,
                          sclae: 1.02,
                          onTap: () {
                            controller.scrollToLevel(item.levelId);
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRightToggleButton(BuildContext context) {
    return CardLearningButtonsItemWidget(
      title: "编辑教材",
      svg: "assets/svg/public/icon_edit.svg",
      color: AppTheme.cSurfaceWarning.color,
      index: 0,
      onTap: () {
        controller.editCourse(context);
      },
    );
  }

  Widget _buildTextRowWidget(CourseLevelEntityLevelListModuleListKnowledgeCounts? knowledgeCount, int index) {
    List<LanguageText?>? names = knowledgeCount?.name;
    if (names == null) return Container();
    String name = "";
    for (int i = 0; i < names.length; i++) {
      if (names[i] == null) continue;
      if (names[i]?.lang == "zh") {
        name = names[i]?.text ?? "";
        break;
      }
    }
    return Row(
      spacing: 10.wMin,
      children: [
        if (index != 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 172.wMin),
            width: 1,
            height: 28.wMin,
            decoration: BoxDecoration(
              color: AppTheme.cTextPrimary.withValues(alpha: 0.1),
            ),
          ),
        Text(
          name,
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          knowledgeCount?.count?.toString() ?? '',
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildUnitCountWidget({
    required int index,
    required int unitCount,
  }) {
    return Row(
      spacing: 10.wMin,
      children: [
        if (index != 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 172.wMin),
            width: 1,
            height: 28.wMin,
            decoration: BoxDecoration(
              color: AppTheme.cTextPrimary.withValues(alpha: 0.1),
            ),
          ),
        Text(
          "$unitCount个单元",
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _TopNotchedPanelPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double radius;
  final double notchCenterX;
  final double notchWidth;
  final double notchHeight;
  final double borderWidth;
  final Color shadowColor;

  const _TopNotchedPanelPainter({
    required this.color,
    required this.borderColor,
    required this.radius,
    required this.notchCenterX,
    required this.notchWidth,
    required this.notchHeight,
    required this.borderWidth,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    canvas.drawShadow(path, shadowColor, 12, false);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, borderPaint);
  }

  Path _buildPath(Size size) {
    final left = borderWidth / 2;
    final top = notchHeight + (borderWidth / 2);
    final right = size.width - (borderWidth / 2);
    final bottom = size.height - (borderWidth / 2);
    final safeRadius = math.min(radius, math.min((right - left) / 2, (bottom - top) / 2));
    final notchHalf = notchWidth / 2;
    final minNotchLeft = left + safeRadius + 12.wMin;
    final maxNotchLeft = right - safeRadius - notchWidth - 12.wMin;
    final notchLeft = (notchCenterX - notchHalf).clamp(minNotchLeft, maxNotchLeft);
    final notchRight = notchLeft + notchWidth;
    final notchShoulder = notchWidth * 0.22;
    final apexX = (notchLeft + notchRight) / 2;
    final apexY = borderWidth / 2;

    return Path()
      ..moveTo(left + safeRadius, top)
      ..lineTo(notchLeft, top)
      ..lineTo(notchLeft + notchShoulder, top)
      ..quadraticBezierTo(apexX - notchShoulder, top, apexX, apexY)
      ..quadraticBezierTo(
        apexX + notchShoulder,
        top,
        notchRight - notchShoulder,
        top,
      )
      ..lineTo(notchRight, top)
      ..lineTo(right - safeRadius, top)
      ..arcToPoint(
        Offset(right, top + safeRadius),
        radius: Radius.circular(safeRadius),
      )
      ..lineTo(right, bottom - safeRadius)
      ..arcToPoint(
        Offset(right - safeRadius, bottom),
        radius: Radius.circular(safeRadius),
      )
      ..lineTo(left + safeRadius, bottom)
      ..arcToPoint(
        Offset(left, bottom - safeRadius),
        radius: Radius.circular(safeRadius),
      )
      ..lineTo(left, top + safeRadius)
      ..arcToPoint(
        Offset(left + safeRadius, top),
        radius: Radius.circular(safeRadius),
      )
      ..close();
  }

  @override
  bool shouldRepaint(covariant _TopNotchedPanelPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.radius != radius ||
        oldDelegate.notchCenterX != notchCenterX ||
        oldDelegate.notchWidth != notchWidth ||
        oldDelegate.notchHeight != notchHeight ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.shadowColor != shadowColor;
  }
}

class _LazyVisibilityImage extends StatefulWidget {
  final String visibilityKey;
  final Widget Function() imageBuilder;
  final Widget placeholder;

  const _LazyVisibilityImage({
    required this.visibilityKey,
    required this.imageBuilder,
    required this.placeholder,
  });

  @override
  State<_LazyVisibilityImage> createState() => _LazyVisibilityImageState();
}

class _LazyVisibilityImageState extends State<_LazyVisibilityImage> {
  bool _shouldLoad = false;
  late final String _instanceVisibilityKey;

  @override
  void initState() {
    super.initState();
    _instanceVisibilityKey = '${widget.visibilityKey}_${identityHashCode(this)}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _shouldLoad) return;
      VisibilityDetectorController.instance.notifyNow();
      _tryLoadIfInViewport();
    });
  }

  void _tryLoadIfInViewport() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached || !renderObject.hasSize) {
      return;
    }
    final Offset topLeft = renderObject.localToGlobal(Offset.zero);
    final Rect widgetRect = topLeft & renderObject.size;
    final Size screenSize = MediaQuery.sizeOf(context);
    final Rect viewportRect = Offset.zero & screenSize;
    if (!widgetRect.overlaps(viewportRect)) return;
    setState(() {
      _shouldLoad = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(_instanceVisibilityKey),
      onVisibilityChanged: (info) {
        if (_shouldLoad || info.visibleFraction <= 0) return;
        if (!mounted) return;
        setState(() {
          _shouldLoad = true;
        });
      },
      child: _shouldLoad ? widget.imageBuilder() : widget.placeholder,
    );
  }
}
