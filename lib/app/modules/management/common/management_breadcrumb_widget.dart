import 'package:flutter/widgets.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';
import '../controllers/management_breadcrumb_controller.dart';


class ManagementBreadcrumbWidget extends GetView<ManagementBreadcrumbController> {
  const ManagementBreadcrumbWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Obx((){
        if(controller.breadcrumbs.isEmpty){
          return const SizedBox.shrink();
        }
        return BreadCrumb(
          overflow: ScrollableOverflow(
            keepLastDivider: false,
          ),
          divider: Text(
            "/",
            style: TextStyle(
              color: AppTheme.cTextPrimary.color,
              fontSize: 20.wMin,
            ),
          ),
          items: List.generate(controller.breadcrumbs.length, (index){
            return BreadCrumbItem(
              margin: EdgeInsets.symmetric(horizontal: 4.wMin),
              padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 6.wMin),
              disabledTextColor: AppTheme.cTextTertiary.color,
              borderRadius: BorderRadius.circular(4.wMin),
              textColor: AppTheme.cTextPrimary.color,
              content: Text(
                controller.breadcrumbs[index].title ?? "",
                style: TextStyle(
                  fontSize: 24.wMin,
                ),
              ),
              onTap: controller.breadcrumbs[index].disabled ? null :() {
                controller.onTapBreadcrumb(controller.breadcrumbs[index]);
              },
            );
          }),
        );
      }),
    );
  }
}

