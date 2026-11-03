import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../bindings/manage_review_ass_binding.dart';
import '../controllers/manage_review_ass_controller.dart';

class ManageReviewAssView extends GetView<ManageReviewAssController> {
  final String tagText;
  const ManageReviewAssView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_REVIEW_ASS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageReviewAssView(tagText: tag),
      binding: ManageReviewAssBinding(tag: tag),
      routeName: Routes.MANAGE_REVIEW_ASS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: _buildListWidget(context),
    );
  }

  Widget _buildListWidget(BuildContext context){

    return Obx((){
      if(controller.loadStatus.value == -1){
        return Container();
      }
      if(controller.taskList.isEmpty){
        return _buildEmptyWidget(context);
      }
      return ListView.separated(
        itemCount: controller.taskList.length,
        padding: EdgeInsets.all(40.wMin),
        separatorBuilder: (context, index) {
          return SizedBox(height: 16.wMin);
        },
        itemBuilder: (context, index) {
          return _buildListItemWidget(controller.taskList[index], index);
        },
      );
    });

  }

  Widget _buildEmptyWidget(BuildContext context){
    if(controller.isSubConditionQuery.value){
      return const NotDataWidget(
        message: "暂无任务",
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/svg/public/not_data.svg",
          width: 200.wMin,
        ),
        Text(
          "没有待审核的字幕",
          style: TextStyle(
            fontSize: 32.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "所有字幕都已审核完成",
          style: TextStyle(
            fontSize: 32.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 50.wMin),
        ButtonWidget(
          text: "再审核一批",
          height: 58.wMin,
          width: 180.wMin,
          borderRadius: 6.wMin,
          color: AppTheme.cSurfaceBrand.color,
          sclae: 1.03,
          fontSize: 24.wMin,
          fontColor: Colors.white,
          onTap: () {
            controller.getAssTaskAnotherBatch();
          },
          
        ),
      ],
    );

  }


  Widget _buildListItemWidget(AssTaskEntityList data, int index){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTagWidget(data),
          SizedBox(height: 8.wMin),
          _buildContentWidget(data),
      
          SizedBox(height: 8.wMin),
           _buildBottomWidget(data),
        ],
      ),
    );
  }

  Widget _buildTagWidget(AssTaskEntityList data){
    ElementsCardColor? typeColor = StatusUtils.getElementsCardColor(data.contentType);
    
    return Row(
      spacing: 8.wMin,
      children: [
        ManageTagFS16Widget(
          tag: data.contentType,
          bgColor: typeColor?.color1,
        ),
        StatusTagDifficultyWidget(
          difficulty: data.difficulty,  
          fontSize: 16.wMin,
          language: "en",
        ),
        Container(width: 1.wMin, height: 18.wMin, color: AppTheme.cBorderTertiary.color),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: AppTheme.cSurfaceQuaternary.color,
          ),
          child: Row(
            spacing: 4.wMin,
            children: [
              SvgPicture.asset(
                "assets/svg/public/icon_clock_w.svg",
                width: 18.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
              ),
              SelectableText(
                "${data.duration??0}s",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        ManageTagFS16Widget(
          tag: data.mediaTypeEnum.name,
          fontColor: data.mediaTypeEnum.color,
        ),
        ManageTagFS16Widget(
          tag: data.stageEnum.name,
          fontColor: data.stageEnum.color,
        ),

      ],
    );
  }

  Widget _buildContentWidget(AssTaskEntityList data){
    return SelectableText(
      data.content??"",
      style: TextStyle(
        fontSize: 24.wMin,
        fontWeight: FontWeight.w500,
        color: AppTheme.cTextPrimary.color,
      ),
    );
  }


  Widget _buildBottomWidget(AssTaskEntityList data){
    return Container(
      padding: EdgeInsets.only(top: 16.wMin),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color)),
      ),
      child: Row(
        children: [

          SelectableText(
            "任务UID：${data.taskId??''}",
            style: TextStyle(
              fontSize: 14.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 8.wMin),
          Container(width: 1.wMin, height: 20.wMin, color: AppTheme.cBorderPrimary.color),
          SizedBox(width: 8.wMin),
          SelectableText(
            DateFormatUtil.formatStrtoStr(data.started, newPattern: "yyyy-MM-dd HH:mm"),
            style: TextStyle(
              fontSize: 14.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
          ),

          const Spacer(),

          ButtonWidget(
            text: "放弃任务",
            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
            height: 40.wMin,
            borderRadius: 6.wMin,
            color: AppTheme.cFeedbackErrorBackground.color,
            fontSize: 16.wMin,
            fontWeight: FontWeight.w500,
            fontColor: AppTheme.cFeedbackErrorText.color,
            sclae: 1.05,
            onTap: () {
              
            },
          ),

          Container(
            margin: EdgeInsets.only(left: 12.wMin),
            child: ButtonWidget(
              text: "审核字幕",
              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
              height: 40.wMin,
              borderRadius: 6.wMin,
              color: AppTheme.cSurfaceInfo.color,
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.05,
              onTap: () {
                controller.toReviewAss(data);
              },
            ),
          ),

        ],
      ),
    );
  }


}
