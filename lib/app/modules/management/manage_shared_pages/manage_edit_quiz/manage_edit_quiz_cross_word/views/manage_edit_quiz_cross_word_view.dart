import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/dialog/manage_quiz_crossword_manual_dialog.dart';
import 'package:langwise/common/widgets/button_widgets.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_edit_quiz_cross_word_binding.dart';
import '../controllers/manage_edit_quiz_cross_word_controller.dart';

class ManageEditQuizCrossWordView extends GetView<ManageEditQuizCrossWordController> {
  final String tagText;
  const ManageEditQuizCrossWordView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_EDIT_QUIZ_CROSS_WORD}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageEditQuizCrossWordView(tagText: tag),
      binding: ManageEditQuizCrossWordBinding(tag: tag),
      routeName: Routes.MANAGE_EDIT_QUIZ_CROSS_WORD,
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
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 1400.wMin,
                      child: Container(
                        key: controller.dialogKey,
                        margin: EdgeInsets.symmetric(horizontal: 24.wMin),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.wMin),
                              child: Container(
                                padding: EdgeInsets.all(24.wMin),
                                decoration: BoxDecoration(
                                  color: const Color(0xffC5C5C5).withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(20.wMin),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.37),
                                      blurRadius: 0,
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(color: const Color(0xff3D3D3D).withValues(alpha: 0.37), blurRadius: 3, offset: Offset(0, 5.wMin)),
                                  ],
                                ),
                                child: buildWordContent(context),
                              ),
                            ),
                            SizedBox(height: 24.wMin),
                            buildWordDirectionWidget(),
                          ],
                        ),
                      ),
                    ),
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
                        Get.back(result: {'refresh': true});
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
                SizedBox(height: 24.wMin),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildBoxItem(int index) {
    return Container(
      key: controller.gridViewData[index].key,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color.fromRGBO(70, 70, 72, 1),
        boxShadow: [
          BoxShadow(
            color: controller.gridViewData[index].isMatch ? Colors.white : Colors.transparent,
            blurRadius: 5,
          ),
        ],
      ),
      child: AutoSizeText(
        controller.gridViewData[index].position.toString(),
        minFontSize: 6,
        style: TextStyle(
          fontSize: 36.wMin,
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget buildLetterWidget(VFillGridLetterData data, VFillWordData dataWord) {
    Color color = const Color.fromRGBO(70, 70, 72, 1);
    if (data.isSelect) {
      color = const Color(0xffFF781F);
    }
    if (data.isErr) {
      color = const Color(0xffFF2D46);
    }

    return TapScaleWidget(
      onTap: () {
        controller.selectLetter(data);
      },
      behavior: HitTestBehavior.deferToChild,
      sclae: 1.05,
      child: Container(
        key: data.key,
        width: data.size.width,
        height: data.size.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: color,
        ),
        child: AutoSizeText(
          data.text,
          minFontSize: 6,
          style: TextStyle(
            fontSize: 36.wMin,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildWordWidget(VFillWordData data, int wordIndex) {
    Widget wordDirection() {
      if (data.isHorizontal) {
        return Row(
          spacing: 12.wMin,
          children: List.generate(data.word.length, (int index) {
            return buildLetterWidget(data.word[index], data);
          }),
        );
      }
      return Column(
        spacing: 12.wMin,
        children: List.generate(data.word.length, (int index) {
          return buildLetterWidget(data.word[index], data);
        }),
      );
    }

    return GestureDetector(
      onTap: () => controller.selectWord(wordIndex),
      behavior: HitTestBehavior.deferToChild,
      child: Transform.translate(
        offset: Offset(-6.wMin, -6.wMin),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(8.wMin),
          dashPattern: [5.wMin, 5.wMin],
          padding: EdgeInsets.zero,
          strokeCap: StrokeCap.round,
          strokeWidth: 1.wMin,
          color: data.isSelect ? const Color(0xff2388FF) : Colors.transparent,
          child: Container(
            margin: EdgeInsets.all(6.wMin),
            child: wordDirection(),
          ),
        ),
      ),
    );
  }

  Widget buildWordContent(context) {
    return Stack(
      clipBehavior: Clip.none,
      key: controller.girdKey,
      children: [
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: GridView.builder(
            itemCount: controller.gridViewData.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: controller.letterRowSize,
              mainAxisSpacing: 12.wMin,
              crossAxisSpacing: 12.wMin,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              return buildBoxItem(index);
            },
          ),
        ),
        ...List.generate(controller.wordList.length, (index) {
          return Positioned(
            left: controller.wordList[index].offset.dx,
            top: controller.wordList[index].offset.dy,
            child: buildWordWidget(controller.wordList[index], index),
          );
        }),
      ],
    );
  }

  Widget buildWordDirectionWidget() {
    Widget buildWordDirectionButton(bool isHorizontal, String text) {
      Color color = const Color(0xff353E5C);
      VFillWordData? currnt = controller.wordList.firstWhereOrNull((e) => e.isSelect);
      if (currnt != null) {
        if (currnt.isHorizontal == isHorizontal) color = const Color(0xffFF781F);
      }

      return TapScaleWidget(
        onTap: () {
          // Direction change logic would go here
        },
        sclae: 1.05,
        child: Container(
          height: 40.wMin,
          padding: EdgeInsets.symmetric(horizontal: 12.wMin),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: color,
          ),
          child: Row(
            spacing: 6.wMin,
            children: [
              Container(
                width: 25.wMin,
                alignment: Alignment.center,
                child: Container(
                  width: isHorizontal ? 22.wMin : 14.wMin,
                  height: isHorizontal ? 14.wMin : 22.wMin,
                  decoration: BoxDecoration(
                    border: Border.all(width: 2.wMin, color: const Color(0xffEBEFF5)),
                    borderRadius: BorderRadius.circular(2.wMin),
                  ),
                ),
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: const Color(0xffEBEFF5),
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 24.wMin,
      children: [
        Text(
          "单词方向",
          style: TextStyle(
            fontSize: 18.wMin,
            color: const Color(0xffEBEFF5),
            fontWeight: FontWeight.w400,
          ),
        ),
        buildWordDirectionButton(true, "横向"),
        buildWordDirectionButton(false, "竖向"),
      ],
    );
  }
}
