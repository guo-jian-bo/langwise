import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ManageTitleWidget extends StatelessWidget {
  final String? title;
  final TextStyle? textStyle;
  final VoidCallback? onCloseTap;

  const ManageTitleWidget({super.key, this.title, this.textStyle, this.onCloseTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title ?? '',
          style: textStyle ??
              TextStyle(
                fontSize: 22.wMin,
                color: const Color(0xffEBEEF3),
                fontWeight: FontWeight.w400,
              ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: OptimizeUtils.noneThrottle(() {
            onCloseTap?.call();
          }, 200),
          child: buildImage(Assets.managerClose, width: 24.wMax, height: 24.wMax),
        ),
      ],
    );
  }
}
