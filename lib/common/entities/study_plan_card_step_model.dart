
import '../widgets/study_plan_widgets/study_plan_widget.dart';
import 'entities.dart';

/// 每一个卡片
class StudyPlanCardStepModel {
/*
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
*/

  String? name;
  String? description;
  int? courseId;
  int? levelId;
  String? levelName;
  int? moduleId;
  String? moduleName;
  int? semester;
  StudyPlanCardStepModelTrigger? trigger;
  List<StudyPlanCardStepModelModuleInfoList?>? moduleInfoList;
  List<LessonTypeEntityList?>? directionList;
  CardContentDifficulty? tierRange;
  int? dailyStudyDuration;
  /// READY,      // 表示资源已就绪，随时可以触发
  /// PENDING,    // 表示已进入队列，正在排队等待
  /// RUNNING,    // 表示任务当前活跃
  /// EXECUTED,   // 表示已执行完成
  String? status;

  /// READY,      // 表示资源已就绪，随时可以触发
  /// PENDING,    // 表示已进入队列，正在排队等待
  /// RUNNING,    // 表示任务当前活跃
  /// EXECUTED,   // 表示已执行完成
  StudyPlanStatusEnum? get statusEnum => StudyPlanStatusEnum.fromValue(status);

  StudyPlanCardStepModel({
    this.name,
    this.description,
    this.courseId,
    this.levelId,
    this.levelName,
    this.moduleId,
    this.moduleName,
    this.semester,
    this.trigger,
    this.moduleInfoList,
    this.directionList,
    this.tierRange,
    this.dailyStudyDuration,
    this.status,
  });
  StudyPlanCardStepModel.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    description = json['description']?.toString();
    courseId = json['courseId']?.toInt();

    levelId = json['levelId']?.toInt();
    levelName = json['levelName']?.toString();
    moduleId = json['moduleId']?.toInt();
    moduleName = json['moduleName']?.toString();
    semester = json['semester']?.toInt();
    trigger = json['trigger'] != null ? StudyPlanCardStepModelTrigger.fromJson(json['trigger']) : null;

    if (json['moduleInfoList'] != null) {
      final v = json['moduleInfoList'];
      final arr0 = <StudyPlanCardStepModelModuleInfoList>[];
      v.forEach((v) {
        arr0.add(StudyPlanCardStepModelModuleInfoList.fromJson(v));
      });
      moduleInfoList = arr0;
    }

    if (json['directionList'] != null) {
      final v = json['directionList'];
      final arr0 = <LessonTypeEntityList>[];
      v.forEach((v) {
        arr0.add(LessonTypeEntityList.fromJson(v));
      });
      directionList = arr0;
    }
    tierRange = (json['tierRange'] != null) ? CardContentDifficulty.fromJson(json['tierRange']) : null;
    dailyStudyDuration = json['dailyStudyDuration']?.toInt();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['description'] = description;
    data['courseId'] = courseId;
    data['levelId'] = levelId;
    data['levelName'] = levelName;
    data['moduleId'] = moduleId;
    data['moduleName'] = moduleName;
    data['semester'] = semester;
    if (trigger != null) {
      data['trigger'] = trigger!.toJson();
    }

    if(moduleInfoList != null){
      final v = moduleInfoList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['moduleInfoList'] = arr0;
    }

    if (directionList != null) {
      final v = directionList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['directionList'] = arr0;
    }
    if (tierRange != null) {
      data['tierRange'] = tierRange!.toJson();
    }
    data['dailyStudyDuration'] = dailyStudyDuration;
    data['status'] = status;
    return data;
  }
}

class StudyPlanCardStepModelTrigger{
  String? type;
  int? tier;

  StudyPlanCardStepModelTrigger({
    this.type,
    this.tier,
  });

  StudyPlanCardStepModelTrigger.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    tier = json['tier']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['tier'] = tier;
    return data;
  }

}



class StudyPlanCardStepModelModuleInfoListContentInfoPronunciationsIpa {
/*
{
  "ipa": "bɔːs",
  "graphemes": "boss",
  "variant": null,
  "positions": [
    0
  ],
  "audioUrl": "https://track.timelywise.cn/knowledge/speech/0E44E4308731F1A30F4625B1E242FA59.mp3?auth_key=1781599406-wc8wzl08ese6-0-ffd5762f2e181247de3681e6155ea4bd"
} 
*/

  String? ipa;
  String? graphemes;
  String? variant;
  List<int?>? positions;
  String? audioUrl;

  StudyPlanCardStepModelModuleInfoListContentInfoPronunciationsIpa({
    this.ipa,
    this.graphemes,
    this.variant,
    this.positions,
    this.audioUrl,
  });
  StudyPlanCardStepModelModuleInfoListContentInfoPronunciationsIpa.fromJson(Map<String, dynamic> json) {
    ipa = json['ipa']?.toString();
    graphemes = json['graphemes']?.toString();
    variant = json['variant']?.toString();
  if (json['positions'] != null) {
  final v = json['positions'];
  final arr0 = <int>[];
  v.forEach((v) {
  arr0.add(v.toInt());
  });
    positions = arr0;
    }
    audioUrl = json['audioUrl']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ipa'] = ipa;
    data['graphemes'] = graphemes;
    data['variant'] = variant;
    if (positions != null) {
      final v = positions;
      final arr0 = [];
  v!.forEach((v) {
  arr0.add(v);
  });
      data['positions'] = arr0;
    }
    data['audioUrl'] = audioUrl;
    return data;
  }
}

class StudyPlanCardStepModelModuleInfoListContentInfoPronunciations {
/*
{
  "phonetic": "bɔːs",
  "audioUrl": "https://track.timelywise.cn/knowledge/speech/0E44E4308731F1A30F4625B1E242FA59.mp3?auth_key=1781599406-wc8wzl08ese6-0-ffd5762f2e181247de3681e6155ea4bd",
  "duration": 1.49,
  "national": "US",
  "nationalTitle": "美音",
  "nationalIconUrl": "https://openpic.timelywise.cn/icon/style/locale/us.webp",
  "syllables": [
    {
      "ipa": "bɔːs",
      "graphemes": "boss",
      "variant": null,
      "positions": [
        0
      ],
      "audioUrl": "https://track.timelywise.cn/knowledge/speech/0E44E4308731F1A30F4625B1E242FA59.mp3?auth_key=1781599406-wc8wzl08ese6-0-ffd5762f2e181247de3681e6155ea4bd"
    }
  ],
  "phonetics": [
    {
      "ipa": "b",
      "graphemes": "b",
      "variant": null,
      "positions": [
        0
      ],
      "audioUrl": "https://track.timelywise.cn/img/jA3xYD3oTWTxaxyVsypuxYkZNP7bBUAyWxz4wor1uKAuwBej.mp3?auth_key=1781599406-vw2qkpbcru1m-0-4963cf56dafeae76d3c94676d6e1a34e"
    }
  ]
} 
*/

  String? phonetic;
  String? audioUrl;
  double? duration;
  String? national;
  String? nationalTitle;
  String? nationalIconUrl;
  List<StudyPlanCardStepModelModuleInfoListContentInfoPronunciationsIpa?>? syllables;
  List<StudyPlanCardStepModelModuleInfoListContentInfoPronunciationsIpa?>? phonetics;

  StudyPlanCardStepModelModuleInfoListContentInfoPronunciations({
    this.phonetic,
    this.audioUrl,
    this.duration,
    this.national,
    this.nationalTitle,
    this.nationalIconUrl,
    this.syllables,
    this.phonetics,
  });
  StudyPlanCardStepModelModuleInfoListContentInfoPronunciations.fromJson(Map<String, dynamic> json) {
    phonetic = json['phonetic']?.toString();
    audioUrl = json['audioUrl']?.toString();
    duration = json['duration']?.toDouble();
    national = json['national']?.toString();
    nationalTitle = json['nationalTitle']?.toString();
    nationalIconUrl = json['nationalIconUrl']?.toString();
  if (json['syllables'] != null) {
  final v = json['syllables'];
  final arr0 = <StudyPlanCardStepModelModuleInfoListContentInfoPronunciationsIpa>[];
  v.forEach((v) {
  arr0.add(StudyPlanCardStepModelModuleInfoListContentInfoPronunciationsIpa.fromJson(v));
  });
    syllables = arr0;
    }
  if (json['phonetics'] != null) {
  final v = json['phonetics'];
  final arr0 = <StudyPlanCardStepModelModuleInfoListContentInfoPronunciationsIpa>[];
  v.forEach((v) {
  arr0.add(StudyPlanCardStepModelModuleInfoListContentInfoPronunciationsIpa.fromJson(v));
  });
    phonetics = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['phonetic'] = phonetic;
    data['audioUrl'] = audioUrl;
    data['duration'] = duration;
    data['national'] = national;
    data['nationalTitle'] = nationalTitle;
    data['nationalIconUrl'] = nationalIconUrl;
    if (syllables != null) {
      final v = syllables;
      final arr0 = [];
  v!.forEach((v) {
  arr0.add(v!.toJson());
  });
      data['syllables'] = arr0;
    }
    if (phonetics != null) {
      final v = phonetics;
      final arr0 = [];
  v!.forEach((v) {
  arr0.add(v!.toJson());
  });
      data['phonetics'] = arr0;
    }
    return data;
  }
}

class StudyPlanCardStepModelModuleInfoListContentInfoTags {
/*
{
  "gloss": [
    {
      "lang": "en",
      "text": "n."
    }
  ],
  "style": [
    {
      "theme": "DARK",
      "color": "#FFFFFF",
      "fontsize": 16,
      "italic": false,
      "weight": 400,
      "backgroundColor": "rgba(59, 130, 246, 0.8)",
      "borderColor": "#3B82F6"
    }
  ]
} 
*/

  List<LanguageText?>? gloss;
  List<ThemeTextStyleEntity?>? style;

  StudyPlanCardStepModelModuleInfoListContentInfoTags({
    this.gloss,
    this.style,
  });
  StudyPlanCardStepModelModuleInfoListContentInfoTags.fromJson(Map<String, dynamic> json) {
  if (json['gloss'] != null) {
  final v = json['gloss'];
  final arr0 = <LanguageText>[];
  v.forEach((v) {
  arr0.add(LanguageText.fromJson(v));
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
  arr0.add(v!.toJson());
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


class StudyPlanCardStepModelModuleInfoListContentInfo {
/*
{
  "contentType": "EN_WORD",
  "contentTypeTitle": "Word",
  "contentId": 106102,
  "semanticId": 666232,
  "content": "boss",
  "definition": "工作单位的管理者",
  "gloss": [
    {
      "lang": "zh",
      "text": "老板；上司"
    }
  ],
  "tags": [
    {
      "gloss": [
        {
          "lang": "en",
          "text": "n."
        }
      ],
      "style": [
        {
          "theme": "DARK",
          "color": "#FFFFFF",
          "fontsize": 16,
          "italic": false,
          "weight": 400,
          "backgroundColor": "rgba(59, 130, 246, 0.8)",
          "borderColor": "#3B82F6"
        }
      ]
    }
  ],
  "pronunciations": [
    {
      "phonetic": "bɔːs",
      "audioUrl": "https://track.timelywise.cn/knowledge/speech/0E44E4308731F1A30F4625B1E242FA59.mp3?auth_key=1781599406-wc8wzl08ese6-0-ffd5762f2e181247de3681e6155ea4bd",
      "duration": 1.49,
      "national": "US",
      "nationalTitle": "美音",
      "nationalIconUrl": "https://openpic.timelywise.cn/icon/style/locale/us.webp",
      "syllables": [
        {
          "ipa": "bɔːs",
          "graphemes": "boss",
          "variant": null,
          "positions": [
            0
          ],
          "audioUrl": "https://track.timelywise.cn/knowledge/speech/0E44E4308731F1A30F4625B1E242FA59.mp3?auth_key=1781599406-wc8wzl08ese6-0-ffd5762f2e181247de3681e6155ea4bd"
        }
      ],
      "phonetics": [
        {
          "ipa": "b",
          "graphemes": "b",
          "variant": null,
          "positions": [
            0
          ],
          "audioUrl": "https://track.timelywise.cn/img/jA3xYD3oTWTxaxyVsypuxYkZNP7bBUAyWxz4wor1uKAuwBej.mp3?auth_key=1781599406-vw2qkpbcru1m-0-4963cf56dafeae76d3c94676d6e1a34e"
        }
      ]
    }
  ],
  "difficulty": {
    "max": 2,
    "min": 2
  },
  "imageUrl": "https://img.timelywise.cn/knowledge/semantic/9C383449D643B0904D129D2C89CC4C2A.webp?auth_key=1781599406-9bhk3huq39rr-0-56e5983d786e358f567b702f0be63350",
  "imageKey": "knowledge/semantic/9C383449D643B0904D129D2C89CC4C2A.webp",
  "phonetic": "bɔːs",
  "audioUrl": "https://track.timelywise.cn/knowledge/speech/0E44E4308731F1A30F4625B1E242FA59.mp3?auth_key=1781599406-wc8wzl08ese6-0-ffd5762f2e181247de3681e6155ea4bd",
  "pos": "n.",
  "posTitle": "名词"
} 
*/

  String? contentType;
  String? contentTypeTitle;
  int? contentId;
  int? semanticId;
  String? content;
  String? definition;
  List<LanguageText?>? gloss;
  List<StudyPlanCardStepModelModuleInfoListContentInfoTags?>? tags;
  List<StudyPlanCardStepModelModuleInfoListContentInfoPronunciations?>? pronunciations;
  CardContentDifficulty? difficulty;
  String? imageUrl;
  String? imageKey;
  String? phonetic;
  String? audioUrl;
  String? pos;
  String? posTitle;

  StudyPlanCardStepModelModuleInfoListContentInfo({
    this.contentType,
    this.contentTypeTitle,
    this.contentId,
    this.semanticId,
    this.content,
    this.definition,
    this.gloss,
    this.tags,
    this.pronunciations,
    this.difficulty,
    this.imageUrl,
    this.imageKey,
    this.phonetic,
    this.audioUrl,
    this.pos,
    this.posTitle,
  });
  StudyPlanCardStepModelModuleInfoListContentInfo.fromJson(Map<String, dynamic> json) {
    contentType = json['contentType']?.toString();
    contentTypeTitle = json['contentTypeTitle']?.toString();
    contentId = json['contentId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    content = json['content']?.toString();
    definition = json['definition']?.toString();
  if (json['gloss'] != null) {
  final v = json['gloss'];
  final arr0 = <LanguageText>[];
  v.forEach((v) {
  arr0.add(LanguageText.fromJson(v));
  });
    gloss = arr0;
    }
  if (json['tags'] != null) {
  final v = json['tags'];
  final arr0 = <StudyPlanCardStepModelModuleInfoListContentInfoTags>[];
  v.forEach((v) {
  arr0.add(StudyPlanCardStepModelModuleInfoListContentInfoTags.fromJson(v));
  });
    tags = arr0;
    }
  if (json['pronunciations'] != null) {
  final v = json['pronunciations'];
  final arr0 = <StudyPlanCardStepModelModuleInfoListContentInfoPronunciations>[];
  v.forEach((v) {
  arr0.add(StudyPlanCardStepModelModuleInfoListContentInfoPronunciations.fromJson(v));
  });
    pronunciations = arr0;
    }
    difficulty = (json['difficulty'] != null) ? CardContentDifficulty.fromJson(json['difficulty']) : null;
    imageUrl = json['imageUrl']?.toString();
    imageKey = json['imageKey']?.toString();
    phonetic = json['phonetic']?.toString();
    audioUrl = json['audioUrl']?.toString();
    pos = json['pos']?.toString();
    posTitle = json['posTitle']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['contentType'] = contentType;
    data['contentTypeTitle'] = contentTypeTitle;
    data['contentId'] = contentId;
    data['semanticId'] = semanticId;
    data['content'] = content;
    data['definition'] = definition;
    if (gloss != null) {
      final v = gloss;
      final arr0 = [];
  v!.forEach((v) {
  arr0.add(v!.toJson());
  });
      data['gloss'] = arr0;
    }
    if (tags != null) {
      final v = tags;
      final arr0 = [];
  v!.forEach((v) {
  arr0.add(v!.toJson());
  });
      data['tags'] = arr0;
    }
    if (pronunciations != null) {
      final v = pronunciations;
      final arr0 = [];
  v!.forEach((v) {
  arr0.add(v!.toJson());
  });
      data['pronunciations'] = arr0;
    }
    if (difficulty != null) {
      data['difficulty'] = difficulty!.toJson();
    }
    data['imageUrl'] = imageUrl;
    data['imageKey'] = imageKey;
    data['phonetic'] = phonetic;
    data['audioUrl'] = audioUrl;
    data['pos'] = pos;
    data['posTitle'] = posTitle;
    return data;
  }
}

class StudyPlanCardStepModelModuleInfoList {
/*
{
  "moduleId": 6161,
  "topic": "b",
  "contentInfo": {
    "contentType": "EN_WORD",
    "contentTypeTitle": "Word",
    "contentId": 106102,
    "semanticId": 666232,
    "content": "boss",
    "definition": "工作单位的管理者",
    "gloss": [
      {
        "lang": "zh",
        "text": "老板；上司"
      }
    ],
    "tags": [
      {
        "gloss": [
          {
            "lang": "en",
            "text": "n."
          }
        ],
        "style": [
          {
            "theme": "DARK",
            "color": "#FFFFFF",
            "fontsize": 16,
            "italic": false,
            "weight": 400,
            "backgroundColor": "rgba(59, 130, 246, 0.8)",
            "borderColor": "#3B82F6"
          }
        ]
      }
    ],
    "pronunciations": [
      {
        "phonetic": "bɔːs",
        "audioUrl": "https://track.timelywise.cn/knowledge/speech/0E44E4308731F1A30F4625B1E242FA59.mp3?auth_key=1781599406-wc8wzl08ese6-0-ffd5762f2e181247de3681e6155ea4bd",
        "duration": 1.49,
        "national": "US",
        "nationalTitle": "美音",
        "nationalIconUrl": "https://openpic.timelywise.cn/icon/style/locale/us.webp",
        "syllables": [
          {
            "ipa": "bɔːs",
            "graphemes": "boss",
            "variant": null,
            "positions": [
              0
            ],
            "audioUrl": "https://track.timelywise.cn/knowledge/speech/0E44E4308731F1A30F4625B1E242FA59.mp3?auth_key=1781599406-wc8wzl08ese6-0-ffd5762f2e181247de3681e6155ea4bd"
          }
        ],
        "phonetics": [
          {
            "ipa": "b",
            "graphemes": "b",
            "variant": null,
            "positions": [
              0
            ],
            "audioUrl": "https://track.timelywise.cn/img/jA3xYD3oTWTxaxyVsypuxYkZNP7bBUAyWxz4wor1uKAuwBej.mp3?auth_key=1781599406-vw2qkpbcru1m-0-4963cf56dafeae76d3c94676d6e1a34e"
          }
        ]
      }
    ],
    "difficulty": {
      "max": 2,
      "min": 2
    },
    "imageUrl": "https://img.timelywise.cn/knowledge/semantic/9C383449D643B0904D129D2C89CC4C2A.webp?auth_key=1781599406-9bhk3huq39rr-0-56e5983d786e358f567b702f0be63350",
    "imageKey": "knowledge/semantic/9C383449D643B0904D129D2C89CC4C2A.webp",
    "phonetic": "bɔːs",
    "audioUrl": "https://track.timelywise.cn/knowledge/speech/0E44E4308731F1A30F4625B1E242FA59.mp3?auth_key=1781599406-wc8wzl08ese6-0-ffd5762f2e181247de3681e6155ea4bd",
    "pos": "n.",
    "posTitle": "名词"
  }
} 
*/

  int? moduleId;
  String? topic;
  StudyPlanCardStepModelModuleInfoListContentInfo? contentInfo;

  StudyPlanCardStepModelModuleInfoList({
    this.moduleId,
    this.topic,
    this.contentInfo,
  });
  StudyPlanCardStepModelModuleInfoList.fromJson(Map<String, dynamic> json) {
    moduleId = json['moduleId']?.toInt();
    topic = json['topic']?.toString();
    contentInfo = (json['contentInfo'] != null) ? StudyPlanCardStepModelModuleInfoListContentInfo.fromJson(json['contentInfo']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['moduleId'] = moduleId;
    data['topic'] = topic;
    if (contentInfo != null) {
      data['contentInfo'] = contentInfo!.toJson();
    }
    return data;
  }
}
