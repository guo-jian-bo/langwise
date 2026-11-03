import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_title_check_text_widget.dart';
import 'package:langwise/app/modules/management/common/manage_create_quiz_request.dart';
import 'package:langwise/common/entities/manage_lesson_quiz_template_entity.dart';
import 'package:langwise/common/entities/manage_unit_knowledge_entity.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../../../../routes/routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';

class ManageCreateQuizWordCompletionController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCreateQuizWordCompletionController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_CREATE_QUIZ_WORD_COMPLETION;

  @override
  String get breadcrumbTitle => '创建单词补全';

  List<ManageUnitKnowledgeEntity>? unitKnowledgeList;
  ManageLessonQuizTemplateEntity? lessonQuizTemplate;
  int? lessonId;
  int? unitId;
  String? language;

  int minOption = 1;
  int maxOption = 4;
  int initOptionCount = 1;
  late ManageUnitKnowledgeEntity knowledge;

  List<ManageTitleCheckTextEntity> wordTextList = [];
  final TextEditingController answerController = TextEditingController();

  List<String> answerList = [];
  List<List<int>> answerPositionsList = [];
  List<TextEditingController> optionList = [];
  List<bool> optionErr = [];

  final GlobalKey dialogKey = GlobalKey();
  bool answerErr = false;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      Map argumentsMap = Get.arguments;
      lessonId = argumentsMap["lessonId"];
      unitId = argumentsMap["unitId"];
      language = argumentsMap["language"];

      lessonQuizTemplate = argumentsMap["lessonQuizTemplate"];

      minOption = lessonQuizTemplate?.template?.optionsLen?.min ?? 1;
      maxOption = lessonQuizTemplate?.template?.optionsLen?.max ?? 4;

      initOptionCount = lessonQuizTemplate?.config?.optionCount ?? 1;

      unitKnowledgeList = argumentsMap["knowledgeList"];
      knowledge = unitKnowledgeList![0];
    }

    String contentText = knowledge.content ?? "";
    for (int i = 0; i < contentText.length; i++) {
      wordTextList.add(ManageTitleCheckTextEntity(text: contentText[i]));
    }
    for (int i = 0; i < initOptionCount - 1; i++) {
      optionList.add(TextEditingController());
      optionErr.add(false);
    }
  }

  void selectItem(int index) {
    answerList.clear();
    answerPositionsList.clear();

    wordTextList[index].seelcted = !wordTextList[index].seelcted;

    String answer = "";
    List<int> positions = [];
    for (int i = 0; i < wordTextList.length; i++) {
      if (wordTextList[i].seelcted) {
        answer += wordTextList[i].text;
        positions.add(i);

        if (i < wordTextList.length - 1) {
          if (!wordTextList[i + 1].seelcted) {
            List<int> positionCopy = List.from(positions);
            answerList.add(answer);
            answerPositionsList.add(positionCopy);

            answer = "";
            positions.clear();
          }
        } else {
          List<int> positionCopy = List.from(positions);
          answerList.add(answer);
          answerPositionsList.add(positionCopy);
        }
      }
    }
    answerController.text = answerList.join(",");
    update();
  }

  void getAnswer() {
    String answer = "";
    for (int i = 0; i < wordTextList.length; i++) {
      if (wordTextList[i].seelcted) {
        answer += wordTextList[i].text;
      }
    }
    answerController.text = answer;
  }

  void createQuiz() async {
    List<Map<String, dynamic>>? optionStrList;

    bool hasOption = false;
    for (var element in optionList) {
      if (element.text.isNotEmpty) {
        hasOption = true;
        break;
      }
    }

    if (answerController.text.isEmpty && !hasOption) {
      final ask = await AskDialog.showUserAsk(
        context: Get.context!,
        content: "没有设置正确答案和错误选项,让AI自动生成么？AI生成预计一分钟左右。",
        define: "继续生成",
        showCancel: true,
      );

      if (ask == false) {
        return;
      }
      optionStrList = null;
    } else {
      if (answerList.isEmpty) {
        ToastUtils.showManageToast(text: "请选择答案位置", containerKey: dialogKey);
        answerErr = true;
        update();
        Future.delayed(const Duration(seconds: 3), () {
          answerErr = false;
          update();
        });
        return;
      }

      optionStrList = [];
      for (int i = 0; i < optionList.length; i++) {
        if (optionList[i].text.isEmpty) {
          ToastUtils.showManageToast(text: "请输入选项", containerKey: dialogKey);
          optionErr[i] = true;
          update();
          Future.delayed(const Duration(seconds: 3), () {
            optionErr[i] = false;
            update();
          });
          return;
        }
        optionStrList.add({
          "text": optionList[i].text,
        });
      }

      String text = "";
      List<int> positions = [];
      bool isOk = false;
      for (int i = 0; i < wordTextList.length; i++) {
        if (wordTextList[i].seelcted) {
          text += wordTextList[i].text;
          positions.add(i);
          isOk = true;
          if (i == wordTextList.length - 1) {
            optionStrList.insert(0, {
              "text": text,
              "positions": positions,
            });
          }
        } else {
          if (isOk) {
            optionStrList.insert(0, {
              "text": text,
              "positions": positions,
            });
            text = "";
            positions = [];
          }
          isOk = false;
        }
      }
    }

    String quizType = lessonQuizTemplate?.exerciseType ?? "";
    List<Map<String, dynamic>> contentList = [];
    for (ManageUnitKnowledgeEntity model in unitKnowledgeList!) {
      contentList.add({
        "uid": model.contentId,
        "type": model.contentType,
        "semanticId": model.semanticId,
      });
    }
    Map<String, dynamic> reqData = {
      "type": quizType,
      "configId": lessonQuizTemplate?.config?.uid,
      "contentList": contentList,
      "options": optionStrList,
      "lessonId": lessonId,
    };

    try {
      ToastUtils.showLoading();

      bool isSuccess = await ManageCreateQuizRequest.createQuiz(reqData);
      if (isSuccess) {
        ToastUtils.showManageToast(text: "创建成功");
        Get.back(result: {'refresh': true});
        Get.back(result: {'refresh': true});
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }
}
