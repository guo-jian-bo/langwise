import 'json.dart';

/// 复用词汇知识点请求参数实体
///
/// 用于封装复用词汇知识点API的请求参数
class ReuseVocabularyKnowledgeParamEntity with JsonSerializableMixin {
  /// 服务套餐ID
  final int? servicePackageId;

  /// 服务套餐版本
  final int? servicePackageVersion;

  /// 构造函数
  ///
  /// [servicePackageId] 服务套餐ID
  /// [servicePackageVersion] 服务套餐版本
  ReuseVocabularyKnowledgeParamEntity({
    this.servicePackageId,
    this.servicePackageVersion,
  });

  /// 从JSON创建实例
  ///
  /// [json] JSON数据映射
  /// 返回 [ReuseVocabularyKnowledgeParamEntity] 实例
  factory ReuseVocabularyKnowledgeParamEntity.fromJson(Map<String, dynamic> json) {
    return ReuseVocabularyKnowledgeParamEntity(
      servicePackageId: json['servicePackageId']?.toInt(),
      servicePackageVersion: json['servicePackageVersion']?.toInt(),
    );
  }

  /// 转换为JSON
  ///
  /// 返回包含实体数据的JSON映射
  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['servicePackageId'] = servicePackageId;
    data['servicePackageVersion'] = servicePackageVersion;
    return data;
  }

  /// 字符串表示
  ///
  /// 返回对象的字符串描述
  @override
  String toString() {
    return 'ReuseVocabularyKnowledgeParamEntity('
        'servicePackageId: $servicePackageId, '
        'servicePackageVersion: $servicePackageVersion)';
  }
}

/// 复用词汇知识点响应实体
///
/// 用于封装复用词汇知识点API的响应数据
class ReuseVocabularyKnowledgeResponseEntity with JsonSerializableMixin {
  /// 状态码
  final String? status;

  /// 请求参数
  final ReuseVocabularyKnowledgeParamEntity? param;

  /// 任务ID
  final int? taskId;

  /// 构造函数
  ///
  /// [status] 状态码
  /// [param] 请求参数
  /// [taskId] 任务ID
  ReuseVocabularyKnowledgeResponseEntity({
    this.status,
    this.param,
    this.taskId,
  });

  /// 从JSON创建实例
  ///
  /// [json] JSON数据映射
  /// 返回 [ReuseVocabularyKnowledgeResponseEntity] 实例
  factory ReuseVocabularyKnowledgeResponseEntity.fromJson(Map<String, dynamic> json) {
    return ReuseVocabularyKnowledgeResponseEntity(
      status: json['status']?.toString(),
      param: json['param'] != null ? ReuseVocabularyKnowledgeParamEntity.fromJson(json['param']) : null,
      taskId: json['taskId']?.toInt(),
    );
  }

  /// 转换为JSON
  ///
  /// 返回包含实体数据的JSON映射
  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    if (param != null) {
      data['param'] = param!.toJson();
    }
    data['taskId'] = taskId;
    return data;
  }

  /// 字符串表示
  ///
  /// 返回对象的字符串描述
  @override
  String toString() {
    return 'ReuseVocabularyKnowledgeResponseEntity('
        'status: $status, '
        'param: $param, '
        'taskId: $taskId)';
  }

  /// 复制并修改部分属性
  ///
  /// [status] 新的状态码
  /// [param] 新的请求参数
  /// [taskId] 新的任务ID
  /// 返回修改后的新实例
  ReuseVocabularyKnowledgeResponseEntity copyWith({
    String? status,
    ReuseVocabularyKnowledgeParamEntity? param,
    int? taskId,
  }) {
    return ReuseVocabularyKnowledgeResponseEntity(
      status: status ?? this.status,
      param: param ?? this.param,
      taskId: taskId ?? this.taskId,
    );
  }

  /// 检查是否为未支付状态
  ///
  /// 返回是否为未支付状态
  bool get isUnpaid => status == 'UNPAY';

  /// 检查是否为支付成功状态
  ///
  /// 返回是否为支付成功状态
  bool get isSUCCESS => status == 'SUCCESS';

  /// 检查是否有有效的任务ID
  ///
  /// 返回是否有有效的任务ID
  bool get hasValidTaskId => taskId != null && taskId! > 0;
}
