import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_quiz_cloze_test_binding.dart';
import '../controllers/manage_quiz_cloze_test_controller.dart';

class ManageQuizClozeTestView extends GetView<ManageQuizClozeTestController> {
  final String tagText;
  const ManageQuizClozeTestView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_QUIZ_CLOZE_TEST}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageQuizClozeTestView(tagText: tag),
      binding: ManageQuizClozeTestBinding(tag: tag),
      routeName: Routes.MANAGE_QUIZ_CLOZE_TEST,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildTypeItem(int index, String name, String tip, {bool isAi = true}) {
      return Obx(() {
        return ManageQuizAiCardWidget(
          onTap: () => controller.selectCreateType(index),
          isSelect: controller.selectCreateTypeIndex.value == index,
          width: 270.wMin,
          name: name,
          tip: tip,
          isAi: isAi,
        );
      });
    }

    Widget buildTypeWidget() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            child: Text(
              "新建题目",
              style: TextStyle(
                fontSize: 22.wMin,
                color: const Color(0xffEBEFF5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
            child: IntrinsicHeight(
              child: Obx(() {
                return Row(
                  spacing: 24.wMin,
                  children: List.generate(controller.createTypeList.length, (index) {
                    return buildTypeItem(
                      index,
                      controller.createTypeList[index].name ?? "",
                      controller.createTypeList[index].description ?? "",
                      isAi: controller.createTypeList[index].ai ?? false,
                    );
                  }),
                );
              }),
            ),
          ),
        ],
      );
    }

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
                SizedBox(height: 48.wMin),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        return ManageQuizPublicQuizListWidget(
                          datas: controller.quizList.toList(),
                          isRadio: true,
                          hideOneBig: true,
                          title: "从已有题目中选择",
                          selectIndexs: [controller.selectQuizIndex.value],
                          onTap: (index) => controller.selectQuiz(index),
                        );
                      }),
                      SizedBox(height: 24.wMin),
                      buildTypeWidget(),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ManageQuizSettingButtons(
                      button1Text: "取消",
                      onButton1: () {
                        Get.back();
                      },
                      button2Text: "下一步",
                      onButton2: () {
                        controller.nextButton(context);
                      },
                    ),
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
