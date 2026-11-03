import '../../../../entities/entities.dart';
import '../../../../enum/enum.dart';
import 'package:langwise/utils/review_marker_id_utils.dart';

/// 批改稿纸上的单条 marker 数据。
class ReviewBoardMarkerData {
  /// marker 稳定 id，和右栏批注卡片共用。
  final String id;

  /// marker 命中的正文块 key。
  final String partKey;

  /// marker 在正文块里的起始偏移。
  final int start;

  /// marker 在正文块里的结束偏移。
  final int end;

  /// marker 的统一编号。
  final int number;

  /// marker 的严重程度或亮点类型。
  final ZhenxieReviewIssueSeverityEnum severity;

  const ReviewBoardMarkerData({
    required this.id,
    required this.partKey,
    required this.start,
    required this.end,
    required this.number,
    required this.severity,
  });
}

/// 批改稿纸的文本切片结果。
class ReviewBoardTextSegment {
  /// 当前切片起始偏移。
  final int start;

  /// 当前切片结束偏移。
  final int end;

  /// 当前切片文本。
  final String text;

  /// 当前切片被哪些 marker 覆盖。
  final List<ReviewBoardMarkerData> markers;

  /// 当前切片结束后需要补哪些角标。
  final List<ReviewBoardMarkerData> endingMarkers;

  const ReviewBoardTextSegment({
    required this.start,
    required this.end,
    required this.text,
    required this.markers,
    required this.endingMarkers,
  });
}

/// 批改稿纸订正视图里真正参与展示的一条 edit。
class ReviewBoardAppliedEdit {
  /// 对应的原始 issue id。
  final String id;

  /// 套用后的起始偏移。
  final int start;

  /// 原文结束偏移。
  final int end;

  /// 当前订正文案。
  final String correction;

  /// 当前统一编号，没有编号时为 null。
  final int? number;

  const ReviewBoardAppliedEdit({
    required this.id,
    required this.start,
    required this.end,
    required this.correction,
    required this.number,
  });
}

/// 升格稿 diff token 的操作类型。
enum ReviewBoardDiffTokenOp {
  /// 原文和升格稿一致。
  same,

  /// 原文里被删掉的词。
  removed,

  /// 升格稿里新增的词。
  inserted,
}

/// 批改稿纸升格视图的一段 diff token。
class ReviewBoardDiffToken {
  /// 当前 token 文本，保留尾部空白。
  final String text;

  /// 当前 token 的 diff 操作。
  final ReviewBoardDiffTokenOp op;

  const ReviewBoardDiffToken({
    required this.text,
    required this.op,
  });
}

/// 批改稿纸的 marker 汇总结果。
class ReviewBoardMarkerBundle {
  /// 全量已排序 marker。
  final List<ReviewBoardMarkerData> items;

  /// 按 partKey 分组后的 marker。
  final Map<String, List<ReviewBoardMarkerData>> markersByPart;

  const ReviewBoardMarkerBundle({
    required this.items,
    required this.markersByPart,
  });

  /// 当前批改稿纸是否有可展示的 marker。
  bool get hasDisplayMarkers => items.isNotEmpty;
}

/// 生成批改稿纸需要的统一 marker 列表和分组结果。
ReviewBoardMarkerBundle buildReviewBoardMarkerBundle({
  required List<ZhenxieTaskDetailsMemberWritingPart> parts,
  required ZhenxieTaskDetailsMemberWritingReview? review,
}) {
  final partOrderMap = <String, int>{};
  final partTextMap = <String, String>{};
  for (var index = 0; index < parts.length; index++) {
    final key = parts[index].key ?? '';
    if (key.isEmpty) continue;
    partOrderMap[key] = index;
    partTextMap[key] = parts[index].text ?? '';
  }
  final sortedMarkers = <_ReviewBoardRawMarker>[];
  final issueRows = review?.issues ?? const [];
  final highlightRows = review?.highlights ?? const [];
  final issues = issueRows.whereType<ZhenxieTaskDetailsMemberWritingReviewIssue>().toList();
  final highlights = highlightRows.whereType<ZhenxieTaskDetailsMemberWritingReviewHighlight>().toList();
  for (var sourceIndex = 0; sourceIndex < issues.length; sourceIndex++) {
    final issue = issues[sourceIndex];
    final marker = _buildIssueMarker(
      issue: issue,
      sourceIndex: sourceIndex,
      partOrderMap: partOrderMap,
      partTextMap: partTextMap,
    );
    if (marker != null) sortedMarkers.add(marker);
  }
  for (var sourceIndex = 0; sourceIndex < highlights.length; sourceIndex++) {
    final highlight = highlights[sourceIndex];
    final marker = _buildHighlightMarker(
      highlight: highlight,
      sourceIndex: sourceIndex,
      partOrderMap: partOrderMap,
      partTextMap: partTextMap,
    );
    if (marker != null) sortedMarkers.add(marker);
  }
  sortedMarkers.sort((a, b) {
    final partCompare = a.partOrder.compareTo(b.partOrder);
    if (partCompare != 0) return partCompare;
    final startCompare = a.start.compareTo(b.start);
    if (startCompare != 0) return startCompare;
    final endCompare = a.end.compareTo(b.end);
    if (endCompare != 0) return endCompare;
    return a.id.compareTo(b.id);
  });
  final items = <ReviewBoardMarkerData>[];
  final markersByPart = <String, List<ReviewBoardMarkerData>>{};
  for (var index = 0; index < sortedMarkers.length; index++) {
    final item = ReviewBoardMarkerData(
      id: sortedMarkers[index].id,
      partKey: sortedMarkers[index].partKey,
      start: sortedMarkers[index].start,
      end: sortedMarkers[index].end,
      number: index + 1,
      severity: sortedMarkers[index].severity,
    );
    items.add(item);
    markersByPart.putIfAbsent(item.partKey, () => <ReviewBoardMarkerData>[]).add(item);
  }
  return ReviewBoardMarkerBundle(
    items: items,
    markersByPart: markersByPart,
  );
}

/// 将当前正文和 marker 列表切成可渲染的富文本片段。
List<ReviewBoardTextSegment> buildReviewBoardTextSegments({
  required String text,
  required List<ReviewBoardMarkerData> markers,
}) {
  if (text.isEmpty || markers.isEmpty) return const <ReviewBoardTextSegment>[];
  final points = <int>{0, text.length};
  for (final marker in markers) {
    points.add(marker.start);
    points.add(marker.end);
  }
  final sortedPoints = points.toList()..sort();
  final segments = <ReviewBoardTextSegment>[];
  for (var index = 0; index < sortedPoints.length - 1; index++) {
    final start = sortedPoints[index];
    final end = sortedPoints[index + 1];
    if (end <= start) continue;
    final coveringMarkers = markers.where((item) => item.start <= start && end <= item.end).toList();
    final endingMarkers = markers.where((item) => item.end == end).toList()..sort((a, b) => a.number.compareTo(b.number));
    segments.add(
      ReviewBoardTextSegment(
        start: start,
        end: end,
        text: text.substring(start, end),
        markers: coveringMarkers,
        endingMarkers: endingMarkers,
      ),
    );
  }
  return segments;
}

/// 生成订正视图真正需要套用的 error edits。
List<ReviewBoardAppliedEdit> buildReviewBoardAppliedEdits({
  required String text,
  required List<ZhenxieTaskDetailsMemberWritingReviewIssue> issues,
  required List<ReviewBoardMarkerData> markers,
}) {
  if (text.isEmpty || issues.isEmpty) return const <ReviewBoardAppliedEdit>[];
  final errorMarkerQueues = _buildAppliedEditMarkerQueues(markers);
  final edits = issues.asMap().entries.where((entry) {
    final item = entry.value;
    return item.severity == ZhenxieReviewIssueSeverityEnum.error.value && _isValidIssueAnchor(item.anchor, text);
  }).map((entry) {
    final sourceIndex = entry.key;
    final item = entry.value;
    final anchor = item.anchor!;
    final matchedMarker = _takeAppliedEditMarker(
      anchor: anchor,
      markerQueues: errorMarkerQueues,
    );
    return ReviewBoardAppliedEdit(
      id: matchedMarker?.id ??
          buildZhenxieReviewMarkerId(
            kind: ZhenxieReviewMarkerKind.issue,
            rawId: item.id,
            anchor: anchor,
            sourceIndex: sourceIndex,
          ),
      start: anchor.start!,
      end: anchor.end!,
      correction: item.correction ?? '',
      number: matchedMarker?.number ?? _resolveAppliedEditNumber(issue: item, markers: markers),
    );
  }).toList()
    ..sort((a, b) {
      final startCompare = a.start.compareTo(b.start);
      if (startCompare != 0) return startCompare;
      return b.end.compareTo(a.end);
    });
  final appliedEdits = <ReviewBoardAppliedEdit>[];
  var cursor = 0;
  for (final edit in edits) {
    if (edit.start < cursor) continue;
    var appliedStart = edit.start;
    final after = edit.end < text.length ? text[edit.end] : '';
    final shouldEatLeadingSpace =
        edit.correction.isEmpty && appliedStart > 0 && text[appliedStart - 1] == ' ' && (after.isEmpty || ' ,.!?;:'.contains(after));
    if (shouldEatLeadingSpace) {
      appliedStart -= 1;
    }
    appliedEdits.add(
      ReviewBoardAppliedEdit(
        id: edit.id,
        start: appliedStart,
        end: edit.end,
        correction: edit.correction,
        number: edit.number,
      ),
    );
    cursor = edit.end;
  }
  return appliedEdits;
}

/// 为订正视图预构造可消费的 error marker 队列。
Map<String, List<ReviewBoardMarkerData>> _buildAppliedEditMarkerQueues(List<ReviewBoardMarkerData> markers) {
  final markerQueues = <String, List<ReviewBoardMarkerData>>{};
  for (final marker in markers) {
    if (marker.severity != ZhenxieReviewIssueSeverityEnum.error) continue;
    final queueKey = _appliedEditQueueKey(marker.start, marker.end);
    markerQueues.putIfAbsent(queueKey, () => <ReviewBoardMarkerData>[]).add(marker);
  }
  return markerQueues;
}

/// 按当前 issue anchor 从队列里消费一条真正对应的 marker。
ReviewBoardMarkerData? _takeAppliedEditMarker({
  required ZhenxieTaskDetailsMemberWritingReviewAnchor anchor,
  required Map<String, List<ReviewBoardMarkerData>> markerQueues,
}) {
  final start = anchor.start;
  final end = anchor.end;
  if (start == null || end == null) return null;
  final queue = markerQueues[_appliedEditQueueKey(start, end)];
  if (queue == null || queue.isEmpty) return null;
  return queue.removeAt(0);
}

/// 返回 applied edit 队列匹配 key。
String _appliedEditQueueKey(int start, int end) {
  return '$start-$end';
}

/// 尽量为订正 edit 回捞统一编号，避免 marker 队列兜底失败时角标丢失。
int? _resolveAppliedEditNumber({
  required ZhenxieTaskDetailsMemberWritingReviewIssue issue,
  required List<ReviewBoardMarkerData> markers,
}) {
  final anchor = issue.anchor;
  if (anchor == null) return null;
  final start = anchor.start;
  final end = anchor.end;
  if (start == null || end == null) return null;
  for (final marker in markers) {
    final sameSeverity = marker.severity == ZhenxieReviewIssueSeverityEnum.error;
    if (!sameSeverity) continue;
    if (marker.start == start && marker.end == end) return marker.number;
  }
  for (final marker in markers) {
    final sameSeverity = marker.severity == ZhenxieReviewIssueSeverityEnum.error;
    if (!sameSeverity) continue;
    if (marker.start == start) return marker.number;
  }
  return null;
}

/// 生成升格视图需要的词级 diff token。
List<ReviewBoardDiffToken> buildReviewBoardWordDiff({
  required String before,
  required String after,
}) {
  final beforeTokens = _wordTokens(before);
  final afterTokens = _wordTokens(after);
  if (beforeTokens.isEmpty && afterTokens.isEmpty) return const <ReviewBoardDiffToken>[];
  final table = List<List<int>>.generate(
    beforeTokens.length + 1,
    (_) => List<int>.filled(afterTokens.length + 1, 0),
  );
  for (var i = beforeTokens.length - 1; i >= 0; i--) {
    for (var j = afterTokens.length - 1; j >= 0; j--) {
      if (_tokenKey(beforeTokens[i]) == _tokenKey(afterTokens[j])) {
        table[i][j] = table[i + 1][j + 1] + 1;
        continue;
      }
      final skipBefore = table[i + 1][j];
      final skipAfter = table[i][j + 1];
      table[i][j] = skipBefore >= skipAfter ? skipBefore : skipAfter;
    }
  }
  final tokens = <ReviewBoardDiffToken>[];
  var i = 0;
  var j = 0;
  while (i < beforeTokens.length && j < afterTokens.length) {
    if (_tokenKey(beforeTokens[i]) == _tokenKey(afterTokens[j])) {
      tokens.add(
        ReviewBoardDiffToken(
          text: afterTokens[j],
          op: ReviewBoardDiffTokenOp.same,
        ),
      );
      i++;
      j++;
      continue;
    }
    if (table[i + 1][j] >= table[i][j + 1]) {
      tokens.add(
        ReviewBoardDiffToken(
          text: beforeTokens[i],
          op: ReviewBoardDiffTokenOp.removed,
        ),
      );
      i++;
      continue;
    }
    tokens.add(
      ReviewBoardDiffToken(
        text: afterTokens[j],
        op: ReviewBoardDiffTokenOp.inserted,
      ),
    );
    j++;
  }
  while (i < beforeTokens.length) {
    tokens.add(
      ReviewBoardDiffToken(
        text: beforeTokens[i],
        op: ReviewBoardDiffTokenOp.removed,
      ),
    );
    i++;
  }
  while (j < afterTokens.length) {
    tokens.add(
      ReviewBoardDiffToken(
        text: afterTokens[j],
        op: ReviewBoardDiffTokenOp.inserted,
      ),
    );
    j++;
  }
  return tokens;
}

/// 命中重叠区域时，优先选更具体的 marker。
ReviewBoardMarkerData? resolveReviewBoardTapMarker(List<ReviewBoardMarkerData> markers) {
  if (markers.isEmpty) return null;
  final sortedMarkers = markers.toList()
    ..sort((a, b) {
      final lengthCompare = (a.end - a.start).compareTo(b.end - b.start);
      if (lengthCompare != 0) return lengthCompare;
      return a.start.compareTo(b.start);
    });
  return sortedMarkers.first;
}

/// 根据当前 marker 判断是否有有效锚点数据。
bool hasValidReviewBoardMarkerData(ZhenxieTaskDetailsMemberWritingReview? review, List<ZhenxieTaskDetailsMemberWritingPart> parts) {
  return buildReviewBoardMarkerBundle(parts: parts, review: review).hasDisplayMarkers;
}

/// 将 issue 转成可排序的中间 marker。
_ReviewBoardRawMarker? _buildIssueMarker({
  required ZhenxieTaskDetailsMemberWritingReviewIssue issue,
  required int sourceIndex,
  required Map<String, int> partOrderMap,
  required Map<String, String> partTextMap,
}) {
  final anchor = issue.anchor;
  if (!_isValidAnchor(anchor, partTextMap)) return null;
  final partKey = anchor!.partKey!;
  return _ReviewBoardRawMarker(
    id: buildZhenxieReviewMarkerId(
      kind: ZhenxieReviewMarkerKind.issue,
      rawId: issue.id,
      anchor: anchor,
      sourceIndex: sourceIndex,
    ),
    partKey: partKey,
    start: anchor.start!,
    end: anchor.end!,
    partOrder: partOrderMap[partKey] ?? partOrderMap.length,
    severity: ZhenxieReviewIssueSeverityEnum.fromValue(issue.severity),
  );
}

/// 将 highlight 转成可排序的中间 marker。
_ReviewBoardRawMarker? _buildHighlightMarker({
  required ZhenxieTaskDetailsMemberWritingReviewHighlight highlight,
  required int sourceIndex,
  required Map<String, int> partOrderMap,
  required Map<String, String> partTextMap,
}) {
  final anchor = highlight.anchor;
  if (!_isValidAnchor(anchor, partTextMap)) return null;
  final partKey = anchor!.partKey!;
  return _ReviewBoardRawMarker(
    id: buildZhenxieReviewMarkerId(
      kind: ZhenxieReviewMarkerKind.highlight,
      rawId: highlight.id,
      anchor: anchor,
      sourceIndex: sourceIndex,
    ),
    partKey: partKey,
    start: anchor.start!,
    end: anchor.end!,
    partOrder: partOrderMap[partKey] ?? partOrderMap.length,
    severity: ZhenxieReviewIssueSeverityEnum.highlight,
  );
}

/// 判断当前 anchor 是否真的可以拿来画 marker。
bool _isValidAnchor(
  ZhenxieTaskDetailsMemberWritingReviewAnchor? anchor,
  Map<String, String> partTextMap,
) {
  final partKey = anchor?.partKey ?? '';
  final start = anchor?.start;
  final end = anchor?.end;
  if (partKey.isEmpty || start == null || end == null) return false;
  if (start < 0 || end <= start) return false;
  final text = partTextMap[partKey];
  if (text == null) return false;
  return end <= text.length;
}

/// 判断当前 issue anchor 是否可以直接用于单段订正渲染。
bool _isValidIssueAnchor(ZhenxieTaskDetailsMemberWritingReviewAnchor? anchor, String text) {
  final start = anchor?.start;
  final end = anchor?.end;
  if (start == null || end == null) return false;
  if (start < 0 || end <= start) return false;
  return end <= text.length;
}

/// 将字符串按“单词 + 尾部空白”切成 token。
List<String> _wordTokens(String text) {
  return RegExp(r'\S+\s*').allMatches(text).map((item) => item.group(0) ?? '').where((item) => item.isNotEmpty).toList();
}

/// 词级 diff 比较时忽略 token 两端空白。
String _tokenKey(String token) {
  return token.trim();
}

/// marker 排序时使用的中间结构。
class _ReviewBoardRawMarker {
  /// marker 稳定 id。
  final String id;

  /// marker 命中的正文块 key。
  final String partKey;

  /// marker 起始偏移。
  final int start;

  /// marker 结束偏移。
  final int end;

  /// marker 所在正文块顺序。
  final int partOrder;

  /// marker 严重程度。
  final ZhenxieReviewIssueSeverityEnum severity;

  const _ReviewBoardRawMarker({
    required this.id,
    required this.partKey,
    required this.start,
    required this.end,
    required this.partOrder,
    required this.severity,
  });
}
