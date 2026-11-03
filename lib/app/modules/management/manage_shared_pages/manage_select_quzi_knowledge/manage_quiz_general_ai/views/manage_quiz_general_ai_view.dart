import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_quiz_general_ai_binding.dart';
import '../controllers/manage_quiz_general_ai_controller.dart';

class ManageQuizGeneralAiView extends GetView<ManageQuizGeneralAiController> {
  final String tagText;
  const ManageQuizGeneralAiView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_QUIZ_GENERAL_AI}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageQuizGeneralAiView(tagText: tag),
      binding: ManageQuizGeneralAiBinding(tag: tag),
      routeName: Routes.MANAGE_QUIZ_GENERAL_AI,
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
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 24.wMin),
                Expanded(
                  child: Obx(() {
                    if (controller.resultState.value == -1) return Container();
                    if (controller.resultState.value == 1) {
                      return Center(
                        child: SvgPicture.asset(
                          "assets/svg/manage/icon_not_data.svg",
                          width: 200.wMin,
                        ),
                      );
                    }
                    return ManageQuizPublicQuizListWidget(
                      title: "选择方案",
                      datas: controller.quizList.toList(),
                      selectIndexs: controller.selectIndexs.toList(),
                      onTap: (index) {
                        controller.selectItemIndex(index);
                      },
                    );
                  }),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() {
                      if (controller.resultState.value == -1) return Container();
                      if (controller.resultState.value == 0) {
                        return ManageQuizSettingButtons(
                          onButton0: () {
                            Get.back();
                          },
                          button1Text: "放弃生成",
                          button1Color: const Color(0xff353E5C),
                          button1BorderColor: const Color(0xff353E5C),
                          onButton1: () {
                            controller.giveUp();
                          },
                          button2Text: "重新生成",
                          onButton2: () {
                            controller.reGenerate();
                          },
                          button3Text: "体验${controller.selectIndexs.length}道题",
                          onButton3: () {
                            controller.toDemonstrate();
                          },
                          button4Text: "保存",
                          onButton4: () {
                            controller.addQuiz();
                          },
                        );
                      }
                      return ManageQuizSettingButtons(
                        onButton0: () {
                          Get.back();
                        },
                        button2Text: "放弃生成",
                        onButton2: () {
                          controller.giveUp();
                        },
                        button3Text: "重新生成",
                        onButton3: () {
                          controller.reGenerate();
                        },
                      );
                    }),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
