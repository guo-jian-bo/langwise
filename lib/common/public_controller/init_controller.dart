import 'package:get/get.dart';
import 'package:langwise/common/widgets/guide_engine/guide_manager.dart';

import '../../app/modules/song_mv/controllers/song_mv_controller.dart';
import 'config_controller.dart';

class InitController {
  /// app 初始化的时候调用 后面不能再次调用
  static Future<void> init() async {
    ConfigController configController = Get.put(ConfigController(), permanent: true);
    await configController.initConfig();
    Get.put(SongMvController(), permanent: true);
  }
}
