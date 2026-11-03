import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_title_check_text_widget.dart';
import 'package:langwise/app/modules/management/common/manage_select_knowledge_table/view.dart';
import 'package:langwise/app/modules/management/common/manage_create_quiz_request.dart';
import 'package:langwise/common/entities/en_phrase_entity.dart';
import 'package:langwise/common/entities/en_sentence_entity.dart';
import 'package:langwise/common/entities/en_word_entity.dart';
import 'package:langwise/common/entities/manage_lesson_quiz_template_entity.dart';
import 'package:langwise/common/entities/manage_unit_knowledge_entity.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../../../../routes/routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';

class ManageCreateQuizListenFindWordController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCreateQuizListenFindWordController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_CREATE_QUIZ_LISTEN_FIND_WORD;

  @override
  String get breadcrumbTitle => '创建听音找词';

  List<ManageUnitKnowledgeEntity>? unitKnowledgeList;
  ManageLessonQuizTemplateEntity? lessonQuizTemplate;
  int? lessonId;
  int? unitId;
  String? language;

  String? knowledgeText;

  List<ManageTitleCheckTextEntity> wordTextList = [];
  final TextEditingController answerController = TextEditingController();

  final GlobalKey dialogKey = GlobalKey();
  bool answerErr = false;
  List<Map<String, dynamic>> contentList = [];

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
      unitKnowledgeList = argumentsMap["knowledgeList"];
      knowledgeText = unitKnowledgeList![0].content ?? "";
    }

    List<String> knowTextList = knowledgeText!.split(" ");
    for (int i = 0; i < knowTextList.length; i++) {
      wordTextList.add(ManageTitleCheckTextEntity(text: knowTextList[i]));
    }
  }

  void selectItem(int index, context) async {
    for (int i = 0; i < wordTextList.length; i++) {
      if (i == index) {
        wordTextList[i].seelcted = true;
      } else {
        wordTextList[i].seelcted = false;
      }
    }
    String text = wordTextList[index].text;
    final isPunctuation = RegExp(r'[,.!?;，。！？；]$').hasMatch(text[text.length - 1]);
    if (isPunctuation) {
      text = text.substring(0, text.length - 1);
    }

    var value = await ManageSelectKnowledgeTableManager.show(
      context: context,
      defaultDessert: [],
      language: 'en',
      showSelectKnowledgeAddButton: false,
      word: text,
      searchContent: text,
      singleSelectionMode: true,
      hidePhrase: true,
      hideSentence: true,
      hideText: true,
    );
    if (value != null && value.isNotEmpty) {
      contentList.clear();
      for (int i = 0; i < value.length; i++) {
        final entity = value[i];
        if (entity is EnWordEntity) {
          contentList.add({
            "uid": entity.uid,
            "type": entity.contentType,
            "semanticId": entity.semanticIds?.first,
          });
        } else if (entity is EnPhraseEntity) {
          contentList.add({
            "uid": entity.uid,
            "type": entity.contentType,
            "semanticId": entity.semanticIds?.first,
          });
        } else if (entity is EnSentenceEntity) {
          contentList.add({
            "uid": entity.uid,
            "type": entity.contentType,
            "semanticId": entity.semanticIds?.first,
          });
        }
      }
    } else {
      return;
    }

    answerController.text = text;
    update();
  }

  void createQuiz() async {
    if (answerController.text.isEmpty) {
      ToastUtils.showManageToast(text: "请选择答案位置", containerKey: dialogKey);
      answerErr = true;
      update();
      Future.delayed(const Duration(seconds: 3), () {
        answerErr = false;
        update();
      });
      return;
    }

    String quizType = lessonQuizTemplate?.exerciseType ?? "";
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
      "options": [
        {
          "text": answerController.text,
        }
      ],
      "lessonId": lessonId,
      "unitId": unitId,
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
