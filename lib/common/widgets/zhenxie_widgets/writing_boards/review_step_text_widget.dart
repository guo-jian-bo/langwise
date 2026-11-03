import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';
import '../../../entities/entities.dart';
import '../../../enum/enum.dart';
import '../../../widgets/widgets.dart';
import 'model/writing_board_data.dart';
import 'utils/review_board_mark_helper.dart';
import 'utils/review_board_style_helper.dart';

/// 批改稿纸里的单拍位展示组件。
class ReviewStepTextWidget extends StatelessWidget {
  /// 当前拍位显示数据。
  final WritingBoardStepData data;

  /// 当前拍位正文 key。
  final String partKey;

  /// 当前拍位填充规则。
  final String fill;

  /// 当前拍位正文内容。
  final String text;

  /// 当前正文块命中的 issue 列表。
  final List<ZhenxieTaskDetailsMemberWritingReviewIssue> issues;

  /// 当前正文块的订正文案。
  final String correctedText;

  /// 当前正文块的升格文案。
  final String improvedText;

  /// 当前拍位对应的 marker 列表。
  final List<ReviewBoardMarkerData> markers;

  /// 当前批改稿纸显示模式。
  final ZhenxieTaskCorrectionWritingBoardModeEnum correctionMode;

  /// 当前是否允许展示批改态富文本。
  final bool showReviewDisplay;

  /// 当前选中的 marker id。
  final String? activeMarkerId;

  /// 当前需要闪一下的 marker id。
  final String? flashMarkerId;

  /// 当前正文块是否正在闪动。
  final bool isFlashingPart;

  /// 当前正文块命中的 focus anchors。
  final List<ZhenxieTaskDetailsMemberWritingReviewAnchor> focusAnchors;

  /// 当前是否显示左侧拍位印章。
  final bool showBeatStamp;

  /// 点击 marker 后的选中回调。
  final void Function(String markerId)? onSelectMarker;

  /// 点击拍位印章。
  final void Function(String beatNid)? onTapStep;

  /// 选中当前拍位。
  final void Function(String beatNid)? onSelectBeatNid;

  const ReviewStepTextWidget({
    super.key,
    required this.data,
    required this.partKey,
    required this.fill,
    required this.text,
    required this.issues,
    required this.correctedText,
    required this.improvedText,
    required this.markers,
    required this.correctionMode,
    required this.showReviewDisplay,
    this.activeMarkerId,
    this.flashMarkerId,
    this.isFlashingPart = false,
    this.focusAnchors = const <ZhenxieTaskDetailsMemberWritingReviewAnchor>[],
    this.showBeatStamp = true,
    this.onSelectMarker,
    this.onTapStep,
    this.onSelectBeatNid,
  });

  @override
  Widget build(BuildContext context) {
    final beatColor = data.beatColor ?? const Color(0xff500724);
    final beatTextColor = data.beatTextColor ?? Colors.white;
    final showSelectedBorder = isFlashingPart;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        showBeatStamp
            ? Container(
                margin: EdgeInsets.only(top: 12.wMin),
                child: TapScaleWidget(
                  onTap: () {
                    onSelectBeatNid?.call(data.beatNid);
                    onTapStep?.call(data.beatNid);
                  },
                  sclae: 1.03,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 49.wMin,
                    height: 49.wMin,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(2.wMin),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: beatColor.withValues(alpha: showSelectedBorder ? 1 : 0),
                        width: 2.wMin,
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: beatColor,
                      ),
                      child: Text(
                        data.beatLabel,
                        style: TextStyle(
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w500,
                          color: beatTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : SizedBox(
                width: 49.wMin,
                height: 59.wMin,
              ),
        SizedBox(width: 8.wMin),
        Expanded(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              border: Border.all(
                color: const Color(0xff9A3412).withValues(alpha: showSelectedBorder ? 1 : 0),
                width: 2.wMin,
              ),
            ),
            padding: EdgeInsets.all(10.wMin),
            child: ReviewBoardAnnotatedTextWidget(
              partKey: partKey,
              fill: fill,
              text: text,
              issues: issues,
              correctedText: correctedText,
              improvedText: improvedText,
              markers: markers,
              correctionMode: correctionMode,
              showReviewDisplay: showReviewDisplay,
              activeMarkerId: activeMarkerId,
              flashMarkerId: flashMarkerId,
              focusAnchors: focusAnchors,
              onSelectMarker: onSelectMarker,
            ),
          ),
        ),
      ],
    );
  }
}

/// 批改稿纸的可点击富文本正文。
class ReviewBoardAnnotatedTextWidget extends StatefulWidget {
  /// 当前正文块 key。
  final String partKey;

  /// 当前正文块填充规则。
  final String fill;

  /// 当前正文块文字内容。
  final String text;

  /// 当前正文块命中的 issue 列表。
  final List<ZhenxieTaskDetailsMemberWritingReviewIssue> issues;

  /// 当前正文块的订正文案。
  final String correctedText;

  /// 当前正文块的升格文案。
  final String improvedText;

  /// 当前正文块对应的 marker 列表。
  final List<ReviewBoardMarkerData> markers;

  /// 当前批改稿纸显示模式。
  final ZhenxieTaskCorrectionWritingBoardModeEnum correctionMode;

  /// 当前是否允许展示批改态富文本。
  final bool showReviewDisplay;

  /// 当前选中的 marker id。
  final String? activeMarkerId;

  /// 当前需要闪一下的 marker id。
  final String? flashMarkerId;

  /// 当前正文块命中的 focus anchors。
  final List<ZhenxieTaskDetailsMemberWritingReviewAnchor> focusAnchors;

  /// 点击 marker 后的选中回调。
  final void Function(String markerId)? onSelectMarker;

  /// 覆盖默认的正文样式。
  final TextStyle? textStyle;

  /// 空内容时的占位文案。
  final String? emptyText;

  const ReviewBoardAnnotatedTextWidget({
    super.key,
    required this.partKey,
    required this.fill,
    required this.text,
    required this.issues,
    required this.correctedText,
    required this.improvedText,
    required this.markers,
    required this.correctionMode,
    required this.showReviewDisplay,
    this.activeMarkerId,
    this.flashMarkerId,
    this.focusAnchors = const <ZhenxieTaskDetailsMemberWritingReviewAnchor>[],
    this.onSelectMarker,
    this.textStyle,
    this.emptyText,
  });

  @override
  State<ReviewBoardAnnotatedTextWidget> createState() => _ReviewBoardAnnotatedTextWidgetState();
}

class _ReviewBoardAnnotatedTextWidgetState extends State<ReviewBoardAnnotatedTextWidget> {
  /// 当前富文本挂载的点击手势集合，重建前需要释放。
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _displayText();
    final style = _buildBaseTextStyle();
    if (!widget.showReviewDisplay || widget.fill == 'given' || widget.text.isEmpty) {
      return Text(
        displayText,
        style: style.copyWith(
          color: widget.fill == 'given' ? Colors.black.withValues(alpha: 0.35) : style.color,
        ),
      );
    }
    if (widget.correctionMode == ZhenxieTaskCorrectionWritingBoardModeEnum.correct) {
      _disposeRecognizers();
      final edits = buildReviewBoardAppliedEdits(
        text: widget.text,
        issues: widget.issues,
        markers: widget.markers,
      );
      if (edits.isEmpty) {
        final fallbackText = widget.correctedText.isNotEmpty && widget.correctedText != widget.text ? widget.correctedText : displayText;
        return Text(fallbackText, style: style);
      }
      final renderData = _buildCorrectedRenderData(edits, style);
      return CustomPaint(
        painter: _ReviewBoardCorrectPainter(
          layoutSpans: renderData.layoutSpans,
          placeholderDimensions: renderData.placeholderDimensions,
          insertedRanges: renderData.insertedRanges,
          selectionRanges: renderData.selectionRanges,
          activeMarkerId: widget.activeMarkerId,
          flashMarkerId: widget.flashMarkerId,
          textDirection: Directionality.of(context),
        ),
        child: RichText(
          text: TextSpan(
            style: style,
            children: renderData.spans,
          ),
        ),
      );
    }
    if (widget.correctionMode == ZhenxieTaskCorrectionWritingBoardModeEnum.upgrade) {
      _disposeRecognizers();
      if (widget.improvedText.trim().isEmpty) {
        return Text(displayText, style: style);
      }
      final tokens = buildReviewBoardWordDiff(
        before: widget.text,
        after: widget.improvedText,
      );
      if (tokens.isEmpty) {
        return Text(widget.improvedText, style: style);
      }
      final renderData = _buildUpgradeRenderData(tokens, style);
      return CustomPaint(
        painter: _ReviewBoardTextBackgroundPainter(
          layoutSpans: renderData.layoutSpans,
          placeholderDimensions: renderData.placeholderDimensions,
          highlightedRanges: renderData.highlightedRanges,
          textDirection: Directionality.of(context),
        ),
        child: RichText(
          text: TextSpan(
            style: style,
            children: renderData.spans,
          ),
        ),
      );
    }
    if (widget.markers.isEmpty) {
      return Text(displayText, style: style);
    }
    final segments = buildReviewBoardTextSegments(
      text: widget.text,
      markers: widget.markers,
    );
    if (segments.isEmpty) {
      return Text(displayText, style: style);
    }
    _disposeRecognizers();
    final layoutSpans = _buildLayoutSpans(segments, style);
    final placeholderDimensions = _buildPlaceholderDimensions(segments);
    final badgeOffsets = _buildBadgeOffsets(segments);
    return CustomPaint(
      painter: _ReviewBoardAnnotationPainter(
        layoutSpans: layoutSpans,
        placeholderDimensions: placeholderDimensions,
        badgeOffsets: badgeOffsets,
        markers: widget.markers,
        activeMarkerId: widget.activeMarkerId,
        flashMarkerId: widget.flashMarkerId,
        focusRanges: _buildFocusRanges(),
        textDirection: Directionality.of(context),
      ),
      child: RichText(
        text: TextSpan(
          style: style,
          children: _buildSpanList(segments, style),
        ),
      ),
    );
  }

  /// 当前正文块显示给用户的文案。
  String _displayText() {
    if (widget.text.isNotEmpty) return widget.text;
    if (widget.emptyText?.isNotEmpty == true) return widget.emptyText!;
    return widget.fill == 'given' ? '（范文未挂）' : '（没写）';
  }

  /// 批改稿纸正文的基础样式。
  TextStyle _buildBaseTextStyle() {
    return widget.textStyle ??
        TextStyle(
          fontSize: 28.wMin,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: Colors.black.withValues(alpha: 0.75),
        );
  }

  /// 构造订正视图的富文本 spans。
  _ReviewBoardCorrectRenderData _buildCorrectedRenderData(
    List<ReviewBoardAppliedEdit> edits,
    TextStyle baseStyle,
  ) {
    final spans = <InlineSpan>[];
    final layoutSpans = <InlineSpan>[];
    final placeholderDimensions = <PlaceholderDimensions>[];
    final insertedRanges = <_ReviewBoardOffsetRange>[];
    final selectionRanges = <_ReviewBoardSelectionRange>[];
    var cursor = 0;
    var renderedOffset = 0;
    for (final edit in edits) {
      final recognizer = TapGestureRecognizer()
        ..onTap = () {
          widget.onSelectMarker?.call(edit.id);
        };
      _recognizers.add(recognizer);
      if (edit.start > cursor) {
        spans.add(
          TextSpan(
            text: widget.text.substring(cursor, edit.start),
            style: baseStyle,
          ),
        );
        layoutSpans.add(
          TextSpan(
            text: widget.text.substring(cursor, edit.start),
            style: baseStyle,
          ),
        );
        renderedOffset += edit.start - cursor;
      }
      final editStartOffset = renderedOffset;
      final editSpanData = _buildCorrectedEditSpans(
        original: widget.text.substring(edit.start, edit.end),
        correction: edit.correction,
        baseStyle: baseStyle,
        recognizer: recognizer,
      );
      spans.addAll(editSpanData.spans);
      layoutSpans.addAll(editSpanData.layoutSpans);
      for (final range in editSpanData.insertedRanges) {
        insertedRanges.add(
          _ReviewBoardOffsetRange(
            start: editStartOffset + range.start,
            end: editStartOffset + range.end,
          ),
        );
      }
      renderedOffset += editSpanData.textLength;
      if (renderedOffset > editStartOffset) {
        selectionRanges.add(
          _ReviewBoardSelectionRange(
            markerId: edit.id,
            start: editStartOffset,
            end: renderedOffset,
          ),
        );
      }
      if (edit.number != null) {
        spans.add(
          _buildMarkerBadgeSpan(
            number: edit.number!,
            color: ZhenxieReviewIssueSeverityEnum.error.color ?? AppTheme.cZhenxieFontPrimary.color,
            onTap: () {
              widget.onSelectMarker?.call(edit.id);
            },
          ),
        );
        layoutSpans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: SizedBox(
              width: 20.wMin,
              height: 10.wMin,
              child: Text('${edit.number}'),
            ),
          ),
        );
        placeholderDimensions.add(
          PlaceholderDimensions(
            size: Size(20.wMin, 10.wMin),
            alignment: ui.PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            baselineOffset: 9.wMin,
          ),
        );
        renderedOffset += 1;
      }
      cursor = edit.end;
    }
    if (cursor < widget.text.length) {
      spans.add(
        TextSpan(
          text: widget.text.substring(cursor),
          style: baseStyle,
        ),
      );
      layoutSpans.add(
        TextSpan(
          text: widget.text.substring(cursor),
          style: baseStyle,
        ),
      );
    }
    return _ReviewBoardCorrectRenderData(
      spans: spans,
      layoutSpans: layoutSpans,
      placeholderDimensions: placeholderDimensions,
      insertedRanges: insertedRanges,
      selectionRanges: selectionRanges,
    );
  }

  /// 根据单条订正结果构造局部替换 spans。
  _ReviewBoardInlineSpanData _buildCorrectedEditSpans({
    required String original,
    required String correction,
    required TextStyle baseStyle,
    required GestureRecognizer recognizer,
  }) {
    final deletedStyle = baseStyle.copyWith(
      color: ReviewBoardStyleHelper.correctDeleteTextColor.withValues(alpha: 0.8),
      decoration: TextDecoration.lineThrough,
      decorationColor: ReviewBoardStyleHelper.correctDeleteDecorationColor.withValues(alpha: 0.8),
      decorationThickness: 1.6.wMin,
    );
    final insertedStyle = baseStyle.copyWith(
      color: ReviewBoardStyleHelper.correctInsertTextColor,
      fontWeight: FontWeight.w600,
    );
    if (correction.isEmpty) {
      return _ReviewBoardInlineSpanData(
        spans: <InlineSpan>[
          TextSpan(
            text: original,
            style: deletedStyle,
            recognizer: recognizer,
          ),
        ],
        layoutSpans: <InlineSpan>[
          TextSpan(
            text: original,
            style: deletedStyle,
          ),
        ],
        insertedRanges: const <_ReviewBoardOffsetRange>[],
        textLength: original.length,
      );
    }
    if (original.isNotEmpty && correction.startsWith(original)) {
      final insertedText = correction.substring(original.length);
      return _ReviewBoardInlineSpanData(
        spans: <InlineSpan>[
          TextSpan(
            text: original,
            style: baseStyle,
            recognizer: recognizer,
          ),
          TextSpan(
            text: insertedText,
            style: insertedStyle,
            recognizer: recognizer,
          ),
        ],
        layoutSpans: <InlineSpan>[
          TextSpan(
            text: original,
            style: baseStyle,
          ),
          TextSpan(
            text: insertedText,
            style: insertedStyle,
          ),
        ],
        insertedRanges: insertedText.isEmpty
            ? const <_ReviewBoardOffsetRange>[]
            : <_ReviewBoardOffsetRange>[
                _ReviewBoardOffsetRange(
                  start: original.length,
                  end: correction.length,
                ),
              ],
        textLength: correction.length,
      );
    }
    if (original.isNotEmpty && correction.endsWith(original)) {
      final insertedText = correction.substring(0, correction.length - original.length);
      return _ReviewBoardInlineSpanData(
        spans: <InlineSpan>[
          TextSpan(
            text: insertedText,
            style: insertedStyle,
            recognizer: recognizer,
          ),
          TextSpan(
            text: original,
            style: baseStyle,
            recognizer: recognizer,
          ),
        ],
        layoutSpans: <InlineSpan>[
          TextSpan(
            text: insertedText,
            style: insertedStyle,
          ),
          TextSpan(
            text: original,
            style: baseStyle,
          ),
        ],
        insertedRanges: insertedText.isEmpty
            ? const <_ReviewBoardOffsetRange>[]
            : <_ReviewBoardOffsetRange>[
                _ReviewBoardOffsetRange(
                  start: 0,
                  end: insertedText.length,
                ),
              ],
        textLength: correction.length,
      );
    }
    if (original.toLowerCase() == correction.toLowerCase()) {
      return _ReviewBoardInlineSpanData(
        spans: <InlineSpan>[
          TextSpan(
            text: correction,
            style: insertedStyle,
            recognizer: recognizer,
          ),
        ],
        layoutSpans: <InlineSpan>[
          TextSpan(
            text: correction,
            style: insertedStyle,
          ),
        ],
        insertedRanges: correction.isEmpty
            ? const <_ReviewBoardOffsetRange>[]
            : <_ReviewBoardOffsetRange>[
                _ReviewBoardOffsetRange(
                  start: 0,
                  end: correction.length,
                ),
              ],
        textLength: correction.length,
      );
    }
    return _ReviewBoardInlineSpanData(
      spans: <InlineSpan>[
        TextSpan(
          text: original,
          style: deletedStyle,
          recognizer: recognizer,
        ),
        TextSpan(
          text: ' ',
          style: baseStyle,
          recognizer: recognizer,
        ),
        TextSpan(
          text: correction,
          style: insertedStyle,
          recognizer: recognizer,
        ),
      ],
      layoutSpans: <InlineSpan>[
        TextSpan(
          text: original,
          style: deletedStyle,
        ),
        TextSpan(
          text: ' ',
          style: baseStyle,
        ),
        TextSpan(
          text: correction,
          style: insertedStyle,
        ),
      ],
      insertedRanges: correction.isEmpty
          ? const <_ReviewBoardOffsetRange>[]
          : <_ReviewBoardOffsetRange>[
              _ReviewBoardOffsetRange(
                start: original.length + 1,
                end: original.length + 1 + correction.length,
              ),
            ],
      textLength: original.length + 1 + correction.length,
    );
  }

  /// 构造升格视图的富文本和 painter 数据。
  _ReviewBoardTextRenderData _buildUpgradeRenderData(
    List<ReviewBoardDiffToken> tokens,
    TextStyle baseStyle,
  ) {
    final spans = <InlineSpan>[];
    final layoutSpans = <InlineSpan>[];
    final highlightedRanges = <_ReviewBoardOffsetRange>[];
    var renderedOffset = 0;
    final removedStyle = baseStyle.copyWith(
      color: ReviewBoardStyleHelper.upgradeDeleteTextColor,
      decoration: TextDecoration.lineThrough,
      decorationColor: ReviewBoardStyleHelper.upgradeDeleteDecorationColor.withValues(alpha: 0.8),
      decorationThickness: 1.4.wMin,
    );
    final insertedStyle = baseStyle.copyWith(
      color: ReviewBoardStyleHelper.upgradeInsertTextColor,
    );
    for (final token in tokens) {
      if (token.op == ReviewBoardDiffTokenOp.same) {
        spans.add(TextSpan(text: token.text, style: baseStyle));
        layoutSpans.add(TextSpan(text: token.text, style: baseStyle));
        renderedOffset += token.text.length;
        continue;
      }
      final word = token.text.trimRight();
      final trailingSpace = token.text.substring(word.length);
      if (word.isNotEmpty) {
        final spanStyle = token.op == ReviewBoardDiffTokenOp.removed ? removedStyle : insertedStyle;
        spans.add(TextSpan(text: word, style: spanStyle));
        layoutSpans.add(TextSpan(text: word, style: spanStyle));
        if (token.op == ReviewBoardDiffTokenOp.inserted) {
          highlightedRanges.add(
            _ReviewBoardOffsetRange(
              start: renderedOffset,
              end: renderedOffset + word.length,
            ),
          );
        }
        renderedOffset += word.length;
      }
      if (trailingSpace.isNotEmpty) {
        spans.add(TextSpan(text: trailingSpace, style: baseStyle));
        layoutSpans.add(TextSpan(text: trailingSpace, style: baseStyle));
        renderedOffset += trailingSpace.length;
      }
    }
    return _ReviewBoardTextRenderData(
      spans: spans,
      layoutSpans: layoutSpans,
      placeholderDimensions: const <PlaceholderDimensions>[],
      highlightedRanges: highlightedRanges,
    );
  }

  /// 构造批注角标的行内占位。
  WidgetSpan _buildMarkerBadgeSpan({
    required int number,
    required Color color,
    VoidCallback? onTap,
  }) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 20.wMin,
          height: 10.wMin,
          child: OverflowBox(
            maxWidth: 24.wMin,
            maxHeight: 24.wMin,
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: Offset(1.wMin, -11.wMin),
              child: Container(
                width: 20.wMin,
                height: 20.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 12.wMin,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 将切片结果拼成可点击富文本。
  List<InlineSpan> _buildSpanList(
    List<ReviewBoardTextSegment> segments,
    TextStyle baseStyle,
  ) {
    final spanList = <InlineSpan>[];
    for (final segment in segments) {
      final tapMarker = resolveReviewBoardTapMarker(segment.markers);
      final hasError = segment.markers.any((item) => item.severity == ZhenxieReviewIssueSeverityEnum.error);
      final hasSuggestion = segment.markers.any((item) => item.severity == ZhenxieReviewIssueSeverityEnum.suggestion);
        final hasFocus = _segmentHasFocus(segment);
      TapGestureRecognizer? recognizer;
      if (tapMarker != null) {
        recognizer = TapGestureRecognizer()
          ..onTap = () {
            widget.onSelectMarker?.call(tapMarker.id);
          };
        _recognizers.add(recognizer);
      }
      final spanStyle = baseStyle.copyWith(
          decoration: hasFocus ? TextDecoration.none : (hasError || hasSuggestion ? TextDecoration.underline : TextDecoration.none),
          decorationColor: hasFocus
              ? null
              : (hasError
                    ? ReviewBoardStyleHelper.annotationErrorColor
                    : (hasSuggestion ? ReviewBoardStyleHelper.annotationSuggestionColor : null)),
          decorationStyle: hasFocus
              ? TextDecorationStyle.solid
              : (hasError ? TextDecorationStyle.wavy : (hasSuggestion ? TextDecorationStyle.dashed : TextDecorationStyle.solid)),
          decorationThickness: hasFocus ? null : (hasError || hasSuggestion ? 1.6.wMin : null),
      );
      spanList.add(
        TextSpan(
          text: segment.text,
          recognizer: recognizer,
          style: spanStyle,
        ),
      );
      for (final marker in segment.endingMarkers) {
        spanList.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.onSelectMarker?.call(marker.id);
              },
              child: SizedBox(
                width: 20.wMin,
                height: 10.wMin,
                child: OverflowBox(
                  maxWidth: 24.wMin,
                  maxHeight: 24.wMin,
                  alignment: Alignment.topLeft,
                  child: Transform.translate(
                    offset: Offset(1.wMin, -11.wMin),
                    child: Container(
                      width: 20.wMin,
                      height: 20.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: marker.severity.color ?? AppTheme.cZhenxieFontPrimary.color,
                      ),
                      child: Text(
                        '${marker.number}',
                        style: TextStyle(
                          fontSize: 12.wMin,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return spanList;
  }

  /// 构造和实际 RichText 同一行模型的占位 spans，给 painter 对齐定位用。
  List<InlineSpan> _buildLayoutSpans(List<ReviewBoardTextSegment> segments, TextStyle baseStyle) {
    final spanList = <InlineSpan>[];
    for (final segment in segments) {
      final hasError = segment.markers.any((item) => item.severity == ZhenxieReviewIssueSeverityEnum.error);
      final hasSuggestion = segment.markers.any((item) => item.severity == ZhenxieReviewIssueSeverityEnum.suggestion);
        final hasFocus = _segmentHasFocus(segment);
      spanList.add(
        TextSpan(
          text: segment.text,
          style: baseStyle.copyWith(
              decoration: hasFocus ? TextDecoration.none : (hasError || hasSuggestion ? TextDecoration.underline : TextDecoration.none),
              decorationColor: hasFocus
                  ? null
                  : (hasError
                        ? ReviewBoardStyleHelper.annotationErrorColor
                        : (hasSuggestion ? ReviewBoardStyleHelper.annotationSuggestionColor : null)),
              decorationStyle: hasFocus
                  ? TextDecorationStyle.solid
                  : (hasError ? TextDecorationStyle.wavy : (hasSuggestion ? TextDecorationStyle.dashed : TextDecorationStyle.solid)),
              decorationThickness: hasFocus ? null : (hasError || hasSuggestion ? 1.6.wMin : null),
          ),
        ),
      );
      for (final marker in segment.endingMarkers) {
        spanList.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: SizedBox(
              width: 20.wMin,
              height: 10.wMin,
              child: Text('${marker.number}'),
            ),
          ),
        );
      }
    }
    return spanList;
  }

    /// 判断当前文本切片是否被 focus anchors 命中。
    bool _segmentHasFocus(ReviewBoardTextSegment segment) {
      if (widget.focusAnchors.isEmpty) return false;
      for (final anchor in widget.focusAnchors) {
        final start = anchor.start;
        final end = anchor.end;
        if (start == null || end == null) continue;
        if (start < segment.end && end > segment.start) return true;
      }
      return false;
    }

  /// 构造 painter 排版时需要的行内占位尺寸。
  List<PlaceholderDimensions> _buildPlaceholderDimensions(List<ReviewBoardTextSegment> segments) {
    final dimensions = <PlaceholderDimensions>[];
    for (final segment in segments) {
      for (var index = 0; index < segment.endingMarkers.length; index++) {
        dimensions.add(
          PlaceholderDimensions(
            size: Size(20.wMin, 10.wMin),
            alignment: ui.PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            baselineOffset: 9.wMin,
          ),
        );
      }
    }
    return dimensions;
  }

  /// 记录每个 badge 插入在原文哪个 offset 后面，供 painter 做偏移换算。
  List<int> _buildBadgeOffsets(List<ReviewBoardTextSegment> segments) {
    final offsets = <int>[];
    for (final segment in segments) {
      for (final marker in segment.endingMarkers) {
        offsets.add(marker.end);
      }
    }
    return offsets;
  }

  /// 释放旧的富文本点击手势，避免重复挂载。
  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  /// 将当前 focus anchors 转成 painter 可直接消费的 offset 范围。
  List<_ReviewBoardOffsetRange> _buildFocusRanges() {
    if (widget.focusAnchors.isEmpty || widget.text.isEmpty) return const <_ReviewBoardOffsetRange>[];
    final ranges = <_ReviewBoardOffsetRange>[];
    for (final anchor in widget.focusAnchors) {
      final start = anchor.start;
      final end = anchor.end;
      if (start == null || end == null || start < 0 || end > widget.text.length || end <= start) continue;
      ranges.add(
        _ReviewBoardOffsetRange(
          start: start,
          end: end,
        ),
      );
    }
    return ranges;
  }
}

/// 订正视图真实渲染和 painter 对齐用的数据。
class _ReviewBoardCorrectRenderData {
  /// 实际显示给用户的 spans。
  final List<InlineSpan> spans;

  /// painter 排版使用的 spans。
  final List<InlineSpan> layoutSpans;

  /// badge 对应的行内占位尺寸。
  final List<PlaceholderDimensions> placeholderDimensions;

  /// 需要绘制绿色补写背景的范围。
  final List<_ReviewBoardOffsetRange> insertedRanges;

  /// 每条订正 marker 在渲染文本里的范围。
  final List<_ReviewBoardSelectionRange> selectionRanges;

  const _ReviewBoardCorrectRenderData({
    required this.spans,
    required this.layoutSpans,
    required this.placeholderDimensions,
    required this.insertedRanges,
    required this.selectionRanges,
  });
}

/// 只负责文字背景高亮的渲染数据。
class _ReviewBoardTextRenderData {
  /// 实际显示给用户的 spans。
  final List<InlineSpan> spans;

  /// painter 排版使用的 spans。
  final List<InlineSpan> layoutSpans;

  /// 行内占位尺寸。
  final List<PlaceholderDimensions> placeholderDimensions;

  /// 需要补背景的范围。
  final List<_ReviewBoardOffsetRange> highlightedRanges;

  const _ReviewBoardTextRenderData({
    required this.spans,
    required this.layoutSpans,
    required this.placeholderDimensions,
    required this.highlightedRanges,
  });
}

/// 一段富文本同时维护交互 spans 和 layout spans。
class _ReviewBoardInlineSpanData {
  /// 真实渲染使用的 spans。
  final List<InlineSpan> spans;

  /// painter 排版使用的 spans。
  final List<InlineSpan> layoutSpans;

  /// 这一段文本在 painter 里的字符长度。
  final int textLength;

  /// 当前片段里需要绘制绿色补写背景的范围。
  final List<_ReviewBoardOffsetRange> insertedRanges;

  const _ReviewBoardInlineSpanData({
    required this.spans,
    required this.layoutSpans,
    required this.textLength,
    required this.insertedRanges,
  });
}

/// 渲染文本中的通用 offset 范围。
class _ReviewBoardOffsetRange {
  /// 起始 offset。
  final int start;

  /// 结束 offset。
  final int end;

  const _ReviewBoardOffsetRange({
    required this.start,
    required this.end,
  });
}

/// 当前选中 marker 在渲染文本中的范围。
class _ReviewBoardSelectionRange {
  /// 当前 marker id。
  final String markerId;

  /// 当前范围起始 offset。
  final int start;

  /// 当前范围结束 offset。
  final int end;

  const _ReviewBoardSelectionRange({
    required this.markerId,
    required this.start,
    required this.end,
  });
}

/// 订正视图的选中描边 painter。
class _ReviewBoardCorrectPainter extends CustomPainter {
  /// 和 RichText 对齐的行内 spans。
  final List<InlineSpan> layoutSpans;

  /// 行内 badge 的占位尺寸。
  final List<PlaceholderDimensions> placeholderDimensions;

  /// 当前需要补绿色底的范围。
  final List<_ReviewBoardOffsetRange> insertedRanges;

  /// 当前可描边的 edit 范围。
  final List<_ReviewBoardSelectionRange> selectionRanges;

  /// 当前激活的 marker id。
  final String? activeMarkerId;

  /// 当前需要闪一下的 marker id。
  final String? flashMarkerId;

  /// 当前文本方向。
  final TextDirection textDirection;

  const _ReviewBoardCorrectPainter({
    required this.layoutSpans,
    required this.placeholderDimensions,
    required this.insertedRanges,
    required this.selectionRanges,
    required this.activeMarkerId,
    required this.flashMarkerId,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (layoutSpans.isEmpty || selectionRanges.isEmpty || activeMarkerId?.isEmpty != false || size.width <= 0) return;
    final selectedRanges = selectionRanges.where((item) => item.markerId == activeMarkerId).toList();
    if (selectedRanges.isEmpty) return;
    final textPainter = TextPainter(
      text: TextSpan(children: layoutSpans),
      textDirection: textDirection,
    );
    textPainter.setPlaceholderDimensions(placeholderDimensions);
    textPainter.layout(maxWidth: size.width);
    final placeholderBoxes = textPainter.inlinePlaceholderBoxes ?? const <TextBox>[];
    final insertedPaint = Paint()..color = ReviewBoardStyleHelper.correctInsertBackgroundColor;
    final activePaint = Paint()
      ..color = ReviewBoardStyleHelper.activeBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.wMin;
    final flashPaint = Paint()..color = const Color(0xffFCD34D).withValues(alpha: 0.55);
    for (final range in insertedRanges) {
      final boxes = textPainter.getBoxesForSelection(
        TextSelection(
          baseOffset: range.start,
          extentOffset: range.end,
        ),
      );
      for (final box in boxes) {
        for (final rect in _excludePlaceholderRects(box.toRect(), placeholderBoxes)) {
          canvas.drawRRect(_buildDecorationRRect(rect), insertedPaint);
        }
      }
    }
    for (final range in selectedRanges) {
      final boxes = textPainter.getBoxesForSelection(
        TextSelection(
          baseOffset: range.start,
          extentOffset: range.end,
        ),
      );
      final selectionRects = <Rect>[];
      for (final box in boxes) {
        selectionRects.addAll(_excludePlaceholderRects(box.toRect(), placeholderBoxes));
      }
      for (final rect in _mergeDecorationRects(selectionRects)) {
        canvas.drawRRect(_buildDecorationRRect(rect), activePaint);
      }
    }
    if (flashMarkerId?.isEmpty != false) return;
    final flashRanges = selectionRanges.where((item) => item.markerId == flashMarkerId).toList();
    for (final range in flashRanges) {
      final boxes = textPainter.getBoxesForSelection(
        TextSelection(
          baseOffset: range.start,
          extentOffset: range.end,
        ),
      );
      final selectionRects = <Rect>[];
      for (final box in boxes) {
        selectionRects.addAll(_excludePlaceholderRects(box.toRect(), placeholderBoxes));
      }
      for (final rect in _mergeDecorationRects(selectionRects)) {
        canvas.drawRRect(_buildDecorationRRect(rect), flashPaint);
      }
    }
  }

  /// 将文本盒子收紧成更贴近字面的圆角区域。
  RRect _buildDecorationRRect(Rect rect) {
    final adjustedRect = Rect.fromLTRB(
      rect.left - 2.wMin,
      rect.top - 1.5.wMin,
      rect.right + 2.wMin,
      rect.bottom + 1.5.wMin,
    );
    return RRect.fromRectAndRadius(
      adjustedRect,
      Radius.circular(4.wMin),
    );
  }

  /// 将 badge 的占位区域从文字装饰范围里扣掉，避免序号外面也被框住。
  List<Rect> _excludePlaceholderRects(Rect sourceRect, List<TextBox> placeholderBoxes) {
    var rects = <Rect>[sourceRect];
    for (final placeholder in placeholderBoxes) {
      final placeholderRect = placeholder.toRect();
      final nextRects = <Rect>[];
      for (final rect in rects) {
        final overlap = rect.intersect(placeholderRect);
        final hasOverlap = overlap.width > 0 && overlap.height > 0;
        if (!hasOverlap) {
          nextRects.add(rect);
          continue;
        }
        if (overlap.left > rect.left) {
          nextRects.add(
            Rect.fromLTRB(
              rect.left,
              rect.top,
              overlap.left,
              rect.bottom,
            ),
          );
        }
        if (overlap.right < rect.right) {
          nextRects.add(
            Rect.fromLTRB(
              overlap.right,
              rect.top,
              rect.right,
              rect.bottom,
            ),
          );
        }
      }
      rects = nextRects;
      if (rects.isEmpty) break;
    }
    return rects.where((rect) => rect.width > 0 && rect.height > 0).toList();
  }

  /// 合并同一行里相邻的小矩形，让错误词和订正文共用一个描边框。
  List<Rect> _mergeDecorationRects(List<Rect> rects) {
    if (rects.length <= 1) return rects;
    final sortedRects = rects.toList()
      ..sort((a, b) {
        final topCompare = a.top.compareTo(b.top);
        if (topCompare != 0) return topCompare;
        return a.left.compareTo(b.left);
      });
    final mergedRects = <Rect>[];
    var current = sortedRects.first;
    for (var index = 1; index < sortedRects.length; index++) {
      final next = sortedRects[index];
      final sameLine = (next.top - current.top).abs() <= 2.wMin && (next.bottom - current.bottom).abs() <= 2.wMin;
      final closeEnough = next.left - current.right <= 16.wMin;
      if (sameLine && closeEnough) {
        current = Rect.fromLTRB(
          current.left,
          current.top < next.top ? current.top : next.top,
          current.right > next.right ? current.right : next.right,
          current.bottom > next.bottom ? current.bottom : next.bottom,
        );
        continue;
      }
      mergedRects.add(current);
      current = next;
    }
    mergedRects.add(current);
    return mergedRects;
  }

  @override
  bool shouldRepaint(covariant _ReviewBoardCorrectPainter oldDelegate) {
    if (oldDelegate.activeMarkerId != activeMarkerId ||
        oldDelegate.flashMarkerId != flashMarkerId ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.layoutSpans.length != layoutSpans.length ||
        oldDelegate.placeholderDimensions.length != placeholderDimensions.length ||
        oldDelegate.insertedRanges.length != insertedRanges.length ||
        oldDelegate.selectionRanges.length != selectionRanges.length) {
      return true;
    }
    for (var index = 0; index < insertedRanges.length; index++) {
      final current = insertedRanges[index];
      final old = oldDelegate.insertedRanges[index];
      if (current.start != old.start || current.end != old.end) return true;
    }
    for (var index = 0; index < selectionRanges.length; index++) {
      final current = selectionRanges[index];
      final old = oldDelegate.selectionRanges[index];
      if (current.markerId != old.markerId || current.start != old.start || current.end != old.end) return true;
    }
    return false;
  }
}

/// 只负责绘制贴字背景的 painter。
class _ReviewBoardTextBackgroundPainter extends CustomPainter {
  /// 和 RichText 对齐的行内 spans。
  final List<InlineSpan> layoutSpans;

  /// 行内占位尺寸。
  final List<PlaceholderDimensions> placeholderDimensions;

  /// 当前需要补背景的范围。
  final List<_ReviewBoardOffsetRange> highlightedRanges;

  /// 当前文本方向。
  final TextDirection textDirection;

  const _ReviewBoardTextBackgroundPainter({
    required this.layoutSpans,
    required this.placeholderDimensions,
    required this.highlightedRanges,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (layoutSpans.isEmpty || highlightedRanges.isEmpty || size.width <= 0) return;
    final textPainter = TextPainter(
      text: TextSpan(children: layoutSpans),
      textDirection: textDirection,
    );
    textPainter.setPlaceholderDimensions(placeholderDimensions);
    textPainter.layout(maxWidth: size.width);
    final placeholderBoxes = textPainter.inlinePlaceholderBoxes ?? const <TextBox>[];
    final highlightPaint = Paint()..color = ReviewBoardStyleHelper.upgradeInsertBackgroundColor;
    for (final range in highlightedRanges) {
      final boxes = textPainter.getBoxesForSelection(
        TextSelection(
          baseOffset: range.start,
          extentOffset: range.end,
        ),
      );
      for (final box in boxes) {
        for (final rect in _excludePlaceholderRects(box.toRect(), placeholderBoxes)) {
          canvas.drawRRect(_buildDecorationRRect(rect), highlightPaint);
        }
      }
    }
  }

  /// 将文本盒子收紧成更贴近字面的圆角区域。
  RRect _buildDecorationRRect(Rect rect) {
    final adjustedRect = Rect.fromLTRB(
      rect.left - 2.wMin,
      rect.top - 1.5.wMin,
      rect.right + 2.wMin,
      rect.bottom + 1.5.wMin,
    );
    return RRect.fromRectAndRadius(
      adjustedRect,
      Radius.circular(4.wMin),
    );
  }

  /// 将 badge 的占位区域从文字装饰范围里扣掉。
  List<Rect> _excludePlaceholderRects(Rect sourceRect, List<TextBox> placeholderBoxes) {
    var rects = <Rect>[sourceRect];
    for (final placeholder in placeholderBoxes) {
      final placeholderRect = placeholder.toRect();
      final nextRects = <Rect>[];
      for (final rect in rects) {
        final overlap = rect.intersect(placeholderRect);
        final hasOverlap = overlap.width > 0 && overlap.height > 0;
        if (!hasOverlap) {
          nextRects.add(rect);
          continue;
        }
        if (overlap.left > rect.left) {
          nextRects.add(Rect.fromLTRB(rect.left, rect.top, overlap.left, rect.bottom));
        }
        if (overlap.right < rect.right) {
          nextRects.add(Rect.fromLTRB(overlap.right, rect.top, rect.right, rect.bottom));
        }
      }
      rects = nextRects;
      if (rects.isEmpty) break;
    }
    return rects.where((rect) => rect.width > 0 && rect.height > 0).toList();
  }

  @override
  bool shouldRepaint(covariant _ReviewBoardTextBackgroundPainter oldDelegate) {
    if (oldDelegate.textDirection != textDirection ||
        oldDelegate.layoutSpans.length != layoutSpans.length ||
        oldDelegate.placeholderDimensions.length != placeholderDimensions.length ||
        oldDelegate.highlightedRanges.length != highlightedRanges.length) {
      return true;
    }
    for (var index = 0; index < highlightedRanges.length; index++) {
      final current = highlightedRanges[index];
      final old = oldDelegate.highlightedRanges[index];
      if (current.start != old.start || current.end != old.end) return true;
    }
    return false;
  }
}

/// 在正常文本排版背后补画亮点背景和选中描边。
class _ReviewBoardAnnotationPainter extends CustomPainter {
  /// 和 RichText 对齐的行内 spans。
  final List<InlineSpan> layoutSpans;

  /// 行内 badge 的占位尺寸。
  final List<PlaceholderDimensions> placeholderDimensions;

  /// 每个 badge 对应的原文结束 offset。
  final List<int> badgeOffsets;

  /// 当前正文块 marker 列表。
  final List<ReviewBoardMarkerData> markers;

  /// 当前激活的 marker id。
  final String? activeMarkerId;

  /// 当前需要闪一下的 marker id。
  final String? flashMarkerId;

  /// 当前需要高亮的 focus 范围。
  final List<_ReviewBoardOffsetRange> focusRanges;

  /// 当前文本方向。
  final TextDirection textDirection;

  const _ReviewBoardAnnotationPainter({
    required this.layoutSpans,
    required this.placeholderDimensions,
    required this.badgeOffsets,
    required this.markers,
    required this.activeMarkerId,
    required this.flashMarkerId,
    required this.focusRanges,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
      if (layoutSpans.isEmpty || size.width <= 0) return;
    final textPainter = TextPainter(
      text: TextSpan(children: layoutSpans),
      textDirection: textDirection,
    );
    textPainter.setPlaceholderDimensions(placeholderDimensions);
    textPainter.layout(maxWidth: size.width);
    final placeholderBoxes = textPainter.inlinePlaceholderBoxes ?? const <TextBox>[];
      final focusPaint = Paint()..color = const Color(0xffFDE68A);
      final focusUnderlinePaint = Paint()
        ..color = const Color(0xffB45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.wMin
        ..strokeCap = StrokeCap.round;
    final highlightPaint = Paint()..color = ReviewBoardStyleHelper.annotationHighlightBackgroundColor.withValues(alpha: 0.8);
    final flashPaint = Paint()..color = const Color(0xffFCD34D).withValues(alpha: 0.55);
    final activePaint = Paint()
      ..color = ReviewBoardStyleHelper.activeBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.wMin;
      final focusRects = <Rect>[];
    for (final marker in markers) {
      if (marker.severity != ZhenxieReviewIssueSeverityEnum.highlight) continue;
      final boxes = textPainter.getBoxesForSelection(
        TextSelection(
          baseOffset: _resolvePainterOffset(marker.start),
          extentOffset: _resolvePainterOffset(marker.end),
        ),
      );
      for (final box in boxes) {
        for (final rect in _excludePlaceholderRects(box.toRect(), placeholderBoxes)) {
          canvas.drawRRect(_buildDecorationRRect(rect), highlightPaint);
        }
      }
    }
      if (flashMarkerId?.isEmpty == false) {
        for (final marker in markers.where((item) => item.id == flashMarkerId)) {
          final boxes = textPainter.getBoxesForSelection(
            TextSelection(
              baseOffset: _resolvePainterOffset(marker.start),
              extentOffset: _resolvePainterOffset(marker.end),
            ),
          );
          for (final box in boxes) {
            for (final rect in _excludePlaceholderRects(box.toRect(), placeholderBoxes)) {
              canvas.drawRRect(_buildDecorationRRect(rect), flashPaint);
            }
          }
        }
      }
      for (final range in focusRanges) {
        final boxes = textPainter.getBoxesForSelection(
          TextSelection(
            baseOffset: _resolvePainterOffset(range.start),
            extentOffset: _resolvePainterOffset(range.end),
          ),
        );
        for (final box in boxes) {
          for (final rect in _excludePlaceholderRects(box.toRect(), placeholderBoxes)) {
            focusRects.add(rect);
            canvas.drawRRect(_buildDecorationRRect(rect), focusPaint);
            final underlineY = rect.bottom - 1.5.wMin;
            canvas.drawLine(
              Offset(rect.left + 2.wMin, underlineY),
              Offset(rect.right - 2.wMin, underlineY),
              focusUnderlinePaint,
            );
          }
        }
    }
    if (activeMarkerId?.isEmpty != false) return;
    for (final marker in markers.where((item) => item.id == activeMarkerId)) {
      final boxes = textPainter.getBoxesForSelection(
        TextSelection(
            baseOffset: _resolvePainterOffset(marker.start),
          extentOffset: _resolvePainterOffset(marker.end),
        ),
      );
      for (final box in boxes) {
          final visibleRects = _subtractOverlapRects(
            _excludePlaceholderRects(box.toRect(), placeholderBoxes),
            focusRects,
          );
          for (final rect in visibleRects) {
          canvas.drawRRect(_buildDecorationRRect(rect), activePaint);
        }
      }
    }
  }

  /// 将文本盒子收紧成更贴近字面的圆角区域。
  RRect _buildDecorationRRect(Rect rect) {
    final adjustedRect = Rect.fromLTRB(
      rect.left - 2.wMin,
      rect.top - 1.5.wMin,
      rect.right + 2.wMin,
      rect.bottom + 1.5.wMin,
    );
    return RRect.fromRectAndRadius(
      adjustedRect,
      Radius.circular(4.wMin),
    );
  }

  /// 将 badge 的占位区域从文字装饰范围里扣掉，避免序号外面也被框住。
  List<Rect> _excludePlaceholderRects(Rect sourceRect, List<TextBox> placeholderBoxes) {
    var rects = <Rect>[sourceRect];
    for (final placeholder in placeholderBoxes) {
      final placeholderRect = placeholder.toRect();
      final nextRects = <Rect>[];
      for (final rect in rects) {
        final overlap = rect.intersect(placeholderRect);
        final hasOverlap = overlap.width > 0 && overlap.height > 0;
        if (!hasOverlap) {
          nextRects.add(rect);
          continue;
        }
        if (overlap.left > rect.left) {
          nextRects.add(
            Rect.fromLTRB(
              rect.left,
              rect.top,
              overlap.left,
              rect.bottom,
            ),
          );
        }
        if (overlap.right < rect.right) {
          nextRects.add(
            Rect.fromLTRB(
              overlap.right,
              rect.top,
              rect.right,
              rect.bottom,
            ),
          );
        }
      }
      rects = nextRects;
      if (rects.isEmpty) break;
    }
    return rects.where((rect) => rect.width > 0 && rect.height > 0).toList();
  }

    /// 将 focus 覆盖掉的区域从当前描边矩形中扣掉，避免这部分文字继续显示选中框。
    List<Rect> _subtractOverlapRects(List<Rect> sourceRects, List<Rect> masks) {
      var rects = sourceRects;
      for (final mask in masks) {
        final nextRects = <Rect>[];
        for (final rect in rects) {
          final overlap = rect.intersect(mask);
          final hasOverlap = overlap.width > 0 && overlap.height > 0;
          if (!hasOverlap) {
            nextRects.add(rect);
            continue;
          }
          if (overlap.left > rect.left) {
            nextRects.add(
              Rect.fromLTRB(
                rect.left,
                rect.top,
                overlap.left,
                rect.bottom,
              ),
            );
          }
          if (overlap.right < rect.right) {
            nextRects.add(
              Rect.fromLTRB(
                overlap.right,
                rect.top,
                rect.right,
                rect.bottom,
              ),
            );
          }
        }
        rects = nextRects;
        if (rects.isEmpty) break;
      }
      return rects.where((rect) => rect.width > 0 && rect.height > 0).toList();
    }

  /// 将原文 offset 映射到包含 badge 占位后的 painter offset。
  int _resolvePainterOffset(int originalOffset) {
    var shift = 0;
    for (final offset in badgeOffsets) {
      if (offset < originalOffset) {
        shift++;
      }
    }
    return originalOffset + shift;
  }

  @override
  bool shouldRepaint(covariant _ReviewBoardAnnotationPainter oldDelegate) {
    return oldDelegate.activeMarkerId != activeMarkerId ||
        oldDelegate.flashMarkerId != flashMarkerId ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.layoutSpans.length != layoutSpans.length ||
        oldDelegate.placeholderDimensions.length != placeholderDimensions.length ||
        oldDelegate.badgeOffsets.length != badgeOffsets.length ||
        oldDelegate.focusRanges.length != focusRanges.length ||
        !_sameMarkers(oldDelegate.markers, markers);
  }

  /// 判断 marker 列表是否真的变化。
  bool _sameMarkers(List<ReviewBoardMarkerData> oldList, List<ReviewBoardMarkerData> newList) {
    if (oldList.length != newList.length) return false;
    for (var index = 0; index < oldList.length; index++) {
      if (oldList[index].id != newList[index].id ||
          oldList[index].start != newList[index].start ||
          oldList[index].end != newList[index].end ||
          oldList[index].severity != newList[index].severity) {
        return false;
      }
    }
    return true;
  }
}
