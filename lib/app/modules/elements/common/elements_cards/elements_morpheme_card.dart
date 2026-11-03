import 'package:auto_size_text/auto_size_text.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../model/elements_detils_data_model.dart';
import '../elements_card_box_widget.dart';
import '../elements_card_body_widget.dart';
import '../elements_card_title_widget.dart';

class WlementsMorphemeCard extends StatefulWidget {
  final ElementsCardBoxController? controller;
  final CardSide side;
  final ElementsDetilsDataModel? data;
  /// 词素
  const WlementsMorphemeCard({
    super.key,
    this.controller, 
    this.side = CardSide.FRONT, 
    this.data,
  });

  @override
  State<WlementsMorphemeCard> createState() => _WlementsMorphemeCardState();
}

class _WlementsMorphemeCardState extends State<WlementsMorphemeCard> {
  final ConfigController configController = Get.find<ConfigController>();


  @override
  Widget build(BuildContext context) {
    if(widget.data == null) return Container();

    Color color = StatusUtils.getMorphemeTagColor(widget.data?.data?.pos);

    String before = "";
    String after = "";
    String? posContent = "";

    if(widget.data?.data?.contentList?.isNotEmpty??false){
      posContent = widget.data?.data?.content?.replaceAll("-", "");
      String word = widget.data?.data?.contentList?.first?.content??"";
      int index = word.indexOf(posContent??"");

      if(index != -1){
        before = word.substring(0, index); // "dis" 之前的部分
        after = word.substring(index + (posContent?.length??0)); // "dis" 之后的部分
      }
    }

    return ElementsCardBoxWidget(
      controller: widget.controller,
      side: widget.side,
      star: widget.data?.data?.cardStar,
      front: Container(
        padding: EdgeInsets.only(
          left: 8.wMin,
          right: 8.wMin,
          bottom: 10.wMin,
        ),
        child: Column(
          children: [
            // ElemenetsCardStarLevelWidget(star: widget.data?.data?.cardStar),
            // SizedBox(height: 6.wMin),
            SizedBox(height: 16.wMin),
            AspectRatio(
              aspectRatio: 1,
              child: ElementsCardBodyWidget(
                pronunciations: widget.data?.data?.pronunciations,
                borderRadius: 10.wMin,
                child: AutoSizeText(
                  widget.data?.data?.content??"",
                  maxLines: 1,
                  minFontSize: 12,
                  style: TextStyle(
                    fontSize: 75.wMin,
                    color: color,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1.8.wMin,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.wMin),
            Expanded(
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: AppTheme.cBgTertiary,
                ),
                child: Text.rich(TextSpan(
                  style: TextStyle(
                    fontSize: 32.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(text: before),
                    TextSpan(
                      text: posContent, 
                      style: TextStyle(color: color),
                    ),
                    TextSpan(text: after),
                  ],
                )),
              ),
            ),
            SizedBox(height: 8.wMin),
            ElementCardTypeLevelWidget(
              type: widget.data!.type,
              name: widget.data!.data?.contentTypeTitle??"",
              minDifficulty: widget.data!.data?.difficulty?.min,
              maxDifficulty: widget.data!.data?.difficulty?.max,
              language: configController.userSetting.value.learningLang,
            ),
          ],
        ),
      ),
    );
  }
}