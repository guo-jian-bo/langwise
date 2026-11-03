import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';

enum WordInflectionInfoTagTone {
  brand,
  normal,
}

class WordInflectionInfoTagWidget extends StatelessWidget {
  final String text;
  final WordInflectionInfoTagTone tone;
  final Color? textColor;
  final Color? bgColor;
  final Color? borderColor;

  const WordInflectionInfoTagWidget(
    this.text, {
    super.key,
    this.tone = WordInflectionInfoTagTone.normal,
    this.textColor,
    this.bgColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final _WordInflectionInfoTagColors colors = _getColors();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        color: colors.bgColor,
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(
          color: colors.borderColor,
          width: 1.wMin,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w400,
          color: colors.textColor,
        ),
      ),
    );
  }

  _WordInflectionInfoTagColors _getColors() {
    if (textColor != null || bgColor != null || borderColor != null) {
      return _WordInflectionInfoTagColors(
        textColor: textColor ?? AppTheme.cTextSecondary.color,
        bgColor: bgColor ?? AppTheme.cSurfaceTertiary.color,
        borderColor: borderColor ?? AppTheme.cBorderThin.color,
      );
    }

    if (tone == WordInflectionInfoTagTone.brand) {
      return _WordInflectionInfoTagColors(
        textColor: AppTheme.cSurfaceBrand.color,
        bgColor: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.12),
        borderColor: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
      );
    }

    return _WordInflectionInfoTagColors(
      textColor: AppTheme.cTextPrimary,
      bgColor: AppTheme.cSurfaceTranslucentElevated,
      borderColor: AppTheme.cBorderTranslucentSubtle,
    );
  }
}

class _WordInflectionInfoTagColors {
  final Color textColor;
  final Color bgColor;
  final Color borderColor;

  const _WordInflectionInfoTagColors({
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });
}
