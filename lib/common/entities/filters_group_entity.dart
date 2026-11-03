

import 'entities.dart';

class FiltersGroupEntityValues {
/*
{
  "value": "-uid",
  "name": "最新创建",
  "names": [
    {
      "lang": "en",
      "text": "最新创建"
    }
  ],
  "defaultValue": false
} 
*/

  String? value;
  String? name;
  List<LanguageText?>? names;
  bool? defaultValue;

  FiltersGroupEntityValues({
    this.value,
    this.name,
    this.names,
    this.defaultValue,
  });
  FiltersGroupEntityValues.fromJson(Map<String, dynamic> json) {
    value = json['value']?.toString();
    name = json['name']?.toString();
    if (json['names'] != null) {
      final v = json['names'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      names = arr0;
    }
    defaultValue = json['defaultValue'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['value'] = value;
    data['name'] = name;
    if (names != null) {
      final v = names;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['names'] = arr0;
    }
    data['defaultValue'] = defaultValue;
    return data;
  }
}

class FiltersGroupEntityFilters {
/*
{
  "code": "supportsPyramid",
  "name": "支持金字塔",
  "component": "radio",
  "radioGroup": true,
  "values": [
    {
      "value": "true",
      "name": "支持",
      "names": [
        {
          "lang": "en",
          "text": "支持"
        }
      ],
      "defaultValue": false
    }
  ]
} 
*/

  String? code;
  String? name;
  String? component;
  bool? radioGroup;
  List<FiltersGroupEntityValues?>? values;

  FiltersGroupEntityFilters({
    this.code,
    this.name,
    this.component,
    this.radioGroup,
    this.values,
  });
  FiltersGroupEntityFilters.fromJson(Map<String, dynamic> json) {
    code = json['code']?.toString();
    name = json['name']?.toString();
    component = json['component']?.toString();
    radioGroup = json['radioGroup'];
    if (json['values'] != null) {
      final v = json['values'];
      final arr0 = <FiltersGroupEntityValues>[];
      v.forEach((v) {
        arr0.add(FiltersGroupEntityValues.fromJson(v));
      });
      values = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    data['name'] = name;
    data['component'] = component;
    data['radioGroup'] = radioGroup;
    if (values != null) {
      final v = values;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['values'] = arr0;
    }
    return data;
  }
}

class FiltersGroupEntity {
/*
{
  "filters": [
    {
      "code": "supportsPyramid",
      "name": "支持金字塔",
      "component": "radio",
      "radioGroup": true,
      "values": [
        {
          "value": "true",
          "name": "支持",
          "names": [
            {
              "lang": "en",
              "text": "支持"
            }
          ],
          "defaultValue": false
        }
      ]
    }
  ],
  "orders": [
    {
      "code": "sort",
      "name": "排序",
      "component": "radio",
      "radioGroup": true,
      "values": [
        {
          "value": "-uid",
          "name": "最新创建",
          "names": [
            {
              "lang": "en",
              "text": "最新创建"
            }
          ],
          "defaultValue": false
        }
      ]
    }
  ]
} 
*/

  List<FiltersGroupEntityFilters?>? filters;
  List<FiltersGroupEntityFilters?>? orders;

  FiltersGroupEntity({
    this.filters,
    this.orders,
  });
  FiltersGroupEntity.fromJson(Map<String, dynamic> json) {
    if (json['filters'] != null) {
      final v = json['filters'];
      final arr0 = <FiltersGroupEntityFilters>[];
      v.forEach((v) {
        arr0.add(FiltersGroupEntityFilters.fromJson(v));
      });
      filters = arr0;
    }
    if (json['orders'] != null) {
      final v = json['orders'];
      final arr0 = <FiltersGroupEntityFilters>[];
      v.forEach((v) {
        arr0.add(FiltersGroupEntityFilters.fromJson(v));
      });
      orders = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (filters != null) {
      final v = filters;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['filters'] = arr0;
    }
    if (orders != null) {
      final v = orders;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['orders'] = arr0;
    }
    return data;
  }
}
