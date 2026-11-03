import 'dart:async';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:langwise/common/widgets/shimmer_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/curve/custom_curves.dart';
import '../../../../common/entities/entities.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';

class ElementsCardBoxController {
  _ElementsCardBoxWidgetState? state;

  Future<void> toggleCard() async {
    await state?.toggleCard();
  }

  Future<void> startError() async {
    await state?.startError();
  }

  Future<void> startSuccess() async {
    await state?.startSuccess();
  }
}

class ElementsCardBoxWidget extends StatefulWidget {
  final ElementsCardBoxController? controller;
  final CardSide side;
  final Widget? front;
  final ElementsCardStar? star;
  final double? width;
  final double? height;
  const ElementsCardBoxWidget({
    super.key,
    this.controller,
    this.front,
    this.side = CardSide.FRONT,
    this.star,
    this.width,
    this.height,
  });

  @override
  State<ElementsCardBoxWidget> createState() => _ElementsCardBoxWidgetState();
}

class ElementsCardBackWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double? borderRadius;

  const ElementsCardBackWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 334.wMin,
      height: height ?? 534.wMin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 20.wMin),
        child: Image.asset(
          "assets/images/elements/card_bg.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ElementsCardBoxWidgetState extends State<ElementsCardBoxWidget> {
  final FlipCardController _flipCardController = FlipCardController();

  CardSide _side = CardSide.BACK;

  bool _isComplete = false;

  bool _shimmer = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.state = this;
    _side = widget.side;
    if (widget.controller == null) {
      _isComplete = true;
    }
  }

  Future<void> toggleCard() async {
    await _flipCardController.toggleCard();
  }

  Future<void> startError() async {
    await _flipCardController.skew(0.45,
        duration: const Duration(milliseconds: 3000),
        curve: CustomCurves.flipError);
    await _flipCardController.skew(0,
        duration: const Duration(milliseconds: 1000), curve: Curves.bounceOut);
  }

  Future<void> startSuccess() async {
    _shimmer = true;
    if (mounted) setState(() {});
    await _flipCardController.skew(1,
        duration: const Duration(milliseconds: 2000),
        curve: Curves.easeInOutCirc);
    _shimmer = false;
    _isComplete = true;
    _side = CardSide.FRONT;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double width = widget.width ?? 334.wMin;
    final double height = widget.height ?? 534.wMin;

    Color color =
        ColorUtils.parseColor(widget.star?.color) ?? AppTheme.cBorderSecondary;

    Widget buildFrontCard() {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.wMin),
          color: AppTheme.cBgSecondary,
          border: Border.all(
            color: color,
            width: 2.wMin,
          ),
        ),
        child: ShimmerWidget(
          enabled: _shimmer,
          color: color,
          colorOpacity: 0.8,
          duration: const Duration(seconds: 1),
          child: widget.front ?? const SizedBox(),
        ),
      );
    }

    Widget buildBackCard() {
      return ElementsCardBackWidget(
        width: width,
        height: height,
        borderRadius: 20.wMin,
      );
    }

    Widget buildBodyWidget() {
      if (_isComplete) {
        if (_side == CardSide.BACK) {
          return buildBackCard();
        }
        return buildFrontCard();
      }
      return FlipCard(
        controller: _flipCardController,
        flipOnTouch: false,
        side: _side,
        front: buildFrontCard(),
        back: buildBackCard(),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        child: buildBodyWidget(),
      ),
    );
  }
}
