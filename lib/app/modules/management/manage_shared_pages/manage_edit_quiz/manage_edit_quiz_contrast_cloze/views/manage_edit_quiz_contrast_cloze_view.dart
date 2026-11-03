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
import '../bindings/manage_edit_quiz_contrast_cloze_binding.dart';
import '../controllers/manage_edit_quiz_contrast_cloze_controller.dart';

class ManageEditQuizContrastClozeView extends GetView<ManageEditQuizContrastClozeController> {
  final String tagText;
  const ManageEditQuizContrastClozeView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_EDIT_QUIZ_CONTRAST_CLOZE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageEditQuizContrastClozeView(tagText: tag),
      binding: ManageEditQuizContrastClozeBinding(tag: tag),
      routeName: Routes.MANAGE_EDIT_QUIZ_CONTRAST_CLOZE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
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
                      ...List.generate(controller.wordsTextList.length, (listIndex) {
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
                      }),
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
                          child: ReorderableColumn(
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
            spacing: 20.wMin,
            children: List.generate(controller.optionsList[index].length, (index1) {
              String number = (index * 2 + index1 + 1).toString();
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
                    )
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
