import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ElementsMemoryActionButton extends StatelessWidget {
  final bool favorited;
  final VoidCallback? onTap;
  final String normalText;
  final String favoritedText;
  final Color color;

  const ElementsMemoryActionButton({
    super.key,
    required this.favorited,
    required this.onTap,
    this.normalText = '加入记忆',
    this.favoritedText = '已加记忆',
    this.color = AppTheme.cMorphemeCardColor1,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: favorited ? null : onTap,
      sclae: 1.02,
      child: Opacity(
        opacity: favorited ? 0.8 : 1,
        child: Container(
          height: 50.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999.wMin),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1.wMin,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/svg/public/Icons_memory.svg',
                width: 20.wMin,
                height: 20.wMin,
                colorFilter: ColorFilter.mode(
                  color,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 6.wMin),
              Text(
                favorited ? favoritedText : normalText,
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
