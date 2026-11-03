import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';

class ManageNoticeTempController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageNoticeTempController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_NOTICE_TEMP;

  @override
  String get breadcrumbTitle => '通知管理';

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{
    "updated": FilterSortsData(
      title: "更新时间",
      sorts: [
        FilterSortsItem(name: "最早更新", direction: FilterSortDirection.up),
        FilterSortsItem(name: "最近更新", direction: FilterSortDirection.down, selected: true, isDefault: true),
      ],
    ),
  }.obs;

  final RxMap<String, FilterConditionsData> filterConditions = {
    "access": FilterConditionsData(
      title: "状态",
      conditions: [
        FilterConditionsItem(name: "全部", value: null, selected: true),
        FilterConditionsItem(name: "已启用", value: AccessEnum.NORMAL.value),
        FilterConditionsItem(name: "已停用", value: AccessEnum.INTERNAL.value),
      ],
    ),
    // "jump": FilterConditionsData(
    //   title: "跳转",
    //   conditions: [
    //     FilterConditionsItem(name: "全部", value: null, selected: true),
    //     FilterConditionsItem(name: JumpTypeEnum.h5Link.name, value: JumpTypeEnum.h5Link.value),
    //     FilterConditionsItem(name: JumpTypeEnum.deepLink.name, value: JumpTypeEnum.deepLink.value),
    //   ],
    // ),
  }.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "搜索模版名称 / 标题 / 内容",
      controller: TextEditingController(),
    ),
  };

  List<NotifyTempTypeEntity> noticeTempTypeList = [];

  /// 模版列表
  final RxList<NotifyTempEntity> noticeTempList = <NotifyTempEntity>[].obs;
  /// 滚动控制器
  final ScrollController scrollController = ScrollController();
  /// 总条数
  int total = 0;
  /// offset
  int offset = 0;
  /// limit
  int limit = 20;
  /// 是否加载中
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    listenScroll();
    getNotifyTempType();
    refreshList();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange){
        if(!isLoading.value && noticeTempList.length < total){
          offset += limit;
          getNoticeTempList();
        }
      }
    });
  }

  /// 获取模版分类列表 用作筛选
  Future<void> getNotifyTempType() async{
    List<NotifyTempTypeEntity>? list = await AccountConsoleRequest.getNotifyTempType();
    if(list == null) return;
    noticeTempTypeList = list;

    List<FilterConditionsItem> conditions = [
      FilterConditionsItem(name: "全部", value: null, selected: true),
    ];
    conditions.addAll(list.map((e) => FilterConditionsItem(name: e.title??"", value: e.type)).toList());

    filterConditions["type"] = FilterConditionsData(
      title: "分组",
      conditions: conditions,
    );
  }

  /// 根据type获取分类名称
  String? getNotifyTempTypeTitle(String? type){
    if(type == null) return null;
    return noticeTempTypeList.firstWhereOrNull((e) => e.type == type)?.title;
  }

  /// 刷新列表
  Future<void> refreshList() async{
    noticeTempList.clear();
    offset = 0;
    total = 0;
    getNoticeTempList();
  }

  /// 获取通知模版列表
  Future<void> getNoticeTempList() async {
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      Map<String, dynamic> sortParams = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
      if(sortParams.isNotEmpty){
        params.addAll(sortParams);
      }

      Map<String, dynamic> reqData = {};
      Map<String, dynamic> conditionParams = FilterStripUtils.getConditionParameter(conditions: filterConditions);
      if(conditionParams.isNotEmpty){
        reqData.addAll(conditionParams);
      }

      Map<String, dynamic> searchParams = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      if(searchParams.isNotEmpty){
        reqData.addAll(searchParams);
      }

      ListResponseEntity<NotifyTempEntity>? list = await AccountConsoleRequest.getNoticeTempList(params: params, data: reqData);
      if(list == null) return;
      total = list.count??0;
      noticeTempList.addAll(list.datas??[]);
    }finally{
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }


  /// 跳转至新建通知模版页面
  Future<void> navigateToCreateNoticeTemp() async{
    dynamic res = await ManagePageRegistry.jumpTo(Routes.MANAGE_NOTICE_TEMP_CREATE);
    if(res == null) return;
    refreshList();
  }

  /// 编辑通知模版
  Future<void> editNoticeTemp(NotifyTempEntity noticeTemp) async{
    if(!ManageAuthUtils.isAuth(ManageAuthCode.notifyTemplateEdit)) return;

    dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_NOTICE_TEMP_CREATE, 
      arguments: {
        "noticeTemp": noticeTemp,
      },
    );
    if(res == null) return;
    if(res is NotifyTempEntity){
      NotifyTempEntity temp = res;
      for(int i = 0; i < noticeTempList.length; i++){
        if(noticeTempList[i].uid == temp.uid){
          noticeTempList[i] = temp;
          break;
        }
      }
      noticeTempList.refresh();
    }else if(res == -1){
      noticeTempList.removeWhere((e) => e.uid == noticeTemp.uid);
      noticeTempList.refresh();
    }
    
  }



  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
