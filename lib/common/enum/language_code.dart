enum LanguageCode{
  zh("zh", "china", "中国"),
  en("en", "us_uk", "欧美");

  final String value;
  final String local;
  final String name;

  const LanguageCode(this.value, this.local, this.name);
}