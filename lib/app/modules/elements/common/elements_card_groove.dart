
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/list_animation_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/enum/elements_card_type.dart';
import '../model/elements_detils_data_model.dart';
import 'elements_card_front_panel_widget.dart';
import 'elements_cards/elements_type_card_widget.dart';


class ElementsCardGroove extends StatelessWidget {
  final int index;
  final bool isAnimating;
  final int animateionIndex;
  final ElementsDetilsDataModel? data;
  final void Function(ElementsCardType type)? onPageBack;
  final void Function(ElementsDetilsDataModel? data)? onTap;
  final void Function(ElementsDetilsDataModel? data, GlobalKey cardKey)? onLongPress;
  final bool disableImagePreview;
  final bool useOptimizedTextLayout;
  final double? cardHeight;
  final ElementsCardTextHighlightConfig? textHighlightConfig;
  const ElementsCardGroove({
    super.key, 
    required this.index, 
    this.isAnimating = false,
    this.animateionIndex = -1,
    this.data,
    this.onPageBack,
    this.onTap,
    this.onLongPress,
    this.disableImagePreview = false,
    this.useOptimizedTextLayout = false,
    this.cardHeight,
    this.textHighlightConfig,
  });

  @override
  Widget build(BuildContext context) {
    if(data == null) return Container();

    return Visibility(
      visible: data!.type != ElementsCardType.none,
      child: ListAnimationWidget(
        verticalOffset: 48.wMin,
        duration: Duration(milliseconds: isAnimating && animateionIndex == index ? 300 : 0),
        child: ElementsTypeCardWidget(
          data: data,
          jupmTapSclae: 1.01,
          onPageBack: onPageBack,
          onTap: onTap,
          onLongPress: onLongPress,
          disableImagePreview: disableImagePreview,
          useOptimizedTextLayout: useOptimizedTextLayout,
          cardHeight: cardHeight,
          textHighlightConfig: textHighlightConfig,
        ),
      ),
    );
  }

}
