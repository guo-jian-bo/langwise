

import 'package:url_launcher/url_launcher_string.dart';

import '../app/routes/routes.dart';
import '../app/routes/tag_routes.dart';

class WebViewUtils {
  
  /// 打开webview
  /// [url] webview的url
  /// [portrait] 是否为竖屏模式
  /// [openExternalBrowser] 是否打开外部浏览器
  /// [hideAppBar] 是否隐藏appbar
  static Future<void> openWebView({
    required String url,
    bool portrait = false,
    bool openExternalBrowser = false,
    bool hideAppBar = false,
  }) async {
    
    if(openExternalBrowser){
      await launchUrlString(url);
      return;
    }

    // url = "http://192.168.58.250:8083/app/anniversary";

    await TagRoutes.toNamed(
      Routes.WEB_PAGE,
      arguments: {
        "url": url,
        "portrait": portrait,
        "hideAppBar": hideAppBar,
      },
    );

    // if(Platform.isWindows){
    //   await launchUrlString(url);
    // }else{
    //   await TagRoutes.toNamed(
    //     Routes.WEB_PAGE,
    //     arguments: {
    //       "url": url,
    //       "portrait": portrait,
    //       "hideAppBar": hideAppBar,
    //     },
    //   );
    // }

  }

}
