import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../../routes/routes.dart';
import '../../../../../common/commons.dart';
import '../bindings/manage_quiz_label_picture_prview_binding.dart';
import '../controllers/manage_quiz_label_picture_prview_controller.dart';

class ManageQuizLabelPicturePrviewView extends GetView<ManageQuizLabelPicturePrviewController> {
  final String tagText;
  const ManageQuizLabelPicturePrviewView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_QUIZ_LABEL_PICTURE_PRVIEW}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageQuizLabelPicturePrviewView(tagText: tag),
      binding: ManageQuizLabelPicturePrviewBinding(tag: tag),
      routeName: Routes.MANAGE_QUIZ_LABEL_PICTURE_PRVIEW,
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
              child: Obx(() {
                return ManageQuizPublicQuizListWidget(
                  datas: controller.quizList.toList(),
                );
              }),
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
                  button3Text: "保存",
                  onButton3: () {
                    controller.addQuiz();
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
