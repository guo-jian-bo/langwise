import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class MissionControlCenterStatisticsDialog{

  /// 显示任务统计弹窗
  /// [missionDurationAvg] 任务平均用时
  /// [missionScoreAvg] 任务平均得分
  /// [duration] 任务总用时
  /// [missionPoints] 总获得学点
  static Future<void> show({
    required BuildContext context,
    required String missionDurationAvg,
    required String missionScoreAvg,
    required String duration,
    required String missionPoints,
  }) async{
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return MissionControlCenterStatisticsDialogWidget(
          missionDurationAvg: missionDurationAvg,
          missionScoreAvg: missionScoreAvg,
          duration: duration,
          missionPoints: missionPoints,
        );
      },
    );
  }

}


class MissionControlCenterStatisticsDialogWidget extends StatefulWidget {
  final String missionDurationAvg;
  final String missionScoreAvg;
  final String duration;
  final String missionPoints;
  final bool showBackColor;
  const MissionControlCenterStatisticsDialogWidget({
    super.key, 
    required this.missionDurationAvg, 
    required this.missionScoreAvg, 
    required this.duration, 
    required this.missionPoints,
    this.showBackColor = true,
  });

  @override
  State<MissionControlCenterStatisticsDialogWidget> createState() => _MissionControlCenterStatisticsDialogWidgetState();
}

class _MissionControlCenterStatisticsDialogWidgetState extends State<MissionControlCenterStatisticsDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !widget.showBackColor ? null : () => Navigator.pop(context),
      child: Material(
        color: widget.showBackColor ? Colors.transparent : AppTheme.cOverlayBackground.color,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 40.wMin,
            children: [
              _buildStatisticsItemWidget(
                title: "任务平均用时",
                value: widget.missionDurationAvg,
                color: AppTheme.cMorphemeTagInfix.color,
              ),
              _buildStatisticsItemWidget(
                title: "任务平均得分",
                value: widget.missionScoreAvg,
                color: AppTheme.cFeedbackInfoIcon.color,
              ),
              _buildStatisticsItemWidget(
                title: "任务总用时",
                value: widget.duration,
                color: AppTheme.cFeedbackSuccessIcon.color,
              ),
              _buildStatisticsItemWidget(
                title: "总获得学点",
                value: widget.missionPoints,
                color: AppTheme.cFeedbackWarningIcon.color,
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildStatisticsItemWidget({
    required String title,
    required String value,
    required Color color,
  }){
    return Container(
      width: 370.wMin,
      height: 200.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: AppTheme.cBgSecondary.color,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 72.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.wMin),
                topRight: Radius.circular(24.wMin),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 32.wMin,
                color: AppTheme.cStaticWhite.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 64.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

}