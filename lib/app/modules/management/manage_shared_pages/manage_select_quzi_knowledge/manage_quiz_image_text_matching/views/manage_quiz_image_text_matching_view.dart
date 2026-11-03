import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_quiz_image_text_matching_binding.dart';
import '../controllers/manage_quiz_image_text_matching_controller.dart';

class ManageQuizImageTextMatchingView extends GetView<ManageQuizImageTextMatchingController> {
  final String tagText;
  const ManageQuizImageTextMatchingView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_QUIZ_IMAGE_TEXT_MATCHING}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageQuizImageTextMatchingView(tagText: tag),
      binding: ManageQuizImageTextMatchingBinding(tag: tag),
      routeName: Routes.MANAGE_QUIZ_IMAGE_TEXT_MATCHING,
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
                    int length = controller.unitKnowledgeList?.length ?? 4;
                    int errCount = controller.errorCountNumber.value;
                    int result = length + errCount * length;
                    return Row(
                      spacing: 24.wMin,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 488.wMin,
                          child: ManageQuizStettingRotationWidget(
                            title: "错误题目轮数",
                            maxNumber: length,
                            minNumber: 0,
                            value: errCount,
                            onchange: (value) {
                              controller.changeErrorCount(value);
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
                                "$length+${errCount}x$length=$result",
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
