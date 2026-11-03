
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_auth_box_widget.dart';
import 'package:langwise/app/modules/management/manage_content/manage_zhendu_console/common/manage_zhendu_widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../utils/utils.dart';
import '../controllers/manage_unified_image_crop_controller.dart';

class ManageUnifiedImageCropSettingWidget extends StatelessWidget {
  final ManageUnifiedImageCropController controller;
  
  const ManageUnifiedImageCropSettingWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            "裁剪工具箱",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 16.wMin),
          _buildRatioSelectorWidget(),
          SizedBox(height: 16.wMin),
          _buildTargetSizeWidget(),
          SizedBox(height: 16.wMin),
          _buildOutputTargetSizeEstimateWidget(),
          const Spacer(),
          _buildButtonWidget(context),
        ],
      ),
    );
  }


  /// 比例选择器
  Widget _buildRatioSelectorWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6.wMin,
      children: [
        SelectableText(
          "比例",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.aspectRatioList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 6.wMin,
            crossAxisSpacing: 6.wMin,
            mainAxisExtent: 44.wMin,
          ),
          itemBuilder: (context, index) {

            String text = "Any";
            if(controller.aspectRatioList[index] != null){
              text = controller.aspectRatioList[index]!.name;
            }

            return Obx((){
              bool isEnable = controller.isFixedAspectRatio.value && controller.aspectRatioList[index] == controller.aspectRatio.value;
              if(controller.sceneType != null){
                isEnable = controller.sceneType == SceneStoryboardTypeEnum.storyboard_sheet;
              }
              return _buildItemWidget(
                text: text,
                isSelected: controller.aspectRatio.value == controller.aspectRatioList[index],
                isEnable: isEnable,
                onTap: () {
                  controller.switchAspectRatio(controller.aspectRatioList[index]);
                },
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildItemWidget({
    required String text,
    bool isSelected = false,
    bool isEnable = true,
    void Function()? onTap,
  }){
    return IgnorePointer(
      ignoring: !isEnable,
      child: Opacity(
        opacity: isEnable ? 1 : 0.6,
        child: TapScaleWidget(
          onTap: onTap,
          sclae: 1.01,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: isSelected ? AppTheme.cSurfaceBrand.color : AppTheme.cSurfaceSecondary.color,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.cTextPrimary.color,
              ),
            ),
          ),
        ),
      ),
    );
  }


  /// 目标size
  Widget _buildTargetSizeWidget(){
    return Row(
      spacing: 16.wMin,
      children: [
        Expanded(
          child: ManageZhenduNumberInputWidget(
            title: "目标宽度",
            controller: controller.targetWidthController,
            jumpValue: 1,
            isInt: true,
            onChanged: (p0) {
              controller.syncByTargetHeight();
            },
          ),
        ),
        Expanded(
          child: ManageZhenduNumberInputWidget(
            title: "目标高度",
            controller: controller.targetHeightController,
            jumpValue: 1,
            isInt: true,
            onChanged: (p0) {
              controller.syncByTargetHeight();
            },
          ),
        ),
      ],
    );
  }

  /// 输出预估目标size
  Widget _buildOutputTargetSizeEstimateWidget(){
    return Obx((){
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cSurfaceSecondary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6.wMin,
          children: [
            SelectableText(
              "输出预估",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),

            SelectableText(
              "裁剪原始尺寸: ${controller.imageSizeSize.value.width.toInt()} × ${controller.imageSizeSize.value.height.toInt()}",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            SelectableText(
              "实际超分尺寸: ${controller.actualUpscaleSize.value.width.toInt()} × ${controller.actualUpscaleSize.value.height.toInt()}",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),

            SelectableText(
              "按 height 同比超分，width 会按比例向上规整到 32 的倍数。",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            
          ],
        ),
      );
    });
  }


  Widget _buildButtonWidget(BuildContext context){
    return Row(
      spacing: 16.wMin,
      children: [
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.adminContentReviewImageCropUndo],
          child: Expanded(
            child: ButtonWidget(
              text: "撤销裁剪",
              height: 48.wMin,
              borderRadius: 8.wMin,
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(
                color: AppTheme.cBorderSecondary.color,
                width: 1.wMin,
              ),
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              fontColor: AppTheme.cTextSecondary.color,
              sclae: 1.01,
              onTap: () {
                controller.undoCrop(context);
              },
            ),
          ),
        ),
        Expanded(
          child: ButtonWidget(
            text: "确认裁剪",
            height: 48.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceBrand.color,
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            fontColor: Colors.white,
            sclae: 1.01,
            onTap: () {
              controller.confirmCrop(context);
            },
          ),
        ),
      ],
    );
  }

}
