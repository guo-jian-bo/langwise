import 'package:quiz_play/quiz_play.dart';


class TodayTaskInfoEntity {
/*
{
  "exerciseId": 0,
  "status": "",
  "exercises": [
    QuizModel
  ]
} 
*/

  int? exerciseId;
  String? status;
  List<TodayTaskInfoEntityExercise?>? exercises;

  /// 还没有开始学习
  bool get notYetLearned => status == "UNLEARNED" || status == null;

  /// 已经学习完成
  bool get learned => status == "LEARNED";

  /// 正在学习
  bool get learning => status == "LEARNING";

  TodayTaskInfoEntity({
    this.exerciseId,
    this.status,
    this.exercises,
  });
  TodayTaskInfoEntity.fromJson(Map<String, dynamic> json) {
    exerciseId = json['exerciseId']?.toInt();
    status = json['status']?.toString();
    if (json['exercises'] != null) {
      final v = json['exercises'];
      final arr0 = <TodayTaskInfoEntityExercise>[];
      v.forEach((v) {
        arr0.add(TodayTaskInfoEntityExercise.fromJson(v));
      });
      exercises = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['exerciseId'] = exerciseId;
    data['status'] = status;
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


class TodayTaskInfoEntityExercise{
  QuizModelContext? context;
  String? testType;
  QuizModel? exercise;
  bool? learned;

  TodayTaskInfoEntityExercise({
    this.context,
    this.testType,
    this.exercise,
    this.learned,
  });

  TodayTaskInfoEntityExercise.fromJson(Map<String, dynamic> json) {
    if(json['context'] != null){
      context = QuizModelContext.fromJson(json['context']);
    }
    if(json['exercise'] != null){
      exercise = QuizModel.fromJson(json['exercise']);
    }
    learned = json['learned'];
    testType = json['testType']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['context'] = context?.toJson();
    data['exercise'] = exercise?.toJson();
    data['learned'] = learned;
    data['testType'] = testType;
    return data;
  }
}