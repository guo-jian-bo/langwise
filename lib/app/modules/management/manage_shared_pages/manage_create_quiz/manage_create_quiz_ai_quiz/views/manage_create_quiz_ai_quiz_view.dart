import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/quiz_public_widget.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_create_quiz_ai_quiz_binding.dart';
import '../controllers/manage_create_quiz_ai_quiz_controller.dart';

class ManageCreateQuizAiQuizView extends GetView<ManageCreateQuizAiQuizController> {
  final String tagText;
  const ManageCreateQuizAiQuizView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CREATE_QUIZ_AI_QUIZ}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageCreateQuizAiQuizView(tagText: tag),
      binding: ManageCreateQuizAiQuizBinding(tag: tag),
      routeName: Routes.MANAGE_CREATE_QUIZ_AI_QUIZ,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: tagText,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: ManageScaffold(
            body: Padding(
              padding: EdgeInsets.only(top: 20.wMin, left: 20.wMin, right: 20.wMin, bottom: 60.wMin),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 600.wMin,
                    padding: EdgeInsets.all(10.wMin),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23283D),
                      borderRadius: BorderRadius.circular(12.wMin),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.77,
                      child: Stack(
                        children: [
                          TapScaleWidget(
                            onTap: () {
                              controller.toDemonstrate();
                            },
                            sclae: 1.03,
                            child: QuizPublicQuizWidget(
                              borderRadius: 12.wMin,
                              data: controller.aiQuizModel?.exerciseDTO,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ManageQuizSettingButtons(
                    onButton0: () {
                      Get.back();
                    },
                    button1Text: "放弃生成",
                    button1Color: const Color(0xff353E5C),
                    button1BorderColor: const Color(0xff353E5C),
                    onButton1: () {
                      controller.giveUp();
                    },
                    button2Text: "编辑",
                    onButton2: () {
                      controller.edit();
                    },
                    button3Text: "保存",
                    onButton3: () {
                      controller.confirm();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
