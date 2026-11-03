import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../entities/entities.dart';
import '../../../theme/theme.dart';
import 'zhenxie_knowledge_card_helper.dart';

/// 写作目标正文，按步骤范围和知识点范围渲染高亮文本。
class ZhenxieParagraphTextWidget extends StatefulWidget {
  /// 原始正文内容。
  final String content;
  final bool isManagement;

  /// 当前选中的步骤 nid。
  final String? selectBeatNid;

  /// 段落修辞步骤，用于匹配步骤颜色。
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;

  /// 步骤范围列表。
  final List<ParagraphWritingGoalEntityBeatSpan?>? beatSpanList;

  /// 知识点锚点列表。
  final List<ParagraphWritingGoalEntityAnchor?>? anchors;

  /// 点击某个步骤文本后的回调。
  final void Function(String beatNid)? onTapText;

  const ZhenxieParagraphTextWidget({
    super.key,
    required this.content,
    this.isManagement = false,
    this.selectBeatNid,
    required this.paragraphRhetoricalList,
    required this.beatSpanList,
    required this.anchors,
    this.onTapText,
  });

  @override
  State<ZhenxieParagraphTextWidget> createState() => _ZhenxieParagraphTextWidgetState();
}

class _ZhenxieParagraphTextWidgetState extends State<ZhenxieParagraphTextWidget> {
  /// 不同知识点类型对应的下划线颜色。
  static const Map<String, Color> _anchorDecorationColorMap = {
    'EN_WORD': Color(0xFF0EA5E9),
    'EN_PHRASE': Color(0xFFF59E0B),
    'EN_SENTENCE': Color(0xFF8B5CF6),
  };

  /// 显示知识点卡片
  Future<void> showKnowledgeCard(_WritingTextSlice slice) async {
    if (slice.anchor == null) return;
    widget.onTapText?.call(slice.beatNid ?? '');
    if (!mounted) return;
    await ZhenxieKnowledgeCardHelper.showKnowledgeCard(
      context: context,
      contentType: slice.anchor?.contentType,
      uid: slice.anchor?.uid,
      semanticId: slice.anchor?.semanticId,
      isManagement: widget.isManagement,
    );
  }

  @override
  Widget build(BuildContext context) {
    final slices = _buildSliceList();
    final groups = _buildGroupList(slices);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16.wMin, horizontal: 16.wMin),
      child: SizedBox(
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final TextSpan textSpan = TextSpan(children: _buildInlineSpanList(slices), style: _buildBaseTextStyle());
            final TextPainter textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)
              ..layout(maxWidth: constraints.maxWidth);
            return CustomPaint(
              painter: _WritingTextHighlightPainter(
                textPainter: textPainter,
                groupList: groups,
                colorGetter: _findBeatColor,
                selectBeatNid: widget.selectBeatNid,
                horizontalPadding: 6.wMin,
                verticalPadding: 2.wMin,
                borderRadius: 4.wMin,
                borderWidth: 1.wMin,
              ),
              child: RichText(text: textSpan),
            );
          },
        ),
      ),
    );
  }

  /// 按步骤和知识点范围切分文本，生成可独立着色的最小片段。
  List<_WritingTextSlice> _buildSliceList() {
    final beatSpanList = widget.beatSpanList ?? [];
    final anchorList = widget.anchors ?? [];
    final points = <int>{0, widget.content.length};

    for (final ParagraphWritingGoalEntityBeatSpan? beatSpan in beatSpanList) {
      final int? start = beatSpan?.start;
      final int? end = beatSpan?.end;
      if (start == null || end == null) continue;
      points.add(start);
      points.add(end);
    }

    for (final ParagraphWritingGoalEntityAnchor? anchor in anchorList) {
      for (final ParagraphWritingGoalEntityAnchorRange? range in anchor?.ranges ?? []) {
        final int? start = range?.start;
        final int? end = range?.end;
        if (start == null || end == null) continue;
        points.add(start);
        points.add(end);
      }
    }

    final List<int> cutList = points.where((item) => item >= 0 && item <= widget.content.length).toList()..sort();
    final List<_WritingTextSlice> sliceList = <_WritingTextSlice>[];
    for (int index = 0; index < cutList.length - 1; index++) {
      final int start = cutList[index];
      final int end = cutList[index + 1];
      if (end <= start) continue;
      final ParagraphWritingGoalEntityBeatSpan? beatSpan = _findCoverBeatSpan(start, end);
      final ParagraphWritingGoalEntityAnchor? anchor = _findCoverAnchor(start, end);
      sliceList.add(
        _WritingTextSlice(
          start: start,
          end: end,
          text: widget.content.substring(start, end),
          beatNid: beatSpan?.beatNid,
          anchor: anchor,
        ),
      );
    }

    for (int index = 0; index < sliceList.length; index++) {
      final _WritingTextSlice slice = sliceList[index];
      if (slice.beatNid != null || slice.text.trim().isNotEmpty) continue;
      final String? previousBeatNid = index > 0 ? sliceList[index - 1].beatNid : null;
      final String? nextBeatNid = index < sliceList.length - 1 ? sliceList[index + 1].beatNid : null;
      if (previousBeatNid != null && previousBeatNid == nextBeatNid) {
        slice.beatNid = previousBeatNid;
      }
    }
    return sliceList;
  }

  /// 按步骤将连续片段合并，保证边框作用在整段文本上。
  List<_WritingTextGroup> _buildGroupList(List<_WritingTextSlice> sliceList) {
    final List<_WritingTextGroup> groupList = <_WritingTextGroup>[];
    for (final _WritingTextSlice slice in sliceList) {
      final _WritingTextGroup? lastGroup = groupList.isEmpty ? null : groupList.last;
      if (lastGroup != null && lastGroup.beatNid == slice.beatNid) {
        lastGroup.sliceList.add(slice);
        continue;
      }
      groupList.add(_WritingTextGroup(beatNid: slice.beatNid, sliceList: <_WritingTextSlice>[slice]));
    }
    return groupList;
  }

  /// 构建最终展示用的富文本片段。
  List<InlineSpan> _buildInlineSpanList(List<_WritingTextSlice> sliceList) {
    final List<InlineSpan> spanList = <InlineSpan>[];
    for (final _WritingTextSlice slice in sliceList) {
      spanList.add(_buildSliceSpan(slice));
    }
    return spanList;
  }

  /// 构建单个切片的文本样式，保留知识点下划线。
  TextSpan _buildSliceSpan(_WritingTextSlice slice) {
    final Color? decorationColor = _anchorDecorationColorMap[slice.anchor?.contentType ?? ''];
    GestureRecognizer? recognizer;
    if (slice.anchor != null) {
      recognizer = TapGestureRecognizer()..onTap = () => showKnowledgeCard(slice);
    } else if (slice.beatNid != null) {
      recognizer = TapGestureRecognizer()..onTap = () => widget.onTapText?.call(slice.beatNid!);
    }

    return TextSpan(
      text: slice.text,
      style: _buildBaseTextStyle().copyWith(
        decoration: slice.anchor == null ? TextDecoration.none : TextDecoration.underline,
        decorationColor: decorationColor,
        decorationThickness: slice.anchor == null ? null : 1.5.wMin,
      ),
      recognizer: recognizer,
    );
  }

  /// 统一的正文基础样式。
  TextStyle _buildBaseTextStyle() {
    return TextStyle(
      fontSize: 28.wMin,
      fontWeight: FontWeight.w400,
      color: Color(0xff042F2E),
      height: 1.5,
    );
  }

  /// 找到完整覆盖当前区间的步骤范围。
  ParagraphWritingGoalEntityBeatSpan? _findCoverBeatSpan(int start, int end) {
    for (final ParagraphWritingGoalEntityBeatSpan? beatSpan in widget.beatSpanList ?? []) {
      final int? rangeStart = beatSpan?.start;
      final int? rangeEnd = beatSpan?.end;
      if (rangeStart == null || rangeEnd == null) continue;
      if (rangeStart <= start && end <= rangeEnd) {
        return beatSpan;
      }
    }
    return null;
  }

  /// 找到完整覆盖当前区间的知识点范围，优先返回更短的锚点。
  ParagraphWritingGoalEntityAnchor? _findCoverAnchor(int start, int end) {
    final List<ParagraphWritingGoalEntityAnchor> anchorList = <ParagraphWritingGoalEntityAnchor>[];
    for (final ParagraphWritingGoalEntityAnchor? anchor in widget.anchors ?? []) {
      if (anchor == null) continue;
      final bool isCover = (anchor.ranges ?? []).any((ParagraphWritingGoalEntityAnchorRange? range) {
        final int? rangeStart = range?.start;
        final int? rangeEnd = range?.end;
        if (rangeStart == null || rangeEnd == null) return false;
        return rangeStart <= start && end <= rangeEnd;
      });
      if (isCover) {
        anchorList.add(anchor);
      }
    }
    if (anchorList.isEmpty) return null;
    anchorList.sort((a, b) => _calculateAnchorLength(a).compareTo(_calculateAnchorLength(b)));
    return anchorList.first;
  }

  /// 计算知识点总长度，便于在重叠时优先取更精确的范围。
  int _calculateAnchorLength(ParagraphWritingGoalEntityAnchor anchor) {
    int length = 0;
    for (final ParagraphWritingGoalEntityAnchorRange? range in anchor.ranges ?? []) {
      final int? start = range?.start;
      final int? end = range?.end;
      if (start == null || end == null || end <= start) continue;
      length += end - start;
    }
    return length;
  }

  /// 根据步骤 nid 获取对应主色。
  Color _findBeatColor(String? beatNid) {
    for (final ParagraphRhetoricalEntityList item in widget.paragraphRhetoricalList) {
      if (item.nid == beatNid) {
        return item.getThemeColor(AppThemeKey.light)?.colorValue ?? AppTheme.cWritePrimary.color;
      }
    }
    return AppTheme.cWritePrimary.color;
  }
}

/// 行内最小文本片段。
class _WritingTextSlice {
  final int start;
  final int end;
  final String text;
  String? beatNid;
  final ParagraphWritingGoalEntityAnchor? anchor;

  _WritingTextSlice({
    required this.start,
    required this.end,
    required this.text,
    required this.beatNid,
    required this.anchor,
  });
}

/// 连续同一步骤的文本分组。
class _WritingTextGroup {
  final String? beatNid;
  final List<_WritingTextSlice> sliceList;

  _WritingTextGroup({required this.beatNid, required this.sliceList});

  int get start => sliceList.first.start;

  int get end => sliceList.last.end;
}

/// 单个高亮绘制盒子。
class _WritingTextHighlightRect {
  final String? beatNid;
  final Color color;
  final Rect rect;

  _WritingTextHighlightRect({required this.beatNid, required this.color, required this.rect});

  _WritingTextHighlightRect copyWith({String? beatNid, Color? color, Rect? rect}) {
    return _WritingTextHighlightRect(
      beatNid: beatNid ?? this.beatNid,
      color: color ?? this.color,
      rect: rect ?? this.rect,
    );
  }
}

/// 绘制步骤背景和选中边框，避免 WidgetSpan 导致整段强制换行。
class _WritingTextHighlightPainter extends CustomPainter {
  final TextPainter textPainter;
  final List<_WritingTextGroup> groupList;
  final Color Function(String? beatNid) colorGetter;
  final String? selectBeatNid;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;
  final double borderWidth;

  _WritingTextHighlightPainter({
    required this.textPainter,
    required this.groupList,
    required this.colorGetter,
    required this.selectBeatNid,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final List<_WritingTextHighlightRect> rectList = <_WritingTextHighlightRect>[];
    for (final _WritingTextGroup group in groupList) {
      if (group.beatNid == null) continue;
      final Color color = colorGetter(group.beatNid);
      final List<TextBox> textBoxList = textPainter.getBoxesForSelection(
        TextSelection(baseOffset: group.start, extentOffset: group.end),
      );
      for (final TextBox textBox in textBoxList) {
        rectList.add(
          _WritingTextHighlightRect(
            beatNid: group.beatNid,
            color: color,
            rect: Rect.fromLTRB(
              textBox.left - horizontalPadding,
              textBox.top - verticalPadding,
              textBox.right + horizontalPadding,
              textBox.bottom + verticalPadding,
            ),
          ),
        );
      }
    }
    final List<_WritingTextHighlightRect> normalizedRectList = _normalizeOverlapRectList(rectList);
    for (final _WritingTextHighlightRect item in normalizedRectList) {
      final RRect rRect = RRect.fromRectAndRadius(item.rect, Radius.circular(borderRadius));
      canvas.drawRRect(rRect, Paint()..color = item.color.withValues(alpha: 0.2));
      if (item.beatNid == selectBeatNid) {
        canvas.drawRRect(
          rRect,
          Paint()
            ..color = item.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = borderWidth,
        );
      }
    }
  }

  /// 收缩同一行相邻高亮框，避免左右 padding 发生重叠。
  List<_WritingTextHighlightRect> _normalizeOverlapRectList(List<_WritingTextHighlightRect> rectList) {
    if (rectList.length < 2) return rectList;
    final List<_WritingTextHighlightRect> sortedRectList = [...rectList]..sort((a, b) {
        final int topCompare = a.rect.top.compareTo(b.rect.top);
        if (topCompare != 0) return topCompare;
        return a.rect.left.compareTo(b.rect.left);
      });
    final List<_WritingTextHighlightRect> result = <_WritingTextHighlightRect>[];
    int start = 0;
    while (start < sortedRectList.length) {
      int end = start + 1;
      while (end < sortedRectList.length && _isSameLine(sortedRectList[start].rect, sortedRectList[end].rect)) {
        end++;
      }
      result.addAll(_normalizeLineRectList(sortedRectList.sublist(start, end)));
      start = end;
    }
    return result;
  }

  /// 判断两个文本框是否位于同一行。
  bool _isSameLine(Rect leftRect, Rect rightRect) {
    return (leftRect.top - rightRect.top).abs() < 0.5 && (leftRect.bottom - rightRect.bottom).abs() < 0.5;
  }

  /// 调整单行内相邻文本框的交界位置。
  List<_WritingTextHighlightRect> _normalizeLineRectList(List<_WritingTextHighlightRect> lineRectList) {
    if (lineRectList.length < 2) return lineRectList;
    final List<_WritingTextHighlightRect> result = [...lineRectList];
    for (int index = 1; index < result.length; index++) {
      final _WritingTextHighlightRect previous = result[index - 1];
      final _WritingTextHighlightRect current = result[index];
      if (previous.rect.right <= current.rect.left) continue;
      final double middle = (previous.rect.right + current.rect.left) / 2;
      result[index - 1] = previous.copyWith(
        rect: Rect.fromLTRB(previous.rect.left, previous.rect.top, middle, previous.rect.bottom),
      );
      result[index] = current.copyWith(
        rect: Rect.fromLTRB(middle, current.rect.top, current.rect.right, current.rect.bottom),
      );
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant _WritingTextHighlightPainter oldDelegate) {
    return oldDelegate.textPainter.text != textPainter.text ||
        oldDelegate.groupList != groupList ||
        oldDelegate.selectBeatNid != selectBeatNid;
  }
}
