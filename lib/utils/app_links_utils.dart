

import 'package:app_links/app_links.dart';

class AppLinksUtils {
  static Future<void> initAppLinks() async {
    final appLinks = AppLinks();
    final initialLink = await appLinks.getInitialLink();
    if (initialLink != null) {
      handleDeepLink(initialLink);
    }
    appLinks.uriLinkStream.listen((uri) {
      handleDeepLink(uri);
    });
  }

  static void handleDeepLink(Uri uri) {
    print('收到 Universal Link: $uri');
    
    // 处理以 /alipay 开头的路径
    if (uri.path.startsWith('/alipay')) {
      handleAlipayCallback(uri);
    }
    // 处理以 /openapp 开头的路径
    else if (uri.path.startsWith('/openapp')) {
      handleOpenAppCallback(uri);
    }
    // 处理支付回调（保留原有逻辑）
    else if (uri.path == '/payment/callback') {
      handlePaymentCallback(uri);
    }
    // 处理其他路径
    else {
      handleOtherPaths(uri);
    }
  }
  
  // 新增处理 /openapp 路径的方法
  static void handleOpenAppCallback(Uri uri) {
    print('处理 openapp 回调: $uri');
    
    // 根据具体路径进行不同处理
    if (uri.path == '/openapp/') {
      // 处理基础 openapp 路径
    } else if (uri.path.startsWith('/openapp/page/')) {
      // 处理特定页面跳转
      // Get.toNamed('/$pageName');
    }
    // 可以根据需要添加更多子路径处理
  }
  
  
  static void handleAlipayCallback(Uri uri) {
    // 处理支付宝回调逻辑
  }

  static void handlePaymentCallback(Uri uri) {
    // 处理支付回调逻辑
  }

  static void handleOtherPaths(Uri uri) {
    // 处理其他路径逻辑
  }
}
