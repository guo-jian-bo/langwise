import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'common/widgets/widgets.dart';

class FloatingLogWindow extends StatefulWidget {
  final Widget child;
  const FloatingLogWindow({super.key, required this.child});

  @override
  _FloatingLogWindowState createState() => _FloatingLogWindowState();
}

class _FloatingLogWindowState extends State<FloatingLogWindow> {
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

  LogManager logManager = LogManager();

  @override
  void initState() {
    super.initState();
    logManager.addListener(_update);
    _logScrollController.addListener(_handleLogScroll);
  }

  @override
  void dispose() {
    logManager.removeListener(_update);
    _logScrollController.removeListener(_handleLogScroll);
    _logScrollController.dispose();
    super.dispose();
  }

  void _update() {
    if (!mounted) return;
    if (_hasActiveTextSelection) {
      _hasPendingLogRefresh = true;
      return;
    }
    setState(() {});
    _scrollToLatestIfNeeded();
  }

  void _handleLogSelectionChanged(
      TextSelection selection, SelectionChangedCause? cause) {
    final hasActiveTextSelection = !selection.isCollapsed;
    if (_hasActiveTextSelection == hasActiveTextSelection) return;
    _hasActiveTextSelection = hasActiveTextSelection;
    if (!_hasActiveTextSelection && _hasPendingLogRefresh && mounted) {
      _hasPendingLogRefresh = false;
      setState(() {});
      _scrollToLatestIfNeeded(force: true);
    }
  }

  void _handleLogScroll() {
    if (!_logScrollController.hasClients) return;
    final position = _logScrollController.position;
    _shouldAutoScrollToLatest =
        position.maxScrollExtent - position.pixels <= 48;
  }

  void _scrollToLatestIfNeeded({bool force = false, int retryCount = 3}) {
    if (!_expanded) return;
    if (!force && !_shouldAutoScrollToLatest) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_logScrollController.hasClients) return;
      final position = _logScrollController.position;
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

  List<Object> get _filteredLogs {
    final keyword = _searchKeyword.trim().toLowerCase();
    if (keyword.isEmpty) return logManager.logs;
    return logManager.logs
        .where((log) => log.toString().toLowerCase().contains(keyword))
        .toList();
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
        widget.child,
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
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _opacity = 1.0),
                        onExit: (_) => setState(() => _opacity = 0.3),
                        child: AnimatedContainer(
                          onEnd: () {
                            _showButton = true;
                            setState(() {});
                            if (_expanded) {
                              _scrollToLatestIfNeeded(
                                  force: true, retryCount: 5);
                            }
                          },
                          duration: const Duration(milliseconds: 200),
                          width: _fill ? size.width : (_expanded ? 300 : 100),
                          height: _fill
                              ? size.height
                              : (_expanded ? size.height : 40),
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
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          _logPos = (_logPos + 1) % 4;
        });
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.transparent,
        child: Row(
          children: [
            const Text('日志',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            const Spacer(),
            Visibility(
              visible: _showButton,
              child: Row(
                children: [
                  Visibility(
                    visible: _expanded || _fill,
                    child: IconButton(
                      icon: const Icon(Icons.cleaning_services_rounded,
                          size: 18, color: Colors.white),
                      onPressed: () {
                        logManager.clearLogs();
                      },
                    ),
                  ),
                  Visibility(
                    visible: _expanded,
                    child: IconButton(
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
                      icon: Icon(
                        Icons.clear,
                        size: 18,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _showLogWindow = false;
                        setState(() {});
                      },
                    ),
                  ),
                  IconButton(
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
      ),
    );
  }

  Widget _buildLogList() {
    final filteredLogs = _filteredLogs;
    return Expanded(
      child: Theme(
        data: Theme.of(context).copyWith(
          scrollbarTheme: ScrollbarThemeData(
            thumbColor:
                WidgetStateProperty.all(Colors.white.withValues(alpha: 0.2)),
            trackColor:
                WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
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
                      onChanged: (value) {
                        setState(() {
                          _searchKeyword = value;
                        });
                        _shouldAutoScrollToLatest = true;
                        _scrollToLatestIfNeeded(force: true);
                      },
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
              child: filteredLogs.isEmpty
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
                      itemCount: filteredLogs.length,
                      padding: const EdgeInsets.all(10),
                      separatorBuilder: (context, index) {
                        return Container(
                          height: 0.5,
                          color: Colors.white.withValues(alpha: 0.3),
                        );
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          key: ValueKey(filteredLogs[index].toString()),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: SelectableText(
                            filteredLogs[index].toString(),
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
    );
  }
}

class LogManager {
  static final LogManager _instance = LogManager._internal();
  final List<Object> _logs = [];
  final int _maxLogs = 1000; // 最大日志条数

  factory LogManager() => _instance;

  LogManager._internal();

  List<Object> get logs => _logs;

  void addLog(Object message) {
    final timestamp = DateTime.now().toString();
    _logs.add('[$timestamp] $message');

    // 限制日志数量
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

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
    for (final listener in _listeners) {
      listener();
    }
  }

  /// 复制全部日志
  Future<void> copyAllLogs() async {
    await Clipboard.setData(ClipboardData(text: _logs.join('\n')));
  }

  /// 清空所有日志
  void clearLogs() {
    _logs.clear();
    _notifyListeners();
  }
}
