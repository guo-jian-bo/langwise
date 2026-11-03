import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';

class ElementsCardBodyWidget extends StatefulWidget {
  final Widget? child;
  final double? borderRadius;
  final List<PronunciationsEntity?>? pronunciations;
  final int? minDifficulty;
  final int? maxDifficulty;
  final String? language;
  const ElementsCardBodyWidget(
      {super.key,
      this.child,
      this.borderRadius,
      this.pronunciations,
      this.minDifficulty,
      this.maxDifficulty,
      this.language});

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
              borderRadius:
                  BorderRadius.circular(widget.borderRadius ?? 16.wMin),
              child: widget.child,
            ),
          ),
          Visibility(
              visible:
                  widget.minDifficulty != null || widget.maxDifficulty != null,
              child: Positioned(
                  top: 10.wMin,
                  left: 10.wMin,
                  right: 0,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.wMin),
                        // 限制模糊范围不溢出，同时保持标签圆角
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.wMin, vertical: 2.wMin),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.wMin),
                              color: Colors.black.withValues(alpha: 0.32),
                            ),
                            child: Row(
                              children: [
                                StatusTagDifficultyWidget(
                                  difficulty: widget.minDifficulty,
                                  language: widget.language,
                                  fontSize: 16.wMin,
                                  defaultColor: Colors.transparent,
                                  fontColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                ),
                                Visibility(
                                  visible: widget.maxDifficulty != null &&
                                      widget.minDifficulty != null,
                                  child: Text(
                                    "-",
                                    style: TextStyle(
                                        fontSize: 16.wMin, color: Colors.white),
                                  ),
                                ),
                                StatusTagDifficultyWidget(
                                  difficulty: widget.maxDifficulty,
                                  language: widget.language,
                                  fontSize: 16.wMin,
                                  defaultColor: Colors.transparent,
                                  fontColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ))),
          Visibility(
            visible: widget.pronunciations?.isNotEmpty ?? false,
            child: Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    List.generate(widget.pronunciations?.length ?? 0, (index) {
                  return PlayLottieIconWidget(
                    size: 48.wMin,
                    audioUrl: widget.pronunciations?[index]?.audioUrl,
                    backgroundImageUrl:
                        widget.pronunciations?[index]?.nationalIconUrl,
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
