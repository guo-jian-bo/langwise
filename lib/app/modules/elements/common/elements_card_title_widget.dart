import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';
import '../../../../common/enum/elements_card_type.dart';

class ElementCardTypeLevelWidget extends StatelessWidget {
  final int? minDifficulty;
  final int? maxDifficulty;
  final String? language;
  final ElementsCardType type;
  final String? name;
  final String? pos;
  final String? posTitle;
  const ElementCardTypeLevelWidget({
    super.key, 
    this.minDifficulty, 
    this.maxDifficulty, 
    this.language, 
    this.type = ElementsCardType.none, 
    this.name,
    this.pos,
    this.posTitle,
  });

  @override
  Widget build(BuildContext context) {

    final ConfigController controller = Get.find<ConfigController>();
    
    LanguageConfigColorModel? colorInfo = StatusUtils.getConfigColorForAbbr(
      controller.colorConfigs.value.pos, 
      pos,
    );
    
    return Row(
      children: [
        Visibility(
          visible: type != ElementsCardType.none && name != null && name!.isNotEmpty,
          child: StatusKnowlegeTypeTagWidget(
            type: type,
            value: name,
          ),
        ),
        // 词性
        Visibility(
          visible: pos != null && posTitle != null,
          child: Container(
            margin: EdgeInsets.only(left: 4.wMin),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.wMin),
                color: (colorInfo?.color?.bgColor)?.withValues(alpha: 0.2),
                border: Border.all(width: 1.wMin, color: colorInfo?.color?.borderColor??Colors.transparent),
              ),
              child: Obx((){
                LangPreference lang = controller.userSetting.value.expandLang;
                String? posText = posTitle;
                if(lang == LangPreference.original || lang == LangPreference.none){
                  posText = pos;
                }else{
                  posText = posTitle;
                }

                return Text(
                  posText??"",
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: colorInfo?.color?.borderColor??AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                );
              }),
            ),
          ),
        ),
        const Spacer(),
        Visibility(
          visible: minDifficulty != null || maxDifficulty != null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cBgTertiary,
            ),
            child: Row(
              children: [
                StatusTagDifficultyWidget(
                  difficulty: minDifficulty,
                  language: language,
                  fontSize: 16.wMin,
                  defaultColor: Colors.transparent,
                  fontColor: AppTheme.cTextDisabled,
                  padding: EdgeInsets.zero,
                ),
                Visibility(
                  visible: maxDifficulty != null && minDifficulty != null,
                  child: Text(
                    "-",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: AppTheme.cTextDisabled,
                    ),
                  ),
                ),
                StatusTagDifficultyWidget(
                  difficulty: maxDifficulty,
                  language: language,
                  fontSize: 16.wMin,
                  defaultColor: Colors.transparent,
                  fontColor: AppTheme.cTextDisabled,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }
}