import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_play/utils/utils.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/stores/stores.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../../management/dialog/manage_select_knowledge_dialog.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';

class ManageSelectQuziKnowledgeController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageSelectQuziKnowledgeController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SELECT_QUZI_KNOWLEDGE;

  @override
  String get breadcrumbTitle => '选择题目知识点';

  int? lessonTemplateId;
  int? unitId;
  int? difficultyMin;
  int? difficultyMax;
  String? language;
  int? lessonId;
  int? moduleId;

  final RxList<ManageLessonQuizTemplateEntity> quizList = <ManageLessonQuizTemplateEntity>[].obs;

  final RxList<ManageUnitKnowledgeEntity> knowledgeList = <ManageUnitKnowledgeEntity>[].obs;

  /// 当前的知识点类型tab下标
  final RxInt knowledgeTabIndex = 0.obs;

  /// 当前显示的知识点列表
  final RxList<ManageUnitKnowledgeEntity> showKnowledgeList = <ManageUnitKnowledgeEntity>[].obs;
  final TextEditingController searchKnowledginput = TextEditingController();

  /// 选择的题目模版下标
  final RxInt selectTemplateIndex = (-1).obs;

  /// 选择知识点的uid 根据题型来判断是多选还是单选
  final RxList<int> selectKnowledgeUids = <int>[].obs;

  /// 知识点是否是单选
  final RxBool knowledgeSingle = false.obs;

  /// EN_TEXT知识点是否已经选择
  bool knowledgeEnTextSelected = false;

  /// 多选情况下最大选择知识点数量
  final RxInt knowledgeMaxSelect = 4.obs;

  /// 多选情况下最小选择知识点数量
  final RxInt knowledgeMinSelect = 1.obs;

  /// 待审核题目数量
  final RxInt reviewQuizCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if (Get.arguments != null) {
      Map parame = Get.arguments;
      lessonTemplateId = parame["lessonTemplateId"];
      unitId = parame["unitId"];
      difficultyMin = parame["difficultyMin"];
      difficultyMax = parame["difficultyMax"];
      language = parame["language"];
      lessonId = parame["lessonId"];
      moduleId = parame["moduleId"];
      getQuizData();
      getKnowledgeList();
      getReviewQuizCount();
    }
  }

  /// 查询待审核数量
  Future<void> getReviewQuizCount() async {
    if(lessonId == null) return;
    if(!UserStore.to.rolePermissions.value.userIsExerciseReviewer) return;
    try {
      Map<String, dynamic> reqData = {
        "lessonIds": [lessonId],
      };
      ExerciseReviewEntity? entity = await ExerciseReviewRequest.getExerciseReviewList(reqData);
      if(entity == null) return;
      List<ExerciseReviewEntityList?>? list = entity.list??[];
      reviewQuizCount.value = list.length;
      
    } catch (_) {}
  }


  Future<void> getQuizData() async {
    if (lessonTemplateId == null) return;
    List<ManageLessonQuizTemplateEntity>? resList = await ManageLessonTemplateRequest.getLessonQuizList(lessonTemplateId!);
    if (resList == null) return;
    quizList.value = resList;
    if (quizList.isNotEmpty) {
      knowledgeSingle.value = quizList.first.template?.isKnowledgeSingle ?? false;
    }
    selectTemplate(0);
  }

  /// 获取知识点列表
  Future<void> getKnowledgeList() async {
    if (unitId == null) {
      return;
    }

    UnitKnowledgePointsEntity? entity = await OfficialCourseDetailsRequest.getAdminUnitTarget(unitId!);
    if (entity == null) {
      return;
    }
    List<UnitKnowledgePointsEntityKnowledgeList?>? list = entity.knowledgeList ?? [];
    for (int i = 0; i < list.length; i++) {
      UnitKnowledgePointsEntityKnowledgeList? item = list[i];
      if (item == null) continue;
      if (item.isSong) continue;
      knowledgeList.add(ManageUnitKnowledgeEntity.fromJson(item.toJson()));
    }

    changeKnowledgeTabIndex(0);
  }

  /// 切换知识点类型tab下标
  void changeKnowledgeTabIndex(int index) {
    knowledgeTabIndex.value = index;
    searchKnowledg();
  }

  /// 搜索知识点
  void searchKnowledg() {
    showKnowledgeList.clear();
    if (searchKnowledginput.text.isEmpty) {
      for (int i = 0; i < knowledgeList.length; i++) {
        addShowKnowledge(knowledgeList[i]);
      }
      return;
    }
    String text = searchKnowledginput.text.toLowerCase();

    for (int i = 0; i < knowledgeList.length; i++) {
      String content = (knowledgeList[i].content ?? "").toLowerCase();
      String definition = (knowledgeList[i].definition ?? "").toLowerCase();
      if (content.contains(text) || definition.contains(text)) {
        addShowKnowledge(knowledgeList[i]);
      }
    }
  }

  /// 根据知识点类型展示相应的知识点
  void addShowKnowledge(ManageUnitKnowledgeEntity data) {
    if (knowledgeTabIndex.value == 0) {
      showKnowledgeList.add(data);
    } else if (knowledgeTabIndex.value == 1 && data.isEnWord) {
      showKnowledgeList.add(data);
    } else if (knowledgeTabIndex.value == 2 && data.isEnPhrase) {
      showKnowledgeList.add(data);
    } else if (knowledgeTabIndex.value == 3 && data.isEnSentence) {
      showKnowledgeList.add(data);
    } else if (knowledgeTabIndex.value == 4 && data.isEnText) {
      showKnowledgeList.add(data);
    }
  }

  /// 根据题型来获取可选知识点的数量数组
  List<int> getQuantityScope() {
    ManageLessonQuizTemplateEntity currentQuiz = quizList[selectTemplateIndex.value];
    List<int?>? quantityScope = currentQuiz.template?.stemQuantityScope;
    if (quantityScope == null || quantityScope.isEmpty) {
      quantityScope = currentQuiz.template?.optionQuantityScope;
    }
    if (quantityScope == null || quantityScope.isEmpty) return [];
    List<int> request = [];
    for (int i = 0; i < quantityScope.length; i++) {
      if (quantityScope[i] == null) continue;
      request.add(quantityScope[i]!);
    }
    return request;
  }

  void selectTemplate(int index) {
    if (selectTemplateIndex.value == index) return;
    selectTemplateIndex.value = index;
    ManageLessonQuizTemplateEntity currentQuiz = quizList[index];
    knowledgeSingle.value = currentQuiz.template?.isKnowledgeSingle ?? false;

    knowledgeMinSelect.value = currentQuiz.template?.contentsLen?.min ?? 1;
    knowledgeMaxSelect.value = currentQuiz.template?.contentsLen?.max ?? 16;

    if (knowledgeSingle.value) {
      knowledgeMinSelect.value = 1;
    }

    selectKnowledgeUids.clear();
    knowledgeEnTextSelected = false;
  }

  void selectKnowledge(ManageUnitKnowledgeEntity data) {
    if (data.uid == null) return;

    if (selectKnowledgeUids.contains(data.uid)) {
      if (data.isEnText) {
        knowledgeEnTextSelected = false;
      }
      selectKnowledgeUids.remove(data.uid!);
      return;
    }

    if (knowledgeSingle.value) {
      selectKnowledgeUids.clear();
    }

    if (selectKnowledgeUids.length >= knowledgeMaxSelect.value) {
      ToastUtils.showManageToast(text: "最多可选择${knowledgeMaxSelect.value}个知识点");
      return;
    }

    if (data.isEnText) {
      if (knowledgeEnTextSelected) {
        ToastUtils.showManageToast(text: "只允许选择一个文章类型的知识点");
        return;
      }
      knowledgeEnTextSelected = true;
    }

    selectKnowledgeUids.add(data.uid!);
  }

  /// 下一步按钮 跳转至下一步页面
  Future<void> nextButton(BuildContext context) async {
    PlayAudioUtils.instance.stopAll();
    if (unitId == null) return;
    if (selectKnowledgeUids.isEmpty) return ToastUtils.showManageToast(text: "请选择知识点");
    

    List<ManageUnitKnowledgeEntity> knowledges = [];
    ManageLessonQuizTemplateEntity template = quizList[selectTemplateIndex.value];
    if (template.exerciseType == null) return;
    String quizType = template.exerciseType!;

    if(quizType == ExerciseType.CLOZE_TEST || quizType == ExerciseType.CLOZE_TEST_B || quizType == ExerciseType.CONTEXT_CHOICE || quizType == ExerciseType.CONTEXT_CHOICE_B){
      bool isText = false;
      for (var element in showKnowledgeList) {
        if(element.isEnText){
          isText = true;
          break;
        }
      }
      if(!isText){
        return ToastUtils.showManageToast(text: "文章类题目必须选择一个文章");
      }
    }

    if (quizType == ExerciseType.CROSS_WORD || quizType == ExerciseType.CLASSIFY_CHALLENGE) {
      List<ManageUnitKnowledgeEntity>? res = await showSelectKnowledgeDialog(context);
      if (res == null) return;
      if (knowledgeMinSelect.value > res.length) {
        return ToastUtils.showManageToast(text: "请选择最少${knowledgeMinSelect.value}个知识点");
      }
      knowledges = res;
    } else {
      if (!knowledgeSingle.value && !knowledgeEnTextSelected) {
        if (knowledgeMinSelect.value > selectKnowledgeUids.length) {
          return ToastUtils.showManageToast(text: "请选择最少${knowledgeMinSelect.value}个知识点");
        }
      }

      for (int i = 0; i < knowledgeList.length; i++) {
        if (knowledgeList[i].uid == null) continue;
        if (selectKnowledgeUids.contains(knowledgeList[i].uid)) {
          knowledges.add(knowledgeList[i]);
        }
      }
    }

    selectKnowledgeUids.clear();
    knowledgeEnTextSelected = false;

    // 准备跳转参数
    List<Map<String, dynamic>> argumentsKnowledgeList = [];
    for (var item in knowledges) {
      argumentsKnowledgeList.add(item.toJson());
    }
    final createQuizArguments = {
      "lessonQuizTemplate": template.toJson(),
      "knowledgeList": argumentsKnowledgeList,
      "unitId": unitId,
      "difficultyMin": difficultyMin,
      "difficultyMax": difficultyMax,
      "language": language,
      "lessonId": lessonId,
    };
    
    dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_CREATE_QUIZ,
      arguments: createQuizArguments,
    );
    if (res == true) {
      Get.back(result: true);
    }else{
      getReviewQuizCount();
    }
  }

  Future<List<ManageUnitKnowledgeEntity>?> showSelectKnowledgeDialog(BuildContext context) async {
    ManageLessonQuizTemplateEntity quizTemplate = quizList[selectTemplateIndex.value];

    List<ManageUnitKnowledgeEntity> initKnowledges = [];
    for (int i = 0; i < knowledgeList.length; i++) {
      if (knowledgeList[i].uid == null) continue;
      if (selectKnowledgeUids.contains(knowledgeList[i].uid)) {
        initKnowledges.add(knowledgeList[i]);
      }
    }

    return await ManageSelectKnowledgeDialog.show(
      context: context,
      unitId: unitId!,
      initKnowledges: initKnowledges.toList(),
      contentScope: quizTemplate.template?.contentScope ?? [],
      knowledgeSingle: knowledgeSingle.value,
      knowledgeMaxSelect: knowledgeMaxSelect.value,
      knowledgeMinSelect: knowledgeMinSelect.value,
      language: language,
      exerciseType: quizTemplate.exerciseType,
    );
  }

  /// 判断知识点是否可以点击
  bool isKnowledgeFore(ManageUnitKnowledgeEntity data) {
    if (selectTemplateIndex.value == -1) return false;
    if (data.content == null || data.content == "") return false;
    if (data.contentType == null || data.contentType == "") return false;
    if (data.semanticId == null && !data.isEnText) return false;
    if (quizList.isEmpty) return false;

    List<String?> contentScope = quizList[selectTemplateIndex.value].template?.contentScope ?? [];
    contentScope.removeWhere((e) => e == null);
    if (data.contentType != null) {
      bool type = contentScope.contains(data.contentType);
      if (!type) return false;
    }

    String quizBreakdownLevels = quizList[selectTemplateIndex.value].config?.breakdownLevel ?? "";
    if (data.breakdownLevel != null && quizBreakdownLevels.isNotEmpty) {
      List<String?> breakdownLevel = data.breakdownLevel ?? [];
      breakdownLevel.removeWhere((e) => e == null);
      bool breakdown = breakdownLevel.contains(quizBreakdownLevels);
      if (!breakdown) return false;
    }

    return true;
  }

  /// 取消按钮
  void onCancel() {
    Get.back();
  }

  /// 题目待审核
  Future<void> toReviewQuiz() async{
    if(lessonId == null) return;
    if(reviewQuizCount.value == 0) return ToastUtils.showToast(text: "暂无待审核题目");
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_EXERCISES,
      arguments: {
        "lessonId": lessonId,
      },
    );
    getReviewQuizCount();
  }

  @override
  void onClose() {
    searchKnowledginput.dispose();
    super.onClose();
  }
}
