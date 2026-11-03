import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

class EditorSidebarBtnWidget extends StatelessWidget {
  const EditorSidebarBtnWidget({
    super.key,
    required this.text,
    required this.onTap,
    required this.color,
    this.width = -1,
  });

  final String text;
  final VoidCallback onTap;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    final double resolvedWidth = width > 0 ? width : 120.wMin;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: resolvedWidth,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10.wMin),
          border: Border.all(color: color, width: 1.0),
        ),
        child: Text(
          text,
          style: TextStyle(color: color, fontSize: 16.wMin),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
