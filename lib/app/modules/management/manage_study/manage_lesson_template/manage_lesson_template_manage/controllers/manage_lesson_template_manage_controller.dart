import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../utils/manage_page_registry.dart';

class ManageLessonTemplateManageController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageLessonTemplateManageController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_LESSON_TEMPLATE_MANAGE;

  @override
  String get breadcrumbTitle => '课时模板管理';

  int? lessonTemplateUid;
  final RxList<ManageLessonQuizTemplateEntity> quizList = <ManageLessonQuizTemplateEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      lessonTemplateUid = Get.arguments["lessonTemplateUid"];
    }
    getQuizData();
  }

  Future<void> getQuizData() async {
    if (lessonTemplateUid == null) return;
    List<ManageLessonQuizTemplateEntity>? resList = await ManageLessonTemplateRequest.getLessonQuizList(lessonTemplateUid!);
    if (resList == null) return;
    quizList.value = resList;
  }

  /// 选择题型模版并添加
  Future<void> selectQuizTemplate(BuildContext context) async {
    if (lessonTemplateUid == null) return;

    dynamic selectRes = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_CONFIG_EXERCISES,
      arguments: {
        "pageType": "single",
      },
    );
    if (selectRes == null) return;
    List selectResList = selectRes;
    if (selectResList.isEmpty) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "uid": selectResList.first,
      };

      bool res = await CourseConsoleRequest.lessonTemplateBindConfig(lessonTemplateUid!, reqData);
      if (!res) return;
      ToastUtils.showToast(text: "绑定成功", type: ToastType.success);
      getQuizData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 删除模版
  Future<void> deleteQuiz(BuildContext context, ManageLessonQuizTemplateEntity data) async {
    if (quizList.length == 1) {
      return ToastUtils.showToast(text: "至少保留一个模版");
    }
    if (lessonTemplateUid == null) return;
    bool? ask = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确定要移除该模板吗？",
      contentColor: AppTheme.cSurfaceError.color,
      defineColor: AppTheme.cSurfaceError.color,
      define: "确认移除",
    );
    if (!ask) return;
    try {
      List<int> configlds = [];

      for (int i = 0; i < quizList.length; i++) {
        if (quizList[i].config?.uid == null) continue;
        if (quizList[i].config?.uid == data.config?.uid) continue;
        configlds.add(quizList[i].config!.uid!);
      }

      Map<String, dynamic> reqData = {
        "configIds": configlds,
      };
      ToastUtils.showLoading();
      bool resp = await CourseConsoleRequest.editLessonTemplateConfig(lessonTemplateUid!, reqData);
      if (!resp) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      getQuizData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 编辑题目模版
  Future<void> showQuizDialog(BuildContext context, ManageLessonQuizTemplateEntity? data, int index) async {
    if (data == null) return;
    if (lessonTemplateUid == null) return;

    QuizConfigDialogResult? quizRes = await QuizConfigDialog.show(
      context: context,
      showDscribe: true,
      data: ManageQuizTemplateEntity(
        exercise: data.exercise,
        template: data.template,
        description: data.description,
      ),
    );
    if (quizRes == null) return;

    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确定要修改该模版吗？修改后会影响使用此模版的所有题目",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "uid": quizRes.quizModelConfig.uid,
      };
      Map<String, dynamic> reqData = {
        "description": quizRes.desc,
        "config": quizRes.quizModelConfig.toJson(),
        "estimatedTime": quizRes.quizData?.estimatedTime,
        "exerciseType": quizRes.quizData?.type,
      };
      bool res = await CourseConsoleRequest.editConfigExercise(parameters, reqData);
      if (!res) return;
      ToastUtils.showToast(text: "编辑成功", type: ToastType.success);
      getQuizData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 重新排序
  Future<void> onReorder(int oldIndex, int newIndex) async {
    if (lessonTemplateUid == null) return;

    try {
      Map<String, dynamic> reqData = {
        "configId": quizList[oldIndex].config?.uid,
        "target": newIndex + 1,
      };
      ToastUtils.showLoading();
      bool resp = await ManageLessonTemplateRequest.sortLessonTemplateQuiz(reqData, lessonTemplateUid!);
      if (!resp) return;
      ToastUtils.showToast(text: "排序成功", type: ToastType.success);
      getQuizData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

}
