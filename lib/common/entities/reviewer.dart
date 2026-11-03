import 'package:common_utils/common_utils.dart';
import 'package:langwise/common/widgets/data_table_widget/data_sources.dart';

/// 审核人员实体类
class ReviewerEntity extends Dessert {
  /// 用户ID
  final int? userId;

  /// 昵称
  final String? nickName;

  /// 真实姓名
  final String? realName;

  /// 审核单词数量
  final int? reviewedCount;

  /// 审核图片数量
  final int? reviewedImageCount;

  /// 活跃日期
  final String? activeDay;

  /// 构造函数
  ReviewerEntity({
    required int uid,
    this.userId,
    this.nickName,
    this.realName,
    this.reviewedCount,
    this.reviewedImageCount,
    this.activeDay,
    bool selected = false,
  }) : super(uid: uid, selected: selected);

  /// 从JSON创建实体
  factory ReviewerEntity.fromJson(Map<String, dynamic> json) {
    return ReviewerEntity(
      uid: json['uid'] ?? 0,
      userId: json['userId'],
      nickName: json['nickName'],
      realName: json['realName'],
      reviewedCount: json['reviewedCount'],
      reviewedImageCount: json['reviewedImageCount'],
      activeDay: json['activeDay'],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'userId': userId,
      'nickName': nickName,
      'realName': realName,
      'reviewedCount': reviewedCount,
      'reviewedImageCount': reviewedImageCount,
      'activeDay': activeDay,
    };
  }

  bool get hasReviewedImageCount => reviewedImageCount != null;

  /// 是否可以批量审核（图片数>=5000）
  bool get canBatchReview => hasReviewedImageCount && reviewedImageCount! >= 5000;

  String get newActiveDay => _formatDate(activeDay);

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    return DateUtil.formatDateStr(dateStr, format: "yyyy-MM-dd");
  }

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ReviewerEntity && other.uid == uid;
  }

  @override
  int get hashCode => Object.hash(runtimeType, uid);
}

/// 审核人员统计数据实体
///
/// 包含审核人员的今日和累计审核数据统计
class ReviewerStatsEntity {
  /// 今日审核单词数
  final int? todayWordCount;

  /// 今日审核图片数
  final int? todayImageCount;

  /// 累计审核单词数
  final int? reviewedWordCount;

  /// 累计审核图片数
  final int? reviewedImageCount;

  /// 已批准图片数量
  final int? imageApproveCount;

  /// 批量处理状态
  final bool? batchStatus;

  /// 审核员
  final String? inspector;

  /// 用户ID
  final int? userId;

  /// 昵称
  final String? nickName;

  /// 真实姓名
  final String? realName;

  /// 审核单词数量
  final int? reviewedCount;

  /// 添加单词数量
  final int? additionCount;

  /// 添加图片数量
  final int? additionImageCount;

  /// 批量数量
  final int? batchCount;

  /// 活跃日期
  final String? activeDay;

  /// 构造函数
  ReviewerStatsEntity(
      {this.todayWordCount,
      this.todayImageCount,
      this.reviewedWordCount,
      this.reviewedImageCount,
      this.imageApproveCount,
      this.batchStatus,
      this.inspector,
      this.userId,
      this.nickName,
      this.realName,
      this.reviewedCount,
      this.additionCount,
      this.additionImageCount,
      this.batchCount,
      this.activeDay});

  /// 从JSON创建实体
  factory ReviewerStatsEntity.fromJson(Map<String, dynamic> json) {
    return ReviewerStatsEntity(
        todayWordCount: json['todayWordCount'],
        todayImageCount: json['todayImageCount'],
        reviewedWordCount: json['reviewedWordCount'],
        reviewedImageCount: json['reviewedImageCount'],
        imageApproveCount: json['imageApproveCount'],
        batchStatus: json['batchStatus'],
        inspector: json['inspector'],
        userId: json['userId'],
        nickName: json['nickName'],
        realName: json['realName'],
        reviewedCount: json['reviewedCount'],
        additionCount: json['additionCount'],
        additionImageCount: json['additionImageCount'],
        batchCount: json['batchCount'],
        activeDay: json['activeDay']);
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'todayWordCount': todayWordCount,
      'todayImageCount': todayImageCount,
      'reviewedWordCount': reviewedWordCount,
      'reviewedImageCount': reviewedImageCount,
      'imageApproveCount': imageApproveCount,
      'batchStatus': batchStatus,
      'inspector': inspector,
      'userId': userId,
      'nickName': nickName,
      'realName': realName,
      'reviewedCount': reviewedCount,
      'additionCount': additionCount,
      'additionImageCount': additionImageCount,
      'batchCount': batchCount,
      'activeDay': activeDay
    };
  }

  /// 创建副本并更新部分属性
  ReviewerStatsEntity copyWith(
      {int? todayWordCount,
      int? todayImageCount,
      int? reviewedWordCount,
      int? reviewedImageCount,
      int? imageApproveCount,
      bool? batchStatus,
      String? inspector,
      int? userId,
      String? nickName,
      String? realName,
      int? reviewedCount,
      int? additionCount,
      int? additionImageCount,
      int? batchCount,
      String? activeDay}) {
    return ReviewerStatsEntity(
        todayWordCount: todayWordCount ?? this.todayWordCount,
        todayImageCount: todayImageCount ?? this.todayImageCount,
        reviewedWordCount: reviewedWordCount ?? this.reviewedWordCount,
        reviewedImageCount: reviewedImageCount ?? this.reviewedImageCount,
        imageApproveCount: imageApproveCount ?? this.imageApproveCount,
        batchStatus: batchStatus ?? this.batchStatus,
        inspector: inspector ?? this.inspector,
        userId: userId ?? this.userId,
        nickName: nickName ?? this.nickName,
        realName: realName ?? this.realName,
        reviewedCount: reviewedCount ?? this.reviewedCount,
        additionCount: additionCount ?? this.additionCount,
        additionImageCount: additionImageCount ?? this.additionImageCount,
        batchCount: batchCount ?? this.batchCount,
        activeDay: activeDay ?? this.activeDay);
  }

  /// 获取批量处理状态
  bool get canBatchReview => batchStatus ?? false;

  /// 累计审核图片数
  String get newReviewedImageCount {
    if (ObjectUtil.isEmpty(reviewedImageCount) || ObjectUtil.isEmpty(imageApproveCount)) {
      return "0/0";
    }

    if (reviewedImageCount! <= imageApproveCount!) {
      return "$reviewedImageCount/$imageApproveCount";
    }

    return "$reviewedImageCount";
  }

  /// 获取昵称的首字母
  /// 如果昵称为空，返回空字符串
  String get firstLetter => nickName != null && nickName!.isNotEmpty ? nickName![0] : '';
  
  /// 计算剩余需要审核的图片数量
  /// 如果已审核图片数量超过或等于imageApproveCount，返回0
  /// 否则返回imageApproveCount减去已审核图片数量
  int get remainingImages {
    if (reviewedImageCount == null || imageApproveCount == null || reviewedImageCount! >= imageApproveCount!) {
      return 0;
    }
    return imageApproveCount! - reviewedImageCount!;
  }

  String get newActiveDay => _formatDate(activeDay);

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    return DateUtil.formatDateStr(dateStr, format: "yyyy-MM-dd");
  }
}
