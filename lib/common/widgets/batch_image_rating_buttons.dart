/// 批量图片评分按钮组件
///
/// 功能需求：
/// 1. 显示条件：
///    - 仅在批量模式下且至少有一张图片被选中时显示
///    - 当没有图片被选中时自动隐藏
///
/// 2. 按钮设计：
///    - 包含5个星级评分按钮（1-5星）
///    - 每个按钮显示星级数字和对应的评价文本
///    - 按钮背景颜色根据星级使用 `getStarColor` 方法获取
///    - 按钮布局与当前图片中展示的样式保持一致
///
/// 3. 交互效果：
///    - 鼠标悬停时有颜色变化效果（增加亮度或透明度变化）
///    - 点击按钮时通过回调函数将评分传递给父组件
///
/// 4. 通信机制：
///    - 每个按钮点击时触发同一个回调函数，传递不同的星级参数
///    - 组件不直接处理业务逻辑，只负责UI展示和用户交互
///    - 父组件通过回调函数接收评分操作并处理批量评分逻辑
///
/// 使用示例：
/// ```dart
/// BatchImageRatingButtons(
///   isVisible: controller.hasSelectedImages,
///   onRateSelected: (stars) {
///     // 处理批量评分逻辑
///     controller.batchRateImages(stars);
///   },
/// )
/// ```
import 'package:flutter/material.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 批量图片评分按钮组件
class BatchImageRatingButtons extends StatefulWidget {
  /// 评分回调函数，参数为星级(1-5)
  final Function(int stars) onRateSelected;

  /// 是否显示组件
  final bool isVisible;

  const BatchImageRatingButtons({
    Key? key,
    required this.onRateSelected,
    required this.isVisible,
  }) : super(key: key);

  @override
  _BatchImageRatingButtonsState createState() => _BatchImageRatingButtonsState();
}

class _BatchImageRatingButtonsState extends State<BatchImageRatingButtons> with SafeSetStateMixin {
  // 存储各个按钮的悬停状态
  final Map<int, bool> _hoverStates = {};

  // 星级评价文本
  final List<String> _ratingTexts = [
    '画风不符',
    '信息有误',
    '主体失真',
    '大体可用',
    '各项完美',
  ];

  @override
  void initState() {
    super.initState();
    // 初始化悬停状态
    for (int i = 1; i <= 5; i++) {
      _hoverStates[i] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果不可见，返回空容器
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(right: 16.ww),
      padding: EdgeInsets.only(left: 8.ww, right: 8.ww),
      height: 68.wh,
      decoration: BoxDecoration(
        color: color_1E2939,
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final starRating = index + 1;
          return _buildRatingButton(starRating);
        }),
      ),
    );
  }

  /// 构建评分按钮
  Widget _buildRatingButton(int stars) {
    final Color backgroundColor = getStarColor(stars);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _updateHoverState(stars, true),
      onExit: (_) => _updateHoverState(stars, false),
      child: TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() {
          widget.onRateSelected(stars);
        }, 300),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 4.wh),
          margin: stars != 5 ? EdgeInsets.only(right: 8.ww) : null,
          decoration: BoxDecoration(
            color: _hoverStates[stars]! ? backgroundColor.withOpacity(0.8) : backgroundColor,
            borderRadius: BorderRadius.circular(8.ww),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4.wMin,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$stars',
                    style: TextStyle(color: Colors.white, fontSize: 12.wMin, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 0.5.ww),
                  Icon(
                    Icons.star,
                    size: 16.wMin,
                    color: color_FDC700,
                  ),
                ],
              ),
              SizedBox(height: 2.wh),
              Text(
                _ratingTexts[stars - 1],
                style: TextStyle(color: Colors.white, fontSize: 12.wMin, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 更新悬停状态
  void _updateHoverState(int stars, bool isHovering) {
    if (_hoverStates[stars] != isHovering) {
      safeSetState(() {
        _hoverStates[stars] = isHovering;
      });
    }
  }
}
