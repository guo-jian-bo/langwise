class StringUtils{



  static final RegExp _chineseSymbolRegex = RegExp(
    r'[，。！？；：、（）【】“”‘’]',
  );
  static const Map<String, String> _chineseSymbolToEnglishMap = {
    '，': ',',
    '。': '.',
    '！': '!',
    '？': '?',
    '；': ';',
    '：': ':',
    '、': ',',
    '（': '(',
    '）': ')',
    '【': '[',
    '】': ']',
    '“': '"',
    '”': '"',
    '‘': '\'',
    '’': '\'',
  };

  /// 替换所有换行符
  static String replaceAllLineBreak(String str){
    return str.replaceAll(r'\r\n', '\n').replaceAll(r'\n', '\n');
  }

  /// 获取中文符号列表
  static String getChineseSymbolList(){
    return _chineseSymbolRegex.pattern.replaceAll(r'[', '').replaceAll(r']', '');
  }

  /// 检查字符串包含中文符号的数量
  static int checkChineseSymbol(String str){
    if (str.isEmpty) {
      return 0;
    }
    return _chineseSymbolRegex.allMatches(str).length;
  }

  /// 字符串中把中文符号换成英文符号
  static String replaceChineseSymbol(String str){
    if (str.isEmpty) {
      return str;
    }

    return str.split('').map((char) {
      return _chineseSymbolToEnglishMap[char] ?? char;
    }).join();
  }


}
