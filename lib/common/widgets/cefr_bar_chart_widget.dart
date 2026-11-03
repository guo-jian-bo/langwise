

import 'package:bubble_box/bubble_box.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../utils/utils.dart';
import '../painter/painter.dart';

class CefrBarChartWidget extends StatefulWidget {
  final double height;
  final double width;
  final bool selected;
  final String selectedText;
  final String? cefr;
  final String? subTitle;
  final Widget? child;
  final String? scoreRange;
  final bool isDisable;
  final double fontSize1;
  final double fontSize2;
  final double fontSize3;
  const CefrBarChartWidget({
    super.key, 
    this.height = 350,
    this.width = 220,
    this.selected = false,
    this.selectedText = "当前等级",
    this.child,
    this.cefr,
    this.subTitle,
    this.scoreRange,
    this.isDisable = false,
    this.fontSize1 = 32,
    this.fontSize2 = 24,
    this.fontSize3 = 24,
  });

  @override
  State<CefrBarChartWidget> createState() => _CefrBarChartWidgetState();
}

class _CefrBarChartWidgetState extends State<CefrBarChartWidget> {
  bool _isHovered = false;


  @override
  Widget build(BuildContext context) {
    DifficultyColor color = StatusUtils.getDifficultyColorFromCefr(widget.cefr);
    
    return IgnorePointer(
      ignoring: widget.isDisable,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              MouseRegion(
                onEnter: (event) {
                  _isHovered = true;
                  if(mounted) setState(() {});
                },
                onExit: (event) {
                  _isHovered = false;
                  if(mounted) setState(() {});
                },
                child: GestureDetector(
                  onTapDown: (details) {
                    _isHovered = true;
                    if(mounted) setState(() {});
                  },
                  onTapUp: (details) {
                    _isHovered = false;
                    if(mounted) setState(() {});
                  },
                  onTapCancel: () {
                    _isHovered = false;
                    if(mounted) setState(() {});
                  },
                  child: AnimatedScale(
                    scale: _isHovered ? 1.05 : 1,
                    duration: const Duration(milliseconds: 500),
                    child: Opacity(
                      opacity: widget.isDisable ? 0.5 : 1,
                      child: Column(
                        children: [
                          // 3D梯形顶部
                          CustomPaint(
                            size: Size(widget.width, 15.wMin),
                            painter: TrapezoidPainter(angle: 30.wMin, color: color.color2),
                          ),
                          // 主体柱子部分
                          Container(
                            width: widget.width,
                            height: widget.height,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  color.color1,
                                  color.color2,
                                ],
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8.wMin),
                                bottomRight: Radius.circular(8.wMin),
                              ),
                            ),
                            child: widget.child,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      
              Visibility(
                visible: widget.cefr != null,
                child: Text(
                  widget.cefr??"",
                  style: TextStyle(
                    fontSize: widget.fontSize1.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary.color.withValues(alpha: widget.isDisable ? 0.5 : 1),
                  ),
                ),
              ),
              Visibility(
                visible: widget.subTitle != null,
                child: Text(
                  widget.subTitle??"",
                  style: TextStyle(
                    fontSize: widget.fontSize2.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color.withValues(alpha: widget.isDisable ? 0.5 : 1),
                  ),
                ),
              ),
              Visibility(
                visible: widget.scoreRange != null,
                child: Text(
                  widget.scoreRange??"",
                  style: TextStyle(
                    fontSize: widget.fontSize3.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color.withValues(alpha: widget.isDisable ? 0.5 : 1),
                  ),
                ),
              ),
      
            ],
          ),
      
          Visibility(
            visible: widget.selected,
            child: Positioned(
              top: -(24.wMin + 66.66.wMin),
              child: BubbleBox(
                backgroundColor: AppTheme.cFeedbackWarningBorder.color,
                padding: EdgeInsets.all(2.wMin),
                shape: BubbleShapeBorder(
                  direction: BubbleDirection.bottom,
                  arrowQuadraticBezierLength: 2.wMin,
                  radius: BorderRadius.circular(9.wMin),
                  arrowHeight: 10.wMin,
                  arrowAngle: 10.wMin,
                  smooth: 0,
                ),
                child: Container(
                  height: 66.66.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfacePrimary.color,
                    borderRadius: BorderRadius.circular(8.wMin),
                  ),
                  child: Text(
                    widget.selectedText,
                    style: TextStyle(
                      fontSize: 32.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cFeedbackWarningText.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
      
        ],
      ),
    );
  }
}

