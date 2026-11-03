import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
// ignore: implementation_imports
import 'package:bot_toast/src/toast_widget/attached.dart';
// ignore: implementation_imports
import 'package:bot_toast/src/toast_widget/animation.dart';

import '../theme/theme.dart';

enum ManageToastType {
  /// 默认类型
  defaultType,

  /// 失败
  error,

  /// ai处理完成
  aiComplete,

  /// ai放弃
  aiGiveUp,
}

enum ToastType {
  /// 成功
  success,

  /// 失败
  error,

  /// 警告
  warning,

  /// 信息
  info,

  /// 默认
  defaultType
}

class ToastUtils {
  static void showToast({
    required String text,
    ToastType type = ToastType.error,
    bool onlyOne = true,
    double marginBottom = 0,
    bool showCloseBtn = false,
    String btnText = '',
    Function? onBtnTap,
    Function? onClose,
    int milliseconds = 1000,
  }) {
    if (showCloseBtn) {
      milliseconds = 0;
    }
    String toastIcon = 'assets/svg/public/icon_toast_default.svg';
    Color iconBgColor = AppTheme.cTextSecondary.color;
    Color btnTxtColor = AppTheme.cInverseTextLight.color;
    Color closeBtnColor = AppTheme.cTextTertiary.color;
    Color btnBgColor = AppTheme.cSurfaceQuaternary.color;
    //暂无 therity
    Color borderColor = AppTheme.cBorderTertiary.color;
    Color bgColor = AppTheme.cSurfaceTertiary.color;
    if (type == ToastType.error) {
      toastIcon = 'assets/svg/public/icon_toast_error.svg';
      closeBtnColor = AppTheme.cFeedbackErrorText;
      btnTxtColor = AppTheme.cInverseTextLight;
      borderColor = AppTheme.cFeedbackErrorBorder.color;
      bgColor = AppTheme.cFeedbackErrorBackground;
      btnBgColor = AppTheme.cSurfaceError.color;
    } else if (type == ToastType.warning) {
      toastIcon = 'assets/svg/public/icon_toast_warning.svg';
      closeBtnColor = AppTheme.cFeedbackWarningText;
      btnTxtColor = AppTheme.cInverseTextLight;
      borderColor = AppTheme.cFeedbackWarningBorder.color;
      bgColor = AppTheme.cFeedbackWarningBackground;
      btnBgColor = AppTheme.cSurfaceWarning.color;
    } else if (type == ToastType.info) {
      btnTxtColor = AppTheme.cInverseTextLight.color;
      iconBgColor = AppTheme.cSurfaceInfo.color;
      closeBtnColor = AppTheme.cTextBrand.color;
      bgColor = AppTheme.cFeedbackInfoBackground;
      borderColor = AppTheme.cFeedbackInfoBorder.color;
      btnBgColor = AppTheme.cSurfaceInfo.color;
    } else if (type == ToastType.success) {
      toastIcon = 'assets/svg/public/icon_toast_success.svg';
      iconBgColor = AppTheme.cSurfaceSuccess.color;
      btnTxtColor = AppTheme.cInverseTextLight.color;
      closeBtnColor = AppTheme.cFeedbackSuccessText.color;
      borderColor = AppTheme.cFeedbackSuccessBorder.color;
      bgColor = AppTheme.cFeedbackSuccessBackground;
      btnBgColor = AppTheme.cSurfaceSuccess;
    }

    BotToast.showCustomText(
      animationDuration: const Duration(milliseconds: 100),
      onlyOne: onlyOne,
      duration: milliseconds == 0 ? null : Duration(milliseconds: milliseconds),
      toastBuilder: (cancelFunc) {
        return Container(
          height: 80.wMin,
          margin: EdgeInsets.only(bottom: marginBottom),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: AppTheme.cSurfaceTertiary,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: bgColor,
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 80.wMin,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    toastIcon,
                    width: 40.wMin,
                    height: 40.wMin,
                    colorFilter: type == ToastType.info ? ColorFilter.mode(iconBgColor, BlendMode.srcIn) : null,
                  ),
                ),
                SizedBox(width: 12.wMin),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (btnText.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      onBtnTap?.call();
                      cancelFunc();
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 12.wMin),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.wMin), color: btnBgColor),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                      child: Text(
                        btnText,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: btnTxtColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (showCloseBtn)
                  GestureDetector(
                    onTap: () {
                      onClose?.call();
                      cancelFunc();
                    },
                    child: Container(
                        margin: EdgeInsets.only(left: 12.wMin),
                        width: 56.wMin,
                        height: 56.wMin,
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/svg/public/icon_clean.svg',
                          width: 32.wMin,
                          height: 32.wMin,
                          colorFilter: ColorFilter.mode(closeBtnColor, BlendMode.srcIn),
                        )),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  static void showManageToast({
    required String text,
    GlobalKey? containerKey,
    ManageToastType type = ManageToastType.defaultType,
  }) {
    RenderBox? box = containerKey?.currentContext?.findRenderObject() as RenderBox?;
    Rect targetRect = Rect.zero;
    if (box != null) {
      Size size = box.size;
      Offset offset = box.localToGlobal(Offset.zero);
      targetRect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    }

    BotToast.showAnimationWidget(
      animationDuration: const Duration(milliseconds: 200),
      duration: const Duration(seconds: 3),
      onlyOne: true,
      enableKeyboardSafeArea: true,
      wrapToastAnimation: (controller, cancelFunc, widget) {
        return Builder(
          builder: (context) {
            return NormalAnimation(
              controller: controller,
              child: Builder(
                builder: (context) {
                  return CustomSingleChildLayout(
                    delegate: PositionDelegate(
                      target: targetRect,
                      verticalOffset: 0,
                      horizontalOffset: 0,
                      preferDirection: box != null ? PreferDirection.bottomCenter : null,
                      paddingTop: MediaQuery.of(context).padding.top,
                    ),
                    child: Container(
                      alignment: box == null ? Alignment.bottomCenter : null,
                      padding: EdgeInsets.all(box == null ? 100.wMin : 0),
                      child: widget,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      toastBuilder: (cancelFunc) {
        return ManageToastUtilsWidget(
          text: text,
          type: type,
        );
      },
    );
  }

  static void showLoading({String? text}) {
    BotToast.showCustomLoading(
      enableKeyboardSafeArea: false,
      clickClose: false,
      toastBuilder: (cancelFunc) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitFadingCircle(
                color: AppTheme.cBgBrand,
                size: 100.wMin,
              ),
              Visibility(
                visible: text != null,
                child: Container(
                  margin: EdgeInsets.only(top: 20.wMin),
                  child: Text(
                    text ?? "",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void hideLoading() {
    BotToast.closeAllLoading();
  }
}

class ManageToastUtilsWidget extends StatelessWidget {
  final String text;
  final ManageToastType type;

  const ManageToastUtilsWidget({super.key, required this.text, this.type = ManageToastType.defaultType});

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xff2388FF);
    Color backgroundColor = const Color(0xff061C37);
    if (type == ManageToastType.aiComplete) {
      borderColor = const Color(0xff44AF5C);
      backgroundColor = const Color(0xff031E14);
    } else if (type == ManageToastType.aiGiveUp) {
      borderColor = const Color(0xff767E95);
      backgroundColor = const Color(0xff23283D);
    } else if (type == ManageToastType.error) {
      borderColor = const Color(0xffFF2D46);
      backgroundColor = const Color(0xff43050C);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        border: Border.all(width: 1.wMin, color: borderColor),
        color: backgroundColor,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "",
          fontSize: 16.wMin,
          color: const Color(0xffFFFFFF),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
