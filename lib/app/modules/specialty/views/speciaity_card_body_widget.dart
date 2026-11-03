
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/home_card_code.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';
import '../controllers/specialty_controller.dart';
import 'speciaity_default_widget.dart';
import 'speciaity_phonics_course_card_widget.dart';
import 'speciaity_phonics_default_course_card_widget.dart';

class SpeciaityCardBodyWidget extends GetView<SpecialtyController> {
  final HomeCardEntityItems data;
  const SpeciaityCardBodyWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    ThemeColorEntity? cardColor = StyleUtils.getCurrentThemeColors(data.bgColor);
    Color borderColor = ColorUtils.parseColor(cardColor?.borderColor)??Colors.transparent;
    Gradient? gradient = StyleUtils.parseCssLinearGradient(cardColor?.color);

    Widget bodyWidget = SpeciaityDefaultWidget(data: data);

    if(data.code == HomeCardCode.phonicsCourse && controller.phonicsDatas.isNotEmpty){
      bodyWidget = SpeciaityPhonicsCourseCardWidget(data: data);
    } else if(data.code == HomeCardCode.phonicsInitCourse && controller.defaultPhonicsDatas.isNotEmpty){
      bodyWidget = SpeciaityDefaultPhonicsCourseCardWidget(data: data);
    }

    return TapScaleWidget(
      onTap: () {
        controller.toPageByCode(data, context);
      },
      sclae: 1.005,
      child: Container(
        width: 564.wMin,
        height: 745.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.wMin),
          border: Border.all(
            width: 1.wMin,
            color: borderColor,
          ),
          gradient: gradient,
        ),
        child: bodyWidget,
      ),
    );
  }
}