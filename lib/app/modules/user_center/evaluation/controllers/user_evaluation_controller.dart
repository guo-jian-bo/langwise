
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/user_center/common/create_student_dialog.dart';
import 'package:langwise/common/https/pay.dart';
import 'package:langwise/common/https/practice_questions.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/confirm_order_widget.dart';
import 'package:langwise/common/widgets/parent_password_dialog.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/user.dart';
import '../../../../../common/stores/user.dart';
import '../../user_evaluation_level/controllers/user_evaluation_level_controller.dart';
import '../../../../routes/app_pages.dart';

enum UserEvaluationStartPoint {
  zero,
  basic,
  unknown,
}

class UserEvaluationController extends GetxController {
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
  final RxInt gradeIndex = (-1).obs;
  bool isFromEvaResult = false;

  List<int> get totalScoreOptions => const [100, 120, 150];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      isFromEvaResult = Get.arguments['isFromEvaResult'] ?? false;
    }
    loadMemberProfile();
  }

  @override
  void onClose() {
    scoreController.dispose();
    super.onClose();
  }

  Future<void> loadMemberProfile() async {
    try {
      isLoading.value = true;
      final info = await UserRequest.getCurrentMemberInfo();
      if (info == null) {
        currentMember.value = null;
        remainingDays.value = 0;
        birthday.value = "";
        gradeIndex.value = -1;
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

  void onStartFreeEvaluation() async {
    if (startPoint.value == UserEvaluationStartPoint.unknown) {
      ToastUtils.showToast(text: '请选择学习起点');
      return;
    }
    var isZeroBased = startPoint.value == UserEvaluationStartPoint.zero;

    if ((currentMember.value?.grade ?? 0) > 2 && isZeroBased) {
      var res = await AskDialog.showUserAsk(context: Get.context!, title: '温馨提示', content: '确认以零基础作为学习起点吗？');
      if (res) {
        startPoint.value = UserEvaluationStartPoint.zero;
      } else {
        startPoint.value = UserEvaluationStartPoint.basic;
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

    if (!isFromEvaResult) {
      PracticeQuestionsReqest.startToAssessment(Get.context!, isFromEvaResult: isFromEvaResult, data: data);
      return;
    }

    var res = await PracticeQuestionsReqest.getStartAssessmentAiData(data);
    if (res == null) return;
    if (res.status == "assessed") {
      final hasLevel = AppPages.history.contains(Routes.USER_EVALUATION_LEVEL);
      if (hasLevel) {
        if (Get.isRegistered<UserEvaluationLevelController>()) {
          Get.find<UserEvaluationLevelController>().initData();
        }
        Get.until((route) => route.settings.name == Routes.USER_EVALUATION_LEVEL);
      } else {
        Get.offAndToNamed(Routes.USER_EVALUATION_LEVEL);
      }
    } else {
      Get.offAndToNamed(Routes.PRACTICE_QUESTIONS_EVAL, arguments: {"assessmentId": res.assessmentId, "firstQuestion": res});
    }
  }

  Future<void> onStartPointEvaluation(BuildContext context) async {
    if (startPoint.value == UserEvaluationStartPoint.unknown) {
      ToastUtils.showToast(text: '请选择学习起点');
      return;
    }
    var isZeroBased = startPoint.value == UserEvaluationStartPoint.zero;

    if ((currentMember.value?.grade ?? 0) > 2 && isZeroBased) {
      var res = await AskDialog.showUserAsk(context: Get.context!, title: '温馨提示', content: '确认以零基础作为学习起点吗？');
      if (res) {
        startPoint.value = UserEvaluationStartPoint.zero;
      } else {
        startPoint.value = UserEvaluationStartPoint.basic;
        return;
      }
    }
    pay(context);
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
        var res = await PracticeQuestionsReqest.getStartAssessmentAiData(data);
        if (res == null) return;
        if (res.status == "assessed") {
          final hasLevel = AppPages.history.contains(Routes.USER_EVALUATION_LEVEL);
          if (hasLevel) {
            if (Get.isRegistered<UserEvaluationLevelController>()) {
              Get.find<UserEvaluationLevelController>().initData();
            }
            Get.until((route) => route.settings.name == Routes.USER_EVALUATION_LEVEL);
          } else {
            Get.offAndToNamed(Routes.USER_EVALUATION_LEVEL);
          }
        } else {
          Get.offAndToNamed(Routes.PRACTICE_QUESTIONS_EVAL, arguments: {"assessmentId": res.assessmentId, "firstQuestion": res});
        }
      },
      onRecharge: () async {
        final bool isPwdRight = await ParentPasswordialog.show(context: Get.context!);
        if (!isPwdRight) return;

        /// 跳转至充值乃币页面
        await Get.toNamed(Routes.RECHARGE_NAIBI);
      },
    );
  }

  Future<void> toEditUserProfile(BuildContext context) async {
    bool res = await CreateStudentDialog.show(context,
        editData: UserTeamEntityMembers(
          memberId: currentMember.value?.memberId,
          nickname: currentMember.value?.nickname,
          avatarUrl: currentMember.value?.avatarUrl,
          birthday: currentMember.value?.birthday,
          grade: currentMember.value?.grade.toString(),
          address: currentMember.value?.address,
          addressCode: currentMember.value?.addressCode,
        ));
    if (res) {
      loadMemberProfile();
    }
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
