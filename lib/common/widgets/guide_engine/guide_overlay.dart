import 'dart:math' as math;
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';

class GuideOverlay {
  static OverlayEntry? _entry;

  static void showGuide(
    BuildContext context,
    GlobalKey targetKey, {
    required String title,
    required String tip,
    String? progressText,
    bool canSkip = false,
    bool homeGuide = false,
    VoidCallback? onSkip,
    bool allowPenetration = true,
    bool lockTargetInViewport = false,
    VoidCallback? onTargetTap,
  }) {
    if (homeGuide && Get.currentRoute != Routes.APPLICATION) {
      var reachedHome = false;
      try {
        Get.until((route) {
          reachedHome = route.settings.name == Routes.APPLICATION;
          return reachedHome;
        });
      } catch (_) {}
      if (!reachedHome) {
        RoutesBreadcrumbUtils.clearAllBreadcrumb();
        Get.offAllNamed(Routes.APPLICATION);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final overlayContext = Get.overlayContext;
        if (overlayContext == null) return;
        showGuide(
          overlayContext,
          targetKey,
          title: title,
          tip: tip,
          progressText: progressText,
          canSkip: canSkip,
          homeGuide: false,
          onSkip: onSkip,
          allowPenetration: allowPenetration,
          lockTargetInViewport: lockTargetInViewport,
          onTargetTap: onTargetTap,
        );
      });
      return;
    }

    hide();
    _entry = OverlayEntry(
      builder: (context) {
        return _GuideOverlayFollower(
          targetKey: targetKey,
          title: title,
          tip: tip,
          progressText: progressText,
          canSkip: canSkip,
          onSkip: onSkip,
          allowPenetration: allowPenetration,
          lockTargetInViewport: lockTargetInViewport,
          onTargetTap: onTargetTap,
        );
      },
    );

    Overlay.of(context).insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}

class _GuideOverlayFollower extends StatefulWidget {
  final GlobalKey targetKey;
  final String title;
  final String tip;
  final String? progressText;
  final bool canSkip;
  final VoidCallback? onSkip;
  final bool allowPenetration;
  final bool lockTargetInViewport;
  final VoidCallback? onTargetTap;

  const _GuideOverlayFollower({
    required this.targetKey,
    required this.title,
    required this.tip,
    required this.progressText,
    required this.canSkip,
    required this.onSkip,
    required this.allowPenetration,
    required this.lockTargetInViewport,
    required this.onTargetTap,
  });

  @override
  State<_GuideOverlayFollower> createState() => _GuideOverlayFollowerState();
}

class _GuideOverlayFollowerState extends State<_GuideOverlayFollower> {
  Rect? _globalRect;
  final GlobalKey _tipKey = GlobalKey();
  double _tipHeight = 44.wMin;
  static const double _epsilon = 0.5;

  bool _ensuringVisible = false;
  int _lastEnsureMs = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    final newRect = _computeGlobalRect();
    if (newRect != null) {
      final oldRect = _globalRect;
      if (oldRect == null || !_isNear(oldRect, newRect)) {
        _globalRect = newRect;
        setState(() {});
      }

      if (widget.lockTargetInViewport) {
        _ensureTargetInViewportIfNeeded(newRect);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
  }

  Future<void> _ensureTargetInViewportIfNeeded(Rect globalRect) async {
    if (_ensuringVisible) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastEnsureMs < 250) return;
    _lastEnsureMs = now;

    final targetContext = widget.targetKey.currentContext;
    if (targetContext == null) return;
    final media = MediaQuery.maybeOf(targetContext);
    if (media == null) return;

    final screenRect = Offset.zero & media.size;
    if (screenRect.overlaps(globalRect)) return;

    _ensuringVisible = true;
    try {
      await Scrollable.ensureVisible(
        targetContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    } catch (_) {
      return;
    } finally {
      _ensuringVisible = false;
    }
  }

  Rect? _computeGlobalRect() {
    final targetContext = widget.targetKey.currentContext;
    if (targetContext == null) return null;
    final renderObject = targetContext.findRenderObject();
    if (renderObject is! RenderBox) return null;
    if (!renderObject.attached) return null;
    final offset = renderObject.localToGlobal(Offset.zero);
    return offset & renderObject.size;
  }

  bool _isNear(Rect a, Rect b) {
    return (a.left - b.left).abs() < _epsilon &&
        (a.top - b.top).abs() < _epsilon &&
        (a.width - b.width).abs() < _epsilon &&
        (a.height - b.height).abs() < _epsilon;
  }

  @override
  Widget build(BuildContext context) {
    final globalRect = _globalRect;
    if (globalRect == null) {
      return const SizedBox.shrink();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _tipKey.currentContext;
      if (ctx == null) return;
      final ro = ctx.findRenderObject();
      if (ro is! RenderBox) return;
      if (!ro.hasSize) return;
      final h = ro.size.height;
      if ((h - _tipHeight).abs() > 0.5) {
        setState(() {
          _tipHeight = h;
        });
      }
    });

    final overlayBox = context.findRenderObject() as RenderBox?;
    final Rect rect = overlayBox == null
        ? globalRect
        : Rect.fromPoints(
            overlayBox.globalToLocal(globalRect.topLeft),
            overlayBox.globalToLocal(globalRect.bottomRight),
          );

    final media = MediaQuery.of(context);
    final screenRect = Offset.zero & media.size;
    if (!rect.overlaps(screenRect)) {
      return const SizedBox.shrink();
    }

    double edge = 16.wMin;
    double gap = 8.wMin;
    final tipHeight = _tipHeight;

    final tipWidth = math.min(320.wMin, media.size.width - edge * 2);
    final desiredLeft = rect.center.dx - tipWidth / 2;
    final tipLeft = desiredLeft.clamp(edge, media.size.width - edge - tipWidth);

    final availableBottom = (media.size.height - media.padding.bottom) - (rect.bottom + gap);
    final availableTop = (rect.top - gap) - media.padding.top;
    final showBelow = availableBottom >= tipHeight || availableBottom >= availableTop;
    final tipTop = (showBelow ? rect.bottom + gap : rect.top - gap - tipHeight)
        .clamp(media.padding.top + edge, media.size.height - media.padding.bottom - edge - tipHeight);

    final arrowDx = (rect.center.dx - tipLeft).clamp(24.wMin, tipWidth - 24.wMin);

    return TransparentHoleRenderWidget(
      targetRect: rect,
      allowPenetration: widget.allowPenetration,
      child: Stack(
        children: [
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) {
              if (!widget.allowPenetration) {
                if (rect.contains(e.localPosition)) {
                  widget.onTargetTap?.call();
                }
                return;
              }
              if (rect.contains(e.localPosition)) {
                widget.onTargetTap?.call();
              }
            },
            child: IgnorePointer(
              ignoring: true,
              child: CustomPaint(
                size: media.size,
                painter: HolePainter(rect),
              ),
            ),
          ),
          Positioned(
            top: tipTop,
            left: tipLeft,
            width: tipWidth,
            child: _TipBubble(
              key: _tipKey,
              title: widget.title,
              text: widget.tip,
              progressText: widget.progressText,
              arrowDx: arrowDx,
              arrowOnTop: showBelow,
              canSkip: widget.canSkip,
              onSkip: widget.onSkip,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipBubble extends StatelessWidget {
  final String title;
  final String text;
  final String? progressText;
  final double arrowDx;
  final bool arrowOnTop;
  final bool canSkip;
  final VoidCallback? onSkip;

  const _TipBubble({
    super.key,
    required this.title,
    required this.text,
    required this.progressText,
    required this.arrowDx,
    required this.arrowOnTop,
    required this.canSkip,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TipBubblePainter(arrowDx: arrowDx, arrowOnTop: arrowOnTop, radius: 12.wMin),
      child: Padding(
        padding: EdgeInsets.only(left: 16.wMin, right: 16.wMin, bottom: 16.wMin, top: 26.wMin),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 24.wMin, fontWeight: FontWeight.w600),
                ),
                Text(
                  text,
                  style: TextStyle(color: Colors.white, fontSize: 22.wMin, fontWeight: FontWeight.w400),
                ),
                if ((progressText ?? '').isNotEmpty) ...[
                  SizedBox(height: 10.wMin),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      progressText!,
                      style: TextStyle(color: Colors.white, fontSize: 22.wMin, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
            if (canSkip)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onSkip,
                  child: SvgPicture.asset(
                    'assets/svg/public/x.svg',
                    width: 24.wMin,
                    height: 24.wMin,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TipBubblePainter extends CustomPainter {
  final double arrowDx;
  final bool arrowOnTop;
  final double radius;

  const _TipBubblePainter({
    required this.arrowDx,
    required this.arrowOnTop,
    this.radius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double arrowW = 20.wMin;
    double arrowH = 10.wMin;

    final bgPaint = Paint()..color = const Color(0xFF38BDF8);
    final borderPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.wMin;

    final rect = arrowOnTop
        ? Rect.fromLTWH(0, arrowH, size.width, size.height - arrowH)
        : Rect.fromLTWH(0, 0, size.width, size.height - arrowH);

    final clampedDx = arrowDx.clamp(radius + arrowW / 2 + 2, size.width - radius - arrowW / 2 - 2);

    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    if (arrowOnTop) {
      path.moveTo(clampedDx - arrowW / 2, arrowH);
      path.lineTo(clampedDx, 0);
      path.lineTo(clampedDx + arrowW / 2, arrowH);
      path.close();
    } else {
      final y = size.height - arrowH;
      path.moveTo(clampedDx - arrowW / 2, y);
      path.lineTo(clampedDx, size.height);
      path.lineTo(clampedDx + arrowW / 2, y);
      path.close();
    }

    canvas.drawPath(path, bgPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_TipBubblePainter oldDelegate) {
    return oldDelegate.arrowDx != arrowDx || oldDelegate.arrowOnTop != arrowOnTop;
  }
}

class TransparentHoleRenderWidget extends SingleChildRenderObjectWidget {
  final Rect targetRect; // 挖洞的区域
  final bool allowPenetration;

  const TransparentHoleRenderWidget({
    super.child,
    required this.targetRect,
    this.allowPenetration = true,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderTransparentHole(targetRect, allowPenetration: allowPenetration);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderTransparentHole renderObject) {
    renderObject.targetRect = targetRect;
    renderObject.allowPenetration = allowPenetration;
  }
}

class _RenderTransparentHole extends RenderProxyBox {
  Rect targetRect;
  bool allowPenetration;
  _RenderTransparentHole(this.targetRect, {required this.allowPenetration});

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (allowPenetration && targetRect.contains(position)) {
      return false;
    }
    // 洞外区域正常处理（拦截点击）
    return super.hitTest(result, position: position);
  }
}

class HolePainter extends CustomPainter {
  final Rect targetRect;

  HolePainter(this.targetRect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black45; // 半透明背景

    // 使用 PathOperation.difference 挖洞
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(targetRect, Radius.circular(8.wMin))),
      ),
      paint,
    );

    final hole = RRect.fromRectAndRadius(targetRect, Radius.circular(10.wMin));
    const accent = Color(0xFF2388FF);

    final outerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = accent.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRRect(hole, outerGlow);

    final midGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = accent.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRRect(hole, midGlow);

    final sharpRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.75);
    canvas.drawRRect(hole, sharpRing);
  }

  @override
  bool shouldRepaint(HolePainter oldDelegate) => oldDelegate.targetRect != targetRect;
}
