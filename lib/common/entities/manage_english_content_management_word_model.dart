class ManageEnglishContentManagementLanguageModel {
  String? code;
  String? title;
  String? english;
  String? nativeName;

  ManageEnglishContentManagementLanguageModel({
    this.code,
    this.title,
    this.english,
    this.nativeName,
  });

  factory ManageEnglishContentManagementLanguageModel.fromJson(
      Map<String, dynamic> json) {
    return ManageEnglishContentManagementLanguageModel(
      code: json['code'] as String?,
      title: json['title'] as String?,
      english: json['english'] as String?,
      nativeName: json['nativeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    data['title'] = title;
    data['english'] = english;
    data['nativeName'] = nativeName;
    return data;
  }
}

class ManageEnglishContentManagementGlossModel {
  String? lang;
  String? text;

  ManageEnglishContentManagementGlossModel({
    this.lang,
    this.text,
  });

  factory ManageEnglishContentManagementGlossModel.fromJson(
      Map<String, dynamic> json) {
    return ManageEnglishContentManagementGlossModel(
      lang: json['lang'] as String?,
      text: json['text'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['lang'] = lang;
    data['text'] = text;
    return data;
  }
}
