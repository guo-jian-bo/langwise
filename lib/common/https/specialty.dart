import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class SpecialtyRequest {
  /// 获取首页卡片列表
  static Future<HomeCardEntity?> getHomeCardList() async {
    RequestConfig config = RequestConfig(
      requireToken: true,
    );
    try {
      dynamic response = await WiseHttp().request(
        "/studies/page/card/code/specialty",
        Method.get,
        headers: config.headers,
        requireToken: true,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      HomeCardEntity? homeCardEntity = HomeCardEntity.fromJson(responseEntity.data);
      return homeCardEntity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      return null;
    }
  }

  /// 获取自然拼读课等级列表
  static Future<PhonicsCourseEntity?> getPhonicsCourse(int? courseId) async {
    RequestConfig config = RequestConfig(
      requireToken: true,
    );
    try {
      dynamic response = await WiseHttp().request(
        "/course/course/specialty/phonics/$courseId/level/list",
        Method.get,
        headers: config.headers,
        requireToken: true,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      PhonicsCourseEntity? homeCardEntity = PhonicsCourseEntity.fromJson(responseEntity.data);
      return homeCardEntity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }
}
