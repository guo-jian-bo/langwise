import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../modules/application/bindings/application_binding.dart';
import '../modules/application/views/application_view.dart';
import '../modules/custom_course/bindings/custom_course_binding.dart';
import '../modules/custom_course/custom_course_add_grade/bindings/custom_course_add_grade_binding.dart';
import '../modules/custom_course/custom_course_add_grade/views/custom_course_add_grade_view.dart';
import '../modules/custom_course/views/custom_course_view.dart';
import '../modules/customized_courses/bindings/customized_courses_binding.dart';
import '../modules/customized_courses/custom_course_check_knowledge/bindings/custom_course_check_knowledge_binding.dart';
import '../modules/customized_courses/custom_course_check_knowledge/views/custom_course_check_knowledge_view.dart';
import '../modules/customized_courses/custom_course_generation_detail/bindings/custom_course_generation_detail_binding.dart';
import '../modules/customized_courses/custom_course_generation_detail/views/custom_course_generation_detail_view.dart';
import '../modules/customized_courses/custom_course_manage_photos/bindings/custom_course_manage_photos_binding.dart';
import '../modules/customized_courses/custom_course_manage_photos/views/custom_course_manage_photos_view.dart';
import '../modules/customized_courses/custom_course_shoot_words/bindings/custom_course_shoot_words_binding.dart';
import '../modules/customized_courses/custom_course_shoot_words/views/custom_course_shoot_words_view.dart';
import '../modules/customized_courses/upload_book_info/bindings/upload_book_info_binding.dart';
import '../modules/customized_courses/upload_book_info/views/upload_book_info_view.dart';
import '../modules/customized_courses/views/customized_courses_view.dart';
import '../modules/elements/elements_detils/bindings/elements_detils_binding.dart';
import '../modules/elements/elements_detils/views/elements_detils_view.dart';
import '../modules/elements/dictionary/bindings/dictionary_binding.dart';
import '../modules/elements/dictionary/views/dictionary_page.dart';
import '../modules/elements/memory_card_list/bindings/memory_card_list_binding.dart';
import '../modules/elements/memory_card_list/views/memory_card_list_view.dart';
import '../modules/elements/memory_recorder_chart/bindings/memory_recorder_chart_binding.dart';
import '../modules/elements/memory_recorder_chart/views/memory_recorder_chart_view.dart';
import '../modules/elements/morpheme/bindings/morpheme_binding.dart';
import '../modules/elements/morpheme/views/morpheme_page.dart';
import '../modules/exam_preparation/bindings/exam_preparation_binding.dart';
import '../modules/exam_preparation/views/exam_preparation_view.dart';
import '../modules/favourite/bindings/favourite_binding.dart';
import '../modules/favourite/views/favourite_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/listen_and_read/bindings/listen_and_read_binding.dart';
import '../modules/listen_and_read/views/listen_and_read_view.dart';
import '../modules/management/bindings/management_binding.dart';
import '../modules/management/views/management_view.dart';
import '../modules/membership_card_manage/bindings/membership_card_manage_binding.dart';
import '../modules/membership_card_manage/membership_card_manage_agent_dashboard/bindings/membership_card_manage_agent_dashboard_binding.dart';
import '../modules/membership_card_manage/membership_card_manage_agent_dashboard/views/membership_card_manage_agent_dashboard_view.dart';
import '../modules/membership_card_manage/membership_card_manage_generate_record/bindings/membership_card_manage_generate_record_binding.dart';
import '../modules/membership_card_manage/membership_card_manage_generate_record/views/membership_card_manage_generate_record_view.dart';
import '../modules/membership_card_manage/membership_card_manage_rebate_record/bindings/membership_card_manage_rebate_record_binding.dart';
import '../modules/membership_card_manage/membership_card_manage_rebate_record/views/membership_card_manage_rebate_record_view.dart';
import '../modules/membership_card_manage/membership_card_manage_recharge_record/bindings/membership_card_manage_recharge_record_binding.dart';
import '../modules/membership_card_manage/membership_card_manage_recharge_record/views/membership_card_manage_recharge_record_view.dart';
import '../modules/membership_card_manage/views/membership_card_manage_view.dart';
import '../modules/mission_control_center/bindings/mission_control_center_binding.dart';
import '../modules/mission_control_center/mission_complete/bindings/mission_complete_binding.dart';
import '../modules/mission_control_center/mission_complete/views/mission_complete_view.dart';
import '../modules/mission_control_center/mission_content_select/bindings/mission_content_select_binding.dart';
import '../modules/mission_control_center/mission_content_select/views/mission_content_select_view.dart';
import '../modules/mission_control_center/mission_special/bindings/mission_special_binding.dart';
import '../modules/mission_control_center/mission_special/views/mission_special_view.dart';
import '../modules/mission_control_center/mission_test_result/bindings/mission_test_result_binding.dart';
import '../modules/mission_control_center/mission_test_result/views/mission_test_result_view.dart';
import '../modules/mission_control_center/views/mission_control_center_view.dart';
import '../modules/new_music/bindings/new_music_binding.dart';
import '../modules/new_music/views/new_music_view.dart';
import '../modules/official_course_details/bindings/official_course_details_binding.dart';
import '../modules/official_course_details/course_level_select_unit/bindings/course_level_select_unit_binding.dart';
import '../modules/official_course_details/course_level_select_unit/views/course_level_select_unit_view.dart';
import '../modules/official_course_details/official_course_details_dictation/bindings/official_course_details_dictation_binding.dart';
import '../modules/official_course_details/official_course_details_dictation/official_course_details_dictation_check/bindings/official_course_details_dictation_check_binding.dart';
import '../modules/official_course_details/official_course_details_dictation/official_course_details_dictation_check/views/official_course_details_dictation_check_view.dart';
import '../modules/official_course_details/official_course_details_dictation/views/official_course_details_dictation_view.dart';
import '../modules/official_course_details/official_course_details_flash_notes/bindings/official_course_details_flash_notes_binding.dart';
import '../modules/official_course_details/official_course_details_flash_notes/views/official_course_details_flash_notes_view.dart';
import '../modules/official_course_details/official_course_details_level/bindings/official_course_details_level_binding.dart';
import '../modules/official_course_details/official_course_details_level/views/official_course_details_level_view.dart';
import '../modules/official_course_details/official_course_details_preview/bindings/official_course_details_preview_binding.dart';
import '../modules/official_course_details/official_course_details_preview/views/official_course_details_preview_view.dart';
import '../modules/official_course_details/official_course_details_target/bindings/official_course_details_target_binding.dart';
import '../modules/official_course_details/official_course_details_target/views/official_course_details_target_view.dart';
import '../modules/official_course_details/official_course_details_unit_script/bindings/official_course_details_unit_script_binding.dart';
import '../modules/official_course_details/official_course_details_unit_script/views/official_course_details_unit_script_view.dart';
import '../modules/official_course_details/views/official_course_details_view.dart';
import '../modules/practice_questions/bindings/practice_questions_binding.dart';
import '../modules/practice_questions/practice_questions_eval/bindings/practice_questions_eval_binding.dart';
import '../modules/practice_questions/practice_questions_eval/views/practice_questions_eval_view.dart';
import '../modules/practice_questions/practice_questions_review/bindings/practice_questions_review_binding.dart';
import '../modules/practice_questions/practice_questions_review/views/practice_questions_review_view.dart';
import '../modules/practice_questions/views/practice_questions_view.dart';
import '../modules/preparation_plan_list/bindings/preparation_plan_list_binding.dart';
import '../modules/preparation_plan_list/views/preparation_plan_list_view.dart';
import '../modules/sign_in_up/index.dart';
import '../modules/song_mv/bindings/song_mv_binding.dart';
import '../modules/song_mv/views/song_mv_view.dart';
import '../modules/specialty/bindings/specialty_binding.dart';
import '../modules/specialty/phonics_course/bindings/phonics_course_binding.dart';
import '../modules/specialty/phonics_course/views/phonics_course_view.dart';
import '../modules/specialty/views/specialty_view.dart';
import '../modules/splash/bindings.dart';
import '../modules/splash/view.dart';
import '../modules/study_plan/select_learning_module/bindings/select_learning_module_binding.dart';
import '../modules/study_plan/select_learning_module/views/select_learning_module_view.dart';
import '../modules/subscribe_and_listening/bindings.dart';
import '../modules/subscribe_and_listening/view.dart';
import '../modules/study_plan/super_memo_calender/bindings/super_memo_calender_binding.dart';
import '../modules/study_plan/super_memo_calender/views/super_memo_calender_view.dart';
import '../modules/user_center/Illegal_reporting/bindings/illegal_reporting_binding.dart';
import '../modules/user_center/Illegal_reporting/views/illegal_reporting_view.dart';
import '../modules/user_center/about_us/bindings/about_us_binding.dart';
import '../modules/user_center/about_us/views/about_us_view.dart';
import '../modules/user_center/assessment_history_time_machine/bindings/assessment_history_time_machine_binding.dart';
import '../modules/user_center/assessment_history_time_machine/views/assessment_history_time_machine_view.dart';
import '../modules/user_center/become_inviter/bindings/become_inviter_binding.dart';
import '../modules/user_center/become_inviter/views/become_inviter_view.dart';
import '../modules/user_center/bindings/user_center_binding.dart';
import '../modules/user_center/dream_building_team/bindings/dream_building_team_binding.dart';
import '../modules/user_center/dream_building_team/views/dream_building_team_view.dart';
import '../modules/user_center/edit_user_profile/bindings/edit_user_profile_binding.dart';
import '../modules/user_center/edit_user_profile/views/edit_user_profile_view.dart';
import '../modules/user_center/evaluation/bindings/user_evaluation_binding.dart';
import '../modules/user_center/evaluation/views/user_evaluation_view.dart';
import '../modules/user_center/feedback_opinion/bindings/feedback_opinion_binding.dart';
import '../modules/user_center/feedback_opinion/views/feedback_opinion_view.dart';
import '../modules/user_center/invitation_list/bindings/invitation_list_binding.dart';
import '../modules/user_center/invitation_list/views/invitation_list_view.dart';
import '../modules/user_center/learning_point_details/bindings/learning_point_details_binding.dart';
import '../modules/user_center/learning_point_details/views/learning_point_details_view.dart';
import '../modules/user_center/manage_students/bindings/manage_students_binding.dart';
import '../modules/user_center/manage_students/views/manage_students_view.dart';
import '../modules/user_center/member_center/bindings/member_center_binding.dart';
import '../modules/user_center/member_center/views/member_center_view.dart';
import '../modules/user_center/my_coupons/bindings/my_coupons_binding.dart';
import '../modules/user_center/my_coupons/limit_discoun_detail/bindings/limit_discoun_detail_binding.dart';
import '../modules/user_center/my_coupons/limit_discoun_detail/views/limit_discoun_detail_view.dart';
import '../modules/user_center/my_coupons/views/my_coupons_view.dart';
import '../modules/user_center/open_member_settlement/bindings/open_member_settlement_binding.dart';
import '../modules/user_center/open_member_settlement/views/open_member_settlement_view.dart';
import '../modules/user_center/open_source_license/bindings/open_source_license_binding.dart';
import '../modules/user_center/open_source_license/views/open_source_license_view.dart';
import '../modules/user_center/recharge_naibi/bindings/recharge_naibi_binding.dart';
import '../modules/user_center/recharge_naibi/views/recharge_naibi_view.dart';
import '../modules/user_center/recharge_point/bindings/recharge_point_binding.dart';
import '../modules/user_center/recharge_point/views/recharge_point_view.dart';
import '../modules/user_center/user_evaluation_level/bindings/user_evaluation_level_binding.dart';
import '../modules/user_center/user_evaluation_level/views/user_evaluation_level_view.dart';
import '../modules/user_center/views/user_center_view.dart';
import '../modules/video_task_player/bindings/video_task_player_binding.dart';
import '../modules/video_task_player/views/video_task_player_view.dart';
import '../modules/web_page/bindings/web_page_binding.dart';
import '../modules/web_page/views/web_page_view.dart';
import '../modules/zhendu_look/bindings/zhendu_look_binding.dart';
import '../modules/zhendu_look/views/zhendu_look_view.dart';
import '../modules/zhendu/practice/bindings/zhendu_practice_binding.dart';
import '../modules/zhendu/practice/views/zhendu_practice_view.dart';
import '../modules/zhendu/show_detail/bindings/zhendu_show_detail_binding.dart';
import '../modules/zhendu/show_detail/views/zhendu_show_detail_view.dart';
import '../modules/zhendu_perform/bindings/zhendu_perform_binding.dart';
import '../modules/zhendu_perform/views/zhendu_perform_view.dart';
import '../modules/study_plan/views/study_plan_view.dart';
import '../modules/study_plan/bindings/study_plan_binding.dart';
import '../modules/study_plan/plan_details/views/plan_details_view.dart';
import '../modules/study_plan/plan_details/bindings/plan_details_binding.dart';
import '../modules/study_plan/plan_exercise_setting/views/plan_exercise_setting_view.dart';
import '../modules/study_plan/plan_exercise_setting/bindings/plan_exercise_setting_binding.dart';
import '../modules/learning_setting_steps/views/learning_setting_steps_view.dart';
import '../modules/learning_setting_steps/bindings/learning_setting_steps_binding.dart';
import '../modules/study_plan/plan_valid_assessment/views/plan_valid_assessment_view.dart';
import '../modules/study_plan/plan_valid_assessment/bindings/plan_valid_assessment_binding.dart';
import '../modules/intelligent_search/views/intelligent_search_view.dart';
import '../modules/intelligent_search/bindings/intelligent_search_binding.dart';
import 'app_routes_code.dart';
import 'observers.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final RouteObserver<Route> observer = RouteObservers();

  static List<String> history = [];

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_IN_UP,
      page: () => const SignInUpPage(),
      binding: SignInUpBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.APPLICATION,
      page: () => const ApplicationView(),
      binding: ApplicationBinding(),
    ),
    GetPage(
      name: _Paths.PRACTICE_QUESTIONS,
      page: () => const PracticeQuestionsView(tagText: ''),
      binding: PracticeQuestionsBinding(tagText: ''),
      children: [
        GetPage(
          name: _Paths.PRACTICE_QUESTIONS_REVIEW,
          page: () => const PracticeQuestionsReviewView(),
          binding: PracticeQuestionsReviewBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.PRACTICE_QUESTIONS_EVAL,
      page: () => const PracticeQuestionsEvalView(tagText: ''),
      binding: PracticeQuestionsEvalBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.OFFICIAL_COURSE_DETAILS,
      page: () => const OfficialCourseDetailsView(tagText: ''),
      binding: OfficialCourseDetailsBinding(tagText: ''),
      children: [
        GetPage(
          name: _Paths.OFFICIAL_COURSE_DETAILS_LEVEL,
          page: () => const OfficialCourseDetailsLevelView(tagText: ''),
          binding: OfficialCourseDetailsLevelBinding(tagText: ''),
        ),
        GetPage(
          name: _Paths.COURSE_LEVEL_SELECT_UNIT,
          page: () => const CourseLevelSelectUnitView(tagText: ''),
          binding: CourseLevelSelectUnitBinding(tagText: ''),
        ),
      ],
    ),
    GetPage(
      name: _Paths.OFFICIAL_COURSE_DETAILS_TARGET,
      page: () => const OfficialCourseDetailsTargetView(tagText: ''),
      binding: OfficialCourseDetailsTargetBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.OFFICIAL_COURSE_DETAILS_PREVIEW,
      page: () => const OfficialCourseDetailsPreviewView(tagText: ''),
      binding: OfficialCourseDetailsPreviewBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.MISSION_CONTENT_SELECT,
      page: () => const MissionContentSelectView(tagText: ''),
      binding: MissionContentSelectBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.OFFICIAL_COURSE_DETAILS_FLASH_NOTES,
      page: () => const OfficialCourseDetailsFlashNotesView(tagText: ''),
      binding: OfficialCourseDetailsFlashNotesBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.OFFICIAL_COURSE_DETAILS_DICTATION,
      page: () => const OfficialCourseDetailsDictationView(tagText: ''),
      binding: OfficialCourseDetailsDictationBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.OFFICIAL_COURSE_DETAILS_DICTATION_CHECK,
      page: () => const OfficialCourseDetailsDictationCheckView(tagText: ''),
      binding: OfficialCourseDetailsDictationCheckBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.OFFICIAL_COURSE_DETAILS_UNIT_SCRIPT_LIST,
      page: () => const OfficialCourseDetailsUnitScriptView(tagText: ''),
      binding: OfficialCourseDetailsUnitScriptBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.SELECT_LEARNING_MODULE,
      page: () => const SelectLearningModuleView(tagText: ''),
      binding: SelectLearningModuleBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.SUPER_MEMO_CALENDER,
      page: () => const SuperMemoCalenderView(tagText: ''),
      binding: SuperMemoCalenderBinding(tagText: ''),
    ),

    GetPage(
      name: _Paths.MEMBERSHIP_CARD_MANAGE,
      page: () => const MembershipCardManageView(tagText: ''),
      binding: MembershipCardManageBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.MEMBERSHIP_CARD_MANAGE_GENERATE_RECORD,
      page: () => const MembershipCardManageGenerateRecordView(tagText: ''),
      binding: MembershipCardManageGenerateRecordBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.MEMBERSHIP_CARD_MANAGE_REBATE_RECORD,
      page: () => const MembershipCardManageRebateRecordView(tagText: ''),
      binding: MembershipCardManageRebateRecordBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.MEMBERSHIP_CARD_MANAGE_RECHARGE_RECORD,
      page: () => const MembershipCardManageRechargeRecordView(tagText: ''),
      binding: MembershipCardManageRechargeRecordBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.MEMBERSHIP_CARD_MANAGE_AGENT_DASHBOARD,
      page: () => const MembershipCardManageAgentDashboardView(tagText: ''),
      binding: MembershipCardManageAgentDashboardBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.EXAM_PREPARATION,
      page: () => const ExamPreparationView(tagText: ''),
      binding: ExamPreparationBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.PREPARATION_PLAN_LIST,
      page: () => const PreparationPlanListView(tagText: ''),
      binding: PreparationPlanListBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.MEMORY_RECORDER_CHART,
      page: () => const MemoryRecorderChartView(tagText: ''),
      binding: MemoryRecorderChartBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.MEMORY_CARD_LIST,
      page: () => const MemoryCardListView(tagText: ''),
      binding: MemoryCardListBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.ELEMENTS_DETILS,
      page: () => const ElementsDetilsView(),
      binding: ElementsDetilsBinding(),
    ),
    GetPage(
      name: _Paths.USER_CENTER,
      page: () => const UserCenterView(tagText: ''),
      binding: UserCenterBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.BECOME_INVITER,
      page: () => const BecomeInviterView(tagText: ''),
      binding: BecomeInviterBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.INVITATION_LIST,
      page: () => const InvitationListView(tagText: ''),
      binding: InvitationListBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.USER_EVALUATION_LEVEL,
      page: () => const UserEvaluationLevelView(tagText: ''),
      binding: UserEvaluationLevelBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.ASSESSMENT_HISTORY_TIME_MACHINE,
      page: () => const AssessmentHistoryTimeMachineView(tagText: ''),
      binding: AssessmentHistoryTimeMachineBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.USER_EVALUATION,
      page: () => const UserEvaluationView(tagText: ''),
      binding: UserEvaluationBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.OPEN_SOURCE_LICENSE,
      page: () => const OpenSourceLicenseView(tagText: ''),
      binding: OpenSourceLicenseBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.DREAM_BUILDING_TEAM,
      page: () => const DreamBuildingTeamView(tagText: ''),
      binding: DreamBuildingTeamBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.ILLEGAL_REPORTING,
      page: () => const IllegalReportingView(tagText: ''),
      binding: IllegalReportingBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.FEEDBACK_OPINION,
      page: () => const FeedbackOpinionView(tagText: ''),
      binding: FeedbackOpinionBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.RECHARGE_POINT,
      page: () => const RechargePointView(tagText: ''),
      binding: RechargePointBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.RECHARGE_NAIBI,
      page: () => const RechargeNaibiView(tagText: ''),
      binding: RechargeNaibiBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.MEMBER_CENTER,
      page: () => const MemberCenterView(tagText: ''),
      binding: MemberCenterBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.MANAGE_STUDENTS,
      page: () => const ManageStudentsView(tagText: ''),
      binding: ManageStudentsBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.MY_COUPONS,
      page: () => const MyCouponsView(tagText: ''),
      binding: MyCouponsBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.LIMIT_DISCOUN_DETAIL,
      page: () => const LimitDiscounDetailView(tagText: ''),
      binding: LimitDiscounDetailBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.LEARNING_POINT_DETAILS,
      page: () => const LearningPointDetailsView(tagText: ''),
      binding: LearningPointDetailsBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.OPEN_MEMBER_SETTLEMENT,
      page: () => const OpenMemberSettlementView(tagText: ''),
      binding: OpenMemberSettlementBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.EDIT_USER_PROFILE,
      page: () => const EditUserProfileView(tagText: ''),
      binding: EditUserProfileBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.ABOUT_US,
      page: () => const AboutUsView(tagText: ''),
      binding: AboutUsBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.WEB_PAGE,
      page: () => const WebPageView(tagText: ''),
      binding: WebPageBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.CUSTOMIZED_COURSES,
      page: () => const CustomizedCoursesView(tagText: ''),
      binding: CustomizedCoursesBinding(tagText: ''),
      children: [
        GetPage(
          name: _Paths.UPLOAD_BOOK_INFO,
          page: () => const UploadBookInfoView(tagText: ''),
          binding: UploadBookInfoBinding(tagText: ''),
        ),
      ],
    ),
    GetPage(
      name: _Paths.CUSTOM_COURSE_GENERATION_DETAIL,
      page: () => const CustomCourseGenerationDetailView(tagText: ''),
      binding: CustomCourseGenerationDetailBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.CUSTOM_COURSE_MANAGE_PHOTOS,
      page: () => const CustomCourseManagePhotosView(tagText: ''),
      binding: CustomCourseManagePhotosBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.CUSTOM_COURSE_SHOOT_WORDS,
      page: () => const CustomCourseShootWordsView(tagText: ''),
      binding: CustomCourseShootWordsBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.CUSTOM_COURSE_CHECK_KNOWLEDGE,
      page: () => const CustomCourseCheckKnowledgeView(tagText: ''),
      binding: CustomCourseCheckKnowledgeBinding(tagText: ''),
    ),

    // 自定义课程
    GetPage(
      name: _Paths.CUSTOM_COURSE,
      page: () => const CustomCourseView(tagText: ''),
      binding: CustomCourseBinding(tagText: ''),
    ),
    // 自定义课程添加年级
    GetPage(
      name: _Paths.CUSTOM_COURSE_ADD_GRADE,
      page: () => const CustomCourseAddGradeView(tagText: ''),
      binding: CustomCourseAddGradeBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.MISSION_CONTROL_CENTER,
      page: () => const MissionControlCenterView(tagText: ''),
      binding: MissionControlCenterBinding(tagText: ''),
      children: [
        GetPage(
          name: _Paths.MISSION_COMPLETE,
          page: () => const MissionCompleteView(tagText: ''),
          binding: MissionCompleteBinding(tagText: ''),
        ),
        GetPage(
          name: _Paths.MISSION_TEST_RESULT,
          page: () => const MissionTestResultView(tagText: ''),
          binding: MissionTestResultBinding(tagText: ''),
        ),
      ],
    ),
    GetPage(
      name: _Paths.MISSION_SPECIAL,
      page: () => const MissionSpecialView(tagText: ''),
      binding: MissionSpecialBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.LISTEN_AND_READ,
      page: () => const ListenAndReadView(tagText: ''),
      binding: ListenAndReadBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.PHONICS_COURSE,
      page: () => const PhonicsCourseView(tagText: ''),
      binding: PhonicsCourseBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.SPECIALTY,
      page: () => const SpecialtyView(),
      binding: SpecialtyBinding(),
    ),
    GetPage(
      name: _Paths.APP_SUBSCRIBE_LISTENING,
      page: () => const SubListenPage(tagText: Routes.APP_SUBSCRIBE_LISTENING),
      binding: SubListenBinding(),
    ),
    GetPage(
      name: _Paths.SONG_MV,
      page: () => const SongMvView(),
      binding: SongMvBinding(),
    ),
    GetPage(
      name: _Paths.VIDEO_TASK_PLAYER,
      page: () => const VideoTaskPlayerView(tagText: ''),
      binding: VideoTaskPlayerBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.MUSIC,
      page: () => const NewMusicView(tagText: Routes.MUSIC),
      binding: NewMusicBinding(),
    ),
    GetPage(
      name: _Paths.DICTIONARY,
      page: () => const DictionaryPage(tagText: Routes.DICTIONARY),
      binding: DictionaryBinding(tagText: Routes.DICTIONARY),
    ),
    GetPage(
      name: _Paths.DICTIONARY_MORPHEME,
      page: () => const MorphemePage(tagText: Routes.DICTIONARY_MORPHEME),
      binding: MorphemeBinding(tagText: Routes.DICTIONARY_MORPHEME),
    ),
    GetPage(
      name: _Paths.FAVOURITE,
      page: () => const FavouriteView(tagText: ''),
      binding: FavouriteBinding(tagText: ''),
    ),

    GetPage(
      name: _Paths.ZHENDU_LOOK,
      page: () => const ZhenduLookView(tagText: ''),
      binding: ZhenduLookBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.ZHENDU_PERFORM,
      page: () => const ZhenduPerformView(tagText: ''),
      binding: ZhenduPerformBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.ZHENDU_PRACTICE,
      page: () => const ZhenduPracticeView(tagText: ''),
      binding: ZhenduPracticeBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.ZHENDU_SHOW_DETAIL,
      page: () => const ZhenduShowDetailView(tagText: ''),
      binding: ZhenduShowDetailBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.STUDY_PLAN,
      page: () => const StudyPlanView(tagText: ''),
      binding: StudyPlanBinding(tagText: ''),
    ),

    

    GetPage(
      name: _Paths.MANAGEMENT,
      page: () => const ManagementView(),
      binding: ManagementBinding(),
      children: [
        ...manageRoutes,
      ],
    ),

    GetPage(
      name: _Paths.PLAN_DETAILS,
      page: () => const PlanDetailsView(tagText: ''),
      binding: PlanDetailsBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.PLAN_EXERCISE_SETTING,
      page: () => const PlanExerciseSettingView(tagText: ''),
      binding: PlanExerciseSettingBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.LEARNING_SETTING_STEPS,
      page: () => const LearningSettingStepsView(tagText: ''),
      binding: LearningSettingStepsBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.PLAN_VALID_ASSESSMENT,
      page: () => const PlanValidAssessmentView(tagText: ''),
      binding: PlanValidAssessmentBinding(tagText: ''),
    ),
    GetPage(
      name: _Paths.INTELLIGENT_SEARCH,
      page: () => const IntelligentSearchView(tagText: ''),
      binding: IntelligentSearchBinding(tagText: ''),
    ),
  ];

  // 以下路由已改用 Get.to() + tag 方式跳转，不再使用命名路由
  // 详见 [GETX_MULTI_INSTANCE_GUIDE.md]
  static final manageRoutes = [];
}
