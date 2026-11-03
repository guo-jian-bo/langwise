import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// HashMap 并发修改异常测试类
/// 演示在forEach遍历过程中进行增加、删除、更新操作时的异常情况
class HashMapConcurrentModificationTest {
  /// 测试在forEach过程中添加元素导致的并发修改异常
  static void testConcurrentAddException() {
    print('\n=== 测试场景一：遍历过程中添加元素 ===');

    final Map<String, int> userScores = {
      'Alice': 95,
      'Bob': 87,
      'Charlie': 92,
    };

    print('开始遍历用户分数...');

    try {
      userScores.forEach((name, score) {
        print('用户: $name, 分数: $score');

        // 模拟在遍历过程中，另一个业务逻辑添加新用户
        if (name == 'Bob') {
          print('检测到Bob，添加新用户David...');
          userScores['David'] = 88; // ❌ 这里会抛出 ConcurrentModificationError
        }
      });
    } catch (e) {
      print('捕获异常: $e');
      print('异常类型: ${e.runtimeType}');
    }
  }

  /// 测试在forEach过程中删除元素导致的并发修改异常
  static void testConcurrentRemoveException() {
    print('\n=== 测试场景二：遍历过程中删除元素 ===');

    final Map<String, String> taskStatus = {
      'task1': 'pending',
      'task2': 'completed',
      'task3': 'in_progress',
      'task4': 'failed',
    };

    print('开始检查任务状态...');

    try {
      taskStatus.forEach((taskId, status) {
        print('任务 $taskId: $status');

        // 模拟在遍历过程中，另一个业务逻辑删除已完成的任务
        if (status == 'completed') {
          print('删除已完成的任务: $taskId');
          taskStatus.remove(taskId); // ❌ 这里会抛出 ConcurrentModificationError
        }
      });
    } catch (e) {
      print('捕获异常: $e');
      print('异常类型: ${e.runtimeType}');
    }
  }

  /// 测试在forEach过程中更新现有键值对的行为
  /// 注意：根据实际测试，更新现有键的值通常不会导致ConcurrentModificationError
  static void testConcurrentUpdateBehavior() {
    print('\n=== 测试场景三：遍历过程中更新现有键值对 ===');

    final Map<String, String> orderStatus = {
      'order1': 'pending',
      'order2': 'processing',
      'order3': 'completed',
    };

    print('开始遍历订单状态...');
    print('注意：更新现有键的值通常不会抛出异常');

    try {
      orderStatus.forEach((orderId, status) {
        print('处理订单: $orderId, 当前状态: $status');

        // ✅ 更新现有键的值通常不会抛异常（取决于具体实现）
        if (status == 'pending') {
          orderStatus[orderId] = 'processing'; // 更新现有键值对
          print('订单 $orderId 状态已更新为 processing');
        }
      });
      print('遍历完成，未发生异常');
    } catch (e) {
      print('捕获异常: $e');
      print('异常类型: ${e.runtimeType}');
      print('注意：某些Map实现可能对更新操作也会抛出异常');
    }

    print('最终订单状态: $orderStatus');
  }

  /// 详细测试不同修改操作的行为差异
  static void testDifferentModificationTypes() {
    print('\n=== 详细测试：不同修改操作的行为差异 ===');

    // 测试1：更新现有键
    print('\n--- 测试1：更新现有键的值 ---');
    final Map<String, int> testMap1 = {'a': 1, 'b': 2, 'c': 3};
    try {
      testMap1.forEach((key, value) {
        if (key == 'a') {
          testMap1[key] = value * 10; // 更新现有键
          print('更新 $key: $value -> ${testMap1[key]}');
        }
      });
      print('✅ 更新现有键：成功，无异常');
    } catch (e) {
      print('❌ 更新现有键：异常 - $e');
    }

    // 测试2：添加新键
    print('\n--- 测试2：添加新键 ---');
    final Map<String, int> testMap2 = {'a': 1, 'b': 2, 'c': 3};
    try {
      testMap2.forEach((key, value) {
        if (key == 'a') {
          testMap2['d'] = 4; // 添加新键
          print('添加新键 d: 4');
        }
      });
      print('✅ 添加新键：成功，无异常');
    } catch (e) {
      print('❌ 添加新键：异常 - $e');
    }

    // 测试3：删除键
    print('\n--- 测试3：删除现有键 ---');
    final Map<String, int> testMap3 = {'a': 1, 'b': 2, 'c': 3};
    try {
      testMap3.forEach((key, value) {
        if (key == 'c') {
          testMap3.remove('b'); // 删除键
          print('删除键 b');
        }
      });
      print('✅ 删除键：成功，无异常');
    } catch (e) {
      print('❌ 删除键：异常 - $e');
    }

    print('\n=== 结论 ===');
    print('- 更新现有键的值：通常不会抛出ConcurrentModificationError');
    print('- 添加新键：可能会抛出ConcurrentModificationError');
    print('- 删除键：通常会抛出ConcurrentModificationError');
    print('- 具体行为取决于Map的实现类型和Dart版本');
  }

  /// 测试多线程并发修改场景
  static Future<void> testMultiThreadConcurrentException() async {
    print('\n=== 测试场景四：多线程并发修改 ===');

    final Map<String, int> sharedData = {
      'counter1': 0,
      'counter2': 0,
      'counter3': 0,
    };

    // 启动一个定时器模拟另一个业务逻辑
    Timer? timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (timer.tick > 5) {
        timer.cancel();
        return;
      }

      // 模拟另一个业务逻辑在修改数据
      sharedData['counter${timer.tick + 3}'] = timer.tick * 10;
      print('后台任务添加了新数据: counter${timer.tick + 3}');
    });

    // 主业务逻辑遍历数据
    await Future.delayed(Duration(milliseconds: 50));

    try {
      sharedData.forEach((key, value) {
        print('处理数据: $key = $value');
        // 模拟处理时间
        sleep(Duration(milliseconds: 150));
      });
    } catch (e) {
      print('并发修改异常: $e');
      print('异常类型: ${e.runtimeType}');
    }

    timer.cancel();
  }

  /// 安全解决方案一：使用副本进行遍历
  static void testSafeIterationWithCopy() {
    print('\n=== 安全解决方案一：使用副本进行遍历 ===');

    final Map<String, int> originalMap = {
      'item1': 10,
      'item2': 20,
      'item3': 30,
    };

    // 创建副本进行遍历
    final Map<String, int> copyMap = Map.from(originalMap);

    copyMap.forEach((key, value) {
      print('处理: $key = $value');

      // 安全地修改原始map
      if (value > 15) {
        originalMap['${key}_processed'] = value * 2;
      }
    });

    print('最终结果: $originalMap');
  }

  /// 安全解决方案二：收集需要修改的操作，遍历后执行
  static void testSafeIterationWithDelayedModification() {
    print('\n=== 安全解决方案二：延迟修改模式 ===');

    final Map<String, String> userStatus = {
      'user1': 'active',
      'user2': 'inactive',
      'user3': 'pending',
      'user4': 'banned',
    };

    // 收集需要执行的操作
    List<String> toRemove = [];
    Map<String, String> toAdd = {};

    userStatus.forEach((userId, status) {
      print('检查用户: $userId, 状态: $status');

      if (status == 'banned') {
        toRemove.add(userId);
      } else if (status == 'pending') {
        toAdd['${userId}_verified'] = 'active';
      }
    });

    // 遍历完成后，安全地执行修改操作
    for (String userId in toRemove) {
      userStatus.remove(userId);
      print('删除被封禁用户: $userId');
    }

    toAdd.forEach((newUserId, newStatus) {
      userStatus[newUserId] = newStatus;
      print('添加验证用户: $newUserId');
    });

    print('最终用户列表: $userStatus');
  }

  /// 安全解决方案三：使用 entries 进行安全遍历
  static void testSafeIterationWithEntries() {
    print('\n=== 安全解决方案三：使用entries快照遍历 ===');

    final Map<String, double> productPrices = {
      'laptop': 999.99,
      'mouse': 29.99,
      'keyboard': 79.99,
      'monitor': 299.99,
    };

    // 使用 entries 创建快照
    final entries = productPrices.entries.toList();

    for (var entry in entries) {
      print('产品: ${entry.key}, 价格: \$${entry.value}');

      // 安全地修改原始map
      if (entry.value > 100) {
        productPrices['${entry.key}_discounted'] = entry.value * 0.9;
      }
    }

    print('更新后的价格表: $productPrices');
  }

  /// 实际业务场景示例：订单处理系统
  static void testOrderProcessingSystem() {
    print('\n=== 实际业务场景：订单处理系统 ===');

    final orderSystem = OrderProcessingSystem();

    // 添加测试订单
    orderSystem.addOrder('order1', OrderStatus.pending);
    orderSystem.addOrder('order2', OrderStatus.processing);
    orderSystem.addOrder('order3', OrderStatus.pending);
    orderSystem.addOrder('order4', OrderStatus.completed);

    print('\n--- 不安全的订单处理方式 ---');
    orderSystem.unsafeProcessOrders();

    print('\n--- 安全的订单处理方式 ---');
    orderSystem.safeProcessOrders();
  }
}

/// 订单状态枚举
enum OrderStatus { pending, processing, completed, cancelled }

/// 订单处理系统类
class OrderProcessingSystem {
  final Map<String, OrderStatus> _orders = {};

  /// 添加订单
  void addOrder(String orderId, OrderStatus status) {
    _orders[orderId] = status;
  }

  /// 不安全的订单处理方式
  /// 注意：更新操作可能不会抛异常，但删除/添加操作会抛异常
  void unsafeProcessOrders() {
    print('开始处理订单（不安全方式）...');

    try {
      _orders.forEach((orderId, status) {
        print('处理订单: $orderId, 状态: ${status.name}');

        // 更新现有键的值（通常不会抛异常）
        if (status == OrderStatus.pending) {
          _orders[orderId] = OrderStatus.processing; // ⚠️ 更新操作，可能不抛异常
        }

        // 模拟删除已完成订单（这个会抛异常）
        // if (status == OrderStatus.completed) {
        //   _orders.remove(orderId); // ❌ 删除操作，会抛异常
        // }
      });
      print('处理完成，未发生异常');
    } catch (e) {
      print('订单处理异常: $e');
    }
  }

  /// 安全的订单处理方式
  void safeProcessOrders() {
    print('开始处理订单（安全方式）...');

    // 创建订单快照
    final orderSnapshot = Map<String, OrderStatus>.from(_orders);

    List<String> toUpdate = [];
    List<String> toRemove = [];

    orderSnapshot.forEach((orderId, status) {
      print('处理订单: $orderId, 状态: ${status.name}');

      if (status == OrderStatus.pending) {
        toUpdate.add(orderId);
      } else if (status == OrderStatus.completed) {
        toRemove.add(orderId);
      }
    });

    // 批量更新
    for (String orderId in toUpdate) {
      _orders[orderId] = OrderStatus.processing;
      print('订单 $orderId 状态更新为处理中');
    }

    // 批量删除
    for (String orderId in toRemove) {
      _orders.remove(orderId);
      print('已完成订单 $orderId 已归档');
    }
  }
}

/// 主测试函数
void main() {
  group('HashMap 并发修改异常测试', () {
    test('测试遍历过程中添加元素异常', () {
      HashMapConcurrentModificationTest.testConcurrentAddException();
    });

    test('测试遍历过程中删除元素异常', () {
      HashMapConcurrentModificationTest.testConcurrentRemoveException();
    });

    test('测试遍历过程中更新元素行为', () {
      HashMapConcurrentModificationTest.testConcurrentUpdateBehavior();
    });

    test('详细测试不同修改操作的行为差异', () {
      HashMapConcurrentModificationTest.testDifferentModificationTypes();
    });

    test('测试多线程并发修改异常', () async {
      await HashMapConcurrentModificationTest.testMultiThreadConcurrentException();
    });

    test('测试安全遍历方案一：副本模式', () {
      HashMapConcurrentModificationTest.testSafeIterationWithCopy();
    });

    test('测试安全遍历方案二：延迟修改模式', () {
      HashMapConcurrentModificationTest.testSafeIterationWithDelayedModification();
    });

    test('测试安全遍历方案三：entries快照模式', () {
      HashMapConcurrentModificationTest.testSafeIterationWithEntries();
    });

    test('测试实际业务场景：订单处理系统', () {
      HashMapConcurrentModificationTest.testOrderProcessingSystem();
    });
  });
}
