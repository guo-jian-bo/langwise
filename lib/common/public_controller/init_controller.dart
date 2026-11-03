import 'dart:developer';

import 'package:get/get.dart';

import '../../app/modules/song_mv/controllers/song_mv_controller.dart';
import '../../app/routes/breadcrumb_controller.dart';
import 'config_controller.dart';

class InitController {
  /// app 初始化的时候调用 后面不能再次调用
  static Future<void> init() async {
    log('[InitController] init enter');
    ConfigController configController = Get.put(ConfigController(), permanent: true);
    log('[InitController] ConfigController ready');
    await configController.initConfig();
    log('[InitController] configController.initConfig done');
    Get.put(SongMvController(), permanent: true);
    log('[InitController] SongMvController ready');
    
    Get.put(BreadcrumbController(), permanent: true);
    log('[InitController] BreadcrumbController ready');
  }
}
