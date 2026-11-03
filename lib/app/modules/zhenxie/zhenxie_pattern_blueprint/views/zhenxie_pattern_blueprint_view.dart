import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_pattern_blueprint_binding.dart';
import '../controllers/zhenxie_pattern_blueprint_controller.dart';

class ZhenxiePatternBlueprintView extends GetView<ZhenxiePatternBlueprintController> {
  final String tagText;
  const ZhenxiePatternBlueprintView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 管理端入口跳转方法（生成唯一 tag，支持多实例）。
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_PATTERN_BLUEPRINT}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxiePatternBlueprintView(tagText: tag),
      binding: ZhenxiePatternBlueprintBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PATTERN_BLUEPRINT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  /// 标签路由跳转方法（外部传入 tag，支持实例隔离）。
  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxiePatternBlueprintView(tagText: tag),
      binding: ZhenxiePatternBlueprintBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PATTERN_BLUEPRINT,
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
            BreadcrumbWidget(isCompatibleManage: controller.isManagement),
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
    String title = "句型蓝图";
    String description = "一句话怎样才算说完整？把骨架、能换的位置和例句摊开，对照自己会不会说这一型。";
    if(controller.supportsPyramid){
      title = "生长金字塔";
      description = "只会说短句、一加成分就乱？同一句型从短到长加一层，看每一步多了什么、该加在哪。";
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      margin: EdgeInsets.only(top: 16.wMin),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(width: 24.wMin),
          Text(
            description,
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
      if(controller.patternBlueprintList.isEmpty && !controller.isLoading.value){
        return NotDataWidget(message: "暂无数据");
      }
      return ListView.separated(
        controller: controller.scrollController,
        itemCount: controller.patternBlueprintList.length,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 6.wMin),
        separatorBuilder: (context, index) => SizedBox(height: 24.wMin),
        itemBuilder: (context, index) {
          return PatternBlueprintItemWidget(
            isManagement: controller.isManagement,
            data: controller.patternBlueprintList[index],
            onTap: () {
              controller.jumpToDetailPage(controller.patternBlueprintList[index]);
            },
          );
        },
      );
    });
  }



}
