import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:quiz_play/models/quiz_model.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_edit_quiz_cloze_test_a_binding.dart';
import '../controllers/manage_edit_quiz_cloze_test_a_controller.dart';

class ManageEditQuizClozeTestAView extends GetView<ManageEditQuizClozeTestAController> {
  final String tagText;
  const ManageEditQuizClozeTestAView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_EDIT_QUIZ_CLOZE_TEST_A}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageEditQuizClozeTestAView(tagText: tag),
      binding: ManageEditQuizClozeTestABinding(tag: tag),
      routeName: Routes.MANAGE_EDIT_QUIZ_CLOZE_TEST_A,
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
                                        'Options / 选项 (Answer Bank / 答案池) ${controller.optionList.length}个options',
                                        style: TextStyle(
                                          fontSize: 20.wMin,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.wMin),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(12),
                                    itemCount: controller.optionList.length,
                                    itemBuilder: (context, index) => buildOptionWidget(index, controller.optionList[index], context),
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

  Widget buildOptionWidget(int index, QuizModelOptions? option, BuildContext context) {
    return Column(
      key: Key(index.toString()),
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
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 70.wMin,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.drag_indicator,
                            color: const Color(0xFF353E5C),
                            size: 50.wMin,
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 6.wMin, top: 2.wMin, bottom: 4.wMin, right: 6.wMin),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(35, 136, 255, 0.65),
                              borderRadius: BorderRadius.circular(4.wMin),
                            ),
                            child: Text(
                              'pos: ${option?.positions?.first ?? 0}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.wMin,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(width: 20.wMin),
                          Expanded(
                            child: TextField(
                              controller: controller.optionTextFieldList[index],
                              onChanged: (val) {
                                controller.optionList[index]?.text = val;
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
                        ],
                      ),
                    ),
                    SizedBox(height: 20.wMin),
                    buildParseWidget(index, option),
                    SizedBox(height: 10.wMin),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                  size: 32.wMin,
                ),
                onPressed: () {
                  controller.deleteOptionFromOptions(index);
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 15.wMin),
      ],
    );
  }

  Widget buildParseWidget(int index, QuizModelOptions? option) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(width: 50.wMin),
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
                    option?.explanation?.first?.text ?? '',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 4.wMin),
                  Text(
                    option?.explanation?.last?.text ?? '',
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
            width: 130.wMin,
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
        ],
      ),
    );
  }

  Widget buildEditWidget() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '文章（挖空模式） ${controller.optionList.length}个挖空',
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
              visible: controller.selectedWord != null,
              child: TextFieldTapRegion(
                child: ManageButton(
                  text: "创建挖空",
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
                    controller.replaceSelectedWord();
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
                '挖空模式:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 4.wMin),
              Text(
                '在下方文本框中选择文字，然后点击"创建挖空"按钮。 选中的文字将被替换为 {{N}}。',
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
                  '答案池挖空题 UID:${controller.quizId}',
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
                '答案池挖空题:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 4.wMin),
              Text(
                '通过选择文本中的单词来创建空白。所有被挖空的单词形成答案池。每个选项应有一个独特的序号，对应其空白位置。',
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
