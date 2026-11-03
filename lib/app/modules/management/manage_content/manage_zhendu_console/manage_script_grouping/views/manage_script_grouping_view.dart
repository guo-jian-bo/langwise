import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';


import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../bindings/manage_script_grouping_binding.dart';
import '../controllers/manage_script_grouping_controller.dart';
import 'manage_script_grouping_info_widget.dart';
import 'manage_script_grouping_list_card_widget.dart';

class ManageScriptGroupingView extends GetView<ManageScriptGroupingController> {
  final String tagText;
  const ManageScriptGroupingView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SCRIPT_GROUPING}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageScriptGroupingView(tagText: tag),
      binding: ManageScriptGroupingBinding(tag: tag),
      routeName: Routes.MANAGE_SCRIPT_GROUPING,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.refreshListData(isReset: false),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 140.wMin, vertical: 24.wMin),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16.wMin,
                children: [
                  _buildLeftListWidget(context),
                  Expanded(
                    child: ManageScriptGroupingInfoWidget(
                      controller: controller,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 10.wMin,
            bottom: 150.wMin,
            child: _buildFloatWidget(context),
          ),
        ],
      ),
      bottomNavigationBar: _buildFilterWidget(context),
    );
  }

  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context){
    return Container(
      margin: EdgeInsets.only(bottom: 16.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx((){
            return FilterStripWidget(
              sorts: {...controller.filterSorts},
              conditions: {...controller.filterConditions},
              searchs: controller.filterSearchs,
              onSorts: (sorts) {
                controller.filterSorts.value = sorts;
                controller.refreshListData();
              },
              onConditions: (conditions) {
                controller.filterConditions.value = conditions;
                controller.refreshListData();
              },
              onReset: (sorts, conditions) {
                controller.filterSorts.value = sorts;
                controller.filterConditions.value = conditions;
                controller.refreshListData();
              },
              onSearch: () {
                controller.refreshListData();
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFloatWidget(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaScriptGroupCreate],
          child: ButtonWidget(
            text: "新增分组",
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            height: 44.wMin,
            color: const Color(0xff00b8db).withValues(alpha: 0.2),
            borderRadius: 8.wMin,
            border: Border.all(width: 1.wMin, color: const Color(0xff00b8db)),
            fontColor: const Color(0xff00b8db),
            fontSize: 18.wMin,
            sclae: 1.03,
            onTap: () {
              controller.addGroup(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeftListWidget(BuildContext context){
    return Container(
      width: 514.wMin,
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Obx((){
        if(controller.listData.isEmpty) {
          return const NotDataWidget(
            message: "暂无数据",
          );
        }
        return ListView.separated(
          itemCount: controller.listData.length,
          controller: controller.leftScrollController,
          padding: EdgeInsets.symmetric(vertical: 10.wMin),
          separatorBuilder: (context, index) => SizedBox(height: 8.wMin),
          itemBuilder: (context, index) {
            return ManageScriptGroupingListCardWidget(controller: controller, index: index, data: controller.listData[index]);
          },
        );
      }),
    );
  }

}
