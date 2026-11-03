import 'package:flutter/material.dart';
import 'pathfinding_visualization_widget.dart';

/// 寻路算法演示应用入口
/// 这个文件展示了如何在主应用中集成寻路算法可视化组件
void main() {
  runApp(const PathfindingDemoApp());
}

/// 寻路算法演示应用
class PathfindingDemoApp extends StatelessWidget {
  const PathfindingDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '寻路算法学习演示',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      home: const PathfindingHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 寻路算法学习主页
class PathfindingHomePage extends StatelessWidget {
  const PathfindingHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('寻路算法学习'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 标题区域
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.route,
                        size: 60,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '寻路算法可视化学习',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '通过交互式可视化界面学习经典寻路算法',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // 算法介绍卡片
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.2,
                    children: [
                      _buildAlgorithmCard(
                        'A* 算法',
                        '启发式搜索\n最优路径',
                        Icons.star,
                        Colors.orange,
                      ),
                      _buildAlgorithmCard(
                        'Dijkstra',
                        '最短路径\n保证最优',
                        Icons.timeline,
                        Colors.green,
                      ),
                      _buildAlgorithmCard(
                        'BFS',
                        '广度优先\n逐层搜索',
                        Icons.waves,
                        Colors.blue,
                      ),
                      _buildAlgorithmCard(
                        'DFS',
                        '深度优先\n深入搜索',
                        Icons.vertical_align_bottom,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 开始按钮
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PathfindingVisualizationWidget(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, size: 24),
                      SizedBox(width: 8),
                      Text(
                        '开始学习寻路算法',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // 说明文本
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '学习提示',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• 点击网格设置起点、终点和障碍物\n'
                        '• 选择不同算法观察搜索过程\n'
                        '• 比较各算法的效率和路径质量',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建算法介绍卡片
  Widget _buildAlgorithmCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 如何在现有项目中集成寻路算法组件的示例
class IntegrationExample {
  /// 方法1: 作为独立页面
  static void navigateToPathfinding(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PathfindingVisualizationWidget(),
      ),
    );
  }
  
  /// 方法2: 作为底部弹窗
  static void showPathfindingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: const PathfindingVisualizationWidget(),
      ),
    );
  }
  
  /// 方法3: 作为对话框
  static void showPathfindingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: const PathfindingVisualizationWidget(),
        ),
      ),
    );
  }
}

/// 使用示例Widget
class UsageExampleWidget extends StatelessWidget {
  const UsageExampleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('集成示例'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => IntegrationExample.navigateToPathfinding(context),
              child: const Text('打开寻路算法页面'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => IntegrationExample.showPathfindingBottomSheet(context),
              child: const Text('显示寻路算法底部弹窗'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => IntegrationExample.showPathfindingDialog(context),
              child: const Text('显示寻路算法对话框'),
            ),
          ],
        ),
      ),
    );
  }
}