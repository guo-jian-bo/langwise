/// 星星评分组件
/// 
/// 功能：
/// 1. 显示指定数量的星星，支持点亮和未点亮状态
/// 2. 统一星星图标大小和颜色
/// 3. 可自定义星星数量、大小和颜色
/// 4. 支持水平和垂直排列
/// 
/// 使用场景：
/// - 图片评分显示
/// - 评分选项卡片
/// - 图片卡片底部评分展示
///
/// 作者：LangWise Team
/// 最后更新：2025-05-25

import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

class StarRatingWidget extends StatelessWidget {
  /// 星星总数
  final int totalStars;
  
  /// 点亮的星星数量
  final int litStars;
  
  /// 星星大小
  final double starSize;
  
  /// 点亮星星的颜色
  final Color litStarColor;
  
  /// 未点亮星星的颜色
  final Color unlitStarColor;
  
  /// 星星之间的间距
  final double spacing;
  
  /// 排列方向
  final Axis direction;
  
  /// 主轴对齐方式
  final MainAxisAlignment mainAxisAlignment;
  
  /// 交叉轴对齐方式
  final CrossAxisAlignment crossAxisAlignment;

  const StarRatingWidget({
    Key? key,
    this.totalStars = 5,
    required this.litStars,
    this.starSize = 14.0,
    this.litStarColor = Colors.amber,
    this.unlitStarColor = Colors.white30,
    this.spacing = 2.0,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final starWidgets = List.generate(totalStars, (index) {
      // 判断当前星星是否点亮
      final isLit = index < litStars;
      
      return Icon(
        Icons.star,
        size: starSize.wMin,
        color: isLit ? litStarColor : unlitStarColor,
      );
    });

    // 根据方向创建不同的布局
    if (direction == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacingBetween(starWidgets, spacing.ww),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacingBetween(starWidgets, spacing.wh),
      );
    }
  }
  
  /// 在星星之间添加间距
  List<Widget> _addSpacingBetween(List<Widget> widgets, double spacing) {
    if (widgets.isEmpty) return [];
    if (widgets.length == 1) return widgets;
    
    final result = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      
      // 在非最后一个元素后添加间距
      if (i < widgets.length - 1) {
        if (direction == Axis.horizontal) {
          result.add(SizedBox(width: spacing));
        } else {
          result.add(SizedBox(height: spacing));
        }
      }
    }
    
    return result;
  }
}
