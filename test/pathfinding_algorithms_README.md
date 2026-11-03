# 寻路算法学习项目

这是一个用于学习和理解各种寻路算法的Flutter项目。项目包含了多种经典寻路算法的实现和可视化演示。

## 📚 包含的算法

### 1. A* 算法 (A-Star)
- **特点**: 启发式搜索算法，结合了Dijkstra算法的准确性和贪心最佳优先搜索的效率
- **时间复杂度**: O(b^d)，其中b是分支因子，d是解的深度
- **空间复杂度**: O(b^d)
- **优点**: 在有良好启发函数的情况下，能快速找到最优路径
- **缺点**: 需要大量内存存储开放列表

### 2. Dijkstra 算法
- **特点**: 单源最短路径算法，保证找到最优解
- **时间复杂度**: O((V + E) log V)，其中V是顶点数，E是边数
- **空间复杂度**: O(V)
- **优点**: 保证找到最短路径，适用于有权图
- **缺点**: 搜索范围大，效率相对较低

### 3. 广度优先搜索 (BFS)
- **特点**: 逐层搜索，保证找到最短路径（在无权图中）
- **时间复杂度**: O(V + E)
- **空间复杂度**: O(V)
- **优点**: 简单易懂，保证找到最短路径
- **缺点**: 内存消耗大，不适用于有权图

### 4. 深度优先搜索 (DFS)
- **特点**: 深入搜索直到无路可走再回溯
- **时间复杂度**: O(V + E)
- **空间复杂度**: O(V)
- **优点**: 内存消耗相对较小
- **缺点**: 不保证找到最短路径，可能陷入深层分支

## 🚀 如何运行

### 运行测试
```bash
# 在项目根目录下运行
flutter test test/pathfinding_algorithms_test.dart
```

### 运行可视化演示
```dart
// 在main.dart中添加以下代码
import 'test/pathfinding_visualization_widget.dart';

void main() {
  runApp(const PathfindingLearningApp());
}
```

## 🎮 使用说明

### 可视化界面操作
1. **设置起点和终点**：点击空白格子设置起点（绿色）和终点（红色）
2. **添加障碍物**：在设置起点终点后，点击空白格子添加障碍物（黑色）
3. **移除障碍物**：点击已有的障碍物可以移除
4. **选择算法**：使用下拉菜单选择要演示的算法
5. **开始寻路**：点击"开始寻路"按钮运行算法
6. **清除网格**：重置整个网格
7. **添加随机障碍物**：自动生成随机障碍物

### 颜色说明
- 🟢 **绿色**：起点
- 🔴 **红色**：终点
- ⚫ **黑色**：障碍物
- 🔵 **蓝色**：最终路径
- 🔷 **浅蓝色**：算法访问过的节点
- ⚪ **白色**：空白区域

## 📖 算法详解

### A* 算法原理
A*算法使用评估函数 f(n) = g(n) + h(n)：
- g(n)：从起点到节点n的实际代价
- h(n)：从节点n到终点的启发式估计代价
- f(n)：节点n的总评估代价

```dart
// A*算法核心逻辑
while (openSet.isNotEmpty) {
  final current = openSet.removeFirst(); // 选择f值最小的节点
  
  if (current.position == end) {
    return reconstructPath(current); // 找到目标
  }
  
  for (final neighbor in grid.getNeighbors(current.position)) {
    final tentativeGCost = current.gCost + distance(current, neighbor);
    
    if (tentativeGCost < neighbor.gCost) {
      neighbor.parent = current;
      neighbor.gCost = tentativeGCost;
      neighbor.hCost = heuristic(neighbor, end);
    }
  }
}
```

### Dijkstra 算法原理
Dijkstra算法维护一个距离表，不断更新到各节点的最短距离：

```dart
// Dijkstra算法核心逻辑
while (unvisited.isNotEmpty) {
  final current = unvisited.removeFirst(); // 选择距离最小的未访问节点
  
  for (final neighbor in grid.getNeighbors(current.position)) {
    final distance = distances[current] + edgeWeight(current, neighbor);
    
    if (distance < distances[neighbor]) {
      distances[neighbor] = distance;
      neighbor.parent = current;
    }
  }
}
```

### BFS 算法原理
BFS使用队列确保按层次搜索：

```dart
// BFS算法核心逻辑
final queue = Queue<GridNode>();
queue.add(startNode);

while (queue.isNotEmpty) {
  final current = queue.removeFirst();
  
  if (current.position == end) {
    return reconstructPath(current);
  }
  
  for (final neighbor in grid.getNeighbors(current.position)) {
    if (!visited.contains(neighbor)) {
      visited.add(neighbor);
      neighbor.parent = current;
      queue.add(neighbor);
    }
  }
}
```

## 🔧 代码结构

```
test/
├── pathfinding_algorithms_test.dart      # 算法实现和单元测试
├── pathfinding_visualization_widget.dart # 可视化界面组件
└── pathfinding_algorithms_README.md      # 项目说明文档
```

### 主要类说明

#### PathfindingGrid
网格类，管理搜索空间：
- 维护网格节点
- 处理障碍物
- 提供邻居节点查询

#### GridNode
网格节点类：
- 存储位置信息
- 维护路径查找所需的代价值
- 记录父节点用于路径重建

#### PathfindingAlgorithm
算法抽象基类：
- 定义通用接口
- 提供距离计算方法
- 实现路径重建逻辑

#### VisualizableAlgorithm
可视化算法接口：
- 支持步进式算法执行
- 提供搜索过程的实时反馈

## 🎯 学习建议

### 1. 理论学习顺序
1. **BFS** - 最简单的搜索算法，理解搜索的基本概念
2. **DFS** - 理解深度搜索和回溯的概念
3. **Dijkstra** - 学习最短路径算法的经典实现
4. **A*** - 理解启发式搜索和优化策略

### 2. 实践练习
1. 在不同网格大小下测试算法性能
2. 尝试不同的障碍物布局
3. 比较各算法的路径长度和搜索节点数
4. 修改启发函数观察A*算法的行为变化

### 3. 扩展实验
1. 实现Jump Point Search (JPS) 算法
2. 添加对角线移动的权重
3. 实现双向搜索
4. 添加动态障碍物

## 📊 性能比较

| 算法 | 最优性 | 完备性 | 时间复杂度 | 空间复杂度 | 适用场景 |
|------|--------|--------|------------|------------|----------|
| A* | ✅ | ✅ | O(b^d) | O(b^d) | 有良好启发函数的场景 |
| Dijkstra | ✅ | ✅ | O((V+E)logV) | O(V) | 有权图最短路径 |
| BFS | ✅* | ✅ | O(V+E) | O(V) | 无权图最短路径 |
| DFS | ❌ | ✅** | O(V+E) | O(V) | 路径存在性检查 |

*仅在无权图中保证最优  
**仅在有限图中保证完备

## 🤔 常见问题

### Q: 为什么A*算法有时比Dijkstra慢？
A: 当启发函数不够好或者目标点在起点附近时，A*可能退化为类似Dijkstra的行为，但由于额外的启发函数计算开销，可能会更慢。

### Q: 什么时候选择BFS而不是A*？
A: 在无权图中，BFS实现简单且保证最短路径。当不需要考虑移动代价或者图规模较小时，BFS是很好的选择。

### Q: DFS什么时候有用？
A: DFS适用于只需要找到任意一条路径（不要求最短）的场景，或者用于检测路径的连通性。

### Q: 如何选择合适的启发函数？
A: 启发函数应该是可接受的（不高估实际代价）和一致的。常用的有曼哈顿距离、欧几里得距离等。

## 📚 参考资料

1. [A* Search Algorithm - Wikipedia](https://en.wikipedia.org/wiki/A*_search_algorithm)
2. [Dijkstra's Algorithm - Wikipedia](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm)
3. [Breadth-First Search - Wikipedia](https://en.wikipedia.org/wiki/Breadth-first_search)
4. [Depth-First Search - Wikipedia](https://en.wikipedia.org/wiki/Depth-first_search)
5. [Introduction to A* - Red Blob Games](https://www.redblobgames.com/pathfinding/a-star/introduction.html)

## 🛠️ 技术栈

- **Flutter**: 跨平台UI框架
- **Dart**: 编程语言
- **flutter_test**: 单元测试框架

## 📝 许可证

本项目仅用于学习目的，欢迎自由使用和修改。

---

**Happy Learning! 🎉**

通过这个项目，你将深入理解寻路算法的工作原理，并能够在实际项目中选择合适的算法。记住，最好的学习方式是动手实践！