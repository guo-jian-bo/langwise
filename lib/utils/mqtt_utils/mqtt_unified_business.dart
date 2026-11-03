



import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/routes.dart';
import '../../common/entities/entities.dart';
import '../../common/widgets/guide_engine/guide_engine.dart';
import '../utils.dart';
import 'mqtt_message_services_code.dart';

/// 统一业务逻辑
class MqttUnifiedBusiness{

  /// 处理task逻辑 TODO
  static Future<void> byTask(PushMessageEntity data) async{
    String? code = data.code;
    if(code == null) return;

    if(code == MqttMessageServicesCode.activateVipCoupon) {
      MqttNotificationToast.showModal(
        messages: [data],
        buttonText: "下一步",
      );
    } else if(code == MqttMessageServicesCode.officialPlanExecuteEvent || code == MqttMessageServicesCode.phonicsPlanExecuteEvent || code == MqttMessageServicesCode.textbookPlanExecuteEvent) {
      await showReward(data);
    }
  }

  /// 完成任务显示奖励
  static Future<void> showReward(PushMessageEntity data) async{
    await MqttNotificationToast.showModal(
      messages: [data],
      buttonText: "我知道了",
      onComplete: () async{
        await handleTaskGuide();
      },
      onCancel: () async{
        await handleTaskGuide();
      },
    );
  }

  /// 处理任务引导逻辑 
  static Future<void> handleTaskGuide() async{
    try {
      ToastUtils.showLoading();
      await GuideTaskController.to.loadNewbieGuideTaskList();
    } finally{
      ToastUtils.hideLoading();
    }
    // 最后一步完成后 判断还有没有未完成的新手引导 如果有 回到首页继续引导
    int uncompletedQuestCount = GuideTaskController.to.getExecutableQuestCount();
    if(uncompletedQuestCount <= 0) return;
    Get.until((route) => route.settings.name == Routes.APPLICATION);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      GuideTaskController.to.showHomeGuide();
    });
  }




}