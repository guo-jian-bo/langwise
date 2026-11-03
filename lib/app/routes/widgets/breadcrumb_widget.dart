
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../breadcrumb_controller.dart';
import '../routes_breadcrumb_utils.dart';

class BreadcrumbWidget extends StatefulWidget {
  /// 点击返回按钮回调 为null默认返回上一页
  final void Function()? onBack;

  /// 点击面包屑回调 返回false不跳转，默认跳转
  final Future<bool> Function()? onRoute;

  /// 点击面包屑回调（带item） 返回false不跳转，默认跳转
  final Future<bool> Function(RoutesBreadcrumbItem item)? onRouteWithItem;

  /// 内边距 默认头部=安全区域+20  左右各90 下=20
  final EdgeInsetsGeometry? padding;

  /// 右侧自定义widget
  final Widget? actionWidget;

  const BreadcrumbWidget({super.key, this.onBack, this.onRoute, this.onRouteWithItem, this.padding, this.actionWidget});

  @override
  State<BreadcrumbWidget> createState() => _BreadcrumbWidgetState();
}

class _BreadcrumbWidgetState extends State<BreadcrumbWidget> {
  final BreadcrumbController controller = Get.find<BreadcrumbController>();

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry padding = EdgeInsets.zero;
    if(widget.padding != null){
      padding = widget.padding!;
    }else{
      padding = EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20.wMin,
        left: 90.wMin,
        right: 90.wMin,
        bottom: 20.wMin,
      );
    }

    return Hero(
      tag: "breadcrumb_hero",
      child: Container(
        padding: padding,
        child: Row(
          children: [
            
            TapScaleWidget(
              onTap: () {
                
                if(widget.onBack != null){
                  widget.onBack!();
                }else{
                  Get.back();
                }
      
              },
              sclae: 1.03,
              child: Container(
                width: 56.wMin,
                height: 56.wMin,
                color: Colors.transparent,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cSurfaceLayerElevated.color,
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_arrow_back.svg",
                    width: 40.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
      
            SizedBox(width: 24.wMin),
      
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: Obx((){
                  List<RoutesBreadcrumbItem> breadcrumbs = controller.breadcrumbs.toList();
                  if(breadcrumbs.isEmpty){
                    return const SizedBox.shrink();
                  }
                  return BreadCrumb(
                    overflow: ScrollableOverflow(
                      keepLastDivider: false,
                    ),
                    divider: Text(
                      "/",
                      style: TextStyle(
                        color: AppTheme.cTextTertiary.color,
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    items: List.generate(breadcrumbs.length, (index){
                      bool isDisabled = index == breadcrumbs.length - 1 || breadcrumbs[index].disabled;
                      return BreadCrumbItem(
                        margin: EdgeInsets.symmetric(horizontal: 4.wMin),
                        padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
                        borderRadius: BorderRadius.circular(4.wMin),
                        splashColor: Colors.transparent,
                        content: Text(
                          breadcrumbs[index].title ?? "",
                          style: TextStyle(
                            fontSize: 28.wMin,
                            fontWeight: FontWeight.w500,
                            color: isDisabled ? AppTheme.cTextPrimary.color : AppTheme.cTextTertiary.color,
                          ),
                        ),
                        onTap: isDisabled ? null :() async {
                          
                          if(widget.onRouteWithItem != null){
                            bool result = await widget.onRouteWithItem!(breadcrumbs[index]);
                            if(result) return;
                          }else if(widget.onRoute != null){
                            bool result = await widget.onRoute!();
                            if(result) return;
                          }
      
                          controller.onTapBreadcrumb(breadcrumbs[index]);
                        },
                      );
                    }),
                  );
                }),
              ),
            ),
      
            SizedBox(width: 24.wMin),
      
            SizedBox(child: widget.actionWidget),
      
          ],
        ),
      ),
    );
  }

}
