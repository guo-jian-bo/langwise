import '../../../../common/entities/entities.dart';

class VisualStyleModel{

  String localeTitle;
  String locale;
  List<String> iconUrls;

  List<VisualStyleEntityImageStyles> list;

  VisualStyleModel({
    required this.localeTitle,
    required this.locale,
    required this.iconUrls,
    required this.list,
  });
}