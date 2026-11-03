import 'assessment_result_detail_entity.dart';

class AssessmentHistoryPageEntity {
  final int? offset;
  final int? limit;
  final int? count;
  final List<AssessmentHistoryItemEntity> datas;

  const AssessmentHistoryPageEntity({
    this.offset,
    this.limit,
    this.count,
    this.datas = const [],
  });

  factory AssessmentHistoryPageEntity.fromJson(Map<String, dynamic> json) {
    final rawDatas = json['datas'];
    final list = <AssessmentHistoryItemEntity>[];
    if (rawDatas is List) {
      for (final item in rawDatas) {
        if (item is Map<String, dynamic>) {
          list.add(AssessmentHistoryItemEntity.fromJson(item));
        }
      }
    }

    return AssessmentHistoryPageEntity(
      offset: json['offset']?.toInt(),
      limit: json['limit']?.toInt(),
      count: json['count']?.toInt(),
      datas: list,
    );
  }
}

class AssessmentHistoryItemEntity {
  int? assessmentId;
  DateTime? assessmentDate;
  String? cefr;
  int? tier;
  List<AssessmentResultDetailEntityTierInfos?>? tierInfos;
  List<AssessmentResultDetailEntityTierSkills?>? tierSkills;

  AssessmentHistoryItemEntity({
    this.assessmentId,
    this.assessmentDate,
    this.cefr,
    this.tier,
    this.tierInfos,
    this.tierSkills,
  });

  AssessmentHistoryItemEntity.fromJson(Map<String, dynamic> json) {
    assessmentId = json['assessmentId']?.toInt();

    final dynamic rawDate = json['assessmentDate'];
    if (rawDate is DateTime) {
      assessmentDate = rawDate;
    } else if (rawDate is String) {
      assessmentDate = DateTime.tryParse(rawDate);
    } else if (rawDate != null) {
      assessmentDate = DateTime.tryParse(rawDate.toString());
    }

    cefr = json['cefr']?.toString();
    tier = json['tier']?.toInt();

    if (json['tierInfos'] != null) {
      final v = json['tierInfos'];
      final arr0 = <AssessmentResultDetailEntityTierInfos>[];
      if (v is List) {
        for (final item in v) {
          if (item is Map<String, dynamic>) {
            arr0.add(AssessmentResultDetailEntityTierInfos.fromJson(item));
          }
        }
      }
      tierInfos = arr0;
    }

    if (json['tierSkills'] != null) {
      final v = json['tierSkills'];
      final arr0 = <AssessmentResultDetailEntityTierSkills>[];
      if (v is List) {
        for (final item in v) {
          if (item is Map<String, dynamic>) {
            arr0.add(AssessmentResultDetailEntityTierSkills.fromJson(item));
          }
        }
      }
      tierSkills = arr0;
    }
  }
}
