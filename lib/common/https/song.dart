import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class SongRequest{


  /// 获取播放知识点列表 没有音频和ass信息
  static Future<SongEntity?> getPlayKnowledgeList(Map<String, dynamic> data) async{
    RequestConfig config = RequestConfig(
      requireToken: true,
      data: data,
    );
    try {
      dynamic response = await WiseHttp().request(
        "/languages/content/list/base/infos", 
        Method.post, 
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code != HttpStatus.ok) return null;
      SongEntity? songEntity = SongEntity.fromJson(responseEntity.data);
      return songEntity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } on DioException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取播放知识点详情
  static Future<SongEntityList?> getPlayKnowledgeInfoList(Map<String, dynamic> parameters) async{
    RequestConfig config = RequestConfig(
      requireToken: true,
      parameters: parameters,
    );
    try {
      dynamic response = await WiseHttp().request(
        "/languages/content/detail/info", 
        Method.get, 
        headers: config.headers,
        requireToken: config.requireToken,
        parameters: config.parameters,
      );
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code != HttpStatus.ok) return null;
      SongEntityList? songEntity = SongEntityList.fromJson(responseEntity.data);
      return songEntity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } on DioException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 上报播放记录
  static Future<bool> reportPlayKnowledgeList(Map<String, dynamic> data) async{
    RequestConfig config = RequestConfig(
      requireToken: true,
      data: data,
    );
    try {
      dynamic response = await WiseHttp().request(
        "/studies/member/content/play/upload", 
        Method.post, 
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if(response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code != HttpStatus.ok) return false;
      return true;
    } on FormatException catch (_) {
      return false;
    } on DioException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }

}