import 'package:flutter/material.dart';

class HeroWidget extends StatelessWidget {
  final Object tag;
  final Widget child;
  final double borderRadius;
  const HeroWidget({super.key, required this.tag, required this.child, this.borderRadius = 0});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag, 
      createRectTween: (begin, end) {
        return MaterialRectCenterArcTween(begin: begin, end: end);
      },
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}

class HeroCustomRectTween extends RectTween {

  HeroCustomRectTween({ Rect? begin, Rect? end})
      : super(begin: begin, end: end);

  @override
  Rect lerp(double t) {
    double transformT = Curves.easeInOutBack.transform(t);
    var rect = Rect.fromLTRB(
        _rectMove(begin!.left, end!.left, transformT),
        _rectMove(begin!.top, end!.top, transformT),
        _rectMove(end!.right, end!.right, transformT),
        _rectMove(begin!.bottom, end!.bottom, transformT));

    return rect;
  }

  double _rectMove(double begin, double end, double t) {
    return begin *  (1 - t) + end * t;
  }
}