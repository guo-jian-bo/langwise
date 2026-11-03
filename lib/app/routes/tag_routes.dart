import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/study_plan/super_memo_calender/views/super_memo_calender_view.dart';
import 'breadcrumb_controller.dart';
import 'routes_breadcrumb_utils.dart';
import '../modules/elements/elements_phrase_detils/views/elements_phrase_detils_view.dart';
import '../modules/elements/elements_lexical_detail/views/elements_lexical_detail_view.dart';
import '../modules/elements/elements_phrase_relations/views/elements_phrase_relations_view.dart';
import '../modules/elements/elements_phrase_sentence_cards/views/elements_phrase_sentence_cards_view.dart';
import '../modules/elements/elements_sentence_detils/views/elements_sentence_detils_view.dart';
import '../modules/elements/elements_sentence_detils/views/elements_sentence_analysis_view.dart';
import '../modules/elements/elements_word_analysis_cards/views/elements_word_analysis_cards_view.dart';
import '../modules/elements/elements_word_detils/views/elements_word_detils_view.dart';
import '../modules/elements/memory_card_list/views/memory_card_list_view.dart';
import '../modules/elements/memory_recorder_chart/views/memory_recorder_chart_view.dart';
import '../modules/elements/morpheme/views/morpheme_page.dart';
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
import '../modules/practice_questions/views/practice_questions_view.dart';
import '../modules/practice_questions/practice_questions_eval/views/practice_questions_eval_view.dart';
import '../modules/listen_and_read/views/listen_and_read_view.dart';
import '../modules/video_task_player/views/video_task_player_view.dart';
import '../modules/zhendu_look/views/zhendu_look_view.dart';
import '../modules/zhendu_perform/views/zhendu_perform_view.dart';
import '../modules/zhendu/practice/views/zhendu_practice_view.dart';
import '../modules/zhendu/show_detail/views/zhendu_show_detail_view.dart';
import '../modules/zhendu/theater_list/views/zhendu_theater_list_view.dart';
import '../modules/study_plan/select_learning_module/views/select_learning_module_view.dart';
import '../modules/mission_control_center/views/mission_control_center_view.dart';
import '../modules/mission_control_center/mission_complete/views/mission_complete_view.dart';
import '../modules/mission_control_center/mission_content_select/views/mission_content_select_view.dart';
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
import '../modules/official_course_details/official_course_details_target/views/official_course_details_target_view.dart';
import '../modules/official_course_details/official_course_details_preview/views/official_course_details_preview_view.dart';
import '../modules/official_course_details/official_course_details_dictation/views/official_course_details_dictation_view.dart';
import '../modules/official_course_details/official_course_details_dictation/official_course_details_dictation_check/views/official_course_details_dictation_check_view.dart';
import '../modules/official_course_details/official_course_details_flash_notes/views/official_course_details_flash_notes_view.dart';
import '../modules/official_course_details/views/official_course_details_view.dart';
import '../modules/official_course_details/views/official_course_details_lesson_quiz_list_page.dart';
import '../modules/official_course_details/official_course_details_level/views/official_course_details_level_view.dart';
import '../modules/official_course_details/course_level_select_unit/views/course_level_select_unit_view.dart';
import '../modules/official_course_details/official_course_details_unit_script/views/official_course_details_unit_script_view.dart';
import '../modules/elements/dictionary/views/dictionary_page.dart';
import '../modules/management/views/management_view.dart';
import '../modules/management/manage_content/manage_zhenxie_console/manage_word_morphology/views/manage_word_morphology_view.dart';
import '../modules/management/manage_content/manage_zhenxie_console/manage_word_morphology_details/views/manage_word_morphology_details_view.dart';
import '../modules/management/manage_content/manage_zhenxie_console/manage_word_inflection_details/views/manage_word_inflection_details_view.dart';
import '../modules/management/manage_content/manage_zhenxie_console/manage_word_morphology_tree/views/manage_word_morphology_tree_view.dart';
import '../modules/new_music/views/new_music_view.dart';
import '../modules/specialty/views/specialty_view.dart';
import '../modules/subscribe_and_listening/view.dart';
import '../modules/zhendu/home/views/zhendu_home_view.dart';
import '../modules/study_plan/views/study_plan_view.dart';
import '../modules/study_plan/plan_details/views/plan_details_view.dart';
import '../modules/study_plan/plan_exercise_setting/views/plan_exercise_setting_view.dart';
import '../modules/learning_setting_steps/views/learning_setting_steps_view.dart';
import '../modules/study_plan/plan_valid_assessment/views/plan_valid_assessment_view.dart';
import '../modules/intelligent_search/views/intelligent_search_view.dart';
import '../modules/zhenxie/views/zhenxie_view.dart';
import '../modules/zhenxie/zhenxie_syntax/views/zhenxie_syntax_view.dart';
import '../modules/zhenxie/zhenxie_lexis/views/zhenxie_lexis_view.dart';
import '../modules/zhenxie/zhenxie_phrase_contrast/views/zhenxie_phrase_contrast_view.dart';
import '../modules/zhenxie/zhenxie_phrase_contrast_details/views/zhenxie_phrase_contrast_details_view.dart';
import '../modules/zhenxie/zhenxie_phrase_pair/views/zhenxie_phrase_pair_view.dart';
import '../modules/zhenxie/zhenxie_phrase_pair_details/views/zhenxie_phrase_pair_details_view.dart';
import '../modules/zhenxie/zhenxie_phrase_match/views/zhenxie_phrase_match_view.dart';
import '../modules/zhenxie/zhenxie_phrase_match_details/views/zhenxie_phrase_match_details_view.dart';
import '../modules/zhenxie/zhenxie_phrase_match_extras/views/zhenxie_phrase_match_extras_view.dart';
import '../modules/zhenxie/zhenxie_phrase_structure/views/zhenxie_phrase_structure_view.dart';
import '../modules/zhenxie/zhenxie_phrase_structure_details/views/zhenxie_phrase_structure_details_view.dart';
import '../modules/zhenxie/zhenxie_enter_sentence/views/zhenxie_enter_sentence_view.dart';
import '../modules/zhenxie/zhenxie_enter_sentence_details/views/zhenxie_enter_sentence_details_view.dart';
import '../modules/zhenxie/zhenxie_grammar_panorama/views/zhenxie_grammar_panorama_view.dart';
import '../modules/zhenxie/zhenxie_grammar_panorama_details/views/zhenxie_grammar_panorama_details_view.dart';
import '../modules/zhenxie/zhenxie_pattern_blueprint/views/zhenxie_pattern_blueprint_view.dart';
import '../modules/zhenxie/zhenxie_pattern_blueprint_details/views/zhenxie_pattern_blueprint_details_view.dart';
import '../modules/zhenxie/zhenxie_sentence_pair/views/zhenxie_sentence_pair_view.dart';
import '../modules/zhenxie/zhenxie_sentence_pair_details/views/zhenxie_sentence_pair_details_view.dart';
import '../modules/zhenxie/zhenxie_sentence_pair_fork_details/views/zhenxie_sentence_pair_fork_details_view.dart';
import '../modules/zhenxie/zhenxie_sentence_pattern_compare/views/zhenxie_sentence_pattern_compare_view.dart';
import '../modules/zhenxie/zhenxie_sentence_pattern_compare_details/views/zhenxie_sentence_pattern_compare_details_view.dart';
import '../modules/elements/etymology_memory/views/etymology_memory_view.dart';
import '../modules/zhenxie/zhenxie_etymology_forest/views/zhenxie_etymology_forest_view.dart';
import '../modules/zhenxie/zhenxie_paragraph_blueprint/views/zhenxie_paragraph_blueprint_view.dart';
import '../modules/zhenxie/zhenxie_paragraph_blueprint_details/views/zhenxie_paragraph_blueprint_details_view.dart';
import '../modules/zhenxie/zhenxie_paragraph_example/views/zhenxie_paragraph_example_view.dart';
import '../modules/zhenxie/zhenxie_paragraph_writing_goal/views/zhenxie_paragraph_writing_goal_view.dart';
import '../modules/zhenxie/zhenxie_exam/views/zhenxie_exam_view.dart';
import '../modules/zhenxie/zhenxie_exam_compare/views/zhenxie_exam_compare_view.dart';
import '../modules/zhenxie/zhenxie_exam_tasks/views/zhenxie_exam_tasks_view.dart';
import '../modules/zhenxie/zhenxie_exam_task_detail/views/zhenxie_exam_task_detail_view.dart';
import '../modules/zhenxie/zhenxie_composition_stages/views/zhenxie_composition_stages_view.dart';
import '../modules/zhenxie/zhenxie_composition_stages/views/zhenxie_composition_stage_edit_view.dart';
import '../modules/zhenxie/zhenxie_composition_writing/views/zhenxie_composition_writing_view.dart';
import '../modules/zhenxie/zhenxie_composition_instances/views/zhenxie_composition_instances_view.dart';
import '../modules/zhenxie/zhenxie_article_blueprint/views/zhenxie_article_blueprint_view.dart';
import '../modules/zhenxie/zhenxie_article_blueprint_details/views/zhenxie_article_blueprint_details_view.dart';
import '../modules/zhenxie/zhenxie_task_details/views/zhenxie_task_details_view.dart';
import '../modules/official_course_details/course_unit_target/views/course_unit_target_view.dart';
import '../modules/management/manage_shared_pages/manage_unit_grammar_target_details/views/manage_unit_grammar_target_details_view.dart';
import '../modules/official_course_details/course_unit_grammar_details/views/course_unit_grammar_details_view.dart';
import 'routes.dart';

class TagRoutes {
  /// 页面注册表：route -> View.to 方法
  static final Map<String, Future<dynamic> Function({dynamic arguments, required String tag})> _pages = {
    Routes.APP_SUBSCRIBE_LISTENING: SubListenPage.to,
    Routes.ZHENDU_HOME: ZhenduHomeView.to,
    Routes.MUSIC: NewMusicView.to,
    Routes.DICTIONARY: DictionaryPage.to,
    Routes.DICTIONARY_MORPHEME: MorphemePage.to,
    Routes.SPECIALTY: SpecialtyView.to,
    Routes.EN_WORD_DETAIL: ElementsWordDetilsView.to,
    Routes.EN_PHRASE_DETAIL: ElementsPhraseDetilsView.to,
    Routes.EN_LEXICAL_DETAIL: ElementsLexicalDetailView.to,
    Routes.EN_PHRASE_RELATIONS: ElementsPhraseRelationsView.to,
    Routes.EN_PHRASE_SENTENCE_CARDS: ElementsPhraseSentenceCardsView.to,
    Routes.EN_SENTENCE_DETAIL: ElementsSentenceDetilsView.to,
    Routes.EN_SENTENCE_ANALYSIS: ElementsSentenceAnalysisView.to,
    Routes.EN_WORD_ANALYSIS_CARDS: ElementsWordAnalysisCardsView.to,
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
    Routes.MANAGE_WORD_MORPHOLOGY: ({arguments, required tag}) => ManageWordMorphologyView.to(arguments: arguments, tag: tag),
    Routes.MANAGE_WORD_MORPHOLOGY_DETAILS: ({arguments, required tag}) =>
        ManageWordMorphologyDetailsView.to(arguments: arguments, tag: tag),
    Routes.MANAGE_WORD_INFLECTION_DETAILS: ({arguments, required tag}) =>
        ManageWordInflectionDetailsView.to(arguments: arguments, tag: tag),
    Routes.MANAGE_WORD_MORPHOLOGY_TREE: ({arguments, required tag}) => ManageWordMorphologyTreeView.to(arguments: arguments, tag: tag),
    Routes.USER_EVALUATION_LEVEL: UserEvaluationLevelView.to,
    Routes.ASSESSMENT_HISTORY_TIME_MACHINE: AssessmentHistoryTimeMachineView.to,
    Routes.USER_EVALUATION: UserEvaluationView.to,
    Routes.PHONICS_COURSE: PhonicsCourseView.to,
    Routes.PRACTICE_QUESTIONS: PracticeQuestionsView.to,
    Routes.PRACTICE_QUESTIONS_EVAL: PracticeQuestionsEvalView.to,
    Routes.OFFICIAL_COURSE_DETAILS: OfficialCourseDetailsView.to,
    Routes.OFFICIAL_COURSE_DETAILS_LEVEL: OfficialCourseDetailsLevelView.to,
    Routes.COURSE_LEVEL_SELECT_UNIT: CourseLevelSelectUnitView.to,
    Routes.OFFICIAL_COURSE_DETAILS_TARGET: OfficialCourseDetailsTargetView.to,
    Routes.OFFICIAL_COURSE_DETAILS_PREVIEW: OfficialCourseDetailsPreviewView.to,
    Routes.MISSION_CONTENT_SELECT: MissionContentSelectView.to,
    Routes.OFFICIAL_COURSE_DETAILS_DICTATION: OfficialCourseDetailsDictationView.to,
    Routes.OFFICIAL_COURSE_DETAILS_DICTATION_CHECK: OfficialCourseDetailsDictationCheckView.to,
    Routes.OFFICIAL_COURSE_DETAILS_FLASH_NOTES: OfficialCourseDetailsFlashNotesView.to,
    Routes.OFFICIAL_COURSE_DETAILS_UNIT_SCRIPT_LIST: OfficialCourseDetailsUnitScriptView.to,
    Routes.OFFICIAL_COURSE_DETAILS_LESSON_QUIZ_LIST: OfficialCourseDetailsLessonQuizListView.to,
    Routes.LISTEN_AND_READ: ListenAndReadView.to,
    Routes.VIDEO_TASK_PLAYER: VideoTaskPlayerView.to,
    Routes.ZHENDU_LOOK: ZhenduLookView.to,
    Routes.ZHENDU_PERFORM: ZhenduPerformView.to,
    Routes.ZHENDU_PRACTICE: ZhenduPracticeView.to,
    Routes.ZHENDU_THEATER_LIST: ZhenduTheaterListView.to,
    Routes.ZHENDU_SHOW_DETAIL: ZhenduShowDetailView.to,
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
    Routes.MANAGEMENT: ManagementView.to,
    Routes.STUDY_PLAN: StudyPlanView.to,
    Routes.PLAN_DETAILS: PlanDetailsView.to,
    Routes.PLAN_EXERCISE_SETTING: PlanExerciseSettingView.to,
    Routes.LEARNING_SETTING_STEPS: LearningSettingStepsView.to,
    Routes.PLAN_VALID_ASSESSMENT: PlanValidAssessmentView.to,
    Routes.INTELLIGENT_SEARCH: IntelligentSearchView.to,
    Routes.ZHENXIE: ZhenxieView.to,
    Routes.ZHENXIE_LEXIS: ZhenxieLexisView.to,
    Routes.ZHENXIE_SYNTAX: ZhenxieSyntaxView.to,
    Routes.ZHENXIE_PHRASE_CONTRAST: ZhenxiePhraseContrastView.to,
    Routes.ZHENXIE_PHRASE_CONTRAST_DETAILS: ZhenxiePhraseContrastDetailsView.to,
    Routes.ZHENXIE_PHRASE_PAIR: ZhenxiePhrasePairView.to,
    Routes.ZHENXIE_PHRASE_PAIR_DETAILS: ZhenxiePhrasePairDetailsView.to,
    Routes.ZHENXIE_PHRASE_MATCH: ZhenxiePhraseMatchView.to,
    Routes.ZHENXIE_PHRASE_MATCH_DETAILS: ZhenxiePhraseMatchDetailsView.to,
    Routes.ZHENXIE_PHRASE_MATCH_EXTRAS: ZhenxiePhraseMatchExtrasView.to,
    Routes.ZHENXIE_PHRASE_STRUCTURE: ZhenxiePhraseStructureView.to,
    Routes.ZHENXIE_PHRASE_STRUCTURE_DETAILS: ZhenxiePhraseStructureDetailsView.to,
    Routes.ZHENXIE_ENTER_SENTENCE: ZhenxieEnterSentenceView.to,
    Routes.ZHENXIE_ENTER_SENTENCE_DETAILS: ZhenxieEnterSentenceDetailsView.to,
    Routes.ZHENXIE_GRAMMAR_PANORAMA: ZhenxieGrammarPanoramaView.to,
    Routes.ZHENXIE_GRAMMAR_PANORAMA_DETAILS: ZhenxieGrammarPanoramaDetailsView.to,
    Routes.ZHENXIE_PATTERN_BLUEPRINT: ZhenxiePatternBlueprintView.to,
    Routes.ZHENXIE_PATTERN_BLUEPRINT_DETAILS: ZhenxiePatternBlueprintDetailsView.to,
    Routes.ZHENXIE_SENTENCE_PAIR: ZhenxieSentencePairView.to,
    Routes.ZHENXIE_SENTENCE_PAIR_DETAILS: ZhenxieSentencePairDetailsView.to,
    Routes.ZHENXIE_SENTENCE_PAIR_FORK_DETAILS: ZhenxieSentencePairForkDetailsView.to,
    Routes.ZHENXIE_SENTENCE_PATTERN_COMPARE: ZhenxieSentencePatternCompareView.to,
    Routes.ZHENXIE_SENTENCE_PATTERN_COMPARE_DETAILS: ZhenxieSentencePatternCompareDetailsView.to,
    Routes.ETYMOLOGY_MEMORY: EtymologyMemoryView.to,
    Routes.ZHENXIE_ETYMOLOGY_FOREST: ZhenxieEtymologyForestView.to,
    Routes.ZHENXIE_PARAGRAPH_BLUEPRINT: ZhenxieParagraphBlueprintView.to,
    Routes.ZHENXIE_PARAGRAPH_BLUEPRINT_DETAILS: ZhenxieParagraphBlueprintDetailsView.to,
    Routes.ZHENXIE_PARAGRAPH_EXAMPLE: ZhenxieParagraphExampleView.to,
    Routes.ZHENXIE_PARAGRAPH_WRITING_GOAL: ZhenxieParagraphWritingGoalView.to,
    Routes.ZHENXIE_EXAM: ZhenxieExamView.to,
    Routes.ZHENXIE_EXAM_COMPARE: ZhenxieExamCompareView.to,
    Routes.ZHENXIE_EXAM_TASKS: ZhenxieExamTaskListView.to,
    Routes.ZHENXIE_EXAM_TASK_DETAIL: ZhenxieExamTaskDetailView.to,
    Routes.ZHENXIE_COMPOSITION_STAGES: ZhenxieCompositionStagesView.to,
    Routes.ZHENXIE_COMPOSITION_STAGE_EDIT: ZhenxieCompositionStageEditView.to,
    Routes.ZHENXIE_COMPOSITION_WRITING: ZhenxieCompositionWritingView.to,
    Routes.ZHENXIE_COMPOSITION_INSTANCES: ZhenxieCompositionInstancesView.to,
    Routes.ZHENXIE_ARTICLE_BLUEPRINT: ZhenxieArticleBlueprintView.to,
    Routes.ZHENXIE_ARTICLE_BLUEPRINT_DETAILS: ZhenxieArticleBlueprintDetailsView.to,
    Routes.ZHENXIE_TASK_DETAILS: ZhenxieTaskDetailsView.to,
    Routes.COURSE_UNIT_TARGET: CourseUnitTargetView.to,
    Routes.MANAGE_UNIT_GRAMMAR_TARGET_DETAILS: ({arguments, required tag}) =>
        ManageUnitGrammarTargetDetailsView.to(arguments: arguments),
    Routes.COURSE_UNIT_GRAMMAR_DETAILS: CourseUnitGrammarDetailsView.to,
  };

  /// 根据路由跳转
  static Future<T?> toNamed<T>(String route, {dynamic arguments, String? tagText}) async {
    final tag = tagText ?? '${route}_${DateTime.now().millisecondsSinceEpoch}';
    final toMethod = _pages[route];

        if (kDebugMode) {
      print("路由参数: arguments:\n $arguments");

    }
    if (toMethod != null) {
      final result = await toMethod(arguments: arguments, tag: tag);
      return result as T?;
    }
    if (kDebugMode) {
      print('⚠️ [ManagePageRegistry] 未注册的路由: $route');
    }
    return null;
  }

  /// 替换当前页面并跳转到新页面
  /// 相当于先 Get.back() 再 jumpTo()
  static Future<T?> offAndToNamed<T>(String route, {dynamic arguments}) async {
    final canPop = Get.key.currentState?.canPop() ?? false;
    if (canPop) {
      Get.back();
    }
    return await toNamed<T>(route, arguments: arguments);
  }

  static Future<T?> offNamed<T>(String route, {dynamic arguments}) async {
    return await offAndToNamed(route, arguments: arguments);
  }

  /// 返回到指定路由，然后跳转到新页面
  /// predicate: 返回 true 时停止返回
  static Future<T?> offNamedUntil<T>(
    String route,
    bool Function(Route<dynamic>) predicate, {
    dynamic arguments,
  }) async {
    Get.until(predicate);
    final currentRoute = getCurrentRoute();
    if (currentRoute?.route == route) {
      return null;
    }
    return await toNamed<T>(route, arguments: arguments);
  }

  /// 获取堆栈中最新的一个控制器
  static S? findLast<S>(String route) {
    final result = finds<S>(route);
    if (result.isEmpty) return null;
    return result.last;
  }

  /// 根据route 和 tag 获取控制器
  static S? find<S>(String route, String tag) {
    final history = getHistory(route, tag);
    if (history == null) return null;
    if (!Get.isRegistered<S>(tag: tag)) return null;
    return Get.find<S>(tag: tag);
  }

  /// 根据route获取当前在堆栈中的控制器
  static List<S> finds<S>(String route) {
    final List<String> tags = _getTagsByRoute(route);
    if (tags.isEmpty) return [];

    List<S> result = [];
    for (final tag in tags) {
      if (!Get.isRegistered<S>(tag: tag)) continue;
      result.add(Get.find<S>(tag: tag));
    }
    return result;
  }

  /// 指定页面是否存在
  static bool isRegistered<S>(String route, {String? tag}) {
    if (tag == null) return findLast(route) != null;
    return find(route, tag) != null;
  }

  /// 根据路由获取历史路由
  static RoutesBreadcrumbItem? getHistory(String route, String tag) {
    return _findBreadcrumb(route, tag);
  }

  /// 获取当前路由
  static RoutesBreadcrumbItem? getCurrentRoute() {
    return _getCurrentBreadcrumb();
  }

  static BreadcrumbController? _breadcrumbControllerOrNull() {
    if (!Get.isRegistered<BreadcrumbController>()) return null;
    return Get.find<BreadcrumbController>();
  }

  static List<String> _getTagsByRoute(String route) {
    final controller = _breadcrumbControllerOrNull();
    final List<String> tags = [];
    if (controller != null) {
      for (final item in controller.breadcrumbs) {
        if (item.route == route && !tags.contains(item.tag)) {
          tags.add(item.tag);
        }
      }
    }
    return tags;
  }

  static RoutesBreadcrumbItem? _findBreadcrumb(String route, String tag) {
    final controller = _breadcrumbControllerOrNull();
    if (controller == null) return null;
    return controller.breadcrumbs.firstWhereOrNull((item) => item.route == route && item.tag == tag);
  }

  static RoutesBreadcrumbItem? _getCurrentBreadcrumb() {
    final controller = _breadcrumbControllerOrNull();
    if (controller == null || controller.breadcrumbs.isEmpty) return null;
    return controller.breadcrumbs.last;
  }
}
