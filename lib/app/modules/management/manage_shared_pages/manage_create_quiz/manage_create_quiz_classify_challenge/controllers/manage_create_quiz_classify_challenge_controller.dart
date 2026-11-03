import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/dialog/manage_select_knowledge_dialog.dart';
import 'package:langwise/app/modules/management/dialog/manage_quiz_classify_challenge_manual_dialog.dart';
import 'package:langwise/app/modules/management/common/manage_create_quiz_request.dart';
import 'package:langwise/common/entities/manage_lesson_quiz_template_entity.dart';
import 'package:langwise/common/entities/manage_unit_knowledge_entity.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../../../../routes/routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';

class ManageCreateQuizClassifyChallengeController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCreateQuizClassifyChallengeController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_CREATE_QUIZ_CLASSIFY_CHALLENGE;

  @override
  String get breadcrumbTitle => '创建分类挑战';

  List<ManageUnitKnowledgeEntity>? unitKnowledgeList;
  ManageLessonQuizTemplateEntity? lessonQuizTemplate;
  int? lessonId;
  int? unitId;
  String? language;

  List<String?>? contentScope;
  int minClass = 2;
  int maxClass = 4;

  final GlobalKey dialogKey = GlobalKey();

  final List<int> selectKnowledgeIndexs = [];
  final List<int> selectUnIndexs = [];
  List<ManageQuizClassifyChallengeData> classList = [];

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

      contentScope = lessonQuizTemplate?.template?.contentScope;

      minClass = lessonQuizTemplate?.template?.optionsLen?.min ?? 1;
      maxClass = lessonQuizTemplate?.template?.optionsLen?.max ?? 4;
    }
  }

  Future<void> addOption(context) async {
    if (classList.length >= maxClass) {
      ToastUtils.showManageToast(text: "最多可以添加$maxClass个分类");
      return;
    }

    List<ManageUnitKnowledgeEntity>? resList = await ManageSelectKnowledgeDialog.show(
      context: context,
      unitId: unitId,
      knowledgeSingle: true,
      contentScope: contentScope,
      language: language,
      showHaveKnowledge: false,
      title: "选择分类名",
    );
    if (resList == null || resList.isEmpty) return;

    for (int i = 0; i < classList.length; i++) {
      if (classList[i].classData.uid == resList.first.uid) {
        ToastUtils.showManageToast(text: "分类已存在", containerKey: dialogKey);
        return;
      }
    }
    classList.insert(0, ManageQuizClassifyChallengeData(classData: resList.first));
    update();
  }

  Future<void> createQuiz() async {
    if (classList.length < minClass) {
      return ToastUtils.showManageToast(text: "最少需要$minClass个分类");
    }

    List<Map<String, dynamic>> contentList = [];
    List<Map<String, dynamic>> categoryList = [];
    for (int i = 0; i < classList.length; i++) {
      ManageQuizClassifyChallengeData classModel = classList[i];
      if (classModel.selectIndex.isEmpty) {
        return ToastUtils.showManageToast(text: "请添加知识点到分类${classModel.classData.content}里面");
      }

      contentList.add({
        "uid": classModel.classData.contentId,
        "type": classModel.classData.contentType,
        "semanticId": classModel.classData.semanticId,
      });

      List<Map<String, dynamic>> knowledgePoints = [];
      for (var index in classModel.selectIndex) {
        ManageUnitKnowledgeEntity knowModel = unitKnowledgeList![index];
        knowledgePoints.add({
          "uid": knowModel.contentId,
        });

        contentList.add({
          "uid": knowModel.contentId,
          "type": knowModel.contentType,
          "semanticId": knowModel.semanticId,
        });
      }
      categoryList.add({
        "name": classModel.classData.content,
        "knowledge_points": knowledgePoints,
      });
    }

    String quizType = lessonQuizTemplate?.exerciseType ?? "";
    Map<String, dynamic> reqData = {
      "type": quizType,
      "configId": lessonQuizTemplate?.config?.uid,
      "contentList": contentList,
      "category": categoryList,
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
