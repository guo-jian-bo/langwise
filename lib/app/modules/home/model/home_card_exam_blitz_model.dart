
import 'package:get/get.dart';

import '../../../../common/entities/entities.dart';


class HomeCardExamBlitzListModel {
  HomeCardExamBlitzModel data;
  Rx<DateTime> calendarCurrentMonth;
  HomeCardExamBlitzListModel({
    required this.data,
    required this.calendarCurrentMonth,
  });
}


class HomeCardExamBlitzModelData {
/*
{
  "uid": 8,
  "name": "435",
  "language": "en",
  "examDate": "2025-06-24T00:00:00.000+00:00",
  "startPrepDate": "2025-06-17T00:00:00.000+00:00",
  "dailyDuration": 1000,
  "nextDay": 0,
  "timeSlots": [
    {
      "date": "2025-06-17",
      "hour": 8,
      "minute": 52,
      "daysFromStart": 0,
      "reviewNumber": 1
    }
  ],
  "updated": "2025-06-17T00:53:25.490+00:00"
} 
*/

  int? uid;
  String? name;
  String? language;
  String? examDate;
  String? startPrepDate;
  int? dailyDuration;
  int? nextDay;
  String? status;
  List<PreparationPlanTimeSlots?>? timeSlots;
  String? updated;

  bool get isDoing => status == "doing";

  HomeCardExamBlitzModelData({
    this.uid,
    this.name,
    this.language,
    this.examDate,
    this.startPrepDate,
    this.dailyDuration,
    this.nextDay,
    this.status,
    this.timeSlots,
    this.updated,
  });
  HomeCardExamBlitzModelData.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    name = json['name']?.toString();
    language = json['language']?.toString();
    examDate = json['examDate']?.toString();
    startPrepDate = json['startPrepDate']?.toString();
    dailyDuration = json['dailyDuration']?.toInt();
    nextDay = json['nextDay']?.toInt();
    status = json['status']?.toString();
    if (json['timeSlots'] != null) {
      final v = json['timeSlots'];
      final arr0 = <PreparationPlanTimeSlots>[];
      v.forEach((v) {
        arr0.add(PreparationPlanTimeSlots.fromJson(v));
      });
      timeSlots = arr0;
    }
    updated = json['updated']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['name'] = name;
    data['language'] = language;
    data['examDate'] = examDate;
    data['startPrepDate'] = startPrepDate;
    data['dailyDuration'] = dailyDuration;
    data['nextDay'] = nextDay;
    data['status'] = status;
    if (timeSlots != null) {
      final v = timeSlots;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['timeSlots'] = arr0;
    }
    data['updated'] = updated;
    return data;
  }
}

class HomeCardExamBlitzModel {
/*
{
  "title": {
    "text": "435",
    "style": [
      {
        "theme": "DARK",
        "color": "rgba(255, 255, 255, 1)",
        "fontsize": 36,
        "italic": false,
        "weight": 600
      }
    ]
  },
  "data": {
    "uid": 8,
    "name": "435",
    "language": "en",
    "examDate": "2025-06-24T00:00:00.000+00:00",
    "startPrepDate": "2025-06-17T00:00:00.000+00:00",
    "dailyDuration": 1000,
    "nextDay": 0,
    "timeSlots": [
      {
        "date": "2025-06-17",
        "hour": 8,
        "minute": 52,
        "daysFromStart": 0,
        "reviewNumber": 1
      }
    ],
    "updated": "2025-06-17T00:53:25.490+00:00"
  }
} 
*/

  ThemeTextEntity? title;
  HomeCardExamBlitzModelData? data;

  HomeCardExamBlitzModel({
    this.title,
    this.data,
  });
  HomeCardExamBlitzModel.fromJson(Map<String, dynamic> json) {
    title = (json['title'] != null)
        ? ThemeTextEntity.fromJson(json['title'])
        : null;
    data = (json['data'] != null)
        ? HomeCardExamBlitzModelData.fromJson(json['data'])
        : null;
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
