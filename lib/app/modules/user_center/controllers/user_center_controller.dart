import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/membership_card_manage/views/membership_card_password_dialog.dart';
import 'package:langwise/app/modules/membership_card_manage/views/set_membership_card_password_dialog.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/guide_engine/guide_engine.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/public_controller/mv_player_global_float_controller.dart';
import '../../../../common/stores/user.dart';
import '../../../../common/values/values.dart';
import '../../../../theme/theme_utils.dart';
import '../../application/controllers/application_controller.dart';
import '../../management/dialog/dialogs.dart';
import '../../../routes/routes_breadcrumb_utils.dart';
import '../../../routes/tag_routes.dart';
import '../common/create_student_dialog.dart';
import '../common/delete_student_dialog.dart';
import '../common/exchange_coupons_dialog.dart';
import 'user_visual_style_controller.dart';

class UserCenterController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  UserCenterController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.USER_CENTER;

  @override
  String get breadcrumbTitle => "用户中心";

  /// 传进来的参数 滚动到指定的区域 0=当前激活的学员
  int? toUserModelIndex;

  final UserStore userStore = UserStore.to;

  late final UserVisualStyleController styleController = Get.find<UserVisualStyleController>(tag: tagText);

  /// 滚动定位控制器
  final AutoScrollController autoScrollController = AutoScrollController();

  /// 联系助教老师widget key
  final RxBool showContactTeacherTipsFlag = false.obs;
  Timer? showContactTeacherTipsTimer;

  /// 卡券tab列表
  final RxList<CouponTabEntity> cardCouponsList = <CouponTabEntity>[].obs;

  /// 语言方言设置 US=美式英语 UK=英式英语
  final RxString currentLanguageDialectCode = "".obs;

  /// 课程播放速度
  final RxDouble playSpeed = 1.0.obs;

  /// 非课程播放速度
  final RxDouble otherPlaySpeed = 1.0.obs;

  final RxString exercisePreference = 'bilingual'.obs;

  final RxString extensionPreference = 'bilingual'.obs;

  /// 语言方言是否展开
  final RxBool languageDialectOpen = false.obs;

  /// 音节划分模式 memory=直观记忆 dictionary=词典标准
  final RxString currentSyllableDivisionCode = "".obs;

  /// 音节划分模式是否展开
  final RxBool syllableDivisionOpen = false.obs;

  /// 最大可购买席位数量
  final RxInt maxBuySeatCount = 0.obs;

  /// 用户可购买的席位数量
  final RxInt currentBuySeatCount = 0.obs;

  /// 用户学员列表
  final RxList<UserTeamEntityMembers> userTeamMembers = <UserTeamEntityMembers>[].obs;

  /// 配置文案
  // final Rx<UserCenterOptionEntity> userCenterOptionData = UserCenterOptionEntity().obs;
  final Rx<UserPreferenceOptionEntity> userPreferenceOptionData = UserPreferenceOptionEntity().obs;

  final RxBool isLoading = true.obs;
  final RxString exercisePreferenceDescription = "".obs;
  final RxString extensionPreferenceDescription = "".obs;
  RxInt isSetAnchor = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      toUserModelIndex = Get.arguments["toUserModelIndex"];
    }
    initServiceData(scrollToModel: true);

    GuideTaskController.to.loadTasks(pageCode: AppRoutesCode.userCenter);
  }

  Future<void> initServiceData({bool showLoading = true, bool scrollToModel = false}) async {
    try {
      if (showLoading) ToastUtils.showLoading();
      await getUserInfo();
      await getCouponTabList();
      await getUserTeam();
      await getUserCenterOption();
      await styleController.getStyleList();
      isLoading.value = false;
      if (scrollToModel) scrollToModelIndex();
      
    } finally {
      if (showLoading) ToastUtils.hideLoading();
    }
    showContactTeacherTips();

    await GuideTaskController.to.start(AppRoutesCode.userCenter);
  }

  Future<void> scrollToModelIndex() async {
    if (toUserModelIndex == null) return;
    await Future.delayed(const Duration(milliseconds: 300));
    autoScrollController.scrollToIndex(
      toUserModelIndex!,
      duration: const Duration(milliseconds: 300),
      preferPosition: AutoScrollPosition.begin,
    );
  }

  /// 帮助与客服
  Future<void> customerService(BuildContext context) async {
    await CustomerServiceDialog.reportCustomer(context);
    GuideTaskController.to.continueGuide(AppRoutesCode.userCenter, GuideWidgetIds.userCenterContactTeacherButton);
  }

  /// 弹出联系助教老师tips
  Future<void> showContactTeacherTips() async {
    /// 联系助教老师 不在提示
    bool notRemindContactTeacher = StorageUtil().getBool(NOT_REMIND_CONTACT_TEACHER_KEY);
    if (notRemindContactTeacher) return;

    /// 联系助教老师 不在提示 设为true
    StorageUtil().setBool(NOT_REMIND_CONTACT_TEACHER_KEY, true);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      showContactTeacherTipsFlag.value = true;

      showContactTeacherTipsTimer = Timer(const Duration(seconds: 5), () {
        showContactTeacherTipsFlag.value = false;
      });
    });
  }

  /// 管理学员
  Future<void> toManageStudents() async {
    await TagRoutes.toNamed(Routes.MANAGE_STUDENTS);
    GuideTaskController.to.continueGuide(AppRoutesCode.userCenter, GuideWidgetIds.userCenterManageStudentButton);
  }

  /// 新建学员
  Future<void> createStudent(BuildContext context, int? traineeId) async {
    bool res = await CreateStudentDialog.show(context, traineeId: traineeId);
    if (!res) return;
    int teamUserSize = userTeamMembers.where((e) => e.memberId != null).length;
    await initServiceData();
    if (teamUserSize == 0) {
      if (userStore.userInfo.value.config?.theme != null) {
        ThemeUtils.changeTheme(userStore.userInfo.value.config!.theme!);
      }

      if (Get.isRegistered<ApplicationController>()) {
        await Get.find<ApplicationController>().refreshHomePages();
      }
    }
  }

  /// 切换学员
  Future<void> switcherStudent(BuildContext context, UserTeamEntityMembers? member) async {
    if (member == null) return;
    if (member.memberId == null) return;
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "要切换 ${member.nickname ?? ''} 来进行学习吗？",
      content: "切换后，学习计划、进度和记录将全部更新为该学员的内容。",
      define: "确认切换",
    );
    if (!askRes) return;

    SwitchStudentsUtils.switchStudent(
      context: context, 
      targetMemberId: member.memberId, 
      targetAvatarUrl: member.avatarUrl, 
      targetName: member.nickname,
      onComplete: () async{
        await initServiceData(showLoading: false);
      },
    );

  }

  /// 编辑学员
  Future<void> editStudent(BuildContext context, UserTeamEntityMembers? member) async {
    bool res = await CreateStudentDialog.show(context, editData: member);
    GuideTaskController.to.continueGuide(AppRoutesCode.userCenter, GuideWidgetIds.userCenterEditActiveStudentInfoButton);
    if (!res) return;
    initServiceData();
    
  }

  Future<void> changeExerciseLanguagePreference(String code) async {
    if (exercisePreference.value == code) return;
    userStore.userInfo.value.config?.exerciseConfig?.translationType = code;
    bool res = await editConfig();
    if (!res) {
      userStore.userInfo.value.config?.exerciseConfig?.translationType = exercisePreference.value;
      return;
    }
    if (Get.isRegistered<ConfigController>()) {
      Get.find<ConfigController>().initConfig();
      getUserInfo();
    }
    exercisePreference.value = code;

    Get.find<ConfigController>().setUserSetting(courseTranslationType: exercisePreference.value);
  }

  Future<void> changeExtensionLanguagePreference(String code) async {
    if (extensionPreference.value == code) return;
    userStore.userInfo.value.config?.extensionConfig?.translationType = code;
    bool res = await editConfig();
    if (!res) {
      userStore.userInfo.value.config?.extensionConfig?.translationType = extensionPreference.value;
      return;
    }
    if (Get.isRegistered<ConfigController>()) {
      Get.find<ConfigController>().initConfig();
      getUserInfo();
    }
    extensionPreference.value = code;
    Get.find<ConfigController>().setUserSetting(expandTranslationType: extensionPreference.value);
  }

  /// 切换英语语言方向
  Future<void> changeLanguageDialect(String code) async {
    // if(!languageDialectOpen.value){
    //   openLanguageDialect(true);
    //   return;
    // }
    if (currentLanguageDialectCode.value == code) return;
    userStore.userInfo.value.config?.national = code;
    bool res = await editConfig();
    if (!res) {
      userStore.userInfo.value.config?.national = currentLanguageDialectCode.value;
      return;
    }
    if (Get.isRegistered<ConfigController>()) {
      Get.find<ConfigController>().initConfig();
    }
    currentLanguageDialectCode.value = code;
  }

  /// 切换课程内播放速度
  Future<void> changePlaySpeed(double? speed) async {
    if (playSpeed.value == speed) return;
    userStore.userInfo.value.config?.exerciseConfig?.playSpeed = speed;
    bool res = await editConfig();
    if (!res) {
      userStore.userInfo.value.config?.exerciseConfig?.playSpeed = playSpeed.value;
      return;
    }
    if (Get.isRegistered<ConfigController>()) {
      Get.find<ConfigController>().initConfig();
    }
    playSpeed.value = speed ?? 1.0;
    Get.find<ConfigController>().setUserSetting(expandAudioSpeed: playSpeed.value);
  }

  /// 切换非课程播放速度
  Future<void> changeOtherPlaySpeed(double? speed) async {
    if (otherPlaySpeed.value == speed) return;
    userStore.userInfo.value.config?.extensionConfig?.playSpeed = speed;
    bool res = await editConfig();
    if (!res) {
      userStore.userInfo.value.config?.extensionConfig?.playSpeed = otherPlaySpeed.value;
      return;
    }
    otherPlaySpeed.value = speed ?? 1.0;
    Get.find<ConfigController>().setUserSetting(expandAudioSpeed: otherPlaySpeed.value);
  }

  /// 展开收起英语方言设置
  void openLanguageDialect(bool value) {
    languageDialectOpen.value = value;
    if (!value) return;
    Future.delayed(const Duration(milliseconds: 210), () {
      autoScrollController.scrollToIndex(
        1,
        duration: const Duration(milliseconds: 300),
        preferPosition: AutoScrollPosition.begin,
      );
    });
  }

  /// 切换音节划分模式
  Future<void> changeSyllableDivision(String code) async {
    // if(!syllableDivisionOpen.value){
    //   openSyllableDivision(true);
    //   return;
    // }
    if (currentSyllableDivisionCode.value == code) return;
    userStore.userInfo.value.config?.syllableType = code;
    bool res = await editConfig();
    if (!res) {
      userStore.userInfo.value.config?.syllableType = currentSyllableDivisionCode.value;
      return;
    }
    currentSyllableDivisionCode.value = code;
  }

  /// 展开收起音节划分模式
  void openSyllableDivision(bool value) {
    syllableDivisionOpen.value = value;
    if (!value) return;
    Future.delayed(const Duration(milliseconds: 210), () {
      autoScrollController.scrollToIndex(
        1,
        duration: const Duration(milliseconds: 300),
        preferPosition: AutoScrollPosition.begin,
      );
    });
  }

  /// 跳转至关于我们
  Future<void> toAboutUs() async {
    await TagRoutes.toNamed(Routes.ABOUT_US);
  }

  /// 设置家长密码
  Future<void> setParentPassword(BuildContext context) async {
    if (!context.mounted) return;
    await SetTeamPasswordDialog.show(context: context, isEdit: userStore.userInfo.value.hasPassword == 1);
    GuideTaskController.to.continueGuide(AppRoutesCode.userCenter, GuideWidgetIds.userCenterResetParentPasswordButton);
  }

  /// 跳转至编辑个人信息
  Future<void> toEditUserProfile() async {
    await TagRoutes.toNamed(Routes.EDIT_USER_PROFILE);
    GuideTaskController.to.continueGuide(AppRoutesCode.userCenter, GuideWidgetIds.userCenterEditInfoButton);
  }

  /// 复制用户id
  Future<void> copyUserId() async {
    if (userStore.userInfo.value.userId == null) return;
    await Clipboard.setData(ClipboardData(text: userStore.userInfo.value.userId?.toString() ?? ""));
    ToastUtils.showToast(text: "复制成功", type: ToastType.success);
  }

  /// 退出登录
  Future<void> signOut(BuildContext context) async {
    bool askRes = await AskDialog.showUserAsk(context: context, title: "温馨提示", content: "您确定要退出此账号吗？");
    if (!askRes) return;
    try {
      ToastUtils.showLoading();
      RoutesBreadcrumbUtils.clearAllBreadcrumb();
      await userStore.onLogout("");
      UmengUtils.signOut();
      MvPlayerGlobalFloatController.to.stop();
    } finally {
      ToastUtils.hideLoading();
    }
    Get.offAllNamed(Routes.SIGN_IN_UP);
  }

  /// 跳转至会员中心
  Future<void> toMemberCenter() async {
    await TagRoutes.toNamed(Routes.MEMBER_CENTER);
    GuideTaskController.to.continueGuide(AppRoutesCode.userCenter, GuideWidgetIds.userCenterUpgradeMemberButton);
  }

  /// 跳转至我的优惠券
  Future<void> toMyCoupons() async {
    await TagRoutes.toNamed(Routes.MY_COUPONS);
    GuideTaskController.to.continueGuide(AppRoutesCode.userCenter, GuideWidgetIds.userCenterCouponButton);
  }


  /// 兑换卡券
  Future<void> toExchangeCoupon(BuildContext context) async {
    bool resCode = await ExchangeCouponsDialog.show(context: context);
    if(!resCode) return;
    initServiceData(showLoading: false);
  }

  /// 跳转至兑换学点页面
  Future<void> toLearningPointPayment(BuildContext context) async {
    bool isPwdRight = await ParentPasswordialog.show(context: context);
    if (!isPwdRight) {
      GuideTaskController.to.stop();
      return;
    }

    await TagRoutes.toNamed(Routes.RECHARGE_POINT);

    GuideTaskController.to.continueGuide(AppRoutesCode.userCenter, GuideWidgetIds.userCenterRechargePointButton);
  }

  /// 跳转至充值乃币页面
  Future<void> toRechargeNaibi(BuildContext context) async {
    bool isPwdRight = await ParentPasswordialog.show(context: context);
    if (!isPwdRight) {
      GuideTaskController.to.stop();
      return;
    }
    await TagRoutes.toNamed(
      Routes.RECHARGE_NAIBI,
      arguments: {
        "pageType": 2,
      },
    );
    GuideTaskController.to.continueGuide(AppRoutesCode.userCenter, GuideWidgetIds.userCenterRechargeCreditButton);
  }

  /// 跳转至学点明细
  Future<void> toLearningPointDetails() async {
    await TagRoutes.toNamed(Routes.LEARNING_POINT_DETAILS);
    GuideTaskController.to.continueGuide(AppRoutesCode.userCenter, GuideWidgetIds.userCenterPointRecordButton);
  }

  /// 跳转至用户评测
  Future<void> toUserEvaluationLevel(BuildContext context) async {
    try {
      ToastUtils.showLoading();
      AssessmentLastResponseEntity? assessmentLastResponseEntity = await PracticeQuestionsReqest.getLastAssessment();
      if (assessmentLastResponseEntity == null) return;

      // 如果assessmentId==null 说明没有评测
      int? assessmentId = assessmentLastResponseEntity.assessmentId;
      if (assessmentId != null) {
        // 说明有评测 那么调用继续评测接口
        bool? askRes = await AskDialog.showUserCancelAsk(
          context: context,
          title: "温馨提示",
          content: "您有未完成的评测，是否继续上次的评测？",
          cancel: "重新开始",
          define: "继续评测",
        );
        if (askRes == null) return; // 点击关闭按钮
        if (!askRes) {
          // 点击取消
          assessmentId = null;
        }
      }

      if (assessmentId == null) { // 没有评测
        TagRoutes.toNamed(Routes.USER_EVALUATION, arguments: {'pageType': 0});
        return;
      }
      TagRoutes.toNamed(
        Routes.PRACTICE_QUESTIONS_EVAL,
        arguments: {
          "assessmentId": assessmentId,
          "pageType": 0,
        },
      );
    } finally{
      ToastUtils.hideLoading();
    }




    GuideTaskController.to.continueGuide(AppRoutesCode.userCenter, GuideWidgetIds.userCenterGoTestButton);
  }

  /// 跳转至用户评测结果页面
  Future<void> toUserEvaluationResult() async {
    await TagRoutes.toNamed(Routes.USER_EVALUATION_LEVEL);
    GuideTaskController.to.continueGuide(AppRoutesCode.userCenter, GuideWidgetIds.userCenterCurrentCefrLevelButton);
  }

  /// 切换主题
  Future<void> changeTheme(String themeKey) async {
    if (userStore.userInfo.value.config?.theme == themeKey) return;
    userStore.userInfo.value.config?.theme = themeKey;
    bool res = await editConfig();
    if (!res) return;
    ThemeUtils.changeTheme(themeKey);
  }

  /// 获取卡券tab列表
  Future<void> getCouponTabList() async {
    try {
      List<CouponTabEntity>? res = await CouponsRequest.getCouponTabList();
      if (res == null) return;
      cardCouponsList.value = res;
    } finally {
    }
  }

  /// 获取用户信息
  Future<void> getUserInfo() async {
    await userStore.getUserInfo(showLoading: false);
    currentLanguageDialectCode.value = userStore.userInfo.value.config?.national ?? "";
    currentSyllableDivisionCode.value = userStore.userInfo.value.config?.syllableType ?? "";
    playSpeed.value = userStore.userInfo.value.config?.exerciseConfig?.playSpeed ?? 1.0;
    otherPlaySpeed.value = userStore.userInfo.value.config?.extensionConfig?.playSpeed ?? 1.0;
    exercisePreference.value = userStore.userInfo.value.config?.exerciseConfig?.translationType ?? "";
    extensionPreference.value = userStore.userInfo.value.config?.extensionConfig?.translationType ?? "";
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
        await initServiceData();
        return;
      }

      // 说明删除的是当前学员 如果还有其他学员 切换至第一个
      // 过滤出其他学员
      List<UserTeamEntityMembers> otherList = [];
      for (int i = 0; i < userTeamMembers.length; i++) {
        if (userTeamMembers[i].memberId != data.memberId) {
          otherList.add(userTeamMembers[i]);
        }
      }

      if (otherList.isNotEmpty) {
        // 删除之后还有学员 切换至第一个学员
        UserTeamEntityMembers fistMember = otherList.first;
        Map<String, dynamic> reqData = {
          "memberId": fistMember.memberId,
        };
        bool switchRes = await UserRequest.switchStudent(reqData);
        if (!switchRes) return;
      }

      await initServiceData();
      if (userStore.userInfo.value.config?.theme != null) {
        ThemeUtils.changeTheme(userStore.userInfo.value.config!.theme!);
      }

      if (Get.isRegistered<ApplicationController>()) {
        await Get.find<ApplicationController>().refreshHomePages();
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 获取配置文案
  Future<void> getUserCenterOption() async {
    UserPreferenceOptionEntity? option = await Get.find<ConfigController>().getUserConfig();
    if (option == null) return;
    userPreferenceOptionData.value = option;
  }

  String getDescription(UserPreferenceExercisePreference preference, bool isStudy) {
    String des = "";
    if (isStudy) {
      preference.definitionDisplayMode!.options!.forEach((element) {
        if (element!.code == exercisePreference.value) {
          des = element.description ?? "";
        }
      });
    } else {
      preference.definitionDisplayMode!.options!.forEach((element) {
        if (element!.code == extensionPreference.value) {
          des = element.description ?? "";
        }
      });
    }

    return des;
  }

  /// 编辑配置
  Future<bool> editConfig() async {
    Map<String, dynamic> data = {
      "national": userStore.userInfo.value.config?.national,
      "syllableType": userStore.userInfo.value.config?.syllableType,
      "imageStyleIds": userStore.userInfo.value.config?.imageStyleIds,
      "theme": userStore.userInfo.value.config?.theme,
      "exerciseConfig": userStore.userInfo.value.config?.exerciseConfig?.toJson(),
      "extensionConfig": userStore.userInfo.value.config?.extensionConfig?.toJson(),
    };
    ToastUtils.showLoading();
    bool res = await UserRequest.editUserTeamMemberConfig(data);
    ToastUtils.hideLoading();
    if (!res) return false;
    // await initServiceData();
    return true;
  }

  /// 跳转至会员卡管理模块
  Future<void> jumpToCardMember(BuildContext context) async {
    if (userStore.userInfo.value.isSalesAgentPassword != true) {
      bool askRes = await AskDialog.showUserAsk(
        context: context,
        title: "温馨提示",
        content: "您还没有设置代理商密码",
        define: "去设置",
      );
      if (!askRes) return;
      bool setPwd = await SetMembershipCardPasswordDialog.show(context: context);
      if (!setPwd) return;
      await TagRoutes.toNamed(Routes.MEMBERSHIP_CARD_MANAGE);
      return;
    }

    final bool isPwdRight = await MembershipCardPasswordDialog.show(context: Get.context!);
    if (!isPwdRight) return;

    await TagRoutes.toNamed(Routes.MEMBERSHIP_CARD_MANAGE);
  }

  /// 设置代理商密码
  Future<void> setMembershipCardPassword(BuildContext context) async {
    SetMembershipCardPasswordDialog.show(
      context: context,
      isEdit: userStore.userInfo.value.isSalesAgentPassword ?? false,
    );
  }

  /// 设置管理员密码
  Future<void> setManagePassword(BuildContext context) async {
    ManagePasswordDialog.showSetPasswordDialog(
      context: context,
      isEdit: userStore.rolePermissions.value.manageHasPassword,
    );
  }


  /// 购买席位
  Future<void> buySeat() async {
    await TagRoutes.toNamed(
      Routes.OPEN_MEMBER_SETTLEMENT,
      arguments: {
        "isBuySeat": true,
      },
    );
  }

  /// 续期学员
  Future<void> renewStudent(UserTeamEntityMembers? data) async {
    if (data?.traineeId == null) return;
    await TagRoutes.toNamed(
      Routes.OPEN_MEMBER_SETTLEMENT,
      arguments: {
        "isBuySeat": true,
        "traineeId": data?.traineeId,
      },
    );
  }

  /// 邀请
  Future<void> toInviter() async {
    if(userStore.rolePermissions.value.userIsReferrer){
      await TagRoutes.toNamed(Routes.INVITATION_LIST);
    }else{
      await TagRoutes.toNamed(Routes.BECOME_INVITER);
    }
    await GuideTaskController.to.continueGuide(
      AppRoutesCode.userCenter,
      GuideWidgetIds.userCenterInviterButton,
    );
  }



  @override
  void onClose() {
    showContactTeacherTipsTimer?.cancel();
    autoScrollController.dispose();
    super.onClose();
  }
}
