import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class StudyAppRequest{

  /// 获取题目数据
  static Future<CourseDirectionExerciseEntity?> getExerciseData({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(requireToken: true, data: data);
      dynamic response = await WiseHttp().request(
        "/studies/member/course/direction/exercise/category/list",
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
      return CourseDirectionExerciseEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 提交写作任务
  static Future<bool> submitWritingTask({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(requireToken: true, data: data);
      dynamic response = await WiseHttp().request(
        "/studies/composition/submit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
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

}