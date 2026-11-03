
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'board_paper_noise_layer.dart';

class BoardTitleBandPaper extends StatelessWidget {
  final Widget? child;

  /// 题签纸
  const BoardTitleBandPaper({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.wMin),
      child: ColoredBox(
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: BoardPaperNoiseLayer(
            darkColor: const Color(0xff6B7280),
            lightColor: const Color(0xffffffff),
            darkAlpha: 0.022,
            lightAlpha: 0.018,
            density: 420,
            minRadius: 0.22,
            maxRadius: 0.72,
            seedSalt: 19,
            child: Column(
              children: [
                _buildTitleWidget(),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      scrollbars: false, // 隐藏滚动条
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: 70.wMin,
                        left: 50.wMin,
                        right: 50.wMin,
                        bottom: 70.wMin,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 32.wMin),
                          SizedBox(child: child),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 64.wMin,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff0f766e),
                Color(0xff155e75),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -32.wMin,
          child: Container(
            width: 64.wMin,
            height: 64.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xfffef3c7),
            ),
            child: Text(
              "T",
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }


}