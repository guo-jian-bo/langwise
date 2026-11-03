import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

import '../utils.dart';
import 'interaction_record_constants.dart';
import 'interaction_record_model.dart';

/// 交互记录数据库操作类
class InteractionRecordDatabase {
  /// 创建单例数据库实例
  InteractionRecordDatabase._internal();

  /// 单例数据库实例
  static final InteractionRecordDatabase _instance =
      InteractionRecordDatabase._internal();

  /// 获取数据库实例
  static InteractionRecordDatabase get instance => _instance;

  /// SQLite 数据库实例
  Database? _database;

  /// 数据库是否已初始化
  bool _isInitialized = false;

  /// 初始化数据库
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _database = AppDBUtils.instance.appReportDB;
      _createTable();
      _isInitialized = true;
    } catch (e) {
      debugPrint('[InteractionRecordDatabase] initialize failed: $e');
      rethrow;
    }
  }

  /// 创建交互记录表及索引
  void _createTable() {
    _database?.execute('''
      CREATE TABLE IF NOT EXISTS ${InteractionRecordConstants.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        source TEXT,
        type TEXT,
        type_id INTEGER,
        style_id INTEGER,
        dialect TEXT,
        learn_type TEXT,
        content_type TEXT NOT NULL,
        content_id INTEGER NOT NULL,
        duration REAL NOT NULL DEFAULT 0,
        started_at INTEGER NOT NULL,
        last_active_at INTEGER,
        idle_started_at INTEGER,
        ended_at INTEGER,
        accumulated_active_ms INTEGER NOT NULL DEFAULT 0,
        report_status TEXT DEFAULT 'pending',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        extra TEXT
      )
    ''');

    _database?.execute('''
      CREATE INDEX IF NOT EXISTS idx_interaction_session_id
      ON ${InteractionRecordConstants.tableName} (session_id)
    ''');

    _database?.execute('''
      CREATE INDEX IF NOT EXISTS idx_interaction_report_status
      ON ${InteractionRecordConstants.tableName} (report_status)
    ''');

    _database?.execute('''
      CREATE INDEX IF NOT EXISTS idx_interaction_created_at
      ON ${InteractionRecordConstants.tableName} (created_at)
    ''');
  }

  /// 插入交互记录
  Future<int?> insert(InteractionRecordModel record) async {
    if (_database == null) {
      debugPrint('[InteractionRecordDatabase] database not initialized');
      return null;
    }

    try {
      _database!.execute('''
        INSERT INTO ${InteractionRecordConstants.tableName}
        (
          session_id,
          source,
          type,
          type_id,
          style_id,
          dialect,
          learn_type,
          content_type,
          content_id,
          duration,
          started_at,
          last_active_at,
          idle_started_at,
          ended_at,
          accumulated_active_ms,
          report_status,
          created_at,
          updated_at,
          extra
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', <Object?>[
        record.sessionId,
        record.source,
        record.type,
        record.typeId,
        record.styleId,
        record.dialect,
        record.learnType,
        record.contentType,
        record.contentId,
        record.duration,
        record.startedAt,
        record.lastActiveAt,
        record.idleStartedAt,
        record.endedAt,
        record.accumulatedActiveMs,
        record.reportStatus,
        record.createdAt,
        record.updatedAt,
        record.extra,
      ]);

      final int lastId = _database!.lastInsertRowId;
      debugPrint('[InteractionRecordDatabase] insert success, id=$lastId');
      return lastId;
    } catch (e) {
      debugPrint('[InteractionRecordDatabase] insert failed: $e');
      return null;
    }
  }

  /// 更新交互记录
  Future<bool> updateRecord(
    int id, {
    int? lastActiveAt,
    int? idleStartedAt,
    int? endedAt,
    int? accumulatedActiveMs,
    String? reportStatus,
    String? extra,
    int? updatedAt,
  }) async {
    if (_database == null) return false;

    try {
      final List<String> setClauses = <String>[];
      final List<Object?> params = <Object?>[];

      if (lastActiveAt != null) {
        setClauses.add('last_active_at = ?');
        params.add(lastActiveAt);
      }
      if (idleStartedAt != null) {
        setClauses.add('idle_started_at = ?');
        params.add(idleStartedAt);
      }
      if (endedAt != null) {
        setClauses.add('ended_at = ?');
        params.add(endedAt);
      }
      if (accumulatedActiveMs != null) {
        setClauses.add('accumulated_active_ms = ?');
        params.add(accumulatedActiveMs);
      }
      if (reportStatus != null) {
        setClauses.add('report_status = ?');
        params.add(reportStatus);
      }
      if (extra != null) {
        setClauses.add('extra = ?');
        params.add(extra);
      }

      /// 始终刷新更新时间，保证本地数据有最近状态。
      final int realUpdatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;
      setClauses.add('updated_at = ?');
      params.add(realUpdatedAt);

      if (setClauses.isEmpty) return true;

      params.add(id);

      _database!.execute('''
        UPDATE ${InteractionRecordConstants.tableName}
        SET ${setClauses.join(', ')}
        WHERE id = ?
      ''', params);

      return true;
    } catch (e) {
      debugPrint('[InteractionRecordDatabase] update failed: $e');
      return false;
    }
  }

  /// 更新交互记录状态
  Future<bool> updateStatus(
    int id,
    InteractionRecordReportStatus status,
  ) async {
    return updateRecord(
      id,
      reportStatus: status.value,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 根据会话 ID 获取交互记录
  Future<InteractionRecordModel?> getBySessionId(String sessionId) async {
    if (_database == null) return null;

    try {
      final ResultSet result = _database!.select('''
        SELECT *
        FROM ${InteractionRecordConstants.tableName}
        WHERE session_id = ?
        ORDER BY id DESC
        LIMIT 1
      ''', <Object?>[sessionId]);

      if (result.isEmpty) return null;
      return InteractionRecordModel.fromMap(result.first);
    } catch (e) {
      debugPrint('[InteractionRecordDatabase] getBySessionId failed: $e');
      return null;
    }
  }

  /// 获取待上报交互记录
  Future<List<InteractionRecordModel>> getPendingRecords({int limit = 50}) async {
    if (_database == null) return <InteractionRecordModel>[];

    try {
      final ResultSet result = _database!.select('''
        SELECT *
        FROM ${InteractionRecordConstants.tableName}
        WHERE report_status IN (?, ?)
        ORDER BY created_at ASC
        LIMIT ?
      ''', <Object?>[
        InteractionRecordReportStatus.pending.value,
        InteractionRecordReportStatus.failed.value,
        limit,
      ]);

      return result
          .map((Row row) => InteractionRecordModel.fromMap(row))
          .toList();
    } catch (e) {
      debugPrint('[InteractionRecordDatabase] getPendingRecords failed: $e');
      return <InteractionRecordModel>[];
    }
  }

  /// 删除单条交互记录
  Future<bool> delete(int id) async {
    if (_database == null) return false;

    try {
      _database!.execute('''
        DELETE FROM ${InteractionRecordConstants.tableName}
        WHERE id = ?
      ''', <Object?>[id]);
      return true;
    } catch (e) {
      debugPrint('[InteractionRecordDatabase] delete failed: $e');
      return false;
    }
  }

  /// 批量删除交互记录
  Future<bool> deleteByIds(List<int> ids) async {
    if (_database == null || ids.isEmpty) return false;

    try {
      final String placeholders = ids.map((_) => '?').join(',');
      _database!.execute('''
        DELETE FROM ${InteractionRecordConstants.tableName}
        WHERE id IN ($placeholders)
      ''', ids);
      return true;
    } catch (e) {
      debugPrint('[InteractionRecordDatabase] deleteByIds failed: $e');
      return false;
    }
  }

  /// 清理过期记录
  Future<int> cleanExpiredRecords() async {
    if (_database == null) return 0;

    try {
      final int expirationTime = DateTime.now().millisecondsSinceEpoch -
          (InteractionRecordConstants.maxRetentionDays *
              24 *
              60 *
              60 *
              1000);

      _database!.execute('''
        DELETE FROM ${InteractionRecordConstants.tableName}
        WHERE created_at < ?
      ''', <Object?>[expirationTime]);

      return _database!.updatedRows;
    } catch (e) {
      debugPrint('[InteractionRecordDatabase] cleanExpiredRecords failed: $e');
      return 0;
    }
  }

  /// 清理超出最大条数的记录
  Future<int> cleanExcessRecords() async {
    if (_database == null) return 0;

    try {
      final ResultSet countResult = _database!.select('''
        SELECT COUNT(*) AS count
        FROM ${InteractionRecordConstants.tableName}
      ''');

      final int count = countResult.first['count'] as int? ?? 0;
      if (count <= InteractionRecordConstants.maxRecordCount) return 0;

      final int deleteCount =
          count - InteractionRecordConstants.maxRecordCount;

      _database!.execute('''
        DELETE FROM ${InteractionRecordConstants.tableName}
        WHERE id IN (
          SELECT id
          FROM ${InteractionRecordConstants.tableName}
          ORDER BY created_at ASC
          LIMIT ?
        )
      ''', <Object?>[deleteCount]);

      return _database!.updatedRows;
    } catch (e) {
      debugPrint('[InteractionRecordDatabase] cleanExcessRecords failed: $e');
      return 0;
    }
  }

  /// 执行数据库清理
  Future<void> performCleanup() async {
    await cleanExpiredRecords();
    await cleanExcessRecords();
  }

  /// 关闭数据库引用
  void close() {
    _database = null;
    _isInitialized = false;
  }
}
