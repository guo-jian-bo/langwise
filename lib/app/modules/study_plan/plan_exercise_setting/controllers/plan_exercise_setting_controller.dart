import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';

class PlanExerciseSettingController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  PlanExerciseSettingController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.PLAN_EXERCISE_SETTING;

  @override
  String get breadcrumbTitle => "全局题型设置";

  // ===== 传进来的参数 =====
  int? courseId;
  /// 选中的课时
  List<String> directionList = [];
  /// 禁用的题目类型
  List<String> disabledExerciseTypes = [];  

  /// 原始数据
  final Rx<CourseDirectionExerciseEntity> exerciseEntity = CourseDirectionExerciseEntity().obs;

  /// 选择的题目类型
  final RxList<String> selectedExerciseTypes = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      courseId = Get.arguments["courseId"];
      directionList = Get.arguments["directionList"]?.cast<String>()??[];
      disabledExerciseTypes = Get.arguments["disabledExerciseTypes"]?.cast<String>()??[];
      selectedExerciseTypes.addAll(disabledExerciseTypes);
      
      getExerciseData();
    }
  }

  ///获取题目数据
  Future<void> getExerciseData() async{
    if(courseId == null) return;
    
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "courseId": courseId,
        "directionList": directionList,
      };
      CourseDirectionExerciseEntity? entity = await StudyAppRequest.getExerciseData(data: reqData);
      if(entity == null) return;
      exerciseEntity.value = entity;

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 选择题目类型
  void selectExerciseType(CourseDirectionExerciseEntityExerciseCategoryListExerciseList? exercise){
    if(exercise == null) return;
    String? type = exercise.exerciseType;
    if(type == null) return;
  
    if(selectedExerciseTypes.contains(type)){
      selectedExerciseTypes.remove(type);
    } else {
      if(exercise.required == true){
        return ToastUtils.showToast(text: exercise.requiredBriefs?.join("\n").toString() ?? "必备题目不能禁用");
      }
      selectedExerciseTypes.add(type);
    }
  }


  /// 预览题目
  Future<void> previewExercise(QuizModel? exercise) async{
    if(exercise == null) return;
    try {
      ToastUtils.showLoading();
      await CacheManagerUtils.instance.cacheQuizAssetsFirstTwo([exercise]);
    } finally{
      ToastUtils.hideLoading();
    }
    Get.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "quizDatas": [exercise],
      },
    );
  }


  /// 确认选择 {"exerciseType": "SOUND_BLOCKS", "exerciseName": "声部烙刻", "category": "听口"}
  void confirmSelect(){
    List<CourseDirectionExerciseEntityExerciseCategoryList?> exerciseCategoryList = exerciseEntity.value.exerciseCategoryList??[];
    if(exerciseCategoryList.isEmpty) return;
    List<PlanEntityDisableExerciseTypeInfos> disableExerciseTypeInfos = [];
    
    for(CourseDirectionExerciseEntityExerciseCategoryList? category in exerciseCategoryList){
      if(category == null) continue;
      List<CourseDirectionExerciseEntityExerciseCategoryListExerciseList?> exerciseList = category.exerciseList??[];
      for(CourseDirectionExerciseEntityExerciseCategoryListExerciseList? exercise in exerciseList){
        if(exercise?.exerciseType == null) continue;
        if(selectedExerciseTypes.contains(exercise?.exerciseType)){
          
          disableExerciseTypeInfos.add(PlanEntityDisableExerciseTypeInfos(
            category: category.category??"",
            categoryName: category.title??"",
            exerciseType: exercise?.exerciseType??"",
            exerciseTypeName: exercise?.name??"",
            requiredLessons: exercise?.requiredLessons,
          ));

        }
      }
    }
    Get.back(result: disableExerciseTypeInfos);
  }



  @override
  void onClose() {
    super.onClose();
  }
}
