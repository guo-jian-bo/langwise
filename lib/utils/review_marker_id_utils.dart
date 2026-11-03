import '../common/entities/entities.dart';

/// 真写批改 marker 的稳定类型。
enum ZhenxieReviewMarkerKind {
  /// 错误或建议批注。
  issue('issue'),

  /// 亮点批注。
  highlight('highlight');

  /// 用于拼接稳定 id 的字符串值。
  final String value;

  const ZhenxieReviewMarkerKind(this.value);
}

/// 构造真写批改链路统一使用的 marker id。
String buildZhenxieReviewMarkerId({
  required ZhenxieReviewMarkerKind kind,
  String? rawId,
  required ZhenxieTaskDetailsMemberWritingReviewAnchor anchor,
  required int sourceIndex,
}) {
  final partKey = anchor.partKey ?? '';
  final start = anchor.start ?? 0;
  final end = anchor.end ?? 0;
  final resolvedRawId = rawId?.isNotEmpty == true ? rawId! : '$partKey-$start-$end';
  final sourceKey = sourceIndex.toString().padLeft(4, '0');
  return '${kind.value}::$resolvedRawId::$partKey::$start::$end::$sourceKey';
}
