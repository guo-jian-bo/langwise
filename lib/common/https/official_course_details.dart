import 'dart:io';

import 'package:api/api.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class OfficialCourseDetailsRequest {
  /// 获取课程模块课时列表
  static Future<CourseModuleHoursEntity?> getModuleClassHours(
    int? courseId,
    int? levelId,
    int? moduleId, {
    String? styleCode,
    int? mediaMode,
  }) async {
    if (courseId == null || levelId == null || moduleId == null) return null;
    RequestConfig config = RequestConfig(
      requireToken: true,
      parameters: {
        "style": styleCode,
        "mediaMode": mediaMode,
      },
    );
    try {
      dynamic response = await WiseHttp().request(
        "/course/course/$courseId/level/$levelId/module/$moduleId/lesson/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showToast(text: responseEntity.message ?? "");
        }
        return null;
      }
      if (responseEntity.data == null) return null;
      CourseModuleHoursEntity entity = CourseModuleHoursEntity.fromJson(responseEntity.data);
      return entity;
    } on FormatException catch (e) {
      Get.back();
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取课时下的任务
  static Future<LessonTasksEntity?> getLessonTasks(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/course/lesson/mission/exercise",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      LessonTasksEntity entity = LessonTasksEntity.fromJson(responseEntity.data);
      return entity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取单元目标
  static Future<UnitKnowledgePointsEntity?> getUnitTarget(
    int courseId, 
    int moduleId, 
    int unitId, {
      List<String?>? contentTypes,
      String? styleCode,
      int? mediaMode,
    }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: {
          "contentTypes": contentTypes,
          "style": styleCode,
          "mediaMode": mediaMode,
        },
      );
      dynamic response = await WiseHttp().request(
        "/course/course/$courseId/module/$moduleId/unit/$unitId/knowledge/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      UnitKnowledgePointsEntity entity = UnitKnowledgePointsEntity.fromJson(responseEntity.data);
      return entity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取单元剧场列表
  static Future<List<ZhenduScriptEntity>> getUnitScriptList(
    int courseId,
    int moduleId,
    int unitId,
  ) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/course/course/$courseId/module/$moduleId/unit/$unitId/script/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if (response == null) return <ZhenduScriptEntity>[];
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return <ZhenduScriptEntity>[];
      }
      if (responseEntity.data == null) return <ZhenduScriptEntity>[];
      final data = responseEntity.data as Map<String, dynamic>?;
      final list = data?['list'];
      if (list is! List) return <ZhenduScriptEntity>[];
      return list
          .whereType<Map<String, dynamic>>()
          .map(ZhenduScriptEntity.fromJson)
          .toList();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return <ZhenduScriptEntity>[];
    } catch (e) {
      return <ZhenduScriptEntity>[];
    }
  }

  /// 管理端获取单元知识点列表 单元目标
  static Future<UnitKnowledgePointsEntity?> getAdminUnitTarget(int unitId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/knowledge/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      UnitKnowledgePointsEntity entity = UnitKnowledgePointsEntity.fromJson(responseEntity.data);
      return entity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }



  /// 获取自定义课程当前步骤
  static Future<CustomCourseStatusEntity?> getCustomCourseStatus(Map<String, dynamic> parameters) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: {},
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/v3/course/current/status",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      CustomCourseStatusEntity entity = CustomCourseStatusEntity.fromJson(responseEntity.data);
      return entity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑课程
  static Future<bool> editCourse(int courseId, Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/course/$courseId/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      if (responseEntity.data == null) return false;
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 编辑年级
  static Future<bool> editLevel(int levelId, Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/course/level/$levelId/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      if (responseEntity.data == null) return false;
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 切换等级状态
  static Future<bool> levelStatusSwitch(int levelId, Map<String, dynamic> parameters) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/course/level/$levelId/status/switch",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      if (responseEntity.data == null) return false;
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 编辑模块
  static Future<bool> editModule(int moduleId, Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/course/module/$moduleId/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      if (responseEntity.data == null) return false;
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 切换模块状态
  static Future<bool> moduleStatusSwitch(int moduleId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/course/module/$moduleId/status/switch",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      if (responseEntity.data == null) return false;
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 排序
  static Future<bool> sortLevelModule(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/v2/course/order",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      if (responseEntity.data == null) return false;
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取课程信息
  static Future<CustomizedCoursesLMEntity?> getCourseInfo(int courseId) async {
    // /course/user/custom/course/level/module/list/info
    try {
      RequestConfig config = RequestConfig(requireToken: true, requireCache: true, parameters: {
        "courseId": courseId,
      });
      dynamic response = await WiseHttp().request(
        "/course/user/custom/course/level/module/list/info",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      CustomizedCoursesLMEntity entity = CustomizedCoursesLMEntity.fromJson(responseEntity.data);
      return entity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑教材接口
  static Future<CustomizedCoursesLMEntity?> editCourseInfo(int courseId) async {
    try {
      RequestConfig config = RequestConfig(requireToken: true, requireCache: true, parameters: {
        "courseId": courseId,
      });
      dynamic response = await WiseHttp().request(
        "/course/user/custom/v2/course/level/module/list/info",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      CustomizedCoursesLMEntity entity = CustomizedCoursesLMEntity.fromJson(responseEntity.data);
      return entity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 移动教材
  static Future<ResponseEntity?> moveModule({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/v3/course/order",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 课程自动整理
  static Future<ResponseEntity?> autoSort(int courseId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/course/$courseId/autoSort",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 初始化课程
  static Future<CourseLevelEntity?> initCourseInfo() async {
    try {
      RequestConfig config = RequestConfig(requireToken: true, requireCache: true, parameters: {});
      dynamic response = await WiseHttp().request(
        "/course/course/v2/create/initial",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      CourseLevelEntity? entity = CourseLevelEntity.fromJson(responseEntity.data);
      return entity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 新增年级
  static Future<ResponseEntity?> addGrade({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/v2/course/level/create",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getUserCustomCourseProgressLevel(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/course/progress/level",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      dynamic resData = responseEntity.data;
      return resData;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getUserCustomCourseProgressModule(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/course/progress/module",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      dynamic resData = responseEntity.data;
      return resData;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取知识点的价格
  static Future<KnowledgeDownloadInfoEntity?> getKnowledgePrice({Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/resource/download/info/price/preview",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      KnowledgeDownloadInfoEntity entity = KnowledgeDownloadInfoEntity.fromJson(responseEntity.data);
      return entity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取知识点下载信息
  static Future<TodayKnowledgeEntity?> getKnowledgeDownloadInfo({Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/resource/download/info/detail/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      TodayKnowledgeEntity entity = TodayKnowledgeEntity.fromJson(responseEntity.data);
      return entity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  

}
