import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ZhenxieTaskViewSampleLockDialog {
  static Future<bool> show({
    required BuildContext context,
    bool isManagement = false,
    required String title,
    required String content,
  }) async {
    bool? res = await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ZhenxieTaskViewSampleLockDialogWidget(
          isManagement: isManagement,
          title: title,
          content: content,
        );
      },
    );

    return res ?? false;
  }
}

class ZhenxieTaskViewSampleLockDialogWidget extends StatefulWidget {
  final bool isManagement;

  /// 弹窗标题文案，由外部根据业务场景传入。
  final String title;

  /// 弹窗内容文案，由外部根据业务场景传入。
  final String content;
  const ZhenxieTaskViewSampleLockDialogWidget({
    super.key,
    this.isManagement = false,
    required this.title,
    required this.content,
  });

  @override
  State<ZhenxieTaskViewSampleLockDialogWidget> createState() => _ZhenxieTaskViewSampleLockDialogWidgetState();
}

class _ZhenxieTaskViewSampleLockDialogWidgetState extends State<ZhenxieTaskViewSampleLockDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Container(
          width: 720.wMin,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.wMin),
            color: AppTheme.cSurfaceSecondary.color,
            border: Border.all(
              color: AppTheme.cBorderPrimary.color,
              width: 1.wMin,
            ),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitleWidget(),
                  _buildContentWidget(),
                  SizedBox(height: 64.wMin),
                  _buildButtonsWidget(),
                  SizedBox(height: 32.wMin),
                ],
              ),
              Positioned(
                top: 20.wMin,
                right: 20.wMin,
                child: _buildCloseWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.wMin),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffF97316).withValues(alpha: 0.12),
            Color(0xffF97316).withValues(alpha: 0),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100.wMin,
            height: 100.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xffF97316).withValues(alpha: 0.2),
            ),
            child: SvgPicture.asset(
              "assets/svg/public/icon_lock.svg",
              width: 40.wMin,
            ),
          ),
          SizedBox(height: 6.wMin),
          Text(
            widget.title,
            style: TextStyle(
              color: AppTheme.cTextPrimary.color,
              fontSize: 40.wMin,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Text(
        widget.content,
        style: TextStyle(
          color: AppTheme.cTextSecondary.color,
          fontSize: 24.wMin,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCloseWidget() {
    return TapScaleWidget(
      onTap: () {
        Get.back(result: false);
      },
      sclae: 1.05,
      child: Container(
        width: 48.wMin,
        height: 48.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.cSurfaceLayerElevated.color,
        ),
        child: SvgPicture.asset(
          "assets/svg/public/x.svg",
          width: 24.wMin,
          colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildButtonsWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        spacing: 12.wMin,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: ButtonWidget(
              text: "取消",
              height: 56.wMin,
              borderRadius: 8.wMin,
              color: AppTheme.cSurfaceLayerElevated.color,
              border: Border.all(
                color: AppTheme.cBorderSubtle.color,
                width: 0.8.wMin,
              ),
              fontColor: AppTheme.cTextSecondary.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.01,
              onTap: () {
                Get.back(result: false);
              },
            ),
          ),
          Expanded(
            child: ButtonWidget(
              text: widget.isManagement ? "教研查看" : "先去写",
              height: 56.wMin,
              borderRadius: 8.wMin,
              color: Color(0xffF97316).withValues(alpha: 0.8),
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.01,
              onTap: () {
                Get.back(result: widget.isManagement ? true : false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
