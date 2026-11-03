import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import 'package:quiz_play/models/models.dart';
import 'package:wise_http/wise_http.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../common/enum/home_card_code.dart';
import '../model/home_card_exam_blitz_model.dart';
import '../model/home_card_fist_tab_model.dart';
import '../model/home_card_member_course_model.dart';
import '../model/home_card_official_model.dart';
import '../model/home_card_self_built_model.dart';
import '../model/home_card_study_play_model.dart';
import '../views/home_card_default_widget.dart';
import '../views/home_exam_blitz_card.dart';
import '../views/home_member_course_card.dart';
import '../views/home_official_courses_card.dart';
import '../views/home_self-built_courses_card.dart';
import '../views/home_study_plan_card.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  final List<String> lottieCelebrateList = [
    "assets/lottie/celebrate1.json",
    "assets/lottie/celebrate2.json",
    "assets/lottie/celebrate3.json",
    "assets/lottie/celebrate4.json",
    "assets/lottie/celebrate5.json",
    "assets/lottie/trophy.json",
  ];

  /// 首页请求错误状态
  /// -1=未请求 0=成功 1=无网络 2=请求超时 3=服务器请求异常(代表服务器回null) 4=空(代表服务器回的是空)
  final RxInt homeReqError = (-1).obs;

  /// 其他小卡片
  final RxList<Widget> bodyCardList = <Widget>[].obs;

  //  ----------- 第一个大卡片 ------------
  /// 第一个卡片的数据
  final RxString fistFinishSvg = "".obs;
  final Rx<HomeCardEntityItems> homeFistCardData = HomeCardEntityItems().obs;
  final RxList<HomeCardFistTabModel> homeFistCardTabData = <HomeCardFistTabModel>[].obs;
  TabController? fistCardTabController;
  final RxInt fistCardTabIndex = 0.obs;
  final RxBool fistCardTabInit = false.obs;

  // ------------- 官方课程 --------------
  final RxBool initOfficialCourses = false.obs;
  final Rx<HomeCardEntityItems> homeOfficialCardData = HomeCardEntityItems().obs;

  /// 官方课程tab
  final RxList<HomeCardOfficialModel> officialCoursesTab = <HomeCardOfficialModel>[].obs;

  /// 官方课程tab控制器
  TabController? officialCoursesTabController;
  final RxInt officialCoursesTabIndex = 0.obs;

  // -------------- 会员课程(已经加入的课程) ---------
  final RxBool initMemberCourse = false.obs;

  /// 会员课程数据
  final Rx<HomeCardEntityItems> memberCourseData = HomeCardEntityItems().obs;

  /// 会员课程列表
  final RxList<HomeCardMemberCourseModel> memberCourseList = <HomeCardMemberCourseModel>[].obs;
  final RxInt memberCourseTabIndex = 0.obs;
  final CarouselSliderController memberCourseCarouselController = CarouselSliderController();

  // -------------- 备考计划 --------------
  /// 备考计划数据
  final Rx<HomeCardEntityItems> preparationPlanData = HomeCardEntityItems().obs;

  /// 备考计划列表
  final RxList<HomeCardExamBlitzListModel> preparationPlanList = <HomeCardExamBlitzListModel>[].obs;

  /// 备考计划tab
  TabController? preparationPlanTabController;

  /// 备考计划tab索引
  final RxInt preparationPlanTabIndex = 0.obs;
  final RxBool initPreparationPlanTab = false.obs;

  // -------------- 学习计划 ----------------
  /// 学习计划数据
  final Rx<HomeCardEntityItems> studyPlanData = HomeCardEntityItems().obs;

  /// 学习计划列表
  final RxList<HomeCardStudyPlayModel> studyPlanList = <HomeCardStudyPlayModel>[].obs;

  /// 学习计划tab
  TabController? studyPlanTabController;

  /// 学习计划tab索引
  final RxInt studyPlanTabIndex = 0.obs;
  final RxBool initStudyPlanTab = false.obs;

  // ------------- 自定义课程 ------------------
  /// 自定义课程列表
  final RxList<HomeCardSelfBuiltModel> selfbuiltCoursesList = <HomeCardSelfBuiltModel>[].obs;

  /// 自定义课程数据
  final Rx<HomeCardEntityItems> selfbuiltCoursesData = HomeCardEntityItems().obs;

  /// 自定义课程tab
  TabController? selfbuiltCoursesTabController;

  /// 自定义课程tab索引
  final RxInt selfbuiltCoursesTabIndex = 0.obs;
  final RxBool initSelfbuiltCoursesTab = false.obs;

  /// 是否已经创建自建课程 测试
  final RxBool createSelfbuiltCoursesFlag = false.obs;

  @override
  void onInit() {
    super.onInit();
    fistFinishSvg.value = lottieCelebrateList[Random().nextInt(lottieCelebrateList.length)];
    initHomeCardList();
  }

  /// 初始化首页，获取首页卡片列表
  Future<void> initHomeCardList() async {
    try {
      if (!(await ConnectivityUtil.checkConnectivity())) {
        homeReqError.value = 1;
        ToastUtils.showToast(text: "网络错误，请检查网络连接后重试!");
        return;
      }

      HomeCardEntity? homeCardEntity = await HomeRequest.getHomeCardList();
      if (homeCardEntity == null) {
        homeReqError.value = 3;
        return;
      }
      List<HomeCardEntityItems?>? items = homeCardEntity.items;
      if (items == null) {
        homeReqError.value = 4;
        return;
      }

      DateTime now = DateTime.now().toLocal();
      await StorageUtil().setString(HOME_REFRESH_DATE_KEY, "${now.year}${now.month}${now.day}");

      bodyCardList.clear();
      initStudyPlanTab.value = false;
      initMemberCourse.value = false;
      fistCardTabInit.value = false;
      initOfficialCourses.value = false;
      initPreparationPlanTab.value = false;
      initSelfbuiltCoursesTab.value = false;
      studyPlanTabIndex.value = 0;
      memberCourseTabIndex.value = 0;
      preparationPlanTabIndex.value = 0;
      officialCoursesTabIndex.value = 0;
      fistCardTabIndex.value = 0;
      selfbuiltCoursesTabIndex.value = 0;
      List<Widget> bodyList = [];
      for (int i = 0; i < items.length; i++) {
        if (items[i] == null) continue;
        if (items[i]!.code == null) continue;
        if (items[i]!.code == HomeCardCode.todayTask) {
          homeFistCardData.value = items[i]!;
        } else if (items[i]!.code == HomeCardCode.course) {
          homeOfficialCardData.value = items[i]!;
          bodyList.add(const HomeOfficialCoursesCard());
        } else if (items[i]!.code == HomeCardCode.memberCourse) {
          memberCourseData.value = items[i]!;
          bodyList.add(const HomeMemberCourseCard());
        } else if (items[i]!.code == HomeCardCode.examPlan) {
          preparationPlanData.value = items[i]!;
          bodyList.add(const HomeExamBlitzCard());
        } else if (items[i]!.code == HomeCardCode.coursePlan) {
          studyPlanData.value = items[i]!;
          bodyList.add(const HomeStudyPlanCard());
        } else if (items[i]!.code == HomeCardCode.customCourseMange) {
          selfbuiltCoursesData.value = items[i]!;
          bodyList.add(const HomeSelfbuiltCoursesCard());
        } else {
          bodyList.add(HomeCardDefaultWidget(data: items[i]!));
        }
      }

      await initFistCardTab();
      initOfficialCoursesCard();
      initPreparationPlanCard();
      initMemberCourseCard();
      initStudyPlanCard();
      initSelfbuiltCoursesCard();

      bodyCardList.value = bodyList;

      if (bodyCardList.isEmpty) {
        homeReqError.value = 4;
      } else {
        homeReqError.value = 0;
      }
    } on DioException catch (e) {
      DioExceptionType dioExceptionType = DioExceptionUtils.handleDioException(e);
      if (dioExceptionType == DioExceptionType.connectionTimeout || dioExceptionType == DioExceptionType.sendTimeout || dioExceptionType == DioExceptionType.receiveTimeout) {
        homeReqError.value = 2;
      } else {
        homeReqError.value = 3;
      }
    } catch (_) {
      homeReqError.value = 5;
    }
  }

  /// 初始化第一个卡片
  Future<void> initFistCardTab() async {
    try {
      homeFistCardTabData.clear();
      if ((homeFistCardData.value.list ?? []).isNotEmpty) {
        for (int i = 0; i < homeFistCardData.value.list!.length; i++) {
          if (homeFistCardData.value.list![i] == null) continue;
          HomeCardFistTabModel item = HomeCardFistTabModel.fromJson(homeFistCardData.value.list![i]);

          homeFistCardTabData.add(item);
        }
      }

      fistCardTabController = TabController(length: homeFistCardTabData.length, vsync: this);
      fistCardTabController?.addListener(() {
        fistCardTabIndex.value = fistCardTabController?.index ?? 0;
      });

      fistCardTabInit.value = true;
    } catch (e) {
      fistCardTabInit.value = false;
    }
  }

  /// 初始化官方课程卡片
  Future<void> initOfficialCoursesCard() async {
    officialCoursesTab.clear();
    if ((homeOfficialCardData.value.list ?? []).isNotEmpty) {
      for (int i = 0; i < homeOfficialCardData.value.list!.length; i++) {
        if (homeOfficialCardData.value.list![i] == null) continue;
        HomeCardOfficialModel item = HomeCardOfficialModel.fromJson(homeOfficialCardData.value.list![i]);
        officialCoursesTab.add(item);
      }
    }

    try {
      officialCoursesTabController = TabController(length: officialCoursesTab.length, vsync: this);
      officialCoursesTabController?.addListener(() {
        officialCoursesTabIndex.value = officialCoursesTabController?.index ?? 0;
      });
      initOfficialCourses.value = true;
    } catch (e) {
      initOfficialCourses.value = false;
    }
  }

  /// 初始化会员课程(已经加入的课程)
  Future<void> initMemberCourseCard() async {
    memberCourseList.clear();
    if (memberCourseData.value.list?.isEmpty ?? true) return;
    for (int i = 0; i < memberCourseData.value.list!.length; i++) {
      if (memberCourseData.value.list![i] == null) continue;
      HomeCardMemberCourseModel item = HomeCardMemberCourseModel.fromJson(memberCourseData.value.list![i]);
      memberCourseList.add(item);
    }
    initMemberCourse.value = true;
  }

  /// 初始化学习计划
  Future<void> initStudyPlanCard() async {
    studyPlanList.clear();
    if (studyPlanData.value.list?.isEmpty ?? true) return;
    for (int i = 0; i < studyPlanData.value.list!.length; i++) {
      if (studyPlanData.value.list![i] == null) continue;
      HomeCardStudyPlayModel item = HomeCardStudyPlayModel.fromJson(studyPlanData.value.list![i]);
      studyPlanList.add(item);
    }
    try {
      studyPlanTabController = TabController(length: studyPlanList.length, vsync: this);
      studyPlanTabController?.addListener(() {
        studyPlanTabIndex.value = studyPlanTabController?.index ?? 0;
      });
      initStudyPlanTab.value = true;
    } catch (e) {
      initStudyPlanTab.value = false;
    }
  }

  /// 初始化备考计划卡片
  Future<void> initPreparationPlanCard() async {
    preparationPlanList.clear();
    if (preparationPlanData.value.list?.isEmpty ?? true) return;
    for (int i = 0; i < preparationPlanData.value.list!.length; i++) {
      if (preparationPlanData.value.list![i] == null) continue;
      HomeCardExamBlitzModel item = HomeCardExamBlitzModel.fromJson(preparationPlanData.value.list![i]);
      preparationPlanList.add(HomeCardExamBlitzListModel(
        data: item,
        calendarCurrentMonth: DateTime.now().obs,
      ));
    }

    try {
      preparationPlanTabController = TabController(length: preparationPlanList.length, vsync: this);
      preparationPlanTabController?.addListener(() {
        preparationPlanTabIndex.value = preparationPlanTabController?.index ?? 0;
      });
      initPreparationPlanTab.value = true;
    } catch (e) {
      initPreparationPlanTab.value = false;
    }
  }

  /// 初始化自定义课程卡片
  Future<void> initSelfbuiltCoursesCard() async {
    selfbuiltCoursesList.clear();
    if (selfbuiltCoursesData.value.list?.isEmpty ?? true) return;
    for (int i = 0; i < selfbuiltCoursesData.value.list!.length; i++) {
      if (selfbuiltCoursesData.value.list![i] == null) continue;
      HomeCardSelfBuiltModel item = HomeCardSelfBuiltModel.fromJson(selfbuiltCoursesData.value.list![i]);
      selfbuiltCoursesList.add(item);
    }
    try {
      selfbuiltCoursesTabController = TabController(length: selfbuiltCoursesList.length, vsync: this);
      selfbuiltCoursesTabController?.addListener(() {
        selfbuiltCoursesTabIndex.value = selfbuiltCoursesTabController?.index ?? 0;
      });
      initSelfbuiltCoursesTab.value = true;
    } catch (e) {
      initSelfbuiltCoursesTab.value = false;
    }
  }


  /// 超额学习 再来一课
  Future<void> overlearning(BuildContext context) async {
    bool student = await LockUtils.checkStudent(context);
    if(!student) return;
    if (await LockUtils.checkLock(homeFistCardData.value.rights, context)) return;
    // 今天的在做一遍/学习明天的
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "超额学习",
      content: "今日计划已完成，是否提前学习明日计划？",
      cancel: "巩固今日",
      define: "开始明日",
    );
    if (!askRes) {
      checkFistCard(context, next: false);
    } else {
      checkFistCard(context, next: true);
    }
  }

  Future<void> checkFistCard(BuildContext context, {bool next = false}) async {
    bool student = await LockUtils.checkStudent(context);
    if(!student) return;
    if (await LockUtils.checkLock(homeFistCardData.value.rights, context)) return;

    Get.toNamed(
      Routes.MISSION_CONTROL_CENTER,
      arguments: {
        "review": next ? 1 : 0,
      },
    );
  }

  /// 点击官方课程卡片
  Future<void> checkOfficialCourseCard(BuildContext context) async {
    if (await LockUtils.checkLock(homeOfficialCardData.value.rights, context)) return;
    if (officialCoursesTab[officialCoursesTabIndex.value].data?.moduleInfoList?.isEmpty ?? true) return;
    // 先跳转选择模块页面
    dynamic resStart = await Get.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_LEVEL,
      arguments: {
        "courseId": officialCoursesTab[officialCoursesTabIndex.value].data?.moduleInfoList?.first?.courseId,
        "showRecommend": true,
        "scrollToStudyZoneEnum": StudyZoneEnum.study,
      },
    );
    if (resStart == null) return;
    Map<String, dynamic> resMap = resStart;
    toCoursesDetil(
      context,
      resMap['courseId'],
      resMap['moduleId'],
      resMap['levelId'],
      homeOfficialCardData.value.rights,
    );
  }

  /// 跳转至课程详情
  Future<void> toCoursesDetil(
    BuildContext context,
    int? courseId,
    int? moduleId,
    int? levelId,
    LockEntity? rights,
  ) async {
    if (await LockUtils.checkLock(rights, context)) return;

    if (courseId == null) return;
    dynamic res = await Get.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS,
      arguments: {
        "courseId": courseId,
        "moduleId": moduleId,
        "levelId": levelId,
      },
    );
    if (res == null) return;
    Map<String, dynamic> map = res;
    if (map['type'] == 0) {
      executeFirstCardAnimation(context);
    }
  }

  /// 跳转至创建学习计划页面
  Future<void> toCreateStudyPlan(BuildContext context) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;
    bool student = await LockUtils.checkStudent(context);
    if(!student) return;
    if (await LockUtils.checkLock(homeFistCardData.value.rights, context)) return;
    // Get.toNamed(Routes.CREATE_STUDY_PLAN, arguments: {"isVerificationPlanList": true});
    Get.toNamed(Routes.TODAY_PLAN);
  }

  /// 跳转至学习计划列表
  Future<void> toStudyPlan(BuildContext context) async {
    bool student = await LockUtils.checkStudent(context);
    if(!student) return;
    if (await LockUtils.checkLock(studyPlanData.value.rights, context)) return;

    await Get.toNamed(
      Routes.TODAY_PLAN,
      arguments: {
        "tabIndex": studyPlanTabIndex.value,
        "todayPlanCount": studyPlanList.length,
      },
    );
  }

  /// 跳转至备考计划
  Future<void> toPreparationPlan(int index, BuildContext context) async {
    bool student = await LockUtils.checkStudent(context);
    if(!student) return;
    if (await LockUtils.checkLock(preparationPlanData.value.rights, context)) return;

    await Get.toNamed(Routes.PREPARATION_PLAN_LIST, arguments: {"initIndex": index});
  }

  /// 备考计划开始练习
  Future<void> toPreparationPlanStartPractice(HomeCardExamBlitzListModel data, BuildContext context) async {
    bool student = await LockUtils.checkStudent(context);
    if(!student) return;
    if (await LockUtils.checkLock(selfbuiltCoursesData.value.rights, context)) return;

    int? uid = data.data.data?.uid;
    if (uid == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqParams = {
        "date": DateFormatUtil.formatStr(DateTime.now()),
      };
      PlanQuizEntity? entity = await HomeRequest.getExamPreparationData(uid, reqParams);
      if (entity == null) return;
      List<PlanQuizEntityExercises?> list = entity.exercises ?? [];
      if (list.isEmpty) return;

      List<QuizModel> quizList = [];
      for (int i = 0; i < list.length; i++) {
        if (list[i] == null) continue;
        if (list[i]!.exercise == null) continue;
        QuizModel quizModel = list[i]!.exercise!;
        quizModel.testType = list[i]!.testType;
        quizModel.context = list[i]!.context;
        quizModel.duration = list[i]!.duration?.toDouble();
        quizList.add(list[i]!.exercise!);
      }

      dynamic res = await Get.toNamed(
        Routes.PRACTICE_QUESTIONS,
        arguments: {
          // "currentQuizId": currentExerciseId,
          "quizDatas": quizList,
          "questionIsReport": true,
          "isShowPercentageProgress": true,
          "settingTotalDurationSecond": entity.duration,
        },
      );
      if (res == null) return;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 跳转至自定义课程继续创建 已经完成的课程跳转至课程详情
  Future<void> toSelfbuiltCoursesCreate(HomeCardSelfBuiltModelData? data, BuildContext context) async {
    bool student = await LockUtils.checkStudent(context);
    if(!student) return;
    if (await LockUtils.checkLock(selfbuiltCoursesData.value.rights, context)) return;

    if (data == null) return;
    if (data.courseId == null) return;

    if (data.moduleId != null && data.moduleId! > 0) {
      //跳转教材详情页
      dynamic res = await Get.toNamed(
        Routes.OFFICIAL_COURSE_DETAILS,
        arguments: {
          "courseId": data.courseId,
          "moduleId": data.moduleId,
          "levelId": data.levelId,
        },
      );
      if (res == null) return;
      Map<String, dynamic> map = res;
      if (map['type'] == 0) {
        executeFirstCardAnimation(context);
      }
    } else {
      // 先跳转切换年级界面
      dynamic resStart = await Get.toNamed(
        Routes.OFFICIAL_COURSE_DETAILS_LEVEL,
        arguments: {
          "courseId": data.courseId,
          "isFromCustomCourse": true,
          "showRecommend": true,
          "scrollToStudyZoneEnum": StudyZoneEnum.study,
        },
      );
      if (resStart == null) return;
      Map<String, dynamic> resMap = resStart;
      toCoursesDetil(
        context,
        resMap['courseId'],
        resMap['moduleId'],
        resMap['levelId'],
        homeOfficialCardData.value.rights,
      );

      //新增书籍
      //await Get.toNamed(Routes.CUSTOM_COURSE_ADD_GRADE);
    }
  }

  /// 执行第一个卡片的按钮动画
  Future<void> executeFirstCardAnimation(BuildContext context) async {
    await checkFistCard(context);
  }

  /// 根据code跳转页面
  Future<void> toPageByCode(HomeCardEntityItems data, BuildContext context) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;
    bool student = await LockUtils.checkStudent(context);
    if(!student) return;

    if (await LockUtils.checkLock(data.rights, context)) return;

    if (data.code == HomeCardCode.coursePlan) {
      await Get.toNamed(Routes.TODAY_PLAN);
    } else if (data.code == HomeCardCode.customCourseMange) {
      await Get.toNamed(Routes.CUSTOM_COURSE_ADD_GRADE);
    } else if (data.code == HomeCardCode.examPlan) {
      await Get.toNamed(Routes.EXAM_PREPARATION);
    } else {
      PushMessageEntity jumpData = PushMessageEntity(
        jump: data.jump,
        category: JumpPageUtils.userType,
      );
      await JumpPageUtils.jumpPage(jumpData);
    }
  }

  @override
  void onClose() {
    try {
      fistCardTabController?.dispose();
      officialCoursesTabController?.dispose();
      preparationPlanTabController?.dispose();
      studyPlanTabController?.dispose();
      selfbuiltCoursesTabController?.dispose();
    } catch (_) {}
    super.onClose();
  }
}
