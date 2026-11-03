import 'package:langwise/common/entities/entities.dart';

class ImageModerationListState {
  static const String myReviewsId = 'my_reviews';

  // 每页请求的数量
  final int limit = 30;

  // 列表加载数据
  int offset = 0;

  /// 页面加载状态
  bool isLoading = false;

  /// 我的审核列表
  List<KnowledgePoint> myReviews = <KnowledgePoint>[];

  /// 总数据量
  int totalCount = 0;

  /// 是否还有更多数据
  bool get hasMoreData => myReviews.length < totalCount;

  /// 清空状态
  void clear() {
    isLoading = false;
    myReviews = [];
  }
}
