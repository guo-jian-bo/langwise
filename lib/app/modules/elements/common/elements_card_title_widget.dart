import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';
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
  final VoidCallback? onDetailTap;
  final bool showDetailAction;
  const ElementCardTypeLevelWidget({
    super.key,
    this.minDifficulty,
    this.maxDifficulty,
    this.language,
    this.type = ElementsCardType.none,
    this.name,
    this.pos,
    this.posTitle,
    this.onDetailTap,
    this.showDetailAction = true,
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
          visible:
              type != ElementsCardType.none && name != null && name!.isNotEmpty,
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
              padding:
                  EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: (colorInfo?.color?.bgColor)?.withValues(alpha: 0.2),
              ),
              child: Obx(() {
                LangPreference lang = controller.userSetting.value.expandLang;
                String? posText = posTitle;
                if (lang == LangPreference.original ||
                    lang == LangPreference.none) {
                  posText = pos;
                } else {
                  posText = posTitle;
                }

                return Text(
                  posText ?? "",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: colorInfo?.color?.borderColor ??
                        AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                );
              }),
            ),
          ),
        ),

        Visibility(
          visible: (minDifficulty != null || maxDifficulty != null) &&
              (language ?? '').isNotEmpty,
          child: Container(
            margin: EdgeInsets.only(left: 4.wMin),
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceSoildTertiary,
              border: Border.all(
                color: AppTheme.cBorderSoildSecondary,
                width: 1.wMin,
              ),
            ),
            child: Row(
              children: [
                StatusTagDifficultyWidget(
                  difficulty: minDifficulty,
                  language: language,
                  fontSize: 16.wMin,
                  defaultColor: Colors.transparent,
                  fontColor: AppTheme.cTextSecondary,
                  padding: EdgeInsets.zero,
                ),
                Visibility(
                  visible: maxDifficulty != null &&
                      minDifficulty != null &&
                      maxDifficulty != minDifficulty,
                  child: Text(
                    "-",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: AppTheme.cTextSecondary,
                    ),
                  ),
                ),
                if (maxDifficulty != null &&
                    minDifficulty != null &&
                    maxDifficulty != minDifficulty)
                  StatusTagDifficultyWidget(
                    difficulty: maxDifficulty,
                    language: language,
                    fontSize: 16.wMin,
                    defaultColor: Colors.transparent,
                    fontColor: AppTheme.cTextSecondary,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
        ),

        const Spacer(),

        if (showDetailAction)
          GestureDetector(
            onTap: onDetailTap,
            child: Row(
              children: [
                Text(
                  "查看详情",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextPrimary.color.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(width: 4.wMin),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.wMin,
                  color: AppTheme.cTextPrimary.color.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
