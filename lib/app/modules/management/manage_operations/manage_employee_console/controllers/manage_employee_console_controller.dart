import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lib_common/common.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/mixins/mixins.dart';
import '../../../../../../common/public_controller/manage_sandbox_controller.dart';
import '../../../../../../common/stores/stores.dart';
import '../../../../../../common/values/values.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../../../routes/tag_routes.dart';
import '../../../../official_course_details/official_course_details_level/controllers/official_course_details_page_mode.dart';
import '../../../utils/utils.dart';
import '../../common/manage_select_channel_dialog.dart';
import '../../common/manage_inspection_history_dialog.dart';
import '../../common/manage_inspection_ticket_dialog.dart';
import '../../common/manage_select_notice_temp_dialog.dart';

class ManageEmployeeConsoleController extends GetxController with DualBreadcrumbMixin {
  final String tag;
  ManageEmployeeConsoleController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_EMPLOYEE_CONSOLE;

  @override
  String get breadcrumbTitle => '工作人员操作台';

  // 传进来的参数
  /// 是否是管理端
  bool isManagement = false;
  



  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{}.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "keyword": FilterSearchsData(
      title: "搜索",
      hintText: "搜索用户ID / 手机号",
      controller: TextEditingController(),
    ),
  };

  /// 工作人员操作台顶部统计
  final Rx<ManageEmployeeConsoleSummaryEntity> summaryData = ManageEmployeeConsoleSummaryEntity().obs;

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();
  /// offset
  int offset = 0;
  /// limit
  int limit = 40;
  /// 是否加载中
  final RxBool isLoading = false.obs;
  /// 是否还有更多数据
  bool hasMore = true;
  final RxList<ManageEmployeeConsoleMemberEntity> memberList = <ManageEmployeeConsoleMemberEntity>[].obs;
  final RxInt memberCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if(Get.arguments != null){
      isManagement = Get.arguments['isManagement']??false;
    }
    listenScroll();
    getSortConditionsData();
    getSummary();
    getMemberList();
  }

    /// 监听列表滚动进行分页加载
  void listenScroll(){
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange){
        if(!isLoading.value && hasMore){
          offset += limit;
          getMemberList();
        }
      }
    });
  }

  /// 获取排序筛选数据
  Future<void> getSortConditionsData() async{
    ZhenduScriptQueryMetaGroupListEntity? res = await AccountConsoleRequest.getEmployeeStorCondition();
    if(res == null) return;
    List<ZhenduScriptQueryMetaGroupEntity> orders = res.orders;
    if(orders.isNotEmpty){
      filterSorts.clear();
      for (var element in orders) {
        if(element.groupCode == null) continue;
        if(element.items.isEmpty) continue;
        filterSorts[element.groupCode!] = FilterSortsData(
          title: element.groupName??"",
          sorts: List.generate(element.items.length, (index){
            bool isDesc = element.items[index].value?.startsWith("-")??false;
            return FilterSortsItem(
              name: element.items[index].name??"",
              direction: isDesc ? FilterSortDirection.down : FilterSortDirection.up,
              selected: element.items[index].defaultValue??false,
              isDefault: element.items[index].defaultValue??false,
            );
          }),
        );
      }
    }

    List<ZhenduScriptQueryMetaGroupEntity> filters = res.filters;
    if(filters.isNotEmpty){
      filterConditions.clear();
      for (var element in filters) {
        if(element.groupCode == null) continue;
        if(element.items.isEmpty) continue;
        filterConditions[element.groupCode!] = FilterConditionsData(
          title: element.groupName??"",
          isSingle: element.radioGroup??false,
          conditions: List.generate(element.items.length, (index){
            return FilterConditionsItem(
              name: element.items[index].name??"",
              value: element.items[index].value??"",
              selected: element.items[index].defaultValue??false,
            );
          }),
        );
      }
    }
    
  }

  /// 刷新数据
  Future<void> refreshList() async{
    try {
      ToastUtils.showLoading();
      await getSummary();
      memberList.clear();
      offset = 0;
      hasMore = true;
      await getMemberList(showLoading: false);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 获取顶部统计
  Future<void> getSummary() async{
    if(!ManageAuthUtils.isAuth(ManageAuthCode.staffConsoleSummary)) return;
    try {
      ManageEmployeeConsoleSummaryEntity? summary = await AccountConsoleRequest.getEmployeeConsoleSummary();
      if(summary == null) return;
      summaryData.value = summary;
    } finally{
    }
  }

  /// 获取学员列表
  Future<void> getMemberList({bool showLoading = true}) async{
    if(!ManageAuthUtils.isAuth(ManageAuthCode.staffConsoleMemberPages)) return;
    try {
      isLoading.value = true;
      if(showLoading) ToastUtils.showLoading();
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
      ListResponseEntity<ManageEmployeeConsoleMemberEntity>? list = await AccountConsoleRequest.getEmployeeConsoleMemberList(data: reqData, params: params);
      if(list == null) return;
      if(list.count != null) memberCount.value = list.count!;
      if(list.offset != null) offset = list.offset!;
      hasMore = (list.datas??[]).isNotEmpty;
      memberList.addAll(list.datas ?? []);

    } finally{
      isLoading.value = false;
      if(showLoading) ToastUtils.hideLoading();
    }
  }


  /// 单独刷新
  Future<void> refreshMemberList(ManageEmployeeConsoleMemberEntity item) async{
    try {
      Map<String, dynamic> reqData = {
        "userId": item.userId,
        "memberId": item.memberId,
      };
      ListResponseEntity<ManageEmployeeConsoleMemberEntity>? list = await AccountConsoleRequest.getEmployeeConsoleMemberList(data: reqData);
      if(list == null) return;
      if((list.datas??[]).isEmpty) return;
       _replaceMemberListItems(list.datas??[]);
    } finally{}
  }

  /// 用返回结果覆盖列表中的对应成员数据
  void _replaceMemberListItems(List<ManageEmployeeConsoleMemberEntity> items) {
    for (final element in items) {
      final int index = memberList.indexWhere((memberItem) {
        return memberItem.userId == element.userId && memberItem.teamId == element.teamId && memberItem.memberId == element.memberId;
      });
      if (index != -1) memberList[index] = element;
    }
  }

  /// 领取巡检
  Future<void> receiveInspection(BuildContext context, ManageEmployeeConsoleMemberEntity item) async{
    if(item.userId == null) return ToastUtils.showToast(text: "userId不能为空");
    bool? askRes = await AskDialog.showUserCancelAsk(
      context: context,
      title: "温馨提示",
      content: "确认领取吗？",
    );
    if(askRes != true) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "userId": item.userId,
      };
      List<ManageEmployeeConsoleMemberEntity>? res = await AccountConsoleRequest.collectInspectionReport(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "领取成功", type: ToastType.success);
      _replaceMemberListItems(res);
      memberList.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }
  
  /// 转交巡检
  Future<void> forwardInspection(BuildContext context, ManageEmployeeConsoleMemberEntity item) async{
    if(item.userId == null) return ToastUtils.showToast(text: "userId不能为空");

    ManagePermissionUserEntity? resAdmin = await ManageSelectChannelUserDialog.show(
      context: context,
      title: "转交巡检·${item.name??''}",
      buttonText: "转交给TA",
    );
    if(resAdmin == null) return;
    if(resAdmin.userId == null) return ToastUtils.showToast(text: "员工userId不能为空");
    
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "userId": item.userId,
        "targetStaffUserId": resAdmin.userId,
      };
      List<ManageEmployeeConsoleMemberEntity>? res = await AccountConsoleRequest.transferForInspection(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "转交成功", type: ToastType.success);
      _replaceMemberListItems(res);
      memberList.refresh();
    } finally{
      ToastUtils.hideLoading();
    }

  }

  /// 关注/取消关注
  Future<void> toggleFollowStaffAccount(BuildContext context, ManageEmployeeConsoleMemberEntity item) async{
    if(!ManageAuthUtils.isAuth(ManageAuthCode.channelStaffAccountFollow)) return;
    if(item.userId == null) return ToastUtils.showToast(text: "userId不能为空");

    final bool isFollowed = item.userRelationDTO?.followed == true;
    final bool nextFollowed = !isFollowed;
    try {
      ToastUtils.showLoading();
      List<ManageEmployeeConsoleMemberEntity>? res = await AccountConsoleRequest.followStaffAccount(
        data: {
          "userId": item.userId,
          "followed": nextFollowed.toString(),
        },
      );
      
      if(res == null) return;
      ToastUtils.showToast(text: nextFollowed ? "已关注" : "已取消关注", type: ToastType.success);
      _replaceMemberListItems(res);
      memberList.refresh();
      
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 查看巡检操作历史
  Future<void> viewInspectionHistory(BuildContext context, ManageEmployeeConsoleMemberEntity item) async{
    await ManageInspectionHistoryDialog.show(context: context, data: item);
  }

  /// 进入学员
  Future<void> enterStudent(BuildContext context, ManageEmployeeConsoleMemberEntity item, {bool isEditBook = false}) async{

    ImpersonateUserEntity? impersonateUser;

    try {
      ToastUtils.showLoading();
      String deviceId = StorageUtil().getString(STORAGE_DEVICE_ID_KEY);
       
      Map<String, dynamic> reqData = {
        "userId": item.userId,
        "teamId": item.teamId,
        "memberId": item.memberId,
        "platform": UserStore.to.profile.platform,
        "platformId": UserStore.to.profile.platformId,
        "deviceId": deviceId,
      };
      impersonateUser = await AccountConsoleRequest.simulateUserLogin(data: reqData);
      if(impersonateUser == null) return;
      
    } finally{
      ToastUtils.hideLoading();
    }

    try {
      List<String> roleApiIds = impersonateUser.roleApiIds??[];
      if(roleApiIds.isEmpty) return ToastUtils.showToast(text: "当前没有权限进入学员");
      
      if(item.userId == null) return ToastUtils.showToast(text: "userId不能为空");
      if(item.memberId == null) return ToastUtils.showToast(text: "memberId不能为空");
      ManageSandboxController.to.start(impersonateUser, item, item.userId!, item.memberId!);
      HttpAuthUtils.instance.setAuthCodes(roleApiIds);

      if(!isEditBook){
        int? todayTaskPageInitTab;
        if(HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseTodayTaskMissionList)){
          todayTaskPageInitTab = 0;
        } else if(HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseMonthSupermemoDaily)){
          todayTaskPageInitTab = 1;
        } else if(HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseMilestoneChallengeOverview)){
          todayTaskPageInitTab = 2;
        }
        if(todayTaskPageInitTab == null){
          closeSimulateLogin();
          return ToastUtils.showToast(text: "无权限");
        } 
        await TagRoutes.toNamed(
          Routes.MISSION_CONTROL_CENTER,
          arguments: {
            "initialTab": todayTaskPageInitTab,
          },
        );
      }else{
        if(impersonateUser.usableCourse?.customId == null){
          closeSimulateLogin();
          return ToastUtils.showToast(text: "课程ID不能为空");
        }
        if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.courseLevelList)){
          closeSimulateLogin();
          return ToastUtils.showToast(text: "无权限");
        }
        await TagRoutes.toNamed(
          Routes.OFFICIAL_COURSE_DETAILS_LEVEL, 
          arguments: {
            "courseId": impersonateUser.usableCourse?.customId,
            "initialMode": OfficialCourseDetailsPageMode.manage,
          },
        );
        
      }
      closeSimulateLogin();
      refreshMemberList(item);
    } finally{
      
    }
  }

  /// 关闭模拟登录
  Future<void> closeSimulateLogin() async{
    ManageSandboxController.to.exit();
    HttpAuthUtils.instance.clearAuthCodes();
    if(!Mqtt5ClientUtils.instance.isConnected){
      // 如果mqtt断掉了 就重新连接
      Mqtt5ClientUtils.instance.initMqtt();
    }
  }

  /// 发送通知
  Future<void> sendNotify(BuildContext context, ManageEmployeeConsoleMemberEntity item) async{
    NotifyTempEntity? resTemp = await ManageSelectNoticeTempDialog.show(
      context: context,
      title: "发送通知·${item.name??''}",
      buttonText: "发送模版通知",
    );
    if(resTemp == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "userId": item.userId,
        "teamId": item.teamId,
        "memberId": item.memberId,
        "templateId": resTemp.uid,
      };
      bool res = await AccountConsoleRequest.sendNotifyTemplate(data: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "发送成功", type: ToastType.success);
      refreshMemberList(item);

    } finally{
      ToastUtils.hideLoading();
    }

  }

  /// 查看工单
  Future<void> viewInspectionTicket(BuildContext context, ManageEmployeeConsoleMemberEntity item) async{
    await ManageInspectionTicketDialog.show(
      context: context,
      data: item,
    );
  }



  @override
  void onClose() {
    ManageSandboxController.to.exit();
    HttpAuthUtils.instance.clearAuthCodes();
    // TODO: 清理逻辑
    super.onClose();
  }
}
