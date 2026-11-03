import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/stores/stores.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../routes/routes.dart';
import '../../../routes/tag_routes.dart';
import '../controllers/management_breadcrumb_controller.dart';
import '../controllers/management_controller.dart';
import '../controllers/management_message_controller.dart';
import '../dialog/dialogs.dart';
import '../enums/enums.dart';
import '../models/models.dart';
import 'manage_message_drawer_widget.dart';
import 'commons.dart';

/// 管理模块通用 Scaffold
/// 包含顶部面包屑和底部导航栏，使用 Hero 动画实现页面切换时保持不动
class ManageScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final List<Widget>? persistentFooterButtons;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool? resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final Color backgroundColor;
  final bool extendBody;
  final Drawer? drawer;
  final Widget? endDrawer;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;
  final Color? drawerScrimColor;
  final DrawerCallback? onDrawerChanged;
  final DrawerCallback? onEndDrawerChanged;
  final double? drawerEdgeDragWidth;
  final AlignmentDirectional persistentFooterAlignment;
  /// 是否显示页面收藏按钮
  final bool showCollectButton;
  /// 顶部标题 在没有注册管理端面包屑时显示
  final String? title;
  /// 是否显示底部菜单
  final bool showBottomNavigationBar;
  /// 刷新按钮回调 为null不显示
  final void Function()? onRefresh;
  /// 返回按钮拦截回调 返回true允许退出 返回false阻止退出
  final Future<bool> Function()? onBack;
  /// 消息列表跳转回来之后的回调
  final void Function(PushMessageEntity message)? onMessagePageBack;
  const ManageScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.persistentFooterButtons,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.resizeToAvoidBottomInset,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor = AppTheme.cBgPrimary,
    this.extendBody = false,
    this.drawer,
    this.endDrawer,
    this.floatingActionButtonAnimator,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
    this.drawerScrimColor,
    this.onDrawerChanged,
    this.onEndDrawerChanged,
    this.drawerEdgeDragWidth,
    this.persistentFooterAlignment = AlignmentDirectional.centerEnd,
    this.title,
    this.showCollectButton = true,
    this.showBottomNavigationBar = false,
    this.onRefresh,
    this.onBack,
    this.onMessagePageBack,
  });
  

  @override
  Widget build(BuildContext context) {
    bool canShowManageMessageDrawer = Get.isRegistered<ManagementController>() && Get.isRegistered<ManageMessageController>();

    return PopScope(
      canPop: false,
      // onPopInvokedWithResult: (didPop, result) {
      //   bool isRegistered = Get.isRegistered<ManagementBreadcrumbController>();
      //   if(!isRegistered) return;
      //   ManagementBreadcrumbController _breadcrumbController = Get.find<ManagementBreadcrumbController>();
      //   _breadcrumbController.breadcrumbBack();
      // },
      child: Scaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        extendBody: true,
        endDrawer: canShowManageMessageDrawer ? ManageMessageDrawerWidget(onPageBack: onMessagePageBack) : null,
        endDrawerEnableOpenDragGesture: false,
        body: Column(
          children: [
            _buildHeaderWidget(context),
            Expanded(
              child: Scaffold(
                appBar: appBar,
                body: body,
                backgroundColor: backgroundColor,
                floatingActionButton: floatingActionButton,
                floatingActionButtonLocation: floatingActionButtonLocation,
                persistentFooterButtons: persistentFooterButtons,
                persistentFooterAlignment: persistentFooterAlignment,
                bottomNavigationBar: bottomNavigationBar,
                bottomSheet: bottomSheet,
                resizeToAvoidBottomInset: resizeToAvoidBottomInset,
                extendBodyBehindAppBar: extendBodyBehindAppBar,
                extendBody: extendBody,
                drawer: drawer,
                endDrawer: endDrawer,
                floatingActionButtonAnimator: floatingActionButtonAnimator,
                primary: primary,
                drawerDragStartBehavior: drawerDragStartBehavior,
                drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
                endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
                restorationId: restorationId,
                drawerScrimColor: drawerScrimColor,
                onDrawerChanged: onDrawerChanged,
                onEndDrawerChanged: onEndDrawerChanged,
                drawerEdgeDragWidth: drawerEdgeDragWidth,
              ),
            ),
          ],
        ),
        floatingActionButton: _buildAnimatedFloatingButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  /// 顶部面包屑区域
  Widget _buildHeaderWidget(BuildContext context) {
    bool isRegistered = Get.isRegistered<ManagementBreadcrumbController>();
    if(!isRegistered) {
      if(title == null) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
        child: BackWidget(title: title),
      );
    }

    ManagementBreadcrumbController _breadcrumbController = Get.find<ManagementBreadcrumbController>();
    bool canShowManageMessageDrawer = Get.isRegistered<ManagementController>() && Get.isRegistered<ManageMessageController>();
    final headerContent = Material(
      color: Colors.transparent,
      child: Container(
        height: 60.wMin,
        padding: EdgeInsets.only(left: 70.wMin, right: 70.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cBgPrimary.color,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.cBorderPrimary.color,
              width: 1.wMin,
            ),
          ),
        ),
        child: Row(
          children: [
            TapScaleWidget(
              onTap: () {
                TagRoutes.toNamed(Routes.USER_CENTER);
              },
              sclae: 1.03,
              child: ClipOval(
                child: CachedImageWidget(
                  UserStore.to.userInfo.value.avatarUrl ?? "",
                  width: 38.wMin,
                  height: 38.wMin,
                  errorWidget: Center(
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_user.svg",
                      width: 32.wMin,
                      height: 32.wMin,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 32.wMin),
            TapScaleWidget(
              onTap: () {
                if(onBack != null) {
                  onBack?.call();
                  return;
                }

                _breadcrumbController.breadcrumbBack();
              },
              sclae: 1.03,
              borderRadius: 4.wMin,
              backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
              child: Container(
                width: 56.wMin,
                height: 56.wMin,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  "assets/svg/public/icon_arrow_left_thin.svg",
                  width: 32.wMin,
                  height: 32.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                ),
              ),
            ),
            SizedBox(width: 24.wMin),
            const Expanded(
              child: ManagementBreadcrumbWidget(),
            ),

            SizedBox(width: 16.wMin),
            // 刷新按钮
            Visibility(
              visible: onRefresh != null,
              child: TapScaleWidget(
                onTap: onRefresh,
                sclae: 1.03,
                borderRadius: 4.wMin,
                backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
                child: Container(
                  width: 56.wMin,
                  height: 56.wMin,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Icon(
                    Icons.refresh_rounded,
                    color: AppTheme.cTextPrimary.color,
                    size: 26.wMin,
                  ),
                ),
              ),
            ),

            Visibility(
              visible: canShowManageMessageDrawer,
              child: Builder(
                builder: (context) {
                  return TapScaleWidget(
                    onTap: () {
                      Get.find<ManageMessageController>().openEndDrawer(context);
                    },
                    sclae: 1.03,
                    borderRadius: 4.wMin,
                    backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
                    child: Container(
                      width: 56.wMin,
                      height: 56.wMin,
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.messenger_outline,
                            color: AppTheme.cTextPrimary.color,
                            size: 24.wMin,
                          ),
                          Positioned(
                            right: -4.wMin,
                            top: -4.wMin,
                            child: Obx((){
                              int unreadCount = Get.find<ManageMessageController>().unreadCount.value;
                              if(unreadCount == 0) return Container();
                              return Container(
                                width: 10.wMin,
                                height: 10.wMin,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.cSurfaceError.color,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            TapScaleWidget(
              onTap: () {
                ManagePageBookmarkDialog.show(context);
              },
              sclae: 1.03,
              borderRadius: 4.wMin,
              backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
              child: Container(
                width: 56.wMin,
                height: 56.wMin,
                alignment: Alignment.center,
                color: Colors.transparent,
                child: Icon(
                  Icons.bookmarks_outlined,
                  color: AppTheme.cTextPrimary.color,
                  size: 24.wMin,
                ),
              ),
            ),
            // 页面收藏夹
            Visibility(
              visible: showCollectButton,
              child: TapScaleWidget(
                onTap: () {
                  _breadcrumbController.collectPage(context);
                },
                sclae: 1.03,
                borderRadius: 4.wMin,
                backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
                child: Container(
                  width: 56.wMin,
                  height: 56.wMin,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Icon(
                    Icons.bookmark_add_outlined,
                    color: AppTheme.cTextPrimary.color,
                    size: 24.wMin,
                  ),
                ),
              ),
            ),
            TapScaleWidget(
              onTap: () {
                ManageSettingDialog.show(context);
              },
              sclae: 1.03,
              borderRadius: 4.wMin,
              backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
              child: Container(
                width: 56.wMin,
                height: 56.wMin,
                alignment: Alignment.center,
                color: Colors.transparent,
                child: Icon(
                  Icons.settings,
                  color: AppTheme.cTextPrimary.color,
                  size: 24.wMin,
                ),
              ),
            ),
            SizedBox(width: 40.wMin),
            TapScaleWidget(
              onTap: () {
                _breadcrumbController.closeManage();
              },
              sclae: 1.03,
              borderRadius: 4.wMin,
              backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
              child: Container(
                alignment: Alignment.center,
                width: 56.wMin,
                height: 56.wMin,
                child: SvgPicture.asset(
                  "assets/svg/manage/icon_off.svg",
                  width: 38.wMin,
                  height: 38.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                ),
              ),
            ),

          ],
        ),
      ),
    );

    return Hero(
      tag: "manage_breadcrumb_hero",
      child: headerContent,
    );
  }

  /// 动画切换的浮动按钮
  Widget _buildAnimatedFloatingButton(BuildContext context) {

    bool isRegistered = Get.isRegistered<ManagementBreadcrumbController>();
    if(!isRegistered) return Container();

    ManagementBreadcrumbController _breadcrumbController = Get.find<ManagementBreadcrumbController>();
    return Obx(() {
      bool isBottomMenuCollapsed = _breadcrumbController.isBottomMenuCollapsed.value;
      return AnimatedAlign(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: isBottomMenuCollapsed ? Alignment.bottomRight : Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            right: isBottomMenuCollapsed ? 16.wMin : 0,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: Hero(
              tag: 'manage_nav_hero',
              child: SizedBox(
                key: ValueKey(isBottomMenuCollapsed),
                child: Visibility(
                  visible: showBottomNavigationBar,
                  child: isBottomMenuCollapsed ? _buildOpenButtonWidget() : _buildNavWidget(context),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 底部导航栏
  Widget _buildNavWidget(BuildContext context) {
    bool isRegistered = Get.isRegistered<ManagementController>();
    if(!isRegistered) return Container();

    ManagementController _controller = Get.find<ManagementController>();
    return Obx((){
      if(_controller.manageNavList.isEmpty) return Container();
      return ClipRRect(
        borderRadius: BorderRadius.circular(20.wMin),
        child: PlatformBackdropFilterWidget(
          sigmaX: 8,
          sigmaY: 8,
          child: Container(
            height: 80.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.wMin),
              color: AppTheme.cStaticBlack.color.withValues(alpha: 0.05),
              border: Border.all(
                width: 1.wMin,
                color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 10.wMin, right: 10.wMin),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16.wMin,
                children: [
                  ...List.generate(_controller.manageNavList.length, (index){
                    return _buildNavItemWidget(_controller.manageNavList[index]);
                  }),
                  _buildCollapseButtonWidget(),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItemWidget(ManageNavEnum nav) {
    bool isRegistered = Get.isRegistered<ManagementController>();
    if(!isRegistered) return Container();

    ManagementController _controller = Get.find<ManagementController>();
    return Obx(() {
      ManageNavEnum? currentNav = _controller.currentNav.value;
      return TapScaleWidget(
        onTap: () {
          _controller.switchNavIndex(nav);
        },
        sclae: 1.05,
        child: Container(
          height: 60.wMin,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 20.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: currentNav == nav ? AppTheme.cSurfaceBrand.color : AppTheme.cSurfaceSecondary.color,
          ),
          child: Text(
            nav.name,
            style: TextStyle(
              color: currentNav == nav ? AppTheme.cInverseTextLight.color : AppTheme.cTextPrimary.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  /// 收起按钮
  Widget _buildCollapseButtonWidget() {
    bool isRegistered = Get.isRegistered<ManagementBreadcrumbController>();
    if(!isRegistered) return Container();
    ManagementBreadcrumbController _breadcrumbController = Get.find<ManagementBreadcrumbController>();
    return TapScaleWidget(
      onTap: () {
        _breadcrumbController.collapseBottomMenu();
      },
      sclae: 1.03,
      child: Container(
        height: 60.wMin,
        width: 60.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceSecondary.color,
        ),
        child: SvgPicture.asset(
          "assets/svg/public/icon_w_arrow_right.svg",
          width: 28.wMin,
          colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
        ),
      ),
    );
  }

  /// 展开按钮
  Widget _buildOpenButtonWidget() {
    bool isRegistered = Get.isRegistered<ManagementBreadcrumbController>();
    if(!isRegistered) return Container();
    ManagementBreadcrumbController _breadcrumbController = Get.find<ManagementBreadcrumbController>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.wMin),
      child: PlatformBackdropFilterWidget(
        sigmaX: 8,
        sigmaY: 8,
        child: Container(
          height: 80.wMin,
          width: 80.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.wMin),
            color: AppTheme.cStaticBlack.color.withValues(alpha: 0.05),
            border: Border.all(
              width: 1.wMin,
              color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.1),
            ),
          ),
          child: TapScaleWidget(
            onTap: () {
              _breadcrumbController.expandBottomMenu();
            },
            sclae: 1.03,
            child: Container(
              height: 60.wMin,
              width: 60.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cSurfaceSecondary.color,
              ),
              child: SvgPicture.asset(
                "assets/svg/public/icon_w_arrow_left.svg",
                width: 28.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



/// 管理端页面收藏夹
class ManagePageBookmarkDialog{
  static Future<void> show(BuildContext context) async{
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return const ManagePageBookmarkDialogWidget();
      },
    );
  }
}


class ManagePageBookmarkDialogWidget extends StatefulWidget {
  const ManagePageBookmarkDialogWidget({super.key});

  @override
  State<ManagePageBookmarkDialogWidget> createState() => _ManagePageBookmarkDialogWidgetState();
}

class _ManagePageBookmarkDialogWidgetState extends State<ManagePageBookmarkDialogWidget> {

  final ManagementBreadcrumbController _breadcrumbController = Get.find<ManagementBreadcrumbController>();

  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "页面收藏夹",
      child: SizedBox(
        height: 600.wMin,
        child: _buildListWidget(),
      ),
    );
  }

  Widget _buildListWidget(){
    return Obx((){
      return ListView.separated(
        itemCount: _breadcrumbController.pageBookmarks.length,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        separatorBuilder: (context, index) {
          return Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color);
        },
        itemBuilder: (context, index) {
          return _buildItemWidget(_breadcrumbController.pageBookmarks[index], index);
        },
      );
    });
  }

  Widget _buildItemWidget(ManagePageBookmarkModel item, int index){
    String remark = "";
    if(item.remark != null && item.remark != ""){
      remark = "  （ ${item.remark} ）";
    }

    return TapScaleWidget(
      onTap: () {
        Get.back();
        _breadcrumbController.jumpToPageBookmark(context, index);
      },
      sclae: 1,
      borderRadius: 10.wMin,
      backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.05),
      child: Container(
        padding: EdgeInsets.only(
          left: 24.wMin,
          right: 4.wMin,
          bottom: 8.wMin,
          top: 8.wMin,
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            Expanded(
              child: Text(
                "${item.name} $remark",
                style: TextStyle(
                  color: AppTheme.cTextPrimary.color,
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 10.wMin),
      
            TapScaleWidget(
              onTap: () {
                _breadcrumbController.editPageBookmark(context, index);
              },
              sclae: 1.03,
              borderRadius: 4.wMin,
              backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
              child: Container(
                width: 48.wMin,
                height: 48.wMin,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  "assets/svg/manage/icon_edit.svg",
                  width: 20.wMin,
                  height: 20.wMin,
                ),
              ),
            ),
      
            TapScaleWidget(
              onTap: () {
                _breadcrumbController.removePageBookmark(index);
              },
              sclae: 1.03,
              borderRadius: 4.wMin,
              backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
              child: Container(
                width: 48.wMin,
                height: 48.wMin,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  "assets/svg/public/x.svg",
                  width: 24.wMin,
                  height: 24.wMin,
                ),
              ),
            ),
      
          ],
        ),
      ),
    );
  }

}
