import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class AccountConsoleRequest{

  /// 获取管理端权限列表
  static Future<AdminAuthEntity?> getAuthList() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/user/role/admin/auth/tree",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return AdminAuthEntity.fromJson(responseEntity.data);
    } on FormatException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取用户列表
  static Future<ListResponseEntity<ManageUserTableEntity>?> getUserList({Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/user/application/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: ManageUserTableEntity.fromJson);
    } on FormatException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取模版消息类型列表
  static Future<List<NotifyTempTypeEntity>?> getNotifyTempType() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/notify/template/type/all/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      List? list = responseEntity.data;
      if(list == null) return null;
      return list.map((item) => NotifyTempTypeEntity.fromJson(item)).toList();
    } on FormatException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取消息模版列表 NotifyTempEntity
  static Future<ListResponseEntity<NotifyTempEntity>?> getNoticeTempList({Map<String, dynamic>? data, Map<String, dynamic>? params}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        parameters: params,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/notify/template/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: NotifyTempEntity.fromJson);
    } on FormatException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取可发送的消息模版列表
  static Future<GroupNotifyTempEntityEntity?> getNoticeTempSendList({Map<String, dynamic>? data, Map<String, dynamic>? params}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        parameters: params,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/notify/template/sendable/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return GroupNotifyTempEntityEntity.fromJson(responseEntity.data);
    } on FormatException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 消息模版创建
  static Future<NotifyTempEntity?> createNoticeTemp({Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console/notify/template/create",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return NotifyTempEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 消息模版编辑
  static Future<NotifyTempEntity?> editNoticeTemp({required int uid, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console/notify/template/$uid/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return NotifyTempEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除消息模版
  static Future<void> deleteNoticeTemp({required int uid}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console//notify/template/$uid/remove",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return;
      }
      if (responseEntity.data == null) return;
      return;
    } on FormatException catch (_) {
      return;
    } catch (e) {
      return;
    }
  }

  /// 发送模版消息
  static Future<bool> sendNotifyTemplate({Map<String, dynamic>? data, Map<String, dynamic>? params}) async{
    // /notify/template/send
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console/notify/template/send",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 工作人员操作台顶部统计
  static Future<ManageEmployeeConsoleSummaryEntity?> getEmployeeConsoleSummary({Map<String, dynamic>? data, Map<String, dynamic>? params}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console/staff/console/summary",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageEmployeeConsoleSummaryEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 工作人员操作台学员列表
  static Future<ListResponseEntity<ManageEmployeeConsoleMemberEntity>?> getEmployeeConsoleMemberList({Map<String, dynamic>? data, Map<String, dynamic>? params}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console/staff/console/member/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: ManageEmployeeConsoleMemberEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 领取巡检
  static Future<List<ManageEmployeeConsoleMemberEntity>?> collectInspectionReport({Map<String, dynamic>? data, Map<String, dynamic>? params}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console/channel/staff/account/get",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      List? list = responseEntity.data;
      if(list == null) return null;
      return list.map((e) => ManageEmployeeConsoleMemberEntity.fromJson(e)).toList();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 转交巡检
  static Future<List<ManageEmployeeConsoleMemberEntity>?> transferForInspection({Map<String, dynamic>? data, Map<String, dynamic>? params}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console/channel/staff/account/change",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      List? list = responseEntity.data;
      if(list == null) return null;
      return list.map((e) => ManageEmployeeConsoleMemberEntity.fromJson(e)).toList();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<ManageEmployeeConsoleMemberEntity>?>  followStaffAccount({Map<String, dynamic>? data, Map<String, dynamic>? params}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console/channel/staff/account/follow",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      List? list = responseEntity.data;
      if(list == null) return null;

      return list.map((e) => ManageEmployeeConsoleMemberEntity.fromJson(e)).toList();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 巡检操作历史
  static Future<ListResponseEntity<ManageInspectionHistoryEntity>?> getInspectionHistory({Map<String, dynamic>? data, Map<String, dynamic>? params}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console/channel/user/log/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: ManageInspectionHistoryEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 巡检统计列表
  static Future<ManageInspectionStaffAccountEntity?> getInspectionStaffAccountPage({Map<String, dynamic>? data, Map<String, dynamic>? params}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/staff/account/inspection/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageInspectionStaffAccountEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 工作人员巡检记录
  static Future<ListResponseEntity<ManageInspectionHistoryEntity>?> getInspectionStaffLogPage({Map<String, dynamic>? data, Map<String, dynamic>? params}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/staff/account/log/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: ManageInspectionHistoryEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }




  /// 新建渠道
  static Future<ManageChannelEntity?> createChannel({required Map<String, dynamic> data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console/channel/create/v2",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageChannelEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑渠道
  static Future<ManageChannelEntity?> editChannel({required int uid, required Map<String, dynamic> data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console/channel/$uid/edit/v2",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageChannelEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除渠道
  static Future<bool> deleteChannel({required int uid}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console/channel/$uid/remove",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取渠道列表
  static Future<ListResponseEntity<ManageChannelEntity>?> getChannelList({Map<String, dynamic>? data, Map<String, dynamic>? params}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console/channel/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: ManageChannelEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<ManageChannelEntity>?> getUsableChannelAllList() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/usable/all/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      final dynamic data = responseEntity.data;
      if (data is! List) return null;
      return data.whereType<Map<String, dynamic>>().map((e) => ManageChannelEntity.fromJson(e)).toList();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取渠道详情
  static Future<ManageChannelEntity?> getChannelDetail({required int channelUid}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console/channel/$channelUid/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageChannelEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取用户角色列表
  static Future<ListResponseEntity<ManageUserRoleEntity>?> getUserRoleList({Map<String, dynamic>? data, Map<String, dynamic>? params}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/user/role/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: ManageUserRoleEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 查询巡检筛选排序数据
  static Future<ZhenduScriptQueryMetaGroupListEntity?> getEmployeeStorCondition() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/staff/console/member/query/meta/group/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ZhenduScriptQueryMetaGroupListEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 模拟用户登录获取信息
  static Future<ImpersonateUserEntity?> simulateUserLogin({Map<String, dynamic>? data, Map<String, dynamic>? params}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/user/impersonate/member",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ImpersonateUserEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取工单跟进记录列表
  static Future<ListResponseEntity<ManageTicketRecordEntity>?> getTicketRecordList({
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/ticket/record/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: ManageTicketRecordEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 完成工单
  static Future<bool> ticketRecordComplete({
    required int ticketRecordId,
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
  }) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/ticket/record/$ticketRecordId/complete",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 查询工单详情
  static Future<ManageTicketDetailEntity?> getTicketDetail({
    required int ticketRecordId,
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
  }) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/ticket/record/$ticketRecordId/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageTicketDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 工单需要修改
  static Future<bool> modifyTicket({required int uid, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );  
      dynamic response = await WiseHttp().request(
        "/account-console/channel/ticket/record/$uid/revision",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> createUserCourseModule({required Map<String, dynamic> data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/course/user/module/create",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }


  /// 获取渠道协管员列表
  static Future<ListResponseEntity<ManagePermissionUserEntity>?> getManagePermissionUserList({
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/user/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: ManagePermissionUserEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取渠道协管员详情
  static Future<ManagePermissionUserEntity?> getManagePermissionUserDetail({required int userId}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/user/user/$userId/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: {
          "userId": userId,
        },
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManagePermissionUserEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 创建渠道协管员
  static Future<bool> createManagePermissionUser({required Map<String, dynamic> data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/user/create",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 编辑渠道协管员
  static Future<ManagePermissionUserEntity?> editManagePermissionUser({
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/user/user/$userId/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManagePermissionUserEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除渠道协管员
  static Future<bool> deleteManagePermissionUser({required int uid}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/user/role/$uid/remove",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取 assistant 角色列表
  static Future<ListResponseEntity<RoleDtoEntity>?> getRolePages({
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/role/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: RoleDtoEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 新建工单模版
  static Future<bool> createManageTicketTemp({required Map<String, dynamic> data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/ticket/template/create",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

    /// 编辑工单模版
  static Future<ManageTicketTempEntity?> editManageTicketTemp({required int tempId, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/ticket/template/$tempId/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      return ManageTicketTempEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除工单模版
  static Future<bool> deleteManageTicketTemp({required int tempId}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/ticket/template/$tempId/remove",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取工单模版列表
  static Future<ListResponseEntity<ManageTicketTempEntity>?> getManageTicketTempList({
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: params,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/ticket/template/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: ManageTicketTempEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 管理员操作台查询统计
  static Future<ManageInspectionStatisticsEntity?> getManageInspectionStatistics() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/channel/user/console/summary",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageInspectionStatisticsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


}
