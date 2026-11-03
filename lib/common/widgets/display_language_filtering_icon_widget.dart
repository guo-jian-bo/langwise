

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../entities/entities.dart';
import '../enum/enum.dart';
import '../public_controller/config_controller.dart';
import 'widgets.dart';

class DisplayLanguageFilteringIconWidget extends StatefulWidget {
  final bool isIosAwait;
  final LearModePreference mode;
  final bool excludeHiddenText;
  /// 显示语言的筛选
  const DisplayLanguageFilteringIconWidget({
    super.key,
    this.isIosAwait = false,
    this.mode = LearModePreference.extension,
    this.excludeHiddenText = false,
  });

  @override
  State<DisplayLanguageFilteringIconWidget> createState() => _DisplayLanguageFilteringIconWidgetState();
}

class _DisplayLanguageFilteringIconWidgetState extends State<DisplayLanguageFilteringIconWidget> {
  final ConfigController controller = Get.find<ConfigController>();

  @override
  void initState() {
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    return Obx((){

      List<UserPreferenceDefinitionDisplayModeOption>? dropdownMenu;
      LangPreference? lang;

      if(widget.mode == LearModePreference.course){
        dropdownMenu = controller.userSetting.value.courseDropdownMenu;
        lang = controller.userSetting.value.courseLang;
      }else{
        dropdownMenu = controller.userSetting.value.expandDropdownMenu;
        lang = controller.userSetting.value.expandLang;
      }
      
      if(dropdownMenu == null) return Container();

      if (widget.excludeHiddenText) {
        dropdownMenu = dropdownMenu
            .where((e) => e.code != LangPreference.none.code)
            .toList();
        if (lang == LangPreference.none) {
          Future.microtask(() {
            controller.setLearLangSetting(
              LangPreference.bilingual.code,
              widget.mode,
            );
          });
        }
      }

      List<IconDropdownCheckData<String>> learLangShowSettingMenu = dropdownMenu.map((e) => IconDropdownCheckData<String>(value: e.code??"", title: e.title??"")).toList();

      int selectIndex = learLangShowSettingMenu.indexWhere((element) => element.value == lang?.code);

      if(selectIndex == -1) return Container();
      return IconDropdownCheckWidget(
        items: learLangShowSettingMenu,
        width: 350.wMin,
        selectIndex: selectIndex,
        sclae: 1.01,
        fontSize: 28.wMin,
        itemHeight: 70.wMin,
        isIosAwait: widget.isIosAwait,
        child: _buildDrapBoyWidget(learLangShowSettingMenu[selectIndex].title),
        onTap: (IconDropdownCheckData data, int index) {
          controller.setLearLangSetting(data.value!, widget.mode);
        },
      );
    });
  }

  Widget _buildDrapBoyWidget(String title){
    return Container(
      color: Colors.transparent,
      child: Row(
        spacing: 8.wMin,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
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
