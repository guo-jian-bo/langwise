import 'dart:convert';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lib_common/common.dart';

import '../values/storage.dart';

class LanguageTranslations extends Translations{
  /// 语言json
  final Map<String, Map<String, String>> _keys = {};

  /// 支持的语言列表
  final List<Locale> _supportedLocales = [
    const Locale('en', 'US'), // 美国英语
    const Locale.fromSubtags(languageCode: "zh", scriptCode: "Hans", countryCode: "CN"), // 中文简体
  ];

  /// 支持的语言列表
  List<Locale> get supportedLocales => _supportedLocales;

  /// 回退语言
  Locale get fallbackLocale => const Locale.fromSubtags(languageCode: "zh", scriptCode: "Hans", countryCode: "CN");

  @override
  Map<String, Map<String, String>> get keys => _keys;
  

  Future<void> initLanguage() async{
    // 获取操作系统的第一语言 需要保存下来或者给服务端保存
    final Locale languageCode = PlatformDispatcher.instance.locales.first;
    
    await switcherLanguage(languageCode);
  }


  Future<void> loadLanguageFromServer(Locale locale) async {
    // 1. 根据 locale 从服务器获取对应的语言文件 和 语言列表 并保存本地
    // ...

    // 2. 如果从服务器获取失败 则从本地缓存中获取语言json
    String storageJson = StorageUtil().getString(STORAGE_LANGUAGE_JSON);
    if(!ObjectUtil.isEmptyString(storageJson)){
      Map<String, dynamic> storageData = json.decode(storageJson);
      _keys[locale.toString()] = Map<String, String>.from(storageData);
      // return; // 这里先注掉 后面有接口就放开
    }

    // 3. 如果本地没有语言json 则读取项目中默认json(中文简体)
    String loadJson = await rootBundle.loadString("assets/language_json/zh_cn.json");
    final Map<String, dynamic> data = json.decode(loadJson);
    _keys["${locale.languageCode}_${locale.countryCode}"] = Map<String, String>.from(data);
    await StorageUtil().setString(STORAGE_LANGUAGE_JSON, json.encode(data));

    /// 以下读取英文 现在只做测试
    String loadJsonTestEn = await rootBundle.loadString("assets/language_json/en_us.json");
    final Map<String, dynamic> dataTestEn = json.decode(loadJsonTestEn);
    _keys["en_US"] = Map<String, String>.from(dataTestEn);

  }

  /// 切换语言
  Future<void> switcherLanguage(Locale locale) async{
    await loadLanguageFromServer(locale);
    await Get.updateLocale(locale);
  }
  
  
}


