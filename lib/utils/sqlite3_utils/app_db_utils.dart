import 'dart:io';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';


class AppDatabaseName{

  /// app上报数据库
  static const String appReportDBName = 'app_report.db';


}

class AppDBUtils{

  AppDBUtils._internal();
  static final AppDBUtils _instance = AppDBUtils._internal();
  static AppDBUtils get instance => _instance;


  bool _isInitialized = false;


  Database? _appReportDB;
  /// app上报数据库
  Database? get appReportDB => _appReportDB;


  /// 初始化数据库
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      final dir = await getApplicationCacheDirectory();
      final dbPath = dir.path + Platform.pathSeparator + "app" + Platform.pathSeparator;

      String appReportDBPath = dbPath + AppDatabaseName.appReportDBName;

      final dbFile = File(appReportDBPath);
      await dbFile.parent.create(recursive: true);

      _appReportDB = sqlite3.open(appReportDBPath);
      
      _isInitialized = true;

      debugPrint('[PlayRecordDatabase] 数据库初始化成功');
    } catch (e) {
      debugPrint('[PlayRecordDatabase] 数据库初始化失败: $e');
      rethrow;
    }
  }

}