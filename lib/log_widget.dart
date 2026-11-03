import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'common/widgets/widgets.dart';

class FloatingLogWindow extends StatefulWidget {
  final Widget child;
  const FloatingLogWindow({super.key, required this.child});

  @override
  State<FloatingLogWindow> createState() => _FloatingLogWindowState();
}

class _FloatingLogWindowState extends State<FloatingLogWindow> {
  static const Duration _logRefreshInterval = Duration(milliseconds: 120);
  static const Duration _searchDebounceInterval = Duration(milliseconds: 180);

  /// 是否显示日志弹窗
  bool _showLogWindow = true;

  bool _expanded = false;
  double _opacity = 0.7;
  bool _fill = false;
  String _searchKeyword = '';

  // 0=左上角 1=左下角 2=右下角 3=右上角
  int _logPos = 3;

  bool _showButton = true;
  bool _hasActiveTextSelection = false;
  bool _hasPendingLogRefresh = false;
  bool _shouldAutoScrollToLatest = true;
  final ScrollController _logScrollController = ScrollController();
  Timer? _refreshTimer;
  Timer? _searchDebounceTimer;
  List<String> _visibleLogs = const [];
  int _lastVisibleLogVersion = -1;
  String _lastVisibleKeyword = '';

  LogManager logManager = LogManager();

  ScrollPosition? get _activeLogScrollPosition {
    if (!_logScrollController.hasClients) return null;
    final positions = _logScrollController.positions;
    if (positions.isEmpty) return null;
    return positions.last;
  }

  @override
  void initState() {
    super.initState();
    logManager.addListener(_update);
    _logScrollController.addListener(_handleLogScroll);
    _refreshVisibleLogs(force: true);
  }

  @override
  void dispose() {
    logManager.removeListener(_update);
    _logScrollController.removeListener(_handleLogScroll);
    _logScrollController.dispose();
    _refreshTimer?.cancel();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _update() {
    if (!mounted) return;
    if (_hasActiveTextSelection) {
      _hasPendingLogRefresh = true;
      return;
    }
    _scheduleRefresh();
  }

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

  void _applyRefresh({bool forceScroll = false}) {
    if (!mounted) return;
    _refreshVisibleLogs(force: true);
    setState(() {});
    _scrollToLatestIfNeeded(force: forceScroll);
  }

  void _handleLogSelectionChanged(TextSelection selection, SelectionChangedCause? cause) {
    final hasActiveTextSelection = !selection.isCollapsed;
    if (_hasActiveTextSelection == hasActiveTextSelection) return;
    _hasActiveTextSelection = hasActiveTextSelection;
    if (!_hasActiveTextSelection && _hasPendingLogRefresh && mounted) {
      _hasPendingLogRefresh = false;
      _scheduleRefresh(immediate: true, forceScroll: true);
    }
  }

  void _handleLogScroll() {
    final position = _activeLogScrollPosition;
    if (position == null) return;
    _shouldAutoScrollToLatest = position.maxScrollExtent - position.pixels <= 48;
  }

  void _scrollToLatestIfNeeded({bool force = false, int retryCount = 3}) {
    if (!_expanded) return;
    if (!force && !_shouldAutoScrollToLatest) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
        _logScrollController.jumpTo(maxScrollExtent);
      }
      if (retryCount > 0 && distanceToLatest > 1) {
        _scrollToLatestIfNeeded(force: force, retryCount: retryCount - 1);
      }
    });
  }

  void _refreshVisibleLogs({bool force = false}) {
    final keyword = _searchKeyword.trim().toLowerCase();
    if (!force && _lastVisibleLogVersion == logManager.version && _lastVisibleKeyword == keyword) {
      return;
    }
    final logs = logManager.logs;
    _visibleLogs = keyword.isEmpty
        ? List<String>.unmodifiable(logs)
        : List<String>.unmodifiable(
            logs.where((log) => log.toLowerCase().contains(keyword)),
          );
    _lastVisibleLogVersion = logManager.version;
    _lastVisibleKeyword = keyword;
  }

  void _updateOpacity(double opacity) {
    if (_opacity == opacity) return;
    setState(() => _opacity = opacity);
  }

  void _handleSearchChanged(String value) {
    _searchKeyword = value;
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounceInterval, () {
      if (!mounted) return;
      _refreshVisibleLogs(force: true);
      setState(() {});
      _shouldAutoScrollToLatest = true;
      _scrollToLatestIfNeeded(force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showLogWindow) return widget.child;

    double? top;
    double? left;
    double? right;
    double? bottom;
    if (_logPos == 0) {
      top = 0;
      left = 0;
    } else if (_logPos == 1) {
      bottom = 0;
      left = 0;
    } else if (_logPos == 2) {
      bottom = 0;
      right = 0;
    } else if (_logPos == 3) {
      top = 0;
      right = 0;
    }

    return Stack(
      children: [
        RepaintBoundary(child: widget.child),
        Positioned(
          top: top,
          left: left,
          right: right,
          bottom: bottom,
          child: HeroControllerScope(
            controller: HeroController(),
            child: Navigator(
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) {
                    Size size = MediaQuery.of(context).size;
                    return Material(
                      type: MaterialType.transparency, // 透明背景
                      child: RepaintBoundary(
                        child: MouseRegion(
                          onEnter: (_) => _updateOpacity(1.0),
                          onExit: (_) => _updateOpacity(0.3),
                          child: AnimatedContainer(
                            onEnd: () {
                              _showButton = true;
                              setState(() {});
                              if (_expanded) {
                                _scrollToLatestIfNeeded(
                                  force: true,
                                  retryCount: 5,
                                );
                              }
                            },
                            duration: const Duration(milliseconds: 200),
                            width: _fill ? size.width : (_expanded ? 300 : 100),
                            height: _fill ? size.height : (_expanded ? size.height : 40),
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
                            child: Column(
                              children: [
                                _buildHeader(context),
                                if (_expanded) _buildLogList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 40,
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
          Visibility(
            visible: _showButton,
            child: Row(
              children: [
                Visibility(
                  visible: _expanded || _fill,
                  child: IconButton(
                    splashColor: Colors.white10,
                    highlightColor: Colors.white10,
                    icon: const Icon(
                      Icons.cleaning_services_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      logManager.clearLogs();
                    },
                  ),
                ),
                Visibility(
                  visible: _expanded,
                  child: IconButton(
                    splashColor: Colors.white10,
                    highlightColor: Colors.white10,
                    icon: Icon(
                      _fill ? Icons.copy : Icons.check_box_outline_blank,
                      size: 18,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() => _fill = !_fill),
                  ),
                ),
                Visibility(
                  visible: _expanded,
                  child: IconButton(
                    splashColor: Colors.white10,
                    highlightColor: Colors.white10,
                    icon: Icon(
                      Icons.clear,
                      size: 18,
                      color: Colors.white,
                    ),
                    onLongPress: () {
                      _showLogWindow = false;
                      setState(() {});
                    },
                    onPressed: () {},
                  ),
                ),
                IconButton(
                  splashColor: Colors.white10,
                  highlightColor: Colors.white10,
                  icon: Icon(
                    _expanded ? Icons.remove : Icons.copy,
                    size: 18,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _expanded = !_expanded;
                    _showButton = false;
                    _fill = false;
                    _searchKeyword = "";
                    _shouldAutoScrollToLatest = true;
                    _scrollToLatestIfNeeded(force: true);

                    setState(() {});
                    if (_expanded) {
                      _shouldAutoScrollToLatest = true;
                      _scrollToLatestIfNeeded(force: true);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    final visibleLogs = _visibleLogs;
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
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: CardInputWidget(
                        hintText: "搜索日志",
                        height: 40,
                        borderColor: Colors.white.withValues(alpha: 0.3),
                        fillColor: Colors.black,
                        onChanged: _handleSearchChanged,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await logManager.copyAllLogs();
                      },
                      child: Text(
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
              Expanded(
                child: visibleLogs.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无匹配日志',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: _logScrollController,
                        primary: false,
                        itemCount: visibleLogs.length,
                        padding: const EdgeInsets.all(10),
                        separatorBuilder: (context, index) {
                          return Container(
                            height: 0.5,
                            color: Colors.white.withValues(alpha: 0.3),
                          );
                        },
                        itemBuilder: (context, index) {
                          return Container(
                            key: ValueKey(visibleLogs[index]),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: SelectableText(
                              visibleLogs[index],
                              onSelectionChanged: _handleLogSelectionChanged,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogManager {
  static final LogManager _instance = LogManager._internal();
  final List<Object> _logs = <Object>[];
  final int _maxLogs = 1000; // 最大日志条数
  int _version = 0;

  factory LogManager() => _instance;

  LogManager._internal();

  List<String> get logs => List<String>.unmodifiable(_logs.map((log) => log.toString()));
  int get version => _version;

  void addLog(Object message) {
    final timestamp = DateTime.now().toString();
    _logs.add('[$timestamp] $message');

    // 限制日志数量
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    _version++;
    // 通知监听者
    _notifyListeners();
  }

  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      listener();
    }
  }

  /// 复制全部日志
  Future<void> copyAllLogs() async {
    await Clipboard.setData(
      ClipboardData(text: _logs.map((log) => log.toString()).join('\n')),
    );
  }

  /// 清空所有日志
  void clearLogs() {
    _logs.clear();
    _version++;
    _notifyListeners();
  }
}
