import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../modules/application/bindings/application_binding.dart';
import '../modules/application/views/application_view.dart';
import '../modules/create_study_plan/bindings/create_study_plan_binding.dart';
import '../modules/create_study_plan/bindings/new_create_study_plan_binding.dart';
import '../modules/create_study_plan/select_learning_module/bindings/select_learning_module_binding.dart';
import '../modules/create_study_plan/select_learning_module/views/select_learning_module_view.dart';
import '../modules/create_study_plan/views/create_study_plan_view.dart';
import '../modules/create_study_plan/views/new_create_study_plan_view.dart';
import '../modules/custom_course/bindings/custom_course_binding.dart';
import '../modules/custom_course/custom_course_add_grade/bindings/custom_course_add_grade_binding.dart';
import '../modules/custom_course/custom_course_add_grade/views/custom_course_add_grade_view.dart';
import '../modules/custom_course/custom_course_manage_grade/bindings/custom_course_manage_grade_binding.dart';
import '../modules/custom_course/custom_course_manage_grade/custom_course_manage_grade_sort/bindings/custom_course_manage_grade_sort_binding.dart';
import '../modules/custom_course/custom_course_manage_grade/custom_course_manage_grade_sort/views/custom_course_manage_grade_sort_view.dart';
import '../modules/custom_course/custom_course_manage_grade/views/custom_course_manage_grade_view.dart';
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
import '../modules/elements/elements_collect_card/bindings/elements_collect_card_binding.dart';
import '../modules/elements/elements_collect_card/views/elements_collect_card_view.dart';
import '../modules/elements/elements_detils/bindings/elements_detils_binding.dart';
import '../modules/elements/elements_detils/views/elements_detils_view.dart';
import '../modules/elements/elements_upgrade_card/bindings/elements_upgrade_card_binding.dart';
import '../modules/elements/elements_upgrade_card/views/elements_upgrade_card_view.dart';
import '../modules/elements/memory_card_list/bindings/memory_card_list_binding.dart';
import '../modules/elements/memory_card_list/views/memory_card_list_view.dart';
import '../modules/elements/memory_recorder_chart/bindings/memory_recorder_chart_binding.dart';
import '../modules/elements/memory_recorder_chart/views/memory_recorder_chart_view.dart';
import '../modules/exam_preparation/bindings/exam_preparation_binding.dart';
import '../modules/exam_preparation/views/exam_preparation_view.dart';
import '../modules/favourite/bindings/favourite_binding.dart';
import '../modules/favourite/views/favourite_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/image_moderation_admin/index.dart';
import '../modules/image_moderation_admin_detail/index.dart';
import '../modules/image_moderation_detail/bindings.dart';
import '../modules/image_moderation_detail/view.dart';
import '../modules/image_moderation_list/index.dart';
import '../modules/listen_and_read/bindings/listen_and_read_binding.dart';
import '../modules/listen_and_read/views/listen_and_read_view.dart';
import '../modules/management/bindings/management_binding.dart';
import '../modules/management/views/management_view.dart';
import '../modules/membership_card_manage/bindings/membership_card_manage_binding.dart';
import '../modules/membership_card_manage/views/membership_card_manage_view.dart';
import '../modules/mission_control_center/bindings/mission_control_center_binding.dart';
import '../modules/mission_control_center/mission_complete/bindings/mission_complete_binding.dart';
import '../modules/mission_control_center/mission_complete/views/mission_complete_view.dart';
import '../modules/mission_control_center/mission_special/bindings/mission_special_binding.dart';
import '../modules/mission_control_center/mission_special/views/mission_special_view.dart';
import '../modules/mission_control_center/mission_test_result/bindings/mission_test_result_binding.dart';
import '../modules/mission_control_center/mission_test_result/views/mission_test_result_view.dart';
import '../modules/mission_control_center/views/mission_control_center_view.dart';
import '../modules/music/bindings/music_binding.dart';
import '../modules/music/views/music_view.dart';
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
import '../modules/official_course_details/views/official_course_details_view.dart';
import '../modules/practice_questions/bindings/practice_questions_binding.dart';
import '../modules/practice_questions/exercise_completed/bindings/exercise_completed_binding.dart';
import '../modules/practice_questions/exercise_completed/views/exercise_completed_view.dart';
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
import '../modules/video_task_player/bindings/video_task_player_binding.dart';
import '../modules/video_task_player/views/video_task_player_view.dart';
import '../modules/specialty/bindings/specialty_binding.dart';
import '../modules/specialty/phonics_course/bindings/phonics_course_binding.dart';
import '../modules/specialty/phonics_course/views/phonics_course_view.dart';
import '../modules/specialty/views/specialty_view.dart';
import '../modules/splash/bindings.dart';
import '../modules/splash/view.dart';
import '../modules/subscribe_and_listening/bindings.dart';
import '../modules/subscribe_and_listening/view.dart';
import '../modules/subscribe_and_listening_details/bindings.dart';
import '../modules/subscribe_and_listening_details/view.dart';
import '../modules/today_plan/bindings/today_plan_binding.dart';
import '../modules/today_plan/edit_today_plan/bindings/edit_today_plan_binding.dart';
import '../modules/today_plan/edit_today_plan/views/edit_today_plan_view.dart';
import '../modules/today_plan/super_memo_calender/bindings/super_memo_calender_binding.dart';
import '../modules/today_plan/super_memo_calender/views/super_memo_calender_view.dart';
import '../modules/today_plan/views/today_plan_view.dart';
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
import '../modules/user_center/personal_data/bindings/personal_data_binding.dart';
import '../modules/user_center/personal_data/views/personal_data_view.dart';
import '../modules/user_center/recharge_naibi/bindings/recharge_naibi_binding.dart';
import '../modules/user_center/recharge_naibi/views/recharge_naibi_view.dart';
import '../modules/user_center/recharge_point/bindings/recharge_point_binding.dart';
import '../modules/user_center/recharge_point/views/recharge_point_view.dart';
import '../modules/user_center/series_of_pictures/bindings/series_of_pictures_binding.dart';
import '../modules/user_center/series_of_pictures/views/series_of_pictures_view.dart';
import '../modules/user_center/user_evaluation_level/bindings/user_evaluation_level_binding.dart';
import '../modules/user_center/user_evaluation_level/views/user_evaluation_level_view.dart';
import '../modules/user_center/views/user_center_view.dart';
import '../modules/web_page/bindings/web_page_binding.dart';
import '../modules/web_page/views/web_page_view.dart';
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
      page: () => const PracticeQuestionsView(),
      binding: PracticeQuestionsBinding(),
      children: [
        GetPage(
          name: _Paths.EXERCISE_COMPLETED,
          page: () => const ExerciseCompletedView(),
          binding: ExerciseCompletedBinding(),
        ),
        GetPage(
          name: _Paths.PRACTICE_QUESTIONS_REVIEW,
          page: () => const PracticeQuestionsReviewView(),
          binding: PracticeQuestionsReviewBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.PRACTICE_QUESTIONS_EVAL,
      page: () => const PracticeQuestionsEvalView(),
      binding: PracticeQuestionsEvalBinding(),
    ),
    GetPage(
      name: _Paths.OFFICIAL_COURSE_DETAILS,
      page: () => const OfficialCourseDetailsView(),
      binding: OfficialCourseDetailsBinding(),
      children: [
        GetPage(
          name: _Paths.OFFICIAL_COURSE_DETAILS_LEVEL,
          page: () => const OfficialCourseDetailsLevelView(),
          binding: OfficialCourseDetailsLevelBinding(),
        ),
        GetPage(
          name: _Paths.COURSE_LEVEL_SELECT_UNIT,
          page: () => const CourseLevelSelectUnitView(),
          binding: CourseLevelSelectUnitBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.OFFICIAL_COURSE_DETAILS_TARGET,
      page: () => const OfficialCourseDetailsTargetView(),
      binding: OfficialCourseDetailsTargetBinding(),
    ),
    GetPage(
      name: _Paths.OFFICIAL_COURSE_DETAILS_PREVIEW,
      page: () => const OfficialCourseDetailsPreviewView(),
      binding: OfficialCourseDetailsPreviewBinding(),
    ),
    GetPage(
      name: _Paths.OFFICIAL_COURSE_DETAILS_FLASH_NOTES,
      page: () => const OfficialCourseDetailsFlashNotesView(),
      binding: OfficialCourseDetailsFlashNotesBinding(),
    ),
    GetPage(
      name: _Paths.OFFICIAL_COURSE_DETAILS_DICTATION,
      page: () => const OfficialCourseDetailsDictationView(),
      binding: OfficialCourseDetailsDictationBinding(),
    ),
    GetPage(
      name: _Paths.OFFICIAL_COURSE_DETAILS_DICTATION_CHECK,
      page: () => const OfficialCourseDetailsDictationCheckView(),
      binding: OfficialCourseDetailsDictationCheckBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_STUDY_PLAN,
      page: () => const CreateStudyPlanView(),
      binding: CreateStudyPlanBinding(),
      children: [
        GetPage(
          name: _Paths.SELECT_LEARNING_MODULE,
          page: () => const SelectLearningModuleView(),
          binding: SelectLearningModuleBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.NEW_CREATE_STUDY_PLAN,
      page: () => const NewCreateStudyPlanView(),
      binding: NewCreateStudyPlanBinding(),
    ),
    GetPage(
      name: _Paths.TODAY_PLAN,
      page: () => const TodayPlanView(),
      binding: TodayPlanBinding(),
    ),
    GetPage(
      name: _Paths.SUPER_MEMO_CALENDER,
      page: () => const SuperMemoCalenderView(),
      binding: SuperMemoCalenderBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_TODAY_PLAN,
      page: () => const EditTodayPlanView(),
      binding: EditTodayPlanBinding(),
    ),


    GetPage(
      name: _Paths.MEMBERSHIP_CARD_MANAGE,
      page: () => const MembershipCardManageView(),
      binding: MembershipCardManageBinding(),
    ),
    GetPage(
      name: _Paths.EXAM_PREPARATION,
      page: () => const ExamPreparationView(),
      binding: ExamPreparationBinding(),
    ),
    GetPage(
      name: _Paths.PREPARATION_PLAN_LIST,
      page: () => const PreparationPlanListView(),
      binding: PreparationPlanListBinding(),
    ),
    GetPage(
      name: _Paths.IMAGE_MODERATION_DETAIL,
      page: () => const ImageModerationDetailPage(),
      binding: ImageModerationDetailBinding(),
    ),
    GetPage(
      name: _Paths.IMAGE_MODERATION_LIST,
      page: () => const ImageModerationListPage(),
      binding: ImageModerationListBinding(),
    ),
    GetPage(
      name: _Paths.IMAGE_MODERATION_ADMIN,
      page: () => const ImageModerationAdminPage(),
      binding: ImageModerationAdminBinding(),
    ),
    GetPage(
      name: _Paths.IMAGE_MODERATION_ADMIN_DETAIL,
      page: () => const ImageModerationAdminDetailPage(),
      binding: ImageModerationAdminDetailBinding(),
    ),
    GetPage(
      name: _Paths.MEMORY_RECORDER_CHART,
      page: () => const MemoryRecorderChartView(),
      binding: MemoryRecorderChartBinding(),
    ),
    GetPage(
      name: _Paths.MEMORY_CARD_LIST,
      page: () => const MemoryCardListView(),
      binding: MemoryCardListBinding(),
    ),
    GetPage(
      name: _Paths.ELEMENTS_DETILS,
      page: () => const ElementsDetilsView(),
      binding: ElementsDetilsBinding(),
    ),
    GetPage(
      name: _Paths.ELEMENTS_UPGRADE_CARD,
      page: () => const ElementsUpgradeCardView(),
      binding: ElementsUpgradeCardBinding(),
    ),
    GetPage(
      name: _Paths.ELEMENTS_COLLECT_CARD,
      page: () => const ElementsCollectCardView(),
      binding: ElementsCollectCardBinding(),
    ),
    GetPage(
      name: _Paths.USER_CENTER,
      page: () => const UserCenterView(),
      binding: UserCenterBinding(),
    ),
    GetPage(
      name: _Paths.BECOME_INVITER,
      page: () => const BecomeInviterView(),
      binding: BecomeInviterBinding(),
    ),
    GetPage(
      name: _Paths.INVITATION_LIST,
      page: () => const InvitationListView(),
      binding: InvitationListBinding(),
    ),
    GetPage(
      name: _Paths.USER_EVALUATION_LEVEL,
      page: () => const UserEvaluationLevelView(),
      binding: UserEvaluationLevelBinding(),
    ),
    GetPage(
      name: _Paths.ASSESSMENT_HISTORY_TIME_MACHINE,
      page: () => const AssessmentHistoryTimeMachineView(),
      binding: AssessmentHistoryTimeMachineBinding(),
    ),
    GetPage(
      name: _Paths.USER_EVALUATION,
      page: () => const UserEvaluationView(),
      binding: UserEvaluationBinding(),
    ),
    GetPage(
      name: _Paths.OPEN_SOURCE_LICENSE,
      page: () => const OpenSourceLicenseView(),
      binding: OpenSourceLicenseBinding(),
    ),
    GetPage(
      name: _Paths.DREAM_BUILDING_TEAM,
      page: () => const DreamBuildingTeamView(),
      binding: DreamBuildingTeamBinding(),
    ),
    GetPage(
      name: _Paths.ILLEGAL_REPORTING,
      page: () => const IllegalReportingView(),
      binding: IllegalReportingBinding(),
    ),
    GetPage(
      name: _Paths.FEEDBACK_OPINION,
      page: () => const FeedbackOpinionView(),
      binding: FeedbackOpinionBinding(),
    ),
    GetPage(
      name: _Paths.RECHARGE_POINT,
      page: () => const RechargePointView(),
      binding: RechargePointBinding(),
    ),
    GetPage(
      name: _Paths.RECHARGE_NAIBI,
      page: () => const RechargeNaibiView(),
      binding: RechargeNaibiBinding(),
    ),
    GetPage(
      name: _Paths.SERIES_OF_PICTURES,
      page: () => const SeriesOfPicturesView(),
      binding: SeriesOfPicturesBinding(),
      opaque: false,
      transition: Transition.fade,
    ),
    GetPage(
      name: _Paths.PERSONAL_DATA,
      page: () => const PersonalDataView(),
      binding: PersonalDataBinding(),
    ),
    GetPage(
      name: _Paths.MEMBER_CENTER,
      page: () => const MemberCenterView(),
      binding: MemberCenterBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_STUDENTS,
      page: () => const ManageStudentsView(),
      binding: ManageStudentsBinding(),
    ),
    GetPage(
      name: _Paths.MY_COUPONS,
      page: () => const MyCouponsView(),
      binding: MyCouponsBinding(),
    ),
    GetPage(
      name: _Paths.LIMIT_DISCOUN_DETAIL,
      page: () => const LimitDiscounDetailView(),
      binding: LimitDiscounDetailBinding(),
    ),
    GetPage(
      name: _Paths.LEARNING_POINT_DETAILS,
      page: () => const LearningPointDetailsView(),
      binding: LearningPointDetailsBinding(),
    ),
    GetPage(
      name: _Paths.OPEN_MEMBER_SETTLEMENT,
      page: () => const OpenMemberSettlementView(),
      binding: OpenMemberSettlementBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_USER_PROFILE,
      page: () => const EditUserProfileView(),
      binding: EditUserProfileBinding(),
    ),
    GetPage(
      name: _Paths.ABOUT_US,
      page: () => const AboutUsView(),
      binding: AboutUsBinding(),
    ),
    GetPage(
      name: _Paths.WEB_PAGE,
      page: () => const WebPageView(),
      binding: WebPageBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOMIZED_COURSES,
      page: () => const CustomizedCoursesView(),
      binding: CustomizedCoursesBinding(),
      children: [
        GetPage(
          name: _Paths.UPLOAD_BOOK_INFO,
          page: () => const UploadBookInfoView(),
          binding: UploadBookInfoBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.CUSTOM_COURSE_GENERATION_DETAIL,
      page: () => const CustomCourseGenerationDetailView(),
      binding: CustomCourseGenerationDetailBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOM_COURSE_MANAGE_PHOTOS,
      page: () => const CustomCourseManagePhotosView(),
      binding: CustomCourseManagePhotosBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOM_COURSE_SHOOT_WORDS,
      page: () => const CustomCourseShootWordsView(),
      binding: CustomCourseShootWordsBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOM_COURSE_CHECK_KNOWLEDGE,
      page: () => const CustomCourseCheckKnowledgeView(),
      binding: CustomCourseCheckKnowledgeBinding(),
    ),

    // 自定义课程
    GetPage(
      name: _Paths.CUSTOM_COURSE,
      page: () => const CustomCourseView(),
      binding: CustomCourseBinding(),
    ),
    // 自定义课程添加年级
    GetPage(
      name: _Paths.CUSTOM_COURSE_ADD_GRADE,
      page: () => const CustomCourseAddGradeView(),
      binding: CustomCourseAddGradeBinding(),
    ),
    // 自定义课程管理年级
    GetPage(
      name: _Paths.CUSTOM_COURSE_MANAGE_GRADE,
      page: () => const CustomCourseManageGradeView(),
      binding: CustomCourseManageGradeBinding(),
    ),
    // 自定义课程管理年级排序
    GetPage(
      name: _Paths.CUSTOM_COURSE_MANAGE_GRADE_SORT,
      page: () => const CustomCourseManageGradeSortView(),
      binding: CustomCourseManageGradeSortBinding(),
    ),

    GetPage(
      name: _Paths.MISSION_CONTROL_CENTER,
      page: () => const MissionControlCenterView(),
      binding: MissionControlCenterBinding(),
      children: [
        GetPage(
          name: _Paths.MISSION_COMPLETE,
          page: () => const MissionCompleteView(),
          binding: MissionCompleteBinding(),
        ),
        GetPage(
          name: _Paths.MISSION_TEST_RESULT,
          page: () => const MissionTestResultView(),
          binding: MissionTestResultBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.MISSION_SPECIAL,
      page: () => const MissionSpecialView(),
      binding: MissionSpecialBinding(),
    ),
    GetPage(
      name: _Paths.LISTEN_AND_READ,
      page: () => const ListenAndReadView(),
      binding: ListenAndReadBinding(),
    ),
    GetPage(
      name: _Paths.PHONICS_COURSE,
      page: () => const PhonicsCourseView(),
      binding: PhonicsCourseBinding(),
    ),
    GetPage(
      name: _Paths.SPECIALTY,
      page: () => const SpecialtyView(),
      binding: SpecialtyBinding(),
    ),
    GetPage(
      name: _Paths.APP_SUBSCRIBE_LISTENING,
      page: () => SubListenPage(),
      binding: SubListenBinding(),
    ),
    GetPage(
      name: _Paths.APP_SUBSCRIBE_LISTENING_DETAILS,
      page: () => const SubListenDetailsPage(),
      binding: SubListenDetailsBinding(),
    ),
    GetPage(
      name: _Paths.SONG_MV,
      page: () => const SongMvView(),
      binding: SongMvBinding(),
    ),
    GetPage(
      name: _Paths.VIDEO_TASK_PLAYER,
      page: () => const VideoTaskPlayerView(),
      binding: VideoTaskPlayerBinding(),
    ),
    GetPage(
      name: _Paths.MUSIC,
      page: () => MusicView(),
      binding: MusicBinding(),
    ),
    GetPage(
      name: _Paths.FAVOURITE,
      page: () => const FavouriteView(),
      binding: FavouriteBinding(),
    ),
    GetPage(
      name: _Paths.MANAGEMENT,
      page: () => const ManagementView(),
      binding: ManagementBinding(),
      children: [
        ...manageRoutes,
      ],
    ),
  ];

  // 以下路由已改用 Get.to() + tag 方式跳转，不再使用命名路由
  // 详见 [GETX_MULTI_INSTANCE_GUIDE.md]
  static final manageRoutes = [
    
  ];
}
