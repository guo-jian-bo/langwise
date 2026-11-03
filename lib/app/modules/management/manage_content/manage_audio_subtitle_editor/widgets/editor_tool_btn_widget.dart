import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../../../theme/theme.dart';

class EditorToolBtnWidget extends StatelessWidget {
  const EditorToolBtnWidget({
    super.key,
    required this.text,
    required this.onTap,
    this.color,
  });

  final String text;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.wMin),
          border: Border.all(
            color: color ?? AppTheme.cBorderSecondary,
            width: 0.4.wMin,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.wMin,
            color: color ?? AppTheme.cTextPrimary,
          ),
        ),
      ),
    );
  }
}
