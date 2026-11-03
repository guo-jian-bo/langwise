import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/access_enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/filter_widgets.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/app_pages.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../utils/manage_page_registry.dart';


class ManagePermissionController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManagePermissionController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_PERMISSION;

  @override
  String get breadcrumbTitle => '权限管理';

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{}.obs;

  final RxMap<String, FilterConditionsData> filterConditions = {
    "access": FilterConditionsData(
      title: "状态",
      conditions: [
        FilterConditionsItem(name: "全部", value: null, selected: true),
        FilterConditionsItem(name: "已启用", value: AccessEnum.NORMAL.value),
        FilterConditionsItem(name: "已停用", value: AccessEnum.INTERNAL.value),
      ],
    ),
  }.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "userId": FilterSearchsData(
      title: "搜索",
      hintText: "搜索用户ID",
      controller: TextEditingController(),
    ),
  };

  final RxList<ManagePermissionUserEntity> permissionUserList = <ManagePermissionUserEntity>[].obs;
  final RxList<ManageChannelEntity> channelList = <ManageChannelEntity>[].obs;
  final RxList<NotifyTempEntity> notifyTemplateList = <NotifyTempEntity>[].obs;
  final RxList<GroupNotifyTempEntityEntityList> notifyTemplateGroups = <GroupNotifyTempEntityEntityList>[].obs;
  final RxList<RoleDtoEntity> roleList = <RoleDtoEntity>[].obs;
  final ScrollController scrollController = ScrollController();
  final RxBool isLoading = false.obs;
  final RxBool isBaseDataLoading = false.obs;
  int total = 0;
  int offset = 0;
  int limit = 20;

  Future<void> createEmployee() async {
    dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_PERMISSION_CREATE,
      arguments: {
        "channelList": channelList.toList(),
        "notifyTemplateGroups": notifyTemplateGroups.toList(),
        "notifyTemplateList": notifyTemplateList.toList(),
        "roleOptions": roleList
            .where((e) => e.uid != null && (e.name ?? '').trim().isNotEmpty)
            .map((e) => {
                  "id": e.uid,
                  "name": e.name,
                })
            .toList(),
      },
    );
    if (res == null) return;
    refreshList();
  }

  Future<void> editEmployee(ManagePermissionUserEntity user) async {
    dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_PERMISSION_CREATE,
      arguments: {
        "permissionUser": user,
        "channelList": channelList.toList(),
        "notifyTemplateGroups": notifyTemplateGroups.toList(),
        "notifyTemplateList": notifyTemplateList.toList(),
        "roleOptions": roleList
            .where((e) => e.uid != null && (e.name ?? '').trim().isNotEmpty)
            .map((e) => {
                  "id": e.uid,
                  "name": e.name,
                })
            .toList(),
      },
    );
    if (res == null) return;
    refreshList();
  }

  void listenScroll() {
    scrollController.addListener(() {
      if (scrollController.position.pixels < scrollController.position.maxScrollExtent - 200) {
        return;
      }
      if (scrollController.position.outOfRange) return;
      if (isLoading.value) return;
      if (permissionUserList.length >= total) return;
      offset += limit;
      getPermissionUserList();
    });
  }

  Future<void> refreshList() async {
    permissionUserList.clear();
    offset = 0;
    total = 0;
    await getPermissionUserList();
  }

  Future<void> getPermissionUserList() async {
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      final Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      final Map<String, dynamic> reqData = {};
      final Map<String, dynamic> conditionParams = FilterStripUtils.getConditionParameter(conditions: filterConditions);
      if (conditionParams.isNotEmpty) {
        reqData.addAll(conditionParams);
      }
      final Map<String, dynamic> searchParams = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      if (searchParams.isNotEmpty) {
        reqData.addAll(searchParams);
      }
      final ListResponseEntity<ManagePermissionUserEntity>? list =
          await AccountConsoleRequest.getManagePermissionUserList(
        data: reqData,
        params: params,
      );
      if (list == null) return;
      total = list.count ?? 0;
      permissionUserList.addAll(list.datas ?? []);
    } finally {
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  Future<void> loadBaseData() async {
    try {
      isBaseDataLoading.value = true;
      ToastUtils.showLoading();
      final List<Future<dynamic>> tasks = [
        AccountConsoleRequest.getUsableChannelAllList(),
        AccountConsoleRequest.getNoticeTempSendList(
          params: const {
            "offset": 0,
            "limit": 100,
          },
        ),
        AccountConsoleRequest.getRolePages(
          data: const {
            "groupType": "assistant",
          },
          params: const {
            "offset": 0,
            "limit": 100,
          },
        ),
      ];
      final List<dynamic> results = await Future.wait(tasks);
      channelList.value = (results[0] as List<ManageChannelEntity>?) ?? [];
      final GroupNotifyTempEntityEntity? groupNotifyTemp = results[1] as GroupNotifyTempEntityEntity?;
      notifyTemplateGroups.value = groupNotifyTemp?.list?.whereType<GroupNotifyTempEntityEntityList>().toList() ?? [];
      final Map<int, NotifyTempEntity> notifyTempMap = {};
      for (final group in groupNotifyTemp?.list ?? []) {
        for (final temp in group?.templates ?? []) {
          if (temp?.uid == null) continue;
          notifyTempMap[temp!.uid!] = temp;
        }
      }
      notifyTemplateList.value = notifyTempMap.values.toList();
      roleList.value = (results[2] as ListResponseEntity<RoleDtoEntity>?)?.datas ?? [];
    } finally {
      isBaseDataLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    listenScroll();
    loadBaseData();
    refreshList();
  }

  @override
  void onClose() {
    scrollController.dispose();
    for (final item in filterSearchs.values) {
      item.controller.dispose();
    }
    super.onClose();
  }
}
