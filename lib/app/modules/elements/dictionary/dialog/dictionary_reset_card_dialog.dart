import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../common/elements_cards/elements_public_card.dart';

class DictionaryResetCardDialog {
  static Future<void> show({
    required BuildContext context,
    required KnowledgeCommonEntityList data,
    required GlobalKey cardKey,
    void Function()? onTap,
  }) async {
    await showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) {
        return _DictionaryResetCardDialogWidget(
          data: data,
          cardKey: cardKey,
          onTap: onTap,
        );
      },
    );
  }
}

class _DictionaryResetCardDialogWidget extends StatefulWidget {
  final KnowledgeCommonEntityList data;
  final GlobalKey cardKey;
  final void Function()? onTap;

  const _DictionaryResetCardDialogWidget({
    required this.data,
    required this.cardKey,
    this.onTap,
  });

  @override
  State<_DictionaryResetCardDialogWidget> createState() =>
      _DictionaryResetCardDialogWidgetState();
}

class _DictionaryResetCardDialogWidgetState
    extends State<_DictionaryResetCardDialogWidget> {
  Offset cardOffset = Offset.zero;
  Size cardSize = Size.zero;
  bool showButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _getCardPosition();
    });
  }

  void _getCardPosition() {
    final RenderBox? renderBox =
        widget.cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    cardOffset = renderBox.localToGlobal(Offset.zero);
    cardSize = renderBox.size;
    if (mounted) setState(() {});
    _movePosition();
  }

  Future<void> _movePosition() async {
    if (cardOffset == Offset.zero) return;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double screenHeight = MediaQuery.of(context).size.height;
    await Future.delayed(const Duration(milliseconds: 300));
    final bool isOverflowTop = cardOffset.dy < 0;
    final double buttonHeight = 56.wMin + 24.wMin;
    final bool isOverflowBottom = cardOffset.dy + cardSize.height >
        screenHeight - bottomPadding - buttonHeight;

    if (isOverflowTop) {
      cardOffset = Offset(
        cardOffset.dx,
        24.wMin + topPadding,
      );
      if (mounted) setState(() {});
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (isOverflowBottom) {
      cardOffset = Offset(
        cardOffset.dx,
        screenHeight - cardSize.height - 24.wMin - bottomPadding - buttonHeight,
      );
      if (mounted) setState(() {});
      await Future.delayed(const Duration(milliseconds: 300));
    }

    showButton = true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Material(
        color: AppTheme.cOverlayBackground.color,
        child: Visibility(
          visible: cardOffset != Offset.zero,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: cardOffset.dx,
                top: cardOffset.dy,
                child: Column(
                  children: [
                    SizedBox(
                      width: cardSize.width,
                      height: cardSize.height,
                      child: ElementsDictReadCard(
                        data: widget.data,
                        showCardStarArea: true,
                      ),
                    ),
                    SizedBox(height: 24.wMin),
                    AnimatedOpacity(
                      opacity: showButton ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: ButtonWidget(
                        text: '重置学习记录',
                        height: 56.wMin,
                        width: 200.wMin,
                        borderRadius: 8.wMin,
                        color: AppTheme.cFeedbackErrorBorder.color,
                        fontColor: AppTheme.cStaticWhite.color,
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w600,
                        sclae: 1.03,
                        onTap: widget.onTap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
