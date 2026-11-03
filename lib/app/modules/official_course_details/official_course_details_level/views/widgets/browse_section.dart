import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../utils/utils.dart';
import '../../controllers/official_course_details_level_controller.dart';
import 'cards/browse_module_card.dart';
import 'lazy_visibility_image.dart';

class BrowseSection extends GetView<OfficialCourseDetailsLevelController> {
  final String tagText;
  final double bottomPadding;
  final Color chemeColor;

  const BrowseSection({
    super.key,
    required this.tagText,
    required this.bottomPadding,
    required this.chemeColor,
  });

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        controller: controller.scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.fromLTRB(90.wMin, 16.wMin, 90.wMin, bottomPadding),
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
        SizedBox(height: 8.wMin),
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
                          child: KeyedSubtree(
                            key: module.moduleId == null
                                ? null
                                : controller.getModuleKey(module.moduleId!),
                            child: BrowseModuleCard(
                              tagText: tagText,
                              module: module,
                              isExpanded: module.moduleId == expandedModuleId,
                              chemeColor: chemeColor,
                            ),
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
    final bool isRecommended = controller.showRecommend &&
        controller.courseLevelTree.value.studyTier != null &&
        controller.courseLevelTree.value.studyTier == levelTier;
    final Color titleColor = StatusUtils.getStudyZoneColor(studyZone) ??
        StatusUtils.getStudyZoneColor(null) ??
        AppTheme.cTextPrimary.color;
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
        borderColor: chemeColor,
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
    return Obx(() {
      final recentVisitedUnitId = controller.recentVisitedUnitId.value;
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
          final rawUnitProgress = unit.progress ?? 0;
          final double progress = rawUnitProgress <= 0
              ? 0.0
              : rawUnitProgress <= 1
                  ? (rawUnitProgress * 100).clamp(0, 100).toDouble()
                  : rawUnitProgress.clamp(0, 100).toDouble();
          final double progressRowHeight = 18.wMin;
          final double progressRowGap = 10.wMin;
          final isRecentVisited = unit.unitId != null && recentVisitedUnitId == unit.unitId;
          final borderColor = isRecentVisited
              ? chemeColor
              : isComplete
                  ? AppTheme.cFeedbackSuccessBorder
                  : AppTheme.cBorderSecondary;
          final double borderWidth = isRecentVisited ? 2.4 : (isComplete ? 2.0 : 1.2);
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
                  color: borderColor,
                  width: borderWidth,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LazyVisibilityImage(
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
                    bottom: 10.wMin + progressRowHeight + progressRowGap,
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
                          height: 32.wMin,
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
                      ],
                    ),
                  ),
                  Positioned(
                    left: 10.wMin,
                    right: 10.wMin,
                    bottom: 10.wMin,
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
                                child: Container(color: chemeColor),
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
                
                
                ],
              ),
            ),
          );
        },
      );
    });
  }

  String? _preferZh(List<LanguageText?>? texts) {
    if (texts == null) return null;
    for (final t in texts) {
      if (t == null) continue;
      if (t.lang == 'zh') return t.text;
    }
    return texts.first?.text;
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
