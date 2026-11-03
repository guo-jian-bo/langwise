import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'board_paper_noise_layer.dart';

class BoardSpeechWidget extends StatelessWidget {
  final Widget? child;

  /// 演讲纸
  const BoardSpeechWidget({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        child: BoardPaperNoiseLayer(
          darkColor: const Color(0xff6B7280),
          lightColor: const Color(0xffffffff),
          darkAlpha: 0.022,
          lightAlpha: 0.018,
          density: 420,
          minRadius: 0.22,
          maxRadius: 0.72,
          seedSalt: 19,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: 50.wMin,
              left: 50.wMin,
              right: 50.wMin,
              bottom: 50.wMin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitleWidget(),
                SizedBox(height: 32.wMin),
                SizedBox(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Text(
        "SPEECH",
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w500,
          color: Colors.black.withValues(alpha: 0.3),
          letterSpacing: 8.wMin,
        ),
      ),
    );
  }
}
