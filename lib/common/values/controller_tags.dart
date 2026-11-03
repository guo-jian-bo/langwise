/// 控制器 Tag 常量
///
/// 用于标识和管理控制器实例，特别是需要多实例的控制器
class ControllerTags {
  /// 私有构造函数，防止实例化
  ControllerTags._();

  /// BookPageGalleryController 的 tag 前缀
  static const String bookPageGalleryPrefix = 'book_page_gallery_';

  /// 根据书籍 ID 生成 BookPageGalleryController 的 tag
  static String bookPageGallery(int? bookUid) {
    return '$bookPageGalleryPrefix${bookUid ?? 'default'}';
  }

  /// BookPageScanController 的 tag 前缀
  static const String bookPageScanPrefix = 'book_page_scan_';

  /// 根据书籍 ID 生成 BookPageScanController 的 tag
  static String bookPageScan(int? bookUid) {
    return '$bookPageScanPrefix${bookUid ?? 'default'}';
  }
}
