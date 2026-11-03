import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/values/values.dart';
import 'package:uuid/uuid.dart';

/// 获取状态对应的颜色
Color _getStatusColor(ReviewStatus status) {
  switch (status) {
    case ReviewStatus.pending:
      return color_6A7282;
    case ReviewStatus.inReview:
      return color_2B7FFF;
    case ReviewStatus.reReview:
      return color_AD46FF;
    case ReviewStatus.approved:
      return color_00C950;
    case ReviewStatus.abandon:
      return color_FB2C36;
  }
}

/// 审核状态类型
enum ReviewStatus {
  pending('PENDING', "未审核"),
  inReview('CHECKING', "审核中"),
  reReview('RECHECKING', "已初审"),
  approved('APPROVED', "审核通过"),
  abandon('ABANDON', "放弃审核");

  final String label;
  final String title;

  const ReviewStatus(this.label, this.title);

  /// 是否未审核状态
  bool get isPending => this == ReviewStatus.pending;

  /// 是否审核中状态
  bool get isInReview => this == ReviewStatus.inReview;

  /// 是否已初审状态
  bool get isReReview => this == ReviewStatus.reReview;

  /// 是否审核通过状态
  bool get isApproved => this == ReviewStatus.approved;

  /// 是否放弃审核状态
  bool get isAbandon => this == ReviewStatus.abandon;

  static ReviewStatus fromString(String value) {
    return ReviewStatus.values.firstWhere(
      (status) => status.label == value,
      orElse: () => ReviewStatus.pending,
    );
  }
}

/// 图片项实体
class ImageItem {
  /// 唯一标识符
  final String uniqueId;

  /// 图片ID
  final int? imageId;

  /// 图片URL
  final String? imageUrl;

  /// 图片Key
  final String? imageKey;

  /// 风格ID
  final int? styleId;

  /// 图片风格
  final String? style;
  final String? styleTitle;

  /// 地区
  final String? locale;
  final String? localeTitle;

  /// 图片评分
  final int? imageScore;

  /// 工作流
  final String? workFlow;

  /// 噪声种子
  final int? noiseSeed;

  /// 提示词ID
  final int? promptId;

  /// 提示词内容
  final String? prompt;

  /// MD5哈希值
  final String? md5;

  /// 任务ID
  final int? taskId;

  /// 文件大小（字节）
  final int? size;

  /// 图片宽度
  final int? width;

  /// 图片高度
  final int? height;

  /// 批次ID
  final int? batchId;

  /// 创建时间
  final String? created;

  /// 更新时间
  final String? updated;

  /// 批量模式下是否被选中
  bool isSelected;

  /// UI关联的全局键
  final GlobalKey globalKey;

  /// 构造函数
  ImageItem({
    String? uniqueId,
    this.imageId,
    this.imageUrl,
    this.imageKey,
    this.styleId,
    this.style,
    this.styleTitle,
    this.locale,
    this.localeTitle,
    this.imageScore,
    this.workFlow,
    this.noiseSeed,
    this.promptId,
    this.prompt,
    this.md5,
    this.taskId,
    this.size,
    this.width,
    this.height,
    this.batchId,
    this.created,
    this.updated,
    this.isSelected = false,
  })  : uniqueId = uniqueId ?? _generateUniqueId(),
        globalKey = GlobalKey(debugLabel: imageId.toString());

  /// 唯一ID生成策略
  static String _generateUniqueId() {
    return const Uuid().v6();
  }

  /// 从JSON创建实体
  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      imageId: json['imageId'],
      imageUrl: json['imageUrl'],
      imageKey: json['imageKey'],
      styleId: json['styleId'],
      style: json['style'],
      styleTitle: json['styleTitle'],
      locale: json['locale'],
      localeTitle: json['localeTitle'],
      imageScore: json['imageScore'],
      workFlow: json['workFlow'],
      noiseSeed: json['noiseSeed'],
      promptId: json['promptId'],
      prompt: json['prompt'],
      md5: json['md5'],
      taskId: json['taskId'],
      size: json['size'],
      width: json['width'],
      height: json['height'],
      batchId: json['batchId'] != null ? int.tryParse(json['batchId'].toString()) : null,
      created: json['created'],
      updated: json['updated'],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'imageId': imageId,
      'imageUrl': imageUrl,
      'imageKey': imageKey,
      'styleId': styleId,
      'style': style,
      'styleTitle': styleTitle,
      'locale': locale,
      'localeTitle': localeTitle,
      'imageScore': imageScore,
      'workFlow': workFlow,
      'noiseSeed': noiseSeed,
      'promptId': promptId,
      'prompt': prompt,
      'md5': md5,
      'taskId': taskId,
      'size': size,
      'width': width,
      'height': height,
      'batchId': batchId,
      'created': created,
      'updated': updated,
    };
  }

  /// 创建带有更新的副本
  ImageItem copyWith({
    int? imageId,
    String? imageUrl,
    String? imageKey,
    int? styleId,
    String? style,
    String? styleTitle,
    String? locale,
    String? localeTitle,
    int? imageScore,
    String? workFlow,
    int? noiseSeed,
    int? promptId,
    String? prompt,
    String? md5,
    int? taskId,
    int? size,
    int? width,
    int? height,
    int? batchId,
    String? created,
    String? updated,
    bool? isSelected,
  }) {
    return ImageItem(
      imageId: imageId ?? this.imageId,
      imageUrl: imageUrl ?? this.imageUrl,
      imageKey: imageKey ?? this.imageKey,
      styleId: styleId ?? this.styleId,
      style: style ?? this.style,
      styleTitle: styleTitle ?? this.styleTitle,
      locale: locale ?? this.locale,
      localeTitle: localeTitle ?? this.localeTitle,
      imageScore: imageScore ?? this.imageScore,
      workFlow: workFlow ?? this.workFlow,
      noiseSeed: noiseSeed ?? this.noiseSeed,
      promptId: promptId ?? this.promptId,
      prompt: prompt ?? this.prompt,
      md5: md5 ?? this.md5,
      taskId: taskId ?? this.taskId,
      size: size ?? this.size,
      width: width ?? this.width,
      height: height ?? this.height,
      batchId: batchId ?? this.batchId,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// 检查图片ID是否有效（不为空且大于0）
  bool get hasValidImageId => imageId != null && imageId! > 0;

  /// 返回保存结果的JSON数据，包含imageKey、noiseSeed、workFlow
  Map<String, dynamic> toSaveResultJson() {
    return {
      "imageId": imageId,
      "md5": md5,
      "taskId": taskId,
      "size": size,
      "width": width,
      "height": height,
      'imageKey': imageKey,
      'noiseSeed': noiseSeed,
      'workFlow': workFlow,
    };
  }

  /// 检查图片是否需要审核（评分为空或零）
  bool get needsReview => imageScore == null || imageScore == 0;

  /// 获取图片边框颜色
  Color get borderColor => imageScore != null && imageScore! > 0 ? getStarColor(imageScore!) : color_D1D5DC;

  // 时间格式化（复用相同逻辑）
  String get newUpdated => _formatDate(updated);

  String get newCreated => _formatDate(created);

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    return DateUtil.formatDateStr(dateStr, format: "yyyy-MM-dd HH:mm");
  }

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ImageItem && other.imageId == imageId;
  }

  /// 哈希值
  @override
  int get hashCode => Object.hash(runtimeType, imageId);

  /// 字符串表示
  @override
  String toString() {
    return 'ImageItem{'
        'uniqueId: $uniqueId, '
        'imageId: $imageId, '
        'imageUrl: $imageUrl, '
        'imageKey: $imageKey, '
        'styleId: $styleId, '
        'style: $style, '
        'styleTitle: $styleTitle, '
        'locale: $locale, '
        'localeTitle: $localeTitle, '
        'imageScore: $imageScore, '
        'promptId: $promptId, '
        'prompt: $prompt, '
        'isSelected: $isSelected, '
        'needsReview: $needsReview'
        '}';
  }
}

/// 释义项实体
class GlossItem {
  /// 唯一标识符
  final String uniqueId;

  /// 语义内容
  final String? semantic;

  /// 定义或翻译
  final String? definition;

  final String? glossEn;

  final String? glossZh;

  /// 难度
  final String? difficulty;

  /// 图片列表
  final List<ImageItem> images;

  /// 构造函数
  GlossItem({
    String? uniqueId,
    this.semantic,
    this.definition,
    this.difficulty,
    this.glossEn,
    this.glossZh,
    required this.images,
  }) : uniqueId = uniqueId ?? _generateUniqueId();

  /// 唯一ID生成策略
  static String _generateUniqueId() {
    return const Uuid().v6();
  }

  /// 从JSON创建实体
  /// 在加载数据时就对图片进行排序，将未审核的图片放在前面，已审核的图片按星星数量降序排序放在后面
  factory GlossItem.fromJson(Map<String, dynamic> json) {
    // 先将所有图片转换为ImageItem对象
    final allImages = (json['images'] as List<dynamic>?)?.map((img) => ImageItem.fromJson(img)).toList() ?? [];

    // 将图片分为未审核和已审核两组
    final unreviewed = allImages.where((img) => img.needsReview).toList();
    final reviewed = allImages.where((img) => !img.needsReview).toList();

    // 已审核的图片按星星数量降序排序
    reviewed.sort((a, b) => (b.imageScore ?? 0).compareTo(a.imageScore ?? 0));

    // 将未审核的图片放在前面，已审核的图片放在后面
    final sortedImages = [...unreviewed, ...reviewed];

    return GlossItem(
      semantic: json['semantic'] as String?,
      definition: json['definition'] as String?,
      difficulty: json['difficulty'] as String?,
      glossEn: json['glossEn'] as String?,
      glossZh: json['glossZh'] as String?,
      images: sortedImages,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'semantic': semantic,
      'definition': definition,
      'difficulty': difficulty,
      'glossEn': glossEn,
      'glossZh': glossZh,
      'images': images.map((img) => img.toJson()).toList(),
    };
  }

  /// 获取未审核数量（stars为0的图片数量）
  int get pendingCount => images.where((img) => img.needsReview).toList().length;

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is GlossItem && other.semantic == semantic && other.definition == definition;
  }

  /// 哈希值
  @override
  int get hashCode => Object.hash(runtimeType, semantic, definition);
}

/// 词性组实体
class PosGroup {
  /// 唯一标识符
  final String uniqueId;

  /// 词性名称
  final String? title;

  /// 词性描述
  final String? description;

  /// 释义列表
  final List<GlossItem> semanticList;

  /// 构造函数
  PosGroup({
    String? uniqueId,
    this.title,
    this.description,
    required this.semanticList,
  }) : uniqueId = uniqueId ?? _generateUniqueId();

  /// 唯一ID生成策略
  static String _generateUniqueId() {
    return const Uuid().v6();
  }

  /// 从JSON创建实体
  factory PosGroup.fromJson(Map<String, dynamic> json) {
    return PosGroup(
      title: json['title'],
      description: json['description'],
      semanticList:
          (json['semanticList'] as List<dynamic>?)?.map((semantic) => GlossItem.fromJson(semantic)).toList() ?? [],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'semanticList': semanticList.map((semantic) => semantic.toJson()).toList(),
    };
  }

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PosGroup && other.title == title && other.description == description;
  }

  /// 哈希值
  @override
  int get hashCode => Object.hash(runtimeType, title, description);

  /// 获取未审核的图片数量
  int get unreviewedImagesCount {
    int count = 0;
    for (final gloss in semanticList) {
      count += gloss.images.where((img) => img.needsReview).length;
    }
    return count;
  }
}

/// 知识点实体
class KnowledgePoint {
  /// 知识点ID
  final int uid;

  final int? userId;

  /// 英文
  final String? content;

  /// 类型中文
  final String? contentType;

  /// 类型英文
  final String? typeTitle;

  /// 审核状态英文
  final String? status;

  /// 审核状态中文
  final String? statusTitle;

  // 昵称
  final String? nickName;

  // 是否自己
  final bool? oneself;

  /// 更新时间
  final String? updated;

  /// 已审核图片数量
  final int? reviewedImageCount;

  /// 图片总数
  final int? imageCount;

  /// UI关联的全局键
  final GlobalKey globalKey;

  /// 构造函数
  KnowledgePoint({
    required this.uid,
    this.userId,
    this.content,
    this.contentType,
    this.typeTitle,
    this.status,
    this.statusTitle,
    this.nickName,
    this.oneself,
    this.updated,
    this.reviewedImageCount,
    this.imageCount,
  }) : globalKey = GlobalKey(debugLabel: uid.toString());

  factory KnowledgePoint.fromJson(Map<String, dynamic> json) {
    return KnowledgePoint(
      uid: json['uid'] ?? 0,
      userId: json["userId"],
      content: json['content'] as String?,
      contentType: json['contentType'] as String?,
      typeTitle: json['typeTitle'] as String?,
      status: json['status'] as String?,
      statusTitle: json['statusTitle'] as String?,
      nickName: json['nickName'] as String?,
      oneself: json['oneself'] as bool?,
      updated: json['updated'] as String?,
      reviewedImageCount: json['reviewedImageCount'] as int?,
      imageCount: json['imageCount'] as int?,
    );
  }

  /// 审核状态
  ReviewStatus get reviewStatus => ReviewStatus.fromString(status ?? '');

  /// 知识点类型
  KnowledgeType get knowledgeType => KnowledgeType.fromValue(contentType ?? '');

  /// 状态颜色
  Color get statusColor => _getStatusColor(reviewStatus);

  /// 格式化的更新时间
  String get newUpdate {
    if (updated == null) {
      return '';
    }

    return DateUtil.formatDateStr(updated!, format: "yyyy-MM-dd");
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'userId': userId,
      'content': content,
      'contentType': contentType,
      'typeTitle': typeTitle,
      'status': status,
      'statusTitle': statusTitle,
      'updated': updated,
      'nickName': nickName,
      'oneself': oneself,
      'reviewedImageCount': reviewedImageCount,
      'imageCount': imageCount,
    };
  }

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is KnowledgePoint && other.uid == uid;
  }

  /// 哈希值
  @override
  int get hashCode => Object.hash(runtimeType, uid);
}

/// 知识点详情实体
class KnowledgePointDetail {
  /// 知识点ID
  final int uid;

  /// 英文
  final String? content;

  /// 类型中文
  final String? contentType;

  /// 图片数量
  final int? imageCount;

  // 已审核数量
  final int? reviewedCount;

  /// 词性组列表
  final List<PosGroup>? contentPosList;

  /// 是否可批量审核
  final bool? batchStatus;

  /// 更新时间
  final String? updated;

  /// UI关联的全局键
  final GlobalKey globalKey;

  /// 构造函数
  KnowledgePointDetail({
    required this.uid,
    this.content,
    this.contentType,
    this.imageCount,
    this.reviewedCount,
    this.contentPosList,
    this.batchStatus,
    this.updated,
  }) : globalKey = GlobalKey(debugLabel: uid.toString());

  factory KnowledgePointDetail.fromJson(Map<String, dynamic> json) {
    // 解析posGroups字段
    List<PosGroup>? contentPosList;
    if (json['contentPosList'] != null) {
      contentPosList =
          (json['contentPosList'] as List).map((item) => PosGroup.fromJson(item as Map<String, dynamic>)).toList();
    }

    return KnowledgePointDetail(
      uid: json['uid'] ?? 0,
      content: json['content'] as String?,
      contentType: json['contentType'] as String?,
      imageCount: json['imageCount'] as int?,
      reviewedCount: json['reviewedCount'] as int?,
      contentPosList: contentPosList,
      batchStatus: json['batchStatus'],
      updated: json['updated'] as String?,
    );
  }

  /// 知识点类型
  KnowledgeType get knowledgeType => KnowledgeType.fromValue(contentType ?? '');

  /// 格式化的更新时间
  String get newUpdate {
    if (updated == null) {
      return '';
    }

    return DateUtil.formatDateStr(updated!, format: "yyyy-MM-dd");
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'content': content,
      'contentType': contentType,
      'imageCount': imageCount,
      'reviewedCount': reviewedCount,
      'contentPosList': contentPosList?.map((group) => group.toJson()).toList(),
      'batchStatus': batchStatus,
      'updated': updated,
    };
  }

  /// 获取批量处理状态
  bool get canBatchReview => batchStatus ?? false;

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is KnowledgePoint && other.uid == uid;
  }

  /// 哈希值
  @override
  int get hashCode => Object.hash(runtimeType, uid);

  /// 获取所有图片
  List<ImageItem> getAllImages() {
    List<ImageItem> allImages = [];

    if (contentPosList == null) return allImages;

    for (var posGroup in contentPosList!) {
      for (var semantic in posGroup.semanticList) {
        allImages.addAll(semantic.images);
      }
    }

    return allImages;
  }
}

/// 子介绍项分类模型
class SubIntroduceCategory {
  /// 分类名称
  final String category;

  /// 分类下的项目列表
  final List<String> items;

  SubIntroduceCategory({
    required this.category,
    required this.items,
  });

  /// 从JSON创建实体
  factory SubIntroduceCategory.fromJson(Map<String, dynamic> json) {
    return SubIntroduceCategory(
      category: json['category'] as String,
      items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'items': items,
    };
  }
}

/// 评分选项模型
class RatingOption {
  /// 标题
  final String title;

  /// 评分值
  final int imageScore;

  /// 子介绍项分类列表
  final List<SubIntroduceCategory> subIntroduces;

  /// 是否选中
  bool isSelected;

  RatingOption({
    required this.title,
    required this.imageScore,
    this.subIntroduces = const [],
    this.isSelected = false,
  });

  /// 从JSON创建实体
  factory RatingOption.fromJson(Map<String, dynamic> json) {
    return RatingOption(
      title: json['title'] as String,
      imageScore: json['imageScore'] as int? ?? 0,
      subIntroduces: json['subIntroduces'] != null
          ? (json['subIntroduces'] as List<dynamic>)
              .map((e) => SubIntroduceCategory.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imageScore': imageScore,
      'subIntroduces': subIntroduces.map((e) => e.toJson()).toList(),
    };
  }

  /// 创建选中状态的副本
  RatingOption copyWith({bool? isSelected}) {
    return RatingOption(
      title: title,
      imageScore: imageScore,
      subIntroduces: subIntroduces,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// 根据星级获取颜色
  Color get color => getStarColor(imageScore);
}
