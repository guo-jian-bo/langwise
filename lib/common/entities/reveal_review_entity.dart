import 'article_entity.dart';

/// 管理端甄听审核列表：单条记录实体
class RevealReviewItemEntity {
  /// 审核来源链接
  final String? sourceUrl;

  /// 曲风名称，多语言
  final List<RevealReviewLangTextEntity> revealGenreName;

  /// 主题名称，多语言
  final List<RevealReviewLangTextEntity> revealThemeName;

  /// 对应的一组文章内容列表
  final List<ArticleEntity> contentList;

  RevealReviewItemEntity({
    this.sourceUrl,
    required this.revealGenreName,
    required this.revealThemeName,
    required this.contentList,
  });

  factory RevealReviewItemEntity.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? genreList = json['revealGenreName'] as List<dynamic>?;
    final List<dynamic>? themeList = json['revealThemeName'] as List<dynamic>?;
    final List<dynamic>? contents = json['contentlist'] as List<dynamic>?;

    return RevealReviewItemEntity(
      sourceUrl: json['sourceUrl'] as String?,
      revealGenreName: genreList == null
          ? <RevealReviewLangTextEntity>[]
          : genreList
              .map((e) => RevealReviewLangTextEntity.fromJson(e as Map<String, dynamic>))
              .toList(),
      revealThemeName: themeList == null
          ? <RevealReviewLangTextEntity>[]
          : themeList
              .map((e) => RevealReviewLangTextEntity.fromJson(e as Map<String, dynamic>))
              .toList(),
      contentList: contents == null
          ? <ArticleEntity>[]
          : contents
              .map((e) => ArticleEntity.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sourceUrl': sourceUrl,
      'revealGenreName': revealGenreName.map((e) => e.toJson()).toList(),
      'revealThemeName': revealThemeName.map((e) => e.toJson()).toList(),
      'contentlist': contentList.map((e) => e.toJson()).toList(),
    };
  }
}

/// 审核列表中多语言文本实体
class RevealReviewLangTextEntity {
  final String? lang;
  final String? text;

  RevealReviewLangTextEntity({
    this.lang,
    this.text,
  });

  factory RevealReviewLangTextEntity.fromJson(Map<String, dynamic> json) {
    return RevealReviewLangTextEntity(
      lang: json['lang'] as String?,
      text: json['text'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'lang': lang,
      'text': text,
    };
  }
}
