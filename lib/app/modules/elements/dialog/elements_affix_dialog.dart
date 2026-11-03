import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/status_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../utils/utils.dart';

/// 前后缀弹窗
class ElementsAffixDialog {
  static Future<void> show({
    required BuildContext context,
    required CardMorphemeDetilsEntity data,
  }) async {
    await showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ElementsAffixDialogWidget(data: data);
      },
    );
  }
}

class ElementsAffixDialogWidget extends StatefulWidget {
  final CardMorphemeDetilsEntity data;
  const ElementsAffixDialogWidget({super.key, required this.data});

  @override
  State<ElementsAffixDialogWidget> createState() =>
      _ElementsAffixDialogWidgetState();
}

class _ElementsAffixDialogWidgetState extends State<ElementsAffixDialogWidget> {
  final ConfigController configController = Get.find<ConfigController>();

  double _calculateTextSize(String text) {
    final TextStyle textStyle = TextStyle(
      fontSize: 32.wMin,
      fontWeight: FontWeight.w600,
      color: AppTheme.cStaticWhite,
    );

    // 获取文字的宽度
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.size.width + 20.wMin;
  }

  @override
  Widget build(BuildContext context) {
    String learningLang =
        Get.find<ConfigController>().userSetting.value.learningLang;

    Color color = StatusUtils.getMorphemeTagColor(widget.data.type);

    double textWidth = _calculateTextSize(widget.data.content ?? "");

    List<List<LanguageText?>?> posLinks = widget.data.posLinks ?? [];

    List<LanguageText> typeNameList =
        LearningLangUtils.getShowLBList(widget.data.typeName);
    List<LanguageText> meaningList =
        LearningLangUtils.getShowLBList(widget.data.meaning);
    List<LanguageText> learnTipsList =
        LearningLangUtils.getShowLBList(widget.data.learnTips);

    return GestureDetector(
      onTap: () => Get.back(),
      child: Material(
        color: AppTheme.cOverlayBackground,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 720.wMin,
              padding: EdgeInsets.all(48.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.wMin),
                color: AppTheme.cBgTertiary,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: textWidth,
                        height: textWidth,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                        child: Center(
                          child: Text(
                            widget.data.content ?? "",
                            style: TextStyle(
                              fontSize: 32.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cStaticWhite,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 24.wMin),
                      Text(
                        "${typeNameList.map((e) => e.text).join(' ')}·${widget.data.origin ?? ''}",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40.wMin),
                  Text(
                    "含义",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary,
                    ),
                  ),
                  SizedBox(height: 8.wMin),
                  Column(
                    spacing: 4.wMin,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(meaningList.length, (index) {
                      if (index == 0) {
                        return Text(
                          meaningList[index].text ?? '',
                          style: TextStyle(
                            fontSize: 24.wMin,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.cTextPrimary,
                          ),
                        );
                      }
                      return Text(
                        meaningList[index].text ?? '',
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextSecondary,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 32.wMin),
                  Text(
                    "学习提示",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary,
                    ),
                  ),
                  SizedBox(height: 8.wMin),
                  Column(
                    spacing: 4.wMin,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(learnTipsList.length, (index) {
                      if (index == 0) {
                        return Text(
                          learnTipsList[index].text ?? '',
                          style: TextStyle(
                            fontSize: 24.wMin,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.cTextPrimary,
                          ),
                        );
                      }
                      return Text(
                        learnTipsList[index].text ?? '',
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: color,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 32.wMin),
                  Visibility(
                    visible: posLinks.isNotEmpty,
                    child: Text(
                      "常见词性",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextTertiary,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.wMin),
                  Wrap(
                    spacing: 8.wMin,
                    runSpacing: 8.wMin,
                    children: List.generate(posLinks.length, (index) {
                      List<LanguageText> learningLangTexts =
                          LearningLangUtils.getShowLBList(posLinks[index]);

                      String pos = "";
                      for (int i = 0; i < learningLangTexts.length; i++) {
                        if (learningLangTexts[i].lang == learningLang) {
                          pos = learningLangTexts[i].text ?? "";
                          continue;
                        }
                      }

                      LanguageConfigColorModel? colorConfig =
                          StatusUtils.getConfigColorForAbbr(
                              configController.colorConfigs.value.pos, pos);
                      final Color tagBackgroundColor =
                          (colorConfig?.color?.bgColor ??
                                  AppTheme.cBgBrand.color)
                              .withValues(alpha: 0.2);
                      final Color tagTextColor =
                          colorConfig?.color?.borderColor ??
                              AppTheme.cTextPrimary;

                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.wMin,
                          vertical: 2.wMin,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.wMin),
                          color: tagBackgroundColor,
                        ),
                        child: Text(
                          learningLangTexts.map((e) => e.text).join(" "),
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w400,
                            color: tagTextColor,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
