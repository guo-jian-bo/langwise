import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class ElementsCardListStudiedWidget extends StatefulWidget {
  final bool value;
  final void Function(bool value) onChange;
  /// 卡片列表 已经学习 和 全部卡片 切换按钮
  const ElementsCardListStudiedWidget({super.key, this.value = false, required this.onChange});

  @override
  State<ElementsCardListStudiedWidget> createState() => _ElementsCardListStudiedWidgetState();
}

class _ElementsCardListStudiedWidgetState extends State<ElementsCardListStudiedWidget> {

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: (){
        widget.onChange(!widget.value);
      },
      sclae: 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 160.wMin,
        height: 46.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: !widget.value ? AppTheme.cFeedbackWarningBorder : AppTheme.cSurfaceBrand,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(horizontal: 5.wMin),
              alignment: !widget.value ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 36.wMin,
                height: 36.wMin,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cStaticWhite,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              alignment: widget.value ? Alignment.centerLeft : Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  !widget.value ? "全部卡片" : "已学卡片",
                  key: ValueKey(!widget.value),
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cStaticWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}