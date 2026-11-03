import 'package:flutter/cupertino.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart' as Time;
import 'dart:developer';

class DateFormatUtil {

  
  static String formatStrtoStr(String? input, {String newPattern = "yyyy-MM-dd", Locale? locale}) {
    if (input == null || input.isEmpty) return "";
    // String resInput = input.replaceFirst("+", " ");
    DateTime? date = tryParseDate(input);
    if (date == null) return "";
    try {
      final formatter = Time.DateFormat(newPattern, locale?.toString());
      return formatter.format(date);
    } catch (_) {
      return "";
    }
  }

  static DateTime? tryParseDate(String? input) {
    if (input == null || input.isEmpty) return null;

    // 1. 首先尝试 DateTime.tryParse（支持 ISO 8601 格式）
    DateTime? date = DateTime.tryParse(input);
    if (date != null) return date.toLocal();

    // 2. 尝试替换 / 为 -（解决 "2020/10/20" 问题）
    if (input.contains('/')) {
      date = DateTime.tryParse(input.replaceAll('/', '-'));
      if (date != null) return date.toLocal();
    }

    // 3. 尝试中文格式（如 "2025年5月20日"）
    try {
      final format = Time.DateFormat("yyyy年M月d日");
      return format.parse(input).toLocal();
    } catch (_) {}

    // 4. 尝试英文格式（如 "May 20, 2025"）
    try {
      final format = Time.DateFormat("MMMM d, yyyy", "en_US");
      return format.parse(input).toLocal();
    } catch (_) {}

    // 5. 尝试其他常见格式
    final possibleFormats = [
      "yyyy/M/d",
      "M/d/yyyy",
      "d/M/yyyy",
      "MMM d, yyyy",
      "d MMM yyyy",
    ];

    for (final formatStr in possibleFormats) {
      try {
        final format = Time.DateFormat(formatStr);
        return format.parse(input).toLocal();
      } catch (_) {}
    }

    return null; // 所有格式都不匹配
  }

  /// 获取本周日期
  static List<DateTime> getCurrentWeekDates() {
    DateTime today = DateTime.now();
    // 找到本周的周日（假设周日是一周的第一天）
    DateTime sunday = today.subtract(Duration(days: today.weekday % 7));
    
    List<DateTime> weekDates = [];
    for (int i = 0; i < 7; i++) {
      weekDates.add(sunday.add(Duration(days: i)));
    }
    
    return weekDates;
  }

  /// 将秒转为分钟 四舍五入 不足一分钟按一分钟计算
  static int convertSecondsToMinutes(int? seconds) {
    if (seconds == null || seconds <= 0) return 0;
    int minutes = (seconds + 30) ~/ 60;
    if(minutes == 0){
      minutes = 1;
    }
    return minutes;

  }

  /// 将毫秒转换为分秒
  static String convertMillisecondsToMinSec(int milliseconds) {
    int seconds = milliseconds ~/ 1000;  // 用整除得到秒数
    return convertSecondsToMinSec(seconds);
  }

  /// 将妙转换为分秒
  static String convertSecondsToMinSec(int seconds) {
    if(seconds <= 0){
      return "00:00";
    }
    int minutes = seconds ~/ 60;  // 用整除得到分钟数
    int remainingSeconds = seconds % 60;  // 得到剩余的秒数
    
    // 使用字符串格式化，确保分钟和秒数为两位数
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 将毫秒转换为秒毫秒
  static String convertMillisecondsToSeconds(int milliseconds) {
    int seconds = milliseconds ~/ 1000;  // 用整除得到秒数
    return convertSecondsToMinSec(seconds);
  }

  /// 把毫秒转为秒 保留两位小数
  static String millisecondsToSecondsWithDecimal(int milliseconds) {
    double seconds = milliseconds / 1000;  // 用整除得到秒数
    return seconds.toStringAsFixed(2);
  }

  /// 把秒(1.12)转为Duration
  static Duration secondsToDuration(double seconds) {
    // 将秒数转换为毫秒，因为Duration的构造函数接受整数毫秒
    int milliseconds = (seconds * 1000).round();
    return Duration(milliseconds: milliseconds);
  }
  
  /// 直接把秒(1.12)转为 分:秒.毫秒 毫秒保留两位小数
  static String secondsToMinSecStr(double seconds){
    Duration duration = secondsToDuration(seconds);
    return formatMillisecondsToMinSec(duration);
  }

  /// 将毫秒转为 分:秒.毫秒 毫秒保留两位小数
  static String formatMillisecondsToMinSec(Duration duration) {
    int milliseconds = duration.inMilliseconds;
    int seconds = milliseconds ~/ 1000;  // 用整除得到秒数
    int minutes = seconds ~/ 60;  // 用整除得到分钟数
    int remainingSeconds = seconds % 60;  // 得到剩余的秒数
    int remainingMilliseconds = milliseconds % 1000;  // 得到剩余的毫秒数
    
    // 使用字符串格式化，确保分钟和秒数为两位数
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}.${remainingMilliseconds.toString().padLeft(3, '0').substring(0, 2)}';
  }

  static String formatToYearMonth(DateTime dateTime, {Locale? locale}) {
    locale ??= const Locale("en", "US");
    // 创建 DateFormat，指定格式为 MMMM 并设置 locale 为中文
    final Time.DateFormat formatter = Time.DateFormat.yM(locale.toString());
    return formatter.format(dateTime); // 返回格式化后的结果
  }
  
  /// 把时和分转为对应国家的时间
  static String hsToLocaleTime(int? hour, int? minute, {Locale? locale}){
    try {
      locale ??= const Locale("zh", "CN");
      final formatter = Time.DateFormat("HH:mm", locale.toString());
      DateTime dateTime = DateTime.now();
      return formatter.format(DateTime(dateTime.year, dateTime.month, dateTime.day, hour ?? 0, minute ?? 0));
    } catch (e) {
      return "";
    }
  }
    

  /// 转为时分
  static String formatHM(DateTime dateTime, {Locale? locale}){
    try {
      locale ??= const Locale("zh", "CN");
      final formatter = Time.DateFormat("HH:mm", locale.toString());
      return formatter.format(dateTime);
    } catch (e) {
      return "";
    }
  }

  
  /// 把年月日 转换成对应国家的格式
  static String formatLocale(DateTime date, {Locale? locale}){
    try {
      locale ??= const Locale("zh", "CN");
      final formatter = Time.DateFormat.yMd(locale.toString());
      return formatter.format(date);
    } catch (e) {
      return "";
    }
  }

  ///2024-07-09 格式转 7月19号
  static String date2day(String date) {
    try {
      final arrays = date.split('-');
      return '${int.parse(arrays[1])}月${int.parse(arrays[2])}号';
    } catch (e) {
      log("date2day error = $e");
    }

    return date;
  }

  ///没指定时区 由系统默认时区决定
  static int parseData(String date) {
    try {
      return Time.DateFormat('yyyy-MM-dd').parse(date).millisecondsSinceEpoch;
    } catch (e) {
      log("date2day error = $e");
    }

    return 0;
  }

  /// 把Duration 转为 时分格式
  static String combineHourMinute(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    return '$hours:$minutes';
  }

  static String formatStr(DateTime date, {String newPattern = "yyyy-MM-dd", Locale? locale}){
    try {
      final formatter = Time.DateFormat(newPattern, locale?.toString());
      return formatter.format(date);
    } catch (e) {
      return "";
    }
  }

  static String formatIsoTime(String time, {bool? fullFormat = true}) {
    try {
      final dateTime = DateTime.parse(time).toLocal();
      Time.DateFormat formatter;
      if (fullFormat == true) {
        formatter = Time.DateFormat(
          "yyyy-MM-dd HH:mm:ss",
        );
      } else {
        formatter = Time.DateFormat(
          "yyyy-MM-dd",
        );
      }
      return formatter.format(dateTime);
    } catch (e) {
      log('formatIsoTime e = $e');
    }

    return '';
  }

  static String getTodayDate({String newPattern = "yyyy-MM-dd"}) {
    try {
      final dateTime = DateTime.timestamp().toLocal();
      final formatter = Time.DateFormat(
        newPattern,
      );
      return formatter.format(dateTime);
    } catch (e) {
      log('formatIsoTime e = $e');
    }

    return '';
  }

  /// 判断日期，是今日还是昨日
  /// 返回值：0今日，-1昨日，1未来
  static int getTodayState(String? date, {Duration offset = Duration.zero}) {
    if (date == null || date.isEmpty) {
      return -1;
    }
    DateTime dateTime = DateTime.parse(date);

    DateTime today = DateTime.now();

    // 获取今天的 0 点时间
    DateTime todayZero = DateTime(today.year, today.month, today.day).toUtc();

    todayZero = todayZero.add(offset);

    // NLogger.d('$TAG 当前UTC时间 -> ${todayZero} dateTime -> $dateTime');

    if (dateTime.year == todayZero.year && dateTime.month == todayZero.month && dateTime.day == todayZero.day) {
      // debugPrint('这个日期是今天');
      // NLogger.d('$TAG date 000 -> ${date}');
      return 0;
    } else if (dateTime.isBefore(today)) {
      // NLogger.d('$TAG date -1-1-1 -> ${date}');
      return -1;
    } else {
      // NLogger.d('$TAG date 111 -> ${date}');
      return 1;
    }
  }

  static bool isDateAfterToday(DateTime date) {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);
    return date.isAfter(today);
  }

  /// 获取北京时间
  static String getBeijingTime() {
    // 获取当前时间的UTC时间
    DateTime now = DateTime.now().toUtc();
    // 创建一个UTC+8的时区偏移 要获取北京时间 东八区  所以是偏移 8
    Duration offset = const Duration(hours: 8);

    DateTime nowInUtc = now.add(offset);
    return nowInUtc.toString();
  }

  /// 把时间转为utc时间
  static DateTime toUtcTime(DateTime date) {
    return date.toUtc();
  }

  static DateTime toLocalTime(DateTime date){
    return date.toLocal();
  }

  static bool isTimeInRange(Duration time, Duration start, Duration end) {
    // 确保 start <= end
    if (start > end) {
      throw ArgumentError('Start time must be less than or equal to end time.');
    }
    return time >= start && time <= end;
  }

  static bool isTodayWeekend() {
    // 获取当前日期
    DateTime now = DateTime.now();

    // 获取今天是星期几
    int weekday = now.weekday; // 1 = Monday, 7 = Sunday

    // 判断是否为周末（星期六或星期日）
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  static bool isTimestampToday(int timestamp) {
    // 将时间戳转换为 DateTime 对象
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // 获取当前日期
    DateTime now = DateTime.now();

    // 比较日期的年、月、日
    return dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day;
  }

  static bool isToday(DateTime? date1, DateTime? date2){
    if(date1 == null && date2 == null) return false;
    return date1?.year == date2?.year && date1?.month == date2?.month && date1?.day == date2?.day;
  }


  /// 获取时区信息
  static Future<String?> getTimeZoneInfo() async{
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      return currentTimeZone;
    } catch (e) {
      return null;
    }
  }

  /// 周数组
  static List<String> getWeekList(){
    return [
      "周一",
      "周二",
      "周三",
      "周四",
      "周五",
      "周六",
      "周日",
    ];
  }

  /// 周数组
  static List<String> getWeekList1(){
    return [
      "一",
      "二",
      "三",
      "四",
      "五",
      "六",
      "日",
    ];
  }

  /// 根据周int获取周字符串
  static String getWeekStrForInt(int weekDay){
    return getWeekList()[weekDay - 1];
  }

}

extension StringExtension on String? {
  bool equalsIgnoreCase(String? other) {
    if (this == null && other == null) {
      return true;
    } else if (this != null && other != null) {
      return this!.toLowerCase() == other.toLowerCase();
    }
    return false;
  }
}

extension IntExt on int? {
  String padLeft(int width, String padding) {
    if (this == null) return '';
    return toString().padLeft(width, padding);
  }
}
