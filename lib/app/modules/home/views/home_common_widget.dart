

import 'package:flutter/material.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/tap_scale_widget.dart';
import '../../../../theme/theme.dart';

class HomeCardTabbarWidget extends StatefulWidget {
  final List<ThemeTextEntity?>? tabs;
  final int selectIndex;
  final EdgeInsetsGeometry? padding;
  final void Function(int)? onTap;
  const HomeCardTabbarWidget({
    super.key, 
    required this.tabs, 
    required this.selectIndex, 
    this.padding,
    this.onTap,
  });

  @override
  State<HomeCardTabbarWidget> createState() => _HomeCardTabbarWidgetState();
}

class _HomeCardTabbarWidgetState extends State<HomeCardTabbarWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(HomeCardTabbarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectIndex != widget.selectIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          // 计算选中项之前所有项的总宽度
          double offset = 0;
          for (int i = 0; i < widget.selectIndex; i++) {
            if (widget.tabs![i] != null) {
              // 文本宽度 + 间距
              offset += getTextWidth(i) + 24.wMin;
            }
          }
          _scrollController.animateTo(
            offset.clamp(0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  double getTextWidth(int index){
    if(widget.tabs == null || widget.tabs!.isEmpty) return 0;
    if(index < 0 || index >= widget.tabs!.length) return 0;
    if(widget.tabs![index] == null) return 0;
    ThemeTextStyleEntity? themeText = StyleUtils.getCurrentThemeText(widget.tabs![index]!.style);
    return (TextPainter(
      text: TextSpan(
        text: widget.tabs![index]!.text ?? "",
        style: TextStyle(
          fontSize: (themeText?.fontsize?.toDouble())?.wMin,
          fontWeight: StyleUtils.getFontWeight(themeText?.weight),
          fontStyle: StyleUtils.getFontStyle(themeText?.italic),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout()).width;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.tabs == null || widget.tabs!.isEmpty) return Container();

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: widget.padding,
      child: Row(
        spacing: 24.wMin,
        children: List.generate(widget.tabs!.length, (index){
          if(widget.tabs![index] == null) return Container();
          ThemeTextStyleEntity? themeText = StyleUtils.getCurrentThemeText(widget.tabs![index]!.style);
          Color color = ColorUtils.parseColor(themeText?.color)??AppTheme.cTextPrimary;

          return TapScaleWidget(
            onTap: widget.onTap == null || index == widget.selectIndex ? null : (){
              widget.onTap?.call(index);
            },
            sclae: 1,
            child: Container(
              color: Colors.transparent,
              child: Text(
                widget.tabs![index]!.text??"",
                style: TextStyle(
                  fontSize: (themeText?.fontsize?.toDouble())?.wMin,
                  color: color.withValues(alpha: widget.selectIndex == index ? 1 : 0.3),
                  fontWeight: StyleUtils.getFontWeight(themeText?.weight),
                  fontStyle: StyleUtils.getFontStyle(themeText?.italic),
                ),
              ),
            ),
          );
        }),
      ),
    );

  }
}

class HomeMinButton extends StatelessWidget {
  final String text;
  final double? width;
  final AlignmentGeometry? alignment;
  final double sclae;
  final void Function()? onTap;
  final Color? fontColor;
  final Color? backColor;
  const HomeMinButton({
    super.key, 
    required this.text, 
    this.onTap, 
    this.width, 
    this.alignment, 
    this.sclae = 1.05,
    this.fontColor,
    this.backColor,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      sclae: sclae,
      child: Container(
        width: width,
        alignment: alignment,
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: backColor??AppTheme.cWhiteAlpha10,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20.wMin,
            color: fontColor??AppTheme.cTextPrimary,
            fontWeight: FontWeight.w500,
            height: 1.33,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}