import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../model/elements_detils_data_model.dart';
import 'elements_card_body_widget.dart';
import 'elements_card_media_widget.dart';
import 'elements_card_star_level_widget.dart';
import 'elements_card_title_widget.dart';

class ElementsCardFrontPanelWidget extends StatelessWidget {
  final ElementsDetilsDataModel data;
  final VoidCallback? onDetailTap;
  final double contentFontSize;
  final double contentHeight;
  final int contentMaxLines;
  final double glossFontSize;
  final double glossHeight;
  final int glossMaxLines;
  final bool hideGlossWhenSameAsContent;
  final bool showDetailAction;

  const ElementsCardFrontPanelWidget({
    super.key,
    required this.data,
    this.onDetailTap,
    required this.contentFontSize,
    required this.contentHeight,
    this.contentMaxLines = 2,
    required this.glossFontSize,
    required this.glossHeight,
    this.glossMaxLines = 2,
    this.hideGlossWhenSameAsContent = false,
    this.showDetailAction = true,
  });

  ConfigController get _configController => Get.find<ConfigController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 8.wMin,
        right: 8.wMin,
        bottom: 10.wMin,
      ),
      child: Column(
        children: [
          ElemenetsCardStarLevelWidget(
            star: data.data?.cardStar,
            hideStar: data.hideStar,
          ),
          SizedBox(height: 6.wMin),
          AspectRatio(
            aspectRatio: 1,
            child: ElementsCardBodyWidget(
              minDifficulty: data.data?.difficulty?.min,
              maxDifficulty: data.data?.difficulty?.max,
              language: _configController.userSetting.value.learningLang,
              pronunciations: data.data?.pronunciations,
              child: ElementsCardMediaWidget(data: data.data),
            ),
          ),
          SizedBox(height: 6.wMin),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                color: AppTheme.cBgTertiary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.data?.content ?? "",
                    maxLines: contentMaxLines,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: contentFontSize,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                      height: contentHeight,
                    ),
                  ),
                  Obx(() {
                    LanguageText? gloss = LearningLangUtils.getShowForNone(data.data?.gloss);
                    final String glossText = gloss?.text ?? "";
                    final bool hideGloss = glossText.isEmpty || (hideGlossWhenSameAsContent && glossText == data.data?.content);
                    if (hideGloss) return Container();
                    return Container(
                      margin: EdgeInsets.only(top: 6.wMin),
                      child: Text(
                        glossText,
                        maxLines: glossMaxLines,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: glossFontSize,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w500,
                          height: glossHeight,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.wMin),
          ElementCardTypeLevelWidget(
            type: data.type,
            name: data.data?.contentTypeTitle ?? "",
            minDifficulty: data.data?.difficulty?.min,
            maxDifficulty: data.data?.difficulty?.max,
            language: _configController.userSetting.value.learningLang,
            pos: data.data?.pos,
            posTitle: data.data?.posTitle,
            onDetailTap: onDetailTap,
            showDetailAction: showDetailAction,
          ),
        ],
      ),
    );
  }
}
