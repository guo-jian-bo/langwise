import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

class WritHeadBoxWidget extends StatefulWidget {
  final String type;
  final String title;
  final String content;
  final String? placeholder;
  final TextStyle? textStyle;
  final bool editable;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(String text)? onChanged;
  final bool highlighted;
  final VoidCallback? onTap;

  /// 首尾格式
  const WritHeadBoxWidget({
    super.key,
    required this.type,
    required this.title,
    required this.content,
    this.placeholder,
    this.textStyle,
    this.editable = false,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.highlighted = false,
    this.onTap,
  });

  @override
  State<WritHeadBoxWidget> createState() => _WritHeadBoxWidgetState();
}

class _WritHeadBoxWidgetState extends State<WritHeadBoxWidget> {
  @override
  Widget build(BuildContext context) {
    final borderColor = const Color(0xffCCBCB8).withValues(alpha: widget.highlighted ? 1 : 0.45);
    final backgroundColor = const Color(0xffCCBCB8).withValues(alpha: widget.highlighted ? 0.4 : 0.12);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: widget.highlighted ? 1.3.wMin : 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.type,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                color: const Color(0xffF97316).withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 8.wMin),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ),
            widget.editable ? _buildInputWidget() : _buildTextWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextWidget() {
    return Container(
      margin: EdgeInsets.only(top: 4.wMin),
      child: Text(
        widget.content,
        style: widget.textStyle ??
            TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w400,
              color: Colors.black.withValues(alpha: 0.75),
            ),
      ),
    );
  }

  Widget _buildInputWidget() {
    return Container(
      margin: EdgeInsets.only(top: 8.wMin),
      child: IntrinsicWidth(
        child: Container(
          constraints: BoxConstraints(minWidth: 200.wMin),
          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: widget.placeholder ?? "输入内容",
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
