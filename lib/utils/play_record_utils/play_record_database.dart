

import 'package:flutter/foundation.dart';
import 'package:langwise/utils/utils.dart';
import 'package:sqlite3/sqlite3.dart';

import 'play_record_constants.dart';
import 'play_record_model.dart';

/// 播放记录数据库操作类
class PlayRecordDatabase {
  PlayRecordDatabase._internal();
  static final PlayRecordDatabase _instance = PlayRecordDatabase._internal();
  static PlayRecordDatabase get instance => _instance;

  Database? _database;
  bool _isInitialized = false;

  /// 初始化数据库
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {

      _database = AppDBUtils.instance.appReportDB;
      _createTable();
      _isInitialized = true;

    } catch (e) {
      rethrow;
    }
  }

  /// 创建表
  void _createTable() {
    _database?.execute('''
      CREATE TABLE IF NOT EXISTS ${PlayRecordConstants.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        type TEXT DEFAULT '',
        type_id INTEGER DEFAULT 0,
        style_id INTEGER,
        dialect TEXT,
        learn_type TEXT,
        content_type TEXT NOT NULL,
        content_id INTEGER NOT NULL,
        played REAL NOT NULL,
        duration REAL NOT NULL,
        trigger_type TEXT,
        report_status TEXT DEFAULT 'pending',
        created_at INTEGER NOT NULL,
        extra TEXT
      )
    ''');

    _database?.execute('''
      CREATE INDEX IF NOT EXISTS idx_report_status 
      ON ${PlayRecordConstants.tableName} (report_status)
    ''');

    _database?.execute('''
      CREATE INDEX IF NOT EXISTS idx_created_at 
      ON ${PlayRecordConstants.tableName} (created_at)
    ''');

    // 兼容老表结构：增量补齐新增列
    final columns = _database?.select(
          'PRAGMA table_info(${PlayRecordConstants.tableName})',
        ) ??
        [];
    final columnNames = columns.map((e) => e['name'] as String).toSet();
    if (!columnNames.contains('style_id')) {
      _database?.execute('''
        ALTER TABLE ${PlayRecordConstants.tableName}
        ADD COLUMN style_id INTEGER
      ''');
    }
    if (!columnNames.contains('dialect')) {
      _database?.execute('''
        ALTER TABLE ${PlayRecordConstants.tableName}
        ADD COLUMN dialect TEXT
      ''');
    }
    if (!columnNames.contains('learn_type')) {
      _database?.execute('''
        ALTER TABLE ${PlayRecordConstants.tableName}
        ADD COLUMN learn_type TEXT
      ''');
    }
  }

  /// 插入记录
  Future<int?> insert(PlayRecordModel record) async {
    if (_database == null) {
      debugPrint('[PlayRecordDatabase] 数据库未初始化');
      return null;
    }

    try {
      _database!.execute('''
        INSERT INTO ${PlayRecordConstants.tableName} 
        (session_id, type, type_id, style_id, dialect, learn_type, content_type, content_id, played, duration, trigger_type, report_status, created_at, extra)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        record.sessionId,
        record.type,
        record.typeId,
        record.styleId,
        record.dialect,
        record.learnType,
        record.contentType,
        record.contentId,
        record.played,
        record.duration,
        record.triggerType,
        record.reportStatus,
        record.createdAt,
        record.extra,
      ]);

      final lastId = _database!.lastInsertRowId;
      debugPrint('[PlayRecordDatabase] 插入记录成功, id: $lastId');
      return lastId;
    } catch (e) {
      debugPrint('[PlayRecordDatabase] 插入记录失败: $e');
      return null;
    }
  }

  /// 更新记录状态
  Future<bool> updateStatus(int id, PlayRecordReportStatus status) async {
    if (_database == null) return false;

    try {
      _database!.execute('''
        UPDATE ${PlayRecordConstants.tableName} 
        SET report_status = ?
        WHERE id = ?
      ''', [status.value, id]);
      return true;
    } catch (e) {
      debugPrint('[PlayRecordDatabase] 更新状态失败: $e');
      return false;
    }
  }

  /// 更新记录内容（用于上报时更新播放时长和触发类型）
  Future<bool> updateRecord(int id, {
    double? played,
    String? triggerType,
    PlayRecordReportStatus? status,
  }) async {
    if (_database == null) return false;

    try {
      List<String> setClauses = [];
      List<dynamic> params = [];

      if (played != null) {
        setClauses.add('played = ?');
        params.add(played);
      }
      if (triggerType != null) {
        setClauses.add('trigger_type = ?');
        params.add(triggerType);
      }
      if (status != null) {
        setClauses.add('report_status = ?');
        params.add(status.value);
      }

      if (setClauses.isEmpty) return true;

      params.add(id);
      _database!.execute('''
        UPDATE ${PlayRecordConstants.tableName} 
        SET ${setClauses.join(', ')}
        WHERE id = ?
      ''', params);
      
      debugPrint('[PlayRecordDatabase] 更新记录成功, id: $id');
      return true;
    } catch (e) {
      debugPrint('[PlayRecordDatabase] 更新记录失败: $e');
      return false;
    }
  }

  /// 删除记录
  Future<bool> delete(int id) async {
    if (_database == null) return false;

    try {
      _database!.execute('''
        DELETE FROM ${PlayRecordConstants.tableName} WHERE id = ?
      ''', [id]);
      debugPrint('[PlayRecordDatabase] 删除记录成功, id: $id');
      return true;
    } catch (e) {
      debugPrint('[PlayRecordDatabase] 删除记录失败: $e');
      return false;
    }
  }

  /// 批量删除记录
  Future<bool> deleteByIds(List<int> ids) async {
    if (_database == null || ids.isEmpty) return false;

    try {
      final placeholders = ids.map((_) => '?').join(',');
      _database!.execute('''
        DELETE FROM ${PlayRecordConstants.tableName} WHERE id IN ($placeholders)
      ''', ids);
      debugPrint('[PlayRecordDatabase] 批量删除记录成功, count: ${ids.length}');
      return true;
    } catch (e) {
      debugPrint('[PlayRecordDatabase] 批量删除记录失败: $e');
      return false;
    }
  }

  /// 获取待上报的记录（pending + failed）
  Future<List<PlayRecordModel>> getPendingRecords({int limit = 50}) async {
    if (_database == null) return [];

    try {
      final result = _database!.select('''
        SELECT * FROM ${PlayRecordConstants.tableName} 
        WHERE report_status IN (?, ?)
        ORDER BY created_at ASC
        LIMIT ?
      ''', [
        PlayRecordReportStatus.pending.value,
        PlayRecordReportStatus.failed.value,
        limit,
      ]);

      return result.map((row) => PlayRecordModel.fromMap(row)).toList();
    } catch (e) {
      debugPrint('[PlayRecordDatabase] 获取待上报记录失败: $e');
      return [];
    }
  }

  /// 获取失败的记录（只有 failed 状态）
  Future<List<PlayRecordModel>> getFailedRecords({int limit = 50}) async {
    if (_database == null) return [];

    try {
      final result = _database!.select('''
        SELECT * FROM ${PlayRecordConstants.tableName} 
        WHERE report_status = ?
        ORDER BY created_at ASC
        LIMIT ?
      ''', [
        PlayRecordReportStatus.failed.value,
        limit,
      ]);

      return result.map((row) => PlayRecordModel.fromMap(row)).toList();
    } catch (e) {
      debugPrint('[PlayRecordDatabase] 获取失败记录失败: $e');
      return [];
    }
  }

  /// 获取记录总数
  Future<int> getRecordCount() async {
    if (_database == null) return 0;

    try {
      final result = _database!.select('''
        SELECT COUNT(*) as count FROM ${PlayRecordConstants.tableName}
      ''');
      return result.first['count'] as int;
    } catch (e) {
      debugPrint('[PlayRecordDatabase] 获取记录总数失败: $e');
      return 0;
    }
  }

  /// 清理过期记录
  Future<int> cleanExpiredRecords() async {
    if (_database == null) return 0;

    try {
      final expirationTime = DateTime.now().millisecondsSinceEpoch -
          (PlayRecordConstants.maxRetentionDays * 24 * 60 * 60 * 1000);

      _database!.execute('''
        DELETE FROM ${PlayRecordConstants.tableName} 
        WHERE created_at < ?
      ''', [expirationTime]);

      final deletedCount = _database!.updatedRows;
      if (deletedCount > 0) {
        debugPrint('[PlayRecordDatabase] 清理过期记录: $deletedCount 条');
      }
      return deletedCount;
    } catch (e) {
      debugPrint('[PlayRecordDatabase] 清理过期记录失败: $e');
      return 0;
    }
  }

  /// 清理超出最大条数的记录（保留最新的）
  Future<int> cleanExcessRecords() async {
    if (_database == null) return 0;

    try {
      final count = await getRecordCount();
      if (count <= PlayRecordConstants.maxRecordCount) return 0;

      final deleteCount = count - PlayRecordConstants.maxRecordCount;

      _database!.execute('''
        DELETE FROM ${PlayRecordConstants.tableName} 
        WHERE id IN (
          SELECT id FROM ${PlayRecordConstants.tableName} 
          ORDER BY created_at ASC 
          LIMIT ?
        )
      ''', [deleteCount]);

      final deletedCount = _database!.updatedRows;
      if (deletedCount > 0) {
        debugPrint('[PlayRecordDatabase] 清理超出记录: $deletedCount 条');
      }
      return deletedCount;
    } catch (e) {
      debugPrint('[PlayRecordDatabase] 清理超出记录失败: $e');
      return 0;
    }
  }

  /// 执行清理任务（过期 + 超出条数）
  Future<void> performCleanup() async {
    await cleanExpiredRecords();
    await cleanExcessRecords();
  }

  /// 关闭数据库
  void close() {
    _database?.dispose();
    _database = null;
    _isInitialized = false;
    debugPrint('[PlayRecordDatabase] 数据库已关闭');
  }
}
