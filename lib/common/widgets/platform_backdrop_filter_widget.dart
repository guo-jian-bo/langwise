import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';

class PlatformBackdropFilterWidget extends StatelessWidget {
  final Widget? child;
  final double sigmaX;
  final double sigmaY;
  final Color backgroundColor;
  final Color? fallbackColor;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final DecorationImage? image;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;
  final double? width;
  final double? height;
  final Clip clipBehavior;

  const PlatformBackdropFilterWidget({
    super.key,
    this.child,
    this.sigmaX = 8,
    this.sigmaY = 8,
    this.backgroundColor = Colors.transparent,
    this.fallbackColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
    this.image,
    this.padding,
    this.margin,
    this.alignment,
    this.constraints,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  });

  static bool get shouldUseBlur => Platform.isIOS || Platform.isMacOS;

  @override
  Widget build(BuildContext context) {
              final Color defaultFallbackColor =
        AppTheme.cStaticBlack.color.withValues(alpha: 0.12);
    final Color resolvedBackgroundColor =
        shouldUseBlur ? backgroundColor : (fallbackColor ?? defaultFallbackColor);
        

    final Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment,
      constraints: constraints,
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
        gradient: gradient,
        image: image,
      ),
      child: child,
    );

    if (!shouldUseBlur || (sigmaX <= 0 && sigmaY <= 0)) {
      return content;
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
          child: content,
        ),
      );
    }

    return ClipRect(
      clipBehavior: clipBehavior,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: content,
      ),
    );
  }
}
