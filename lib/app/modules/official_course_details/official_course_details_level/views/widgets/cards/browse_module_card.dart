import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../controllers/official_course_details_level_controller.dart';
import '../lazy_visibility_image.dart';
import 'course_module_card_main_content.dart';
import 'course_module_card_shell.dart';

class BrowseModuleCard extends GetView<OfficialCourseDetailsLevelController> {
  final String tagText;
  final CourseLevelTreeModule module;
  final bool isExpanded;
  final Color chemeColor;

  const BrowseModuleCard({
    super.key,
    required this.tagText,
    required this.module,
    required this.isExpanded,
    required this.chemeColor,
  });

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    final double modProgress = controller.getModuleProgress(module);
    final int unitCount = module.units?.whereType<CourseLevelTreeUnit>().length ?? 0;
    final BorderSide borderSide = BorderSide(
      color: isExpanded ? chemeColor : AppTheme.cBorderSecondary,
      width: isExpanded ? 2.wMin : 1.wMin,
    );

    return TapScaleWidget(
      onTap: () {
        controller.toggleModuleExpanded(module.moduleId);
      },
      sclae: 1.0,
      child: CourseModuleCardShell(
        borderSide: borderSide,
        mainContentHeight: controller.moduleCardBaseHeight,
        mainContent: CourseModuleCardMainContent(
          cover: _buildModuleCover(modProgress),
          title: module.name ?? "",
          description: module.description ?? "",
          tierMappings: module.tierMappings,
        ),
        footer: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 16.wMin,
                  children: [
                    ...List.generate(module.knowledgeCounts?.length ?? 0, (index) {
                      return _buildTextRowWidget(module.knowledgeCounts?[index], index);
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
            _buildExpandUnitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCover(double progress) {
    final coverHeight = controller.moduleCardBaseHeight;
    final coverWidth = coverHeight * 3 / 4;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.wMin),
      child: Container(
        clipBehavior: Clip.hardEdge,
        width: coverWidth,
        height: coverHeight,
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase,
          border: Border.all(color: AppTheme.cBorderSecondary.color),
          borderRadius: BorderRadius.circular(20.wMin),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: LazyVisibilityImage(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandUnitButton() {
    return TapScaleWidget(
      onTap: () {
        controller.toggleModuleExpanded(module.moduleId);
      },
      sclae: 1.02,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase.color,
          borderRadius: BorderRadius.circular(6.wMin),
          border: Border.all(
            color: AppTheme.cSurfaceLayerElevated.color,
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
                color: chemeColor,
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
                color: chemeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextRowWidget(
    CourseLevelEntityLevelListModuleListKnowledgeCounts? knowledgeCount,
    int index,
  ) {
    final List<LanguageText?>? names = knowledgeCount?.name;
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
