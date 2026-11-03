




import '../enum/enum.dart';
import 'entities.dart';

class PlanEntityPlanPathCoursesStudyPlanStartUnit {
/*
{
  "courseId": 29,
  "levelId": 42,
  "moduleId": 249,
  "unitId": 2752
} 
*/

  int? courseId;
  int? levelId;
  int? moduleId;
  int? unitId;

  PlanEntityPlanPathCoursesStudyPlanStartUnit({
    this.courseId,
    this.levelId,
    this.moduleId,
    this.unitId,
  });
  PlanEntityPlanPathCoursesStudyPlanStartUnit.fromJson(Map<String, dynamic> json) {
    courseId = json['courseId']?.toInt();
    levelId = json['levelId']?.toInt();
    moduleId = json['moduleId']?.toInt();
    unitId = json['unitId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['courseId'] = courseId;
    data['levelId'] = levelId;
    data['moduleId'] = moduleId;
    data['unitId'] = unitId;
    return data;
  }
}

class PlanEntityPlanPathCoursesStudyPlanStartUnitInfo {
/*
{
  "courseId": 29,
  "courseName": "LangWise官方课程",
  "courseCoverUrl": "https://img.timelywise.cn/u/861273427f8ece51dff5ba64ac6fe6ce/28_1f04a65f-951d-6f10-b718-07a9eb06953d.png?auth_key=1781604038-7f6pj7erwe0e-0-9bd23ae4c37e160f6810589e79cca449",
  "specialty": "EN_OFFICIAL",
  "levelId": 42,
  "levelName": "Level 0",
  "moduleId": 249,
  "moduleName": "日常活动",
  "moduleDescription": "学习日常生活中的常见动作，能使用简单的现在进行时的语法结构，来描述身边人正在做的动作。",
  "moduleCoverUrl": "https://img.timelywise.cn/knowledge/semantic/46CF341EB84F677DD6B90B79E32C187C.webp?auth_key=1781604038-9kh4v1veg91d-0-9b86bfb3d14282ea31a415f754b84030",
  "moduleTier": 0,
  "tierMappings": [
    {
      "text": "Pre A1",
      "style": [
        {
          "theme": "DARK",
          "color": "rgba(100, 116, 139, 1)",
          "fontsize": 16,
          "weight": 400,
          "backgroundColor": "rgba(100, 116, 139, 0.12)",
          "borderColor": "rgba(100, 116, 139, 0.2)"
        }
      ]
    }
  ],
  "unitId": 2752,
  "unitName": "Unit 1 日常活动1",
  "unitDescription": "学习4个常见的和日常互动相关的动词，2个名词。学习最简单的打招呼方式。",
  "unitTotal": 9
} 
*/

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
  List<ThemeTextEntity?>? tierMappings;
  int? unitId;
  String? unitName;
  String? moduleTopic;
  String? unitDescription;
  int? unitTotal;
  int? moduleDay;
  int? unitDay;
  int? lessonCount;

  PlanEntityPlanPathCoursesStudyPlanStartUnitInfo({
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
    this.tierMappings,
    this.unitId,
    this.unitName,
    this.moduleTopic,
    this.unitDescription,
    this.unitTotal,
    this.moduleDay,
    this.unitDay,
    this.lessonCount,
  });
  PlanEntityPlanPathCoursesStudyPlanStartUnitInfo.fromJson(Map<String, dynamic> json) {
    courseId = json['courseId']?.toInt();
    courseName = json['courseName']?.toString();
    courseCoverUrl = json['courseCoverUrl']?.toString();
    specialty = json['specialty']?.toString();
    levelId = json['levelId']?.toInt();
    levelName = json['levelName']?.toString();
    moduleId = json['moduleId']?.toInt();
    moduleName = json['moduleName']?.toString();
    moduleDescription = json['moduleDescription']?.toString();
    moduleCoverUrl = json['moduleCoverUrl']?.toString();
    moduleTier = json['moduleTier']?.toInt();
    if (json['tierMappings'] != null) {
      final v = json['tierMappings'];
      final arr0 = <ThemeTextEntity>[];
      v.forEach((v) {
        arr0.add(ThemeTextEntity.fromJson(v));
      });
      tierMappings = arr0;
    }
    unitId = json['unitId']?.toInt();
    unitName = json['unitName']?.toString();
    moduleTopic = json['moduleTopic']?.toString();
    unitDescription = json['unitDescription']?.toString();
    unitTotal = json['unitTotal']?.toInt();
    moduleDay = json['moduleDay']?.toInt();
    unitDay = json['unitDay']?.toInt();
    lessonCount = json['lessonCount']?.toInt();
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
    if (tierMappings != null) {
      final v = tierMappings;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['tierMappings'] = arr0;
    }
    data['unitId'] = unitId;
    data['unitName'] = unitName;
    data['moduleTopic'] = moduleTopic;
    data['unitDescription'] = unitDescription;
    data['unitTotal'] = unitTotal;
    data['moduleDay'] = moduleDay;
    data['unitDay'] = unitDay;
    data['lessonCount'] = lessonCount;
    return data;
  }
}

class PlanEntityPlanPathCoursesStudyPlanPlansTimes{
  int? hour;
  int? minute;
  PlanEntityPlanPathCoursesStudyPlanPlansTimes({
    this.hour,
    this.minute,
  });
  PlanEntityPlanPathCoursesStudyPlanPlansTimes.fromJson(Map<String, dynamic> json) {
    hour = json['hour']?.toInt();
    minute = json['minute']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['hour'] = hour;
    data['minute'] = minute;
    return data;
  }
}

class PlanEntityPlanPathCoursesStudyPlanPlans {
/*
{
  "type": "work",
  "weeks": [
    1
  ],
  "times": [
    {"hour": 9, "minute": 0}
  ],
  "notifies": null,
  "dailyStudyDuration": 1800
} 
*/

  String? type;
  List<int?>? weeks;
  List<PlanEntityPlanPathCoursesStudyPlanPlansTimes?>? times;
  String? notifies;
  int? dailyStudyDuration;

  /// 是否是休息日
  bool get isRest => type == "rest";

  PlanEntityPlanPathCoursesStudyPlanPlans({
    this.type,
    this.weeks,
    this.times,
    this.notifies,
    this.dailyStudyDuration,
  });
  PlanEntityPlanPathCoursesStudyPlanPlans.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    if (json['weeks'] != null) {
      final v = json['weeks'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      weeks = arr0;
    }
    if (json['times'] != null) {
      final v = json['times'];
      final arr0 = <PlanEntityPlanPathCoursesStudyPlanPlansTimes>[];
      v.forEach((v) {
        arr0.add(PlanEntityPlanPathCoursesStudyPlanPlansTimes.fromJson(v));
      });
      times = arr0;
    }
    notifies = json['notifies']?.toString();
    dailyStudyDuration = json['dailyStudyDuration']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    if (weeks != null) {
      final v = weeks;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['weeks'] = arr0;
    }
    if (times != null) {
      final v = times;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v?.toJson());
      });
      data['times'] = arr0;
    }
    data['notifies'] = notifies;
    data['dailyStudyDuration'] = dailyStudyDuration;
    return data;
  }
}

class PlanEntityDisableExerciseTypeInfos {
/*
{
  "category": "",
  "categoryName": "",
  "exerciseType": "",
  "exerciseTypeName": "",
  "requiredLessons": [
    ""
  ]
} 
*/

  String? category;
  String? categoryName;
  String? exerciseType;
  String? exerciseTypeName;
  List<String?>? requiredLessons;

  PlanEntityDisableExerciseTypeInfos({
    this.category,
    this.categoryName,
    this.exerciseType,
    this.exerciseTypeName,
    this.requiredLessons,
  });
  PlanEntityDisableExerciseTypeInfos.fromJson(Map<String, dynamic> json) {
    category = json['category']?.toString();
    categoryName = json['categoryName']?.toString();
    exerciseType = json['exerciseType']?.toString();
    exerciseTypeName = json['exerciseTypeName']?.toString();

    if (json['requiredLessons'] != null) {
      final v = json['requiredLessons'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      requiredLessons = arr0;
    }

  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['category'] = category;
    data['categoryName'] = categoryName;
    data['exerciseType'] = exerciseType;
    data['exerciseTypeName'] = exerciseTypeName;

    if (requiredLessons != null) {
      final v = requiredLessons;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['requiredLessons'] = arr0;
    }

    return data;
  }
}

class PlanEntityPlanPathCoursesStudyPlan {
/*
{
  "uid": 25935,
  "courseId": 29,
  "courseName": "LangWise官方课程",
  "type": "MAIN",
  "specialty": "EN_OFFICIAL",
  "difficulty": null,
  "dailyStudyDuration": 1800,
  "plans": [
    {
      "type": "work",
      "weeks": [
        1
      ],
      "times": [
        ""
      ],
      "notifies": null,
      "dailyStudyDuration": 1800
    }
  ],
  "holidayAdjustment": true,
  "nextUnit": "Unit 2\t日常活动2",
  "nextUnitDay": 2,
  "startUnitInfo": {
    "courseId": 29,
    "courseName": "LangWise官方课程",
    "courseCoverUrl": "https://img.timelywise.cn/u/861273427f8ece51dff5ba64ac6fe6ce/28_1f04a65f-951d-6f10-b718-07a9eb06953d.png?auth_key=1781604038-7f6pj7erwe0e-0-9bd23ae4c37e160f6810589e79cca449",
    "specialty": "EN_OFFICIAL",
    "levelId": 42,
    "levelName": "Level 0",
    "moduleId": 249,
    "moduleName": "日常活动",
    "moduleDescription": "学习日常生活中的常见动作，能使用简单的现在进行时的语法结构，来描述身边人正在做的动作。",
    "moduleCoverUrl": "https://img.timelywise.cn/knowledge/semantic/46CF341EB84F677DD6B90B79E32C187C.webp?auth_key=1781604038-9kh4v1veg91d-0-9b86bfb3d14282ea31a415f754b84030",
    "moduleTier": 0,
    "tierMappings": [
      {
        "text": "Pre A1",
        "style": [
          {
            "theme": "DARK",
            "color": "rgba(100, 116, 139, 1)",
            "fontsize": 16,
            "weight": 400,
            "backgroundColor": "rgba(100, 116, 139, 0.12)",
            "borderColor": "rgba(100, 116, 139, 0.2)"
          }
        ]
      }
    ],
    "unitId": 2752,
    "unitName": "Unit 1 日常活动1",
    "unitDescription": "学习4个常见的和日常互动相关的动词，2个名词。学习最简单的打招呼方式。",
    "unitTotal": 9
  },
  "startUnit": {
    "courseId": 29,
    "levelId": 42,
    "moduleId": 249,
    "unitId": 2752
  },
  "currentUnitInfo": {
    "courseId": 29,
    "courseName": "LangWise官方课程",
    "courseCoverUrl": "https://img.timelywise.cn/u/861273427f8ece51dff5ba64ac6fe6ce/28_1f04a65f-951d-6f10-b718-07a9eb06953d.png?auth_key=1781604038-7f6pj7erwe0e-0-9bd23ae4c37e160f6810589e79cca449",
    "specialty": "EN_OFFICIAL",
    "levelId": 42,
    "levelName": "Level 0",
    "moduleId": 249,
    "moduleName": "日常活动",
    "moduleDescription": "学习日常生活中的常见动作，能使用简单的现在进行时的语法结构，来描述身边人正在做的动作。",
    "moduleCoverUrl": "https://img.timelywise.cn/knowledge/semantic/46CF341EB84F677DD6B90B79E32C187C.webp?auth_key=1781604038-9kh4v1veg91d-0-9b86bfb3d14282ea31a415f754b84030",
    "moduleTier": 0,
    "tierMappings": [
      {
        "text": "Pre A1",
        "style": [
          {
            "theme": "DARK",
            "color": "rgba(100, 116, 139, 1)",
            "fontsize": 16,
            "weight": 400,
            "backgroundColor": "rgba(100, 116, 139, 0.12)",
            "borderColor": "rgba(100, 116, 139, 0.2)"
          }
        ]
      }
    ],
    "unitId": 2752,
    "unitName": "Unit 1 日常活动1",
    "unitDescription": "学习4个常见的和日常互动相关的动词，2个名词。学习最简单的打招呼方式。",
    "unitTotal": 9
  },
  "directionList": [
    {
      "direction": "CORE_LESSON",
      "iconUrl": "https://openpic.timelywise.cn/icon/lesson/001-core-lesson.webp",
      "title": [
        {
          "lang": "en",
          "text": "Introductory Lesson"
        }
      ],
      "subtitle": [
        {
          "lang": "en",
          "text": "Like learning your native tongue, this immersive preview helps you effortlessly build a knowledge framework for the unit's core content."
        }
      ],
      "order": 90000,
      "exclude": false
    }
  ],
  "excludeDirections": [
    ""
  ],
  "excludeDirectionList": [
    ""
  ],
  "includeDirections": [
    "CORE_LESSON"
  ],
  "includeDirectionList": [
    {
      "direction": "CORE_LESSON",
      "iconUrl": "https://openpic.timelywise.cn/icon/lesson/001-core-lesson.webp",
      "title": [
        {
          "lang": "en",
          "text": "Introductory Lesson"
        }
      ],
      "subtitle": [
        {
          "lang": "en",
          "text": "Like learning your native tongue, this immersive preview helps you effortlessly build a knowledge framework for the unit's core content."
        }
      ],
      "order": 90000,
      "exclude": null
    }
  ],
  "moduleContentInfo": null,
  "pause": null,
  "resumeDate": null,
  "validAssessment": true,
  "ableUnitTest": true
} 
*/

  int? uid;
  int? courseId;
  String? courseName;
  String? type;
  String? specialty;
  String? difficulty;
  int? dailyStudyDuration;
  List<PlanEntityPlanPathCoursesStudyPlanPlans?>? plans;
  bool? holidayAdjustment;
  String? nextUnit;
  int? nextUnitDay;
  PlanEntityPlanPathCoursesStudyPlanStartUnitInfo? startUnitInfo;
  PlanEntityPlanPathCoursesStudyPlanStartUnit? startUnit;
  PlanEntityPlanPathCoursesStudyPlanStartUnitInfo? currentUnitInfo;
  List<LessonTypeEntityList?>? directionList;
  List<String?>? excludeDirections;
  List<String?>? excludeDirectionList;
  List<String?>? includeDirections;
  List<LessonTypeEntityList?>? includeDirectionList;
  List<String?>? disableExerciseTypes;
  List<PlanEntityDisableExerciseTypeInfos?>? disableExerciseTypeInfos;
  SpeciaityPhonicsModelDataModuleContentInfo? moduleContentInfo;
  bool? pause;
  String? resumeDate;
  bool? validAssessment;
  bool? ableUnitTest;

  PlanEntityPlanPathCoursesStudyPlan({
    this.uid,
    this.courseId,
    this.courseName,
    this.type,
    this.specialty,
    this.difficulty,
    this.dailyStudyDuration,
    this.plans,
    this.holidayAdjustment,
    this.nextUnit,
    this.nextUnitDay,
    this.startUnitInfo,
    this.startUnit,
    this.currentUnitInfo,
    this.directionList,
    this.excludeDirections,
    this.excludeDirectionList,
    this.includeDirections,
    this.includeDirectionList,
    this.disableExerciseTypes,
    this.disableExerciseTypeInfos,
    this.moduleContentInfo,
    this.pause,
    this.resumeDate,
    this.validAssessment,
    this.ableUnitTest,
  });
  PlanEntityPlanPathCoursesStudyPlan.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    courseId = json['courseId']?.toInt();
    courseName = json['courseName']?.toString();
    type = json['type']?.toString();
    specialty = json['specialty']?.toString();
    difficulty = json['difficulty']?.toString();
    dailyStudyDuration = json['dailyStudyDuration']?.toInt();
    if (json['plans'] != null) {
      final v = json['plans'];
      final arr0 = <PlanEntityPlanPathCoursesStudyPlanPlans>[];
      v.forEach((v) {
        arr0.add(PlanEntityPlanPathCoursesStudyPlanPlans.fromJson(v));
      });
      plans = arr0;
    }
    holidayAdjustment = json['holidayAdjustment'];
    nextUnit = json['nextUnit']?.toString();
    nextUnitDay = json['nextUnitDay']?.toInt();
    startUnitInfo = (json['startUnitInfo'] != null) ? PlanEntityPlanPathCoursesStudyPlanStartUnitInfo.fromJson(json['startUnitInfo']) : null;
    startUnit = (json['startUnit'] != null) ? PlanEntityPlanPathCoursesStudyPlanStartUnit.fromJson(json['startUnit']) : null;
    currentUnitInfo = (json['currentUnitInfo'] != null) ? PlanEntityPlanPathCoursesStudyPlanStartUnitInfo.fromJson(json['currentUnitInfo']) : null;
    if (json['directionList'] != null) {
      final v = json['directionList'];
      final arr0 = <LessonTypeEntityList>[];
      v.forEach((v) {
        arr0.add(LessonTypeEntityList.fromJson(v));
      });
      directionList = arr0;
    }
    if (json['excludeDirections'] != null) {
      final v = json['excludeDirections'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      excludeDirections = arr0;
    }
    if (json['excludeDirectionList'] != null) {
      final v = json['excludeDirectionList'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      excludeDirectionList = arr0;
    }
    if (json['includeDirections'] != null) {
      final v = json['includeDirections'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      includeDirections = arr0;
    }
    if (json['includeDirectionList'] != null) {
      final v = json['includeDirectionList'];
      final arr0 = <LessonTypeEntityList>[];
      v.forEach((v) {
        arr0.add(LessonTypeEntityList.fromJson(v));
      });
      includeDirectionList = arr0;
    }

    if (json['disableExerciseTypes'] != null) {
      final v = json['disableExerciseTypes'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      disableExerciseTypes = arr0;
    }

    if (json['disableExerciseTypeInfos'] != null) {
      final v = json['disableExerciseTypeInfos'];
      final arr0 = <PlanEntityDisableExerciseTypeInfos>[];
      v.forEach((v) {
        arr0.add(PlanEntityDisableExerciseTypeInfos.fromJson(v));
      });
      disableExerciseTypeInfos = arr0;
    }

    moduleContentInfo = (json['moduleContentInfo'] != null) ? SpeciaityPhonicsModelDataModuleContentInfo.fromJson(json['moduleContentInfo']) : null;
    pause = json['pause'];
    resumeDate = json['resumeDate']?.toString();
    validAssessment = json['validAssessment'];
    ableUnitTest = json['ableUnitTest'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['courseId'] = courseId;
    data['courseName'] = courseName;
    data['type'] = type;
    data['specialty'] = specialty;
    data['difficulty'] = difficulty;
    data['dailyStudyDuration'] = dailyStudyDuration;
    if (plans != null) {
      final v = plans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['plans'] = arr0;
    }
    data['holidayAdjustment'] = holidayAdjustment;
    data['nextUnit'] = nextUnit;
    data['nextUnitDay'] = nextUnitDay;
    if (startUnitInfo != null) {
      data['startUnitInfo'] = startUnitInfo!.toJson();
    }
    if (startUnit != null) {
      data['startUnit'] = startUnit!.toJson();
    }
    if (currentUnitInfo != null) {
      data['currentUnitInfo'] = currentUnitInfo!.toJson();
    }
    if (directionList != null) {
      final v = directionList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['directionList'] = arr0;
    }
    if (excludeDirections != null) {
      final v = excludeDirections;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['excludeDirections'] = arr0;
    }
    if (excludeDirectionList != null) {
      final v = excludeDirectionList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['excludeDirectionList'] = arr0;
    }
    if (includeDirections != null) {
      final v = includeDirections;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['includeDirections'] = arr0;
    }
    if (includeDirectionList != null) {
      final v = includeDirectionList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['includeDirectionList'] = arr0;
    }

    if (disableExerciseTypes != null) {
      final v = disableExerciseTypes;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['disableExerciseTypes'] = arr0;
    }

    if (disableExerciseTypeInfos != null) {
      final v = disableExerciseTypeInfos;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['disableExerciseTypeInfos'] = arr0;
    }

    data['moduleContentInfo'] = moduleContentInfo?.toJson();
    data['pause'] = pause;
    data['resumeDate'] = resumeDate;
    data['validAssessment'] = validAssessment;
    data['ableUnitTest'] = ableUnitTest;
    return data;
  }
}

class PlanEntityPlanPathCourses {
/*
{
  "courseId": 29,
  "courseName": "LangWise官方课程",
  "type": "MAIN",
  "specialty": "EN_OFFICIAL",
  "steps": [
    {
      "name": "基础入门",
      "description": "从零开始，全课时高强度学习，为教材课打基础",
      "courseId": 29,
      "directionList": [
        {
          "direction": "CORE_LESSON",
          "iconUrl": "https://openpic.timelywise.cn/icon/lesson/001-core-lesson.webp",
          "title": [
            {
              "lang": "en",
              "text": "Introductory Lesson"
            }
          ],
          "subtitle": [
            {
              "lang": "en",
              "text": "Like learning your native tongue, this immersive preview helps you effortlessly build a knowledge framework for the unit's core content."
            }
          ],
          "order": 90000,
          "exclude": false
        }
      ],
      "tierRange": {
        "max": 3,
        "min": 0
      },
      "dailyStudyDuration": 1800,
      "status": "RUNNING"
    }
  ],
  "studyPlan": {
    "uid": 25935,
    "courseId": 29,
    "courseName": "LangWise官方课程",
    "type": "MAIN",
    "specialty": "EN_OFFICIAL",
    "difficulty": null,
    "dailyStudyDuration": 1800,
    "plans": [
      {
        "type": "work",
        "weeks": [
          1
        ],
        "times": [
          ""
        ],
        "notifies": null,
        "dailyStudyDuration": 1800
      }
    ],
    "holidayAdjustment": true,
    "nextUnit": "Unit 2\t日常活动2",
    "nextUnitDay": 2,
    "startUnitInfo": {
      "courseId": 29,
      "courseName": "LangWise官方课程",
      "courseCoverUrl": "https://img.timelywise.cn/u/861273427f8ece51dff5ba64ac6fe6ce/28_1f04a65f-951d-6f10-b718-07a9eb06953d.png?auth_key=1781604038-7f6pj7erwe0e-0-9bd23ae4c37e160f6810589e79cca449",
      "specialty": "EN_OFFICIAL",
      "levelId": 42,
      "levelName": "Level 0",
      "moduleId": 249,
      "moduleName": "日常活动",
      "moduleDescription": "学习日常生活中的常见动作，能使用简单的现在进行时的语法结构，来描述身边人正在做的动作。",
      "moduleCoverUrl": "https://img.timelywise.cn/knowledge/semantic/46CF341EB84F677DD6B90B79E32C187C.webp?auth_key=1781604038-9kh4v1veg91d-0-9b86bfb3d14282ea31a415f754b84030",
      "moduleTier": 0,
      "tierMappings": [
        {
          "text": "Pre A1",
          "style": [
            {
              "theme": "DARK",
              "color": "rgba(100, 116, 139, 1)",
              "fontsize": 16,
              "weight": 400,
              "backgroundColor": "rgba(100, 116, 139, 0.12)",
              "borderColor": "rgba(100, 116, 139, 0.2)"
            }
          ]
        }
      ],
      "unitId": 2752,
      "unitName": "Unit 1 日常活动1",
      "unitDescription": "学习4个常见的和日常互动相关的动词，2个名词。学习最简单的打招呼方式。",
      "unitTotal": 9
    },
    "startUnit": {
      "courseId": 29,
      "levelId": 42,
      "moduleId": 249,
      "unitId": 2752
    },
    "currentUnitInfo": {
      "courseId": 29,
      "courseName": "LangWise官方课程",
      "courseCoverUrl": "https://img.timelywise.cn/u/861273427f8ece51dff5ba64ac6fe6ce/28_1f04a65f-951d-6f10-b718-07a9eb06953d.png?auth_key=1781604038-7f6pj7erwe0e-0-9bd23ae4c37e160f6810589e79cca449",
      "specialty": "EN_OFFICIAL",
      "levelId": 42,
      "levelName": "Level 0",
      "moduleId": 249,
      "moduleName": "日常活动",
      "moduleDescription": "学习日常生活中的常见动作，能使用简单的现在进行时的语法结构，来描述身边人正在做的动作。",
      "moduleCoverUrl": "https://img.timelywise.cn/knowledge/semantic/46CF341EB84F677DD6B90B79E32C187C.webp?auth_key=1781604038-9kh4v1veg91d-0-9b86bfb3d14282ea31a415f754b84030",
      "moduleTier": 0,
      "tierMappings": [
        {
          "text": "Pre A1",
          "style": [
            {
              "theme": "DARK",
              "color": "rgba(100, 116, 139, 1)",
              "fontsize": 16,
              "weight": 400,
              "backgroundColor": "rgba(100, 116, 139, 0.12)",
              "borderColor": "rgba(100, 116, 139, 0.2)"
            }
          ]
        }
      ],
      "unitId": 2752,
      "unitName": "Unit 1 日常活动1",
      "unitDescription": "学习4个常见的和日常互动相关的动词，2个名词。学习最简单的打招呼方式。",
      "unitTotal": 9
    },
    "directionList": [
      {
        "direction": "CORE_LESSON",
        "iconUrl": "https://openpic.timelywise.cn/icon/lesson/001-core-lesson.webp",
        "title": [
          {
            "lang": "en",
            "text": "Introductory Lesson"
          }
        ],
        "subtitle": [
          {
            "lang": "en",
            "text": "Like learning your native tongue, this immersive preview helps you effortlessly build a knowledge framework for the unit's core content."
          }
        ],
        "order": 90000,
        "exclude": false
      }
    ],
    "excludeDirections": [
      ""
    ],
    "excludeDirectionList": [
      ""
    ],
    "includeDirections": [
      "CORE_LESSON"
    ],
    "includeDirectionList": [
      {
        "direction": "CORE_LESSON",
        "iconUrl": "https://openpic.timelywise.cn/icon/lesson/001-core-lesson.webp",
        "title": [
          {
            "lang": "en",
            "text": "Introductory Lesson"
          }
        ],
        "subtitle": [
          {
            "lang": "en",
            "text": "Like learning your native tongue, this immersive preview helps you effortlessly build a knowledge framework for the unit's core content."
          }
        ],
        "order": 90000,
        "exclude": null
      }
    ],
    "moduleContentInfo": null,
    "pause": null,
    "resumeDate": null,
    "validAssessment": true,
    "ableUnitTest": true
  },
  "assessmentPlan": 1,
  "assessmentPlanStatus": 0,
  "ableUnitTest": true,
  "rights": {
    "access": "NORMAL",
    "rights": "NORMAL"
  }
} 
*/

  int? courseId;
  String? courseName;
  String? type;
  String? specialty;
  List<StudyPlanCardStepModel?>? steps;
  PlanEntityPlanPathCoursesStudyPlan? studyPlan;
  int? assessmentPlan;
  int? assessmentPlanStatus;
  /// 是否展示解锁的计划弹窗 0=不展示 1第一个 2第二个 3第三个
  int? canShowIndex;
  bool? ableUnitTest;
  LockEntity? rights;

  PlanEntityPlanPathCourses({
    this.courseId,
    this.courseName,
    this.type,
    this.specialty,
    this.steps,
    this.studyPlan,
    this.assessmentPlan,
    this.assessmentPlanStatus,
    this.canShowIndex,
    this.ableUnitTest,
    this.rights,
  });
  PlanEntityPlanPathCourses.fromJson(Map<String, dynamic> json) {
    courseId = json['courseId']?.toInt();
    courseName = json['courseName']?.toString();
    type = json['type']?.toString();
    specialty = json['specialty']?.toString();
    if (json['steps'] != null) {
      final v = json['steps'];
      final arr0 = <StudyPlanCardStepModel>[];
      v.forEach((v) {
        arr0.add(StudyPlanCardStepModel.fromJson(v));
      });
      steps = arr0;
    }
    studyPlan = (json['studyPlan'] != null) ? PlanEntityPlanPathCoursesStudyPlan.fromJson(json['studyPlan']) : null;
    assessmentPlan = json['assessmentPlan']?.toInt();
    assessmentPlanStatus = json['assessmentPlanStatus']?.toInt();
    canShowIndex = json['canShowIndex']?.toInt();
    ableUnitTest = json['ableUnitTest'];
    rights = (json['rights'] != null) ? LockEntity.fromJson(json['rights']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['courseId'] = courseId;
    data['courseName'] = courseName;
    data['type'] = type;
    data['specialty'] = specialty;
    if (steps != null) {
      final v = steps;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['steps'] = arr0;
    }
    if (studyPlan != null) {
      data['studyPlan'] = studyPlan!.toJson();
    }
    data['assessmentPlan'] = assessmentPlan;
    data['assessmentPlanStatus'] = assessmentPlanStatus;
    data['canShowIndex'] = canShowIndex;
    data['ableUnitTest'] = ableUnitTest;
    if (rights != null) {
      data['rights'] = rights!.toJson();
    }
    return data;
  }
}

class PlanEntityExamPlan{
  LockEntity? rights;
  int? examPlanStatus;

  PlanEntityExamPlan({
    this.rights,
    this.examPlanStatus,
  });

  PlanEntityExamPlan.fromJson(Map<String, dynamic> json) {
    rights = (json['rights'] != null) ? LockEntity.fromJson(json['rights']) : null;
    examPlanStatus = json['examPlanStatus']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (rights != null) {
      data['rights'] = rights!.toJson();
    }
    data['examPlanStatus'] = examPlanStatus;
    return data;
  }
}

class PlanEntity {
/*
{
  "assessmentPlan": 1,
  "validAssessmentPlan": false,
  "validAssessmentExplain": "需要说明点击替换原来的计划会全部删除，替换按钮",
  "planPathCourses": [
    {
      "courseId": 29,
      "courseName": "LangWise官方课程",
      "type": "MAIN",
      "specialty": "EN_OFFICIAL",
      "steps": [
        {
          "name": "基础入门",
          "description": "从零开始，全课时高强度学习，为教材课打基础",
          "courseId": 29,
          "directionList": [
            {
              "direction": "CORE_LESSON",
              "iconUrl": "https://openpic.timelywise.cn/icon/lesson/001-core-lesson.webp",
              "title": [
                {
                  "lang": "en",
                  "text": "Introductory Lesson"
                }
              ],
              "subtitle": [
                {
                  "lang": "en",
                  "text": "Like learning your native tongue, this immersive preview helps you effortlessly build a knowledge framework for the unit's core content."
                }
              ],
              "order": 90000,
              "exclude": false
            }
          ],
          "tierRange": {
            "max": 3,
            "min": 0
          },
          "dailyStudyDuration": 1800,
          "status": "RUNNING"
        }
      ],
      "studyPlan": {
        "uid": 25935,
        "courseId": 29,
        "courseName": "LangWise官方课程",
        "type": "MAIN",
        "specialty": "EN_OFFICIAL",
        "difficulty": null,
        "dailyStudyDuration": 1800,
        "plans": [
          {
            "type": "work",
            "weeks": [
              1
            ],
            "times": [
              ""
            ],
            "notifies": null,
            "dailyStudyDuration": 1800
          }
        ],
        "holidayAdjustment": true,
        "nextUnit": "Unit 2\t日常活动2",
        "nextUnitDay": 2,
        "startUnitInfo": {
          "courseId": 29,
          "courseName": "LangWise官方课程",
          "courseCoverUrl": "https://img.timelywise.cn/u/861273427f8ece51dff5ba64ac6fe6ce/28_1f04a65f-951d-6f10-b718-07a9eb06953d.png?auth_key=1781604038-7f6pj7erwe0e-0-9bd23ae4c37e160f6810589e79cca449",
          "specialty": "EN_OFFICIAL",
          "levelId": 42,
          "levelName": "Level 0",
          "moduleId": 249,
          "moduleName": "日常活动",
          "moduleDescription": "学习日常生活中的常见动作，能使用简单的现在进行时的语法结构，来描述身边人正在做的动作。",
          "moduleCoverUrl": "https://img.timelywise.cn/knowledge/semantic/46CF341EB84F677DD6B90B79E32C187C.webp?auth_key=1781604038-9kh4v1veg91d-0-9b86bfb3d14282ea31a415f754b84030",
          "moduleTier": 0,
          "tierMappings": [
            {
              "text": "Pre A1",
              "style": [
                {
                  "theme": "DARK",
                  "color": "rgba(100, 116, 139, 1)",
                  "fontsize": 16,
                  "weight": 400,
                  "backgroundColor": "rgba(100, 116, 139, 0.12)",
                  "borderColor": "rgba(100, 116, 139, 0.2)"
                }
              ]
            }
          ],
          "unitId": 2752,
          "unitName": "Unit 1 日常活动1",
          "unitDescription": "学习4个常见的和日常互动相关的动词，2个名词。学习最简单的打招呼方式。",
          "unitTotal": 9
        },
        "startUnit": {
          "courseId": 29,
          "levelId": 42,
          "moduleId": 249,
          "unitId": 2752
        },
        "currentUnitInfo": {
          "courseId": 29,
          "courseName": "LangWise官方课程",
          "courseCoverUrl": "https://img.timelywise.cn/u/861273427f8ece51dff5ba64ac6fe6ce/28_1f04a65f-951d-6f10-b718-07a9eb06953d.png?auth_key=1781604038-7f6pj7erwe0e-0-9bd23ae4c37e160f6810589e79cca449",
          "specialty": "EN_OFFICIAL",
          "levelId": 42,
          "levelName": "Level 0",
          "moduleId": 249,
          "moduleName": "日常活动",
          "moduleDescription": "学习日常生活中的常见动作，能使用简单的现在进行时的语法结构，来描述身边人正在做的动作。",
          "moduleCoverUrl": "https://img.timelywise.cn/knowledge/semantic/46CF341EB84F677DD6B90B79E32C187C.webp?auth_key=1781604038-9kh4v1veg91d-0-9b86bfb3d14282ea31a415f754b84030",
          "moduleTier": 0,
          "tierMappings": [
            {
              "text": "Pre A1",
              "style": [
                {
                  "theme": "DARK",
                  "color": "rgba(100, 116, 139, 1)",
                  "fontsize": 16,
                  "weight": 400,
                  "backgroundColor": "rgba(100, 116, 139, 0.12)",
                  "borderColor": "rgba(100, 116, 139, 0.2)"
                }
              ]
            }
          ],
          "unitId": 2752,
          "unitName": "Unit 1 日常活动1",
          "unitDescription": "学习4个常见的和日常互动相关的动词，2个名词。学习最简单的打招呼方式。",
          "unitTotal": 9
        },
        "directionList": [
          {
            "direction": "CORE_LESSON",
            "iconUrl": "https://openpic.timelywise.cn/icon/lesson/001-core-lesson.webp",
            "title": [
              {
                "lang": "en",
                "text": "Introductory Lesson"
              }
            ],
            "subtitle": [
              {
                "lang": "en",
                "text": "Like learning your native tongue, this immersive preview helps you effortlessly build a knowledge framework for the unit's core content."
              }
            ],
            "order": 90000,
            "exclude": false
          }
        ],
        "excludeDirections": [
          ""
        ],
        "excludeDirectionList": [
          ""
        ],
        "includeDirections": [
          "CORE_LESSON"
        ],
        "includeDirectionList": [
          {
            "direction": "CORE_LESSON",
            "iconUrl": "https://openpic.timelywise.cn/icon/lesson/001-core-lesson.webp",
            "title": [
              {
                "lang": "en",
                "text": "Introductory Lesson"
              }
            ],
            "subtitle": [
              {
                "lang": "en",
                "text": "Like learning your native tongue, this immersive preview helps you effortlessly build a knowledge framework for the unit's core content."
              }
            ],
            "order": 90000,
            "exclude": null
          }
        ],
        "moduleContentInfo": null,
        "pause": null,
        "resumeDate": null,
        "validAssessment": true,
        "ableUnitTest": true
      },
      "assessmentPlan": 1,
      "assessmentPlanStatus": 0,
      "ableUnitTest": true,
      "rights": {
        "access": "NORMAL",
        "rights": "NORMAL"
      }
    }
  ]
} 
*/

  /// 1=跟随系统计划
  int? assessmentPlan;
  int? assessmentId;
  int? lastAssessmentId;
  bool? validAssessmentPlan;
  String? validAssessmentExplain;
  /// 评测的步骤
  String? assessmentGuideStep;
  List<PlanEntityPlanPathCourses?>? planPathCourses;
  /// 权限
  LockEntity? rights;
  /// 备考
  PlanEntityExamPlan? examPlan;

  /// 评测的步骤枚举 需要弹出弹窗 不让操作计划页面
  LearningSettingStepsEnum? get assessmentGuideStepEnum => LearningSettingStepsEnum.fromValue(assessmentGuideStep);

  PlanEntity({
    this.assessmentPlan,
    this.assessmentId,
    this.lastAssessmentId,
    this.validAssessmentPlan,
    this.validAssessmentExplain,
    this.planPathCourses,
    this.rights,
  });
  PlanEntity.fromJson(Map<String, dynamic> json) {
    assessmentPlan = json['assessmentPlan']?.toInt();
    assessmentId = json['assessmentId']?.toInt();
    lastAssessmentId = json['lastAssessmentId']?.toInt();
    validAssessmentPlan = json['validAssessmentPlan'];
    validAssessmentExplain = json['validAssessmentExplain']?.toString();
    assessmentGuideStep = json['assessmentGuideStep']?.toString();
    if (json['planPathCourses'] != null) {
      final v = json['planPathCourses'];
      final arr0 = <PlanEntityPlanPathCourses>[];
      v.forEach((v) {
        arr0.add(PlanEntityPlanPathCourses.fromJson(v));
      });
      planPathCourses = arr0;
    }
    rights = json['rights'] == null ? null : LockEntity.fromJson(json['rights']);
    examPlan = json['examPlan'] == null ? null : PlanEntityExamPlan.fromJson(json['examPlan']);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['assessmentPlan'] = assessmentPlan;
    data['assessmentId'] = assessmentId;
    data['validAssessmentPlan'] = validAssessmentPlan;
    data['validAssessmentExplain'] = validAssessmentExplain;
    data['assessmentGuideStep'] = assessmentGuideStep;
    if (planPathCourses != null) {
      final v = planPathCourses;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['planPathCourses'] = arr0;
    }
    data['rights'] = rights?.toJson();
    data['examPlan'] = examPlan?.toJson();
    return data;
  }
}
