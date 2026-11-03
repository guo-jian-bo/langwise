import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../common/entities/entities.dart';
import '../theme/theme.dart';
import '../theme/theme_utils.dart';
import 'color_utils.dart';

/// 辅助记录类型，用于保存方向信息
typedef _DirectionInfo = ({Alignment begin, Alignment end, bool isDirectionKeyword});

class StyleUtils {
  /// 获取当前主题的文字
  static ThemeTextStyleEntity? getCurrentThemeText(List<ThemeTextStyleEntity?>? styles) {
    if (styles == null) return null;
    for (int i = 0; i < styles.length; i++) {
      if (styles[i] == null) continue;
      String? theme = styles[i]!.theme;
      if (theme == null) continue;
      bool isCurrent = ThemeUtils.isCurrentTheme(theme);
      if (isCurrent) {
        return styles[i];
      }
    }
    return null;
  }

  /// 获取Text
  static Text? getText(ThemeTextEntity? text) {
    if (text == null) return null;
    if (text.text == null) return null;

    ThemeTextStyleEntity? themeText = getCurrentThemeText(text.style);
    Color? color = ColorUtils.parseColor(themeText?.color);

    return Text(
      text.text ?? "",
      style: TextStyle(
        color: color,
        fontSize: (themeText?.fontsize?.toDouble())?.wMin,
        fontWeight: getFontWeight(themeText?.weight),
        fontStyle: getFontStyle(themeText?.italic),
      ),
    );
  }

  static TextStyle? getTextStyle(
    List<ThemeTextStyleEntity?>? styles, {
    Color defaultColor = AppTheme.cStaticWhite,
    double defaultSize = 20,
    FontWeight defaultWeight = FontWeight.w400,
  }) {
    if (styles == null) {
      return TextStyle(
        color: defaultColor,
        fontSize: defaultSize.wMin,
        fontWeight: defaultWeight,
      );
    }

    ThemeTextStyleEntity? themeText = getCurrentThemeText(styles);

    Color fontColor = ColorUtils.parseColor(themeText?.color) ?? defaultColor;
    int? fontSize = themeText?.fontsize;
    bool isItalic = themeText?.italic ?? false;
    FontWeight fontWeight = StyleUtils.getFontWeight(themeText?.weight, defaultWeight: defaultWeight);

    return TextStyle(
      color: fontColor,
      fontSize: (fontSize?.toDouble() ?? defaultSize).wMin,
      fontWeight: fontWeight,
      fontStyle: getFontStyle(isItalic),
    );
  }


  static TextStyle getMarkdownStyle(
    List<ThemeTextStyleEntity?>? styles, {
    Color defaultColor = AppTheme.cStaticWhite,
    double defaultSize = 20,
    FontWeight defaultWeight = FontWeight.w400,
    bool textBackgroundColor = true,
  }) {
    if (styles == null) {
      return TextStyle(
        color: defaultColor,
        fontSize: defaultSize.wMin,
        fontWeight: defaultWeight,
      );
    }

    ThemeTextStyleEntity? themeText = getCurrentThemeText(styles);

    Color fontColor = ColorUtils.parseColor(themeText?.color) ?? defaultColor;
    int? fontSize = themeText?.fontsize;
    bool isItalic = themeText?.italic ?? false;
    FontWeight fontWeight = StyleUtils.getFontWeight(themeText?.weight, defaultWeight: defaultWeight);

    return TextStyle(
      color: fontColor,
      fontSize: (fontSize?.toDouble() ?? defaultSize).wMin,
      fontWeight: fontWeight,
      fontStyle: getFontStyle(isItalic),
      letterSpacing: themeText?.letterSpacing,
      height: (themeText?.lineHeight??0) / (fontSize?.toDouble() ?? defaultSize),
      backgroundColor: textBackgroundColor ? ColorUtils.parseColor(themeText?.backgroundColor) : null,
      decoration: themeText?.underline == true ? TextDecoration.underline : null,
      decorationColor: ColorUtils.parseColor(themeText?.color),
    );
  }

  /// 获取文字的权重
  static FontWeight getFontWeight(int? weight, {FontWeight defaultWeight = FontWeight.w400}) {
    if (weight == null) return defaultWeight;
    switch (weight) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return defaultWeight;
    }
  }

  /// 获取字体是否是斜体
  static FontStyle? getFontStyle(bool? italic) {
    if (italic == null) return null;
    return italic ? FontStyle.italic : null;
  }

  /// 获取按钮样式
  // static Widget getHelpButton(HomeCardEntityItemsButton? data, {String? helpVideoUrl}) {
  //   if(data == null) return Container();
  //   String? pattern = data.pattern;
  //   ThemeColorEntity? colors = getCurrentThemeColors(data.color);
  //   Color? color = ColorUtils.parseColor(colors?.color);
  //   Color? borderColor = ColorUtils.parseColor(colors?.borderColor);
  //   BoxShape shape = BoxShape.rectangle;
  //   if(pattern == "circularArrow"){
  //     shape = BoxShape.circle;
  //   }else{
  //     shape = BoxShape.rectangle;
  //   }

  //   return HelpIVideoIconWidget(
  //     bgColor: color ?? AppTheme.cBgBrand.color,
  //     shape: shape,
  //     borderColor: borderColor,
  //     helpVideoUrl: helpVideoUrl,
  //   );
  // }

  /// 获取当前主题的颜色
  static ThemeColorEntity? getCurrentThemeColors(List<ThemeColorEntity?>? colors) {
    if (colors == null) return null;
    for (int i = 0; i < colors.length; i++) {
      if (colors[i] == null) continue;
      String? theme = colors[i]!.theme;
      if (theme == null) continue;
      bool isCurrent = ThemeUtils.isCurrentTheme(theme);
      if (isCurrent) {
        return colors[i];
      }
    }
    return null;
  }

  /// 获取当前主题的图片
  static ThemeImageEntity? getCurrentThemeImage(List<ThemeImageEntity?>? images) {
    if (images == null) return null;
    for (int i = 0; i < images.length; i++) {
      if (images[i] == null) continue;
      String? theme = images[i]!.theme;
      if (theme == null) continue;
      bool isCurrent = ThemeUtils.isCurrentTheme(theme);
      if (isCurrent) {
        return images[i];
      }
    }
    return null;
  }

  /// 解析 CSS linear-gradient 字符串并返回一个 Flutter LinearGradient 对象。
  ///
  /// 这个函数具有很高的健壮性，支持：
  /// - 角度值 (e.g., "180deg") 和关键字 (e.g., "to right")。
  /// - 多种颜色格式: rgba, rgb, hex (3, 4, 6, 8位), 以及常见的 CSS 颜色名。
  /// - 带有百分比的颜色断点 (e.g., "red 50%")。
  /// - 不带颜色断点的情况 (e.g., "red, blue")，此时颜色会均匀分布。
  ///
  /// @param cssGradient 要解析的 CSS 字符串。
  /// @return 一个包含 LinearGradient 和解析消息的记录，如果解析失败则返回 null。
  static LinearGradient? parseCssLinearGradient(String? cssGradient) {
    if (cssGradient == null) return null;
    // 预处理：转为小写并去除首尾空格，方便后续处理
    final String input = cssGradient.trim().toLowerCase();

    // 1. 基本格式验证与内容提取
    final regex = RegExp(r'linear-gradient\((.*)\)');
    final match = regex.firstMatch(input);
    if (match == null) {
      debugPrint("错误: 无效的 linear-gradient 格式。");
      return null;
    }

    // 提取括号内的核心内容
    final String content = match.group(1)!;

    // 2. 分割内容 (方向和颜色断点)
    // 使用这个正则表达式可以按逗号分割，同时忽略 rgba() 等函数内的逗号
    final List<String> parts = content.split(RegExp(r',\s*(?![^()]*\))'));
    if (parts.isEmpty) {
      debugPrint("错误: linear-gradient 内部没有内容。");
      return null;
    }

    // 3. 解析方向 (列表的第一个元素)
    String firstPart = parts.first.trim();
    _DirectionInfo directionInfo = _parseDirection(firstPart);

    // 确定颜色断点部分
    final List<String> colorStopParts = directionInfo.isDirectionKeyword
        ? parts.sublist(1) // 如果第一个元素是方向，则从第二个元素开始都是颜色
        : parts; // 如果第一个元素不是方向，则所有元素都是颜色

    if (colorStopParts.isEmpty) {
      debugPrint("错误: 未找到任何颜色断点。");
      return null;
    }

    // 4. 解析颜色和色标
    final List<Color> colors = [];
    final List<double> stops = [];
    bool hasStops = false; // 标记是否显式定义了任何色标

    // 用于从字符串中分离颜色和可选的百分比位置
    final colorStopRegex = RegExp(r'^(.*?)\s+([\d.]+)%$');

    for (final part in colorStopParts) {
      final String currentPart = part.trim();
      final colorStopMatch = colorStopRegex.firstMatch(currentPart);

      Color? color;
      double? stop;

      if (colorStopMatch != null) {
        // 情况1: 包含颜色和百分比, e.g., "red 50%"
        final String colorString = colorStopMatch.group(1)!.trim();
        final String stopString = colorStopMatch.group(2)!.trim();

        color = ColorUtils.parseColor(colorString);
        stop = double.tryParse(stopString);
        if (stop != null) {
          stops.add(stop / 100.0); // 将百分比转换为 0.0-1.0 范围
          hasStops = true;
        }
      } else {
        // 情况2: 只包含颜色, e.g., "blue"
        color = ColorUtils.parseColor(currentPart);
        // 在这种情况下，我们不向 stops 列表添加任何内容
      }

      if (color != null) {
        colors.add(color);
      } else {
        debugPrint("警告: 无法解析颜色 '$currentPart'。已跳过。");
      }
    }

    if (colors.isEmpty) {
      debugPrint("错误: 没有解析出任何有效的颜色。");
      return null;
    }

    // 5. 构建并返回 Flutter LinearGradient
    // 如果 CSS 中没有提供任何 stop 值 (hasStops 为 false)，
    // 我们将 stops 参数设为 null，Flutter 会自动均匀分布颜色。
    // 这完美地模拟了 CSS 的默认行为。
    final LinearGradient gradient = LinearGradient(
      begin: directionInfo.begin,
      end: directionInfo.end,
      colors: colors,
      stops: hasStops ? stops : null,
    );

    return gradient;
  }

  /// 解析方向字符串 (角度或关键字)
  static _DirectionInfo _parseDirection(String directionStr) {
    // 默认值: 'to bottom', 等同于 '180deg'
    Alignment begin = Alignment.topCenter;
    Alignment end = Alignment.bottomCenter;
    bool isDirectionKeyword = false;

    if (directionStr.contains('deg')) {
      isDirectionKeyword = true;
      final angleStr = directionStr.replaceAll('deg', '').trim();
      final angle = double.tryParse(angleStr) ?? 180.0;

      // 将 CSS 角度转换为 Flutter 的 Alignment 坐标
      // CSS 中 0deg 指向顶部，而数学中 0 度指向右侧。因此需要减去 90 度。
      final double angleInRad = (angle - 90) * (pi / 180.0);

      // 通过三角函数计算 Alignment 的 x, y 值
      // begin 和 end 是相反的向量
      begin = Alignment(-cos(angleInRad), -sin(angleInRad));
      end = Alignment(cos(angleInRad), sin(angleInRad));
    } else if (directionStr.startsWith('to ')) {
      isDirectionKeyword = true;
      switch (directionStr) {
        case 'to bottom':
          begin = Alignment.topCenter;
          end = Alignment.bottomCenter;
          break;
        case 'to top':
          begin = Alignment.bottomCenter;
          end = Alignment.topCenter;
          break;
        case 'to right':
          begin = Alignment.centerLeft;
          end = Alignment.centerRight;
          break;
        case 'to left':
          begin = Alignment.centerRight;
          end = Alignment.centerLeft;
          break;
        case 'to bottom right':
          begin = Alignment.topLeft;
          end = Alignment.bottomRight;
          break;
        case 'to bottom left':
          begin = Alignment.topRight;
          end = Alignment.bottomLeft;
          break;
        case 'to top right':
          begin = Alignment.bottomLeft;
          end = Alignment.topRight;
          break;
        case 'to top left':
          begin = Alignment.bottomRight;
          end = Alignment.topLeft;
          break;
      }
    }

    return (begin: begin, end: end, isDirectionKeyword: isDirectionKeyword);
  }
}
