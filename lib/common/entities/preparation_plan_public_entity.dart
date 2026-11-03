
class PreparationPlanTimeSlots {
/*
{
  "date": "2025-06-12",
  "hour": 12,
  "minute": 31,
  "daysFromStart": 0,
  "reviewNumber": 1,
  "status": "waiting", //waiting, start, finish, expired
} 
*/

  String? date;
  int? hour;
  int? minute;
  int? daysFromStart;
  int? reviewNumber;
  String? status;
  int? currentExerciseId;

  bool get isWaiting => status == "waiting";
  bool get isStart => status == "start";
  bool get isFinish => status == "finish";
  bool get isExpired => status == "expired";

  PreparationPlanTimeSlots({
    this.date,
    this.hour,
    this.minute,
    this.daysFromStart,
    this.reviewNumber,
    this.status,
    this.currentExerciseId,
  });
  PreparationPlanTimeSlots.fromJson(Map<String, dynamic> json) {
    date = json['date']?.toString();
    hour = json['hour']?.toInt();
    minute = json['minute']?.toInt();
    daysFromStart = json['daysFromStart']?.toInt();
    reviewNumber = json['reviewNumber']?.toInt();
    status = json['status']?.toString();
    currentExerciseId = json['currentExerciseId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['hour'] = hour;
    data['minute'] = minute;
    data['daysFromStart'] = daysFromStart;
    data['reviewNumber'] = reviewNumber;
    data['status'] = status;
    data['currentExerciseId'] = currentExerciseId;
    return data;
  }
}
