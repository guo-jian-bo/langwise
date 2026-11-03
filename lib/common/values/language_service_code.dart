// ignore_for_file: constant_identifier_names

class LanguageServiceCode {
  static const String US = "US";
  static const String UK = "UK";

  static const String dicDialectUS = "en_us";
  static const String dicDialectUK = "en_br";


  static String getEvelDctDialect(String? national){
    if(national == US){
      return dicDialectUS;
    }
    return dicDialectUK;
  }
}

enum LanguageServiceCodeEnum {
  US("US", "美音"),
  UK("UK", "英音");

  final String value;
  final String text;
  const LanguageServiceCodeEnum(this.value, this.text);

  static LanguageServiceCodeEnum fromValue(String? value) {
    return LanguageServiceCodeEnum.values.firstWhere(
      (element) => element.value == value,
      orElse: () => US,
    );
  }
}