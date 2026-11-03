import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';

import 'package:ui_essentials/ui_essentials.dart';

double componentMarginValue = 24.ww;

class DataGeneralColumnWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final double? height;

  const DataGeneralColumnWidget({super.key, required this.child, this.margin, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.only(left: componentMarginValue, right: componentMarginValue),
      alignment: Alignment.centerLeft,
      height: height,
      child: child,
    );
  }
}

// 在通用组件库中添加
class TableTextCell extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;

  /// 是否启用文本选择功能，默认为true
  final bool enableSelection;

  const TableTextCell(
    this.text, {
    Key? key,
    this.style,
    this.maxLines,
    this.enableSelection = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 计算文本样式
    final TextStyle textStyle = style ??
        TextStyle(
          color: const Color(0xffEBEEF3),
          fontSize: 18.wMin,
          fontWeight: FontWeight.w400,
          // 使用系统默认height值
          // height: 1.0
        );

    if (!enableSelection) {
      // 不需要复制
      return DataGeneralColumnWidget(
        child: Text(
          text,
          maxLines: maxLines ?? 3,
          style: textStyle,
          textAlign: TextAlign.left,
        ),
      );
    }

    // 使用Theme设置选中文本的背景颜色
    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: const ScrollbarThemeData(
          thumbVisibility: WidgetStatePropertyAll<bool>(false),
          thickness: WidgetStatePropertyAll<double>(0.0),
        ),
      ),
      child: DataGeneralColumnWidget(
        child: LimitedSelectableText.createCopyableText(text,
            style: textStyle, maxLines: maxLines ?? 3, scrollPhysics: const NeverScrollableScrollPhysics()),
      ),
    );
  }
}

/*

// 使用Theme设置选中文本的背景颜色
    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: const ScrollbarThemeData(
          thumbVisibility: WidgetStatePropertyAll<bool>(false),
          thickness: WidgetStatePropertyAll<double>(0.0),
        ),
      ),
      child: DataGeneralColumnWidget(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // 获取可用的最大宽度（已经减去DataGeneralColumnWidget的margin）
            final availableWidth = constraints.maxWidth;

            // 使用TextPainter计算文本高度
            final TextPainter textPainter = TextPainter(
              text: TextSpan(text: text, style: textStyle),
              textDirection: TextDirection.ltr,
              maxLines: maxLines ?? 3,
            );

            // 使用可用宽度进行布局
            textPainter.layout(minWidth: availableWidth, maxWidth: availableWidth);

            // 计算文本行数
            int lineCount = 1;
            // 检查文本中的换行符
            for (int i = 0; i < text.length; i++) {
              if (text[i] == '\n') {
                lineCount++;
              }
            }

            // 检查TextPainter的实际行数
            final List<ui.LineMetrics> lines = textPainter.computeLineMetrics();
            final int textPainterLineCount = lines.length;

            // 取这两种方式计算出的行数的较大值
            lineCount = max(lineCount, textPainterLineCount);

            // 计算文本高度，使用baseline对齐时需要更多空间
            final double textHeight = textPainter.height + 8.wh;

            // print("---😆😆 可用宽度: $availableWidth, 文本高度: $textHeight, 文本行数: $lineCount 😆😆---");

            // 使用Row和CrossAxisAlignment.center确保文本垂直居中
            return Container(
              width: availableWidth,
              height: textHeight,
              padding: EdgeInsets.symmetric(vertical: 2.wh),
              child: IntrinsicHeight(
                child: Row(
                  // 使用baseline对齐来解决文本下沉问题
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: SelectableText(
                        text,
                        maxLines: maxLines ?? 3,
                        style: textStyle,
                        selectionControls: MaterialTextSelectionControls(),
                        textAlign: TextAlign.left,
                        selectionHeightStyle: ui.BoxHeightStyle.tight,
                        selectionWidthStyle: ui.BoxWidthStyle.tight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
 */
