import 'entities.dart';

/// 写作语法 Target 轻量信息实体，对应 `POST /course/write/target/list` 返回项。
class CourseWriteTargetItemEntity {
  /// Target 主键。
  int? uid;

  /// Target 标题，多语言结构。
  List<LanguageText?>? title;

  /// 语法资产类型中文名，供前端直接展示。
  String? kindTitle;

  CourseWriteTargetItemEntity({
    this.uid,
    this.title,
    this.kindTitle,
  });

  CourseWriteTargetItemEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    title = _parseLanguageTextList(json['title']);
    kindTitle = json['kindTitle']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['title'] = title?.map((e) => e?.toJson()).toList();
    data['kindTitle'] = kindTitle;
    return data;
  }
}

/// 统一解析语言文案数组，避免页面层散落原始 JSON 判断。
List<LanguageText?>? _parseLanguageTextList(dynamic value) {
  if (value is! List) return null;
  return value.map((item) {
    if (item is! Map<String, dynamic>) return null;
    return LanguageText.fromJson(item);
  }).toList();
}
