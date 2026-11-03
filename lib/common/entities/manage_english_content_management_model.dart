class ManageEnglishContentManagementModel {
  final String? contentType;
  final String? typeName;
  final String? describe;
  final int? count;

  ManageEnglishContentManagementModel({
    this.contentType,
    this.typeName,
    this.describe,
    this.count,
  });

  factory ManageEnglishContentManagementModel.fromJson(
      Map<String, dynamic> json) {
    return ManageEnglishContentManagementModel(
      contentType: json['contentType'] as String?,
      typeName: json['typeName'] as String?,
      describe: json['describe'] as String?,
      count: json['count'] as int?,
    );
  }
}
