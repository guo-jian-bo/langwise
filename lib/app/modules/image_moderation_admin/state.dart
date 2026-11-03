/// 审核人管理页面状态
class ImageModerationAdminState {
  static const String reviewersListId = 'reviewers_list';
  static const String searchId = 'search';
  static const String sortId = 'sort';

  /// 每页请求的数量
  final int limit = 20;

  /// 列表加载数据
  int offset = 0;

  /// 搜索关键词
  String searchTerm = '';

  /// 排序字段：'reviewedContentCount' 或 'reviewedImageCount'
  String sortField = 'reviewedImageCount';

  /// 排序方向
  /// - 'asc'（ascending）：升序排列，从小到大，例如 10, 50, 100
  /// - 'desc'（descending）：降序排列，从大到小，例如 100, 50, 10
  /// 默认为降序('desc')，用户点击排序按钮时会在两种状态间切换
  String sortDirection = 'desc';

  /// 判断搜索词是否为空
  bool get isSearchEmpty => searchTerm.trim().isEmpty;

  /// 清空状态
  void clear() {
    searchTerm = '';
  }
}
