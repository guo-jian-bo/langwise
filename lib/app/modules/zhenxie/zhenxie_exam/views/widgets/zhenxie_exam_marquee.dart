import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 无限横滚（对齐 React ExamHomePage 的 StageMarquee）：
/// 内容复制两份循环滚动，滚完一份宽度无缝回绕；指针悬停暂停。
class ZxMarqueeWidget extends StatefulWidget {
  final Widget child;

  /// 一份内容的宽度（含尾部间距），由外层量好后传入。
  final double stripWidth;

  /// 滚完一份的秒数（React duration = max(18, n * 4.5)）。
  final double durationSeconds;

  const ZxMarqueeWidget({
    super.key,
    required this.child,
    required this.stripWidth,
    required this.durationSeconds,
  });

  @override
  State<ZxMarqueeWidget> createState() => _ZxMarqueeWidgetState();
}

class _ZxMarqueeWidgetState extends State<ZxMarqueeWidget> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  double _offset = 0;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_paused || widget.stripWidth <= 0) {
      _lastTick = elapsed;
      return;
    }
    final double delta = (elapsed - _lastTick).inMicroseconds / Duration.microsecondsPerSecond;
    _lastTick = elapsed;
    final double next = _offset + widget.stripWidth / widget.durationSeconds * delta;
    final double wrapped = next % widget.stripWidth;
    if (wrapped != _offset) setState(() => _offset = wrapped);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _paused = true,
      onExit: (_) => _paused = false,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          maxWidth: double.infinity,
          child: Transform.translate(
            offset: Offset(-_offset, 0),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// 横滚内容宽度测量：量一份内容，传给 ZxMarqueeWidget。
class ZxMarqueeSizerWidget extends StatefulWidget {
  final Widget strip;
  final double durationSeconds;

  const ZxMarqueeSizerWidget({super.key, required this.strip, required this.durationSeconds});

  @override
  State<ZxMarqueeSizerWidget> createState() => _ZxMarqueeSizerWidgetState();
}

class _ZxMarqueeSizerWidgetState extends State<ZxMarqueeSizerWidget> {
  final GlobalKey _stripKey = GlobalKey();
  double _stripWidth = 0;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(ZxMarqueeSizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.strip != widget.strip) {
      // 内容换了（切考段）：先归零重新量一份新宽度，避免拿旧宽回绕跳帧。
      SchedulerBinding.instance.addPostFrameCallback((_) => _measure(reset: true));
    }
  }

  void _measure({bool reset = false}) {
    if (!mounted) return;
    final RenderBox? box = _stripKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final double width = box.size.width;
    if (reset) {
      setState(() => _stripWidth = 0);
      SchedulerBinding.instance.addPostFrameCallback((_) => _measure());
      return;
    }
    if ((width - _stripWidth).abs() < 0.5) return;
    setState(() => _stripWidth = width);
  }

  @override
  Widget build(BuildContext context) {
    // 两份内容：第一份挂测量 key；量到宽度前 offset 恒为 0，静态展示。
    return ZxMarqueeWidget(
      stripWidth: _stripWidth,
      durationSeconds: widget.durationSeconds,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(key: _stripKey, child: widget.strip),
          widget.strip,
        ],
      ),
    );
  }
}
