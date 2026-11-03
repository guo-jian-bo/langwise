import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/entities/entities.dart';
import '../../../management/common/commons.dart';
import '../controllers/zhenxie_task_exercise_controller.dart';

class ZhenxieTaskExerciseWidget extends StatelessWidget {
  final ZhenxieTaskExerciseController controller;

  /// 练习
  const ZhenxieTaskExerciseWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final exerciseList = controller.exerciseList.toList();
      if(controller.isLoading.value){
        return SpinKitFadingCircle(
          color: AppTheme.cBgBrand.color,
          size: 100.wMin,
        );
      }
      if(exerciseList.isEmpty && !controller.isLoading.value) {
        return NotDataWidget(message: "这篇范文还没有练习");
      }
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 32.wMin),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 32.wMin,
            children: List.generate(exerciseList.length, (index) {
              return _buildExerciseListWidget(exerciseList[index]);
            }),
          ),
        ),
      );
    });
  }

  /// 练习分组。
  Widget _buildExerciseListWidget(ZhenxieTaskExerciseItemEntity item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title ?? '',
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontTertiary.color,
          ),
        ),
        SizedBox(height: 8.wMin),
        _buildExerciseItemWidget(item),
      ],
    );
  }

  /// 练习卡片。
  Widget _buildExerciseItemWidget(ZhenxieTaskExerciseItemEntity item) {
    final accessEnum = AccessEnum.fromRawValue(item.exercise?.access ?? '');
    return TapScaleWidget(
      onTap: () {
        controller.toDoExercise(item);
      },
      sclae: 1,
      backColor: AppTheme.cZhenxieBackgroundPrimary.color,
      borderRadius: 12.wMin,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cZhenxieBackgroundPrimary.color,
          border: Border.all(
            color: AppTheme.cZhenxieBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.description ?? '',
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cZhenxieFontPrimary.color,
                    ),
                  ),
                ),
                SizedBox(width: 10.wMin),
                SvgPicture.asset(
                  "assets/svg/public/icon_w_arrow_right.svg",
                  width: 28.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cZhenxieFontTertiary.color, BlendMode.srcIn),
                ),
              ],
            ),
            SizedBox(height: 10.wMin),

            Wrap(
              spacing: 10.wMin,
              runSpacing: 6.wMin,
              children: [
                _buildTagWidget(
                  tag: item.inputModeLabel ?? '',
                  color: AppTheme.cSurfaceSuccess.color,
                  textColor: AppTheme.cSurfaceSuccess.color,
                ),
                _buildTagWidget(
                  tag: "${item.exercise?.questions?.length ?? 0} 题",
                  color: AppTheme.cZhenxieBorderPrimary.color,
                  textColor: AppTheme.cZhenxieFontTertiary.color,
                ),
                if(controller.pageController().isManagement) ...[
                  _buildTagWidget(
                    tag: accessEnum.label,
                    color: accessEnum.color,
                    textColor: accessEnum.color,
                  ),
                  CopyTagWidget(
                    name: "题目",
                    value: item.exercise?.uid?.toString() ?? '',
                    isShow: item.exercise?.uid != null,
                  ),
                ],
                
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 标签。
  Widget _buildTagWidget({
    required String tag,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: color.withValues(alpha: 0.12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 0.5.wMin,
        ),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
