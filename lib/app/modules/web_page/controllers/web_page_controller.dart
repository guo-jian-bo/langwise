import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/storage_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:themed/themed.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/stores/user.dart';
import '../../../../common/values/values.dart';
import '../../../../config.dart';
import '../../../../theme/theme_utils.dart';
import '../../../../utils/utils.dart';
import '../../../routes/routes.dart';
import '../../../routes/routes_breadcrumb_utils.dart';
import '../codes/web_handler_code.dart';
import '../codes/web_param_code.dart';
import '../models/web_result.dart';

class WebPageController extends GetxController with RoutesBreadcrumbMixin, RouteAware {
  final String tagText;
  WebPageController({required this.tagText});

  Route<dynamic>? _route;

  @override
  String get breadcrumbRoute => Routes.WEB_PAGE;

  @override
  String get breadcrumbTitle => Config.appName;

  // 传进来的参数 是否是竖屏
  bool portrait = false;

  // 传进来的参数
  final RxString url = "".obs;

  /// webview控制器
  InAppWebViewController? webViewController;
  WebViewEnvironment? webViewEnvironment;

  /// Windows 安装版运行在 Program Files 时，WebView2 用户目录需要放到可写目录。
  final RxBool webViewEnvironmentReady = false.obs;

  /// 前进是否可用
  final RxBool canGoForward = false.obs;
  /// 后退是否可用
  final RxBool canGoBack = false.obs;

  /// 加载进度
  final RxInt loadProgress = 0.obs;

  // --------------- 样式 ----------------------
  /// * web标题，自动获取web title，如果需要改标题，请修改web页面title。
  final RxString webTitle = "".obs;

  /// * appBar(title)标题文字颜色，支持16进制和rgba。默认跟随APP的主题
  /// * 参数名: appBarTitleColor， 参数类型: String
  final Rxn<Color> appBarTitleColor = Rxn<Color>();

  /// * 隐藏appBar(title)，默认显示(false)。
  /// * 参数名: hideAppBar， 参数类型: bool
  final RxBool hideAppBar = false.obs;

  /// * 隐藏appBar(title)下的加载进度，默认隐藏(false)。
  /// * 参数名: hideAppBarLoadProgress， 参数类型: bool
  final RxBool hideAppBarLoadProgress = false.obs;

  /// * 头部appBar(title)下的加载进度颜色，默认#38BDF8。(支持16进制和rgba)
  /// * 参数名: appBarLoadProgressColor， 参数类型: String
  final Rx<Color> appBarLoadProgressColor = const Color(0xFF38BDF8).obs;

  /// * appBar(title)上的按钮颜色，支持16进制和rgba。默认#9EA4AC
  /// * 参数名: appBarIconColor， 参数类型: String
  final Rxn<Color> appBarIconColor = Rxn<Color>();

  /// * 页面主题(页面背景色，包括title背景色)，支持：dark, light, 自定义(支持16进制和rgba)，默认跟随APP的主题
  /// * 如果设置为dark或light，则会自动设置appBarTitleColor和appBarIconColor为适应色
  /// * 参数名: backgroundColor， 参数类型: String
  final Rxn<Color> backgroundColor = Rxn<Color>();
  
  
  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      url.value = Get.arguments["url"]??"";
      portrait = Get.arguments["portrait"]??false;
      hideAppBar.value = Get.arguments["hideAppBar"]??false;
    }
    _initWebViewEnvironment();
  }

  Future<void> _initWebViewEnvironment() async {
    if (!Platform.isWindows) {
      webViewEnvironmentReady.value = true;
      return;
    }

    try {
      final Directory appSupportDir = await getApplicationSupportDirectory();
      final String userDataFolder = "${appSupportDir.path}${Platform.pathSeparator}webview2";
      await Directory(userDataFolder).create(recursive: true);
      webViewEnvironment = await WebViewEnvironment.create(
        settings: WebViewEnvironmentSettings(userDataFolder: userDataFolder),
      );
      print("web -- Windows WebView2 数据目录 : $userDataFolder");
    } catch (error, stackTrace) {
      ErrorLogUtils.to.logError(error, stackTrace);
      print("web -- 初始化 Windows WebView2 环境失败 : $error");
    } finally {
      webViewEnvironmentReady.value = true;
    }
  }


  /// 处理屏幕方向
  Future<void> handleOrientation() async{
    if(!portrait) return;
    if(!_shouldFollowPhoneOrientation()) return;
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  /// 仅手机设备遵循页面传入的横竖屏限制，平板和 PC 不处理。
  bool _shouldFollowPhoneOrientation() {
    if(!(Platform.isAndroid || Platform.isIOS)) return false;
    final BuildContext? context = Get.context;
    if(context == null) return false;
    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide < 600;
  }

  /// 订阅当前页面的路由变化，用于切换横竖屏。
  void _subscribeRouteObserver() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Route<dynamic>? route = routeInstanceMap[Get.currentRoute] ?? routeInstanceMap[Routes.WEB_PAGE];
      if(_route == route) return;
      _unsubscribeRouteObserver();
      _route = route;
      if(route is PageRoute<dynamic>) {
        AppPages.observer.subscribe(this, route);
      }
    });
  }

  /// 取消当前页面的路由监听。
  void _unsubscribeRouteObserver() {
    final Route<dynamic>? route = _route;
    if(route is! PageRoute<dynamic>) return;
    AppPages.observer.unsubscribe(this);
    _route = null;
  }

  /// 恢复 App 默认横屏，仅手机设备处理。
  Future<void> _restoreLandscapeOrientation() async {
    if(!_shouldFollowPhoneOrientation()) return;
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// 设置网页标题
  Future<void> setWebTitle(String? title) async{
    webTitle.value = title?? Config.appName;
    // 最多显示10个字符 超出部分省略号表示
    String breadcrumbTitle = webTitle.value.length > 10 ? "${webTitle.value.substring(0, 10)}..." : webTitle.value;
    updateBreadcrumbTitle(breadcrumbTitle);
  }





  // -------------------- 以下是 js调用app的处理器 start --------------------

  /// js调用app的处理器
  Future<WebResult> appHandler(List<dynamic> args, BuildContext context) async{
    if(args.isEmpty) {
      return WebResult(code: 0, message: "必须包含参数 {'code': ''}");
    }
    dynamic arg = args.first;
    if(arg is! Map) return WebResult(code: 0, message: "参数必须是Map");
    Map argMap = arg;
    String? code = argMap[WebParamCode.code];
    if(code == null) return WebResult(code: 0, message: "必须包含code参数");
    if(code.isEmpty) return WebResult(code: 0, message: "code不能为空");

    Map? params = argMap[WebParamCode.params];

    switch (code) {
      case WebHandlerCode.getToken:
        return await getToken();
      case WebHandlerCode.getDeviceId:
        return await getDeviceId();
      case WebHandlerCode.getUserData:
        return await getUserData();
      case WebHandlerCode.setTheme:
        return await setTheme(params);
      case WebHandlerCode.setAppBarStyle:
        return await setAppBarStyle(params);
      case WebHandlerCode.getSafeAreaInsets:
        return await getSafeAreaInsets(context);
      case WebHandlerCode.reload:
        return await reload();
      case WebHandlerCode.closeWebPage:
        return await closeWebPage();
      case WebHandlerCode.goForward:
        return await goForward();
      case WebHandlerCode.goBack:
        return await goBack();
      case WebHandlerCode.getHistory:
        return await getHistory();
      case WebHandlerCode.stopLoading:
        return await stopLoading();
      case WebHandlerCode.loadUrl:
        return await loadUrl(params);
      case WebHandlerCode.openAppUserPage:
        return await openAppUserPage(params);
      case WebHandlerCode.showNoticeDialog:
        return await showNoticeDialog(params);
      case WebHandlerCode.openExternalBrowser:
        return await openExternalBrowser(params);
      case WebHandlerCode.openExternalBrowserCurrentUrl:
        return await openExternalBrowserCurrentUrl();
      
      default:
        return WebResult(code: 0, message: "无效参数");
    }
  }

  /// 用外部浏览器打开当前url
  Future<WebResult> openExternalBrowserCurrentUrl() async{
    if(webViewController == null) return WebResult(code: 0, message: "当前还未初始化");
    WebUri? uri = await webViewController?.getUrl();
    if(uri == null) return WebResult(code: 0, message: "获取url失败");
    String url = uri.toString();
    WebViewUtils.openWebView(url: url, openExternalBrowser: true);
    return WebResult(code: 200, message: "ok");
  }

  /// 用外部浏览器打开url
  Future<WebResult> openExternalBrowser(Map? params) async{
    if(params == null) return WebResult(code: 0, message: "${WebParamCode.params}不能为空");
    String url = params[WebParamCode.url]??"";
    if(url.isEmpty) return WebResult(code: 0, message: "${WebParamCode.url}不能为空");
    WebViewUtils.openWebView(url: url, openExternalBrowser: true);
    return WebResult(code: 200, message: "ok");
  }

  /// 获取APP安全区域
  Future<WebResult> getSafeAreaInsets(BuildContext context) async{
    EdgeInsets safeAreaInsets = MediaQuery.of(context).padding;
    return WebResult(
      code: 200, 
      message: "ok",
      data: {
        "top": safeAreaInsets.top,
        "bottom": safeAreaInsets.bottom,
        "left": safeAreaInsets.left,
        "right": safeAreaInsets.right,
      },
    );
  }

  /// 关闭web页面
  Future<WebResult> closeWebPage() async{
    Get.back();
    return WebResult(code: 200, message: "ok");
  }

  /// 加载url
  Future<WebResult> loadUrl(Map? params) async{
    if(params == null) return WebResult(code: 0, message: "${WebParamCode.params}不能为空");
    String url = params[WebParamCode.url]??"";
    if(url.isEmpty) return WebResult(code: 0, message: "${WebParamCode.url}不能为空");
    await webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    return WebResult(code: 200, message: "ok");
  }

  /// 打开app用户页面
  Future<WebResult> openAppUserPage(Map? params) async{
    if(params == null) return WebResult(code: 0, message: "${WebParamCode.params}不能为空");
    String routeCode = params[WebParamCode.routeCode]??"";
    if(routeCode.isEmpty) return WebResult(code: 0, message: "${WebParamCode.routeCode}不能为空");
    Map<String, dynamic>? routeParams = params[WebParamCode.routeParams]?.cast<String, dynamic>();
    bool closeWebPage = params[WebParamCode.closeWebPage]?.toString() == "true";
    if(closeWebPage){
      Get.back();
    }
    JumpPageUtils.jumpUserPages(PushMessageEntityJump(code: routeCode, params: routeParams));

    return WebResult(code: 200, message: "ok");
  }

  /// 弹出公告弹窗
  Future<WebResult> showNoticeDialog(Map? params) async{
    if(params == null) return WebResult(code: 0, message: "${WebParamCode.params}不能为空");
    Map<String, dynamic>? routeParams = params[WebParamCode.routeParams]?.cast<String, dynamic>();
    if(routeParams == null) return WebResult(code: 0, message: "${WebParamCode.routeParams}不能为空");
    PushMessageEntity message = PushMessageEntity.fromJson(routeParams);
    MqttNotificationToast.showModal(messages: [message]);
    return WebResult(code: 200, message: "ok");
  }

  /// 前进
  Future<WebResult> goForward() async{
    await webViewController?.goForward();
    return WebResult(code: 200, message: "ok");
  }

  /// 后退
  Future<WebResult> goBack() async{
    await webViewController?.goBack();
    return WebResult(code: 200, message: "ok");
  }

  /// 取消加载
  Future<WebResult> stopLoading() async{
    await webViewController?.stopLoading();
    return WebResult(code: 200, message: "ok");
  }

  /// 获取token
  Future<WebResult> getToken() async{
    String token = StorageUtil().getString(STORAGE_USER_TOKEN_KEY);
    if(token.isEmpty) return WebResult(code: 1, message: "token为空");
    return WebResult(code: 200, message: "ok", data: token);
  }

  /// 获取DeviceId
  Future<WebResult> getDeviceId() async{
    String deviceId = StorageUtil().getString(STORAGE_DEVICE_ID_KEY);
    if(deviceId.isEmpty) return WebResult(code: 1, message: "deviceId为空");
    return WebResult(code: 200, message: "ok", data: deviceId);
  }

  /// 获取用户信息
  Future<WebResult> getUserData() async{
    UserInfoEntity userInfo = UserStore.to.userInfo.value;
    return WebResult(code: 200, message: "ok", data: userInfo.toJson());
  }

  /// 刷新当前url
  Future<WebResult> reload() async{
    await webViewController?.reload();
    return WebResult(code: 200, message: "ok");
  }

  /// 获取历史页面
  Future<WebResult> getHistory() async{
    WebHistory? copyBackForwardList = await webViewController?.getCopyBackForwardList();
    if(copyBackForwardList == null) return WebResult(code: 0, message: "获取历史页面失败");
    return WebResult(code: 200, message: "ok", data: copyBackForwardList.toJson());
  }

  /// 设置主题
  Future<WebResult> setTheme(Map? params) async{
    if(params == null) return WebResult(code: 0, message: "${WebParamCode.params}不能为空");
    String argTheme = params[WebParamCode.theme]??"";
    if(argTheme.isEmpty) return WebResult(code: 0, message: "${WebParamCode.theme}不能为空");
    Color? themeColor = ColorUtils.parseColor(argTheme);
    if(themeColor != null){
      backgroundColor.value = themeColor;
    }else{
      Map<ThemeRef, Object>? themeMap = ThemeUtils.getThemeMap(argTheme);
      if(themeMap == null) return WebResult(code: 0, message: "$argTheme不存在");
      final bgColor = ThemeUtils.getThemeColorById(themeMap, AppTheme.cBgPrimary.id);
      if (bgColor != null) backgroundColor.value = bgColor;

      String? argAppBarTitleColor = params[WebParamCode.appBarTitleColor];
      if(argAppBarTitleColor == null){
        final titleColor = ThemeUtils.getThemeColorById(themeMap, AppTheme.cTextPrimary.id);
        if (titleColor != null) appBarTitleColor.value = titleColor;
      }
      String? argAppBarIconColor = params[WebParamCode.appBarIconColor];
      if(argAppBarIconColor == null){
        final iconColor = ThemeUtils.getThemeColorById(themeMap, AppTheme.cTextPrimary.id);
        if (iconColor != null) appBarIconColor.value = iconColor;
      }
    }
    return WebResult(code: 200, message: "ok");
  }
  

  /// 设置AppBar样式
  Future<WebResult> setAppBarStyle(Map? params) async{
    if(params == null) return WebResult(code: 0, message: "${WebParamCode.params}不能为空");

    // 设置是否显示appbar
    bool? argHideAppBar = params[WebParamCode.hideAppBar];
    if(argHideAppBar != null) hideAppBar.value = argHideAppBar;

    // 设置文字颜色
    String? argAppBarTitleColor = params[WebParamCode.appBarTitleColor];
    if(argAppBarTitleColor != null) {
      Color? color = ColorUtils.parseColor(argAppBarTitleColor);
      if(color != null) appBarTitleColor.value = color;
    }

    // 设置是否显示加载进度
    bool? argHideAppBarLoadProgress = params[WebParamCode.hideAppBarLoadProgress];
    if(argHideAppBarLoadProgress != null) hideAppBarLoadProgress.value = argHideAppBarLoadProgress;

    // 设置加载进度颜色
    String? argAppBarLoadProgressColor = params[WebParamCode.appBarLoadProgressColor];
    if(argAppBarLoadProgressColor != null) {
      Color? color = ColorUtils.parseColor(argAppBarLoadProgressColor);
      if(color != null) appBarLoadProgressColor.value = color;
    }

    // 设置icon颜色
    String? argAppBarIconColor = params[WebParamCode.appBarIconColor];
    if(argAppBarIconColor != null) {
      Color? color = ColorUtils.parseColor(argAppBarIconColor);
      if(color != null) appBarIconColor.value = color;
    }

    return WebResult(code: 200, message: "ok");
  }


    // -------------------- 以上是 js调用app的处理器 end --------------------


  @override
  void onReady() {
    super.onReady();
    _subscribeRouteObserver();
    handleOrientation();
  }

  @override
  void didPushNext() {
    _restoreLandscapeOrientation();
  }

  @override
  void didPopNext() {
    handleOrientation();
  }

  @override
  void onClose() {
    try {
      _unsubscribeRouteObserver();
      // 如果是竖屏模式 退出页面需要设置为横屏
      if(portrait) _restoreLandscapeOrientation();

      webViewController?.dispose();
      webViewEnvironment?.dispose();
    } catch (_) {}
    super.onClose();
  }
}
