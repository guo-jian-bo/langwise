import 'package:api/entities/config.dart';
import 'package:api/entities/response.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/models/quiz_model.dart';
import 'package:wise_http/wise_http.dart';

import '../models/manage_create_quiz_model.dart';

class ManageCreateQuizRequest {
  /// 题目查重
  static Future<List<QuizModel>?> checkQuizExist(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/check/exist",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      List? list = responseEntity.data;
      if (list == null) return null;
      List<QuizModel> result = [];
      for (var item in list) {
        result.add(QuizModel.fromJson(item));
      }
      return result;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 绑定题目
  static Future<bool> bindQuiz(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/lesson/bind",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 新建题目
  static Future<bool> createQuiz(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 300),
        ),
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/v2/create",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        options: config.options,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 放弃ai生成的题目
  static Future<bool> giveUpAiQuiz(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/operation/batch_exercise_shelf_delete",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 确认ai生成的题目
  static Future<bool> confirmAiQuiz(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/operation/batch_exercise_shelf_on",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 删除ai生成的题目
  static Future<bool> deleteAiQuiz(int recordId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/ai/record/remove/$recordId",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取创建题目的配置信息
  static Future<ManageCreateQuizModel?> getCreateQuizConfig(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/theme/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageCreateQuizModel.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }
}
