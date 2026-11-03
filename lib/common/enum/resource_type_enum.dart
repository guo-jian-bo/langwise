import 'package:flutter/material.dart';

enum ResourceTypeEnum{
  image("image", "图片", Color(0xff00BC7D), "assets/svg/public/icon_image_resource.svg"),
  audio("audio", "音频", Color(0xff3B82F6), ""),
  video("video", "视频", Color(0xffA855F7), "assets/svg/public/icon_video_resource.svg");

  final String value;
  final String name;
  final Color color;
  final String svg;
  const ResourceTypeEnum(this.value, this.name, this.color, this.svg);

  factory ResourceTypeEnum.fromRawValue(String? value) {
    return values.firstWhere(
      (element) => element.value == value,
      orElse: () => image,
    );
  }

}

enum ResourceAlignEnum{
  align("align", "字幕", Color(0xffA855F7)),
  translate("translate", "翻译", Color(0xffEC4899));

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