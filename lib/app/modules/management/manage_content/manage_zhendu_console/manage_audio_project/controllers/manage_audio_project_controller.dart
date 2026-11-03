import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
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

  final RxMap<String, FilterConditionData> filterConditionDatas = <String, FilterConditionData>{
    "status": FilterConditionData(
      title: "状态",
      isSingle: true,
      conditions: ManageAudioProjectStatusEnum.values.map((e) => FilterConditionItem(
        name: e.value,
        value: e.value,
        color: AppTheme.cSurfaceBrand.color,
      )).toList(),
    ),
  }.obs;

  final Map<String, FilterInputData> filterInputDatas = {
    "keyword": FilterInputData(
      hintText: "综合搜索（标题 / 状态 / 关联对象）",
      controller: TextEditingController(),
    ),
    "uid": FilterInputData(
      hintText: "uid",
      controller: TextEditingController(),
    ),
    "title": FilterInputData(
      hintText: "title",
      controller: TextEditingController(),
    ),
  };

  final RxInt totalCount = 0.obs;
  int offset = 0;
  int limit = 20;
  final PagerController pagerController = PagerController();
  final RxList<ManageAudioProjectEntity> dataList = <ManageAudioProjectEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    getDataList();
  }

  /// 分页器回调
  void pagerCallback(int page, int pageSize) {
    offset = (page - 1) * pageSize;
    limit = pageSize;
    getDataList();
  }

   /// 筛选-改变
  void changeFilterConditionData(Map<String, FilterConditionData> datas) {
    filterConditionDatas.value = datas;
    filterConditionDatas.refresh();
    pagerController.jumpToPage(1);
  }

  /// 搜索提交
  void searchSubmitted() {
    pagerController.jumpToPage(1);
  }

  Future<void> getDataList() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "offset": offset,
        "limit": limit,
        "order": "-uid",
      };

      Map<String, dynamic> reqData = {};

      String? keywordStr = FilterDialog.getSearchStr(key: "keyword", filterInputDatas: filterInputDatas);
      if(keywordStr != null){
        reqData['keyword'] = keywordStr;
      }

      String? searchUid = FilterDialog.getSearchStr(key: "uid", filterInputDatas: filterInputDatas);
      List<int>? uids = FilterDialog.stringToIntList(searchUid);
      if(uids != null){
        reqData['uids'] = uids;
      }
      String? titleStr = FilterDialog.getSearchStr(key: "title", filterInputDatas: filterInputDatas);
      if(titleStr != null){
        reqData['title'] = titleStr;
      }

      List<FilterConditionItem>? status = FilterDialog.getFilterData(key: "status", filterConditionData: filterConditionDatas);
      if((status??[]).isNotEmpty){
        reqData['status'] = status?.first.value;
      }

      ListResponseEntity<ManageAudioProjectEntity>? res = await LanguageConsoleDramaRequest.getAudioProjectList(parameters: parameters, data: reqData);
      if(res == null) return;
      totalCount.value = res.count??0;
      List<ManageAudioProjectEntity> list = res.datas??[];
      dataList.value = list;
    } finally{
      ToastUtils.hideLoading();
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
  }
}
