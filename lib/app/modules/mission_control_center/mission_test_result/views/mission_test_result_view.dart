import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../controllers/mission_test_result_controller.dart';
import 'mission_test_result_latitude_widget.dart';

class MissionTestResultView extends GetView<MissionTestResultController> {
  const MissionTestResultView({super.key});
  @override
  Widget build(BuildContext context) {
    print(controller.unitTestRecordId);
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.cBgBrand.color.withValues(alpha: 0.3),
              AppTheme.cBgBrand.color.withValues(alpha: 0),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildTitleWidget(context),
            SizedBox(height: 10.wMin),
            Expanded(
              child: Container(
                
                padding: EdgeInsets.symmetric(horizontal: 110.wMin),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40.wMin)),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Column(
                          children: [
                            _buildScoreWidget(),
                            SizedBox(height: 40.wMin),
                            const MissionTestResultLatitudeWidget(),
                            // SizedBox(height: 40.wMin),
                            // const UserEvaluationLevelOverallWidget(),
                            // SizedBox(height: 40.wMin),
                          ],
                        ),
                        SizedBox(height: 100.wMin + MediaQuery.of(context).padding.bottom),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 24.wMin),
          const BackWidget(title: "单元测试结果"),
        ],
      ),
    );
  }


  Widget _buildScoreWidget(){
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfacePrimary.color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(40.wMin),
      ),
      child: Column(
        children: [
          const EvaluationTitleWidget(title: "本次测试得分"),
          SizedBox(height: 20.wMin),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx((){
                return Text(
                  "${controller.resultDetail.value.score ?? 0}",
                  style: TextStyle(
                    fontSize: 100.wMin,
                    color: AppTheme.cFeedbackWarningText.color,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
              SizedBox(width: 10.wMin),
              Text(
                "分",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cFeedbackWarningText.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
