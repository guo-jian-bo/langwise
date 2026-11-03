import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ManageContentInputWidget extends StatefulWidget {
  final String? title;
  final String? hintText;

  // 是否必填
  final bool required;

  /// 焦点顺序
  final double focusOrder;
  final bool error;
  final bool readOnly;
  final bool enabled;
  final TextEditingController? controller;
  final Widget? child;
  final Widget? prefixWidget;
  final double? width;
  final double? height;
  final int? maxLines;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? padding;
  final void Function()? onTap;
  final void Function(String text)? onSubmitted;
  final void Function(String text)? onChanged;

  const ManageContentInputWidget({
    super.key,
    this.title,
    this.hintText,
    this.required = false,
    this.controller,
    this.onTap,
    this.onSubmitted,
    this.onChanged,
    this.focusOrder = 0,
    this.readOnly = false,
    this.enabled = true,
    this.child,
    this.prefixWidget,
    this.width,
    this.height,
    this.maxLines,
    this.textInputAction = TextInputAction.done,
    this.inputFormatters,
    this.padding,
    this.error = false,
  });

  @override
  State<ManageContentInputWidget> createState() => _ManageContentInputWidgetState();
}

class _ManageContentInputWidgetState extends State<ManageContentInputWidget> with SafeSetStateMixin {
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
                      color: const Color(0xffEBEEF3),
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
            padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 12.ww),
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
                    child: AutoSizeTextField(
                      controller: widget.controller,
                      focusNode: focusNode,
                      enabled: widget.enabled,
                      maxLines: widget.maxLines,
                      // 使用固定值
                      minFontSize: 16,
                      // 确保步进粒度为整数
                      stepGranularity: 1.0,
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: const Color(0xffEDF0F4),
                        fontWeight: FontWeight.w400,
                      ),
                      readOnly: _readOnly,
                      // 使用 Enter 键提交数据
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: widget.textInputAction,
                      cursorColor: Colors.white,
                      inputFormatters: widget.inputFormatters,
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
                          color: const Color.fromRGBO(255, 255, 255, 0.4),
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
  void didUpdateWidget(covariant ManageContentInputWidget oldWidget) {
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
