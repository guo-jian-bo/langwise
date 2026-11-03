import 'dart:io';
import 'package:api/api.dart';
import 'package:langwise/app/modules/membership_card_manage/membership_card_manage_code_manage/models/membership_card_manage_code_manage_model.dart';
import 'package:langwise/app/modules/membership_card_manage/membership_card_manage_agent_dashboard/models/membership_card_manage_agent_dashboard_model.dart';
import 'package:langwise/app/modules/membership_card_manage/membership_card_manage_generate_code/models/membership_card_manage_generate_code_model.dart';
import 'package:langwise/app/modules/membership_card_manage/membership_card_manage_generate_record/models/membership_card_manage_generate_record_model.dart';
import 'package:langwise/app/modules/membership_card_manage/membership_card_manage_rebate_record/models/membership_card_manage_rebate_record_model.dart';
import 'package:langwise/app/modules/membership_card_manage/membership_card_manage_recharge_center/models/membership_card_manage_recharge_center_model.dart';
import 'package:langwise/app/modules/membership_card_manage/membership_card_manage_recharge_record/models/membership_card_manage_recharge_record_model.dart';
import 'package:langwise/app/modules/membership_card_manage/models/membership_card_manage_model.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:wise_http/wise_http.dart';

import '../../app/modules/membership_card_manage/membership_card_manage_rebate_statistics/models/membership_card_manage_rebate_statistics_model.dart';

class MembershipCardCancelActivateEntity {
  final bool? isNewCoupon;
  final String? revokeOrde;
  final String? oldCoupon;
  final String? newCoupon;

  MembershipCardCancelActivateEntity({
    this.isNewCoupon,
    this.revokeOrde,
    this.oldCoupon,
    this.newCoupon,
  });

  factory MembershipCardCancelActivateEntity.fromJson(Map<String, dynamic> json) {
    return MembershipCardCancelActivateEntity(
      isNewCoupon: json['isNewCoupon'] as bool?,
      revokeOrde: json['revokeOrde']?.toString(),
      oldCoupon: json['oldCoupon']?.toString(),
      newCoupon: json['newCoupon']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isNewCoupon': isNewCoupon,
      'revokeOrde': revokeOrde,
      'oldCoupon': oldCoupon,
      'newCoupon': newCoupon,
    };
  }
}

class MembershipCardManageApi {
  /// 会员卡详情
  static Future<ResponseEntity<MembershipCardManageModel>?> membershipCardDetails({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/sales-gent/sales-agent/details",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<MembershipCardManageModel>.fromJson(response, fromJson: MembershipCardManageModel.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// VIP列表
  static Future<ResponseEntity<MembershipCardManageGenerateCodeVIPListEntity>?> vipList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/sales-gent/vip/type",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<MembershipCardManageGenerateCodeVIPListEntity>.fromJson(response, fromJson: MembershipCardManageGenerateCodeVIPListEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 月卡、季卡、年卡...信息列表
  static Future<ResponseEntity<MembershipCardManageGenerateCodeCouponSupplyListEntity>?> couponSupplyList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/sales-gent/coupon-supply/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<MembershipCardManageGenerateCodeCouponSupplyListEntity>.fromJson(response, fromJson: MembershipCardManageGenerateCodeCouponSupplyListEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取当前价格
  static Future<ResponseEntity<MembershipCardManageGenerateCodeSettlementEntity>?> getSettlement({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/sales-gent/settlement",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<MembershipCardManageGenerateCodeSettlementEntity>.fromJson(response, fromJson: MembershipCardManageGenerateCodeSettlementEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 生成卡密
  static Future<ResponseEntity?> generateCode({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/sales-gent/generate/coupon",
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
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 卡密管理列表
  static Future<ResponseEntity<MembershipCardManageCodeManageModelEntity>?> codeManageList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/sales-gent/coupon/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<MembershipCardManageCodeManageModelEntity>.fromJson(response, fromJson: MembershipCardManageCodeManageModelEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 建卡记录列表
  static Future<MembershipCardManageGenerateRecordListEntity?> generateRecordList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/stores/sales-gent/coupon/generate/list",
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
        return null;
      }
      if (responseEntity.data == null) return null;
      return MembershipCardManageGenerateRecordListEntity.fromDynamic(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 充值记录列表
  static Future<MembershipCardManageRechargeRecordListEntity?> rechargeRecordList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/stores/sales-gent/recharge/record/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return MembershipCardManageRechargeRecordListEntity.fromDynamic(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 返点记录列表
  static Future<MembershipCardManageRebateRecordListEntity?> rebateRecordList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/stores/sales-gent/rebate/record/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return MembershipCardManageRebateRecordListEntity.fromDynamic(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 代理商数据看板
  static Future<MembershipCardManageAgentDashboardEntity?> salesAgentDetailsList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/account-console/agents/salesAgentDetailsList",
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
        return null;
      }
      if (responseEntity.data == null) return null;
      return MembershipCardManageAgentDashboardEntity.fromDynamic(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 销毁退款
  static Future<bool> destroyRefund(String? couponCode, Map<String, dynamic>? data) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/sales-gent/failure/order/$couponCode",
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
      if (responseEntity.data == null) return false;
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 撤销激活
  static Future<ResponseEntity<MembershipCardCancelActivateEntity>?> cancelActivate(String? couponCode, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/sales-gent/revoke/order/$couponCode",
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
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<MembershipCardCancelActivateEntity>.fromJson(
        response,
        fromJson: (json) => MembershipCardCancelActivateEntity.fromJson(json),
      );
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 添加备注
  static Future<ResponseEntity?> addNote({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/sales-gent/update/sales/card/remarks",
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
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取统计信息
  static Future<ResponseEntity<MembershipCardManageRebateStatisticsEntity>?> rebateStatistics({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/sales-gent/statistical-rebate",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<MembershipCardManageRebateStatisticsEntity>.fromJson(response, fromJson: MembershipCardManageRebateStatisticsEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 充值中心列表
  static Future<ResponseEntity<MembershipCardManageRechargeCenterEntity>?> rechargeCenterList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/sales-gent/sales-recharge-config-up/list",
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
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<MembershipCardManageRechargeCenterEntity>.fromJson(response, fromJson: MembershipCardManageRechargeCenterEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 代理商设置、修改密码
  static Future<ResponseEntity?> setPassword({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/sales-gent/sales-agent/settings-password",
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
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 代理商校验密码
  static Future<ResponseEntity?> checkPassword(String? password, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    RequestConfig config = RequestConfig(
      requireToken: true,
      requireCache: true,
      parameters: parameters,
      data: data,
    );
    dynamic response = await WiseHttp().request(
      "/accounts/sales-gent/sales-agent/check-password/$password",
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
      return null;
    }

    if (responseEntity.data == null) return null;
    return responseEntity;
  }
}
