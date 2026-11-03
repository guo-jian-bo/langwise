import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../../management/dialog/manage_show_delete_option_dialog.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';
import '../../../controllers/manage_setting_controller.dart';
import 'package:langwise/common/enum/enum.dart';

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

  final RxInt lessonQuizTotalTime = 0.obs;
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

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if (Get.arguments != null) {
      quizId = Get.arguments['quizId'];
      lessonId = Get.arguments['lessonId'];
      moduleId = Get.arguments['moduleId'];
      getLessonQuizList();
    }
  }

  /// 获取课时下已经添加的题目列表
  Future<void> getLessonQuizList({bool showToast = true}) async {
    try {
      ToastUtils.showLoading();
      lessonQuizTotalTime.value = 0;
      lessonQuizCount.value = 0;

      if (lessonId == null) return;
      List<LessonExerciseInfoEntity>? resIds = await ManageSelectQuziKnowledge.getLessonQuizList(lessonId!);
      if (resIds == null) return;
      List<int> exerciseIds = [];
      int estimated = 0;
      for (int i = 0; i < resIds.length; i++) {
        estimated += resIds[i].estimated ?? 0;
        if (resIds[i].exerciseId == null) continue;
        exerciseIds.add(resIds[i].exerciseId!);
      }

      if (exerciseIds.isEmpty) {
        lessonQuizList.clear();
        lessonQuizCount.value = 0;
        lessonQuizTotalTime.value = 0;
        return;
      }
      final int mediaMode = ManageSettingController.to.defaultResources.value == ResourceTypeEnum.image ? 0 : 1;
      final String? style = ManageSettingController.to.defaultStyle.value.style;
      List<QuizModel>? resQuizList = await ManageSelectQuziKnowledge.getQuizListByIds(
        exerciseIds,
        mediaMode: mediaMode,
        styleCodes: (style != null && style.isNotEmpty) ? [style] : null,
        moduleId: moduleId,
      );
      if (resQuizList == null) return;

      for (int i = 0; i < resIds.length; i++) {
        if (resIds[i].exerciseId == null) continue;
        for (int j = 0; j < resQuizList.length; j++) {
          if (resIds[i].exerciseId == resQuizList[j].uid) {
            resQuizList[j].reason = resIds[i].upDown.toString();
          }
        }
      }

      lessonQuizList.value = resQuizList;
      lessonQuizCount.value = lessonQuizList.length;
      lessonQuizTotalTime.value = estimated;

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
    );
    if (deleteRes == null) return;
    bool res = false;
    String method = "";
    if (deleteRes == 0) {
      method = "database_delete";
      res = await AskDialog.show(
        context: context,
        title: "确定要从 后台数据中 删除该题？",
        content: "该题会从数据库中永久删除，并且不可恢复。",
        define: "确定删除",
        defineColor: const Color(0xffFF2D46),
        titleColor: const Color(0xffFF2D46),
      );
    } else {
      method = "course_delete";
      res = await AskDialog.show(
        context: context,
        title: "确定要从当前课程中删除该题？",
        content: "该题会从当前课程中删除，后期可再次添加。",
        define: "确认删除",
        defineColor: const Color(0xffFF2D46),
      );
    }
    if (!res) return;

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

  /// 跳转到做题页面 演示
  Future<void> toDemonstrate(int index) async {
    if (lessonQuizList.isEmpty) return;
    if (lessonQuizList.length <= index) return;
    dynamic res = await Get.toNamed(
      Routes.PRACTICE_QUESTIONS,
      preventDuplicates: false,
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

    isSelectAll.value = batchOperationIds.length == lessonQuizList.length;
  }

  /// 全选上架/取消
  void selectPublished() {
    isSelectAllPublished.value = !isSelectAllPublished.value;
    batchOperationIds.clear();
    if (isSelectAllPublished.value) {
      for (var quiz in lessonQuizList) {
        if (quiz.reason == "1") {
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
        if (quiz.reason == "0") {
          batchOperationIds.add(quiz.uid!);
        }
      }
    }
  }

  /// 批量删除
  Future<void> showBatchDeleteQuizDialog(BuildContext context) async {
    int? deleteRes = await ManageShowDeleteOptionDialog().show(
      context: context,
    );
    if (deleteRes == null) return;
    bool res = false;
    String method = "";
    if (deleteRes == 0) {
      method = "database_delete";
      res = await AskDialog.show(
        context: context,
        title: "确定要从 后台数据中 删除选中的题？",
        content: "选中的题会从数据库中永久删除，并且不可恢复。",
        define: "确定删除",
        defineColor: const Color(0xffFF2D46),
        titleColor: const Color(0xffFF2D46),
      );
    } else {
      method = "course_delete";
      res = await AskDialog.show(
        context: context,
        title: "确定要从当前课程中删除选中的题？",
        content: "选中的题会从当前课程中删除，后期可再次添加。",
        define: "确认删除",
        defineColor: const Color(0xffFF2D46),
      );
    }
    if (!res) return;

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

  @override
  void onClose() {
    super.onClose();
  }
}
