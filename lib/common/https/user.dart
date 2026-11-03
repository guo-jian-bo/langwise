
import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class UserRequest{

  /// 获取队伍成员列表
  static Future<UserTeamEntity?> getUserTeam() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/team/member/list/v2",
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
      return UserTeamEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  } 

  /// 获取当前学员信息
  static Future<CurrentMemberInfoEntity?> getCurrentMemberInfo() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/team/member/current/info",
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
      return CurrentMemberInfoEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 创建队伍成员
  static Future<bool> createTeamMember(Map<String, dynamic> data) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/team/member/create",
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

  /// 获取用户偏好配置（语言、练习、拓展、主题）
  static Future<UserPreferenceOptionEntity?> getUserPreferenceOption() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/member/config/option/list",
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
      return UserPreferenceOptionEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 切换学员
  static Future<bool> switchStudent(Map<String, dynamic> data) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/team/member/switch",
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

  /// 编辑队伍学员信息
  static Future<bool> editTeamStudent(Map<String, dynamic> data, int memberId) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/team/member/$memberId/edit/info",
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

  /// 编辑当前用户学员信息
  static Future<bool> editUserTeamMemberConfig(Map<String, dynamic> data) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/team/member/config/edit",
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

  /// 删除队伍学员
  static Future<bool> deleteTeamMember(int memberId) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {
          "memberId": memberId,
        },
      );
      dynamic response = await WiseHttp().request(
        "/accounts/team/member/remove",
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

  /// 获取个人中心页面的配置文案信息
  static Future<UserCenterOptionEntity?> getUserCenterOption() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/config/option/list",
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
      return UserCenterOptionEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑用户信息
  static Future<bool> editUserInfo(Map<String, dynamic> data) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/edit/info",
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

  /// 获取图片风格列表
  static Future<VisualStyleEntity?> getVisualStyleList() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/image/style/rights",
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
      return VisualStyleEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取最新版本号
  static Future<AppCheckEntity?> getAppLastVersion(String type, {String? version, String? appChannel}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: {
          "version": version,
          "channel": appChannel,
        },
      );
      dynamic response = await WiseHttp().request(
        "/versionary/app/version/last/version/$type",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) {}
      return AppCheckEntity.fromJson(responseEntity.data);
    } on FormatException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 设置家长密码发送验证码
  static Future<bool> setParentPasswordSendSmsCode(Map<String, dynamic> parameters) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/stores/team/reset/password/sms/send",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// 设置家长密码
  static Future<bool> setParentPassword(Map<String, dynamic> data) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/stores/team/reset/password/sms/token",
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

  /// 验证密码
  static Future<bool?> verifyPassword(String password) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {
          "password": password,
        },
      );
      dynamic response = await WiseHttp().request(
        "/stores/team/validate/password",
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
      if(responseEntity.data != 1){
        ToastUtils.showToast(text: "密码错误");
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  
  /// 获取卡片权益数量
  static Future<RightCountDetailsEntity?> getCardRightCount() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/module/rights",
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
      RightCountDetailsEntity rightCountDetailsEntity = RightCountDetailsEntity.fromJson(responseEntity.data);
      return rightCountDetailsEntity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取客服二维码
  static Future<CustomerInfoEntity?> getCustomerInfo({bool showToast = true}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/stores/user/report/customer/staff",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code!= HttpStatus.ok) {
        if(showToast) {
          ToastUtils.showToast(text: responseEntity.message??"");
        }
        return null;
      }
      if(responseEntity.data == null) return null;
      CustomerInfoEntity customerInfoEntity = CustomerInfoEntity.fromJson(responseEntity.data);
      return customerInfoEntity;
    } on FormatException catch (e) {
      if(showToast) {
        ToastUtils.showToast(text: e.source.message);
      }
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 意见反馈
  static Future<bool> feedbackOpinion(Map<String, dynamic> data) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/report/advice",
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

  /// 获取反馈知识点内容错误类型
  static Future<FeedbackContentTypeEntity?> getFeedbackContentType() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/languages/language/error/report/types",
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
      FeedbackContentTypeEntity feedbackContentTypeEntity = FeedbackContentTypeEntity.fromJson(responseEntity.data);
      return feedbackContentTypeEntity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 上报反馈知识点内容错误
  static Future<bool> submitFeedbackContent(Map<String, dynamic> data) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/languages/language/error/content/report",
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


  /// 获取筑梦团列表
  static Future<List<DreamBuildingTeamEntity>?> getDreamBuildingTeamList() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/stores/activity/special/thanks/list",
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
      List<DreamBuildingTeamEntity> dreamBuildingTeamList = list.map((e) => DreamBuildingTeamEntity.fromJson(e)).toList();
      return dreamBuildingTeamList;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }
  
  


}