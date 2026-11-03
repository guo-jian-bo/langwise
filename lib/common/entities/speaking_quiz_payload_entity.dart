import 'package:quiz_play/models/models.dart';

class SpeakingQuizPayloadEntity {
  List<QuizModel> quizList;

  SpeakingQuizPayloadEntity({
    List<QuizModel>? quizList,
  })  : quizList = quizList ?? <QuizModel>[];
}
