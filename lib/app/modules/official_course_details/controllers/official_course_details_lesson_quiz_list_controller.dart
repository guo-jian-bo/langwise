import 'dart:async';

import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../common/mixins/mixins.dart';
import '../controllers/official_course_details_controller.dart';

class OfficialCourseDetailsLessonQuizListController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  OfficialCourseDetailsLessonQuizListController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.OFFICIAL_COURSE_DETAILS_LESSON_QUIZ_LIST;

  @override
  String get breadcrumbTitle => "题目列表";

  /// 父页面 controller 的 tag，用于复用课程详情已有的数据请求与跳题逻辑。
  String? parentTagText;

  int? unitId;
  int? lessonId;
  String? title;

  late final OfficialCourseDetailsController detailsController;

  /// 当前列表数据。
  final Rxn<LessonQuizData> lessonQuizData = Rxn<LessonQuizData>();

  /// 页面 loading 状态。
  final RxBool isLoading = true.obs;

  /// 当前点击中的题目索引，用于高亮角标。
  final RxInt currentIndex = 0.obs;

  bool _hasRequestedInitialData = false;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      parentTagText = Get.arguments['parentTagText'];
      unitId = Get.arguments['unitId'];
      lessonId = Get.arguments['lessonId'];
      title = Get.arguments['title'];
    }
    if ((title ?? '').isNotEmpty) {
      updateBreadcrumbTitle(title!);
    }
    detailsController = Get.find<OfficialCourseDetailsController>(tag: parentTagText);
  }

  @override
  void onReady() {
    super.onReady();
    if (_hasRequestedInitialData) return;
    _hasRequestedInitialData = true;
    unawaited(loadLessonQuizData());
  }

  /// 拉取当前课时的题目列表。
  Future<void> loadLessonQuizData() async {
    final context = Get.context;
    if (context == null) return;
    try {
      isLoading.value = true;
      lessonQuizData.value = await detailsController.fetchLessonQuizData(context, unitId, lessonId);
    } finally {
      isLoading.value = false;
    }
  }

  /// 进入做题页，返回后刷新题目进度。
  Future<void> openQuiz(int index) async {
    final data = lessonQuizData.value;
    if (data == null) return;
    final quiz = data.quizList[index];

    currentIndex.value = index;
    await detailsController.toQuizPage(
      data.unitId,
      data.lessonId,
      quiz.uid ?? data.exerciseCurrentId,
      data.quizList,
    );
    if (isClosed) return;

    await Future.delayed(const Duration(milliseconds: 200));
    if (isClosed) return;
    await loadLessonQuizData();
  }
}
