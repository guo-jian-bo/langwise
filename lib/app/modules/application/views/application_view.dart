import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      body: const HomeView(),
      bottomNavigationBar: const NavButtonsWidget(),
    );
  }


}
