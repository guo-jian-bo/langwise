import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../controllers/mission_special_controller.dart';
import 'mission_special_card_widget.dart';

class MissionSpecialView extends GetView<MissionSpecialController> {
  const MissionSpecialView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget(context),
          Expanded(child: _buildListWidget(context)),
          
        ],
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16.wMin,
        bottom: 16.wMin,
        left: 40.wMin,
        right: 40.wMin,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.wMin,
        children: [
          const BackWidget(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.wMin),
              Obx((){
                return Text(
                  controller.taskSpecial.value.title??"",
                  style: TextStyle(
                    fontSize: 32.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
              Obx((){

                // 全部任务
                int allCount = controller.taskSpecial.value.allCount ?? 0;
                // 新任务
                int newCount = controller.nowTaskCount.value;
                // 已完成
                // int completedCount = controller.completedCount.value;

                return Text(
                  "共 $allCount 个任务 · $newCount 个新任务",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListWidget(BuildContext context){
    return Obx((){

      if(controller.dataStatus.value == 1){
        return const NotDataWidget(
          message: "暂无任务",
        );
      }

      return GridView.builder(
        padding: EdgeInsets.only(
          left: 70.wMin,
          right: 70.wMin,
          top: MediaQuery.of(context).padding.top + 24.wMin,
          bottom: MediaQuery.of(context).padding.bottom + 24.wMin,
        ),
        itemCount: controller.taskSpecialList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 32.wMin,
          crossAxisSpacing: 32.wMin,
          mainAxisExtent: 240.wMin,
        ),
        itemBuilder: (context, index){
          TaskMissionMenuListEntityList item = controller.taskSpecialList[index];
          return MissionSpecialCardWidget(
            index: index,
            data: item,
            onTap: (value) {
              controller.onTapItem(context, value);
            },
          );
        },
      );
    });
  }
  

}
