import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../entities/entities.dart';
import '../../../../theme/theme.dart';
import 'word_inflection_meta.dart';
import 'word_inflection_slot_card_widget.dart';

class WordInflectionSlotBoardWidget extends StatelessWidget {
  final String pos;
  final List<WordInflectionDetailSlotEntity> slots;
  final Widget? Function(WordInflectionDetailSlotEntity slot)? footerBuilder;
  final bool Function(WordInflectionDetailSlotEntity slot)? focusedBuilder;
  final void Function(WordInflectionDetailSlotEntity slot)? onSlotTap;

  const WordInflectionSlotBoardWidget({
    super.key,
    required this.pos,
    required this.slots,
    this.footerBuilder,
    this.focusedBuilder,
    this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    if (_shouldUseSingleBaseBoard()) {
      return _buildSingleBaseBoard();
    }
    if (pos == "NOUN") {
      return _buildNounBoard();
    }
    if (pos == "ADJECTIVE" || pos == "ADVERB") {
      return _buildDegreeBoard();
    }
    if (pos == "VERB") {
      List<String> surfaces = _getAllSurfaces();
      if (WordInflectionMeta.useVerbGridLayout(surfaces, pos)) {
        return _buildVerbGridBoard();
      }
      return _buildVerbWindmillBoard();
    }
    return _buildFallbackGridBoard();
  }

  Widget _buildSingleBaseBoard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SizedBox(
            width: constraints.maxWidth * 0.28,
            height: constraints.maxHeight * 0.62,
            child: _buildSlotCard("base", hub: true),
          ),
        );
      },
    );
  }

  Widget _buildNounBoard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.wMin),
          child: Row(
            children: [
              SizedBox(width: 90.wMin),
              Expanded(child: _buildAxisLabel("通格")),
              SizedBox(width: 16.wMin),
              Expanded(child: _buildAxisLabel("所有格")),
            ],
          ),
        ),
        SizedBox(height: 10.wMin),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    SizedBox(width: 50.wMin, child: _buildSideAxisLabel("单数")),
                    Expanded(child: _buildSlotCard("base")),
                    SizedBox(width: 16.wMin),
                    Expanded(child: _buildSlotCard("possessive")),
                  ],
                ),
              ),
              SizedBox(height: 16.wMin),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(width: 50.wMin, child: _buildSideAxisLabel("复数")),
                    Expanded(child: _buildSlotCard("plural")),
                    SizedBox(width: 16.wMin),
                    Expanded(child: _buildSlotCard("possessive_plural")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDegreeBoard() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.wMin),
          child: Row(
            children: [
              Text(
                "弱",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextQuaternary.color,
                ),
              ),
              SizedBox(width: 10.wMin),
              Expanded(
                child: Container(
                  height: 5.wMin,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999.wMin),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFFF97316).withValues(alpha: 0.08),
                        const Color(0xFFF97316),
                      ],
                    ),
                  ),
                ),
              ),
             
              SizedBox(width: 10.wMin),
              Text(
                "强",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextQuaternary.color,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.wMin),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildSlotCard("base", degreeTone: WordInflectionDegreeTone.base)),
              SizedBox(width: 16.wMin),
              Expanded(child: _buildSlotCard("comparative", degreeTone: WordInflectionDegreeTone.mid)),
              SizedBox(width: 16.wMin),
              Expanded(child: _buildSlotCard("superlative", degreeTone: WordInflectionDegreeTone.high)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerbWindmillBoard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _VerbWindmillPainter(
                    color: AppTheme.cBorderDark.color,
                ),
              ),
            ),
            Positioned(
              left: constraints.maxWidth * 0.02,
              top: constraints.maxHeight * 0.02,
              width: constraints.maxWidth * 0.28,
              height: constraints.maxHeight * 0.44,
              child: _buildSlotCard("third_person_singular"),
            ),
            Positioned(
              right: constraints.maxWidth * 0.02,
              top: constraints.maxHeight * 0.02,
              width: constraints.maxWidth * 0.28,
              height: constraints.maxHeight * 0.44,
              child: _buildSlotCard("present_participle"),
            ),
            Positioned(
              left: constraints.maxWidth * 0.36,
              top: constraints.maxHeight * 0.16,
              width: constraints.maxWidth * 0.28,
              height: constraints.maxHeight * 0.62,
              child: _buildSlotCard("base", hub: true),
            ),
            Positioned(
              left: constraints.maxWidth * 0.02,
              bottom: constraints.maxHeight * 0.02,
              width: constraints.maxWidth * 0.28,
              height: constraints.maxHeight * 0.44,
              child: _buildSlotCard("past_simple"),
            ),
            Positioned(
              right: constraints.maxWidth * 0.02,
              bottom: constraints.maxHeight * 0.02,
              width: constraints.maxWidth * 0.28,
              height: constraints.maxHeight * 0.44,
              child: _buildSlotCard("past_participle"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVerbGridBoard() {
    double spacing = 16.wMin;
    int columns = slots.length > 6 ? 4 : 3;
    int rowCount = (slots.length / columns).ceil();
    return LayoutBuilder(
      builder: (context, constraints) {
        double rowHeight = rowCount <= 0
            ? 0
            : (constraints.maxHeight - spacing * (rowCount - 1)) / rowCount;
        List<Widget> rows = [];
        for (int i = 0; i < slots.length; i += columns) {
          List<Widget> children = [];
          for (int j = 0; j < columns; j++) {
            int index = i + j;
            children.add(
              Expanded(
                child: SizedBox(
                  height: rowHeight,
                  child: index < slots.length
                      ? WordInflectionSlotCardWidget(
                          slot: slots[index],
                          pos: pos,
                          focused: focusedBuilder?.call(slots[index]) == true,
                          footerWidget: footerBuilder?.call(slots[index]),
                          onTap: onSlotTap != null ? () => onSlotTap!(slots[index]) : null,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            );
            if (j < columns - 1) {
              children.add(SizedBox(width: spacing));
            }
          }
          rows.add(
            SizedBox(
              height: rowHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          );
          if (i + columns < slots.length) {
            rows.add(SizedBox(height: spacing));
          }
        }
        return Column(
          children: rows,
        );
      },
    );
  }

  Widget _buildFallbackGridBoard() {
    int columns = math.min(slots.length, 3);
    if (columns <= 0) columns = 1;
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 16.wMin,
        crossAxisSpacing: 16.wMin,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return WordInflectionSlotCardWidget(
          slot: slots[index],
          pos: pos,
            focused: focusedBuilder?.call(slots[index]) == true,
          footerWidget: footerBuilder?.call(slots[index]),
          onTap: onSlotTap != null ? () => onSlotTap!(slots[index]) : null,
        );
      },
    );
  }

  bool _shouldUseSingleBaseBoard() {
    if (slots.length != 1) return false;
    return slots.first.typeNid == "base";
  }

  Widget _buildSlotCard(
    String typeNid, {
    WordInflectionDegreeTone? degreeTone,
    bool hub = false,
  }) {
    WordInflectionDetailSlotEntity slot = _findSlot(typeNid);
    return WordInflectionSlotCardWidget(
      slot: slot,
      pos: pos,
      degreeTone: degreeTone,
      hub: hub,
      focused: focusedBuilder?.call(slot) == true,
      footerWidget: footerBuilder?.call(slot),
      onTap: onSlotTap != null ? () => onSlotTap!(slot) : null,
    );
  }

  Widget _buildAxisLabel(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextQuaternary.color,
          letterSpacing: 1.wMin,
        ),
      ),
    );
  }

  Widget _buildSideAxisLabel(String text) {
    final String verticalText = text.split('').join('\n');
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(right: 0.wMin),
        child: Text(
          verticalText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextQuaternary.color,
            letterSpacing: 1.wMin,
            height: 1.1,
          ),
        ),
      ),
    );
  }

  WordInflectionDetailSlotEntity _findSlot(String typeNid) {
    for (int i = 0; i < slots.length; i++) {
      if (slots[i].typeNid == typeNid) {
        return slots[i];
      }
    }
    return WordInflectionDetailSlotEntity(
      typeNid: typeNid,
      kind: "unavailable",
      contentType: "EN_WORD",
      isPrimary: true,
      variants: [],
    );
  }

  List<String> _getAllSurfaces() {
    List<String> values = [];
    for (int i = 0; i < slots.length; i++) {
      String surface = slots[i].content ?? slots[i].surface ?? '';
      if (surface.isNotEmpty && !values.contains(surface)) {
        values.add(surface);
      }
      List<WordInflectionDetailSlotVariantEntity?> variants = slots[i].variants ?? [];
      for (int j = 0; j < variants.length; j++) {
        String variantSurface = variants[j]?.surface ?? '';
        if (variantSurface.isNotEmpty && !values.contains(variantSurface)) {
          values.add(variantSurface);
        }
      }
    }
    return values;
  }
}

class _VerbWindmillPainter extends CustomPainter {
  final Color color;

  const _VerbWindmillPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawCurve(
      canvas,
      paint,
      start: Offset(size.width * 0.30, size.height * 0.24),
      end: Offset(size.width * 0.36, size.height * 0.47),
    );
    _drawCurve(
      canvas,
      paint,
      start: Offset(size.width * 0.70, size.height * 0.24),
      end: Offset(size.width * 0.64, size.height * 0.47),
    );
    _drawCurve(
      canvas,
      paint,
      start: Offset(size.width * 0.30, size.height * 0.76),
      end: Offset(size.width * 0.36, size.height * 0.53),
    );
    _drawCurve(
      canvas,
      paint,
      start: Offset(size.width * 0.70, size.height * 0.76),
      end: Offset(size.width * 0.64, size.height * 0.53),
    );
  }

  void _drawCurve(
    Canvas canvas,
    Paint paint, {
    required Offset start,
    required Offset end,
  }) {
    final Path path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        (start.dx + end.dx) / 2,
        start.dy,
        (start.dx + end.dx) / 2,
        end.dy,
        end.dx,
        end.dy,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _VerbWindmillPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
