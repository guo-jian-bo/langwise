import 'dart:io';

import 'package:get/get.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/camera_macos_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/camera_windows_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/guide_engine/guide_manager.dart';
import 'package:langwise/utils/utils.dart';

import '../app/modules/song_mv/controllers/song_mv_controller.dart';
import '../app/modules/user_center/user_evaluation_level/controllers/user_evaluation_level_controller.dart';
import '../app/routes/routes.dart';
import '../app/routes/tag_routes.dart';
import '../common/entities/entities.dart';
import 'play_record_utils/play_record_utils.dart';

/// 根据消息跳转页面
class JumpPageUtils {
  static const String manageType = "MANAGE";
  static const String userType = "USER";
  static const String taskType = "TASK";
  static const String reward = 'REWARD';

  /// 根据消息跳转页面
  /// * data: 消息数据 Map<String, dynamic>
  /// ```dart
  ///   {
  ///     "code": "manage_level",
  ///     "type": "manage",
  ///     "params": {
  ///       "页面需要的参数": xxx,
  ///     },
  ///   }
  /// ```
  static Future<void> jumpPage(PushMessageEntity? data) async {
    if (data == null) return;
    final String? type = data.category;
    if (type == null || type.isEmpty) return;

    if (data.code == "assessmentPlanCompleted" && Get.currentRoute == Routes.USER_EVALUATION_LEVEL) {
      final userEvaluationLevelControllers = TagRoutes.finds<UserEvaluationLevelController>(Routes.USER_EVALUATION_LEVEL);
      if (userEvaluationLevelControllers.isNotEmpty) {
        for (final c in userEvaluationLevelControllers) {
          c.getAssessmentResultDetail();
        }
      }
      return;
    }

    if (data.module == 'ACTIVITY') {
      if (GuideManager.instance.isGuiding) {
        await GuideManager.instance.loadRemoteTasks();
        return;
      }

      final taskCode = data.code;
      if (type == reward) {
        await AskDialog.showUserAskToast(
          showCancel: false,
          title: data.title,
          content: data.content ?? '',
          blockDuringTransition: true,
        );

      }

      if (taskCode == null || taskCode.trim().isEmpty) {
        await GuideManager.instance.pushMethod();
        return;
      } else {
        await GuideManager.instance.loadRemoteTasks();
      }

      dynamic task;
      for (final t in GuideManager.instance.tasks) {
        if (t.taskId == taskCode) {
          task = t;
          break;
        }
      }
      if (task == null) return;
      if (task.isDone) return;
      await GuideManager.instance.scheduleStartTask(task.taskId);
      return;
    }

    final String? code = data.jump?.code;
    if (code == null || code.isEmpty) return;

    final Map<String, dynamic> params = data.jump?.params ?? {};

    if (type == manageType) {
      
    } else if (type == userType) {
      jumpUserPages(code, params);
    }
  }

  static Future<dynamic> jumpUserPages(String? routeCode, Map<String, dynamic>? params) async {
    if (routeCode == null || routeCode.isEmpty) return;
    if(routeCode == AppRoutesCode.customCourseShootWords) {
      return await jumpCustomCourseShootWords(params);
    } else if (routeCode == AppRoutesCode.songMV) {
      List? contents = params?["contents"];
      List<Map<String, dynamic>> contentsList = [];
      if (contents != null) {
        contentsList = contents.map((e) => e as Map<String, dynamic>).toList();
      }
      int? contentId = params?["contentId"];
      String? contentType = params?["contentType"];
      int? semanticId = params?["semanticId"];
      int? styleId = params?["styleId"];
      String? dialect = params?["dialect"];
      String? type = params?["type"];
      int? typeId = params?["typeId"];
      return await jumpSongMv(
        contents: contentsList,
        contentId: contentId,
        contentType: contentType,
        semanticId: semanticId,
        styleId: styleId,
        dialect: dialect,
        type: PlayRecordPageType.fromValue(type),
        typeId: typeId,
      );
    } else {
      if (Get.currentRoute == "/$routeCode") {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      return await TagRoutes.toNamed("/$routeCode", arguments: params);
    }
  }


  /// 跳转到播放歌曲页面
  static Future<void> jumpSongMv({
    List<Map<String, dynamic>>? contents,
    int? contentId,
    String? contentType,
    int? semanticId,
    int? styleId,
    String? dialect,
    bool isReplaceRoute = false,
    int? milliseconds,
    PlayRecordPageType? type,
    int? typeId,
    String? traceAdminHeader,
  }) async {
    if (contents == null) {
      SongMvController.to.noParam();
      await Get.toNamed(Routes.SONG_MV);
      return;
    }
    try {
      ToastUtils.showLoading();
      await SongMvController.to.setParam(
        contents,
        contentId: contentId,
        contentType: contentType,
        milliseconds: milliseconds,
        type: type?.value,
        typeId: typeId,
        semanticId: semanticId,
        styleId: styleId,
        dialect: dialect,
        traceAdminHeader: traceAdminHeader,
      );
    } finally {
      ToastUtils.hideLoading();
    }
    if (isReplaceRoute) {
      await Get.offNamed(Routes.SONG_MV);
    } else {
      await Get.toNamed(Routes.SONG_MV);
    }
  }


  /// 跳转自定义课程拍摄单词页面
  static Future<dynamic> jumpCustomCourseShootWords(Map<String, dynamic>? params) async {
    bool isCameraPermission = await PermissionUtils.camera(Get.context!);
    if (!isCameraPermission) {
      return;
    }

    //pc端选择摄像头的弹窗
    if (Platform.isMacOS) {
      String? deviceId = await CameraMacOSCustomCurseDialog.show(
        context: Get.context!,
      );
      params?["deviceId"] = deviceId;
    } else if (Platform.isWindows) {
      CameraDescription? cameraDescription = await CameraWindowsCustomCurseDialog.show(
        context: Get.context!,
      );
      params?["cameraDescription"] = cameraDescription;
    }

    // 跳转自定义课程拍摄单词页面
    return await TagRoutes.toNamed(
      Routes.CUSTOM_COURSE_SHOOT_WORDS,
      arguments: params,
    );
  }
}
