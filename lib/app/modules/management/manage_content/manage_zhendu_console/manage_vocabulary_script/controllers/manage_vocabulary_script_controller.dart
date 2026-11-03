import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';

class ManageVocabularyScriptController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageVocabularyScriptController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_VOCABULARY_SCRIPT;

  @override
  String get breadcrumbTitle => '词汇剧本';


  final RxMap<String, FilterConditionData> filterConditionDatas = <String, FilterConditionData>{

  }.obs;

  final Map<String, FilterInputData> filterInputDatas = {
    "uid": FilterInputData(
      hintText: "uid",
      controller: TextEditingController(),
    ),
    "title": FilterInputData(
      hintText: "标题",
      controller: TextEditingController(),
    ),
    "theme_nid": FilterInputData(
      hintText: "theme",
      controller: TextEditingController(),
    ),
    "genre_nid": FilterInputData(
      hintText: "genre",
      controller: TextEditingController(),
    ),
  };

  final RxInt totalCount = 0.obs;
  int offset = 0;
  int limit = 20;
  final PagerController pagerController = PagerController();
  final RxList<ManageScriptEntity> dataList = <ManageScriptEntity>[].obs;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    refreshListData();
  }

  /// 刷新列表数据
  Future<void> refreshListData() async{
    totalCount.value = 0;
    offset = 0;
    dataList.clear();
    await getDataList();
  }

  /// 分页器回调
  void pagerCallback(int page, int pageSize) {
    offset = (page - 1) * pageSize;
    limit = pageSize;
    refreshListData();
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
      Map<String, dynamic> reqData = {
        "scriptType": ScriptTypeEnum.vocabulary.value,
      };
      String? searchUid = FilterDialog.getSearchStr(key: "uid", filterInputDatas: filterInputDatas);
      List<int>? uids = FilterDialog.stringToIntList(searchUid);
      if(uids != null){
        reqData['uids'] = uids;
      }
      String? titleStr = FilterDialog.getSearchStr(key: "title", filterInputDatas: filterInputDatas);
      if(titleStr != null){
        reqData['title'] = titleStr;
      }
      String? themeNidStr = FilterDialog.getSearchStr(key: "theme_nid", filterInputDatas: filterInputDatas);
      if(themeNidStr != null){
        reqData['theme_nid'] = themeNidStr;
      }
      String? genreNidStr = FilterDialog.getSearchStr(key: "genre_nid", filterInputDatas: filterInputDatas);
      if(genreNidStr != null){
        reqData['genre_nid'] = genreNidStr;
      }

      ListResponseEntity<ManageScriptEntity>? res = await LanguageConsoleDramaRequest.getScriptList(parameters: parameters, data: reqData);
      if(res == null) return;
      totalCount.value = res.count??0;
      List<ManageScriptEntity> list = res.datas??[];
      dataList.value = list;
    } finally{
      ToastUtils.hideLoading();
    }
  }

    /// 上下架
  Future<void> onListingAndDelisting(BuildContext context, ManageScriptEntity entity) async{
    if(entity.uid == null) return;
    bool res = await AskDialog.showUserAsk(
      context: context,
      title: entity.isNormal ? "下架": "上架",
      content: "确定要${entity.isNormal ? "下架": "上架"}此剧本吗？",
      define: entity.isNormal ? "下架": "上架",
      defineColor: entity.isNormal ? AppTheme.cSurfaceError.color : AppTheme.cSurfaceSuccess.color,
    );
    if(!res) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": entity.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
      };

      bool res = await LanguageConsoleDramaRequest.scriptEdit(entity.uid!, data: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "${entity.isNormal ? "下架": "上架"}成功", type: ToastType.success);
      getDataList();
    } finally{
      ToastUtils.hideLoading();
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

  /// 分配分组
  Future<void> assignGroups(ManageScriptEntity data) async{
    dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_SCRIPT_ALLOCATION_GROUP,
      arguments: {
        "data": data.toJson(),
        "scriptType": ScriptTypeEnum.vocabulary.value,
      },
    );
    if(res == true){
      getDataList();
    }
  }

  /// 剧本详情
  Future<void> scriptDetils(ManageScriptEntity data) async{
    if(data.uid == null) return;
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_SCRIPT_DETAILS,
      arguments: {
        "scriptId": data.uid,
        "scriptType": ScriptTypeEnum.vocabulary.value,
      },
    );
  }


  /// 新建词汇剧本
  Future<void> createVocabularyScript() async{
    ManagePageRegistry.jumpTo(Routes.MANAGE_CREATE_VOCABULARY_SCRIPT);
  }
  

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
