import 'dart:async';

import 'package:api/entities/entities.dart';
import 'package:get/get.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/manage_ai_queue_controller.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../controllers/manage_select_quzi_knowledge_controller.dart';

class ManageQuizGeneralAiController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageQuizGeneralAiController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_QUIZ_GENERAL_AI;

  @override
  String get breadcrumbTitle => 'AI题目预览';

  int? unitId;
  int? lessonId;
  int? aiRecordId;
  final RxBool jump = false.obs;

  List<ManageUnitKnowledgeEntity>? unitKnowledgeList;
  String? aiCode;
  int? difficultyMin;
  int? difficultyMax;
  String? language;
  int? lessonTemplateId;
  int? configId;

  final RxList<QuizModel> quizList = <QuizModel>[].obs;

  /// -1=请求未结束 0=生成成功 1=生成失败
  final RxInt resultState = (-1).obs;

  final RxList<int> selectIndexs = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if (Get.arguments != null) {
      Map argumentsMap = Get.arguments;
      unitId = argumentsMap["unitId"];
      lessonId = argumentsMap["lessonId"];
      if (argumentsMap['aiRecordId'] != null) {
        if (argumentsMap['aiRecordId'] is int) {
          aiRecordId = argumentsMap['aiRecordId'];
        } else {
          aiRecordId = int.tryParse(argumentsMap['aiRecordId']);
        }
      }

      // 从 aiQuizModel 获取 aiRecordId
      if (argumentsMap['aiQuizModel'] != null) {
        AiQuizModel aiQuizModel = argumentsMap['aiQuizModel'];
        aiRecordId = aiQuizModel.uid;
      }

      jump.value = argumentsMap['jump'] ?? false;
      initData();
    }
  }

  Future<void> initData() async {
    try {
      ToastUtils.showLoading();
      await getUnitInfo();
      await getAiBackQuizData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> getUnitInfo() async {
    if (unitId == null) return;
    Map<String, dynamic> reqData = {
      "uid": [unitId],
    };
    try {
      ResponseEntity<ListResponseEntity<NewUnitResponseEntity<MiniLessonResponseEntity>>> unitEntity = await UnitUtil.fetchPages(
        config: RequestConfig(
          data: reqData,
          requireToken: true,
        ),
      );
      if (unitEntity.data == null) return;
      List<NewUnitResponseEntity<MiniLessonResponseEntity>>? unitList = unitEntity.data!.datas;
      if (unitList == null) return;
      if (unitList.isEmpty) return;
      difficultyMin = unitList.first.difficulty?.min;
      difficultyMax = unitList.first.difficulty?.max;
      language = unitList.first.language;

      // 获取课时详情数据 为了拿一个lessonTemplateId
      ResponseEntity<ListResponseEntity<LessonResponseEntity<dynamic>>> lessonEntity = await LessonUtil.fetchPages(
          config: RequestConfig(
        data: {
          "uid": [lessonId],
        },
        requireToken: true,
      ));
      if (lessonEntity.data == null) return;
      List<LessonResponseEntity<dynamic>>? lessonList = lessonEntity.data!.datas;
      if (lessonList == null) return;
      if (lessonList.isEmpty) return;
      lessonTemplateId = lessonList.first.lessonTemplateId;
    } catch (e) {
      return;
    }
  }

  Future<void> getAiBackQuizData() async {
    if (aiRecordId == null) {
      resultState.value = 1;
      return;
    }
    AiBackPreviewInfoEntity? resData = await ManageSelectQuziKnowledge.getAiBackQuizData(aiRecordId!);
    if (resData == null) {
      resultState.value = 1;
      return;
    }
    if (resData.list == null) {
      resultState.value = 1;
      return;
    }
    List<QuizModel> resList = [];
    for (int i = 0; i < resData.list!.length; i++) {
      if (resData.list![i] == null) continue;
      if ((resData.list![i]?.reason ?? "").isEmpty) {
        resData.list![i]?.reason = "备选${i + 1}";
      }

      resList.add(resData.list![i]!);
    }
    quizList.value = resList;
    if (quizList.isEmpty) {
      resultState.value = 1;
      return;
    }
    resultState.value = 0;
    selectIndexs.value = [0];
    aiCode = resData.suggestCode;
    configId = resList.first.config?.uid;
    if (resData.knowledgeList != null) {
      List<ManageUnitKnowledgeEntity?> resKnowledgeList = resData.knowledgeList ?? [];
      List<ManageUnitKnowledgeEntity> respKnowledgeList = [];
      for (int i = 0; i < resKnowledgeList.length; i++) {
        if (resKnowledgeList[i] == null) continue;
        respKnowledgeList.add(resKnowledgeList[i]!);
      }
      unitKnowledgeList = respKnowledgeList;
    }
  }

  void selectItemIndex(int index) {
    if (selectIndexs.contains(index)) {
      selectIndexs.remove(index);
      return;
    }
    selectIndexs.add(index);
  }

  /// 体验本题
  Future<void> toDemonstrate() async {
    if (selectIndexs.isEmpty) {
      ToastUtils.showManageToast(text: "请选择要体验的题目", type: ManageToastType.error);
      return;
    }
    List<QuizModel> saveQuizList = [];
    for (int i = 0; i < selectIndexs.length; i++) {
      saveQuizList.add(quizList[selectIndexs[i]]);
    }
    Get.toNamed(
      Routes.PRACTICE_QUESTIONS,
      preventDuplicates: false,
      arguments: {
        "quizDatas": saveQuizList,
      },
    );
  }

  /// 重新生成
  Future<void> reGenerate() async {
    if (aiRecordId == null) return;
    try {
      ToastUtils.showLoading();
      bool res = await AiQueueRequest.reGenerate(aiRecordId!);
      if (!res) return;
      await Get.find<ManageAiQueueController>().getQueueList(lessonId);
      ToastUtils.showManageToast(text: "提交成功");
      Get.back();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 放弃生成
  Future<void> giveUp() async {
    if (aiRecordId == null) return;
    try {
      ToastUtils.showLoading();
      bool res = await AiQueueRequest.giveUp(aiRecordId!);
      if (!res) return;
      await Get.find<ManageAiQueueController>().getQueueList(lessonId);
      ToastUtils.showManageToast(text: "提交成功");
      Get.back();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 保存
  Future<void> addQuiz() async {
    if (selectIndexs.isEmpty) {
      ToastUtils.showManageToast(text: "请选择方案", type: ManageToastType.error);
      return;
    }
    if (unitKnowledgeList == null) return;

    List<QuizModel> saveQuizList = [];
    for (int i = 0; i < selectIndexs.length; i++) {
      saveQuizList.add(quizList[selectIndexs[i]]);
    }

    try {
      ToastUtils.showLoading();

      int errorNumber = 0;

      for (int i = 0; i < saveQuizList.length; i++) {
        QuizModel quiz = saveQuizList[i];
        bool res = await ManageSelectQuziKnowledge.addRequest(
          quiz: quiz,
          unitKnowledgeList: unitKnowledgeList,
          aiCode: aiCode,
          difficultyMin: difficultyMin,
          difficultyMax: difficultyMax,
          language: language,
          lessonId: lessonId,
          recordId: aiRecordId,
          configId: configId,
        );
        if (!res) {
          errorNumber++;
        }
      }

      if (errorNumber > 0) {
        ToastUtils.showManageToast(text: "$errorNumber个方案保存失败, ${saveQuizList.length - errorNumber}个方案保存成功");
        return;
      }

      Get.find<ManageAiQueueController>().getQueueList(lessonId);
      bool initialized = Get.isRegistered<ManageSelectQuziKnowledgeController>();
      if (!initialized) return;
      Get.find<ManageSelectQuziKnowledgeController>().getLessonQuizList();
    } catch (e) {
      return;
    } finally {
      ToastUtils.hideLoading();
    }

    ToastUtils.showManageToast(text: "保存成功");

    Get.back(result: true);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
