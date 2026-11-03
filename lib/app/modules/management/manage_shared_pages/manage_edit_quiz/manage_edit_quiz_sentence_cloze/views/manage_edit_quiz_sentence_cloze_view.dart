import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_title_check_text_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/app/modules/management/dialog/manage_quiz_contrast_cloze_manual_dialog.dart';
import 'package:langwise/common/widgets/button_widgets.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:reorderables/reorderables.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_edit_quiz_sentence_cloze_binding.dart';
import '../controllers/manage_edit_quiz_sentence_cloze_controller.dart';

class ManageEditQuizSentenceClozeView extends GetView<ManageEditQuizSentenceClozeController> {
  final String tagText;
  const ManageEditQuizSentenceClozeView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_EDIT_QUIZ_SENTENCE_CLOZE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageEditQuizSentenceClozeView(tagText: tag),
      binding: ManageEditQuizSentenceClozeBinding(tag: tag),
      routeName: Routes.MANAGE_EDIT_QUIZ_SENTENCE_CLOZE,
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
                SizedBox(height: 20.wMin),
                Container(
                  key: controller.dialogKey,
                  height: 800.wMin,
                  margin: EdgeInsets.symmetric(horizontal: 24.wMin),
                  padding: EdgeInsets.all(16.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: const Color(0xff22293C),
                  ),
                  child: Column(
                    spacing: 24.wMin,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...List.generate(
                        controller.wordsTextList.length,
                        (listIndex) {
                          return IgnorePointer(
                            ignoring: controller.takeTurns != listIndex,
                            child: GestureDetector(
                              child: ManageTitleCheckTextWidget(
                                title: listIndex == 0 ? "题目" : null,
                                textList: controller.wordsTextList[listIndex],
                                isFocus: controller.takeTurns == listIndex,
                                onTap: (index) => controller.selectItem(index, controller.wordsTextList[listIndex], context),
                              ),
                            ),
                          );
                        },
                      ),
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
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ReorderableColumn(
                                buildDraggableFeedback: (context, constraints, child) {
                                  return Transform.scale(
                                    scale: 1.02,
                                    child: Container(
                                      constraints: constraints,
                                      child: child,
                                    ),
                                  );
                                },
                                onReorder: (oldIndex, newIndex) {
                                  List<ContrastClozeData> row = controller.optionsList.removeAt(oldIndex);
                                  controller.optionsList.insert(newIndex, row);
                                  controller.update();
                                },
                                children: List.generate(controller.optionsList.length, (index) {
                                  return Container(
                                    key: Key(index.toString()),
                                    margin: EdgeInsets.only(bottom: 16.wMin),
                                    child: buildOptionWidget(index, context),
                                  );
                                }),
                              ),
                              buildDistractorWidget(),
                            ],
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildDistractorWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.wMin),
        Visibility(
          visible: controller.distractorList.isNotEmpty,
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Wrap(
              spacing: 12.wMin,
              runSpacing: 12.wMin,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: List.generate(controller.distractorList.length, (int index) {
                return SizedBox(
                  width: 324.6.wMin,
                  child: ManageTitleInput1Widget(
                    title: index == 0 ? "设置干扰项" : null,
                    controller: controller.distractorList[index],
                    error: controller.optionErr[index],
                    focusOrder: index.toDouble(),
                    subTitle: "干扰项",
                    showDelIcon: true,
                    onDel: () {
                      controller.distractorList.removeAt(index);
                      controller.update();
                    },
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(height: 24.wMin),
        TapScaleWidget(
          onTap: () {
            controller.distractorList.add(TextEditingController());
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
                    "添加干扰项",
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
        SizedBox(height: 24.wMin),
      ],
    );
  }

  Widget buildOptionWidget(int index, context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.wMin),
            color: const Color(0xff141828).withValues(alpha: 0.4),
          ),
          child: Row(
            spacing: 16.wMin,
            children: List.generate(controller.optionsList[index].length, (index1) {
              String number = (index + index1 + 1).toString();

              return Expanded(
                child: Stack(
                  children: [
                    ManageTitleInput1Widget(
                      title: number,
                      subTitle: "正确答案",
                      enabled: false,
                      error: controller.optionsList[index][index1].error,
                      inputFontColor: const Color(0xffFF781F),
                      controller: controller.optionsList[index][index1].controller,
                    ),
                    Positioned(
                      right: 20.wMin,
                      top: 42.wMin,
                      child: SizedBox(
                        width: 100.wMin,
                        child: ButtonWidget(
                          text: controller.semanticList.where((element) => element.definition == number).isNotEmpty ? "更换语义" : "添加语义",
                          sclae: 1.03,
                          borderRadius: 6.wMin,
                          color: const Color(0xff353E5C),
                          fontSize: 14.wMin,
                          height: 40.wMin,
                          fontColor: const Color(0xffACB4C0),
                          onTap: () {
                            controller.changeSemantic(index, index1, context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: TapScaleWidget(
            onTap: () => controller.delOption(index),
            child: Container(
              padding: EdgeInsets.all(10.wMin),
              color: Colors.transparent,
              child: SvgPicture.asset(
                "assets/svg/manage/icon_close.svg",
                width: 16.wMin,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
