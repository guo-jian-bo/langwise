import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class TopTabBarWidget extends StatefulWidget {
  final int index;
  final String? title;
  final String leftIcon;
  final String? rightIcon;
  final bool isSelected;
  final Color backColor;
  final double sclae;
  final Function(int)? onTap;

  const TopTabBarWidget({
    super.key,
    required this.index,
    this.title,
    this.leftIcon = Assets.manageIconSearch,
    this.rightIcon,
    this.isSelected = false,
    this.onTap,
    this.backColor = const Color(0xFF23283D),
    this.sclae = 1.1,
  });

  @override
  State<TopTabBarWidget> createState() => _TopTabBarWidgetState();
}

class _TopTabBarWidgetState extends State<TopTabBarWidget> with SafeSetStateMixin {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      sclae: widget.sclae,
        onTap: OptimizeUtils.noneThrottle(() {
          widget.onTap?.call(widget.index);
        }, 200),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            safeSetState(() {
              _isHover = true;
            });
          },
          onExit: (event) {
            safeSetState(() {
              _isHover = false;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.wMin, horizontal: 10.wMin),
            // width: 90.ww,
            decoration: _isHover
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: widget.backColor,
                  )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  widget.leftIcon,
                  width: 18.ww,
                  height: 18.ww,
                ),
                Gaps.getWidth(8.ww),
                Text(
                  widget.title ?? '',
                  style: TextStyle(
                    color: const Color(0xffEDF0F4),
                    fontSize: Dimens.font_sp18.wMin,
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                  ),
                ),
                Visibility(
                  visible: widget.rightIcon != null,
                  child: Container(
                    margin: EdgeInsets.only(left: 5.wMin),
                    child: SvgPicture.asset(
                      widget.rightIcon??"",
                      width: 18.ww,
                      height: 18.ww,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class TopFilterTabBarWidget extends StatefulWidget {
  final int index;
  final String? title;
  final String? leftIcon;
  final String? rightIcon;
  final bool isSelected;
  final Color backColor;
  final Function(int)? onTap;

  const TopFilterTabBarWidget({
    super.key,
    required this.index,
    this.title,
    this.leftIcon = Assets.managerSearch,
    this.rightIcon = Assets.managerChevronDown,
    this.isSelected = false,
    this.onTap,
    this.backColor = const Color(0xFF23283D),
  });

  @override
  State<TopFilterTabBarWidget> createState() => _TopFilterTabBarWidgetState();
}

class _TopFilterTabBarWidgetState extends State<TopFilterTabBarWidget> with SafeSetStateMixin {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() {
          widget.onTap?.call(widget.index);
        }, 200),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            safeSetState(() {
              _isHover = true;
            });
          },
          onExit: (event) {
            safeSetState(() {
              _isHover = false;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 6.wh),
            width: 90.ww,
            decoration: _isHover
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: widget.backColor,
                    border: Border.all(
                      color: _isHover ? const Color(0xFF2388FF) : const Color(0xFF444B5F),
                      width: 0.5, // 边框宽度
                    ),
                  )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildImage(
                  widget.leftIcon!,
                  width: 18.ww,
                  height: 18.ww,
                ),
                Gaps.getWidth(8.ww),
                Text(
                  widget.title ?? '',
                  style: TextStyle(
                    color: const Color(0xffEDF0F4),
                    fontSize: Dimens.font_sp18.wMin,
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                  ),
                ),
                Gaps.getWidth(8.ww),
                buildImage(
                  widget.rightIcon!,
                  width: 18.ww,
                  height: 18.ww,
                ),
              ],
            ),
          ),
        ));
  }
}
