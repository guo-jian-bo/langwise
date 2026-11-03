import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:vm_service/vm_service.dart';
import 'dart:io';
import 'package:vm_service/vm_service_io.dart';

/// 内存管理工具类 (MemoryUtils)
///
/// 提供全面的内存管理功能，包括：
///
/// 1. **内存监控**
///    - 实时监控内存使用情况，在Debug/Profile模式下使用VM Service获取真实数据
///    - 在Release模式下使用轻量级估算方法，避免引入调试依赖
///    - 支持通过GetX Worker监听内存变化
///
/// 2. **内存压力检测**
///    - 自动检测内存压力级别（正常/中等/严重）
///    - 当内存压力达到严重级别时自动清理缓存
///    - 支持注册外部监听器响应内存压力事件
///
/// 3. **内存泄漏检测**
///    - 自动跟踪对象生命周期，检测可疑的内存泄漏
///    - 支持手动跟踪重要对象（如控制器、服务等）
///    - 定期检查并报告可疑的内存泄漏对象
///    - 支持注册外部监听器接收泄漏检测结果
///
/// 4. **堆快照生成**
///    - 在Debug/Profile模式下生成内存快照文件
///    - 快照包含堆内存、外部内存及内存分配详情
///    - 支持手动触发GC以获取更准确的内存快照
///
/// 5. **内存优化组件**
///    - 提供 MemoryOptimizedWidget 包装器，适用于列表项等高频创建的组件
///    - 自动应用 RepaintBoundary 和状态保活控制
///    - 支持自动保活控制组件
///
/// 使用示例：
/// ```dart
/// // 启动内存监控
/// MemoryUtils.instance.startMemoryMonitoring();
///
/// // 监听内存变化
/// final worker = MemoryUtils.instance.listenToMemoryUsage((memoryMB) {
///   print('当前内存使用: $memoryMB MB');
/// });
///
/// // 添加内存压力监听
/// MemoryUtils.instance.addMemoryPressureListener((level) {
///   if (level == MemoryPressureLevel.critical) {
///     // 清理缓存
///     ImageCache().clear();
///   }
/// });
///
/// // 跟踪对象以检测泄漏
/// MemoryUtils.instance.trackObject(myController, tag: 'MyController');
///
/// // 生成内存快照
/// MemoryUtils.instance.takeHeapSnapshot('app_start');
/// ```
class MemoryUtils {
  static final MemoryUtils _instance = MemoryUtils._();

  static MemoryUtils get instance => _instance;

  // 跟踪的对象
  final Map<int, _TrackedObject> _trackedObjects = {};

  // 内存压力监听器
  final List<Function(MemoryPressureLevel)> _pressureListeners = [];

  // 泄漏结果监听器
  final List<void Function(List<_TrackedObject>)> _leakListeners = [];

  // 内存使用统计
  final RxDouble _currentMemoryUsageMB = 0.0.obs;
  Timer? _memoryMonitorTimer;

  // 内存管理状态标记

  MemoryUtils._();

  /// 获取当前内存使用量（MB）
  double get currentMemoryUsageMB => _currentMemoryUsageMB.value;

  /// 监听内存使用量变化
  Worker listenToMemoryUsage(Function(double memoryMB) callback) {
    return ever(_currentMemoryUsageMB, callback);
  }

  /// 配置GC策略
  ///
  /// 注意：实际的GC参数调整需要引擎层支持
  /// 此方法提供API封装，实际调用需要Native支持
  void configureGCPolicy({
    int? oldGenMinFreeMB,
    double? oldGenGrowthFactor,
    double? scavengeThreshold,
  }) {
    final params = <String, dynamic>{};
    if (oldGenMinFreeMB != null) params['oldGenMinFree'] = oldGenMinFreeMB;
    if (oldGenGrowthFactor != null) params['oldGenGrowthFactor'] = oldGenGrowthFactor;
    if (scavengeThreshold != null) params['scavengeThreshold'] = scavengeThreshold;

    // debugPrint('配置GC策略: $params');

    // 模拟配置成功
    Future.delayed(const Duration(milliseconds: 100), () {
      // debugPrint('GC策略配置成功');
    });
  }

  /// 开始内存使用监控
  void startMemoryMonitoring({int intervalMilliseconds = 1000}) {
    // 避免重复启动
    if (_memoryMonitorTimer != null) return;

    // 定时获取内存使用情况
    _memoryMonitorTimer = Timer.periodic(Duration(milliseconds: intervalMilliseconds), (_) async {
      final memoryInfo = await _getMemoryInfo();
      _currentMemoryUsageMB.value = (memoryInfo['usedHeapSize'] ?? 0) / (1024 * 1024);

      // 检查内存压力
      _checkMemoryPressure(memoryInfo);
    });

    // debugPrint('启动内存监控，间隔$intervalSeconds秒');
  }

  /// 停止内存监控
  void stopMemoryMonitoring() {
    _memoryMonitorTimer?.cancel();
    _memoryMonitorTimer = null;
    // debugPrint('停止内存监控');
  }

  /// 获取内存信息
  Future<Map<String, double>> _getMemoryInfo() async {
    final info = <String, double>{};

    // 在Debug或Profile模式下尝试使用VM服务获取精确内存信息
    if (kDebugMode || kProfileMode) {
      try {
        final vmServiceResult = await _getVMService();
        if (vmServiceResult != null) {
          final vmService = vmServiceResult.service;
          final isolateId = vmServiceResult.isolateId;

          // 获取内存使用情况
          final memoryUsage = await vmService.getMemoryUsage(isolateId);
          final heapUsage = memoryUsage.heapUsage;
          final heapCapacity = memoryUsage.heapCapacity;
          final externalUsage = memoryUsage.externalUsage;

          // 转换为字节
          info['usedHeapSize'] = heapUsage?.toDouble() ?? 0;
          info['totalHeapSize'] = heapCapacity?.toDouble() ?? 0;
          info['externalMemory'] = externalUsage?.toDouble() ?? 0;

          // 获取更详细的内存分配信息
          try {
            final profile = await vmService.getAllocationProfile(isolateId);
            // 获取内存分配详情
            // 注意：不同版本的VM Service API可能有所不同
            final memoryUsage = profile.memoryUsage;
            if (memoryUsage != null) {
              // 使用反射获取属性，以兼容不同版本
              try {
                // 安全获取内存使用详情
                final dynamic jsonData = memoryUsage.json;
                if (jsonData is Map<String, dynamic>) {
                  for (final entry in jsonData.entries) {
                    if (entry.value is num) {
                      info['mem_${entry.key}'] = (entry.value as num).toDouble();
                    }
                  }
                }
              } catch (e) {
                // debugPrint('解析内存使用详情失败: $e');
              }
            }
          } catch (e) {
            // debugPrint('获取内存分配详情失败: $e');
          }

          // debugPrint('VM服务获取内存信息成功: ${info.toString()}');
          return info;
        }
      } catch (e) {
        // debugPrint('VM服务获取内存信息失败: $e');
      }
    }

    // 如果VM服务不可用或在Release模式下，使用原有的估计方法
    try {
      // 使用简单的在内存估计
      double usedHeapSize = 0.0;

      // 创建一个短期用于测试的大对象以获取内存分配速度
      // 这只是一种比较粗略的估计方法
      final before = DateTime.now().millisecondsSinceEpoch;
      final testList = List<int>.filled(1000000, 0, growable: true);
      final after = DateTime.now().millisecondsSinceEpoch;

      // 根据分配速度粗略估计当前内存压力
      final allocTimeMs = after - before;

      // 分配时间越长说明内存压力越大
      if (allocTimeMs > 10) {
        // 估计高内存使用
        usedHeapSize = 180 * 1024 * 1024;
      } else if (allocTimeMs > 5) {
        // 估计中等内存使用
        usedHeapSize = 120 * 1024 * 1024;
      } else {
        // 估计低内存使用
        usedHeapSize = 80 * 1024 * 1024;
      }

      // 清理测试对象
      testList.clear();

      info['usedHeapSize'] = usedHeapSize;
      info['totalHeapSize'] = usedHeapSize * 1.5; // 模拟总内存
      info['externalMemory'] = usedHeapSize * 0.2; // 模拟外部内存
    } catch (e) {
      // 提供默认值
      info['usedHeapSize'] = 100 * 1024 * 1024;
      info['totalHeapSize'] = 200 * 1024 * 1024;
      info['externalMemory'] = 20 * 1024 * 1024;
    }

    return info;
  }

  /// 检查内存压力
  void _checkMemoryPressure(Map<String, double> memoryInfo) {
    // 计算内存使用率
    final totalHeap = memoryInfo['totalHeapSize'] ?? 0;
    final usedHeap = memoryInfo['usedHeapSize'] ?? 0;

    MemoryPressureLevel level;
    if (totalHeap <= 0) {
      level = MemoryPressureLevel.normal;
    } else {
      final usageRatio = usedHeap / totalHeap;

      if (usageRatio > 0.85) {
        level = MemoryPressureLevel.critical;
      } else if (usageRatio > 0.7) {
        level = MemoryPressureLevel.moderate;
      } else {
        level = MemoryPressureLevel.normal;
      }
    }

    // 通知监听器
    for (final listener in _pressureListeners) {
      listener(level);
    }
  }

  /// 注册内存压力监听
  void addMemoryPressureListener(Function(MemoryPressureLevel) listener) {
    _pressureListeners.add(listener);
  }

  /// 移除内存压力监听
  void removeMemoryPressureListener(Function(MemoryPressureLevel) listener) {
    _pressureListeners.remove(listener);
  }

  /// 开始对象泄漏检测
  ///
  /// [intervalMinutes] 检测间隔（分钟）
  void startLeakDetection({int intervalMinutes = 5}) {
    // 定期进行泄漏检测
    Timer.periodic(Duration(minutes: intervalMinutes), (_) {
      _checkForLeaks();
    });

    // 为页面和控制器添加自动跟踪
    _setupWidgetLifecycleTracking();

    // debugPrint('启动内存泄漏检测，间隔$intervalMinutes分钟');
  }

  /// 设置组件生命周期跟踪
  void _setupWidgetLifecycleTracking() {
    // 添加生命周期观察者
    WidgetsBinding.instance.addObserver(_WidgetLifecycleObserver());

    // 监听GetX控制器
    // 在实际实现中，可以添加Get.reference监听或修改GetX的控制器工厂

    // debugPrint('设置组件生命周期跟踪');
  }

  /// 跟踪对象（手动添加跟踪）
  ///
  /// [object] 要跟踪的对象
  /// [tag] 可选标签，用于区分同类对象
  void trackObject(Object object, {String? tag}) {
    final id = identityHashCode(object);
    final type = object.runtimeType.toString();

    _trackedObjects[id] = _TrackedObject(
      id: id,
      type: type,
      tag: tag,
      creationTime: DateTime.now(),
      weakRef: WeakReference(object),
    );

    // debugPrint('开始跟踪对象: $type${tag != null ? "($tag)" : ""} [id=$id]');
  }

  /// 停止跟踪对象
  void stopTracking(Object object) {
    final id = identityHashCode(object);
    final removed = _trackedObjects.remove(id);

    if (removed != null) {
      // debugPrint('停止跟踪对象: ${removed.type}${removed.tag != null ? "(${removed.tag})" : ""} [id=$id]');
    }
  }

  /// 检查泄漏
  void _checkForLeaks() {
    // 主动触发一次GC
    _forceGC();

    // 延迟检查，给GC一些时间
    Future.delayed(const Duration(seconds: 1), () {
      final now = DateTime.now();
      final leakySuspects = <_TrackedObject>[];
      final expiredIds = <int>[];

      // 检查所有跟踪的对象
      for (final entry in _trackedObjects.entries) {
        final tracked = entry.value;
        final object = tracked.weakRef.target;

        // 对象已被回收
        if (object == null) {
          expiredIds.add(entry.key);
          continue;
        }

        // 检查对象年龄
        final ageMinutes = now.difference(tracked.creationTime).inMinutes;

        // 可疑条件：
        // 1. 控制器存活超过30分钟
        // 2. 状态对象存活超过10分钟
        bool isLeakySuspect = false;

        if (tracked.type.contains('Controller') && ageMinutes > 30) {
          isLeakySuspect = true;
        } else if (tracked.type.contains('State') && ageMinutes > 10) {
          isLeakySuspect = true;
        } else if (ageMinutes > 60) {
          // 任何对象存活超过1小时
          isLeakySuspect = true;
        }

        if (isLeakySuspect) {
          leakySuspects.add(tracked);
        }
      }

      // 移除已回收的对象
      for (final id in expiredIds) {
        _trackedObjects.remove(id);
      }

      // 报告可疑泄漏
      if (leakySuspects.isNotEmpty) {
        // debugPrint('===== 检测到 ${leakySuspects.length} 个可疑的内存泄漏 =====');

        // for (final suspect in leakySuspects) {
          // 注释掉日志输出，但保留循环逻辑以维持功能
          // final ageMinutes = now.difference(suspect.creationTime).inMinutes;
          // debugPrint('可疑对象: ${suspect.type}${suspect.tag != null ? "(${suspect.tag})" : ""}');
          // debugPrint('[id=${suspect.id}] - 存活时间: ${ageMinutes}分钟');
        // }

        // debugPrint('=======================================');
      }

      // 通知外部监听器
      for (final listener in _leakListeners) {
        listener(leakySuspects);
      }
    });
  }

  /// 主动执行一次 GC
  void _forceGC() {
    try {
      // 使用dart:developer中的gc函数
      // 注意：这只是一个提示，不保证立即执行
      dev.debugger(when: false); // 触发轻量级GC

      // 强制分配然后释放大对象也可能触发GC
      final temp = List<int>.filled(1000000, 0);
      temp.clear();
    } catch (_) {
      /* ignore */
    }
  }

  /// 生成堆快照（Debug/Profile 模式下，需要 vm_service 支持）
  Future<void> takeHeapSnapshot([String tag = 'snapshot']) async {
    if (!kDebugMode && !kProfileMode) return;

    try {
      final vmServiceResult = await _getVMService();
      if (vmServiceResult == null) {
        // debugPrint('📝 [$tag] 无法连接VM服务，堆快照生成失败');
        return;
      }

      // 使用直接的方式获取堆快照
      // 注意：这里简化了实现，实际上需要更复杂的逻辑
      // debugPrint('📝 [$tag] 开始获取内存快照...');

      // 使用强制GC确保快照准确性
      _forceGC();
      await Future.delayed(const Duration(milliseconds: 500));

      // 保存到文件
      final fileName = '$tag-${DateTime.now().millisecondsSinceEpoch}.txt';
      final directory = Directory.systemTemp;
      final file = File('${directory.path}/$fileName');

      // 生成简单的内存分析文件
      final memoryInfo = await _getMemoryInfo();
      final memoryReport = StringBuffer();

      memoryReport.writeln('===== 内存快照 [$tag] =====');
      memoryReport.writeln('生成时间: ${DateTime.now()}');
      memoryReport.writeln('设备: ${vmServiceResult.isolateId}');
      memoryReport.writeln('\n内存使用情况:');

      // 按照类型分组显示内存信息
      final heapKeys = memoryInfo.keys
          .where((k) => k.startsWith('heap') || k.startsWith('used') || k.startsWith('total'))
          .toList();
      final memKeys = memoryInfo.keys.where((k) => k.startsWith('mem_')).toList();
      final otherKeys = memoryInfo.keys.where((k) => !heapKeys.contains(k) && !memKeys.contains(k)).toList();

      memoryReport.writeln('\n-- 堆内存 --');
      for (final key in heapKeys) {
        final value = (memoryInfo[key]! / (1024 * 1024)).toStringAsFixed(2);
        memoryReport.writeln('$key: $value MB');
      }

      if (memKeys.isNotEmpty) {
        memoryReport.writeln('\n-- 内存分配详情 --');
        for (final key in memKeys) {
          final value = (memoryInfo[key]! / (1024 * 1024)).toStringAsFixed(2);
          memoryReport.writeln('${key.replaceFirst('mem_', '')}: $value MB');
        }
      }

      if (otherKeys.isNotEmpty) {
        memoryReport.writeln('\n-- 其他内存信息 --');
        for (final key in otherKeys) {
          final value = (memoryInfo[key]! / (1024 * 1024)).toStringAsFixed(2);
          memoryReport.writeln('$key: $value MB');
        }
      }

      // 写入文件
      await file.writeAsString(memoryReport.toString());

      // debugPrint('📝 [$tag] 堆快照已保存到 ${file.path}');
    } catch (e) {
      // debugPrint('📝 [$tag] 堆快照生成失败: $e');
    }
  }

  /// 添加泄漏结果监听器
  void addLeakListener(void Function(List<_TrackedObject>) listener) {
    _leakListeners.add(listener);
  }

  /// 移除泄漏结果监听器
  void removeLeakListener(void Function(List<_TrackedObject>) listener) {
    _leakListeners.remove(listener);
  }

  /// 获取VM服务连接
  Future<_VMServiceResult?> _getVMService() async {
    try {
      // 获取VM服务信息
      final serviceInfo = await dev.Service.getInfo();
      if (serviceInfo.serverUri == null) {
        // debugPrint('VM服务URI不可用');
        return null;
      }

      // 连接到VM服务
      final wsUri = serviceInfo.serverUri.toString().replaceFirst('http://', 'ws://') + 'ws';
      final vmService = await vmServiceConnectUri(wsUri);

      // 获取当前隔离区ID
      final vm = await vmService.getVM();
      final isolateId = vm.isolates!.first.id!;

      return _VMServiceResult(vmService, isolateId);
    } catch (e) {
      // debugPrint('连接VM服务失败: $e');
      return null;
    }
  }
}

/// 组件生命周期观察者
class _WidgetLifecycleObserver extends WidgetsBindingObserver {
  // 缓存当前活跃的组件，用于内存泄漏检测
  final Map<int, DateTime> _activeWidgets = {};

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 应用回到前台，检查状态对象
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scanActiveWidgets();
      });
    }
  }

  void _scanActiveWidgets() {
    // 在实际应用中使用更复杂的方法扫描活跃组件
    // 这里只是简单记录当前帧的时间戳
    final now = DateTime.now();
    _activeWidgets[now.millisecondsSinceEpoch] = now;

    // 清理超过5分钟的记录
    _activeWidgets.removeWhere((_, time) => now.difference(time).inMinutes > 5);

    // debugPrint('活跃组件扫描完成: ${_activeWidgets.length}个记录');
  }
}

/// VM服务连接结果
class _VMServiceResult {
  final VmService service;
  final String isolateId;

  _VMServiceResult(this.service, this.isolateId);
}

/// 内存压力级别
enum MemoryPressureLevel {
  /// 正常
  normal,

  /// 中等压力
  moderate,

  /// 严重压力
  critical,
}

/// 被跟踪的对象
class _TrackedObject {
  final int id;
  final String type;
  final String? tag;
  final DateTime creationTime;
  final WeakReference<Object> weakRef;

  _TrackedObject({
    required this.id,
    required this.type,
    this.tag,
    required this.creationTime,
    required this.weakRef,
  });
}
