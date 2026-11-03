import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class UnitItemWidget extends StatelessWidget {
  final int index;
  final String title;
  final bool isNeedIcon;
  final Function(int)? onTap;

  const UnitItemWidget({super.key, required this.index, required this.title, this.isNeedIcon = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: OptimizeUtils.noneThrottle(() {
        onTap?.call(index);
      }, 100),
      child: Container(
        alignment: const Alignment(0, 0),
        padding: EdgeInsets.only(left: 8.ww, right: 8.ww, top: 5.wh, bottom: 5.wh),
        margin: EdgeInsets.only(bottom: isNeedIcon ? 0 : 8.wh),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.wMin),
          color: const Color(0xff353E5C),
        ),
        child: Row(
          mainAxisAlignment: isNeedIcon ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
          children: [
            Flexible(
                child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xffACB4C0),
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                height: 1.0,
              ),
            )),
            if (isNeedIcon) buildImage(Assets.managerTableItemDown, width: 20.ww, height: 20.ww),
          ],
        ),
      ),
    );
  }
}
