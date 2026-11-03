
import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class CouponsRequest{

  /// 上传截图
  static Future<bool> uploadScreenshots(Map<String, dynamic> reqData) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/stores/activity/upload/ntt/manage/image",
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

  /// 获取优惠券tab列表
  static Future<List<CouponTabEntity>?> getCouponTabList() async{
     try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/stores/coupon/tabs",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code!= HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message??"");
        return null;
      }
      if(responseEntity.data == null) return null;
      List? list = responseEntity.data['list'];
      if(list == null) return null;
      List<CouponTabEntity> tabList = [];
      for(var item in list){
        tabList.add(CouponTabEntity.fromJson(item));
      }
      return tabList;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取优惠券列表
  static Future<CouponEntity?> getCouponList(Map<String, dynamic> parameters) async{
     try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/stores/coupon/page",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      ).catchError((_){});
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code!= HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message??"");
        return null;
      }
      if(responseEntity.data == null) return null;
      CouponEntity couponEntity = CouponEntity.fromJson(responseEntity.data);
      return couponEntity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  
  /// 转送优惠券发送验证码
  static Future<bool> transferCouponsSendCode(Map<String, dynamic> reqData) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/stores/coupon/transfer/sms/send",
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

  /// 转送优惠券提交
  static Future<bool> transferCouponsSubmit(Map<String, dynamic> reqData) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/stores/coupon/transfer/phone/token",
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

  /// 获取热点活动列表
  static Future<List<HotspotsActivityEntity>?> getHotspotsActivityList() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/stores/activity/hot/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      ).catchError((_){});
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code!= HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message??"");
        return null;
      }
      if(responseEntity.data == null) return null;
      List? list = responseEntity.data['list'];
      if(list == null) return null;
      List<HotspotsActivityEntity> tabList = [];
      for(var item in list){
        tabList.add(HotspotsActivityEntity.fromJson(item));
      }
      return tabList;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// 获取活动提交状态
  static Future<HotspotsActivitySubmitStatuEntity?> getHotspotsActivitySubmitStatus() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/stores/activity/ntt/manage/image",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      ).catchError((_){});
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code!= HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message??"");
        return null;
      }
      if(responseEntity.data == null) return null;
      HotspotsActivitySubmitStatuEntity entity = HotspotsActivitySubmitStatuEntity.fromJson(responseEntity.data);
      return entity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 兑换卡券
  static Future<bool> couponActivate(Map<String, dynamic> reqData) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/stores/coupon/activate",
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

  /// 获取兑换码信息
  static Future<RedemptionCodeInfoEntity?> couponActivateStartInfo(Map<String, dynamic> reqData) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/stores/coupon/activate/start",
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
      return RedemptionCodeInfoEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }
  
  

}