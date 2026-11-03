import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

import '../sqlite3_utils/app_db_utils.dart';
import 'learn_record_constants.dart';
import 'learn_record_model.dart';

class LearnRecordDatabase {
  LearnRecordDatabase._internal();
  static final LearnRecordDatabase _instance = LearnRecordDatabase._internal();
  static LearnRecordDatabase get instance => _instance;

  Database? _database;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _database = AppDBUtils.instance.appReportDB;
    _createTable();
    _isInitialized = true;
  }

  void _createTable() {
    _database?.execute('''
      CREATE TABLE IF NOT EXISTS ${LearnRecordConstants.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        type TEXT,
        duration_sec INTEGER NOT NULL DEFAULT 0,
        content_list_json TEXT NOT NULL DEFAULT '[]',
        report_status TEXT NOT NULL DEFAULT '${LearnRecordConstants.statusPending}',
        created_at INTEGER NOT NULL
      )
    ''');

    _database?.execute('''
      CREATE INDEX IF NOT EXISTS idx_${LearnRecordConstants.tableName}_status
      ON ${LearnRecordConstants.tableName} (report_status)
    ''');

    _database?.execute('''
      CREATE INDEX IF NOT EXISTS idx_${LearnRecordConstants.tableName}_created_at
      ON ${LearnRecordConstants.tableName} (created_at)
    ''');

    final columns = _database?.select(
          'PRAGMA table_info(${LearnRecordConstants.tableName})',
        ) ??
        [];
    final columnNames = columns.map((e) => e['name'] as String).toSet();
    if (!columnNames.contains('type')) {
      _database?.execute('''
        ALTER TABLE ${LearnRecordConstants.tableName}
        ADD COLUMN type TEXT
      ''');
    }
    if (!columnNames.contains('duration_sec')) {
      _database?.execute('''
        ALTER TABLE ${LearnRecordConstants.tableName}
        ADD COLUMN duration_sec INTEGER NOT NULL DEFAULT 0
      ''');
    }
    if (!columnNames.contains('content_list_json')) {
      _database?.execute('''
        ALTER TABLE ${LearnRecordConstants.tableName}
        ADD COLUMN content_list_json TEXT NOT NULL DEFAULT '[]'
      ''');
    }
    if (!columnNames.contains('report_status')) {
      _database?.execute('''
        ALTER TABLE ${LearnRecordConstants.tableName}
        ADD COLUMN report_status TEXT NOT NULL DEFAULT '${LearnRecordConstants.statusPending}'
      ''');
    }
  }

  Future<int?> insert(LearnRecordModel record) async {
    if (_database == null) return null;
    try {
      _database!.execute('''
        INSERT INTO ${LearnRecordConstants.tableName}
        (session_id, type, duration_sec, content_list_json, report_status, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
      ''', [
        record.sessionId,
        record.type,
        record.durationSec,
        record.toMap()['content_list_json'],
        record.reportStatus,
        record.createdAt,
      ]);
      return _database!.lastInsertRowId;
    } catch (e) {
      debugPrint('[LearnRecordDatabase] 插入记录失败: $e');
      return null;
    }
  }

  Future<bool> updateSnapshot(int id, LearnRecordModel record) async {
    if (_database == null) return false;
    try {
      _database!.execute('''
        UPDATE ${LearnRecordConstants.tableName}
        SET type = ?, duration_sec = ?, content_list_json = ?, report_status = ?
        WHERE id = ?
      ''', [
        record.type,
        record.durationSec,
        record.toMap()['content_list_json'],
        record.reportStatus,
        id,
      ]);
      return true;
    } catch (e) {
      debugPrint('[LearnRecordDatabase] 更新记录失败: $e');
      return false;
    }
  }

  Future<bool> updateStatus(int id, String status) async {
    if (_database == null) return false;
    try {
      _database!.execute('''
        UPDATE ${LearnRecordConstants.tableName}
        SET report_status = ?
        WHERE id = ?
      ''', [status, id]);
      return true;
    } catch (e) {
      debugPrint('[LearnRecordDatabase] 更新状态失败: $e');
      return false;
    }
  }

  Future<bool> delete(int id) async {
    if (_database == null) return false;
    try {
      _database!.execute('DELETE FROM ${LearnRecordConstants.tableName} WHERE id = ?', [id]);
      return true;
    } catch (e) {
      debugPrint('[LearnRecordDatabase] 删除记录失败: $e');
      return false;
    }
  }

  Future<List<LearnRecordModel>> getPendingRecords({int limit = 50}) async {
    if (_database == null) return [];
    try {
      final result = _database!.select('''
        SELECT * FROM ${LearnRecordConstants.tableName}
        WHERE report_status IN (?, ?)
        ORDER BY created_at ASC
        LIMIT ?
      ''', [
        LearnRecordConstants.statusPending,
        LearnRecordConstants.statusFailed,
        limit,
      ]);
      return result.map((row) => LearnRecordModel.fromMap(row)).toList();
    } catch (e) {
      debugPrint('[LearnRecordDatabase] 获取待上报记录失败: $e');
      return [];
    }
  }
}
