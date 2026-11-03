/// 句型对照例句 AI 创建任务返回。
class SentencePatternCompareAiCreateEntity {
  String? status;
  String? message;
  String? error;
  int? taskId;

  SentencePatternCompareAiCreateEntity({
    this.status,
    this.message,
    this.error,
    this.taskId,
  });

  SentencePatternCompareAiCreateEntity.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    message = json['message']?.toString();
    error = json['error']?.toString();
    taskId = json['task_id']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['error'] = error;
    data['task_id'] = taskId;
    return data;
  }
}
