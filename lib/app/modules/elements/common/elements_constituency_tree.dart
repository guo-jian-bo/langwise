import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';

class ElementsConstituencyTree extends StatefulWidget {
  final bool graphShowDetils;
  final void Function(String word)? onWord;
  final String constituency;
  final List<LanguageConfigColorEntityInfo?>? colorConfigs;
  /// 句法关系树
  const ElementsConstituencyTree({
    super.key, 
    this.graphShowDetils = false, 
    this.onWord, 
    required this.constituency,
    this.colorConfigs,
  });

  @override
  State<ElementsConstituencyTree> createState() => _ElementsConstituencyTreeState();
}

class _ElementsConstituencyTreeState extends State<ElementsConstituencyTree> {
  // String parse = "(ROOT\n  (S\n    (NP (DT The) (NN teacher))\n    (VP\n      (VBD knew)\n      (SBAR\n        (IN that)\n        (S\n          (NP\n            (NP (DT the) (JJ diligent) (NN student))\n            (SBAR\n              (WHNP (WP who))\n              (S\n                (ADVP (RB always))\n                (VP\n                  (VBD arrived)\n                  (ADVP (RB early))))))\n          (VP\n            (MD would)\n            (VP\n              (VB pass)\n              (NP (DT the) (NN exam))\n              (SBAR\n                (IN if)\n                (S\n                  (NP (PRP she))\n                  (VP\n                    (VBD studied)\n                    (ADVP (RB consistently))))))))))\n    (. .)))\n";

  final GlobalKey chartKey = GlobalKey();

  final TransformationController transformationController = TransformationController();

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  
  // 存储节点信息的映射
  final Map<String, Node> nodeMap = {};
  // 存储节点标签的映射
  final Map<String, String> nodeLabelMap = {};
  // 节点ID计数器
  int nodeIdCounter = 0;


  @override
  void initState() {
    super.initState();
    // 解析句法树字符串并构建图形
    _parseConstituencyTree(widget.constituency);
    
    // 配置布局参数
    builder
      ..siblingSeparation = (20.wMin.toInt())
      ..levelSeparation = (35.wMin.toInt())
      ..subtreeSeparation = (30.wMin.toInt())
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT);


    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox? renderBox = chartKey.currentContext?.findRenderObject() as RenderBox?;
      RenderBox? mainRenderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && mainRenderBox != null) {
        Size chartSize = renderBox.size;
        double scale = mainRenderBox.size.height / (chartSize.height + 40);

        // 计算居中所需的偏移量
        double dx = (mainRenderBox.size.width - chartSize.width) / 2;
        double dy = (mainRenderBox.size.height - chartSize.height - 40) / 2;
        
        // 应用变换以水平居中显示
        transformationController.value = Matrix4.identity()
          ..translate(dx > 0 ? dx : 0, dy > 0 ? dy : 0)
          ..scale(scale);

        if(mounted) setState(() {});
      }
    });
  }
  
  /// 解析句法树字符串并构建图形
  void _parseConstituencyTree(String parseString) {
    // 清空之前的数据
    nodeMap.clear();
    nodeLabelMap.clear();
    nodeIdCounter = 0;
    
    // 预处理字符串，移除换行符和多余空格
    String processed = parseString
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    // 递归解析括号嵌套结构
    _parseNode(processed, null);
  }
  
  // 存储节点单词的映射
  final Map<String, String> nodeWordMap = {};
  
  /// 递归解析节点
  /// [nodeText] 当前节点的文本
  /// [parentId] 父节点ID，如果是根节点则为null
  /// 返回创建的节点ID
  String _parseNode(String nodeText, String? parentId) {
    // 移除最外层括号
    nodeText = nodeText.trim();
    if (nodeText.startsWith('(') && nodeText.endsWith(')')) {
      nodeText = nodeText.substring(1, nodeText.length - 1).trim();
    }
    
    // 提取标签
    int spaceIndex = nodeText.indexOf(' ');
    String label = spaceIndex > 0 ? nodeText.substring(0, spaceIndex) : nodeText;
    
    // 创建当前节点
    String nodeId = 'node_${nodeIdCounter++}';
    Node node = Node.Id(nodeId);
    nodeMap[nodeId] = node;
    nodeLabelMap[nodeId] = label;
    
    // 如果有父节点，添加边
    if (parentId != null) {
      graph.addEdge(nodeMap[parentId]!, node);
    }
    
    // 如果没有空格，说明是叶子节点
    if (spaceIndex <= 0) {
      return nodeId;
    }
    
    // 解析子节点
    String childrenText = nodeText.substring(spaceIndex + 1).trim();
    
    // 如果子节点文本不包含括号，则是叶子节点的值
    if (!childrenText.contains('(')) {
      // 存储叶子节点的单词
      nodeWordMap[nodeId] = childrenText;
      return nodeId;
    }
    
    // 分析括号嵌套结构，提取子节点
    List<String> childNodes = _extractChildNodes(childrenText);
    
    // 递归处理每个子节点
    for (String childNode in childNodes) {
      _parseNode(childNode, nodeId);
    }
    
    return nodeId;
  }
  
  /// 提取括号嵌套结构中的子节点
  List<String> _extractChildNodes(String text) {
    List<String> nodes = [];
    int depth = 0;
    int startIndex = -1;
    
    for (int i = 0; i < text.length; i++) {
      if (text[i] == '(') {
        depth++;
        if (depth == 1) {
          startIndex = i;
        }
      } else if (text[i] == ')') {
        depth--;
        if (depth == 0 && startIndex != -1) {
          nodes.add(text.substring(startIndex, i + 1));
          startIndex = -1;
        }
      }
    }
    
    return nodes;
  }
  


  bool _isLeafNode(String nodeId) {
    // 获取该节点在图中的实例
    Node? node = nodeMap[nodeId];
    if (node == null) return true;
    
    // 检查该节点是否有子节点
    return !graph.edges.any((edge) => edge.source == node);
  }

  double calculateTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  /// 构建节点小部件
  Widget nodeWidget(String id) {
    // 获取节点标签
    String label = nodeLabelMap[id] ?? '';

    LanguageConfigColorModel? colorConfig = StatusUtils.getConfigColor(widget.colorConfigs, label);
    Color? labelColorTextColor = colorConfig?.color?.textColor;
    if(label.toUpperCase() == "ROOT"){
      labelColorTextColor = AppTheme.cTextBrand.color;
    }
    // 获取节点单词（如果有）
    String? word = nodeWordMap[id];
    
    bool isLeafNode = _isLeafNode(id);

    TextStyle labelStyle = TextStyle(
      fontSize: 12.wMin,
      color: AppTheme.cTextPrimary,
      fontWeight: FontWeight.w500,
    );

    double width = calculateTextWidth(label, labelStyle);
    
    if (isLeafNode) {
      // 终端节点（词性标注 + 单词）样式
      return TapScaleWidget(
        onTap: () {
          if(word == null) return;
          widget.onWord?.call(word);
        },
        sclae: 1,
        child: Container(
          color: Colors.transparent,
          child: Row(
            spacing: 4.wMin,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                decoration: BoxDecoration(
                  color: colorConfig?.color?.bgColor,
                  borderRadius: BorderRadius.circular(4.wMin),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.wMin,
                    fontWeight: FontWeight.w400,
                    color: labelColorTextColor,
                  ),
                ),
              ),
              Text(
                word??"",
                style: labelStyle,
              ),
            ],
          ),
        ),
      );
    } else {
      // 非终端节点（短语结构）样式
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Visibility(
            visible: widget.graphShowDetils,
            child: Positioned(
              left: -width - 5.wMin,
              child: Text(
                label,
                style: labelStyle,
              ),
            ),
          ),
          Container(
            width: 6.wMin,
            height: 6.wMin,
            decoration: BoxDecoration(
              color: labelColorTextColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: transformationController,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 1,
      maxScale: 5,
      alignment: Alignment.center,
      child: Container(
        key: chartKey,
        padding: EdgeInsets.only(left: 50.wMin),
        child: GraphView(
          graph: graph,
          algorithm: BuchheimWalkerAlgorithm(builder, CurvedEdgeRenderer(builder)),
          animated: false,
          paint: Paint()
            ..color = AppTheme.cBorderSecondary
            ..strokeWidth = 1.wMin
            ..style = PaintingStyle.stroke,
          builder: (Node node) {
            var id = node.key?.value as String;
            return nodeWidget(id);
          },
        ),
      ),
    );
  }
}

/// 自定义曲线边渲染器
class CurvedEdgeRenderer extends EdgeRenderer {
  final BuchheimWalkerConfiguration builder;

  CurvedEdgeRenderer(this.builder);

  @override
  void renderEdge(Canvas canvas, Edge edge, Paint paint) {
    final edgePaint = (edge.paint ?? paint)..style = PaintingStyle.stroke;
    final source = edge.source;
    final destination = edge.destination;

    final sourcePosition = getNodePosition(source);
    final destinationPosition = getNodePosition(destination);

    // 沿用旧逻辑，以节点左侧/中线作为连线锚点。
    final sourceCenter = Offset(
      sourcePosition.dx,
      sourcePosition.dy + source.height / 2,
    );

    final destCenter = Offset(
      destinationPosition.dx,
      destinationPosition.dy + destination.height / 2,
    );

    final isOnSamePlane = _isOnSamePlane(sourceCenter, destCenter);

    if (isOnSamePlane) {
      canvas.drawLine(sourceCenter, destCenter, edgePaint);
      return;
    }

    final controlPoints = _calculateCubicControlPoints(sourceCenter, destCenter);
    final path = Path()
      ..moveTo(sourceCenter.dx, sourceCenter.dy)
      ..cubicTo(
        controlPoints[0].dx,
        controlPoints[0].dy,
        controlPoints[1].dx,
        controlPoints[1].dy,
        destCenter.dx,
        destCenter.dy,
      );

    canvas.drawPath(path, edgePaint);
  }

  // 判断两个点是否在同一平面上
  bool _isOnSamePlane(Offset source, Offset destination) {
    // 水平布局时，判断y坐标是否接近
    if (builder.orientation == BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT) {
      return (source.dy - destination.dy).abs() < 10.0; // 允许10像素的误差
    } else {
      // 垂直布局时，判断x坐标是否接近
      return (source.dx - destination.dx).abs() < 10.0; // 允许10像素的误差
    }
  }

  // 计算三次贝塞尔曲线的控制点
  List<Offset> _calculateCubicControlPoints(Offset source, Offset destination) {
    List<Offset> controlPoints = List.filled(2, Offset.zero);

    if (builder.orientation == BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT) {
      // 水平布局（从左到右）
      final dx = (destination.dx - source.dx) / 2;

      // 第一个控制点：从源点向右延伸1/3距离
      controlPoints[0] = Offset(source.dx + dx, source.dy);

      // 第二个控制点：从目标点向左延伸1/3距离
      controlPoints[1] = Offset(destination.dx - dx, destination.dy);
    } else {
      // 垂直布局（从上到下）
      final dy = (destination.dy - source.dy) / 2;

      // 第一个控制点：从源点向下延伸1/3距离
      controlPoints[0] = Offset(source.dx, source.dy + dy);

      // 第二个控制点：从目标点向上延伸1/3距离
      controlPoints[1] = Offset(destination.dx, destination.dy - dy);
    }

    return controlPoints;
  }
}
