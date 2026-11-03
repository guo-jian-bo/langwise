import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'etymology_canvas_card_widget.dart';
import 'etymology_canvas_text_card_widget.dart';

class EtymologyCanvasController {
  void Function(EdgeInsets insets)? _fitToCanvasCallback;
  void Function(String nodeId, int? contentId, int? semanticId)? _focusToNodeCallback;

  /// 让画布回到初始的适应视图。
  void fitToCanvas({EdgeInsets insets = EdgeInsets.zero}) {
    _fitToCanvasCallback?.call(insets);
  }

  /// 聚焦到指定节点。
  void focusToNode(String nodeId, {int? contentId, int? semanticId}) {
    if (nodeId.trim().isEmpty) return;
    _focusToNodeCallback?.call(nodeId, contentId, semanticId);
  }

  /// 绑定当前画布实例的适应方法。
  void _attach({
    required void Function(EdgeInsets insets) fitToCanvas,
      required void Function(String nodeId, int? contentId, int? semanticId) focusToNode,
  }) {
    _fitToCanvasCallback = fitToCanvas;
    _focusToNodeCallback = focusToNode;
  }

  /// 解除当前画布实例的适应方法绑定。
  void _detach() {
    _fitToCanvasCallback = null;
    _focusToNodeCallback = null;
  }
}

class EtymologyCanvasWidget extends StatefulWidget {
  /// 词源记忆画布组件
  const EtymologyCanvasWidget({
    super.key,
    this.controller,
    required this.tree,
    this.activeNodeId,
    this.activeContentId,
    this.activeSemanticId,
    this.contentText = '',
    this.onInteractionStart,
  });

  /// 外部画布控制器，可用于恢复到初始适应视图。
  final EtymologyCanvasController? controller;
  final CardContentEtymologyTree tree;
  final String? activeNodeId;
  final int? activeContentId;
  final int? activeSemanticId;
  final String contentText;
  final VoidCallback? onInteractionStart;

  @override
  State<EtymologyCanvasWidget> createState() => _EtymologyCanvasWidgetState();
}

class _EtymologyCanvasWidgetState extends State<EtymologyCanvasWidget> {
  /// 画布缩放与平移控制器。
  final TransformationController transformationController = TransformationController();

  /// 画布根节点 key，用于换算连接线坐标。
  final GlobalKey canvasKey = GlobalKey();

  /// 是否已经排队执行一次节点测量，避免重复提交 post frame 回调。
  bool isMeasureScheduled = false;

  /// 当前所有节点的真实渲染尺寸与锚点信息。
  Map<String, _EtymologyCanvasNodeMetrics> nodeMetrics = <String, _EtymologyCanvasNodeMetrics>{};

  /// 最近一次用于适应画布的视口尺寸。
  Size? lastFittedViewportSize;

  /// 最近一次用于适应画布的画布尺寸。
  Size? lastFittedCanvasSize;

  /// 当前最新的画布布局结果，供控制器复位时复用。
  _EtymologyCanvasLayout? currentLayout;

  /// 当前最新的视口尺寸，供控制器复位时复用。
  Size? currentViewportSize;

  /// 最近一次自动定位的聚焦目标，避免重复回中。
  String? lastFocusedTargetId;

  /// 当外部在画布完成布局前发起适应请求时，先暂存 inset，等布局完成后再应用。
  EdgeInsets? pendingFitInsets;

  /// 当外部在画布完成布局前发起聚焦请求时，先暂存节点 id，等布局完成后再应用。
  _EtymologyCanvasFocusTarget? pendingFocusTarget;

  List<_EtymologyCanvasNodeEntry> nodeEntries = <_EtymologyCanvasNodeEntry>[];
  Map<String, _EtymologyCanvasNodeEntry> nodeEntryMap = <String, _EtymologyCanvasNodeEntry>{};
  Map<String, List<String>> childNodeMap = <String, List<String>>{};
  Map<String, int> nodeDepthMap = <String, int>{};
  List<_EtymologyCanvasConnection> connections = <_EtymologyCanvasConnection>[];
  String? rootNodeId;

  @override
  void initState() {
    super.initState();
      widget.controller?._attach(
        fitToCanvas: _fitToCanvas,
        focusToNode: _requestFocusToNode,
      );
    _resetCanvasEntries();
  }

  @override
  void didUpdateWidget(covariant EtymologyCanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
        widget.controller?._attach(
          fitToCanvas: _fitToCanvas,
          focusToNode: _requestFocusToNode,
        );
    }
    if (oldWidget.tree != widget.tree || oldWidget.contentText != widget.contentText) {
      _resetCanvasEntries();
    }
      if (oldWidget.activeNodeId != widget.activeNodeId ||
          oldWidget.activeContentId != widget.activeContentId ||
          oldWidget.activeSemanticId != widget.activeSemanticId ||
          oldWidget.tree != widget.tree) {
        lastFocusedTargetId = null;
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _scheduleNodeMeasure();
        final _EtymologyCanvasLayout? layout = _buildCanvasLayout(constraints);
        if (layout == null) return _buildMeasureStage();
        currentLayout = layout;
        currentViewportSize = _resolveViewportSize(constraints);
        final double minScale = _buildFitScale(currentViewportSize!, layout.size);
          _applyPendingFitToCanvasIfNeeded(layout, constraints);
          _applyPendingFocusToNodeIfNeeded(layout, constraints);
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: InteractiveViewer(
            transformationController: transformationController,
            onInteractionStart: (_) => widget.onInteractionStart?.call(),
            constrained: false,
            maxScale: 4,
            minScale: minScale,
            boundaryMargin: _buildBoundaryMargin(constraints, layout.size),
            child: _buildCanvasStage(layout),
          ),
        );
      },
    );
  }

  void _resetCanvasEntries() {
    rootNodeId = _findRootNodeId();
    childNodeMap = _buildChildNodeMap();
    nodeDepthMap = _buildNodeDepthMap();
    connections = _buildConnections();
    nodeEntries = _buildCanvasNodeEntries();
    nodeEntryMap = <String, _EtymologyCanvasNodeEntry>{
      for (final _EtymologyCanvasNodeEntry entry in nodeEntries) entry.id: entry,
    };
    nodeMetrics = <String, _EtymologyCanvasNodeMetrics>{};
    lastFittedViewportSize = null;
    lastFittedCanvasSize = null;
    currentLayout = null;
    currentViewportSize = null;
      lastFocusedTargetId = null;
  }

  Widget _buildMeasureStage() {
    return IgnorePointer(
      child: Opacity(
        opacity: 0,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: nodeEntries.map(_buildNodeMeasureWidget).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCanvasStage(_EtymologyCanvasLayout layout) {
    return SizedBox(
      key: canvasKey,
      width: layout.size.width,
      height: layout.size.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _EtymologyCanvasTreePainter(
                  canvasKey: canvasKey,
                  nodeEntryMap: nodeEntryMap,
                  connections: connections,
                ),
              ),
            ),
          ),
          ...nodeEntries.map(
            (entry) => _buildNodePositionedWidget(entry, layout.positions[entry.id]!),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeMeasureWidget(_EtymologyCanvasNodeEntry entry) {
    return SizedBox(key: entry.wrapperKey, child: entry.buildChild());
  }

  Widget _buildNodePositionedWidget(_EtymologyCanvasNodeEntry entry, Offset position) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: SizedBox(key: entry.wrapperKey, child: entry.buildChild()),
    );
  }

  _EtymologyCanvasLayout? _buildCanvasLayout(BoxConstraints constraints) {
    final String? rootId = rootNodeId;
    if (rootId == null || !_hasAllNodeMetrics()) return null;
    final Map<String, double> subtreeWidths = <String, double>{};
    final Map<String, Offset> localPositions = <String, Offset>{};
    final Map<int, double> depthTopMap = _buildDepthTopMap();

    double resolveSubtreeWidth(String nodeId) {
      final double nodeWidth = nodeMetrics[nodeId]!.size.width;
      final List<String> childNodeIds = childNodeMap[nodeId] ?? <String>[];
      if (childNodeIds.isEmpty) {
        subtreeWidths[nodeId] = nodeWidth;
        return nodeWidth;
      }
      final List<double> childWidths = childNodeIds.map(resolveSubtreeWidth).toList();
      final double childGap = _buildHorizontalGap(childNodeIds);
      final double totalChildWidth =
            childWidths.fold<double>(0.0, (double value, double item) => value + item) +
              math.max(childNodeIds.length - 1, 0) * childGap;
      final double subtreeWidth = math.max(nodeWidth, totalChildWidth);
      subtreeWidths[nodeId] = subtreeWidth;
      return subtreeWidth;
    }

    void assignPosition(String nodeId, double startX) {
      final double subtreeWidth = subtreeWidths[nodeId]!;
      final Size nodeSize = nodeMetrics[nodeId]!.size;
      final int depth = nodeDepthMap[nodeId] ?? 0;
      final double top = depthTopMap[depth] ?? 0;
      localPositions[nodeId] = Offset(startX + (subtreeWidth - nodeSize.width) / 2, top);
      final List<String> childNodeIds = childNodeMap[nodeId] ?? <String>[];
      if (childNodeIds.isEmpty) return;
      final double childGap = _buildHorizontalGap(childNodeIds);
      final double totalChildWidth = childNodeIds
              .map((String childNodeId) => subtreeWidths[childNodeId]!)
                .fold<double>(0.0, (double value, double item) => value + item) +
          math.max(childNodeIds.length - 1, 0) * childGap;
      double childStartX = startX + (subtreeWidth - totalChildWidth) / 2;
      for (final String childNodeId in childNodeIds) {
        assignPosition(childNodeId, childStartX);
        childStartX += subtreeWidths[childNodeId]! + childGap;
      }
    }

      resolveSubtreeWidth(rootId);
    assignPosition(rootId, 0);

    double minLeft = double.infinity;
    double maxRight = double.negativeInfinity;
    double maxBottom = double.negativeInfinity;
    for (final _EtymologyCanvasNodeEntry entry in nodeEntries) {
      final Offset position = localPositions[entry.id]!;
      final Size size = nodeMetrics[entry.id]!.size;
      minLeft = math.min(minLeft, position.dx);
      maxRight = math.max(maxRight, position.dx + size.width);
      maxBottom = math.max(maxBottom, position.dy + size.height);
    }
    final double actualWidth = maxRight - minLeft;
    final double viewportWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : actualWidth;
    final double canvasWidth = math.max(actualWidth, viewportWidth);
    final double shiftX = -minLeft + (canvasWidth - actualWidth) / 2;
    final Map<String, Offset> positions = <String, Offset>{
      for (final MapEntry<String, Offset> entry in localPositions.entries)
        entry.key: Offset(entry.value.dx + shiftX, entry.value.dy),
    };
    return _EtymologyCanvasLayout(size: Size(canvasWidth, maxBottom), positions: positions);
  }

  Map<int, double> _buildDepthTopMap() {
    final Map<int, double> depthTopMap = <int, double>{0: 0};
    final List<int> depthList = nodeDepthMap.values.toSet().toList()..sort();
    for (int index = 1; index < depthList.length; index++) {
      final int previousDepth = depthList[index - 1];
      final int currentDepth = depthList[index];
      final double previousHeight = _depthMaxHeight(previousDepth);
      final double currentHeight = _depthMaxHeight(currentDepth);
      depthTopMap[currentDepth] = (depthTopMap[previousDepth] ?? 0) +
          previousHeight +
          _buildVerticalGap(
            previousDepth: previousDepth,
            currentDepth: currentDepth,
            previousHeight: previousHeight,
            currentHeight: currentHeight,
          );
    }
    return depthTopMap;
  }

  double _depthMaxHeight(int depth) {
    final List<String> nodeIds = _depthNodeIds(depth);
    if (nodeIds.isEmpty) return 0;
    return nodeIds.map((String nodeId) => nodeMetrics[nodeId]!.size.height).reduce(math.max);
  }

  List<String> _depthNodeIds(int depth) {
    final List<String> nodeIds = nodeDepthMap.entries
        .where((MapEntry<String, int> entry) => entry.value == depth)
        .map((MapEntry<String, int> entry) => entry.key)
        .toList();
    nodeIds.sort(_compareNodeId);
    return nodeIds;
  }

  double _buildVerticalGap({
    required int previousDepth,
    required int currentDepth,
    required double previousHeight,
    required double currentHeight,
  }) {
    final bool previousHasCard = _depthNodeIds(previousDepth).any(_isCardNodeId);
    final bool currentHasCard = _depthNodeIds(currentDepth).any(_isCardNodeId);
    final double base = math.max(previousHeight, currentHeight);
    if (previousDepth == 0 && !currentHasCard) {
      return base * 0.45;
    }
    if (previousDepth == 0 && currentHasCard) {
      return base * 0.24;
    }
    if (previousHasCard || currentHasCard) {
      return base * 0.14;
    }
    return base * 0.26;
  }

  double _buildHorizontalGap(List<String> nodeIds) {
    if (nodeIds.length < 2) return 0;
    final double averageWidth = nodeIds
            .map((String nodeId) => nodeMetrics[nodeId]!.size.width)
            .reduce((double a, double b) => a + b) /
        nodeIds.length;
    return averageWidth * 0.12;
  }

  Matrix4 _buildFitMatrix(
    Size viewportSize,
    Size canvasSize, {
    EdgeInsets insets = EdgeInsets.zero,
  }) {
    final double scale = _buildFitScale(viewportSize, canvasSize, insets: insets);
    final double availableWidth = math.max(viewportSize.width - insets.left - insets.right, 1);
    final double availableHeight = math.max(viewportSize.height - insets.top - insets.bottom, 1);
    final double translateX = insets.left + (availableWidth - canvasSize.width * scale) / 2;
    final double translateY = insets.top + (availableHeight - canvasSize.height * scale) / 2;
    return Matrix4.identity()
      ..translateByDouble(translateX, translateY, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  double _buildFitScale(
    Size viewportSize,
    Size canvasSize, {
    EdgeInsets insets = EdgeInsets.zero,
  }) {
    final double padding = math.min(viewportSize.width, viewportSize.height) * 0.04;
    final double availableWidth =
        math.max(viewportSize.width - insets.left - insets.right - padding * 2, 1);
    final double availableHeight =
        math.max(viewportSize.height - insets.top - insets.bottom - padding * 2, 1);
    return math.min(availableWidth / canvasSize.width, availableHeight / canvasSize.height)
        .clamp(0.05, 4.0);
  }

  void _applyPendingFitToCanvasIfNeeded(
    _EtymologyCanvasLayout layout,
    BoxConstraints constraints,
  ) {
    final EdgeInsets? fitInsets = pendingFitInsets;
    if (fitInsets == null) return;
    pendingFitInsets = null;
    final Size viewportSize = _resolveViewportSize(constraints);
    _applyFitToCanvas(layout.size, viewportSize, insets: fitInsets);
  }

  void _applyFitToCanvas(
    Size canvasSize,
    Size viewportSize, {
    EdgeInsets insets = EdgeInsets.zero,
  }) {
    transformationController.value = _buildFitMatrix(
      viewportSize,
      canvasSize,
      insets: insets,
    );
    lastFittedViewportSize = viewportSize;
    lastFittedCanvasSize = canvasSize;
  }

  void _fitToCanvas(EdgeInsets insets) {
    final _EtymologyCanvasLayout? layout = currentLayout;
    final Size? viewportSize = currentViewportSize;
    if (layout == null || viewportSize == null) {
      pendingFitInsets = insets;
      return;
    }
    _applyFitToCanvas(layout.size, viewportSize, insets: insets);
  }

  void _requestFocusToNode(String nodeId, int? contentId, int? semanticId) {
    final String normalizedNodeId = nodeId.trim();
    if (normalizedNodeId.isEmpty) return;
    pendingFocusTarget = _EtymologyCanvasFocusTarget(
      nodeId: normalizedNodeId,
      contentId: contentId,
      semanticId: semanticId,
    );
    lastFocusedTargetId = null;
    if (mounted) setState(() {});
  }

  void _applyPendingFocusToNodeIfNeeded(
    _EtymologyCanvasLayout layout,
    BoxConstraints constraints,
  ) {
    final _EtymologyCanvasFocusTarget? target = pendingFocusTarget;
    final String targetId = target?.targetId ?? '';
    if (target == null || targetId.isEmpty || lastFocusedTargetId == targetId) return;
    final Size viewportSize = _resolveViewportSize(constraints);
    _focusToNode(target, layout, viewportSize);
    pendingFocusTarget = null;
  }

  void _focusToNode(
    _EtymologyCanvasFocusTarget target,
    _EtymologyCanvasLayout layout,
    Size viewportSize,
  ) {
    final _EtymologyCanvasNodeMetrics? metrics = nodeMetrics[target.nodeId];
    final Offset? position = layout.positions[target.nodeId];
    if (metrics == null || position == null) return;
    final Rect anchorRect =
        metrics.focusAnchorRect ?? metrics.anchorRect ?? (Offset.zero & metrics.size);
    final Offset nodeCenter = position + anchorRect.center;
    final double fitScale = _buildFitScale(viewportSize, layout.size);
    final double currentScale = transformationController.value.getMaxScaleOnAxis();
    final double scale = currentScale > fitScale ? currentScale : fitScale;
    final double translateX = viewportSize.width / 2 - nodeCenter.dx * scale;
    final double translateY = viewportSize.height / 2 - nodeCenter.dy * scale;
    transformationController.value = Matrix4.identity()
      ..translateByDouble(translateX, translateY, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
    lastFocusedTargetId = target.targetId;
  }

  Size _resolveViewportSize(BoxConstraints constraints) {
    if (constraints.maxWidth.isFinite && constraints.maxHeight.isFinite) {
      return Size(constraints.maxWidth, constraints.maxHeight);
    }
    return MediaQuery.sizeOf(context);
  }

  EdgeInsets _buildBoundaryMargin(BoxConstraints constraints, Size canvasSize) {
    final Size viewportSize = _resolveViewportSize(constraints);
    final double viewportLongestSide = math.max(viewportSize.width, viewportSize.height);
    final double canvasLongestSide = math.max(canvasSize.width, canvasSize.height);
    final double freeDragMargin = math.max(viewportLongestSide, canvasLongestSide) * 4;
    return EdgeInsets.all(freeDragMargin);
  }

  bool _hasAllNodeMetrics() {
    return nodeMetrics.length == nodeEntries.length;
  }

  void _scheduleNodeMeasure() {
    if (isMeasureScheduled) return;
    isMeasureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isMeasureScheduled = false;
      if (!mounted) return;
      final Map<String, _EtymologyCanvasNodeMetrics> latestMetrics = <String, _EtymologyCanvasNodeMetrics>{};
      for (final _EtymologyCanvasNodeEntry entry in nodeEntries) {
        final _EtymologyCanvasNodeMetrics? metrics = _measureNode(entry);
        if (metrics != null) latestMetrics[entry.id] = metrics;
      }
      if (_didNodeMetricsChange(latestMetrics)) {
        setState(() => nodeMetrics = latestMetrics);
      }
    });
  }

  _EtymologyCanvasNodeMetrics? _measureNode(_EtymologyCanvasNodeEntry entry) {
    final RenderBox? wrapperBox = entry.wrapperKey.currentContext?.findRenderObject() as RenderBox?;
    if (wrapperBox == null) return null;
    return _EtymologyCanvasNodeMetrics(
      size: wrapperBox.size,
      anchorRect: _measureLocalAnchorRect(entry.wrapperKey, entry.contentKey),
      focusAnchorRect: _measureLocalAnchorRect(entry.wrapperKey, entry.focusKey),
    );
  }

  Rect? _measureLocalAnchorRect(GlobalKey wrapperKey, GlobalKey? contentKey) {
    if (contentKey == null) return null;
    final RenderBox? wrapperBox = wrapperKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? contentBox = contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (wrapperBox == null || contentBox == null) return null;
    final Offset topLeft = wrapperBox.globalToLocal(contentBox.localToGlobal(Offset.zero));
    return topLeft & contentBox.size;
  }

  bool _didNodeMetricsChange(Map<String, _EtymologyCanvasNodeMetrics> latestMetrics) {
    if (latestMetrics.length != nodeMetrics.length) return true;
    for (final MapEntry<String, _EtymologyCanvasNodeMetrics> entry in latestMetrics.entries) {
      final _EtymologyCanvasNodeMetrics? currentMetrics = nodeMetrics[entry.key];
      if (currentMetrics == null || currentMetrics != entry.value) return true;
    }
    return false;
  }

  List<_EtymologyCanvasNodeEntry> _buildCanvasNodeEntries() {
    final List<_EtymologyCanvasNodeEntry> entries = <_EtymologyCanvasNodeEntry>[];
    final List<CardContentEtymologyNode> nodes = _sortedNodes();
    for (final CardContentEtymologyNode node in nodes) {
      final String nodeId = node.nodeId ?? '';
      if (nodeId.isEmpty) continue;
      if (nodeId == rootNodeId) {
        entries.add(_buildRootNodeEntry(node));
        continue;
      }
      if (_isCardNode(node)) {
        entries.add(_buildCardNodeEntry(node));
        continue;
      }
      entries.add(_buildTextNodeEntry(node));
    }
    return entries;
  }

  _EtymologyCanvasNodeEntry _buildRootNodeEntry(CardContentEtymologyNode node) {
    final GlobalKey wrapperKey = GlobalKey();
    final GlobalKey contentKey = GlobalKey();
    return _EtymologyCanvasNodeEntry(
      id: node.nodeId ?? '',
      wrapperKey: wrapperKey,
      contentKey: contentKey,
      buildChild: () => EtymologyCanvasRootWidget(
        contentKey: contentKey,
        contentText: widget.contentText,
        node: node,
        isActive: _isNodeInActivePath(node.nodeId),
      ),
    );
  }

  _EtymologyCanvasNodeEntry _buildTextNodeEntry(CardContentEtymologyNode node) {
    final GlobalKey wrapperKey = GlobalKey();
    final GlobalKey contentKey = GlobalKey();
    return _EtymologyCanvasNodeEntry(
      id: node.nodeId ?? '',
      wrapperKey: wrapperKey,
      contentKey: contentKey,
      buildChild: () => EtymologyCanvasTextCardWidget(
        contentKey: contentKey,
        node: node,
        isActive: _isNodeInActivePath(node.nodeId),
      ),
    );
  }

  _EtymologyCanvasNodeEntry _buildCardNodeEntry(CardContentEtymologyNode node) {
    final GlobalKey wrapperKey = GlobalKey();
    final GlobalKey contentKey = GlobalKey();
    final GlobalKey focusKey = GlobalKey();
    return _EtymologyCanvasNodeEntry(
      id: node.nodeId ?? '',
      wrapperKey: wrapperKey,
      contentKey: contentKey,
      focusKey: focusKey,
      buildChild: () => EtymologyCanvasCardWidget(
        contentKey: contentKey,
        focusCardKey: focusKey,
        node: node,
        isActive: (widget.activeNodeId ?? '') == (node.nodeId ?? ''),
        activeContentId: widget.activeContentId,
        activeSemanticId: widget.activeSemanticId,
      ),
    );
  }

  String? _findRootNodeId() {
    final List<CardContentEtymologyNode> nodes = _treeNodes();
    if (nodes.isEmpty) return null;
    for (final CardContentEtymologyNode node in nodes) {
      final String nodeId = node.nodeId ?? '';
      if (_findParentNodeId(nodeId).isEmpty) {
        return nodeId;
      }
    }
    return null;
  }

  Map<String, List<String>> _buildChildNodeMap() {
    final Map<String, List<String>> map = <String, List<String>>{};
    for (final CardContentEtymologyNode node in _treeNodes()) {
      final String nodeId = node.nodeId ?? '';
      if (nodeId.isEmpty) continue;
      map.putIfAbsent(nodeId, () => <String>[]);
      final String parentNodeId = _findParentNodeId(nodeId);
      if (parentNodeId.isEmpty) continue;
      map.putIfAbsent(parentNodeId, () => <String>[]).add(nodeId);
    }
    for (final List<String> childNodeIds in map.values) {
      childNodeIds.sort(_compareNodeId);
    }
    return map;
  }

  Map<String, int> _buildNodeDepthMap() {
    final Map<String, int> map = <String, int>{};
    for (final CardContentEtymologyNode node in _treeNodes()) {
      final String nodeId = node.nodeId ?? '';
      if (nodeId.isEmpty) continue;
      map[nodeId] = nodeId.split('.').length - 1;
    }
    return map;
  }

  List<_EtymologyCanvasConnection> _buildConnections() {
    final List<_EtymologyCanvasConnection> values = <_EtymologyCanvasConnection>[];
    for (final MapEntry<String, List<String>> entry in childNodeMap.entries) {
      for (final String childNodeId in entry.value) {
        values.add(_EtymologyCanvasConnection(startId: entry.key, endId: childNodeId));
      }
    }
    return values;
  }

  List<CardContentEtymologyNode> _treeNodes() {
    return widget.tree.nodes?.whereType<CardContentEtymologyNode>().toList() ?? <CardContentEtymologyNode>[];
  }

  List<CardContentEtymologyNode> _sortedNodes() {
    final List<CardContentEtymologyNode> nodes = _treeNodes();
    nodes.sort((CardContentEtymologyNode a, CardContentEtymologyNode b) {
      return _compareNodeId(a.nodeId ?? '', b.nodeId ?? '');
    });
    return nodes;
  }

  bool _isCardNode(CardContentEtymologyNode node) {
    return node.senseCards?.whereType<ElementsCardEntityDatas>().isNotEmpty ?? false;
  }

  bool _isCardNodeId(String nodeId) {
    final CardContentEtymologyNode? node = _findNode(nodeId);
    if (node == null) return false;
    return _isCardNode(node);
  }

  CardContentEtymologyNode? _findNode(String nodeId) {
    for (final CardContentEtymologyNode node in _treeNodes()) {
      if (node.nodeId == nodeId) return node;
    }
    return null;
  }

  bool _isNodeInActivePath(String? nodeId) {
    final String currentNodeId = (widget.activeNodeId ?? '').trim();
    final String targetNodeId = (nodeId ?? '').trim();
    if (currentNodeId.isEmpty || targetNodeId.isEmpty) return false;
    return currentNodeId == targetNodeId || currentNodeId.startsWith('$targetNodeId.');
  }

  String _findParentNodeId(String nodeId) {
    final int lastDotIndex = nodeId.lastIndexOf('.');
    if (lastDotIndex <= 0) return '';
    return nodeId.substring(0, lastDotIndex);
  }

  int _compareNodeId(String a, String b) {
    final List<int> aParts = a.split('.').where((String item) => item.isNotEmpty).map(int.parse).toList();
    final List<int> bParts = b.split('.').where((String item) => item.isNotEmpty).map(int.parse).toList();
    final int minLength = math.min(aParts.length, bParts.length);
    for (int index = 0; index < minLength; index++) {
      final int compare = aParts[index].compareTo(bParts[index]);
      if (compare != 0) return compare;
    }
    return aParts.length.compareTo(bParts.length);
  }
}

class _EtymologyCanvasNodeEntry {
  const _EtymologyCanvasNodeEntry({
    required this.id,
    required this.wrapperKey,
    this.contentKey,
    this.focusKey,
    required this.buildChild,
  });

  final String id;
  final GlobalKey wrapperKey;
  final GlobalKey? contentKey;
  final GlobalKey? focusKey;
  final Widget Function() buildChild;
}

class _EtymologyCanvasNodeMetrics {
  const _EtymologyCanvasNodeMetrics({
    required this.size,
    this.anchorRect,
    this.focusAnchorRect,
  });

  final Size size;
  final Rect? anchorRect;
  final Rect? focusAnchorRect;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _EtymologyCanvasNodeMetrics &&
        other.size == size &&
          other.anchorRect == anchorRect &&
          other.focusAnchorRect == focusAnchorRect;
  }

  @override
  int get hashCode => Object.hash(size, anchorRect, focusAnchorRect);
}

class _EtymologyCanvasFocusTarget {
  const _EtymologyCanvasFocusTarget({
    required this.nodeId,
    this.contentId,
    this.semanticId,
  });

  final String nodeId;
  final int? contentId;
  final int? semanticId;

  String get targetId => '$nodeId#${contentId ?? 0}:${semanticId ?? 0}';
}

class _EtymologyCanvasLayout {
  const _EtymologyCanvasLayout({required this.size, required this.positions});

  final Size size;
  final Map<String, Offset> positions;
}

class _EtymologyCanvasConnection {
  const _EtymologyCanvasConnection({required this.startId, required this.endId});

  final String startId;
  final String endId;
}

class _EtymologyCanvasTreePainter extends CustomPainter {
  const _EtymologyCanvasTreePainter({
    required this.canvasKey,
    required this.nodeEntryMap,
    required this.connections,
  });

  final GlobalKey canvasKey;
  final Map<String, _EtymologyCanvasNodeEntry> nodeEntryMap;
  final List<_EtymologyCanvasConnection> connections;

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox? canvasBox = canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (canvasBox == null) return;
    final Paint linePaint = Paint()
      ..color = AppTheme.cSurfaceWarning.color.withValues(alpha: 0.55)
      ..strokeWidth = 3.wMin
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final _EtymologyCanvasConnection connection in connections) {
      final _EtymologyCanvasNodeEntry? startEntry = nodeEntryMap[connection.startId];
      final _EtymologyCanvasNodeEntry? endEntry = nodeEntryMap[connection.endId];
      if (startEntry == null || endEntry == null) continue;
      final Offset? start = _resolveAnchorPoint(canvasBox, startEntry.wrapperKey, startEntry.contentKey, true);
      final Offset? end = _resolveAnchorPoint(canvasBox, endEntry.wrapperKey, endEntry.contentKey, false);
      if (start == null || end == null) continue;
      final double controlY = start.dy + (end.dy - start.dy) * 0.45;
      final Path path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(start.dx, controlY, end.dx, controlY, end.dx, end.dy);
      canvas.drawPath(path, linePaint);
    }
  }

  Offset? _resolveAnchorPoint(
    RenderBox canvasBox,
    GlobalKey wrapperKey,
    GlobalKey? contentKey,
    bool useBottomPoint,
  ) {
    final RenderBox? contentBox = contentKey?.currentContext?.findRenderObject() as RenderBox?;
    if (contentBox != null) {
      final Offset localPoint = useBottomPoint
          ? Offset(contentBox.size.width / 2, contentBox.size.height)
          : Offset(contentBox.size.width / 2, 0);
      return canvasBox.globalToLocal(contentBox.localToGlobal(localPoint));
    }
    final RenderBox? wrapperBox = wrapperKey.currentContext?.findRenderObject() as RenderBox?;
    if (wrapperBox == null) return null;
    final Offset fallbackPoint = useBottomPoint
        ? Offset(wrapperBox.size.width / 2, wrapperBox.size.height)
        : Offset(wrapperBox.size.width / 2, 0);
    return canvasBox.globalToLocal(wrapperBox.localToGlobal(fallbackPoint));
  }

  @override
  bool shouldRepaint(covariant _EtymologyCanvasTreePainter oldDelegate) => true;
}
