
import 'package:wise_http/wise_http.dart';

import '../../common/public_controller/manage_sandbox_controller.dart';
import '../../common/stores/stores.dart';
import 'request_auth_interceptor.dart';

class DioInterceptorUtils{

  /// 自定义拦截器列表
  static final List<Interceptor> _customInterceptors = <Interceptor>[];

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
    if(isManagementApi(path)) return token;

    if(!ManageSandboxController.to.isSimulate) return token;
    
    String? sAccessToken = ManageSandboxController.to.accessToken;
    if(sAccessToken == null) return token;

    return sAccessToken;
  }

  /// 获取 actorId 
  /// 如果是管理伪装 返回当前登录人(操作人)的 userId 需要加上请求的query参数上
  static int? getActorId(String path){
    if(isManagementApi(path)) return null;
    if(!ManageSandboxController.to.isSimulate) return null;
    return UserStore.to.userInfo.value.userId;
  }

  /// 获取 userId 
  /// 如果是管理伪装 返回模拟用户的 userId
  static int? getUserId(String path){
    int? userId = UserStore.to.userInfo.value.userId;
    if(isManagementApi(path)) return userId;
    if(!ManageSandboxController.to.isSimulate) return userId;
    return ManageSandboxController.to.userId;
  }

  /// 获取 memberId 
  /// 如果是管理伪装 返回模拟用户的 memberId
  static int? getMemberId(String path){
    int? memberId = UserStore.to.userInfo.value.memberId;
    if(isManagementApi(path)) return memberId;
    if(!ManageSandboxController.to.isSimulate) return memberId;
    return ManageSandboxController.to.memberId;
  }

  /// 是否是管理端的接口
  static bool isManagementApi(String path){
    return path.startsWith("/account-console");
  }



}