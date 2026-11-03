import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../theme/theme.dart';
import '../../../../routes/routes.dart';
import '../../common/manage_scaffold.dart';
import '../../models/manage_auth_menu_model.dart';
import '../bindings/manage_review_binding.dart';
import '../controllers/manage_review_controller.dart';

class ManageReviewView extends GetView<ManageReviewController> {
  final String tagText;
  const ManageReviewView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_REVIEW}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageReviewView(tagText: tag),
      binding: ManageReviewBinding(tag: tag),
      routeName: Routes.MANAGE_REVIEW,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      showBottomNavigationBar: true,
      body: Obx((){
        return GridView.builder(
          itemCount: controller.managePeviewList.length,
          padding: EdgeInsets.all(70.wMin),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16.wMin,
            crossAxisSpacing: 16.wMin,
            mainAxisExtent: 200.wMin,
          ),
          itemBuilder: (context, index) {
            return _buildCardItemWidget(controller.managePeviewList[index]);
          },
        );
      }),
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
