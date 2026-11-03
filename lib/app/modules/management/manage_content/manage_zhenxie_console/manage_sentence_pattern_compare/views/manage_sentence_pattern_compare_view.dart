import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_sentence_pattern_compare_binding.dart';
import '../controllers/manage_sentence_pattern_compare_controller.dart';

class ManageSentencePatternCompareView extends GetView<ManageSentencePatternCompareController> {
  final String tagText;
  const ManageSentencePatternCompareView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SENTENCE_PATTERN_COMPARE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSentencePatternCompareView(tagText: tag),
      binding: ManageSentencePatternCompareBinding(tag: tag),
      routeName: Routes.MANAGE_SENTENCE_PATTERN_COMPARE,
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

  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx((){
        return FilterStripWidget(
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
        );
      }),
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      margin: EdgeInsets.only(top: 16.wMin),
      child: Row(
        children: [
          Text(
            "句型对照",
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(width: 24.wMin),
          Text(
            "跨壳单轴对照：一次只拧一个开关（肯否、问法、语态、引导词、近义说法……）。列表露出壳名串与对照组预览（↔），详情可打开每层蓝图。",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListWidget(){
    return Obx((){
      if(controller.patternCompareList.isEmpty && !controller.isLoading.value){
        return NotDataWidget(message: "暂无数据");
      }
      return ListView.separated(
        controller: controller.scrollController,
        itemCount: controller.patternCompareList.length,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 6.wMin),
        separatorBuilder: (context, index) => SizedBox(height: 24.wMin),
        itemBuilder: (context, index) {
          return _buildItemWidget(controller.patternCompareList[index]);
        },
      );
    });
  }

  Widget _buildItemWidget(SentencePatternCompareEntity data){
    LanguageText? description = LearningLangUtils.getLocalLang(data.description);
    return TapScaleWidget(
      onTap: (){
        controller.jumpToDetailPage(data);
      },
      sclae: 1,
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
                  child: _buildItemContentLeftWidget(data),
                ),
                _buildItemContentRightWidget(data),
              ],
            ),
            SizedBox(height: 4.wMin),
            Text(
              description?.text??'',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            SizedBox(height: 16.wMin),
            SameGroupCompareTableWidget(
              memberList: data.memberList,
              sentenceRealizationSetList: data.sentenceRealizationSetList,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemContentLeftWidget(SentencePatternCompareEntity data){
    LanguageText? dimensionName = LearningLangUtils.getLocalLang(data.dimension?.name);
    LanguageText? name = LearningLangUtils.getLocalLang(data.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 4.wMin,
          children: [
            Text(
              dimensionName?.text??'',
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            CopyTagWidget(
              name: "维度",
              value: data.dimensionNid??'',
            ),
          ],
        ),
        SizedBox(height: 4.wMin),
        Wrap(
          spacing: 4.wMin,
          runSpacing: 4.wMin,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              name?.text??'',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            CopyTagWidget(
              name: "对照", 
              value: data.dimensionNid??'',
            ),
          ],
        ),
        
      ],
    );
  }

  Widget _buildItemContentRightWidget(SentencePatternCompareEntity data){
    LanguageText? transformationKindName = LearningLangUtils.getLocalLang(data.transformationKind?.name);
    LanguageText? contrastTypeName = LearningLangUtils.getLocalLang(data.contrastType?.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildTagWidget(
          tagText: transformationKindName?.text??'',
        ),
        SizedBox(height: 6.wMin),
        Row(
          spacing: 4.wMin,
          children: [
            _buildTagWidget(
              tagText: contrastTypeName?.text??'',
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }){
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


  
}
