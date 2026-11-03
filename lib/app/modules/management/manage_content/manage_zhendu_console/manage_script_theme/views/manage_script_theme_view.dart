import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../bindings/manage_script_theme_binding.dart';
import '../controllers/manage_script_theme_controller.dart';
import 'manage_script_theme_list_card_widget.dart';
import 'manage_script_theme_info_widget.dart';

class ManageScriptThemeView extends GetView<ManageScriptThemeController> {
  final String tagText;
  const ManageScriptThemeView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SCRIPT_THEME}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageScriptThemeView(tagText: tag),
      binding: ManageScriptThemeBinding(tag: tag),
      routeName: Routes.MANAGE_SCRIPT_THEME,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: controller.refreshListData,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 140.wMin, vertical: 24.wMin),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.wMin,
          children: [
            _buildLeftListWidget(context),
            Expanded(
              child: ManageScriptThemeInfoWidget(
                controller: controller,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFloatWidget(),
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
      child: Column(
        children: [
          CardInputWidget(
            hintText: "搜索nid / 中文名称 / 分类",
            controller: controller.searchInput,
            textInputAction: TextInputAction.search,
            height: 54.wMin,
            valueStyle: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w400,
            ),
            hintStyle: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
            onSubmitted: (value) {
              controller.refreshListData();
            },
          ),
          // SizedBox(height: 10.wMin),
          Expanded(
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
                  return ManageScriptThemeListCardWidget(controller: controller, index: index, data: controller.listData[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }


  Widget _buildFloatWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaScriptThemeCreate],
          child: ButtonWidget(
            text: "新增主题",
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            height: 44.wMin,
            color: const Color(0xff8E51FF).withValues(alpha: 0.2),
            borderRadius: 8.wMin,
            border: Border.all(width: 1.wMin, color: const Color(0xff8E51FF)),
            fontColor: const Color(0xff8E51FF),
            fontSize: 18.wMin,
            sclae: 1.03,
            onTap: () {
              controller.addTheme();
            },
          ),
        ),
      ],
    );
  }

}
