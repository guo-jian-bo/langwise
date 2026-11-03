import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/tag_routes.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/enum/enum.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../../utils/utils.dart';
import '../../../../../../../routes/routes.dart';
import '../../../../../utils/utils.dart';

class ManageCreateAudioProjectController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCreateAudioProjectController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_CREATE_AUDIO_PROJECT;

  @override
  String get breadcrumbTitle => '新建音频项目';
  
  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{
    "uid": FilterSortsData(
      title: "uid",
      sorts: [
        FilterSortsItem(name: "从小到大", direction: FilterSortDirection.up),
        FilterSortsItem(name: "从大到小", direction: FilterSortDirection.down, selected: true, isDefault: true),
      ],
    ),
    "created": FilterSortsData(
      title: "创建日期",
      sorts: [
        FilterSortsItem(name: "从早到晚", direction: FilterSortDirection.up),
        FilterSortsItem(name: "从晚到早", direction: FilterSortDirection.down),
      ],
    ),
  }.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "uids": FilterSearchsData(
      title: "uid",
      hintText: "uid",
      controller: TextEditingController(),
      isCommaSeparated: true,
    ),
    "title": FilterSearchsData(
      title: "标题",
      hintText: "标题",
      controller: TextEditingController(),
    ),
    "moduleId": FilterSearchsData(
      title: "模块ID",
      hintText: "模块ID",
      controller: TextEditingController(),
    ),
    "unitId": FilterSearchsData(
      title: "单元ID",
      hintText: "单元ID",
      controller: TextEditingController(),
    ), 
  };

  final ScrollController scriptScrollController = ScrollController();
  int totalCount = 0;
  int offset = 0;
  int limit = 20;
  bool isLoading = true;
  /// 剧本列表
  final RxList<ManageScriptEntity> scriptList = <ManageScriptEntity>[].obs;
  /// 剧本类型 0=全部 1=单元剧本 2=词汇剧本
  final RxInt scriptType = 0.obs;

  /// 选择的剧本
  final Rx<ManageScriptEntity?> selectScriptData = Rx(null);

  /// 生成音频数量
  final RxInt audioNumber = 4.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    if(Get.arguments != null){
      int? scriptId = Get.arguments['scriptId'];
      filterSearchs['uids']?.controller.text = scriptId?.toString()??'';
    }
    getThemeGenreList();
    listenScroll();
    refreshScriptListData();
  }

  /// 获取主题题材列表 用作筛选
  Future<void> getThemeGenreList() async{
    List<ManageScriptThemeEntity>? res = await LanguageConsoleDramaRequest.getScriptThemeList();
    if(res != null){
      List<FilterConditionsItem> conditions = [];
      for (var element in res) {
        String? name = element.name?.firstWhereOrNull((e) => e?.lang == "zh")?.text;
        if(name == null && element.name?.isNotEmpty == true){
          name = element.name?.first?.text;
        }
        if(name == null || name.isEmpty) continue;
        conditions.add(FilterConditionsItem(name: name, value: element.nid));
      }
      filterConditions['theme_nid'] = FilterConditionsData(
        title: "主题",
        conditions: conditions,
      );
    }

    List<ManageScriptGenreEntity>? resGenre = await LanguageConsoleDramaRequest.getScriptGenreList();
    if(resGenre != null){
      List<FilterConditionsItem> conditions = [];
      for (var element in resGenre) {
        String? name = element.name?.firstWhereOrNull((e) => e?.lang == "zh")?.text;
        if(name == null && element.name?.isNotEmpty == true){
          name = element.name?.first?.text;
        }
        if(name == null || name.isEmpty) continue;
        conditions.add(FilterConditionsItem(name: name, value: element.nid));
      }
      filterConditions['genre_nid'] = FilterConditionsData(
        title: "题材",
        conditions: conditions,
      );
    }
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    scriptScrollController.addListener(() {
      if(scriptScrollController.position.pixels >= scriptScrollController.position.maxScrollExtent - 200 && !scriptScrollController.position.outOfRange){
        if(!isLoading && scriptList.length < totalCount){
          offset += limit;
          getScriptDataList();
        }
      }
    });
  }

  /// 刷新列表数据
  Future<void> refreshScriptListData() async{
    totalCount = 0;
    offset = 0;
    scriptList.clear();
    await getScriptDataList();
  }

  Future<void> getScriptDataList() async{
    try {
      isLoading = true;
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "offset": offset,
        "limit": limit,
        "order": "-uid",
      };

      Map<String, dynamic> sortOrder = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
      parameters.addAll(sortOrder);

      ScriptTypeEnum? scriptTypeEnum;
      if(scriptType.value == 1){
        scriptTypeEnum = ScriptTypeEnum.unit;
      }else if(scriptType.value == 2){
        scriptTypeEnum = ScriptTypeEnum.vocabulary;
      }
      
      Map<String, dynamic> reqData = {
        "scriptType": scriptTypeEnum?.value,
      };

      Map<String, dynamic> conditionParameter = FilterStripUtils.getConditionParameter(conditions: filterConditions);
      reqData.addAll(conditionParameter);

      Map<String, dynamic> searchParameter = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      reqData.addAll(searchParameter);

      ListResponseEntity<ManageScriptEntity>? res = await LanguageConsoleDramaRequest.getScriptList(parameters: parameters, data: reqData);
      if(res == null) return;
      totalCount = res.count??0;
      List<ManageScriptEntity> list = res.datas??[];
      scriptList.addAll(list);
    } finally{
      isLoading = false;
      ToastUtils.hideLoading();
    }
  }

  /// 根据uid查询单独的剧本数据 用作刷新单独的剧本详情
  Future<ManageScriptEntity?> refreshScriptData(int? scriptId) async{
    try {
      ToastUtils.showLoading();
      if(scriptId == null) return null;
      Map<String, dynamic> reqData = {
        "uid": scriptId,
      };
      ListResponseEntity<ManageScriptEntity>? res = await LanguageConsoleDramaRequest.getScriptList(data: reqData);
      if(res == null) return null;
      return res.datas?.firstWhereOrNull((e) => e.uid == scriptId);  
    } finally{
      ToastUtils.hideLoading();
    }
  }



  /// 跳转至音频项目详情
  Future<void> toAudioProjectDetail(ManageScriptEntity data, ManageScriptEntityAudioProjects? audioProject) async{
    if(audioProject?.projectId == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_AUDIO_PROJECT_DETILS,
      arguments: {
        "projectId": audioProject?.projectId,
      },
    );
    ManageScriptEntity? res = await refreshScriptData(data.uid);
    if(res != null){
      data = res;
      scriptList.refresh();
    }
  }

  /// 跳转至视觉项目详情
  Future<void> toVisualProjectDetail(ManageScriptEntity data, ManageScriptEntityVisualProjects? visualProject) async{
    if(visualProject?.projectId == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_VISUAL_PROJECT_DETILS,
      arguments: {
        "projectId": visualProject?.projectId,
      },
    );
    ManageScriptEntity? res = await refreshScriptData(data.uid);
    if(res != null){
      data = res;
      scriptList.refresh();
    }
  }

  /// 核心知识点
  Future<void> coreKnowledge(ManageScriptEntity data) async{
    if((data.usedKnowledgePoints?.length??0) == 0) return ToastUtils.showToast(text: "暂无核心知识点");
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_CORE_KNOWLEDGE,
      arguments: {
        "uid": data.uid,
        "type": KnowledgeTypeEnum.SCRIPT.value,
      },
    );
  }

  /// 关联课程
  Future<void> relatedCourses(ManageScriptEntity data) async{
    if(data.courseInfo == null) return;

    // TagRoutes.toNamed(
    //   Routes.OFFICIAL_COURSE_DETAILS_TARGET,
    //   arguments: {
    //     "courseId": data.courseInfo?.courseId,
    //     "moduleId": data.courseInfo?.courseModuleId,
    //     "unitId": data.courseInfo?.courseUnitId,
    //     "isAdminPage": true,
    //     "language": data.lang,
    //   },
    // );

    await TagRoutes.toNamed(
      Routes.COURSE_UNIT_TARGET,
      arguments: {
        "courseId": data.courseInfo?.courseId,
        "moduleId": data.courseInfo?.courseModuleId,
        "unitId": data.courseInfo?.courseUnitId,
        "language": data.lang,
        "isManagement": true,
      },
    );

  }


  /// 选择剧本
  Future<void> selectScript(ManageScriptEntity data) async{
    selectScriptData.value = data;
  }

  /// 创建音频项目
  Future<void> createAudioProject() async{
    if(selectScriptData.value == null) return ToastUtils.showToast(text: "请选择剧本");
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "scriptId": selectScriptData.value?.uid,
        "numberOfVoices": audioNumber.value,
      };

      String? res = await LanguageConsoleDramaRequest.createAudioProject(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      Get.back(result: true);

    } finally{
      ToastUtils.hideLoading();
    }
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
