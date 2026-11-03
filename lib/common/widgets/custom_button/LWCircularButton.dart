
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../theme/theme.dart';
import '../tap_scale_widget.dart';
/*
tabar组件，
外部用 EdgeInsets.symmetric(vertical: 12.wMin),
margin: EdgeInsets.only(left: 12.wMin),
 */
class LWCircularButtonWidget extends StatefulWidget {
  final String text;
  final bool isAction;
  final void Function()? onTap;
  final double sclae;
  final  Color?color;
  const LWCircularButtonWidget({
    super.key,
    required this.text,
    this.onTap,
    this.sclae = 1.03,
    this.isAction = false,
    this.color,


  });

  @override
  State<LWCircularButtonWidget> createState() => _LWCircularButtonWidgetState();
}

class _LWCircularButtonWidgetState extends State<LWCircularButtonWidget> {

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: () {
        widget.onTap?.call();
      },
      sclae: 1,
      child: Container(
        height: 56.wMin,
        padding: EdgeInsets.only(left: 16.wMin, right: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: widget.isAction?widget.color?.withValues(alpha: 0.12):Colors.transparent,
          border: Border.all(
            color: widget.isAction?widget.color!.withValues(alpha: 0.2):Colors.transparent,
            width: 0.8.wMin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [


            Text(
              widget.text,
              style: TextStyle(
                color:widget.isAction?widget.color: AppTheme.cTextPrimary.color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
