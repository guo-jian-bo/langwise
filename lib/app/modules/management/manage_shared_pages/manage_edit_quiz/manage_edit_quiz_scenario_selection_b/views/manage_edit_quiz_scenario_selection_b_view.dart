import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:quiz_play/models/quiz_model.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_edit_quiz_scenario_selection_b_binding.dart';
import '../controllers/manage_edit_quiz_scenario_selection_b_controller.dart';

class ManageEditQuizScenarioSelectionBView extends GetView<ManageEditQuizScenarioSelectionBController> {
  final String tagText;
  const ManageEditQuizScenarioSelectionBView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_EDIT_QUIZ_SCENARIO_SELECTION_B}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageEditQuizScenarioSelectionBView(tagText: tag),
      binding: ManageEditQuizScenarioSelectionBBinding(tag: tag),
      routeName: Routes.MANAGE_EDIT_QUIZ_SCENARIO_SELECTION_B,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (_) {
        bool canDraggable = true;
        for (var element in controller.unfoldList) {
          if (element == true) {
            canDraggable = false;
            break;
          }
        }

        return PopScope(
          canPop: false,
          child: ManageScaffold(
            body: Padding(
              padding: EdgeInsets.all(15.wMin),
              child: Column(
                children: [
                  buildHeadWidget(),
                  SizedBox(height: 15.wMin),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.all(15.wMin),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22293C),
                              borderRadius: BorderRadius.circular(12.wMin),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: SingleChildScrollView(child: buildEditWidget()),
                          ),
                        ),
                        SizedBox(width: 15.wMin),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.all(15.wMin),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22293C),
                              borderRadius: BorderRadius.circular(12.wMin),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '问题 (${controller.questionList.length}个问题)',
                                        style: TextStyle(
                                          fontSize: 20.wMin,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const Spacer(),
                                      ManageButton(
                                        text: "添加问题",
                                        width: 110.wMin,
                                        height: 40.wMin,
                                        color: const Color(0xFF2388FF),
                                        borderColor: Colors.transparent,
                                        style: TextStyle(
                                          fontSize: 18.wMin,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        onTap: () {
                                          controller.addQuestion();
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.wMin),
                                  !canDraggable
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.all(12),
                                          itemCount: controller.questionList.length,
                                          itemBuilder: (context, index) {
                                            if (index >= controller.questionList.length || controller.questionList[index] == null) {
                                              return const SizedBox();
                                            }
                                            QuizModelQuestions question = controller.questionList[index]!;
                                            return buildOptionsWidget(index, question, context);
                                          },
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.all(12),
                                          itemCount: controller.questionList.length,
                                          itemBuilder: (context, index) {
                                            if (index >= controller.questionList.length || controller.questionList[index] == null) {
                                              return const SizedBox();
                                            }
                                            QuizModelQuestions question = controller.questionList[index]!;

                                            return KeyedSubtree(
                                              key: ValueKey(question.position ?? 0),
                                              child: LongPressDraggable<QuizModelQuestions>(
                                                data: question,
                                                feedback: Material(
                                                  color: const Color(0xFF0E0F0F),
                                                  child: SizedBox(
                                                    width: 1500.wMin,
                                                    child: buildOptionsWidget(index, question, context),
                                                  ),
                                                ),
                                                childWhenDragging: Opacity(
                                                  opacity: 0.3,
                                                  child: buildOptionsWidget(index, question, context),
                                                ),
                                                child: DragTarget<QuizModelQuestions>(
                                                  builder: (context, candidateData, rejectedData) {
                                                    return buildOptionsWidget(
                                                      index,
                                                      question,
                                                      context,
                                                      isDropTarget: candidateData.isNotEmpty,
                                                    );
                                                  },
                                                  onAcceptWithDetails: (details) {
                                                    if (controller.questionList.contains(details.data)) {
                                                      controller.questionList.remove(details.data);
                                                      controller.questionList.insert(index, details.data);
                                                      controller.update();
                                                    }
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildOptionsWidget(int questionIndex, QuizModelQuestions question, BuildContext context, {bool isDropTarget = false}) {
    int? sureNum;
    sureNum = question.options?.where((element) => element?.isAnswer == true).length;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.wMin),
            border: Border.all(
              color: isDropTarget ? Colors.blue : Colors.white24,
              width: 1.wMin,
            ),
          ),
          child: Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  controller.unfoldList[questionIndex] = !controller.unfoldList[questionIndex];
                  controller.update();
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF353E5C),
                      radius: 18.wMin,
                      child: Text(
                        '${questionIndex + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(width: 15.wMin),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.question ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            '${question.options?.length ?? 0}个选项,$sureNum个正确',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 15.wMin),
                    Icon(
                      controller.unfoldList[questionIndex] ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white70,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                        size: 24.wMin,
                      ),
                      onPressed: () {
                        controller.deleteAnswer(questionIndex);
                      },
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: controller.unfoldList[questionIndex],
                child: Column(
                  children: [
                    SizedBox(height: 10.wMin),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.wMin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '问题文本',
                            style: TextStyle(
                              fontSize: 20.wMin,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 15.wMin),
                          TextField(
                            controller: controller.questionTextFieldList[questionIndex],
                            onChanged: (val) {
                              controller.questionList[questionIndex]?.question = val;
                              controller.update();
                            },
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.wMin,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              hintText: '请输入问题的内容',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.wMin),
                                borderSide: BorderSide(
                                  color: Colors.white24,
                                  width: 1.wMin,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.wMin),
                                borderSide: BorderSide(
                                  color: Colors.white24,
                                  width: 1.wMin,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.wMin),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 20.wMin),
                        Text(
                          'Options / 选项 (Multiple Choice / 多选题) ${question.options?.length ?? 0}个options',
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        ManageButton(
                          text: "添加option",
                          width: 130.wMin,
                          height: 40.wMin,
                          color: const Color(0xFF63DE77),
                          borderColor: Colors.transparent,
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                          onTap: () {
                            controller.addOption(questionIndex);
                          },
                        ),
                        SizedBox(width: 20.wMin),
                      ],
                    ),
                    SizedBox(height: 10.wMin),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: question.options?.length ?? 0,
                      itemBuilder: (context, optionIndex) {
                        final option = question.options?[optionIndex];
                        return KeyedSubtree(
                          key: ObjectKey(option),
                          child: buildOptionWidget(questionIndex, optionIndex, option, context),
                        );
                      },
                    ),
                    buildParseWidget(questionIndex, question),
                    SizedBox(height: 15.wMin),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.wMin),
      ],
    );
  }

  Widget buildParseWidget(int index, QuizModelQuestions? question) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(width: 15.wMin),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 10.wMin, bottom: 10.wMin, left: 10.wMin),
              decoration: BoxDecoration(
                color: const Color(0xFF353E5C),
                borderRadius: BorderRadius.circular(8.wMin),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '答案解析:',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 4.wMin),
                  Text(
                    question?.explanation?.first?.text ?? '',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 4.wMin),
                  Text(
                    question?.explanation?.last?.text ?? '',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 20.wMin),
          ManageButton(
            text: "编辑\n解析",
            width: 90.wMin,
            color: const Color.fromRGBO(35, 136, 255, 0.30),
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 18.wMin,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            onTap: () {
              controller.editAnswer(index);
            },
          ),
          SizedBox(width: 15.wMin),
        ],
      ),
    );
  }

  Widget buildOptionWidget(int questionIndex, int optionIndex, QuizModelQuestionsOptions? option, BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.wMin),
            border: Border.all(
              color: Colors.white24,
              width: 1.wMin,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.drag_indicator,
                color: const Color(0xFF353E5C),
                size: 50.wMin,
              ),
              CircleAvatar(
                backgroundColor: const Color(0xFF353E5C),
                radius: 18.wMin,
                child: Text(
                  controller.getSequence(optionIndex),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(width: 5.wMin),
              IconButton(
                icon: Icon(
                  option?.isAnswer == true ? Icons.check_circle : Icons.cancel,
                  color: option?.isAnswer == true ? Colors.greenAccent : Colors.grey[500],
                  size: 34.wMin,
                ),
                onPressed: () {
                  controller.updateOptionIsAnswer(questionIndex, optionIndex, !(option?.isAnswer ?? false));
                },
              ),
              SizedBox(width: 5.wMin),
              Expanded(
                child: TextField(
                  controller: controller.optionTextFieldList[questionIndex][optionIndex],
                  onChanged: (val) {
                    controller.questionList[questionIndex]?.options?[optionIndex]?.text = val;
                    controller.update();
                  },
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: '请输入选项的内容',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.wMin),
                      borderSide: BorderSide(
                        color: Colors.white24,
                        width: 1.wMin,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.wMin),
                      borderSide: BorderSide(
                        color: Colors.white24,
                        width: 1.wMin,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20.wMin),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                  size: 24.wMin,
                ),
                onPressed: () {
                  controller.deleteOption(questionIndex, optionIndex);
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 15.wMin),
      ],
    );
  }

  Widget buildEditWidget() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '文章内容',
              style: TextStyle(
                fontSize: 20.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 20.wMin),
            SelectableText(
              '文章ID:${controller.quizData.value.stems?.first?.content?.uid}',
              style: TextStyle(
                fontSize: 18.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: 15.wMin),
        Row(
          children: [
            TextFieldTapRegion(
              child: ManageButton(
                text: "管理文章音频",
                width: 140.wMin,
                height: 40.wMin,
                color: const Color(0xFF2388FF),
                borderColor: Colors.transparent,
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
                onTap: () {
                  controller.navigateToManageArticleAudioPage();
                },
              ),
            ),
            const Spacer(),
            ManageButton(
              text: "全部移除",
              width: 110.wMin,
              height: 40.wMin,
              color: const Color(0xFFFF2D46),
              borderColor: Colors.transparent,
              style: TextStyle(
                fontSize: 18.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              onTap: () {
                controller.deleteAllOptions();
              },
            ),
          ],
        ),
        SizedBox(height: 15.wMin),
        SizedBox(
          height: 240.wMin,
          child: TextField(
            controller: controller.textController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: '请输入文章内容',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.wMin),
                borderSide: BorderSide(
                  color: Colors.white24,
                  width: 1.wMin,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.wMin),
                borderSide: BorderSide(
                  color: Colors.white24,
                  width: 1.wMin,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHeadWidget() {
    return Column(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '编辑练习',
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SelectableText(
                  '全文综合阅读理解 UID:${controller.quizId}',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ManageButton(
              text: "题型演示",
              width: 110.wMin,
              height: 40.wMin,
              color: const Color(0xFF353E5C),
              borderColor: Colors.transparent,
              style: TextStyle(
                fontSize: 18.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              onTap: () {
                controller.showQuizEditResult();
              },
            ),
            SizedBox(width: 20.wMin),
            ManageButton(
              text: "保存更改",
              width: 110.wMin,
              height: 40.wMin,
              color: const Color(0xFF2388FF),
              borderColor: Colors.transparent,
              style: TextStyle(
                fontSize: 18.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              onTap: () {
                controller.saveChanges();
              },
            ),
          ],
        ),
        SizedBox(height: 15.wMin),
        Container(
          padding: EdgeInsets.all(12.wMin),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1C38),
            borderRadius: BorderRadius.circular(8.wMin),
            border: Border.all(color: const Color(0xFF3C5A99)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.lightBlueAccent,
                size: 20.wMin,
              ),
              SizedBox(width: 8.wMin),
              Text(
                '全文综合阅读理解:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 4.wMin),
              Text(
                '创建关于全文的问题。 不需要在文章中添加标记，问题测试整体理解。',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
