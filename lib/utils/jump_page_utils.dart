import 'dart:io';

import 'package:get/get.dart';
import 'package:langwise/app/modules/user_center/user_evaluation_level/controllers/user_evaluation_level_controller.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/camera_macos_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/camera_windows_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/guide_engine/guide_manager.dart';
import 'package:langwise/utils/utils.dart';

import '../app/modules/elements/elements_morpheme_detils/bindings/elements_morpheme_detils_binding.dart';
import '../app/modules/elements/elements_morpheme_detils/views/elements_morpheme_detils_view.dart';
import '../app/modules/elements/elements_phrase_detils/bindings/elements_phrase_detils_binding.dart';
import '../app/modules/elements/elements_phrase_detils/views/elements_phrase_detils_view.dart';
import '../app/modules/elements/elements_sentence_detils/bindings/elements_sentence_detils_binding.dart';
import '../app/modules/elements/elements_sentence_detils/views/elements_sentence_detils_view.dart';
import '../app/modules/elements/elements_word_detils/bindings/elements_word_detils_binding.dart';
import '../app/modules/elements/elements_word_detils/views/elements_word_detils_view.dart';
import '../app/modules/song_mv/controllers/song_mv_controller.dart';
import '../app/routes/routes.dart';
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
      if (Get.isRegistered<UserEvaluationLevelController>()) {
        Get.find<UserEvaluationLevelController>().getAssessmentResultDetail();
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

        // if(Get.context != null){
        //   await AskDialog.showUserAsk(
        //     context: Get.context!,
        //     title: data.title,
        //     content: data.content ?? '',
        //     showLastCountdown: true,
        //     showCancel: false,
        //   );
        // }
        

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
    if (routeCode == AppRoutesCode.enWordDetils) {
      return await jumpEnWordDetils(params);
    } else if (routeCode == AppRoutesCode.enPhraseDetils) {
      return await jumpEnPhraseDetils(params);
    } else if (routeCode == AppRoutesCode.enSentenceDetils) {
      return await jumpEnSentenceDetils(params);
    } else if (routeCode == AppRoutesCode.enMorphemeDetils) {
      return await jumpEnMorphemeDetils(params);
    } else if (routeCode == AppRoutesCode.customCourseManagePhotos) {
      return await jumpCustomCourseManagePhotos(params);
    } else if (routeCode == AppRoutesCode.customCourseShootWords) {
      return await jumpCustomCourseShootWords(params);
    } else if (routeCode == AppRoutesCode.customCourseCheckKnowledge) {
      return await jumpCustomCourseCheckKnowledge(params);
    } else if (routeCode == AppRoutesCode.songMV) {
      List? contents = params?["contents"];
      List<Map<String, dynamic>> contentsList = [];
      if (contents != null) {
        contentsList = contents.map((e) => e as Map<String, dynamic>).toList();
      }
      int? contentId = params?["contentId"];
      String? contentType = params?["contentType"];
      String? type = params?["type"];
      int? typeId = params?["typeId"];
      return await jumpSongMv(
        contents: contentsList,
        contentId: contentId,
        contentType: contentType,
        type: PlayRecordPageType.fromValue(type),
        typeId: typeId,
      );
    } else {
      if (Get.currentRoute == "/$routeCode") {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      return await Get.toNamed("/$routeCode", arguments: params);
    }
  }


  /// 跳转到播放歌曲页面
  static Future<void> jumpSongMv({
    List<Map<String, dynamic>>? contents,
    int? contentId,
    String? contentType,
    bool isReplaceRoute = false,
    int? milliseconds,
    PlayRecordPageType? type,
    int? typeId,
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

  /// 跳转单词详情页面
  /// * params: 单词详情参数 Map<String, dynamic>
  static Future<dynamic> jumpEnWordDetils(Map<String, dynamic>? params) async {
    if (params == null) return;
    int? contentId = params["contentId"];
    if (contentId == null) return;
    return await Get.to(
      ElementsWordDetilsView(tagText: contentId.toString()),
      preventDuplicates: false,
      binding: ElementsWordDetilsBinding(tagText: contentId.toString()),
      arguments: {
        "contentId": contentId,
      },
    );
  }

  /// 跳转短语详情页面
  /// * params: 短语详情参数 Map<String, dynamic>
  static Future<dynamic> jumpEnPhraseDetils(Map<String, dynamic>? params) async {
    if (params == null) return;
    int? contentId = params["contentId"];
    if (contentId == null) return;
    return await Get.to(
      ElementsPhraseDetilsView(tagText: contentId.toString()),
      preventDuplicates: false,
      binding: ElementsPhraseDetilsBinding(tagText: contentId.toString()),
      arguments: {
        "contentId": contentId,
      },
    );
  }

  /// 跳转句子详情页面
  /// * params: 句子详情参数 Map<String, dynamic>
  static Future<dynamic> jumpEnSentenceDetils(Map<String, dynamic>? params) async {
    if (params == null) return;
    int? contentId = params["contentId"];
    if (contentId == null) return;
    return await Get.to(
      ElementsSentenceDetilsView(tagText: contentId.toString()),
      preventDuplicates: false,
      binding: ElementsSentenceDetilsBinding(tagText: contentId.toString()),
      arguments: {
        "contentId": contentId,
      },
    );
  }

  /// 跳转词素详情页面
  /// * params: 词素详情参数 Map<String, dynamic>
  static Future<dynamic> jumpEnMorphemeDetils(Map<String, dynamic>? params) async {
    if (params == null) return;
    String? content = params["content"];
    String? pos = params["pos"];
    if (content == null) return;
    return await Get.to(
      ElementsMorphemeDetilsView(tagText: "$content+$pos"),
      preventDuplicates: false,
      binding: ElementsMorphemeDetilsBinding(tagText: "$content+$pos"),
      arguments: {
        "content": content,
        "pos": pos,
      },
    );
  }

  /// 跳转自定义课程管理照片页面
  static Future<dynamic> jumpCustomCourseManagePhotos(Map<String, dynamic>? params) async {
    return await Get.toNamed(
      Routes.CUSTOM_COURSE_MANAGE_PHOTOS,
      arguments: params,
    );
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
    return await Get.toNamed(
      Routes.CUSTOM_COURSE_SHOOT_WORDS,
      arguments: params,
    );
  }

  /// 跳转自定义课程检查知识点页面
  static Future<dynamic> jumpCustomCourseCheckKnowledge(Map<String, dynamic>? params) async {
    return await Get.toNamed(
      Routes.CUSTOM_COURSE_CHECK_KNOWLEDGE,
      arguments: params,
    );
  }
}
