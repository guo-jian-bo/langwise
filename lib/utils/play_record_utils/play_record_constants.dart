/// 播放记录上报相关常量配置
class PlayRecordConstants {
  PlayRecordConstants._();

  /// 最小有效播放时长（秒）- 小于此时长不上报
  static const int minValidPlaySeconds = 1;

  /// 数据库记录最大保留天数
  static const int maxRetentionDays = 7;

  /// 数据库最大记录条数
  static const int maxRecordCount = 1000;

  /// 数据库名称
  static const String databaseName = 'play_record.db';

  /// 数据库版本
  static const int databaseVersion = 1;

  /// 表名
  static const String tableName = 'play_records';
}

/// 上报状态枚举
enum PlayRecordReportStatus {
  /// 待上报
  pending('pending'),
  /// 上报中
  reporting('reporting'),
  /// 上报失败
  failed('failed'),
  /// 上报成功
  success('success');

  final String value;
  const PlayRecordReportStatus(this.value);

  static PlayRecordReportStatus fromValue(String? value) {
    return PlayRecordReportStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PlayRecordReportStatus.pending,
    );
  }
}

/// 上报触发类型
enum PlayRecordTriggerType {
  /// 播放完成
  playComplete('play_complete'),
  /// 切换歌曲
  switchSong('switch_song'),
  /// 退出播放器
  exitPlayer('exit_player');

  final String value;
  const PlayRecordTriggerType(this.value);
}


/// 上报的页面类型type
enum PlayRecordPageType {
  unit('unit'),
  favorite('favorite'),
  collection('collection'),
  script('SCRIPT');

  final String value;
  const PlayRecordPageType(this.value);

  static PlayRecordPageType? fromValue(String? value) {
    if (value == null) return null;
    try {
      return PlayRecordPageType.values.firstWhere(
        (e) => e.value == value,
      );
    } catch (e) {
      return null;
    }
  } 
}
