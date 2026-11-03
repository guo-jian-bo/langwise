import 'package:langwise/common/entities/lock_entity.dart';

import 'card_public_entity.dart';
import 'knowledge_common_entity.dart';
import 'manage_subscribe_entity.dart';
import 'theme_style_entity.dart';

class UserRevealTagEntity {
  List<ManageSubscribeNameItem>? gloss;
  List<ThemeTextStyleEntity>? style;

  UserRevealTagEntity({
    this.gloss,
    this.style,
  });

  UserRevealTagEntity.fromJson(Map<String, dynamic> json) {
    if (json['gloss'] != null) {
      final v = json['gloss'] as List;
      final arr = <ManageSubscribeNameItem>[];
      for (final e in v) {
        arr.add(ManageSubscribeNameItem.fromJson(e as Map<String, dynamic>));
      }
      gloss = arr;
    }

    if (json['style'] != null) {
      final v = json['style'] as List;
      final arr = <ThemeTextStyleEntity>[];
      for (final e in v) {
        arr.add(ThemeTextStyleEntity.fromJson(e as Map<String, dynamic>));
      }
      style = arr;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (gloss != null) {
      data['gloss'] = gloss!.map((e) => e.toJson()).toList();
    }
    if (style != null) {
      data['style'] = style!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class UserRevealDifficultyEntity {
  int? max;
  int? min;

  UserRevealDifficultyEntity({
    this.max,
    this.min,
  });

  UserRevealDifficultyEntity.fromJson(Map<String, dynamic> json) {
    max = json['max']?.toInt();
    min = json['min']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['max'] = max;
    data['min'] = min;
    return data;
  }
}

class UserRevealDetailItemEntity {
  String? contentType;
  String? contentTypeTitle;
  int? contentId;
  int? styleId;
  String? dialect;
  String? title;
  String? content;
  List<ManageSubscribeNameItem>? gloss;
  List<UserRevealTagEntity>? tags;
  UserRevealDifficultyEntity? difficulty;
  String? imageUrl;
  bool? isRead;
  bool? isNewContent;
  LockEntity? cardRights;
  bool? favourite;

  UserRevealDetailItemEntity({
    this.contentType,
    this.contentTypeTitle,
    this.contentId,
    this.styleId,
    this.dialect,
    this.title,
    this.content,
    this.gloss,
    this.tags,
    this.difficulty,
    this.imageUrl,
    this.isRead,
    this.isNewContent,
    this.cardRights,
    this.favourite
  });

  UserRevealDetailItemEntity.fromJson(Map<String, dynamic> json) {
    contentType = json['contentType']?.toString();
    contentTypeTitle = json['contentTypeTitle']?.toString();
    contentId = json['contentId']?.toInt();
    styleId = json['styleId']?.toInt();
    dialect = json['dialect']?.toString();
    title = json['title']?.toString();
    content = json['content']?.toString();

    if (json['gloss'] != null) {
      final v = json['gloss'] as List;
      final arr = <ManageSubscribeNameItem>[];
      for (final e in v) {
        arr.add(ManageSubscribeNameItem.fromJson(e as Map<String, dynamic>));
      }
      gloss = arr;
    }

    if (json['tags'] != null) {
      final v = json['tags'] as List;
      final arr = <UserRevealTagEntity>[];
      for (final e in v) {
        arr.add(UserRevealTagEntity.fromJson(e as Map<String, dynamic>));
      }
      tags = arr;
    }

    if (json['difficulty'] != null) {
      difficulty = UserRevealDifficultyEntity.fromJson(
        json['difficulty'] as Map<String, dynamic>,
      );
    }
    imageUrl = json['imageUrl']?.toString();
    isRead = json['isRead']??false;
    isNewContent = json['isNewContent']??false;
    favourite = json['favorited'] ?? false;
    
    if (json['cardRights'] != null) {
      cardRights = LockEntity.fromJson(json['cardRights'] as Map<String, dynamic>);
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['contentType'] = contentType;
    data['contentTypeTitle'] = contentTypeTitle;
    data['contentId'] = contentId;
    data['styleId'] = styleId;
    data['dialect'] = dialect;
    data['title'] = title;
    data['content'] = content;
    data['favorited'] = favourite;
    if (gloss != null) {
      data['gloss'] = gloss!.map((e) => e.toJson()).toList();
    }

    if (tags != null) {
      data['tags'] = tags!.map((e) => e.toJson()).toList();
    }

    if (difficulty != null) {
      data['difficulty'] = difficulty!.toJson();
    }

    data['imageUrl'] = imageUrl;
    data['isRead'] = isRead;
    data['isNewContent'] = isNewContent;
    data['cardRights'] = cardRights?.toJson();
    return data;
  }
}

class UserRevealDetailsPageEntity {
  int? count;
  List<UserRevealDetailItemEntity>? datas;

  UserRevealDetailsPageEntity({
    this.count,
    this.datas,
  });

  UserRevealDetailsPageEntity.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> inner = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    count = inner['count']?.toInt();

    if (inner['datas'] != null) {
      final list = inner['datas'] as List;
      final arr = <UserRevealDetailItemEntity>[];
      for (final e in list) {
        arr.add(UserRevealDetailItemEntity.fromJson(e as Map<String, dynamic>));
      }
      datas = arr;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['count'] = count;
    if (datas != null) {
      data['datas'] = datas!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class UserRevealDetailsV2PageEntity {
  int? count;
  int? offset;
  int? limit;
  List<KnowledgeCommonEntityList>? datas;

  UserRevealDetailsV2PageEntity({
    this.count,
    this.offset,
    this.limit,
    this.datas,
  });

  UserRevealDetailsV2PageEntity.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> inner =
        json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    final dynamic rawList = inner['datas'] ?? inner['list'];

    count = _toInt(inner['count']);
    offset = _toInt(inner['offset']);
    limit = _toInt(inner['limit']);

    if (rawList is List) {
      final arr = <KnowledgeCommonEntityList>[];
      for (final dynamic e in rawList) {
        if (e is! Map<String, dynamic>) continue;
        arr.add(_toKnowledgeCommonEntity(e));
      }
      datas = arr;
      count ??= arr.length;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['count'] = count;
    data['offset'] = offset;
    data['limit'] = limit;
    if (datas != null) {
      data['datas'] = datas!.map((e) => e.toJson()).toList();
    }
    return data;
  }

  static KnowledgeCommonEntityList _toKnowledgeCommonEntity(
    Map<String, dynamic> json,
  ) {
    final bool isKnowledgeCommon =
        (json['contentTypeTitle'] == null ||
            json['contentTypeTitle'] is Map<String, dynamic>) &&
        (json['content'] == null || json['content'] is Map<String, dynamic>) &&
        (json['coverImage'] == null || json['coverImage'] is Map<String, dynamic>);
    if (isKnowledgeCommon) {
      return KnowledgeCommonEntityList.fromJson(json);
    }

    final Map<String, dynamic> mapped = <String, dynamic>{
      'contentType': json['contentType'],
      'contentTypeTitle': _wrapContentTypeTitle(json['contentTypeTitle']),
      'contentId': _toInt(json['contentId']),
      'content': <String, dynamic>{
        'type': json['contentType'],
        'uid': _toInt(json['contentId']),
        'semanticId': _toInt(json['semanticId']) ?? _firstInt(json['semanticIds']),
        'styleId': _toInt(json['styleId']),
        'dialect': json['dialect']?.toString(),
      },
      'title': json['title']?.toString() ?? json['content']?.toString(),
      'subTitle': json['definition']?.toString(),
      'focus': _toLanguageTextJsonList(json['gloss']),
      'coverImage': _wrapCoverImage(json),
      'coverVideo': _wrapCoverVideo(json['video']),
      'tags': _toTagJsonList(json['tags']),
      'rights': _wrapRights(json),
      'favorited': json['favorited'],
    };
    return KnowledgeCommonEntityList.fromJson(_removeNullValues(mapped));
  }

  static Map<String, dynamic>? _wrapContentTypeTitle(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    final String text = raw?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    return <String, dynamic>{
      'gloss': <Map<String, dynamic>>[
        <String, dynamic>{'lang': 'en', 'text': text},
      ],
    };
  }

  static List<Map<String, dynamic>>? _toLanguageTextJsonList(dynamic raw) {
    if (raw is! List) return null;
    final List<Map<String, dynamic>> list = <Map<String, dynamic>>[];
    for (final dynamic item in raw) {
      if (item is Map<String, dynamic>) {
        list.add(<String, dynamic>{
          'lang': item['lang']?.toString(),
          'text': item['text']?.toString(),
        });
      } else if (item is ManageSubscribeNameItem) {
        list.add(item.toJson());
      } else if (item is LanguageText) {
        list.add(item.toJson());
      }
    }
    return list.isEmpty ? null : list;
  }

  static List<Map<String, dynamic>>? _toTagJsonList(dynamic raw) {
    if (raw is! List) return null;
    final List<Map<String, dynamic>> list = <Map<String, dynamic>>[];
    for (final dynamic item in raw) {
      if (item is Map<String, dynamic>) {
        list.add(item);
      } else if (item is UserRevealTagEntity) {
        list.add(item.toJson());
      }
    }
    return list.isEmpty ? null : list;
  }

  static Map<String, dynamic>? _wrapCoverImage(Map<String, dynamic> json) {
    if (json['coverImage'] is Map<String, dynamic>) {
      return json['coverImage'] as Map<String, dynamic>;
    }
    final String url = json['imageUrl']?.toString().trim() ?? '';
    if (url.isEmpty) return null;
    return <String, dynamic>{
      'type': 'image',
      'mediaId': _toInt(json['imageId']),
      'url': url,
      'key': json['imageKey']?.toString(),
      'md5': null,
    };
  }

  static Map<String, dynamic>? _wrapCoverVideo(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    return <String, dynamic>{
      'type': 'video',
      'mediaId': _toInt(raw['videoId']),
      'url': raw['videoUrl']?.toString(),
      'key': raw['videoKey']?.toString(),
      'md5': raw['md5']?.toString(),
      'duration': raw['duration'],
      'firstFrameUrl': raw['firstFrameUrl']?.toString(),
      'firstFrameKey': raw['firstFrameKey']?.toString(),
      'firstFrameMd5': raw['firstFrameMd5']?.toString(),
      'startSeconds': raw['startSeconds'],
      'endSeconds': raw['endSeconds'],
    };
  }

  static Map<String, dynamic>? _wrapRights(Map<String, dynamic> json) {
    if (json['rights'] is Map<String, dynamic>) {
      return json['rights'] as Map<String, dynamic>;
    }
    if (json['cardRights'] is Map<String, dynamic>) {
      return json['cardRights'] as Map<String, dynamic>;
    }
    final String access = json['access']?.toString() ?? '';
    final String rights = json['rights']?.toString() ?? access;
    if (access.isEmpty && rights.isEmpty) return null;
    return <String, dynamic>{
      'access': access,
      'rights': rights,
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static int? _firstInt(dynamic raw) {
    if (raw is! List) return null;
    for (final dynamic item in raw) {
      final int? value = _toInt(item);
      if (value != null) return value;
    }
    return null;
  }

  static Map<String, dynamic> _removeNullValues(Map<String, dynamic> input) {
    final Map<String, dynamic> result = <String, dynamic>{};
    input.forEach((key, value) {
      if (value == null) return;
      if (value is Map<String, dynamic>) {
        final Map<String, dynamic> nested = _removeNullValues(value);
        if (nested.isEmpty) return;
        result[key] = nested;
        return;
      }
      result[key] = value;
    });
    return result;
  }
}
