import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/manage_scaffold.dart';
import '../bindings/manage_review_exercises_statistics_binding.dart';
import '../controllers/manage_review_exercises_statistics_controller.dart';

class ManageReviewExercisesStatisticsView extends GetView<ManageReviewExercisesStatisticsController> {
  final String tagText;
  const ManageReviewExercisesStatisticsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_REVIEW_EXERCISES_STATISTICS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageReviewExercisesStatisticsView(tagText: tag),
      binding: ManageReviewExercisesStatisticsBinding(tag: tag),
      routeName: Routes.MANAGE_REVIEW_EXERCISES_STATISTICS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.wMin),
        child: Column(
          children: [
            SizedBox(height: 10.wMin),
            _buildHeardWidget(),
            SizedBox(height: 16.wMin),
            _buildStatisticsWidget(),
            SizedBox(height: 16.wMin),
            Expanded(child: _buildRankingWidget()),
          ],
        ),
      ),
    );
  }


  Widget _buildHeardWidget(){
    return Row(
      children: [
    
        Builder(
          builder: (context) {
            return TapScaleWidget(
              onTap: () {
                controller.filterTime(context);
              },
              sclae: 1.02,
              child: Container(
                height: 50.wMin,
                padding: EdgeInsets.only(left: 16.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: AppTheme.cSurfaceSecondary.color,
                  border: Border.all(
                    color: AppTheme.cBorderPrimary.color,
                    width: 1.wMin,
                  ),
                ),
                child: Obx((){
    
                  String startDate = "";
                  String endDate = "";
                  
                  if(controller.startDate.value == null || controller.endDate.value == null){
                    startDate = "开始日期";
                    endDate = "结束日期";
                  }else{
                    startDate = DateFormatUtil.formatStr(controller.startDate.value!);
                    endDate = DateFormatUtil.formatStr(controller.endDate.value!);
                  }
    
                  return Row(
                  children: [
                    Text(
                      "$startDate ～ $endDate",
                        style: TextStyle(
                          color: AppTheme.cTextPrimary.color,
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TapScaleWidget(
                        onTap: () {
                          controller.clearFilterTime();
                        },
                        sclae: 1.1,
                        child: Container(
                          width: 50.wMin,
                          height: 50.wMin,
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            "assets/svg/public/x.svg",
                            width: 28.wMin,
                          ),
                        ),
                        
                      ),
    
                    ],
                  );
                }),
              ),
            );
          },
        ),
    
        const Spacer(),
    
        Obx((){
          return ButtonWidget(
            text: "只看自己",
            height: 50.wMin,
            width: 120.wMin,
            borderRadius: 8.wMin,
            color: controller.selfOrAll.value == 0 ? const Color(0xff2388FF) : const Color(0xff353E5C),
            fontColor: Colors.white,
            fontSize: 20.wMin,
            fontWeight: FontWeight.w400,
            sclae: 1.05,
            onTap: () {
              controller.switchSelfOrAll(0);
            },
          );
        }),
    
        SizedBox(width: 10.wMin),
    
        Obx((){
          return ButtonWidget(
            text: "查看全部",
            height: 50.wMin,
            width: 120.wMin,
            borderRadius: 8.wMin,
            color: controller.selfOrAll.value == 1 ? const Color(0xff2388FF) : const Color(0xff353E5C),
            fontColor: Colors.white,
            fontSize: 20.wMin,
            fontWeight: FontWeight.w400,
            sclae: 1.05,
            onTap: () {
              controller.switchSelfOrAll(1);
            },
          );
        }),
    
      ],
    );
  }


  /// 统计
  Widget _buildStatisticsWidget(){
    return Obx((){
      return Row(
        spacing: 42.wMin,
        children: [
          _buildStatisticsItemWidget(
            fist: "总审核任务数",
            value: controller.statistics.value.totalTaskCount?.toString()??"0",
            last: "个任务",
            color: const Color(0xff2388FF),
          ),
          _buildStatisticsItemWidget(
            fist: "未审核任务数",
            value: controller.statistics.value.totalNoCheckedTaskCount?.toString()??"0",
            last: "个任务",
            color: const Color(0xff63DE77),
          ),
          _buildStatisticsItemWidget(
            fist: "被放弃任务数",
            value: controller.statistics.value.totalAbandonedTaskCount?.toString()??"0",
            last: "个任务",
            color: const Color(0xffFF2D46),
          ),
        ],
      );
    });
  }

  Widget _buildStatisticsItemWidget({
    required String fist,
    required String value,
    required String last,
    required Color color,
  }){
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.wMin),
          color: AppTheme.cSurfaceSecondary.color,
          border: Border.all(
            color: AppTheme.cBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              fist,
              style: TextStyle(
                color: AppTheme.cTextTertiary.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
            SelectableText(
              value,
              style: TextStyle(
                color: color,
                fontSize: 38.wMin,
                fontWeight: FontWeight.w600,
              ),
            ),
            SelectableText(
              last,
              style: TextStyle(
                color: AppTheme.cTextTertiary.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
      
          ],
        ),
      ),
    );
  }


  /// 排名
  Widget _buildRankingWidget(){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.wMin),
        ),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 20.wMin),
            child: Text(
              "审核员排名",
              style: TextStyle(
                color: AppTheme.cTextPrimary.color,
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Container(
            height: 1.wMin,
            color: AppTheme.cBorderPrimary.color,
          ),

          Expanded(
            child: Obx((){
              return ListView.separated(
                padding: EdgeInsets.only(
                  bottom: 120.wMin,
                ),
                itemCount: controller.rankingList.length,
                separatorBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.wMin),
                    height: 1.wMin,
                    color: AppTheme.cBorderPrimary.color,
                  );
                },
                itemBuilder: (context, index) {
                  return _buildRankingItemWidget(controller.rankingList[index], index);
                },
              );
            }),
          ),
          
        ],
      ),
    );
  }

  Widget _buildRankingItemWidget(ExerciseReviewStatisticsEntityAuditorStats item, int index){
    Color numColor = const Color(0xff353E5C);
    if(index == 0){
      numColor = const Color(0xffFF9E0D);
    }else if(index == 1){
      numColor = const Color(0xff929292);
    }else if(index == 2){
      numColor = const Color(0xff85592C);
    }

    return TapScaleWidget(
      onTap: () {
        controller.onTapRankingItem(item);
      },
      sclae: 1,
      backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.wMin, horizontal: 20.wMin),
        child: Row(
          children: [
            Container(
              constraints: BoxConstraints(
                minWidth: 50.wMin,
                minHeight: 50.wMin,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: numColor,
              ),
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
      
            SizedBox(width: 8.wMin),
      
            SelectableText(
              "${item.auditorName??''} (ID: ${item.userId??''})",
              style: TextStyle(
                color: AppTheme.cTextPrimary.color,
                fontSize: 26.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
      
            const Spacer(),
      
            _buildRankingItemColumnWidget(
              name: "任务通过",
              value: item.taskCount?.toString()??"0",
              color: const Color(0xff2388FF),
            ),
      
            SizedBox(width: 70.wMin),
      
            _buildRankingItemColumnWidget(
              name: "任务失败",
              value: item.failedTaskCount?.toString()??"0",
              color: const Color(0xffFF2D46),
            ),
      
          ],
        ),
      ),
    );
  }

  Widget _buildRankingItemColumnWidget({
    required String name,
    required String value,
    required Color color,
  }){
    return Column(
      children: [
        SelectableText(
          value,
          style: TextStyle(
            color: color,
            fontSize: 26.wMin,
            fontWeight: FontWeight.w500,
          ),
        ),

        SelectableText(
          name,
          style: TextStyle(
            color: AppTheme.cTextTertiary.color,
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
          ),
        ),


      ],
    );
  }


}
