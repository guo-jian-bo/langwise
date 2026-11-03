import 'dart:io';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:themed/themed.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';
import '../public_controller/config_controller.dart';
import 'tips_icon_widget.dart';

class CardNeatBoxWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Widget child;
  final double? borderRadius;
  const CardNeatBoxWidget({
    super.key,
    this.width,
    this.height,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width ?? 586.wMin,
        height: height ?? 800.wMin,
        padding: padding ?? EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary,
          borderRadius: BorderRadius.circular(borderRadius ?? 32.wMin),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cShadowLight,
              blurRadius: 1.wMin,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class CardBoxWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final int pageIndex;
  final bool showBorder;
  final double currentPageIndex;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool buttonDisable;
  final String continueText;
  final void Function()? onContinue;
  final String? bottomButton;
  final ScrollController? scrollController;

  /// 按钮如果不是当前页面执行透明度隐藏
  final bool buttonNotCurrentOption;
  final void Function()? onBottomButton;
  final bool showButton1;
  final String button1Text;
  final void Function()? onButton1;
  final void Function()? onClose;

  const CardBoxWidget({
    super.key,
    this.width,
    this.height,
    required this.child,
    this.pageIndex = 0,
    this.showBorder = true,
    this.currentPageIndex = 0,
    this.padding,
    this.buttonDisable = false,
    this.onContinue,
    this.bottomButton,
    this.scrollController,
    this.onBottomButton,
    this.continueText = "继续",
    this.showButton1 = false,
    this.buttonNotCurrentOption = false,
    this.button1Text = "取消",
    this.onButton1,
    this.onClose,
  });

  @override
  State<CardBoxWidget> createState() => _CardBoxWidgetState();
}

class _CardBoxWidgetState extends State<CardBoxWidget> {
  @override
  Widget build(BuildContext context) {
    double difference = (widget.currentPageIndex - widget.pageIndex).abs();
    double scale = 1;
    double alpha = 1;
    double opacity = 1;
    double buttonOpacity = 1;
    double closeOpacity = 1;
    if (difference == 0) {
      scale = 1.0;
      alpha = 1.0;
      opacity = 1.0;
      buttonOpacity = 1;
      closeOpacity = 1;
    } else if (difference <= 1) {
      scale = 1 - difference * 0.1;
      alpha = 1 - difference;
      opacity = 1 - difference * 0.2;
      closeOpacity = 1 - difference;
      if (widget.buttonNotCurrentOption) {
        buttonOpacity = 1 - difference;
      }
    } else {
      scale = 0.9;
      alpha = 0;
      opacity = 0.8;
      closeOpacity = 0;
      if (widget.buttonNotCurrentOption) {
        buttonOpacity = 0;
      }
    }

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24.wMin),
      child: FutureBuilder(
        initialData: false,
        future: Future.delayed(const Duration(milliseconds: 10), () {
          return true;
        }),
        builder: (context, snapshot) {
          return IgnorePointer(
            ignoring: widget.currentPageIndex != widget.pageIndex,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: widget.width ?? 800.wMin,
                height: widget.height ?? 900.wMin,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.wMin),
                  color: widget.showBorder?AppTheme.cBgSecondary:Colors.transparent,
                  border: Border.all(
                    width: 2.wMin,
                    color: widget.showBorder?AppTheme.cBorderFocus.withValues(alpha: alpha):Colors.transparent,
                  ),
                  boxShadow: widget.showBorder?[
                    BoxShadow(
                      color: AppTheme.cBgSecondary,
                      blurRadius: 1.wMin,
                    ),
                  ]:[],
                ),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  extendBody: true,
                  resizeToAvoidBottomInset: false,
                  body: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: (snapshot.data ?? true) ? opacity : 0,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          controller: widget.scrollController,
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.only(bottom: 170.wMin),
                          child: Container(
                            padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 120.wMin),
                            child: AnimationLimiter(
                              child: widget.child,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: widget.onClose != null,
                          child: Positioned(
                            top: 20.wMin,
                            right: 20.wMin,
                            child: Opacity(
                              opacity: closeOpacity,
                              child: TapScaleWidget(
                                sclae: 1.03,
                                onTap: widget.onClose,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 6.wMin),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.wMin),
                                    color: AppTheme.cFeedbackErrorBackground.color,
                                  ),
                                  child: Text(
                                    "删除",
                                    style: TextStyle(
                                      color: AppTheme.cFeedbackErrorText,
                                      fontSize: 24.wMin,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottomNavigationBar: widget.onContinue == null
                      ? null
                      : ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(24.wMin),
                          ),
                          child: Opacity(
                            opacity: buttonOpacity,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              height: widget.onBottomButton == null ? 120.wMin : 160.wMin,
                              padding: EdgeInsets.only(top: 24.wMin),
                              decoration: BoxDecoration(
                                gradient: widget.showBorder?LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.01, 0.05, 0.3, 1],
                                  colors: [
                                    AppTheme.cSurfaceSecondary.withValues(alpha: 0),
                                    AppTheme.cSurfaceSecondary.withValues(alpha: 0.1),
                                    AppTheme.cSurfaceSecondary,
                                    AppTheme.cSurfaceSecondary,
                                  ],
                                ):null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Visibility(
                                    visible: widget.showButton1,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 80.wMin),
                                      child: Row(
                                        spacing: 12.wMin,
                                        children: [
                                          Expanded(
                                            child: ContinueButtonWidget(
                                              text: widget.button1Text,
                                              onTap: widget.onButton1,
                                            ),
                                          ),
                                          Expanded(
                                            child: ContinueButtonWidget(
                                              buttonDisable: widget.buttonDisable,
                                              text: widget.continueText,
                                              onTap: widget.onContinue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: !widget.showButton1,
                                    child: ContinueButtonWidget(
                                      buttonDisable: widget.buttonDisable,
                                      width: 480.wMin,
                                      text: widget.continueText,
                                      onTap: widget.onContinue,
                                    ),
                                  ),
                                  Visibility(
                                    visible: widget.bottomButton != null,
                                    child: Container(
                                      margin: EdgeInsets.only(top: 10.wMin),
                                      child: TapScaleWidget(
                                        onTap: widget.onBottomButton,
                                        sclae: 1.1,
                                        child: Container(
                                          padding: EdgeInsets.all(6.wMin),
                                          color: Colors.transparent,
                                          child: Text(
                                            widget.bottomButton ?? "",
                                            style: TextStyle(
                                              fontSize: 24.wMin,
                                              color: AppTheme.cTextBrand,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CardSelectRowBoxWidget extends StatelessWidget {
  final String name;
  final String description;
  final bool isSelected;
  final int animationIndex;
  final Color backColor;
  final Duration? delay;
  final void Function()? onTap;

  const CardSelectRowBoxWidget({
    super.key,
    required this.name,
    this.description = "",
    this.isSelected = false,
    this.onTap,
    this.animationIndex = 0,
    this.delay,
    this.backColor = AppTheme.cBgTertiary,
  });

  @override
  Widget build(BuildContext context) {
    return ListAnimationWidget(
      index: animationIndex,
      delay: delay,
      child: TapScaleWidget(
        onTap: onTap,
        sclae: 1.02,
        child: Container(
          padding: EdgeInsets.all(24.wMin),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.cTransparentBrand1 : backColor,
            borderRadius: BorderRadius.circular(16.wMin),
            border: Border.all(
              width: 1.wMin,
              color: isSelected ? AppTheme.cBorderBrand : AppTheme.cBorderPrimary,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    Visibility(
                      visible: description.isNotEmpty,
                      child: Container(
                        margin: EdgeInsets.only(top: 12.wMin),
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: AppTheme.cTextSecondary,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CardSelectDotWidget(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}

class CardSelectDotWidget extends StatelessWidget {
  final bool isSelected;
  final double size;
  const CardSelectDotWidget({super.key, this.isSelected = false, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      child: SvgPicture.asset(
        isSelected ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
        key: ValueKey(isSelected),
        width: size.wMin,
        height: size.wMin,
      ),
    );
  }
}

class CardSelectDot1Widget extends StatelessWidget {
  final bool isSelected;
  final double size;
  const CardSelectDot1Widget({super.key, this.isSelected = false, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      child: SvgPicture.asset(
        isSelected ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
        key: ValueKey(isSelected),
        width: size.wMin,
        height: size.wMin,
        colorFilter: isSelected ? null : const ColorFilter.mode(Color(0xFF5B6167), BlendMode.srcIn),
      ),
    );
  }
}

class PageAppBarWidget extends StatelessWidget {
  final double? paddingTop;
  final String? title;
  final VoidCallback? onBackTap;
  final bool showRightIcon;

  const PageAppBarWidget({super.key, this.paddingTop, this.title, this.onBackTap, this.showRightIcon = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + (paddingTop ?? 24.wMin)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.wMin),
        height: 65.wMin,
        child: Row(
          children: [
            TapScaleWidget(
              onTap: () {
                if (onBackTap != null) {
                  onBackTap!.call();
                } else {
                  Get.back();
                }
              },
              child: Container(
                height: 65.wMin,
                width: 65.wMin,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  "assets/svg/public/icon_arrow_left.svg",
                  height: 24.wMin,
                ),
              ),
            ),
            Text(
              title ?? "",
              style: TextStyle(
                fontSize: 17.wMin,
                color: const Color(0xffF2F4F9),
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            Visibility(
              visible: showRightIcon,
              child: TapScaleWidget(
                onTap: () {},
                child: Container(
                  height: 65.wMin,
                  width: 65.wMin,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_more.svg",
                    height: 45.wMin,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardDialogBoxWidget extends StatelessWidget {
  final String cancel;
  final String confirm;
  final String title;
  final Widget child;
  final double? height;
  final void Function()? onCancel;
  final void Function()? onConfirm;

  const CardDialogBoxWidget({
    super.key,
    required this.child,
    this.cancel = "取消",
    this.confirm = "完成",
    this.title = "",
    this.height,
    this.onCancel,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Material(
        color: AppTheme.cOverlayBackground,
        child: Center(
          child: Container(
            width: 720.wMin,
            height: height ?? 760.wMin,
            padding: EdgeInsets.only(top: 16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.wMin),
              color: AppTheme.cBgSecondary.color,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    TapScaleWidget(
                      onTap: onCancel,
                      sclae: 1.1,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 16.wMin),
                        color: Colors.transparent,
                        child: Text(
                          cancel,
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextBrand,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 28.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    TapScaleWidget(
                      onTap: onConfirm,
                      sclae: 1.1,
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 16.wMin),
                        child: Text(
                          confirm,
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextBrand,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardTitleIconTextWidget extends StatelessWidget {
  final String title;
  final String svg;
  final bool hideIcon;

  const CardTitleIconTextWidget({
    super.key,
    this.title = "",
    this.svg = "assets/svg/custom_course/icon_setting.svg",
    this.hideIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: !hideIcon,
          child: Container(
            margin: EdgeInsets.only(bottom: 8.wMin),
            child: SvgPicture.asset(
              svg,
              width: 120.wMin,
              height: 120.wMin,
            ),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 36.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class CardSelectWidget extends StatefulWidget {
  final String? title;
  final String svg;
  final String? hintText;
  final String? value;
  final double scale;
  final void Function(BuildContext context)? onTap;

  const CardSelectWidget({super.key, this.title, required this.svg, this.hintText, this.value, this.scale = 1.01, this.onTap});

  @override
  State<CardSelectWidget> createState() => _CardSelectWidgetState();
}

class _CardSelectWidgetState extends State<CardSelectWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: widget.title != null,
          child: Container(
            margin: EdgeInsets.only(bottom: 4.wMin),
            child: Text(
              widget.title ?? "",
              style: TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Builder(builder: (cxt) {
          return TapScaleWidget(
            sclae: widget.scale,
            onTap: () {
              widget.onTap?.call(cxt);
            },
            child: Container(
              height: 72.wMin,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cSurfaceTertiary.color,
                borderRadius: BorderRadius.circular(12.wMin),
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.value == null || widget.value == "" ? widget.hintText ?? "" : widget.value ?? "",
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: widget.value == null || widget.value == "" ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.wMin),
                  SvgPicture.asset(
                    widget.svg,
                    width: 24.wMin,
                    height: 24.wMin,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class CardInputWidget extends StatefulWidget {
  final String? title;
  final String? hintText;
  final void Function(String value)? onChanged;
  final void Function(String value)? onSubmitted;
  final void Function()? onClean;
  final TextEditingController? controller;
  final int? maxLength;
  final Color fillColor;
  final Color borderColor;
  final Color enabledColor;
  final BorderRadius? borderRadius;
  final bool readOnly;
  final bool enabled;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final double? height;
  final TextStyle? valueStyle;
  final TextStyle? hintStyle;
  final TextStyle? titleStyle;

  const CardInputWidget({
    super.key,
    this.hintText,
    this.title,
    this.onChanged,
    this.controller,
    this.maxLength,
    this.onSubmitted,
    this.onClean,
    this.fillColor = AppTheme.cSurfaceTertiary,
    this.borderColor = AppTheme.cBorderSecondary,
    this.enabledColor = AppTheme.cTextPrimary,
    this.borderRadius,
    this.readOnly = false,
    this.obscureText = false,
    this.enabled = true,
    this.inputFormatters,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.height,
    this.valueStyle,
    this.hintStyle,
    this.titleStyle,
  });

  @override
  State<CardInputWidget> createState() => _CardInputWidgetState();
}

class _CardInputWidgetState extends State<CardInputWidget> {
  final FocusNode focusNode = FocusNode();
  bool isFocus = false;
  bool isEmpty = true;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      isEmpty = widget.controller?.text.isEmpty ?? true;
    }

    focusNode.addListener(() {
      isFocus = focusNode.hasFocus;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(12.wMin),
      borderSide: BorderSide(width: 1.wMin, color: widget.borderColor),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: widget.title != null,
          child: Container(
            margin: EdgeInsets.only(bottom: 4.wMin),
            child: Text(
              widget.title ?? "",
              style: widget.titleStyle?? TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(
          height: widget.height?? 72.wMin,
          child: TextField(
            focusNode: focusNode,
            onChanged: (value) {
              isEmpty = value.isEmpty;
              if (mounted) setState(() {});
              widget.onChanged?.call(value);
            },
            onSubmitted: widget.onSubmitted,
            controller: widget.controller,
            maxLength: widget.maxLength,
            readOnly: widget.readOnly,
            enabled: widget.enabled,
            obscureText: widget.obscureText,
            inputFormatters: widget.inputFormatters,
            keyboardType: widget.keyboardType,
            style: widget.valueStyle ?? TextStyle(
              fontSize: 28.wMin,
              color: widget.enabled ? AppTheme.cTextPrimary : widget.enabledColor,
              fontWeight: FontWeight.w500,
            ),
            onTapOutside: (event) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            decoration: InputDecoration(
              isDense: true,
              counterText: "",
              fillColor: widget.fillColor,
              filled: true,
              border: border,
              focusedBorder: border,
              enabledBorder: border,
              disabledBorder: border,
              hintText: widget.hintText,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.wMin),
              hintStyle: widget.hintStyle?? TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextTertiary,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: widget.prefixIcon,
              suffixIconConstraints: BoxConstraints(
                maxWidth: widget.height??72.wMin,
                minHeight: widget.height??72.wMin,
              ),
              suffixIcon: widget.suffixIcon ??
                  Visibility(
                    visible: widget.onClean != null,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isFocus && !widget.readOnly && widget.enabled ? 1 : (isEmpty ? 0 : 0.5),
                      child: TapScaleWidget(
                        onTap: () {
                          isEmpty = true;
                          if (mounted) setState(() {});
                          widget.onClean?.call();
                        },
                        child: Container(
                          height: widget.height??72.wMin,
                          width: widget.height??72.wMin,
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          child: SvgPicture.asset(
                            "assets/svg/public/icon_clean.svg",
                            width: 24.wMin,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
            ),
          ),
        ),
      ],
    );
  }
}

class CardMinBoxWidget extends StatelessWidget {
  final String title;
  final Widget child;
  final Color backColor;
  final Color borderColor;
  final EdgeInsets? padding;

  const CardMinBoxWidget({
    super.key,
    required this.child,
    required this.title,
    this.backColor = AppTheme.cBgTertiary,
    this.borderColor = AppTheme.cBorderPrimary,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: backColor,
        border: Border.all(width: 1.wMin, color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class CardMinBox1Widget extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const CardMinBox1Widget({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cBgTertiary,
      ),
      child: child,
    );
  }
}

class CardMinBox2Widget extends StatelessWidget {
  final Widget child;
  final Color backColor;
  final Color borderColor;
  final EdgeInsets? padding;
  final double? radius;

  const CardMinBox2Widget({
    super.key,
    required this.child,
    this.padding,
    this.backColor = AppTheme.cBgTertiary,
    this.borderColor = AppTheme.cBgTertiary,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      padding: padding ?? EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 12.wMin),
        color: backColor,
        border: Border.all(width: 1.wMin, color: borderColor),
      ),
      child: child,
    );
  }
}

class CardLabelWidget extends StatelessWidget {
  final String? imageurl;
  final String? name;
  const CardLabelWidget({super.key, this.imageurl, this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin),
      height: 40.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: AppTheme.cBgQuaternary.color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: imageurl != null,
            child: Container(
              margin: EdgeInsets.only(right: 2.wMin),
              child: CachedImageWidget(imageurl ?? "", width: 24.wMin, height: 24.wMin),
            ),
          ),
          Text(
            name ?? "",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class CardTapArrowCoustomWidget extends StatelessWidget {
  final String? title;
  final double scale;
  final bool showArrow;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final void Function()? onTap;
  const CardTapArrowCoustomWidget({
    super.key,
    this.title,
    this.scale = 1.01,
    this.showArrow = true,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: title != null,
          child: Container(
            margin: EdgeInsets.only(bottom: 8.wMin),
            child: Text(
              title ?? "",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        TapScaleWidget(
          sclae: scale,
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(
              minHeight: 64.wMin,
            ),
            padding: padding ?? EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cBgTertiary,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: child,
                ),
                Visibility(
                  visible: showArrow,
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_w_arrow_right.svg",
                    width: 32.wMin,
                    colorFilter: const ColorFilter.mode(AppTheme.cTextTertiary, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CardTapArrowWidget extends StatelessWidget {
  final String? title;
  final String? hintText;
  final String? value;
  final double scale;
  final bool showArrow;
  final void Function()? onTap;

  const CardTapArrowWidget({
    super.key,
    this.value,
    this.title,
    this.hintText,
    this.showArrow = true,
    this.onTap,
    this.scale = 1.01,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: title != null,
          child: Container(
            margin: EdgeInsets.only(bottom: 8.wMin),
            child: Text(
              title ?? "",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        TapScaleWidget(
          sclae: scale,
          onTap: onTap,
          child: Container(
            height: 64.wMin,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cBgTertiary,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Visibility(
                        visible: hintText != null && value == null,
                        child: Text(
                          hintText ?? "",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextDisabled,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            scrollbars: false,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              height: double.infinity,
                              child: Text(
                                value ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: AppTheme.cTextPrimary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: showArrow,
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_w_arrow_right.svg",
                    width: 32.wMin,
                    colorFilter: const ColorFilter.mode(AppTheme.cTextTertiary, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CardSelectChangeWidget extends StatelessWidget {
  final String? title;
  final String? hintText;
  final String? value;
  final void Function()? onTap;

  const CardSelectChangeWidget({
    super.key,
    this.value,
    this.title,
    this.hintText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: title != null,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.wMin),
            child: Text(
              title ?? "",
              style: TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Container(
          height: 64.wMin,
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cBgTertiary,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Visibility(
                      visible: hintText != null && value == null,
                      child: Text(
                        hintText ?? "",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextDisabled,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        value ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: onTap != null,
                child: TapScaleWidget(
                  onTap: onTap,
                  sclae: 1.1,
                  child: Container(
                    height: 64.wMin,
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      "更改",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextBrand,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CardSelectBoxWidget extends StatelessWidget {
  final void Function()? onTap;
  final bool isSelect;
  final String name;
  final String content;
  final String svg;

  const CardSelectBoxWidget({
    super.key,
    this.onTap,
    this.isSelect = false,
    required this.name,
    required this.content,
    required this.svg,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.01,
      child: CardMinBox2Widget(
        borderColor: isSelect ? AppTheme.cBorderFocus : AppTheme.cBorderPrimary,
        backColor: AppTheme.cTransparentBrand1.addOpacity(isSelect ? 1 : 0),
        padding: EdgeInsets.all(16.wMin),
        radius: 16.wMin,
        child: IntrinsicHeight(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.wMin),
                child: SizedBox(
                  width: 126.wMin,
                  height: 126.wMin,
                  child: SvgPicture.asset(svg),
                ),
              ),
              SizedBox(width: 8.wMin),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: isSelect ? AppTheme.cTextBrand : AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          content,
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: isSelect ? AppTheme.cTextBrand : AppTheme.cTextTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CardSelectDotWidget(isSelected: isSelect),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardAddImageBoxWidget extends StatelessWidget {
  final String? title;
  final String addName;
  final String? fileUrl;
  final String? netUrl;
  final double? imageRadius;
  final double? imageWidth;
  final double? imageHeight;
  final bool showUpdateImage;
  final void Function()? onTap;

  const CardAddImageBoxWidget({
    super.key,
    this.addName = "添加封面",
    this.title,
    this.fileUrl,
    this.netUrl,
    this.imageRadius,
    this.imageWidth,
    this.imageHeight,
    this.showUpdateImage = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Container();
    if ((fileUrl?.isEmpty ?? true) && (netUrl?.isEmpty ?? true)) {
      imageWidget = buildAddWidget();
    } else {
      imageWidget = buildImageWidget();
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: title != null,
            child: Container(
              margin: EdgeInsets.only(bottom: 12.wMin),
              child: Text(
                title ?? "",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          TapScaleWidget(
            onTap: showUpdateImage ? onTap : null,
            sclae: 1.02,
            child: imageWidget,
          ),
        ],
      ),
    );
  }

  Widget buildAddWidget() {
    return DottedBorder(
      radius: Radius.circular(12.wMin),
      borderType: BorderType.RRect,
      padding: EdgeInsets.zero,
      color: AppTheme.cBorderSecondary,
      dashPattern: [4.wMin, 2.wMin],
      strokeWidth: 1.wMin,
      child: Container(
        height: 156.wMin,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceTertiary,
          borderRadius: BorderRadius.circular(12.wMin),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/svg/public/icon_add_plus.svg",
              width: 28.wMin,
            ),
            SizedBox(height: 2.wMin),
            Text(
              addName,
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextBrand,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageWidget() {
    Widget imageWidget = Container();
    if (fileUrl != null && (fileUrl?.isNotEmpty ?? false)) {
      imageWidget = Image.file(
        File(fileUrl!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (netUrl != null && (netUrl?.isNotEmpty ?? false)) {
      imageWidget = CachedImageWidget(
        netUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(imageRadius ?? 15.wMin),
      child: SizedBox(
        height: imageHeight ?? 138.wMin,
        width: imageWidth ?? 138.wMin,
        child: Stack(
          children: [
            imageWidget,
            Positioned(
              bottom: 0,
              child: Visibility(
                visible: showUpdateImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(imageRadius ?? 12.wMin),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.wMin, sigmaY: 4.wMin),
                    child: Container(
                      height: 30.wMin,
                      width: imageWidth ?? 138.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(imageRadius ?? 12.wMin),
                        color: AppTheme.cBlackAlpha50,
                      ),
                      child: Text(
                        "修改封面",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardAddImageWidget extends StatelessWidget {
  final String? title;
  final String name;
  final String? image;
  final double? imageWidth;
  final double? imageHeight;
  final double? imageRadius;
  final void Function()? onTap;

  const CardAddImageWidget({
    super.key,
    this.title,
    this.name = "添加封面",
    this.onTap,
    this.image,
    this.imageWidth,
    this.imageHeight,
    this.imageRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: title != null,
            child: Container(
              margin: EdgeInsets.only(bottom: 12.wMin),
              child: Text(
                title ?? "",
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          TapScaleWidget(
            onTap: onTap,
            sclae: 1.02,
            child: image != null && image!.trim().isNotEmpty ? buildImageWidget() : buildAddWidget(),
          ),
        ],
      ),
    );
  }

  Widget buildAddWidget() {
    return DottedBorder(
      radius: Radius.circular(12.wMin),
      borderType: BorderType.RRect,
      padding: EdgeInsets.zero,
      color: AppTheme.cBorderSecondary,
      dashPattern: [4.wMin, 2.wMin],
      strokeWidth: 1.wMin,
      child: Container(
        height: 156.wMin,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceTertiary,
          borderRadius: BorderRadius.circular(12.wMin),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/svg/public/icon_add_plus.svg",
              width: 28.wMin,
            ),
            SizedBox(height: 2.wMin),
            Text(
              name,
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextBrand,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(imageRadius ?? 15.wMin),
      child: SizedBox(
        height: imageHeight ?? 138.wMin,
        width: imageWidth ?? 138.wMin,
        child: Stack(
          children: [
            CachedImageWidget(image!),
            Positioned(
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(imageRadius ?? 12.wMin),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.wMin, sigmaY: 4.wMin),
                  child: Container(
                    height: 30.wMin,
                    width: imageWidth ?? 138.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(imageRadius ?? 12.wMin),
                      color: AppTheme.cBlackAlpha50,
                    ),
                    child: Text(
                      "修改封面",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CopyCardAddImageWidget extends StatelessWidget {
  final String? title;
  final String name;
  final String? image;
  final double? imageWidth;
  final double? imageHeight;
  final double? imageRadius;
  final void Function()? onTap;

  const CopyCardAddImageWidget({
    super.key,
    this.title,
    this.name = "添加封面",
    this.onTap,
    this.image,
    this.imageWidth,
    this.imageHeight,
    this.imageRadius,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.02,
      child: image != null && image!.trim().isNotEmpty ? buildImageWidget() : buildAddWidget(),
    );
  }

  Widget buildAddWidget() {
    return DottedBorder(
      radius: Radius.circular(12.wMin),
      borderType: BorderType.RRect,
      padding: EdgeInsets.zero,
      color: AppTheme.cBorderSecondary,
      dashPattern: [4.wMin, 2.wMin],
      strokeWidth: 1.wMin,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceTertiary,
          borderRadius: BorderRadius.circular(12.wMin),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/svg/public/icon_add_plus.svg",
              width: 28.wMin,
            ),
            SizedBox(height: 2.wMin),
            Text(
              name,
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextBrand,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(imageRadius ?? 15.wMin),
      child: SizedBox(
        width: imageWidth ?? 80.wMin,
        height: imageHeight ?? 150.wMin,
        child: Stack(
          children: [
            CachedImageWidget(image!, fit: BoxFit.contain),
            Positioned(
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(imageRadius ?? 12.wMin),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.wMin, sigmaY: 4.wMin),
                  child: Container(
                    height: 30.wMin,
                    width: imageWidth ?? 80.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(imageRadius ?? 12.wMin),
                      color: AppTheme.cBlackAlpha50,
                    ),
                    child: Text(
                      "修改封面",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardSwitchWidget extends StatelessWidget {
  final bool value;
  final double? width;
  final double? height;
  final Color switchActiveColor;
  final Color switchInactiveColor;
  final void Function(bool value)? onChanged;

  const CardSwitchWidget({
    super.key,
    required this.value,
    this.onChanged,
    this.width,
    this.height,
    this.switchActiveColor = AppTheme.cBgBrand,
    this.switchInactiveColor = AppTheme.cBgQuaternary,
  });

  @override
  Widget build(BuildContext context) {
    double w = width ?? 71.wMin;
    double h = height ?? 38.wMin;
    return TapScaleWidget(
      onTap: onChanged == null
          ? null
          : () {
              onChanged?.call(!value);
            },
      sclae: 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: w,
        height: h,
        padding: EdgeInsets.all(3.wMin),
        alignment: !value ? Alignment.centerLeft : Alignment.centerRight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(h + 10),
          color: value ? switchActiveColor : switchInactiveColor,
        ),
        child: Container(
          width: h - 3.wMin,
          height: h - 3.wMin,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class CardTitleSwitchWidget extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final String? subContent;
  final EdgeInsetsGeometry? padding;
  final bool value;
  final Color switchActiveColor;
  final double? switchWidth;
  final double? switchHeight;
  final void Function(bool value)? onChanged;
  final Color backColor;
  final Color borderColor;
  final String? tips;

  const CardTitleSwitchWidget({
    super.key,
    required this.title,
    this.titleStyle,
    required this.value,
    this.switchActiveColor = AppTheme.cBgBrand,
    this.switchWidth,
    this.switchHeight,
    this.onChanged,
    this.subContent,
    this.padding,
    this.tips,
    this.backColor = Colors.transparent,
    this.borderColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: backColor,
        border: Border.all(width: 1.wMin, color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      title,
                      style: titleStyle ??
                          TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Visibility(
                      visible: tips != null,
                      child: TipsIconWidget(
                        tipsText: tips,
                        icon: SvgPicture.asset(
                          "assets/svg/user_center/icon_info.svg",
                          width: 24.wMin,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CardSwitchWidget(
                value: value,
                width: switchWidth,
                height: switchHeight,
                switchActiveColor: switchActiveColor,
                onChanged: onChanged,
              ),
            ],
          ),
          Visibility(
            visible: subContent != null,
            child: Container(
              margin: EdgeInsets.only(top: 6.wMin),
              child: Text(
                subContent ?? "",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardLearningReminderListWidget extends StatelessWidget {
  final String title;
  final List<int> weeks;
  final List<DateTime> list;
  final void Function(int index)? onRemove;
  final void Function()? onAdd;

  const CardLearningReminderListWidget({
    super.key,
    required this.title,
    required this.weeks,
    required this.list,
    this.onRemove,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> weekTextList = DateFormatUtil.getWeekList1();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cBgTertiary,
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 66.wMin,
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                      height: 2,
                    ),
                  ),
                  SizedBox(width: 10.wMin),
                  Expanded(
                    child: Wrap(
                      children: List.generate(weeks.length, (index) {
                        String weekText = "周${weekTextList[weeks[index] - 1]}";
                        if (index != weeks.length - 1) weekText += "、";
                        return Text(
                          weekText,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 10.wMin,
                            color: AppTheme.cTextSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              spacing: 8.wMin,
              children: List.generate(list.length, (index) {
                return ListAnimationWidget(
                  index: index,
                  horizontalOffset: 100.wMin,
                  child: Row(
                    children: [
                      TapScaleWidget(
                        onTap: () {
                          onRemove?.call(index);
                        },
                        child: SvgPicture.asset(
                          "assets/svg/public/icon_remove.svg",
                          width: 24.wMin,
                        ),
                      ),
                      SizedBox(width: 12.wMin),
                      Container(
                        height: 50.wMin,
                        width: 88.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.wMin),
                          color: AppTheme.cWhiteAlpha10,
                        ),
                        child: Text(
                          DateFormatUtil.formatStr(list[index], newPattern: "HH:mm"),
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            SizedBox(height: 6.wMin),
            Visibility(
              visible: onAdd != null,
              child: TapScaleWidget(
                sclae: 1.02,
                onTap: () => onAdd?.call(),
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 8.wMin),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        "assets/svg/public/icon_c_add.svg",
                        width: 24.wMin,
                      ),
                      SizedBox(width: 12.wMin),
                      Text(
                        "添加提醒",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cTextBrand,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardReviewWidget extends StatelessWidget {
  final PreparationPlanTimeSlots? data;
  final int index;
  final bool showLock;
  final bool showOption;
  final void Function(int index)? onRemove;
  final void Function(int index)? onTap;

  const CardReviewWidget({
    super.key,
    required this.index,
    this.data,
    this.onRemove,
    this.onTap,
    this.showLock = false,
    this.showOption = false,
  });

  @override
  Widget build(BuildContext context) {
    if (data == null) return Container();
    DateTime? date = DateFormatUtil.tryParseDate(data?.date ?? "");
    if (date == null) return Container();
    String dateStr = DateFormatUtil.formatStrtoStr(data?.date, locale: Get.locale);

    String timeStr = DateFormatUtil.hsToLocaleTime(data?.hour, data?.minute, locale: Get.locale);

    return TapScaleWidget(
      onTap: onTap == null || showOption || showLock ? null : () => onTap?.call(index),
      sclae: 1.02,
      child: Opacity(
        opacity: showOption ? 0.6 : 1,
        child: CardMinBox2Widget(
          borderColor: Colors.transparent,
          padding: EdgeInsets.zero,
          child: Container(
            padding: EdgeInsets.all(12.wMin),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        "第${index + 1}次复习",
                        maxLines: 1,
                        minFontSize: 4,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: showLock,
                      child: Container(
                        padding: EdgeInsets.all(5.wMin),
                        color: Colors.transparent,
                        child: SvgPicture.asset("assets/svg/public/icon_lock.svg", width: 24.wMin),
                      ),
                    ),
                    Visibility(
                      visible: onRemove != null,
                      child: TapScaleWidget(
                        onTap: () => onRemove?.call(index),
                        sclae: 1.1,
                        child: Container(
                          padding: EdgeInsets.all(5.wMin),
                          color: Colors.transparent,
                          child: SvgPicture.asset("assets/svg/public/icon_clean.svg", width: 24.wMin),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 11.wMin),
                Row(
                  spacing: 10.wMin,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildReviewDateItemDate(dateStr, 65),
                    buildReviewDateItemDate(timeStr, 35),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildReviewDateItemDate(String val, int flex) {
    return Expanded(
      flex: flex,
      child: CardMinBox2Widget(
        padding: EdgeInsets.symmetric(vertical: 8.wMin),
        radius: 6.wMin,
        borderColor: Colors.transparent,
        backColor: AppTheme.cBgQuaternary.color,
        child: Center(
          child: Text(
            val,
            maxLines: 1,
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class CaedFunctionalDescriptionButton extends StatelessWidget {
  /// 功能说明按钮
  final String text;
  final Function()? onTap;

  const CaedFunctionalDescriptionButton({super.key, this.text = "功能说明", this.onTap});

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.03,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999.wMin),
            border: Border.all(width: 1.wMin, color: const Color(0xff7DD3FC)),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.cBgBrand.withValues(alpha: 0.7),
                AppTheme.cBgBrand,
              ],
            )),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30.wMin,
              height: 30.wMin,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppTheme.cStaticWhite,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                "assets/svg/public/icon_play.svg",
                width: 14.wMin,
                height: 14.wMin,
              ),
            ),
            SizedBox(width: 8.wMin),
            Text(
              text,
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cStaticWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardKnowledgeWidget extends StatelessWidget {
  const CardKnowledgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      // onTap: () => controller.currentWordIndex(index),
      sclae: 1.05,
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardKnowledgeImageWidget(),
            SizedBox(height: 8.wMin),
            AutoSizeText(
              "Word",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              wrapWords: false,
              softWrap: false,
              minFontSize: 6,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary,
                letterSpacing: 0.08,
              ),
            ),
            SizedBox(height: 2.wMin),
            AutoSizeText(
              "释义",
              maxLines: 1,
              minFontSize: 6,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary,
                letterSpacing: 0.072,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardKnowledgeImageWidget extends StatelessWidget {
  const CardKnowledgeImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ConfigController configController = Get.find<ConfigController>();
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.wMin),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
          ),
          child: Stack(
            children: [
              Container(
                color: AppTheme.cBlackAlpha10,
              ),
              Positioned(
                left: 4.wMin,
                top: 4.wMin,
                child: StatusTagDifficultyWidget(
                  fontSize: 10.wMin,
                  difficulty: 1,
                  language: configController.userSetting.value.learningLang,
                ),
              ),
              Positioned(
                left: 8.wMin,
                bottom: 8.wMin,
                child: Container(
                  width: 26.wMin,
                  height: 26.wMin,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cBgBrand,
                  ),
                  child: SvgPicture.asset("assets/svg/public/icon_speaker.svg", width: 14.wMin),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
