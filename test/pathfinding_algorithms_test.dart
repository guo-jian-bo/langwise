import 'dart:collection';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

/// 寻路算法学习项目
/// 包含多种经典寻路算法的实现和测试
void main() {
  group('寻路算法测试', () {
    late PathfindingGrid grid;
    
    setUp(() {
      // 创建一个10x10的网格用于测试
      grid = PathfindingGrid(10, 10);
    });

    test('A*算法测试', () {
      final astar = AStarAlgorithm();
      final path = astar.findPath(grid, Point(0, 0), Point(9, 9));
      
      expect(path, isNotNull);
      expect(path!.first, equals(Point(0, 0)));
      expect(path.last, equals(Point(9, 9)));
      
      print('A*算法路径长度: ${path.length}');
      _printPath(grid, path, 'A*算法');
    });

    test('Dijkstra算法测试', () {
      final dijkstra = DijkstraAlgorithm();
      final path = dijkstra.findPath(grid, Point(0, 0), Point(9, 9));
      
      expect(path, isNotNull);
      expect(path!.first, equals(Point(0, 0)));
      expect(path.last, equals(Point(9, 9)));
      
      print('Dijkstra算法路径长度: ${path.length}');
      _printPath(grid, path, 'Dijkstra算法');
    });

    test('BFS算法测试', () {
      final bfs = BFSAlgorithm();
      final path = bfs.findPath(grid, Point(0, 0), Point(9, 9));
      
      expect(path, isNotNull);
      expect(path!.first, equals(Point(0, 0)));
      expect(path.last, equals(Point(9, 9)));
      
      print('BFS算法路径长度: ${path.length}');
      _printPath(grid, path, 'BFS算法');
    });

    test('DFS算法测试', () {
      final dfs = DFSAlgorithm();
      final path = dfs.findPath(grid, Point(0, 0), Point(9, 9));
      
      expect(path, isNotNull);
      expect(path!.first, equals(Point(0, 0)));
      expect(path.last, equals(Point(9, 9)));
      
      print('DFS算法路径长度: ${path.length}');
      _printPath(grid, path, 'DFS算法');
    });

    test('带障碍物的寻路测试', () {
      // 添加一些障碍物
      grid.addObstacle(Point(5, 5));
      grid.addObstacle(Point(5, 6));
      grid.addObstacle(Point(5, 7));
      grid.addObstacle(Point(6, 5));
      grid.addObstacle(Point(7, 5));
      
      final astar = AStarAlgorithm();
      final path = astar.findPath(grid, Point(0, 0), Point(9, 9));
      
      expect(path, isNotNull);
      print('带障碍物的A*算法路径长度: ${path!.length}');
      _printPathWithObstacles(grid, path, '带障碍物的A*算法');
    });

    test('算法性能比较', () {
      final algorithms = {
        'A*': AStarAlgorithm(),
        'Dijkstra': DijkstraAlgorithm(),
        'BFS': BFSAlgorithm(),
        'DFS': DFSAlgorithm(),
      };
      
      print('\n=== 算法性能比较 ===');
      
      for (final entry in algorithms.entries) {
        final stopwatch = Stopwatch()..start();
        final path = entry.value.findPath(grid, Point(0, 0), Point(9, 9));
        stopwatch.stop();
        
        print('${entry.key}: 路径长度=${path?.length ?? 0}, 耗时=${stopwatch.elapsedMicroseconds}μs');
      }
    });
  });
}

/// 打印路径到控制台（用于可视化）
void _printPath(PathfindingGrid grid, List<Point<int>> path, String algorithmName) {
  print('\n=== $algorithmName 路径可视化 ===');
  
  for (int y = 0; y < grid.height; y++) {
    String row = '';
    for (int x = 0; x < grid.width; x++) {
      final point = Point(x, y);
      if (path.contains(point)) {
        if (point == path.first) {
          row += 'S '; // 起点
        } else if (point == path.last) {
          row += 'E '; // 终点
        } else {
          row += '* '; // 路径
        }
      } else {
        row += '. '; // 空地
      }
    }
    print(row);
  }
}

/// 打印带障碍物的路径
void _printPathWithObstacles(PathfindingGrid grid, List<Point<int>> path, String algorithmName) {
  print('\n=== $algorithmName 路径可视化（带障碍物）===');
  
  for (int y = 0; y < grid.height; y++) {
    String row = '';
    for (int x = 0; x < grid.width; x++) {
      final point = Point(x, y);
      if (grid.isObstacle(point)) {
        row += '# '; // 障碍物
      } else if (path.contains(point)) {
        if (point == path.first) {
          row += 'S '; // 起点
        } else if (point == path.last) {
          row += 'E '; // 终点
        } else {
          row += '* '; // 路径
        }
      } else {
        row += '. '; // 空地
      }
    }
    print(row);
  }
}

/// 网格节点类
class GridNode {
  final Point<int> position;
  double gCost = 0; // 从起点到当前节点的实际代价
  double hCost = 0; // 从当前节点到终点的启发式代价
  double get fCost => gCost + hCost; // 总代价
  GridNode? parent;
  bool isObstacle = false;
  bool isVisited = false;
  
  GridNode(this.position);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GridNode && other.position == position;
  }
  
  @override
  int get hashCode => position.hashCode;
}

/// 寻路网格类
class PathfindingGrid {
  final int width;
  final int height;
  final List<List<GridNode>> _grid;
  
  PathfindingGrid(this.width, this.height) 
      : _grid = List.generate(
          height,
          (y) => List.generate(
            width,
            (x) => GridNode(Point(x, y)),
          ),
        );
  
  /// 获取指定位置的节点
  GridNode? getNode(Point<int> position) {
    if (position.x < 0 || position.x >= width || 
        position.y < 0 || position.y >= height) {
      return null;
    }
    return _grid[position.y][position.x];
  }
  
  /// 添加障碍物
  void addObstacle(Point<int> position) {
    final node = getNode(position);
    if (node != null) {
      node.isObstacle = true;
    }
  }
  
  /// 检查是否为障碍物
  bool isObstacle(Point<int> position) {
    final node = getNode(position);
    return node?.isObstacle ?? true;
  }
  
  /// 获取邻居节点
  List<GridNode> getNeighbors(Point<int> position) {
    final neighbors = <GridNode>[];
    final directions = [
      Point(-1, 0), Point(1, 0),  // 左右
      Point(0, -1), Point(0, 1),  // 上下
      Point(-1, -1), Point(1, -1), // 对角线
      Point(-1, 1), Point(1, 1),
    ];
    
    for (final direction in directions) {
      final neighborPos = Point(
        position.x + direction.x,
        position.y + direction.y,
      );
      
      final neighbor = getNode(neighborPos);
      if (neighbor != null && !neighbor.isObstacle) {
        neighbors.add(neighbor);
      }
    }
    
    return neighbors;
  }
  
  /// 重置网格状态
  void reset() {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final node = _grid[y][x];
        node.gCost = 0;
        node.hCost = 0;
        node.parent = null;
        node.isVisited = false;
        node.isObstacle = false;
      }
    }
  }
}

/// 寻路算法抽象基类
abstract class PathfindingAlgorithm {
  /// 寻找从起点到终点的路径
  List<Point<int>>? findPath(PathfindingGrid grid, Point<int> start, Point<int> end);
  
  /// 计算两点间的曼哈顿距离
  double manhattanDistance(Point<int> a, Point<int> b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs().toDouble();
  }
  
  /// 计算两点间的欧几里得距离
  double euclideanDistance(Point<int> a, Point<int> b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }
  
  /// 重建路径
  List<Point<int>> reconstructPath(GridNode endNode) {
    final path = <Point<int>>[];
    GridNode? current = endNode;
    
    while (current != null) {
      path.add(current.position);
      current = current.parent;
    }
    
    return path.reversed.toList();
  }
}

/// A*算法实现
class AStarAlgorithm extends PathfindingAlgorithm {
  @override
  List<Point<int>>? findPath(PathfindingGrid grid, Point<int> start, Point<int> end) {
    grid.reset();
    
    final startNode = grid.getNode(start);
    final endNode = grid.getNode(end);
    
    if (startNode == null || endNode == null) return null;
    
    final openSet = PriorityQueue<GridNode>((a, b) => a.fCost.compareTo(b.fCost));
    final closedSet = <GridNode>{};
    
    startNode.gCost = 0;
    startNode.hCost = euclideanDistance(start, end);
    openSet.add(startNode);
    
    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();
      closedSet.add(current);
      
      if (current.position == end) {
        return reconstructPath(current);
      }
      
      for (final neighbor in grid.getNeighbors(current.position)) {
        if (closedSet.contains(neighbor)) continue;
        
        final tentativeGCost = current.gCost + euclideanDistance(current.position, neighbor.position);
        
        if (!openSet.contains(neighbor)) {
          openSet.add(neighbor);
        } else if (tentativeGCost >= neighbor.gCost) {
          continue;
        }
        
        neighbor.parent = current;
        neighbor.gCost = tentativeGCost;
        neighbor.hCost = euclideanDistance(neighbor.position, end);
      }
    }
    
    return null;
  }
}

/// Dijkstra算法实现
class DijkstraAlgorithm extends PathfindingAlgorithm {
  @override
  List<Point<int>>? findPath(PathfindingGrid grid, Point<int> start, Point<int> end) {
    grid.reset();
    
    final startNode = grid.getNode(start);
    final endNode = grid.getNode(end);
    
    if (startNode == null || endNode == null) return null;
    
    final unvisited = PriorityQueue<GridNode>((a, b) => a.gCost.compareTo(b.gCost));
    final distances = <GridNode, double>{};
    
    // 初始化距离
    for (int y = 0; y < grid.height; y++) {
      for (int x = 0; x < grid.width; x++) {
        final node = grid.getNode(Point(x, y))!;
        distances[node] = double.infinity;
        unvisited.add(node);
      }
    }
    
    distances[startNode] = 0;
    startNode.gCost = 0;
    
    while (unvisited.isNotEmpty) {
      final current = unvisited.removeFirst();
      
      if (current.position == end) {
        return reconstructPath(current);
      }
      
      for (final neighbor in grid.getNeighbors(current.position)) {
        if (!unvisited.contains(neighbor)) continue;
        
        final distance = distances[current]! + euclideanDistance(current.position, neighbor.position);
        
        if (distance < distances[neighbor]!) {
          distances[neighbor] = distance;
          neighbor.gCost = distance;
          neighbor.parent = current;
        }
      }
    }
    
    return null;
  }
}

/// 广度优先搜索算法实现
class BFSAlgorithm extends PathfindingAlgorithm {
  @override
  List<Point<int>>? findPath(PathfindingGrid grid, Point<int> start, Point<int> end) {
    grid.reset();
    
    final startNode = grid.getNode(start);
    final endNode = grid.getNode(end);
    
    if (startNode == null || endNode == null) return null;
    
    final queue = Queue<GridNode>();
    final visited = <GridNode>{};
    
    queue.add(startNode);
    visited.add(startNode);
    
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
    
    return null;
  }
}

/// 深度优先搜索算法实现
class DFSAlgorithm extends PathfindingAlgorithm {
  @override
  List<Point<int>>? findPath(PathfindingGrid grid, Point<int> start, Point<int> end) {
    grid.reset();
    
    final startNode = grid.getNode(start);
    final endNode = grid.getNode(end);
    
    if (startNode == null || endNode == null) return null;
    
    final visited = <GridNode>{};
    
    if (_dfsRecursive(grid, startNode, endNode, visited)) {
      return reconstructPath(endNode);
    }
    
    return null;
  }
  
  /// DFS递归实现
  bool _dfsRecursive(PathfindingGrid grid, GridNode current, GridNode target, Set<GridNode> visited) {
    visited.add(current);
    
    if (current.position == target.position) {
      return true;
    }
    
    for (final neighbor in grid.getNeighbors(current.position)) {
      if (!visited.contains(neighbor)) {
        neighbor.parent = current;
        if (_dfsRecursive(grid, neighbor, target, visited)) {
          return true;
        }
      }
    }
    
    return false;
  }
}

/// 简单的优先队列实现
class PriorityQueue<T> {
  final List<T> _items = [];
  final int Function(T, T) _compare;
  
  PriorityQueue(this._compare);
  
  void add(T item) {
    _items.add(item);
    _items.sort(_compare);
  }
  
  T removeFirst() {
    return _items.removeAt(0);
  }
  
  bool get isNotEmpty => _items.isNotEmpty;
  bool get isEmpty => _items.isEmpty;
  
  bool contains(T item) => _items.contains(item);
}