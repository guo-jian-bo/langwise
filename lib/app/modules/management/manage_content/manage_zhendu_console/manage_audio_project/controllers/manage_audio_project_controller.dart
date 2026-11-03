import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/stores/user.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/mqtt_utils/mqtt_message_services_code.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../../enums/manage_audio_project_status_enum.dart';

class ManageAudioProjectController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageAudioProjectController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_AUDIO_PROJECT;

  @override
  String get breadcrumbTitle => '音频项目';

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
      conditions: ManageAudioProjectStatusEnum.values.map((e) => FilterConditionsItem(
        name: e.value,
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
  final RxList<ManageAudioProjectEntity> dataList = <ManageAudioProjectEntity>[].obs;

  StreamSubscription<PushMessageServiceEnitiy>? _composeAudioSub;

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

    _composeAudioSub = MqttNotificationMessage.instance.listenByCode(
      codes: [
        MqttMessageServicesCode.MESSAGE_VISUAL_PROJECT_CREATE, 
        MqttMessageServicesCode.MESSAGE_ASS_TASK, 
        MqttMessageServicesCode.MESSAGE_COMPOSE_AUDIO,
        MqttMessageServicesCode.MESSAGE_VOICE_DIALOGUE_CREATE,
      ], 
      onData: (value){
        getDataList(showLoading: false);
      },
    );
  }

  /// 分页器回调
  void pagerCallback(int page, int pageSize) {
    offset = (page - 1) * pageSize;
    limit = pageSize;
    getDataList();
  }

  Future<void> getDataList({bool showLoading = true}) async{
    try {
      if(showLoading) ToastUtils.showLoading();
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

      ListResponseEntity<ManageAudioProjectEntity>? res = await LanguageConsoleDramaRequest.getAudioProjectList(parameters: parameters, data: reqData);
      if(res == null) return;
      totalCount.value = res.count??0;
      List<ManageAudioProjectEntity> list = res.datas??[];
      dataList.value = list;
    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }


  /// 删除
  Future<void> deleteData(BuildContext context, ManageAudioProjectEntity data) async{
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
      bool res = await LanguageConsoleDramaRequest.deleteAudioProject(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      getDataList();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 新建视觉项目
  Future<void> addVisualProject(ManageAudioProjectEntity data) async {
    if(data.uid == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_CREATE_VISUAL_PROJECT,
      arguments: {
        "projectId": data.uid,
      },
    );
    getDataList();
  }

  /// 视觉项目详情
  Future<void> visualProjectDetail(ManageAudioProjectEntityVisualProjects? visualProject) async {
    if(visualProject?.projectId == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_VISUAL_PROJECT_DETILS,
      arguments: {
        "projectId": visualProject?.projectId,
      },
    );
    getDataList();
  }

  /// 新建字幕
  Future<void> assReviewCreateAss(ManageAudioProjectEntityAudioInfo? audioInfo) async{
    if(audioInfo?.audioId == null) return;

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "audioUid": audioInfo?.audioId,
      };
      String? res = await LanguageConsoleRequest.assReviewCreateAudioAlign(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 去编辑字幕页面
  Future<void> toEditAssPage(ManageAudioProjectEntityAudioInfo? audioInfo) async{
    if(audioInfo?.audioId == null) return ToastUtils.showToast(text: "缺少assId");
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_ASS_DETILS,
      arguments: {
        "assId": audioInfo?.assId,
      },
    );
    getDataList();
  }

  /// 去编辑翻译页面
  Future<void> toEditTranslatePage(ManageAudioProjectEntityAudioInfo? audioInfo) async{
    if(audioInfo?.audioId == null) return ToastUtils.showToast(text: "缺少assId");
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_ASS_TRANSLATE,
      arguments: {
        "assId": audioInfo?.assId,
      },
    );
    getDataList();
  }

  /// 去审核音频
  Future<void> reviewAudio(ManageAudioProjectEntity data) async {
    if(data.audioTaskIds == null || data.audioTaskIds?.isNotEmpty == false) {
      return ToastUtils.showToast(text: "暂无待审核音频");
    }
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_AUDIO,
      arguments: {
        "taskIds": data.audioTaskIds,
      },
    );
    getDataList();
  }

  /// 去审核字幕
  Future<void> reviewAss(ManageAudioProjectEntity data) async {
    if(data.assTaskIds == null || data.assTaskIds?.isNotEmpty == false) {
      return ToastUtils.showToast(text: "暂无待审核字幕");
    }
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_ASS,
      arguments: {
        "taskIds": data.assTaskIds,
      },
    );
    getDataList();
  }

  /// 创建记录
  Future<void> createRecord() async{
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_ZHENDU_GENERATE_TASK,
      arguments: {
        "taskType": "audioProjectCreate",
      },
    );
  }

  /// 新增音频项目
  Future<void> addAudioProject() async {
    ManagePageRegistry.jumpTo(Routes.MANAGE_CREATE_AUDIO_PROJECT);
  }

  /// 音频项目详情
  Future<void> audioProjectDetail(ManageAudioProjectEntity data) async {
    if(data.uid == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_AUDIO_PROJECT_DETILS,
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
    _composeAudioSub?.cancel();
  }
}
