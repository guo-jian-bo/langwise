import '../../../../../common/enum/enum.dart';
import '../../../../../common/entities/entities.dart';
import '../../../../../utils/review_marker_id_utils.dart';

/// 右栏批注列表的统一条目类型。
enum ZhenxieTaskCorrectionReviewItemType {
  /// 错误或建议批注。
  issue,

  /// 亮点批注。
  highlight,
}

/// 批改右栏与左稿纸共用的统一批注条目。
class ZhenxieTaskCorrectionReviewItem {
  /// 当前条目的稳定 id。
  final String id;

  /// 当前条目的统一编号。
  final int number;

  /// 当前条目类型。
  final ZhenxieTaskCorrectionReviewItemType type;

  /// 当前条目的锚点。
  final ZhenxieTaskDetailsMemberWritingReviewAnchor anchor;

  /// 原始 issue，只有 issue 类型时存在。
  final ZhenxieTaskDetailsMemberWritingReviewIssue? issue;

  /// 原始 highlight，只有 highlight 类型时存在。
  final ZhenxieTaskDetailsMemberWritingReviewHighlight? highlight;

  const ZhenxieTaskCorrectionReviewItem({
    required this.id,
    required this.number,
    required this.type,
    required this.anchor,
    this.issue,
    this.highlight,
  });

  /// 当前是否为亮点。
  bool isHighlight() {
    return type == ZhenxieTaskCorrectionReviewItemType.highlight;
  }

  /// 当前是否为错误批注。
  bool isErrorIssue() {
    return issue?.severity == ZhenxieReviewIssueSeverityEnum.error.value;
  }

  /// 当前是否为建议批注。
  bool isSuggestionIssue() {
    return issue?.severity == ZhenxieReviewIssueSeverityEnum.suggestion.value;
  }

  /// 当前条目在右栏筛选里对应的 key。
  String filterKey() {
    if (isHighlight()) return ZhenxieReviewMarkerTabEnum.highlight.value;
    return issue?.dimension ?? ZhenxieReviewMarkerTabEnum.grammar.value;
  }
}

/// 统一构造右栏与左稿纸共用的批注列表。
List<ZhenxieTaskCorrectionReviewItem> buildZhenxieTaskCorrectionReviewItems({
  required List<ZhenxieTaskDetailsMemberWritingPart> parts,
  required List<ZhenxieTaskDetailsMemberWritingReviewIssue> issues,
  required List<ZhenxieTaskDetailsMemberWritingReviewHighlight> highlights,
}) {
  final partOrderMap = <String, int>{};
  for (var index = 0; index < parts.length; index++) {
    final key = parts[index].key ?? '';
    if (key.isEmpty) continue;
    partOrderMap[key] = index;
  }
  final rawItems = <_ZhenxieTaskCorrectionReviewRawItem>[];
  for (var sourceIndex = 0; sourceIndex < issues.length; sourceIndex++) {
    final issue = issues[sourceIndex];
    final anchor = issue.anchor;
    if (anchor == null || !_hasValidAnchor(anchor)) continue;
    rawItems.add(
      _ZhenxieTaskCorrectionReviewRawItem.issue(
        id: buildZhenxieReviewMarkerId(
          kind: ZhenxieReviewMarkerKind.issue,
          rawId: issue.id,
          anchor: anchor,
          sourceIndex: sourceIndex,
        ),
        anchor: anchor,
        issue: issue,
      ),
    );
  }
  for (var sourceIndex = 0; sourceIndex < highlights.length; sourceIndex++) {
    final highlight = highlights[sourceIndex];
    final anchor = highlight.anchor;
    if (anchor == null || !_hasValidAnchor(anchor)) continue;
    rawItems.add(
      _ZhenxieTaskCorrectionReviewRawItem.highlight(
        id: buildZhenxieReviewMarkerId(
          kind: ZhenxieReviewMarkerKind.highlight,
          rawId: highlight.id,
          anchor: anchor,
          sourceIndex: sourceIndex,
        ),
        anchor: anchor,
        highlight: highlight,
      ),
    );
  }
  rawItems.sort((left, right) {
    final leftPartOrder = partOrderMap[left.anchor.partKey ?? ''] ?? parts.length;
    final rightPartOrder = partOrderMap[right.anchor.partKey ?? ''] ?? parts.length;
    final partCompare = leftPartOrder.compareTo(rightPartOrder);
    if (partCompare != 0) return partCompare;
    final startCompare = (left.anchor.start ?? 1 << 20).compareTo(right.anchor.start ?? 1 << 20);
    if (startCompare != 0) return startCompare;
    final endCompare = (left.anchor.end ?? 1 << 20).compareTo(right.anchor.end ?? 1 << 20);
    if (endCompare != 0) return endCompare;
    return left.id.compareTo(right.id);
  });
  return List.generate(rawItems.length, (index) => rawItems[index].toReviewItem(index + 1));
}

/// helper 内部使用的原始批注行。
class _ZhenxieTaskCorrectionReviewRawItem {
  /// 当前原始条目的稳定 id。
  final String id;

  /// 当前原始条目类型。
  final ZhenxieTaskCorrectionReviewItemType type;

  /// 当前原始条目的锚点。
  final ZhenxieTaskDetailsMemberWritingReviewAnchor anchor;

  /// 当前原始条目对应的 issue。
  final ZhenxieTaskDetailsMemberWritingReviewIssue? issue;

  /// 当前原始条目对应的 highlight。
  final ZhenxieTaskDetailsMemberWritingReviewHighlight? highlight;

  const _ZhenxieTaskCorrectionReviewRawItem.issue({
    required this.id,
    required this.anchor,
    required ZhenxieTaskDetailsMemberWritingReviewIssue this.issue,
  })  : type = ZhenxieTaskCorrectionReviewItemType.issue,
        highlight = null;

  const _ZhenxieTaskCorrectionReviewRawItem.highlight({
    required this.id,
    required this.anchor,
    required ZhenxieTaskDetailsMemberWritingReviewHighlight this.highlight,
  })  : type = ZhenxieTaskCorrectionReviewItemType.highlight,
        issue = null;

  /// 按统一编号产出最终条目。
  ZhenxieTaskCorrectionReviewItem toReviewItem(int number) {
    return ZhenxieTaskCorrectionReviewItem(
      id: id,
      number: number,
      type: type,
      anchor: anchor,
      issue: issue,
      highlight: highlight,
    );
  }
}

/// 判断当前 anchor 是否真的可以参与批改定位。
bool _hasValidAnchor(ZhenxieTaskDetailsMemberWritingReviewAnchor? anchor) {
  if (anchor == null) return false;
  final partKey = anchor.partKey ?? '';
  final start = anchor.start;
  final end = anchor.end;
  return partKey.isNotEmpty && start != null && end != null && start >= 0 && end > start;
}
