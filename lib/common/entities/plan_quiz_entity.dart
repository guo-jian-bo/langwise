

import 'package:quiz_play/quiz_play.dart';

class PlanQuizEntityExercises {
/*
{
  "testType": "EXAM",
  "context": null,
  "exercise": {
    "uid": 219799,
    "type": "GRID_CONNECTION",
    "purpose": "LEARN",
    "contentList": [
      {
        "type": "EN_WORD",
        "uid": 104737,
        "semanticId": 663968
      }
    ],
    "stems": [
      {
        "text": "bathroom",
        "audioUrl": "http://track.timelywise.cn/knowledge/speech/B9823060366CA8A4BF0165F337024C39.mp3?auth_key=1754645609-b5k6vhc2wg2y-0-3f69da1fe9c4f7b8e0c5acd2287a22ce",
        "imageUrl": "http://img.timelywise.cn/knowledge/semantic/3E06B63DD198B10197734DADC20859B4.webp?auth_key=1754645609-jvjd5mv1hvha-0-5cb547f108e977a0825126808385b2ca",
        "imageKey": "knowledge/semantic/3E06B63DD198B10197734DADC20859B4.webp"
      }
    ],
    "config": {
      "uid": 1659,
      "stemDisplay": "IMAGE",
      "optionDisplay": "TEXT",
      "preTeaching": null,
      "stemAudio": true,
      "optionAudio": false,
      "questionAudio": null,
      "inputMode": null,
      "highlight": null,
      "followSentence": null,
      "breakdownLevel": null,
      "optionCount": null,
      "errorCount": null
    },
    "estimatedTime": 45
  },
  "learned": null,
  "duration": null
} 
*/

  String? testType;
  QuizModelContext? context;
  QuizModel? exercise;
  String? learned;
  int? duration;
  bool? isCurrent;

  PlanQuizEntityExercises({
    this.testType,
    this.context,
    this.exercise,
    this.learned,
    this.duration,
    this.isCurrent,
  });
  PlanQuizEntityExercises.fromJson(Map<String, dynamic> json) {
    testType = json['testType']?.toString();
    context = json['context'] != null
        ? QuizModelContext.fromJson(json['context'])
        : null;
    exercise = (json['exercise'] != null)
        ? QuizModel.fromJson(json['exercise'])
        : null;
    learned = json['learned']?.toString();
    duration = json['duration']?.toInt();
    isCurrent = json['isCurrent'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['testType'] = testType;
    if(context != null){
      data['context'] = context!.toJson();
    }
    if (exercise != null) {
      data['exercise'] = exercise!.toJson();
    }
    data['learned'] = learned;
    data['duration'] = duration;
    data['isCurrent'] = isCurrent;
    return data;
  }
}

class PlanQuizEntity {
/*
{
  "duration": 600,
  "exercises": [
    {
      "testType": "EXAM",
      "context": null,
      "exercise": {
        "uid": 219799,
        "type": "GRID_CONNECTION",
        "purpose": "LEARN",
        "contentList": [
          {
            "type": "EN_WORD",
            "uid": 104737,
            "semanticId": 663968
          }
        ],
        "stems": [
          {
            "text": "bathroom",
            "audioUrl": "http://track.timelywise.cn/knowledge/speech/B9823060366CA8A4BF0165F337024C39.mp3?auth_key=1754645609-b5k6vhc2wg2y-0-3f69da1fe9c4f7b8e0c5acd2287a22ce",
            "imageUrl": "http://img.timelywise.cn/knowledge/semantic/3E06B63DD198B10197734DADC20859B4.webp?auth_key=1754645609-jvjd5mv1hvha-0-5cb547f108e977a0825126808385b2ca",
            "imageKey": "knowledge/semantic/3E06B63DD198B10197734DADC20859B4.webp"
          }
        ],
        "config": {
          "uid": 1659,
          "stemDisplay": "IMAGE",
          "optionDisplay": "TEXT",
          "preTeaching": null,
          "stemAudio": true,
          "optionAudio": false,
          "questionAudio": null,
          "inputMode": null,
          "highlight": null,
          "followSentence": null,
          "breakdownLevel": null,
          "optionCount": null,
          "errorCount": null
        },
        "estimatedTime": 45
      },
      "learned": null,
      "duration": null
    }
  ]
} 
*/

  int? duration;
  List<PlanQuizEntityExercises?>? exercises;

  PlanQuizEntity({
    this.duration,
    this.exercises,
  });
  PlanQuizEntity.fromJson(Map<String, dynamic> json) {
    duration = json['duration']?.toInt();
    if (json['exercises'] != null) {
      final v = json['exercises'];
      final arr0 = <PlanQuizEntityExercises>[];
      v.forEach((v) {
        arr0.add(PlanQuizEntityExercises.fromJson(v));
      });
      exercises = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['duration'] = duration;
    if (exercises != null) {
      final v = exercises;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['exercises'] = arr0;
    }
    return data;
  }
}
