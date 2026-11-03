import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/behavior/route_transition_observer.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'button_widgets.dart';
import 'tap_scale_widget.dart';

enum AskLevelType {
  message,
  success,
  error,
  warning,
}

class AskDialogAction {
  final String text;
  final Color color;
  final Color fontColor;
  final FontWeight fontWeight;
  final BoxBorder? border;
  final double borderRadius;
  final bool enabled;
  final void Function()? onTap;

  const AskDialogAction({
    required this.text,
    required this.color,
    this.fontColor = AppTheme.cStaticWhite,
    this.fontWeight = FontWeight.w400,
    this.border,
    this.borderRadius = 12,
    this.enabled = true,
    this.onTap,
  });
}

/// 询问弹窗
/// * showLastCountdown: 是否显示define按钮后面的倒计时
/// * lastCountdown: 倒计时时长
class AskDialog {
  static Future<bool> show({
    required BuildContext context,
    String? title,
    Color? titleColor,
    String? content,
    String cancel = "取消",
    String define = "确定",
    Color? defineColor,
    double? defineButtonWidth,
    bool showCancel = true,
    bool showLastCountdown = false,
    int lastCountdown = 3,
    AskLevelType askLevel = AskLevelType.warning,
    void Function()? onCancel,
    void Function()? onDefine,
  }) async {
    bool? ask = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return AskDialogWidget(
          title: title,
          conten: content,
          cancel: cancel,
          define: define,
          showCancel: showCancel,
          onCancel: onCancel,
          onDefine: onDefine,
          showLastCountdown: showLastCountdown,
          lastCountdown: lastCountdown,
          defineButtonWidth: defineButtonWidth,
          askLevel: askLevel,
          defineColor: defineColor,
          titleColor: titleColor,
        );
      },
    );
    if (ask == null) return false;
    return ask;
  }

  static Future<T?> showCustom<T>({
    required BuildContext context,
    String? title,
    Color titleColor = AppTheme.cTextPrimary,
    required Widget child,
    required List<AskDialogAction> actions,
    bool barrierDismissible = false,
    double width = 720,
    EdgeInsets? padding,
    bool showTopClose = true,
  }) async {
    final T? res = await showCupertinoDialog<T>(
      context: context,
      builder: (context) {
        return AskCustomDialogWidget(
          title: title,
          titleColor: titleColor,
          width: width,
          padding: padding,
          showTopClose: showTopClose,
          actions: actions,
          child: child,
        );
      },
      barrierDismissible: barrierDismissible,
    );
    return res;
  }

  static Future<bool> showUserAskToast({
    String? title,
    Color titleColor = AppTheme.cTextPrimary,
    String? content,
    Color contentColor = AppTheme.cTextPrimary,
    Color defineColor = AppTheme.cBgBrand,
    String cancel = "取消",
    bool showCancel = true,
    String define = "确定",
    bool blockDuringTransition = false,
  }) async {
    final completer = Completer<bool>();

    BotToast.showCustomText(
      onlyOne: true,
      crossPage: true,
      duration: null,
      toastBuilder: (cancelFunc) {
        return _AskToastDialog(
          title: title,
          titleColor: titleColor,
          content: content,
          contentColor: contentColor,
          cancelText: cancel,
          defineText: define,
          defineColor: defineColor,
          showCancel: showCancel,
          blockDuringTransition: blockDuringTransition,
          onResult: (v) {
            if (!completer.isCompleted) {
              completer.complete(v);
            }
            cancelFunc();
          },
        );
      },
    );

    return completer.future;
  }

  static Future<bool> showUserAsk({
    required BuildContext context,
    String? title,
    Color titleColor = AppTheme.cTextPrimary,
    String? content,
    Color contentColor = AppTheme.cTextPrimary,
    Color defineColor = AppTheme.cBgBrand,
    String cancel = "取消",
    bool showCancel = true,
    String define = "确定",
    bool showLastCountdown = false,
    int lastCountdown = 3,
    void Function()? onCancel,
    void Function()? onDefine,
    CrossAxisAlignment? crossAxisAlignment,
  }) async {
    bool? ask = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return AskUserAskDialogWidget(
          title: title,
          content: content,
          cancel: cancel,
          define: define,
          showCancel: showCancel,
          defineColor: defineColor,
          onCancel: onCancel,
          onDefine: onDefine,
          titleColor: titleColor,
          contentColor: contentColor,
          showLastCountdown: showLastCountdown,
          lastCountdown: lastCountdown,
          crossAxisAlignment: crossAxisAlignment,
        );
      },
    );
    if (ask == null) return false;
    return ask;
  }

  static Future<bool?> showUserCancelAsk({
    required BuildContext context,
    String? title,
    Color titleColor = AppTheme.cTextPrimary,
    String? content,
    Color contentColor = AppTheme.cTextPrimary,
    String cancel = "取消",
    bool showCancel = true,
    String define = "确定",
    Color defineColor = AppTheme.cBgBrand,
    bool showLastCountdown = false,
    int lastCountdown = 3,
    void Function()? onCancel,
    void Function()? onDefine,
    CrossAxisAlignment? crossAxisAlignment,
  }) async {
    bool? ask = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return AskUserAskDialogWidget(
          title: title,
          content: content,
          cancel: cancel,
          define: define,
          defineColor: defineColor,
          showCancel: showCancel,
          onCancel: onCancel,
          onDefine: onDefine,
          titleColor: titleColor,
          contentColor: contentColor,
          showLastCountdown: showLastCountdown,
          lastCountdown: lastCountdown,
          crossAxisAlignment: crossAxisAlignment,
          showTopClose: true,
        );
      },
    );
    return ask;
  }

}

class AskUserAskDialogWidget extends StatefulWidget {
  final String? title;
  final Color titleColor;
  final String? content;
  final Color contentColor;
  final String cancel;
  final bool showCancel;
  final String define;
  final Color defineColor;
  final bool showLastCountdown;
  final int lastCountdown;
  final void Function()? onCancel;
  final void Function()? onDefine;
  final CrossAxisAlignment? crossAxisAlignment;
  final bool showTopClose;
  const AskUserAskDialogWidget({
    super.key,
    this.title,
    this.titleColor = AppTheme.cTextPrimary,
    this.content,
    this.contentColor = AppTheme.cTextPrimary,
    this.cancel = "取消",
    this.showCancel = true,
    this.define = "确定",
    this.defineColor = AppTheme.cBgBrand,
    this.showLastCountdown = false,
    this.lastCountdown = 3,
    this.onCancel,
    this.onDefine,
    this.crossAxisAlignment,
    this.showTopClose = false,
  });

  @override
  State<AskUserAskDialogWidget> createState() => _AskUserAskDialogWidgetState();
}

class _AskUserAskDialogWidgetState extends State<AskUserAskDialogWidget> {

  int countdown = 3;
  bool defineButtonFlag = true;

  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    if (widget.showLastCountdown) {
      defineButtonFlag = false;
      countdown = widget.lastCountdown;
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown--;
      if (countdown < 0) {
        timer.cancel();
        defineButtonFlag = true;
        _countdownTimer = null;
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.wMin),
          child: Container(
            width: 640.wMin,
            padding: EdgeInsets.all(32.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cBgSecondary,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Column(
                      crossAxisAlignment: widget.crossAxisAlignment ?? CrossAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: widget.title != null,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              widget.title ?? "",
                              style: TextStyle(
                                fontSize: 32.wMin,
                                fontWeight: FontWeight.w600,
                                color: widget.titleColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 32.wMin),
                        Visibility(
                          visible: widget.content != null,
                          child: Container(
                            //alignment: Alignment.center,
                            constraints: BoxConstraints(
                              minHeight: 60.wMin,
                            ),
                            child: Text(
                              widget.content ?? "",
                              //textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24.wMin,
                                color: widget.contentColor,
                                fontWeight: FontWeight.w500,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: widget.showTopClose,
                      child: Positioned(
                        right: 0,
                        top: 0,
                        child: TapScaleWidget(
                          sclae: 1.05,
                            onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                          child: Container(
                            width: 42.wMin,
                            height: 42.wMin,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.cSurfaceTertiary.color,
                            ),
                            child: SvgPicture.asset(
                              "assets/svg/public/x.svg",
                              width: 24.wMin,
                              height: 24.wMin,
                              colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 38.wMin),
                Row(
                  spacing: 18.wMin,
                  children: [
                    Visibility(
                      visible: widget.showCancel,
                      child: Expanded(
                        child: ButtonWidget(
                          text: widget.cancel,
                          height: 64.wMin,
                          fontColor: AppTheme.cTextSecondary,
                          fontSize: 24.wMin,
                          color: AppTheme.cBgTertiary,
                          borderRadius: 12.wMin,
                          sclae: 1.03,
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).pop(false);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ButtonWidget(
                        text: widget.define + (defineButtonFlag ? "" : "(${countdown}s)"),
                        height: 64.wMin,
                        fontColor: defineButtonFlag ? AppTheme.cStaticWhite : AppTheme.cTextDisabled,
                        fontSize: 24.wMin,
                        color: defineButtonFlag ? widget.defineColor : AppTheme.cBgTertiary,
                        borderRadius: 12.wMin,
                        sclae: 1.03,
                        onTap: defineButtonFlag ? () {
                          Navigator.of(context, rootNavigator: true).pop(true);
                        } : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AskDialogWidget extends StatefulWidget {
  final String? title;
  final String? conten;
  final String cancel;
  final String define;
  final bool showCancel;
  final bool showLastCountdown;
  final int lastCountdown;
  final double? defineButtonWidth;
  final void Function()? onCancel;
  final void Function()? onDefine;
  final AskLevelType askLevel;
  final Color? defineColor;
  final Color? titleColor;

  const AskDialogWidget({
    super.key,
    this.title,
    this.conten,
    required this.cancel,
    required this.define,
    required this.showCancel,
    this.showLastCountdown = false,
    this.lastCountdown = 3,
    this.defineButtonWidth,
    this.onCancel,
    this.onDefine,
    this.askLevel = AskLevelType.warning,
    this.defineColor,
    this.titleColor,
  });

  @override
  State<AskDialogWidget> createState() => _AskDialogWidgetState();
}

class _AskDialogWidgetState extends State<AskDialogWidget> {
  int countdown = 3;
  bool defineButtonFlag = true;

  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    if (widget.showLastCountdown) {
      defineButtonFlag = false;
      countdown = widget.lastCountdown;
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown--;
      if (countdown < 0) {
        timer.cancel();
        defineButtonFlag = true;
        _countdownTimer = null;
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildTitleWidget() {
      String svg = "assets/svg/manage/icon_warn.svg";
      if (widget.askLevel == AskLevelType.message) {
        svg = "assets/svg/manage/icon_info_circle.svg";
      } else if (widget.askLevel == AskLevelType.success) {
        svg = "assets/svg/manage/icon_success_circle.svg";
      } else if (widget.askLevel == AskLevelType.error) {
        svg = "assets/svg/manage/icon_error_circle.svg";
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(
                  svg,
                  width: 24.wMin,
                ),
                SizedBox(width: 14.wMin),
                Expanded(
                  child: Text(
                    widget.title ?? "",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: widget.titleColor?? const Color(0xffEBEEF3),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TapScaleWidget(
            onTap: () {
              widget.onCancel?.call();
              Get.back(result: false);
            },
            child: Container(
              color: Colors.transparent,
              width: 24.wMin,
              height: 24.wMin,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                "assets/svg/manage/icon_close.svg",
                width: 20.wMin,
                height: 20.wMin,
              ),
            ),
          ),
        ],
      );
    }

    return Material(
      color: const Color(0xff040712).withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 424.wMin,
          padding: EdgeInsets.all(24.wMin),
          decoration: BoxDecoration(
            color: const Color(0xff23283D),
            borderRadius: BorderRadius.circular(16.wMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitleWidget(),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 500.wMin,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: 21.wMin,
                    left: 37.wMin,
                    bottom: 21.wMin,
                  ),
                  child: Text(
                    widget.conten ?? '',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: const Color(0xffACB4C0),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.wMin),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                    visible: widget.showCancel,
                    child: Container(
                      margin: EdgeInsets.only(right: 13.wMin),
                      child: ButtonWidget(
                        text: widget.cancel,
                        borderRadius: 6.wMin,
                        border: Border.all(width: 0.5.wMin, color: const Color(0xff767E95)),
                        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                        height: 40.wMin,
                        color: Colors.transparent,
                        fontSize: 14.wMin,
                        fontColor: const Color(0xffEBEEF3),
                        onTap: () {
                          widget.onCancel?.call();
                          Get.back(result: false);
                        },
                      ),
                    ),
                  ),
                  ButtonWidget(
                    text: widget.define + (!defineButtonFlag ? " ($countdown)" : ""),
                    borderRadius: 6.wMin,
                    height: 40.wMin,
                    width: widget.defineButtonWidth,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    // color: defineButtonFlag ? const Color(0xff2388FF) : const Color(0xff1D4A7E),
                    color: (widget.defineColor??const Color(0xff2388FF)).withValues(alpha: defineButtonFlag ? 1 : 0.5),
                    fontSize: 14.wMin,
                    fontColor: defineButtonFlag ? const Color(0xffEBEFF5) : const Color(0xff8B9BB3),
                    onTap: !defineButtonFlag
                        ? null
                        : () {
                      widget.onDefine?.call();
                      Get.back(result: true);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AskAppDialogWidget extends StatefulWidget {
  final String? title;
  final String? conten;
  final String cancel;
  final String define;
  final bool showCancel;
  final bool showLastCountdown;
  final int lastCountdown;
  final double? defineButtonWidth;
  final void Function()? onCancel;
  final void Function()? onDefine;
  final AskLevelType askLevel;

  const AskAppDialogWidget({
    super.key,
    this.title,
    this.conten,
    required this.cancel,
    required this.define,
    required this.showCancel,
    this.showLastCountdown = false,
    this.lastCountdown = 3,
    this.defineButtonWidth,
    this.onCancel,
    this.onDefine,
    this.askLevel = AskLevelType.warning,
  });

  @override
  State<AskAppDialogWidget> createState() => _AskAppDialogWidgetState();
}

class _AskAppDialogWidgetState extends State<AskAppDialogWidget> {
  int countdown = 3;
  bool defineButtonFlag = true;

  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    if (widget.showLastCountdown) {
      defineButtonFlag = false;
      countdown = widget.lastCountdown;
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown--;
      if (countdown < 0) {
        timer.cancel();
        defineButtonFlag = true;
        _countdownTimer = null;
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildTitleWidget() {
      String svg = "assets/svg/manage/icon_warn.svg";
      if (widget.askLevel == AskLevelType.message) {
        svg = "assets/svg/manage/icon_info_circle.svg";
      } else if (widget.askLevel == AskLevelType.success) {
        svg = "assets/svg/manage/icon_success_circle.svg";
      } else if (widget.askLevel == AskLevelType.error) {
        svg = "assets/svg/manage/icon_error_circle.svg";
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            svg,
            width: 24.wMin,
          ),
          SizedBox(width: 14.wMin),
          Expanded(
            child: Text(
              widget.title ?? "",
              style: TextStyle(
                fontSize: 24.wMin,
                color: const Color(0xffF9F9FA),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Container(
          width: 640.wMin,
          height: 284.wh,
          padding: EdgeInsets.all(40.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cBgSecondary,
            borderRadius: BorderRadius.circular(16.wMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitleWidget(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: 21.wMin,
                    left: 37.wMin,
                    bottom: 21.wMin,
                  ),
                  child: Text(
                    widget.conten ?? '',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: const Color(0xffAFB1B5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.wMin),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                    visible: widget.showCancel,
                    child: Container(
                      margin: EdgeInsets.only(right: 13.wMin),
                      child: ButtonWidget(
                        text: widget.cancel,
                        borderRadius: 6.wMin,
                        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                        height: 56.wh,
                        color: Colors.white.withValues(alpha: 0.08),
                        fontSize: 20.wMin,
                        width: 190.wMin,
                        fontColor: Colors.white,
                        onTap: () {
                          widget.onCancel?.call();
                          Get.back(result: false);
                        },
                      ),
                    ),
                  ),
                  ButtonWidget(
                    text: widget.define + (!defineButtonFlag ? " ($countdown)" : ""),
                    borderRadius: 6.wMin,
                    height: 56.wh,
                    width: widget.defineButtonWidth ?? 280.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    color: defineButtonFlag ? const Color(0xff0EA5E9) : const Color(0xff1D4A7E),
                    fontSize: 20.wMin,
                    fontColor: defineButtonFlag ? const Color(0xffffffff) : const Color(0xff8B9BB3),
                    onTap: !defineButtonFlag
                        ? null
                        : () {
                      widget.onDefine?.call();
                      Get.back(result: true);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class AskCustomDialogWidget extends StatelessWidget {
  final String? title;
  final Color titleColor;
  final Widget child;
  final List<AskDialogAction> actions;
  final bool showTopClose;
  final double width;
  final EdgeInsets? padding;

  const AskCustomDialogWidget({
    super.key,
    this.title,
    this.titleColor = AppTheme.cTextPrimary,
    required this.child,
    required this.actions,
    this.showTopClose = true,
    this.width = 720,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.wMin),
          child: Container(
            width: width.wMin,
            padding: padding ?? EdgeInsets.all(24.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cBgSecondary,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null) ...[
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              title ?? '',
                              style: TextStyle(
                                fontSize: 20.wMin,
                                fontWeight: FontWeight.w600,
                                color: titleColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.wMin),
                        ],
                        child,
                      ],
                    ),
                    if (showTopClose)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: TapScaleWidget(
                          sclae: 1.05,
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 42.wMin,
                            height: 42.wMin,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.cBgActive,
                            ),
                            child: SvgPicture.asset(
                              'assets/svg/public/x.svg',
                              width: 24.wMin,
                              height: 24.wMin,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 20.wMin),
                Row(
                  spacing: 16.wMin,
                  children: actions
                      .map(
                        (a) => Expanded(
                      child: ButtonWidget(
                        text: a.text,
                        height: 48.wMin,
                        fontColor: a.enabled ? a.fontColor : AppTheme.cTextDisabled,
                        fontSize: 16.wMin,
                        fontWeight: a.fontWeight,
                        color: a.enabled ? a.color : AppTheme.cBgTertiary,
                        border: a.border,
                        borderRadius: a.borderRadius.wMin,
                        sclae: 1.03,
                        onTap: a.enabled ? a.onTap : null,
                      ),
                    ),
                  )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AskToastDialog extends StatefulWidget {
  final String? title;
  final Color titleColor;
  final String? content;
  final Color contentColor;
  final String cancelText;
  final String defineText;
  final Color defineColor;
  final bool showCancel;
  final bool blockDuringTransition;
  final ValueChanged<bool> onResult;

  const _AskToastDialog({
    required this.title,
    required this.titleColor,
    required this.content,
    required this.contentColor,
    required this.cancelText,
    required this.defineText,
    required this.defineColor,
    required this.showCancel,
    this.blockDuringTransition = false,
    required this.onResult,
  });

  @override
  State<_AskToastDialog> createState() => _AskToastDialogState();
}

class _AskToastDialogState extends State<_AskToastDialog> {
  bool _sawTransitioning = false;
  bool _locked = false;

  Timer? _fallbackUnlockTimer;
  VoidCallback? _transitionListener;

  @override
  void initState() {
    super.initState();
    _locked = widget.blockDuringTransition;

    if (widget.blockDuringTransition) {
      _transitionListener = () {
        if (!mounted) return;
        _onTransitionChanged(RouteTransitionObserver.instance.isTransitioning.value);
      };
      RouteTransitionObserver.instance.isTransitioning.addListener(_transitionListener!);
    }

    if (widget.blockDuringTransition) {
      _fallbackUnlockTimer?.cancel();
      _fallbackUnlockTimer = Timer(const Duration(milliseconds: 3000), () {
        if (!mounted) return;
        if (_sawTransitioning) return;
        if (RouteTransitionObserver.instance.isTransitioning.value) return;
        if (_locked) {
          setState(() {
            _locked = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _fallbackUnlockTimer?.cancel();
    _fallbackUnlockTimer = null;

    if (_transitionListener != null) {
      RouteTransitionObserver.instance.isTransitioning.removeListener(_transitionListener!);
      _transitionListener = null;
    }

    super.dispose();
  }

  void _onTransitionChanged(bool transitioning) {
    if (!widget.blockDuringTransition) return;
    if (transitioning) {
      _sawTransitioning = true;
      if (!_locked) {
        setState(() {
          _locked = true;
        });
      }
      return;
    }

    if (_sawTransitioning && _locked) {
      setState(() {
        _locked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 650.wMin),
          child: Container(
            padding: EdgeInsets.all(24.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cSurfacePrimary.color,
              borderRadius: BorderRadius.circular(24.wMin),
              border: Border.all(
                color: AppTheme.cBorderPrimary.color,
                width: 1.wMin,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((widget.title ?? '').trim().isNotEmpty)
                  Container(
                    padding: EdgeInsets.only(bottom: 24.wMin),
                    child: Text(
                      widget.title!,
                      style: TextStyle(
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                  ),
    
                if ((widget.content ?? '').trim().isNotEmpty)
                  Container(
                    constraints: BoxConstraints(maxWidth: 600.wMin, minHeight: 100.wMin),
                    padding: EdgeInsets.only(bottom: 24.wMin),
                    child: Text(
                      widget.content!,
                      style: TextStyle(
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                  ),
                SizedBox(height: 24.wMin),
                ValueListenableBuilder<bool>(
                  valueListenable: RouteTransitionObserver.instance.isTransitioning,
                  builder: (_, transitioning, __) {
                    final disabled = _locked || transitioning;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        Expanded(
                          child: ButtonWidget(
                            text: widget.defineText,
                            height: 64.wMin,
                            fontColor: !disabled ? AppTheme.cStaticWhite : AppTheme.cTextDisabled,
                            fontSize: 24.wMin,
                            color: !disabled ? widget.defineColor : AppTheme.cBgTertiary,
                            borderRadius: 12.wMin,
                            sclae: 1.01,
                            onTap: disabled ? null : () {
                              widget.onResult(true);
                            },
                          ),
                        ),

                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
