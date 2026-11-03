import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../model/elements_detils_data_model.dart';
import '../elements_card_box_widget.dart';
import '../elements_card_front_panel_widget.dart';

class ElementsPhraseCard extends StatefulWidget {
  final ElementsCardBoxController? controller;
  final CardSide side;
  final ElementsDetilsDataModel? data;
  final VoidCallback? onDetailTap;
  final bool showDetailAction;
  final bool disableImagePreview;
  final bool useOptimizedTextLayout;
  final double? cardHeight;

  /// 短语卡
  const ElementsPhraseCard({
    super.key,
    this.controller,
    this.side = CardSide.FRONT,
    this.data,
    this.onDetailTap,
    this.showDetailAction = true,
    this.disableImagePreview = false,
    this.useOptimizedTextLayout = false,
    this.cardHeight,
  });

  @override
  State<ElementsPhraseCard> createState() => _ElementsPhraseCardState();
}

class _ElementsPhraseCardState extends State<ElementsPhraseCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.data == null) return Container();

    return ElementsCardBoxWidget(
      controller: widget.controller,
      side: widget.side,
      star: widget.data?.data?.cardStar,
      height: widget.cardHeight,
      front: ElementsCardFrontPanelWidget(
        data: widget.data!,
        onDetailTap: widget.onDetailTap,
        showDetailAction: widget.showDetailAction,
        disableImagePreview: widget.disableImagePreview,
        useOptimizedTextLayout: widget.useOptimizedTextLayout,
        contentFontSize: 28.wMin,
        contentHeight: 1.0,
        glossFontSize: 20.wMin,
        glossHeight: 1.2,
      ),
    );
  }
}
