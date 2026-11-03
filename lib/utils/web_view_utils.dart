import 'dart:io';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../app/routes/routes.dart';

class WebViewUtils {
  
  static Future<void> openWebView({
    required String url,
  }) async {
    if(Platform.isWindows){
      await launchUrlString(url);
    }else{
      await Get.toNamed(
        Routes.WEB_PAGE,
        arguments: {
          "url": url,
        },
      );
    }
  }

}
