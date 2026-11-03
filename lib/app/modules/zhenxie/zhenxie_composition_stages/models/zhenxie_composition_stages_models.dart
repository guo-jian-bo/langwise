import '../../../../../common/entities/entities.dart';

class CompositionStageSlotModel {
  int? order;
  String? beatNid;
  String? paragraphTypeNid;
  List<LanguageText> paragraphTypeName;
  String? fill;

  CompositionStageSlotModel({
    this.order,
    this.beatNid,
    this.paragraphTypeNid,
    this.paragraphTypeName = const <LanguageText>[],
    this.fill,
  });

  factory CompositionStageSlotModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? paragraphType = json['paragraphType'] is Map<String, dynamic>
        ? json['paragraphType'] as Map<String, dynamic>
        : null;
    return CompositionStageSlotModel(
      order: json['order']?.toInt(),
      beatNid: json['beatNid']?.toString(),
      paragraphTypeNid: json['paragraphTypeNid']?.toString(),
      paragraphTypeName: (paragraphType?['name'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      fill: json['fill']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'order': order,
      'beatNid': beatNid,
      'paragraphTypeNid': paragraphTypeNid,
      'paragraphTypeName': paragraphTypeName.map((item) => item.toJson()).toList(),
      'fill': fill,
    };
  }
}

class CompositionStageMilestoneLiteModel {
  String? nid;
  List<LanguageText> name;
  List<LanguageText> description;

  CompositionStageMilestoneLiteModel({
    this.nid,
    this.name = const <LanguageText>[],
    this.description = const <LanguageText>[],
  });

  factory CompositionStageMilestoneLiteModel.fromJson(Map<String, dynamic> json) {
    return CompositionStageMilestoneLiteModel(
      nid: json['nid']?.toString(),
      name: (json['name'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      description: (json['description'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nid': nid,
      'name': name.map((item) => item.toJson()).toList(),
      'description': description.map((item) => item.toJson()).toList(),
    };
  }
}

class CompositionBlueprintFrameModel {
  bool hasHead;
  bool hasTail;
  List<LanguageText> headName;
  List<LanguageText> tailName;

  CompositionBlueprintFrameModel({
    this.hasHead = false,
    this.hasTail = false,
    this.headName = const <LanguageText>[],
    this.tailName = const <LanguageText>[],
  });

  factory CompositionBlueprintFrameModel.fromJson(Map<String, dynamic> json) {
    return CompositionBlueprintFrameModel(
      hasHead: json['hasHead'] == true,
      hasTail: json['hasTail'] == true,
      headName: (json['headName'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      tailName: (json['tailName'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'hasHead': hasHead,
      'hasTail': hasTail,
      'headName': headName.map((item) => item.toJson()).toList(),
      'tailName': tailName.map((item) => item.toJson()).toList(),
    };
  }
}

class CompositionBlueprintAllowedParagraphModel {
  String? paragraphTypeNid;
  List<LanguageText> paragraphTypeName;

  CompositionBlueprintAllowedParagraphModel({
    this.paragraphTypeNid,
    this.paragraphTypeName = const <LanguageText>[],
  });

  factory CompositionBlueprintAllowedParagraphModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? paragraphType = json['paragraphType'] is Map<String, dynamic>
        ? json['paragraphType'] as Map<String, dynamic>
        : null;
    return CompositionBlueprintAllowedParagraphModel(
      paragraphTypeNid: json['paragraphTypeNid']?.toString(),
      paragraphTypeName: (paragraphType?['name'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'paragraphTypeNid': paragraphTypeNid,
      'paragraphTypeName': paragraphTypeName.map((item) => item.toJson()).toList(),
    };
  }
}

class CompositionBlueprintSlotModel {
  int? order;
  String? beatNid;
  int? repeatMax;
  List<CompositionBlueprintAllowedParagraphModel> allowedParagraphs;

  CompositionBlueprintSlotModel({
    this.order,
    this.beatNid,
    this.repeatMax,
    this.allowedParagraphs = const <CompositionBlueprintAllowedParagraphModel>[],
  });

  factory CompositionBlueprintSlotModel.fromJson(Map<String, dynamic> json) {
    return CompositionBlueprintSlotModel(
      order: json['order']?.toInt(),
      beatNid: json['beatNid']?.toString(),
      repeatMax: json['repeatMax']?.toInt(),
      allowedParagraphs: (json['allowedParagraphs'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(CompositionBlueprintAllowedParagraphModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'order': order,
      'beatNid': beatNid,
      'repeatMax': repeatMax,
      'allowedParagraphs': allowedParagraphs.map((item) => item.toJson()).toList(),
    };
  }
}

class CompositionBlueprintModel {
  String? nid;
  String? cover;
  String? coverUrl;
  String? coverMd5;
  String? compositionFamilyNid;
  List<LanguageText> name;
  List<LanguageText> description;
  CompositionBlueprintFrameModel? frame;
  List<CompositionBlueprintSlotModel> slots;

  CompositionBlueprintModel({
    this.nid,
    this.cover,
    this.coverUrl,
    this.coverMd5,
    this.compositionFamilyNid,
    this.name = const <LanguageText>[],
    this.description = const <LanguageText>[],
    this.frame,
    this.slots = const <CompositionBlueprintSlotModel>[],
  });

  factory CompositionBlueprintModel.fromJson(Map<String, dynamic> json) {
    return CompositionBlueprintModel(
      nid: json['nid']?.toString(),
      cover: json['cover']?.toString(),
      coverUrl: json['coverUrl']?.toString(),
      coverMd5: json['coverMd5']?.toString(),
      compositionFamilyNid: json['compositionFamilyNid']?.toString(),
      name: (json['name'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      description: (json['description'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      frame: json['frame'] is Map<String, dynamic> ? CompositionBlueprintFrameModel.fromJson(json['frame']) : null,
      slots: (json['slots'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(CompositionBlueprintSlotModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nid': nid,
      'cover': cover,
      'coverUrl': coverUrl,
      'coverMd5': coverMd5,
      'compositionFamilyNid': compositionFamilyNid,
      'name': name.map((item) => item.toJson()).toList(),
      'description': description.map((item) => item.toJson()).toList(),
      'frame': frame?.toJson(),
      'slots': slots.map((item) => item.toJson()).toList(),
    };
  }
}

class CompositionStageModel {
  String? nid;
  String? cover;
  String? coverUrl;
  String? coverMd5;
  String? compositionBlueprintNid;
  String? genreNid;
  CompositionBlueprintModel? compositionBlueprint;
  CardContentDifficulty? difficulty;
  String? answerKind;
  int? answerMinCount;
  int? answerMaxCount;
  bool? lockBlueprintTab;
  bool? lockExemplarView;
  List<CompositionStageSlotModel> slots;
  String? headFill;
  String? tailFill;
  int? order;
  List<String> milestones;
  List<CompositionStageMilestoneLiteModel> milestoneList;
  List<LanguageText> name;
  List<LanguageText> description;
  bool? system;
  bool? enabled;
  int? learnedCount;
  int? taskCount;
  bool? hasHead;
  bool? hasTail;
  List<LanguageText> headName;
  List<LanguageText> tailName;

  CompositionStageModel({
    this.nid,
    this.cover,
    this.coverUrl,
    this.coverMd5,
    this.compositionBlueprintNid,
    this.genreNid,
    this.compositionBlueprint,
    this.difficulty,
    this.answerKind,
    this.answerMinCount,
    this.answerMaxCount,
    this.lockBlueprintTab,
    this.lockExemplarView,
    this.slots = const <CompositionStageSlotModel>[],
    this.headFill,
    this.tailFill,
    this.order,
    this.milestones = const <String>[],
    this.milestoneList = const <CompositionStageMilestoneLiteModel>[],
    this.name = const <LanguageText>[],
    this.description = const <LanguageText>[],
    this.system,
    this.enabled,
    this.learnedCount,
    this.taskCount,
    this.hasHead,
    this.hasTail,
    this.headName = const <LanguageText>[],
    this.tailName = const <LanguageText>[],
  });

  factory CompositionStageModel.fromJson(Map<String, dynamic> json) {
    return CompositionStageModel(
      nid: json['nid']?.toString(),
      cover: json['cover']?.toString(),
      coverUrl: json['coverUrl']?.toString(),
      coverMd5: json['coverMd5']?.toString(),
      compositionBlueprintNid: json['compositionBlueprintNid']?.toString(),
      genreNid: json['genreNid']?.toString(),
      compositionBlueprint: json['compositionBlueprint'] is Map<String, dynamic>
          ? CompositionBlueprintModel.fromJson(json['compositionBlueprint'])
          : null,
      difficulty: json['difficulty'] is Map<String, dynamic> ? CardContentDifficulty.fromJson(json['difficulty']) : null,
      answerKind: json['answerKind']?.toString(),
      answerMinCount: json['answerMinCount']?.toInt(),
      answerMaxCount: json['answerMaxCount']?.toInt(),
      lockBlueprintTab: json['lockBlueprintTab'] == null ? null : json['lockBlueprintTab'] == true,
      lockExemplarView: json['lockExemplarView'] == null ? null : json['lockExemplarView'] == true,
      slots: (json['slots'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(CompositionStageSlotModel.fromJson)
          .toList(),
      headFill: json['headFill']?.toString(),
      tailFill: json['tailFill']?.toString(),
      order: json['order']?.toInt(),
      milestones: (json['milestones'] as List<dynamic>? ?? <dynamic>[]).map((item) => item.toString()).toList(),
      milestoneList: (json['milestoneList'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(CompositionStageMilestoneLiteModel.fromJson)
          .toList(),
      name: (json['name'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      description: (json['description'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      system: json['system'] == null ? null : json['system'] == true,
      enabled: json['enabled'] == null ? null : json['enabled'] == true,
      learnedCount: json['learnedCount']?.toInt(),
      taskCount: json['taskCount']?.toInt(),
      hasHead: json['hasHead'] == null ? null : json['hasHead'] == true,
      hasTail: json['hasTail'] == null ? null : json['hasTail'] == true,
      headName: (json['headName'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      tailName: (json['tailName'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nid': nid,
      'cover': cover,
      'coverUrl': coverUrl,
      'coverMd5': coverMd5,
      'compositionBlueprintNid': compositionBlueprintNid,
      'genreNid': genreNid,
      'compositionBlueprint': compositionBlueprint?.toJson(),
      'difficulty': difficulty?.toJson(),
      'answerKind': answerKind,
      'answerMinCount': answerMinCount,
      'answerMaxCount': answerMaxCount,
      'lockBlueprintTab': lockBlueprintTab,
      'lockExemplarView': lockExemplarView,
      'slots': slots.map((item) => item.toJson()).toList(),
      'headFill': headFill,
      'tailFill': tailFill,
      'order': order,
      'milestones': milestones,
      'milestoneList': milestoneList.map((item) => item.toJson()).toList(),
      'name': name.map((item) => item.toJson()).toList(),
      'description': description.map((item) => item.toJson()).toList(),
      'system': system,
      'enabled': enabled,
      'learnedCount': learnedCount,
      'taskCount': taskCount,
      'hasHead': hasHead,
      'hasTail': hasTail,
      'headName': headName.map((item) => item.toJson()).toList(),
      'tailName': tailName.map((item) => item.toJson()).toList(),
    };
  }
}

class CompositionGenreModel {
  String? nid;
  List<LanguageText> name;
  List<LanguageText> description;
  String? color;

  CompositionGenreModel({
    this.nid,
    this.name = const <LanguageText>[],
    this.description = const <LanguageText>[],
    this.color,
  });

  factory CompositionGenreModel.fromJson(Map<String, dynamic> json) {
    return CompositionGenreModel(
      nid: json['nid']?.toString(),
      name: (json['name'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      description: (json['description'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      color: json['color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nid': nid,
      'name': name.map((item) => item.toJson()).toList(),
      'description': description.map((item) => item.toJson()).toList(),
      'color': color,
    };
  }
}

class CompositionStageMilestoneGroupModel {
  int startIndex;
  int endIndex;
  String key;
  String label;
  List<CompositionStageMilestoneLiteModel> milestoneList;

  CompositionStageMilestoneGroupModel({
    required this.startIndex,
    required this.endIndex,
    required this.key,
    required this.label,
    this.milestoneList = const <CompositionStageMilestoneLiteModel>[],
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'startIndex': startIndex,
      'endIndex': endIndex,
      'key': key,
      'label': label,
      'milestoneList': milestoneList.map((item) => item.toJson()).toList(),
    };
  }
}

enum CompositionStageMilestoneSegmentType {
  none,
  single,
  start,
  middle,
  end,
}

class CompositionStageMapColumnModel {
  int columnIndex;
  CompositionStageModel stage;
  int? laneIndex;
  String milestoneKey;
  String milestoneLabel;
  CompositionStageMilestoneSegmentType milestoneSegment;

  CompositionStageMapColumnModel({
    required this.columnIndex,
    required this.stage,
    required this.laneIndex,
    required this.milestoneKey,
    required this.milestoneLabel,
    required this.milestoneSegment,
  });
}
