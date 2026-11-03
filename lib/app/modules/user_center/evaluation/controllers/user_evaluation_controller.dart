import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/user_center/common/create_student_dialog.dart';
import 'package:langwise/common/https/pay.dart';
import 'package:langwise/common/https/practice_questions.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/confirm_order_widget.dart';
import 'package:langwise/common/widgets/guide_engine/guide_engine.dart';
import 'package:langwise/common/widgets/parent_password_dialog.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/user.dart';
import '../../../../../common/stores/user.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../../../routes/tag_routes.dart';
import '../../../home/controllers/home_controller.dart';
import '../../user_evaluation_level/controllers/user_evaluation_level_controller.dart';

enum UserEvaluationStartPoint {
  zero,
  basic,
  unknown,
}

class UserEvaluationController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  UserEvaluationController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.USER_EVALUATION;

  @override
  String get breadcrumbTitle => "英语水平评测";

  final UserStore userStore = UserStore.to;

  final RxBool isLoading = true.obs;
  final Rxn<CurrentMemberInfoEntity> currentMember = Rxn<CurrentMemberInfoEntity>();

  final Rx<UserEvaluationStartPoint> startPoint = UserEvaluationStartPoint.unknown.obs;

  final TextEditingController scoreController = TextEditingController();
  final RxInt totalScore = 100.obs;

  final RxInt remainingDays = (-1).obs;
  final RxString avatarFile = "".obs;
  final RxString avatarUrl = "".obs;
  final RxString avatarKey = "".obs;
  final RxString address = ''.obs;

  final RxString birthday = "".obs;
  final RxString age = ''.obs;
  final RxString nickName = ''.obs;
  final RxInt gradeIndex = 0.obs;

  List<int> get totalScoreOptions => const [100, 120, 150];

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    loadMemberProfile(isInit: true);
  }

  @override
  void onClose() {
    scoreController.dispose();
    super.onClose();
  }

  Future<void> loadMemberProfile({bool isInit = false}) async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCoursePlanCurrentCourseInfo)) return;
    try {
      isLoading.value = true;
      if(isInit){
        await GuideTaskController.to.loadTasks(pageCode: AppRoutesCode.userEvaluation);
      }

      final info = await UserRequest.getCurrentMemberInfo();
      if (info == null) {
        currentMember.value = null;
        remainingDays.value = 0;
        birthday.value = "";
        gradeIndex.value = 0;
        avatarUrl.value = "";
        age.value = "";
        return;
      }

      currentMember.value = info;
      avatarUrl.value = info.avatarUrl ?? "";
      avatarKey.value = info.avatar ?? '';
      remainingDays.value = info.assessmentFreeDay ?? 0;
      final birthdayDate = DateFormatUtil.tryParseDate(info.birthday ?? "");
      birthday.value = birthdayDate == null ? "" : DateFormatUtil.formatStr(birthdayDate, locale: Get.locale);
      age.value = birthdayDate == null ? '' : calculateAge(birthdayDate).toString();
      nickName.value = info.nickname ?? "";
      gradeIndex.value = min(info.grade ?? 0, 13);
      address.value = info.address ?? "";
    } finally {
      isLoading.value = false;
    }

    if (isInit) {
      Future.delayed(const Duration(milliseconds: 300), () {
        GuideTaskController.to.start(AppRoutesCode.userEvaluation);
      });
    }
  }

  void setStartPoint(UserEvaluationStartPoint v) {
    startPoint.value = v;
  }

  void setTotalScore(int v) {
    totalScore.value = v;
    if ((int.tryParse(scoreController.text) ?? 0) > v) {
      scoreController.text = v.toString();
    }
  }

  void passEvaluation() {
    Get.back();
  }

  // 评测操作
  Future<void> evelRespFun(AssessmentQuizEntity res) async{
    if(res.status != "assessed"){
      await TagRoutes.offAndToNamed(
        Routes.PRACTICE_QUESTIONS_EVAL, 
        arguments: {
          "assessmentId": res.assessmentId, 
          "firstQuestion": res,
        },
      );
      return;
    }

    final homeControllerRegistered = Get.isRegistered<HomeController>();
    if(homeControllerRegistered){
      Get.find<HomeController>().initHomeCardList();
    }

    UserEvaluationLevelController? levelController = TagRoutes.findLast<UserEvaluationLevelController>(Routes.USER_EVALUATION_LEVEL);
    if (levelController != null) {
      Get.until((route) => route.settings.name == Routes.USER_EVALUATION_LEVEL);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        levelController.initData(isGuide: true);
      });

    }else{
      TagRoutes.offAndToNamed(Routes.USER_EVALUATION_LEVEL);
    }
  }

  /// 是否正在评测
  Future<bool> isEvaluatingDoing(BuildContext context) async {
    try {
      ToastUtils.showLoading();
      AssessmentLastResponseEntity? assessmentLastResponseEntity = await PracticeQuestionsReqest.getLastAssessment();
      if (assessmentLastResponseEntity == null) true;
      // 如果assessmentId==null 说明没有评测
      int? assessmentId = assessmentLastResponseEntity?.assessmentId;
      if(assessmentId == null) return true;
      // 说明有评测 那么调用继续评测接口
      bool? askRes = await AskDialog.showUserCancelAsk(
        context: context,
        title: "温馨提示",
        content: "您有未完成的评测，是否继续上次的评测？",
        cancel: "重新开始",
        define: "继续评测",
      );
      if (askRes == null) return false; // 点击关闭按钮
      if (!askRes) {
        // 点击取消 说明要重新评测
        return true;
      }

      TagRoutes.offAndToNamed(
        Routes.PRACTICE_QUESTIONS_EVAL,
        arguments: {
          "assessmentId": assessmentId,
          "pageType": 0,
        },
      );

      return false;

    } finally{
      ToastUtils.hideLoading();
    }
  }

  void onStartFreeEvaluation(BuildContext context) async {
    bool isEvaluating = await isEvaluatingDoing(context);
    if(!isEvaluating) return GuideTaskController.to.stop();


    if (startPoint.value == UserEvaluationStartPoint.unknown) {
      ToastUtils.showToast(text: '请选择学员的英语水平');
      GuideTaskController.to.stop();
      return;
    }
    var isZeroBased = startPoint.value == UserEvaluationStartPoint.zero;

    if (isZeroBased) {

      bool res = await DeleteDialog.show(
        context: Get.context ?? context, 
        title: '确认选择零基础，跳过水平评测',
        subTitle: "未接触过英语或认识单词不多，建议由此开始。",
        content: '注意：选择后将跳过水平评测，将根据学员的年龄和年级进行智能推荐，请正确填写信息。',
        confirmText: '确认',
        showTRClean: false,
      );
      if (res) {
        startPoint.value = UserEvaluationStartPoint.zero;
      } else {
        startPoint.value = UserEvaluationStartPoint.basic;
        GuideTaskController.to.stop();
        return;
      }
    }
    var data = {
      "nickname": currentMember.value?.nickname,
      "avatar": currentMember.value?.avatar,
      "birthday": currentMember.value?.birthday,
      "grade": currentMember.value?.grade,
      "isZeroBased": startPoint.value == UserEvaluationStartPoint.zero,
      "address": currentMember.value?.address,
      "addressCode": currentMember.value?.addressCode,
    };
    if (scoreController.text.isNotEmpty) {
      data["exam"] = {'score': int.parse(scoreController.text), 'total': totalScore.value};
    }

    try {
      ToastUtils.showLoading();
      var res = await PracticeQuestionsReqest.getStartAssessmentAiData(data);
      if (res == null) return GuideTaskController.to.stop();
      GuideTaskController.to.continueGuide(AppRoutesCode.userEvaluation, GuideWidgetIds.userEvaluationStartTestButton);
      evelRespFun(res);
    } finally{
      ToastUtils.hideLoading();
    }
    
  }

  Future<void> onStartPointEvaluation(BuildContext context) async {
    bool isEvaluating = await isEvaluatingDoing(context);
    if(!isEvaluating) return GuideTaskController.to.stop();

    if (startPoint.value == UserEvaluationStartPoint.unknown) {
      ToastUtils.showToast(text: '请选择学员的英语水平');
      GuideTaskController.to.stop();
      return;
    }
    var isZeroBased = startPoint.value == UserEvaluationStartPoint.zero;

    if (isZeroBased) {
      bool res = await DeleteDialog.show(
        context: Get.context ?? context, 
        title: '确认选择零基础，跳过水平评测',
        subTitle: "未接触过英语或认识单词不多，建议由此开始。",
        content: '注意：选择后将跳过水平评测，将根据学员的年龄和年级进行智能推荐，请正确填写信息。',
        confirmText: '确认',
        showTRClean: false,
      );

      // var res = await AskDialog.showUserAsk(
      //   context: Get.context!,
      //   title: '确认选择零基础',
      //   content: '选择后将跳过水平评测，将根据学员的年龄和年级进行智能推荐，请正确填写信息。未接触过英语或认识单词不多，建议由此开始。',
      //   define: "确认",
      // );
      if (!res) {
        startPoint.value = UserEvaluationStartPoint.basic;
        GuideTaskController.to.stop();
        return;
      }
      startPoint.value = UserEvaluationStartPoint.zero;
    }
    await pay(context);
  }

  Future<void> pay(BuildContext context) async {
    // 获取套餐详情
    Map<String, dynamic> packReqData = {
      "servicePackageId": currentMember.value?.assessmentServicePkgId,
      "servicePackageVersion": currentMember.value?.assessmentServicePkgVersion,
      "defaultCoupon": false,
    };
    PackageShopDetailEntity? packageShopDetail = await PayRequest.getPackageShopDetail(packReqData);
    if (packageShopDetail == null) return;
    ConfirmOrderWidgetManager.showC(
      context: context,
      title: '提前开始评测',
      packageShopDetailEntity: packageShopDetail,
      onOk: () async {
        var data = {
          "nickname": currentMember.value?.nickname,
          "avatar": currentMember.value?.avatar,
          "birthday": currentMember.value?.birthday,
          "grade": currentMember.value?.grade,
          "isZeroBased": startPoint.value == UserEvaluationStartPoint.zero,
          "address": currentMember.value?.address,
          "addressCode": currentMember.value?.addressCode,
          "assessmentServicePkgId": currentMember.value?.assessmentServicePkgId,
          "assessmentServicePkgVersion": currentMember.value?.assessmentServicePkgVersion,
        };
        if (scoreController.text.isNotEmpty) {
          data["exam"] = {'score': int.parse(scoreController.text), 'total': totalScore.value};
        }
        try {
          ToastUtils.showLoading();
          var res = await PracticeQuestionsReqest.getStartAssessmentAiData(data);
          if (res == null) return GuideTaskController.to.stop();
          GuideTaskController.to.continueGuide(AppRoutesCode.userEvaluation, GuideWidgetIds.userEvaluationStartTestButton);
          evelRespFun(res);
        } finally{
          ToastUtils.hideLoading();
        }

      },
      onRecharge: () async {
        GuideTaskController.to.stop();
        final bool isPwdRight = await ParentPasswordialog.show(context: Get.context!);
        if (!isPwdRight) return;

        /// 跳转至充值乃币页面
        await TagRoutes.toNamed(Routes.RECHARGE_NAIBI);
      },
    );
  }

  Future<void> toEditUserProfile(BuildContext context) async {
    bool res = await CreateStudentDialog.show(
      context,
      editData: UserTeamEntityMembers(
        memberId: currentMember.value?.memberId,
        nickname: currentMember.value?.nickname,
        avatarUrl: currentMember.value?.avatarUrl,
        birthday: currentMember.value?.birthday,
        grade: currentMember.value?.grade.toString(),
        address: currentMember.value?.address,
        addressCode: currentMember.value?.addressCode,
      ),
    );
    if (res) {
      loadMemberProfile();
    }

    GuideTaskController.to.continueGuide(AppRoutesCode.userEvaluation, GuideWidgetIds.userEvaluationEditStudentInfoButton);
  }

  int calculateAge(DateTime birthDate) {
    final now = DateTime.now();

    int age = now.year - birthDate.year;

    // 如果还没过生日，减去一岁
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }
}
