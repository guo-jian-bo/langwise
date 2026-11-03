
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/third_party_account_entity.dart';
import '../../practice_questions/common/practice_questions_quiz_widget.dart';
import '../controllers/listen_and_read_practice_controller.dart';

class ListenAndReadPracticeView extends GetView<ListenAndReadPracticeController> {
  /// 练习
  const ListenAndReadPracticeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx((){
      if(controller.listenAndReadController.titleNavIndex.value != 2) return Container();
      if(controller.quizDatas.isEmpty) return Container();
      double topPadding = 110.wMin + MediaQuery.of(context).padding.top;
      return Container(
        margin: EdgeInsets.only(top: topPadding),
        child: PracticeQuestionsQuizWidget(
          data: controller.quizDatas[controller.currentQuizIndex.value],
          letters: const [],
          stateController: controller.stateController,
          endPractice: false,
          soundAccount: ThirdPartyAccountEntityList(),
          playSpeed: controller.listenAndReadController.playbackRate.value,
          listener: QuizPlayListener(
            onFinish: (log) {
              controller.nextQuiz();
            },
          ),
        ),
      );
    });
  }
}