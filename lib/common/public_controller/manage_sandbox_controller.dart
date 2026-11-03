
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/modules/management/manage_operations/common/manage_inspection_history_dialog.dart';
import '../../app/modules/management/manage_operations/common/manage_inspection_ticket_dialog.dart';
import '../../app/modules/mission_control_center/controllers/mission_control_center_controller.dart';
import '../../app/modules/official_course_details/official_course_details_level/controllers/official_course_details_level_controller.dart';
import '../../app/modules/official_course_details/official_course_details_level/controllers/official_course_details_page_mode.dart';
import '../../app/modules/user_center/common/exchange_coupons_dialog.dart';
import '../../app/routes/routes.dart';
import '../../app/routes/tag_routes.dart';
import '../../utils/utils.dart';
import '../entities/entities.dart';

/// 管理端沙盒
class ManageSandboxController extends GetxController with WidgetsBindingObserver{
  static ManageSandboxController get to => Get.find<ManageSandboxController>();

  /// 是否正在模拟中
  bool get isSimulate => _simulateUser.value != null && _userPatrol.value != null && _userId.value != null && _memberId.value != null;

  /// 获取当前模拟的用户 userId
  int? get userId => _userId.value;
  /// 获取当前模拟的用户 memberId
  int? get memberId => _memberId.value;
  /// 获取当前模拟用户的 accessToken
  String? get accessToken => _simulateUser.value?.accessToken;
  /// 获取当前模拟用户的 name
  ManageEmployeeConsoleMemberEntity? get userPatrol => _userPatrol.value;

  /// 学员巡检数据
  final Rx<ManageEmployeeConsoleMemberEntity?> _userPatrol = Rx(null);
  /// 要模拟的用户数据
  final Rx<ImpersonateUserEntity?> _simulateUser  = Rx(null);
  /// 当前模拟的用户 userId
  final Rx<int?> _userId = Rx(null);
  /// 当前模拟的用户 memberId
  final Rx<int?> _memberId = Rx(null);

  final Rx<Size> windowSize = Size.zero.obs;

  /// 是否展开菜单
  final RxBool isShowMenu = false.obs;

  /// 是否已经打开工单列表
  bool isShowInspectionTicket = false;
  /// 是否已经查看巡检操作历史
  bool isShowInspectionHistory = false;
  /// 是否已经打开兑换卡券弹窗
  bool isShowExchangeCoupons = false;

  @override
  void onInit() {
    super.onInit(); 
    WidgetsBinding.instance.addObserver(this);
  }


  /// 开始设置沙盒环境
  /// [user] 要模拟的用户数据
  /// [userId] 要模拟的用户 userId
  /// [memberId] 要模拟的用户 memberId
  void start(ImpersonateUserEntity user, ManageEmployeeConsoleMemberEntity patrol, int userId, int memberId) {
    _userPatrol.value = patrol;
    _simulateUser.value = user;
    _userId.value = userId;
    _memberId.value = memberId;
    print("ManageSandboxController ------- 开始模拟沙盒环境: $userId, $memberId");
  }

  /// 退出沙盒环境
  void exit() {
    _userPatrol.value = null;
    _simulateUser.value = null;
    _userId.value = null;
    _memberId.value = null;
    isShowMenu.value = false;
    isShowInspectionTicket = false;
    isShowInspectionHistory = false;
    isShowExchangeCoupons = false;
    print("ManageSandboxController ------- 退出沙盒环境");
  }

  /// 展开/收起菜单
  void toggleMenu() {
    isShowMenu.value = !isShowMenu.value;
  }

  /// 退出学员沙盒环境
  void exitMember() {
    Get.until((route) => route.settings.name == Routes.MANAGE_EMPLOYEE_CONSOLE);
    exit();
  }

  /// 查看工单
  Future<void> viewInspectionTicket() async{
    if(_userPatrol.value == null) return;
    if(Get.context == null) return;
    if(isShowInspectionTicket) return;
    isShowInspectionTicket = true;
    await ManageInspectionTicketDialog.show(
      context: Get.context!,
      data: _userPatrol.value!,
    );
    isShowInspectionTicket = false;
  }

  /// 查看巡检操作历史
  Future<void> viewInspectionHistory() async{
    if(_userPatrol.value == null) return;
    if(Get.context == null) return;
    if(isShowInspectionHistory) return;
    isShowInspectionHistory = true;
    await ManageInspectionHistoryDialog.show(
      context: Get.context!, 
      data: _userPatrol.value!,
    );
    isShowInspectionHistory = false;
  }

  /// 跳转至学习规划页面
  Future<void> navigateToLearningPlan() async{
    // 需要判断是否已经在学习规划页面
    if(Get.currentRoute == Routes.MISSION_CONTROL_CENTER){
      ToastUtils.showToast(text: "当前已经在学习规划页面");
      return;
    }

    int? todayTaskPageInitTab;
    if(HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseTodayTaskMissionList)){
      todayTaskPageInitTab = 0;
    } else if(HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseMonthSupermemoDaily)){
      todayTaskPageInitTab = 1;
    } else if(HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseMilestoneChallengeOverview)){
      todayTaskPageInitTab = 2;
    }
    if(todayTaskPageInitTab == null){
      return ToastUtils.showToast(text: "无权限");
    } 

    MissionControlCenterController? route = TagRoutes.findLast<MissionControlCenterController>(Routes.MISSION_CONTROL_CENTER);
    if(route != null){
      Get.until((route) => route.settings.name == Routes.MISSION_CONTROL_CENTER);
      return;
    }

    await TagRoutes.toNamed(
      Routes.MISSION_CONTROL_CENTER,
      arguments: {
        "initialTab": todayTaskPageInitTab,
      },
    );
  }

  /// 跳转至管理教材页面
  Future<void> navigateToManageTextbook() async{
    if(_simulateUser.value == null) return;
    if(Get.currentRoute == Routes.OFFICIAL_COURSE_DETAILS_LEVEL){
      ToastUtils.showToast(text: "当前已经在管理教材页面");
      return;
    }

    if(_simulateUser.value?.usableCourse?.customId == null){
      return ToastUtils.showToast(text: "课程ID不能为空");
    }
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.courseLevelList)){
      return ToastUtils.showToast(text: "无权限");
    }

    OfficialCourseDetailsLevelController? route = TagRoutes.findLast<OfficialCourseDetailsLevelController>(Routes.OFFICIAL_COURSE_DETAILS_LEVEL);
    if(route != null){
      Get.until((route) => route.settings.name == Routes.OFFICIAL_COURSE_DETAILS_LEVEL);
      return;
    }

    await TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_LEVEL, 
      arguments: {
        "courseId": _simulateUser.value?.usableCourse?.customId,
        "initialMode": OfficialCourseDetailsPageMode.manage,
      },
    );

  }

  /// 兑换卡券
  Future<void> exchangeCoupon() async{

    if(!HttpAuthUtils.instance.isAuths([
      HttpAuthCodes.couponActivateStart,
      HttpAuthCodes.couponActivate,
    ])){
      return ToastUtils.showToast(text: "无权限");
    }

    if(Get.context == null) return;
    if(isShowExchangeCoupons) return;

    isShowExchangeCoupons = true;
    await ExchangeCouponsDialog.show(
      context: Get.context!,
    );
    isShowExchangeCoupons = false;
  }





  @override
  void didChangeMetrics() {
    if(Get.context != null){
      final window = View.of(Get.context!).physicalSize;
      windowSize.value = window;
    }
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
  }

}
