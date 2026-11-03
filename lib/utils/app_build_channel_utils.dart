

/// 应用构建渠道工具类。
///
/// 通过 `--dart-define=APP_CHANNEL=xxx` 注入当前构建渠道，
/// 便于在运行时区分不同安装包，例如渠道统计、灰度标识、问题排查等。
///
/// 单个渠道包示例：
/// `flutter build apk --release --dart-define=APP_CHANNEL=huawei`
///
/// 单个 Android Bundle 示例：
/// `flutter build appbundle --release --dart-define=APP_CHANNEL=huawei`
///
/// 单个 iOS 包示例：
/// `flutter build ipa --release --dart-define=APP_CHANNEL=appstore`
///
/// 多个渠道包示例（apk）：
/// `mkdir -p build/channels`
/// `for channel in huawei xiaomi oppo vivo; do flutter build apk --release --dart-define=APP_CHANNEL=$channel && cp build/app/outputs/flutter-apk/app-release.apk build/channels/app-$channel-release.apk; done`
///
/// 多个渠道 Bundle 示例（aab）：
/// `mkdir -p build/channels`
/// `for channel in huawei xiaomi oppo vivo; do flutter build appbundle --release --dart-define=APP_CHANNEL=$channel && cp build/app/outputs/bundle/release/app-release.aab build/channels/app-$channel-release.aab; done`
class AppBuildChannelUtils {
  AppBuildChannelUtils._();

  /// 渠道环境变量 key。
  static const String appChannelKey = 'APP_CHANNEL';

  /// 默认渠道名称。
  static const String appChannelDefault = 'default';

  /// 编译期注入的原始渠道值。
  static const String _rawAppChannel = String.fromEnvironment(
    appChannelKey,
    defaultValue: appChannelDefault,
  );

  /// 获取当前应用渠道。
  ///
  /// 会自动执行去空格和小写标准化，避免 `Huawei`、` huawei `
  /// 这类值造成渠道判断不一致。
  static String getAppChannel() {
    return normalizeChannel(_rawAppChannel);
  }

  /// 获取标准化后的渠道名称。
  static String normalizeChannel(String? channel) {
    final String normalized = channel?.trim().toLowerCase() ?? '';
    return normalized.isEmpty ? appChannelDefault : normalized;
  }

  /// 当前是否为默认渠道。
  static bool isDefaultChannel() {
    return getAppChannel() == appChannelDefault;
  }

  /// 判断当前是否为指定渠道。
  static bool isChannel(String channel) {
    return getAppChannel() == normalizeChannel(channel);
  }

  /// 判断当前是否命中了多个候选渠道中的任意一个。
  static bool isAnyChannel(List<String> channels) {
    final String currentChannel = getAppChannel();
    return channels.any((String channel) {
      return currentChannel == normalizeChannel(channel);
    });
  }
}
