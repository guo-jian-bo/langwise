import '../../utils/utils.dart';

class DateTypeEnum{
  static const String updated = "updated";
  static const String created = "created";

  /// 全部
  static const String all = "all";

  /// 昨天
  static const String yesterday = "yesterday";

  /// 今天
  static const String today = "today";

  /// 最近3天
  static const String last_3_days = "last_3_days";

  /// 最近7天
  static const String last_7_days = "last_7_days";

  /// 最近14天
  static const String last_14_days = "last_14_days";

  /// 最近30天
  static const String last_30_days = "last_30_days";


  static DateTypeEnumResult? getFilterTimeRange(String initValue){
    DateTime now = DateTime.now();
    DateTime startTime = DateTime.now();
    DateTime endTime = DateTime.now();
    if(initValue == DateTypeEnum.all){
      return null;
    } else if(initValue == DateTypeEnum.yesterday){
      startTime = DateTime(now.year, now.month, now.day - 1);
      endTime = DateTime(now.year, now.month, now.day);
    }else if(initValue == DateTypeEnum.today){
      startTime = DateTime(now.year, now.month, now.day);
      endTime = now;
    }else if(initValue == DateTypeEnum.last_3_days){
      startTime = DateTime(now.year, now.month, now.day - 2);
      endTime = now;
    }else if(initValue == DateTypeEnum.last_7_days){
      startTime = DateTime(now.year, now.month, now.day - 6);
      endTime = now;
    }else if(initValue == DateTypeEnum.last_14_days){
      startTime = DateTime(now.year, now.month, now.day - 13);
      endTime = now;
    }else if(initValue == DateTypeEnum.last_30_days){
      startTime = DateTime(now.year, now.month, now.day - 29);
      endTime = now;
    }
    return DateTypeEnumResult(
      start: DateFormatUtil.toLocalTime(startTime), 
      end: DateFormatUtil.toLocalTime(endTime),
    );
  }


}

class DateTypeEnumResult{
  DateTime start;
  DateTime end;

  DateTypeEnumResult({
    required this.start,
    required this.end,
  });
}