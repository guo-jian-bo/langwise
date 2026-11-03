class StringUtils{

  /// 替换所有换行符
  static String replaceAllLineBreak(String str){
    return str.replaceAll(r'\r\n', '\n').replaceAll(r'\n', '\n');
  }
}
