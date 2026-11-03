import 'package:flutter_test/flutter_test.dart';
import 'package:langwise/utils/ring_buffer.dart';

/// 环形缓冲区测试
void main() {
  group('RingBuffer Tests', () {
    late RingBuffer<int> buffer;

    setUp(() {
      buffer = RingBuffer<int>(8);
    });

    group('基本功能测试', () {
      test('初始状态应该为空', () {
        expect(buffer.isEmpty, isTrue);
        expect(buffer.isFull, isFalse);
        expect(buffer.size, equals(0));
        expect(buffer.capacity, equals(8));
      });

      test('容量必须为2的整数次幂', () {
        expect(() => RingBuffer<int>(7), throwsArgumentError);
        expect(() => RingBuffer<int>(0), throwsArgumentError);
        expect(() => RingBuffer<int>(-1), throwsArgumentError);
        
        // 这些应该成功
        expect(() => RingBuffer<int>(1), returnsNormally);
        expect(() => RingBuffer<int>(2), returnsNormally);
        expect(() => RingBuffer<int>(4), returnsNormally);
        expect(() => RingBuffer<int>(8), returnsNormally);
        expect(() => RingBuffer<int>(16), returnsNormally);
      });

      test('push操作应该正确添加元素', () {
        expect(buffer.push(1), isTrue);
        expect(buffer.size, equals(1));
        expect(buffer.isEmpty, isFalse);
        
        expect(buffer.push(2), isTrue);
        expect(buffer.size, equals(2));
      });

      test('pop操作应该正确取出元素', () {
        buffer.push(1);
        buffer.push(2);
        
        expect(buffer.pop(), equals(1));
        expect(buffer.size, equals(1));
        
        expect(buffer.pop(), equals(2));
        expect(buffer.size, equals(0));
        expect(buffer.isEmpty, isTrue);
      });

      test('空缓冲区pop应该返回null', () {
        expect(buffer.pop(), isNull);
      });

      test('满缓冲区push应该返回false', () {
        // 填满缓冲区
        for (int i = 0; i < 8; i++) {
          expect(buffer.push(i), isTrue);
        }
        
        expect(buffer.isFull, isTrue);
        expect(buffer.push(8), isFalse);
      });
    });

    group('FIFO行为测试', () {
      test('应该按FIFO顺序取出元素', () {
        final testData = [1, 2, 3, 4, 5];
        
        // 添加元素
        for (final item in testData) {
          buffer.push(item);
        }
        
        // 按顺序取出
        for (final expected in testData) {
          expect(buffer.pop(), equals(expected));
        }
      });

      test('混合push和pop操作', () {
        buffer.push(1);
        buffer.push(2);
        
        expect(buffer.pop(), equals(1));
        
        buffer.push(3);
        
        expect(buffer.pop(), equals(2));
        expect(buffer.pop(), equals(3));
        expect(buffer.isEmpty, isTrue);
      });
    });

    group('环形特性测试', () {
      test('应该正确处理环形回绕', () {
        // 填满缓冲区
        for (int i = 0; i < 8; i++) {
          buffer.push(i);
        }
        
        // 取出一些元素
        for (int i = 0; i < 3; i++) {
          expect(buffer.pop(), equals(i));
        }
        
        // 再添加一些元素（触发回绕）
        for (int i = 8; i < 11; i++) {
          expect(buffer.push(i), isTrue);
        }
        
        // 验证顺序
        final expected = [3, 4, 5, 6, 7, 8, 9, 10];
        for (final exp in expected) {
          expect(buffer.pop(), equals(exp));
        }
      });
    });

    group('高级功能测试', () {
      test('peek应该返回头部元素但不移除', () {
        buffer.push(1);
        buffer.push(2);
        
        expect(buffer.peek(), equals(1));
        expect(buffer.size, equals(2));
        
        expect(buffer.pop(), equals(1));
        expect(buffer.peek(), equals(2));
      });

      test('空缓冲区peek应该返回null', () {
        expect(buffer.peek(), isNull);
      });

      test('forcePush应该覆盖最旧元素', () {
        // 填满缓冲区
        for (int i = 0; i < 8; i++) {
          buffer.push(i);
        }
        
        // 强制添加新元素
        buffer.forcePush(8);
        buffer.forcePush(9);
        
        // 第一个元素应该是2（0和1被覆盖）
        expect(buffer.pop(), equals(2));
        expect(buffer.size, equals(7));
      });

      test('reset应该清空缓冲区', () {
        buffer.push(1);
        buffer.push(2);
        
        buffer.reset();
        
        expect(buffer.isEmpty, isTrue);
        expect(buffer.size, equals(0));
        expect(buffer.pop(), isNull);
      });

      test('toList应该返回正确顺序的列表', () {
        final testData = [1, 2, 3, 4, 5];
        
        for (final item in testData) {
          buffer.push(item);
        }
        
        expect(buffer.toList(), equals(testData));
      });

      test('空缓冲区toList应该返回空列表', () {
        expect(buffer.toList(), isEmpty);
      });
    });

    group('扩展方法测试', () {
      test('pushAll应该批量添加元素', () {
        final items = [1, 2, 3, 4, 5];
        final addedCount = buffer.pushAll(items);
        
        expect(addedCount, equals(5));
        expect(buffer.size, equals(5));
        expect(buffer.toList(), equals(items));
      });

      test('pushAll在缓冲区满时应该停止', () {
        // 先添加一些元素
        for (int i = 0; i < 6; i++) {
          buffer.push(i);
        }
        
        final items = [10, 11, 12, 13];
        final addedCount = buffer.pushAll(items);
        
        expect(addedCount, equals(2)); // 只能添加2个
        expect(buffer.isFull, isTrue);
      });

      test('popMultiple应该批量取出元素', () {
        final items = [1, 2, 3, 4, 5];
        buffer.pushAll(items);
        
        final popped = buffer.popMultiple(3);
        
        expect(popped, equals([1, 2, 3]));
        expect(buffer.size, equals(2));
        expect(buffer.toList(), equals([4, 5]));
      });

      test('popMultiple超出可用元素数量', () {
        buffer.push(1);
        buffer.push(2);
        
        final popped = buffer.popMultiple(5);
        
        expect(popped, equals([1, 2]));
        expect(buffer.isEmpty, isTrue);
      });

      test('drain应该清空并返回所有元素', () {
        final items = [1, 2, 3, 4, 5];
        buffer.pushAll(items);
        
        final drained = buffer.drain();
        
        expect(drained, equals(items));
        expect(buffer.isEmpty, isTrue);
      });
    });

    group('泛型支持测试', () {
      test('应该支持字符串类型', () {
        final stringBuffer = RingBuffer<String>(4);
        
        stringBuffer.push('Hello');
        stringBuffer.push('World');
        
        expect(stringBuffer.pop(), equals('Hello'));
        expect(stringBuffer.pop(), equals('World'));
      });

      test('应该支持自定义对象', () {
        final objectBuffer = RingBuffer<Map<String, int>>(2);
        
        final obj1 = {'id': 1};
        final obj2 = {'id': 2};
        
        objectBuffer.push(obj1);
        objectBuffer.push(obj2);
        
        expect(objectBuffer.pop(), equals(obj1));
        expect(objectBuffer.pop(), equals(obj2));
      });
    });

    group('边界条件测试', () {
      test('容量为1的缓冲区', () {
        final smallBuffer = RingBuffer<int>(1);
        
        expect(smallBuffer.push(1), isTrue);
        expect(smallBuffer.isFull, isTrue);
        expect(smallBuffer.push(2), isFalse);
        
        expect(smallBuffer.pop(), equals(1));
        expect(smallBuffer.isEmpty, isTrue);
      });

      test('大容量缓冲区', () {
        final largeBuffer = RingBuffer<int>(1024);
        
        // 填满缓冲区
        for (int i = 0; i < 1024; i++) {
          expect(largeBuffer.push(i), isTrue);
        }
        
        expect(largeBuffer.isFull, isTrue);
        expect(largeBuffer.size, equals(1024));
        
        // 验证FIFO
        for (int i = 0; i < 1024; i++) {
          expect(largeBuffer.pop(), equals(i));
        }
        
        expect(largeBuffer.isEmpty, isTrue);
      });
    });
  });

  group('性能测试', () {
    test('大量操作性能测试', () {
      final buffer = RingBuffer<int>(1024);
      final stopwatch = Stopwatch();
      
      stopwatch.start();
      
      const iterations = 10000;
      for (int i = 0; i < iterations; i++) {
        buffer.push(i);
        if (buffer.isFull) {
          buffer.pop();
        }
      }
      
      stopwatch.stop();
      
      // 性能测试不应该超过合理时间（这里设置为1秒）
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      
      print('完成 $iterations 次操作，耗时: ${stopwatch.elapsedMilliseconds}ms');
    });
  });

  group('并发安全测试', () {
    test('基本并发操作', () async {
      final buffer = RingBuffer<int>(16);
      final futures = <Future>[];
      
      // 生产者
      futures.add(Future(() async {
        for (int i = 0; i < 50; i++) {
          while (!buffer.push(i)) {
            await Future.delayed(Duration(microseconds: 1));
          }
        }
      }));
      
      // 消费者
      final consumed = <int>[];
      futures.add(Future(() async {
        for (int i = 0; i < 50; i++) {
          int? item;
          while ((item = buffer.pop()) == null) {
            await Future.delayed(Duration(microseconds: 1));
          }
          consumed.add(item!);
        }
      }));
      
      await Future.wait(futures);
      
      expect(consumed.length, equals(50));
      expect(buffer.isEmpty, isTrue);
    });
  });
}