import 'package:flutter/cupertino.dart';

abstract class AnimationEffect<T> {
  /// The delay for this specific [AnimationEffect].
  final Duration? delay;

  /// The duration for the specific [AnimationEffect].
  final Duration? duration;

  /// The curve for the specific [AnimationEffect].
  final Curve? curve;

  AnimationEffect({
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 300),
    this.curve,
  });

  Widget build(
      BuildContext context, Widget child, Animation<double> animation, EffectEntry entry, Duration totalDuration) {
    return child;
  }

  Animatable<T> buildAnimation(EffectEntry entry, Duration totalDuration, {required T begin, required T end}) {
    return Tween<T>(begin: begin, end: end).chain(entry.buildAnimation(totalDuration: totalDuration));
  }
}

@immutable
class EffectEntry {
  const EffectEntry({
    required this.animationEffect,
    required this.delay,
    required this.duration,
    required this.curve,
  });

  /// The delay for this entry.
  final Duration delay;

  /// The duration for this entry.
  final Duration duration;

  /// The curve used by this entry.
  final Curve curve;

  /// The effect associated with this entry.
  final AnimationEffect animationEffect;

  /// The begin time for this entry.
  Duration get begin => delay;

  /// The end time for this entry.
  Duration get end => begin + duration;

  /// Builds a sub-animation based on the properties of this entry.
  CurveTween buildAnimation({
    required Duration totalDuration,
    Curve? curve,
  }) {
    // 修复：确保begin和end值都在0.0和1.0之间
    double beginT = begin.inMicroseconds / totalDuration.inMicroseconds;
    double endT = end.inMicroseconds / totalDuration.inMicroseconds;

    // 防止除以零
    if (totalDuration.inMicroseconds == 0) {
      beginT = 0.0;
      endT = 1.0;
    }

    // 确保值在有效范围内
    beginT = beginT.clamp(0.0, 1.0);
    endT = endT.clamp(beginT, 1.0); // 确保endT >= beginT且不超过1.0

    return CurveTween(
      curve: Interval(beginT, endT, curve: curve ?? this.curve),
    );
  }

  @override
  String toString() {
    return "delay: $delay, Duration: $duration, curve: $curve, begin: $begin, end: $end, Effect: $animationEffect";
  }
}
