import 'package:api/entities/response.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/en_phrase_entity.dart';
import 'package:langwise/common/entities/en_sentence_entity.dart';
import 'package:langwise/common/entities/en_text_entity.dart';
import 'package:langwise/common/entities/en_word_entity.dart';
import 'package:langwise/common/entities/list.dart';
import 'package:langwise/common/https/home.dart';
import 'package:langwise/common/https/manage_select_quzi_knowledge.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/data_table_widget/data_sources.dart';
import 'package:langwise/utils/quiz_routes_utils.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/models/quiz_model.dart';

import '../../../../../../common/https/manage_exercise_request.dart';
import '../../../../../../common/entities/manage_exercise_filter_model.dart';
import '../../../../../routes/routes.dart';
import '../../../../../routes/tag_routes.dart';
import '../../../common/manage_select_knowledge_table/view.dart';
import '../../../models/manage_exercise_quiz_model.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';
import '../views/quiz_json_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../controllers/manage_setting_controller.dart';
import '../../../../../../common/enum/enum.dart';

class ManageExerciseController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageExerciseController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_EXERCISE_LIST;

  @override
  String get breadcrumbTitle => '题目管理';

  AsyncDataTableSource? dataSourceAsync;

  List<String> uids = [];

  List<String> difficultyList = [];

  List<ManageExerciseFilterQuizTypeData> typeList = [];

  RxInt selectAccessIndex = (-1).obs;
  RxInt selectDifficultyIndex = (-1).obs;
  RxInt selectTypeIndex = (-1).obs;

  Map<String, dynamic>? content;
  Map<String, dynamic> serviceJson = {};
  Map<String, dynamic> clientJson = {};

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if (Get.arguments != null && Get.arguments is Map) {
      int? contentId = Get.arguments['contentId'];
      String? contentType = Get.arguments['contentType'];
      int? semanticId = Get.arguments['semanticId'];
      if (contentId != null && contentType != null) {
        content = {
          "uid": contentId,
          "type": contentType,
          "semanticId": semanticId,
        };
      }
    }
    getFilter();
  }

  void onSetDataSourceAsync(AsyncDataTableSource source) {
    dataSourceAsync = source;
  }

  void onRefresh() {
    dataSourceAsync?.refreshDatasource();
  }

  void onSetId(String value, {bool isSubmit = false}) {
    uids = value.split(',').where((e) => e.trim().isNotEmpty).toList();
    if (isSubmit) {
      onRefresh();
    }
  }

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
        data: resData,
      );
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
    final String? style = ManageSettingController.to.defaultStyle.value.style;
    List<QuizModel>? resQuizList = await ManageSelectQuziKnowledge.getQuizListByIds(
      [item.uid],
      mediaMode: mediaMode,
      styleCodes: (style != null && style.isNotEmpty) ? [style] : null,
    );
    var clientList = await HomeRequest.getQuizListByIds([item.uid]);

    if (resQuizList != null && resQuizList.isNotEmpty) {
      serviceJson = resQuizList.first.toJson();
    }

    if (clientList != null && clientList.isNotEmpty) {
      clientJson = clientList.first.toJson();
    }

    QuizJsonDialog.show(
      item: item,
      context: Get.context!,
      clientJson: clientJson,
      serviceJson: serviceJson,
      onShowQuiz: dialogShowQuiz,
    );
  }

  Future<void> dialogShowQuiz() async {
    if (serviceJson.isEmpty) return;
    await TagRoutes.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "quizDatas": [QuizModel.fromJson(serviceJson)],
        "isShowUpDownStatus": true,
      },
    );
  }

  void showQuiz(ManageExerciseQuizModel item) async {
    QuizModel quizModel;
    try {
      ToastUtils.showLoading();
      final int mediaMode = ManageSettingController.to.defaultResources.value == ResourceTypeEnum.image ? 0 : 1;
      final String? style = ManageSettingController.to.defaultStyle.value.style;
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

  void editQuiz(ManageExerciseQuizModel item) async {
    String? type = item.type;
    int? uid = item.uid;
    if (type == null || type == "") return;
    String? manageRoute = QuizRoutesUtils.getEditQuizRouteNameByContentType(type);
    if (manageRoute == null || manageRoute == "") {
      ToastUtils.showManageToast(text: "不支持编辑此类型题目");
      return;
    }
    ManagePageRegistry.jumpTo(
      manageRoute,
      arguments: {
        "quizId": uid,
      },
    );
  }

  void courseAffiliation(context, ManageExerciseQuizModel item) async {
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_EXERCISE_COURSE_AFFILIATION,
      arguments: {
        "quizModel": item,
      },
    );
    onRefresh();
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
        },
      );
      if (res == null) {
        return;
      }
      ToastUtils.showManageToast(text: item.access == 'NORMAL' ? '下架成功' : '上架成功');
      onRefresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void deleteQuiz(context, ManageExerciseQuizModel item) async {
    final askRes = await AskDialog.showUserAsk(
      context: context,
      content: "您确定要删除此题目吗？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) {
      return;
    }

    try {
      ToastUtils.showLoading();

      final ResponseEntity? res = await ManageExerciseRequest.deleteQuiz(
        'batch_exercise_shelf_delete',
        data: {
          "exerciseIds": [item.uid],
        },
      );
      if (res == null) {
        return;
      }
      ToastUtils.showManageToast(text: '删除成功');
      onRefresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }
}
