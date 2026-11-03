import 'package:flutter/material.dart';
import 'package:langwise/common/values/values.dart';
import 'package:ui_essentials/ui_essentials.dart';

class TagWidget extends StatelessWidget {
  final TagType type;

  const TagWidget({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 121.ww, // 固定宽度
      height: 44.wh, // 固定高度
      decoration: BoxDecoration(
        color: type.backgroundColor,
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10.wMax,
            height: 10.wMax,
            decoration: BoxDecoration(
              color: type.textColor,
              borderRadius: BorderRadius.circular(5.wMax),
            ),
          ),
          Gaps.getWidth(10.ww),
          Text(
            type.title,
            style: TextStyle(color: type.textColor, fontSize: 18.wMin, height: 1.0, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

class ScanWordTagWidget extends StatelessWidget {
  final ScanWordType type;
  final double? fontSize;
  final FontWeight? fontWeight;

  const ScanWordTagWidget({Key? key, required this.type, this.fontSize, this.fontWeight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // 固定高度
      height: 44.wh,
      padding: EdgeInsets.only(left: 12.ww, right: 12.ww),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: type.backgroundColor,
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10.wMax,
            height: 10.wMax,
            decoration: BoxDecoration(
              color: type.textColor,
              borderRadius: BorderRadius.circular(5.wMax),
            ),
          ),
          Gaps.getWidth(10.ww),
          Expanded(
              child: Text(
            type.title,
            maxLines: 3,
            style: TextStyle(
                color: type.textColor,
                fontSize: (fontSize ?? 18).wMin,
                height: 1.0,
                fontWeight: fontWeight ?? FontWeight.w400),
          )),
        ],
      ),
    );
  }
}

class InventoryTagWidget extends StatelessWidget {
  final InventoryType type;

  const InventoryTagWidget({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // 固定高度
      height: 24.wh,
      padding: EdgeInsets.only(left: 12.ww, right: 12.ww),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: type.backgroundColor,
        borderRadius: BorderRadius.circular(2.wMin),
      ),
      child: Text(
        type.title,
        style: TextStyle(color: const Color(0xffEBEFF5), fontSize: 12.wMin, height: 1.0, fontWeight: FontWeight.w400),
      ),
    );
  }
}

class UnmountTagWidget extends StatelessWidget {
  final UnmountType type;
  final TextStyle? textStyle;

  const UnmountTagWidget({Key? key, required this.type, this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // 固定高度
      height: 24.wh,
      padding: EdgeInsets.only(left: 12.ww, right: 12.ww),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: type.backgroundColor,
        borderRadius: BorderRadius.circular(2.wMin),
      ),
      child: Text(
        type.title,
        style: textStyle ??
            TextStyle(color: const Color(0xffEBEFF5), fontSize: 12.wMin, height: 1.0, fontWeight: FontWeight.w400),
      ),
    );
  }
}

class PublicTagWidget extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color fontColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final FontStyle? fontStyle;

  const PublicTagWidget(
      {super.key,
      required this.text,
      required this.backgroundColor,
      required this.fontColor,
      this.fontSize,
      this.fontWeight = FontWeight.w400,
      this.fontStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.wMin), color: backgroundColor),
      child: Text(
        text,
        style: TextStyle(
          color: fontColor,
          fontSize: fontSize ?? 18.wMin,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
        ),
      ),
    );
  }
}

/// 知识点状态标签组件
///
/// 用于显示知识点的不同状态（未收录、重复添加、正常状态）
class KnowledgePointStatusWidget extends StatelessWidget {
  /// 知识点状态类型
  final KnowledgePointStatus status;

  /// 自定义文本样式
  final TextStyle? textStyle;

  const KnowledgePointStatusWidget({Key? key, required this.status, this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // 固定高度
      height: 24.wh,
      padding: EdgeInsets.only(left: 12.ww, right: 12.ww),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(6.wMin),
      ),
      child: Text(
        status.title,
        style: textStyle ??
            TextStyle(color: status.textColor, fontSize: 16.wMin, height: 1.0, fontWeight: FontWeight.w400),
      ),
    );
  }
}
