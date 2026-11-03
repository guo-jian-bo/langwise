import 'dart:async';

import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../common/https/https.dart';
import 'listen_and_read_controller.dart';

class ListenAndReadPracticeController extends GetxController{

  final ListenAndReadController listenAndReadController = Get.find<ListenAndReadController>();

  final RxList<QuizModel> quizDatas= <QuizModel>[].obs;

  StreamController<QuizStateType>? stateController = StreamController<QuizStateType>.broadcast();

  final RxInt currentQuizIndex = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    getQuizData();
  }

  Future<void> getQuizData() async {
    try {
      ToastUtils.showLoading();
      List<int?>? exerciseIds = listenAndReadController.currentSong?.exerciseIds;
      if(exerciseIds == null || exerciseIds.isEmpty) return;
      List<int> ids = [];
      for(int? id in exerciseIds){
        if(id == null) continue;
        ids.add(id);
      }

      List<QuizModel>? quizList = await HomeRequest.getQuizListByIds(ids);
      if(quizList == null || quizList.isEmpty) return;

      quizDatas.value = quizList;

    } finally{
      ToastUtils.hideLoading();
    }
  }

  Future<void> nextQuiz() async {
    if(currentQuizIndex.value >= quizDatas.length - 1) {
      ToastUtils.showToast(text: "练习已完成", type: ToastType.success);
      return;
    }
    currentQuizIndex.value++;
  }


}