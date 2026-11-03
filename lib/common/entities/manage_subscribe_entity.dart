import 'article_entity.dart';
import 'theme_style_entity.dart';

/// 订阅集合名称多语言项
class ManageSubscribeNameItem {
  String? lang;
  String? text;

  ManageSubscribeNameItem({
    this.lang,
    this.text,
  });

  ManageSubscribeNameItem.fromJson(Map<String, dynamic> json) {
    lang = json['lang']?.toString();
    text = json['text']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['lang'] = lang;
    data['text'] = text;
    return data;
  }
}

/// 订阅集合参考来源
class ManageSubscribeReference {
  String? name;
  String? type;
  String? url;

  ManageSubscribeReference({
    this.name,
    this.type,
    this.url,
  });

  ManageSubscribeReference.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    type = json['type']?.toString();
    url = json['url']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['url'] = url;
    return data;
  }
}

/// genreName / themeName 外层对象
class ManageSubscribeNameGroup {
  List<ManageSubscribeNameItem>? gloss;
  String? style;

  ManageSubscribeNameGroup({
    this.gloss,
    this.style,
  });

  ManageSubscribeNameGroup.fromJson(Map<String, dynamic> json) {
    if (json['gloss'] != null) {
      final v = json['gloss'];
      final arr = <ManageSubscribeNameItem>[];
      v.forEach((e) {
        arr.add(ManageSubscribeNameItem.fromJson(e));
      });
      gloss = arr;
    }
    style = json['style']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (gloss != null) {
      data['gloss'] = gloss!.map((e) => e.toJson()).toList();
    }
    data['style'] = style;
    return data;
  }
}

/// 订阅集合实体（对齐 /reveals/list 接口）
class ManageSubscribeEntity {
  int? collectionId;
  String? title;
  String? description;
  String? avatarUrl;
  String? avatar;
  String? taskAvatar;
  String? taskAvatarUrl;
  ManageSubscribeNameGroup? genreName;
  ManageSubscribeNameGroup? themeName;
  List<ManageSubscribeReference>? references;
  int? size;
  int? accessSize;
  int? startNum;
  int? finishNum;
  int? audioStartNum;
  int? audioFinishNum;

  ManageSubscribeEntity({
    this.collectionId,
    this.title,
    this.description,
    this.avatarUrl,
    this.avatar,
    this.taskAvatar,
    this.taskAvatarUrl,
    this.genreName,
    this.themeName,
    this.references,
    this.size,
    this.accessSize,
    this.startNum,
    this.finishNum,
    this.audioStartNum,
    this.audioFinishNum,
  });

  ManageSubscribeEntity.fromJson(Map<String, dynamic> json) {
    collectionId = json['collectionId']?.toInt();
    title = json['title']?.toString();
    description = json['description']?.toString();
    avatarUrl = json['avatarUrl']?.toString();
    avatar = json['avatar']?.toString();
    taskAvatar = json['taskAvatar']?.toString();
    taskAvatarUrl = json['taskAvatarUrl']?.toString();

    if (json['genreName'] != null) {
      genreName = ManageSubscribeNameGroup.fromJson(
        json['genreName'] as Map<String, dynamic>,
      );
    }

    if (json['themeName'] != null) {
      themeName = ManageSubscribeNameGroup.fromJson(
        json['themeName'] as Map<String, dynamic>,
      );
    }

    if (json['references'] != null) {
      final v = json['references'];
      final arr = <ManageSubscribeReference>[];
      v.forEach((e) {
        arr.add(ManageSubscribeReference.fromJson(e));
      });
      references = arr;
    }

    size = json['size']?.toInt();
    accessSize = json['accessSize']?.toInt();
    startNum = json['startNum']?.toInt();
    finishNum = json['finishNum']?.toInt();
    audioStartNum = json['audioStartNum']?.toInt();
    audioFinishNum = json['audioFinishNum']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['collectionId'] = collectionId;
    data['title'] = title;
    data['description'] = description;
    data['avatarUrl'] = avatarUrl;
    data['avatar'] = avatar;
    data['taskAvatar'] = taskAvatar;
    data['taskAvatarUrl'] = taskAvatarUrl;

    if (genreName != null) {
      data['genreName'] = genreName!.toJson();
    }
    if (themeName != null) {
      data['themeName'] = themeName!.toJson();
    }

    if (references != null) {
      data['references'] = references!.map((e) => e.toJson()).toList();
    }

    data['size'] = size;
    data['accessSize'] = accessSize;
    data['startNum'] = startNum;
    data['finishNum'] = finishNum;
    data['audioStartNum'] = audioStartNum;
    data['audioFinishNum'] = audioFinishNum;
    return data;
  }
}

/// 甄听专栏下方搜索栏项
class ManageSubscribeGenreEntity {
  String? id;
  int? v;
  List<ManageSubscribeNameItem>? name;
  List<ManageSubscribeNameItem>? description;
  String? descriptionForPrompt;
  String? created;
  String? updated;

  ManageSubscribeGenreEntity({
    this.id,
    this.v,
    this.name,
    this.description,
    this.descriptionForPrompt,
    this.created,
    this.updated,
  });

  ManageSubscribeGenreEntity.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    v = json['v']?.toInt();

    if (json['name'] != null) {
      final v = json['name'];
      final arr0 = <ManageSubscribeNameItem>[];
      v.forEach((v) {
        arr0.add(ManageSubscribeNameItem.fromJson(v));
      });
      name = arr0;
    }

    if (json['description'] != null) {
      final v = json['description'];
      final arr0 = <ManageSubscribeNameItem>[];
      v.forEach((v) {
        arr0.add(ManageSubscribeNameItem.fromJson(v));
      });
      description = arr0;
    }

    descriptionForPrompt = json['description_for_prompt']?.toString();
    created = json['created']?.toString();
    updated = json['updated']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['v'] = v;

    if (name != null) {
      data['name'] = name!.map((e) => e.toJson()).toList();
    }

    if (description != null) {
      data['description'] = description!.map((e) => e.toJson()).toList();
    }

    data['description_for_prompt'] = descriptionForPrompt;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}

/// 专栏详情中的 contentCollection
class ManageSubscribeContentCollectionEntity {
  String? id;
  int? v;
  int? uid;
  String? title;
  String? description;
  String? skillType;
  String? pushType;
  String? theme;
  String? genre;
  String? brand;
  List<dynamic>? rightsIds;
  int? price;
  String? vipType;
  List<ThemeTextStyleEntity>? themeStyle;
  List<ThemeTextStyleEntity>? genreStyle;
  int? order;
  String? avatar;
  String? taskAvatar;
  String? updated;
  String? created;

  ManageSubscribeContentCollectionEntity({
    this.id,
    this.v,
    this.uid,
    this.title,
    this.description,
    this.skillType,
    this.pushType,
    this.theme,
    this.genre,
    this.brand,
    this.rightsIds,
    this.price,
    this.vipType,
    this.themeStyle,
    this.genreStyle,
    this.order,
    this.avatar,
    this.taskAvatar,
    this.updated,
    this.created,
  });

  ManageSubscribeContentCollectionEntity.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    v = json['v']?.toInt();
    uid = json['uid']?.toInt();
    title = json['title']?.toString();
    description = json['description']?.toString();
    skillType = json['skillType']?.toString();
    pushType = json['pushType']?.toString();
    theme = json['theme']?.toString();
    genre = json['genre']?.toString();
    brand = json['brand']?.toString();
    rightsIds = json['rightsIds'] as List<dynamic>?;
    price = json['price']?.toInt();
    vipType = json['vipType']?.toString();

    if (json['themeStyle'] != null) {
      final List<dynamic> v = json['themeStyle'] as List<dynamic>;
      final List<ThemeTextStyleEntity> arr = <ThemeTextStyleEntity>[];
      for (final dynamic e in v) {
        if (e is Map<String, dynamic>) {
          arr.add(ThemeTextStyleEntity.fromJson(e));
        }
      }
      themeStyle = arr;
    }

    if (json['genreStyle'] != null) {
      final List<dynamic> v = json['genreStyle'] as List<dynamic>;
      final List<ThemeTextStyleEntity> arr = <ThemeTextStyleEntity>[];
      for (final dynamic e in v) {
        if (e is Map<String, dynamic>) {
          arr.add(ThemeTextStyleEntity.fromJson(e));
        }
      }
      genreStyle = arr;
    }
    order = json['order']?.toInt();
    avatar = json['avatar']?.toString();
    taskAvatar = json['taskAvatar']?.toString();
    updated = json['updated']?.toString();
    created = json['created']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['v'] = v;
    data['uid'] = uid;
    data['title'] = title;
    data['description'] = description;
    data['skillType'] = skillType;
    data['pushType'] = pushType;
    data['theme'] = theme;
    data['genre'] = genre;
    data['brand'] = brand;
    data['rightsIds'] = rightsIds;
    data['price'] = price;
    data['vipType'] = vipType;

    if (themeStyle != null) {
      data['themeStyle'] = themeStyle!.map((e) => e.toJson()).toList();
    }
    if (genreStyle != null) {
      data['genreStyle'] = genreStyle!.map((e) => e.toJson()).toList();
    }
    data['order'] = order;
    data['avatar'] = avatar;
    data['taskAvatar'] = taskAvatar;
    data['updated'] = updated;
    data['created'] = created;
    return data;
  }
}

/// 分组下轻量级内容信息（来自 JSON 中的 `contents` 数组）
class ManageSubscribeGroupContentMeta {
  String? id;
  int? v;
  int? collectionId;
  String? contentType;
  int? contentId;
  String? group;
  int? order;
  String? calendarType;
  String? publishedDate;
  bool? published;
  Map<String, dynamic>? difficulty;
  String? access;
  String? updated;
  String? created;

  ManageSubscribeGroupContentMeta({
    this.id,
    this.v,
    this.collectionId,
    this.contentType,
    this.contentId,
    this.group,
    this.order,
    this.calendarType,
    this.publishedDate,
    this.published,
    this.difficulty,
    this.access,
    this.updated,
    this.created,
  });

  ManageSubscribeGroupContentMeta.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    v = json['v']?.toInt();
    collectionId = json['collectionId']?.toInt();
    contentType = json['contentType']?.toString();
    contentId = json['contentId']?.toInt();
    group = json['group']?.toString();
    order = json['order']?.toInt();
    calendarType = json['calendarType']?.toString();
    publishedDate = json['publishedDate']?.toString();
    published = json['published'] as bool?;
    difficulty = json['difficulty'] as Map<String, dynamic>?;
    access = json['access']?.toString();
    updated = json['updated']?.toString();
    created = json['created']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['v'] = v;
    data['collectionId'] = collectionId;
    data['contentType'] = contentType;
    data['contentId'] = contentId;
    data['group'] = group;
    data['order'] = order;
    data['calendarType'] = calendarType;
    data['publishedDate'] = publishedDate;
    data['published'] = published;
    data['difficulty'] = difficulty;
    data['access'] = access;
    data['updated'] = updated;
    data['created'] = created;
    return data;
  }
}

/// 新接口中 enGroupRevealContents.datas 里的单个分组
class ManageSubscribeGroupRevealItem {
  String? group;
  /// 详细内容信息，对应 JSON 中的 `contentDTOS`，解析为 ArticleEntity
  List<ArticleEntity>? contentDTOS;

  /// 资源类型 0=图片 1=视频
  int? assetType;

  ManageSubscribeGroupRevealItem({
    this.group,
    this.contentDTOS,
    this.assetType = 0,
  });

  ManageSubscribeGroupRevealItem.fromJson(Map<String, dynamic> json) {
    group = json['group']?.toString();

    if (json['contentDTOS'] != null) {
      final List<dynamic> v = json['contentDTOS'] as List<dynamic>;
      final List<ArticleEntity> arr = <ArticleEntity>[];
      for (final dynamic e in v) {
        if (e is Map<String, dynamic>) {
          arr.add(ArticleEntity.fromJson(e));
        }
      }
      contentDTOS = arr;
    }

    assetType = 0;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group'] = group;
    if (contentDTOS != null) {
      data['contentDTOS'] = contentDTOS!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

/// 新接口中的 enGroupRevealContents
class ManageSubscribeGroupRevealContents {
  int? offset;
  int? limit;
  int? count;
  List<ManageSubscribeGroupRevealItem>? datas;

  ManageSubscribeGroupRevealContents({
    this.offset,
    this.limit,
    this.count,
    this.datas,
  });

  ManageSubscribeGroupRevealContents.fromJson(Map<String, dynamic> json) {
    offset = json['offset']?.toInt();
    limit = json['limit']?.toInt();
    count = json['count']?.toInt();

    if (json['datas'] != null) {
      final List<dynamic> v = json['datas'] as List<dynamic>;
      final List<ManageSubscribeGroupRevealItem> arr = <ManageSubscribeGroupRevealItem>[];
      for (final dynamic e in v) {
        if (e is Map<String, dynamic>) {
          arr.add(ManageSubscribeGroupRevealItem.fromJson(e));
        }
      }
      datas = arr;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['offset'] = offset;
    data['limit'] = limit;
    data['count'] = count;
    if (datas != null) {
      data['datas'] = datas!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

/// 甄听专栏详情实体（对齐 /language-console/en/reveals/page/group/enReveals 返回）
class ManageSubscribeRevealDetailEntity {
  ManageSubscribeContentCollectionEntity? contentCollection;
  int? finishContentNum;
  int? finishAudioNum;
  List<ManageSubscribeNameItem>? revealGenreName;
  List<ManageSubscribeNameItem>? revealThemeName;

  /// 新结构：按 group 分好组的数据
  ManageSubscribeGroupRevealContents? enGroupRevealContents;

  ManageSubscribeRevealDetailEntity({
    this.contentCollection,
    this.finishContentNum,
    this.finishAudioNum,
    this.revealGenreName,
    this.revealThemeName,
    this.enGroupRevealContents,
  });

  ManageSubscribeRevealDetailEntity.fromJson(Map<String, dynamic> json) {
    if (json['contentCollection'] != null) {
      contentCollection = ManageSubscribeContentCollectionEntity.fromJson(
        json['contentCollection'] as Map<String, dynamic>,
      );
    }

    finishContentNum = json['finishContentNum']?.toInt();
    finishAudioNum = json['finishAudioNum']?.toInt();

    if (json['revealGenreName'] != null) {
      final List<dynamic> v = json['revealGenreName'] as List<dynamic>;
      final List<ManageSubscribeNameItem> arr = <ManageSubscribeNameItem>[];
      for (final dynamic e in v) {
        if (e is Map<String, dynamic>) {
          arr.add(ManageSubscribeNameItem.fromJson(e));
        }
      }
      revealGenreName = arr;
    }

    if (json['revealThemeName'] != null) {
      final List<dynamic> v = json['revealThemeName'] as List<dynamic>;
      final List<ManageSubscribeNameItem> arr = <ManageSubscribeNameItem>[];
      for (final dynamic e in v) {
        if (e is Map<String, dynamic>) {
          arr.add(ManageSubscribeNameItem.fromJson(e));
        }
      }
      revealThemeName = arr;
    }

    // 新字段：enGroupRevealContents
    if (json['enGroupRevealContents'] != null && json['enGroupRevealContents'] is Map<String, dynamic>) {
      enGroupRevealContents = ManageSubscribeGroupRevealContents.fromJson(
        json['enGroupRevealContents'] as Map<String, dynamic>,
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (contentCollection != null) {
      data['contentCollection'] = contentCollection!.toJson();
    }
    data['finishContentNum'] = finishContentNum;
    data['finishAudioNum'] = finishAudioNum;

    if (revealGenreName != null) {
      data['revealGenreName'] = revealGenreName!.map((e) => e.toJson()).toList();
    }
    if (revealThemeName != null) {
      data['revealThemeName'] = revealThemeName!.map((e) => e.toJson()).toList();
    }

    if (enGroupRevealContents != null) {
      data['enGroupRevealContents'] = enGroupRevealContents!.toJson();
    }

    return data;
  }
}
