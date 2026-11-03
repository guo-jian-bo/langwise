class CoverDirectoryCacheUtil {
  // 私有静态变量保存路径
  static String? _lastCoverDir;

  // 提供安全访问方法
  static String? get lastDirectory => _lastCoverDir;

  static void saveDirectory(String path) {
    _lastCoverDir = path;
  }

  static void clear() {
    _lastCoverDir = null;
  }
}
