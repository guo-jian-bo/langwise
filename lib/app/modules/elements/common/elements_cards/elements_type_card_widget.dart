import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../../common/enum/elements_card_type.dart';
import '../../model/elements_detils_data_model.dart';
import '../../utils/elements_page_utils.dart';
import '../elements_card_box_widget.dart';
import 'elements_morpheme_card.dart';
import 'elements_phrase_card.dart';
import 'elements_sentence_card.dart';
import 'elements_word_card.dart';


class ElementsTypeCardWidget extends StatefulWidget {
  final ElementsCardBoxController? controller;
  final CardSide side;
  final ElementsDetilsDataModel? data;
  final bool jumpToDetail;
  final double jupmTapSclae;
  final void Function(ElementsCardType type)? onPageBack;
  final void Function(ElementsDetilsDataModel? data)? onTap;
  final void Function(ElementsDetilsDataModel? data, GlobalKey cardKey)? onLongPress;
  final bool disableTap;
  final bool showDetailAction;
  const ElementsTypeCardWidget({
    super.key,
    this.data, 
    this.controller,
    this.side = CardSide.FRONT,
    this.jumpToDetail = true,
    this.jupmTapSclae = 1.02,
    this.onPageBack,
    this.disableTap = false,
    this.onTap,
    this.onLongPress,
    this.showDetailAction = true,
  });

  @override
  State<ElementsTypeCardWidget> createState() => _ElementsTypeCardWidgetState();
}

class _ElementsTypeCardWidgetState extends State<ElementsTypeCardWidget> {

  final GlobalKey cardKey = GlobalKey();

  Future<void> _jumpToDetail() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if(widget.onTap != null){
      widget.onTap!(widget.data);
      return;
    }

    await ElementsPageUtils.jumpElementsPage(
      contentId: widget.data?.data?.contentId,
      contentType: widget.data?.data?.contentType,
      semanticId: widget.data?.data?.semanticId,
      styleId: null,
      dialect: null,
      semanticIds: widget.data?.data?.semanticIds,
      content: widget.data?.data?.content,
      pos: widget.data?.data?.pos,
    );
    
    if(widget.data?.data?.contentId == null || widget.data?.data?.contentType == null) return;

    ElementsCardType type = ElementsCardType.fromRawValue(widget.data?.data?.contentType??"");

    widget.onPageBack?.call(type);
  }

  @override
  Widget build(BuildContext context) {
    if(widget.data?.type == null) return Container();
    
    Widget child = Container();

    switch (widget.data!.type) {
      case ElementsCardType.none:
        return Container();
      case ElementsCardType.word:
        child = ElementsWordCardWidget(
          data: widget.data,
          controller: widget.controller,
          side: widget.side,
          onDetailTap: widget.showDetailAction ? () async => _jumpToDetail() : null,
          showDetailAction: widget.showDetailAction,
        );
      case ElementsCardType.phrase:
        child = ElementsPhraseCard(
          data: widget.data,
          controller: widget.controller,
          side: widget.side,
          onDetailTap: widget.showDetailAction ? () async => _jumpToDetail() : null,
          showDetailAction: widget.showDetailAction,
        );
      case ElementsCardType.sentence:
        child = ElementsSentenceCard(
          data: widget.data,
          controller: widget.controller,
          side: widget.side,
          onDetailTap: widget.showDetailAction ? () async => _jumpToDetail() : null,
          showDetailAction: widget.showDetailAction,
        );
      case ElementsCardType.morpheme:
        child = WlementsMorphemeCard(data: widget.data, controller: widget.controller, side: widget.side);
      case ElementsCardType.text:
        child = Container();
      case ElementsCardType.reveal:
        child = Container();
      case ElementsCardType.song:
        child = Container();
      case ElementsCardType.script:
        child = Container();
        break;
    }

    if(!widget.jumpToDetail) return child;

    return TapScaleWidget(
      key: cardKey,
      onLongPress: widget.onLongPress == null ? null : () => widget.onLongPress?.call(widget.data, cardKey),
      onTap: widget.disableTap ? null: _jumpToDetail,
      sclae: widget.jupmTapSclae,
      child: child,
    );
    
  }
}
