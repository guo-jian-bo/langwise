import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../app/modules/elements/common/elements_public_widgets.dart';
import '../../../entities/entities.dart';
import '../../widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';

enum WordInflectionDegreeTone {
  base,
  mid,
  high,
}

class WordInflectionSlotCardWidget extends StatelessWidget {
  final WordInflectionDetailSlotEntity slot;
  final String pos;
  final WordInflectionDegreeTone? degreeTone;
  final bool hub;
  final bool focused;
  final Widget? footerWidget;
  final void Function()? onTap;

  const WordInflectionSlotCardWidget({
    super.key,
    required this.slot,
    required this.pos,
    this.degreeTone,
    this.hub = false,
    this.focused = false,
    this.footerWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color posColor = WordInflectionMeta.getPosColor(pos);
    final bool isUnavailable = slot.kind == "unavailable";
    final bool isMissing = slot.kind == "missing";
    final _WordInflectionSlotCardStyle cardStyle = _getCardStyle(
      posColor,
      isUnavailable: isUnavailable,
      isMissing: isMissing,
    );

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(24.wMin),
      child: Container(
        color: cardStyle.bgColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(posColor, cardStyle),
            Expanded(child: _buildContentWidget()),
            _buildFooterWidget(cardStyle),
          ],
        ),
      ),
    );

    if (cardStyle.dashed) {
      content = DottedBorder(
        borderType: BorderType.RRect,
        radius: Radius.circular(24.wMin),
        dashPattern: [4.wMin, 3.wMin],
        padding: EdgeInsets.zero,
        strokeCap: StrokeCap.round,
        strokeWidth: focused ? 1.2.wMin : 1.wMin,
        color: focused ? posColor.withValues(alpha: 0.6) : cardStyle.borderColor,
        child: content,
      );
    } else {
      content = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.wMin),
          border: Border.all(
            color: focused ? posColor.withValues(alpha: 0.6) : cardStyle.borderColor,
            width: focused ? 1.2.wMin : 1.wMin,
          ),
        ),
        child: content,
      );
    }

    return TapScaleWidget(
      onTap: onTap,
      sclae: 1,
      child: content,
    );
  }

  Widget _buildTitleWidget(Color posColor, _WordInflectionSlotCardStyle cardStyle) {
    final String label = WordInflectionMeta.getSlotLabel(slot.typeNid);
    final Color textColor = cardStyle.titleTextColor ?? _getTitleColor(posColor);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
      decoration: BoxDecoration(
        color: cardStyle.titleBgColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.wMin),
          topRight: Radius.circular(24.wMin),
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.cBorderThin.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildContentWidget() {
    if (slot.kind == "unavailable") {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 24.wMin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment .center,
          children: [
            Row(
               mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
              "此屈折位对该词不适用",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextDisabled2,
              ),
            )
              ],
            ),
          ],
        ),
      );
    }

    final String headword = _getHeadword();
    final String description = _getDescription();
    final List<String> variants = _getVariants(headword);
    final List<PronunciationsEntity?> pronunciations = slot.contentCard?.pronunciations ?? [];
    final List<PronunciationsEntity?> usUkPronunciations = _getUsUkPronunciations(pronunciations);

    return Padding(
      padding: EdgeInsets.fromLTRB(36.wMin, 0, 36.wMin, 20.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: _WordInflectionHeadwordWidget(
              headword: headword.isEmpty ? "—" : headword,
              pronunciations: usUkPronunciations,
            ),
          ),
          if ((slot.syncretismLabel ?? '').isNotEmpty) ...[
            SizedBox(height: 10.wMin),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999.wMin),
                  border: Border.all(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.22),
                    width: 1.wMin,
                  ),
                ),
                child: Text(
                  slot.syncretismLabel ?? '',
                  style: TextStyle(
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF99F6E4),
                  ),
                ),
              ),
            ),
          ],
          if (variants.isNotEmpty) ...[
            SizedBox(height: 10.wMin),
            Text(
              variants.join(" / "),
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ],
          if (description.isNotEmpty) ...[
            SizedBox(height: 14.wMin),
            _buildAdaptiveDescriptionText(description),
          ],
        ],
      ),
    );
  }

  Widget _buildFooterWidget(_WordInflectionSlotCardStyle cardStyle) {
    return Container(
      width: double.infinity,
      height: 60.wMin,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: cardStyle.footerBgColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.wMin),
          bottomRight: Radius.circular(24.wMin),
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.cBorderThin.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: footerWidget ?? _buildDefaultFooterText(),
    );
  }

  Widget _buildDefaultFooterText() {
    String text = "已关联";
    if (slot.kind == "missing") {
      text = "理论词形，尚未入库";
    } else if (slot.kind == "unavailable") {
      text = "暂无关联";
    }
    return Text(
      text,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 14.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cTextQuaternary.color,
      ),
    );
  }

  String _getHeadword() {
    if (slot.kind == "linked") {
      return slot.content ?? slot.surface ?? slot.contentCard?.content ?? '';
    }
    if (slot.kind == "missing") {
      return slot.surface ?? slot.content ?? '';
    }
    return '';
  }

  String _getDescription() {
    LanguageText? localDescription = LearningLangUtils.getLocalLang(slot.descriptions);
    if ((localDescription?.text ?? '').isNotEmpty) {
      return localDescription?.text ?? '';
    }
    LanguageText? localGloss = LearningLangUtils.getLocalLang(slot.contentCard?.gloss);
    if ((localGloss?.text ?? '').isNotEmpty) {
      return localGloss?.text ?? '';
    }
    return slot.contentCard?.definition ?? '';
  }

  List<String> _getVariants(String headword) {
    List<String> values = [];
    List<WordInflectionDetailSlotVariantEntity?> variants = slot.variants ?? [];
    for (int i = 0; i < variants.length; i++) {
      String surface = variants[i]?.surface ?? '';
      if (surface.isEmpty) continue;
      if (surface.toLowerCase() == headword.toLowerCase()) continue;
      if (values.contains(surface)) continue;
      values.add(surface);
    }
    return values;
  }

  List<PronunciationsEntity?> _getUsUkPronunciations(List<PronunciationsEntity?> values) {
    List<PronunciationsEntity?> results = [];
    for (int i = 0; i < values.length; i++) {
      final PronunciationsEntity? item = values[i];
      final String national = item?.national ?? '';
      final String nationalTitle = item?.nationalTitle ?? '';
      final bool isUs = national == 'US' || nationalTitle == '美音';
      final bool isUk = national == 'UK' || nationalTitle == '英音';
      if (!isUs && !isUk) continue;
      results.add(item);
    }
    return results.length >= 2 ? results : [];
  }

  Widget _buildAdaptiveDescriptionText(String description) {
    final TextStyle style = TextStyle(
      fontSize: 20.wMin,
      fontWeight: FontWeight.w400,
      color: AppTheme.cTextTertiary.color,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final TextPainter painter = TextPainter(
          text: TextSpan(text: description, style: style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout(maxWidth: constraints.maxWidth);
        final bool isSingleLine = !painter.didExceedMaxLines;
        return SizedBox(
          width: double.infinity,
          child: Text(
            description,
            textAlign: isSingleLine ? TextAlign.center : TextAlign.left,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        );
      },
    );
  }

  Color _getTitleColor(Color posColor) {
    if (slot.kind == "unavailable") {
      return AppTheme.cTextQuaternary.color;
    }
    if (pos == "VERB" || pos == "NOUN") {
      return AppTheme.cTextSecondary.color;
    }
    return pos == "ADJECTIVE" || pos == "ADVERB" ? Colors.white : posColor;
  }

  Color _getBorderColor(Color posColor, {required bool isUnavailable, required bool isMissing}) {
    if (pos == "VERB" || pos == "NOUN") return AppTheme.cBorderTranslucentSubtle;
    if (isUnavailable) return AppTheme.cBorderThin.color.withValues(alpha: 0.6);
    if (isMissing) return posColor.withValues(alpha: 0.24);
    return posColor.withValues(alpha: 0.2);
  }

  Color _getBackgroundColor(Color posColor, {required bool isUnavailable, required bool isMissing}) {
    if (isUnavailable) return Colors.white.withValues(alpha: 0.02);
    if (pos == "NOUN") return AppTheme.cSurfaceLayerBase.color;
    if (isMissing) return posColor.withValues(alpha: 0.06);
    if (degreeTone == WordInflectionDegreeTone.mid) {
      return const Color(0xFF3A2A12).withValues(alpha: 0.42);
    }
    if (degreeTone == WordInflectionDegreeTone.high) {
      return const Color(0xFF4A2212).withValues(alpha: 0.5);
    }
    return AppTheme.cSurfaceLayerBase.color;
  }

  _WordInflectionSlotCardStyle _getCardStyle(
    Color posColor, {
    required bool isUnavailable,
    required bool isMissing,
  }) {
    if (_useDegreeCardStyle()) {
      return _getDegreeCardStyle();
    }
    if (pos == "VERB" || pos == "NOUN") {
      return _WordInflectionSlotCardStyle(
        borderColor: _getBorderColor(posColor, isUnavailable: isUnavailable, isMissing: isMissing),
        bgColor: _getBackgroundColor(posColor, isUnavailable: isUnavailable, isMissing: isMissing),
        titleBgColor: Colors.white.withValues(alpha: 0.04),
        footerBgColor: Colors.white.withValues(alpha: 0.03),
        titleTextColor: AppTheme.cTextSecondary.color,
      );
    }
    return _WordInflectionSlotCardStyle(
      borderColor: _getBorderColor(posColor, isUnavailable: isUnavailable, isMissing: isMissing),
      bgColor: _getBackgroundColor(posColor, isUnavailable: isUnavailable, isMissing: isMissing),
      titleBgColor: Colors.white.withValues(alpha: 0.04),
      footerBgColor: Colors.white.withValues(alpha: 0.03),
    );
  }

  bool _useDegreeCardStyle() {
    return (pos == "ADJECTIVE" || pos == "ADVERB") && degreeTone != null;
  }

  _WordInflectionSlotCardStyle _getDegreeCardStyle() {
    if (slot.kind == "unavailable") {
      return _WordInflectionSlotCardStyle(
        borderColor: AppTheme.cBorderTranslucentSubtle,
        bgColor: AppTheme.cSurfaceTranslucentBase,
        titleBgColor: AppTheme.cSurfaceTranslucentThin,
        footerBgColor: AppTheme.cSurfaceTranslucentBase,
        dashed: true,
        titleTextColor: AppTheme.cTextDisabled2.color,
      );
    }

    if (degreeTone == WordInflectionDegreeTone.mid) {
      return _WordInflectionSlotCardStyle(
        borderColor: AppTheme.cAmber.withValues(alpha: 0.45),
        bgColor: AppTheme.cSurfaceTranslucentBase,
        titleBgColor: AppTheme.cAmber.withValues(alpha: 0.12),
        footerBgColor: AppTheme.cSurfaceTranslucentBase,
        dashed: true,
      );
    }

    if (degreeTone == WordInflectionDegreeTone.high) {
      return _WordInflectionSlotCardStyle(
        borderColor: AppTheme.cFeedbackWarningBg.withValues(alpha: 0.45),
        bgColor: AppTheme.cSurfaceTranslucentBase,
        titleBgColor: AppTheme.cFeedbackWarningBg.withValues(alpha: 0.12),
        footerBgColor: AppTheme.cSurfaceTranslucentBase,
        dashed: true,
      );
    }

    return _WordInflectionSlotCardStyle(
      borderColor: AppTheme.cBorderTranslucentSubtle,
      bgColor: AppTheme.cSurfaceTranslucentBase,
      titleBgColor: AppTheme.cSurfaceTranslucentBase,
      footerBgColor: AppTheme.cSurfaceTranslucentBase,
    );
  }
}

class _WordInflectionHeadwordWidget extends StatefulWidget {
  final String headword;
  final List<PronunciationsEntity?> pronunciations;

  const _WordInflectionHeadwordWidget({
    required this.headword,
    required this.pronunciations,
  });

  @override
  State<_WordInflectionHeadwordWidget> createState() => _WordInflectionHeadwordWidgetState();
}

class _WordInflectionHeadwordWidgetState extends State<_WordInflectionHeadwordWidget> {
  @override
  Widget build(BuildContext context) {
    final bool showUsUk = widget.pronunciations.length >= 2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.headword,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 38.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        if (showUsUk) ...[
          SizedBox(width: 16.wMin),
          Wrap(
            spacing: 12.wMin,
            runSpacing: 8.wMin,
            children: widget.pronunciations
                .whereType<PronunciationsEntity>()
                .map((item) => _WordInflectionPronunciationButton(item: item))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _WordInflectionPronunciationButton extends StatefulWidget {
  final PronunciationsEntity item;

  const _WordInflectionPronunciationButton({required this.item});

  @override
  State<_WordInflectionPronunciationButton> createState() => _WordInflectionPronunciationButtonState();
}

class _WordInflectionPronunciationButtonState extends State<_WordInflectionPronunciationButton> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return ElementsPronunciationCapsuleButton(
      label: _resolvePronunciationLabel(widget.item),
      phonetic: widget.item.phonetic,
      isPlaying: isPlaying,
      onTap: () async {
        if ((widget.item.audioUrl ?? '').isEmpty) return;
        try {
          setState(() {
            isPlaying = true;
          });
          await PlayAudioUtils.instance.playSingle(widget.item.audioUrl);
        } finally {
          if (mounted) {
            setState(() {
              isPlaying = false;
            });
          }
        }
      },
    );
  }

  String _resolvePronunciationLabel(PronunciationsEntity item) {
    final String national = (item.national ?? '').trim().toUpperCase();
    if (national.isNotEmpty) return national;
    return (item.nationalTitle ?? '').contains('英') ? 'UK' : 'US';
  }
}

class _WordInflectionSlotCardStyle {
  final Color borderColor;
  final Color bgColor;
  final Color titleBgColor;
  final Color footerBgColor;
  final bool dashed;
  final Color? titleTextColor;

  const _WordInflectionSlotCardStyle({
    required this.borderColor,
    required this.bgColor,
    required this.titleBgColor,
    required this.footerBgColor,
    this.dashed = false,
    this.titleTextColor,
  });
}
