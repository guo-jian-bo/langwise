import 'dart:async';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/widgets/guide_engine/guide_engine.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import 'package:quiz_play/models/models.dart';
import 'package:wise_http/wise_http.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/stores/stores.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../common/enum/home_card_code.dart';
import '../../../../utils/mqtt_utils/mqtt_message_services_code.dart';
import '../../../routes/routes.dart';
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

  /// 首页广告内容列表
  final RxList<PushMessageEntity> homeAdvertList = <PushMessageEntity>[].obs;

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
  /// 第一个卡片状态timer
  Timer? fistStatusTimer;
  /// 第一个卡片的状态
  final Rx<HomeGenerateStatusEnum> fistCardStatus = HomeGenerateStatusEnum.FINISHED.obs;

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

  // ------------- 其他 ------------------

  Timer? _nextDayTimer;

  StreamSubscription<PushMessageServiceEnitiy>? _messageSubscription;

  @override
  void onInit() {
    super.onInit();
    fistFinishSvg.value = lottieCelebrateList[Random().nextInt(lottieCelebrateList.length)];
    initHomeCardList(init: true);
    nextDayRefresh();

    _messageSubscription = MqttNotificationMessage.instance.listenByCode(
      codes: [
        MqttMessageServicesCode.refreshHomePage, 
        MqttMessageServicesCode.assessmentPlanCompleted,
        MqttMessageServicesCode.refreshHomePageAd,
        MqttMessageServicesCode.refreshPlanMission,
      ], 
      onData: (value){
        if(value.message.code == MqttMessageServicesCode.refreshHomePageAd){
          getActivityList();
        }else if(value.message.code == MqttMessageServicesCode.refreshPlanMission){
          initFistCardTabStartStatus();
        }else{
          initHomeCardList();
          UserStore.to.getUserInfo();
          GuideTaskController.to.loadNewbieGuideTaskList();
        }
      },
    );
  }

  /// 0点~0点15分随机刷新
  void nextDayRefresh(){
    _nextDayTimer?.cancel();
    DateTime now = DateTime.now().toLocal();
    
    const int minSeconds = 1;
    const int maxSeconds = 15 * 60;// 15分钟内随机
    final int randomSeconds = minSeconds + Random().nextInt(maxSeconds - minSeconds + 1);
    DateTime nextDay = DateTime(now.year, now.month, now.day + 1).add(Duration(seconds: randomSeconds)); // 0点之后随机刷新
    Duration refreshDuration = nextDay.difference(now);
    if (refreshDuration.isNegative) refreshDuration = Duration(seconds: 1);

    _nextDayTimer = Timer(refreshDuration, () async{
      if(isClosed) return;
      await initHomeCardList();
      if(isClosed) return;
      await Future.delayed(const Duration(seconds: 5));
      if(isClosed) return;
      nextDayRefresh();
    });
  }

  /// 初始化首页，获取首页卡片列表
  Future<void> initHomeCardList({bool init = false}) async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.pageCardCodePageCode)) {
      return;
    }
    try {
      // if (!(await ConnectivityUtil.checkConnectivity())) {
      //   homeReqError.value = 1;
      //   ToastUtils.showToast(text: "网络错误，请检查网络连接后重试!");
      //   return;
      // }
      
      fistStatusTimer?.cancel();

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

      getActivityList();

      if(init){
        loadNewbieGuideTaskList();
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

  /// 加载新手任务引导
  Future<void> loadNewbieGuideTaskList() async {
    if(!UserStore.to.isLogin) return;
    await GuideTaskController.to.loadNewbieGuideTaskList();
    int? userId = UserStore.to.userInfo.value.userId;
    if(userId != null){
      bool isShowAgain = StorageUtil().getBoolNull("${NOVICE_TASK_REMINDER_KEY}_$userId")??false;
      if(isShowAgain) return;
    }
    if(GuideTaskController.to.getExecutableQuestCount() <= 0){
      await GuideTaskController.to.loadTasks(pageCode: AppRoutesCode.home);
      await Future.delayed(const Duration(milliseconds: 300));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GuideTaskController.to.start(AppRoutesCode.home);
      });
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    // 下一帧显示引导
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GuideTaskController.to.showHomeGuide();
    });
  }

  /// 获取活动列表
  Future<void> getActivityList() async {
    if(!UserStore.to.isLogin) return;
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.activitiesAdvertTypeList)) return;
    try {
      List<PushMessageEntity>? homeAdvertEntities = await ActivitiesRequest.getHomeAdList("home");
      if(homeAdvertEntities == null) return;
      
      // homeAdvertEntities.forEach((element) {
      //   element.started = "2026-07-09 19:36";
      //   element.ended = "2026-07-09 19:37";
      // });

      homeAdvertList.value = homeAdvertEntities;

    } catch (_) {}
  }

  /// 初始化第一个卡片
  Future<void> initFistCardTab() async {
    try {
      homeFistCardTabData.clear();
      if ((homeFistCardData.value.list ?? []).isNotEmpty) {
        for (int i = 0; i < homeFistCardData.value.list!.length; i++) {
          if (homeFistCardData.value.list![i] == null) continue;
          HomeCardFistTabModel item = HomeCardFistTabModel.fromJson(homeFistCardData.value.list![i]);

          fistCardStatus.value = item.data?.generateStatusEnum ?? HomeGenerateStatusEnum.FINISHED;

          homeFistCardTabData.add(item);
        }
      }
      fistCardTabController?.dispose();
      fistCardTabController = TabController(length: homeFistCardTabData.length, vsync: this);
      fistCardTabController?.addListener(() {
        fistCardTabIndex.value = fistCardTabController?.index ?? 0;
      });

      fistCardTabInit.value = true;

      fistStatusTimer?.cancel();

      initFistCardTabStartStatus();

    } catch (e) {
      fistCardTabInit.value = false;
    }
  }


  /// 开始循环请求接口查询计划是否准备好
  Future<void> initFistCardTabStartStatus() async {
    if(homeFistCardTabData.isEmpty) return;

    for(HomeCardFistTabModel item in homeFistCardTabData){
      // 判断设置计划的步骤
      if(item.data?.guideStepEnum != LearningSettingStepsEnum.START_LEARNING && item.data?.guideStepPge != null) return;
      // 当前没有计划
      if(item.data?.finish == null) return;
      // 计划已经完成
      if(item.data?.finish == true) return;
      /// 如果状态是空的 并且 mission不是空 则是 任务已经加载成功
      if(item.data?.generateStatusEnum == null) {
        if((item.data?.missions??[]).isNotEmpty){
          return;
        }
      }else{
        // 如果状态已完成 但是 mission是空的 则是 已完成
        if(item.data?.generateStatusEnum == HomeGenerateStatusEnum.FINISHED) {
          return;
        }
      }
    }
    fistStatusTimer?.cancel();
    // 开始循环调用查询状态的接口
    fistStatusTimer = Timer.periodic(const Duration(seconds: 2), (timer) async{
      await initFistCardTabStartStatusItem();
    });
  }   

  /// 开始循环请求接口查询计划是否准备好
  Future<void> initFistCardTabStartStatusItem() async{
    try {
      MissionAsyncStatusEntity? missionAsyncStatusEntity = await StudiesRequest.getTodayTaskStatus();
      if(missionAsyncStatusEntity == null) return;
      fistCardStatus.value = missionAsyncStatusEntity.generateStatusEnum ?? HomeGenerateStatusEnum.FINISHED;
      if(missionAsyncStatusEntity.generateStatusEnum != HomeGenerateStatusEnum.FINISHED) return;
      // 加载完成
      fistStatusTimer?.cancel();
      initHomeCardList();
    } catch (_) {}
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
    preparationPlanTabController?.dispose();
    preparationPlanTabController = null;
    preparationPlanList.clear();
    initPreparationPlanTab.value = false;
    preparationPlanTabIndex.value = 0;
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
      showLastCountdown: true,
    );
    if (!askRes) {
      checkFistCard(context, next: false);
    } else {
      checkFistCard(context, next: true);
    }
  }

  Future<void> checkFistCard(BuildContext context, {bool next = false}) async {
    bool student = await LockUtils.checkStudent(context);
    if(!student) {
      GuideTaskController.to.stop();
      return;
    }
    if (await LockUtils.checkLock(homeFistCardData.value.rights, context)) return;

    await TagRoutes.toNamed(
      Routes.MISSION_CONTROL_CENTER,
      arguments: {
        "review": next ? 1 : 0,
      },
    );

    GuideTaskController.to.continueGuide(AppRoutesCode.home, GuideWidgetIds.homeStartLearningButton);

  }

  /// 点击官方课程卡片
  Future<void> checkOfficialCourseCard(BuildContext context) async {
    if (await LockUtils.checkLock(homeOfficialCardData.value.rights, context)) {
      GuideTaskController.to.stop();
      return;
    }
    if (officialCoursesTab[officialCoursesTabIndex.value].data?.moduleInfoList?.isEmpty ?? true) {
      GuideTaskController.to.stop();
      return;
    }
    final dynamic levelRes = await _openCourseLevelPage(
      courseId: officialCoursesTab[officialCoursesTabIndex.value]
          .data
          ?.moduleInfoList
          ?.first
          ?.courseId,
      showRecommend: true,
      scrollToStudyZoneEnum: StudyZoneEnum.study,
    );
    if (levelRes == null) {
      GuideTaskController.to.stop();
      return;
    }
    GuideTaskController.to.continueGuide(
      AppRoutesCode.home,
      GuideWidgetIds.homeOfficialCourseCard,
    );

  }

  Future<dynamic> _openCourseLevelPage({
    required int? courseId,
    int? levelId,
    int? moduleId,
    bool isFromCustomCourse = false,
    bool showRecommend = true,
    String? scrollToStudyZoneEnum,
    bool autoOpenDetail = false,
  }) async {
    if (courseId == null) return null;
    return await TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_LEVEL,
      arguments: {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
        "isFromCustomCourse": isFromCustomCourse,
        "scrollToLevelId": levelId,
        "scrollToModuleId": moduleId,
        "showRecommend": showRecommend,
        "scrollToStudyZoneEnum": scrollToStudyZoneEnum,
        "autoOpenDetail": autoOpenDetail,
        "autoOpenLevelId": levelId,
        "autoOpenModuleId": moduleId,
      },
    );
  }

  /// 跳转至课程详情
  Future<void> toCoursesDetil(
    BuildContext context,
    int? courseId,
    int? moduleId,
    int? levelId,
    LockEntity? rights,
    {bool viaLevel = true, bool isFromCustomCourse = false}
  ) async {
    if (await LockUtils.checkLock(rights, context)) return;

    if (courseId == null) return;
    if (viaLevel) {
      final dynamic levelRes = await _openCourseLevelPage(
        courseId: courseId,
        levelId: levelId,
        moduleId: moduleId,
        isFromCustomCourse: isFromCustomCourse,
        showRecommend: true,
        scrollToStudyZoneEnum: StudyZoneEnum.study,
        autoOpenDetail: levelId != null && moduleId != null,
      );
      if (levelRes == null) return;
      if (levelRes is Map<String, dynamic>) {
        if (levelRes['type'] == 0) {
          checkFistCard(context);
          return;
        }
      }
      return;
    }

    dynamic res = await TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS,
      arguments: {
        "courseId": courseId,
        "moduleId": moduleId,
        "levelId": levelId,
      },
    );
    if (res == null) return;
    if (res is Map<String, dynamic> && res['type'] == 0) {
      checkFistCard(context);
    }
  }

  /// 跳转至创建学习计划页面
  Future<void> toCreateStudyPlan(BuildContext context) async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCoursePlanPathInfo)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;
    bool student = await LockUtils.checkStudent(context);
    if(!student) return;
    if (await LockUtils.checkLock(homeFistCardData.value.rights, context)) return;
    TagRoutes.toNamed(Routes.STUDY_PLAN);
  }

  /// 跳转至学习计划列表
  Future<void> toStudyPlan(BuildContext context) async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCoursePlanPathInfo)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }
    bool student = await LockUtils.checkStudent(context);
    if(!student) {
      GuideTaskController.to.stop();
      return;
    }
    if (await LockUtils.checkLock(studyPlanData.value.rights, context)) {
      GuideTaskController.to.stop();
      return;
    }

    await TagRoutes.toNamed(Routes.STUDY_PLAN);

    GuideTaskController.to.continueGuide(AppRoutesCode.home, GuideWidgetIds.homePlanCard);
  }

  /// 跳转至备考计划
  Future<void> toPreparationPlan(int index, BuildContext context) async {
    bool student = await LockUtils.checkStudent(context);
    if(!student) {
      GuideTaskController.to.stop();
      return;
    }
    if (await LockUtils.checkLock(preparationPlanData.value.rights, context)) {
      GuideTaskController.to.stop();
      return;
    }

    await TagRoutes.toNamed(Routes.PREPARATION_PLAN_LIST, arguments: {"initIndex": index});

    GuideTaskController.to.continueGuide(AppRoutesCode.home, GuideWidgetIds.homePreparationPlanCard);
  }

  /// 备考计划开始练习
  Future<void> toPreparationPlanStartPractice(HomeCardExamBlitzListModel data, BuildContext context, int? currentExerciseId) async {
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

      dynamic res = await TagRoutes.toNamed(
        Routes.PRACTICE_QUESTIONS,
        arguments: {
          "currentQuizId": currentExerciseId,
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
    if(!student) {
      GuideTaskController.to.stop();
      return;
    }
    if (await LockUtils.checkLock(selfbuiltCoursesData.value.rights, context)) {
      GuideTaskController.to.stop();
      return;
    }

    if (data == null || data.courseId == null) {
      GuideTaskController.to.stop();
      return;
    }

    if (data.moduleId != null && data.moduleId! > 0) {
      await toCoursesDetil(
        context,
        data.courseId,
        data.moduleId,
        data.levelId,
        selfbuiltCoursesData.value.rights,
        isFromCustomCourse: true,
      );
    } else {
      final dynamic levelRes = await _openCourseLevelPage(
        courseId: data.courseId,
        isFromCustomCourse: true,
        showRecommend: true,
        scrollToStudyZoneEnum: StudyZoneEnum.study,
      );
      if (levelRes == null) {
        GuideTaskController.to.stop();
        return;
      }
    }
    GuideTaskController.to.continueGuide(AppRoutesCode.home, GuideWidgetIds.homeCustomCourseCard);
  }

  /// 根据code 获取 widgetId
  String? getWidgetIdByCode(String? code) {
    if (code == null) return null;
    switch (code) {
      case HomeCardCode.coursePlan:
        return GuideWidgetIds.homePlanCard;
      case HomeCardCode.customCourseMange:
        return GuideWidgetIds.homeCustomCourseCard;
      case HomeCardCode.examPlan:
        return GuideWidgetIds.homePreparationPlanCard;
      case HomeCardCode.writeCourse:
        return GuideWidgetIds.homeWriteCourseCard;
      default:
        return null;
    }
  }

  /// 根据code跳转页面
  Future<void> toPageByCode(HomeCardEntityItems data, BuildContext context) async {
    // getActivityList();
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) {
      GuideTaskController.to.stop();
      return;
    }
    bool student = await LockUtils.checkStudent(context);
    if(!student) {
      GuideTaskController.to.stop();
      return;
    }

    if (await LockUtils.checkLock(data.rights, context)) {
      GuideTaskController.to.stop();
      return;
    }

    if (data.code == HomeCardCode.coursePlan) {
      if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCoursePlanPathInfo)) {
        ToastUtils.showToast(text: "无权限");
        return;
      }
      await TagRoutes.toNamed(Routes.STUDY_PLAN);
    } else if (data.code == HomeCardCode.customCourseMange) {
      await TagRoutes.toNamed(Routes.CUSTOM_COURSE_ADD_GRADE);
    } else if (data.code == HomeCardCode.examPlan) {
      await TagRoutes.toNamed(Routes.EXAM_PREPARATION);
    } else {
      PushMessageEntity jumpData = PushMessageEntity(
        jump: data.jump,
        category: JumpPageUtils.userType,
      );
      await JumpPageUtils.jumpPage(jumpData);
    }

    String? widgetId = getWidgetIdByCode(data.code);
    if(widgetId != null) {
      GuideTaskController.to.continueGuide(AppRoutesCode.home, widgetId);
    } else {
      GuideTaskController.to.stop();
    }

  }

  /// 去登录
  Future<void> goLogin() async {
    Get.offAllNamed(Routes.SPLASH);
  }

  @override
  void onClose() {
    try {
      fistStatusTimer?.cancel();
      _nextDayTimer?.cancel();
      fistCardTabController?.dispose();
      officialCoursesTabController?.dispose();
      preparationPlanTabController?.dispose();
      studyPlanTabController?.dispose();
      selfbuiltCoursesTabController?.dispose();
      _messageSubscription?.cancel();
    } catch (_) {}
    super.onClose();
  }
}
