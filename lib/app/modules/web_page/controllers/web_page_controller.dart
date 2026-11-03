import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/storage_util.dart';
import 'package:themed/themed.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/stores/user.dart';
import '../../../../common/values/values.dart';
import '../../../../theme/theme_utils.dart';
import '../../../../utils/utils.dart';
import '../../../routes/routes.dart';
import '../../../routes/routes_breadcrumb_utils.dart';
import '../codes/web_handler_code.dart';
import '../codes/web_param_code.dart';
import '../models/web_result.dart';

class WebPageController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  WebPageController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.WEB_PAGE;

  @override
  String get breadcrumbTitle => "网页";

  // 传进来的参数
  final RxString url = "".obs;

  /// webview控制器
  InAppWebViewController? webViewController;

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
  final Rx<Color?> appBarTitleColor = null.obs;

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
  final Rx<Color?> appBarIconColor = null.obs;

  /// * 页面主题(页面背景色，包括title背景色)，支持：dark, light, 自定义(支持16进制和rgba)，默认跟随APP的主题
  /// * 如果设置为dark或light，则会自动设置appBarTitleColor和appBarIconColor为适应色
  /// * 参数名: backgroundColor， 参数类型: String
  final Rx<Color?> backgroundColor = null.obs;
  
  
  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      url.value = Get.arguments["url"]??"";
    }
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
      default:
        return WebResult(code: 0, message: "无效参数");
    }
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
      ThemeRef bg = ColorRef.fromId(AppTheme.cBgPrimary.id);
      backgroundColor.value = themeMap[bg] as Color?;

      String? argAppBarTitleColor = params[WebParamCode.appBarTitleColor];
      if(argAppBarTitleColor == null){
        ThemeRef text = ColorRef.fromId(AppTheme.cTextPrimary.id);
        appBarTitleColor.value = themeMap[text] as Color?;
      }
      String? argAppBarIconColor = params[WebParamCode.appBarIconColor];
      if(argAppBarIconColor == null){
        ThemeRef icon = ColorRef.fromId(AppTheme.cTextPrimary.id);
        appBarIconColor.value = themeMap[icon] as Color?;
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
  }

  @override
  void onClose() {
    try {
      webViewController?.dispose();
    } catch (_) {
      
    }
    super.onClose();
  }
}
