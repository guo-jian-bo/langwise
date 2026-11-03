import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../../elements/common/elements_cards/elements_public_card.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_phrase_structure_details_binding.dart';
import '../controllers/zhenxie_phrase_structure_details_controller.dart';

class ZhenxiePhraseStructureDetailsView extends GetView<ZhenxiePhraseStructureDetailsController> {
  final String tagText;
  const ZhenxiePhraseStructureDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_PHRASE_STRUCTURE_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxiePhraseStructureDetailsView(tagText: tag),
      binding: ZhenxiePhraseStructureDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PHRASE_STRUCTURE_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxiePhraseStructureDetailsView(tagText: tag),
      binding: ZhenxiePhraseStructureDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PHRASE_STRUCTURE_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () {
        controller.getDetails();
      },
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            BreadcrumbWidget(
              isCompatibleManage: controller.isManagement,
              actionWidget: GeneralSettingButtonWidget(
                isManagement: controller.isManagement,
              ),
            ),
          Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 90.wMin),
                child: _buildScrollWidget(context),
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildScrollWidget(BuildContext context) {
      return Obx(() {
        if (controller.isLoading.value) return const SizedBox.shrink();
        final data = controller.detailData.value;
        final List<KnowledgeCommonEntityList?> contentCards = data.contentCards ?? <KnowledgeCommonEntityList?>[];
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: CustomScrollView(
            key: controller.mainScrollViewKey,
            controller: controller.mainScrollController,
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 24.wMin)),
              SliverToBoxAdapter(child: _buildContentWidget(context)),
              SliverToBoxAdapter(child: SizedBox(height: 24.wMin)),
              SliverToBoxAdapter(child: _buildInfoWidget()),
              SliverToBoxAdapter(child: SizedBox(height: 24.wMin)),
              if (contentCards.isEmpty)
                const SliverToBoxAdapter(
                  child: NotDataWidget(message: "暂无词卡"),
                )
              else
                SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 24.wMin,
                    crossAxisSpacing: 24.wMin,
                    childAspectRatio: 346 / 546,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final cardData = contentCards[index];
                      final isSelected = controller.selectedPhraseItemUid.value != null &&
                          controller.isContentCardSelected(cardData);
                      return AnimatedContainer(
                        key: controller.getContentCardKey(index),
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.wMin),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.48)
                                : Colors.transparent,
                            width: 1.wMin,
                          ),
                        ),
                        child: ElementsDictReadCard(
                          data: cardData,
                        ),
                      );
                    },
                    childCount: contentCards.length,
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: 40.wMin)),
            ],
          ),
        );
      });
    }

  Widget _buildContentWidget(BuildContext context){
    return Obx((){
      PhraseStructureEntity data = controller.detailData.value;
      final int? selectedPhraseItemUid = controller.selectedPhraseItemUid.value;
      ConfigController configController = Get.find<ConfigController>();
      final posColor = StatusUtils.getConfigColor(configController.colorConfigs.value.pos, data.pos??'');
      Color posBorderColor = posColor?.color?.borderColor ?? AppTheme.cSurfaceBrand.color;

      return Container(
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase.color,
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(
            color: AppTheme.cBorderThin.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "块内怎么切",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
                Spacer(),
                _buildTagWidget(
                  tagText: data.mixLabel??'',
                ),
                SizedBox(width: 6.wMin),
                _buildTagWidget(
                  tagText: posColor?.title??'',
                  textColor: posBorderColor,
                  bgColor: posBorderColor.withValues(alpha: 0.12),
                  borderColor: posBorderColor.withValues(alpha: 0.6),
                ),
                // SizedBox(width: 6.wMin),
                // _buildTagWidget(
                //   tagText: "词典词条",
                // ),
              ],
            ),
            SizedBox(height: 8.wMin),
            Row(
              children: [
                Text(
                  data.content??'',
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                SizedBox(width: 4.wMin),
                CopyTagWidget(
                  name: "短语",
                  value: data.phraseId?.toString()??'',
                  isShow: controller.isManagement,
                ),
              ],
            ),
            SizedBox(height: 8.wMin),
            Text(
              "先看这块短语内部的词各干什么，再点词卡进词典，落到这个用法对应的第一条义项。",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            SizedBox(height: 16.wMin),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: AppTheme.cSurfaceLayerBase.color,
              ),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false, // 隐藏滚动条
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.wMin),
                  child: IntrinsicHeight(
                    child: Row(
                      spacing: 6.wMin,
                      children: List.generate(data.items?.length??0, (index){
                        PhraseStructureEntityItems? item = data.items?[index];
                        return _buildPhraseItemWidget(
                          item,
                          isSelected: item?.uid == selectedPhraseItemUid,
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      );
    });
  }

  LanguageConfigColorEntityColors? _getColor(String? roleNid){
    ConfigController configController = Get.find<ConfigController>();
    List<LanguageConfigColorEntityInfo?> phraseItemRoles = configController.colorConfigs.value.phraseItemRoles??[];

    return phraseItemRoles.firstWhereOrNull((element) => element?.code == roleNid)?.color;
  }

  void _scrollToSelectedContentCard() {
    final int? selectedIndex = controller.getSelectedContentCardIndex();
    if (selectedIndex == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? scrollContext = controller.mainScrollViewKey.currentContext;
      final BuildContext? targetContext = controller.getContentCardKey(selectedIndex).currentContext;
      if (scrollContext == null || targetContext == null) return;
      if (!controller.mainScrollController.hasClients) return;
      final RenderObject? targetRenderObject = targetContext.findRenderObject();
      final RenderObject? scrollableRenderObject = scrollContext.findRenderObject();
      if (targetRenderObject is RenderBox && scrollableRenderObject is RenderBox) {
        final Offset targetOffset = targetRenderObject.localToGlobal(Offset.zero, ancestor: scrollableRenderObject);
        final double targetTop = targetOffset.dy;
        final double targetBottom = targetTop + targetRenderObject.size.height;
        final double viewportHeight = scrollableRenderObject.size.height;
        final double viewportPadding = 24.wMin;
        final bool isVisible = targetTop >= viewportPadding && targetBottom <= viewportHeight - viewportPadding;
        if (isVisible) return;

        double nextOffset = controller.mainScrollController.offset;
        if (targetTop < viewportPadding) {
          nextOffset += targetTop - viewportPadding;
        } else if (targetBottom > viewportHeight - viewportPadding) {
          nextOffset += targetBottom - viewportHeight + viewportPadding;
        }
        final double minOffset = controller.mainScrollController.position.minScrollExtent;
        final double maxOffset = controller.mainScrollController.position.maxScrollExtent;
        nextOffset = nextOffset.clamp(minOffset, maxOffset);
        controller.mainScrollController.animateTo(
          nextOffset,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }


  Widget _buildPhraseItemWidget(PhraseStructureEntityItems? item, {required bool isSelected}){
    LanguageConfigColorEntityColors? colors = _getColor(item?.roleNid);
    Color bgColor = colors?.bgC??AppTheme.cSurfaceLayerBase.color;
    Color borderColor = colors?.borderC??(AppTheme.cBorderSubtle.color);
    Color textColor = colors?.textC??AppTheme.cTextPrimary.color;
    final Color selectedColor = AppTheme.cSurfaceBrand.color;
    final Color currentBorderColor = isSelected
        ? selectedColor.withValues(alpha: 0.72)
        : borderColor;

    return GestureDetector(
      onTap: () {
        controller.toggleSelectedPhraseItem(item);
        _scrollToSelectedContentCard();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.all(8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          color: bgColor,
          border: Border.all(
            color: currentBorderColor,
            width: isSelected ? 1.wMin : 0.5.wMin,
          ),
        ),
        child: Column(
          spacing: 10.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item?.roleNameZh??'',
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
            Text(
              item?.text??'',
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }) {
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: borderColor.withValues(alpha: 0.2),
          width: 0.5.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tagText,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 结构说明
  Widget _buildInfoWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Obx((){
        PhraseStructureEntity data = controller.detailData.value;
        List<PhraseStructureEntityStructures?> structures = data.structures??[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(structures.length, (index){
            PhraseStructureEntityStructures? structure = structures[index];
            return _buildInfoItemWidget(structure, structures.length, index);
          }),
        );
      }),
    );
  }

  Widget _buildInfoItemWidget(PhraseStructureEntityStructures? structure, int structureCount, int index){
    LanguageText? explanation = LearningLangUtils.getLocalLang(structure?.explanations);
    return Column(
      spacing: 10.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              structureCount > 1 ? "结构 ${index+1}" : "结构说明",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            SizedBox(width: 8.wMin),
            CopyTagWidget(
              name: "结构",
              value: structure?.uid?.toString()??'',
              isShow: controller.isManagement,
            ),
          ],
        ),
        Text(
          explanation?.text??'',
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      ],
    );
  }


}
