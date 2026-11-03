import 'package:langwise/common/entities/entities.dart';

/// 图片审核管理详情页状态类
///
/// 管理图片审核员详情页面的所有状态数据
/// 包括审核员信息、知识点列表、筛选条件和加载状态等
class ImageModerationAdminDetailState {
  /// 审核员信息
  ReviewerStatsEntity? reviewer;

  // 每页请求的数量
  final int limit = 30;

  // 列表加载数据
  int offset = 0;

  /// 知识点列表
  List<KnowledgePoint> knowledgePoints = <KnowledgePoint>[];

  /// 总数据量
  int totalCount = 0;

  /// 搜索关键词
  String searchTerm = '';

  /// 排序字段
  String sortField = 'reviewDate';

  /// 排序方向
  String sortDirection = 'desc';

  /// 状态筛选，null表示全部状态
  ReviewStatus? statusFilter;

  /// 是否还有更多数据
  bool get hasMoreData => knowledgePoints.length < totalCount;
}
