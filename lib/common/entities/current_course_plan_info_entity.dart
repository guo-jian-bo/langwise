class CurrentCoursePlanInfoEntity {
  List<CurrentCoursePlanInfoCourseItem?>? courseList;

  CurrentCoursePlanInfoEntity({this.courseList});

  CurrentCoursePlanInfoEntity.fromJson(Map<String, dynamic> json) {
    if (json['courseList'] != null) {
      final v = json['courseList'];
      final arr0 = <CurrentCoursePlanInfoCourseItem>[];
      for (final item in v) {
        arr0.add(CurrentCoursePlanInfoCourseItem.fromJson(item));
      }
      courseList = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (courseList != null) {
      final v = courseList;
      final arr0 = [];
      for (final item in v!) {
        arr0.add(item?.toJson());
      }
      data['courseList'] = arr0;
    }
    return data;
  }
}

class CurrentCoursePlanInfoCourseItem {
  int? courseId;
  String? courseName;
  String? courseCoverUrl;
  CurrentCoursePlanInfoCurrentInfo? currentInfo;
  bool? pause;
  String? resumeDate;
  int? execute;
  CurrentCoursePlanInfoTrigger? trigger;
  bool? listening;
  bool? speaking;
  bool? reading;
  bool? writing;

  CurrentCoursePlanInfoCourseItem({
    this.courseId,
    this.courseName,
    this.courseCoverUrl,
    this.currentInfo,
    this.pause,
    this.resumeDate,
    this.execute,
    this.trigger,
    this.listening,
    this.speaking,
    this.reading,
    this.writing,
  });

  bool get showListening => listening == true;
  bool get showSpeaking => speaking == true;
  bool get showReading => reading == true;
  bool get showWriting => writing == true;
  bool get isNotStarted => execute == 0 && currentInfo != null;
  bool get isNeedAddCourse => execute == 0 && currentInfo == null;
  bool get isNormalLearning => execute == 1;
  bool get isCompleted => execute == 2;
  bool get isAutoUnlock => execute == 10 && pause != false;
  bool get isPaused => execute == 10 && pause == false;
  int? get triggerTier => trigger?.tier;

  CurrentCoursePlanInfoCourseItem.fromJson(Map<String, dynamic> json) {
    courseId = _parseInt(json['courseId']);
    courseName = json['courseName']?.toString();
    courseCoverUrl = json['courseCoverUrl']?.toString();
    if (json['currentInfo'] != null) {
      currentInfo = CurrentCoursePlanInfoCurrentInfo.fromJson(json['currentInfo']);
    }
    pause = json['pause'];
    resumeDate = json['resumeDate']?.toString();
    execute = _parseInt(json['execute']);
    if (json['trigger'] != null) {
      trigger = CurrentCoursePlanInfoTrigger.fromJson(json['trigger']);
    }
    listening = json['listening'] == true;
    speaking = json['speaking'] == true;
    reading = json['reading'] == true;
    writing = json['writing'] == true;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['courseId'] = courseId;
    data['courseName'] = courseName;
    data['courseCoverUrl'] = courseCoverUrl;
    data['currentInfo'] = currentInfo?.toJson();
    data['pause'] = pause;
    data['resumeDate'] = resumeDate;
    data['execute'] = execute;
    data['trigger'] = trigger?.toJson();
    data['listening'] = listening;
    data['speaking'] = speaking;
    data['reading'] = reading;
    data['writing'] = writing;
    return data;
  }
}

class CurrentCoursePlanInfoTrigger {
  String? type;
  int? tier;

  CurrentCoursePlanInfoTrigger({
    this.type,
    this.tier,
  });

  CurrentCoursePlanInfoTrigger.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    tier = _parseInt(json['tier']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['tier'] = tier;
    return data;
  }
}

class CurrentCoursePlanInfoCurrentInfo {
  int? courseId;
  String? courseName;
  String? courseCoverUrl;
  String? specialty;
  int? levelId;
  String? levelName;
  int? moduleId;
  String? moduleName;
  String? moduleDescription;
  String? moduleCoverUrl;
  int? moduleTier;
  int? unitId;
  int? unitIndex;
  String? unitName;
  String? unitCoverUrl;
  String? unitDescription;
  int? unitTotal;
  double? unitProgress;
  int? lessonId;
  String? lessonName;
  int? lessonCount;

  CurrentCoursePlanInfoCurrentInfo({
    this.courseId,
    this.courseName,
    this.courseCoverUrl,
    this.specialty,
    this.levelId,
    this.levelName,
    this.moduleId,
    this.moduleName,
    this.moduleDescription,
    this.moduleCoverUrl,
    this.moduleTier,
    this.unitId,
    this.unitIndex,
    this.unitName,
    this.unitCoverUrl,
    this.unitDescription,
    this.unitTotal,
    this.unitProgress,
    this.lessonId,
    this.lessonName,
    this.lessonCount,
  });

  CurrentCoursePlanInfoCurrentInfo.fromJson(Map<String, dynamic> json) {
    courseId = _parseInt(json['courseId']);
    courseName = json['courseName']?.toString();
    courseCoverUrl = json['courseCoverUrl']?.toString();
    specialty = json['specialty']?.toString();
    levelId = _parseInt(json['levelId']);
    levelName = json['levelName']?.toString();
    moduleId = _parseInt(json['moduleId']);
    moduleName = json['moduleName']?.toString();
    moduleDescription = json['moduleDescription']?.toString();
    moduleCoverUrl = json['moduleCoverUrl']?.toString();
    moduleTier = _parseInt(json['moduleTier']);
    unitId = _parseInt(json['unitId']);
    unitIndex = _parseInt(json['unitIndex']);
    unitName = json['unitName']?.toString();
    unitCoverUrl = json['unitCoverUrl']?.toString();
    unitDescription = json['unitDescription']?.toString();
    unitTotal = _parseInt(json['unitTotal']);
    unitProgress = _parseDouble(json['unitProgress']);
    lessonId = _parseInt(json['lessonId']);
    lessonName = json['lessonName']?.toString();
    lessonCount = _parseInt(json['lessonCount']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['courseId'] = courseId;
    data['courseName'] = courseName;
    data['courseCoverUrl'] = courseCoverUrl;
    data['specialty'] = specialty;
    data['levelId'] = levelId;
    data['levelName'] = levelName;
    data['moduleId'] = moduleId;
    data['moduleName'] = moduleName;
    data['moduleDescription'] = moduleDescription;
    data['moduleCoverUrl'] = moduleCoverUrl;
    data['moduleTier'] = moduleTier;
    data['unitId'] = unitId;
    data['unitIndex'] = unitIndex;
    data['unitName'] = unitName;
    data['unitCoverUrl'] = unitCoverUrl;
    data['unitDescription'] = unitDescription;
    data['unitTotal'] = unitTotal;
    data['unitProgress'] = unitProgress;
    data['lessonId'] = lessonId;
    data['lessonName'] = lessonName;
    data['lessonCount'] = lessonCount;
    return data;
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
