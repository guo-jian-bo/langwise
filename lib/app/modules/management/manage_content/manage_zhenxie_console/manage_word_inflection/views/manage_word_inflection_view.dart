import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_word_inflection_binding.dart';
import '../controllers/manage_word_inflection_controller.dart';
import '../../manage_word_inflection_details/views/manage_word_inflection_details_view.dart';

class ManageWordInflectionView extends GetView<ManageWordInflectionController> {
  final String tagText;
  const ManageWordInflectionView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_WORD_INFLECTION}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageWordInflectionView(tagText: tag),
      binding: ManageWordInflectionBinding(tag: tag),
      routeName: Routes.MANAGE_WORD_INFLECTION,
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
            SizedBox(height: 10.wMin),
            Expanded(child: _buildListWidget()),
          ],
        ),
        floatingActionButton: _buildFilterWidget(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildFilterWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx(() {
        return FilterStripWidget(
          sorts: {...controller.filterSorts},
          conditions: {...controller.filterConditions},
          searchs: controller.filterSearchs,
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

  Widget _buildTitleWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      margin: EdgeInsets.only(top: 16.wMin),
      child: Row(
        children: [
          Text(
            "曲折变化",
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(width: 24.wMin),
          Expanded(
            child: Text(
              "以词族为列表，点进去看这个 family 的语法画像与全部合法词形。有词条走词典卡，缺词条用分析说明占位。",
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

  Widget _buildListWidget() {
    return Obx(() {
      if (controller.wordInflectionList.isEmpty && !controller.isLoading.value) {
        return NotDataWidget(message: "暂无数据");
      }
      return ListView.separated(
        controller: controller.scrollController,
        itemCount: controller.wordInflectionList.length,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 6.wMin),
        separatorBuilder: (context, index) => SizedBox(height: 24.wMin),
        itemBuilder: (context, index) {
          return _buildListItemWidget(controller.wordInflectionList[index]);
        },
      );
    });
  }

  Widget _buildListItemWidget(WordInflectionListItemEntity data) {
    String chineseDescription = _getLanguageText(data.descriptions, "zh");
    List<String> grammaticalTypeNames = controller.getGrammaticalTypeNames(data.grammaticalTypeNids);
    List<String> previewSurfaces = data.previewSurfaces?.whereType<String>().toList() ?? [];
    int semanticCount = data.semanticCount ?? 0;
    int missingCount = data.missingCount ?? 0;

    return TapScaleWidget(
      onTap: () {
        ManageWordInflectionDetailsView.to(arguments: {
          "familyKey": data.familyKey,
        });
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 6.wMin,
                        // runSpacing: 6.wMin,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            data.lemma ?? '',
                            style: TextStyle(
                              fontSize: 28.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextPrimary.color,
                            ),
                          ),
                          if ((data.familyKey ?? '').isNotEmpty)
                            CopyTagWidget(
                              name: "词族",
                              value: data.familyKey ?? '',
                            ),
                          WordInflectionInfoTagWidget(
                            controller.getPosName(data.pos),
                            tone: WordInflectionInfoTagTone.brand,
                          ),
                          if (grammaticalTypeNames.isNotEmpty) ...[
                            SizedBox(height: 8.wMin),
                            Wrap(
                              spacing: 8.wMin,
                              runSpacing: 8.wMin,
                              children: grammaticalTypeNames
                                  .map(
                                    (name) => WordInflectionInfoTagWidget(
                                      name,
                                      tone: WordInflectionInfoTagTone.brand,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          Spacer(),
                          if (semanticCount > 0) WordInflectionInfoTagWidget("$semanticCount 个义项"),
                          if (missingCount > 0) ...[
                            SizedBox(height: 6.wMin),
                            WordInflectionInfoTagWidget(
                              "缺失 $missingCount 个",
                              textColor: AppTheme.cAmber,
                              bgColor: AppTheme.cAmber.withValues(alpha: 0.12),
                              borderColor: AppTheme.cAmber.withValues(alpha: 0.2),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              
              ],
            ),
            SizedBox(height: 10.wMin),
            if (previewSurfaces.isNotEmpty)
              Wrap(
                spacing: 8.wMin,
                runSpacing: 8.wMin,
                children: previewSurfaces.map((surface) => _buildSurfaceTag(surface)).toList(),
              ),
            if (previewSurfaces.isEmpty)
              Text(
                "尚无已入库屈折",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            if (chineseDescription.isNotEmpty) ...[
              SizedBox(height: 12.wMin),
              Text(
                chineseDescription,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSurfaceTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentElevated,
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(
          color: AppTheme.cBorderTranslucentSubtle,
          width: 1.wMin,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextPrimary.color,
        ),
      ),
    );
  }

  String _getLanguageText(List<LanguageText?>? values, String lang) {
    if (values == null || values.isEmpty) return '';
    for (int i = 0; i < values.length; i++) {
      if (values[i]?.lang == lang) {
        return values[i]?.text ?? '';
      }
    }
    return '';
  }
}
