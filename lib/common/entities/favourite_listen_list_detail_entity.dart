import 'package:langwise/common/entities/lock_entity.dart';
import 'package:langwise/common/entities/song_theme_entity.dart';
import 'package:langwise/common/entities/theme_style_entity.dart';

class FavouriteListenListDetailEntity {
  int? offset;
  int? limit;
  int? count;
  List<FavouriteListenListDetailItemEntity>? datas;
  int? favoriteId;
  List<FavouriteListenListTypeEntity>? types;
  int? maxContentCount;

  FavouriteListenListDetailEntity({
    this.offset,
    this.limit,
    this.count,
    this.datas,
    this.favoriteId,
    this.types,
    this.maxContentCount,
  });

  FavouriteListenListDetailEntity.fromJson(Map<String, dynamic> json) {
    offset = json['offset']?.toInt();
    limit = json['limit']?.toInt();
    count = json['count']?.toInt();
    favoriteId = json['favoriteId']?.toInt();
    maxContentCount = json['maxContentCount']?.toInt();

    if (json['datas'] != null) {
      final v = json['datas'];
      final arr0 = <FavouriteListenListDetailItemEntity>[];
      v.forEach((v) {
        arr0.add(FavouriteListenListDetailItemEntity.fromJson(v));
      });
      datas = arr0;
    }

    if (json['types'] != null) {
      final v = json['types'];
      final arr0 = <FavouriteListenListTypeEntity>[];
      v.forEach((v) {
        arr0.add(FavouriteListenListTypeEntity.fromJson(v));
      });
      types = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['offset'] = offset;
    data['limit'] = limit;
    data['count'] = count;
    if (datas != null) {
      final v = datas;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v.toJson());
      });
      data['datas'] = arr0;
    }
    data['favoriteId'] = favoriteId;
    if (types != null) {
      final v = types;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v.toJson());
      });
      data['types'] = arr0;
    }
    data['maxContentCount'] = maxContentCount;
    return data;
  }
}

class FavouriteListenListDetailItemEntity {
  String? contentType;
  String? contentTypeTitle;
  int? contentId;
  String? title;
  String? content;
  List<FavouriteListenTagEntity>? tags;
  String? imageUrl;
  bool? isFavourited;
  LockEntity? cardRights;
  String? dialect;
  int? styleId;

  FavouriteListenListDetailItemEntity({
    this.contentType,
    this.contentTypeTitle,
    this.contentId,
    this.title,
    this.content,
    this.tags,
    this.imageUrl,
    this.isFavourited,
    this.cardRights,
    this.dialect,
    this.styleId,
  });

  FavouriteListenListDetailItemEntity.fromJson(Map<String, dynamic> json) {
    contentType = json['contentType']?.toString();
    contentTypeTitle = json['contentTypeTitle']?.toString();
    contentId = json['contentId']?.toInt();
    title = json['title']?.toString();
    content = json['content']?.toString();
    imageUrl = json['imageUrl']?.toString();
    isFavourited = json['favorited']??false;

    if (json['tags'] != null) {
      final v = json['tags'];
      final arr0 = <FavouriteListenTagEntity>[];
      v.forEach((v) {
        arr0.add(FavouriteListenTagEntity.fromJson(v));
      });
      tags = arr0;
    }
    if (json['cardRights'] != null) {
      cardRights = LockEntity.fromJson(json['cardRights'] as Map<String, dynamic>);
    }
    dialect = json['dialect']?.toString();
    styleId = json['styleId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['contentType'] = contentType;
    data['contentTypeTitle'] = contentTypeTitle;
    data['contentId'] = contentId;
    data['title'] = title;
    data['content'] = content;
    data['favorited'] = isFavourited;
    if (tags != null) {
      final v = tags;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v.toJson());
      });
      data['tags'] = arr0;
    }
    data['imageUrl'] = imageUrl;
    data['cardRights'] = cardRights?.toJson();
    data['dialect'] = dialect;
    data['styleId'] = styleId;
    return data;
  }
}

class FavouriteListenTagEntity {
  List<LangTextEntity>? gloss;
  List<ThemeTextStyleEntity?>? style;

  FavouriteListenTagEntity({this.gloss, this.style});

  FavouriteListenTagEntity.fromJson(Map<String, dynamic> json) {
    if (json['gloss'] != null) {
      final v = json['gloss'];
      final arr0 = <LangTextEntity>[];
      v.forEach((v) {
        arr0.add(LangTextEntity.fromJson(v));
      });
      gloss = arr0;
    }
    if (json['style'] != null) {
      final v = json['style'];
      final arr0 = <ThemeTextStyleEntity>[];
      v.forEach((v) {
        arr0.add(ThemeTextStyleEntity.fromJson(v));
      });
      style = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (gloss != null) {
      final v = gloss;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v.toJson());
      });
      data['gloss'] = arr0;
    }
    if (style != null) {
      final v = style;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['style'] = arr0;
    }
    return data;
  }
}

class FavouriteListenListTypeEntity {
  String? type;
  List<LangTextEntity>? titles;

  FavouriteListenListTypeEntity({this.type, this.titles});

  FavouriteListenListTypeEntity.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    if (json['titles'] != null) {
      final v = json['titles'];
      final arr0 = <LangTextEntity>[];
      v.forEach((v) {
        arr0.add(LangTextEntity.fromJson(v));
      });
      titles = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    if (titles != null) {
      final v = titles;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v.toJson());
      });
      data['titles'] = arr0;
    }
    return data;
  }
}
