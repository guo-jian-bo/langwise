import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../theme/theme_utils.dart';
import '../../utils/utils.dart';
import 'entities.dart';

class ParagraphRhetoricalEntityColorItem {
  String? theme;
  String? code;
  String? color;
  String? textColor;

  Color? get colorValue => ColorUtils.parseColor(color);
  Color? get textColorValue => ColorUtils.parseColor(textColor);

  ParagraphRhetoricalEntityColorItem({
    this.theme,
    this.code,
    this.color,
    this.textColor,
  });

  ParagraphRhetoricalEntityColorItem.fromJson(Map<String, dynamic> json) {
    theme = json['theme']?.toString();
    code = json['code']?.toString();
    color = json['color']?.toString();
    textColor = json['textColor']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['theme'] = theme;
    data['code'] = code;
    data['color'] = color;
    data['textColor'] = textColor;
    return data;
  }
}

class ParagraphRhetoricalEntityList {
/*
{
  "nid": "opening",
  "name": [
    {
      "lang": "zh",
      "text": "起·开头"
    }
  ],
  "description": [
    {
      "lang": "zh",
      "text": "先写开头：这是谁、你的回答、你的看法，或你要讲的问题。"
    }
  ],
  "colors": [
    {
      "theme": "LIGHT",
      "code": "primary",
      "color": "rgba(212, 72, 50, 1)",
      "textColor": "rgba(255, 255, 255, 1)"
    }
  ]
} 
*/

  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  List<LanguageText?>? gloss;
  String? color;
  List<ParagraphRhetoricalEntityColorItem?>? colors;

  Color? get colorValue => ColorUtils.parseColor(color);
  
  /// 获取当前主题颜色
  ParagraphRhetoricalEntityColorItem? get currentThemeColor {
    for (var element in colors ?? []) {
      bool isCurrent = ThemeUtils.isCurrentTheme(element?.theme ?? "");
      if (isCurrent) {
        return element;
      }
    }
    return null;
  }

  /// 根据主题获取颜色
  ParagraphRhetoricalEntityColorItem? getThemeColor(AppThemeKey theme) {
    for (ParagraphRhetoricalEntityColorItem? item in colors ?? []) {
      if (item?.theme?.toUpperCase() == theme.value.toUpperCase()) {
        return item;
      }
    }
    return null;
  }

  ParagraphRhetoricalEntityColorItem? findThemeColorItem(String themeKey) {
    if (colors == null || colors!.isEmpty || themeKey.isEmpty) return null;
    for (final ParagraphRhetoricalEntityColorItem? item in colors!) {
      if ((item?.theme ?? '').toUpperCase() == themeKey.toUpperCase()) {
        return item;
      }
    }
    return null;
  }

  ParagraphRhetoricalEntityList({
    this.nid,
    this.name,
    this.description,
    this.gloss,
    this.color,
    this.colors,
  });
  ParagraphRhetoricalEntityList.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    if (json['name'] != null) {
      final v = json['name'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      name = arr0;
    }
    if (json['description'] != null) {
      final v = json['description'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      description = arr0;
    }
    if (json['gloss'] != null) {
      final v = json['gloss'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      gloss = arr0;
    }

    color = json['color']?.toString();
    if (json['colors'] != null) {
      final v = json['colors'];
      final arr0 = <ParagraphRhetoricalEntityColorItem>[];
      for (final item in v) {
        arr0.add(ParagraphRhetoricalEntityColorItem.fromJson(item));
      }
      colors = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    if (name != null) {
      final v = name;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['name'] = arr0;
    }
    if (description != null) {
      final v = description;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['description'] = arr0;
    }
    if (gloss != null) {
      final v = gloss;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['gloss'] = arr0;
    }

    data['color'] = color;
    if (colors != null) {
      final v = colors;
      final arr0 = [];
      for (final item in v!) {
        arr0.add(item!.toJson());
      }
      data['colors'] = arr0;
    }
    return data;
  }
}

class ParagraphRhetoricalEntity {
/*
{
  "list": [
    {
      "nid": "opening",
      "name": [
        {
          "lang": "zh",
          "text": "起·开头"
        }
      ],
      "description": [
        {
          "lang": "zh",
          "text": "先写开头：这是谁、你的回答、你的看法，或你要讲的问题。"
        }
      ]
    }
  ]
} 
*/

  List<ParagraphRhetoricalEntityList?>? list;

  ParagraphRhetoricalEntity({
    this.list,
  });
  ParagraphRhetoricalEntity.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      final v = json['list'];
      final arr0 = <ParagraphRhetoricalEntityList>[];
      v.forEach((v) {
        arr0.add(ParagraphRhetoricalEntityList.fromJson(v));
      });
      list = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (list != null) {
      final v = list;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['list'] = arr0;
    }
    return data;
  }
}
