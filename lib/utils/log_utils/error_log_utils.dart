import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// 错误日志工具类
/// 用于收集错误和崩溃信息，写入文件
/// 在下次启动时检查、上报并清除日志
class ErrorLogUtils {
  /// 旧版单文件日志的文件名。
  ///
  /// 新架构初始化时如果发现这个旧文件，会尝试迁移成第一片分片文件，
  /// 避免升级后直接丢失历史日志。
  static const String _legacyLogFileName = 'langwise_log.json';

  /// 日志系统在应用私有目录下的根目录名。
  static const String _logRootDirName = 'langwise_logs';

  /// 正式日志分片所在的子目录名。
  static const String _segmentDirName = 'log_segments';

  /// 上传临时文件所在的子目录名。
  static const String _uploadTmpDirName = 'upload_tmp';

  /// 正式日志分片文件名前缀。
  ///
  /// 结合递增序号后形成 `langwise_log_000001.jsonl` 这种稳定命名，
  /// 便于按文件名直接排序。
  static const String _segmentFilePrefix = 'langwise_log_';

  /// 正式日志分片文件扩展名。
  static const String _segmentFileExtension = '.jsonl';

  /// 单个日志分片的最大字节数，达到阈值后切换到下一个分片。
  static const int _maxSegmentBytes = 512 * 1024;

  /// 所有正式日志分片允许占用的总字节上限。
  ///
  /// 超过该阈值后，只会删除最旧整文件，不会裁剪任何单个文件内容。
  static const int _maxLogBytes = 10 * 1024 * 1024;

  /// 用于匹配并解析正式日志分片文件名的正则表达式。
  ///
  /// 当前要求文件名格式固定为 `langwise_log_000001.jsonl`，
  /// 正则中的分组会提取出递增序号，供排序和状态恢复使用。
  static final RegExp _segmentFileRegExp =
      RegExp(r'^langwise_log_(\d{6})\.jsonl$');

  /// `ErrorLogUtils` 的全局单例实例。
  static final ErrorLogUtils _instance = ErrorLogUtils._internal();

  /// 工厂构造，统一返回单例。
  factory ErrorLogUtils() => _instance;

  /// 私有构造，禁止外部重复创建实例。
  ErrorLogUtils._internal();

  /// 对外暴露的单例快捷访问入口。
  static ErrorLogUtils get to => _instance;

  /// 所有日志文件 IO 的串行执行链。
  ///
  /// 这里不引入额外线程池，而是把“写日志 / 切分分片 / 删除旧文件 / 生成上传文件”
  /// 全部挂到同一条 Future 队列上顺序执行，避免多个异步 IO 同时命中磁盘，
  /// 影响网络缓存、音视频缓存和播放器相关文件操作的流畅度。
  Future<void> _ioQueue = Future<void>.value();

  /// 缓存应用版本号，避免每条日志都重复向平台层查询版本信息。
  Future<String>? _versionFuture;

  /// 正式日志分片目录：只存放可长期保留的日志分片文件。
  Directory? _segmentDir;

  /// 上传临时目录：只存放整合后的临时上传文件，上传完成后立即删除。
  Directory? _uploadTmpDir;

  /// 当前正在追加写入的活跃分片文件。
  File? _currentSegmentFile;

  /// 当前活跃分片序号，决定下一个分片文件名。
  int _currentSegmentIndex = 0;

  /// 当前活跃分片已写入的字节数，用于快速判断是否需要切换分片。
  int _currentSegmentBytes = 0;

  /// 所有正式日志分片的累计字节数，用于控制总量不超过 10MB。
  int _totalSegmentBytes = 0;

  /// 目录和分片状态是否已完成初始化。
  bool _initialized = false;

  /// 获取所有正式日志分片总大小（字节）
  ///
  /// 新架构下已经不是单文件，因此这里返回的是 `log_segments` 目录下
  /// 所有正式分片文件的累计大小，不包含上传临时文件。
  Future<int> getLogFileSize() async {
    try {
      return await _enqueueIoTask<int>(() async {
        await _ensureInitialized();
        return _totalSegmentBytes;
      });
    } catch (_) {
      return 0;
    }
  }

  /// 兼容旧调用：返回当前活跃日志分片文件，不建议直接用于上传。
  ///
  /// 这个方法保留是为了降低旧调用点的改造成本。它只返回“当前活跃分片”，
  /// 不能代表完整日志集合，因此上传场景必须改用 [buildUploadTempLogFile]。
  Future<File> getLogFile() async {
    return _enqueueIoTask<File>(() async {
      await _ensureInitialized();
      return _ensureWritableSegment(0);
    });
  }

  /// 获取正式日志分片列表
  ///
  /// 返回值按文件序号从旧到新排序，调用方可以直接按返回顺序读取，
  /// 得到与原始写入时间一致的日志顺序。
  Future<List<File>> getLogSegmentFiles() async {
    try {
      return await _enqueueIoTask<List<File>>(() async {
        await _ensureInitialized();
        return _listSegmentFiles();
      });
    } catch (_) {
      return const <File>[];
    }
  }

  /// 记录错误信息到文件
  /// [error] 错误对象
  /// [stackTrace] 堆栈跟踪
  ///
  /// 行为分两部分：
  /// 1. 保留现有友盟错误上报能力，便于线上统一检索
  /// 2. 将结构化后的单行 JSON 追加写入本地分片日志
  ///
  /// 本地写入不会直接裁剪文件内容，只会在后台串行队列中做：
  /// - 追加写入
  /// - 超过 512KB 时切换新分片
  /// - 总量超过 10MB 时删除最旧整文件
  Future<void> logError(dynamic error, StackTrace? stackTrace) async {
    try {
      if (kDebugMode) {
        print('记录错误: $error');
        if (stackTrace != null) print(stackTrace);
      }
      final errorInfo = <String, dynamic>{
        'type': 'error',
        'time': DateFormatUtil.formatStr(DateTime.now().toLocal(),
            newPattern: "yyyy-MM-dd HH:mm:ss"),
        'err': toSingleLineJsonSafe(error),
        'platform': Platform.operatingSystem,
        'version': await _getAppVersion(),
        'route': Get.currentRoute,
      };
      if (stackTrace != null) {
        errorInfo['stack'] = toSingleLineJsonSafe(stackTrace);
      }
      final String line = jsonEncode(errorInfo);
      UmengUtils.error(line);
      await _appendLine(line);
    } catch (e) {
      if (kDebugMode) {
        print('记录错误日志失败: $e');
      }
    }
  }

  /// 记录普通信息到文件
  /// [message] 普通信息
  ///
  /// 普通信息日志会遵循用户配置开关 `recordLog`。
  /// 如果用户关闭日志记录，则直接跳过，避免无意义的磁盘写入。
  Future<void> logInfo(Object message) async {
    if (UserStore.to.userInfo.value.recordLog == 0) return;
    try {
      final info = <String, dynamic>{
        'type': 'info',
        'userId': UserStore.to.userInfo.value.userId,
        'time': DateFormatUtil.formatStr(DateTime.now().toLocal(),
            newPattern: "yyyy-MM-dd HH:mm:ss"),
        'platform': Platform.operatingSystem,
        'version': await _getAppVersion(),
        'info': toSingleLineJsonSafe(message),
      };
      await _appendLine(jsonEncode(info));
    } catch (e) {
      if (kDebugMode) {
        print('记录普通信息日志失败: $e');
      }
    }
  }

  /// 清除错误日志和上传临时文件
  ///
  /// 这里只删除日志系统自己的目录内容：
  /// - 正式日志分片
  /// - 上传临时文件
  ///
  /// 不会触碰缓存目录、网络缓存、音视频资源文件，也不会影响其他模块的文件。
  Future<void> clearErrorLogs() async {
    try {
      await _enqueueIoTask<void>(() async {
        await _ensureInitialized();
        await _deleteAllFilesInDirectory(_segmentDir);
        await _deleteAllFilesInDirectory(_uploadTmpDir);
        _currentSegmentFile = null;
        _currentSegmentIndex = 0;
        _currentSegmentBytes = 0;
        _totalSegmentBytes = 0;
      });
    } catch (e) {
      if (kDebugMode) {
        print('清除错误日志失败: $e');
      }
    }
  }

  /// 整合所有日志分片，生成一个临时上传文件
  ///
  /// 上传接口更适合接收单个文件，因此这里会把当前所有正式日志分片
  /// 按“从旧到新”的顺序流式复制到一个临时 jsonl 文件中。
  ///
  /// 注意：
  /// - 不会把所有日志一次性读入内存再拼成大字符串
  /// - 不会修改任何正式日志分片
  /// - 生成的文件只用于上传，调用方上传完成后必须删除
  Future<File?> buildUploadTempLogFile() async {
    try {
      return await _enqueueIoTask<File?>(() async {
        await _ensureInitialized();
        final List<File> segments = await _listNonEmptySegmentFiles();
        if (segments.isEmpty) return null;
        final String timestamp =
            DateTime.now().millisecondsSinceEpoch.toString();
        final File uploadFile = File(
            '${_uploadTmpDir!.path}${Platform.pathSeparator}langwise_log_upload_$timestamp.jsonl');
        if (await uploadFile.exists()) {
          await uploadFile.delete();
        }
        // 使用流式复制整合多个分片，避免把全部日志一次性放入内存。
        final IOSink sink =
            uploadFile.openWrite(mode: FileMode.write, encoding: utf8);
        try {
          for (final File segment in segments) {
            await sink.addStream(segment.openRead());
          }
          await sink.flush();
        } finally {
          await sink.close();
        }
        if (await uploadFile.length() == 0) {
          await uploadFile.delete();
          return null;
        }
        return uploadFile;
      });
    } catch (e) {
      if (kDebugMode) {
        print('生成上传日志临时文件失败: $e');
      }
      return null;
    }
  }

  /// 删除上传完成后的临时日志文件
  ///
  /// 这里只清理 [buildUploadTempLogFile] 生成的临时文件，
  /// 不会删除正式日志分片，避免上传成功后把本地日志源数据一并清空。
  Future<void> deleteUploadTempLogFile(File? file) async {
    if (file == null) return;
    try {
      await _enqueueIoTask<void>(() async {
        if (await file.exists()) {
          await file.delete();
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('删除上传日志临时文件失败: $e');
      }
    }
  }

  /// 将输入内容压缩成适合 jsonl 落盘的单行文本。
  ///
  /// 处理策略：
  /// - 如果输入本身是合法 JSON 字符串，则重新编码成紧凑单行 JSON
  /// - 如果输入是 Map/List/对象，则直接 `jsonEncode`
  /// - 如果输入只是普通文本，则移除换行、制表符和冗余空白
  ///
  /// 这样可以确保“每条日志严格占一行”，后续无论是分片存储还是上传整合，
  /// 都不需要额外处理跨行问题。
  String toSingleLineJsonSafe(Object? input) {
    try {
      if (input == null) {
        return 'null';
      }
      if (input is String) {
        final String s = input.trim();
        final dynamic decoded = jsonDecode(s);
        return jsonEncode(decoded);
      }
      return jsonEncode(input);
    } catch (_) {
      try {
        final String s = input.toString();
        final String withoutBreaks =
            s.replaceAll(RegExp(r'(\r\n|\r|\n|\t)+'), ' ');
        return withoutBreaks.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
      } catch (_) {
        return input.toString();
      }
    }
  }

  /// 将单条日志文本追加到当前分片，并在必要时触发分片轮转和总量清理。
  ///
  /// 这是整个日志系统真正发生磁盘写入的入口，所有写操作都必须经过它，
  /// 这样才能保证：
  /// - 同一时刻只有一个日志 IO 任务在执行
  /// - 不会出现多个并发写入互相覆盖
  /// - 不会边写边删，造成分片状态混乱
  Future<void> _appendLine(String line) async {
    await _enqueueIoTask<void>(() async {
      await _ensureInitialized();
      final String payload = '$line\n';
      final int appendBytes = utf8.encode(payload).length;

      // 先确认本次写入应落到哪个分片，如果当前分片接近上限则新建分片。
      final File file = await _ensureWritableSegment(appendBytes);

      // 这里只做尾部追加，不做任何旧内容裁剪或整段回写。
      await file.writeAsString(payload,
          mode: FileMode.append, encoding: utf8, flush: false);
      _currentSegmentBytes += appendBytes;
      _totalSegmentBytes += appendBytes;

      // 总量超限后只删除最旧整文件，避免高成本“删除文件头部内容”。
      if (_totalSegmentBytes > _maxLogBytes) {
        await _trimOldSegments();
      }
    });
  }

  /// 将日志文件相关任务串行化执行。
  ///
  /// 每次传入的新任务都会接在上一个任务后面，形成稳定的单通道 IO 顺序。
  /// 这样可以显著降低磁盘竞争概率，避免日志系统对播放器、缓存和请求落盘
  /// 造成额外抖动。
  Future<T> _enqueueIoTask<T>(Future<T> Function() task) {
    final Completer<T> completer = Completer<T>();
    _ioQueue = _ioQueue.catchError((_) {}).then((_) async {
      try {
        completer.complete(await task());
      } catch (e, stackTrace) {
        completer.completeError(e, stackTrace);
      }
    });
    return completer.future;
  }

  /// 初始化日志目录和当前分片状态。
  ///
  /// 初始化只执行一次，内容包括：
  /// 1. 创建日志根目录、分片目录、上传临时目录
  /// 2. 如有旧的单文件日志，则迁移到第一片分片
  /// 3. 扫描现有分片，恢复当前活跃分片和总大小
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    final Directory baseDir = await _getLogBaseDirectory();
    final Directory rootDir =
        Directory('${baseDir.path}${Platform.pathSeparator}$_logRootDirName');
    final Directory segmentDir =
        Directory('${rootDir.path}${Platform.pathSeparator}$_segmentDirName');
    final Directory uploadTmpDir =
        Directory('${rootDir.path}${Platform.pathSeparator}$_uploadTmpDirName');
    await rootDir.create(recursive: true);
    await segmentDir.create(recursive: true);
    await uploadTmpDir.create(recursive: true);
    _segmentDir = segmentDir;
    _uploadTmpDir = uploadTmpDir;
    await _migrateLegacySingleFile(baseDir, segmentDir);
    final List<File> segmentFiles = await _listSegmentFiles();
    if (segmentFiles.isEmpty) {
      _currentSegmentIndex = 0;
      _currentSegmentBytes = 0;
      _currentSegmentFile = null;
      _totalSegmentBytes = 0;
    } else {
      _currentSegmentFile = segmentFiles.last;
      _currentSegmentIndex = _parseSegmentIndex(_currentSegmentFile!);
      _currentSegmentBytes = await _currentSegmentFile!.length();
      _totalSegmentBytes = 0;
      for (final File file in segmentFiles) {
        _totalSegmentBytes += await file.length();
      }
    }
    _initialized = true;
  }

  /// 根据平台获取日志根目录的父目录。
  ///
  /// 这里只选应用私有目录，避免和外部缓存或共享目录混在一起，
  /// 降低被系统清理或被其他模块误操作的概率。
  Future<Directory> _getLogBaseDirectory() async {
    if (Platform.isAndroid) {
      return getApplicationDocumentsDirectory();
    }
    if (Platform.isIOS || Platform.isWindows || Platform.isMacOS) {
      return getApplicationSupportDirectory();
    }
    return getTemporaryDirectory();
  }

  /// 将旧版单文件日志迁移为新架构下的第一片分片文件。
  ///
  /// 迁移策略尽量保守：
  /// - 如果已经存在分片文件，说明新架构已经开始工作，此时直接删除旧文件
  /// - 如果还没有分片，则把旧文件直接重命名成第一片，避免重复复制
  Future<void> _migrateLegacySingleFile(
      Directory baseDir, Directory segmentDir) async {
    final File legacyFile =
        File('${baseDir.path}${Platform.pathSeparator}$_legacyLogFileName');
    if (!await legacyFile.exists()) return;
    final List<File> segmentFiles = await _listSegmentFiles();
    if (segmentFiles.isNotEmpty) {
      await legacyFile.delete();
      return;
    }
    final File migratedFile = File(
        '${segmentDir.path}${Platform.pathSeparator}${_buildSegmentFileName(1)}');
    await legacyFile.rename(migratedFile.path);
  }

  /// 获取当前可写分片。
  ///
  /// 如果当前没有活跃分片，则创建第一片。
  /// 如果当前分片再写入本条日志后会超过 512KB，则切到新分片。
  Future<File> _ensureWritableSegment(int appendBytes) async {
    File? current = _currentSegmentFile;
    if (current == null) {
      return _createNextSegmentFile();
    }
    final bool shouldRotate = _currentSegmentBytes > 0 &&
        _currentSegmentBytes + appendBytes > _maxSegmentBytes;
    if (!shouldRotate) return current;
    return _createNextSegmentFile();
  }

  /// 创建下一个日志分片文件，并将其设为新的活跃分片。
  ///
  /// 分片文件名使用固定递增序号，这样按文件名排序即可得到时间顺序，
  /// 后续删除最旧文件和整合上传时都会更简单稳定。
  Future<File> _createNextSegmentFile() async {
    final int nextIndex = _currentSegmentIndex + 1;
    final File nextFile = File(
        '${_segmentDir!.path}${Platform.pathSeparator}${_buildSegmentFileName(nextIndex)}');
    if (!await nextFile.exists()) {
      await nextFile.create(recursive: true);
    }
    _currentSegmentIndex = nextIndex;
    _currentSegmentFile = nextFile;
    _currentSegmentBytes = await nextFile.length();
    return nextFile;
  }

  /// 列出所有正式日志分片，并按“从旧到新”排序返回。
  Future<List<File>> _listSegmentFiles() async {
    final List<FileSystemEntity> entities =
        await _segmentDir!.list(followLinks: false).toList();
    final List<File> files = entities
        .whereType<File>()
        .where(
            (File file) => _segmentFileRegExp.hasMatch(_fileNameOf(file.path)))
        .toList();
    files.sort((File a, File b) =>
        _parseSegmentIndex(a).compareTo(_parseSegmentIndex(b)));
    return files;
  }

  /// 列出所有非空正式日志分片。
  ///
  /// 上传整合时只关心有实际内容的文件，避免把空分片一并打包进去。
  Future<List<File>> _listNonEmptySegmentFiles() async {
    final List<File> files = await _listSegmentFiles();
    final List<File> result = <File>[];
    for (final File file in files) {
      if (await file.length() > 0) {
        result.add(file);
      }
    }
    return result;
  }

  /// 删除最旧的正式日志分片，直到总大小回落到 10MB 以内。
  ///
  /// 这是新架构最关键的性能优化点：
  /// - 只删除整文件
  /// - 永远不删除文件内容的一部分
  /// - 永远不做“保留后半段再覆写”的高成本操作
  ///
  /// 这样能把清理动作控制在较轻的文件级操作上，尽量减少对磁盘 IO 的冲击。
  Future<void> _trimOldSegments() async {
    final List<File> files = await _listSegmentFiles();
    for (int i = 0;
        i < files.length - 1 && _totalSegmentBytes > _maxLogBytes;
        i++) {
      final File file = files[i];
      final int length = await file.length();
      await file.delete();
      _totalSegmentBytes -= length;
    }
    final List<File> remainFiles = await _listSegmentFiles();
    if (remainFiles.isEmpty) {
      _currentSegmentFile = null;
      _currentSegmentIndex = 0;
      _currentSegmentBytes = 0;
      _totalSegmentBytes = 0;
      return;
    }
    _currentSegmentFile = remainFiles.last;
    _currentSegmentIndex = _parseSegmentIndex(_currentSegmentFile!);
    _currentSegmentBytes = await _currentSegmentFile!.length();
  }

  /// 删除指定目录下的所有普通文件。
  ///
  /// 当前仅用于清理日志系统自己的目录，不递归删除子目录，
  /// 以降低误删范围。
  Future<void> _deleteAllFilesInDirectory(Directory? dir) async {
    if (dir == null || !await dir.exists()) return;
    final List<FileSystemEntity> entities =
        await dir.list(followLinks: false).toList();
    for (final FileSystemEntity entity in entities) {
      if (entity is File) {
        await entity.delete();
      }
    }
  }

  /// 从分片文件名中解析序号，用于排序和恢复当前分片状态。
  int _parseSegmentIndex(File file) {
    final Match? match = _segmentFileRegExp.firstMatch(_fileNameOf(file.path));
    if (match == null) return 0;
    return int.tryParse(match.group(1) ?? '') ?? 0;
  }

  /// 根据分片序号生成标准化文件名。
  String _buildSegmentFileName(int index) {
    return '$_segmentFilePrefix${index.toString().padLeft(6, '0')}$_segmentFileExtension';
  }

  /// 从完整路径中提取文件名。
  String _fileNameOf(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  /// 获取并缓存应用版本号。
  ///
  /// 版本号写入每条日志是为了后续排查问题时快速判断日志来源版本，
  /// 但平台查询本身没有必要每次都做，因此这里做一次性缓存。
  Future<String> _getAppVersion() async {
    _versionFuture ??= () async {
      try {
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();
        return '${packageInfo.version}+${packageInfo.buildNumber}';
      } catch (_) {
        return 'unknown';
      }
    }();
    return _versionFuture!;
  }
}
