import 'package:langwise/common/entities/lock_entity.dart';
import 'package:langwise/common/entities/theme_style_entity.dart';

import 'manage_subscribe_entity.dart';

class UserRevealCollectionEntity {
  int? collectionId;
  int? contentUid;
  String? title;
  int? count;
  String? avatarUrl;
  String? avatar;
  String? taskAvatarUrl;
  String? taskAvatar;
  List<ManageSubscribeNameItem>? depiction;
  String? description;
  bool? isSubscribe;
  bool? isNewContent;
  ManageSubscribeNameGroup? genreName;
  List<ThemeTextStyleEntity>? txtStyle;
  ManageSubscribeNameGroup? themeName;
  String? themeZhName;

  UserRevealCollectionEntity({
    this.collectionId,
    this.contentUid,
    this.title,
    this.count,
    this.avatarUrl,
    this.avatar,
    this.taskAvatarUrl,
    this.taskAvatar,
    this.description,
    this.isSubscribe,
    this.isNewContent,
    this.genreName,
    this.txtStyle,
    this.themeName,
    this.themeZhName,
  });

  UserRevealCollectionEntity.fromJson(Map<String, dynamic> json) {
    collectionId = json['collectionId']?.toInt();
    contentUid = json['contentUid']?.toInt();
    title = json['title']?.toString();
    count = json['count']?.toInt();
    avatarUrl = json['avatarUrl']?.toString();
    avatar = json['avatar']?.toString();
    taskAvatarUrl = json['taskAvatarUrl']?.toString();
    taskAvatar = json['taskAvatar']?.toString();
    description = json['description']?.toString();

    if (json['depiction'] != null) {
      final arr = json['depiction'] as List;
      depiction = arr.whereType<Map<String, dynamic>>().map((e) => ManageSubscribeNameItem.fromJson(e)).toList();
    }
    isSubscribe = json['isSubscribe'] as bool?;
    isNewContent = json['isNewContent'] as bool?;

    if (json['genreName'] != null) {
      final genreJson = json['genreName'] as Map<String, dynamic>;
      genreName = ManageSubscribeNameGroup.fromJson(genreJson);

      // 从 genreName.style 里解析主题样式列表（当前后端返回的是一个数组）
      final styleList = genreJson['style'];
      if (styleList is List) {
        final arr0 = <ThemeTextStyleEntity>[];
        for (final v in styleList) {
          arr0.add(ThemeTextStyleEntity.fromJson(v as Map<String, dynamic>));
        }
        txtStyle = arr0;
      }
    }

    // 兼容旧的根级 style 字段（如果存在的话）
    if (txtStyle == null && json['style'] is List) {
      final v = json['style'] as List;
      final arr0 = <ThemeTextStyleEntity>[];
      for (final e in v) {
        arr0.add(ThemeTextStyleEntity.fromJson(e as Map<String, dynamic>));
      }
      txtStyle = arr0;
    }

    if (json['themeName'] != null) {
      themeName = ManageSubscribeNameGroup.fromJson(
        json['themeName'] as Map<String, dynamic>,
      );
    }

    themeZhName = json['themeZhName']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['collectionId'] = collectionId;
    data['contentUid'] = contentUid;
    data['title'] = title;
    data['count'] = count;
    data['avatarUrl'] = avatarUrl;
    data['avatar'] = avatar;
    data['taskAvatarUrl'] = taskAvatarUrl;
    data['taskAvatar'] = taskAvatar;
    data['description'] = description;
    data['isNewContent'] = isNewContent;
    data['isSubscribe'] = isSubscribe;

    if (genreName != null) {
      data['genreName'] = genreName!.toJson();
    }

    if (themeName != null) {
      data['themeName'] = themeName!.toJson();
    }

    data['themeZhName'] = themeZhName;
    return data;
  }
}

class UserRevealsPageEntity {
  int? count;
  List<UserRevealCollectionEntity>? datas;
  LockEntity? rights;
  String? warnMessage;
  bool? warnDialog;

  UserRevealsPageEntity({
    this.count,
    this.datas,
    this.rights,
    this.warnMessage,
    this.warnDialog,
  });

  UserRevealsPageEntity.fromJson(Map<String, dynamic> json) {
    // 兼容两种结构：
    // 1. 直接传入 {count, datas}
    // 2. 传入完整返回 {code, data: {count, datas}}
    final Map<String, dynamic> inner = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    count = inner['count']?.toInt();

    if (inner['datas'] != null) {
      final list = inner['datas'] as List;
      final arr = <UserRevealCollectionEntity>[];
      for (final e in list) {
        arr.add(UserRevealCollectionEntity.fromJson(e as Map<String, dynamic>));
      }
      datas = arr;
    }

    rights = LockEntity.fromJson(json['rights']);

    warnMessage = json['warnMessage'] ?? "";
    warnDialog = json['warnDialog'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['count'] = count;
    if (datas != null) {
      data['datas'] = datas!.map((e) => e.toJson()).toList();
    }
    data['warnMessage'] = warnMessage;
    data['warnDialog'] = warnDialog;
    return data;
  }
}
