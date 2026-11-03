import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

class EditorActionTagWidget extends StatelessWidget {
  const EditorActionTagWidget({
    super.key,
    required this.text,
    required this.color,
    required this.onTap,
  });

  final String text;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(),
        padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 12.wMin),
        child: Text(
          text,
          style: TextStyle(fontSize: 16.wMin, color: color),
        ),
      ),
    );
  }
}
