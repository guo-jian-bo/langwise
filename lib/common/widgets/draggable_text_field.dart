
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';

class DraggableTextField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final double height;

  const DraggableTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.height = 160,
  });

  @override
  State<DraggableTextField> createState() => _DraggableTextFieldState();
}

class _DraggableTextFieldState extends State<DraggableTextField> {
  double _inputHeight = 160; // 初始高度
  final double _minHeight = 80;
  final double _maxHeight = 500;
  late TextEditingController _textEditingController;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _inputHeight = widget.height;
    _ownsController = widget.controller == null;
    _textEditingController = widget.controller ?? TextEditingController();
  }

  @override
  void didUpdateWidget(covariant DraggableTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) {
        _textEditingController.dispose();
      }
      _ownsController = widget.controller == null;
      _textEditingController = widget.controller ?? TextEditingController();
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _textEditingController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _inputHeight,
      child: Stack(
        children: [
          // 文本输入区域
          Positioned.fill(
            child: TextField(
              expands: true,
              controller: _textEditingController,
              onChanged: widget.onChanged,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(fontSize: 16.wMin, color: AppTheme.cTextPrimary.color),
              decoration: InputDecoration(
                hintText: '在此粘贴或输入原文内容',
                fillColor: AppTheme.cSurfaceQuaternary.color.withValues(alpha: .35),
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8.wMin,
                  vertical: 16.wMin,
                ),
                hintStyle: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.wMin),
                  borderSide: const BorderSide(color: Color(0xFF4B5268)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.wMin),
                  borderSide: const BorderSide(color: Color(0xFF2388FF)),
                ),
              ),
            ),
          ),

          // 右下角拖拽控件
          Positioned(
            right: 4.wMin,
            bottom: 4.wMin,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                setState(() {
                  _inputHeight += details.delta.dy;
                  if (_inputHeight < _minHeight) _inputHeight = _minHeight;
                  if (_inputHeight > _maxHeight) _inputHeight = _maxHeight;
                });
              },
              child: CustomPaint(
                size: Size(16.wMin, 16.wMin),
                painter: ResizeCornerPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResizeCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint trianglePaint = Paint()
      ..color = AppTheme.cTextTertiary.color.withValues(alpha: .1)
      ..style = PaintingStyle.fill;

    final Paint linePaint = Paint()
      ..color = AppTheme.cTextTertiary.color.withValues(alpha: .6)
      ..strokeWidth = 1;

    final double w = size.width;
    final double h = size.height;

    // 画右下角三角形背景
    final Path triangle = Path()
      ..moveTo(w, h)
      ..lineTo(0, h)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(triangle, trianglePaint);

    // 画几条斜纹线（从右下角往上/往左）
    const int lineCount = 3;
    final double step = w / (lineCount + 1);

    for (int i = 1; i <= lineCount; i++) {
      final double offset = step * i;
      final Offset start = Offset(w - offset, h); // 底边
      final Offset end = Offset(w, h - offset); // 右边
      canvas.drawLine(start, end, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}