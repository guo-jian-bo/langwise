import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/elements/elements_morpheme_detils/views/elements_morpheme_detils_view.dart';
import '../modules/elements/elements_phrase_detils/views/elements_phrase_detils_view.dart';
import '../modules/elements/elements_sentence_detils/views/elements_sentence_detils_view.dart';
import '../modules/elements/elements_word_detils/views/elements_word_detils_view.dart';
import '../modules/elements/memory_card_list/views/memory_card_list_view.dart';
import '../modules/elements/memory_recorder_chart/views/memory_recorder_chart_view.dart';
import '../modules/user_center/views/user_center_view.dart';
import '../modules/user_center/member_center/views/member_center_view.dart';
import '../modules/user_center/manage_students/views/manage_students_view.dart';
import '../modules/user_center/my_coupons/views/my_coupons_view.dart';
import '../modules/user_center/learning_point_details/views/learning_point_details_view.dart';
import '../modules/user_center/open_member_settlement/views/open_member_settlement_view.dart';
import '../modules/user_center/edit_user_profile/views/edit_user_profile_view.dart';
import '../modules/user_center/about_us/views/about_us_view.dart';
import '../modules/user_center/recharge_naibi/views/recharge_naibi_view.dart';
import '../modules/user_center/recharge_point/views/recharge_point_view.dart';
import '../modules/web_page/views/web_page_view.dart';
import '../modules/user_center/my_coupons/limit_discoun_detail/views/limit_discoun_detail_view.dart';
import '../modules/favourite/views/favourite_view.dart';
import '../modules/user_center/feedback_opinion/views/feedback_opinion_view.dart';
import '../modules/user_center/Illegal_reporting/views/illegal_reporting_view.dart';
import '../modules/user_center/dream_building_team/views/dream_building_team_view.dart';
import '../modules/user_center/become_inviter/views/become_inviter_view.dart';
import '../modules/user_center/invitation_list/views/invitation_list_view.dart';
import '../modules/user_center/open_source_license/views/open_source_license_view.dart';
import '../modules/user_center/user_evaluation_level/views/user_evaluation_level_view.dart';
import '../modules/user_center/assessment_history_time_machine/views/assessment_history_time_machine_view.dart';
import '../modules/user_center/evaluation/views/user_evaluation_view.dart';
import '../modules/specialty/phonics_course/views/phonics_course_view.dart';
import '../modules/subscribe_and_listening_details/view.dart';
import '../modules/practice_questions/views/practice_questions_view.dart';
import '../modules/practice_questions/practice_questions_eval/views/practice_questions_eval_view.dart';
import '../modules/listen_and_read/views/listen_and_read_view.dart';
import '../modules/video_task_player/views/video_task_player_view.dart';
import '../modules/zhendu_look/views/zhendu_look_view.dart';
import '../modules/zhendu_perform/views/zhendu_perform_view.dart';
import '../modules/zhendu/practice/views/zhendu_practice_view.dart';
import '../modules/zhendu/show_detail/views/zhendu_show_detail_view.dart';
import '../modules/create_study_plan/views/new_create_study_plan_view.dart';
import '../modules/today_plan/views/today_plan_view.dart';
import '../modules/today_plan/super_memo_calender/views/super_memo_calender_view.dart';
import '../modules/create_study_plan/select_learning_module/views/select_learning_module_view.dart';
import '../modules/mission_control_center/views/mission_control_center_view.dart';
import '../modules/mission_control_center/mission_complete/views/mission_complete_view.dart';
import '../modules/mission_control_center/mission_test_result/views/mission_test_result_view.dart';
import '../modules/mission_control_center/mission_special/views/mission_special_view.dart';
import '../modules/exam_preparation/views/exam_preparation_view.dart';
import '../modules/preparation_plan_list/views/preparation_plan_list_view.dart';
import '../modules/membership_card_manage/views/membership_card_manage_view.dart';
import '../modules/membership_card_manage/membership_card_manage_generate_record/views/membership_card_manage_generate_record_view.dart';
import '../modules/membership_card_manage/membership_card_manage_rebate_record/views/membership_card_manage_rebate_record_view.dart';
import '../modules/membership_card_manage/membership_card_manage_recharge_record/views/membership_card_manage_recharge_record_view.dart';
import '../modules/membership_card_manage/membership_card_manage_agent_dashboard/views/membership_card_manage_agent_dashboard_view.dart';
import '../modules/customized_courses/views/customized_courses_view.dart';
import '../modules/customized_courses/custom_course_generation_detail/views/custom_course_generation_detail_view.dart';
import '../modules/customized_courses/upload_book_info/views/upload_book_info_view.dart';
import '../modules/customized_courses/custom_course_manage_photos/views/custom_course_manage_photos_view.dart';
import '../modules/customized_courses/custom_course_shoot_words/views/custom_course_shoot_words_view.dart';
import '../modules/customized_courses/custom_course_check_knowledge/views/custom_course_check_knowledge_view.dart';
import '../modules/custom_course/views/custom_course_view.dart';
import '../modules/custom_course/custom_course_add_grade/views/custom_course_add_grade_view.dart';
import '../modules/custom_course/custom_course_manage_grade/views/custom_course_manage_grade_view.dart';
import '../modules/custom_course/custom_course_manage_grade/custom_course_manage_grade_sort/views/custom_course_manage_grade_sort_view.dart';
import '../modules/official_course_details/official_course_details_target/views/official_course_details_target_view.dart';
import '../modules/official_course_details/official_course_details_preview/views/official_course_details_preview_view.dart';
import '../modules/official_course_details/official_course_details_dictation/views/official_course_details_dictation_view.dart';
import '../modules/official_course_details/official_course_details_dictation/official_course_details_dictation_check/views/official_course_details_dictation_check_view.dart';
import '../modules/official_course_details/official_course_details_flash_notes/views/official_course_details_flash_notes_view.dart';
import '../modules/official_course_details/views/official_course_details_view.dart';
import '../modules/official_course_details/official_course_details_level/views/official_course_details_level_view.dart';
import '../modules/official_course_details/course_level_select_unit/views/course_level_select_unit_view.dart';
import '../modules/official_course_details/official_course_details_unit_script/views/official_course_details_unit_script_view.dart';
import '../modules/application/views/application_view.dart';
import 'routes.dart';

class TagRoutes{

  /// 页面注册表：route -> View.to 方法
  static final Map<String, Future<dynamic> Function({dynamic arguments, required String tag})> _pages = {
    Routes.APPLICATION: ApplicationView.to,
    Routes.EN_WORD_DETAIL: ElementsWordDetilsView.to,
    Routes.EN_PHRASE_DETAIL: ElementsPhraseDetilsView.to,
    Routes.EN_SENTENCE_DETAIL: ElementsSentenceDetilsView.to,
    Routes.EN_MORPHEME_DETAIL: ElementsMorphemeDetilsView.to,
    Routes.MEMORY_CARD_LIST: MemoryCardListView.to,
    Routes.MEMORY_RECORDER_CHART: MemoryRecorderChartView.to,
    Routes.USER_CENTER: UserCenterView.to,
    Routes.MEMBER_CENTER: MemberCenterView.to,
    Routes.MANAGE_STUDENTS: ManageStudentsView.to,
    Routes.MY_COUPONS: MyCouponsView.to,
    Routes.LEARNING_POINT_DETAILS: LearningPointDetailsView.to,
    Routes.OPEN_MEMBER_SETTLEMENT: OpenMemberSettlementView.to,
    Routes.EDIT_USER_PROFILE: EditUserProfileView.to,
    Routes.ABOUT_US: AboutUsView.to,
    Routes.WEB_PAGE: WebPageView.to,
    Routes.LIMIT_DISCOUN_DETAIL: LimitDiscounDetailView.to,
    Routes.RECHARGE_NAIBI: RechargeNaibiView.to,
    Routes.RECHARGE_POINT: RechargePointView.to,
    Routes.FAVOURITE: FavouriteView.to,
    Routes.FEEDBACK_OPINION: FeedbackOpinionView.to,
    Routes.ILLEGAL_REPORTING: IllegalReportingView.to,
    Routes.DREAM_BUILDING_TEAM: DreamBuildingTeamView.to,
    Routes.BECOME_INVITER: BecomeInviterView.to,
    Routes.INVITATION_LIST: InvitationListView.to,
    Routes.OPEN_SOURCE_LICENSE: OpenSourceLicenseView.to,
    Routes.USER_EVALUATION_LEVEL: UserEvaluationLevelView.to,
    Routes.ASSESSMENT_HISTORY_TIME_MACHINE: AssessmentHistoryTimeMachineView.to,
    Routes.USER_EVALUATION: UserEvaluationView.to,
    Routes.PHONICS_COURSE: PhonicsCourseView.to,
    Routes.APP_SUBSCRIBE_LISTENING_DETAILS: SubListenDetailsPage.to,
    Routes.PRACTICE_QUESTIONS: PracticeQuestionsView.to,
    Routes.PRACTICE_QUESTIONS_EVAL: PracticeQuestionsEvalView.to,
    Routes.OFFICIAL_COURSE_DETAILS: OfficialCourseDetailsView.to,
    Routes.OFFICIAL_COURSE_DETAILS_LEVEL: OfficialCourseDetailsLevelView.to,
    Routes.COURSE_LEVEL_SELECT_UNIT: CourseLevelSelectUnitView.to,
    Routes.OFFICIAL_COURSE_DETAILS_TARGET: OfficialCourseDetailsTargetView.to,
    Routes.OFFICIAL_COURSE_DETAILS_PREVIEW: OfficialCourseDetailsPreviewView.to,
    Routes.OFFICIAL_COURSE_DETAILS_DICTATION: OfficialCourseDetailsDictationView.to,
    Routes.OFFICIAL_COURSE_DETAILS_DICTATION_CHECK: OfficialCourseDetailsDictationCheckView.to,
    Routes.OFFICIAL_COURSE_DETAILS_FLASH_NOTES: OfficialCourseDetailsFlashNotesView.to,
    Routes.OFFICIAL_COURSE_DETAILS_UNIT_SCRIPT_LIST: OfficialCourseDetailsUnitScriptView.to,
    Routes.LISTEN_AND_READ: ListenAndReadView.to,
    Routes.VIDEO_TASK_PLAYER: VideoTaskPlayerView.to,
    Routes.ZHENDU_LOOK: ZhenduLookView.to,
    Routes.ZHENDU_PERFORM: ZhenduPerformView.to,
    Routes.ZHENDU_PRACTICE: ZhenduPracticeView.to,
    Routes.ZHENDU_SHOW_DETAIL: ZhenduShowDetailView.to,
    Routes.NEW_CREATE_STUDY_PLAN: NewCreateStudyPlanView.to,
    Routes.TODAY_PLAN: TodayPlanView.to,
    Routes.SUPER_MEMO_CALENDER: SuperMemoCalenderView.to,
    Routes.SELECT_LEARNING_MODULE: SelectLearningModuleView.to,
    Routes.MISSION_CONTROL_CENTER: MissionControlCenterView.to,
    Routes.MISSION_COMPLETE: MissionCompleteView.to,
    Routes.MISSION_TEST_RESULT: MissionTestResultView.to,
    Routes.MISSION_SPECIAL: MissionSpecialView.to,
    Routes.EXAM_PREPARATION: ExamPreparationView.to,
    Routes.PREPARATION_PLAN_LIST: PreparationPlanListView.to,
    Routes.MEMBERSHIP_CARD_MANAGE: MembershipCardManageView.to,
    Routes.MEMBERSHIP_CARD_MANAGE_GENERATE_RECORD: MembershipCardManageGenerateRecordView.to,
    Routes.MEMBERSHIP_CARD_MANAGE_REBATE_RECORD: MembershipCardManageRebateRecordView.to,
    Routes.MEMBERSHIP_CARD_MANAGE_RECHARGE_RECORD: MembershipCardManageRechargeRecordView.to,
    Routes.MEMBERSHIP_CARD_MANAGE_AGENT_DASHBOARD: MembershipCardManageAgentDashboardView.to,
    Routes.CUSTOMIZED_COURSES: CustomizedCoursesView.to,
    Routes.CUSTOM_COURSE_GENERATION_DETAIL: CustomCourseGenerationDetailView.to,
    Routes.UPLOAD_BOOK_INFO: UploadBookInfoView.to,
    Routes.CUSTOM_COURSE_MANAGE_PHOTOS: CustomCourseManagePhotosView.to,
    Routes.CUSTOM_COURSE_SHOOT_WORDS: CustomCourseShootWordsView.to,
    Routes.CUSTOM_COURSE_CHECK_KNOWLEDGE: CustomCourseCheckKnowledgeView.to,
    Routes.CUSTOM_COURSE: CustomCourseView.to,
    Routes.CUSTOM_COURSE_ADD_GRADE: CustomCourseAddGradeView.to,
    Routes.CUSTOM_COURSE_MANAGE_GRADE: CustomCourseManageGradeView.to,
    Routes.CUSTOM_COURSE_MANAGE_GRADE_SORT: CustomCourseManageGradeSortView.to,
  };

  /// 路由历史
  static final List<TagRoutesHistoryData> _history = [];
  /// 最多存放的路由历史
  static const int _maxHistoryLength = 1000;


  /// 根据路由跳转
  static Future<T?> toNamed<T>(String route, {dynamic arguments, String? tagText}) async {
    final tag = tagText ?? '${route}_${DateTime.now().millisecondsSinceEpoch}';
    final toMethod = _pages[route];
    if (toMethod != null) {
      addHistory(route, tag, arguments);
      try {
        final result = await toMethod(arguments: arguments, tag: tag);
        return result as T?;
      } finally {
        _removeHistoryByTag(tag);
        _markLastAsCurrent();
      }
    }
    if (kDebugMode) {
      print('⚠️ [ManagePageRegistry] 未注册的路由: $route');
    }
    return null;
  }

  /// 替换当前页面并跳转到新页面
  /// 相当于先 Get.back() 再 jumpTo()
  static Future<T?> offAndToNamed<T>(String route, {dynamic arguments}) async {
    // 先返回上一页
    final canPop = Get.key.currentState?.canPop() ?? false;
    if (canPop) {
      TagRoutesHistoryData? current = getCurrentRoute();
      if (current == null) {
        for (var i = _history.length - 1; i >= 0; i--) {
          if (_history[i].isCurrentRoute) {
            current = _history[i];
            break;
          }
        }
      }
      current ??= _history.isNotEmpty ? _history.last : null;
      final removeTarget = current;
      if (removeTarget != null) {
        _history.removeWhere((e) => e.route == removeTarget.route && e.tag == removeTarget.tag);
      }
      Get.back();
    }
    // 再跳转到新页面
    return await toNamed<T>(route, arguments: arguments);
  }

  static Future<T?> offNamed<T>(String route, {dynamic arguments}) async{
    return await offAndToNamed(route, arguments: arguments);
  }

  /// 返回到指定路由，然后跳转到新页面
  /// predicate: 返回 true 时停止返回
  static Future<T?> offNamedUntil<T>(
    String route, 
    bool Function(Route<dynamic>) predicate, {
    dynamic arguments,
  }) async {
    // 使用 Get.until 返回到指定页面
    // 由于新管理端使用独立路由栈，这里简化为返回后跳转
    Get.until(predicate);
    // 再跳转到新页面
    return await toNamed<T>(route, arguments: arguments);
  }

  /// 关闭所有页面并跳转新页面
  static Future<T?> offAllNamed<T>(String route, {dynamic arguments}) async {
    _history.clear();
    return await Get.offAllNamed(route, arguments: arguments);
  }

  /// 获取堆栈中最新的一个控制器
  static S? findLast<S>(String route){
    final result = finds<S>(route);
    if(result.isEmpty) return null;
    return result.last;
  }

  /// 根据route 和 tag 获取控制器
  static S? find<S>(String route, String tag){
    final history = getHistory(route, tag);
    if (history == null) return null;
    if (!Get.isRegistered<S>(tag: tag)) return null;
    return Get.find<S>(tag: tag);
  }

  /// 根据route获取当前在堆栈中的控制器
  static List<S> finds<S>(String route){
    List<String> tags = [];
    for (final item in _history) {
      if (item.route == route) {
        tags.add(item.tag);
      }
    }
    if(tags.isEmpty) return [];

    List<S> result = [];
    for (final tag in tags) {
      if(!Get.isRegistered<S>(tag: tag)) continue;
      result.add(Get.find<S>(tag: tag));
    }
    return result;
  }

  /// 指定页面是否存在
  static bool isRegistered<S>(String route, {String? tag}) {
    if(tag == null) return findLast(route) != null;
    return find(route, tag) != null;
  }

  /// 添加历史路由
  static void addHistory(String route, String tag, dynamic arguments){
    for (final item in _history) {
      item.isCurrentRoute = false;
    }
    _history.add(TagRoutesHistoryData(route: route, tag: tag, arguments: arguments, isCurrentRoute: true));
    final over = _history.length - _maxHistoryLength;
    if (over > 0) {
      _history.removeRange(0, over);
    }
  }

  /// 根据路由获取历史路由
  static TagRoutesHistoryData? getHistory(String route, String tag){
    return _history.firstWhereOrNull((element) => element.route == route && element.tag == tag);
  }

  /// 获取当前路由
  static TagRoutesHistoryData? getCurrentRoute(){
    return _history.firstWhereOrNull((element) => element.isCurrentRoute);
  }

  static void _removeHistoryByTag(String tag) {
    _history.removeWhere((e) => e.tag == tag);
  }

  static void _markLastAsCurrent() {
    for (final item in _history) {
      item.isCurrentRoute = false;
    }
    if (_history.isNotEmpty) {
      _history.last.isCurrentRoute = true;
    }
  }

}

class TagRoutesHistoryData{
  /// 路由
  String route;
  /// 路由tag
  String tag;
  /// 路由参数
  dynamic arguments;
  /// 是否是当前路由
  bool isCurrentRoute;
  TagRoutesHistoryData({
    required this.route,
    required this.tag,
    this.arguments,
    this.isCurrentRoute = false,
  });
}
