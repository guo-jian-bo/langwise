

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/official_course_details/official_course_details_dictation/controllers/official_course_details_dictation_controller.dart';
import 'package:langwise/common/values/language_service_code.dart';
import 'package:langwise/common/widgets/icon_dropdown_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class LanguageFilteringPopButton extends StatefulWidget {
  final bool isIosAwait;
  /// 显示语言的筛选
  const LanguageFilteringPopButton({super.key, this.isIosAwait = true});

  @override
  State<LanguageFilteringPopButton> createState() => _LanguageFilteringPopButtonState();
}

class _LanguageFilteringPopButtonState extends State<LanguageFilteringPopButton> {
  final OfficialCourseDetailsDictationController controller = Get.find<OfficialCourseDetailsDictationController>();

  @override
  void initState() {
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    return Obx((){
      List<IconDropdownCheckData<String>> learLangShowSettingMenu = controller.learLangShowSettingMenu;
      LanguageServiceCodeEnum learningLangShowSetting = controller.national.value;
      int selectIndex = learLangShowSettingMenu.indexWhere((element) => element.value == learningLangShowSetting.value);
      return IconDropdownCheckWidget(
        items: controller.learLangShowSettingMenu,
        width: 268.wMin,
        selectIndex: selectIndex,
        sclae: 1.01,
        fontSize: 28.wMin,
        itemHeight: 70.wMin,
        alignRight: true,
        isIosAwait: widget.isIosAwait,
        child: _buildDrapBoyWidget(learLangShowSettingMenu[selectIndex].title),
        onTap: (data, index) {
          controller.setLanguageSetting(data.value);
        },
      );
    });
  }

  Widget _buildDrapBoyWidget(String title){
    return Container(
      padding: EdgeInsets.all(10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Row(
        spacing: 8.wMin,
        children: [
          Text(
            "发音:$title",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary,
            ),
          ),
          SvgPicture.asset(
            "assets/svg/public/icon_arrow_down.svg",
            width: 36.wMin,
            colorFilter: const ColorFilter.mode(AppTheme.cTextPrimary, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
