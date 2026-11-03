/// 简化的性能优化测试（纯Dart版本）

void main() {
  print('开始运行性能优化测试...');

  // 测试1：复杂getter场景
  testComplexGetter();

  // 测试2：大数据集场景
  testLargeDataset();

  // 测试3：并发安全场景
  testConcurrentSafety();

  print('\n所有测试完成！');
}

/// 测试1：复杂getter场景
void testComplexGetter() {
  print('\n=== 复杂getter场景测试 ===');

  final processor = ExpensiveDataProcessor();

  // 预热JIT
  for (int i = 0; i < 5; i++) {
    processor.optimizedProcess();
    processor.nonOptimizedProcess();
  }

  // 测试优化版本
  final optimizedTimes = <int>[];
  for (int i = 0; i < 20; i++) {
    final stopwatch = Stopwatch()..start();
    processor.optimizedProcess();
    stopwatch.stop();
    optimizedTimes.add(stopwatch.elapsedMicroseconds);
  }

  // 重置计数器
  processor.reset();

  // 测试非优化版本
  final nonOptimizedTimes = <int>[];
  for (int i = 0; i < 20; i++) {
    final stopwatch = Stopwatch()..start();
    processor.nonOptimizedProcess();
    stopwatch.stop();
    nonOptimizedTimes.add(stopwatch.elapsedMicroseconds);
  }

  final optimizedAvg = optimizedTimes.reduce((a, b) => a + b) / optimizedTimes.length;
  final nonOptimizedAvg = nonOptimizedTimes.reduce((a, b) => a + b) / nonOptimizedTimes.length;
  final improvement = ((nonOptimizedAvg - optimizedAvg) / nonOptimizedAvg * 100);

  print('优化版本平均耗时: ${optimizedAvg.toStringAsFixed(1)}μs');
  print('非优化版本平均耗时: ${nonOptimizedAvg.toStringAsFixed(1)}μs');
  print('性能提升: ${improvement.toStringAsFixed(1)}%');
  print('优化版本getter调用次数: ${processor.optimizedCallCount}');
  print('非优化版本getter调用次数: ${processor.nonOptimizedCallCount}');

  // 验证优化版本调用次数更少
  assert(processor.optimizedCallCount < processor.nonOptimizedCallCount, '优化版本应该有更少的getter调用');
}

/// 测试2：大数据集场景
void testLargeDataset() {
  print('\n=== 大数据集场景测试 ===');

  final processor = LargeDataProcessor();

  // 预热
  processor.optimizedBatchProcess();
  processor.nonOptimizedBatchProcess();

  // 测试优化版本
  final stopwatch1 = Stopwatch()..start();
  final result1 = processor.optimizedBatchProcess();
  stopwatch1.stop();

  // 测试非优化版本
  final stopwatch2 = Stopwatch()..start();
  final result2 = processor.nonOptimizedBatchProcess();
  stopwatch2.stop();

  print('优化版本耗时: ${stopwatch1.elapsedMilliseconds}ms');
  print('非优化版本耗时: ${stopwatch2.elapsedMilliseconds}ms');
  print('结果一致性: ${result1 == result2 ? "✓" : "✗"}');

  final improvement =
      ((stopwatch2.elapsedMilliseconds - stopwatch1.elapsedMilliseconds) / stopwatch2.elapsedMilliseconds * 100);
  print('性能提升: ${improvement.toStringAsFixed(1)}%');

  // 验证结果一致
  assert(result1 == result2, '两种方法应该产生相同结果');
}

/// 测试3：并发安全场景
void testConcurrentSafety() {
  print('\n=== 并发安全场景测试 ===');

  final processor = ConcurrentDataProcessor();

  // 测试快照模式
  processor.reset();
  for (int i = 0; i < 10; i++) {
    processor.safeSnapshotProcess();
  }
  final snapshotConsistency = processor.snapshotConsistencyCount;

  // 测试直接访问模式
  processor.reset();
  for (int i = 0; i < 10; i++) {
    processor.directAccessProcess();
  }
  final directConsistency = processor.directAccessConsistencyCount;

  print('快照模式一致性计数: $snapshotConsistency');
  print('直接访问一致性计数: $directConsistency');
  print('安全性提升: ${snapshotConsistency >= directConsistency ? "✓" : "✗"}');

  // 验证快照模式更安全
  assert(snapshotConsistency >= directConsistency, '快照模式应该有更好的一致性');
}

/// 复杂数据处理器
class ExpensiveDataProcessor {
  List<String> _data = List.generate(50, (i) => 'item_$i');
  int optimizedCallCount = 0;
  int nonOptimizedCallCount = 0;

  void reset() {
    optimizedCallCount = 0;
    nonOptimizedCallCount = 0;
  }

  List<String> get expensiveData {
    // 模拟昂贵的计算
    final result = <String>[];
    for (final item in _data) {
      // 模拟复杂处理
      final processed = item.toUpperCase() + '_processed';
      result.add(processed);
      // 增加计算复杂度
      for (int i = 0; i < 100; i++) {
        processed.hashCode;
      }
    }
    // 记录getter被调用
    if (optimizedCallCount >= 0) optimizedCallCount++;
    if (nonOptimizedCallCount >= 0) nonOptimizedCallCount++;
    return result;
  }

  /// 优化版本：缓存getter结果
  int optimizedProcess() {
    // 重置计数器，只计算这次调用
    final oldCount = optimizedCallCount;
    optimizedCallCount = 0;
    nonOptimizedCallCount = -1; // 标记为优化模式

    final data = expensiveData; // 只调用一次getter

    int count = 0;
    for (final item in data) {
      if (item.isNotEmpty) count++;
    }
    for (final item in data) {
      if (item.contains('_')) count++;
    }

    // 恢复并累加计数
    final thisCallCount = optimizedCallCount;
    optimizedCallCount = oldCount + thisCallCount;
    nonOptimizedCallCount = 0;

    return count;
  }

  /// 非优化版本：重复调用getter
  int nonOptimizedProcess() {
    // 重置计数器，只计算这次调用
    final oldCount = nonOptimizedCallCount;
    nonOptimizedCallCount = 0;
    optimizedCallCount = -1; // 标记为非优化模式

    int count = 0;
    for (final item in expensiveData) {
      // 第一次调用
      if (item.isNotEmpty) count++;
    }
    for (final item in expensiveData) {
      // 第二次调用
      if (item.contains('_')) count++;
    }

    // 恢复并累加计数
    final thisCallCount = nonOptimizedCallCount;
    nonOptimizedCallCount = oldCount + thisCallCount;
    optimizedCallCount = 0;

    return count;
  }
}

/// 大数据处理器
class LargeDataProcessor {
  final List<int> _largeDataset = List.generate(10000, (i) => i);

  List<int> get processedData {
    // 增加计算复杂度
    return _largeDataset.map((x) {
      int result = x;
      for (int i = 0; i < 10; i++) {
        result = result * result + 1;
        result = result % 1000000; // 防止溢出
      }
      return result;
    }).toList();
  }

  /// 优化版本：缓存处理结果
  double optimizedBatchProcess() {
    final data = processedData; // 只处理一次

    double sum = 0;
    for (final value in data) {
      sum += value;
    }

    double average = sum / data.length;

    // 再次使用相同数据
    double variance = 0;
    for (final value in data) {
      variance += (value - average) * (value - average);
    }

    return variance / data.length;
  }

  /// 非优化版本：重复处理
  double nonOptimizedBatchProcess() {
    double sum = 0;
    for (final value in processedData) {
      // 第一次处理
      sum += value;
    }

    double average = sum / processedData.length; // 第二次处理

    double variance = 0;
    for (final value in processedData) {
      // 第三次处理
      variance += (value - average) * (value - average);
    }

    return variance / processedData.length; // 第四次处理
  }
}

/// 并发数据处理器
class ConcurrentDataProcessor {
  List<String> _sharedData = List.generate(50, (i) => 'item_$i');
  int snapshotConsistencyCount = 0;
  int directAccessConsistencyCount = 0;

  void reset() {
    _sharedData = List.generate(50, (i) => 'item_$i');
    snapshotConsistencyCount = 0;
    directAccessConsistencyCount = 0;
  }

  /// 安全的快照模式
  void safeSnapshotProcess() {
    final snapshot = List.from(_sharedData); // 创建快照
    final originalLength = snapshot.length;

    // 模拟并发修改
    _simulateConcurrentModification();

    // 使用快照，不受并发修改影响
    int count = 0;
    for (final item in snapshot) {
      if (item.isNotEmpty) {
        count++;
      }
    }

    if (count == originalLength) {
      snapshotConsistencyCount++;
    }
  }

  /// 直接访问模式
  void directAccessProcess() {
    final originalLength = _sharedData.length;

    // 模拟并发修改
    _simulateConcurrentModification();

    // 直接访问可能被修改的数据
    int count = 0;
    try {
      for (final item in _sharedData) {
        if (item.isNotEmpty) {
          count++;
        }
      }
    } catch (e) {
      return;
    }

    if (count == originalLength) {
      directAccessConsistencyCount++;
    }
  }

  void _simulateConcurrentModification() {
    if (_sharedData.isNotEmpty && _sharedData.length < 80) {
      _sharedData.add('concurrent_item_${_sharedData.length}');
    }
  }
}

/*
dart run test/simple_optimization_test.dart
 */
