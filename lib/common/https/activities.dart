import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class ActivitiesRequest {
  
  /// 查询邀请任务列表
  static Future<BecomeInviterTaskEntity?> getInvitationTaskList({Map<String, dynamic>? parameters, Map<String, dynamic>? reqData}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/activities/task/user/task/list",
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
      BecomeInviterTaskEntity data = BecomeInviterTaskEntity.fromJson(responseEntity.data);
      return data;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }

  }


  /// 获取邀请者可以获得奖励信息
  static Future<InviterRewardsEntity?> getInviterRewardInfo() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/activities/task/load/task/prize",
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
      return InviterRewardsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }



  /// 告诉服务端当前进度
  static Future<bool> referralTaskProgress({Map<String, dynamic>? reqData}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/activities/task/complete",
        Method.post,
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


  /// 成为邀请者
  static Future<bool> referralApply() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/activities/referral/apply",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
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


  /// 邀请发送短信
  static Future<bool> referralSmsSend({Map<String, dynamic>? reqData}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/activities/referral/sms/send",
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

  /// 邀请短信确认
  static Future<bool> referralSmsTokenBind({Map<String, dynamic>? reqData}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/activities/referral/sms/token/bind",
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

  /// 邀请奖励列表
  static Future<ReferralAwardEntity?> getReferralAwardList() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/activities/referral/award/list",
        Method.get,
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
      return ReferralAwardEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 查询邀请规则
  static Future<ReferralRulesEntity?> getReferralRules() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/activities/referral/rule/explain",
        Method.get,
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
      return ReferralRulesEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 领取邀请奖励
  static Future<bool> claimInvitationReward({Map<String, dynamic>? reqData}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/activities/referral/award/claim/referral",
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

  /// 领取vip奖励
  static Future<bool> claimVipReward({Map<String, dynamic>? reqData}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/activities/referral/award/claim/vip",
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