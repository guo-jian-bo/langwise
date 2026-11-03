import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/back_widget.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../views/today_plan_calender.dart';
import '../controllers/super_memo_calender_controller.dart';

class SuperMemoCalenderView extends GetView<SuperMemoCalenderController> {
  const SuperMemoCalenderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
        children: [
          _buildTitleWidget(context),
          Expanded(child: TodayPlanCalenderWidget()),
          SizedBox(height: 50.wMin)
        ],
      ),
    );
  }

    Widget _buildTitleWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24.wMin, left: 64.wMin, right: 72.wMin),
      child: Row(
        children: [
          const BackWidget(title: ""),
          const Spacer(),
          Row(
              children: [
                TapScaleWidget(
                  onTap: () {
                    controller.toUserEvaluationResult(context);
                  },
                  sclae: 1,
                  child: Container(
                    height: 40,
                    padding: EdgeInsets.only(left: 12.wMin, right: 8.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.wMin),
                      color: AppTheme.cBgTertiary.color,
                    ),
                    child: Row(
                      spacing: 4.wMin,
                      children: [
                        Text(
                          "当前等级:",
                          style: TextStyle(
                            fontSize: 22.wMin,
                            color: AppTheme.cTextSecondary.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Level ${UserStore.to.userInfo.value.assessmentTier ?? 0}",
                          style: TextStyle(
                            fontSize: 22.wMin,
                            color: AppTheme.cTextSecondary.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SvgPicture.asset(
                          "assets/svg/public/icon_w_arrow_right.svg",
                          width: 24.wMin,
                          colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
