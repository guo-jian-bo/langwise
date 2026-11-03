import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_word_morphology_binding.dart';
import '../controllers/manage_word_morphology_controller.dart';

class ManageWordMorphologyView extends GetView<ManageWordMorphologyController> {
  final String tagText;
  const ManageWordMorphologyView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, String? tag}) async {
    final pageTag = tag ?? '${Routes.MANAGE_WORD_MORPHOLOGY}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageWordMorphologyView(tagText: pageTag),
      binding: ManageWordMorphologyBinding(tag: pageTag),
      routeName: Routes.MANAGE_WORD_MORPHOLOGY,
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
        body: Column(
          children: [
            _buildTitleWidget(),
            _buildSummaryWidget(),
            SizedBox(height: 12.wMin),
            Expanded(child: _buildListWidget()),
          ],
        ),
        floatingActionButton: _buildFilterWidget(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  /// 底部筛选浮条。
  Widget _buildFilterWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx(() {
        return FilterStripWidget(
          sorts: {...controller.filterSorts},
          conditions: {...controller.filterConditions},
          searchs: controller.filterSearchs,
          searchSingleWidth: 480.wMin,
          startText: "共 ${controller.total} 条",
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
        );
      }),
    );
  }

  /// 顶部标题说明。
  Widget _buildTitleWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      margin: EdgeInsets.only(top: 16.wMin),
      child: Row(
        children: [
          Text(
            "词根词缀",
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(width: 24.wMin),
          Expanded(
            child: Text(
              "构词 Morphology 目录页。按类型、位置、教育适配度浏览可教学词素，卡片展示语义提示、词源、例词与成员词数量。",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 顶部总览统计。
  Widget _buildSummaryWidget() {
    return Obx(() {
      if (controller.summaryTypeList.isEmpty) return SizedBox(height: 12.wMin);
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 90.wMin),
        margin: EdgeInsets.only(top: 20.wMin),
        child: Wrap(
          spacing: 16.wMin,
          runSpacing: 16.wMin,
          children: controller.summaryTypeList.map((item) => _buildSummaryItemWidget(item)).toList(),
        ),
      );
    });
  }

  Widget _buildSummaryItemWidget(WordMorphologySummaryTypeEntity data) {
    return Container(
      width: 220.wMin,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
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
          Text(
            data.name ?? '',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          SizedBox(height: 8.wMin),
          Text(
            data.count?.toString() ?? '',
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ],
      ),
    );
  }

  /// 词素目录网格。
  Widget _buildListWidget() {
    return Obx(() {
      if (controller.morphologyList.isEmpty && !controller.isLoading.value) {
        return NotDataWidget(message: "暂无数据");
      }
      return GridView.builder(
        controller: controller.scrollController,
        itemCount: controller.morphologyList.length,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 6.wMin),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16.wMin,
          crossAxisSpacing: 16.wMin,
          mainAxisExtent: 474.wMin,
        ),
        itemBuilder: (context, index) {
          return _buildListItemWidget(controller.morphologyList[index]);
        },
      );
    });
  }

  Widget _buildListItemWidget(WordMorphologyListItemEntity data) {
    final semanticHint = controller.getLangText(data.semanticHint, "zh");
    final etymology = controller.getLangText(data.etymology, "zh");
    final description = controller.getLangText(data.descriptions, "zh");
    final morphemeTypeTitle = controller.getMorphemeTypeTitle(data.morphemeTypeNid);
    final morphemeTypeTextColor = controller.getMorphemeTypeTextColor(data.morphemeTypeNid);
    final tierColor = controller.getTierColor(data.tierColor);
    final attachesToPosTitle = controller.getPosTitle(data.attachesToPos);
    final attachesToPosTextColor = controller.getPosTextColor(data.attachesToPos);
    final resultPosTitle = controller.getPosTitle(data.resultPos);
    final resultPosTextColor = controller.getPosTextColor(data.resultPos);
    final exampleWords = data.exampleWords?.whereType<String>().toList() ?? [];

    return TapScaleWidget(
      onTap: () {
        controller.jumpToDetailPage(data);
      },
      sclae: 1.01,
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderThin.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  data.content ?? '',
                  style: TextStyle(
                    fontSize: 56.wMin,
                    fontWeight: FontWeight.w700,
                    color: morphemeTypeTextColor,
                  ),
                ),
                SizedBox(width: 8.wMin),
                if ((data.nid ?? '').isNotEmpty)
                  CopyTagWidget(
                    name: "词组",
                    value: data.nid ?? '',
                  ),
                Spacer(),
                if (data.memberCount != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${data.memberCount}",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextSecondary.color,
                        ),
                      ),
                      Text('个词',
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextSecondary.color,
                          ))
                    ],
                  ),
              ],
            ),
            SizedBox(height: 12.wMin),
            Wrap(
              spacing: 8.wMin,
              runSpacing: 8.wMin,
              children: [
                if (morphemeTypeTitle.isNotEmpty)
                  WordInflectionInfoTagWidget(
                    morphemeTypeTitle,
                    textColor: morphemeTypeTextColor,
                    bgColor: morphemeTypeTextColor?.withValues(alpha: 0.12),
                    borderColor: morphemeTypeTextColor?.withValues(alpha: 0.20),
                  ),
                if ((data.tierTitle ?? '').isNotEmpty)
                  WordInflectionInfoTagWidget(
                    "教育适配度 ${data.tierTitle ?? ''}",
                    textColor: tierColor ?? AppTheme.cTextPrimary,
                    bgColor: (tierColor ?? AppTheme.cSurfaceLayerBase).withValues(alpha: 0.12),
                    borderColor: (tierColor ?? AppTheme.cBorderThin).withValues(alpha: 0.20),
                  ),
                if (data.difficulty?.min != null)
                  _buildDifficultyTagWidget(
                    minDifficulty: data.difficulty?.min,
                    maxDifficulty: data.difficulty?.max,
                  ),
              ],
            ),
            if (semanticHint.isNotEmpty) ...[
              SizedBox(height: 16.wMin),
              Text(
                semanticHint,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ],
            if (etymology.isNotEmpty) ...[
              SizedBox(height: 16.wMin),
              Text(
                etymology,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
            ],
            if (description.isNotEmpty) ...[
              SizedBox(height: 16.wMin),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ],
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: 16.wMin),
              child: Divider(
                height: 1.wMin,
                color: AppTheme.cBorderTranslucentSubtle.color,
              ),
            ),
            if ((data.attachesToPos ?? '').isNotEmpty && (data.resultPos ?? '').isNotEmpty && (data.formPosition ?? '').isNotEmpty)//根据配置是否显示
              Text.rich(TextSpan(children: [
                TextSpan(
                  text: '附着在 ',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: WordInflectionInfoTagWidget(
                    attachesToPosTitle,
                    textColor: attachesToPosTextColor,
                    bgColor: attachesToPosTextColor?.withValues(alpha: 0.12),
                    borderColor: attachesToPosTextColor?.withValues(alpha: 0.20),
                  ),
                ),
                TextSpan(
                  text: ' 的 ',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
                TextSpan(
                  text: data.formPositionTitle ?? '',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                TextSpan(
                  text: ' 得到 ',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: WordInflectionInfoTagWidget(
                    resultPosTitle,
                    textColor: resultPosTextColor,
                    bgColor: resultPosTextColor?.withValues(alpha: 0.12),
                    borderColor: resultPosTextColor?.withValues(alpha: 0.20),
                  ),
                ),
              ])),
                  
                   if ((data.attachesToPos ?? '').isEmpty &&(data.resultPos ?? '').isEmpty )
                    Text.rich(TextSpan(children: [
                TextSpan(
                  text: '出现在 ',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),


                TextSpan(
                  text: data.formPositionTitle ?? '',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
  
              ])),
                
            if (exampleWords.isNotEmpty) ...[
              SizedBox(height: 16.wMin),
              Wrap(
                spacing: 8.wMin,
                runSpacing: 8.wMin,
                children: exampleWords.take(4).map((item) => WordInflectionInfoTagWidget(item)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyTagWidget({
    required int? minDifficulty,
    required int? maxDifficulty,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.wMin),
        color: AppTheme.cSurfaceSoildTertiary,
        border: Border.all(
          color: AppTheme.cBorderSoildSecondary,
          width: 1.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusTagDifficultyWidget(
            difficulty: minDifficulty,
            language: controller.getLearningLang(),
            fontSize: 16.wMin,
            defaultColor: Colors.transparent,
            fontColor: AppTheme.cTextSecondary,
            padding: EdgeInsets.zero,
          ),
          if (maxDifficulty != null && minDifficulty != null && maxDifficulty != minDifficulty)
            Text(
              "-",
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextSecondary,
              ),
            ),
          if (maxDifficulty != null && minDifficulty != null && maxDifficulty != minDifficulty)
            StatusTagDifficultyWidget(
              difficulty: maxDifficulty,
              language: controller.getLearningLang(),
              fontSize: 16.wMin,
              defaultColor: Colors.transparent,
              fontColor: AppTheme.cTextSecondary,
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
