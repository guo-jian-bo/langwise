
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';

class ManageTagFS14Widget extends StatelessWidget {
  final String? tag;
  final Color bgColor;
  final Color fontColor;
  const ManageTagFS14Widget({
    super.key, 
    this.tag,
    this.bgColor = AppTheme.cSurfaceQuaternary,
    this.fontColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    if(tag == null){
      return const SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: bgColor,
      ),
      child: SelectableText(
        tag ?? '',
        style: TextStyle(
          fontSize: 14.wMin,
          color: fontColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class ManageTagFS16Widget extends StatelessWidget {
  final String? tag;
  final Color? bgColor;
  final Color fontColor;
  final double? borderRadius;
  const ManageTagFS16Widget({
    super.key, 
    this.tag,
    this.bgColor = AppTheme.cSurfaceQuaternary,
    this.fontColor = Colors.white,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if(tag == null){
      return const SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 4.wMin),
        color: bgColor,
      ),
      child: SelectableText(
        tag ?? '',
        style: TextStyle(
          fontSize: 16.wMin,
          color: fontColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

