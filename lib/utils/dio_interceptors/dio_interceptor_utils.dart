
import 'package:get/get.dart';
import 'package:wise_http/wise_http.dart';

import '../../app/modules/management/controllers/manage_setting_controller.dart';
import '../../common/enum/enum.dart';
import '../../common/public_controller/config_controller.dart';
import '../../common/public_controller/manage_sandbox_controller.dart';
import '../../common/stores/stores.dart';
import 'request_auth_interceptor.dart';

class DioInterceptorUtils{

  /// 自定义拦截器列表
  static final List<Interceptor> _customInterceptors = <Interceptor>[];

  /// 视觉风格 接口过滤视觉风格相关请求参数 extra key
  static const String visualStyleExtraKey = "visual_style_key";

  /// app 视觉风格 locale
  static String? _appLocale;

  /// 添加拦截器
  static void addInterceptor(Interceptor interceptor){
    if (!_customInterceptors.contains(interceptor)) {
      _customInterceptors.add(interceptor);
    }
    WiseHttp().addInterceptor(interceptor);
  }

  /// 重置链接
  static void reset(){
    WiseHttp().reset();

    final customInterceptors = List<Interceptor>.from(_customInterceptors);
    for (final interceptor in customInterceptors) {
      if (interceptor is RequestAuthInterceptor) {
        interceptor.resetState();
      }
    }
    // 先重建拦截器列表，再让 _createDio() 统一挂载到新的 Dio 上。
    _customInterceptors.clear();
    _customInterceptors.addAll(customInterceptors);
  }

  /// 获取 accessToken 
  /// 如果是管理伪装 则需要替换token
  static String getAccessToken(String path){
    String token = UserStore.to.accessToken;
    if(isManagementAccountApi(path)) return token;

    if(!ManageSandboxController.to.isSimulate) return token;
    
    String? sAccessToken = ManageSandboxController.to.accessToken;
    if(sAccessToken == null) return token;

    return sAccessToken;
  }

  /// 获取 actorId 
  /// 如果是管理伪装 返回当前登录人(操作人)的 userId 需要加上请求的query参数上
  static int? getActorId(String path){
    if(isManagementAccountApi(path)) return null;
    if(!ManageSandboxController.to.isSimulate) return null;
    return UserStore.to.userInfo.value.userId;
  }

  /// 获取 userId 
  /// 如果是管理伪装 返回模拟用户的 userId
  static int? getUserId(String path){
    int? userId = UserStore.to.userInfo.value.userId;
    if(isManagementAccountApi(path)) return userId;
    if(!ManageSandboxController.to.isSimulate) return userId;
    return ManageSandboxController.to.userId;
  }

  /// 获取 memberId 
  /// 如果是管理伪装 返回模拟用户的 memberId
  static int? getMemberId(String path){
    int? memberId = UserStore.to.userInfo.value.memberId;
    if(isManagementAccountApi(path)) return memberId;
    if(!ManageSandboxController.to.isSimulate) return memberId;
    return ManageSandboxController.to.memberId;
  }

  /// 是否是管理端account的接口
  static bool isManagementAccountApi(String path){
    return path.startsWith("/account-console");
  }

  /// * 获取视觉风格请求参数
  /// * app的mediaMode和style从全局设置里面取；manage的mediaMode和style从管理端全局设置里面取
  /// * app loacle从课程里面获取；manage locale 从管理端全局设置里面取
  static Map<String, dynamic> getVisualStyleRequestParams(String path){
    Map<String, dynamic> params = {};
    if(isManageRequest(path)){
      bool isRegistered = Get.isRegistered<ManageSettingController>();
      if(isRegistered){
        final ManageSettingController manageSettingController = Get.find<ManageSettingController>();
        ResourceTypeEnum resource = manageSettingController.defaultResources.value;
        String? manageStyle = manageSettingController.getCurrentStyleCode();
        String manageLocale = manageSettingController.selectedStyleAreaCode.value;
        params['mediaMode'] = resource == ResourceTypeEnum.video ? 1 : 0;
        if(manageStyle != null){
          params['style'] = Uri.encodeComponent(manageStyle);
        }
        if(manageLocale.isNotEmpty){
          params['locale'] = manageLocale;
        }
      }
    }else{
      bool isRegistered = Get.isRegistered<ConfigController>();
      if(isRegistered){
        final ConfigController configController = Get.find<ConfigController>();
        ResourceTypeEnum resource = configController.currentShowResource.value;
        params['mediaMode'] = resource == ResourceTypeEnum.video ? 1 : 0;
        String appStyle = configController.currentShowStyleCode.value;
        if(appStyle.isNotEmpty){
          params['style'] = Uri.encodeComponent(appStyle);
        }
        if(_appLocale != null){
          params['locale'] = _appLocale;
        }
      }
    }

    return params;
  }

  /// 设置app 请求locale 参数
  static void setAppLocale(String? locale){
    if(locale == null) return;
    if(locale.isEmpty) return;
    _appLocale = locale;
  }

  /// 清除app 请求locale 参数
  static void clearAppLocale(){
    _appLocale = null;
  }

  /// 是否是管理端的接口
  static bool isManageRequest(String path){
    if(path.isEmpty) return false;
    String substr = path.substring(1);
    List<String> paths = substr.split("/");
    if(paths.isEmpty) return false;
    String firstPath = paths.first;
    if(firstPath.contains("console")){
      return true;
    }
    return false;
  }


}