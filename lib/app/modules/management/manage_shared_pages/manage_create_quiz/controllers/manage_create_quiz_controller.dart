import 'package:api/api.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/manage_lesson_quiz_template_entity.dart';
import 'package:langwise/common/entities/manage_unit_knowledge_entity.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/models/quiz_model.dart';
import 'package:quiz_play/utils/exercise_subtype.dart';

import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../../../routes/tag_routes.dart';
import '../../../common/manage_create_quiz_request.dart';
import '../../../dialog/manage_create_quiz_text_setting_dialog.dart';
import '../../../models/manage_create_quiz_model.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';

class ManageCreateQuizController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCreateQuizController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_CREATE_QUIZ;

  @override
  String get breadcrumbTitle => '创建题目';

  // 上个页面传进来的知识点
  List<ManageUnitKnowledgeEntity>? unitKnowledgeList;
  // 上个页面传进来的题目模版
  ManageLessonQuizTemplateEntity? lessonQuizTemplate;
  int? lessonId;
  int? unitId;
  String? language;
  String? contentType;

  /// 请求到的重复题目List
  final RxList<QuizModel> quizList = <QuizModel>[].obs;

  /// 题目是否选中的List
  final RxList<bool> selectList = <bool>[].obs;
  RxInt selectedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      Map argumentsMap = Get.arguments;
      Map<String, dynamic>? argumentsLessonQuizTemplate = argumentsMap["lessonQuizTemplate"];
      if (argumentsLessonQuizTemplate != null) {
        lessonQuizTemplate = ManageLessonQuizTemplateEntity.fromJson(argumentsLessonQuizTemplate);
      }
      List<Map<String, dynamic>>? argumentsKnowledgeList = argumentsMap["knowledgeList"];
      if (argumentsKnowledgeList != null) {
        unitKnowledgeList = argumentsKnowledgeList.map((e) => ManageUnitKnowledgeEntity.fromJson(e)).toList();
      }

      lessonId = argumentsMap["lessonId"];
      unitId = argumentsMap["unitId"];
      language = argumentsMap["language"];
      contentType = argumentsMap["contentType"];
    }

    getQuizExistList();
  }

  /// 获取题目数据
  Future<void> getQuizExistList() async {
    List<Map<String, dynamic>> contentList = [];
    for (ManageUnitKnowledgeEntity model in unitKnowledgeList!) {
      contentList.add({
        "uid": model.contentId,
        "type": model.contentType,
        "semanticId": model.semanticId,
      });
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "contentList": contentList,
        "configId": lessonQuizTemplate?.config?.uid,
      };
      List<QuizModel>? resQuizList = await ManageCreateQuizRequest.checkQuizExist(reqData);
      if (resQuizList == null || resQuizList.isEmpty) return;
      quizList.value = resQuizList;

      /// 初始化选中List
      selectList.value = List.generate(quizList.length, (index) => false);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 上架/下架题目
  void accessQuiz(context, QuizModel item) async {
    final askRes = await AskDialog.showUserAsk(
      context: context,
      content: "您确定要${item.accessNormal ? '下架' : '上架'}此题目吗？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) {
      return;
    }

    try {
      ToastUtils.showLoading();

      final ResponseEntity? res = await ManageExerciseRequest.deleteQuiz(
          item.accessNormal ? 'batch_exercise_shelf_off' : 'batch_exercise_shelf_on',
          data: {
            "exerciseIds": [item.uid],
          });
      if (res == null) {
        return;
      }
      ToastUtils.showManageToast(text: item.accessNormal ? '下架成功' : '上架成功');
      // 刷新
      getQuizExistList();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 绑定题目
  void bindQuiz() async {
    if (selectedCount.value == 0) return;

    List<String> selectedQuizIDList = [];
    for (int i = 0; i < selectList.length; i++) {
      if (selectList[i]) {
        QuizModel model = quizList[i];
        selectedQuizIDList.add(model.uid.toString());
      }
    }

    Map<String, dynamic> reqData = {
      "exerciseIds": selectedQuizIDList,
      "lessonId": lessonId,
    };
    bool isSuccess = await ManageCreateQuizRequest.bindQuiz(reqData);
    if (isSuccess) {
      ToastUtils.showManageToast(text: "绑定成功");
      Get.back();
    }
  }

  /// 新建题目
  void createQuiz(context) async {
    try {
      ToastUtils.showLoading();
      String quizType = lessonQuizTemplate?.exerciseType ?? "";
      if (quizType.isEmpty) return;
      if (unitKnowledgeList == null || unitKnowledgeList!.isEmpty) return;

      List<Map<String, dynamic>> contentList = [];
      for (ManageUnitKnowledgeEntity model in unitKnowledgeList!) {
        contentList.add({
          "uid": model.contentId,
          "type": model.contentType,
          "semanticId": model.semanticId,
        });
      }

      bool isDirectly = await createQuizDirectly(quizType);
      if (isDirectly) {
        Map<String, dynamic> reqData = {
          "type": quizType,
          "configId": lessonQuizTemplate?.config?.uid,
          "contentList": contentList,
          "lessonId": lessonId,
          "unitId": unitId,
        };
        bool isSuccess = await ManageCreateQuizRequest.createQuiz(reqData);
        if (isSuccess) {
          ToastUtils.showManageToast(text: "创建成功");
          Get.back(result: {'refresh': true});
        }
        return;
      }

      ///下面是需跳转新建界面的题目创建
      Map<String, dynamic> arguments = {
        "lessonQuizTemplate": lessonQuizTemplate,
        "knowledgeList": unitKnowledgeList,
        "unitId": unitId,
        "language": language,
        "lessonId": lessonId,
      };
      // 单词补全
      if (quizType == ExerciseType.WORD_COMPLETION) {
        ManagePageRegistry.jumpTo(
          Routes.MANAGE_CREATE_QUIZ_WORD_COMPLETION,
          arguments: arguments,
        );
        return;
      }

      // 听音找词
      if (quizType == ExerciseType.LISTEN_FIND_WORD) {
        ManagePageRegistry.jumpTo(
          Routes.MANAGE_CREATE_QUIZ_LISTEN_FIND_WORD,
          arguments: arguments,
        );
        return;
      }

      //单项选择
      if (quizType == ExerciseType.SINGLE_CHOICE) {}

      // 标注图片
      if (quizType == ExerciseType.LABEL_PICTURE) {
        Map<String, dynamic> reqData = {
          "type": quizType,
          "configId": lessonQuizTemplate?.config?.uid,
          "contentList": contentList,
          "lessonId": lessonId,
          "unitId": unitId,
        };
        bool isSuccess = await ManageCreateQuizRequest.createQuiz(reqData);
        if (isSuccess) {
          ToastUtils.showManageToast(text: "正在生成中");
          Get.back(result: {'refresh': true, 'refreshAiQueue': true});
        }
        return;
      }

      // 纵横字谜
      if (quizType == ExerciseType.CROSS_WORD) {
        Map<String, dynamic> reqData = {
          "type": quizType,
          "configId": lessonQuizTemplate?.config?.uid,
          "contentList": contentList,
          "lessonId": lessonId,
          "unitId": unitId,
        };
        bool isSuccess = await ManageCreateQuizRequest.createQuiz(reqData);
        if (isSuccess) {
          ToastUtils.showManageToast(text: "创建成功");
          Get.back(result: {'refresh': true});
        }
        return;
      }

      // 分类挑战
      if (quizType == ExerciseType.CLASSIFY_CHALLENGE) {
        ManagePageRegistry.jumpTo(
          Routes.MANAGE_CREATE_QUIZ_CLASSIFY_CHALLENGE,
          arguments: arguments,
        );
        return;
      }

      // 对比填空
      if (quizType == ExerciseType.CONTRAST_CLOZE) {
        ManagePageRegistry.jumpTo(
          Routes.MANAGE_CREATE_QUIZ_CONTRAST_CLOZE,
          arguments: arguments,
        );
        return;
      }

      // 句子填空
      if (quizType == ExerciseType.SENTENCE_CLOZE) {
        ManagePageRegistry.jumpTo(
          Routes.MANAGE_CREATE_QUIZ_SENTENCE_CLOZE,
          arguments: arguments,
        );
        return;
      }

      // 情境选择ab和完形填空ab
      if (quizType == ExerciseType.CONTEXT_CHOICE ||
          quizType == ExerciseType.CONTEXT_CHOICE_B ||
          quizType == ExerciseType.CLOZE_TEST ||
          quizType == ExerciseType.CLOZE_TEST_B) {
        bool hasEnText = unitKnowledgeList?.any((element) => element.isEnText) ?? false;
        Map<String, dynamic>? extraInstruction;
        if (!hasEnText) {
          ManageCreateQuizModel? configModel = await ManageCreateQuizRequest.getCreateQuizConfig({});

          if (contentType == null) {
            Map<String, dynamic>? result = await ManageCreateQuizTextSettingDialog.show(
              context: Get.context!,
              configModel: configModel,
            );
            if (result == null) return;
            extraInstruction = result;
          } else {
            // 甄听 剧本 不需要选择体裁等信息
            if (ElementsCardType.fromRawValue(contentType!) != ElementsCardType.reveal && ElementsCardType.fromRawValue(contentType!) != ElementsCardType.script) {
              Map<String, dynamic>? result = await ManageCreateQuizTextSettingDialog.show(
                context: Get.context!,
                configModel: configModel,
              );
              if (result == null) return;
              extraInstruction = result;
            }
          }
        }

        Map<String, dynamic> reqData = {
          "type": quizType,
          "configId": lessonQuizTemplate?.config?.uid,
          "contentList": contentList,
          "extraInstruction": extraInstruction,
          "lessonId": lessonId,
          "unitId": unitId,
        };
        bool isSuccess = await ManageCreateQuizRequest.createQuiz(reqData);
        if (isSuccess) {
          ToastUtils.showManageToast(text: "正在生成中");
          Get.back(result: {'refresh': true, 'refreshAiQueue': true});
        }
        return;
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 判断是否是直接调用新建接口的题目
  Future<bool> createQuizDirectly(String quizType) async {
    //链式沉浸学习、单词拼装、单词拼写
    if (quizType == ExerciseType.IMMERSIVE_CHAIN ||
        quizType == ExerciseType.WORD_BUILDER ||
        quizType == ExerciseType.WORD_SPELLING) {
      return true;
    }

    //宫格连线、拼读积木、拼读拆解
    if (quizType == ExerciseType.GRID_CONNECTION ||
        quizType == ExerciseType.SOUND_BLOCKS ||
        quizType == ExerciseType.PRONUNCIATION_BREAKDOWN) {
      return true;
    }

    //是非判断、对对碰、单词搜索
    if (quizType == ExerciseType.IMAGE_TEXT_MATCHING ||
        quizType == ExerciseType.PAIR_MATCHING ||
        quizType == ExerciseType.WORD_SEARCH) {
      return true;
    }

    //单词书写、发音评测
    if (quizType == ExerciseType.LETTER_TRACING || quizType == ExerciseType.PRONUNCIATION_ASSESSMENT) {
      return true;
    }

    return false;
  }

  /// 跳转到做题演示页面
  Future<void> toDemonstrate(int index) async {
    if (quizList.isEmpty) return;
    if (quizList.length <= index) return;
    await TagRoutes.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "currentQuizId": quizList[index].uid,
        "quizDatas": [quizList[index]],
        "isShowUpDownStatus": true,
      },
    );
  }
}
