import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SelectedContent;
import 'package:flutter/services.dart';

import 'common/widgets/widgets.dart';

/// 应用全局日志浮窗。
///
/// 该组件只负责在页面上方叠加一个轻量日志面板，不参与页面路由栈管理，
/// 以避免日志频繁刷新时拖慢整棵页面树。
class FloatingLogWindow extends StatefulWidget {
  /// 页面主体内容。
  final Widget child;

  const FloatingLogWindow({super.key, required this.child});

  @override
  State<FloatingLogWindow> createState() => _FloatingLogWindowState();
}

class _FloatingLogWindowState extends State<FloatingLogWindow> {
  /// 普通日志刷新节流时间，避免高频日志持续触发重建。
  static const Duration _logRefreshInterval = Duration(milliseconds: 120);

  /// 搜索输入防抖时间，避免每次输入都立刻筛选整份日志。
  static const Duration _searchDebounceInterval = Duration(milliseconds: 180);

  /// 面板动画时长。
  static const Duration _panelAnimationDuration = Duration(milliseconds: 180);

  /// 头部栏高度。
  static const double _headerHeight = 40;

  /// 折叠态面板宽度。
  static const double _collapsedWidth = 100;

  /// 展开态面板最大宽度。
  static const double _expandedWidth = 360;

  /// 最小自动跟随距离，小于该值时认为用户仍停留在底部附近。
  static const double _followLatestThreshold = 48;

  /// 是否显示日志浮窗。
  bool _showLogWindow = true;

  /// 是否处于展开态。
  bool _expanded = false;

  /// 是否铺满当前可用区域。
  bool _fill = false;

  /// 浮窗透明度，鼠标悬浮时会提高。
  double _opacity = 0.72;

  /// 当前搜索关键字。
  String _searchKeyword = '';

  /// 面板停靠位置，0=左上角 1=左下角 2=右下角 3=右上角。
  int _logPos = 3;

  /// 文本是否正在被选择，用于暂停刷新避免选区丢失。
  bool _hasActiveTextSelection = false;

  /// 选择文本期间是否积压了待刷新日志。
  bool _hasPendingLogRefresh = false;

  /// 是否自动跟随最新日志滚动到底部。
  bool _shouldAutoScrollToLatest = true;

  /// 日志滚动控制器。
  ///
  /// 日志浮窗不需要把滚动位置写入 PageStorage，关闭该能力可以避免
  /// 选中文本时在保存滚动偏移量阶段触发额外异常。
  final ScrollController _logScrollController = ScrollController(keepScrollOffset: false);

  /// 搜索输入控制器，用于在收起面板时清空输入框。
  final TextEditingController _searchController = TextEditingController();

  /// 日志刷新定时器。
  Timer? _refreshTimer;

  /// 搜索防抖定时器。
  Timer? _searchDebounceTimer;

  /// 当前可见日志列表。
  List<String> _visibleLogs = const [];

  /// 当前可见日志拼接后的大文本，用于单个可选文本渲染。
  String _visibleLogText = '';

  /// 最近一次筛选对应的日志版本。
  int _lastVisibleLogVersion = -1;

  /// 最近一次筛选对应的关键字。
  String _lastVisibleKeyword = '';

  /// 全局日志管理器。
  final LogManager _logManager = LogManager();

  /// 当前激活的滚动位置。
  ScrollPosition? get _activeLogScrollPosition {
    if (!_logScrollController.hasClients) return null;
    final positions = _logScrollController.positions;
    if (positions.isEmpty) return null;
    return positions.last;
  }

  @override
  void initState() {
    super.initState();
    _logManager.addListener(_handleLogManagerUpdated);
    _logScrollController.addListener(_handleLogScroll);
    _rebuildVisibleLogs(force: true);
  }

  @override
  void dispose() {
    _logManager.removeListener(_handleLogManagerUpdated);
    _logScrollController.removeListener(_handleLogScroll);
    _logScrollController.dispose();
    _searchController.dispose();
    _refreshTimer?.cancel();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  /// 处理日志源更新。
  void _handleLogManagerUpdated() {
    if (!mounted) return;
    if (_hasActiveTextSelection) {
      _hasPendingLogRefresh = true;
      return;
    }
    _scheduleRefresh(forceScroll: _shouldAutoScrollToLatest);
  }

  /// 节流触发日志刷新。
  void _scheduleRefresh({bool immediate = false, bool forceScroll = false}) {
    if (!mounted) return;
    if (immediate) {
      _refreshTimer?.cancel();
      _applyRefresh(forceScroll: forceScroll);
      return;
    }
    if (_refreshTimer?.isActive ?? false) return;
    _refreshTimer = Timer(_logRefreshInterval, () {
      _applyRefresh(forceScroll: forceScroll);
    });
  }

  /// 执行一次实际刷新。
  void _applyRefresh({bool forceScroll = false}) {
    if (!mounted) return;
    _rebuildVisibleLogs(force: true);
    setState(() {});
    _scrollToLatestIfNeeded(force: forceScroll);
  }

  /// 处理日志文本选择变化，选择期间暂停刷新避免选区丢失。
  void _handleLogSelectionChanged(SelectedContent? selectedContent) {
    final hasActiveTextSelection = (selectedContent?.plainText ?? '').isNotEmpty;
    if (_hasActiveTextSelection == hasActiveTextSelection) return;
    _hasActiveTextSelection = hasActiveTextSelection;
    if (!_hasActiveTextSelection && _hasPendingLogRefresh && mounted) {
      _hasPendingLogRefresh = false;
      _scheduleRefresh(immediate: true, forceScroll: _shouldAutoScrollToLatest);
    }
  }

  /// 处理日志区指针按下，尽早暂停自动滚动避免打断文本选择。
  void _handleLogPointerDown(PointerDownEvent event) {
    _refreshTimer?.cancel();
    _shouldAutoScrollToLatest = false;
  }

  /// 根据用户滚动位置决定是否继续自动跟随最新日志。
  void _handleLogScroll() {
    final position = _activeLogScrollPosition;
    if (position == null) return;
    _shouldAutoScrollToLatest = position.maxScrollExtent - position.pixels <= _followLatestThreshold;
  }

  /// 在展开态下把日志滚动到最新位置。
  void _scrollToLatestIfNeeded({bool force = false, int retryCount = 3}) {
    if (!_expanded) return;
    if (!force && !_shouldAutoScrollToLatest) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_hasActiveTextSelection) return;
      final position = _activeLogScrollPosition;
      if (position == null) return;
      if (!position.hasContentDimensions) {
        if (retryCount > 0) {
          _scrollToLatestIfNeeded(force: force, retryCount: retryCount - 1);
        }
        return;
      }
      final maxScrollExtent = position.maxScrollExtent;
      final distanceToLatest = (maxScrollExtent - position.pixels).abs();
      if (distanceToLatest > 1) {
        if (!_logScrollController.hasClients) return;
        _logScrollController.jumpTo(maxScrollExtent);
      }
      if (retryCount > 0 && distanceToLatest > 1) {
        _scrollToLatestIfNeeded(force: force, retryCount: retryCount - 1);
      }
    });
  }

  /// 重建当前可见日志缓存。
  void _rebuildVisibleLogs({bool force = false}) {
    final keyword = _searchKeyword.trim().toLowerCase();
    if (!force && _lastVisibleLogVersion == _logManager.version && _lastVisibleKeyword == keyword) {
      return;
    }
    final logs = _logManager.logs;
    _visibleLogs = keyword.isEmpty
        ? List<String>.unmodifiable(logs)
        : List<String>.unmodifiable(
            logs.where((log) => log.toLowerCase().contains(keyword)),
          );
    _visibleLogText = _visibleLogs.join('\n');
    _lastVisibleLogVersion = _logManager.version;
    _lastVisibleKeyword = keyword;
  }

  /// 更新面板透明度。
  void _updateOpacity(double opacity) {
    if (_opacity == opacity) return;
    setState(() => _opacity = opacity);
  }

  /// 处理搜索关键字变更。
  void _handleSearchChanged(String value) {
    _searchKeyword = value;
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounceInterval, () {
      if (!mounted) return;
      _rebuildVisibleLogs(force: true);
      setState(() {});
      _shouldAutoScrollToLatest = true;
      _scrollToLatestIfNeeded(force: true);
    });
  }

  /// 切换面板的展开状态。
  void _toggleExpanded() {
    final nextExpanded = !_expanded;
    setState(() {
      _expanded = nextExpanded;
      if (!_expanded) {
        _fill = false;
        _clearSearchKeyword();
      }
      _shouldAutoScrollToLatest = true;
    });
    if (_expanded) {
      _scrollToLatestIfNeeded(force: true, retryCount: 5);
    }
  }

  /// 清空当前搜索关键字和输入框。
  void _clearSearchKeyword() {
    _searchKeyword = '';
    if (_searchController.text.isEmpty) return;
    _searchController.clear();
  }

  /// 根据停靠位置返回对齐方式。
  Alignment _resolvePanelAlignment() {
    if (_logPos == 0) return Alignment.topLeft;
    if (_logPos == 1) return Alignment.bottomLeft;
    if (_logPos == 2) return Alignment.bottomRight;
    return Alignment.topRight;
  }

  @override
  Widget build(BuildContext context) {
    if (!_showLogWindow) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: SafeArea(
            minimum: const EdgeInsets.all(8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final panelWidth = _fill
                    ? constraints.maxWidth
                    : (_expanded ? (constraints.maxWidth < _expandedWidth ? constraints.maxWidth : _expandedWidth) : _collapsedWidth);
                final panelHeight = _fill ? constraints.maxHeight : (_expanded ? constraints.maxHeight : _headerHeight);
                return Align(
                  alignment: _resolvePanelAlignment(),
                  child: MouseRegion(
                    onEnter: (_) => _updateOpacity(1.0),
                    onExit: (_) => _updateOpacity(0.32),
                    child: RepaintBoundary(
                      child: Material(
                        type: MaterialType.transparency,
                        child: AnimatedContainer(
                          duration: _panelAnimationDuration,
                          curve: Curves.easeOutCubic,
                          width: panelWidth,
                          height: panelHeight,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: _opacity),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Overlay(
                              initialEntries: [
                                OverlayEntry(
                                  canSizeOverlay: true,
                                  builder: (context) {
                                    return SizedBox.expand(
                                      child: Column(
                                        children: [
                                          _buildHeader(),
                                          if (_expanded) _buildLogContent(),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 构建浮窗头部操作栏。
  Widget _buildHeader() {
    return Container(
      height: _headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.transparent,
      child: Row(
        children: [
          GestureDetector(
            onDoubleTap: () {
              setState(() {
                _logPos = (_logPos + 1) % 4;
              });
            },
            child: const Text(
              '日志',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              if (_expanded || _fill)
                IconButton(
                  splashColor: Colors.white10,
                  highlightColor: Colors.white10,
                  icon: const Icon(
                    Icons.cleaning_services_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _logManager.clearLogs();
                    _shouldAutoScrollToLatest = true;
                  },
                ),
              if (_expanded)
                IconButton(
                  splashColor: Colors.white10,
                  highlightColor: Colors.white10,
                  icon: Icon(
                    _fill ? Icons.fullscreen_exit : Icons.fullscreen,
                    size: 18,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() => _fill = !_fill);
                    _shouldAutoScrollToLatest = true;
                    _scrollToLatestIfNeeded(force: true, retryCount: 5);
                  },
                ),
              if (_expanded)
                IconButton(
                  splashColor: Colors.white10,
                  highlightColor: Colors.white10,
                  icon: const Icon(
                    Icons.clear,
                    size: 18,
                    color: Colors.white,
                  ),
                  onLongPress: () => setState(() => _showLogWindow = false),
                  onPressed: () {},
                ),
              IconButton(
                splashColor: Colors.white10,
                highlightColor: Colors.white10,
                icon: Icon(
                  _expanded ? Icons.remove : Icons.copy,
                  size: 18,
                  color: Colors.white,
                ),
                onPressed: _toggleExpanded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建展开态日志区域。
  Widget _buildLogContent() {
    return Expanded(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              interactive: false,
              thumbColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.2)),
              trackColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
            ),
            textSelectionTheme: const TextSelectionThemeData(
              selectionColor: Colors.blue,
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: CardInputWidget(
                        hintText: "搜索日志",
                        height: 40,
                        controller: _searchController,
                        borderColor: Colors.white.withValues(alpha: 0.3),
                        fillColor: Colors.black,
                        onChanged: _handleSearchChanged,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _logManager.copyAllLogs();
                      },
                      child: const Text(
                        "复制全部",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildLogBody(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建日志文本主体。
  Widget _buildLogBody() {
    if (_visibleLogs.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            '暂无匹配日志',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            controller: _logScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _logScrollController,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Listener(
                  onPointerDown: _handleLogPointerDown,
                  child: SelectionArea(
                    onSelectionChanged: _handleLogSelectionChanged,
                    contextMenuBuilder: (context, selectableRegionState) {
                      return AdaptiveTextSelectionToolbar.selectableRegion(
                        selectableRegionState: selectableRegionState,
                      );
                    },
                    child: Text(
                      _visibleLogText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.45,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 全局日志管理器。
class LogManager {
  /// 单例实例。
  static final LogManager _instance = LogManager._internal();

  /// 日志文本缓存。
  final List<String> _logs = <String>[];

  /// 最大日志条数，超出后会移除最早的一条。
  final int _maxLogs = 1000;

  /// 当前日志版本号，用于判断日志列表是否发生变化。
  int _version = 0;

  factory LogManager() => _instance;

  LogManager._internal();

  /// 当前日志快照。
  List<String> get logs => List<String>.unmodifiable(_logs);

  /// 当前日志版本号。
  int get version => _version;

  /// 新增一条日志并通知监听者。
  void addLog(Object message) {
    final timestamp = DateTime.now().toString();
    _logs.add('[$timestamp] $message');

    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    _version++;
    _notifyListeners();
  }

  /// 日志变更监听列表。
  final List<VoidCallback> _listeners = [];

  /// 注册日志监听。
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// 移除日志监听。
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// 通知所有监听者日志已更新。
  void _notifyListeners() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      listener();
    }
  }

  /// 复制全部日志
  Future<void> copyAllLogs() async {
    await Clipboard.setData(
      ClipboardData(text: _logs.join('\n')),
    );
  }

  /// 清空所有日志
  void clearLogs() {
    _logs.clear();
    _version++;
    _notifyListeners();
  }
}
