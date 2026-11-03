

import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';
import '../controllers/memory_recorder_chart_controller.dart';

class MemoryRecorderChartView extends GetView<MemoryRecorderChartController> {
  const MemoryRecorderChartView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.5],
            colors: [
              AppTheme.cMemberPrimary.color.withValues(alpha: 0.3),
              AppTheme.cMemberPrimary.color.withValues(alpha: 0),
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 24.wMin),
            _buildTitleWidget(),
            Expanded(
              child: Center(
                child: SizedBox(
                  height: 600.wMin,
                  child: _buildChartWidget(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.wMin),
      child: const Row(
        children: [
          BackWidget(title: "超级记忆记录"),
          
        ],
      ),
    );
  }

  Widget _buildChartWidget(){
    return ChartWidget(
      coordinateRender: ChartDimensionsCoordinateRender(
        margin: EdgeInsets.symmetric(horizontal: 100.wMin, vertical: 20.wMin),
        padding: EdgeInsets.symmetric(horizontal: 50.wMin),
        // animationDuration: const Duration(milliseconds: 800),
        onClickChart: (context, list) {
          int? selectIndex = list.first.selectedIndex;
          if(selectIndex == null) return;
          controller.showInfoTip(context, selectIndex, list.first.children[selectIndex].originRect);
        },
        yAxis: [
          YAxis(
            min: 0,
            max: 15,
            drawGrid: true,
            drawDivider: true,
            lineColor: AppTheme.cBorderPrimary.color,
            textStyle: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        xAxis: XAxis(
          count: 10,
          max: 15,
          lineColor: AppTheme.cBorderPrimary.color,
          formatter: (index) {
            return "$index";
          },
          textStyle: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        charts: [
          StackBar<int>(
            data: [8 ,10 ,11, 12, 13, 8 ,10 ,11, 12, 13, 8 ,10 ,11, 12, 13],
            position: (p0, index) {
              return index + 0.15;
            },
            itemWidth: 56.wMin,
            highlightColor: AppTheme.cMemberPrimary.color, // 选中的颜色
            hotColor: AppTheme.cWhiteAlpha10.color,
            colors: [AppTheme.cMemberPrimary.color],
            values: (item) => [
              item.toDouble(),
            ],
          ),
          Line<int>(
            data: [10 ,10 ,11, 12, 13, 8 ,10 ,11, 12, 13, 8 ,10 ,11, 12, 13, 15],
            colors: [AppTheme.cMemberPrimary.color],
            strokeWidth: 4.wMin,
            isCurve: true,
            position: (p0, index) {
              return index;
            },
            values: (item) => [
              item.toDouble(),
            ],
          ),
          Line<int>(
            data: [14 ,14 ,13, 12, 11, 10 ,9 ,8, 7, 6, 5 ,4 ,3, 3, 3, 3],
            colors: [AppTheme.cMemberPrimary.color],
            strokeWidth: 4.wMin,
            isCurve: true,
            position: (p0, index) {
              return index;
            },
            values: (item) => [
              item.toDouble(),
            ],
          ),

          
        ],
      ),
    );
  }

  


}
