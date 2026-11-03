import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/impeller_utils_new.dart';
import 'package:langwise/utils/memory_utils.dart';
import 'package:langwise/utils/performance_monitor_utils.dart';

/// 性能监控服务
///
/// 集成了所有性能优化工具，提供统一的性能监控和优化接口
class PerformanceService extends GetxService {
  static PerformanceService get to => Get.find<PerformanceService>();

  /// 是否启用性能监控
  final RxBool _monitoringEnabled = false.obs;

  bool get isMonitoringEnabled => _monitoringEnabled.value;

  /// 性能监控配置
  final Map<String, dynamic> _config = {
    // 性能监控配置
    'monitoring': {
      'historyLength': 60, // 保留60秒历史
      'sampleRate': 1000, // 每1000毫秒采样一次
    },
    // 阈值配置
    'thresholds': {
      'fps': {'warn': 45.0, 'alert': 30.0},
      'memory': {'warn': 150.0, 'alert': 300.0},
      'jank': {'warn': 5.0, 'alert': 20.0},
      'builds': {'warn': 60.0, 'alert': 120.0},
    },
    // 着色器预热配置
    'shader': {
      'maxDuration': 400, // 预热最长时间（毫秒）
      'frameBudget': 8, // 每帧编译预算（毫秒）
    },
    // 内存配置
    'memory': {
      'oldGenMinFreeMB': 100, // 为长寿命对象预留空间（MB）
      'oldGenGrowthFactor': 1.3, // 老生代扩容因子
      'scavengeThreshold': 0.55, // 新生代晋升阈值
      'monitorInterval': 5, // 内存监控间隔（秒）
    }
  };

  @override
  void onInit() {
    super.onInit();

    // 仅在调试模式下启用完整性能监控
    if (kDebugMode) {
      _initializePerformanceMonitoring();
    } else {
      // 在生产环境中仅启用关键优化
      _initializeProductionOptimizations();
    }
  }

  /// 初始化性能监控（调试模式）
  void _initializePerformanceMonitoring() {
    _monitoringEnabled.value = true;

    // 1. 配置GC策略（这是PerformanceMonitorUtils不包含的功能）
    MemoryUtils.instance.configureGCPolicy(
      oldGenMinFreeMB: _config['memory']['oldGenMinFreeMB'],
      oldGenGrowthFactor: _config['memory']['oldGenGrowthFactor'],
      scavengeThreshold: _config['memory']['scavengeThreshold'],
    );

    // 2. 启动内存泄漏检测（这是PerformanceMonitorUtils不包含的功能）
    MemoryUtils.instance.startLeakDetection();

    // 3. 配置着色器预热（这是PerformanceMonitorUtils不包含的功能）
    ImpellerUtils.instance.configureShaderPrecache(
      maxDuration: _config['shader']['maxDuration'],
      frameBudget: _config['shader']['frameBudget'],
    );

    // 4. 启动核心性能监控（使用PerformanceMonitorUtils作为统一入口）
    PerformanceMonitorUtils.instance.startMonitoring(
      includeMemory: true,
      // PerformanceMonitorUtils会内部启动内存监控
      includeRender: true,
      includeBuilds: true,
      historyLength: _config['monitoring']['historyLength'],
      sampleRate: _config['monitoring']['sampleRate'],
    );

    // 5. 设置性能阈值
    _setPerformanceThresholds();

    // 6. 添加性能告警处理
    _setupAlertHandlers();

    // debugPrint('🚀 性能监控服务已启动（调试模式）');
  }

  /// 初始化生产环境优化
  void _initializeProductionOptimizations() {
    // 1. 配置着色器预热（提高首屏加载速度）
    ImpellerUtils.instance.configureShaderPrecache(
      maxDuration: _config['shader']['maxDuration'],
      frameBudget: _config['shader']['frameBudget'],
    );

    // 2. 配置GC策略
    MemoryUtils.instance.configureGCPolicy(
      oldGenMinFreeMB: _config['memory']['oldGenMinFreeMB'],
      oldGenGrowthFactor: _config['memory']['oldGenGrowthFactor'],
      scavengeThreshold: _config['memory']['scavengeThreshold'],
    );

    // debugPrint('🚀 性能优化服务已启动（生产模式）');
  }

  /// 设置性能阈值
  void _setPerformanceThresholds() {
    try {
      final Map<String, dynamic> thresholds = _config['thresholds'] as Map<String, dynamic>;

      // 设置FPS阈值
      _setThreshold(
        'fps',
        thresholds['fps'] as Map<String, dynamic>,
      );

      // 设置内存阈值
      _setThreshold(
        'memory',
        thresholds['memory'] as Map<String, dynamic>,
      );

      // 设置卡顿阈值
      _setThreshold(
        'jank',
        thresholds['jank'] as Map<String, dynamic>,
      );

      // 设置构建频率阈值
      _setThreshold(
        'builds',
        thresholds['builds'] as Map<String, dynamic>,
      );
    } catch (e) {
      // debugPrint('设置性能阈值时出错: $e');
    }
  }

  /// 设置单个指标的阈值，并确保类型安全
  void _setThreshold(String metric, Map<String, dynamic> thresholdMap) {
    try {
      // 确保值是double类型
      final double warnValue =
          (thresholdMap['warn'] is int) ? (thresholdMap['warn'] as int).toDouble() : thresholdMap['warn'] as double;

      final double alertValue = (thresholdMap['alert'] is int)
          ? (thresholdMap['alert'] as int).toDouble()
          : thresholdMap['alert'] as double;

      PerformanceMonitorUtils.instance.setThreshold(
        metric,
        warnThreshold: warnValue,
        alertThreshold: alertValue,
      );
    } catch (e) {
      // debugPrint('设置 $metric 阈值时出错: $e');
    }
  }

  /// 设置告警处理器
  void _setupAlertHandlers() {
    // FPS告警处理
    PerformanceMonitorUtils.instance.addAlertHandler('fps', (value) {
      // debugPrint('⚠️ FPS过低: ${value.toStringAsFixed(1)}');
      // 在开发环境中可以添加更多处理逻辑
    });

    // 内存告警处理
    PerformanceMonitorUtils.instance.addAlertHandler('memory', (value) {
      // debugPrint('⚠️ 内存使用过高: ${value.toStringAsFixed(1)}MB');
      // 触发内存清理
      _cleanupMemory();
    });

    // 卡顿告警处理
    PerformanceMonitorUtils.instance.addAlertHandler('jank', (value) {
      // debugPrint('⚠️ 检测到严重卡顿: ${value.toStringAsFixed(1)}ms');
    });

    // 构建频率告警处理
    PerformanceMonitorUtils.instance.addAlertHandler('builds', (value) {
      // debugPrint('⚠️ 构建频率过高: $value 次/秒');
    });
  }

  /// 清理内存
  void _cleanupMemory() {
    // 清理图片缓存
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    // 强制GC - 这是一个内部方法，但我们知道它存在
    try {
      // 使用反射调用私有方法（不推荐，但在这种情况下是必要的）
      // final memoryUtils = MemoryUtils.instance;
      // final method = memoryUtils.runtimeType.toString().contains('_forceGC') ? '_forceGC' : 'forceGC';
      // debugPrint('尝试调用 $method 方法');

      // 作为替代方案，我们可以直接实现GC逻辑
      final temp = List<int>.filled(1000000, 0);
      temp.clear();
      // debugPrint('已触发内存清理');
    } catch (e) {
      // debugPrint('内存清理失败: $e');
    }
  }

  /// 开始性能追踪
  Stopwatch startTrace(String tag) {
    return PerformanceMonitorUtils.instance.startTrace(tag);
  }

  /// 结束性能追踪
  void endTrace(String tag, Stopwatch stopwatch, {int? expectedDurationMs}) {
    PerformanceMonitorUtils.instance.endTrace(
      tag,
      stopwatch,
      expectedDurationMs: expectedDurationMs,
    );
  }
  
  /// 记录API性能数据
  /// 
  /// [tag] API调用的标识符
  /// [performanceData] 包含API性能指标的数据
  /// [expectedDurationMs] 预期的API响应时间（毫秒）
  void recordApiPerformance(String tag, Map<String, dynamic> performanceData, {int? expectedDurationMs}) {
    if (!_monitoringEnabled.value) return;
    
    final int duration = performanceData['duration'] as int;
    
    // 记录性能数据
    PerformanceMonitorUtils.instance.recordCustomMetric(
      tag, 
      duration.toDouble(), 
      extraData: performanceData
    );
    
    // 检查是否超出预期时间
    if (expectedDurationMs != null && duration > expectedDurationMs) {
      // 记录性能告警
      PerformanceMonitorUtils.instance.recordPerformanceAlert(
        tag,
        duration.toDouble(),
        expectedValue: expectedDurationMs.toDouble(),
        alertType: 'api_performance'
      );
    }
  }


  /// 生成内存快照
  Future<void> takeMemorySnapshot(String tag) async {
    if (_monitoringEnabled.value) {
      await MemoryUtils.instance.takeHeapSnapshot(tag);
    }
  }

  /// 跟踪对象（用于内存泄漏检测）
  void trackObject(Object object, {String? tag}) {
    MemoryUtils.instance.trackObject(object, tag: tag);
  }

  /// 停止跟踪对象
  void stopTracking(Object object) {
    MemoryUtils.instance.stopTracking(object);
  }

  @override
  void onClose() {
    if (_monitoringEnabled.value) {
      // 1. 停止核心性能监控（PerformanceMonitorUtils会内部停止内存监控）
      PerformanceMonitorUtils.instance.stopMonitoring();
      PerformanceMonitorUtils.instance.removeAlertHandler('fps');
      PerformanceMonitorUtils.instance.removeAlertHandler('memory');
      PerformanceMonitorUtils.instance.removeAlertHandler('jank');
      PerformanceMonitorUtils.instance.removeAlertHandler('builds');
    }

    super.onClose();
  }
}
