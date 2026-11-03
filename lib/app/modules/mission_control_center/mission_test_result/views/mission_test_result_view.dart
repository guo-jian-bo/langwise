import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../routes/routes.dart';
import '../bindings/mission_test_result_binding.dart';
import '../controllers/mission_test_result_controller.dart';
import 'mission_test_result_latitude_widget.dart';

class MissionTestResultView extends GetView<MissionTestResultController> {
  final String tagText;
  const MissionTestResultView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => MissionTestResultView(tagText: tag),
      binding: MissionTestResultBinding(tagText: tag),
      routeName: Routes.MISSION_TEST_RESULT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }
  @override
  Widget build(BuildContext context) {
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
                            MissionTestResultLatitudeWidget(tagText: tagText),
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
    return const BreadcrumbWidget();
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
