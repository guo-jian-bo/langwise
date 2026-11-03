
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ListingAndDelistingWidget extends StatelessWidget {
  final bool value;
  final void Function()? onChange;
  final bool showBorder;
  final bool showSwitch;
  /// 上下架widget
  const ListingAndDelistingWidget({
    super.key, 
    this.showBorder = true,
    this.value = false, 
    this.onChange,
    this.showSwitch = true,
});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 12.wMin, left: 12.wMin),
      decoration: showBorder ? BoxDecoration(
        border: Border(
          right: BorderSide(width: 1.wMin, color: AppTheme.cBorderTertiary.color),
        ),
      ) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value ?  "上架" : "下架",
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 4.wMin),
          Visibility(
            visible: showSwitch,
            child: CardSwitchWidget(
              value: value,
              width: 50.wMin,
              height: 28.wMin,
              switchActiveColor: AppTheme.cSurfaceSuccess.color,
              switchInactiveColor: AppTheme.cSurfaceQuaternary.color,
              onChanged: (value) {
                onChange?.call();
              },
            ),
          ),
        ],
      ),
    );
  }
}