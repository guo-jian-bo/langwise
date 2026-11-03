
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class MemoryIconWidget extends StatelessWidget {
  /// 记忆的icon
  final double? mSize;
  final double? boxSize;
  const MemoryIconWidget({super.key, this.mSize, this.boxSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: boxSize?? 38.wMin,
      height: boxSize?? 38.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.cBgPrimary.color,
        border: Border.all(
          color: AppTheme.cMemoryPrimary.color,
          width: 3.wMin,
        ),
      ),
      child: SvgPicture.asset(
        "assets/svg/public/icon_memory_m.svg",
        width: mSize?? 20.wMin,
      ),
    );
  }
}