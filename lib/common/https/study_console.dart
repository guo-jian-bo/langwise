import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class StudyConsoleRequest {
  

  /// 获取超级记忆题目列表
  static Future<ListResponseEntity<SuperMemoryExercisesEntity>?> getSuperMemoryExercises(Map<String, dynamic> parameters, Map<String, dynamic> reqData) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/study-console/super/memo/exercise/need/resolve/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<SuperMemoryExercisesEntity>.fromJson(responseEntity.data, fromJson: SuperMemoryExercisesEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 超级记忆编辑
  static Future<SuperMemoryExercisesEntity?> editSuperMemory(Map<String, dynamic> data) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/study-console/super/memo/exercise/need/resolve/edit",
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
      return SuperMemoryExercisesEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  } 


  /// 超记同步
  static Future<bool> syncSuperMemory(Map<String, dynamic> data) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/study-console/super/memo/exercise/need/resolve/auto/sync",
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