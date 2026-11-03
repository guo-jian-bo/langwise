import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../manage_content/manage_generate_audio/views/manage_generate_audio_view.dart';
import '../manage_content/manage_knowledge_create_history/views/manage_knowledge_create_history_view.dart';
import '../manage_content/manage_word/views/manage_word_view.dart';
import '../manage_content/manage_word_audio/views/manage_word_audio_view.dart';
import '../manage_content/views/manage_content_view.dart';
import '../manage_study/manage_book_scan/view.dart';
import '../manage_study/manage_book_scan/manage_book_word_list/view.dart';
import '../manage_study/manage_book_scan/manage_book_word_list/manage_book_word_list_check_knowledge/views/manage_book_word_list_check_knowledge_view.dart';
import '../manage_users/views/manage_users_view.dart';
import '../manage_users/manage_new_crowd/views/manage_new_crowd_view.dart';
import '../manage_users/manage_task/views/manage_task_view.dart';
import '../manage_users/manage_prize/views/manage_prize_view.dart';
import '../manage_users/manage_new_crowd/manage_new_crowd_detail/views/manage_new_crowd_detail_view.dart';
import '../manage_users/manage_new_crowd/manage_new_crowd_editor/views/manage_new_crowd_editor_view.dart';
import '../manage_review/manage_check_image/approved_images_confirm/views/approved_images_confirm_view.dart';
import '../manage_review/manage_check_image/audit_history/views/manage_check_image_audit_history_view.dart';
import '../manage_review/manage_check_image/audit_statistics/views/manage_check_image_audit_statistics_view.dart';
import '../manage_review/manage_check_image/views/manage_check_image_view.dart';
import '../manage_review/manage_review_exercises/manage_review_exercises_history/views/manage_review_exercises_history_view.dart';
import '../manage_review/manage_review_exercises/manage_review_exercises_statistics/views/manage_review_exercises_statistics_view.dart';
import '../manage_review/manage_review_exercises/views/manage_review_exercises_view.dart';
import '../manage_review/views/manage_review_view.dart';
import '../manage_study/manage_config_exercises/views/manage_config_exercises_view.dart';
import '../manage_study/views/manage_study_view.dart';
import '../manage_content/manage_phrase/views/manage_phrase_view.dart';
import '../manage_content/manage_core_knowledge/views/manage_core_knowledge_view.dart';
import '../manage_shared_pages/manage_all_courses_detils/views/manage_all_courses_detils_view.dart';
import '../manage_shared_pages/manage_module_detils/views/manage_module_detils_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/views/manage_select_quzi_knowledge_view.dart';
import '../manage_shared_pages/manage_quiz_list/views/manage_quiz_list_view.dart';
import '../manage_shared_pages/manage_module_detils/manage_module_detils_generate_article/views/manage_module_detils_generate_article_view.dart';
import '../manage_shared_pages/manage_module_detils/manage_general_song/views/manage_general_song_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_general/views/manage_quiz_general_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_single_choice/views/manage_quiz_single_choice_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_cloze_test/views/manage_quiz_cloze_test_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_context_choice/views/manage_quiz_context_choice_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_word_completion/views/manage_quiz_word_completion_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_listen_find_word/views/manage_quiz_listen_find_word_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_contrast_cloze/views/manage_quiz_contrast_cloze_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_image_text_matching/views/manage_quiz_image_text_matching_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_immersive_chain/views/manage_quiz_immersive_chain_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_classify_challenge/views/manage_quiz_classify_challenge_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_cloze_test_b/views/manage_quiz_cloze_test_b_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_context_choice_b/views/manage_quiz_context_choice_b_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_label_picture/views/manage_quiz_label_picture_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_label_picture/manage_quiz_label_picture_images/views/manage_quiz_label_picture_images_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_label_picture/manage_quiz_label_picture_prview/views/manage_quiz_label_picture_prview_view.dart';
import '../manage_shared_pages/manage_select_quzi_knowledge/manage_quiz_label_picture/manage_quiz_label_picture_setting/views/manage_quiz_label_picture_setting_view.dart';
import '../manage_study/manage_course_list/views/manage_course_list_view.dart';
import '../manage_shared_pages/manage_create_exercises/views/manage_create_exercises_view.dart';
import '../manage_shared_pages/manage_select_exercises/views/manage_select_exercises_view.dart';
import '../manage_shared_pages/manage_exercise_course_affiliation/views/manage_exercise_course_affiliation_view.dart';
import '../manage_shared_pages/manage_create_quiz/views/manage_create_quiz_view.dart';
import '../manage_shared_pages/manage_edit_quiz/manage_edit_quiz_word_completion/views/manage_edit_quiz_word_completion_view.dart';
import '../manage_shared_pages/manage_edit_quiz/manage_edit_quiz_listen_find_word/views/manage_edit_quiz_listen_find_word_view.dart';
import '../manage_shared_pages/manage_create_quiz/manage_create_quiz_word_completion/views/manage_create_quiz_word_completion_view.dart';
import '../manage_shared_pages/manage_create_quiz/manage_create_quiz_listen_find_word/views/manage_create_quiz_listen_find_word_view.dart';
import '../manage_shared_pages/manage_create_quiz/manage_create_quiz_classify_challenge/views/manage_create_quiz_classify_challenge_view.dart';
import '../manage_shared_pages/manage_create_quiz/manage_create_quiz_contrast_cloze/views/manage_create_quiz_contrast_cloze_view.dart';
import '../manage_shared_pages/manage_create_quiz/manage_create_quiz_sentence_cloze/views/manage_create_quiz_sentence_cloze_view.dart';
import '../manage_shared_pages/manage_create_quiz/manage_create_quiz_ai_quiz/views/manage_create_quiz_ai_quiz_view.dart';
import '../manage_shared_pages/manage_edit_quiz/manage_edit_quiz_classify_challenge/views/manage_edit_quiz_classify_challenge_view.dart';
import '../manage_shared_pages/manage_edit_quiz/manage_edit_quiz_contrast_cloze/views/manage_edit_quiz_contrast_cloze_view.dart';
import '../manage_shared_pages/manage_edit_quiz/manage_edit_quiz_sentence_cloze/views/manage_edit_quiz_sentence_cloze_view.dart';
import '../manage_shared_pages/manage_edit_quiz/manage_edit_quiz_cloze_test_a/views/manage_edit_quiz_cloze_test_a_view.dart';
import '../manage_shared_pages/manage_edit_quiz/manage_edit_quiz_cloze_test_b/views/manage_edit_quiz_cloze_test_b_view.dart';
import '../manage_shared_pages/manage_edit_quiz/manage_edit_quiz_scenario_selection_a/views/manage_edit_quiz_scenario_selection_a_view.dart';
import '../manage_shared_pages/manage_edit_quiz/manage_edit_quiz_scenario_selection_b/views/manage_edit_quiz_scenario_selection_b_view.dart';
import '../manage_shared_pages/manage_edit_quiz/manage_edit_quiz_cross_word/views/manage_edit_quiz_cross_word_view.dart';
import '../manage_shared_pages/manage_edit_quiz/manage_edit_quiz_label_picture/views/manage_edit_quiz_label_picture_view.dart';
import '../manage_shared_pages/manage_knowledge_related_details/views/manage_knowledge_related_details_view.dart';
import '../manage_shared_pages/manage_english_course_usage/views/manage_english_course_usage_view.dart';
import '../manage_content/manage_article/views/manage_article_view.dart';
import '../manage_content/manage_sentence/views/manage_sentence_view.dart';
import '../manage_content/manage_song/views/manage_song_view.dart';
import '../manage_content/manage_audio_subtitle_editor/views/manage_audio_subtitle_editor_view.dart';
import '../manage_content/manage_subscribe/views/manage_subscribe_view.dart';
import '../manage_content/manage_subscribe/views/subscribe_create_view.dart';
import '../manage_content/manage_subscribe/views/subscribe_listening_listcard_view.dart';
import '../manage_study/manage_level/views/manage_level_view.dart';
import '../manage_study/manage_module/views/manage_module_view.dart';
import '../manage_study/manage_unit/views/manage_unit_view.dart';
import '../manage_study/manage_lesson/views/manage_lesson_view.dart';
import '../manage_study/manage_lesson_template/views/manage_lesson_template_view.dart';
import '../manage_study/manage_lesson_template/manage_lesson_template_manage/views/manage_lesson_template_manage_view.dart';
import '../manage_study/manage_exercise/views/manage_exercise_view.dart';
import '../manage_study/manage_super_memory_exercises/views/manage_super_memory_exercises_view.dart';
import '../manage_study/manage_quiz_template/views/manage_quiz_template_view.dart';
import '../manage_study/manage_phonics_course/views/manage_phonics_course_view.dart';
import '../manage_review/manage_review_video/views/manage_review_video_view.dart';
import '../manage_review/manage_review_video/manage_review_video_detils/views/manage_review_video_detils_view.dart';
import '../manage_review/manage_review_video/manage_review_video_history/views/manage_review_video_history_view.dart';
import '../manage_review/manage_review_video/manage_review_video_statistics/views/manage_review_video_statistics_view.dart';
import '../manage_review/manage_review_video/manage_review_video_confirmation/views/manage_review_video_confirmation_view.dart';
import '../manage_review/manage_review_ass/views/manage_review_video_ass_view.dart';
import '../manage_review/manage_review_ass/manage_review_ass_detils/views/manage_review_ass_detils_view.dart';
import '../manage_review/manage_review_ass/manage_review_ass_history/views/manage_review_ass_history_view.dart';
import '../manage_review/manage_review_ass/manage_review_ass_statistics/views/manage_review_ass_statistics_view.dart';
import '../manage_review/manage_review_ass/manage_review_ass_translate/views/manage_review_ass_translate_view.dart';
import '../manage_review/manage_review_audio/views/manage_review_audio_view.dart';
import '../manage_review/manage_review_audio/manage_review_audio_history/views/manage_review_audio_history_view.dart';
import '../manage_review/manage_review_audio/manage_review_audio_statistics/views/manage_review_audio_statistics_view.dart';
import '../manage_content/manage_zhendu_console/views/manage_zhendu_console_view.dart';
import '../manage_content/manage_zhendu_console/manage_vocal_emotions/views/manage_vocal_emotions_view.dart';
import '../manage_content/manage_zhendu_console/manage_vocal_timbre/views/manage_vocal_timbre_view.dart';
import '../manage_content/manage_zhendu_console/manage_persona/views/manage_persona_view.dart';
import '../manage_content/manage_zhendu_console/manage_script_theme/views/manage_script_theme_view.dart';
import '../manage_content/manage_zhendu_console/manage_script_genre/views/manage_script_genre_view.dart';
import '../manage_content/manage_zhendu_console/manage_unit_script/views/manage_unit_script_view.dart';
import '../manage_content/manage_zhendu_console/manage_unit_script/manage_create_unit_script/views/manage_create_unit_script_view.dart';
import '../manage_content/manage_zhendu_console/manage_script_details/views/manage_script_details_view.dart';
import '../manage_content/manage_zhendu_console/manage_vocabulary_script/views/manage_vocabulary_script_view.dart';
import '../manage_content/manage_zhendu_console/manage_vocabulary_script/manage_create_vocabulary_script/views/manage_create_vocabulary_script_view.dart';
import '../manage_content/manage_zhendu_console/manage_audio_project/views/manage_audio_project_view.dart';
import '../manage_content/manage_zhendu_console/manage_audio_project/manage_create_audio_project/views/manage_create_audio_project_view.dart';
import '../manage_content/manage_zhendu_console/manage_audio_project_detils/views/manage_audio_project_detils_view.dart';
import '../manage_content/manage_zhendu_console/manage_visual_project/views/manage_visual_project_view.dart';
import '../manage_content/manage_zhendu_console/manage_visual_project/manage_create_visual_project/views/manage_create_visual_project_view.dart';
import '../manage_content/manage_zhendu_console/manage_visual_project_detils/views/manage_visual_project_detils_view.dart';
import '../manage_content/manage_zhendu_console/manage_visual_project_synthesis_video/views/manage_visual_project_synthesis_video_view.dart';
import '../manage_content/manage_zhendu_console/manage_script_grouping/views/manage_script_grouping_view.dart';
import '../manage_content/manage_zhendu_console/manage_script_allocation_group/views/manage_script_allocation_group_view.dart';
import '../manage_content/manage_zhendu_console/manage_subtitle_mapping/views/manage_subtitle_mapping_view.dart';
import '../manage_content/manage_zhendu_console//manage_zhendu_generate_task/views/manage_zhendu_generate_task_view.dart';
import '../manage_shared_pages/manage_unified_image_create/views/manage_unified_image_create_view.dart';
import '../manage_shared_pages/manage_unified_image_crop/views/manage_unified_image_crop_view.dart';
import '../manage_content/manage_zhendu_console/manage_storyboard_workbench/views/manage_storyboard_workbench_view.dart';
import '../../../routes/routes.dart';

class ManagePageRegistry {
  /// 页面注册表：route -> View.to 方法
  static final Map<String, Future<dynamic> Function({dynamic arguments})> _pages = {
    Routes.MANAGE_CONTENT: ManageContentView.to,
    Routes.MANAGE_WORD: ManageWordView.to,
    Routes.MANAGE_GENERATE_AUDIO: ManageGenerateAudioView.to,
    Routes.MANAGE_WORD_AUDIO: ManageWordAudioView.to,
    Routes.MANAGE_KNOWLEDGE_CREATE_HISTORY: ManageKnowledgeCreateHistoryView.to,
    Routes.MANAGE_REVIEW: ManageReviewView.to,
    Routes.MANAGE_CHECK_IMAGE: ManageCheckImageView.to,
    Routes.MANAGE_CHECK_IMAGE_AUDIT_HISTORY: ManageCheckImageAuditHistoryView.to,
    Routes.MANAGE_CHECK_IMAGE_AUDIT_STATISTICS: ManageCheckImageAuditStatisticsView.to,
    Routes.APPROVED_IMAGES_CONFIRM: ApprovedImagesConfirmView.to,
    Routes.MANAGE_REVIEW_EXERCISES: ManageReviewExercisesView.to,
    Routes.MANAGE_REVIEW_EXERCISES_HISTORY: ManageReviewExercisesHistoryView.to,
    Routes.MANAGE_REVIEW_EXERCISES_STATISTICS: ManageReviewExercisesStatisticsView.to,
    Routes.MANAGE_STUDY: ManageStudyView.to,
    Routes.MANAGE_CONFIG_EXERCISES: ManageConfigExercisesView.to,
    Routes.MANAGE_PHRASE: ManagePhraseView.to,
    Routes.MANAGE_CORE_KNOWLEDGE: ManageCoreKnowledgeView.to,
    Routes.MANAGE_BOOK_SCAN: ManageBookScanPage.to,
    Routes.MANAGE_WORD_LIST: ManageBookWordListPage.to,
    Routes.MANAGE_WORD_LIST_CHECK_KNOWLEDGE: ManageBookWordListCheckKnowledgeView.to,
    Routes.MANAGE_USERS: ManageUsersView.to,
    Routes.MANAGE_NEW_CROWD: ManageNewCrowdView.to,
    Routes.MANAGE_TASK: ManageTaskView.to,
    Routes.MANAGE_PRIZE: ManagePrizeView.to,
    Routes.MANAGE_NEW_CROWD_DETAIL: ManageNewCrowdDetailView.to,
    Routes.MANAGE_NEW_CROWD_EDITOR: ManageNewCrowdEditorView.to,
    // 公共页面 (manage_shared_pages)
    Routes.MANAGE_ALL_COURSES_DETILS: ManageAllCoursesDetilsView.to,
    Routes.MANAGE_MODULE_DETILS: ManageModuleDetilsView.to,
    Routes.MANAGE_SELECT_QUZI_KNOWLEDGE: ManageSelectQuziKnowledgeView.to,
    Routes.MANAGE_QUIZ_LIST: ManageQuizListView.to,
    Routes.MANAGE_MODULE_DETILS_GENERATE_ARTICLE: ManageModuleDetilsGenerateArticleView.to,
    Routes.MANAGE_GENERAL_SONG_PAGE: ManageGeneralSongView.to,
    // 题型子页面
    Routes.MANAGE_QUIZ_GENERAL: ManageQuizGeneralView.to,
    Routes.MANAGE_QUIZ_SINGLE_CHOICE: ManageQuizSingleChoiceView.to,
    Routes.MANAGE_QUIZ_CLOZE_TEST: ManageQuizClozeTestView.to,
    Routes.MANAGE_QUIZ_CONTEXT_CHOICE: ManageQuizContextChoiceView.to,
    Routes.MANAGE_QUIZ_WORD_COMPLETION: ManageQuizWordCompletionView.to,
    Routes.MANAGE_QUIZ_LISTEN_FIND_WORD: ManageQuizListenFindWordView.to,
    Routes.MANAGE_QUIZ_CONTRAST_CLOZE: ManageQuizContrastClozeView.to,
    Routes.MANAGE_QUIZ_IMAGE_TEXT_MATCHING: ManageQuizImageTextMatchingView.to,
    Routes.MANAGE_QUIZ_IMMERSIVE_CHAIN: ManageQuizImmersiveChainView.to,
    Routes.MANAGE_QUIZ_CLASSIFY_CHALLENGE: ManageQuizClassifyChallengeView.to,
    Routes.MANAGE_QUIZ_CLOZE_TEST_B: ManageQuizClozeTestBView.to,
    Routes.MANAGE_QUIZ_CONTEXT_CHOICE_B: ManageQuizContextChoiceBView.to,
    Routes.MANAGE_QUIZ_LABEL_PICTURE: ManageQuizLabelPictureView.to,
    Routes.MANAGE_QUIZ_LABEL_PICTURE_IMAGES: ManageQuizLabelPictureImagesView.to,
    Routes.MANAGE_QUIZ_LABEL_PICTURE_PRVIEW: ManageQuizLabelPicturePrviewView.to,
    Routes.MANAGE_QUIZ_LABEL_PICTURE_SETTING: ManageQuizLabelPictureSettingView.to,
    Routes.MANAGE_COURSE_LIST: ManageCourseListView.to,
    Routes.MANAGE_CREATE_EXERCISES: ManageCreateExercisesView.to,
    Routes.MANAGE_SELECT_EXERCISES: ManageSelectExercisesView.to,
    Routes.MANAGE_EXERCISE_COURSE_AFFILIATION: ManageExerciseCourseAffiliationView.to,
    Routes.MANAGE_CREATE_QUIZ: ManageCreateQuizView.to,
    Routes.MANAGE_EDIT_QUIZ_WORD_COMPLETION: ManageEditQuizWordCompletionView.to,
    Routes.MANAGE_EDIT_QUIZ_LISTEN_FIND_WORD: ManageEditQuizListenFindWordView.to,
    Routes.MANAGE_CREATE_QUIZ_WORD_COMPLETION: ManageCreateQuizWordCompletionView.to,
    Routes.MANAGE_CREATE_QUIZ_LISTEN_FIND_WORD: ManageCreateQuizListenFindWordView.to,
    Routes.MANAGE_CREATE_QUIZ_CLASSIFY_CHALLENGE: ManageCreateQuizClassifyChallengeView.to,
    Routes.MANAGE_CREATE_QUIZ_CONTRAST_CLOZE: ManageCreateQuizContrastClozeView.to,
    Routes.MANAGE_CREATE_QUIZ_SENTENCE_CLOZE: ManageCreateQuizSentenceClozeView.to,
    Routes.MANAGE_CREATE_QUIZ_AI_QUIZ: ManageCreateQuizAiQuizView.to,
    Routes.MANAGE_EDIT_QUIZ_CLASSIFY_CHALLENGE: ManageEditQuizClassifyChallengeView.to,
    Routes.MANAGE_EDIT_QUIZ_CONTRAST_CLOZE: ManageEditQuizContrastClozeView.to,
    Routes.MANAGE_EDIT_QUIZ_SENTENCE_CLOZE: ManageEditQuizSentenceClozeView.to,
    Routes.MANAGE_EDIT_QUIZ_CLOZE_TEST_A: ManageEditQuizClozeTestAView.to,
    Routes.MANAGE_EDIT_QUIZ_CLOZE_TEST_B: ManageEditQuizClozeTestBView.to,
    Routes.MANAGE_EDIT_QUIZ_SCENARIO_SELECTION_A: ManageEditQuizScenarioSelectionAView.to,
    Routes.MANAGE_EDIT_QUIZ_SCENARIO_SELECTION_B: ManageEditQuizScenarioSelectionBView.to,
    Routes.MANAGE_EDIT_QUIZ_CROSS_WORD: ManageEditQuizCrossWordView.to,
    Routes.MANAGE_EDIT_QUIZ_LABEL_PICTURE: ManageEditQuizLabelPictureView.to,
    Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS: ManageKnowledgeRelatedDetailsView.to,
    Routes.MANAGE_ENGLISH_COURSE_USAGE: ManageEnglishCourseUsageView.to,
    Routes.MANAGE_ARTICLE: ManageArticleView.to,
    Routes.MANAGE_SENTENCE: ManageSentenceView.to,
    Routes.MANAGE_SONG: ManageSongView.to,
    Routes.MANAGE_AUDIO_SUBTITLE_EDITOR: ManageAudioSubtitleEditorView.to,
    Routes.MANAGE_SUBSCRIBE: ManageSubscribeView.to,
    Routes.MANAGE_SUBSCRIBE_CREATE: SubscribeCreateView.to,
    Routes.MANAGE_SUBSCRIBE_LISTCARD: SubscribeListeningListcardView.to,
    Routes.MANAGE_LEVEL: ManageLevelView.to,
    Routes.MANAGE_MODULE: ManageModuleView.to,
    Routes.MANAGE_UNIT: ManageUnitView.to,
    Routes.MANAGE_LESSON: ManageLessonView.to,
    Routes.MANAGE_LESSON_TEMPLATE: ManageLessonTemplateView.to,
    Routes.MANAGE_LESSON_TEMPLATE_MANAGE: ManageLessonTemplateManageView.to,
    Routes.MANAGE_EXERCISE_LIST: ManageExerciseView.to,
    Routes.MANAGE_SUPER_MEMORY_EXERCISES: ManageSuperMemoryExercisesView.to,
    Routes.MANAGE_QUIZ_TEMPLATE: ManageQuizTemplateView.to,
    Routes.MANAGE_PHONICS_COURSE: ManagePhonicsCourseView.to,
    Routes.MANAGE_REVIEW_VIDEO: ManageReviewVideoView.to,
    Routes.MANAGE_REVIEW_VIDEO_DETILS: ManageReviewVideoDetilsView.to,
    Routes.MANAGE_REVIEW_VIDEO_HISTORY: ManageReviewVideoHistoryView.to,
    Routes.MANAGE_REVIEW_VIDEO_STATISTICS: ManageReviewVideoStatisticsView.to,
    Routes.MANAGE_REVIEW_VIDEO_CONFIRMATION: ManageReviewVideoConfirmationView.to,
    Routes.MANAGE_REVIEW_ASS: ManageReviewAssView.to,
    Routes.MANAGE_REVIEW_ASS_DETILS: ManageReviewAssDetilsView.to,
    Routes.MANAGE_REVIEW_ASS_HISTORY: ManageReviewAssHistoryView.to,
    Routes.MANAGE_REVIEW_ASS_STATISTICS: ManageReviewAssStatisticsView.to,
    Routes.MANAGE_REVIEW_ASS_TRANSLATE: ManageReviewAssTranslateView.to,
    Routes.MANAGE_REVIEW_AUDIO: ManageReviewAudioView.to,
    Routes.MANAGE_REVIEW_AUDIO_HISTORY: ManageReviewAudioHistoryView.to,
    Routes.MANAGE_REVIEW_AUDIO_STATISTICS: ManageReviewAudioStatisticsView.to,
    Routes.MANAGE_ZHENDU_CONSOLE: ManageZhenduConsoleView.to,
    Routes.MANAGE_VOCAL_EMOTIONS: ManageVocalEmotionsView.to,
    Routes.MANAGE_VOCAL_TIMBRE: ManageVocalTimbreView.to,
    Routes.MANAGE_PERSONA: ManagePersonaView.to,
    Routes.MANAGE_SCRIPT_THEME: ManageScriptThemeView.to,
    Routes.MANAGE_SCRIPT_GENRE: ManageScriptGenreView.to,
    Routes.MANAGE_UNIT_SCRIPT: ManageUnitScriptView.to,
    Routes.MANAGE_CREATE_UNIT_SCRIPT: ManageCreateUnitScriptView.to,
    Routes.MANAGE_SCRIPT_DETAILS: ManageScriptDetailsView.to,
    Routes.MANAGE_VOCABULARY_SCRIPT: ManageVocabularyScriptView.to,
    Routes.MANAGE_CREATE_VOCABULARY_SCRIPT: ManageCreateVocabularyScriptView.to,
    Routes.MANAGE_AUDIO_PROJECT: ManageAudioProjectView.to,
    Routes.MANAGE_CREATE_AUDIO_PROJECT: ManageCreateAudioProjectView.to,
    Routes.MANAGE_AUDIO_PROJECT_DETILS: ManageAudioProjectDetilsView.to,
    Routes.MANAGE_VISUAL_PROJECT: ManageVisualProjectView.to,
    Routes.MANAGE_CREATE_VISUAL_PROJECT: ManageCreateVisualProjectView.to,
    Routes.MANAGE_VISUAL_PROJECT_DETILS: ManageVisualProjectDetilsView.to,
    Routes.MANAGE_VISUAL_PROJECT_SYNTHESIS_VIDEO: ManageVisualProjectSynthesisVideoView.to,
    Routes.MANAGE_SCRIPT_GROUPING: ManageScriptGroupingView.to,
    Routes.MANAGE_SCRIPT_ALLOCATION_GROUP: ManageScriptAllocationGroupView.to,
    Routes.MANAGE_SUBTITLE_MAPPING: ManageSubtitleMappingView.to,
    Routes.MANAGE_ZHENDU_GENERATE_TASK: ManageZhenduGenerateTaskView.to,
    Routes.MANAGE_UNIFIED_IMAGE_CREATE: ManageUnifiedImageCreateView.to,
    Routes.MANAGE_UNIFIED_IMAGE_CROP: ManageUnifiedImageCropView.to,
    Routes.MANAGE_STORYBOARD_WORKBENCH: ManageStoryboardWorkbenchView.to,
  };

  /// 根据路由跳转
  static Future<T?> jumpTo<T>(String route, {dynamic arguments}) async {
    final toMethod = _pages[route];
    if (toMethod != null) {
      final result = await toMethod(arguments: arguments);
      return result as T?;
    }
    if (kDebugMode) {
      print('⚠️ [ManagePageRegistry] 未注册的路由: $route');
    }
    return null;
  }

  /// 检查路由是否已注册
  static bool isRegistered(String route) => _pages.containsKey(route);

  /// 替换当前页面并跳转到新页面
  /// 相当于先 Get.back() 再 jumpTo()
  static Future<T?> offAndToNamed<T>(String route, {dynamic arguments}) async {
    // 先返回上一页
    Get.back();
    // 再跳转到新页面
    return await jumpTo<T>(route, arguments: arguments);
  }

  /// 返回到指定路由，然后跳转到新页面
  /// predicate: 返回 true 时停止返回
  static Future<T?> offNamedUntil<T>(
    String route, {
    required bool Function(String routeName) predicate,
    dynamic arguments,
  }) async {
    // 使用 Get.until 返回到指定页面
    // 由于新管理端使用独立路由栈，这里简化为返回后跳转
    Get.until((r) => predicate(r.settings.name ?? ''));
    // 再跳转到新页面
    return await jumpTo<T>(route, arguments: arguments);
  }
}
