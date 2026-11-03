
import 'package:flutter/material.dart';

class ColorUtils{

  /// 解析颜色,支持16进制和rgba
  static Color? parseColor(String? colorString) {
    if(colorString == null) return null;
    // 去除所有空格并转为小写方便处理
    colorString = colorString.replaceAll(' ', '').toLowerCase();
    
    // 检查是否是16进制颜色
    if (isHexColor(colorString)) {
      return parseHexColor(colorString);
    }
    
    // 检查是否是RGBA颜色
    if (isRgbaColor(colorString)) {
      return rgbaToColor(colorString);
    }
    
    return null;
  }

  /// rgba字符串转Color
  static Color? rgbaToColor(String? rgba) {
    if(rgba == null) return null;
    // 提取 rgba 字符串中的数字部分
    final RegExp regExp = RegExp(r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)');
    final Match? match = regExp.firstMatch(rgba);

    if (match != null) {
      final int r = int.parse(match.group(1)!);
      final int g = int.parse(match.group(2)!);
      final int b = int.parse(match.group(3)!);
      final double opacity = double.parse(match.group(4)!);

      // 返回 Color 对象（注意：Flutter 的 Color 需要 alpha 是 0-255 的整数）
      return Color.fromRGBO(r, g, b, opacity);
    }

    // 如果解析失败，返回默认颜色（如透明）
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
    return hexRegex.hasMatch(str);
  }

  /// 判断是否是rgba颜色
  static bool isRgbaColor(String str) {
    // 匹配 rgba(255,255,255,1) 或 rgba(255, 255, 255, 0.5) 格式
    final rgbaRegex = RegExp(r'^rgba\((\d{1,3}),(\d{1,3}),(\d{1,3}),([01]?\.\d+|\d)\)$');
    return rgbaRegex.hasMatch(str);
  }


}