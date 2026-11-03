import 'entities.dart';

class LexicalDetailEntity {
  String? contentType;
  int? contentId;
  int? semanticId;
  String? headword;
  String? pos;
  List<LanguageText?>? translate;
  List<LanguageText?>? descriptions;
  List<LexicalDetailSemanticItem?>? semanticItems;
  List<LexicalDetailSetGroup?>? synonymSets;
  List<LexicalDetailSetGroup?>? antonymSets;

  LexicalDetailEntity({
    this.contentType,
    this.contentId,
    this.semanticId,
    this.headword,
    this.pos,
    this.translate,
    this.descriptions,
    this.semanticItems,
    this.synonymSets,
    this.antonymSets,
  });

  LexicalDetailEntity.fromJson(Map<String, dynamic> json) {
    contentType = json['contentType']?.toString();
    contentId = json['contentId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    headword = json['headword']?.toString();
    pos = json['pos']?.toString();
    if (json['translate'] != null) {
      final List<LanguageText> items = <LanguageText>[];
      for (final dynamic item in json['translate']) {
        items.add(LanguageText.fromJson(item));
      }
      translate = items;
    }
    if (json['descriptions'] != null) {
      final List<LanguageText> items = <LanguageText>[];
      for (final dynamic item in json['descriptions']) {
        items.add(LanguageText.fromJson(item));
      }
      descriptions = items;
    }
    if (json['semanticItems'] != null) {
      final List<LexicalDetailSemanticItem> items = <LexicalDetailSemanticItem>[];
      for (final dynamic item in json['semanticItems']) {
        items.add(LexicalDetailSemanticItem.fromJson(item));
      }
      semanticItems = items;
    }
    if (json['synonymSets'] != null) {
      final List<LexicalDetailSetGroup> items = <LexicalDetailSetGroup>[];
      for (final dynamic item in json['synonymSets']) {
        items.add(LexicalDetailSetGroup.fromJson(item));
      }
      synonymSets = items;
    }
    if (json['antonymSets'] != null) {
      final List<LexicalDetailSetGroup> items = <LexicalDetailSetGroup>[];
      for (final dynamic item in json['antonymSets']) {
        items.add(LexicalDetailSetGroup.fromJson(item));
      }
      antonymSets = items;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['contentType'] = contentType;
    data['contentId'] = contentId;
    data['semanticId'] = semanticId;
    data['headword'] = headword;
    data['pos'] = pos;
    if (translate != null) {
      data['translate'] = translate!.map((item) => item?.toJson()).toList();
    }
    if (descriptions != null) {
      data['descriptions'] = descriptions!.map((item) => item?.toJson()).toList();
    }
    if (semanticItems != null) {
      data['semanticItems'] = semanticItems!.map((item) => item?.toJson()).toList();
    }
    if (synonymSets != null) {
      data['synonymSets'] = synonymSets!.map((item) => item?.toJson()).toList();
    }
    if (antonymSets != null) {
      data['antonymSets'] = antonymSets!.map((item) => item?.toJson()).toList();
    }
    return data;
  }
}

class LexicalDetailSemanticItem {
  String? contentType;
  int? contentId;
  int? semanticId;
  String? pos;
  String? posAddr;
  List<LanguageText?>? posTitle;
  String? translate;
  List<ThemeTextStyleEntity?>? textStyle;

  LexicalDetailSemanticItem({
    this.contentType,
    this.contentId,
    this.semanticId,
    this.pos,
    this.posAddr,
    this.posTitle,
    this.translate,
    this.textStyle,
  });

  LexicalDetailSemanticItem.fromJson(Map<String, dynamic> json) {
    contentType = json['contentType']?.toString();
    contentId = json['contentId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    pos = json['pos']?.toString();
    posAddr = json['posAddr']?.toString();
    translate = json['translate']?.toString();
    if (json['posTitle'] != null) {
      final List<LanguageText> items = <LanguageText>[];
      for (final dynamic item in json['posTitle']) {
        items.add(LanguageText.fromJson(item));
      }
      posTitle = items;
    }
    if (json['textStyle'] != null) {
      final List<ThemeTextStyleEntity> items = <ThemeTextStyleEntity>[];
      for (final dynamic item in json['textStyle']) {
        items.add(ThemeTextStyleEntity.fromJson(item));
      }
      textStyle = items;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['contentType'] = contentType;
    data['contentId'] = contentId;
    data['semanticId'] = semanticId;
    data['pos'] = pos;
    data['posAddr'] = posAddr;
    data['translate'] = translate;
    if (posTitle != null) {
      data['posTitle'] = posTitle!.map((item) => item?.toJson()).toList();
    }
    if (textStyle != null) {
      data['textStyle'] = textStyle!.map((item) => item?.toJson()).toList();
    }
    return data;
  }
}

class LexicalDetailSetGroup {
  int? uid;
  List<LanguageText?>? concept;
  List<LanguageText?>? descriptions;
  LexicalDetailPoleLabels? poleLabels;
  LexicalDetailDisplay? display;
  List<LexicalDetailMember?>? members;

  LexicalDetailSetGroup({
    this.uid,
    this.concept,
    this.descriptions,
    this.poleLabels,
    this.display,
    this.members,
  });

  LexicalDetailSetGroup.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    if (json['concept'] != null) {
      final List<LanguageText> items = <LanguageText>[];
      for (final dynamic item in json['concept']) {
        items.add(LanguageText.fromJson(item));
      }
      concept = items;
    }
    if (json['descriptions'] != null) {
      final List<LanguageText> items = <LanguageText>[];
      for (final dynamic item in json['descriptions']) {
        items.add(LanguageText.fromJson(item));
      }
      descriptions = items;
    }
    if (json['poleLabels'] != null) {
      poleLabels = LexicalDetailPoleLabels.fromJson(
        json['poleLabels'] as Map<String, dynamic>,
      );
    }
    if (json['display'] != null) {
      display = LexicalDetailDisplay.fromJson(
        json['display'] as Map<String, dynamic>,
      );
    }
    if (json['members'] != null) {
      final List<LexicalDetailMember> items = <LexicalDetailMember>[];
      for (final dynamic item in json['members']) {
        items.add(LexicalDetailMember.fromJson(item));
      }
      members = items;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    if (concept != null) {
      data['concept'] = concept!.map((item) => item?.toJson()).toList();
    }
    if (descriptions != null) {
      data['descriptions'] = descriptions!.map((item) => item?.toJson()).toList();
    }
    if (poleLabels != null) {
      data['poleLabels'] = poleLabels!.toJson();
    }
    if (display != null) {
      data['display'] = display!.toJson();
    }
    if (members != null) {
      data['members'] = members!.map((item) => item?.toJson()).toList();
    }
    return data;
  }
}

class LexicalDetailPoleLabels {
  List<LanguageText?>? a;
  List<LanguageText?>? b;

  LexicalDetailPoleLabels({
    this.a,
    this.b,
  });

  LexicalDetailPoleLabels.fromJson(Map<String, dynamic> json) {
    if (json['a'] != null) {
      final List<LanguageText> items = <LanguageText>[];
      for (final dynamic item in json['a']) {
        items.add(LanguageText.fromJson(item));
      }
      a = items;
    }
    if (json['b'] != null) {
      final List<LanguageText> items = <LanguageText>[];
      for (final dynamic item in json['b']) {
        items.add(LanguageText.fromJson(item));
      }
      b = items;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (a != null) {
      data['a'] = a!.map((item) => item?.toJson()).toList();
    }
    if (b != null) {
      data['b'] = b!.map((item) => item?.toJson()).toList();
    }
    return data;
  }
}

class LexicalDetailDisplay {
  String? left;
  String? right;

  LexicalDetailDisplay({
    this.left,
    this.right,
  });

  LexicalDetailDisplay.fromJson(Map<String, dynamic> json) {
    left = json['left']?.toString();
    right = json['right']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['left'] = left;
    data['right'] = right;
    return data;
  }
}

class LexicalDetailMember {
  String? role;
  List<LanguageText?>? roleName;
  String? pole;
  bool? isCurrent;
  KnowledgeCommonEntityList? card;

  LexicalDetailMember({
    this.role,
    this.roleName,
    this.pole,
    this.isCurrent,
    this.card,
  });

  LexicalDetailMember.fromJson(Map<String, dynamic> json) {
    role = json['role']?.toString();
    pole = json['pole']?.toString();
    isCurrent = json['isCurrent'];
    if (json['roleName'] != null) {
      final List<LanguageText> items = <LanguageText>[];
      for (final dynamic item in json['roleName']) {
        items.add(LanguageText.fromJson(item));
      }
      roleName = items;
    }
    if (json['card'] != null) {
      card = KnowledgeCommonEntityList.fromJson(
        json['card'] as Map<String, dynamic>,
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['role'] = role;
    data['pole'] = pole;
    data['isCurrent'] = isCurrent;
    if (roleName != null) {
      data['roleName'] = roleName!.map((item) => item?.toJson()).toList();
    }
    if (card != null) {
      data['card'] = card!.toJson();
    }
    return data;
  }
}
