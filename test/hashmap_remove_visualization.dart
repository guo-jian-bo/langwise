

/// 简化的哈希表节点
class HashNode {
  String key;
  String value;
  HashNode? next;
  
  HashNode(this.key, this.value, [this.next]);
  
  @override
  String toString() => 'key: "$key"';
}

/// 简化的哈希表实现
class SimpleHashMap {
    List<HashNode?> buckets;
    int size = 0;
    
    SimpleHashMap(int capacity) : buckets = List.filled(capacity, null);
    
    /// 计算哈希值
    int _hash(String key) {
      int hash = 0;
      for (int i = 0; i < key.length; i++) {
        hash += key.codeUnitAt(i);
      }
      return hash;
    }
    
    /// 获取桶索引
    int _getBucketIndex(String key) {
      return _hash(key) & (buckets.length - 1);
    }
    
    /// 添加元素
    void put(String key, String value) {
      int index = _getBucketIndex(key);
      HashNode newNode = HashNode(key, value);
      
      if (buckets[index] == null) {
        buckets[index] = newNode;
      } else {
        // 添加到链表头部
        newNode.next = buckets[index];
        buckets[index] = newNode;
      }
      size++;
    }
    
    /// 移除元素并返回可视化步骤
    List<String> removeWithVisualization(String key) {
      List<String> steps = [];
      
      // 步骤1: 计算哈希值
      int hash = _hash(key);
      steps.add('步骤1: 计算哈希值');
      steps.add('hash("$key") = $hash');
      
      // 步骤2: 计算桶索引
      int index = _getBucketIndex(key);
      steps.add('\n步骤2: 计算桶索引');
      steps.add('index = $hash & ${buckets.length - 1} = $index');
      
      // 步骤3: 访问桶
      steps.add('\n步骤3: 访问桶[$index]');
      if (buckets[index] == null) {
        steps.add('桶为空，元素不存在');
        return steps;
      }
      
      // 步骤4: 遍历链表查找元素
      steps.add('\n步骤4: 遍历链表查找目标元素');
      HashNode? current = buckets[index];
      HashNode? previous = null;
      int position = 0;
      
      while (current != null) {
        if (current.key == key) {
          steps.add('在位置 $position 找到目标元素: "$key"');
          break;
        }
        steps.add('位置 $position: "${current.key}" ≠ "$key", 继续查找');
        previous = current;
        current = current.next;
        position++;
      }
      
      if (current == null) {
        steps.add('未找到目标元素');
        return steps;
      }
      
      // 步骤5: 移除节点
      steps.add('\n步骤5: 移除节点');
      if (previous == null) {
        // 移除头节点
        buckets[index] = current.next;
        steps.add('移除头节点，将桶[$index]指向下一个节点');
      } else {
        // 移除中间或尾部节点
        previous.next = current.next;
        steps.add('将前一个节点的next指针指向被删除节点的下一个节点');
      }
      
      size--;
      steps.add('元素成功移除，哈希表大小: $size');
      
      return steps;
    }
    
    /// 打印哈希表状态
    void printState() {
      print('\n=== 哈希表当前状态 ===');
      for (int i = 0; i < buckets.length; i++) {
        if (buckets[i] != null) {
          String chain = '';
          HashNode? current = buckets[i];
          while (current != null) {
            chain += '"${current.key}"';
            if (current.next != null) {
              chain += ' -> ';
            }
            current = current.next;
          }
          print('桶[$i]: $chain');
        } else {
          print('桶[$i]: 空');
        }
      }
      print('总元素数: $size\n');
    }
  }

/// HashMap 移除过程可视化演示
class HashMapRemoveVisualization {
  /// 演示移除过程的可视化
  static void demonstrateRemoveProcess() {
    print('=== HashMap 移除过程可视化演示 ===\n');
    
    // 创建一个容量为8的哈希表
    SimpleHashMap hashMap = SimpleHashMap(8);
    
    // 添加一些元素
    print('初始化哈希表，添加元素...');
    hashMap.put('apple', 'red');
    hashMap.put('banana', 'yellow');
    hashMap.put('cherry', 'red');
    hashMap.put('date', 'brown');
    
    hashMap.printState();
    
    // 演示移除 "banana" 的过程
    print('=== 移除 "banana" 的详细过程 ===');
    List<String> steps = hashMap.removeWithVisualization('banana');
    
    for (String step in steps) {
      print(step);
    }
    
    print('\n移除后的哈希表状态:');
    hashMap.printState();
    
    // 演示移除不存在元素的过程
    print('=== 尝试移除不存在的元素 "grape" ===');
    List<String> notFoundSteps = hashMap.removeWithVisualization('grape');
    
    for (String step in notFoundSteps) {
      print(step);
    }
  }
  
  /// 创建ASCII艺术风格的链表可视化
  static void visualizeLinkedListRemoval() {
    print('\n=== 链表节点移除可视化 ===\n');
    
    print('移除前的链表结构:');
    print('┌─────────────┐    ┌──────────────┐    ┌──────────────┐');
    print('│key: "cherry"│───▶│key: "banana" │───▶│key: "apple"  │');
    print('│             │    │   (目标)     │    │              │');
    print('└─────────────┘    └──────────────┘    └──────────────┘');
    print('      头节点            中间节点            尾节点\n');
    
    print('移除 "banana" 节点的步骤:');
    print('1. 找到目标节点的前驱节点 ("cherry")');
    print('2. 将前驱节点的next指针指向目标节点的后继节点 ("apple")');
    print('3. 释放目标节点的内存\n');
    
    print('移除后的链表结构:');
    print('┌─────────────┐                       ┌──────────────┐');
    print('│key: "cherry"│──────────────────────▶│key: "apple"  │');
    print('│             │                       │              │');
    print('└─────────────┘                       └──────────────┘');
    print('      头节点                              尾节点\n');
  }
  
  /// 演示不同位置节点的移除
  static void demonstrateDifferentPositionRemovals() {
    print('=== 不同位置节点移除演示 ===\n');
    
    SimpleHashMap hashMap = SimpleHashMap(8);
    
    // 构造一个有多个元素的链表
    // 注意：由于put方法将新元素添加到链表头部，
    // 添加顺序 'first', 'second', 'third' 会形成链表：'third' -> 'second' -> 'first'
    hashMap.put('first', 'value1');   // 第一个添加，最终在尾部
    hashMap.put('second', 'value2');  // 第二个添加，最终在中间
    hashMap.put('third', 'value3');   // 第三个添加，最终在头部
    
    print('初始状态（链表结构：third -> second -> first）:');
    hashMap.printState();
    
    // 移除头节点 (third)
    print('=== 移除头节点 (third) ===');
    List<String> headRemoval = hashMap.removeWithVisualization('third');
    for (String step in headRemoval) {
      print(step);
    }
    print('移除头节点后，链表变为：second -> first');
    hashMap.printState();
    
    // 移除中间节点 (second) - 现在second变成了头节点
    print('=== 移除当前头节点 (second) ===');
    List<String> middleRemoval = hashMap.removeWithVisualization('second');
    for (String step in middleRemoval) {
      print(step);
    }
    print('移除second后，链表变为：first');
    hashMap.printState();
    
    // 移除尾节点 (first) - 现在first是唯一节点
    print('=== 移除最后一个节点 (first) ===');
    List<String> tailRemoval = hashMap.removeWithVisualization('first');
    for (String step in tailRemoval) {
      print(step);
    }
    print('移除first后，链表为空');
    hashMap.printState();
    
    // 重新演示真正的中间节点移除
    print('\n=== 重新演示真正的中间节点移除 ===');
    hashMap.put('node1', 'value1');   // 尾节点
    hashMap.put('node2', 'value2');   // 中间节点  
    hashMap.put('node3', 'value3');   // 头节点
    
    print('重新构建链表（node3 -> node2 -> node1）:');
    hashMap.printState();
    
    print('=== 移除真正的中间节点 (node2) ===');
    List<String> realMiddleRemoval = hashMap.removeWithVisualization('node2');
    for (String step in realMiddleRemoval) {
      print(step);
    }
    print('移除中间节点后，链表变为：node3 -> node1');
    hashMap.printState();
  }
}

/// 主函数 - 运行所有演示
void main() {
  // 基本移除过程演示
  HashMapRemoveVisualization.demonstrateRemoveProcess();
  
  // 链表可视化
  HashMapRemoveVisualization.visualizeLinkedListRemoval();
  
  // 不同位置节点移除演示
  HashMapRemoveVisualization.demonstrateDifferentPositionRemovals();
  
  print('=== 演示完成 ===');
}