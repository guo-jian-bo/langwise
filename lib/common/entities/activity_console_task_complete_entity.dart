class ActivityConsoleTaskCompleteOperationEntity {
  final String? operationType;
  final String? priceType;
  final String? title;
  final String? description;
  final List<String> values;
  final String? prizeName;
  final String? prizeDescription;

  const ActivityConsoleTaskCompleteOperationEntity({
    this.operationType,
    this.priceType,
    this.title,
    this.description,
    this.values = const [],
    this.prizeName,
    this.prizeDescription,
  });

  factory ActivityConsoleTaskCompleteOperationEntity.fromJson(Map<String, dynamic> json) {
    final rawValues = json['values'];
    final values = <String>[];
    if (rawValues is List) {
      for (final v in rawValues) {
        final s = v?.toString();
        if (s != null && s.isNotEmpty) values.add(s);
      }
    }

    return ActivityConsoleTaskCompleteOperationEntity(
      operationType: json['operationType']?.toString(),
      priceType: json['priceType']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      values: values,
      prizeName: json['prizeName']?.toString(),
      prizeDescription: json['prizeDescription']?.toString(),
    );
  }
}

class ActivityConsoleTaskCompleteDataEntity {
  final String? taskCode;
  final bool eligible;
  final bool completed;
  final bool rewarded;
  final List<ActivityConsoleTaskCompleteOperationEntity> operation;

  const ActivityConsoleTaskCompleteDataEntity({
    this.taskCode,
    this.eligible = false,
    this.completed = false,
    this.rewarded = false,
    this.operation = const [],
  });

  factory ActivityConsoleTaskCompleteDataEntity.fromJson(Map<String, dynamic> json) {
    final rawOps = json['operation'];
    final ops = <ActivityConsoleTaskCompleteOperationEntity>[];
    if (rawOps is List) {
      for (final v in rawOps) {
        if (v is Map<String, dynamic>) {
          ops.add(ActivityConsoleTaskCompleteOperationEntity.fromJson(v));
        }
      }
    }

    final rewarded = json['rewarded'];

    return ActivityConsoleTaskCompleteDataEntity(
      taskCode: json['taskCode']?.toString(),
      eligible: json['eligible'] == true,
      completed: json['completed'] == true,
      rewarded: rewarded == true,
      operation: ops,
    );
  }
}
