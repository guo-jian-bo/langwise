import 'package:quiz_play/models/models.dart';

class SpeakingQuizPayloadEntity {
  List<QuizModel> quizList;
  Map<int, Map<String, dynamic>> contextByExerciseId;

  SpeakingQuizPayloadEntity({
    List<QuizModel>? quizList,
    Map<int, Map<String, dynamic>>? contextByExerciseId,
  })  : quizList = quizList ?? <QuizModel>[],
        contextByExerciseId = contextByExerciseId ?? <int, Map<String, dynamic>>{};
}
