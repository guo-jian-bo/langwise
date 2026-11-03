import 'package:wise_camera/wise_camera.dart';

class CameraUtil {
  factory CameraUtil() => _getInstance();

  static CameraUtil get instance => _getInstance();

  static CameraUtil? _instance;

  // 相机唯一标识
  String? _deviceId;

  set deviceId(String value) => _deviceId = value;

  String get deviceId => _deviceId ?? "";

  // 是否有相机
  bool get hasCamera => _deviceId != null;

  // 相机
  WiseCamera? _camera;

  WiseCamera? get camera => _camera;

  static CameraUtil _getInstance() {
    _instance ??= CameraUtil._internal();
    return _instance!;
  }

  CameraUtil._internal() {
    _camera = WiseCamera();
  }

  // 销毁相机
  void dispose() {
    _camera?.dispose();
  }
}
