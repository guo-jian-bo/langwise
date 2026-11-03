import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../../../routes/tag_routes.dart';
import '../../../../management/dialog/manage_show_delete_option_dialog.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';

class ManageQuizListController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageQuizListController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_QUIZ_LIST;

  @override
  String get breadcrumbTitle => '题目列表';

  int? quizId;
  int? lessonId;
  int? moduleId;
  int? unitId;
  int? lessonTemplateId;
  int? difficultyMin;
  int? difficultyMax;
  String? language;

  final RxInt lessonQuizCount = 0.obs;
  final RxList<QuizModel> lessonQuizList = <QuizModel>[].obs;

  /// 是否打开批量操作
  final RxBool isOpenBatchOperation = false.obs;

  /// 批量操作 选择的题目id
  final RxList<int> batchOperationIds = <int>[].obs;

  /// 是否全选
  final RxBool isSelectAll = false.obs;

  /// 是否全选上架
  final RxBool isSelectAllPublished = false.obs;

  /// 是否全选下架
  final RxBool isSelectAllUnPublished = false.obs;

  /// 当前列表筛选：all / published / unpublished
  final RxString currentFilter = "all".obs;

  List<QuizModel> get filteredLessonQuizList {
    switch (currentFilter.value) {
      case "published":
        return lessonQuizList.where((item) => item.accessNormal).toList();
      case "unpublished":
        return lessonQuizList.where((item) => item.accessInternal).toList();
      default:
        return lessonQuizList.toList();
    }
  }

  int get publishedQuizCount => lessonQuizList.where((item) => item.accessNormal).length;

  int get unpublishedQuizCount => lessonQuizList.where((item) => item.accessInternal).length;

  bool get isAllFilteredSelected {
    final List<int> visibleIds = filteredLessonQuizList.where((item) => item.uid != null).map((item) => item.uid!).toList();
    if (visibleIds.isEmpty) return false;
    return visibleIds.every(batchOperationIds.contains);
  }

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if (Get.arguments != null) {
      quizId = Get.arguments['quizId'];
      lessonId = Get.arguments['lessonId'];
      moduleId = Get.arguments['moduleId'];
      unitId = Get.arguments['unitId'];
      lessonTemplateId = Get.arguments['lessonTemplateId'];
      difficultyMin = Get.arguments['difficultyMin'];
      difficultyMax = Get.arguments['difficultyMax'];
      language = Get.arguments['language'];
      getLessonQuizList();
    }
  }

  bool get hasLessonActionContext => lessonId != null && unitId != null;

  bool get hasCreateQuizContext => hasLessonActionContext && lessonTemplateId != null;

  /// 获取课时下已经添加的题目列表
  Future<void> getLessonQuizList({bool showToast = true}) async {
    try {
      ToastUtils.showLoading();
      lessonQuizCount.value = 0;

      if (lessonId == null) return;

      List<PlanQuizEntityExercises>? resExercises = await ManageSelectQuziKnowledge.getCourseLessonExerciseList(lessonId: lessonId!);
      if (resExercises == null) return;
      List<QuizModel> resQuizList = [];
      for (var element in resExercises) {
        QuizModel? item = element.exercise;
        if(item == null) continue;
        resQuizList.add(element.exercise!);
      }

      lessonQuizList.value = resQuizList;
      lessonQuizCount.value = lessonQuizList.length;

      if (showToast) {
        ToastUtils.showManageToast(text: "刷新成功");
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 排序
  Future<void> sortQuizList(int oldIndex, int newIndex) async {
    if (lessonId == null) return;
    try {
      ToastUtils.showLoading();
      final QuizModel row = lessonQuizList.removeAt(oldIndex);
      if (row.uid == null) return;
      lessonQuizList.insert(newIndex, row);
      bool res = await ManageSelectQuziKnowledge.editQuizOrder(lessonId!, newIndex + 1, row.uid!);
      if (!res) {
        final QuizModel row = lessonQuizList.removeAt(newIndex);
        lessonQuizList.insert(oldIndex, row);
        return;
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 显示删除菜单
  Future<void> showDeleteQuizDialog(BuildContext context, int index) async {
    int? deleteRes = await ManageShowDeleteOptionDialog().show(
      context: context,
      selectedCount: 1,
    );
    if (deleteRes == null) return;
    String method = "";
    if (deleteRes == 0) {
      method = "database_delete";
    } else {
      method = "course_delete";
    }

    if (lessonQuizList[index].uid == null) return;
    quizOperation(method, [lessonQuizList[index].uid!], "删除");
  }

  /// 上下架
  Future<void> upDownLessonQuiz(bool isUp) async {
    if (lessonId == null) return;
    if (batchOperationIds.isEmpty) return ToastUtils.showManageToast(text: "请先选择题目");
    quizOperation(
      isUp ? "batch_shelf_on" : "batch_shelf_off",
      batchOperationIds,
      isUp ? "上架" : "下架",
    );
  }

  Future<void> quizOperation(String method, List<int> ids, String text) async {
    if (lessonId == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> data = {
        "exerciseIds": ids,
        "lessonId": lessonId,
      };
      bool res = await ManageSelectQuziKnowledge.quizOperation(data, method);
      if (!res) return;
      batchOperationIds.clear();
      isSelectAll.value = false;
      ToastUtils.showManageToast(text: "$text成功");
      await getLessonQuizList();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> refreshLessonPlan() async {
    if (!hasLessonActionContext) {
      ToastUtils.showManageToast(text: "缺少课时上下文，暂时无法刷新课时计划");
      return;
    }

    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.refreshLessonPlan(
        unitId: unitId.toString(),
        lessonId: lessonId.toString(),
        config: RequestConfig(requireToken: true),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      await getLessonQuizList(showToast: false);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> regenerateLessonQuiz() async {
    if (!hasLessonActionContext) {
      ToastUtils.showManageToast(text: "缺少课时上下文，暂时无法重新生成题目");
      return;
    }

    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.generateLessonTitle(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            "lessonIds": [lessonId.toString()]
          },
        ),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      await getLessonQuizList(showToast: false);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> toSelectKnowledgePage() async {
    if (!hasCreateQuizContext) {
      ToastUtils.showManageToast(text: "缺少创建题目所需参数");
      return;
    }
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_SELECT_QUZI_KNOWLEDGE,
      arguments: {
        "lessonTemplateId": lessonTemplateId,
        "unitId": unitId,
        "moduleId": moduleId,
        "difficultyMin": difficultyMin,
        "difficultyMax": difficultyMax,
        "language": language,
        "lessonId": lessonId,
      },
    );
    await getLessonQuizList(showToast: false);
  }

  /// 跳转到做题页面 演示
  Future<void> toDemonstrate(int index) async {
    if (lessonQuizList.isEmpty) return;
    if (lessonQuizList.length <= index) return;
    dynamic res = await TagRoutes.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "currentQuizId": lessonQuizList[index].uid,
        "quizDatas": lessonQuizList.toList(),
        "isShowUpDownStatus": true,
        "isAdminPage": true,
      },
    );
    if (res == null) return;
    Map<String, dynamic> resMap = res as Map<String, dynamic>;
    if (resMap["isEdit"] != true) return;
    String? manageRoute = resMap["manageRoute"];
    if (manageRoute == null || manageRoute.isEmpty) return;
    int? uid = resMap["quizId"];
    if (uid == null) return;
    await ManagePageRegistry.jumpTo(
      manageRoute,
      arguments: {
        "quizId": uid,
      },
    );
    await getLessonQuizList();



  }

  /// 选择题目
  void selectQuiz(int? uid) {
    if (lessonQuizList.isEmpty) return;
    if (uid == null) return;
    if (batchOperationIds.contains(uid)) {
      batchOperationIds.remove(uid);
    } else {
      batchOperationIds.add(uid);
    }

    isSelectAll.value = isAllFilteredSelected;
  }

  void changeFilter(String filter) {
    currentFilter.value = filter;
    isSelectAll.value = isAllFilteredSelected;
  }

  /// 全选上架/取消
  void selectPublished() {
    isSelectAllPublished.value = !isSelectAllPublished.value;
    batchOperationIds.clear();
    if (isSelectAllPublished.value) {
      for (var quiz in lessonQuizList) {
        if (quiz.accessNormal) {
          batchOperationIds.add(quiz.uid!);
        }
      }
    }
  }

  /// 全选下架/取消
  void selectUnPublished() {
    isSelectAllUnPublished.value = !isSelectAllUnPublished.value;
    batchOperationIds.clear();
    if (isSelectAllUnPublished.value) {
      for (var quiz in lessonQuizList) {
        if (quiz.accessInternal) {
          batchOperationIds.add(quiz.uid!);
        }
      }
    }
  }

  /// 批量删除
  Future<void> showBatchDeleteQuizDialog(BuildContext context) async {
    if (batchOperationIds.isEmpty) {
      ToastUtils.showManageToast(text: "请先选择题目");
      return;
    }
    int? deleteRes = await ManageShowDeleteOptionDialog().show(
      context: context,
      selectedCount: batchOperationIds.length,
    );
    if (deleteRes == null) return;
    String method = "";
    if (deleteRes == 0) {
      method = "database_delete";
    } else {
      method = "course_delete";
    }

    if (batchOperationIds.isEmpty) return;
    await quizOperation(method, batchOperationIds, "删除");
    batchOperationIds.clear();
  }

  /// 全选/取消全选
  void selectAllQuiz() {
    if (isSelectAll.value) {
      batchOperationIds.clear();
    } else {
      for (int i = 0; i < lessonQuizList.length; i++) {
        if (lessonQuizList[i].uid == null) continue;
        if (batchOperationIds.contains(lessonQuizList[i].uid!)) continue;
        batchOperationIds.add(lessonQuizList[i].uid!);
      }
    }

    isSelectAll.value = batchOperationIds.length == lessonQuizList.length;
  }

  /// 全选当前筛选下可见题目
  void selectAllFilteredQuiz() {
    for (final item in filteredLessonQuizList) {
      if (item.uid == null) continue;
      if (batchOperationIds.contains(item.uid!)) continue;
      batchOperationIds.add(item.uid!);
    }
    isSelectAll.value = isAllFilteredSelected;
  }

  /// 取消全选当前筛选下可见题目
  void clearFilteredSelection() {
    final List<int> visibleIds = filteredLessonQuizList.where((item) => item.uid != null).map((item) => item.uid!).toList();
    batchOperationIds.removeWhere((id) => visibleIds.contains(id));
    isSelectAll.value = isAllFilteredSelected;
  }

  /// 关联题目
  Future<void> relatedTopics() async {
    dynamic resExerciseIds = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_SELECT_EXERCISES,
      arguments: {
        "lessonId": lessonId,
      },
    );
    if (resExerciseIds == null) return;

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> data = {
        "lessonId": lessonId,
        "exerciseIds": resExerciseIds,
      };

      bool res = await ManageSelectQuziKnowledge.exerciseLessonBind(data);
      if (!res) return;
      ToastUtils.showManageToast(text: "关联成功");
      getLessonQuizList(showToast: false);
    } finally {
      ToastUtils.hideLoading();
    }
  }
}
