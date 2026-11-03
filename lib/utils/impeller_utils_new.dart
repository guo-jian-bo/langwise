import 'dart:collection';
import 'dart:math' as math;
import 'package:flutter/scheduler.dart';

/// 着色器使用数据
class _ShaderUsageData {
  final String shaderId;
  final int usageCount;
  final double priority;

  _ShaderUsageData({
    required this.shaderId,
    required this.usageCount,
    required this.priority,
  });
}

/// 着色器编译任务
class _ShaderCompileTask {
  final String shaderId;
  final double priority;
  _CompileStatus status;

  _ShaderCompileTask({
    required this.shaderId,
    required this.priority,
    required this.status,
  });
}

/// 编译状态枚举
enum _CompileStatus { pending }

/// 着色器编译状态
class _ShaderCompileState {
  final Queue<_ShaderCompileTask> tasks;
  final int maxDuration;
  final int frameBudget;
  final int startTime;
  int compiledCount = 0;

  _ShaderCompileState({
    required this.tasks,
    required this.maxDuration,
    required this.frameBudget,
    required this.startTime,
  });
}

/// 预热策略
class WarmupStrategy {
  final int maxDuration;
  final int frameBudget;

  const WarmupStrategy({
    required this.maxDuration,
    required this.frameBudget,
  });

  /// 基于帧的预热策略
  ///
  /// [maxDuration] 最长预热时间(毫秒)
  /// [frameBudget] 每帧编译预算(毫秒)
  static WarmupStrategy frameBased({
    required int maxDuration,
    required int frameBudget,
  }) {
    return WarmupStrategy(
      maxDuration: maxDuration,
      frameBudget: frameBudget,
    );
  }
}

/// Impeller着色器预编译引擎
class ImpellerEngine {
  // 当前编译优先级因子
  static double _priorityFactor = 1.0;

  /// 预编译关键着色器
  ///
  /// [shaders] 需要预编译的着色器列表
  /// [warmupStrategy] 预热策略
  static void precacheShaders({
    required Map<String, double> shaders,
    required WarmupStrategy warmupStrategy,
  }) {
    // 1. 按优先级排序着色器
    final sortedShaders = _sortShadersByPriority(shaders);

    // 2. 创建编译任务队列
    final compileTasks = _createCompileTasks(sortedShaders);

    // 3. 初始化编译状态
    final state = _ShaderCompileState(
      tasks: compileTasks,
      maxDuration: warmupStrategy.maxDuration,
      frameBudget: warmupStrategy.frameBudget,
      startTime: DateTime.now().millisecondsSinceEpoch,
    );

    // 4. 注册到下一帧开始编译
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _startCompileProcess(state);
    });
  }

  /// 调整编译优先级
  ///
  /// [factor] 优先级调整因子，大于1提高优先级，小于1降低优先级
  static void adjustCompilePriority(double factor) {
    _priorityFactor = factor.clamp(0.1, 10.0);
  }

  /// 按优先级排序着色器
  static List<_ShaderCompileTask> _sortShadersByPriority(Map<String, double> shaders) {
    final entries = shaders.entries.toList();
    // 按优先级降序排列
    entries.sort((a, b) => b.value.compareTo(a.value));

    return entries
        .map((entry) => _ShaderCompileTask(
              shaderId: entry.key,
              priority: entry.value,
              status: _CompileStatus.pending,
            ))
        .toList();
  }

  /// 创建编译任务队列
  static Queue<_ShaderCompileTask> _createCompileTasks(List<_ShaderCompileTask> sortedTasks) {
    return Queue.from(sortedTasks);
  }

  /// 启动编译过程
  static void _startCompileProcess(_ShaderCompileState state) {
    // 检查是否已超过最大编译时间
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - state.startTime > state.maxDuration) {
      _finalizeCompilation(state);
      return;
    }

    // 检查是否所有任务已完成
    if (state.tasks.isEmpty) {
      _finalizeCompilation(state);
      return;
    }

    // 创建当前帧的编译预算 (考虑优先级因子)
    final adjustedBudget = (state.frameBudget * _priorityFactor).toInt();
    final frameStopwatch = Stopwatch()..start();

    // 在当前帧预算内编译尽可能多的着色器
    while (state.tasks.isNotEmpty && frameStopwatch.elapsedMilliseconds < adjustedBudget) {
      final task = state.tasks.removeFirst();

      // 实际编译着色器 - 这里会调用到Native层
      _compileShader(task.shaderId);

      // 更新统计信息
      state.compiledCount++;
    }

    // 如果还有任务，安排到下一帧继续
    if (state.tasks.isNotEmpty) {
      SchedulerBinding.instance.scheduleFrame();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _startCompileProcess(state);
      });
    } else {
      _finalizeCompilation(state);
    }
  }

  /// 完成编译过程
  static void _finalizeCompilation(_ShaderCompileState state) {
    // final duration = DateTime.now().millisecondsSinceEpoch - state.startTime;
    // debugPrint('Impeller着色器预热完成: 预编译了${state.compiledCount}个着色器，耗时${duration}ms');
  }

  /// 编译单个着色器 - 这会调用到Native层
  static void _compileShader(String shaderId) {
    // 在实际实现中，这里会通过Platform Channel或FFI调用到Native层
    // 执行实际的着色器编译工作

    // 模拟编译耗时 (实际实现中不需要)
    final random = math.Random();
    // 模拟编译时间，但不阻塞线程
    random.nextInt(3);
  }
}

/// Impeller渲染引擎优化工具类
///
/// 提供着色器预热、优化渲染性能等功能
class ImpellerUtils {
  static final ImpellerUtils _instance = ImpellerUtils._();

  static ImpellerUtils get instance => _instance;

  // 保存优先级较高的着色器列表
  final Map<String, double> _criticalShaders = {};

  ImpellerUtils._() {
    _initDefaultShaders();
  }

  /// 初始化默认着色器列表
  void _initDefaultShaders() {
    // 常见UI元素的着色器
    _criticalShaders['flutter_default_rect'] = 1.0;
    _criticalShaders['flutter_rounded_rect'] = 0.9;
    _criticalShaders['flutter_text'] = 0.8;
    _criticalShaders['flutter_image'] = 0.7;
  }

  /// 配置着色器预热
  ///
  /// [maxDuration] 最长预热时间(毫秒)
  /// [frameBudget] 每帧编译预算(毫秒)
  /// [criticalShaders] 额外的关键着色器列表
  void configureShaderPrecache({
    int maxDuration = 500,
    int frameBudget = 8,
    Map<String, double>? criticalShaders,
  }) {
    if (criticalShaders != null) {
      _criticalShaders.addAll(criticalShaders);
    }

    // 使用ImpellerEngine进行着色器预热
    ImpellerEngine.precacheShaders(
        shaders: _getCriticalShaders(), // 自动识别高频使用着色器
        warmupStrategy: WarmupStrategy.frameBased(
            maxDuration: maxDuration, // 最长预热时间
            frameBudget: frameBudget // 每帧编译不超过指定毫秒
            ));

    // 动态优先级队列（避免编译阻塞UI线程）
    SchedulerBinding.instance.addTimingsCallback(_adjustCompilePriority);

    // debugPrint('配置着色器预热: 最长时间=${maxDuration}ms, 每帧预算=${frameBudget}ms');
    // debugPrint('已配置${_criticalShaders.length}个关键着色器');
  }

  /// 获取关键着色器列表
  Map<String, double> _getCriticalShaders() {
    // 1. 从本地存储加载历史渲染数据
    final historicalData = _loadHistoricalRenderData();

    // 2. 如果有足够的历史数据，使用分析结果预测
    if (historicalData.isNotEmpty) {
      return _predictCriticalShaders(historicalData);
    }

    // 3. 否则使用默认的关键着色器列表
    return _criticalShaders;
  }

  /// 加载历史渲染数据
  List<_ShaderUsageData> _loadHistoricalRenderData() {
    // 实际应用中，这里会从本地存储加载历史数据
    // 简化实现，返回空列表
    return [];
  }

  /// 预测关键着色器
  Map<String, double> _predictCriticalShaders(List<_ShaderUsageData> historicalData) {
    // 在实际实现中，这里会分析历史数据预测关键着色器
    // 简化实现，直接返回默认列表
    return _criticalShaders;
  }

  /// 动态调整编译优先级
  void _adjustCompilePriority(List<FrameTiming> timings) {
    if (timings.isEmpty) return;

    // 分析最近帧的性能
    final lastFrameTiming = timings.last;
    final uiTime = lastFrameTiming.buildDuration.inMicroseconds / 1000;
    final rasterTime = lastFrameTiming.rasterDuration.inMicroseconds / 1000;

    // 如果渲染时间过长，通知引擎暂时降低编译优先级
    if (uiTime > 14 || rasterTime > 14) {
      // 接近16.7ms的帧预算
      ImpellerEngine.adjustCompilePriority(0.5); // 降低优先级
    } else if (uiTime < 8 && rasterTime < 8) {
      // 有足够的空闲时间
      ImpellerEngine.adjustCompilePriority(2.0); // 提高优先级
    }
  }
}
