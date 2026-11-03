import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/user_center/common/invite_student_dialog.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/stores/user.dart';
import '../../../../../theme/theme_utils.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../application/controllers/application_controller.dart';
import '../../../elements/elements_detils/controllers/elements_detils_controller.dart';
import '../../../home/controllers/home_controller.dart';
import '../../common/create_student_dialog.dart';
import '../../common/delete_student_dialog.dart';
import '../../controllers/user_center_controller.dart';

class ManageStudentsController extends GetxController {
  final UserStore userStore = UserStore.to;

  /// 最大可购买席位数量
  final RxInt maxBuySeatCount = 0.obs;

  /// 用户可购买的席位数量
  final RxInt currentBuySeatCount = 0.obs;

  /// 用户学员列表
  final RxList<UserTeamEntityMembers> userTeamMembers = <UserTeamEntityMembers>[].obs;

  @override
  void onInit() {
    super.onInit();
    initServiceData();
  }

  Future<void> initServiceData() async {
    try {
      ToastUtils.showLoading();
      await userStore.getUserInfo();
      await getUserTeam();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 获取队伍成员列表
  Future<void> getUserTeam() async {
    UserTeamEntity? team = await UserRequest.getUserTeam();
    if (team == null) return;
    List<UserTeamEntityMembers?> members = team.members ?? [];
    maxBuySeatCount.value = team.maxSize ?? 0;
    currentBuySeatCount.value = team.buySize ?? 0;
    userTeamMembers.clear();
    for (UserTeamEntityMembers? member in members) {
      if (member == null) continue;
      userTeamMembers.add(member);
    }
  }

  Future<void> createStudent(BuildContext context, {UserTeamEntityMembers? data, int? traineeId}) async {
    bool res = await CreateStudentDialog.show(context, editData: data, traineeId: traineeId);
    if (!res) return;

    int teamUserSize = userTeamMembers.where((e) => e.memberId != null).length;

    await initServiceData();
    bool isRegistered = Get.isRegistered<UserCenterController>();
    if (isRegistered) {
      Get.find<UserCenterController>().initServiceData();
    }

    if (teamUserSize == 0) {
      if (userStore.userInfo.value.config?.theme != null) {
        ThemeUtils.changeTheme(userStore.userInfo.value.config!.theme!);
      }
      if(Get.isRegistered<ApplicationController>()){
        await Get.find<ApplicationController>().refreshHomePages();
      }
    }
  }

  /// 复制学员id
  Future<void> copyUserId(int? memberId) async {
    if (memberId == null) return;
    await Clipboard.setData(ClipboardData(text: memberId.toString()));
    ToastUtils.showToast(text: "复制成功", type: ToastType.success);
  }

  Future<void> inviteStudent(BuildContext context) async {
    await InviteStudentDialog.show(context);
  }

  Future<void> deleteStudent(BuildContext context, UserTeamEntityMembers? data) async {
    if (data == null) return;
    if (data.memberId == null) return;

    bool res = await DeleteStudentDialog.show(context, memberId: data.memberId!, nickname: data.nickname);
    if (!res) return;

    bool isCurrentMember = true;
    if (userStore.userInfo.value.memberId != data.memberId) {
      //说明删除的不是当前学员
      isCurrentMember = false;
    }

    try {
      ToastUtils.showLoading();
      bool res2 = await UserRequest.deleteTeamMember(data.memberId!);
      if (!res2) return;
      await getUserTeam();
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);

      if (!isCurrentMember) {
        // 删除的不是当前的学员
        if (Get.isRegistered<UserCenterController>()) {
          Get.find<UserCenterController>().initServiceData();
        }
        return;
      }

      // 说明删除的是当前学员 如果还有其他学员 切换至第一个
      // 过滤出其他学员
      List<UserTeamEntityMembers> otherList = [];
      for (int i = 0; i < userTeamMembers.length; i++) {
        if (userTeamMembers[i].memberId != null) {
          otherList.add(userTeamMembers[i]);
        }
      }
      
      if(otherList.isEmpty) {
        bool res = await userStore.getUserInfo(traineeId: userTeamMembers.first.traineeId);
        if(!res) return;
        getUserTeam();

      }else{
        // 删除之后还有学员 切换至第一个学员
        UserTeamEntityMembers fistMember = otherList.first;
        Map<String, dynamic> reqData = {
          "memberId": fistMember.memberId,
        };
        bool switchRes = await UserRequest.switchStudent(reqData);
        if (!switchRes) return;
      }

      if (Get.isRegistered<UserCenterController>()) {
        await Get.find<UserCenterController>().initServiceData();
      }
      if (userStore.userInfo.value.config?.theme != null) {
        ThemeUtils.changeTheme(userStore.userInfo.value.config!.theme!);
      }
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().initHomeCardList();
      }
      if (Get.isRegistered<ElementsDetilsController>()) {
        Get.find<ElementsDetilsController>().externalRefresh();
      }
      if (Get.isRegistered<ConfigController>()) {
        Get.find<ConfigController>().initConfig();
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 购买席位
  Future<void> buySeat() async {
    dynamic res = await Get.toNamed(
      Routes.OPEN_MEMBER_SETTLEMENT,
      arguments: {
        "isBuySeat": true,
      },
    );
    if (res != true) return;
    await getUserTeam();
  }

  /// 续期学员
  Future<void> renewStudent(UserTeamEntityMembers? data) async {
    if (data?.traineeId == null) return;
    dynamic res = await Get.toNamed(
      Routes.OPEN_MEMBER_SETTLEMENT,
      arguments: {
        "isBuySeat": true,
        "traineeId": data?.traineeId,
      },
    );
    if (res != true) return;
    await getUserTeam();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
