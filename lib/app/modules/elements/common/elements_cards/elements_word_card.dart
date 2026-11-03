import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../model/elements_detils_data_model.dart';
import '../elements_card_box_widget.dart';
import '../elements_card_front_panel_widget.dart';

class ElementsWordCardWidget extends StatefulWidget {
  final ElementsCardBoxController? controller;
  final CardSide side;
  final ElementsDetilsDataModel? data;
  final VoidCallback? onDetailTap;
  final bool showDetailAction;

  /// 单词卡
  const ElementsWordCardWidget({
    super.key,
    this.controller,
    this.side = CardSide.FRONT,
    this.data,
    this.onDetailTap,
    this.showDetailAction = true,
  });

  @override
  State<ElementsWordCardWidget> createState() => _ElementsWordCardWidgetState();
}

class _ElementsWordCardWidgetState extends State<ElementsWordCardWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) return Container();

    return ElementsCardBoxWidget(
      controller: widget.controller,
      side: widget.side,
      star: widget.data?.data?.cardStar,
      front: ElementsCardFrontPanelWidget(
        data: widget.data!,
        onDetailTap: widget.onDetailTap,
        showDetailAction: widget.showDetailAction,
        contentFontSize: 32.wMin,
        contentHeight: 0.9,
        glossFontSize: 20.wMin,
        glossHeight: 1.2,
      ),
    );
  }
}
