import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LazyVisibilityImage extends StatefulWidget {
  final String visibilityKey;
  final Widget Function() imageBuilder;
  final Widget placeholder;

  const LazyVisibilityImage({
    super.key,
    required this.visibilityKey,
    required this.imageBuilder,
    required this.placeholder,
  });

  @override
  State<LazyVisibilityImage> createState() => _LazyVisibilityImageState();
}

class _LazyVisibilityImageState extends State<LazyVisibilityImage> {
  bool _shouldLoad = false;
  late final String _instanceVisibilityKey;

  @override
  void initState() {
    super.initState();
    _instanceVisibilityKey = '${widget.visibilityKey}_${identityHashCode(this)}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _shouldLoad) return;
      VisibilityDetectorController.instance.notifyNow();
      _tryLoadIfInViewport();
    });
  }

  void _tryLoadIfInViewport() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached || !renderObject.hasSize) {
      return;
    }
    final Offset topLeft = renderObject.localToGlobal(Offset.zero);
    final Rect widgetRect = topLeft & renderObject.size;
    final Size screenSize = MediaQuery.sizeOf(context);
    final Rect viewportRect = Offset.zero & screenSize;
    if (!widgetRect.overlaps(viewportRect)) return;
    setState(() {
      _shouldLoad = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(_instanceVisibilityKey),
      onVisibilityChanged: (info) {
        if (_shouldLoad || info.visibleFraction <= 0) return;
        if (!mounted) return;
        setState(() {
          _shouldLoad = true;
        });
      },
      child: _shouldLoad ? widget.imageBuilder() : widget.placeholder,
    );
  }
}
