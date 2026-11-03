import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ListAnimationWidget extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final Duration? delay;
  final double? verticalOffset;
  final double? horizontalOffset;
  final Curve curve;
  const ListAnimationWidget({
    super.key, 
    this.index = 0, 
    required this.child, 
    this.duration = const Duration(milliseconds: 225),
    this.delay,
    this.verticalOffset,
    this.horizontalOffset,
    this.curve = Curves.ease,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: duration,
      delay: delay,
      child: SlideAnimation(
        verticalOffset: verticalOffset,
        horizontalOffset: horizontalOffset,
        curve: curve,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}

class ListAnimationGridWidget extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final Duration? delay;
  final Curve curve;
  final int columnCount;
  const ListAnimationGridWidget({
    super.key, 
    this.index = 0, 
    required this.child, 
    this.duration = const Duration(milliseconds: 225),
    this.delay,
    this.curve = Curves.ease, 
    required this.columnCount,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredGrid(
      position: index,
      duration: duration,
      delay: delay,
      columnCount: columnCount,
      child: ScaleAnimation(
        curve: curve,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}

class ListScaleAnimationWidget extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final Duration? delay;
  final Curve curve;
  const ListScaleAnimationWidget({
    super.key, 
    this.index = 0, 
    required this.child, 
    this.duration = const Duration(milliseconds: 225),
    this.delay,
    this.curve = Curves.ease,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: duration,
      delay: delay,
      child: ScaleAnimation(
        curve: curve,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}