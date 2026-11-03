import 'package:flutter/services.dart';

class OrientationControlUtil {
  static const MethodChannel _channel = MethodChannel('orientation_control');

  static Future<void> forceLandscape() async {
    await _channel.invokeMethod('forceLandscape');
  }
}
