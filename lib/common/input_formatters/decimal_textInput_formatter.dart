

import 'package:flutter/services.dart';

/// 自定义输入格式化器：限制只能输入两位小数，且不能超过最大值
class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange; // 小数位数
  final double? maxValue; // 最大值限制（可选）
  final bool allowNegative; // 是否允许负数
  
  DecimalTextInputFormatter({
    this.decimalRange = 2,
    this.maxValue,
    this.allowNegative = false,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 处理空值
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 获取当前光标位置
    int selectionIndex = newValue.selection.end;
    
    // 1. 过滤掉非法字符（只保留数字、小数点和可能的负号）
    String filteredText = _filterText(newValue.text);
    
    // 2. 处理多个小数点的问题（只保留第一个小数点）
    filteredText = _processDecimalPoints(filteredText);
    
    // 3. 处理小数点位置和位数限制
    filteredText = _processDecimalLimit(filteredText);
    
    // 4. 处理负号位置
    if (allowNegative) {
      filteredText = _processNegativeSign(filteredText);
    }
    
    // 5. 如果文本没有变化且不符合格式，尝试修复
    if (filteredText.isEmpty) {
      return oldValue;
    }
    
    // 6. 检查最大值限制
    if (!_isWithinMaxValue(filteredText)) {
      return oldValue;
    }

    // 7. 计算新的光标位置
    selectionIndex = _calculateNewSelectionIndex(
      oldValue.text,
      filteredText,
      selectionIndex,
    );

    return TextEditingValue(
      text: filteredText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }

  /// 过滤非法字符
  String _filterText(String text) {
    String pattern = r'[^\d\.';
    if (allowNegative) {
      pattern += r'\-';
    }
    pattern += r']';
    
    // 先过滤掉非法字符
    String filtered = text.replaceAll(RegExp(pattern), '');
    
    // 确保不会出现多个负号（除了开头的负号）
    if (allowNegative) {
      // 移除中间出现的负号
      List<String> chars = filtered.split('');
      bool hasNegativeAtStart = chars.isNotEmpty && chars[0] == '-';
      
      // 重新构建字符串，只保留开头的负号
      String result = '';
      for (int i = 0; i < chars.length; i++) {
        if (chars[i] == '-') {
          if (i == 0 && !hasNegativeAtStart) {
            result += chars[i];
            hasNegativeAtStart = true;
          }
          // 其他位置的负号都忽略
        } else {
          result += chars[i];
        }
      }
      filtered = result;
    }
    
    return filtered;
  }

  /// 处理多个小数点（只保留第一个）
  String _processDecimalPoints(String text) {
    if (!text.contains('.')) {
      return text;
    }
    
    List<String> parts = text.split('.');
    if (parts.length <= 2) {
      return text; // 只有一个小数点
    }
    
    // 有多个小数点，只保留第一个
    // 例如： "123.456.789" -> "123.456789"
    String result = parts[0] + '.';
    for (int i = 1; i < parts.length; i++) {
      result += parts[i];
    }
    
    return result;
  }

  /// 处理小数位数限制
  String _processDecimalLimit(String text) {
    if (decimalRange == 0) {
      // 不允许小数，移除所有小数点
      return text.replaceAll('.', '');
    }
    
    if (!text.contains('.')) {
      return text;
    }
    
    int dotIndex = text.indexOf('.');
    int decimalDigits = text.length - dotIndex - 1;
    
    if (decimalDigits <= decimalRange) {
      return text; // 小数位数在限制范围内
    }
    
    // 超过小数位数限制，截断
    return text.substring(0, dotIndex + decimalRange + 1);
  }

  /// 处理负号位置
  String _processNegativeSign(String text) {
    if (!text.contains('-')) {
      return text;
    }
    
    // 确保负号只在开头
    if (text.startsWith('-')) {
      return text;
    }
    
    // 移除所有负号，然后在开头添加
    return '-' + text.replaceAll('-', '');
  }

  /// 检查是否超过最大值
  bool _isWithinMaxValue(String text) {
    if (maxValue == null) {
      return true;
    }
    
    // 如果是单独的负号或空字符串，允许
    if (text == '-' || text.isEmpty || text == '.') {
      return true;
    }
    
    // 如果以小数点开头，临时补0用于解析
    String parseText = text;
    if (parseText.startsWith('.')) {
      parseText = '0$parseText';
    }
    if (parseText.startsWith('-.')) {
      parseText = '-0.${parseText.substring(2)}';
    }
    
    double? value = double.tryParse(parseText);
    if (value == null) {
      return true; // 无法解析的数字暂时允许
    }
    
    return value <= maxValue!;
  }

  /// 计算新的光标位置
  int _calculateNewSelectionIndex(String oldText, String newText, int oldSelectionIndex) {
    // 简单处理：如果新文本更短，光标在末尾
    if (newText.length < oldText.length) {
      return newText.length;
    }
    
    // 如果新文本更长，光标也在末尾
    if (newText.length > oldText.length) {
      return newText.length;
    }
    
    // 长度相同，尽量保持原有光标位置
    return oldSelectionIndex.clamp(0, newText.length);
  }
}