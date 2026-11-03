import 'package:langwise/common/entities/knowledge.dart';

class ManageBookWordListCheckKnowledgeResponseEntity {
  final List<KnowledgeInfo>? unitList;
  final KnowledgeInfo? stagingList;

  ManageBookWordListCheckKnowledgeResponseEntity({
    this.unitList,
    this.stagingList,
  });

  factory ManageBookWordListCheckKnowledgeResponseEntity.fromJson(
      Map<String, dynamic> json) {
    return ManageBookWordListCheckKnowledgeResponseEntity(
      unitList: json['unitList'] != null
          ? (json['unitList'] as List)
              .map((e) => KnowledgeInfo<Knowledge>.fromJson(e,
                  fromJson: (json) => Knowledge.fromJson(json)))
              .toList()
          : null,
      stagingList: json['stagingList'] != null
          ? KnowledgeInfo<Knowledge>.fromJson(json['stagingList'],
              fromJson: (json) => Knowledge.fromJson(json))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "unitList": unitList,
        "stagingList": stagingList,
      };
}

class ManageBookWordListAddKnowledgeResponseEntity {
  final KnowledgeInfo? stagingList;

  ManageBookWordListAddKnowledgeResponseEntity({
    this.stagingList,
  });

  factory ManageBookWordListAddKnowledgeResponseEntity.fromJson(
      Map<String, dynamic> json) {
    return ManageBookWordListAddKnowledgeResponseEntity(
      stagingList: json['stagingList'] != null
          ? KnowledgeInfo<Knowledge>.fromJson(json['stagingList'],
              fromJson: (json) => Knowledge.fromJson(json))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "stagingList": stagingList,
      };
}
