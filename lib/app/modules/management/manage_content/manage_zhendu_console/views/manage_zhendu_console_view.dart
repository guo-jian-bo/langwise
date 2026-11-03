import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../../../common/manage_scaffold.dart';
import '../../../models/models.dart';
import '../bindings/manage_zhendu_console_binding.dart';
import '../controllers/manage_zhendu_console_controller.dart';

class ManageZhenduConsoleView extends GetView<ManageZhenduConsoleController> {
  final String tagText;
  const ManageZhenduConsoleView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_ZHENDU_CONSOLE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageZhenduConsoleView(tagText: tag),
      binding: ManageZhenduConsoleBinding(tag: tag),
      routeName: Routes.MANAGE_ZHENDU_CONSOLE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 70.wMin, vertical: 40.wMin),
        child: Obx((){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "甄读管理台",
                style: TextStyle(
                  fontSize: 32.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                "围绕人声资产与角色设定的统一管理后台",
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),

              _buildListWidget(
                title: "角色",
                subTitle: "角色、人声音色与情绪资产统一收口到这一组。",
                list: controller.roleList.toList(),
              ),

              _buildListWidget(
                title: "剧本",
                subTitle: "主题、题材与剧本生产页都聚合到剧本分组。",
                list: controller.scriptList.toList(),
              ),

              _buildListWidget(
                title: "项目",
                subTitle: "围绕成品制作的音频项目与视频项目入口。",
                list: controller.projectList.toList(),
              ),


            ],
          );
        }),
      ),
    );
  }


  Widget _buildListWidget({
    required String title,
    required String subTitle,
    required List<ManageAuthMenuModel> list,
  }){
    if(list.isEmpty) return Container();

    return Container(
      margin: EdgeInsets.only(top: 32.wMin),
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceSecondary.color,
        borderRadius: BorderRadius.circular(24.wMin)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),

          Text(
            subTitle,
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),

          Container(
            height: 1.wMin,
            color: AppTheme.cBorderPrimary.color,
            margin: EdgeInsets.symmetric(vertical: 16.wMin),
          ),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16.wMin,
              crossAxisSpacing: 16.wMin,
              mainAxisExtent: 160.wMin,
            ),
            itemBuilder: (context, index) {
              return _buildCardItemWidget(list[index]);
            },
          ),

        ],
      ),

    );

  }

  Widget _buildCardItemWidget(ManageAuthMenuModel data){
    return TapScaleWidget(
      onTap: () {
        controller.toPage(data);
      },
      sclae: 1.01,
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceTertiary.color,
          border: Border.all(
            color: AppTheme.cBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.wMin,
          children: [
      
            Text(
              data.name,
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
      
            Text(
              data.subtitle,
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
      
          ],
        ),
      ),
    );
  }


}


