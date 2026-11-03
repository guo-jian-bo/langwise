import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'board_paper_noise_layer.dart';

class BoardSchoolTimesWidget extends StatelessWidget {
  final Widget? child;

  /// 学校时光
  const BoardSchoolTimesWidget({super.key, this.child});

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
                SizedBox(height: 24.wMin),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.5),
                      width: 0.8.wMin,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(top: 20.wMin),
                        child: Column(
                          spacing: 2.wMin,
                          children: [
                            Text(
                              "Opinion",
                              style: TextStyle(
                                fontSize: 20.wMin,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withValues(alpha: 0.75),
                              ),
                            ),
                            Container(
                              width: 32.wMin,
                              height: 1.wMin,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(32.wMin),
                        child: child,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Column(
      children: [
        Container(
          height: 0.7.wMin,
          color: Colors.black.withValues(alpha: 0.5),
        ),
        SizedBox(height: 10.wMin),
        Text(
          "THE SCHOOL TIMES",
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w400,
            color: Colors.black.withValues(alpha: 0.85),
            fontFamily: "SourceSerif4",
          ),
        ),
        SizedBox(height: 10.wMin),
        Container(
          height: 0.7.wMin,
          color: Colors.black.withValues(alpha: 0.5),
        ),
        SizedBox(height: 2.wMin),
        Container(
          height: 0.7.wMin,
          color: Colors.black.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}
