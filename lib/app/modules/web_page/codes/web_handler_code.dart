class WebHandlerCode {
  /// 统一前缀 用来表示是这个app
  static const String appPrefix = "lw_";

  /// js调用app的处理器
  static const String appHandler = "${appPrefix}appHandler";
  
  /// 获取token
  static const String getToken = "${appPrefix}getToken";

  /// 获取DeviceId
  static const String getDeviceId = "${appPrefix}getDeviceId";
  
  /// 获取用户信息
  static const String getUserData = "${appPrefix}getUserData";

  /// 设置主题
  static const String setTheme = "${appPrefix}setTheme";

  /// 获取APP安全区域
  static const String getSafeAreaInsets = "${appPrefix}getSafeAreaInsets";
  
  /// 设置样式
  static const String setAppBarStyle = "${appPrefix}setAppBarStyle";
  
  /// 刷新当前url
  static const String reload = "${appPrefix}reload";
  
  /// 关闭web页面
  static const String closeWebPage = "${appPrefix}closeWebPage";

  /// 前进
  static const String goForward = "${appPrefix}goForward";

  /// 后退
  static const String goBack = "${appPrefix}goBack";

  /// 获取历史页面
  static const String getHistory = "${appPrefix}getHistory";

  /// 取消加载
  static const String stopLoading = "${appPrefix}stopLoading";

  /// 加载url
  static const String loadUrl = "${appPrefix}loadUrl";

  /// 打开app用户页面
  static const String openAppUserPage = "${appPrefix}openAppUserPage";

  /// 弹出公告弹窗
  static const String showNoticeDialog = "${appPrefix}showNoticeDialog";

  /// 用外部浏览器打开指定url
  static const String openExternalBrowser = "${appPrefix}openExternalBrowser";

  /// 用外部浏览器打开当前url
  static const String openExternalBrowserCurrentUrl = "${appPrefix}openExternalBrowserCurrentUrl";

}