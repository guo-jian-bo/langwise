import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';

class SearchWidget extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final double? width;
  final double? height;
  final Color? color;
  final Color? borderColor;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final double iconSize;
  final double fontSize;
  final Color? fontColor;

  const SearchWidget({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.width,
    this.height,
    this.color,
    this.borderColor,
    this.onChanged,
    this.onSubmitted,
    this.iconSize = 14,
    this.fontSize = 16,
    this.fontColor,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> with SafeSetStateMixin {
  FocusNode? _defaultFocusNode;

  final TextEditingController _defaultController = TextEditingController();

  bool isFocus = false;

  @override
  void initState() {
    super.initState();
    _defaultFocusNode = widget.focusNode ?? FocusNode();
    _defaultFocusNode?.addListener(() {
      // print("---😆😆hintText:${widget.hintText}, hasFocus: ${(_defaultFocusNode?.hasFocus ?? false)}");
      safeSetState(() {
        isFocus = (_defaultFocusNode?.hasFocus ?? false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        safeSetState(() {
          isFocus = true;
        });
        _defaultFocusNode?.requestFocus();
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        padding: EdgeInsets.only(left: 12.ww, right: 12.ww),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: widget.color ?? const Color(0xff23283D),
          border: Border.all(
            color: isFocus ? AppTheme.cBorderBrand.color : widget.borderColor?? const Color(0xff4B5268),
            width: 1.wMin,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildImage(
              Assets.managerSearch,
              width: widget.iconSize.wMin,
              height: widget.iconSize.wMin,
            ),
            Gaps.getWidth(4.ww),
            Expanded(
                child: TextField(
              controller: widget.controller ?? _defaultController,
              keyboardType: TextInputType.text,
              focusNode: _defaultFocusNode,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                isDense: true,
                // important 用于编辑框对齐
                border: InputBorder.none,
                hintText: widget.hintText ?? '',
                hintStyle: TextStyle(
                  fontSize: widget.fontSize.wMin,
                  height: 1.0,
                  fontWeight: FontWeight.w400,
                  color: (widget.fontColor?? const Color(0xFFACB4C0)).withValues(alpha: 0.6),
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
              style: TextStyle(
                fontSize: widget.fontSize.wMin,
                height: 1.0,
                fontWeight: FontWeight.w400,
                color: (widget.fontColor?? const Color(0xFFACB4C0)),
              ),
              autocorrect: false,
              enableSuggestions: false,
              cursorColor: const Color(0xFFACB4C0),
              onTap: () {
                print('onTap输入框被点击');
                safeSetState(() {
                  isFocus = true;
                });
              },
              onChanged: (value) {
                widget.onChanged?.call(value);
              },
              onSubmitted: (value) {
                safeSetState(() {
                  isFocus = false;
                });
                _defaultFocusNode?.unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
                widget.onSubmitted?.call(value);
              },
              onTapOutside: (event) {
                print('onTapOutside输入框失去焦点');
                safeSetState(() {
                  isFocus = false;
                });
                _defaultFocusNode?.unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _defaultController.dispose();
    _defaultFocusNode?.dispose();
  }
}
