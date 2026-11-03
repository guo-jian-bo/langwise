import 'dart:async';

import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../utils/mqtt_utils/mqtt_message_services_code.dart';
import '../../../../utils/utils.dart';
import '../../../routes/tag_routes.dart';
import '../../home/controllers/home_controller.dart';

class LearningSettingStepsController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  LearningSettingStepsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.LEARNING_SETTING_STEPS;

  @override
  String get breadcrumbTitle => "学习计划";


  /// 当前步骤数据
  final Rx<LearningSettingStepEntity> stepData = LearningSettingStepEntity().obs;

  /// 正在AI规划的提示信息
  final RxString reportMessage = "".obs;

  /// 正在AI规划的剩余时间 秒
  final RxInt reportDuration = 0.obs;

  Timer? _reportTimer;


  StreamSubscription<PushMessageServiceEnitiy>? _messageSubscription;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    getPlanGuideStep();

    _messageSubscription = MqttNotificationMessage.instance.listenByCode(
      codes: [MqttMessageServicesCode.assessmentPlanCompleted], 
      whereBackPage: true,
      onData: (value){
        getPlanGuideStep(showLoading: false, autoJumpPlan: true);
      },
    );
  }


  Future<void> getPlanGuideStep({bool showLoading = true, bool autoJumpPlan = false}) async{
    try {
      if(showLoading) ToastUtils.showLoading();
      LearningSettingStepEntity? step = await StudiesRequest.getPlanGuideStep();
      if(step == null) return;
      stepData.value = step;

      if(stepData.value.currentStep == LearningSettingStepsEnum.AI_PLAN){
        reportDuration.value = step.params?['reportDuration'] ?? 0;
        reportMessage.value = step.params?['message'] ?? "";
        startCountdown();
      }

      if(autoJumpPlan){
        if(stepData.value.currentStep == LearningSettingStepsEnum.EDIT_PLAN){
          if(isClosed) return;
          if(Get.currentRoute != Routes.LEARNING_SETTING_STEPS){
            Get.until((route) => route.settings.name == Routes.LEARNING_SETTING_STEPS);
          }
          TagRoutes.offAndToNamed(Routes.STUDY_PLAN);
        }
      }

    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 开始倒计时
  void startCountdown(){
    _reportTimer?.cancel();
    if(reportDuration.value <= 0) return;
    _reportTimer = Timer.periodic(Duration(seconds: 1), (timer){
      reportDuration.value--;
      if(reportDuration.value <= 0){
        getPlanGuideStep(autoJumpPlan: true);
        _reportTimer?.cancel();
      }
    });
  }


  /// subButton 跳转页面
  void subButtonJump(){
    if(stepData.value.subButton?.jump == null) return;
    JumpPageUtils.jumpPage(PushMessageEntity(
      category: JumpPageUtils.userType,
      jump: stepData.value.subButton?.jump,
    ));
  }


  /// Button 跳转页面
  Future<void> buttonJump() async{
    if(stepData.value.button?.jump == null) return;
    await JumpPageUtils.jumpPage(PushMessageEntity(
      category: JumpPageUtils.userType,
      jump: stepData.value.button?.jump,
    ));
    getPlanGuideStep();
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().initHomeCardList();
    }
  }




  @override
  void onClose() {
    _reportTimer?.cancel();
    _messageSubscription?.cancel();
    super.onClose();
  }
}
