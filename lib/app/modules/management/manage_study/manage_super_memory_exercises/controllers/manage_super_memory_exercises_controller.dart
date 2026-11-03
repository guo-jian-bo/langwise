import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../models/manage_open_model.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';

class ManageSuperMemoryExercisesController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageSuperMemoryExercisesController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SUPER_MEMORY_EXERCISES;

  @override
  String get breadcrumbTitle => '超记题目';

  final RxMap<String, FilterSortsData> filterSorts = {
    "cnt": FilterSortsData(
      title: "排序",
      sorts: [
        FilterSortsItem(name: "搜索次数最多", direction: FilterSortDirection.down, selected: true, isDefault: true),
      ],
    ),
  }.obs;

  final RxMap<String, FilterConditionsData> filterConditions = {
    "is_resolved": FilterConditionsData(
      title: "上下架状态",
      conditions: [
        FilterConditionsItem(
          name: WhetherToProcessEnum.processed.label,
          value: WhetherToProcessEnum.processed.value,
        ),
        FilterConditionsItem(
          name: WhetherToProcessEnum.unprocessed.label,
          value: WhetherToProcessEnum.unprocessed.value,
        ),
      ],
    ),
  }.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "uid": FilterSearchsData(
      title: "contentId",
      controller: TextEditingController(),
      hintText: "contentId",
    ),
  };

  final RxInt totalCount = 0.obs;
  int offset = 0;
  int limit = 20;
  final PagerController pagerController = PagerController();
  final RxList<ManageExpandModel<SuperMemoryExercisesEntity>> exercisesList =
      <ManageExpandModel<SuperMemoryExercisesEntity>>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    getSuperMemoryExercises();
  }

  void pagerCallback(int page, int pageSize) {
    offset = (page - 1) * pageSize;
    limit = pageSize;
    getSuperMemoryExercises();
  }

  Future<void> getSuperMemoryExercises({bool loading = true}) async {
    try {
      if (loading) ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "offset": offset,
        "limit": limit,
      };
      Map<String, dynamic> sortOrder = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
      parameters.addAll(sortOrder);

      Map<String, dynamic> reqData = {};
      Map<String, dynamic> conditionParameter = FilterStripUtils.getConditionParameter(conditions: filterConditions);
      if (conditionParameter["is_resolved"] != null) {
        WhetherToProcessEnum accessEnum = WhetherToProcessEnum.fromRawValue(conditionParameter["is_resolved"]);
        reqData['is_resolved'] = accessEnum.value;
      }
      Map<String, dynamic> searchParameter = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      reqData.addAll(searchParameter);

      ListResponseEntity<SuperMemoryExercisesEntity>? response =
          await StudyConsoleRequest.getSuperMemoryExercises(parameters, reqData);
      if (response == null) return;
      if (isClosed) return;

      totalCount.value = response.count ?? 0;
      List<SuperMemoryExercisesEntity> datas = response.datas ?? [];

      List<String> openIds = [];
      for (int i = 0; i < exercisesList.length; i++) {
        if (!exercisesList[i].isExpanded) continue;
        if (exercisesList[i].data.id == null) continue;
        openIds.add(exercisesList[i].data.id!);
      }

      exercisesList.clear();

      for (int i = 0; i < datas.length; i++) {
        if (datas[i].id == null) continue;
        exercisesList.add(ManageExpandModel<SuperMemoryExercisesEntity>(
          data: datas[i],
          isExpanded: openIds.contains(datas[i].id),
        ));
      }
    } finally {
      if (loading) ToastUtils.hideLoading();
    }
  }

  void onToggleExpand(ManageExpandModel<SuperMemoryExercisesEntity> entity) {
    entity.isExpanded = !entity.isExpanded;
    exercisesList.refresh();
  }

  Future<void> chanageResolved(BuildContext context, ManageExpandModel<SuperMemoryExercisesEntity> entity) async {
    if (!(entity.data.isResolved ?? false)) {
      List<QuizModel?> candidateExercises = entity.data.candidateExercises ?? [];
      if (candidateExercises.isEmpty) {
        ToastUtils.showToast(text: "请先添加题目");
        return;
      }
      bool accessNormal = candidateExercises.any((e) => e?.accessNormal ?? false);
      if (!accessNormal) {
        ToastUtils.showToast(text: "没有上架的题目");
        return;
      }
    }

    final askRes = await AskDialog.showUserAsk(
      context: context,
      title: "超记${(entity.data.isResolved ?? false) ? '下架' : '上架'}",
      content: "您确定要${(entity.data.isResolved ?? false) ? '下架' : '上架'}吗？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    Map<String, dynamic> reqData = {
      "is_resolved": !(entity.data.isResolved ?? false),
      "id": entity.data.id,
    };
    SuperMemoryExercisesEntity? response = await editSuperMemory(reqData);
    if (response == null) return;
    entity.data = response;
    exercisesList.refresh();
    ToastUtils.showToast(
        text: (entity.data.isResolved ?? false) ? "下架成功" : "上架成功", type: ToastType.success);
  }

  Future<void> deleteExercise(
      BuildContext context, ManageExpandModel<SuperMemoryExercisesEntity> entity, QuizModel delData) async {
    bool ask = await DeleteDialog.show(
      context: context,
      title: "移除题目",
      subTitle: "确定要将此题目从记忆题目列表中移除吗？",
      content: "此题目只会从这条记忆数据中移除，不会影响题目本身",
      confirmText: "确认移除",
    );

    if (!ask) return;

    List<int> editExerciseIdscandidate = [];

    List<int?> exerciseIdsCandidate = entity.data.exerciseIdsCandidate ?? [];
    for (int i = 0; i < exerciseIdsCandidate.length; i++) {
      if (exerciseIdsCandidate[i] == null) continue;
      if (exerciseIdsCandidate[i] == delData.uid) continue;
      editExerciseIdscandidate.add(exerciseIdsCandidate[i]!);
    }

    Map<String, dynamic> reqData = {
      "exercise_ids_candidate": editExerciseIdscandidate,
      "id": entity.data.id,
    };
    SuperMemoryExercisesEntity? response = await editSuperMemory(reqData);
    if (response == null) return;
    entity.data = response;
    exercisesList.refresh();
    ToastUtils.showToast(text: "删除成功", type: ToastType.success);
  }

  Future<void> switchExercise(
      BuildContext context, ManageExpandModel<SuperMemoryExercisesEntity> entity, QuizModel switchData) async {
    final askRes = await AskDialog.showUserAsk(
      context: context,
      title: "题目${switchData.accessNormal ? '下架' : '上架'}",
      content: "您确定要${switchData.accessNormal ? '下架' : '上架'}此题目吗？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "exerciseIds": [switchData.uid],
      };

      String operation = switchData.accessNormal ? 'batch_exercise_shelf_off' : 'batch_exercise_shelf_on';

      ResponseEntity? res = await ManageExerciseRequest.deleteQuiz(operation, data: reqData);
      if (res == null) return;
      ToastUtils.showToast(text: switchData.accessNormal ? '下架成功' : '上架成功', type: ToastType.success);

      getSuperMemoryExercises();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> addExercise(BuildContext context, ManageExpandModel<SuperMemoryExercisesEntity> entity) async {
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_CREATE_EXERCISES,
      arguments: {
        "contentType": entity.data.type,
        "contentId": entity.data.uid,
        "semanticId": entity.data.semanticId,
        "pageType": "superMemory",
      },
    );
    getSuperMemoryExercises();
  }

  Future<void> syncSuperMemory(ManageExpandModel<SuperMemoryExercisesEntity> entity) async {
    if (entity.data.id == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "id": entity.data.id,
      };
      bool response = await StudyConsoleRequest.syncSuperMemory(reqData);
      if (!response) return;
      ToastUtils.showToast(text: "同步成功", type: ToastType.success);
      getSuperMemoryExercises();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<SuperMemoryExercisesEntity?> editSuperMemory(Map<String, dynamic> data) async {
    try {
      ToastUtils.showLoading();
      SuperMemoryExercisesEntity? response = await StudyConsoleRequest.editSuperMemory(data);
      return response;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> editExercise(
      BuildContext context, ManageExpandModel<SuperMemoryExercisesEntity> entity, QuizModel switchData) async {
    String? manageRoute = QuizRoutesUtils.getEditQuizRouteNameByContentType(switchData.type);
    if (manageRoute == null || manageRoute == "") {
      ToastUtils.showManageToast(text: "不支持编辑此类型题目");
      return;
    }
    await ManagePageRegistry.jumpTo(
      manageRoute,
      arguments: {
        "quizId": switchData.uid,
      },
    );
    getSuperMemoryExercises();
  }

  Future<void> previewExercise(
      BuildContext context, ManageExpandModel<SuperMemoryExercisesEntity> entity, QuizModel switchData) async {
    dynamic res = await Get.toNamed(
      Routes.PRACTICE_QUESTIONS,
      preventDuplicates: false,
      arguments: {
        "quizDatas": [switchData],
        "isAdminPage": true,
      },
    );

    if (res == null) return;
    Map<String, dynamic> resMap = res as Map<String, dynamic>;
    if (resMap["isEdit"] != true) return;
    String? manageRoute = resMap["manageRoute"];
    if (manageRoute == null || manageRoute.isEmpty) return;
    int? uid = resMap["quizId"];
    if (uid == null) return;
    await ManagePageRegistry.jumpTo(
      manageRoute,
      arguments: {
        "quizId": uid,
      },
    );
    getSuperMemoryExercises();

  }
}
