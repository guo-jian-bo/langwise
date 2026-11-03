import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_quiz_immersive_chain_binding.dart';
import '../controllers/manage_quiz_immersive_chain_controller.dart';

class ManageQuizImmersiveChainView extends GetView<ManageQuizImmersiveChainController> {
  final String tagText;
  const ManageQuizImmersiveChainView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_QUIZ_IMMERSIVE_CHAIN}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageQuizImmersiveChainView(tagText: tag),
      binding: ManageQuizImmersiveChainBinding(tag: tag),
      routeName: Routes.MANAGE_QUIZ_IMMERSIVE_CHAIN,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.only(
          top: 20.wh,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    return ManageQuizPublicQuizListWidget(
                      datas: controller.showQuizList.toList(),
                    );
                  }),
                  SizedBox(height: 24.wMin),
                  Obx(() {
                    return Row(
                      spacing: 24.wMin,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 488.wMin,
                          child: ManageQuizStettingRotationWidget(
                            title: "场景轮换次数",
                            maxNumber: controller.quizList.length,
                            minNumber: 1,
                            value: controller.rotationNumber.value,
                            onchange: (value) {
                              controller.changeRotationNumber(value);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 488.wMin,
                          child: ManageQuizStettingRowBoxWidget(
                            title: "总题目数",
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                              child: Text(
                                "${controller.showQuizList.length}",
                                style: TextStyle(
                                  fontSize: 22.wMin,
                                  color: const Color(0xffEDF0F4),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ManageQuizSettingButtons(
                  onButton0: () {
                    Get.back();
                  },
                  button1Text: "体验本题",
                  onButton1: () {
                    controller.toDemonstrate();
                  },
                  onButton2: () {
                    controller.addQuiz();
                  },
                  onButton3: () {
                    controller.addQuiz(true);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
