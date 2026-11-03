import 'package:api/entities/response.dart';
import 'package:get/get.dart';
import '../../../dialog/quiz_json_dialog.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/en_phrase_entity.dart';
import 'package:langwise/common/entities/en_sentence_entity.dart';
import 'package:langwise/common/entities/en_text_entity.dart';
import 'package:langwise/common/entities/en_word_entity.dart';
import 'package:langwise/common/entities/list.dart';
import 'package:langwise/common/https/home.dart';
import 'package:langwise/common/https/manage_select_quzi_knowledge.dart';
import 'package:langwise/common/mixins/filter_mixin.dart';
import 'package:langwise/common/stores/base_controller.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/data_table_widget/data_sources.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/models/quiz_model.dart';

import '../../../../../../common/https/manage_exercise_request.dart';
import '../../../../../../common/entities/manage_exercise_filter_model.dart';
import '../../../common/manage_select_knowledge_table/view.dart';
import '../../../models/manage_exercise_quiz_model.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';
import '../../../../../routes/routes.dart';
import '../../../../../routes/tag_routes.dart';
import '../../../controllers/manage_setting_controller.dart';
import 'package:langwise/common/enum/enum.dart';

class ManageSelectExercisesController extends BaseController with FilterMixin, ManageBreadcrumbMixin {
  final String tag;
  ManageSelectExercisesController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SELECT_EXERCISES;

  @override
  String get breadcrumbTitle => '选择练习';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    getFilter();
  }

  List<String> difficultyList = [];

  List<ManageExerciseFilterQuizTypeData> typeList = [];

  RxInt selectAccessIndex = (-1).obs;
  RxInt selectDifficultyIndex = (-1).obs;
  RxInt selectTypeIndex = (-1).obs;

  Map<String, dynamic>? content;
  final RxList<int> selectedExerciseIds = <int>[].obs;

  Future<void> getFilter() async {
    try {
      ToastUtils.showLoading();
      ManageExerciseFilterModel? res = await ManageExerciseRequest.getExerciseFilter();
      if (res == null) {
        return;
      }
      typeList = res.exerciseTypeList ?? [];
      difficultyList = res.cefrLevels ?? [];
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<DesertsFakeWebServiceResponse<ManageExerciseQuizModel>> onFetchPages(
      int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    try {
      String? access;
      if (selectAccessIndex.value != -1) {
        if (selectAccessIndex.value == 0) {
          access = "NORMAL";
        } else if (selectAccessIndex.value == 1) {
          access = "INTERNAL";
        }
      }

      int? difficulty;
      if (selectDifficultyIndex.value != -1) {
        difficulty = selectDifficultyIndex.value;
      }

      String? type;
      if (selectTypeIndex.value != -1) {
        type = typeList[selectTypeIndex.value].type;
      }

      Map<String, dynamic> resData;
      if (access == null) {
        resData = {
          "content": content,
          "uid": uids.isEmpty ? null : uids,
          "difficulty": difficulty,
          "type": type,
        };
      } else {
        resData = {
          "content": content,
          "uid": uids.isEmpty ? null : uids,
          "access": [access],
          "difficulty": difficulty,
          "type": type,
        };
      }

      final ListResponseEntity<ManageExerciseQuizModel>? res = await ManageExerciseRequest.getQuizList(
          parameters: {
            'offset': startingAt,
            'limit': count,
          },
          data: resData);
      if (res == null) {
        return DesertsFakeWebServiceResponse<ManageExerciseQuizModel>(0, []);
      }

      return DesertsFakeWebServiceResponse<ManageExerciseQuizModel>(res.count!, (res.datas ?? []));
    } catch (e) {
      return DesertsFakeWebServiceResponse<ManageExerciseQuizModel>(0, []);
    }
  }

  void chooseContent(context) async {
    var value = await ManageSelectKnowledgeTableManager.show(
      context: context,
      defaultDessert: [],
      language: 'en',
      showSelectKnowledgeAddButton: true,
      singleSelectionMode: true,
    );

    if (value != null && value.isNotEmpty) {
      for (int i = 0; i < value.length; i++) {
        final entity = value[i];
        if (entity is EnWordEntity) {
          content = {
            "uid": entity.uid,
            "type": entity.contentType,
            "semanticId": entity.selectedSemantics?.uid,
          };
        } else if (entity is EnPhraseEntity) {
          content = {
            "uid": entity.uid,
            "type": entity.contentType,
            "semanticId": entity.selectedSemantics?.uid,
          };
        } else if (entity is EnSentenceEntity) {
          content = {
            "uid": entity.uid,
            "type": entity.contentType,
            "semanticId": entity.selectedSemantics?.uid,
          };
        } else if (entity is EnTextEntity) {
          content = {
            "uid": entity.uid,
            "type": entity.contentType,
          };
        }
      }
      onRefresh();
      update();
    }
  }

  Future<void> showQuizJson(ManageExerciseQuizModel item) async {
    final int mediaMode = ManageSettingController.to.defaultResources.value == ResourceTypeEnum.image ? 0 : 1;
    final String? style = ManageSettingController.to.getCurrentStyleCode();
    List<QuizModel>? resQuizList = await ManageSelectQuziKnowledge.getQuizListByIds(
      [item.uid],
      mediaMode: mediaMode,
      styleCodes: (style != null && style.isNotEmpty) ? [style] : null,
    );
    var clientList = await HomeRequest.getQuizListByIds([item.uid]);

    QuizJsonDialog.show(
      item: item,
      context: Get.context!,
      clientJson: (clientList?.isEmpty ?? true) ? {} : (clientList?.first.toJson() ?? {}),
      serviceJson: (resQuizList?.isEmpty ?? true) ? {} : resQuizList?.first.toJson() ?? {},
      onShowQuiz: () => dialogShowQuiz(resQuizList),
    );
  }

  Future<void> dialogShowQuiz(List<QuizModel>? resQuizList) async {
    if (resQuizList == null || resQuizList.isEmpty) return;
    await TagRoutes.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "quizDatas": [resQuizList.first],
        "isShowUpDownStatus": true,
      },
    );
  }

  void showQuiz(ManageExerciseQuizModel item) async {
    QuizModel quizModel;
    try {
      ToastUtils.showLoading();
      final int mediaMode = ManageSettingController.to.defaultResources.value == ResourceTypeEnum.image ? 0 : 1;
      final String? style = ManageSettingController.to.getCurrentStyleCode();
      List<QuizModel>? resQuizList = await ManageSelectQuziKnowledge.getQuizListByIds(
        [item.uid],
        mediaMode: mediaMode,
        styleCodes: (style != null && style.isNotEmpty) ? [style] : null,
      );
      if (resQuizList == null || resQuizList.isEmpty) return;
      quizModel = resQuizList.first;
      await TagRoutes.toNamed(
        Routes.PRACTICE_QUESTIONS,
        arguments: {
          "quizDatas": [quizModel],
          "isShowUpDownStatus": true,
        },
      );
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void courseAffiliation(context, ManageExerciseQuizModel item) async {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_EXERCISE_COURSE_AFFILIATION,
      arguments: {
        "quizModel": item,
      },
    ).then((_) {
      onRefresh();
    });
  }

  void accessQuiz(context, ManageExerciseQuizModel item) async {
    final askRes = await AskDialog.showUserAsk(
      context: context,
      content: "您确定要${item.access == 'NORMAL' ? '下架' : '上架'}此题目吗？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) {
      return;
    }

    try {
      ToastUtils.showLoading();

      final ResponseEntity? res = await ManageExerciseRequest.deleteQuiz(
          item.access == 'NORMAL' ? 'batch_exercise_shelf_off' : 'batch_exercise_shelf_on',
          data: {
            "exerciseIds": [item.uid],
          });
      if (res == null) {
        return;
      }
      ToastUtils.showManageToast(text: item.access == 'NORMAL' ? '下架成功' : '上架成功');
      onRefresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void onRowSelectChanged(bool selected, int id, ManageExerciseQuizModel value) {
    if (selected) {
      selectedExerciseIds.add(id);
    } else {
      selectedExerciseIds.remove(id);
    }
  }

  void onConfirmSelect() {
    if (selectedExerciseIds.isEmpty) {
      ToastUtils.showToast(text: '请选择题目');
      return;
    }

    Get.back(result: selectedExerciseIds.toList());
  }
}
