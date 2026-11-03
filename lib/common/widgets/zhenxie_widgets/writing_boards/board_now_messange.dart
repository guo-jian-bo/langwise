
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'board_paper_noise_layer.dart';

class BoardNowMessangeWidget extends StatelessWidget {
  final Widget? child;
  /// 新消息
  const BoardNowMessangeWidget({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.wMin),
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
                  child: SizedBox(
                    width: double.infinity,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        scrollbars: false, // 隐藏滚动条
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          bottom: 50.wMin,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBodyHeaderWidget(),
                            Container(
                              height: 1.wMin,
                              color: Colors.black.withValues(alpha: 0.1),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 50.wMin, vertical: 32.wMin),
                              child: child,
                            ),
                          ],
                        ),
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
      height: 48.wMin,
      padding: EdgeInsets.symmetric(horizontal: 50.wMin),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1.wMin,
        ),
      ),
      child: Row(
        children: [
          _buildTitleDotWidget(Color(0xffFB7185)),
          SizedBox(width: 8.wMin),
          _buildTitleDotWidget(Color(0xffFBBF24)),
          SizedBox(width: 8.wMin),
          _buildTitleDotWidget(Color(0xff00D492)),
          SizedBox(width: 14.wMin),
          Text(
            "Now message",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleDotWidget(Color color){
    return Container(
      width: 16.wMin,
      height: 16.wMin,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildBodyHeaderWidget(){
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 24.wMin,
        horizontal: 50.wMin,
      ),
      child: Column(
        spacing: 10.wMin,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "To：Tom",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
          Text(
            "Subject：Clubs",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

}