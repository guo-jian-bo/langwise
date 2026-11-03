import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';


class StudiesRequest {
  
  /// 获取用户学习天数
  static Future<LearningStatisticsEntity?> getUserStudyDays({bool showToast = true}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/study/info",
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
      return LearningStatisticsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      if(showToast) ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

}