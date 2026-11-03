/// 图片审核状态类
///
/// 用于存储图片审核模块的状态数据
///
/// 功能概述：
/// 图片审核是一个独立功能模块，用于审核系统中的图片资源，确保图片内容符合要求。
/// 该功能需要同时在主APP和管理端的嵌套路由中使用，且两者之间的状态需要隔离。
///
import 'package:langwise/common/entities/entities.dart';

class ImageModerationState {
  /// 知识点列表更新ID
  static const String knowledgeListId = 'knowledge_list';

  /// 我的审核列表更新ID
  static const String myReviewsId = 'my_reviews';

  /// 统计信息更新ID
  static const String statisticsId = 'statistics_id';

  // 每页请求的数量
  final int limit = 30;

  // 列表加载数据
  int offset = 0;

  /// 页面加载状态
  bool isLoading = false;

  /// 知识点列表
  List<KnowledgePoint> knowledgePoints = <KnowledgePoint>[];

  /// 审核状态筛选/默认审核中
  ReviewStatus statusFilter = ReviewStatus.inReview;

  /// 搜索关键词
  String searchTerm = '';

  /// 数据来源是否来自搜索
  bool isFromSearch = false;

  /// 我的审核列表
  List<KnowledgePoint> myReviews = <KnowledgePoint>[];

  ReviewerStatsEntity? reviewerStatsEntity;

  // 是否可批量审核
  bool get canBatchReview => (reviewerStatsEntity?.canBatchReview ?? false);

  /// 清空状态
  void clear() {
    isLoading = false;
    knowledgePoints = [];
    statusFilter = ReviewStatus.pending;
    searchTerm = '';
    myReviews = [];
    reviewerStatsEntity = null;
  }
}
