import 'dart:io';

import 'package:api/api.dart';
import 'package:langwise/app/modules/customized_courses/custom_course_manage_photos/models/custom_course_manage_photos_response_entity.dart';
import 'package:langwise/app/modules/customized_courses/models/customized_courses_difficulty_info_entity.dart';
import 'package:langwise/common/entities/custom_course_book_entity.dart';
import 'package:langwise/common/entities/location.dart';
import 'package:wise_http/wise_http.dart';

import '../../app/modules/customized_courses/custom_course_check_knowledge/models/custom_course_check_knowledge_response_entity.dart';
import '../../utils/utils.dart';
import '../entities/entities.dart';

class CustomizedCoursesRequest {
  /// 查询步骤信息
  static Future<CustomizedCoursesStepsEntity?> getStepsData(
      Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/v2/load/create/status",
        Method.post,
        headers: config.headers,
        requireToken: true,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CustomizedCoursesStepsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 切换课程等级
  static Future<CustomCourseLevelChangeEntity?> changeCourseLevel({required int courseId, required int tier}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: <String, dynamic>{
          'courseId': courseId,
          'tier': tier,
        },
      );
      dynamic response = await WiseHttp().request(
        '/course/user/custom/course/level/change',
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
      return CustomCourseLevelChangeEntity.fromJson((responseEntity.data as Map).cast<String, dynamic>());
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 查询课程信息
  static Future<CustomizedCoursesInfoEntity?> getCourseInfo(
      Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/load/course/level/module/info",
        Method.get,
        headers: config.headers,
        requireToken: true,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CustomizedCoursesInfoEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 查询难度等级
  static Future<CustomizedCoursesDifficultyInfoEntity?>
      getCourseDifficultyInfo() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/course/course/difficulty/level/list",
        Method.get,
        headers: config.headers,
        requireToken: true,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CustomizedCoursesDifficultyInfoEntity.fromJson(
          responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 创建课程
  static Future<CustomizedCoursesCreateEntity?> createCourse(
      Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/create/course/module",
        Method.post,
        headers: config.headers,
        requireToken: true,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CustomizedCoursesCreateEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑等级
  static Future<LevelResponseEntity?> editLevel(
      int levelId, Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
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
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return LevelResponseEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑模块
  static Future<AppCourseModuleResponseEntity?> editModule(
      int moduleId, Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
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
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return AppCourseModuleResponseEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取ISBN信息
  static Future<BookResponseEntity?> getISBNInfo(
      Map<String, dynamic> parameters) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/v2/isbn/info",
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
      return BookResponseEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// AI方式获取教材信息
  static Future<CustomCourseBookListEntity?> getBookInfoWithAI(
      Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/load/isbn/infos",
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
      return CustomCourseBookListEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// ISBN码获取教材信息
  static Future<CustomCourseBookListEntity?> getBookInfoWithISBN(
      int isbn) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/load/isbn/$isbn/info",
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
      return CustomCourseBookListEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 上报没有的教材
  static Future<bool> uploadUnBookInfo(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/upload/isbn/record/${data["recordId"]}",
        Method.post,
        headers: config.headers,
        requireToken: true,
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

  ///根据经纬度获取城市编码
  static Future<LocationResponseEntity?> getCityCode(
      Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/resource/gecode/city",
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
      return LocationResponseEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 上报没有的isbn
  static Future<bool> uploadUnIsbnInfo(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/book/un/found/record",
        Method.post,
        headers: config.headers,
        requireToken: true,
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

  //保存第二条路已拍摄的图片
  static Future<bool> saveCourseImagesList(
      Map<String, dynamic> data, int moduleId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/course/module/$moduleId/page/batch/edit",
        Method.post,
        headers: config.headers,
        requireToken: true,
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

  /// 获取第二条路已拍摄的图片
  static Future<CustomCourseManagePhotosResponseEntity?> getCourseImagesList(
      Map<String, dynamic> data, int moduleId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/course/module/$moduleId/info",
        Method.post,
        headers: config.headers,
        requireToken: true,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CustomCourseManagePhotosResponseEntity.fromJson(
          responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  //重拍第二条路的单词表
  static Future<bool> reshootWordList(int moduleId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: {
          "moduleId": moduleId,
        },
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/book/reshot",
        Method.post,
        headers: config.headers,
        requireToken: true,
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

  //识别第二条路已拍摄的图片
  static Future<bool> recognizeCourseImagesList(int moduleId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/course/module/$moduleId/analysis/page/start",
        Method.post,
        headers: config.headers,
        requireToken: true,
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

  /// 获取第二条路已识别的知识点
  static Future<CustomCourseCheckKnowledgeResponseEntity?> getCourseKnowledges(
      int moduleId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/course/module/$moduleId/knowledge/list",
        Method.get,
        headers: config.headers,
        requireToken: true,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CustomCourseCheckKnowledgeResponseEntity.fromJson(
          responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  //修改第二条路已生成知识点的位置
  static Future<bool> moveKnowledge(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/course/unit/knowledge/order",
        Method.post,
        headers: config.headers,
        requireToken: true,
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

  //第二条路修改单元名称
  static Future<bool> modifyUnitName(
      Map<String, dynamic> data, int unitId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/course/unit/$unitId/edit",
        Method.post,
        headers: config.headers,
        requireToken: true,
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

  //第二条路生成课程
  static Future<bool> generateCourse(int moduleId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/second/generate/course/module/$moduleId",
        Method.post,
        headers: config.headers,
        requireToken: true,
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

  /// 获取自定义课程添加知识点信息 扫码人数 和 大概完成时间 bookId
  static Future<CustomCourseKnowledgeInfoEntity?> getCustomCourseKnowledgeInfo(
      Map<String, dynamic> parameters) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/v2/add/knowledge/info/page",
        Method.get,
        headers: config.headers,
        requireToken: true,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CustomCourseKnowledgeInfoEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取订单id
  static Future<CustomCourseOrderIdsEntity?> getOrderIds() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/course//user/custom/load/product/info",
        Method.get,
        headers: config.headers,
        requireToken: true,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CustomCourseOrderIdsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取ai处理进度
  static Future<CourseGenerateStatusResponseEntity?> getAiProcessStatus(
      Map<String, dynamic> parameters) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/load/generate/status/info",
        Method.get,
        headers: config.headers,
        requireToken: true,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CourseGenerateStatusResponseEntity.fromJson(responseEntity.data);
    } on FormatException catch (_) {
      // ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 用户自定义课程完成
  static Future<bool> customConfirm(Map<String, dynamic> parameters) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/confirm/course/finish",
        Method.post,
        headers: config.headers,
        requireToken: true,
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

  /// 重新生成
  static Future<bool> reGenerateCourse(Map<String, dynamic> parameters) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/course/user/custom/retry/add/knowledge",
        Method.post,
        headers: config.headers,
        requireToken: true,
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
}
