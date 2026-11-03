import 'moderation.dart';

/// 单元图片提示词详情模型
/// 用于封装单元的图片数据和历史图片数据
class UnitImagePromptDetail {
  /// 当前图片列表
  final List<ImageItem>? images;

  /// 历史图片列表（按批次分组）
  final List<List<ImageItem>>? historyImages;

  /// 子内容信息
  final SubContent? subContent;

  /// 提示词ID
  final int? promptId;

  /// 提示词内容
  final String? prompt;

  /// 状态
  final String? status;

  /// 历史ID列表
  final List<int>? historyIds;

  /// 图片风格ID
  final int? styleId;

  /// 构造函数
  ///
  /// [images] 当前图片列表
  /// [historyImages] 历史图片列表（按批次分组）
  /// [subContent] 子内容信息
  /// [promptId] 提示词ID
  /// [prompt] 提示词内容
  /// [status] 状态
  /// [historyIds] 历史ID列表
  /// [styleId] 图片风格ID
  UnitImagePromptDetail({
    this.images,
    this.historyImages,
    this.subContent,
    this.promptId,
    this.prompt,
    this.status,
    this.historyIds,
    this.styleId,
  });

  /// 从JSON创建实例
  ///
  /// [json] JSON数据映射
  /// 返回 [UnitImagePromptDetail] 实例
  factory UnitImagePromptDetail.fromJson(Map<String, dynamic> json) {
    List<List<ImageItem>>? parsedHistoryImages;

    if (json['historyImages'] != null) {
      final historyData = json['historyImages'] as List<dynamic>;
      // 新格式：List<List<Map>>
      parsedHistoryImages = historyData
          .map((batch) =>
              (batch as List<dynamic>).map((item) => ImageItem.fromJson(item as Map<String, dynamic>)).toList())
          .toList();
    }

    return UnitImagePromptDetail(
      images:
          (json['images'] as List<dynamic>?)?.map((item) => ImageItem.fromJson(item as Map<String, dynamic>)).toList(),
      historyImages: parsedHistoryImages,
      subContent: json['subContent'] != null ? SubContent.fromJson(json['subContent'] as Map<String, dynamic>) : null,
      promptId: json['promptId'] as int?,
      prompt: json['prompt'] as String?,
      status: json['status'] as String?,
      historyIds: (json['historyIds'] as List<dynamic>?)?.map((item) => item as int).toList(),
      styleId: json['styleId'] as int?,
    );
  }

  /// 转换为JSON
  ///
  /// 返回包含所有字段的JSON映射
  Map<String, dynamic> toJson() {
    return {
      'images': images?.map((item) => item.toJson()).toList(),
      'historyImages': historyImages?.map((batch) => batch.map((item) => item.toJson()).toList()).toList(),
      'subContent': subContent?.toJson(),
      'promptId': promptId,
      'prompt': prompt,
      'status': status,
      'historyIds': historyIds,
      'styleId': styleId,
    };
  }

  /// 复制并修改部分字段
  ///
  /// 返回新的 [UnitImagePromptDetail] 实例
  UnitImagePromptDetail copyWith({
    List<ImageItem>? images,
    List<List<ImageItem>>? historyImages,
    SubContent? subContent,
    int? promptId,
    String? prompt,
    String? status,
    List<int>? historyIds,
    int? styleId,
  }) {
    return UnitImagePromptDetail(
      images: images ?? this.images,
      historyImages: historyImages ?? this.historyImages,
      subContent: subContent ?? this.subContent,
      promptId: promptId ?? this.promptId,
      prompt: prompt ?? this.prompt,
      status: status ?? this.status,
      historyIds: historyIds ?? this.historyIds,
      styleId: styleId ?? this.styleId,
    );
  }

  /// 获取历史图片数量
  int get historyImageCount => historyImages?.fold<int>(0, (sum, batch) => sum + batch.length) ?? 0;

  /// 是否有图片ids数据
  bool get hasHistoryIds => (historyIds?.isNotEmpty ?? false);

  /// 是否有图片数据
  bool get hasImages => (images?.isNotEmpty ?? false);

  /// 是否有历史图片
  bool get hasHistoryImages => historyImages?.isNotEmpty == true && historyImages!.any((batch) => batch.isNotEmpty);

  /// 获取历史图片批次数量
  int get historyBatchCount => historyImages?.length ?? 0;

  @override
  String toString() {
    String promptDisplay = prompt != null ? (prompt!.length > 50 ? '${prompt!.substring(0, 50)}...' : prompt!) : 'null';
    return 'UnitImagePromptDetail(promptId: $promptId, prompt: $promptDisplay, status: $status, historyIds: $historyIds),images: ${images?.length ?? 0}, historyImages: ${historyBatchCount} batches (${historyImageCount} total), subContent: $subContent';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnitImagePromptDetail &&
        other.images == images &&
        other.historyImages == historyImages &&
        other.subContent == subContent &&
        other.promptId == promptId &&
        other.prompt == prompt &&
        other.status == status &&
        other.historyIds == historyIds &&
        other.styleId == styleId;
  }

  @override
  int get hashCode => Object.hash(images, historyImages, subContent, promptId, prompt, status, historyIds, styleId);
}

/// 子内容模型
/// 用于表示图片提示词的子内容信息
class SubContent {
  /// 内容类型
  final String? type;

  /// 唯一标识符
  final int? uid;

  /// 语义标识符
  final int? semanticId;

  /// 构造函数
  ///
  /// [type] 内容类型
  /// [uid] 唯一标识符
  /// [semanticId] 语义标识符
  SubContent({
    this.type,
    this.uid,
    this.semanticId,
  });

  /// 从JSON创建实例
  ///
  /// [json] JSON数据映射
  /// 返回 [SubContent] 实例
  factory SubContent.fromJson(Map<String, dynamic> json) {
    return SubContent(
      type: json['type'] as String?,
      uid: json['uid'] as int?,
      semanticId: json['semanticId'] as int?,
    );
  }

  /// 转换为JSON
  ///
  /// 返回包含所有字段的JSON映射
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'uid': uid,
      'semanticId': semanticId,
    };
  }

  /// 复制并修改部分字段
  ///
  /// 返回新的 [SubContent] 实例
  SubContent copyWith({
    String? type,
    int? uid,
    int? semanticId,
  }) {
    return SubContent(
      type: type ?? this.type,
      uid: uid ?? this.uid,
      semanticId: semanticId ?? this.semanticId,
    );
  }

  @override
  String toString() {
    return 'SubContent(type: $type, uid: $uid, semanticId: $semanticId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubContent && other.type == type && other.uid == uid && other.semanticId == semanticId;
  }

  @override
  int get hashCode => Object.hash(type, uid, semanticId);
}
