import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';

class ElementsArrowButton extends StatelessWidget {
  final String name;
  final void Function()? onTap;
  const ElementsArrowButton({super.key, required this.name, this.onTap});

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.05,
      child: Container(
        padding: EdgeInsets.only(left: 16.wMin, right: 8.wMin, top: 6.wMin, bottom: 6.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff1A1C20),
        ),
        child: Row(
          spacing: 6.wMin,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 24.wMin,
                color: const Color(0xffA4ABB8),
                fontWeight: FontWeight.w400,
              ),
            ),
            SvgPicture.asset("assets/svg/public/icon_arrow_down.svg", width: 24.wMin),
          ],
        ),
      ),
    );
  }
}