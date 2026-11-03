import 'dart:io';

import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/camera_macos_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/camera_windows_custom_curse_dialog.dart';
import 'package:langwise/utils/utils.dart';

import '../app/modules/management/manage_study/manage_book_scan/views/chapter_management.dart';
import '../app/modules/management/utils/utils.dart';
import '../app/modules/song_mv/controllers/song_mv_controller.dart';
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
  static const String system = 'SYSTEM';

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
  static Future<dynamic> jumpPage(PushMessageEntity? data) async {
    if (data == null) return;
    final String? category = data.category;
    if (category == null || category.isEmpty) return;

    final String? code = data.jump?.code;
    if (code == null || code.isEmpty) return;

    final Map<String, dynamic> params = data.jump?.params ?? {};

    if (category == manageType) {
      return await jumpManagePages(code, params);
    } else if (category == userType || category == system) {
      return await jumpUserPages(code, params);
    }
  }

  static Future<dynamic> jumpManagePages(String? routeCode, Map<String, dynamic>? params) async{
    if(routeCode == null) return;
    if(routeCode == Get.currentRoute) return;
    RolePermissionsEntity role = UserStore.to.rolePermissions.value;
    if(!role.userIsAdmin && !role.isReviewers){
      return;
    }

    if(routeCode == AppManageRoutesCode.showChapterManagementDialog){
      return await showChapterManagement(params); // 弹窗 - 教材章节管理
    } else if(routeCode == AppManageRoutesCode.unitKnowledge){
      return await TagRoutes.toNamed(routeCode, arguments: params); // 单元知识点 - 用户端的页面
    }

    if(Get.currentRoute.contains(Routes.MANAGEMENT)){
      return await ManagePageRegistry.jumpTo("${Routes.MANAGEMENT}/$routeCode", arguments: params);
    }

    return await Get.toNamed(
      Routes.MANAGEMENT,
      arguments: {
        "params": params,
        "routeCode": "${Routes.MANAGEMENT}/$routeCode",
      },
    );

  }

  static Future<dynamic> jumpUserPages(String? routeCode, Map<String, dynamic>? params) async {
    if(routeCode == Get.currentRoute) return;
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


  /// 管理端弹出教材章节管理
  static Future<void> showChapterManagement(Map<String, dynamic>? params) async {
    if(Get.context == null) return;
    int? textbookId = params?["textbookId"];
    if(textbookId == null) return;

    await ChapterManagement.show(
      context: Get.context!,
      textbookId: textbookId,
    );
  }






}
