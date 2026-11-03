import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'pathfinding_algorithms_test.dart';

/// 寻路算法可视化Widget
/// 提供交互式的寻路算法演示界面
class PathfindingVisualizationWidget extends StatefulWidget {
  const PathfindingVisualizationWidget({Key? key}) : super(key: key);

  @override
  State<PathfindingVisualizationWidget> createState() => _PathfindingVisualizationWidgetState();
}

class _PathfindingVisualizationWidgetState extends State<PathfindingVisualizationWidget> {
  static const int gridSize = 20;
  late PathfindingGrid grid;
  Point<int>? startPoint;
  Point<int>? endPoint;
  List<Point<int>> currentPath = [];
  List<Point<int>> visitedNodes = [];
  String selectedAlgorithm = 'A*';
  bool isRunning = false;
  bool showVisited = true;
  
  final Map<String, PathfindingAlgorithm> algorithms = {
    'A*': AStarAlgorithm(),
    'Dijkstra': DijkstraAlgorithm(),
    'BFS': BFSAlgorithm(),
    'DFS': DFSAlgorithm(),
  };

  @override
  void initState() {
    super.initState();
    _initializeGrid();
  }

  /// 初始化网格
  void _initializeGrid() {
    grid = PathfindingGrid(gridSize, gridSize);
    startPoint = const Point(2, 2);
    endPoint = Point(gridSize - 3, gridSize - 3);
    currentPath = [];
    visitedNodes = [];
  }

  /// 运行选定的寻路算法
  Future<void> _runAlgorithm() async {
    if (startPoint == null || endPoint == null || isRunning) return;
    
    setState(() {
      isRunning = true;
      currentPath = [];
      visitedNodes = [];
    });

    final algorithm = algorithms[selectedAlgorithm]!;
    
    // 如果是可视化算法，显示搜索过程
    if (algorithm is VisualizableAlgorithm) {
      await _runVisualizableAlgorithm(algorithm);
    } else {
      // 直接运行算法
      final path = algorithm.findPath(grid, startPoint!, endPoint!);
      setState(() {
        currentPath = path ?? [];
        isRunning = false;
      });
    }
  }

  /// 运行可视化算法
  Future<void> _runVisualizableAlgorithm(VisualizableAlgorithm algorithm) async {
    await for (final step in algorithm.findPathWithVisualization(grid, startPoint!, endPoint!)) {
      if (!mounted) break;
      
      setState(() {
        visitedNodes = step.visitedNodes;
        currentPath = step.currentPath;
      });
      
      await Future.delayed(const Duration(milliseconds: 50));
    }
    
    setState(() {
      isRunning = false;
    });
  }

  /// 清除网格
  void _clearGrid() {
    setState(() {
      _initializeGrid();
    });
  }

  /// 添加随机障碍物
  void _addRandomObstacles() {
    final random = Random();
    final obstacleCount = (gridSize * gridSize * 0.2).round();
    
    for (int i = 0; i < obstacleCount; i++) {
      Point<int> obstacle;
      do {
        obstacle = Point(random.nextInt(gridSize), random.nextInt(gridSize));
      } while (obstacle == startPoint || obstacle == endPoint || grid.isObstacle(obstacle));
      
      grid.addObstacle(obstacle);
    }
    
    setState(() {});
  }

  /// 处理网格点击事件
  void _onGridTap(Point<int> position) {
    if (isRunning) return;
    
    setState(() {
      if (position == startPoint) {
        startPoint = null;
      } else if (position == endPoint) {
        endPoint = null;
      } else if (grid.isObstacle(position)) {
        grid.getNode(position)!.isObstacle = false;
      } else if (startPoint == null) {
        startPoint = position;
      } else if (endPoint == null) {
        endPoint = position;
      } else {
        grid.addObstacle(position);
      }
      
      currentPath = [];
      visitedNodes = [];
    });
  }

  /// 获取网格单元格颜色
  Color _getCellColor(Point<int> position) {
    if (position == startPoint) {
      return Colors.green;
    } else if (position == endPoint) {
      return Colors.red;
    } else if (grid.isObstacle(position)) {
      return Colors.black;
    } else if (currentPath.contains(position)) {
      return Colors.blue;
    } else if (showVisited && visitedNodes.contains(position)) {
      return Colors.lightBlue.withOpacity(0.5);
    } else {
      return Colors.white;
    }
  }

  /// 获取网格单元格图标
  Widget? _getCellIcon(Point<int> position) {
    if (position == startPoint) {
      return const Icon(Icons.play_arrow, color: Colors.white, size: 16);
    } else if (position == endPoint) {
      return const Icon(Icons.flag, color: Colors.white, size: 16);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('寻路算法可视化演示'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 控制面板
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('算法选择: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: selectedAlgorithm,
                      onChanged: isRunning ? null : (value) {
                        setState(() {
                          selectedAlgorithm = value!;
                          currentPath = [];
                          visitedNodes = [];
                        });
                      },
                      items: algorithms.keys.map((algorithm) {
                        return DropdownMenuItem(
                          value: algorithm,
                          child: Text(algorithm),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 20),
                    Checkbox(
                      value: showVisited,
                      onChanged: (value) {
                        setState(() {
                          showVisited = value!;
                        });
                      },
                    ),
                    const Text('显示访问节点'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: isRunning ? null : _runAlgorithm,
                      child: isRunning 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('开始寻路'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: isRunning ? null : _clearGrid,
                      child: const Text('清除网格'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: isRunning ? null : _addRandomObstacles,
                      child: const Text('添加障碍物'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 图例
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildLegendItem(Colors.green, '起点'),
                _buildLegendItem(Colors.red, '终点'),
                _buildLegendItem(Colors.black, '障碍物'),
                _buildLegendItem(Colors.blue, '路径'),
                _buildLegendItem(Colors.lightBlue.withOpacity(0.5), '已访问'),
              ],
            ),
          ),
          
          // 网格
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                    ),
                    itemCount: gridSize * gridSize,
                    itemBuilder: (context, index) {
                      final x = index % gridSize;
                      final y = index ~/ gridSize;
                      final position = Point(x, y);
                      
                      return GestureDetector(
                        onTap: () => _onGridTap(position),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getCellColor(position),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 0.5,
                            ),
                          ),
                          child: _getCellIcon(position),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          
          // 状态信息
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('当前算法: $selectedAlgorithm', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('路径长度: ${currentPath.length}'),
                Text('访问节点数: ${visitedNodes.length}'),
                const SizedBox(height: 8),
                const Text(
                  '操作说明:\n'
                  '• 点击空白处设置起点和终点\n'
                  '• 点击已设置的点可以取消\n'
                  '• 点击空白处添加障碍物\n'
                  '• 点击障碍物可以移除',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建图例项
  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

/// 可视化步骤数据类
class VisualizationStep {
  final List<Point<int>> visitedNodes;
  final List<Point<int>> currentPath;
  final bool isComplete;
  
  const VisualizationStep({
    required this.visitedNodes,
    required this.currentPath,
    this.isComplete = false,
  });
}

/// 可视化算法接口
abstract class VisualizableAlgorithm extends PathfindingAlgorithm {
  /// 带可视化的寻路方法
  Stream<VisualizationStep> findPathWithVisualization(
    PathfindingGrid grid, 
    Point<int> start, 
    Point<int> end
  );
}

/// 可视化A*算法实现
class VisualAStarAlgorithm extends AStarAlgorithm implements VisualizableAlgorithm {
  @override
  Stream<VisualizationStep> findPathWithVisualization(
    PathfindingGrid grid, 
    Point<int> start, 
    Point<int> end
  ) async* {
    grid.reset();
    
    final startNode = grid.getNode(start);
    final endNode = grid.getNode(end);
    
    if (startNode == null || endNode == null) return;
    
    final openSet = PriorityQueue<GridNode>((a, b) => a.fCost.compareTo(b.fCost));
    final closedSet = <GridNode>{};
    final visitedNodes = <Point<int>>[];
    
    startNode.gCost = 0;
    startNode.hCost = euclideanDistance(start, end);
    openSet.add(startNode);
    
    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();
      closedSet.add(current);
      visitedNodes.add(current.position);
      
      yield VisualizationStep(
        visitedNodes: List.from(visitedNodes),
        currentPath: [],
      );
      
      if (current.position == end) {
        final finalPath = reconstructPath(current);
        yield VisualizationStep(
          visitedNodes: List.from(visitedNodes),
          currentPath: finalPath,
          isComplete: true,
        );
        return;
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
  }
}

/// 可视化BFS算法实现
class VisualBFSAlgorithm extends BFSAlgorithm implements VisualizableAlgorithm {
  @override
  Stream<VisualizationStep> findPathWithVisualization(
    PathfindingGrid grid, 
    Point<int> start, 
    Point<int> end
  ) async* {
    grid.reset();
    
    final startNode = grid.getNode(start);
    final endNode = grid.getNode(end);
    
    if (startNode == null || endNode == null) return;
    
    final queue = <GridNode>[startNode];
    final visited = <GridNode>{startNode};
    final visitedNodes = <Point<int>>[start];
    
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      
      yield VisualizationStep(
        visitedNodes: List.from(visitedNodes),
        currentPath: [],
      );
      
      if (current.position == end) {
        final finalPath = reconstructPath(current);
        yield VisualizationStep(
          visitedNodes: List.from(visitedNodes),
          currentPath: finalPath,
          isComplete: true,
        );
        return;
      }
      
      for (final neighbor in grid.getNeighbors(current.position)) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          visitedNodes.add(neighbor.position);
          neighbor.parent = current;
          queue.add(neighbor);
        }
      }
    }
  }
}

/// 寻路算法学习应用主入口
class PathfindingLearningApp extends StatelessWidget {
  const PathfindingLearningApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '寻路算法学习',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PathfindingVisualizationWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}