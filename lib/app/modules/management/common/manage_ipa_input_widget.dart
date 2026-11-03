import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 音标输入组件
/// 用于显示和编辑IPA（国际音标）

class ManageIPAInputWidget extends StatefulWidget {
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
  final TextAlign textAlign;
  final void Function()? onTap;
  final void Function(String text)? onSubmitted;
  final void Function(String text)? onChanged;

  const ManageIPAInputWidget({
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
    this.textAlign = TextAlign.end,
    this.error = false,
  });

  @override
  State<ManageIPAInputWidget> createState() => _ManageIPAInputWidgetState();
}

class _ManageIPAInputWidgetState extends State<ManageIPAInputWidget> with SafeSetStateMixin {
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
    return GestureDetector(
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
          padding: EdgeInsets.symmetric(horizontal: 12.ww),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.wMin),
            color: Colors.transparent,
            border: Border.all(
              width: 1.wMin,
              color:
                  _error ? const Color(0xffFF9262) : (isFocus ? const Color(0xff2388FF) : const Color(0xff4B5268)),
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title ?? "",
                style: TextStyle(
                    fontSize: 16.wMin,
                    color: const Color.fromRGBO(255, 255, 255, 0.4),
                    fontWeight: FontWeight.w400,
                    height: 1.0),
              ),
              Expanded(
                child: FocusTraversalOrder(
                  order: NumericFocusOrder(widget.focusOrder),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: focusNode,
                    enabled: widget.enabled,
                    maxLines: widget.maxLines,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: const Color(0xffEDF0F4),
                      fontWeight: FontWeight.w400,
                    ),
                    readOnly: _readOnly,
                    textAlign: widget.textAlign,
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
            ],
          ),
        ));
  }

  @override
  void didUpdateWidget(covariant ManageIPAInputWidget oldWidget) {
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
