class ThemeImageEntity{
  String? theme;
  String? image;
  String? imageUrl;
  ThemeImageEntity({
    this.theme,
    this.image,
    this.imageUrl,
  });

  ThemeImageEntity.fromJson(Map<String, dynamic> json) {
    theme = json['theme']?.toString();
    image = json['image']?.toString();
    imageUrl = json['imageUrl']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['theme'] = theme;
    data['image'] = image;
    data['imageUrl'] = imageUrl;
    return data;
  }
}

class ThemeColorEntity{
  String? theme;
  String? color;
  String? borderColor;
  ThemeColorEntity({
    this.theme,
    this.color,
    this.borderColor,
  });

  ThemeColorEntity.fromJson(Map<String, dynamic> json) {
    theme = json['theme']?.toString();
    color = json['color']?.toString();
    borderColor = json['borderColor']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['theme'] = theme;
    data['color'] = color;
    data['borderColor'] = borderColor;
    return data;
  }
}

class ThemeTextStyleEntity{
  String? theme;
  String? color;
  int? fontsize;
  bool? italic;
  int? weight;
  String? backgroundColor;
  String? borderColor;
  double? lineHeight;
  double? letterSpacing;
  double? borderRadius;
  double? padding;
  double? margin;
  bool? underline;
  ThemeTextStyleEntity({
    this.theme,
    this.color,
    this.fontsize,
    this.italic,
    this.weight,
    this.backgroundColor,
    this.borderColor,
    this.lineHeight,
    this.letterSpacing,
    this.underline,
  });
  ThemeTextStyleEntity.fromJson(Map<String, dynamic> json) {
    theme = json['theme']?.toString();
    color = json['color']?.toString();
    fontsize = json['fontsize']?.toInt();
    italic = json['italic'];
    weight = json['weight']?.toInt();
    backgroundColor = json['backgroundColor']?.toString();
    borderColor = json['borderColor']?.toString();
    lineHeight = json['lineHeight']?.toDouble();
    letterSpacing = json['letterSpacing']?.toDouble();
    borderRadius = json['borderRadius']?.toDouble();
    padding = json['padding']?.toDouble();
    margin = json['margin']?.toDouble();
    underline = json['underline'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['theme'] = theme;
    data['color'] = color;
    data['fontsize'] = fontsize;
    data['italic'] = italic;
    data['weight'] = weight;
    data['backgroundColor'] = backgroundColor;
    data['borderColor'] = borderColor;
    data['lineHeight'] = lineHeight;
    data['letterSpacing'] = letterSpacing;
    data['borderRadius'] = borderRadius;
    data['padding'] = padding;
    data['margin'] = margin;
    data['underline'] = underline;
    return data;
  }
}

class ThemeTextEntity{
  String? text;
  List<ThemeTextStyleEntity?>? style;
  ThemeTextEntity({
    this.text,
    this.style,
  });
  ThemeTextEntity.fromJson(Map<String, dynamic> json) {
    text = json['text']?.toString();
    if (json['style'] != null) {
      final v = json['style'];
      final arr0 = <ThemeTextStyleEntity>[];
      v.forEach((v) {
        arr0.add(ThemeTextStyleEntity.fromJson(v));
      });
      style = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['text'] = text;
    if (style != null) {
      final v = style;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['style'] = arr0;
    }
    return data;
  }
}