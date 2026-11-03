import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:langwise/common/widgets/card_learning_buttons_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../utils/utils.dart';
import '../controllers/official_course_details_level_controller.dart';

class OfficialCourseDetailsLevelView extends GetView<OfficialCourseDetailsLevelController> {
  const OfficialCourseDetailsLevelView({super.key});
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
                if (controller.levels.isEmpty) {
                  return Center();
                }
                return ListViewObserver(
                  controller: controller.listObserverController,
                  dynamicLeadingOffset: () => MediaQuery.of(context).size.height * 0.3,
                  onObserve: (model) {
                    controller.onListObserve(model);
                  },
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 100.wMin, vertical: 16.wMin),
                    itemCount: controller.moduleItems.length,
                    itemBuilder: (context, index) {
                      final item = controller.moduleItems[index];
                      return _buildModuleListItem(context, item);
                    },
                  ),
                );
              })),
            ],
          ),
          Positioned(
            bottom: 36.wMin,
            left: 0,
            right: 0,
            child: _buildBottomLevelBar(context),
          ),
          Positioned(
            right: 16.wMin,
            bottom: 160.wMin,
            child: _buildRightToggleButton(context),
          ),
        ]),
      );
    });
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24.wMin, left: 40.wMin, right: 40.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            return BackWidget(title: controller.courseTitle.value);
          }),
          Row(
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
        ],
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

  Widget _buildModuleListItem(BuildContext context, ModuleListItem item) {
    final module = item.module;
    final body = module == null ? const SizedBox.shrink() : buildModuleCard(context, controller.levels[item.levelIndex], module);

    if (item.showLevelHeader) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLevelHeader(
            levelIndex: item.levelIndex,
            levelName: item.levelName,
          ),
          SizedBox(height: controller.moduleHeaderGap),
          body,
          SizedBox(height: controller.moduleItemGap),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        body,
        SizedBox(height: controller.moduleItemGap),
      ],
    );
  }

  Widget _buildLevelHeader({
    required int levelIndex,
    required String levelName,
  }) {
    return SizedBox(
      height: controller.moduleHeaderHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          levelName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 32.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget buildModuleCard(BuildContext context, CourseLevelTreeLevel level, CourseLevelTreeModule? module) {
    if (module == null) return const SizedBox.shrink();
    double modProgress = controller.getModuleProgress(module);
    return TapScaleWidget(
      onTap: () {
        controller.onModuleTap(level, module);
      },
      sclae: 1.01,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.wMin),
          // --- 这里是边框 ---
          border: Border.all(
            color: AppTheme.cBorderSecondary, // 边框颜色
            width: 1.wMin, // 边框宽度
          ),
        ),
        child: Column(
          children: [
            Container(
              color: AppTheme.cTextPrimary.withValues(alpha: 0.05),
              child: SizedBox(
                height: controller.moduleCardBaseHeight,
                child: Padding(
                  padding: EdgeInsets.all(16.wMin),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                      ThemeTextEntity? themeTextEntity = module.tierMappings?[idx];
                                      ThemeTextStyleEntity? style = StyleUtils.getCurrentThemeText(themeTextEntity?.style);
                                      Color? bgColor = ColorUtils.parseColor(style?.backgroundColor);
                                      return Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
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
                            Text(
                              module.description ?? "",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 26.wMin,
                                color: AppTheme.cTextSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            if (module.knowledgeCounts?.isNotEmpty ?? false)
                              SizedBox(
                                  height: controller.knowledgeCountsHeight,
                                  child: Column(
                                    children: [
                                      Row(
                                        spacing: 16.wMin,
                                        children: [
                                          ...List.generate(module.knowledgeCounts?.length ?? 0, (i) {
                                            return _buildTextRowWidget(module.knowledgeCounts?[i], i);
                                          }),
                                          if (module.units?.isNotEmpty ?? false)
                                            _buildUnitCountWidget(
                                              index: module.knowledgeCounts?.length ?? 0,
                                              unitCount: module.units?.whereType<CourseLevelTreeUnit>().length ?? 0,
                                            ),
                                        ],
                                      ),
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
                                  )),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.wMin),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18.wMin),
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.cBorderSecondary.color),
                            borderRadius: BorderRadius.circular(16.wMin),
                          ),
                          width: 240.wMin,
                          height: 320.wMin,
                          child: CachedImageWidget(
                            module.coverUrl ?? "",
                            fit: BoxFit.cover,
                            placeholder: buildLoadingWidget(),
                            errorWidget: buildEmptyWidget(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              // color: AppTheme.cTestPrimary,
              child: Obx(() {
                if (!controller.unitsExpanded.value) return const SizedBox.shrink();
                if ((module.units?.isEmpty ?? true)) return const SizedBox.shrink();
                return Container(
                  padding: EdgeInsets.all(12.wMin),
                  child: _buildUnitGrid(context, level, module),
                );
              }),
            )
          ],
        ),
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
        final hasProgress = (unit.progress ?? 0) > 0;
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
                CachedImageWidget(
                  unit.unitCoverUrl ?? "",
                  fit: BoxFit.cover,
                  placeholder: buildLoadingWidget(),
                  errorWidget: buildEmptyWidget(),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppTheme.cBgPrimary.withValues(alpha: 0.55),
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
                      child: Icon(Icons.check, size: 16.wMin, color: AppTheme.cTextPrimary.color),
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
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

               
                      SizedBox(
                        height: 40.wMin,
                        child: Text(
                          unit.description ??"",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            height: 1.2,
                            fontSize: 14.wMin,
                            color: AppTheme.cTextPrimary.withValues(alpha: 0.75),
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
                              color: isComplete ? AppTheme.cFeedbackSuccessText.color : AppTheme.cTextSecondary.color,
                              fontWeight: FontWeight.w800,
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
      if (controller.levels.isEmpty) return const SizedBox.shrink();
      final activeId = controller.activeLevelId.value;
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999.wMin),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cBgPrimary.withValues(alpha: 0.26),
                borderRadius: BorderRadius.circular(999.wMin),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 6.wMin,
                  children: List.generate(controller.levels.length, (i) {
                    final item = controller.levels[i];
                    final text = item.name ?? "Level ${i + 1}";
                    final isActive = item.levelId == activeId;
                    return TapScaleWidget(
                      onTap: () {
                        controller.scrollToLevel(item.levelId);
                      },
                      sclae: 1.02,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 8.wMin),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.cFeedbackSuccessBorder.withValues(alpha: 0.20) : null,
                          borderRadius: BorderRadius.circular(999.wMin),
                          border: Border.all(color: isActive ? AppTheme.cFeedbackSuccessBorder.withValues(alpha: 0.12) : Colors.transparent),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              text,
                              style: TextStyle(
                                fontSize: 26.wMin,
                                color: isActive ? AppTheme.cFeedbackSuccessBorder.withValues(alpha: 0.85) : AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRightToggleButton(BuildContext context) {
    return Obx(() {
      final expanded = controller.unitsExpanded.value;
      final isCustomCourse = controller.isFromCustomCourse == true;
      return Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16.wMin,
        children: [

          CardLearningButtonsItemWidget(
            title: expanded ? "折叠单元" : "展开单元",
            svg: "assets/svg/public/icon_caret_down.svg",
            color: AppTheme.cTextPrimary,
            index: 0,
            iconQuarterTurns: expanded ? 2 : 0,
            onTap: () {
              controller.toggleUnitsExpanded();
            },
          ),
          Opacity(
            opacity: isCustomCourse ? 1 : 0,
            child: IgnorePointer(
              ignoring: !isCustomCourse,
              child: CardLearningButtonsItemWidget(
                title: "编辑课程",
                svg: "assets/svg/public/icon_edit.svg",
                color: AppTheme.cSurfaceWarning.color,
                index: 1,
                onTap: () {
                  controller.editCourse(context);
                },
              ),
            ),
          ),
        ],
      );
    });
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
            fontSize: 22.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          knowledgeCount?.count?.toString() ?? '',
          style: TextStyle(
            fontSize: 22.wMin,
            color: AppTheme.cTextBrand.withValues(alpha: 0.7),
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
            fontSize: 22.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
