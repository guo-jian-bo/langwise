import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/activity_console_task_entities.dart';
import '../entities/activity_console_task_complete_entity.dart';
import '../entities/activity_console_task_prize_detail_entity.dart';
import '../entities/activity_console_task_type_entities.dart';
import '../entities/activity_tags_entities.dart';

class ActivityConsoleTaskRequest {
  static Future<ResponseEntity<ActivityConsoleTaskListEntity?>?> list({Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data ?? const <String, dynamic>{},
      );
      dynamic response = await WiseHttp().request(
        '/activity-console/task/list',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        }

        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<ActivityConsoleTaskListEntity?>.fromJson(
        response,
        fromJson: (json) => ActivityConsoleTaskListEntity.fromJson((json as Map).cast<String, dynamic>()),
      );
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseEntity<TaskData?>?> loadUserTaskPrize({required String taskCode}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: const <String, dynamic>{},
      );
      dynamic response = await WiseHttp().request(
        '/activities/task/load/user/task/prize/$taskCode',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        }
        return null;
      }
      return ResponseEntity<TaskData?>.fromJson(
        response,
        fromJson: (json) => TaskData.fromJson((json as Map).cast<String, dynamic>()),
      );
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseEntity<ActivityConsoleTaskListEntity?>?> userTaskList() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: const <String, dynamic>{},
        parameters: {
          "group":"NEWERGUIDE"
        }
      );
      dynamic response = await WiseHttp().request(
        '/activities/task/user/task/list',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        }
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<ActivityConsoleTaskListEntity?>.fromJson(
        response,
        fromJson: (json) => ActivityConsoleTaskListEntity.fromJson((json as Map).cast<String, dynamic>()),
      );
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseEntity<ActivityConsoleTaskTypeListEntity?>?> typeList({Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data ?? const <String, dynamic>{},
      );
      dynamic response = await WiseHttp().request(
        '/activity-console/task/type/list',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        }
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<ActivityConsoleTaskTypeListEntity?>.fromJson(
        response,
        fromJson: (json) => ActivityConsoleTaskTypeListEntity.fromJson((json as Map).cast<String, dynamic>()),
      );
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseEntity<ActivityConsoleTaskCompleteDataEntity?>?> completeStep({
    required String taskCode,
    required String eventType,
    required String stepCode,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: <String, dynamic>{
          'taskCode': taskCode,
          'eventType': eventType,
          'stepCode': stepCode,
        },
      );
      dynamic response = await WiseHttp().request(
        '/activities/task/complete',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        }
        return null;
      }
      return ResponseEntity<ActivityConsoleTaskCompleteDataEntity?>.fromJson(
        response,
        fromJson: (json) => ActivityConsoleTaskCompleteDataEntity.fromJson((json as Map).cast<String, dynamic>()),
      );
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

    static Future<ResponseEntity<ActivityConsoleTaskCompleteDataEntity?>?> forceCompleteStep({
    required String taskCode,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        '/studies/member/course/newie/activity/$taskCode/complete',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        }
        return null;
      }
      return ResponseEntity<ActivityConsoleTaskCompleteDataEntity?>.fromJson(
        response,
        fromJson: (json) => ActivityConsoleTaskCompleteDataEntity.fromJson((json as Map).cast<String, dynamic>()),
      );
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseEntity<ActivityConsoleTaskItem?>?> create({required Map<String, dynamic> data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        '/activity-console/task/create',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        }
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<ActivityConsoleTaskItem?>.fromJson(
        response,
        fromJson: (json) => ActivityConsoleTaskItem.fromJson((json as Map).cast<String, dynamic>()),
      );
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> createGroup(String group, String name, String description) async {
    try {
      RequestConfig config = RequestConfig(requireToken: true, data: {'group': group, 'name': name, 'description': description});
      dynamic response = await WiseHttp().request(
        '/activity-console/task/create/group',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        }
        return false;
      }
      if (responseEntity.data == null) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<TaskGroupList?> fetchGroupList() async {
    try {
      RequestConfig config = RequestConfig(requireToken: true, data: {});
      dynamic response = await WiseHttp().request(
        '/activity-console/task/group/list',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        }
        return null;
      }
      if (responseEntity.data == null) return null;
      return TaskGroupList.fromJson(responseEntity.data);
    } catch (e) {
      return null;
    }
  }

  static Future<List<ActivityTagItemEntity>?> fetchTagList({
    required Map<String, dynamic> data,
  }) async {
    try {
      RequestConfig config = RequestConfig(requireToken: true, data: data);
      dynamic response = await WiseHttp().request(
        '/activity-console/task/group/list',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        }
        return null;
      }
      if (responseEntity.data == null) return null;

      final raw = responseEntity.data;
      final listRaw = raw is Map ? raw['list'] : null;
      if (listRaw is! List) return <ActivityTagItemEntity>[];

      final list = <ActivityTagItemEntity>[];
      for (final e in listRaw) {
        if (e is Map<String, dynamic>) {
          list.add(ActivityTagItemEntity.fromJson(e));
        } else if (e is Map) {
          list.add(ActivityTagItemEntity.fromJson(e.cast<String, dynamic>()));
        }
      }
      return list;
    } catch (e) {
      return null;
    }
  }
}
