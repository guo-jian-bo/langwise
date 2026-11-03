import 'package:get/get.dart';
import '../controllers/manage_audio_subtitle_editor_controller.dart';

class ManageAudioSubtitleEditorBinding extends Bindings {
  final String tag;
  ManageAudioSubtitleEditorBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageAudioSubtitleEditorController>(
      () => ManageAudioSubtitleEditorController(tag: tag),
      tag: tag,
    );
  }
}
