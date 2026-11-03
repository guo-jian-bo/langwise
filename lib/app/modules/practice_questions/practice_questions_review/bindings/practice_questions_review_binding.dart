import 'package:get/get.dart';

import '../../../management/controllers/manage_admin_auth_controller.dart';
import '../controllers/practice_questions_review_controller.dart';

class PracticeQuestionsReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PracticeQuestionsReviewController>(
      () => PracticeQuestionsReviewController(),
    );
    Get.lazyPut<ManageAuthController>(
      () => ManageAuthController(),
    );
  }
}
