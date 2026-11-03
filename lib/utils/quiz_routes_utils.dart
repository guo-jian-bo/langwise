import 'package:quiz_play/utils/utils.dart';

import '../app/routes/routes.dart';

class QuizRoutesUtils {
  /// 根据题目类型 返回 相应的 编辑题目页面路由
  static String? getEditQuizRouteNameByContentType(String? type) {
    switch (type) {
      case ExerciseType.CLOZE_TEST:
        return Routes.MANAGE_EDIT_QUIZ_CLOZE_TEST_A;
      case ExerciseType.CLOZE_TEST_B:
        return Routes.MANAGE_EDIT_QUIZ_CLOZE_TEST_B;
      case ExerciseType.CONTEXT_CHOICE:
        return Routes.MANAGE_EDIT_QUIZ_SCENARIO_SELECTION_A;
      case ExerciseType.CONTEXT_CHOICE_B:
        return Routes.MANAGE_EDIT_QUIZ_SCENARIO_SELECTION_B;
      case ExerciseType.WORD_COMPLETION:
        return Routes.MANAGE_EDIT_QUIZ_WORD_COMPLETION;
      case ExerciseType.LISTEN_FIND_WORD:
        return Routes.MANAGE_EDIT_QUIZ_LISTEN_FIND_WORD;
      case ExerciseType.LABEL_PICTURE:
        return Routes.MANAGE_EDIT_QUIZ_LABEL_PICTURE;
      case ExerciseType.CROSS_WORD:
        return Routes.MANAGE_EDIT_QUIZ_CROSS_WORD;
      case ExerciseType.CLASSIFY_CHALLENGE:
        return Routes.MANAGE_EDIT_QUIZ_CLASSIFY_CHALLENGE;
      case ExerciseType.SENTENCE_CLOZE:
        return Routes.MANAGE_EDIT_QUIZ_SENTENCE_CLOZE;
      case ExerciseType.CONTRAST_CLOZE:
        return Routes.MANAGE_EDIT_QUIZ_CONTRAST_CLOZE;
      default:
        return null;
    }
  }
}
