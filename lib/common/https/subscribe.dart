import 'package:api/api.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class SubscribeParams {
  final String genre;
  final String theme;
  SubscribeParams({required this.genre, required this.theme});

  Map<String, dynamic> toJson() {
    return {
      'genre': genre,
      'theme': theme,
    };
  }
}

class SubscribeRequest {
  /// 获取 甄听专栏 列表
  static Future<ListResponseEntity<ManageSubscribeEntity>?> getRevealsList(
      int page, int num,
      {String genre = "", String theme = ""}) async {
    try {
      final RequestConfig config = RequestConfig(
          // 参数为en
          requireToken: true,
          requireCache: true,
          data: SubscribeParams(genre: genre, theme: theme).toJson(),
          parameters: {
            'offset': page,
            'limit': num,
          });

      final dynamic response = await WiseHttp().request(
        '/language-console/content/collection/reveals/contentCollection/list',
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

      return ListResponseEntity<ManageSubscribeEntity>.fromJson(
          responseEntity.data,
          fromJson: ManageSubscribeEntity.fromJson);
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

  /// 管理端：更新专栏推送方式
  /// POST https://api-demo.timelywise.cn/language-console/content/collection/update/pushType
  /// body: {"collectionId": 1, "pushType": "HEAD / TAIL / RANDOM"}
  static Future<ResponseEntity?> updateCollectionPushType({
    required int collectionId,
    required String pushType,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {
          'collectionId': collectionId,
          'pushType': pushType,
        },
      );

      final dynamic response = await WiseHttp().request(
        '/language-console/content/collection/update/pushType',
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
      } else {
        // 后端示例返回：{"code":200,"data":"修改成功"}
        ToastUtils.showManageToast(
          text: responseEntity.data?.toString() ?? '修改成功',
          type: ManageToastType.aiComplete,
        );
      }

      return responseEntity;
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

  /// 用户端专栏详情列表：根据专栏 ID 分页获取具体内容
  /// POST https://api-demo.timelywise.cn/languages/content/collection/reveal/pages
  /// body: {"collectionId": 1}
  static Future<UserRevealDetailsPageEntity?> getRevealDetailsPage({
    required int collectionId,
    required int offset,
    required int limit,
    required int difficulty,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: {
          'offset': offset,
          'limit': limit,
        },
        data: {'collectionId': collectionId, 'difficulty': difficulty},
      );

      final dynamic response = await WiseHttp().request(
        '/languages/content/collection/reveal/pages',
        Method.post,
        data: config.data,
        parameters: config.parameters,
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

      return UserRevealDetailsPageEntity.fromJson(
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

  /// 甄听筛选/排序元数据
  static Future<ZhenduScriptQueryMetaGroupListEntity?>
      getCollectionQueryMetaGroupList() async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );

      final dynamic response = await WiseHttp().request(
        '/languages/content/collection/query/meta/group/list',
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

  /// 甄听详情列表：通用筛选排序搜索结构
  static Future<UserRevealDetailsPageEntity?> getRevealDetailsPageByQuery({
    required int collectionId,
    required int offset,
    required int limit,
    String? order,
    Map<String, dynamic>? reqData,
  }) async {
    try {
      final Map<String, dynamic> data = <String, dynamic>{
        'collectionId': collectionId,
      };
      if (reqData != null && reqData.isNotEmpty) {
        data.addAll(reqData);
      }

      final Map<String, dynamic> parameters = <String, dynamic>{
        'offset': offset,
        'limit': limit,
      };
      final String sortValue = (order ?? '').trim();
      if (sortValue.isNotEmpty) {
        parameters['order'] = sortValue;
      }

      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );

      final dynamic response = await WiseHttp().request(
        '/languages/content/collection/reveal/pages',
        Method.post,
        data: config.data,
        parameters: config.parameters,
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

      return UserRevealDetailsPageEntity.fromJson(
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

  /// 甄听曲风列表
  /// GET https://api-demo.timelywise.cn/languages/content/collection/reveal_genres/list
  /// 无参数，返回曲风列表实体
  static Future<List<ManageSubscribeGenreEntity>?> getRevealGenresList() async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );

      final dynamic response = await WiseHttp().request(
        '/languages/content/collection/reveal_genres/list',
        Method.post,
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
      final List<ManageSubscribeGenreEntity> result = [];
      for (int i = 0; i < list.length; i++) {
        result.add(ManageSubscribeGenreEntity.fromJson(list[i]));
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

  /// 学员等级接口
  /// GET https://api-demo.timelywise.cn/studies/member/reveal/member/difficulty
  /// 无参数
  static Future<ResponseEntity?> memberDifficulty() async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );

      final dynamic response = await WiseHttp().request(
        '/studies/member/reveal/member/difficulty',
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

      return responseEntity;
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

  /// 用户端更新每日最大推送数量
  /// POST https://api-demo.timelywise.cn/studies/member/reveal/update/daily/pushMax/{number}
  /// path: max 每日最大推送数量
  static Future<ResponseEntity?> userUpdateDailyPushMax({
    required int max,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );

      final dynamic response = await WiseHttp().request(
        '/studies/member/reveal/update/daily/pushMax/$max',
        Method.post,
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
      } else {
        ToastUtils.showManageToast(
          text: '每日推送上限已更新为${max}篇',
          type: ManageToastType.aiComplete,
        );
      }

      return responseEntity;
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

  /// 用户端一键再推一次
  /// POST https://api-demo.timelywise.cn/studies/member/reveal/onceMorePush/{collectionId}
  /// path: number 推送数量
  static Future<ResponseEntity?> userOnceMorePush({
    required int number,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );

      final dynamic response = await WiseHttp().request(
        '/studies/member/reveal/onceMorePush/$number',
        Method.post,
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
      } else {
        ToastUtils.showManageToast(text: '成功推送新文章到任务列表');
      }

      return responseEntity;
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

  /// 用户订阅推送记录
  /// POST https://api-demo.timelywise.cn/studies/member/reveal/push/subscribe/record
  /// body: 无请求体
  /// response 示例：
  /// {
  ///   "code": 200,
  ///   "data": {
  ///     "pushNum": 2,
  ///     "averagePush": 2.0,
  ///     "readNum": 0,
  ///     "averageRead": 0.0,
  ///     "readRate": 0.0,
  ///     "readDetails": [ ... ]
  ///   }
  /// }
  static Future<UserRevealPushRecordEntity?> userRevealPushRecord() async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );

      final dynamic response = await WiseHttp().request(
        '/studies/member/reveal/push/subscribe/record',
        Method.post,
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

      return UserRevealPushRecordEntity.fromJson(
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

  /// 获取 甄听专栏下方搜索栏 列表
  static Future<List<ManageSubscribeGenreEntity>?> getSearchBarList() async {
    try {
      final RequestConfig config = RequestConfig(
        // 如果该接口需要登录，改为 true
        requireToken: true,
        requireCache: true,
      );

      final dynamic response = await WiseHttp().request(
        '/language-console/en/reveals/reveal_genres/list',
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

      final List<ManageSubscribeGenreEntity> result = [];
      for (int i = 0; i < list.length; i++) {
        result.add(ManageSubscribeGenreEntity.fromJson(list[i]));
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

  /// 生成文章
  static Future<GeneralArticleResultEntity?> generalArticle(
      Map<String, dynamic> data) async {
    try {
      Future<dynamic> _request(Map<String, dynamic> body) {
        final RequestConfig config = RequestConfig(
          requireToken: true,
          requireCache: true,
          data: body,
        );
        return WiseHttp().request(
          '/language-console/en/reveals/create',
          Method.post,
          headers: config.headers,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          data: config.data,
        );
      }

      final dynamic response = await _request(data);
      if (response == null) return null;

      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(
            text: responseEntity.message ?? '',
            type: ManageToastType.error,
          );
        }
        return const GeneralArticleResultEntity(success: false);
      }

      final dynamic rawData = responseEntity.data;
      if (rawData is Map<String, dynamic>) {
        final result = GeneralArticleResultEntity.fromJson(rawData);
        if (result.isRepeat == true) {
          final bool? confirmed = await AskDialog.showUserCancelAsk(
            context: Get.context!,
            title: '提示',
            content: result.content ?? '',
            define: '确定',
            cancel: '取消',
          );

          if (confirmed == true) {
            final Map<String, dynamic> retryBody =
                Map<String, dynamic>.from(data);
            retryBody['isRepeat'] = true;
            final dynamic retryResponse = await _request(retryBody);
            if (retryResponse == null) return null;

            final ResponseEntity retryEntity =
                ResponseEntity.fromJson(retryResponse);
            if (retryEntity.code != HttpStatus.ok) {
              if (retryEntity.message != null) {
                ToastUtils.showManageToast(
                  text: retryEntity.message ?? '',
                  type: ManageToastType.error,
                );
              }
              return const GeneralArticleResultEntity(success: false);
            }

            ToastUtils.showManageToast(
              text: '创建成功',
              type: ManageToastType.aiComplete,
            );
            return const GeneralArticleResultEntity(success: true);
          }

          return GeneralArticleResultEntity(
            success: false,
            isRepeat: true,
            content: result.content,
          );
        }
      }

      ToastUtils.showManageToast(
        text: '创建成功',
        type: ManageToastType.aiComplete,
      );
      return const GeneralArticleResultEntity(success: true);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(
        text: e.source.message,
        type: ManageToastType.error,
      );
      return const GeneralArticleResultEntity(success: false);
    } catch (_) {
      return const GeneralArticleResultEntity(success: false);
    }
  }

  /// 编辑甄听文章
  static Future<bool> editReveal(Map<String, dynamic> data) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );

      final dynamic response = await WiseHttp().request(
        '/language-console/en/reveals/edit',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );

      if (response == null) return false;

      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(
            text: responseEntity.message ?? '',
            type: ManageToastType.error,
          );
        }
        return false;
      } else {
        return true;
      }
    } on FormatException catch (e) {
      ToastUtils.showManageToast(
        text: e.source.message,
        type: ManageToastType.error,
      );
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 删除甄听文章
  /// POST /language-console/en/reveals/delect
  /// body: {"contentId": 1, "collectionId": 1}
  static Future<ResponseEntity?> deleteReveal({
    required int contentId,
    int? collectionId,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {
          'contentId': contentId,
          'collectionId': collectionId,
          "contentType": "EN_REVEAL",
        },
      );

      final dynamic response = await WiseHttp().request(
        '/language-console/en/reveals/delect',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
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

      return responseEntity;
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

  /// 更新分组内容
  /// POST https://api-demo.timelywise.cn/language-console/en/reveals/group/update/content
  static Future<int> updateGroupContent(Map<String, dynamic> data) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );

      final dynamic response = await WiseHttp().request(
        '/language-console/en/reveals/group/update/content',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );

      if (response == null) return 0;

      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(
            text: responseEntity.message ?? '',
            type: ManageToastType.error,
          );
        }
        return 0;
      } else {
        ToastUtils.showManageToast(text: '设置成功');
        return 1;
      }
    } on FormatException catch (e) {
      ToastUtils.showManageToast(
        text: e.source.message,
        type: ManageToastType.error,
      );
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// 设置推送时间
  static Future<void> setPushTime(Map<String, dynamic> data) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );

      final dynamic response = await WiseHttp().request(
        '/language-console/en/reveals/update/push/time',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
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
      } else {
        ToastUtils.showManageToast(text: '设置成功');
      }
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

  /// 用户端专栏列表：根据难度 / 曲风 / 主题分页获取内容合集
  /// POST https://api-demo.timelywise.cn/languages/content/collection/reveals/contentCollection/page
  /// body: {"difficulty":1, "genre":"", "theme":""}
  static Future<UserRevealsPageEntity?> getUserRevealsPage({
    String genre = '',
    String theme = '',
    required int offset,
    required int limit,
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
        },
      );

      final dynamic response = await WiseHttp().request(
        '/languages/content/collection/reveals/contentCollection/page',
        Method.post,
        data: config.data,
        parameters: config.parameters,
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

      return UserRevealsPageEntity.fromJson(
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

  /// 用户端订阅 / 取消订阅专栏
  /// POST https://api-demo.timelywise.cn/studies/member/reveal/subscribe
  /// body: {"collectionId":1, "access":"NORMAL / DELETED"}
  static Future<ResponseEntity?> userToggleSubscribe({
    required int collectionId,
    required String access,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {
          'collectionId': collectionId,
          'access': access,
        },
      );

      final dynamic response = await WiseHttp().request(
        '/studies/member/reveal/subscribe',
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
      } else {
        ToastUtils.showManageToast(
          text: responseEntity.data ?? '',
          type: ManageToastType.aiComplete,
        );
      }

      return responseEntity;
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

  /// 用户订阅配置列表
  /// POST https://api-demo.timelywise.cn/studies/member/reveal/subscribe/config
  /// body: 无请求体
  /// response 示例：
  /// {
  ///   "code": 200,
  ///   "data": {
  ///     "pushSubscribeNum": 2,
  ///     "maxPushNum": 10,
  ///     "collectionSubscribe": [
  ///       {"collectionId": 9, "themeZhName": "文化探秘", "collectionPushNum": 2}
  ///     ]
  ///   }
  /// }
  static Future<UserSubscribeConfigEntity?> getUserSubscribeConfig() async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );

      final dynamic response = await WiseHttp().request(
        '/studies/member/reveal/subscribe/config',
        Method.post,
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

      return UserSubscribeConfigEntity.fromJson(
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

  /// 更新专栏封面与详情卡片封面
  /// POST https://api-demo.timelywise.cn/language-console/content/collection/update/avatar
  /// body: {"collectionId": 1, "avatar": "", "taskAvatar": ""}
  static Future<ResponseEntity?> updateCollectionAvatar({
    required int collectionId,
    required String avatar,
    required String taskAvatar,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {
          'collectionId': collectionId,
          'avatar': avatar,
          'taskAvatar': taskAvatar,
        },
      );

      final dynamic response = await WiseHttp().request(
        '/language-console/content/collection/update/avatar',
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

      return responseEntity;
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

  /// 管理端：甄听审核列表
  /// POST https://api-demo.timelywise.cn/language-console/en/reveals/enReveals/review/list
  /// body: {"collectionId": 1}
  static Future<List<RevealReviewItemEntity>?> getRevealReviewList({
    required int collectionId,
    int offset = 0,
    int limit = 100,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        // 如果后面有分页，可恢复 parameters
        // parameters: {
        //   'offset': offset,
        //   'limit': limit,
        // },
        data: {
          'collectionId': collectionId,
        },
      );

      final dynamic response = await WiseHttp().request(
        '/language-console/en/reveals/enReveals/review/list',
        Method.post,
        // parameters: config.parameters,
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

      final Map<String, dynamic> data =
          responseEntity.data as Map<String, dynamic>;
      final List<dynamic>? list = data['list'] as List<dynamic>?;

      if (list == null) return null;

      return list
          .map(
              (e) => RevealReviewItemEntity.fromJson(e as Map<String, dynamic>))
          .toList();
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

  /// 管理端：更新甄听审核状态
  /// POST https://api-demo.timelywise.cn/language-console/en/reveals/review/enReveals/status
  /// body: {"collectionId": 1, "contentId": 1}
  static Future<ResponseEntity?> updateRevealReviewStatus({
    required int collectionId,
    required int contentId,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {
          'collectionId': collectionId,
          'contentId': contentId,
        },
      );

      final dynamic response = await WiseHttp().request(
        '/language-console/en/reveals/review/enReveals/status',
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

      return responseEntity;
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
