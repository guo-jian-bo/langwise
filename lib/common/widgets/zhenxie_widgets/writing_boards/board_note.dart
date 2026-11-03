import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'board_stick_in_animation.dart';

class BoardNoteWidget extends StatelessWidget {
  /// 便签内容
  final Widget? child;

  /// 是否显示入场动画
  final bool showAnimation;

  /// 便签
  const BoardNoteWidget({
    super.key,
    this.child,
    this.showAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 1,
        child: BoardStickInAnimation(
          showAnimation: showAnimation,
          beginOffsetY: -30.wMin,
          beginScale: 1.08,
          middleScale: 0.97,
          beginRotationAngle: -3.2 * pi / 180,
          endRotationAngle: -1.5 * pi / 180,
          builder: (context, rotationAngle) {
            return Padding(
              padding: EdgeInsets.fromLTRB(18.wMin, 16.wMin, 18.wMin, 22.wMin),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Positioned.fill(
                    child: Transform.rotate(
                      angle: rotationAngle,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xffF3DF8B),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff431407).withValues(alpha: 0.10),
                              offset: const Offset(0, 10),
                              blurRadius: 11.6,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xffffffff).withValues(alpha: 0.10),
                                        const Color(0xffffffff).withValues(alpha: 0.03),
                                        const Color(0xffffffff).withValues(alpha: 0),
                                      ],
                                      stops: const [0, 0.24, 0.52],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context).copyWith(
                                    scrollbars: false, // 隐藏滚动条
                                  ),
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets.symmetric(horizontal: 50.wMin, vertical: 50.wMin),
                                    child: SizedBox(child: child),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -34.wMin,
                    child: Transform.rotate(
                      angle: 1.2 * pi / 180,
                      child: _BoardNoteTapeWidget(
                        width: 182.wMin,
                        height: 58.wMin,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BoardNoteTapeWidget extends StatelessWidget {
  final double width;
  final double height;
  /// 便签顶部纸胶带
  const _BoardNoteTapeWidget({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _BoardNoteTapePainter(
        width: width,
        height: height,
      )),
    );
  }
}

class _BoardNoteTapePainter extends CustomPainter {
  final double width;
  final double height;
  _BoardNoteTapePainter({
    required this.width,
    required this.height,
  }); 



  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _buildTapePath(size);
    canvas.drawShadow(path, const Color(0xff000000).withValues(alpha: 0.25), 1.5, false);
    final Paint paint = Paint()..color = const Color(0xffFB923C);
    canvas.drawPath(path, paint);
  }

  /// 根据 SVG 路径绘制胶带外轮廓
  Path _buildTapePath(Size size) {
    final double scaleX = size.width / 182;
    final double scaleY = size.height / 58;

    return Path()
      ..moveTo(0.763447 * scaleX, 8.85394 * scaleY)
      ..cubicTo(
        -0.843829 * scaleX,
        7.25047 * scaleY,
        0.250662 * scaleX,
        4.50237 * scaleY,
        2.52023 * scaleX,
        4.44294 * scaleY,
      )
      ..lineTo(172.153 * scaleX, 0.000960128 * scaleY)
      ..cubicTo(
        174.27 * scaleX,
        -0.0544774 * scaleY,
        175.55 * scaleX,
        2.3212 * scaleY,
        174.34 * scaleX,
        4.05923 * scaleY,
      )
      ..lineTo(166.778 * scaleX, 14.9199 * scaleY)
      ..cubicTo(
        165.895 * scaleX,
        16.1891 * scaleY,
        166.317 * scaleX,
        17.9451 * scaleY,
        167.681 * scaleX,
        18.674 * scaleY,
      )
      ..lineTo(179.239 * scaleX, 24.8518 * scaleY)
      ..cubicTo(
        180.611 * scaleX,
        25.5853 * scaleY,
        181.029 * scaleX,
        27.3565 * scaleY,
        180.128 * scaleX,
        28.6252 * scaleY,
      )
      ..lineTo(173.382 * scaleX, 38.1279 * scaleY)
      ..cubicTo(
        172.827 * scaleX,
        38.9097 * scaleY,
        172.751 * scaleX,
        39.9344 * scaleY,
        173.184 * scaleX,
        40.7897 * scaleY,
      )
      ..lineTo(176.768 * scaleX, 47.8707 * scaleY)
      ..cubicTo(
        177.624 * scaleX,
        49.5626 * scaleY,
        176.426 * scaleX,
        51.5698 * scaleY,
        174.531 * scaleX,
        51.6195 * scaleY,
      )
      ..lineTo(5.07048 * scaleX, 56.057 * scaleY)
      ..cubicTo(
        2.6455 * scaleX,
        56.1205 * scaleY,
        1.47819 * scaleX,
        53.1086 * scaleY,
        3.3126 * scaleX,
        51.5213 * scaleY,
      )
      ..lineTo(8.39279 * scaleX, 47.1255 * scaleY)
      ..cubicTo(
        9.4005 * scaleX,
        46.2535 * scaleY,
        9.57953 * scaleX,
        44.7581 * scaleY,
        8.80614 * scaleX,
        43.6729 * scaleY,
      )
      ..lineTo(0.846092 * scaleX, 32.5036 * scaleY)
      ..cubicTo(
        0.205568 * scaleX,
        31.6049 * scaleY,
        0.206793 * scaleX,
        30.3985 * scaleY,
        0.84914 * scaleX,
        29.501 * scaleY,
      )
      ..lineTo(8.15872 * scaleX, 19.2884 * scaleY)
      ..cubicTo(
        8.89489 * scaleX,
        18.2598 * scaleY,
        8.77801 * scaleX,
        16.8495 * scaleY,
        7.88257 * scaleX,
        15.9562 * scaleY,
      )
      ..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
