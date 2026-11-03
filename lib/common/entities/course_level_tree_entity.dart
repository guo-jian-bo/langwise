import 'entities.dart';

class CourseLevelTreeUnit {
  int? unitId;
  String? unitName;
  List<LanguageText?>? unitTitle;
  String? unitCoverUrl;
  String? unitCoverKey;
  String? description;
  double? progress;

  CourseLevelTreeUnit({
    this.unitId,
    this.unitName,
    this.unitTitle,
    this.unitCoverUrl,
    this.unitCoverKey,
    this.progress,
  });

  CourseLevelTreeUnit.fromJson(Map<String, dynamic> json) {
    unitId = json['unitId']?.toInt();
    unitName = json['unitName']?.toString();
    if (json['unitTitle'] != null) {
      final v = json['unitTitle'];
      final arr0 = <LanguageText>[];
      v.forEach((e) {
        arr0.add(LanguageText.fromJson(e));
      });
      unitTitle = arr0;
    }
    unitCoverUrl = json['unitCoverUrl']?.toString();
    unitCoverKey = json['unitCoverKey']?.toString();
    description = json['unitDescription']?.toString();
    progress = json['progress'] == null ? null : (json['progress'] as num).toDouble();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['unitId'] = unitId;
    data['unitName'] = unitName;
    if (unitTitle != null) {
      final v = unitTitle;
      final arr0 = [];
      v!.forEach((e) {
        arr0.add(e!.toJson());
      });
      data['unitTitle'] = arr0;
    }
    data['unitCoverUrl'] = unitCoverUrl;
    data['unitCoverKey'] = unitCoverKey;
    data['description'] = description;
    data['progress'] = progress;
    return data;
  }
}

class CourseLevelTreeModule {
  bool? current;
  int? moduleId;
  String? name;
  String? description;
  String? coverUrl;
  bool? completed;
  double? progress;
  List<CourseLevelEntityLevelListModuleListKnowledgeCounts?>? knowledgeCounts;
  CourseLevelEntityLevelListModuleListDifficulty? difficulty;
  List<ThemeTextEntity?>? tierMappings;
  double? order;
  List<CourseLevelTreeUnit?>? units;

  CourseLevelTreeModule({
    this.current,
    this.moduleId,
    this.name,
    this.description,
    this.coverUrl,
    this.completed,
    this.progress,
    this.knowledgeCounts,
    this.difficulty,
    this.tierMappings,
    this.order,
    this.units,
  });

  CourseLevelTreeModule.fromJson(Map<String, dynamic> json) {
    current = json['current'];
    moduleId = json['moduleId']?.toInt();
    name = json['name']?.toString();
    description = json['description']?.toString();
    coverUrl = json['coverUrl']?.toString();
    completed = json['completed'];
    progress = json['progress'] == null ? null : (json['progress'] as num).toDouble();
    if (json['knowledgeCounts'] != null) {
      final v = json['knowledgeCounts'];
      final arr0 = <CourseLevelEntityLevelListModuleListKnowledgeCounts>[];
      v.forEach((e) {
        arr0.add(CourseLevelEntityLevelListModuleListKnowledgeCounts.fromJson(e));
      });
      knowledgeCounts = arr0;
    }
    if (json['difficulty'] != null) {
      difficulty = CourseLevelEntityLevelListModuleListDifficulty.fromJson(json['difficulty']);
    }
    if (json['tierMappings'] != null) {
      final v = json['tierMappings'];
      final arr0 = <ThemeTextEntity>[];
      v.forEach((e) {
        arr0.add(ThemeTextEntity.fromJson(e));
      });
      tierMappings = arr0;
    }
    order = json['order'] == null ? null : (json['order'] as num).toDouble();
    if (json['units'] != null) {
      final v = json['units'];
      final arr0 = <CourseLevelTreeUnit>[];
      v.forEach((e) {
        arr0.add(CourseLevelTreeUnit.fromJson(e));
      });
      units = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['current'] = current;
    data['moduleId'] = moduleId;
    data['name'] = name;
    data['description'] = description;
    data['coverUrl'] = coverUrl;
    data['completed'] = completed;
    data['progress'] = progress;
    if (knowledgeCounts != null) {
      final v = knowledgeCounts;
      final arr0 = [];
      v!.forEach((e) {
        arr0.add(e!.toJson());
      });
      data['knowledgeCounts'] = arr0;
    }
    if (difficulty != null) {
      data['difficulty'] = difficulty!.toJson();
    }
    if (tierMappings != null) {
      final v = tierMappings;
      final arr0 = [];
      v!.forEach((e) {
        arr0.add(e!.toJson());
      });
      data['tierMappings'] = arr0;
    }
    data['order'] = order;
    if (units != null) {
      final v = units;
      final arr0 = [];
      v!.forEach((e) {
        arr0.add(e!.toJson());
      });
      data['units'] = arr0;
    }
    return data;
  }
}

class CourseLevelTreeLevel {
  int? levelId;
  String? name;
  String? cefr;
  String? studyZone;
  int? tier;
  List<ThemeTextEntity?>? tierMappings;
  List<CourseLevelTreeModule?>? moduleList;

  CourseLevelTreeLevel({
    this.levelId,
    this.name,
    this.cefr,
    this.studyZone,
    this.tier,
    this.tierMappings,
    this.moduleList,
  });

  CourseLevelTreeLevel.fromJson(Map<String, dynamic> json) {
    levelId = json['levelId']?.toInt();
    name = json['name']?.toString();
    cefr = json['cefr']?.toString();
    studyZone = json['studyZone']?.toString();
    tier = json['tier']?.toInt();
    if (json['tierMappings'] != null) {
      final v = json['tierMappings'];
      final arr0 = <ThemeTextEntity>[];
      v.forEach((e) {
        arr0.add(ThemeTextEntity.fromJson(e));
      });
      tierMappings = arr0;
    }
    if (json['moduleList'] != null) {
      final v = json['moduleList'];
      final arr0 = <CourseLevelTreeModule>[];
      v.forEach((e) {
        arr0.add(CourseLevelTreeModule.fromJson(e));
      });
      moduleList = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['levelId'] = levelId;
    data['name'] = name;
    data['cefr'] = cefr;
    data['studyZone'] = studyZone;
    data['tier'] = tier;
    if (tierMappings != null) {
      final v = tierMappings;
      final arr0 = [];
      v!.forEach((e) {
        arr0.add(e!.toJson());
      });
      data['tierMappings'] = arr0;
    }
    if (moduleList != null) {
      final v = moduleList;
      final arr0 = [];
      v!.forEach((e) {
        arr0.add(e!.toJson());
      });
      data['moduleList'] = arr0;
    }
    return data;
  }
}

class CourseLevelTreeEntity {
  int? courseId;
  String? courseName;
  String? specialty;
  int? studyTier;
  List<CourseLevelTreeLevel?>? levels;

  CourseLevelTreeEntity({
    this.courseId,
    this.courseName,
    this.specialty,
    this.studyTier,
    this.levels,
  });

  CourseLevelTreeEntity.fromJson(Map<String, dynamic> json) {
    courseId = json['courseId']?.toInt();
    courseName = json['courseName']?.toString();
    specialty = json['specialty']?.toString();
    studyTier = json['studyTier']?.toInt();
    if (json['levels'] != null) {
      final v = json['levels'];
      final arr0 = <CourseLevelTreeLevel>[];
      v.forEach((e) {
        arr0.add(CourseLevelTreeLevel.fromJson(e));
      });
      levels = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['courseId'] = courseId;
    data['courseName'] = courseName;
    data['specialty'] = specialty;
    data['studyTier'] = studyTier;
    if (levels != null) {
      final v = levels;
      final arr0 = [];
      v!.forEach((e) {
        arr0.add(e!.toJson());
      });
      data['levels'] = arr0;
    }
    return data;
  }
}
