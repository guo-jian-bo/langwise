
import 'package:flutter/cupertino.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../theme/theme.dart';
import '../controllers/plan_details_controller.dart';

class PlanDetailsBoxWidget extends StatelessWidget {
  final Widget child;
  final int step;
  final String title;
  final PlanDetailsController controller;
  const PlanDetailsBoxWidget({super.key, required this.child, required this.step, required this.title, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 640.wMin,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase2.color,
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        children: [
          _buildTitleWidget(),
          SizedBox(height: 16.wMin),
          Container(
            height: 1.wMin,
            width: double.infinity,
            color: AppTheme.cBorderDefault.color,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(){
    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(controller.specialty??"");
    return Row(
      spacing: 8.wMin,
      children: [
        Container(
          width: 42.wMin,
          height: 42.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cSurfaceQuaternary.color,
            border: Border.all(
              color: courseColor.color1,
              width: 1.wMin,
            ),
          ),
          child: Text(
            step.toString(),
            style: TextStyle(
              color: courseColor.color1,
              fontSize: 18.wMin,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "STEP $step",
              style: TextStyle(
                color: AppTheme.cTextSecondary.color,
                fontSize: 12.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.cTextPrimary.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

      ],
    );
  }

}