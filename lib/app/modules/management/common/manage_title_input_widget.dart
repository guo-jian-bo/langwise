import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ManageTitleInputWidget extends StatefulWidget {
  final String? title;
  final Color? titleColor;
  final String? hintText;
  final Color? hintTextColor;

  // 是否必填
  final bool required;

  /// 焦点顺序
  final double focusOrder;
  final bool error;
  final bool readOnly;
  final bool enabled;
  final Color textColor;
  final TextEditingController? controller;
  final Widget? child;
  final Widget? prefixWidget;
  final double? width;
  final double? height;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final EdgeInsets? padding;
  final void Function()? onTap;
  final void Function(String text)? onSubmitted;
  final void Function(String text)? onChanged;

  const ManageTitleInputWidget({
    super.key,
    this.title,
    this.titleColor,
    this.hintText,
    this.hintTextColor,
    this.required = false,
    this.controller,
    this.onTap,
    this.onSubmitted,
    this.onChanged,
    this.focusOrder = 0,
    this.readOnly = false,
    this.enabled = true,
    this.textColor = const Color(0xffEDF0F4),
    this.child,
    this.prefixWidget,
    this.width,
    this.height,
    this.maxLines,
    this.maxLength,
    this.textInputAction = TextInputAction.done,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.inputFormatters,
    this.padding,
    this.error = false,
  });

  @override
  State<ManageTitleInputWidget> createState() => _ManageTitleInputWidgetState();
}

class _ManageTitleInputWidgetState extends State<ManageTitleInputWidget> with SafeSetStateMixin {
  final FocusNode focusNode = FocusNode();
  String inputText = "";
  bool isFocus = false;

  bool _readOnly = false, _error = false;

  @override
  void initState() {
    super.initState();
    _readOnly = widget.readOnly;
    _error = widget.error;
    focusNode.addListener(() {
      if (_readOnly) return;
      safeSetState(() {
        isFocus = focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: widget.title != null && widget.title!.trim().isNotEmpty,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.wh),
            child: Text.rich(
              TextSpan(
                children: [
                  // 红色星号
                  if (widget.required)
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.wMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  TextSpan(
                    text: widget.title ?? "",
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: widget.titleColor?? const Color(0xffEBEEF3),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: OptimizeUtils.noneThrottle(() {
            print('点击了');
            widget.onTap?.call();
            if (_readOnly) return;
            focusNode.requestFocus();
          }, 100),
          child: AnimatedContainer(
            width: widget.width,
            height: widget.height ?? (50.wh),
            duration: const Duration(milliseconds: 100),
            padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 12.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.wMin),
              color: Colors.transparent,
              border: Border.all(
                width: 1.wMin,
                color: _error ? const Color(0xffFF9262) : (isFocus ? const Color(0xff2388FF) : const Color(0xff4B5268)),
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                Visibility(
                  visible: widget.prefixWidget != null,
                  child: widget.prefixWidget ?? Container(),
                ),
                Expanded(
                  child: FocusTraversalOrder(
                    order: NumericFocusOrder(widget.focusOrder),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: focusNode,
                      enabled: widget.enabled,
                      maxLines: widget.maxLines,
                      maxLength: widget.maxLength,
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: widget.textColor,
                        fontWeight: FontWeight.w400,
                      ),
                      readOnly: _readOnly,
                      textAlignVertical: TextAlignVertical.center,
                      textAlign: widget.textAlign,
                      textInputAction: widget.textInputAction,
                      cursorColor: Colors.blue,
                      inputFormatters: widget.inputFormatters,
                      keyboardType: widget.keyboardType,
                      decoration: InputDecoration(
                        isDense: true,
                        counterText: "",
                        hintText: widget.hintText ?? '',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 16.wMin,
                          height: 1.0,
                          fontWeight: FontWeight.w400,
                          color: widget.hintTextColor?? const Color.fromRGBO(255, 255, 255, 0.4),
                          textBaseline: TextBaseline.alphabetic,
                        ),
                      ),
                      onTap: () {
                        widget.onTap?.call();
                      },
                      onChanged: (value) {
                        inputText = value;
                        widget.onChanged?.call(value);
                      },
                      onSubmitted: widget.onSubmitted,
                      onTapOutside: (event) {
                        print('onTapOutside输入框失去焦点');
                        focusNode.unfocus();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                  ),
                ),
                if (widget.child != null) widget.child!
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  void didUpdateWidget(covariant ManageTitleInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.readOnly != widget.readOnly) {
      _readOnly = widget.readOnly;
    }

    if (oldWidget.error != widget.error) {
      _error = widget.error;
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}

class ManageTitleInput1Widget extends StatefulWidget {
  final String? title;
  final String? subTitle;
  final String? hintText;
  final Color inputFontColor;

  /// 焦点顺序
  final double focusOrder;
  final bool readOnly;
  final double tapSclae;
  final bool? enabled;
  final TextEditingController? controller;
  final Widget? child;
  final Widget? prefixWidget;
  final double? height;
  final List<TextInputFormatter>? inputFormatters;
  final bool showDelIcon;
  final bool error;
  final void Function()? onDel;
  final void Function()? onTap;
  final void Function(String text)? onSubmitted;
  final void Function(String text)? onChanged;

  const ManageTitleInput1Widget({
    super.key,
    this.title,
    this.hintText,
    this.controller,
    this.onDel,
    this.onTap,
    this.onSubmitted,
    this.onChanged,
    this.focusOrder = 0,
    this.enabled,
    this.readOnly = false,
    this.showDelIcon = false,
    this.error = false,
    this.child,
    this.prefixWidget,
    this.height,
    this.inputFormatters,
    this.subTitle,
    this.inputFontColor = const Color(0xffEBEFF5),
    this.tapSclae = 1.0,
  });

  @override
  State<ManageTitleInput1Widget> createState() => _ManageTitleInput1WidgetState();
}

class _ManageTitleInput1WidgetState extends State<ManageTitleInput1Widget> with SafeSetStateMixin {
  final FocusNode focusNode = FocusNode();
  bool isFocus = false;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (widget.readOnly) return;
      safeSetState(() {
        isFocus = focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: widget.title != null,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.wMin),
            child: Text(
              widget.title ?? "",
              style: TextStyle(
                fontSize: 14.wMin,
                color: const Color(0xffEBEEF3),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        TapScaleWidget(
          sclae: widget.tapSclae,
          onTap: widget.onTap == null
              ? null
              : OptimizeUtils.noneThrottle(() {
                  widget.onTap?.call();
                  if (widget.readOnly) return;
                  if (!(widget.enabled ?? true)) return;
                  focusNode.requestFocus();
                }, 100),
          child: AnimatedContainer(
            height: widget.height ?? (60.wMin),
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.symmetric(vertical: 4.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.wMin),
              color: Colors.transparent,
              border: Border.all(
                width: 1.wMin,
                color: widget.error
                    ? const Color(0xffFF9262)
                    : (isFocus ? const Color(0xff2388FF) : const Color(0xff4B5268)),
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                Visibility(
                  visible: widget.prefixWidget != null,
                  child: widget.prefixWidget ?? Container(),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Visibility(
                            visible: widget.subTitle != null,
                            child: Container(
                              margin: EdgeInsets.only(left: 12.wMin),
                              child: Text(
                                widget.subTitle ?? "",
                                style: TextStyle(
                                  fontSize: 14.wMin,
                                  color: const Color(0xffBAC0CC),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: widget.showDelIcon,
                            child: TapScaleWidget(
                              onTap: widget.onDel,
                              child: Container(
                                margin: EdgeInsets.only(right: 5.wMin),
                                color: Colors.transparent,
                                child: SvgPicture.asset(
                                  Assets.manageIconClose,
                                  width: 16.wMin,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: FocusTraversalOrder(
                          order: NumericFocusOrder(widget.focusOrder),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                            child: IgnorePointer(
                              ignoring: !(widget.enabled ?? true),
                              child: TextField(
                                controller: widget.controller,
                                focusNode: focusNode,
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  color: widget.inputFontColor,
                                  fontWeight: FontWeight.w400,
                                ),
                                enabled: widget.enabled,
                                readOnly: widget.readOnly,
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.done,
                                cursorColor: Colors.white,
                                inputFormatters: widget.inputFormatters,
                                decoration: InputDecoration(
                                  isDense: true,
                                  counterText: "",
                                  hintText: widget.hintText ?? '',
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintStyle: TextStyle(
                                    fontSize: 16.wMin,
                                    height: 1.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color.fromRGBO(255, 255, 255, 0.4),
                                    textBaseline: TextBaseline.alphabetic,
                                  ),
                                ),
                                onTap: () {
                                  widget.onTap?.call();
                                },
                                onChanged: (value) {
                                  widget.onChanged?.call(value);
                                },
                                onSubmitted: widget.onSubmitted,
                                onTapOutside: (event) {
                                  print('onTapOutside输入框失去焦点');
                                  focusNode.unfocus();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.child != null) widget.child!
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}
