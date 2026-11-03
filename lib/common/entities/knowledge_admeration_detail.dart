import 'package:langwise/common/entities/entities.dart';

/// 知识审核详情模型
/// 用于封装知识内容的审核信息，包含内容、图片等详细数据
class KnowledgeAdmerationDetail {
  /// 用户ID
  final int? userId;

  /// 内容文本
  final String? content;

  /// 内容类型（如：EN_WORD表示英文单词）
  final String? contentType;

  /// 图片总数量
  final int? imageCount;

  /// 批处理状态
  final bool? batchStatus;

  /// 已审核数量
  final int? reviewedCount;

  /// 内容位置列表，包含不同风格和地区的图片分组
  final List<ContentPosition>? contentPosList;

  /// 子内容信息
  final SubContent? subContent;

  /// 构造函数
  ///
  /// [userId] 用户ID
  /// [content] 内容文本
  /// [contentType] 内容类型
  /// [imageCount] 图片总数量
  /// [batchStatus] 批处理状态
  /// [reviewedCount] 已审核数量
  /// [contentPosList] 内容位置列表
  /// [subContent] 子内容信息
  KnowledgeAdmerationDetail({
    this.userId,
    this.content,
    this.contentType,
    this.imageCount,
    this.batchStatus,
    this.reviewedCount,
    this.contentPosList,
    this.subContent,
  });

  /// 从JSON创建实例
  ///
  /// [json] JSON数据映射
  /// 返回 [KnowledgeAdmerationDetail] 实例
  factory KnowledgeAdmerationDetail.fromJson(Map<String, dynamic> json) {
    return KnowledgeAdmerationDetail(
      userId: json['userId'] as int?,
      content: json['content'],
      contentType: json['contentType'],
      imageCount: json['imageCount'],
      batchStatus: json['batchStatus'],
      reviewedCount: json['reviewedCount'],
      contentPosList: (json['contentPosList'] as List<dynamic>?)
          ?.map((item) => ContentPosition.fromJson(item as Map<String, dynamic>))
          .toList(),
      subContent: json['subContent'] != null ? SubContent.fromJson(json['subContent'] as Map<String, dynamic>) : null,
    );
  }

  /// 转换为JSON
  ///
  /// 返回包含所有字段的JSON映射
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'content': content,
      'contentType': contentType,
      'imageCount': imageCount,
      'batchStatus': batchStatus,
      'reviewedCount': reviewedCount,
      'contentPosList': contentPosList?.map((item) => item.toJson()).toList(),
      'subContent': subContent?.toJson(),
    };
  }

  /// 复制并修改部分字段
  ///
  /// 返回新的 [KnowledgeAdmerationDetail] 实例
  KnowledgeAdmerationDetail copyWith({
    int? userId,
    String? content,
    String? contentType,
    int? imageCount,
    bool? batchStatus,
    int? reviewedCount,
    List<ContentPosition>? contentPosList,
    SubContent? subContent,
  }) {
    return KnowledgeAdmerationDetail(
      userId: userId ?? this.userId,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      imageCount: imageCount ?? this.imageCount,
      batchStatus: batchStatus ?? this.batchStatus,
      reviewedCount: reviewedCount ?? this.reviewedCount,
      contentPosList: contentPosList ?? this.contentPosList,
      subContent: subContent ?? this.subContent,
    );
  }

  @override
  String toString() {
    return 'KnowledgeAdmerationDetail(content: $content, contentType: $contentType, imageCount: $imageCount, batchStatus: $batchStatus, reviewedCount: $reviewedCount, contentPosList: $contentPosList, subContent: $subContent)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KnowledgeAdmerationDetail &&
        other.userId == userId &&
        other.content == content &&
        other.contentType == contentType &&
        other.imageCount == imageCount &&
        other.batchStatus == batchStatus &&
        other.reviewedCount == reviewedCount &&
        other.contentPosList == contentPosList &&
        other.subContent == subContent;
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, userId, content, contentType, imageCount, batchStatus, reviewedCount, contentPosList, subContent);
}

/// 内容位置模型
/// 表示特定风格和地区的图片分组信息
class ContentPosition {
  /// 位置标题
  final String? posTitle;

  /// 标题（如："中国 照片"）
  final String? title;

  /// 描述信息（如："苹果 (水果)"）
  final String? description;

  /// 词性
  final String? pos;

  /// 图片模块类型（可为空）
  final String? imageModuleType;

  /// 语义列表（可为空）
  final List<dynamic>? semanticList;

  /// 图片列表
  final List<ImageItem>? images;

  /// 风格ID，用作唯一标识
  final int? styleId;

  /// 构造函数
  ///
  /// [posTitle] 位置标题
  /// [title] 标题
  /// [description] 描述信息
  /// [pos] 词性
  /// [imageModuleType] 图片模块类型
  /// [semanticList] 语义列表
  /// [images] 图片列表
  /// [styleId] 风格ID，用作唯一标识
  ContentPosition({
    this.posTitle,
    this.title,
    this.description,
    this.pos,
    this.imageModuleType,
    this.semanticList,
    this.images,
    this.styleId,
  });

  /// 从JSON创建实例
  ///
  /// [json] JSON数据映射
  /// 返回 [ContentPosition] 实例，其中images按审核状态和评分排序
  factory ContentPosition.fromJson(Map<String, dynamic> json) {
    // 解析图片列表并按审核状态和评分排序
    List<ImageItem>? imagesList;
    if (json['images'] != null) {
      // 先将所有图片转换为ImageItem对象
      final allImages =
          (json['images'] as List<dynamic>).map((item) => ImageItem.fromJson(item as Map<String, dynamic>)).toList();

      // 将图片分为未审核和已审核两组
      final unreviewed = allImages.where((img) => img.needsReview).toList();
      final reviewed = allImages.where((img) => !img.needsReview).toList();

      // 已审核的图片按星星数量降序排序
      reviewed.sort((a, b) => (b.imageScore ?? 0).compareTo(a.imageScore ?? 0));

      // 将未审核的图片放在前面，已审核的图片放在后面
      imagesList = [...unreviewed, ...reviewed];
    }

    return ContentPosition(
      posTitle: json['posTitle'],
      title: json['title'],
      description: json['description'],
      pos: json['pos'],
      imageModuleType: json['imageModuleType'],
      semanticList: json['semanticList'],
      images: imagesList,
      styleId: json['styleId'],
    );
  }

  /// 转换为JSON
  ///
  /// 返回包含所有字段的JSON映射
  Map<String, dynamic> toJson() {
    return {
      'posTitle': posTitle,
      'title': title,
      'description': description,
      'pos': pos,
      'imageModuleType': imageModuleType,
      'semanticList': semanticList,
      'images': images?.map((item) => item.toJson()).toList(),
      'styleId': styleId,
    };
  }

  /// 复制并修改部分字段
  ///
  /// 返回新的 [ContentPosition] 实例
  ContentPosition copyWith({
    String? posTitle,
    String? title,
    String? description,
    String? pos,
    String? imageModuleType,
    List<dynamic>? semanticList,
    List<ImageItem>? images,
    int? styleId,
  }) {
    return ContentPosition(
      posTitle: posTitle ?? this.posTitle,
      title: title ?? this.title,
      description: description ?? this.description,
      pos: pos ?? this.pos,
      imageModuleType: imageModuleType ?? this.imageModuleType,
      semanticList: semanticList ?? this.semanticList,
      images: images ?? this.images,
      styleId: styleId ?? this.styleId,
    );
  }

  @override
  String toString() {
    return 'ContentPosition(title: $title, description: $description, imageModuleType: $imageModuleType, semanticList: $semanticList, images: $images, styleId: $styleId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContentPosition && other.styleId == styleId;
  }

  @override
  int get hashCode => Object.hash(runtimeType, styleId);
}
