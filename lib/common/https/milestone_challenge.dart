import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class MilestoneChallengeRequest {
  static const String _basePath = '/studies/member/course/milestone/challenge';

  static Future<MilestoneChallengeMetaEntity?> getMeta() async {
    return _requestEntity(
      path: '$_basePath/meta',
      method: Method.get,
      parser: (data) => MilestoneChallengeMetaEntity.fromJson(data),
    );
  }

  static Future<MilestoneChallengeAnalyseEntity?> analyse({
    required String startDate,
    required String endDate,
    required List<MilestoneChallengeDraftSubtaskRequest> subtasks,
  }) async {
    return _requestEntity(
      path: '$_basePath/analyse',
      method: Method.post,
      data: {
        'startDate': startDate,
        'endDate': endDate,
        'subtasks': subtasks.map((item) => item.toJson(includeTargetValue: false)).toList(),
      },
      parser: (data) => MilestoneChallengeAnalyseEntity.fromJson(data),
    );
  }

  static Future<MilestoneChallengeItemEntity?> create(
    MilestoneChallengeCreateRequest request,
  ) async {
    return _requestEntity(
      path: '$_basePath/create',
      method: Method.post,
      data: request.toJson(),
      parser: (data) => MilestoneChallengeItemEntity.fromJson(data),
    );
  }

  static Future<MilestoneChallengeOverviewEntity?> getOverview() async {
    return _requestEntity(
      path: '$_basePath/overview',
      method: Method.post,
      data: const <String, dynamic>{},
      parser: (data) => MilestoneChallengeOverviewEntity.fromJson(data),
    );
  }

  static Future<MilestoneChallengeHistoryEntity?> getHistory() async {
    return _requestEntity(
      path: '$_basePath/history',
      method: Method.get,
      parser: (data) => MilestoneChallengeHistoryEntity.fromJson(data),
    );
  }

  static Future<MilestoneChallengeItemEntity?> getDetail(int uid) async {
    return _requestEntity(
      path: '$_basePath/$uid',
      method: Method.get,
      parser: (data) => MilestoneChallengeItemEntity.fromJson(data),
    );
  }

  static Future<MilestoneChallengeItemEntity?> claim(int uid) async {
    return _requestEntity(
      path: '$_basePath/$uid/claim',
      method: Method.post,
      data: const <String, dynamic>{},
      parser: (data) => MilestoneChallengeItemEntity.fromJson(data),
    );
  }

  static Future<MilestoneChallengeItemEntity?> voidChallenge(int uid) async {
    return _requestEntity(
      path: '$_basePath/$uid/void',
      method: Method.post,
      data: const <String, dynamic>{},
      parser: (data) => MilestoneChallengeItemEntity.fromJson(data),
    );
  }

  static Future<T?> _requestEntity<T>({
    required String path,
    required String method,
    required T Function(Map<String, dynamic> data) parser,
    Map<String, dynamic>? data,
  }) async {
    try {
      final config = RequestConfig(
        requireToken: true,
        data: data,
      );
      final response = await WiseHttp().request(
        path,
        method,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      final responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        final message = responseEntity.message?.toString();
        if ((message ?? '').isNotEmpty) {
          ToastUtils.showToast(text: message!);
        }
        return null;
      }
      if (responseEntity.data == null || responseEntity.data is! Map<String, dynamic>) {
        return null;
      }
      return parser(responseEntity.data as Map<String, dynamic>);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }
}
