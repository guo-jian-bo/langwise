import 'package:quiz_play/component/tips_video_widget.dart';

class TipsVideoManager {
  TipsVideoManager._();

  static final TipsVideoManager instance = TipsVideoManager._();

  final Set<TipsVideoWidgetController> _controllers =
      <TipsVideoWidgetController>{};

  void register(TipsVideoWidgetController controller) {
    _controllers.add(controller);
  }

  void unregister(TipsVideoWidgetController controller) {
    _controllers.remove(controller);
  }

  void stopAll() {
    final List<TipsVideoWidgetController> snapshot = _controllers.toList();
    for (final TipsVideoWidgetController controller in snapshot) {
      controller.stopAndReset();
    }
  }
}
