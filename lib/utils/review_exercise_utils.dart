import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/quiz_play.dart';

import '../app/routes/routes.dart';
import '../common/https/https.dart';

class ReviewExerciseUtils{
  
  static Future<void> toEval(String? contentType, int? contentId, String? national) async{

      if(contentType == null || contentId == null) return;

      try {
        ToastUtils.showLoading();

        List<QuizModel>? quizList = await ElementsRequest.getReviewExercise(contentType, contentId, national);
        if(quizList == null || quizList.isEmpty) {
          ToastUtils.showToast(text: "暂无数据");
          return;
        }
        
        await CacheManagerUtils.instance.cacheQuizAssetsFirstTwo(quizList);
        if(Get.isRegistered<ConfigController>()){
          await Get.find<ConfigController>().getThirdPartyAccount();
        }
        
        await Get.toNamed(
          Routes.PRACTICE_QUESTIONS,
          arguments: {
            "quizDatas": quizList,
            "questionIsReport": false,
            "isCollectCard": false,
            "national": national,
          },
        );

      } finally{
        ToastUtils.hideLoading();
      }

  }

}
