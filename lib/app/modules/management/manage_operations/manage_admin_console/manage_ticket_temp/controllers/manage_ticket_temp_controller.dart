import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';

class ManageTicketTempController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageTicketTempController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_TICKET_TEMP;

  @override
  String get breadcrumbTitle => '工单模版';

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{
    "updated": FilterSortsData(
      title: "更新时间",
      sorts: [
        FilterSortsItem(name: "最早更新", direction: FilterSortDirection.up),
        FilterSortsItem(name: "最近更新", direction: FilterSortDirection.down, selected: true, isDefault: true),
      ],
    ),
    // "formCount": FilterSortsData(
    //   title: "表单项数量",
    //   sorts: [
    //     FilterSortsItem(name: "最少", direction: FilterSortDirection.up),
    //     FilterSortsItem(name: "最多", direction: FilterSortDirection.down),
    //   ],
    // ),
  }.obs;

  final RxMap<String, FilterConditionsData> filterConditions = {
    "access": FilterConditionsData(
      title: "状态",
      isSingle: false,
      conditions: [
        FilterConditionsItem(name: "已启用", value: AccessEnum.NORMAL.value),
        FilterConditionsItem(name: "已停用", value: AccessEnum.INTERNAL.value),
      ],
    ),
  }.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "搜索模版名称 / 说明",
      controller: TextEditingController(),
    ),
  };

  final RxList<ManageTicketTempEntity> ticketTempList = <ManageTicketTempEntity>[].obs;

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
    refreshList();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange){
        if(!isLoading.value && ticketTempList.length < total){
          offset += limit;
          getTicketTempList();
        }
      }
    });
  }

  /// 刷新列表
  Future<void> refreshList() async{
    ticketTempList.clear();
    offset = 0;
    total = 0;
    getTicketTempList();
  }

  /// 获取工单模版列表
  Future<void> getTicketTempList() async {
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

      ListResponseEntity<ManageTicketTempEntity>? list = await AccountConsoleRequest.getManageTicketTempList(params: params, data: reqData);
      if(list == null) return;
      total = list.count??0;
      ticketTempList.addAll(list.datas??[]);
    }finally{
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }



  /// 新建工单模版
  Future<void> createTicketTemp() async{
    dynamic res = await ManagePageRegistry.jumpTo(Routes.MANAGE_TICKET_TEMP_CREATE);
    if(res == null) return;
    refreshList();
  }

  /// 编辑工单模版
  Future<void> editTicketTemp(ManageTicketTempEntity ticketTemp) async{
    if(!ManageAuthUtils.isAuth(ManageAuthCode.channelTicketTemplateEdit)) return;
    
    dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_TICKET_TEMP_CREATE, 
      arguments: {
        "ticketTemp": ticketTemp,
      },
    );
    if(res == null) return;
    if(res is ManageTicketTempEntity){
      ManageTicketTempEntity temp = res;
      for(int i = 0; i < ticketTempList.length; i++){
        if(ticketTempList[i].uid == temp.uid){
          ticketTempList[i] = temp;
          break;
        }
      }
      ticketTempList.refresh();
    }else if(res == -1){
      ticketTempList.removeWhere((e) => e.uid == ticketTemp.uid);
      ticketTempList.refresh();
    }
  }



  @override
  void onClose() {
    // TODO: 清理逻辑
    scrollController.dispose();
    super.onClose();
  }
}
