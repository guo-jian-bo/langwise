import 'dart:ui';

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
import '../../../../../common/widgets/starsview/pricure_action_button_widget.dart';
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
      OfficialCourseDetailsLevelView(tagText: tag),
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
                if (controller.levels.isEmpty) {
                  return const Center();
                }
                if (_isAllModuleListsEmpty()) {
                  return NotDataWidget(
                    message: '开始打造你的专属教材库',
                    buttonText: '立即添加教材',
                    onButton: () {
                      controller.editCourse(context);
                    },
                  );
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
                        ...List.generate(controller.moduleItems.length, (index) {
                          final item = controller.moduleItems[index];
                          return _buildModuleListItem(context, item);
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
          Obx(() {
            if (controller.levels.isEmpty || _isAllModuleListsEmpty() || controller.isFromStudyPlan == true) {
              return const SizedBox.shrink();
            }
            return Positioned(
              right: 16.wMin,
              bottom: 160.wMin,
              child: _buildRightToggleButton(context),
            );
          }),
        ]),
      );
    });
  }

  bool _isAllModuleListsEmpty() {
    return controller.visibleLevels.isEmpty;
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
            levelId: item.levelId,
            levelName: item.levelName,
            levelTier: controller.levels[item.levelIndex].tier,
            studyZone: controller.levels[item.levelIndex].studyZone,
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

  Widget buildModuleCard(BuildContext context, CourseLevelTreeLevel level, CourseLevelTreeModule? module) {
    if (module == null) return const SizedBox.shrink();
    double modProgress = controller.getModuleProgress(module);
    final moduleCard = TapScaleWidget(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerElevated,
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
              color: AppTheme.cSurfaceLayerBase,
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
                      TapScaleWidget(
                        onTap: () {
                          final unit = module.units?[0] as CourseLevelTreeUnit?;
                          if (unit == null) return;
                          if (unit.unitId == null) return;
                          controller.onUnitTap(level, module, unit);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.wMin),
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.cBorderSecondary.color),
                              borderRadius: BorderRadius.circular(20.wMin),
                            ),
                            width: 240.wMin,
                            height: 335.wMin,
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
                                  right: 10.wMin,
                                  bottom: 10.wMin,
                                  child: Center(
                                    child: PricureActionButtonWidget(
                                      title: '课时列表',
                                      color: AppTheme.cTextPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
    final targetModuleId = module.moduleId;
    if (targetModuleId == null) return moduleCard;
    return KeyedSubtree(
      key: controller.getModuleKey(targetModuleId),
      child: moduleCard,
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
                title: "编辑教材",
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
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          knowledgeCount?.count?.toString() ?? '',
          style: TextStyle(
            fontSize: 22.wMin,
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
            fontSize: 22.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
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
