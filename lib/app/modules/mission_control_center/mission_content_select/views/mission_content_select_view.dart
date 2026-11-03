import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../routes/routes.dart';
import '../../../elements/common/elements_cards/elements_public_card.dart';
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
    final horizontalInset = 90.wMin;
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          BreadcrumbWidget(
            actionWidget: GeneralSettingButtonWidget(),
          ),
          Expanded(
            child: Obx(() {
              if (controller.loadStatus.value == -1) {
                return const SizedBox.shrink();
              }
              if (controller.loadStatus.value == 1) {
                return const NotDataWidget(message: "暂无内容");
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  final viewportSpacer = constraints.maxHeight * 0.78;
                  final minSpacer = 220.wMin;
                  final bottomSpacerHeight = viewportSpacer > minSpacer
                      ? viewportSpacer
                      : minSpacer;
                  return Stack(
                    children: [
                      CustomScrollView(
                        controller: controller.scrollController,
                        slivers: [
                          ..._buildSectionSlivers(
                            ElementsCardType.word.value,
                            horizontalInset: horizontalInset,
                            topSpacing: 12.wMin,
                          ),
                          ..._buildSectionSlivers(
                            ElementsCardType.phrase.value,
                            horizontalInset: horizontalInset,
                          ),
                          ..._buildSectionSlivers(
                            ElementsCardType.sentence.value,
                            horizontalInset: horizontalInset,
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(height: bottomSpacerHeight),
                          ),
                        ],
                      ),
                      Positioned(
                        left: 200.wMin,
                        right: 200.wMin,
                        bottom: 16.wMin + MediaQuery.of(context).padding.bottom,
                        child: _buildBottomBar(),
                      ),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSectionSlivers(
    String contentType, {
    required double horizontalInset,
    double topSpacing = 0,
  }) {
    return [
      Obx(() {
        final items = controller.itemsForType(contentType);
        return SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalInset, topSpacing, horizontalInset, 12.wMin),
          sliver: SliverToBoxAdapter(
            child: Row(
              key: controller.sectionKeys[contentType],
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  controller.typeCountLabel(contentType),
                  style: TextStyle(
                    fontSize: 22.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TapScaleWidget(
                  onTap: items.isEmpty ? null : () => controller.toggleSectionSelect(contentType),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: items.isEmpty ? 0.08 : 0.2),
                      borderRadius: BorderRadius.circular(999.wMin),
                    ),
                    child: Text(
                      controller.sectionActionLabel(contentType),
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: const Color(0xFF38BDF8).withValues(alpha: items.isEmpty ? 0.5 : 1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      Obx(() {
        final items = controller.itemsForType(contentType);
        if (items.isNotEmpty) {
          return SliverPadding(
            padding: EdgeInsets.fromLTRB(horizontalInset, 0, horizontalInset, 22.wMin),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildContentCard(items[index]),
                childCount: items.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 14.wMin,
                mainAxisSpacing: 14.wMin,
                childAspectRatio: 420 / 600,
              ),
            ),
          );
        }
        return SliverToBoxAdapter(
          child: SizedBox(height: 22.wMin),
        );
      }),
    ];
  }

  Widget _buildContentCard(MissionContentSelectItemModel item) {
    final detail = item.detail;
    return Obx(() {
      return ElementsSelectKnowledgeCard(
        data: detail,
        selected: controller.isSelected(item),
        isNew: item.isNew,
        showNewOld: !controller.isCurrentCourseSource,
        onTap: () => controller.toggleSelect(item),
      );
    });
  }

  
  Widget _buildBottomBar() {
    return Obx(() {
      final selectedCount = controller.visibleSelectedCount;
      final totalCount = controller.visibleItemCount.value;
      return ClipRRect(
        borderRadius: BorderRadius.circular(999.wMin),
        child: PlatformBackdropFilterWidget(
          sigmaX: 4.wMin,
          sigmaY: 4.wMin,
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
                Expanded(
                  child: Wrap(
                    spacing: 10.wMin,
                    runSpacing: 8.wMin,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (!controller.isCurrentCourseSource)
                        _buildChipGroup(
                          children: [
                            _buildFilterChip(MissionContentSelectFilter.all, "全部"),
                            _buildFilterChip(MissionContentSelectFilter.oldKnowledge, "旧识"),
                            _buildFilterChip(MissionContentSelectFilter.newKnowledge, "新知"),
                          ],
                        ),
                      _buildSectionAnchorChip(ElementsCardType.word.value),
                      _buildSectionAnchorChip(ElementsCardType.phrase.value),
                      _buildSectionAnchorChip(ElementsCardType.sentence.value),
                    ],
                  ),
                ),
                SizedBox(width: 18.wMin),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "总数 $selectedCount / $totalCount",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10.wMin),
                      ButtonWidget(
                        text: "去学习",
                        width: 96.wMin,
                        height: 46.wMin,
                        borderRadius: 999.wMin,
                        color: selectedCount == 0 ? AppTheme.cTextPrimary.color.withValues(alpha: 0.24) : const Color(0xFF1E88E5),
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

  Widget _buildChipGroup({required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(4.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cTextPrimary.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999.wMin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int index = 0; index < children.length; index++) ...[
            if (index > 0) SizedBox(width: 6.wMin),
            children[index],
          ],
        ],
      ),
    );
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
              ? AppTheme.cTextPrimary.color.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999.wMin),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.cSurfaceLayerBase.color,
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
                ? AppTheme.cTextPrimary.color
                : AppTheme.cTextPrimary.color.withValues(alpha: 0.72),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionAnchorChip(String contentType) {
    final selected = controller.currentAnchorType.value == contentType;
    final type = ElementsCardType.fromRawValue(contentType);
    final count = controller.selectedCountForType(contentType);
    final hasItems = controller.hasItemsForType(contentType);
    return TapScaleWidget(
      onTap: () => controller.scrollToType(contentType),
      sclae: 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.cTextPrimary.color.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999.wMin),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type.name,
              style: TextStyle(
                fontSize: 16.wMin,
                color: selected
                    ? AppTheme.cTextPrimary.color
                    : AppTheme.cTextPrimary.color.withValues(alpha: hasItems ? 0.72 : 0.48),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            SizedBox(
              width: 32.wMin,
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: selected
                      ? AppTheme.cTextPrimary.color
                      : AppTheme.cTextPrimary.color.withValues(alpha: hasItems ? 0.72 : 0.48),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
