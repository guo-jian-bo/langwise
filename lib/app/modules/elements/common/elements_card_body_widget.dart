

import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';


class ElementsCardBodyWidget extends StatefulWidget {
  final Widget? child;
  final double? borderRadius;
  final List<PronunciationsEntity?>? pronunciations;
  const ElementsCardBodyWidget({super.key, this.child, this.borderRadius, this.pronunciations});

  @override
  State<ElementsCardBodyWidget> createState() => _ElementsCardBodyWidgetState();
}

class _ElementsCardBodyWidgetState extends State<ElementsCardBodyWidget> {


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cBgTertiary,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(4.wMin),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius??16.wMin),
              child: widget.child,
            ),
          ),
          Visibility(
            visible: widget.pronunciations?.isNotEmpty ?? false,
            child: Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(widget.pronunciations?.length ?? 0, (index) {
                  return PlayLottieIconWidget(
                    size: 48.wMin,
                    audioUrl: widget.pronunciations?[index]?.audioUrl,
                    backgroundImageUrl: widget.pronunciations?[index]?.nationalIconUrl,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



