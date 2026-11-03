// 支持自定义时长的动画基类
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/platform_backdrop_filter_widget.dart';
import 'dart:math';
import 'dart:ui' as ui;

abstract class MVAnimation {
  final String name;
  final Curve curve;
  final Duration duration;
  
  MVAnimation({
    required this.name,
    this.curve = Curves.easeInOut,
    required this.duration,
  });
  
  // 子类必须实现的动画构建方法
  Widget buildAnimation(BuildContext context, Animation<double> animation, Widget child);
  
  // 可选：获取动画时长
  Duration getAnimationDuration() => duration;
}


// 快速翻转动画 - 1秒
class QuickFlipAnimation extends MVAnimation {
  final Axis axis;
  
  QuickFlipAnimation({this.axis = Axis.horizontal})
      : super(
          name: '快速翻转',
          curve: Curves.easeInOutBack,
          duration: const Duration(milliseconds: 6000),
        );
  
  @override
  Widget buildAnimation(BuildContext context, Animation<double> animation, Widget child) {
    double angle = animation.value * pi;
    
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(axis == Axis.vertical ? angle : 0)
        ..rotateY(axis == Axis.horizontal ? angle : 0),
      alignment: Alignment.center,
      child: child,
    );
  }
}

// 弹性缩放动画 - 1.5秒
class ElasticScaleAnimation extends MVAnimation {
  final double beginScale;
  final double endScale;
  
  ElasticScaleAnimation({
    this.beginScale = 0.0,
    this.endScale = 1.0,
  }) : super(
          name: '弹性缩放',
          curve: Curves.elasticOut,
          duration: Duration(milliseconds: 6000),
        );
  
  @override
  Widget buildAnimation(BuildContext context, Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: Tween(begin: beginScale, end: endScale).animate(animation),
      child: child,
    );
  }
}

// 慢速滑动动画 - 2秒
class SlowSlideAnimation extends MVAnimation {
  final Offset beginOffset;
  final Offset endOffset;
  
  SlowSlideAnimation({
    this.beginOffset = const Offset(1.0, 0.0),
    this.endOffset = Offset.zero,
  }) : super(
          name: '慢速滑动',
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: 6000),
        );
  
  @override
  Widget buildAnimation(BuildContext context, Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: beginOffset, end: endOffset).animate(animation),
      child: child,
    );
  }
}

// 粒子爆炸动画 - 2.5秒
class ParticleExplosionAnimation extends MVAnimation {
  ParticleExplosionAnimation() : super(
    name: '粒子爆炸',
    curve: Curves.easeOut,
    duration: Duration(milliseconds: 6000),
  );
  
  @override
  Widget buildAnimation(BuildContext context, Animation<double> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 主部件
            Transform.scale(
              scale: 1.0 - animation.value * 0.3,
              child: Opacity(
                opacity: 1.0 - animation.value,
                child: child,
              ),
            ),
            // 粒子
            ..._buildParticles(animation, child),
          ],
        );
      },
    );
  }
  
  List<Widget> _buildParticles(Animation<double> animation, Widget original) {
    List<Widget> particles = [];
    int particleCount = 8;
    
    for (int i = 0; i < particleCount; i++) {
      double angle = 2 * pi * i / particleCount;
      double distance = animation.value * 200;
      
      particles.add(
        Positioned(
          left: cos(angle) * distance + 150, // 居中偏移
          top: sin(angle) * distance + 200,
          child: Transform.scale(
            scale: 1.0 - animation.value,
            child: Opacity(
              opacity: 1.0 - animation.value,
              child: SizedBox(
                width: 80,
                height: 80,
                child: original,
              ),
            ),
          ),
        ),
      );
    }
    return particles;
  }
}

// 超慢漩涡动画 - 3秒
class SlowVortexAnimation extends MVAnimation {
  SlowVortexAnimation() : super(
    name: '慢速漩涡',
    curve: Curves.fastOutSlowIn,
    duration: Duration(milliseconds: 6000),
  );
  
  @override
  Widget buildAnimation(BuildContext context, Animation<double> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform(
          transform: Matrix4.identity()
            ..rotateZ(animation.value * 4 * pi)
            ..scale(1.0 - animation.value * 0.5),
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}

// 快速模糊动画 - 800毫秒
class QuickBlurAnimation extends MVAnimation {
  QuickBlurAnimation() : super(
    name: '快速模糊',
    curve: Curves.easeIn,
    duration: Duration(milliseconds: 6000),
  );
  
  @override
  Widget buildAnimation(BuildContext context, Animation<double> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Stack(
          children: [
            child,
            PlatformBackdropFilterWidget(
              sigmaX: animation.value * 10,
              sigmaY: animation.value * 10,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ],
        );
      },
    );
  }
}

// 弹跳进入动画 - 1.2秒
class BounceInAnimation extends MVAnimation {
  BounceInAnimation() : super(
    name: '弹跳进入',
    curve: Curves.bounceOut,
    duration: Duration(milliseconds: 6000),
  );
  
  @override
  Widget buildAnimation(BuildContext context, Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.bounceOut,
      )),
      child: child,
    );
  }
}

// 3D 立方体旋转 - 2.8秒
class CubeRotationAnimation extends MVAnimation {
  CubeRotationAnimation() : super(
    name: '立方体旋转',
    curve: Curves.easeInOut,
    duration: Duration(milliseconds: 6000),
  );
  
  @override
  Widget buildAnimation(BuildContext context, Animation<double> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(animation.value * pi / 2)
            ..rotateY(animation.value * pi / 2),
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}

// 渐隐渐现 - 1.8秒
class FadeTransitionAnimation extends MVAnimation {
  FadeTransitionAnimation() : super(
    name: '渐隐渐现',
    curve: Curves.easeInOut,
    duration: Duration(milliseconds: 6000),
  );
  
  @override
  Widget buildAnimation(BuildContext context, Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Interval(0.3, 1.0, curve: Curves.easeInOut),
      )),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Interval(0.0, 0.7, curve: Curves.easeOut),
        )),
        child: child,
      ),
    );
  }
}



/// Ken Burns Effect (肯·伯恩斯效果)
class KenBurnsEffectAnimation extends MVAnimation {
  /// 缩放增量下限（最终缩放 = 1.0 + delta）
  final double minScaleDelta;
  /// 缩放增量上限（建议 0.12 ~ 0.18）
  final double maxScaleDelta;
  /// 水平位移百分比下限（负值向左，基于父尺寸）
  final double minDxPercent;
  /// 水平位移百分比上限（正值向右，基于父尺寸）
  final double maxDxPercent;
  /// 垂直位移百分比下限（负值向上，基于父尺寸）
  final double minDyPercent;
  /// 垂直位移百分比上限（正值向下，基于父尺寸）
  final double maxDyPercent;

  /// 本次动画选定的缩放增量
  late final double _scaleDelta;
  /// 本次动画选定的水平位移百分比
  late final double _dxPercent;
  /// 本次动画选定的垂直位移百分比
  late final double _dyPercent;

  KenBurnsEffectAnimation({
    double? minScaleDelta,
    double? maxScaleDelta,
    double? minDxPercent,
    double? maxDxPercent,
    double? minDyPercent,
    double? maxDyPercent,
    Duration duration = const Duration(seconds: 3),
  })  : minScaleDelta = minScaleDelta ?? 0.12, // 默认缩放增量下限
        maxScaleDelta = maxScaleDelta ?? 0.18, // 默认缩放增量上限
        minDxPercent = minDxPercent ?? -0.035, // 默认水平位移下限（-3.5%）
        maxDxPercent = maxDxPercent ?? 0.035,  // 默认水平位移上限（+3.5%）
        minDyPercent = minDyPercent ?? -0.025, // 默认垂直位移下限（-2.5%）
        maxDyPercent = maxDyPercent ?? 0.025,  // 默认垂直位移上限（+2.5%）
        super(
          name: '肯·伯恩斯效果',
          curve: Curves.easeInOut,
          duration: duration, // 动画时长（建议 8-12 秒）
        ) {
    final r = Random();
    _scaleDelta = _rand(r, this.minScaleDelta, this.maxScaleDelta);
    _dxPercent = _rand(r, this.minDxPercent, this.maxDxPercent);
    _dyPercent = _rand(r, this.minDyPercent, this.maxDyPercent);
  }

  double _rand(Random r, double min, double max) {
    return min + r.nextDouble() * (max - min);
  }

  @override
  Widget buildAnimation(BuildContext context, Animation<double> animation, Widget child) {
    /// 曲线映射后的进度（0→1）
    final t = curve.transform(animation.value);
    /// 最终缩放系数（1.0→1.0+delta）
    final scale = 1.0 + _scaleDelta * t;
    return Transform.scale(
      scale: scale,
      alignment: Alignment.center,
      child: FractionalTranslation(
        /// 百分比位移（相对父尺寸）
        translation: Offset(_dxPercent * t, _dyPercent * t),
        child: child,
      ),
    );
  }
}



/// Dolly Zoom (变焦镜头/眩晕效果)
class DollyZoomAnimation extends MVAnimation {
  /// 透视强度（Matrix4.setEntry(3, 2, perspective)），值越大透视越明显
  final double perspective;
  /// 起始视野系数（用缩放近似 FOV，值越大视野越窄）
  final double fovStart;
  /// 结束视野系数（用缩放近似 FOV）
  final double fovEnd;
  /// Z 轴起始位移（负值靠近，正值远离）
  final double zStart;
  /// Z 轴结束位移（负值靠近，正值远离）
  final double zEnd;
  final Alignment alignmentStart;
  final Alignment alignmentEnd;

  DollyZoomAnimation({
    this.perspective = 0.0015, // 透视强度
    this.fovStart = 1.1,      // 起始缩放（FOV 映射）
    this.fovEnd = 0.7,        // 结束缩放（FOV 映射）
    this.zStart = -120.0,      // 起始 Z 位移（靠近）
    this.zEnd = 100,         // 结束 Z 位移（远离）
    this.alignmentStart = Alignment.center,
    this.alignmentEnd = const Alignment(0, -0.7),  // 结束时向上偏移
    Duration duration = const Duration(seconds: 3),
  }) : super(
          name: '变焦镜头/眩晕效果',
          curve: Curves.easeInOut,
          duration: duration, // 动画时长
        );

  @override
  Widget buildAnimation(BuildContext context, Animation<double> animation, Widget child) {
    final t = curve.transform(animation.value); // 动画进度（0→1）
    final baseScale = ui.lerpDouble(fovStart, fovEnd, t)!; // 缩放近似 FOV 变化
    final z = ui.lerpDouble(zStart, zEnd, t)!; // Z 轴位移插值

    // 插值计算 alignment
    final alignX = ui.lerpDouble(alignmentStart.x, alignmentEnd.x, t)!;
    final alignY = ui.lerpDouble(alignmentStart.y, alignmentEnd.y, t)!;
    
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, perspective) // 设置透视
        ..translate(0.0, 0.0, z)      // 镜头前进/后退
        ..scale(baseScale),               // 同步反向缩放
      alignment: Alignment(alignX, alignY),
      child: child,
    );
  }
}


/// 平移
class TranslationAnimation extends MVAnimation {
  /// 位移基础百分比（相对父尺寸，例如 0.03 表示 3%）
  final double basePercent;
  /// 前景速度倍数（前景层速度加快）
  final double foregroundSpeed;
  /// 背景速度倍数（背景层速度减慢）
  final double backgroundSpeed;
  /// 位移方向（支持 8 个方向）：
  /// Alignment.centerLeft/centerRight/topCenter/bottomCenter/
  /// topLeft/topRight/bottomLeft/bottomRight
  final Alignment direction;

  TranslationAnimation({
    this.basePercent = 0.03,
    this.foregroundSpeed = 1.5,
    this.backgroundSpeed = 0.5,
    this.direction = Alignment.centerLeft,
    Duration? duration,
  }) : super(
          name: '平移',
          curve: Curves.easeInOut,
          duration: duration ?? const Duration(seconds: 3),
        );

  @override
  Widget buildAnimation(BuildContext context, Animation<double> animation, Widget child) {
    final t = curve.transform(animation.value);
    final tx = direction.x * basePercent * t;
    final ty = direction.y * basePercent * t;
    final pX = (direction.x * basePercent).abs();
    final pY = (direction.y * basePercent).abs();
    final coverScale = 1.0 + 2.0 * max(pX, pY);
    return Transform.scale(
      scale: coverScale,
      alignment: Alignment.center,
      child: FractionalTranslation(
        translation: Offset(tx, ty),
        child: child,
      ),
    );
  }
}
