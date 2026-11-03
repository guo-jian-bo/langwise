import 'dart:convert';

import 'package:app_links/app_links.dart';

import '../../common/entities/entities.dart';
import '../utils.dart';

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

  static Future<void> handleDeepLink(Uri uri) async {

    await Future.delayed(const Duration(milliseconds: 300));

    final String normalizedPath = _normalizedPath(uri);

    // 处理以 /alipay 开头的路径
    if (normalizedPath.startsWith('/alipay')) {
      handleAlipayCallback(uri);
    }
    // 处理以 /openapp 开头的路径
    else if (normalizedPath.startsWith('/openapp')) {
      handleOpenAppCallback(uri);
    }
    // 处理支付回调（保留原有逻辑）
    else if (normalizedPath == '/payment/callback') {
      handlePaymentCallback(uri);
    }
    // 处理其他路径
    else {
      handleOtherPaths(uri);
    }
  }
  
  /// 处理通过 Deeplink / Universal Link 唤起 App 的业务入口。
  ///
  /// 当前约定：
  /// - 先用 `handleDeepLink()` 按 path 分发到 `/openapp`
  /// - 再在这里继续判断 `/openapp` 的子路径
  /// - 目前真正用于“唤起 App 后跳指定页面”的入口是 `/openapp/page`
  ///
  /// 使用方式：
  /// - 基础唤起：`/openapp`
  /// - 唤起并跳页面：`/openapp/page?code=页面路由编码`
  /// - `category` 可选，默认 `USER`
  /// - `params` 可选，必须是 URL 编码后的 JSON 字符串
  ///
  /// 例如：
  /// - `langwise://openapp/page?code=test`
  /// - `langwise://openapp/page?code=test`
  /// - `https://timelywise.cn/openapp/page?code=test`
  /// - `https://timelywise.cn/openapp/page?code=web_view&category=USER&params=%7B%22url%22%3A%22https%3A%2F%2Fexample.com%22%7D`
  ///
  /// 参数说明：
  /// - `code`：必传，对应 `JumpPageUtils.jumpPage()` 里的页面路由编码
  /// - `category`：选传，常用值如 `USER`、`MANAGE`、`TASK`
  /// - `params`：选传，跳转页面需要的参数对象
  ///
  /// 注意：
  /// - 这里只负责解析 `/openapp` 相关业务路径
  /// - 真正执行页面跳转的是 `handleJumpPage()`
  /// - 自定义协议 / Universal Link 是否能成功拉起 App，还依赖原生平台配置
  static void handleOpenAppCallback(Uri uri) {
    final String normalizedPath = _normalizedPath(uri);

    // 根据具体路径进行不同处理
    if (normalizedPath == '/openapp' || normalizedPath == '/openapp/') {
      // 处理基础 openapp 路径
    } else if (normalizedPath.startsWith('/openapp/page')) {
      // 处理特定页面跳转
      handleJumpPage(uri);
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

  /// 处理跳转页面的逻辑
  static void handleJumpPage(Uri uri) {
    final String category = uri.queryParameters['category'] ?? JumpPageUtils.userType;
    final String? code = uri.queryParameters['code'];
    if (code == null || code.isEmpty) {
      return;
    }
    final String? paramsStr = uri.queryParameters['params'];
    Map<String, dynamic> params = {};
    if (paramsStr != null && paramsStr.isNotEmpty) {
      params = Map<String, dynamic>.from(jsonDecode(paramsStr));
    }

    final entity = PushMessageEntity(
      category: category,
      jump: PushMessageEntityJump(
        code: code,
        params: params,
      ),
    );
    JumpPageUtils.jumpPage(entity);
  }

  static String _normalizedPath(Uri uri) {
    final String path = uri.path.isEmpty ? '/' : uri.path;
    // http/https 链接的 host 是域名本身，不参与业务路由路径拼接。
    final bool isWebLink = uri.scheme == 'http' || uri.scheme == 'https';
    // 自定义协议在 Windows 等平台上可能表现为 scheme://host/path，
    // 其中业务首段会落在 host，需要和 path 重新拼成完整路由。
    final bool hasHostSegment = uri.host.isNotEmpty && !isWebLink;

    if (!hasHostSegment) {
      return path;
    }

    if (path == '/') {
      // 例如 langwise://openapp -> /openapp
      return '/${uri.host}';
    }

    // 例如 langwise://openapp/page -> /openapp/page
    return '/${uri.host}$path';
  }
}
