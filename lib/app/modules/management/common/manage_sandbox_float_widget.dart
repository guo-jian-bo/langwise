import 'package:draggable_float_widget/draggable_float_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/public_controller/manage_sandbox_controller.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class ManageSandboxFloatWidget extends GetView<ManageSandboxController> {
  const ManageSandboxFloatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isSimulate = controller.isSimulate;
      bool isShowMenu = controller.isShowMenu.value;
      final Size windowSize = MediaQuery.sizeOf(context);
      final EdgeInsets windowPadding = MediaQuery.paddingOf(context);
      if (!isSimulate) return const SizedBox();
      return DraggableFloatWidget(
        // iOS 部分机型进入沙盒后不一定会触发 didChangeMetrics，
        // 这里直接跟随当前窗口尺寸和安全区重建浮窗，避免首帧挂着空 child。
        key: ValueKey("${windowSize}_${windowPadding}_$isShowMenu"),
        width: isShowMenu ? 300.wMin : 80.wMin,
        height: isShowMenu ? 460.wMin : 80.wMin,
        config: DraggableFloatWidgetBaseConfig(
          initPositionYInTop: false,
          initPositionXInLeft: false,
          delayShowDuration: const Duration(milliseconds: 200),
          animDuration: const Duration(milliseconds: 200),
          borderRight: 10.wMin,
          borderLeft: 10.wMin,
          borderTop: 10.wMin,
          borderBottom: 10.wMin + MediaQuery.of(context).padding.bottom,
          initPositionYMarginBorder: 100.wMin + MediaQuery.of(context).padding.bottom,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: isShowMenu ? _buildMenuWidget(context) : _buildFloatButtonWidget(),
        ),
      );
    });
  }

  Widget _buildFloatButtonWidget() {
    return TapScaleWidget(
      onTap: () {
        controller.toggleMenu();
      },
      sclae: 1.03,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.cSurfaceLayerElevated.color,
          border: Border.all(
            width: 1.wMin,
            color: AppTheme.cBorderPrimary.color,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cSurfaceLayerElevated.color,
              blurRadius: 10.wMin,
            ),
          ],
        ),
        child: Icon(
          Icons.manage_accounts,
          color: AppTheme.cTextPrimary.color,
          size: 32.wMin,
        ),
      ),
    );
  }

  Widget _buildMenuWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cBorderPrimary.color,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cSurfaceLayerElevated.color,
            blurRadius: 10.wMin,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuTitleWidget(),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
                child: _buildMenuBodyWidget(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTitleWidget() {
    return Container(
      height: 48.wMin,
      padding: EdgeInsets.only(left: 16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Row(
        children: [
          Text(
            "管理员沙盒",
            style: TextStyle(
              color: AppTheme.cTextPrimary.color,
              fontSize: 22.wMin,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TapScaleWidget(
            onTap: () {
              controller.toggleMenu();
            },
            sclae: 1.1,
            child: Container(
              color: Colors.transparent,
              width: 48.wMin,
              height: 48.wMin,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                "assets/svg/public/x.svg",
                width: 24.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBodyWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "管理员",
              style: TextStyle(
                color: AppTheme.cTextPrimary.color,
                fontSize: 22.wMin,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TapScaleWidget(
              onTap: () {
                controller.exitMember();
              },
              sclae: 1.01,
              child: Text(
                "退出学员",
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.wMin),
        _buildMenuBodyButtonWidget(
          name: "工单列表",
          onTap: () {
            controller.viewInspectionTicket();
          },
        ),
        SizedBox(height: 8.wMin),
        _buildMenuBodyButtonWidget(
          name: "历史操作",
          onTap: () {
            controller.viewInspectionHistory();
          },
        ),
        SizedBox(height: 10.wMin),
        Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
        SizedBox(height: 10.wMin),
        Text(
          "学员：${controller.userPatrol?.name ?? ''}",
          style: TextStyle(
            color: AppTheme.cTextPrimary.color,
            fontSize: 22.wMin,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.wMin),
        _buildMenuBodyButtonWidget(
          name: "学习规划",
          onTap: () {
            controller.navigateToLearningPlan();
          },
        ),
        SizedBox(height: 8.wMin),
        _buildMenuBodyButtonWidget(
          name: "管理教材",
          onTap: () {
            controller.navigateToManageTextbook();
          },
        ),
        SizedBox(height: 8.wMin),
        _buildMenuBodyButtonWidget(
          name: "兑换卡券",
          onTap: () {
            controller.exchangeCoupon();
          },
        ),
      ],
    );
  }

  Widget _buildMenuBodyButtonWidget({
    required String name,
    void Function()? onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.01,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 16.wMin,
          top: 10.wMin,
          bottom: 10.wMin,
          right: 10.wMin,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceSecondary.color,
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: AppTheme.cTextPrimary.color,
                  fontSize: 22.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SvgPicture.asset(
              "assets/svg/public/icon_w_arrow_right.svg",
              width: 24.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
