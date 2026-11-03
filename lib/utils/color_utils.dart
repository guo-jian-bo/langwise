
import 'package:flutter/material.dart';

class ColorUtils{

  /// 解析颜色,支持16进制、rgb和rgba
  static Color? parseColor(String? colorString) {
    if(colorString == null) return null;
    // 去除所有空格并转为小写方便处理
    colorString = colorString.replaceAll(' ', '').toLowerCase();
    
    // 检查是否是16进制颜色
    if (isHexColor(colorString)) {
      return parseHexColor(colorString);
    }
    
    // 检查是否是 rgb/rgba 颜色
    if (isRgbaColor(colorString)) {
      return rgbaToColor(colorString);
    }

    // 检查是否是RGB颜色
    if (isRgbColor(colorString)) {
      return rgbToColor(colorString);
    }

    return null;
  }

  /// rgb/rgba 字符串转 Color
  static Color? rgbaToColor(String? rgba) {
    if(rgba == null) return null;
    // 先尝试匹配 rgba(r,g,b,a)
    final RegExp rgbaRegExp = RegExp(r'^rgba\((\d+),(\d+),(\d+),([\d.]+)\)$');
    final Match? rgbaMatch = rgbaRegExp.firstMatch(rgba);
    if (rgbaMatch != null) {
      final int r = int.parse(rgbaMatch.group(1)!);
      final int g = int.parse(rgbaMatch.group(2)!);
      final int b = int.parse(rgbaMatch.group(3)!);
      final double opacity = double.parse(rgbaMatch.group(4)!);
      return Color.fromRGBO(r, g, b, opacity);
    }

    // 再尝试匹配 rgb(r,g,b)
    final RegExp rgbRegExp = RegExp(r'^rgb\((\d+),(\d+),(\d+)\)$');
    final Match? rgbMatch = rgbRegExp.firstMatch(rgba);
    if (rgbMatch != null) {
      final int r = int.parse(rgbMatch.group(1)!);
      final int g = int.parse(rgbMatch.group(2)!);
      final int b = int.parse(rgbMatch.group(3)!);
      return Color.fromRGBO(r, g, b, 1);
    }

    // 如果解析失败，返回默认颜色（如透明）
    return null;
  }

  /// rgb字符串转Color
  static Color? rgbToColor(String? rgb) {
    if (rgb == null) return null;
    final RegExp regExp = RegExp(r'rgb\((\d+),\s*(\d+),\s*(\d+)\)');
    final Match? match = regExp.firstMatch(rgb);

    if (match != null) {
      final int r = int.parse(match.group(1)!);
      final int g = int.parse(match.group(2)!);
      final int b = int.parse(match.group(3)!);
      return Color.fromRGBO(r, g, b, 1);
    }

    return null;
  }



  /// 16进制颜色转Color
  static Color? parseHexColor(String hex) {
    hex = hex.replaceFirst('#', '');
    
    // 处理缩写格式 #rgb → #rrggbb
    if (hex.length == 3) {
      hex = hex.split('').map((c) => c + c).join();
    }
    
    // 处理8位带透明度的格式 #aarrggbb
    if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    
    // 默认6位格式，添加完全不透明
    if (hex.length == 6) {
      return Color(int.parse('ff$hex', radix: 16));
    }
    
    return null;
  }

  /// 判断是否是16进制颜色
  static bool isHexColor(String str) {
    // 匹配 #rgb、#rrggbb、#argb 或 #aarrggbb 格式
    final hexRegex = RegExp(r'^#?([0-9a-f]{3}|[0-9a-f]{6}|[0-9a-f]{8})$');
    return hexRegex.hasMatch(str.toLowerCase());
  }

  /// 判断是否是 rgb/rgba 颜色
  static bool isRgbaColor(String str) {
    // 匹配 rgb(255,255,255) 和 rgba(255,255,255,0.5) 格式
    final rgbaRegex = RegExp(r'^rgba\((\d{1,3}),(\d{1,3}),(\d{1,3}),([01]?\.\d+|\d)\)$');
    final rgbRegex = RegExp(r'^rgb\((\d{1,3}),(\d{1,3}),(\d{1,3})\)$');
    return rgbaRegex.hasMatch(str) || rgbRegex.hasMatch(str);
  }

  /// 判断是否是rgb颜色
  static bool isRgbColor(String str) {
    final rgbRegex = RegExp(r'^rgb\((\d{1,3}),(\d{1,3}),(\d{1,3})\)$');
    return rgbRegex.hasMatch(str);
  }


}
