import 'package:quiz_play/quiz_play.dart';

import 'zhendu_detil_entity.dart';

class ContentExerciseDetailEntity {
  List<QuizModel> quizList;
  List<ZhenduLearnItems> learnItems;

  ContentExerciseDetailEntity({
    this.quizList = const <QuizModel>[],
    this.learnItems = const <ZhenduLearnItems>[],
  });

  factory ContentExerciseDetailEntity.fromJson(Map<String, dynamic> json) {
    final quizList = <QuizModel>[];
    final learnItems = <ZhenduLearnItems>[];
    final list = json['list'];
    if (list is List) {
      for (final item in list) {
        if (item is! Map) continue;

        dynamic exercisePayload = item;
        if (item['exercise'] != null) {
          exercisePayload = item['exercise'];
        }
        if (exercisePayload is Map<String, dynamic>) {
          quizList.add(QuizModel.fromJson(exercisePayload));
        } else if (exercisePayload is Map) {
          quizList.add(QuizModel.fromJson(Map<String, dynamic>.from(exercisePayload)));
        }

        if (learnItems.isNotEmpty) continue;
        final rawLearnItems = item['learnItems'];
        if (rawLearnItems is! List) continue;
        for (final learnItem in rawLearnItems) {
          if (learnItem is Map<String, dynamic>) {
            learnItems.add(ZhenduLearnItems.fromJson(learnItem));
          } else if (learnItem is Map) {
            learnItems.add(ZhenduLearnItems.fromJson(Map<String, dynamic>.from(learnItem)));
          }
        }
      }
    }
    return ContentExerciseDetailEntity(
      quizList: quizList,
      learnItems: learnItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': quizList.map((item) => item.toJson()).toList(),
      'learnItems': learnItems.map((item) => item.toJson()).toList(),
    };
  }
}
