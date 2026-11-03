import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../model/elements_detils_data_model.dart';
import '../elements_card_box_widget.dart';
import '../elements_card_body_widget.dart';
import '../elements_card_star_level_widget.dart';
import '../elements_card_title_widget.dart';

class ElementsSentenceCard extends StatefulWidget {
  final ElementsCardBoxController? controller;
  final CardSide side;
  final ElementsDetilsDataModel? data;

  /// 句子卡
  const ElementsSentenceCard({
    super.key,
    this.controller,
    this.side = CardSide.FRONT,
    this.data,
  });

  @override
  State<ElementsSentenceCard> createState() => _ElementsSentenceCardState();
}

class _ElementsSentenceCardState extends State<ElementsSentenceCard> {
  final ConfigController configController = Get.find<ConfigController>();

  @override
  Widget build(BuildContext context) {
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
            ElemenetsCardStarLevelWidget(
              star: widget.data?.data?.cardStar,
              hideStar: widget.data?.hideStar??false,
            ),
            SizedBox(height: 6.wMin),
            AspectRatio(
              aspectRatio: 1,
              child: ElementsCardBodyWidget(
                pronunciations: widget.data?.data?.pronunciations,
                child: Container(
                  color: AppTheme.cBlackAlpha10,
                  child: CachedImageWidget(
                    widget.data?.data?.imageUrl ?? "",
                    errorWidget: buildEmptyWidget(),
                    placeholder: buildLoadingWidget(),
                    fadeInDuration: Duration.zero,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.wMin),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: AppTheme.cBgTertiary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.data!.data?.content ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    Obx(() {
                      LanguageText? gloss = LearningLangUtils.getShowForNone(widget.data!.data?.gloss);
                      if(gloss?.text == widget.data!.data?.content) return Container();
                      return Container(
                        margin: EdgeInsets.only(top: 4.wMin),
                        child: Text(
                          gloss?.text ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w500,
                            height: 1,
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
              type: widget.data!.type,
              name: widget.data!.data?.contentTypeTitle ?? "",
              minDifficulty: widget.data!.data?.difficulty?.min,
              maxDifficulty: widget.data!.data?.difficulty?.max,
              language: configController.userSetting.value.learningLang,
              pos: widget.data!.data?.pos,
              posTitle: widget.data!.data?.posTitle,
            ),
          ],
        ),
      ),
    );
  }
}
