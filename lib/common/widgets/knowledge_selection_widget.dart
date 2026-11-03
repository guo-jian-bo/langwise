import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../generated/assets.dart';
import '../../theme/theme.dart';

/// 知识点选择组件
class KnowledgeSelectionWidget extends StatelessWidget {
  final String title;
  final Widget subtitle;
  final bool isSelected;
  final int animationIndex;
  final Duration? delay;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final bool showAiIcon;

  const KnowledgeSelectionWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.isSelected = false,
    this.animationIndex = 0,
    this.delay,
    this.onTap,
    this.backgroundColor = AppTheme.cBgTertiary,
    this.showAiIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListAnimationWidget(
      index: animationIndex,
      delay: delay,
      child: TapScaleWidget(
        onTap: onTap,
        sclae: 1.02,
        child: Container(
          padding: EdgeInsets.all(24.wMin),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.cTransparentBrand1 : backgroundColor,
            borderRadius: BorderRadius.circular(16.wMin),
            border: Border.all(
              width: 1.wMin,
              color: isSelected ? AppTheme.cBorderBrand : AppTheme.cBorderPrimary,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                      if (showAiIcon) ...[
                        SizedBox(width: 8.wMin),
                        SvgPicture.asset(
                          Assets.customCourseIconAi,
                          width: 57.ww,
                          height: 28.wh,
                        ),
                      ],
                      const Spacer(),
                      // 右侧选择指示器
                      CardSelectDotWidget(isSelected: isSelected),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.wMin),
              subtitle,
            ],
          ),
        ),
      ),
    );
  }
}

/// 知识点选择容器组件
/// 包含多个知识点选择项的容器
class KnowledgeSelectionContainer extends StatelessWidget {
  final List<KnowledgeSelectionItem> items;
  final int selectedIndex;
  final Function(int index) onSelectionChanged;

  const KnowledgeSelectionContainer({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        items.length,
        (index) {
          final KnowledgeSelectionItem m = items[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < items.length - 1 ? 16.wMin : 0,
            ),
            child: KnowledgeSelectionWidget(
              title: m.title,
              subtitle: m.subtitle,
              isSelected: selectedIndex == index,
              animationIndex: index + 1,
              delay: Duration(milliseconds: 300 - (index * 100)),
              onTap: () => onSelectionChanged(index),
              showAiIcon: m.showAiIcon,
            ),
          );
        },
      ),
    );
  }
}

/// 知识点选择项数据模型
class KnowledgeSelectionItem {
  final String title;
  final Widget subtitle;
  final bool showAiIcon;

  const KnowledgeSelectionItem({
    required this.title,
    required this.subtitle,
    this.showAiIcon = false,
  });
}
