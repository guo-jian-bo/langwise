class ZhenduPracticeParams {
  final int scriptId;
  final int? collectionId;
  final int? difficulty;
  final String? locate;
  final int? styleId;
  final String? dialect;

  const ZhenduPracticeParams({
    required this.scriptId,
    this.collectionId,
    this.difficulty,
    this.locate,
    this.styleId,
    this.dialect,
  });

  static ZhenduPracticeParams? fromAny(dynamic value) {
    if (value is Map<String, String?>) return fromGetParameters(value);
    if (value is Map<String, String>) return fromGetParameters(value);
    if (value is Map) {
      final sid = int.tryParse((value['scriptId'] ?? '').toString().trim());
      if (sid == null) return null;
      final collectionId = int.tryParse((value['collectionId'] ?? '').toString().trim());
      final difficulty = int.tryParse((value['difficulty'] ?? '').toString().trim());
      final locateRaw = (value['locate'] ?? '').toString().trim();
      final styleId = int.tryParse((value['styleId'] ?? '').toString().trim());
      final dialectRaw = (value['dialect'] ?? '').toString().trim();
      return ZhenduPracticeParams(
        scriptId: sid,
        collectionId: collectionId,
        difficulty: difficulty,
        locate: locateRaw.isEmpty ? null : locateRaw,
        styleId: styleId,
        dialect: dialectRaw.isEmpty ? null : dialectRaw,
      );
    }
    return null;
  }

  static ZhenduPracticeParams? fromGetParameters(Map<String, String?> parameters) {
    final sid = int.tryParse((parameters['scriptId'] ?? '').trim());
    if (sid == null) return null;
    final collectionId = int.tryParse((parameters['collectionId'] ?? '').trim());
    final difficulty = int.tryParse((parameters['difficulty'] ?? '').trim());
    final locateRaw = (parameters['locate'] ?? '').trim();
    final styleId = int.tryParse((parameters['styleId'] ?? '').trim());
    final dialectRaw = (parameters['dialect'] ?? '').trim();
    return ZhenduPracticeParams(
      scriptId: sid,
      collectionId: collectionId,
      difficulty: difficulty,
      locate: locateRaw.isEmpty ? null : locateRaw,
      styleId: styleId,
      dialect: dialectRaw.isEmpty ? null : dialectRaw,
    );
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'scriptId': scriptId,
    };
    if (collectionId != null) result['collectionId'] = collectionId;
    if (difficulty != null) result['difficulty'] = difficulty;
    final locateValue = locate?.trim() ?? '';
    if (locateValue.isNotEmpty) result['locate'] = locateValue;
    if (styleId != null) result['styleId'] = styleId;
    final dialectValue = dialect?.trim() ?? '';
    if (dialectValue.isNotEmpty) result['dialect'] = dialectValue;
    return result;
  }

  Map<String, String> toGetParameters() {
    final result = <String, String>{
      'scriptId': scriptId.toString(),
    };
    if (collectionId != null) result['collectionId'] = collectionId.toString();
    if (difficulty != null) result['difficulty'] = difficulty.toString();
    final locateValue = locate?.trim() ?? '';
    if (locateValue.isNotEmpty) result['locate'] = locateValue;
    if (styleId != null) result['styleId'] = styleId.toString();
    final dialectValue = dialect?.trim() ?? '';
    if (dialectValue.isNotEmpty) result['dialect'] = dialectValue;
    return result;
  }

  Map<String, dynamic> toQueryParameters() {
    final result = <String, dynamic>{};
    final locateValue = locate?.trim() ?? '';
    if (locateValue.isNotEmpty) result['locate'] = locateValue;
    if (styleId != null) result['styleId'] = styleId;
    final dialectValue = dialect?.trim() ?? '';
    if (dialectValue.isNotEmpty) result['dialect'] = dialectValue;
    return result;
  }
}
