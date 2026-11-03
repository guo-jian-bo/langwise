import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../bindings/mission_content_select_binding.dart';
import '../controllers/mission_content_select_controller.dart';
import '../models/mission_content_select_model.dart';

class MissionContentSelectView extends GetView<MissionContentSelectController> {
  final String tagText;
  const MissionContentSelectView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => MissionContentSelectView(tagText: tag),
      binding: MissionContentSelectBinding(tagText: tag),
      routeName: Routes.MISSION_CONTENT_SELECT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          const BreadcrumbWidget(),
          Expanded(
            child: Obx(() {
              if (controller.loadStatus.value == -1) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.loadStatus.value == 1) {
                return const NotDataWidget(message: "暂无内容");
              }
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.wMin, 12.wMin, 20.wMin, 120.wMin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.missionTitle.isNotEmpty) ...[
                          Text(
                            controller.missionTitle,
                            style: TextStyle(
                              fontSize: 26.wMin,
                              color: AppTheme.cStaticWhite.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 12.wMin),
                        ],
                        _buildSection(ElementsCardType.word.value),
                        _buildSection(ElementsCardType.phrase.value),
                        _buildSection(ElementsCardType.sentence.value),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16.wMin,
                    right: 16.wMin,
                    bottom: 16.wMin + MediaQuery.of(context).padding.bottom,
                    child: _buildBottomBar(),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String contentType) {
    return Obx(() {
      final items = controller.itemsForType(contentType);
      if (items.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(bottom: 22.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  controller.typeCountLabel(contentType),
                  style: TextStyle(
                    fontSize: 22.wMin,
                    color: AppTheme.cStaticWhite.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TapScaleWidget(
                  onTap: () => controller.toggleSectionSelect(contentType),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999.wMin),
                    ),
                    child: Text(
                      controller.sectionActionLabel(contentType),
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: const Color(0xFF38BDF8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.wMin),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 14.wMin,
                mainAxisSpacing: 14.wMin,
                mainAxisExtent: 500.wMin,
              ),
              itemBuilder: (context, index) {
                return _buildContentCard(items[index]);
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildContentCard(MissionContentSelectItemModel item) {
    final isSelected = controller.isSelected(item);
    final detail = item.detail;
    final zhGloss = LearningLangUtils.getLocalLang(detail.gloss)?.text ??
        LearningLangUtils.getLearningLang(detail.gloss)?.text ??
        detail.definition ??
        '';
    return TapScaleWidget(
      onTap: () => controller.toggleSelect(item),
      sclae: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary.color,
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(
            color: isSelected ? const Color(0xFF38BDF8) : AppTheme.cBgTertiary.color,
            width: 1.5.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.wMin)),
              child: SizedBox(
                height: 330.wMin,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    (detail.imageUrl ?? "").isNotEmpty
                        ? CachedImageWidget(
                            detail.imageUrl ?? "",
                            fit: BoxFit.cover,
                            placeholder: _buildCoverPlaceholder(),
                            errorWidget: _buildCoverPlaceholder(),
                          )
                        : _buildCoverPlaceholder(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.18),
                          ],
                          stops: const [0, 0.58, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10.wMin,
                      left: 10.wMin,
                      child: _buildStatusBadge(item.isNew),
                    ),
                    Positioned(
                      top: 10.wMin,
                      right: 10.wMin,
                      child: _buildSelectBadge(isSelected),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.wMin, 10.wMin, 12.wMin, 12.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  
                    Text(
                      detail.content ?? '--',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 36.wMin,
                        color: AppTheme.cStaticWhite.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
               
                    Text(
                      zhGloss,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextSecondary.color,
                     
                      ),
                    ),
                    Spacer(),
                  
                    Wrap(
                      spacing: 4.wMin,
                      runSpacing: 4.wMin,
                      children: [
                        _buildTypeTag(item.typeLabel, const Color(0xFF0EA5E9)),
                        if ((detail.posTitle ?? '').isNotEmpty) _buildTypeTag(detail.posTitle!, const Color(0xFFF59E0B)),
                        if (_buildDifficultyLabel(detail) != null) _buildTypeTag(_buildDifficultyLabel(detail)!, const Color(0xFF6B7280)),
                      ],
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

  Widget _buildStatusBadge(bool isNew) {
    final color = isNew ? const Color(0xFF65A30D) : const Color(0xFFEA580C);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.wMin),
      ),
      child: Text(
        isNew ? '新知' : '旧识',
        style: TextStyle(
          fontSize: 14.wMin,
          color: AppTheme.cStaticWhite.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSelectBadge(bool isSelected) {
    return Container(
      width: 22.wMin,
      height: 22.wMin,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF22C55E) : AppTheme.cStaticWhite.color.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(6.wMin),
        border: Border.all(
          color: AppTheme.cStaticWhite.color.withValues(alpha: isSelected ? 0 : 0.85),
          width: 1.wMin,
        ),
      ),
      child: isSelected
          ? Icon(
              Icons.check_rounded,
              size: 16.wMin,
              color: AppTheme.cStaticWhite.color,
            )
          : null,
    );
  }

  Widget _buildTypeTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6.wMin),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.wMin,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailTags(List<UnitKnowledgePointsEntityKnowledgeListTags?>? tags) {
    final list = tags?.whereType<UnitKnowledgePointsEntityKnowledgeListTags>().toList() ?? [];
    if (list.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 4.wMin,
      runSpacing: 4.wMin,
      children: list.map((tag) {
        final themeText = StyleUtils.getCurrentThemeText(tag.style);
        final text = LearningLangUtils.getLocalLang(tag.gloss)?.text ??
            LearningLangUtils.getLearningLang(tag.gloss)?.text ??
            '';
        if (text.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: ColorUtils.parseColor(themeText?.backgroundColor) ?? AppTheme.cTextInverse.color,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: (themeText?.fontsize ?? 16).wMin,
              color: ColorUtils.parseColor(themeText?.color) ?? AppTheme.cInverseTextLight.color,
            ),
          ),
        );
      }).where((widget) => widget is! SizedBox).toList(),
    );
  }

  Widget _buildBottomBar() {
    return Obx(() {
      final selectedCount = controller.visibleSelectedCount;
      final totalCount = controller.visibleItems.length;
      return ClipRRect(
        borderRadius: BorderRadius.circular(999.wMin),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.wMin, sigmaY: 4.wMin),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 10.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceSearchBackground.color,
              borderRadius: BorderRadius.circular(999.wMin),
              border: Border.all(
                color: AppTheme.cBorderDark.color,
                width: 1.wMin,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cStaticWhite.color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999.wMin),
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip(MissionContentSelectFilter.all, "全部"),
                      SizedBox(width: 6.wMin),
                      _buildFilterChip(MissionContentSelectFilter.oldKnowledge, "旧识"),
                      SizedBox(width: 6.wMin),
                      _buildFilterChip(MissionContentSelectFilter.newKnowledge, "新知"),
                    ],
                  ),
                ),
                SizedBox(width: 24.wMin),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildBottomSummaryText(controller.typeSummaryLabel(ElementsCardType.word.value)),
                      SizedBox(width: 18.wMin),
                      _buildBottomSummaryText(controller.typeSummaryLabel(ElementsCardType.phrase.value)),
                      SizedBox(width: 18.wMin),
                      _buildBottomSummaryText(controller.typeSummaryLabel(ElementsCardType.sentence.value)),
                      SizedBox(width: 24.wMin),
                      Text(
                        "总数 $selectedCount / $totalCount",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cStaticWhite.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 14.wMin),
                      ButtonWidget(
                        text: "去学习",
                        width: 108.wMin,
                        height: 46.wMin,
                        borderRadius: 999.wMin,
                        color: const Color(0xFF1E88E5),
                        fontColor: AppTheme.cStaticWhite.color,
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w600,
                        sclae: 1.02,
                        onTap: selectedCount == 0 ? null : controller.onTapStartPreview,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFilterChip(MissionContentSelectFilter filter, String text) {
    final selected = controller.selectedFilter.value == filter;
    return TapScaleWidget(
      onTap: () => controller.updateFilter(filter),
      sclae: 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 22.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.cStaticWhite.color.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999.wMin),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10.wMin,
                    offset: Offset(0, 2.wMin),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.wMin,
            color: selected
                ? AppTheme.cStaticWhite.color
                : AppTheme.cStaticWhite.color.withValues(alpha: 0.72),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSummaryText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.wMin,
        color: AppTheme.cStaticWhite.color.withValues(alpha: 0.88),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String? _buildDifficultyLabel(UnitKnowledgePointsEntityKnowledgeList detail) {
    final min = detail.difficulty?.min;
    final max = detail.difficulty?.max;
    if (min == null) return null;
    final minLabel = _difficultyLevelText(min);
    if (max == null || max == min) return minLabel;
    return "$minLabel-${_difficultyLevelText(max)}";
  }

  String _difficultyLevelText(int level) {
    switch (level) {
      case 1:
        return 'A1';
      case 2:
        return 'A2';
      case 3:
        return 'B1';
      case 4:
        return 'B2';
      case 5:
        return 'C1';
      case 6:
        return 'C2';
      default:
        return 'A1';
    }
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cBgSecondary.color,
            AppTheme.cBgTertiary.color,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 44.wMin,
          color: AppTheme.cTextTertiary.color,
        ),
      ),
    );
  }
}
