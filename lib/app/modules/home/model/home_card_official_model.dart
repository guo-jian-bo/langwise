import '../../../../common/entities/entities.dart';

class HomeCardOfficialModel {
  ThemeTextEntity? title;
  HomeCardOfficialDataModel? data;

  HomeCardOfficialModel({
    this.title,
    this.data,
  });
  HomeCardOfficialModel.fromJson(Map<String, dynamic> json) {
    title = (json['title'] != null) ? ThemeTextEntity.fromJson(json['title']) : null;
    data = (json['data'] != null) ? HomeCardOfficialDataModel.fromJson(json['data']) : null;
  }
  Map<String, dynamic> toJson() {
    final jsonData = <String, dynamic>{};
    if (title != null) {
      jsonData['title'] = title!.toJson();
    }
    if (data != null) {
      jsonData['data'] = data!.toJson();
    }
    return jsonData;
  }
}

class HomeCardOfficialDataModel {
  List<HomeCardOfficialDataModuleInfoModel?>? moduleInfoList;
  HomeCardOfficialDataModel({
    this.moduleInfoList,
  });
  HomeCardOfficialDataModel.fromJson(Map<String, dynamic> json) {
    if (json['moduleInfoList'] != null) {
      final v = json['moduleInfoList'];
      final arr0 = <HomeCardOfficialDataModuleInfoModel>[];
      v.forEach((v) {
        arr0.add(HomeCardOfficialDataModuleInfoModel.fromJson(v));
      });
      moduleInfoList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (moduleInfoList != null) {
      final v = moduleInfoList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['moduleInfoList'] = arr0;
    }
    return data;
  }
}

class HomeCardOfficialDataModuleInfoModel {
  int? courseId;
  int? moduleId;
  int? levelId;
  String? moduleName;
  String? moduleCoverUrl;

  HomeCardOfficialDataModuleInfoModel({
    this.courseId,
    this.moduleId,
    this.levelId,
    this.moduleName,
    this.moduleCoverUrl,
  });
  HomeCardOfficialDataModuleInfoModel.fromJson(Map<String, dynamic> json) {
    courseId = json['courseId']?.toInt();
    moduleId = json['moduleId']?.toInt();
    levelId = json['levelId']?.toInt();
    moduleName = json['moduleName']?.toString();
    moduleCoverUrl = json['moduleCoverUrl']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['courseId'] = courseId;
    data['moduleId'] = moduleId;
    data['levelId'] = levelId;
    data['moduleName'] = moduleName;
    data['moduleCoverUrl'] = moduleCoverUrl;
    return data;
  }
}
