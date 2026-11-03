import 'package:langwise/common/entities/song_unit_info_entity.dart';

/// 歌曲主题与风格配置实体
class SongThemeListEntity {
  final List<SongThemeEntity>? themes;
  final List<SongGenreEntity>? genres;
  final List<String>? cefrLevels;

  const SongThemeListEntity({this.themes, this.genres, this.cefrLevels});

  factory SongThemeListEntity.fromJson(Map<String, dynamic> json) {
    List<SongThemeEntity>? themes;
    if (json['themes'] != null) {
      themes = (json['themes'] as List).map((e) => SongThemeEntity.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<SongGenreEntity>? genres;
    if (json['genres'] != null) {
      genres = (json['genres'] as List).map((e) => SongGenreEntity.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<String>? cefrLevels;
    if (json['cefrLevels'] != null) {
      cefrLevels = (json['cefrLevels'] as List).map((e) => e.toString()).toList();
    }

    return SongThemeListEntity(
      themes: themes,
      genres: genres,
      cefrLevels: cefrLevels,
    );
  }

  Map<String, dynamic> toJson() => {
        'themes': themes?.map((e) => e.toJson()).toList(),
        'genres': genres?.map((e) => e.toJson()).toList(),
        'cefrLevels': cefrLevels,
      };
}

class SongThemeEntity {
  final String? id;
  final dynamic v;
  final dynamic uid;
  final List<LangTextEntity>? name;
  final List<LangTextEntity>? description;
  final List<String>? scope;
  final String? updated;
  final String? created;

  const SongThemeEntity({
    this.id,
    this.v,
    this.uid,
    this.name,
    this.description,
    this.scope,
    this.updated,
    this.created,
  });

  factory SongThemeEntity.fromJson(Map<String, dynamic> json) {
    List<LangTextEntity>? name;
    if (json['name'] != null) {
      name = (json['name'] as List).map((e) => LangTextEntity.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<LangTextEntity>? description;
    if (json['description'] != null) {
      description = (json['description'] as List).map((e) => LangTextEntity.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<String>? scope;
    if (json['scope'] != null) {
      scope = (json['scope'] as List).map((e) => e.toString()).toList();
    }

    return SongThemeEntity(
      id: json['id'] as String?,
      v: json['v'],
      uid: json['uid'],
      name: name,
      description: description,
      scope: scope,
      updated: json['updated'] as String?,
      created: json['created'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'v': v,
        'uid': uid,
        'name': name?.map((e) => e.toJson()).toList(),
        'description': description?.map((e) => e.toJson()).toList(),
        'scope': scope,
        'updated': updated,
        'created': created,
      };
}

/// 单元歌曲 + 歌曲风格列表合并结果
class SongGenresResponseEntity {
  final SongUnitInfoEntity? unitKnowledgeDTO;
  final List<SongGenreEntity>? genres;

  const SongGenresResponseEntity({this.unitKnowledgeDTO, this.genres});

  factory SongGenresResponseEntity.fromJson(Map<String, dynamic> json) {
    SongUnitInfoEntity? unitKnowledgeDTO;
    if (json['unitKnowledgeDTO'] != null) {
      unitKnowledgeDTO = SongUnitInfoEntity.fromJson(json['unitKnowledgeDTO'] as Map<String, dynamic>);
    }

    List<SongGenreEntity>? genres;
    if (json['genres'] != null) {
      genres = (json['genres'] as List).map((e) => SongGenreEntity.fromJson(e as Map<String, dynamic>)).toList();
    }

    return SongGenresResponseEntity(
      unitKnowledgeDTO: unitKnowledgeDTO,
      genres: genres,
    );
  }

  Map<String, dynamic> toJson() => {
        'unitKnowledgeDTO': unitKnowledgeDTO?.toJson(),
        'genres': genres?.map((e) => e.toJson()).toList(),
      };
}

class SongGenreEntity {
  final dynamic uid;
  final List<LangTextEntity>? name;
  final List<LangTextEntity>? description;
  final List<String>? scope;
  final String? descriptionForPrompt;
  final String? audioUrl;
  final String? updated;
  final String? created;
  final int? inUnitCount;

  const SongGenreEntity({
    this.uid,
    this.name,
    this.description,
    this.scope,
    this.descriptionForPrompt,
    this.audioUrl,
    this.updated,
    this.created,
    this.inUnitCount,
  });

  factory SongGenreEntity.fromJson(Map<String, dynamic> json) {
    List<LangTextEntity>? name;
    if (json['name'] != null) {
      name = (json['name'] as List).map((e) => LangTextEntity.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<LangTextEntity>? description;
    if (json['description'] != null) {
      description = (json['description'] as List).map((e) => LangTextEntity.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<String>? scope;
    if (json['scope'] != null) {
      scope = (json['scope'] as List).map((e) => e.toString()).toList();
    }

    return SongGenreEntity(
      uid: json['uid'],
      name: name,
      description: description,
      scope: scope,
      descriptionForPrompt: json['description_for_prompt'] as String?,
      audioUrl: json['audioUrl'] as String?,
      updated: json['updated'] as String?,
      created: json['created'] as String?,
      inUnitCount: json['inUnitCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name?.map((e) => e.toJson()).toList(),
        'description': description?.map((e) => e.toJson()).toList(),
        'scope': scope,
        'description_for_prompt': descriptionForPrompt,
        'audioUrl': audioUrl,
        'updated': updated,
        'created': created,
        'inUnitCount': inUnitCount,
      };
}

class LangTextEntity {
  final String? lang;
  final String? text;

  const LangTextEntity({this.lang, this.text});

  factory LangTextEntity.fromJson(Map<String, dynamic> json) => LangTextEntity(
        lang: json['lang'] as String?,
        text: json['text'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'lang': lang,
        'text': text,
      };
}
