import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import '../../utils/utils.dart';
import '../entities/entities.dart';
import 'widgets.dart';

class PronunciationsColorWidget extends StatelessWidget {
  final String? content;
  final String? ipa;
  final List<PronunciationsEntity?>? pronunciations;
  final TextStyle style;
  final String? national;
  final bool showArrow;
  final int maxLines;
  const PronunciationsColorWidget({
    super.key,
    required this.content,
    required this.ipa,
    required this.pronunciations,
    required this.style,
    required this.national,
    this.showArrow = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    if ((pronunciations ?? []).isEmpty || content == null || ipa == null || national == null) {
      return Text(
        content ?? "", 
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    List<PronunciationsEntityIpa?>? phonetics;
    for (int i = 0; i < (pronunciations?.length ?? 0); i++) {
      if (pronunciations?[i] == null) continue;
      if (pronunciations?[i]?.national == national) {
        phonetics = pronunciations?[i]?.phonetics;
      }
    }

    // 着色
    List<int> positions = [];
    if (phonetics != null && phonetics.isNotEmpty) {
      for (var ipaData in phonetics) {
        if (ipaData != null && ipaData.ipa != null && ipaData.ipa!.isNotEmpty) {
          String ipaStr = ipaData.ipa!;
          if (ipa == ipaStr) {
            for (int? pos in ipaData.positions ?? []) {
              if (pos != null) {
                positions.add(pos);
              }
            }
          }
        }
      }
    }

    

    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              // color: Colors.yellow,
              constraints: BoxConstraints(
                maxWidth: maxWidth - 30.wMin,
              ),
              child: AutoSizeText.rich(
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                minFontSize: 10,
                TextSpan(
                  style: style,
                  children: List.generate((content?.length ?? 0), (index) {
                    return TextSpan(
                      text: content?[index],
                      style: TextStyle(
                        color: positions.contains(index) ? AppTheme.cInversePrimary.color : style.color,
                      ),
                    );
                  }),
                ),
              ),
            ),
            Visibility(
              visible: showArrow,
              child: Container(
                margin: EdgeInsets.only(top: (style.fontSize??0) / 6),
                child: SvgPicture.asset(
                  "assets/svg/public/icon_w_arrow_right.svg",
                  width: 28.wMin,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 显示音标
class PronunciationsPlayIpaTextWidget extends StatefulWidget {
  final String? ipa;
  final List<PronunciationsEntity?>? pronunciations;
  final TextStyle style;
  final String? national;
  const PronunciationsPlayIpaTextWidget({super.key, this.ipa, this.pronunciations, required this.style, this.national});

  @override
  State<PronunciationsPlayIpaTextWidget> createState() => _PronunciationsPlayIpaTextWidgetState();
}

class _PronunciationsPlayIpaTextWidgetState extends State<PronunciationsPlayIpaTextWidget> {
  /// 播放音标的声音
  Future<void> playIpaSound() async {
    if (widget.ipa == null || widget.pronunciations == null || widget.national == null) return;

    /// 找到对应的发音数据
    PronunciationsEntity? ipaEntity;
    List<PronunciationsEntity?> pronunciations = widget.pronunciations ?? [];
    for (PronunciationsEntity? item in pronunciations) {
      if (item == null) continue;
      if (item.national == widget.national) {
        ipaEntity = item;
        break;
      }
    }
    if (ipaEntity == null) return;

    List<PronunciationsEntityIpa?>? phonetics = ipaEntity.phonetics;
    if (phonetics == null || phonetics.isEmpty) return;

    String? ipaSoundUrl;
    for (PronunciationsEntityIpa? item in phonetics) {
      if (item == null) continue;
      if (item.ipa == null) continue;
      if (item.ipa == widget.ipa) {
        ipaSoundUrl = item.audioUrl;
        break;
      }
    }
    if (ipaSoundUrl == null) return;
    PlayAudioUtils.instance.playSingle(ipaSoundUrl);
  }

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      sclae: 1.05,
      onTap: () {
        playIpaSound();
      },
      backColor: AppTheme.cStaticWhite.color.withValues(alpha: 0.2),
      borderRadius: 10.wMin,
      child: Container(
        color: Colors.transparent,
        child: AutoSizeText(
          "/${widget.ipa ?? ''}/",
          maxLines: 1,
          style: widget.style,
        ),
      ),
    );
  }
}
