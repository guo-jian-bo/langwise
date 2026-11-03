import 'package:flutter/material.dart';

enum ResourceTypeEnum{
  image("image", "图片", Color(0xff38BDF8)),
  audio("audio", "音频", Color(0xff38BDF8)),
  video("video", "视频", Color(0xff00D492));

  final String value;
  final String name;
  final Color color;
  const ResourceTypeEnum(this.value, this.name, this.color);

  factory ResourceTypeEnum.fromRawValue(String? value) {
    return values.firstWhere(
      (element) => element.value == value,
      orElse: () => image,
    );
  }

}

enum ResourceAlignEnum{
  align("align", "字幕", Color(0xffA855F7)),
  tranlate("tranlate", "翻译", Color(0xffEC4899));

  final String value;
  final String name;
  final Color color;
  const ResourceAlignEnum(this.value, this.name, this.color);

  factory ResourceAlignEnum.fromRawValue(String? value) {
    return values.firstWhere(
      (element) => element.value == value,
      orElse: () => align,
    );
  }
}