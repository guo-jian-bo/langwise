/// 播放记录上报工具库
/// 
/// 使用方式:
/// ```dart
/// import 'package:langwise/utils/play_record_utils/play_record_utils.dart';
/// 
/// // 开始追踪
/// PlayRecordManager.instance.startTracking(
///   audioPlaybackUtils: audioPlayerUtils,
///   contentType: 'EN_SONG',
///   contentId: 123,
///   duration: 180.0,
///   source: 'song_mv',
/// );
/// 
/// // 停止追踪（退出播放器时）
/// PlayRecordManager.instance.stopTracking(source: 'song_mv');
/// 
/// // App启动时上报本地缓存记录
/// PlayRecordManager.instance.reportPendingRecords();
/// ```

export 'play_record_constants.dart';
export 'play_record_model.dart';
export 'play_record_database.dart';
export 'play_record_manager.dart';
