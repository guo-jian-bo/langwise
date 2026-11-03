

import 'package:langwise/common/entities/entities.dart';

class ManageCreateQuizModel {
  List<ManageCreateQuizThemesModel>? themes;
  List<ManageCreateQuizGenresModel>? genres;
  List<String>? cefrLevels;

  ManageCreateQuizModel.from({
    this.themes,
    this.genres,
    this.cefrLevels,
  });

  factory ManageCreateQuizModel.fromJson(Map<String, dynamic> json) {
    return ManageCreateQuizModel.from(
      themes: json['themes'] != null ? (json['themes'] as List).map((e) => ManageCreateQuizThemesModel.fromJson(e)).toList() : null,
      genres: json['genres'] != null ? (json['genres'] as List).map((e) => ManageCreateQuizGenresModel.fromJson(e)).toList() : null,
      cefrLevels: json['cefrLevels'] != null ? List<String>.from(json['cefrLevels']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themes': themes?.map((e) => e.toJson()).toList(),
      'genres': genres?.map((e) => e.toJson()).toList(),
      'cefrLevels': cefrLevels,
    };
  }
}

class ManageCreateQuizThemesModel {
  List<LanguageText>? description;
  List<LanguageText>? name;

  ManageCreateQuizThemesModel.from({
    this.description,
    this.name,
  });

  factory ManageCreateQuizThemesModel.fromJson(Map<String, dynamic> json) {
    return ManageCreateQuizThemesModel.from(
      description: json['description'] != null ? (json['description'] as List).map((e) => LanguageText.fromJson(e)).toList() : null,
      name: json['name'] != null ? (json['name'] as List).map((e) => LanguageText.fromJson(e)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description?.map((e) => e.toJson()).toList(),
      'name': name?.map((e) => e.toJson()).toList(),
    };
  }
}

class ManageCreateQuizGenresModel {
  List<LanguageText>? description;
  List<LanguageText>? name;

  ManageCreateQuizGenresModel.from({
    this.description,
    this.name,
  });

  factory ManageCreateQuizGenresModel.fromJson(Map<String, dynamic> json) {
    return ManageCreateQuizGenresModel.from(
      description: json['description'] != null ? (json['description'] as List).map((e) => LanguageText.fromJson(e)).toList() : null,
      name: json['name'] != null ? (json['name'] as List).map((e) => LanguageText.fromJson(e)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description?.map((e) => e.toJson()).toList(),
      'name': name?.map((e) => e.toJson()).toList(),
    };
  }
}
