import 'package:flutter/material.dart';

class FloatingLogWindow extends StatefulWidget {
  final Widget child;
  const FloatingLogWindow({Key? key, required this.child}) : super(key: key);

  @override
  _FloatingLogWindowState createState() => _FloatingLogWindowState();
}

class _FloatingLogWindowState extends State<FloatingLogWindow> {
  bool _expanded = false;
  double _opacity = 0.7;
  bool _fill = false;

  // 0=左上角 1=左下角 2=右下角 3=右上角
  int _logPos = 3;

  bool _showButton = true;

  LogManager logManager = LogManager();

  @override
  void initState() {
    super.initState();
    logManager.addListener(_update);
  }

  @override
  void dispose() {
    logManager.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const Text('日志', style: TextStyle(color: Colors.white, fontSize: 14)),
            const Spacer(),
            Visibility(
              visible: _showButton,
              child: Row(
                children: [
                  Visibility(
                    visible: _expanded || _fill,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, size: 18, color: Colors.white),
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
                      setState(() {});
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
    return Expanded(
      child: Theme(
        data: Theme.of(context).copyWith(
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.2)),
            trackColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
          ),
          textSelectionTheme: const TextSelectionThemeData(
            selectionColor: Colors.blue,
          ),
        ),
        child: ListView.separated(
          reverse: true, // 最新日志显示在最上面
          itemCount: logManager.logs.length,
          padding: const EdgeInsets.all(10),
          separatorBuilder: (context, index) {
            return Container(
              height: 0.5,
              color: Colors.white.withValues(alpha: 0.3),
            );
          },
          itemBuilder: (context, index) {
            final logIndex = logManager.logs.length - 1 - index;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SelectableText(
                logManager.logs[logIndex].toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LogManager {
  static final LogManager _instance = LogManager._internal();
  final List<Object> _logs = [];
  final int _maxLogs = 10000; // 最大日志条数

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

  void clearLogs() {
    _logs.clear();
    _notifyListeners();
  }
}
