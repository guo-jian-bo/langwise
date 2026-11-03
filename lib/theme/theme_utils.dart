
import 'package:lib_common/common.dart';
import 'package:themed/themed.dart';

import '../common/values/values.dart';
import 'theme.dart';

class ThemeUtils{

  /// 初始化主题
  static void initTheme(){
    Themed.saveAll(AppTheme.appThemes);
    String storageTheme = StorageUtil().getString(STORAGE_APP_THEME_KEY);
    if(storageTheme.isEmpty){
      changeTheme(AppThemeKey.dark.value);
    }else{
      changeTheme(storageTheme);
    }
  }


  /// 切换主题
  static void changeTheme(String key) {
    if(isCurrentTheme(key)) return;
    if(!AppTheme.appThemes.containsKey(key)){// 如果没有找到主题，使用暗夜模式
      Themed.setThemeByKey(AppThemeKey.dark.value);
      StorageUtil().setString(STORAGE_APP_THEME_KEY, AppThemeKey.dark.value);
      return;
    }
    
    // 如果找到主题，使用找到的主题
    Themed.setThemeByKey(key);
    StorageUtil().setString(STORAGE_APP_THEME_KEY, key);
  }

  /// 判断当前是否是key主题
  static bool isCurrentTheme(String key) {
    final theme = AppTheme.appThemes[key.toUpperCase()];
    if(theme == null) return false;
    return Themed.ifCurrentThemeIs(theme);
  }

  /// 根据主题key获取主题map
  static Map<ThemeRef, Object>? getThemeMap(String key){
    return AppTheme.appThemes[key.toUpperCase()];
  }





}