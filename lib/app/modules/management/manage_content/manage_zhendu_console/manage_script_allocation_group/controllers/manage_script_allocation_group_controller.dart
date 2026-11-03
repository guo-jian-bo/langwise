import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';

class ManageScriptAllocationGroupController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageScriptAllocationGroupController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SCRIPT_ALLOCATION_GROUP;

  @override
  String get breadcrumbTitle => '剧本分配分组';

  /// 传进来的数据
  ManageScriptEntity? assignedData;

  /// 搜索输入框
  final TextEditingController searchInput = TextEditingController();

  int limit = 20;
  int offset = 0;
  int total = 0;
  bool isLoading = true;

  final ScrollController leftScrollController = ScrollController();

  /// 列表数据
  final RxList<ManageScriptGroupingEntity> listData = <ManageScriptGroupingEntity>[].obs;

  /// 选择的分组
  final RxList<ManageScriptGroupingEntity> selectList = <ManageScriptGroupingEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if(Get.arguments != null){
      Map json = Get.arguments['data'];
      assignedData = ManageScriptEntity.fromJson(Map<String, dynamic>.from(json));
      setDefaultGroup();
    }
    listenScroll();
    refreshListData();
  }


  /// set 默认分组
  void setDefaultGroup(){
    if(assignedData?.groupIds == null || assignedData?.groupName == null) return;
    List<int?> groupIds = assignedData?.groupIds??[];
    List<String?> groupNames = assignedData?.groupName??[];

    for(int i = 0; i < groupIds.length; i++){
      ManageScriptGroupingEntity setData = ManageScriptGroupingEntity(
        uid: groupIds[i],
        name: [LanguageText(lang: "zh", text: groupNames[i])],
      );
      selectList.add(setData);
    }


  }

  /// 监听列表滚动进行分页加载
  void listenScroll() {
    leftScrollController.addListener(() {
      if (leftScrollController.position.pixels >= leftScrollController.position.maxScrollExtent - 200 && !leftScrollController.position.outOfRange) {
        if (!isLoading && listData.length < total) {
          offset += limit;
          getListData();
        }
      }
    });
  }

  /// 刷新列表数据
  Future<void> refreshListData() async {
    total = 0;
    offset = 0;
    listData.clear();
    await getListData();
  }

  /// 获取列表数据
  Future<void> getListData() async {
    try {
      isLoading = true;
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "limit": limit,
        "offset": offset,
        "order": "-uid",
      };
      Map<String, dynamic> reqData = {
        "enable": true,
      };
      if (searchInput.text.isNotEmpty) {
        reqData["keyword"] = searchInput.text;
      }
      ListResponseEntity<ManageScriptGroupingEntity>? res = await LanguageConsoleDramaRequest.getScriptGroupPages(parameters: parameters, data: reqData);
      if (res == null) return;
      total = res.count ?? 0;
      List<ManageScriptGroupingEntity> list = res.datas ?? [];
      for (ManageScriptGroupingEntity item in list) {
        listData.add(item);
      }
    } finally {
      isLoading = false;
      ToastUtils.hideLoading();
    }
  }

  /// 判断是否选中
  bool getIsSelectData(ManageScriptGroupingEntity data){
    if(data.uid == null) return false;
    List<int> selectIds = [];
    for (var element in selectList) {
      if(element.uid == null) continue;
      selectIds.add(element.uid!);
    }
    return selectIds.contains(data.uid);
  }

  /// 选择分组
  void selectGroup(ManageScriptGroupingEntity data){

    if(getIsSelectData(data)){
      selectList.removeWhere((element) => element.uid == data.uid);
    }else{
      selectList.add(data);
    }

  }


  /// 确定分配分组
  Future<void> confirmAllocation(BuildContext context) async{
    if(assignedData?.uid == null) return;

    try {

      ToastUtils.showLoading();

      List<int> uids = [];
      for (var element in selectList) {
        if(element.uid == null) continue;
        uids.add(element.uid!);
      }

      Map<String, dynamic> reqData = {
        "groupIds": uids,
      };
      bool res = await LanguageConsoleDramaRequest.scriptEdit(assignedData!.uid!, data: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "分配成功", type: ToastType.success);
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
