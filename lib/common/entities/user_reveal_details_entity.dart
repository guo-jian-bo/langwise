import 'package:langwise/common/entities/lock_entity.dart';

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
