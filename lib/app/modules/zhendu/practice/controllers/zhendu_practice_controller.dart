import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../../common/https/https.dart';
import '../../../../../common/entities/zhendu_detil_entity.dart';
import '../../../../../common/widgets/feedback_error_content_dialog.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';

class ZhenduPracticeController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  ZhenduPracticeController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENDU_PRACTICE;

  @override
  String get breadcrumbTitle => "甄读剧场·练";

  /// type: unit, favorite, collection, none
  String? type;
  int? typeId;
  /// 用作当前知识点的id
  int? contentId;
  /// 用作当前知识点的类型
  String? contentType;
  List<Map<String, dynamic>> contents = const <Map<String, dynamic>>[];
  int? styleId;
  String? dialect;
  int? milliseconds;
  /// 是否是管理端的标识
  String? traceAdminHeader;

  final RxBool isLoading = false.obs;
  final RxInt loadStatus = (-1).obs;

  final RxList<QuizModel> quizDatas = <QuizModel>[].obs;
  final RxInt currentQuizIndex = 0.obs;
  final RxBool isCompleted = false.obs;

  final Rx<ZhenduDetilEntity?> playInfo = Rx<ZhenduDetilEntity?>(null);
  final RxList<ZhenduLearnItems> pageTypeList = <ZhenduLearnItems>[].obs;

  StreamController<QuizStateType>? stateController = StreamController<QuizStateType>.broadcast();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      type = Get.arguments["type"];
      typeId = Get.arguments["typeId"];
      contentId = Get.arguments["contentId"];
      contentType = Get.arguments["contentType"];
      styleId = Get.arguments["styleId"];
      dialect = Get.arguments["dialect"];
      milliseconds = Get.arguments["milliseconds"];

      try {
        List? argList = Get.arguments["contents"];
        if(argList != null){
          final argContents = <Map<String, dynamic>>[];
          for (var item in argList) {
            argContents.add(item as Map<String, dynamic>);
          }
          contents = argContents;
        }
      } catch (_) {}
      initPage();
    }

  }

  @override
  void onClose() {
    stateController?.close();
    stateController = null;
    super.onClose();
  }

  Future<void> initPage() async {
    if (contentId == null ) {
      loadStatus.value = 2;
      if (kDebugMode) debugPrint('[ZhenduPractice] invalid arguments: ${Get.arguments}');
      return;
    }

    isLoading.value = true;
    loadStatus.value = -1;
    quizDatas.clear();
    pageTypeList.clear();
    currentQuizIndex.value = 0;
    isCompleted.value = false;

    ToastUtils.showLoading();
    try {
      final queryParameters = <String, dynamic>{};
      if (styleId != null) queryParameters['styleId'] = styleId;
      final dialectValue = dialect?.trim() ?? '';
      if (dialectValue.isNotEmpty) queryParameters['dialect'] = dialectValue;
      final detail = await HomeRequest.getQuizListByContentExerciseDetail(
        type:  contentType,
        contentId: contentId,
        parameters: queryParameters.isEmpty ? null : queryParameters,
        traceAdminHeader: traceAdminHeader,
      );
      if (detail == null || detail.quizList.isEmpty) {
        loadStatus.value = 2;
        if (kDebugMode) debugPrint('[ZhenduPractice] empty quizList, scriptUid: $contentId');
        return;
      }

      quizDatas.assignAll(detail.quizList);
      pageTypeList.assignAll(detail.learnItems);
      loadStatus.value = 0;
    } catch (e) {
      loadStatus.value = 1;
      if (kDebugMode) debugPrint('[ZhenduPractice] load failed: $e');
    } finally {
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }



  String? get title => playInfo.value?.contentInfo?.title;

  Future<void> showFeedbackErrorContentDialog(BuildContext context) async {
    final info = playInfo.value;
    await FeedbackErrorContentDialog.show(
      context: context,
      position: null,
      name: info?.contentInfo?.title,
      content: info?.contentInfo?.content,
      contentType: info?.contentType ?? contentType ?? 'SCRIPT',
      contentId: info?.contentId ?? contentId,
    );
  }

  void nextQuiz() {
    if (quizDatas.isEmpty) return;
    if (currentQuizIndex.value >= quizDatas.length - 1) {
      isCompleted.value = true;
      ToastUtils.showToast(text: '练习已完成', type: ToastType.success);
      return;
    }
    currentQuizIndex.value++;
  }

  Future<void> retry() async {
    await initPage();
  }
}
