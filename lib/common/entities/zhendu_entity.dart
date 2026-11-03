import 'lock_entity.dart';
import 'theme_style_entity.dart';
import 'card_public_entity.dart';
import 'knowledge_common_entity.dart';

class ZhenduCategoryListEntity {
  final String? type;
  final String? description;
  final List<ZhenduTheaterEntity> items;
  final String? footer;

  ZhenduCategoryListEntity({
    this.type,
    this.description,
    required this.items,
    this.footer,
  });

  factory ZhenduCategoryListEntity.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>?;
    return ZhenduCategoryListEntity(
      type: json['type'] as String?,
      description: json['description'] as String?,
      items: itemsJson == null
          ? <ZhenduTheaterEntity>[]
          : itemsJson
              .map((e) =>
                  ZhenduTheaterEntity.fromJson(e as Map<String, dynamic>))
              .toList(),
      footer: json['footer'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'description': description,
        'items': items.map((e) => e.toJson()).toList(),
        'footer': footer,
      };
}

class ZhenduTheaterEntity {
  final String? category;
  final String? label;
  final String? iconUrl;
  final String? categoryTitle;
  final List<LanguageText>? title;
  final String? backgroundImage;
  final List<LanguageText>? description;
  final List<LanguageText>? tip;
  final int? status;
  final String? statusTip;
  final String? scriptCount;
  final List<LanguageText>? scriptCountTitle;
  final dynamic jump;
  final LockEntity? rights;

  ZhenduTheaterEntity({
    this.category,
    this.label,
    this.iconUrl,
    this.categoryTitle,
    this.title,
    this.backgroundImage,
    this.description,
    this.tip,
    this.status,
    this.statusTip,
    this.scriptCount,
    this.scriptCountTitle,
    this.jump,
    this.rights,
  });

  factory ZhenduTheaterEntity.fromJson(Map<String, dynamic> json) {
    List<LanguageText>? title;
    final titleJson = json['title'] as List<dynamic>?;
    if (titleJson != null) {
      title = titleJson
          .map((e) => LanguageText.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<LanguageText>? description;
    final descJson = json['description'] as List<dynamic>?;
    if (descJson != null) {
      description = descJson
          .map((e) => LanguageText.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<LanguageText>? tip;
    final tipJson = json['tip'] as List<dynamic>?;
    if (tipJson != null) {
      tip = tipJson
          .map((e) => LanguageText.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<LanguageText>? scriptCountTitle;
    final scriptCountTitleJson = json['scriptCountTitle'] as List<dynamic>?;
    if (scriptCountTitleJson != null) {
      scriptCountTitle = scriptCountTitleJson
          .map((e) => LanguageText.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ZhenduTheaterEntity(
      category: json['category'] as String?,
      label: json['label'] as String?,
      iconUrl: json['iconUrl'] as String?,
      categoryTitle: json['categoryTitle'] as String?,
      title: title,
      backgroundImage: json['backgroundImage'] as String?,
      description: description,
      tip: tip,
      status: (json['status'] as num?)?.toInt(),
      statusTip: json['statusTip'] as String?,
      scriptCount: json['scriptCount']?.toString(),
      scriptCountTitle: scriptCountTitle,
      jump: json['jump'],
      rights: json['rights'] == null
          ? null
          : LockEntity.fromJson(json['rights'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'category': category,
        'label': label,
        'iconUrl': iconUrl,
        'categoryTitle': categoryTitle,
        'title': title?.map((e) => e.toJson()).toList(),
        'backgroundImage': backgroundImage,
        'description': description?.map((e) => e.toJson()).toList(),
        'tip': tip?.map((e) => e.toJson()).toList(),
        'status': status,
        'statusTip': statusTip,
        'scriptCount': scriptCount,
        'scriptCountTitle': scriptCountTitle?.map((e) => e.toJson()).toList(),
        'jump': jump,
        'rights': rights?.toJson(),
      };
}

class ZhenduCategoryContentPagesEntity {
  final int? offset;
  final int? limit;
  final int? count;
  final List<ZhenduScriptEntity> items;
  final ZhenduCategoryInfoEntity? categoryInfo;
  final LockEntity? rights;

  ZhenduCategoryContentPagesEntity({
    this.offset,
    this.limit,
    this.count,
    required this.items,
    this.categoryInfo,
    this.rights,
  });

  factory ZhenduCategoryContentPagesEntity.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>?;
    return ZhenduCategoryContentPagesEntity(
      offset: (json['offset'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      count: (json['count'] as num?)?.toInt(),
      items: itemsJson == null
          ? <ZhenduScriptEntity>[]
          : itemsJson
              .map(
                  (e) => ZhenduScriptEntity.fromJson(e as Map<String, dynamic>))
              .toList(),
      categoryInfo: json['categoryInfo'] == null
          ? null
          : ZhenduCategoryInfoEntity.fromJson(
              json['categoryInfo'] as Map<String, dynamic>),
      rights: json['rights'] == null
          ? null
          : LockEntity.fromJson(json['rights'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'offset': offset,
        'limit': limit,
        'count': count,
        'items': items.map((e) => e.toJson()).toList(),
        'categoryInfo': categoryInfo?.toJson(),
        'rights': rights?.toJson(),
      };
}

class ZhenduCategoryContentV2PagesEntity {
  final int? offset;
  final int? limit;
  final int? count;
  final List<KnowledgeCommonEntityList> list;
  final ZhenduCategoryInfoEntity? categoryInfo;
  final LockEntity? rights;

  ZhenduCategoryContentV2PagesEntity({
    this.offset,
    this.limit,
    this.count,
    required this.list,
    this.categoryInfo,
    this.rights,
  });

  factory ZhenduCategoryContentV2PagesEntity.fromJson(Map<String, dynamic> json) {
    final listJson = json['list'] as List<dynamic>?;
    return ZhenduCategoryContentV2PagesEntity(
      offset: (json['offset'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      count: (json['count'] as num?)?.toInt(),
      list: listJson == null
          ? <KnowledgeCommonEntityList>[]
          : listJson
              .map((e) => KnowledgeCommonEntityList.fromJson(e as Map<String, dynamic>))
              .toList(),
      categoryInfo: json['categoryInfo'] == null
          ? null
          : ZhenduCategoryInfoEntity.fromJson(
              json['categoryInfo'] as Map<String, dynamic>),
      rights: json['rights'] == null
          ? null
          : LockEntity.fromJson(json['rights'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'offset': offset,
        'limit': limit,
        'count': count,
        'list': list.map((e) => e.toJson()).toList(),
        'categoryInfo': categoryInfo?.toJson(),
        'rights': rights?.toJson(),
      };
}

class ZhenduScriptQueryMetaGroupListEntity {
  final List<ZhenduScriptQueryMetaGroupEntity> filters;
  final List<ZhenduScriptQueryMetaGroupEntity> orders;
  final List<ZhenduScriptQuerySearchHintEntity> searchHints;

  ZhenduScriptQueryMetaGroupListEntity({
    required this.filters,
    required this.orders,
    required this.searchHints,
  });

  factory ZhenduScriptQueryMetaGroupListEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    final filtersJson = json['filters'] as List<dynamic>?;
    final ordersJson = json['orders'] as List<dynamic>?;
    final searchHintsJson = json['searchHints'] as List<dynamic>?;
    return ZhenduScriptQueryMetaGroupListEntity(
      filters: filtersJson == null
          ? <ZhenduScriptQueryMetaGroupEntity>[]
          : filtersJson
              .map((e) => ZhenduScriptQueryMetaGroupEntity.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList(),
      orders: ordersJson == null
          ? <ZhenduScriptQueryMetaGroupEntity>[]
          : ordersJson
              .map((e) => ZhenduScriptQueryMetaGroupEntity.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList(),
      searchHints: searchHintsJson == null
          ? <ZhenduScriptQuerySearchHintEntity>[]
          : searchHintsJson
              .map((e) => ZhenduScriptQuerySearchHintEntity.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'filters': filters.map((e) => e.toJson()).toList(),
        'orders': orders.map((e) => e.toJson()).toList(),
        'searchHints': searchHints.map((e) => e.toJson()).toList(),
      };
}

class ZhenduScriptQuerySearchHintEntity {
  final String? text;
  final int? weight;

  ZhenduScriptQuerySearchHintEntity({
    this.text,
    this.weight,
  });

  factory ZhenduScriptQuerySearchHintEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return ZhenduScriptQuerySearchHintEntity(
      text: json['text']?.toString(),
      weight: json['weight'] is int
          ? json['weight'] as int
          : int.tryParse(json['weight']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'text': text,
        'weight': weight,
      };
}

class ZhenduScriptQueryMetaGroupEntity {
  final String? groupCode;
  final String? groupName;
  final String? component;
  final String? filterGroup;
  final bool? radioGroup;
  final List<ZhenduScriptQueryMetaItemEntity> items;

  ZhenduScriptQueryMetaGroupEntity({
    this.groupCode,
    this.groupName,
    this.component,
    this.filterGroup,
    this.radioGroup,
    required this.items,
  });

  factory ZhenduScriptQueryMetaGroupEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    final itemsJson = json['items'] as List<dynamic>?;
    return ZhenduScriptQueryMetaGroupEntity(
      groupCode: json['groupCode'] as String?,
      groupName: json['groupName'] as String?,
      component: json['component']?.toString(),
      filterGroup: json['filterGroup']?.toString(),
      radioGroup: json['radioGroup'] as bool?,
      items: itemsJson == null
          ? <ZhenduScriptQueryMetaItemEntity>[]
          : itemsJson
              .map((e) => ZhenduScriptQueryMetaItemEntity.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'groupCode': groupCode,
        'groupName': groupName,
        'component': component,
        'filterGroup': filterGroup,
        'radioGroup': radioGroup,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class ZhenduScriptQueryMetaItemEntity {
  final String? value;
  final String? name;
  final bool? defaultValue;

  ZhenduScriptQueryMetaItemEntity({
    this.value,
    this.name,
    this.defaultValue,
  });

  factory ZhenduScriptQueryMetaItemEntity.fromJson(
    Map<String, dynamic> json,
  ) =>
      ZhenduScriptQueryMetaItemEntity(
        value: json['value']?.toString(),
        name: json['name']?.toString(),
        defaultValue: json['defaultValue'] as bool?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'value': value,
        'name': name,
        'defaultValue': defaultValue,
      };
}

class ZhenduCategoryInfoEntity {
  final List<LanguageText>? title;
  final String? coverUrl;
  final String? iconUrl;
  final String? description;
  final String? scriptCount;
  final List<LanguageText>? scriptCountTitle;

  ZhenduCategoryInfoEntity({
    this.title,
    this.coverUrl,
    this.iconUrl,
    this.description,
    this.scriptCount,
    this.scriptCountTitle,
  });

  factory ZhenduCategoryInfoEntity.fromJson(Map<String, dynamic> json) {
    List<LanguageText>? title;
    final titleJson = json['title'] as List<dynamic>?;
    if (titleJson != null) {
      title = titleJson
          .map((e) => LanguageText.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<LanguageText>? scriptCountTitle;
    final scriptCountTitleJson = json['scriptCountTitle'] as List<dynamic>?;
    if (scriptCountTitleJson != null) {
      scriptCountTitle = scriptCountTitleJson
          .map((e) => LanguageText.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ZhenduCategoryInfoEntity(
      title: title,
      coverUrl: json['coverUrl'] as String?,
      iconUrl: json['iconUrl'] as String?,
      description: json['description'] as String?,
      scriptCount: json['scriptCount']?.toString(),
      scriptCountTitle: scriptCountTitle,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title?.map((e) => e.toJson()).toList(),
        'coverUrl': coverUrl,
        'iconUrl': iconUrl,
        'description': description,
        'scriptCount': scriptCount,
        'scriptCountTitle': scriptCountTitle?.map((e) => e.toJson()).toList(),
      };
}

class ZhenduScriptDifficultyEntity {
  final int? min;
  final int? max;

  ZhenduScriptDifficultyEntity({this.min, this.max});

  factory ZhenduScriptDifficultyEntity.fromJson(Map<String, dynamic> json) =>
      ZhenduScriptDifficultyEntity(
        min: (json['min'] as num?)?.toInt(),
        max: (json['max'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'min': min,
        'max': max,
      };
}

class ZhenduScriptSourceEntity {
  final String? type;
  final String? name;
  final dynamic difficulty;
  final Map<String, dynamic>? data;

  ZhenduScriptSourceEntity({
    this.type,
    this.name,
    this.difficulty,
    this.data,
  });

  factory ZhenduScriptSourceEntity.fromJson(Map<String, dynamic> json) =>
      ZhenduScriptSourceEntity(
        type: json['type'] as String?,
        name: json['name'] as String?,
        difficulty: json['difficulty'],
        data: json['data'] == null
            ? null
            : Map<String, dynamic>.from(json['data'] as Map),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'name': name,
        'difficulty': difficulty,
        'data': data,
      };
}

class ZhenduTagEntity {
  final List<LanguageText>? gloss;
  final List<ThemeTextStyleEntity>? style;

  ZhenduTagEntity({
    this.gloss,
    this.style,
  });

  factory ZhenduTagEntity.fromJson(Map<String, dynamic> json) {
    List<LanguageText>? gloss;
    final glossJson = json['gloss'] as List<dynamic>?;
    if (glossJson != null) {
      gloss = glossJson
          .map((e) => LanguageText.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<ThemeTextStyleEntity>? style;
    final styleJson = json['style'] as List<dynamic>?;
    if (styleJson != null) {
      style = styleJson
          .map((e) => ThemeTextStyleEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ZhenduTagEntity(
      gloss: gloss,
      style: style,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'gloss': gloss?.map((e) => e.toJson()).toList(),
        'style': style?.map((e) => e.toJson()).toList(),
      };
}

class ZhenduScriptEntity {
  final int? uid;
  final List<LanguageText>? title;
  final String? description;
  final String? coverUrl;
  final bool? isRead;
  final String? locate;
  final List<LanguageText>? locateTitle;
  final int? styleId;
  final List<LanguageText>? styleTitle;
  final String? dialect;
  final List<LanguageText>? dialectTitle;
  final List<ZhenduTagEntity>? tags;
  final int? sceneCount;
  final double? duration;
  final int? status;
  final ZhenduScriptDifficultyEntity? difficulty;
  final ZhenduScriptSourceEntity? source;
  final LockEntity? cardRights;
  final int? servicePackageId;
  final int? servicePackageVersion;

  ZhenduScriptEntity({
    this.uid,
    this.title,
    this.description,
    this.coverUrl,
    this.isRead,
    this.locate,
    this.locateTitle,
    this.styleId,
    this.styleTitle,
    this.dialect,
    this.dialectTitle,
    this.tags,
    this.sceneCount,
    this.duration,
    this.status,
    this.difficulty,
    this.source,
    this.cardRights,
    this.servicePackageId,
    this.servicePackageVersion,
  });

  factory ZhenduScriptEntity.fromJson(Map<String, dynamic> json) {
    List<LanguageText>? _parseLanguageTextList(dynamic value) {
      if (value is! List) return null;
      final resp = <LanguageText>[];
      for (final e in value) {
        if (e is Map<String, dynamic>) {
          resp.add(LanguageText.fromJson(e));
        }
      }
      return resp.isEmpty ? null : resp;
    }

    final title = _parseLanguageTextList(json['title']);
    final locateTitle = _parseLanguageTextList(json['locateTitle']);
    final styleTitle = _parseLanguageTextList(json['styleTitle']);
    final dialectTitle = _parseLanguageTextList(json['dialectTitle']);

    List<ZhenduTagEntity>? tags;
    final tagsJson = json['tags'] as List<dynamic>?;
    if (tagsJson != null) {
      tags = tagsJson
          .map((e) => ZhenduTagEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ZhenduScriptEntity(
      uid: (json['uid'] as num?)?.toInt(),
      title: title,
      description: json['description'] as String?,
      coverUrl: json['coverUrl'] as String?,
      isRead: json['isRead'] as bool?,
      locate: json['locate'] as String?,
      locateTitle: locateTitle,
      styleId: (json['styleId'] as num?)?.toInt(),
      styleTitle: styleTitle,
      dialect: json['dialect'] as String?,
      dialectTitle: dialectTitle,
      tags: tags,
      sceneCount: (json['sceneCount'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toDouble(),
      status: (json['status'] as num?)?.toInt(),
      difficulty: json['difficulty'] == null
          ? null
          : ZhenduScriptDifficultyEntity.fromJson(
              json['difficulty'] as Map<String, dynamic>),
      source: json['source'] == null
          ? null
          : ZhenduScriptSourceEntity.fromJson(
              json['source'] as Map<String, dynamic>),
      cardRights: (json['rights']) == null
          ? null
          : LockEntity.fromJson((json['rights']) as Map<String, dynamic>),
      servicePackageId: (json['servicePackageId'] as num?)?.toInt(),
      servicePackageVersion: (json['servicePackageVersion'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'uid': uid,
        'title': title?.map((e) => e.toJson()).toList(),
        'description': description,
        'coverUrl': coverUrl,
        'isRead': isRead,
        'locate': locate,
        'locateTitle': locateTitle?.map((e) => e.toJson()).toList(),
        'styleId': styleId,
        'styleTitle': styleTitle?.map((e) => e.toJson()).toList(),
        'dialect': dialect,
        'dialectTitle': dialectTitle?.map((e) => e.toJson()).toList(),
        'tags': tags?.map((e) => e.toJson()).toList(),
        'sceneCount': sceneCount,
        'duration': duration,
        'status': status,
        'difficulty': difficulty?.toJson(),
        'source': source?.toJson(),
        'rights': cardRights?.toJson(),
        'servicePackageId': servicePackageId,
        'servicePackageVersion': servicePackageVersion,
      };
}

class ZhenduLearnItemEntity {
  final String? iconUrl;
  final String? iconKey;
  final ZhenduLearnItemColorEntity? color;
  final String? type;
  final List<LanguageText>? title;
  final String? learnTip;
  final String? description;
  final int? index;
  final dynamic jump;
  final int? status;
  final String? statusTip;

  ZhenduLearnItemEntity({
    this.iconUrl,
    this.iconKey,
    this.color,
    this.type,
    this.title,
    this.learnTip,
    this.description,
    this.index,
    this.jump,
    this.status,
    this.statusTip,
  });

  factory ZhenduLearnItemEntity.fromJson(Map<String, dynamic> json) {
    List<LanguageText>? title;
    final titleJson = json['title'] as List<dynamic>?;
    if (titleJson != null) {
      title = titleJson
          .map((e) => LanguageText.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ZhenduLearnItemEntity(
      iconUrl: json['iconUrl'] as String?,
      iconKey: json['iconKey'] as String?,
      color: json['color'] == null
          ? null
          : ZhenduLearnItemColorEntity.fromJson(
              json['color'] as Map<String, dynamic>),
      type: json['type'] as String?,
      title: title,
      learnTip: json['learnTip'] as String?,
      description: json['description'] as String?,
      index: (json['index'] as num?)?.toInt(),
      jump: json['jump'],
      status: (json['status'] as num?)?.toInt(),
      statusTip: json['statusTip'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'iconUrl': iconUrl,
        'iconKey': iconKey,
        'color': color?.toJson(),
        'type': type,
        'title': title?.map((e) => e.toJson()).toList(),
        'learnTip': learnTip,
        'description': description,
        'index': index,
        'jump': jump,
        'status': status,
        'statusTip': statusTip,
      };
}

class ZhenduLearnItemColorEntity {
  final String? from;
  final String? to;

  ZhenduLearnItemColorEntity({
    this.from,
    this.to,
  });

  factory ZhenduLearnItemColorEntity.fromJson(Map<String, dynamic> json) =>
      ZhenduLearnItemColorEntity(
        from: json['from'] as String?,
        to: json['to'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'from': from,
        'to': to,
      };
}

class ZhenduScriptDetailEntity extends ZhenduScriptEntity {
  final ZhenduTheaterEntity? scriptType;
  final List<LanguageText>? detailTitle;
  final int? learnCountMax;
  final int? learnCount;
  final String? preferredNoticeTitle;
  final String? preferredNotice;
  final List<ZhenduLearnItemEntity> learnItems;

  ZhenduScriptDetailEntity({
    super.uid,
    super.title,
    this.scriptType,
    this.detailTitle,
    super.description,
    super.coverUrl,
    super.locate,
    super.locateTitle,
    super.styleId,
    super.styleTitle,
    super.dialect,
    super.dialectTitle,
    super.tags,
    super.sceneCount,
    super.duration,
    super.status,
    super.difficulty,
    super.source,
    this.learnCountMax,
    this.learnCount,
    this.preferredNoticeTitle,
    this.preferredNotice,
    required this.learnItems,
  });

  factory ZhenduScriptDetailEntity.fromJson(Map<String, dynamic> json) {
    final base = ZhenduScriptEntity.fromJson(json);

    List<LanguageText>? detailTitle;
    final titleJson = json['title'] as List<dynamic>?;
    if (titleJson != null) {
      detailTitle = titleJson
          .map((e) => LanguageText.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final learnItemsJson = json['learnItems'] as List<dynamic>?;
    final learnItems = learnItemsJson == null
        ? <ZhenduLearnItemEntity>[]
        : learnItemsJson
            .map((e) =>
                ZhenduLearnItemEntity.fromJson(e as Map<String, dynamic>))
            .toList();

    return ZhenduScriptDetailEntity(
      uid: base.uid,
      title: base.title,
      scriptType: json['scriptType'] == null
          ? null
          : ZhenduTheaterEntity.fromJson(
              json['scriptType'] as Map<String, dynamic>),
      detailTitle: detailTitle,
      description: base.description,
      coverUrl: base.coverUrl,
      locate: base.locate,
      locateTitle: base.locateTitle,
      styleId: base.styleId,
      styleTitle: base.styleTitle,
      dialect: base.dialect,
      dialectTitle: base.dialectTitle,
      tags: base.tags,
      sceneCount: base.sceneCount,
      duration: base.duration,
      status: base.status,
      difficulty: base.difficulty,
      source: base.source,
      learnCountMax: (json['learnCountMax'] as num?)?.toInt(),
      learnCount: (json['learnCount'] as num?)?.toInt(),
      preferredNoticeTitle: json['preferredNoticeTitle'] as String?,
      preferredNotice: json['preferredNotice'] as String?,
      learnItems: learnItems,
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ...super.toJson(),
        'scriptType': scriptType?.toJson(),
        'title': detailTitle?.map((e) => e.toJson()).toList(),
        'learnCountMax': learnCountMax,
        'learnCount': learnCount,
        'preferredNoticeTitle': preferredNoticeTitle,
        'preferredNotice': preferredNotice,
        'learnItems': learnItems.map((e) => e.toJson()).toList(),
      };
}
