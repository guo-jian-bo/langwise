import 'package:intl/intl.dart';

class NumberUtils{

  static String formatNumberWithCommas(double number) {
    final formatter = NumberFormat("#,###.##", "en_US");
    return formatter.format(number);
  }

}