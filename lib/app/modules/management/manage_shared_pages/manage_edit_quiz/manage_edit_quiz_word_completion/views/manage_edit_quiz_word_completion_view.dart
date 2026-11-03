import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_title_check_text_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/common/widgets/button_widgets.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_edit_quiz_word_completion_binding.dart';
import '../controllers/manage_edit_quiz_word_completion_controller.dart';

class ManageEditQuizWordCompletionView extends GetView<ManageEditQuizWordCompletionController> {
  final String tagText;
  const ManageEditQuizWordCompletionView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_EDIT_QUIZ_WORD_COMPLETION}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageEditQuizWordCompletionView(tagText: tag),
      binding: ManageEditQuizWordCompletionBinding(tag: tag),
      routeName: Routes.MANAGE_EDIT_QUIZ_WORD_COMPLETION,
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
                    "题目编辑",
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
                        error: controller.answerErr,
                        textList: controller.wordTextList,
                        onTap: controller.selectItem,
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
                        error: controller.answerErr,
                        enabled: false,
                        controller: controller.answerController,
                        inputFontColor: const Color(0xffFF781F),
                      ),
                      SizedBox(height: 24.wMin),
                      FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: Wrap(
                          spacing: 12.wMin,
                          runSpacing: 12.wMin,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: List.generate(controller.optionList.length, (int index) {
                            return SizedBox(
                              width: 324.6.wMin,
                              child: ManageTitleInput1Widget(
                                title: index == 0 ? "设置选项" : null,
                                controller: controller.optionList[index],
                                error: controller.optionErr[index],
                                focusOrder: index.toDouble(),
                                subTitle: "选项",
                                showDelIcon: controller.optionList.length > controller.minOption,
                                onDel: () {
                                  controller.optionList.removeAt(index);
                                  controller.update();
                                },
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: 24.wMin),
                      TapScaleWidget(
                        onTap: () {
                          if (controller.optionList.length + 1 > controller.maxOption - 1) {
                            ToastUtils.showManageToast(text: "最多只能添加${controller.maxOption - 1}个选项");
                            return;
                          }
                          controller.optionList.add(TextEditingController());
                          controller.update();
                        },
                        sclae: 1.01,
                        child: DottedBorder(
                          radius: Radius.circular(8.wMin),
                          borderType: BorderType.RRect,
                          padding: EdgeInsets.zero,
                          color: const Color(0xff4B5268),
                          dashPattern: [3.wMin, 3.wMin],
                          strokeWidth: 1.wMin,
                          child: Container(
                            height: 56.wMin,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/svg/manage/icon_add.svg",
                                  height: 22.wMin,
                                ),
                                Text(
                                  "添加选项",
                                  style: TextStyle(
                                    fontSize: 16.wMin,
                                    color: const Color(0xffEAECFF),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                      text: "题型演示",
                      fontColor: const Color(0xffEBEFF5),
                      fontSize: 18.wMin,
                      color: const Color(0xFF353E5C),
                      width: 120.wMin,
                      height: 45.wMin,
                      borderRadius: 4.wMin,
                      sclae: 1.05,
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                      onTap: () {
                        controller.showQuizEditResult();
                      },
                    ),
                    SizedBox(width: 12.wMin),
                    ButtonWidget(
                      text: "保存",
                      fontColor: const Color(0xffEBEFF5),
                      fontSize: 18.wMin,
                      color: const Color(0xff2388FF),
                      width: 100.wMin,
                      height: 45.wMin,
                      borderRadius: 4.wMin,
                      sclae: 1.05,
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                      onTap: () {
                        controller.saveQuiz();
                      },
                    ),
                    SizedBox(width: 24.wMin),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
