import 'package:api/api.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:wise_http/wise_http.dart';

import '../entities/song_theme_entity.dart';
import '../entities/song_entity.dart';
import '../entities/lock_entity.dart';
import '../entities/zhendu_entity.dart';
import '../../utils/utils.dart';

/// 音乐模块相关网络请求
class MusicRequest {
  /// 英语歌曲主题列表
  /// GET https://api-demo.timelywise.cn/languages/en/song/themes/list
  /// 无参数，返回结构：{ "code": 200, "data": { "list": [ ... ] } }
  /// 这里直接解析为 List<SongThemeEntity>
  static Future<List<SongThemeEntity>?> getSongThemesList() async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );

      final dynamic response = await WiseHttp().request(
        '/languages/en/song/themes/list',
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );

      if (response == null) return null;

      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(
            text: responseEntity.message ?? '',
            type: ManageToastType.error,
          );
        }
        return null;
      }

      if (responseEntity.data == null) return null;
      final List? list = responseEntity.data['list'];
      if (list == null) return null;

      final List<SongThemeEntity> result = [];
      for (int i = 0; i < list.length; i++) {
        result.add(SongThemeEntity.fromJson(list[i] as Map<String, dynamic>));
      }

      return result;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(
        text: e.source.message,
        type: ManageToastType.error,
      );
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 查询当前用户是否已购买歌曲相关的权益（锁信息）
  /// POST https://api-demo.timelywise.cn/studies/member/reveal/is/buy/reveal
  /// body: {}
  /// 返回结构：{"code":200,"data":{...LockEntity...}}
  static Future<LockEntity?> isBuyReveal({required Object data}) async {
    try {
      final RequestConfig config =
          RequestConfig(requireToken: true, requireCache: true, data: data);

      final dynamic response = await WiseHttp().request(
        '/studies/member/reveal/is/buy/reveal',
        Method.post,
        data: config.data,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );

      if (response == null) return null;

      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(
            text: responseEntity.message ?? '',
            type: ManageToastType.error,
          );
        }
        return null;
      }

      if (responseEntity.data == null) {
        return null;
      }

      if (responseEntity.data is Map<String, dynamic>) {
        return LockEntity.fromJson(
          responseEntity.data as Map<String, dynamic>,
        );
      }

      return null;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(
        text: e.source.message,
        type: ManageToastType.error,
      );
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 英语歌曲曲风列表
  /// GET https://api-demo.timelywise.cn/languages/en/song/genres/list
  /// 无参数，返回结构：{ "code": 200, "data": { "list": [ ... ] } }
  /// 这里直接解析为 List<SongGenreEntity>
  static Future<List<SongGenreEntity>?> getSongGenresList() async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );

      final dynamic response = await WiseHttp().request(
        '/languages/en/song/genres/list',
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );

      if (response == null) return null;

      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(
            text: responseEntity.message ?? '',
            type: ManageToastType.error,
          );
        }
        return null;
      }

      if (responseEntity.data == null) return null;
      final List? list = responseEntity.data['list'];
      if (list == null) return null;

      final List<SongGenreEntity> result = [];
      for (int i = 0; i < list.length; i++) {
        result.add(SongGenreEntity.fromJson(list[i] as Map<String, dynamic>));
      }

      return result;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(
        text: e.source.message,
        type: ManageToastType.error,
      );
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 歌曲详情分页列表
  /// POST https://api-demo.timelywise.cn/languages/en/song/pages?offset=0&limit=10
  /// body: {"genre":"", "theme":"", "title":""}
  /// 返回结构：{ "code": 200, "data": { "count": ..., "datas": [ ... ] } }
  /// 这里直接解析为 SongDetailsPageData，方便调用方使用
  static Future<SongDetailsPageData?> getSongDetailsPage({
    required int offset,
    required int limit,
    String genre = '',
    String theme = '',
    String title = '',
    int difficulty = 0,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: {
          'offset': offset,
          'limit': limit,
        },
        data: {
          'genre': genre,
          'theme': theme,
          'title': title,
          'difficulty': difficulty
        },
      );

      final dynamic response = await WiseHttp().request(
        '/languages/en/song/pages',
        Method.post,
        parameters: config.parameters,
        data: config.data,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );

      if (response == null) return null;

      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(
            text: responseEntity.message ?? '',
            type: ManageToastType.error,
          );
        }
        return null;
      }

      if (responseEntity.data == null) return null;
      if (responseEntity.data is! Map<String, dynamic>) return null;

      // 直接把 data 映射为 SongDetailsPageData
      return SongDetailsPageData.fromJson(
        responseEntity.data as Map<String, dynamic>,
      );
    } on FormatException catch (e) {
      ToastUtils.showManageToast(
        text: e.source.message,
        type: ManageToastType.error,
      );
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 歌曲筛选/排序元数据
  static Future<ZhenduScriptQueryMetaGroupListEntity?>
      getSongQueryMetaGroupList() async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );

      final dynamic response = await WiseHttp().request(
        '/languages/en/song/query/meta/group/list',
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );

      if (response == null) return null;

      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(
            text: responseEntity.message ?? '',
            type: ManageToastType.error,
          );
        }
        return null;
      }

      if (responseEntity.data is! Map<String, dynamic>) return null;
      return ZhenduScriptQueryMetaGroupListEntity.fromJson(
        responseEntity.data as Map<String, dynamic>,
      );
    } on FormatException catch (e) {
      ToastUtils.showManageToast(
        text: e.source.message,
        type: ManageToastType.error,
      );
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 新音乐页歌曲详情分页列表
  static Future<SongDetailsPageData?> getSongDetailsPageByQuery({
    required int offset,
    required int limit,
    String? order,
    Map<String, dynamic>? reqData,
  }) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        'offset': offset,
        'limit': limit,
      };
      if ((order ?? '').trim().isNotEmpty) {
        parameters['order'] = order!.trim();
      }

      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: reqData ?? <String, dynamic>{},
      );

      final dynamic response = await WiseHttp().request(
        '/languages/en/song/pages',
        Method.post,
        parameters: config.parameters,
        data: config.data,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );

      if (response == null) return null;

      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(
            text: responseEntity.message ?? '',
            type: ManageToastType.error,
          );
        }
        return null;
      }

      if (responseEntity.data is! Map<String, dynamic>) return null;
      return SongDetailsPageData.fromJson(
        responseEntity.data as Map<String, dynamic>,
      );
    } on FormatException catch (e) {
      ToastUtils.showManageToast(
        text: e.source.message,
        type: ManageToastType.error,
      );
      return null;
    } catch (_) {
      return null;
    }
  }
}
