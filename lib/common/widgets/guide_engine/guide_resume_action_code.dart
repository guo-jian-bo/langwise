
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/tag_routes.dart';

import '../../../app/modules/user_center/controllers/user_center_controller.dart';

/// 🌞任务完成后的行为
class GuideResumeActionCode{
  
  /// 回到用户中心页面 并 重新获取步骤列表 并开始引导
  static const String toUserCenterAndRefreshTask = "toUserCenterAndRefreshTask";

  /// 计划页面 弹出推荐计划
  static const String lastAssessment = "lastAssessment";


  /// 执行相应的事件
  static Future<void> executeAction(String resumeAction) async {
    if (resumeAction == toUserCenterAndRefreshTask) {

      UserCenterController? controller = TagRoutes.findLast<UserCenterController>(Routes.USER_CENTER);
      if(controller == null){
        Get.until((route) => route.settings.name == Routes.APPLICATION);
        TagRoutes.toNamed(Routes.USER_CENTER);
      }else{
        Get.until((route) => route.settings.name == Routes.USER_CENTER);
        controller.initServiceData(isGuide: true);
      }
      
    }
  }

}