import 'package:flutter/widgets.dart';

/// Http 接口权限
class HttpAuthUtils{

  HttpAuthUtils._();

  static final HttpAuthUtils instance = HttpAuthUtils._();

  factory HttpAuthUtils() => instance;

  /// 是否需要判断权限
  bool get isNeedAuth => _isNeedAuth;

  /// 是否需要判断权限
  bool _isNeedAuth = false;

  /// 拥有的权限
  List<String> _authApis = [];

  /// 初始化 接口权限
  Future<void> setAuthCodes(List<String> roleApiIds) async{
    _isNeedAuth = roleApiIds.isNotEmpty;
    _authApis = roleApiIds;
  }

  /// 清空 接口权限
  void clearAuthCodes(){
    _authApis.clear();
    _isNeedAuth = false;
  }

  /// 根据code[ManageAuthCode]查询是否有权限
  bool isAuth(String code){
    if(!isNeedAuth) return true;
    if(_authApis.isEmpty) return false;
    for(var item in _authApis){
      if(item.isEmpty) continue;
      if(item == code){
        return true;
      }
    }
    return false;
  }

  /// 根据codes[ManageAuthCode]查询是否有权限（需要全部匹配）
  bool isAuths(List<String> codes){
    if(!isNeedAuth) return true;
    if(_authApis.isEmpty) return false;
    if(codes.isEmpty) return false;
    Set<String> authUrls = _authApis.toSet();
    for(var code in codes){
      if(!authUrls.contains(code)){
        return false;
      }
    }
    return true;
  }

  /// 根据codes[ManageAuthCode]查询是否有任一权限
  bool isAnyAuth(List<String> codes){
    if(!isNeedAuth) return true;
    if(_authApis.isEmpty) return false;
    if(codes.isEmpty) return false;
    Set<String> authUrls = _authApis.toSet();
    for(var code in codes){
      if(authUrls.contains(code)){
        return true;
      }
    }
    return false;
  }

}

class HttpAuthCodes{

  /// 今日学习的发音评测题目列表
  static const String todayPronunciationList = 'POST:/member/course/today/content/speaking/exercise/pronunciation/list';
  /// 日程所有计划创建和编辑
  static const String manageCoursePlanCreateEdit = 'POST:/member/course/plan/edit';
  /// 获取成员学习信息
  static const String memberCourseStudyInfo = 'GET:/member/course/study/info';
  /// 学习计划详情
  static const String memberCoursePlanPathInfo = 'GET:/member/course/plan/path/info';
  /// 今日任务的知识点详情
  static const String memberCourseContentDetailList = 'POST:/member/course/content/detail/list';
  /// 单个课程日程编辑
  static const String memberCoursePlanCourseEdit = 'POST:/member/course/plan/course/{courseId}/edit';
  /// 删除课程计划
  static const String memberCoursePlanCourseDelete = 'DELETE:/member/course/plan/course/{courseId}/delete';
  /// 超级日历
  static const String memberCourseMonthSupermemoDaily = 'GET:/member/course/month/supermemo/daily';
  /// 今日任务mission列表
  static const String memberCourseTodayTaskMissionList = 'GET:/member/course/today/task/mission/async/list';
  /// 今日任务的mission题目列表
  static const String memberCourseTodayMissionExerciseList = 'GET:/member/course/today/mission/{missionId}/exercise/list';
  /// 今日计划暂停/studies/member/course/29/plan/pause
  static const String memberCoursePlanPause = 'POST:/member/course/{courseId}/plan/pause';
  /// 课时下题型分类列表
  static const String memberCourseDirectionExerciseCategoryList = 'POST:/member/course/direction/exercise/category/list';
  /// 今日学习的sound_block题目列表
  static const String memberCourseTodayContentSpeakingExerciseSoundBlockList = 'POST:/member/course/today/content/speaking/exercise/sound_block/list';
  /// 预览课程计划起点实际会落到哪个单元
  static const String memberCoursePlanCourseStartPreview = 'POST:/member/course/plan/course/{courseId}/start/preview';
  /// 可以创建计划的课程列表
  static const String memberCourseAllowPlanList = 'GET:/member/course/allow/plan/list';
  /// 当前计划的课程进度
  static const String memberCoursePlanCurrentCourseInfoList = 'GET:/member/course/plan/current/course/info/list';
  /// 首页
  static const String pageCardCodePageCode = 'GET:/page/card/code/{pageCode}';
  /// 活动接口/activities/advert/type/$type/list
  static const String activitiesAdvertTypeList = 'GET:/advert/type/{type}/list';
  /// 记录提醒规划 /member/assessment/$assessmentId/show/update/status
  static const String memberAssessmentShowUpdateStatus = 'POST:/member/assessment/{assessmentId}/show/update/status';

  /// 今日任务拓展菜单列表
  static const String todayTaskMissionExtendList = 'GET:/task/today/group/list';
  /// 获取钻石明细
  static const String studyTaskDiamondDetailList = 'POST:/task/diamond/detail/list';
  /// 获取单元目标 知识点列表 /course/course/$courseId/module/$moduleId/unit/$unitId/knowledge/list
  static const String memberCourseUnitKnowledgeList = 'GET:/course/{courseId}/module/{moduleId}/unit/{unitId}/knowledge/list';
  /// 获取课程模块课时列表 /course/course/$courseId/level/$levelId/module/$moduleId/lesson/list
  static const String memberCourseLevelModuleLessonList = 'GET:/course/{courseId}/level/{levelId}/module/{moduleId}/lesson/list';
  /// 获取课程当前状态 /course/user/custom/v3/course/current/status
  static const String memberCourseCurrentStatus = 'GET:/user/custom/v3/course/current/status';
  /// 获取course module的信息 /course/module/unit/lesson/infos
  static const String memberCourseModuleUnitLessonInfos = 'POST:/course/module/unit/lesson/infos';
   /// 获取课时类型列表 /course/lesson/direction/all/list
  static const String memberCourseLessonDirectionAllList = 'GET:/course/lesson/direction/all/list';
  /// 获取课程等级列表 /course/$courseId/level/module/unit/list
  static const String memberCourseLevelModuleUnitList = 'GET:/course/{courseId}/level/module/unit/list';
  /// 发音课模块列表 /course/specialty/phonics/$courseId/level/list
  static const String memberCoursePhonicsLevelList = 'GET:/course/specialty/phonics/{courseId}/level/list';
  /// 课程模块列表 /course/$courseId/level/list
  static const String courseLevelList = 'GET:/course/{courseId}/level/list';


  /// 进入任务获取专项任务列表/studies/task/$type/task/list/v3
  static const String studyTaskMissionListV3 = 'GET:/task/{type}/task/list/v3';
  /// 获取当前学员信息
  static const String memberCoursePlanCurrentCourseInfo = 'GET:/team/member/current/info';
   /// 获取用户超记统计
  static const String studyMemberCourseSupermemoSummary = 'GET:/member/course/supermemo/summary';
  /// 评测结果详情
  static const String studyMemberCourseAssessmentResultPlanV2 = 'GET:/member/assessment/{assessmentId}/result/plan/v2';
  /// 用户Ai评测结果详情 /studies/member/assessment/detail/plan/v2
  static const String studyMemberCourseAssessmentDetailPlanV2 = 'GET:/member/assessment/detail/plan/v2';
  /// 获取评测历史  /studies/member/assessment/history/pages
  static const String studyMemberCourseAssessmentHistoryPages = 'GET:/member/assessment/history/pages';
  /// 上报内容学习记录 /member/content/learn/upload
  static const String memberContentLearnUpload = 'POST:/member/content/learn/upload';
  /// 里程碑挑战列表 /member/course/milestone/challenge/overview
  static const String memberCourseMilestoneChallengeOverview = 'POST:/member/course/milestone/challenge/overview';
  /// 里程碑挑战分析 /member/course/milestone/challenge/analyse
  static const String memberCourseMilestoneChallengeAnalyse = 'POST:/member/course/milestone/challenge/analyse';
  /// 获取里程碑挑战的静态元信息 /member/course/milestone/challenge/meta
  static const String memberCourseMilestoneChallengeMeta = 'GET:/member/course/milestone/challenge/meta';
  /// 查询历史挑战列表 /member/course/milestone/challenge/history
  static const String memberCourseMilestoneChallengeHistory = 'GET:/member/course/milestone/challenge/history';
  /// 获取里程碑挑战详情 /member/course/milestone/challenge/{uid}
  static const String memberCourseMilestoneChallengeUid = 'GET:/member/course/milestone/challenge/{uid}';
  /// 创建里程碑挑战 /member/course/milestone/challenge/create
  static const String memberCourseMilestoneChallengeCreate = 'POST:/member/course/milestone/challenge/create';
  /// 题目上报 /exercise/record/submit
  static const String exerciseRecordSubmit = 'POST:/exercise/record/submit';
  /// 任务准备状态
  static const String memberCourseTodayTaskMissionAsyncStatus = "GET:/member/course/today/task/mission/async/status";
  /// 收集卡片
  static const String contentCardMemberUpdateShowListV2 = 'GET:/content/card/member/update/show/list/v2';

  /// 获取升级卡片的列表 /content/card/member/update/show/list
  static const String contentCardMemberUpdateShowList = 'GET:/content/card/member/update/show/list';
  /// 自定义课程查询步骤信息 /user/custom/v2/load/create/status
  static const String userCustomV2LoadCreateStatus = 'POST:/user/custom/v2/load/create/status';
  /// 查询课程信息 /user/custom/load/course/level/module/info
  static const String userCustomLoadCourseLevelModuleInfo = 'GET:/user/custom/load/course/level/module/info';
  ///根据经纬度获取城市编码 /resource/gecode/city
  static const String resourceGecodeCity = 'POST:/resource/gecode/city';
  /// 自定义课程 创建课程 /user/custom/create/course/module
  static const String userCustomCreateCourseModule = 'POST:/user/custom/create/course/module';
  /// 获取第三方账号 /secret/supplier/app
  static const String secretSupplierApp = 'GET:/secret/supplier/app';
  /// 知识点统一查询接口 /content/common/card/infos
  static const String contentCommonCardInfos = 'POST:/content/common/card/infos';
  /// 获取播放知识点列表 没有音频和ass信息 /content/list/base/infos
  static const String contentListBaseInfos = 'POST:/content/list/base/infos';
  /// 添加收藏 /favorite/listens/$playListId/content/add
  static const String favoriteListensPlayListIdContentAdd = 'POST:/favorite/listens/{playListId}/content/add';
  /// 删除收藏 /favorite/listens/$playListId/content/remove
  static const String favoriteListensPlayListIdContentRemove = 'POST:/favorite/listens/{playListId}/content/remove';

  /// 根据课程和语言水平获取计划起点 /course/$courseId/tier/unit
  static const String courseTierUnit = 'GET:/course/{courseId}/tier/unit';
  /// 获取课程模块单元列表 /course/$courseId/level/$levelId/module/$moduleId/unit/simaple/list
  static const String courseLevelModuleUnitList = 'GET:/course/{courseId}/level/{levelId}/module/{moduleId}/unit/simaple/list';
   /// 判断单元修改是否满足条件 /member/course/plan/course/$courseId/unit/validate/assessment
  static const String memberCoursePlanCourseUnitValidateAssessment = 'POST:/member/course/plan/course/{courseId}/unit/validate/assessment';
  /// 获取用户端token /resource/token
  static const String resourceToken = 'POST:/resource/token';

  /// AI方式获取教材信息 /user/custom/load/isbn/infos
  static const String userCustomLoadIsbnInfos = 'POST:/user/custom/load/isbn/infos';
  /// 获取自定义课程添加知识点信息 扫码人数 和 大概完成时间 bookId /user/custom/v2/add/knowledge/info/page
  static const String userCustomV2AddKnowledgeInfoPage = 'GET:/user/custom/v2/add/knowledge/info/page';
  /// ISBN码获取教材信息 /course/user/custom/load/isbn/$isbn/info
  static const String courseUserCustomLoadIsbnInfo = 'POST:/user/custom/load/isbn/{isbn}/info';
  /// 获取订单id /user/custom/load/product/info
  static const String userCustomLoadProductInfo = 'GET:/user/custom/load/product/info';
  /// 购买结算明细 /service/package/shopping/detail
  static const String servicePackageShoppingDetail = 'POST:/service/package/shopping/detail';
  /// 用户自定义课程完成 /user/custom/confirm/course/finish
  static const String userCustomConfirmCourseFinish = 'POST:/user/custom/confirm/course/finish';
  /// 教材重拍 /user/custom/book/reshot
  static const String userCustomBookReshot = 'POST:/user/custom/book/reshot';
  /// 上传isbn记录 /user/custom/upload/isbn/record/{recordId}
  static const String userCustomUploadIsbnRecord = 'POST:/user/custom/upload/isbn/record/{recordId}';
  /// 教材未找到记录 /user/custom/book/un/found/record
  static const String userCustomBookUnFoundRecord = 'POST:/user/custom/book/un/found/record';
  /// 切换课程等级 /user/custom/course/level/change
  static const String userCustomCourseLevelChange = 'POST:/user/custom/course/level/change';
  /// v2复用其他词汇 /user/custom/v2/reuse/other/vocabulary
  static const String userCustomV2ReuseOtherVocabulary = 'POST:/user/custom/v2/reuse/other/vocabulary';
  /// 重试添加知识点 /user/custom/retry/add/knowledge
  static const String userCustomRetryAddKnowledge = 'POST:/user/custom/retry/add/knowledge';
  /// 获取生成状态信息 /user/custom/load/generate/status/info
  static const String userCustomLoadGenerateStatusInfo = 'GET:/user/custom/load/generate/status/info';
  /// 复用其他词汇 /user/custom/reuse/other/vocabulary
  static const String userCustomReuseOtherVocabulary = 'POST:/user/custom/reuse/other/vocabulary';
  /// 获取课程模块列表 /user/custom/course/{uid}/module/list
  static const String userCustomCourseModuleList = 'GET:/user/custom/course/{uid}/module/list';
  /// 获取课程等级模块列表 /user/custom/course/level/module/list
  static const String userCustomCourseLevelModuleList = 'GET:/user/custom/course/level/module/list';
  /// 创建课程单元 /user/custom/course/unit/create
  static const String userCustomCourseUnitCreate = 'POST:/user/custom/course/unit/create';
  /// 开始模块分析页 /user/custom/course/module/{uid}/analysis/page/start
  static const String userCustomCourseModuleAnalysisPageStart = 'POST:/user/custom/course/module/{uid}/analysis/page/start';
  /// 课程模块进度 /user/custom/course/progress/module
  static const String userCustomCourseProgressModule = 'POST:/user/custom/course/progress/module';
  /// 获取自定义课程列表 /user/custom/course/list
  static const String userCustomCourseList = 'GET:/user/custom/course/list';
  /// 编辑课程单元 /user/custom/course/unit/{uid}/edit
  static const String userCustomCourseUnitEdit = 'POST:/user/custom/course/unit/{uid}/edit';
  /// 获取模块知识点列表 /user/custom/course/module/{uid}/knowledge/list
  static const String userCustomCourseModuleKnowledgeList = 'GET:/user/custom/course/module/{uid}/knowledge/list';
  /// 获取等级模块列表详情 /user/custom/course/level/module/list/info
  static const String userCustomCourseLevelModuleListInfo = 'GET:/user/custom/course/level/module/list/info';

  /// 获取最后一次的评测状态 如果为空 说明没有评测 就调用开始评测接口 如果有评测 那么调用继续评测接口 /member/assessment/last/status
  static const String memberAssessmentLastStatus = 'GET:/member/assessment/last/status';

  /// 获取难度等级列表 /course/level/tier/list
  static const String courseLevelTierList = 'GET:/course/level/tier/list';
  /// 新增年级 /user/custom/v2/course/level/create
  static const String userCustomV2CourseLevelCreate = 'POST:/user/custom/v2/course/level/create';
  /// 课程自动整理 /user/custom/course/$courseId/autoSort
  static const String userCustomCourseAutoSort = 'POST:/user/custom/course/{courseId}/autoSort';
  /// 移动教材 /user/custom/v3/course/order
  static const String userCustomV3CourseOrder = 'POST:/user/custom/v3/course/order';
  /// 切换等级状态 /user/custom/course/level/$levelId/status/switch 
  static const String userCustomCourseLevelStatusSwitch = 'POST:/user/custom/course/level/{uid}/status/switch';
  /// 编辑年级 /user/custom/course/level/$levelId/edit
  static const String userCustomCourseLevelEdit = 'POST:/user/custom/course/level/{uid}/edit';
  /// 切换模块状态 /user/custom/course/module/$moduleId/status/switch 
  static const String userCustomCourseModuleStatusSwitch = 'POST:/user/custom/course/module/{uid}/status/switch';
  /// 编辑模块 /user/custom/course/module/$moduleId/edit 
  static const String userCustomCourseModuleEdit = 'POST:/user/custom/course/module/{uid}/edit';

  /// 兑换卡券获取信息 /coupon/activate/start
  static const String couponActivateStart = 'POST:/coupon/activate/start';
  /// 兑换卡券 /coupon/activate
  static const String couponActivate = 'POST:/coupon/activate';


}


class HttpAuthBoxWidget extends StatelessWidget {
  /// 权限code [HttpAuthCodes]
  final List<String> authCodes;
  /// 是否任意权限满足即可，默认为 false，表示需要同时满足所有权限
  final bool isAny;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// * 权限判断的包装类
  /// * 需要先初始化 [HttpAuthUtils.setAuthCodes], 如果不需要判断需要清空 [HttpAuthUtils.clearAuthCodes]
  /// * 没有权限会隐藏 [child]
  const HttpAuthBoxWidget({
    super.key, 
    required this.authCodes, 
    this.isAny = false, 
    this.child, 
    this.padding, 
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    if(isAny){
      if (!HttpAuthUtils.instance.isAnyAuth(authCodes)) return const SizedBox.shrink();
    }else{
      if (!HttpAuthUtils.instance.isAuths(authCodes)) return const SizedBox.shrink();
    }

    return Container(
      padding: padding,
      margin: margin,
      child: child,
    );
  }
}
