/// 单元下歌曲列表整体信息
class SongUnitInfoEntity {
  final int? moduleId;
  final String? moduleName;
  final int? unitId;
  final String? unitName;
  final int? unitIndex;
  final String? description;
  final int? lessonCount;
  final List<SongKnowledgeEntity>? knowledgeList;

  SongUnitInfoEntity({
    this.moduleId,
    this.moduleName,
    this.unitId,
    this.unitName,
    this.unitIndex,
    this.description,
    this.lessonCount,
    this.knowledgeList,
  });

  factory SongUnitInfoEntity.fromJson(Map<String, dynamic> json) {
    List<SongKnowledgeEntity>? list;
    if (json['knowledgeList'] != null) {
      list = (json['knowledgeList'] as List).map((e) => SongKnowledgeEntity.fromJson(e as Map<String, dynamic>)).toList();
    }

    return SongUnitInfoEntity(
      moduleId: json['moduleId'] as int?,
      moduleName: json['moduleName'] as String?,
      unitId: json['unitId'] as int?,
      unitName: json['unitName'] as String?,
      unitIndex: json['unitIndex'] as int?,
      description: json['description'] as String?,
      lessonCount: json['lessonCount'] as int?,
      knowledgeList: list,
    );
  }

  Map<String, dynamic> toJson() => {
        'moduleId': moduleId,
        'moduleName': moduleName,
        'unitId': unitId,
        'unitName': unitName,
        'unitIndex': unitIndex,
        'description': description,
        'lessonCount': lessonCount,
        'knowledgeList': knowledgeList?.map((e) => e.toJson()).toList(),
      };
}

/// 单条歌曲知识
class SongKnowledgeEntity {
  final int? uid;
  final String? unitName;
  final String? contentType;
  final int? contentId;
  final int? semanticId;
  final String? content;
  final String? contentTypeTitle;
  final String? title;
  final List<SongTagEntity>? tags;
  final String? theme;
  final String? genre;
  final String? imageUrl;
  final String? audioUrl;
  final SongDifficultyEntity? difficulty;
  final List<dynamic>? breakdownLevel;
  final List<SongPronunciationEntity>? pronunciations;
  final num? order;

  SongKnowledgeEntity({
    this.uid,
    this.unitName,
    this.contentType,
    this.contentId,
    this.semanticId,
    this.content,
    this.contentTypeTitle,
    this.title,
    this.tags,
    this.genre,
    this.theme,
    this.imageUrl,
    this.audioUrl,
    this.difficulty,
    this.breakdownLevel,
    this.pronunciations,
    this.order,
  });

  factory SongKnowledgeEntity.fromJson(Map<String, dynamic> json) {
    List<SongTagEntity>? tagList;
    if (json['tags'] != null) {
      tagList = (json['tags'] as List).map((e) => SongTagEntity.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<SongPronunciationEntity>? pronunciationList;
    if (json['pronunciations'] != null) {
      pronunciationList = (json['pronunciations'] as List).map((e) => SongPronunciationEntity.fromJson(e as Map<String, dynamic>)).toList();
    }

    return SongKnowledgeEntity(
      uid: json['uid'] as int?,
      unitName: json['unitName'] as String?,
      contentType: json['contentType'] as String?,
      contentId: json['contentId'] as int?,
      semanticId: json['semanticId'] as int?,
      content: json['content'] as String?,
      contentTypeTitle: json['contentTypeTitle'] as String?,
      title: json['title'] as String?,
      tags: tagList,
      genre: json['genre'] as String?,
      theme: json['theme'] as String?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      difficulty: json['difficulty'] != null ? SongDifficultyEntity.fromJson(json['difficulty'] as Map<String, dynamic>) : null,
      breakdownLevel: json['breakdownLevel'] as List?,
      pronunciations: pronunciationList,
      order: json['order'] as num?,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'unitName': unitName,
        'contentType': contentType,
        'contentId': contentId,
        'semanticId': semanticId,
        'content': content,
        'contentTypeTitle': contentTypeTitle,
        'title': title,
        'tags': tags?.map((e) => e.toJson()).toList(),
        'genre': genre,
        'theme': theme,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'difficulty': difficulty?.toJson(),
        'breakdownLevel': breakdownLevel,
        'pronunciations': pronunciations?.map((e) => e.toJson()).toList(),
        'order': order,
      };
}

/// 标签
class SongTagEntity {
  final List<SongTagGlossEntity>? gloss;
  final List<SongTagStyleEntity>? style;

  const SongTagEntity({this.gloss, this.style});

  factory SongTagEntity.fromJson(Map<String, dynamic> json) {
    List<SongTagGlossEntity>? glossList;
    if (json['gloss'] != null) {
      glossList = (json['gloss'] as List).map((e) => SongTagGlossEntity.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<SongTagStyleEntity>? styleList;
    if (json['style'] != null) {
      styleList = (json['style'] as List).map((e) => SongTagStyleEntity.fromJson(e as Map<String, dynamic>)).toList();
    }

    return SongTagEntity(
      gloss: glossList,
      style: styleList,
    );
  }

  Map<String, dynamic> toJson() => {
        'gloss': gloss?.map((e) => e.toJson()).toList(),
        'style': style?.map((e) => e.toJson()).toList(),
      };
}

/// 标签文案
class SongTagGlossEntity {
  final String? lang;
  final String? text;

  const SongTagGlossEntity({this.lang, this.text});

  factory SongTagGlossEntity.fromJson(Map<String, dynamic> json) => SongTagGlossEntity(
        lang: json['lang'] as String?,
        text: json['text'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'lang': lang,
        'text': text,
      };
}

/// 标签样式
class SongTagStyleEntity {
  final String? theme;
  final String? color;
  final int? fontsize;
  final bool? italic;
  final int? weight;
  final String? backgroundColor;

  const SongTagStyleEntity({
    this.theme,
    this.color,
    this.fontsize,
    this.italic,
    this.weight,
    this.backgroundColor,
  });

  factory SongTagStyleEntity.fromJson(Map<String, dynamic> json) => SongTagStyleEntity(
        theme: json['theme'] as String?,
        color: json['color'] as String?,
        fontsize: json['fontsize'] as int?,
        italic: json['italic'] as bool?,
        weight: json['weight'] as int?,
        backgroundColor: json['backgroundColor'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'theme': theme,
        'color': color,
        'fontsize': fontsize,
        'italic': italic,
        'weight': weight,
        'backgroundColor': backgroundColor,
      };
}

/// 难度
class SongDifficultyEntity {
  final int? max;
  final int? min;

  const SongDifficultyEntity({this.max, this.min});

  factory SongDifficultyEntity.fromJson(Map<String, dynamic> json) => SongDifficultyEntity(
        max: json['max'] as int?,
        min: json['min'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'max': max,
        'min': min,
      };
}

/// 发音信息
class SongPronunciationEntity {
  final String? audioUrl;
  final double? duration;
  final String? audioAss;
  final String? national;
  final String? nationalTitle;
  final String? nationalIconUrl;

  const SongPronunciationEntity({
    this.audioUrl,
    this.duration,
    this.audioAss,
    this.national,
    this.nationalTitle,
    this.nationalIconUrl,
  });

  factory SongPronunciationEntity.fromJson(Map<String, dynamic> json) => SongPronunciationEntity(
        audioUrl: json['audioUrl'] as String?,
        duration: (json['duration'] as num?)?.toDouble(),
        audioAss: json['audioAss'] as String?,
        national: json['national'] as String?,
        nationalTitle: json['nationalTitle'] as String?,
        nationalIconUrl: json['nationalIconUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'audioUrl': audioUrl,
        'duration': duration,
        'audioAss': audioAss,
        'national': national,
        'nationalTitle': nationalTitle,
        'nationalIconUrl': nationalIconUrl,
      };
}
