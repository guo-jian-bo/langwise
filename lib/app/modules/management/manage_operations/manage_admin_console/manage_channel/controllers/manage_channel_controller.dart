import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';

class ManageChannelController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageChannelController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_CHANNEL;

  @override
  String get breadcrumbTitle => '渠道管理';

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{
    "updated": FilterSortsData(
      title: "更新时间",
      sorts: [
        FilterSortsItem(name: "最早更新", direction: FilterSortDirection.up),
        FilterSortsItem(name: "最近更新", direction: FilterSortDirection.down, selected: true, isDefault: true),
      ],
    ),
    // "subChannelCount": FilterSortsData(
    //   title: "二级渠道数量",
    //   sorts: [
    //     FilterSortsItem(name: "最少", direction: FilterSortDirection.up),
    //     FilterSortsItem(name: "最多", direction: FilterSortDirection.down),
    //   ],
    // ),
  }.obs;

  final RxMap<String, FilterConditionsData> filterConditions = {
    "access": FilterConditionsData(
      title: "状态",
      conditions: [
        FilterConditionsItem(name: "已启用", value: AccessEnum.NORMAL.value),
        FilterConditionsItem(name: "已停用", value: AccessEnum.INTERNAL.value),
      ],
    ),
  }.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "keyWord": FilterSearchsData(
      title: "搜索",
      hintText: "搜索渠道名称 / 渠道ID",
      controller: TextEditingController(),
    ),
  };

  /// 渠道列表
  final RxList<ManageChannelEntity> channelList = <ManageChannelEntity>[].obs;
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
        if(!isLoading.value && channelList.length < total){
          offset += limit;
          getChannelList();
        }
      }
    });
  }

  /// 刷新列表
  Future<void> refreshList() async{
    channelList.clear();
    offset = 0;
    total = 0;
    getChannelList();
  }

  /// 获取渠道列表
  Future<void> getChannelList() async {
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

      ListResponseEntity<ManageChannelEntity>? list = await AccountConsoleRequest.getChannelList(params: params, data: reqData);
      if(list == null) return;
      total = list.count??0;
      channelList.addAll(list.datas??[]);
    }finally{
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }


  /// 跳转至新建一级渠道
  Future<void> createChannel() async {
    dynamic res = await ManagePageRegistry.jumpTo(Routes.MANAGE_CHANNEL_CREATE);
    if(res == null) return;
    refreshList();
  }

  /// 编辑渠道
  Future<void> editChannel(ManageChannelEntity channel) async {
    if(!ManageAuthUtils.isAuth(ManageAuthCode.channelEditV2)) return;

    if(channel.uid == null) return;
    dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_CHANNEL_CREATE, 
      arguments: {
        "channelUid": channel.uid,
      },
    );
    if(res == null) return;
    if(res is ManageChannelEntity){
      ManageChannelEntity temp = res;
      for(int i = 0; i < channelList.length; i++){
        if(channelList[i].uid == temp.uid){
          channelList[i] = temp;
          break;
        }
      }
      channelList.refresh();
    }else if(res == -1){
      channelList.removeWhere((e) => e.uid == channel.uid);
      channelList.refresh();
    }
  }


  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
