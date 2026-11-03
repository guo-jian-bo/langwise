

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../utils/utils.dart';

class ManageConfigExercisesController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageConfigExercisesController({required this.tag});

  /// 页面type  select=选择题目  single=单选
  String? pageType;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{
    "access": FilterConditionsData(
      title: "上下架状态",
      isSingle: false,
      conditions: [
        FilterConditionsItem(
          name: AccessEnum.NORMAL.label,
          value: AccessEnum.NORMAL.value,
        ),
        FilterConditionsItem(
          name: AccessEnum.INTERNAL.label,
          value: AccessEnum.INTERNAL.value,
        ),
      ],
    ),
  }.obs;

  /// 筛选输入框
  final Map<String, FilterSearchsData> filterSearchs = <String, FilterSearchsData>{
    "uid": FilterSearchsData(
      title: "configId",
      controller: TextEditingController(),
      hintText: "configId",
      isCommaSeparated: true,
    ),
  };
  
  
  final RxInt totalCount = 0.obs;
  int offset = 0;
  int limit = 20;
  final PagerController pagerController = PagerController();
  final RxList<ManageLessonQuizTemplateEntity> exercisesList = <ManageLessonQuizTemplateEntity>[].obs;


  /// 选择的题目configid
  final RxList<int> selectedConfigIds = <int>[].obs;

  @override
  String get breadcrumbRoute => Routes.MANAGE_CONFIG_EXERCISES;
  
  @override
  String get breadcrumbTitle => '题目配置';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    
    if(Get.arguments != null){
      pageType = Get.arguments['pageType'];
    }
    getExerciseTypeList();
    getExercises();
  }


  /// 获取题目类型筛选
  Future<void> getExerciseTypeList() async {
    ManageExerciseFilterModel? entity = await CourseConsoleRequest.getExerciseFilter(); 
    if(entity == null) return;
    List<ManageExerciseFilterQuizTypeData>? list = entity.exerciseTypeList;
    if(list == null) return;

    filterConditions['exerciseType'] = FilterConditionsData(
      title: "题目类型",
      isSingle: false,
      conditions: list.map((e) => FilterConditionsItem(
        name: e.typeName??"",
        value: e.type??"",
      )).toList(),
    );
    
  }

  /// 分页器回调
  void pagerCallback(int page, int pageSize) {
    offset = (page - 1) * pageSize;
    limit = pageSize;
    getExercises();
  }


  /// 获取题目列表
  Future<void> getExercises({bool loading = true}) async {
   try {
    if(loading) ToastUtils.showLoading();
    Map<String, dynamic> parameters = {
      "offset": offset,
      "limit": limit,
      "order": "-created",
    };

    Map<String, dynamic> reqData = {};

    Map<String, dynamic> conditionParameter = FilterStripUtils.getConditionParameter(conditions: filterConditions);
    if(conditionParameter['access'] != null){
      reqData['access'] = conditionParameter['access'];
    }

    if(conditionParameter['exerciseType'] != null){
      reqData['exerciseType'] = conditionParameter['exerciseType'];
    }

    Map<String, dynamic> searchParameter = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
    if(searchParameter['uid'] != null){
      reqData['uid'] = searchParameter['uid'];
    }
    
    

    ListResponseEntity<ManageLessonQuizTemplateEntity>? response = await CourseConsoleRequest.getConfigExercises(parameters, reqData);
    if(response == null) return;
    if(!isClosed){
      totalCount.value = response.count??0;
      exercisesList.value = (response.datas??[]);
    }

   } finally{
    if(loading) ToastUtils.hideLoading();
   }
  }

  /// 演示题目
  Future<void> previewExercise(QuizModel? data) async {
    if(data == null) return;
    Get.toNamed(
      Routes.PRACTICE_QUESTIONS,
      preventDuplicates: false,
      arguments: {
        "quizDatas": [data],
      },
    );
  }

  /// 删除题目配置题目
  Future<void> deleteExerciseConfig(BuildContext context, int? configId) async {
    if(configId == null) return;

    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "您确定要删除此模版配置吗？",
      contentColor: AppTheme.cSurfaceError.color,
      defineColor: AppTheme.cSurfaceError.color,
      define: "确认删除",
    );
    if(!ask) return;
    
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {"uid": configId};
      bool res = await CourseConsoleRequest.deleteConfigExercise(parameters);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功");
      getExercises();
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 添加题目配置
  Future<void> addExerciseConfig(BuildContext context) async {
    ManageQuizTemplateEntity? selectRes = await SelectQuizTemplateDialog.show(
      context: context, 
    ); 
    if(selectRes == null) return;

    QuizConfigDialogResult? showRes = await QuizConfigDialog.show(
      context: context, 
      showDscribe: true,
      data: ManageQuizTemplateEntity(
        exercise: selectRes.exercise,
        template: selectRes.template,
        description: selectRes.description,
        templateDescription: selectRes.template?.description,
      ), 
    );
    if(showRes == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "description": showRes.desc,
        "breakdownLevel": showRes.quizModelConfig.breakdownLevel,
        "exerciseType": selectRes.template?.type,
        "config": showRes.quizModelConfig.toJson(),
        "estimatedTime": selectRes.exercise?.estimatedTime,
      };
      bool res = await CourseConsoleRequest.createConfigExercise(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "添加成功");
      getExercises();
    } finally{
      ToastUtils.hideLoading();
    }

  }

  /// 编辑题目配置
  Future<void> editExerciseConfig(BuildContext context, ManageLessonQuizTemplateEntity data) async {
    if(data.exercise == null) return;
    QuizConfigDialogResult? quizRes = await QuizConfigDialog.show(
      context: context, 
      showDscribe: true,
      data: ManageQuizTemplateEntity(
        exercise: data.exercise,
        template: data.template,
        description: data.description,
      ), 
    );
    if(quizRes == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "uid": quizRes.quizModelConfig.uid,
      };
      Map<String, dynamic> reqData = {
        "description": quizRes.desc,
        "config": quizRes.quizModelConfig.toJson(),
        "estimatedTime": quizRes.quizData?.estimatedTime,
        "exerciseType": quizRes.quizData?.type,
      };
      bool res = await CourseConsoleRequest.editConfigExercise(parameters, reqData);
      if(!res) return;
      ToastUtils.showToast(text: "编辑成功");
      getExercises();
    } finally{
      ToastUtils.hideLoading();
    }

    
  }


  /// 选择题目
  void selectExercise(int? configId){
    if(configId == null) return;

    if(pageType == "single"){
      selectedConfigIds.value = [configId];
      return;
    }

    if(selectedConfigIds.contains(configId)){
      selectedConfigIds.remove(configId);
    }else{
      selectedConfigIds.add(configId);
    }
  }


  /// 返回页面
  void back(){
    Get.back();
  }

  /// 确定选择的按钮
  void confirmSelect(){
    if(selectedConfigIds.isEmpty) {
      ToastUtils.showToast(text: "请选择题目模版");
      return;
    }

    Get.back(result: selectedConfigIds.toList());

    
    
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
