import 'package:quiz_play/quiz_play.dart';

class ZhenxieTaskExerciseEntity {
/*
{
  "unitId": 14193,
  "compositionId": 8,
  "lessonId": 53662,
  "list": [
    {
      "exerciseId": 1091516,
      "title": "篇章蓝图·局部",
      "description": "听读范文，判断标记处的句子或段落起什么作用（起承转合）。",
      "inputMode": "CHOICE",
      "inputModeLabel": "选择",
      "questionCount": 3,
      "access": "NORMAL",
      "order": 300.0
    }
  ]
}
*/

  /// 当前练习列表所属单元 id。
  int? unitId;

  /// 当前练习列表所属范文 compositionId。
  int? compositionId;

  /// 当前练习列表所属课时 id。
  int? lessonId;

  /// 当前范文挂载的练习列表。
  List<ZhenxieTaskExerciseItemEntity>? list;

  ZhenxieTaskExerciseEntity({
    this.unitId,
    this.compositionId,
    this.lessonId,
    this.list,
  });

  ZhenxieTaskExerciseEntity.fromJson(Map<String, dynamic> json) {
    unitId = json['unitId']?.toInt();
    compositionId = json['compositionId']?.toInt();
    lessonId = json['lessonId']?.toInt();
    if (json['list'] != null) {
      final v = json['list'];
      final arr0 = <ZhenxieTaskExerciseItemEntity>[];
      v.forEach((v) {
        arr0.add(ZhenxieTaskExerciseItemEntity.fromJson(v));
      });
      list = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['unitId'] = unitId;
    data['compositionId'] = compositionId;
    data['lessonId'] = lessonId;
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ZhenxieTaskExerciseItemEntity {
/*
{
  "context": {
    "courseId": 11797,
    "levelId": 142198,
    "moduleId": 33023,
    "unitId": 14193,
    "lessonId": 53662
  },
  "exercise": {
    "uid": 1091516
  },
  "title": "篇章蓝图·局部",
  "description": "听读范文，判断标记处的句子或段落起什么作用（起承转合）。",
  "inputMode": "CHOICE",
  "inputModeLabel": "选择",
  "order": 300.0
}
*/

  /// 练习标题。
  String? title;

  /// 练习描述。
  String? description;

  /// 练习作答模式编码。
  String? inputMode;

  /// 练习作答模式文案。
  String? inputModeLabel;

  /// 练习排序值。
  double? order;

  /// 练习上下文信息。
  QuizModelContext? context;

  /// 当前练习完整题目数据。
  QuizModel? exercise;

  ZhenxieTaskExerciseItemEntity({
    this.title,
    this.description,
    this.inputMode,
    this.inputModeLabel,
    this.order,
    this.context,
    this.exercise,
  });

  ZhenxieTaskExerciseItemEntity.fromJson(Map<String, dynamic> json) {
    title = json['title']?.toString();
    description = json['description']?.toString();
    inputMode = json['inputMode']?.toString();
    inputModeLabel = json['inputModeLabel']?.toString();
    order = json['order']?.toDouble();
    if (json['context'] != null) {
      context = QuizModelContext.fromJson(json['context']);
    }
    if (json['exercise'] != null) {
      exercise = QuizModel.fromJson(json['exercise']);
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['inputMode'] = inputMode;
    data['inputModeLabel'] = inputModeLabel;
    data['order'] = order;
    if (context != null) {
      data['context'] = context!.toJson();
    }
    if (exercise != null) {
      data['exercise'] = exercise!.toJson();
    }
    return data;
  }
}
