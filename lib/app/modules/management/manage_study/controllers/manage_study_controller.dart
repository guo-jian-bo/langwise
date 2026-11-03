
import 'package:get/get.dart';

import '../../../../routes/routes.dart';
import '../../models/manage_auth_menu_model.dart';
import '../../utils/manage_auth_utils.dart';
import '../../utils/manage_breadcrumb_utils.dart';
import '../../utils/manage_page_registry.dart';

class ManageStudyController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageStudyController({required this.tag});

  /// 学习
  final RxList<ManageAuthMenuModel> manageStudyList = <ManageAuthMenuModel>[].obs;
  /// 学习资源
  final RxList<ManageAuthMenuModel> manageStudyResourcesList = <ManageAuthMenuModel>[].obs;
  /// 题目资源
  final RxList<ManageAuthMenuModel> manageExerciseResourcesList = <ManageAuthMenuModel>[].obs;
  
  @override
  String get breadcrumbRoute => Routes.MANAGE_STUDY;
  
  @override
  String get breadcrumbTitle => '学习';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    initAuth();
  }


  void initAuth(){
    manageStudyList.clear();

    if(ManageAuthUtils.isAuth(ManageAuthCode.coursePages)){
      manageStudyList.add(ManageAuthMenuModel(
        name: "课程",
        subtitle: "管理系统中的所有课程信息",
        authCode: ManageAuthCode.coursePages,
        route: Routes.MANAGE_COURSE_LIST,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.coursePages)){
      manageStudyList.add(ManageAuthMenuModel(
        name: "自然拼读课",
        subtitle: "自然拼读专项课程管理",
        authCode: ManageAuthCode.coursePages,
        route: Routes.MANAGE_PHONICS_COURSE,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.courseLevelPages)){
      manageStudyList.add(ManageAuthMenuModel(
        name: "等级",
        subtitle: "课程难度分级与标准管理",
        authCode: ManageAuthCode.courseLevelPages,
        route: Routes.MANAGE_LEVEL,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.courseModulePages)){
      manageStudyList.add(ManageAuthMenuModel(
        name: "模块",
        subtitle: "教学内容的逻辑分组模块",
        authCode: ManageAuthCode.courseModulePages,
        route: Routes.MANAGE_MODULE,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.courseUnitPages)){
      manageStudyList.add(ManageAuthMenuModel(
        name: "单元",
        subtitle: "具体的教学单元章节内容",
        authCode: ManageAuthCode.courseUnitPages,
        route: Routes.MANAGE_UNIT,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.courseLessonPages)){
      manageStudyList.add(ManageAuthMenuModel(
        name: "课时",
        subtitle: "最小的教学互动课时单位",
        authCode: ManageAuthCode.courseLessonPages,
        route: Routes.MANAGE_LESSON,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.courseLessonTemplatePages)){
      manageStudyList.add(ManageAuthMenuModel(
        name: "课时模版",
        subtitle: "预设的课时结构和布局模版",
        authCode: ManageAuthCode.courseLessonTemplatePages,
        route: Routes.MANAGE_LESSON_TEMPLATE,
      ));
    }

    

    // =============== 学习资源 ===================
    if (ManageAuthUtils.isAuth(ManageAuthCode.bookPages)) {
      manageStudyResourcesList.add(ManageAuthMenuModel(
        name: "教材词汇扫描",
        subtitle: "扫描教材词汇，管理书籍和词汇表",
        authCode: ManageAuthCode.bookPages,
        route: Routes.MANAGE_BOOK_SCAN,
      ));
    }

    // =============== 题目资源 ===================
    

    if(ManageAuthUtils.isAuth(ManageAuthCode.exercisePage)){
      manageExerciseResourcesList.add(ManageAuthMenuModel(
        name: "题目",
        subtitle: "练习题和测验题目",
        authCode: ManageAuthCode.exercisePage,
        route: Routes.MANAGE_EXERCISE_LIST,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.exerciseTemplateList)){
      manageExerciseResourcesList.add(ManageAuthMenuModel(
        name: "题目模版",
        subtitle: "定义不同题型的结构和交互模版",
        authCode: ManageAuthCode.exerciseTemplateList,
        route: Routes.MANAGE_QUIZ_TEMPLATE,
      ));
    }
    
    if(ManageAuthUtils.isAuth(ManageAuthCode.courseLessonTemplateConfigPages)){
      manageExerciseResourcesList.add(ManageAuthMenuModel(
        name: "题目配置",
        subtitle: "所有题目配置",
        authCode: ManageAuthCode.courseLessonTemplateConfigPages,
        route: Routes.MANAGE_CONFIG_EXERCISES,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.superMemoExerciseNeedResolvePages)){
      manageExerciseResourcesList.add(ManageAuthMenuModel(
        name: "超记题目",
        subtitle: "超记知识点的题目管理与关联配置",
        authCode: ManageAuthCode.superMemoExerciseNeedResolvePages,
        route: Routes.MANAGE_SUPER_MEMORY_EXERCISES,
      ));
    }

  }

  /// 跳转到课程列表
  void toPage(ManageAuthMenuModel data){
    if(data.route.isEmpty) return;
    ManagePageRegistry.jumpTo(data.route);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
