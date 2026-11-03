import 'package:get/get.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/tag_routes.dart';
import 'zhenxie_task_details_controller.dart';

class ZhenxieTaskExerciseController extends GetxController {
  final String tagText;
  ZhenxieTaskExerciseController({required this.tagText});

  /// 页面主控制器，用于读取当前模式与路由参数。
  ZhenxieTaskDetailsController? _pageController;

  /// 当前范文练习列表详情。
  final Rxn<ZhenxieTaskExerciseEntity> exerciseData = Rxn<ZhenxieTaskExerciseEntity>();

  /// 当前范文练习卡片列表。
  final RxList<ZhenxieTaskExerciseItemEntity> exerciseList = <ZhenxieTaskExerciseItemEntity>[].obs;


  /// 当前是否正在请求练习列表。
  final RxBool isLoading = false.obs;

  /// 绑定页面主控制器，后续通过主控制器读取页面上下文。
  void bindPageController(ZhenxieTaskDetailsController controller) {
    _pageController = controller;
  }

  /// 当前绑定的页面主控制器。
  ZhenxieTaskDetailsController pageController() {
    return _pageController!;
  }

  /// 切到练习 tab 时按需加载数据，已经成功加载过就直接复用。
  Future<void> ensureExerciseListLoaded() async {
    if (exerciseList.isNotEmpty || isLoading.value) return;
    await getExerciseList();
  }

  /// 请求当前范文对应的练习列表。
  Future<void> getExerciseList() async {
    final pageController = this.pageController();
    int? compositionId = pageController.compositionUid ?? pageController.exemplarController.exemplarDetailsData.value?.uid;
    int? unitId = pageController.unitId ?? pageController.exemplarController.exemplarDetailsData.value?.memberWriting?.unitId;
    // compositionId = 8;
    // unitId = 14193;

    if (compositionId == null || unitId == null) return;
    isLoading.value = true;
    try {
      ZhenxieTaskExerciseEntity? entity;
      if (pageController.isManagement) {
        entity = await CourseConsoleRequest.getUnitWritingExemplarExerciseList(
          unitId: unitId,
          params: {
            "compositionId": compositionId,
          },
        );
      } else {
        entity = await CourseAppUtil.getWritingExemplarExerciseList(
          params: {
            "unitId": unitId,
            "compositionId": compositionId,
          },
        );
      }
      if (entity == null) return;
      exerciseData.value = entity;
      exerciseList.assignAll(entity.list ?? const <ZhenxieTaskExerciseItemEntity>[]);
    } finally {
      isLoading.value = false;
    }
  }

  /// 去做题
  Future<void> toDoExercise(ZhenxieTaskExerciseItemEntity data) async {
    List<QuizModel> quizList = [];

    for (var i = 0; i < exerciseList.length; i++) {
      if(exerciseList[i].exercise == null) continue;
      exerciseList[i].exercise?.context = exerciseList[i].context;
      quizList.add(exerciseList[i].exercise!);
    }

    if(quizList.isEmpty) return;

   await TagRoutes.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "currentQuizId": data.exercise?.uid,
        "quizDatas": quizList,
        "questionIsReport": true,
        "isShowPercentageProgress": true,
      },
    );
    
  }

  


}
