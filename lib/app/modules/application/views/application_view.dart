import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../home/views/home_view.dart';
import '../common/message_drawer_widget.dart';
import '../common/nav_buttons_widget.dart';
import '../controllers/application_controller.dart';

class ApplicationView extends GetView<ApplicationController> {
  const ApplicationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: AppTheme.cBgPrimary.color,
      // extendBody: true,
      resizeToAvoidBottomInset: false,
      drawerScrimColor: AppTheme.cOverlayBackground.color.withValues(alpha: 0.3),
      endDrawer: const MessageDrawerWidget(),
      body: Stack(
        children: [
          const HomeView(),
          // Positioned(
          //   bottom: 20.wMin,
          //   right: 20.wMin,
          //   child: _buildGuideTaskListButtonWidget(context),
          // ),
        ],
      ),
      bottomNavigationBar: const NavButtonsWidget(),
    );
  }

  /// 功能引导浮窗按钮
  Widget _buildGuideTaskListButtonWidget(BuildContext context){
    return TapScaleWidget(
      onTap: () {
        controller.openTaskList(context);
      },
      sclae: 1.01,
      child: Container(
        height: 80.wMin,
        padding: EdgeInsets.symmetric(horizontal: 20.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(width: 1.wMin, color: AppTheme.cInverseOverlay3.color),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xff0EA5E9),
              const Color(0xff0EA5E9),
            ],
          ),
        ),
        child: Row(
          spacing: 6.wMin,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              "assets/svg/public/icon_guide.svg",
              width: 40.wMin,
            ),
            Text(
              "功能指南",
              style: TextStyle(
                fontSize: 28.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  


}
