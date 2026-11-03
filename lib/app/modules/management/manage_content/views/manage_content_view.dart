import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../theme/theme.dart';
import '../../../../routes/routes.dart';
import '../../common/manage_scaffold.dart';
import '../../models/manage_auth_menu_model.dart';
import '../bindings/manage_content_binding.dart';
import '../controllers/manage_content_controller.dart';

class ManageContentView extends GetView<ManageContentController> {
  final String tagText;
  const ManageContentView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CONTENT}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageContentView(tagText: tag),
      binding: ManageContentBinding(tag: tag),
      routeName: Routes.MANAGE_CONTENT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      showBottomNavigationBar: true,
      body: Obx((){
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 70.wMin, vertical: 40.wMin),
          children: [

            _buildCardListWidget("英语内容", controller.manageContentList),
            SizedBox(height: 32.wMin),
            _buildCardListWidget("资源工具", controller.manageResourceToolsList),

          ],
        );
      }),
    );
  }

  Widget _buildCardListWidget(String title, List<ManageAuthMenuModel> list){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.wMin),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16.wMin,
            crossAxisSpacing: 16.wMin,
            mainAxisExtent: 200.wMin,
          ),
          itemBuilder: (context, index) {
            return _buildCardItemWidget(list[index]);
          },
        ),
      ],
    );
  }

  Widget _buildCardItemWidget(ManageAuthMenuModel data){
    return TapScaleWidget(
      onTap: () {
        controller.toPage(data);
      },
      sclae: 1.01,
      child: Container(
        width: 433.wMin,
        height: 176.wMin,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceSecondary.color,
          border: Border.all(
            color: AppTheme.cBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                //   width: 32.wMin,
                //   height: 32.wMin,
                //   color: Colors.white,
                // ),
                Expanded(
                  child: Text(
                    data.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                ),
      
              ],
            ),
            SizedBox(height: 6.wMin),
            Text(
              data.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            const Spacer(),
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(4.wMin),
            //     color: AppTheme.cFeedbackInfoBackground.color,
            //   ),
            //   child: Text(
            //     "40000 个",
            //     style: TextStyle(
            //       fontSize: 18.wMin,
            //       fontWeight: FontWeight.w600,
            //       color: AppTheme.cTextBrand.color,
            //     ),
            //   ),
            // ),
      
      
            
          ],
        ),
      ),
    );
  }


}
