import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

mixin GetViewMixin on StatelessWidget {
  // title
  Widget buildTitleWidget(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.wMin,
            color: const Color(0xffEBEEF3),
            fontWeight: FontWeight.w400,
          ),
        ),
        Gaps.getWidth(2.ww),
        Expanded(
          child: Divider(
            height: 1.wMin,
            color: const Color(0xff4B5268),
          ),
        )
      ],
    );
  }

  // 添加按钮
  Widget buildAddWidget(VoidCallback onTap) {
    return TapScaleWidget(
      onTap: () {
        onTap.call();
      },
      sclae: 1.03,
      child: DottedBorder(
        radius: Radius.circular(8.wMin),
        borderType: BorderType.RRect,
        padding: EdgeInsets.zero,
        color: const Color(0xff444B5F),
        dashPattern: const [1, 2],
        strokeWidth: 1.wMin,
        child: Container(
          alignment: Alignment.center,
          height: 48.wh,
          child: SvgPicture.asset(
            "assets/svg/manage/icon_add.svg",
            height: 22.ww,
          ),
        ),
      ),
    );
  }
}
