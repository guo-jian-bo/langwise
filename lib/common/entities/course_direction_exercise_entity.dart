import 'package:quiz_play/models/models.dart';

import 'entities.dart';

class CourseDirectionExerciseEntityExerciseCategoryListExerciseList {
/*
{
  "name": "声部烙刻",
  "exerciseType": "SOUND_BLOCKS",
  "brief": "点击或拖拽发音单元积木，按正确顺序组合出单词的发音和拼写。",
  "required": false,
  "requiredBrief": null,
  "exercise": {
    "uid": 29,
    "type": "SOUND_BLOCKS",
    "purpose": "PRACTICE",
    "stems": [
      {
        "text": "record",
        "altText": "rɪˈkɔːrd",
        "audioUrl": "https://track.timelywise.cn/knowledge/en/pron/iyTlQZK7G1FCV2YPXPrsUt35sLr69WgfANmuC6bjTiVW4rIk.mp3?auth_key=1781688487-6xlslj0b6yy2-0-4d7dd28a63e72d936fbe1be3d366f7c3",
        "imageUrl": "https://img.timelywise.cn/knowledge/semantic/ecKqIyBZwUTMBdrs4e6q8Uv0xviy7s7CbQK9igVBKMUKihtk.webp?auth_key=1781688487-yf637zd2jp1t-0-e520f954241cea64992adf05503577b7"
      }
    ],
    "options": [
      {
        "text": "re",
        "altText": "rɪ",
        "audioUrl": "https://track.timelywise.cn/knowledge/speech/10EC11410CE67B8F48EE92D0C7D5E438.mp3?auth_key=1781688487-dr91rrgnlg56-0-1ab1bf7709e884dd611d30f595e3f363",
        "positions": [
          0
        ]
      }
    ],
    "config": {
      "uid": null,
      "stemDisplay": "IMAGE_TEXT",
      "optionDisplay": "TEXT",
      "preTeaching": null,
      "stemAudio": true,
      "optionAudio": true,
      "questionAudio": null,
      "inputMode": null,
      "highlight": null,
      "followSentence": null,
      "breakdownLevel": "SYLLABLE",
      "optionCount": null,
      "errorCount": null
    }
  }
} 
*/

  String? name;
  String? exerciseType;
  String? brief;
  bool? required;
  List<String?>? requiredBriefs;
  List<String?>? requiredLessons;
  QuizModel? exercise;

  CourseDirectionExerciseEntityExerciseCategoryListExerciseList({
    this.name,
    this.exerciseType,
    this.brief,
    this.required,
    this.requiredBriefs,
    this.requiredLessons,
    this.exercise,
  });
  CourseDirectionExerciseEntityExerciseCategoryListExerciseList.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    exerciseType = json['exerciseType']?.toString();
    brief = json['brief']?.toString();
    required = json['required'];
    if (json['requiredBriefs'] != null) {
      final v = json['requiredBriefs'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      requiredBriefs = arr0;
    }
    if (json['requiredLessons'] != null) {
      final v = json['requiredLessons'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      requiredLessons = arr0;
    }

    exercise = (json['exercise'] != null) ? QuizModel.fromJson(json['exercise']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['exerciseType'] = exerciseType;
    data['brief'] = brief;
    data['required'] = required;
    if (requiredBriefs != null) {
      final v = requiredBriefs;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['requiredBriefs'] = arr0;
    }
    if (requiredLessons != null) {
      final v = requiredLessons;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
    }
    if (exercise != null) {
      data['exercise'] = exercise!.toJson();
    }
    return data;
  }
}

class CourseDirectionExerciseEntityExerciseCategoryList {
/*
{
  "category": "listening_speaking",
  "title": "听口",
  "exerciseList": [
    {
      "name": "声部烙刻",
      "exerciseType": "SOUND_BLOCKS",
      "brief": "点击或拖拽发音单元积木，按正确顺序组合出单词的发音和拼写。",
      "required": false,
      "requiredBrief": null,
      "exercise": {
        "uid": 29,
        "type": "SOUND_BLOCKS",
        "purpose": "PRACTICE",
        "stems": [
          {
            "text": "record",
            "altText": "rɪˈkɔːrd",
            "audioUrl": "https://track.timelywise.cn/knowledge/en/pron/iyTlQZK7G1FCV2YPXPrsUt35sLr69WgfANmuC6bjTiVW4rIk.mp3?auth_key=1781688487-6xlslj0b6yy2-0-4d7dd28a63e72d936fbe1be3d366f7c3",
            "imageUrl": "https://img.timelywise.cn/knowledge/semantic/ecKqIyBZwUTMBdrs4e6q8Uv0xviy7s7CbQK9igVBKMUKihtk.webp?auth_key=1781688487-yf637zd2jp1t-0-e520f954241cea64992adf05503577b7"
          }
        ],
        "options": [
          {
            "text": "re",
            "altText": "rɪ",
            "audioUrl": "https://track.timelywise.cn/knowledge/speech/10EC11410CE67B8F48EE92D0C7D5E438.mp3?auth_key=1781688487-dr91rrgnlg56-0-1ab1bf7709e884dd611d30f595e3f363",
            "positions": [
              0
            ]
          }
        ],
        "config": {
          "uid": null,
          "stemDisplay": "IMAGE_TEXT",
          "optionDisplay": "TEXT",
          "preTeaching": null,
          "stemAudio": true,
          "optionAudio": true,
          "questionAudio": null,
          "inputMode": null,
          "highlight": null,
          "followSentence": null,
          "breakdownLevel": "SYLLABLE",
          "optionCount": null,
          "errorCount": null
        }
      }
    }
  ]
} 
*/

  String? category;
  String? title;
  List<CourseDirectionExerciseEntityExerciseCategoryListExerciseList?>? exerciseList;

  CourseDirectionExerciseEntityExerciseCategoryList({
    this.category,
    this.title,
    this.exerciseList,
  });
  CourseDirectionExerciseEntityExerciseCategoryList.fromJson(Map<String, dynamic> json) {
    category = json['category']?.toString();
    title = json['title']?.toString();
    if (json['exerciseList'] != null) {
      final v = json['exerciseList'];
      final arr0 = <CourseDirectionExerciseEntityExerciseCategoryListExerciseList>[];
      v.forEach((v) {
        arr0.add(CourseDirectionExerciseEntityExerciseCategoryListExerciseList.fromJson(v));
      });
      exerciseList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['category'] = category;
    data['title'] = title;
    if (exerciseList != null) {
      final v = exerciseList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['exerciseList'] = arr0;
    }
    return data;
  }
}

class CourseDirectionExerciseEntity {
/*
{
  "description": "这里设置的是整个计划的全局题型开关。点击「禁用」后，会对当前计划内所有课时统一生效；如果某个已启用题型对所选课时为必选，则会自动锁定不可禁用。",
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
      "exclude": null
    }
  ],
  "exerciseCategoryList": [
    {
      "category": "listening_speaking",
      "title": "听口",
      "exerciseList": [
        {
          "name": "声部烙刻",
          "exerciseType": "SOUND_BLOCKS",
          "brief": "点击或拖拽发音单元积木，按正确顺序组合出单词的发音和拼写。",
          "required": false,
          "requiredBrief": null,
          "exercise": {
            "uid": 29,
            "type": "SOUND_BLOCKS",
            "purpose": "PRACTICE",
            "stems": [
              {
                "text": "record",
                "altText": "rɪˈkɔːrd",
                "audioUrl": "https://track.timelywise.cn/knowledge/en/pron/iyTlQZK7G1FCV2YPXPrsUt35sLr69WgfANmuC6bjTiVW4rIk.mp3?auth_key=1781688487-6xlslj0b6yy2-0-4d7dd28a63e72d936fbe1be3d366f7c3",
                "imageUrl": "https://img.timelywise.cn/knowledge/semantic/ecKqIyBZwUTMBdrs4e6q8Uv0xviy7s7CbQK9igVBKMUKihtk.webp?auth_key=1781688487-yf637zd2jp1t-0-e520f954241cea64992adf05503577b7"
              }
            ],
            "options": [
              {
                "text": "re",
                "altText": "rɪ",
                "audioUrl": "https://track.timelywise.cn/knowledge/speech/10EC11410CE67B8F48EE92D0C7D5E438.mp3?auth_key=1781688487-dr91rrgnlg56-0-1ab1bf7709e884dd611d30f595e3f363",
                "positions": [
                  0
                ]
              }
            ],
            "config": {
              "uid": null,
              "stemDisplay": "IMAGE_TEXT",
              "optionDisplay": "TEXT",
              "preTeaching": null,
              "stemAudio": true,
              "optionAudio": true,
              "questionAudio": null,
              "inputMode": null,
              "highlight": null,
              "followSentence": null,
              "breakdownLevel": "SYLLABLE",
              "optionCount": null,
              "errorCount": null
            }
          }
        }
      ]
    }
  ]
} 
*/

  String? description;
  List<LessonTypeEntityList?>? directionList;
  List<CourseDirectionExerciseEntityExerciseCategoryList?>? exerciseCategoryList;

  CourseDirectionExerciseEntity({
    this.description,
    this.directionList,
    this.exerciseCategoryList,
  });
  CourseDirectionExerciseEntity.fromJson(Map<String, dynamic> json) {
    description = json['description']?.toString();
    if (json['directionList'] != null) {
      final v = json['directionList'];
      final arr0 = <LessonTypeEntityList>[];
      v.forEach((v) {
        arr0.add(LessonTypeEntityList.fromJson(v));
      });
      directionList = arr0;
    }
    if (json['exerciseCategoryList'] != null) {
      final v = json['exerciseCategoryList'];
      final arr0 = <CourseDirectionExerciseEntityExerciseCategoryList>[];
      v.forEach((v) {
        arr0.add(CourseDirectionExerciseEntityExerciseCategoryList.fromJson(v));
      });
      exerciseCategoryList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['description'] = description;
    if (directionList != null) {
      final v = directionList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['directionList'] = arr0;
    }
    if (exerciseCategoryList != null) {
      final v = exerciseCategoryList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['exerciseCategoryList'] = arr0;
    }
    return data;
  }
}
