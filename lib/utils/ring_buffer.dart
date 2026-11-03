/// 环形缓冲区（Ring Buffer）实现
/// 适用于生产者-消费者模型、音视频处理等场景
/// 使用数组数据结构和位运算来提高效率
class RingBuffer<T> {
  late final List<T?> _buffer;
  late final int _capacity;
  int _head = 0;
  int _tail = 0;
  bool _full = false;

  /// 构造函数
  /// [capacity] 缓冲区容量，必须为2的整数次幂
  RingBuffer(int capacity) {
    // 检查容量是否为2的整数次幂
    if (capacity <= 0 || (capacity & (capacity - 1)) != 0) {
      throw ArgumentError('Capacity must be a positive power of 2');
    }
    _capacity = capacity;
    _buffer = List<T?>.filled(capacity, null);
  }

  /// 向缓冲区添加元素
  /// 返回true表示添加成功，false表示缓冲区已满
  bool push(T item) {
    if (_full) {
      return false;
    }
    
    _buffer[_head] = item;
    _head = (_head + 1) & (_capacity - 1); // 使用位运算替代模运算
    
    if (_head == _tail) {
      _full = true;
    }
    
    return true;
  }

  /// 从缓冲区取出元素
  /// 返回取出的元素，如果缓冲区为空则返回null
  T? pop() {
    if (isEmpty) {
      return null;
    }
    
    final item = _buffer[_tail];
    _buffer[_tail] = null; // 清空引用，避免内存泄漏
    _tail = (_tail + 1) & (_capacity - 1); // 使用位运算替代模运算
    _full = false;
    
    return item;
  }

  /// 检查缓冲区是否为空
  bool get isEmpty => !_full && (_head == _tail);

  /// 检查缓冲区是否已满
  bool get isFull => _full;

  /// 获取当前缓冲区中元素的数量
  int get size {
    if (_full) {
      return _capacity;
    }
    
    if (_head >= _tail) {
      return _head - _tail;
    }
    
    return _head + _capacity - _tail;
  }

  /// 获取缓冲区容量
  int get capacity => _capacity;

  /// 重置缓冲区
  void reset() {
    _head = 0;
    _tail = 0;
    _full = false;
    // 清空所有引用
    for (int i = 0; i < _capacity; i++) {
      _buffer[i] = null;
    }
  }

  /// 查看头部元素但不移除
  T? peek() {
    if (isEmpty) {
      return null;
    }
    return _buffer[_tail];
  }

  /// 强制添加元素（覆盖模式）
  /// 如果缓冲区已满，会覆盖最旧的元素
  void forcePush(T item) {
    if (_full) {
      // 缓冲区已满，覆盖最旧的元素
      _buffer[_head] = item;
      _head = (_head + 1) & (_capacity - 1);
      _tail = (_tail + 1) & (_capacity - 1);
    } else {
      push(item);
    }
  }

  /// 转换为列表（按插入顺序）
  List<T> toList() {
    final result = <T>[];
    if (isEmpty) {
      return result;
    }
    
    int current = _tail;
    do {
      final item = _buffer[current];
      if (item != null) {
        result.add(item);
      }
      current = (current + 1) & (_capacity - 1);
    } while (current != _head);
    
    return result;
  }

  @override
  String toString() {
    return 'RingBuffer{size: $size, capacity: $capacity, isEmpty: $isEmpty, isFull: $isFull}';
  }
}

/// 扩展工具类，提供一些便利方法
extension RingBufferExtension<T> on RingBuffer<T> {
  /// 批量添加元素
  /// 返回成功添加的元素数量
  int pushAll(Iterable<T> items) {
    int count = 0;
    for (final item in items) {
      if (push(item)) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// 批量取出元素
  /// [count] 要取出的元素数量
  List<T> popMultiple(int count) {
    final result = <T>[];
    for (int i = 0; i < count; i++) {
      final item = pop();
      if (item != null) {
        result.add(item);
      } else {
        break;
      }
    }
    return result;
  }

  /// 清空缓冲区并返回所有元素
  List<T> drain() {
    final result = toList();
    reset();
    return result;
  }
}

/*
https://mp.weixin.qq.com/s/OvT0HjPeEiq8Ny6yggmG_A?version=4.1.38.99668&platform=mac&from=industrynews
 */