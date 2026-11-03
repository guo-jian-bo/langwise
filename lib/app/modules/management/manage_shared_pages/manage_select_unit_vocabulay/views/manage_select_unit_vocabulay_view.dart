import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../elements/common/elements_cards/elements_public_card.dart';
import '../../../../../routes/routes.dart';
import '../../../common/manage_scaffold.dart';
import '../bindings/manage_select_unit_vocabulay_binding.dart';
import '../controllers/manage_select_unit_vocabulay_controller.dart';

class ManageSelectUnitVocabulayView extends GetView<ManageSelectUnitVocabulayController> {
  final String tagText;
  const ManageSelectUnitVocabulayView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SELECT_UNIT_VOCABULAY}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSelectUnitVocabulayView(tagText: tag),
      binding: ManageSelectUnitVocabulayBinding(tag: tag),
      routeName: Routes.MANAGE_SELECT_UNIT_VOCABULAY,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Obx(() {
        if (controller.loadStatus.value == -1) {
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (controller.loadStatus.value == 1 || !controller.hasVisibleItems()) {
              return _buildEmptyWidget();
            }
            return Stack(
              children: [
                SingleChildScrollView(
                  controller: controller.scrollController,
                  padding: EdgeInsets.fromLTRB(90.wMin, 24.wMin, 90.wMin, 80.wMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.wMin),
                      _buildSection(ElementsCardType.word.value),
                      _buildSection(ElementsCardType.phrase.value),
                    ],
                  ),
                ),
                Positioned(
                  right: 90.wMin,
                  bottom: 16.wMin + MediaQuery.of(context).padding.bottom,
                  child: _buildBottomBar(),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  /// 单词/短语分区列表。
  Widget _buildSection(String contentType) {
    return Obx(() {
      final List<KnowledgeCommonEntityList> items = controller.getVisibleItemsByType(contentType);
      if (items.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(bottom: 24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              key: controller.sectionKeys[contentType],
              children: [
                Text(
                  controller.buildTypeCountLabel(contentType),
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TapScaleWidget(
                  onTap: () => controller.toggleSectionSelect(contentType),
                  sclae: 1,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22D3EE).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999.wMin),
                    ),
                    child: Text(
                      controller.buildSectionActionLabel(contentType),
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: const Color(0xFF22D3EE),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.wMin),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final int crossAxisCount = (constraints.maxWidth / 300.wMin).floor().clamp(2, 5);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14.wMin,
                    mainAxisSpacing: 14.wMin,
                    childAspectRatio: 420 / 600,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return _buildKnowledgeCard(items[index]);
                  },
                );
              },
            ),
          ],
        ),
      );
    });
  }

  /// 单个词汇卡片，直接复用公共知识点选择卡片。
  Widget _buildKnowledgeCard(KnowledgeCommonEntityList item) {
    return ElementsSelectKnowledgeCard(
      data: controller.buildCardData(item),
      selected: controller.isSelected(item),
      onTap: () => controller.toggleSelect(item),
    );
  }

  /// 底部操作条，包含锚点切换和确认返回按钮。
  Widget _buildBottomBar() {
    return Obx(() {
      final int selectedCount = controller.getSelectedCount();
      return ButtonWidget(
        text: "完成 · 已选 $selectedCount",
        width: 200.wMin,
        height: 52.wMin,
        borderRadius: 999.wMin,
        color: selectedCount == 0 ? AppTheme.cTextPrimary.color.withValues(alpha: 0.24) : AppTheme.cSurfaceBrand.color.withValues(alpha: 0.8),
        fontColor: AppTheme.cTextPrimary.color,
        fontSize: 20.wMin,
        fontWeight: FontWeight.w600,
        sclae: 1.02,
        onTap: selectedCount == 0 ? null : controller.confirmSelection,
      );
    });
  }
  /// 空态展示。
  Widget _buildEmptyWidget() {
    return const Center(
      child: NotDataWidget(message: "暂无可选词汇"),
    );
  }
}
