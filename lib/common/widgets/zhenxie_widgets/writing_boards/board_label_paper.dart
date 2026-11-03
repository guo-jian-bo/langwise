
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'board_paper_noise_layer.dart';

class BoardLabelPaperWidget extends StatelessWidget {
  final Widget? child;
  /// 标签纸
  const BoardLabelPaperWidget({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.wMin),
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
    return Container(
      height: 40.wMin,
      padding: EdgeInsets.only(bottom: 5.wMin),
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: Color(0xff0f766e),
      ),
      child: Container(
        width: 14.wMin,
        height: 14.wMin,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 2.wMin,
          ),
        ),
      ),
    );
  }

}