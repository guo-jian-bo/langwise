import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_title_check_text_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/common/widgets/button_widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_create_quiz_listen_find_word_binding.dart';
import '../controllers/manage_create_quiz_listen_find_word_controller.dart';

class ManageCreateQuizListenFindWordView extends GetView<ManageCreateQuizListenFindWordController> {
  final String tagText;
  const ManageCreateQuizListenFindWordView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CREATE_QUIZ_LISTEN_FIND_WORD}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageCreateQuizListenFindWordView(tagText: tag),
      binding: ManageCreateQuizListenFindWordBinding(tag: tag),
      routeName: Routes.MANAGE_CREATE_QUIZ_LISTEN_FIND_WORD,
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
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 24.wMin, top: 24.wMin),
                    child: Text(
                      "手动创建",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: const Color(0xffACB4C0),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Container(
                    key: controller.dialogKey,
                    margin: EdgeInsets.all(24.wMin),
                    padding: EdgeInsets.all(16.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.wMin),
                      color: const Color(0xff22293C),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ManageTitleCheckTextWidget(
                          title: "题目",
                          textList: controller.wordTextList,
                          error: controller.answerErr,
                          onTap: (index) => controller.selectItem(index, context),
                        ),
                        SizedBox(height: 24.wMin),
                        Row(
                          children: [
                            Text(
                              "选项",
                              style: TextStyle(
                                fontSize: 16.wMin,
                                color: const Color(0xffACB4C0),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Expanded(
                              child: Container(height: 0.5.wMin, color: Colors.white.withValues(alpha: 0.4)),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.wMin),
                        ManageTitleInput1Widget(
                          title: "位置",
                          subTitle: "正确答案",
                          enabled: false,
                          error: controller.answerErr,
                          controller: controller.answerController,
                          inputFontColor: const Color(0xffFF781F),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.wMin),
                  Row(
                    children: [
                      const Spacer(),
                      ButtonWidget(
                        text: "取消",
                        fontColor: const Color(0xffEBEFF5),
                        color: Colors.transparent,
                        border: Border.all(width: 2.wMin, color: const Color(0xff353E5C)),
                        fontSize: 18.wMin,
                        width: 100.wMin,
                        height: 45.wMin,
                        borderRadius: 4.wMin,
                        sclae: 1.05,
                        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                        onTap: () {
                          Get.back();
                        },
                      ),
                      SizedBox(width: 12.wMin),
                      ButtonWidget(
                        text: "创建",
                        fontColor: const Color(0xffEBEFF5),
                        fontSize: 18.wMin,
                        color: const Color(0xff2388FF),
                        width: 100.wMin,
                        height: 45.wMin,
                        borderRadius: 4.wMin,
                        sclae: 1.05,
                        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                        onTap: () {
                          controller.createQuiz();
                        },
                      ),
                      SizedBox(width: 24.wMin),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
