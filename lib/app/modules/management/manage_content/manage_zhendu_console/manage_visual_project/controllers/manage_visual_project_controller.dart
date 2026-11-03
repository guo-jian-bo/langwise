import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../enums/video_task_status_enum.dart';
import '../../../../utils/utils.dart';

class ManageVisualProjectController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageVisualProjectController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_VISUAL_PROJECT;

  @override
  String get breadcrumbTitle => '视觉项目';

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{
    "uid": FilterSortsData(
      title: "project_uid",
      sorts: [
        FilterSortsItem(name: "从小到大", direction: FilterSortDirection.up),
        FilterSortsItem(name: "从大到小", direction: FilterSortDirection.down, selected: true, isDefault: true),
      ],
    ),
  }.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{
    "userId": FilterConditionsData(
      title: "只看自己",
      conditions: [
        FilterConditionsItem(name: "是", value: UserStore.to.userId),
      ],
    ),
    "status": FilterConditionsData(
      title: "状态",
      conditions: VideoTaskStatusEnum.values.map((e) => FilterConditionsItem(
        name: e.name,
        value: e.value,
      )).toList(),
    ),
  }.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "keyword": FilterSearchsData(
      title: "关键词",
      hintText: "综合搜索（标题 / 状态 / 关联对象）",
      controller: TextEditingController(),
    ),
    "uids": FilterSearchsData(
      title: "uid",
      hintText: "uid",
      controller: TextEditingController(),
      isCommaSeparated: true,
    ),
    "title": FilterSearchsData(
      title: "title",
      hintText: "title",
      controller: TextEditingController(),
    ),
  };
  
  final RxInt totalCount = 0.obs;
  int offset = 0;
  int limit = 20;
  final PagerController pagerController = PagerController();
  final RxList<ManageVisualProjectEntity> dataList = <ManageVisualProjectEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    if(Get.arguments != null){
      List? uids = Get.arguments['uids'];
      if(uids != null){
        filterSearchs['uids']?.controller.text = uids.join(',');
      }
    }
    getDataList();
  }


  /// 分页器回调
  void pagerCallback(int page, int pageSize) {
    offset = (page - 1) * pageSize;
    limit = pageSize;
    getDataList();
  }

  Future<void> getDataList() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "offset": offset,
        "limit": limit,
      };
      
      Map<String, dynamic> sortOrder = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
      parameters.addAll(sortOrder);

      Map<String, dynamic> reqData = {};
      Map<String, dynamic> conditionParameter = FilterStripUtils.getConditionParameter(conditions: filterConditions);
      reqData.addAll(conditionParameter);

      Map<String, dynamic> searchParameter = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      reqData.addAll(searchParameter);


      ListResponseEntity<ManageVisualProjectEntity>? res = await LanguageConsoleDramaRequest.getVisualProjectList(parameters: parameters, data: reqData);
      if(res == null) return;
      totalCount.value = res.count??0;
      List<ManageVisualProjectEntity> list = res.datas??[];
      dataList.value = list;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 删除
  Future<void> deleteData(BuildContext context, ManageVisualProjectEntity data) async{
    bool deleteRes = await DeleteDialog.show(
      context: context, 
      title: "删除",
      content: "确定要删除【${data.title??''}】项目吗？"
    );
    if(!deleteRes) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "uid": data.uid,
      };
      bool res = await LanguageConsoleDramaRequest.deleteVisualProject(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      getDataList();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 跳转到剧本列表页面
  Future<void> toScriptPage(ManageVisualProjectEntity data) async{
    List<ManageVisualProjectEntityContentList?> contentList = data.contentList??[];
    if(contentList.isEmpty) return;
    List<int> uids = [];
    for(ManageVisualProjectEntityContentList? item in contentList){
      if(item?.uid == null) continue;
      uids.add(item!.uid!);
    }
    if(data.scriptTypeEnum == ScriptTypeEnum.unit){
      await ManagePageRegistry.jumpTo(
        Routes.MANAGE_UNIT_SCRIPT,
        arguments: {
          "uids": uids,
        },
      );
    }else{
      await ManagePageRegistry.jumpTo(
        Routes.MANAGE_VOCABULARY_SCRIPT,
        arguments: {
          "uids": uids,
        },
      );
    }
    getDataList();
  }

  /// 跳转至音频项目详情页面
  Future<void> audioProjectDetail(ManageVisualProjectEntity data) async{
    if(data.audioProjectId == null) return ToastUtils.showToast(text: "缺少 audioProjectId");
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_AUDIO_PROJECT_DETILS,
      arguments: {
        "projectId": data.audioProjectId,
      },
    );
    getDataList();
  }



  /// 创建记录
  Future<void> createRecord() async{
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_ZHENDU_GENERATE_TASK,
      arguments: {
        "taskType": "visualProjectCreate",
      },
    );
  }

  /// 新建视觉项目
  Future<void> addVisualProject() async {
    ManagePageRegistry.jumpTo(Routes.MANAGE_CREATE_VISUAL_PROJECT);
  }

  /// 视觉项目详情
  Future<void> visualProjectDetail(ManageVisualProjectEntity data) async {
    if(data.uid == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_VISUAL_PROJECT_DETILS,
      arguments: {
        "projectId": data.uid,
      },
    );
    getDataList();
  }
  
  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
