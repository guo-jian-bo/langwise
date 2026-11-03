import 'package:flutter/foundation.dart';

import '../common/https/auth.dart';

/// 服务器时间工具类
class ServiceDateUtils with ChangeNotifier {
  ServiceDateUtils._();

  static final ServiceDateUtils instance = ServiceDateUtils._();

  factory ServiceDateUtils() => instance;

  Future<void>? _initFuture;
  /// 服务端返回的基准时间，仅在启动阶段同步一次。
  DateTime? _serverBaseTime;
  /// 使用单调时钟累计流逝时长，避免被手动修改系统时间影响。
  final Stopwatch _stopwatch = Stopwatch();

  /// 当前是否已经成功建立服务端时间基准。
  bool get hasServerTime => _serverBaseTime != null;

  /// 启动时只初始化一次服务端时间，后续复用同一个 Future。
  Future<void> init() {
    return _initFuture ??= _initServerTime();
  }

  Future<void> _initServerTime() async {
    final int? timestamp = await AuthRequest.getServerTimestamp();
    if (timestamp == null) return;
    // 接口返回秒级时间戳，这里转换为本地时区后参与后续活动时间比较。
    _serverBaseTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true).toLocal();
    _stopwatch..reset()..start();
    notifyListeners();
  }

  /// 返回当前“服务端口径”的时间；若初始化失败则降级为本地时间。
  DateTime now() {
    final DateTime localNow = DateTime.now().toLocal();
    return !hasServerTime ? localNow : _serverBaseTime!.add(_stopwatch.elapsed);
  }
}
