import 'unit_image_prompt_detail.dart';

/// 图片重新生成配置模型
/// 用于封装重新生成图片所需的配置信息
class ImageRegenerationConfig {
  /// 子内容信息
  final SubContent? subContent;

  /// 提示词ID
  final int? promptId;

  /// 提示词内容
  final String? prompt;

  /// 任务ID
  final int? taskId;

  /// 构造函数
  ///
  /// [subContent] 子内容信息
  /// [promptId] 提示词ID
  /// [prompt] 提示词内容
  /// [taskId] 任务ID
  ImageRegenerationConfig({
    this.subContent,
    this.promptId,
    this.prompt,
    this.taskId,
  });

  /// 从UnitImagePromptDetail创建实例
  ///
  /// [detail] 单元图片提示词详情
  /// 返回 [ImageRegenerationConfig] 实例
  factory ImageRegenerationConfig.fromUnitImagePromptDetail(UnitImagePromptDetail detail) {
    return ImageRegenerationConfig(
      subContent: detail.subContent,
      promptId: detail.promptId,
      prompt: detail.prompt,
      taskId: null,
    );
  }

  /// 从JSON创建实例
  ///
  /// [json] JSON数据映射
  /// 返回 [ImageRegenerationConfig] 实例
  factory ImageRegenerationConfig.fromJson(Map<String, dynamic> json) {
    return ImageRegenerationConfig(
      subContent: json['subContent'] != null ? SubContent.fromJson(json['subContent'] as Map<String, dynamic>) : null,
      promptId: json['promptId'] as int?,
      prompt: json['prompt'] as String?,
      taskId: json['taskId'] as int?,
    );
  }

  /// 转换为JSON
  ///
  /// 返回包含所有字段的JSON映射
  Map<String, dynamic> toJson() {
    return {
      'subContent': subContent?.toJson(),
      'promptId': promptId,
      'prompt': prompt,
      'taskId': taskId,
    };
  }

  /// 复制并修改部分字段
  ///
  /// 返回新的 [ImageRegenerationConfig] 实例
  ImageRegenerationConfig copyWith({
    SubContent? subContent,
    int? promptId,
    String? prompt,
    int? taskId,
  }) {
    return ImageRegenerationConfig(
      subContent: subContent ?? this.subContent,
      promptId: promptId ?? this.promptId,
      prompt: prompt ?? this.prompt,
      taskId: taskId ?? this.taskId,
    );
  }

  /// 验证配置是否有效
  ///
  /// 返回配置是否包含必要的信息
  bool isValid() {
    return prompt != null && prompt!.trim().isNotEmpty;
  }

  @override
  String toString() {
    return 'ImageRegenerationConfig(subContent: $subContent, promptId: $promptId, prompt: $prompt, taskId: $taskId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageRegenerationConfig &&
        other.subContent == subContent &&
        other.promptId == promptId &&
        other.prompt == prompt;
  }

  @override
  int get hashCode => Object.hash(subContent, promptId, prompt);
}
