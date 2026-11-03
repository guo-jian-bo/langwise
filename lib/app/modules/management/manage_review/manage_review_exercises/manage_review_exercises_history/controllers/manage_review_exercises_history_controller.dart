import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/utils/utils.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/date_time_picker_widget.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';

class ManageReviewExercisesHistoryController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageReviewExercisesHistoryController({required this.tag});

  /// 是否是管理员进入
  bool fromAdmin = false;
  
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  /// 重新审核的题目的任务id
  final RxInt reReviewTaskIndex = (-1).obs;

  /// 审核员列表
  final RxList<ContentReviewReviewerEntity> auditorList = RxList<ContentReviewReviewerEntity>();

  final RxList<ExerciseReviewEntityList> exerciseReviewList = RxList<ExerciseReviewEntityList>();
  final RxInt totalCount = 0.obs;
  int offset = 0;
  int limit = 20;
  final PagerController pagerController = PagerController();

  /// 筛选的用户id
  final RxInt selectedUserId = (-1).obs;

  /// 筛选的列表
  List<IconDropdownIconData<int>> filterScoreList = [
    IconDropdownIconData(value: 0, title: "全部质量"),
    IconDropdownIconData(value: -1, title: "已被删除"),
    IconDropdownIconData(value: 1, title: "题目错误(无法完成)"),
    IconDropdownIconData(value: 2, title: "题目错误(可以完成)"),
    IconDropdownIconData(value: 4, title: "图片/音频有瑕疵"),
    IconDropdownIconData(value: 5, title: "一切完美"),
  ];

  /// 筛选的分数
  final RxInt selectedScore = 0.obs;

  /// 题目类型的筛选
  final RxList<IconDropdownIconData<String>> exerciseFilerList = <IconDropdownIconData<String>>[].obs;
  /// 选择的题目类型
  final RxString selectedExerciseType = "".obs;


  @override
  String get breadcrumbRoute => Routes.MANAGE_REVIEW_EXERCISES_HISTORY;
  
  @override
  String get breadcrumbTitle => '审核历史';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    DateTime now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, now.day, 0, 0, 0).subtract(const Duration(days: 6));
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if(Get.arguments != null){
      fromAdmin = Get.arguments['fromAdmin']??false;
    }

    getAuditorList();

    getReviewHistoryList();

    getExerciseTypeList();
  }

  /// 获取审核员列表
  Future<void> getAuditorList() async{
    if(!fromAdmin) return;
    List<ContentReviewReviewerEntity>? list = await ExerciseReviewRequest.getAuditorList();
    if(list == null) return;
    auditorList.clear();
    auditorList.add(ContentReviewReviewerEntity(uid: -1, userId: -1, userName: "全部审核员"));
    auditorList.addAll(list);
  }

  /// 获取题目类型筛选
  Future<void> getExerciseTypeList() async {
    if(!ManageAuthUtils.isAuth(ManageAuthCode.exerciseTypeList)) return;
    FilterConditionData? data = await FilterDataUtils.getExerciseTypeList();
    if(data == null) return;
    List<FilterConditionItem> conditions = data.conditions;
    
    exerciseFilerList.clear();
    exerciseFilerList.add(IconDropdownIconData(value: "", title: "全部题目类型"));
    for(var condition in conditions){
      exerciseFilerList.add(IconDropdownIconData(value: condition.value, title: condition.name));
    }
  }



  /// 查询审核历史
  Future<void> getReviewHistoryList() async {
    reReviewTaskIndex.value = -1;
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      Map<String, dynamic> reqData = {};

      if(startDate.value != null && endDate.value != null){
        reqData['startDate'] = DateFormatUtil.formatStr(startDate.value!, newPattern: "yyyy-MM-dd HH:mm:ss");
        reqData['endDate'] = DateFormatUtil.formatStr(endDate.value!, newPattern: "yyyy-MM-dd HH:mm:ss");
      }

      if(selectedScore.value != 0){
        reqData['score'] = selectedScore.value;
      }

      if(selectedExerciseType.isNotEmpty){
        reqData['exerciseType'] = selectedExerciseType.value;
      }


      ListResponseEntity<ExerciseReviewEntityList>? response;

      if(fromAdmin){
        // null = 自己 -1 = 全部
        reqData['userId'] = selectedUserId.value;
        response = await CourseConsoleRequest.getExerciseReviewHistoryList(params, reqData);
      }else{
        response = await ExerciseReviewRequest.getExerciseReviewHistoryList(params, reqData);
      }

      if(response == null) return;
      totalCount.value = response.count??0;
      List<ExerciseReviewEntityList>? list = response.datas??[];
      exerciseReviewList.value = list;

    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 分页器回调
  void pagerCallback(int page, int pageSize) {
    offset = (page - 1) * pageSize;
    limit = pageSize;
    getReviewHistoryList();
  }




  /// 筛选时间
  Future<void> filterTime(BuildContext context) async {
    DateTimePickerUtils.showStartEndCalender(
      context: context,
      minDate: DateTime(2024, 11, 18),
      maxDate: DateTime.now(),
      initialStartDate: startDate.value,
      initialEndDate: endDate.value,
      onTap: (startDate, endDate) {
        var _startDate = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
        var _endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        this.startDate.value = _startDate;
        this.endDate.value = _endDate;
        pagerController.jumpToPage(1);
      },
    );
  }

  /// 筛选审核员
  void filterAuditor(int? userId){
    if(userId == null) return;
    selectedUserId.value = userId;
    pagerController.jumpToPage(1);
  }

  /// 清空筛选时间
  void clearFilterTime() {
    startDate.value = null;
    endDate.value = null;
    pagerController.jumpToPage(1);
  }

  /// 筛选分数
  void filterScore(IconDropdownIconData data){
    selectedScore.value = data.value??-1;
    pagerController.jumpToPage(1);
  }

  /// 筛选题目类型
  void filterExerciseType(IconDropdownIconData data){
    selectedExerciseType.value = data.value??"";
    pagerController.jumpToPage(1);
  }


  /// 重新审核
  void reReview(int index){
    reReviewTaskIndex.value = index;
  }



  /// 删除题目
  Future<void> deleteExercis(BuildContext context, ExerciseReviewEntityList entity) async{
    if(exerciseReviewList.isEmpty) return;

    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "删除题目",
      content: "确定删除该题目吗？",
      contentColor: AppTheme.cSurfaceError.color,
      defineColor: AppTheme.cSurfaceError.color,
    );
    if(!ask) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "taskId": entity.taskId,
      };
      bool res = await ExerciseReviewRequest.deleteTask(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      getReviewHistoryList();
    } finally{
      ToastUtils.hideLoading();
    }

  }

  /// 重新生成
  Future<void> reGenerate(BuildContext context, ExerciseReviewEntityList entity) async{
    if(exerciseReviewList.isEmpty) return;

    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "重新生成",
      content: "确定重新生成吗？",
    );
    if(!ask) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "taskId": entity.taskId,
      };
      bool res = await ExerciseReviewRequest.reGenerate(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "提交成功", type: ToastType.success);
      getReviewHistoryList();
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 题目有错误
  Future<void> exercisesErr(BuildContext context, ExerciseReviewEntityList entity, int score) async{
    
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "taskId": entity.taskId,
        "score": score,
      };
      bool res = await ExerciseReviewRequest.exerciseErr(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "提交成功", type: ToastType.success);
      getReviewHistoryList();
      
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 审核通过
  Future<void> approved(BuildContext context, ExerciseReviewEntityList entity, int score) async{
    if(exerciseReviewList.isEmpty) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "taskId": entity.taskId,
        "score": score,
      };
      bool res = await ExerciseReviewRequest.approved(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "提交成功", type: ToastType.success);
      getReviewHistoryList();
    } finally{
      ToastUtils.hideLoading();
    }

  }

  /// 编辑题目
  Future<void> editExercises(ExerciseReviewEntityList entity) async{
    String? manageRoute = QuizRoutesUtils.getEditQuizRouteNameByContentType(entity.type);
    if (manageRoute == null || manageRoute == "") {
      ToastUtils.showManageToast(text: "不支持编辑此类型题目");
      return;
    }
    await ManagePageRegistry.jumpTo(
      manageRoute,
      arguments: {
        "quizId": entity.exerciseId,
      },
    );
    getReviewHistoryList();
  }


  /// 演示题目
  Future<void> demoExercise(BuildContext context, ExerciseReviewEntityList entity) async{
    if(entity.taskId == null) return;
    dynamic res = await Get.toNamed(
      Routes.PRACTICE_QUESTIONS_REVIEW,
      arguments: {
        "taskIds": [entity.taskId],
        "isAdminPage": true,
        "isReviewHistory": true,
      },
    );
    if(res == null) return;
    getReviewHistoryList();

  }

  /// 查看统计
  Future<void> toStatistics() async{
    dynamic result = await ManagePageRegistry.jumpTo(Routes.MANAGE_REVIEW_EXERCISES_STATISTICS);
    if(result == null) return;
    selectedUserId.value = result;
    pagerController.jumpToPage(1);
  }




  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
