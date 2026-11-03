import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../theme/theme.dart';
import '../../../../routes/routes.dart';
import '../../common/manage_scaffold.dart';
import '../../models/manage_auth_menu_model.dart';
import '../bindings/manage_users_binding.dart';
import '../controllers/manage_users_controller.dart';

class ManageUsersView extends GetView<ManageUsersController> {
  final String tagText;
  const ManageUsersView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_USERS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageUsersView(tagText: tag),
      binding: ManageUsersBinding(tag: tag),
      routeName: Routes.MANAGE_USERS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      showBottomNavigationBar: true,
      body: Obx(() {
        return GridView.builder(
          itemCount: controller.manageUsersList.length,
          padding: EdgeInsets.all(70.wMin),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16.wMin,
            crossAxisSpacing: 16.wMin,
            mainAxisExtent: 200.wMin,
          ),
          itemBuilder: (context, index) {
            return _buildCardItemWidget(controller.manageUsersList[index]);
          },
        );
      }),
    );
  }

  Widget _buildCardItemWidget(ManageAuthMenuModel data) {
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
          ],
        ),
      ),
    );
  }
}
