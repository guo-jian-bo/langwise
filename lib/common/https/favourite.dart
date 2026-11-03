import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class FavouriteRequest {
  //创建听单
  static Future<FavouriteListenEntity?> createListenList({
    required String name,
    required String description,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          'name': name,
          'description': description,
        },
      );
      dynamic response = await WiseHttp().request(
        '/studies/favorite/listens/create',
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
      ToastUtils.showToast(text: '创建成功', type: ToastType.success);
      return FavouriteListenEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

//获取听单列表
  static Future<ListResponseEntity<FavouriteListenEntity>?> getListenListPages({
    int offset = 0,
    int limit = 30,
    String order = '-order',
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: {
          'order': order,
          'offset': offset,
          'limit': limit,
        },
      );
      dynamic response = await WiseHttp().request(
        '/studies/favorite/listens/pages',
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<FavouriteListenEntity>.fromJson(
        responseEntity.data,
        fromJson: (json) => FavouriteListenEntity.fromJson(json),
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

//编辑听单
  static Future<FavouriteListenEntity?> editListenList({
    required int uid,
    required String name,
    required String description,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          'name': name,
          'description': description,
        },
      );
      dynamic response = await WiseHttp().request(
        '/studies/favorite/listens/$uid/edit',
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
      ToastUtils.showToast(text: '修改成功', type: ToastType.success);
      return FavouriteListenEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

//删除听单
  static Future<bool> removeListenList({
    required int uid,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        '/studies/favorite/listens/$uid/remove',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      ToastUtils.showToast(text: '删除成功', type: ToastType.success);
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

//批量删除听单
  static Future<bool> batchRemoveListenList({
    required List<int> uid,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          'uids': uid,
        },
      );
      dynamic response = await WiseHttp().request(
        '/studies/favorite/listens/batch/remove',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      return responseEntity.code == HttpStatus.ok;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

//听单排序
  static Future<bool> sortListenList({
    required int uid,
    required int index,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          'index': index,
        },
      );
      dynamic response = await WiseHttp().request(
        '/studies/favorite/listens/$uid/sort',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      return responseEntity.code == HttpStatus.ok;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

//添加收藏
  static Future<bool> addContent({
    required int playListId,
    required int uid,
    required String type,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          'content': {
            "uid": uid,
            "type": type,
          },
        },
      );
      dynamic response = await WiseHttp().request(
        '/studies/favorite/listens/$playListId/content/add',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      return responseEntity.code == HttpStatus.ok;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

//删除收藏
  static Future<bool> removeContent({
    required int playListId,
    required int uid,
    required String type,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          'content': {
            "uid": uid,
            "type": type,
          },
        },
      );
      dynamic response = await WiseHttp().request(
        '/studies/favorite/listens/$playListId/content/remove',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      return responseEntity.code == HttpStatus.ok;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

//获取听单详情
  static Future<FavouriteListenListDetailEntity?> getListenListDetail({required int playListId, required String type, int offset = 0, int limit = 30}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: {
          'order': '-order',
          'offset': offset,
          'limit': limit,
          'contentType': type,
        },
      );
      dynamic response = await WiseHttp().request(
        '/studies/favorite/listens/$playListId/content/pages',
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return FavouriteListenListDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  ///听单内容排序
  static Future<bool> sortPlayListContent({
    required int playListId,
    required int uid,
    required String type,
    required String index,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          'content': {
            "uid": uid,
            "type": type,
          },
          'index': index,
        },
      );
      dynamic response = await WiseHttp().request(
        '/studies/favorite/listens/$playListId/content/sort',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      return responseEntity.code == HttpStatus.ok;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  ///听单迁移内容
  static Future<bool> moveToPlayList({
    required int playListId,
    required int uid,
    required String type,
    required int targetFavoriteId,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          'content': {
            "uid": uid,
            "type": type,
          },
          'targetFavoriteId': targetFavoriteId,
        },
      );
      dynamic response = await WiseHttp().request(
        '/studies/favorite/listens/$playListId/content/move',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      return responseEntity.code == HttpStatus.ok;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }
}
