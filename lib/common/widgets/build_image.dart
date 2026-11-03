import 'dart:io';
import 'package:flutter/material.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/theme/theme_utils.dart';

Widget buildImage(String name, {VoidCallback? callback, double? width, double? height, int repeatCount = 0, ImageRepeat repeat = ImageRepeat.noRepeat, fit = BoxFit.fill}) {
  return Image.asset(
    name,
    width: width,
    repeat: repeat,
    height: height,
    fit: fit,
  );
}

Widget buildFileImage(
  String path, {
  double? width,
  double? height,
  int repeatCount = 0,
  FilterQuality filterQuality = FilterQuality.medium,
  ImageRepeat repeat = ImageRepeat.noRepeat,
  ImageErrorWidgetBuilder? errorBuilder,
  fit = BoxFit.fill,
  int? cacheWidth,
  int? cacheHeight,
}) {
  return Image.file(
    File(path),
    width: width,
    repeat: repeat,
    height: height,
    fit: fit,
    filterQuality: filterQuality,
    errorBuilder: errorBuilder,
    cacheWidth: cacheWidth,
    cacheHeight: cacheHeight,
  );
}

Widget buildEmptyWidget({double? width, double? height, int repeatCount = 0, ImageRepeat repeat = ImageRepeat.noRepeat, fit = BoxFit.contain}) {
  return buildImage(Assets.logoPlaceholderBlank, width: width, height: height, fit: fit, repeat: repeat);
}

Widget buildLoadingWidget({double? width, double? height, int repeatCount = 0, ImageRepeat repeat = ImageRepeat.noRepeat, fit = BoxFit.contain}) {
  return buildImage(Assets.logoPlaceholderBlank, width: width, height: height, fit: fit, repeat: repeat);
}

Widget buildNetworkWidget({double? width, double? height, int repeatCount = 0, ImageRepeat repeat = ImageRepeat.noRepeat, fit = BoxFit.contain}) {
  if (ThemeUtils.isCurrentTheme(AppThemeKey.light.value)) {
    return buildImage(Assets.logoPlaceholderLight, width: width, height: height, fit: fit, repeat: repeat);
  }
  return buildImage(Assets.logoPlaceholderDark, width: width , height: height, fit: fit, repeat: repeat);
}
