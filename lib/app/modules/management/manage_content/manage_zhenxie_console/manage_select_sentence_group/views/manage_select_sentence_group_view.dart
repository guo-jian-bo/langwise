import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../common/widgets/zhenxie_widgets/zhenxie_grammar_panorama_item_widget.dart';
import '../../../../../../../common/widgets/zhenxie_widgets/zhenxie_sentence_fork_item_widget.dart';
import '../../../../../../../common/widgets/zhenxie_widgets/zhenxie_sentence_pair_item_widget.dart';
import '../../../../../../../common/widgets/zhenxie_widgets/zhenxie_sentence_pattern_compare_card_widget.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_select_sentence_group_binding.dart';
import '../controllers/manage_select_sentence_group_controller.dart';

class ManageSelectSentenceGroupView extends GetView<ManageSelectSentenceGroupController> {
  final String tagText;
  const ManageSelectSentenceGroupView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SELECT_SENTENCE_GROUP}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSelectSentenceGroupView(tagText: tag),
      binding: ManageSelectSentenceGroupBinding(tag: tag),
      routeName: Routes.MANAGE_SELECT_SENTENCE_GROUP,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ManageScaffold(
        onRefresh: () {
          controller.refreshList();
        },
        body: _buildListWidget(),
        floatingActionButton: _buildFilterWidget(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx(() {
        int selectCount = controller.selectIndexs.length;
        String buttonText = "确认选择";
        if(controller.pageType == 0){
          buttonText = "加入本单元 · $selectCount组";
        }

        return Row(
          children: [
            Expanded(
              child: FilterStripWidget(
                sorts: {...controller.filterSorts},
                conditions: {...controller.filterConditions},
                searchs: controller.filterSearchs,
                searchSingleWidth: 480.wMin,
                onSorts: (sorts) {
                  controller.filterSorts.value = sorts;
                  controller.refreshList();
                },
                onConditions: (conditions) {
                  controller.filterConditions.value = conditions;
                  controller.refreshList();
                },
                onReset: (sorts, conditions) {
                  controller.filterSorts.value = sorts;
                  controller.filterConditions.value = conditions;
                  controller.refreshList();
                },
                onSearch: () {
                  controller.refreshList();
                },
              ),
            ),
            SizedBox(width: 24.wMin),
            _buildButtonItem(
              text: selectCount == 0 ? "请选择组" : buttonText,
              isEnabled: selectCount > 0,
              onTap: () {
                controller.addSubmit();
              },
            ),

          ],
        );
      }),
    );
  }

  Widget _buildButtonItem({
    required String text,
    bool isEnabled = true,
    void Function()? onTap,
  }){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: ButtonWidget(
        text: text,
        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
        height: 54.wMin,
        color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.12),
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
        ),
        fontColor: AppTheme.cSurfaceBrand.color.withValues(alpha: isEnabled ? 1 : 0.4),
        fontSize: 24.wMin,
        fontWeight: FontWeight.w500,
        sclae: 1.03,
        onTap: onTap,
      ),
    );
  }

  Widget _buildListWidget(){
    return Obx((){
      if(controller.dataList.isEmpty && !controller.isLoading.value){
        return NotDataWidget(message: "暂无数据");
      }
      final int rowCount = (controller.dataList.length / 2).ceil();

      return ListView.separated(
        controller: controller.scrollController,
        itemCount: rowCount,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 6.wMin),
        separatorBuilder: (context, rowIndex) => SizedBox(height: 16.wMin),
        itemBuilder: (context, rowIndex) {
          final int leftIndex = rowIndex * 2;
          final int rightIndex = leftIndex + 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16.wMin,
              children: [
                Expanded(child: _buildListItemWidget(controller.dataList[leftIndex], leftIndex)),
                Expanded(
                  child: rightIndex < controller.dataList.length ? _buildListItemWidget(controller.dataList[rightIndex], rightIndex) : SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
      );
    });
  }


  Widget _buildListItemWidget(CourseUnitTargetSentenceGrammarGroupEntity data, int index) {
    return Obx((){
      bool isSelected = controller.selectIndexs.contains(index);

      if (data.typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN || data.typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID) {
        if (data.payload?.patternBlueprintData == null) return SizedBox.shrink();
        return PatternBlueprintItemWidget(
          isManagement: true,
          isSelectMode: true,
          isSelected: isSelected,
          highlightSentenceId: controller.sentenceId,
          data: data.payload!.patternBlueprintData!,
          onTap: () {
            controller.selectSentenceGroup(index);
          },
        );
      } else if (data.typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PARADIGM) {
        if (data.payload?.sentencePatternCompareData == null) return SizedBox.shrink();
        return ZhenxieSentencePatternCompareCardWidget(
          isManagement: true,
          isSelectMode: true,
          isSelected: isSelected,
          data: data.payload!.sentencePatternCompareData!,
          onTap: (_) {
            controller.selectSentenceGroup(index);
          },
        );
      } else if (data.typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR) {
        if (data.payload?.sentencePairData == null) return SizedBox.shrink();
        return ZhenxieSentencePairItemWidget(
          isManagement: true,
          isSelectMode: true,
          isSelected: isSelected,
          data: data.payload!.sentencePairData!,
          onTap: () {
            controller.selectSentenceGroup(index);
          },
        );
      } else if (data.typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK) {
        if (data.payload?.sentenceForkData == null) return SizedBox.shrink();
        return ZhenxieSentenceForkItemWidget(
          isManagement: true,
          isSelectMode: true,
          isSelected: isSelected,
          data: data.payload!.sentenceForkData!,
          onTap: () {
            controller.selectSentenceGroup(index);
          },
        );
      } else if (data.typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_GRAMMAR_GRID) {
        if (data.payload?.grammarPanoramaData == null) return SizedBox.shrink();
        return ZhenxieGrammarPanoramaItemWidget(
          isManagement: true,
          isSelectMode: true,
          isSelected: isSelected,
          data: data.payload!.grammarPanoramaData!,
          onTap: () {
            controller.selectSentenceGroup(index);
          },
        );
      }
      return Container();
    });
  }

  
}
