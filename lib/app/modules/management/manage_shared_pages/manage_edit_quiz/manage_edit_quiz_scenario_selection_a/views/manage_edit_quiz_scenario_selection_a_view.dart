import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:quiz_play/models/quiz_model.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_edit_quiz_scenario_selection_a_binding.dart';
import '../controllers/manage_edit_quiz_scenario_selection_a_controller.dart';

class ManageEditQuizScenarioSelectionAView extends GetView<ManageEditQuizScenarioSelectionAController> {
  final String tagText;
  const ManageEditQuizScenarioSelectionAView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_EDIT_QUIZ_SCENARIO_SELECTION_A}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageEditQuizScenarioSelectionAView(tagText: tag),
      binding: ManageEditQuizScenarioSelectionABinding(tag: tag),
      routeName: Routes.MANAGE_EDIT_QUIZ_SCENARIO_SELECTION_A,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageEditQuizScenarioSelectionAController>(
      init: controller,
      tag: tagText,
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
                                    ],
                                  ),
                                  SizedBox(height: 20.wMin),
                                  canDraggable
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.all(12),
                                          itemCount: controller.questionList.length,
                                          itemBuilder: (context, index) {
                                            QuizModelQuestions? question = controller.questionList[index];
                                            return KeyedSubtree(
                                              key: ObjectKey(question),
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
                                                      for (int i = 0; i < controller.questionList.length; i++) {
                                                        QuizModelQuestions? question = controller.questionList[i];
                                                        question?.position = i + 1;
                                                      }
                                                      controller.update();
                                                    }
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.all(12),
                                          itemCount: controller.questionList.length,
                                          itemBuilder: (context, index) {
                                            QuizModelQuestions? question = controller.questionList[index];
                                            return KeyedSubtree(
                                              key: ObjectKey(question),
                                              child: buildOptionsWidget(index, controller.questionList[index], context),
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

  Widget buildOptionsWidget(int questionIndex, QuizModelQuestions? question, BuildContext context, {bool isDropTarget = false}) {
    int? sureNum;
    sureNum = question?.options?.where((element) => element?.isAnswer == true).length;
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
                            question?.question ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            '${question?.options?.length ?? 0}个选项,$sureNum个正确',
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
                          'Options / 选项 (Multiple Choice / 多选题) ${question?.options?.length ?? 0}个options',
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
                      itemCount: question?.options?.length ?? 0,
                      itemBuilder: (context, optionIndex) {
                        final option = question?.options?[optionIndex];
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
              '段落（断点模式） ${controller.questionList.length}个断点',
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
            Visibility(
              visible: controller.showInsertButton == true,
              child: TextFieldTapRegion(
                child: ManageButton(
                  text: "插入断点",
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
                    controller.insertNewQuestion();
                  },
                ),
              ),
            ),
            SizedBox(width: 20.wMin),
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
        Container(
          padding: EdgeInsets.all(12.wMin),
          decoration: BoxDecoration(
            color: const Color(0xFF353E5C),
            borderRadius: BorderRadius.circular(8.wMin),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '断点模式:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 4.wMin),
              Text(
                '将光标放在要插入断点的位置，然后点击"插入断点"按钮。 系统会在光标位置插入 {{N}}。',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.wMin),
        SizedBox(
          height: 240.wMin,
          child: TextField(
            controller: controller.textController,
            focusNode: controller.textFocusNode,
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
        SizedBox(height: 20.wMin),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(15.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.wMin),
            border: Border.all(
              color: Colors.white24,
              width: 1.wMin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '预览:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 10.wMin),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    height: 2.0,
                  ),
                  children: buildTextWithPlaceholders(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<InlineSpan> buildTextWithPlaceholders() {
    String text = controller.textController.text;
    List<InlineSpan> spans = [];
    RegExp regExp = RegExp(r"{{(\d+)}}");
    Iterable<RegExpMatch> matches = regExp.allMatches(text);

    int lastMatchEnd = 0;

    for (var match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      int index = int.parse(match.group(1)!);

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 4.wMin),
            decoration: BoxDecoration(
              color: const Color(0xFF353E5C),
              borderRadius: BorderRadius.circular(4.wMin),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20.wMin,
                  height: 20.wMin,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.wMin),
                    border: Border.all(
                      color: Colors.white24,
                      width: 1.wMin,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      index.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.wMin,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15.wMin),
                GestureDetector(
                  onTap: () {
                    controller.deleteOptionFromPreview(index);
                  },
                  child: Icon(
                    Icons.delete,
                    size: 20.wMin,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return spans;
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
                  '局部情景阅读理解 UID:${controller.quizId}',
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
                '局部情景阅读理解:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 4.wMin),
              Text(
                '在文章中插入断点标记，表示问题出现的位置。 每个问题测试到该断点为止的文章理解。',
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
