
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../../common/manage_zhendu_widgets.dart';
import '../controllers/manage_storyboard_workbench_controller.dart';

class ManageStoryboardWorkbenchPromptWidget extends StatelessWidget {
  final ManageStoryboardWorkbenchController controller;
  const ManageStoryboardWorkbenchPromptWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 830.wMin,
      child: Obx((){
        if(controller.sceneData.value.promptId == null){
          return _buildNotWidget();
        }
        return Column(
          spacing: 16.wMin,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  color: AppTheme.cSurfacePrimary.color,
                ),
                child: _buildPromptWidget(),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  color: AppTheme.cSurfacePrimary.color,
                ),
                child: _buildReferenceImageWidget(context),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNotWidget(){

    return Container(
      alignment: Alignment.center,
      child: NotDataWidget(
        message: "请先生成提示词",
        other: SizedBox(
          width: 300.wMin,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaVisualProjectStoryboardSheetPromptGenerate],
            margin: EdgeInsets.only(right: 24.wMin),
            child: ButtonWidget(
              text: "生成提示词",
              padding: EdgeInsets.symmetric(horizontal: 48.wMin, vertical: 8.wMin),
              borderRadius: 8.wMin,
              sclae: 1.03,
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
              fontColor: AppTheme.cSurfaceBrand.color,
              fontSize: 20.wMin,
              onTap: OptimizeUtils.noneThrottle(() {
                controller.generatePrompt();
              }, 300),
            ),
          ),
        ),
      ),
    );

  }

  Widget _buildPromptWidget(){
    return Obx((){
      if(controller.sceneData.value.promptId == null) return Container();
      return Column(
        children: [
      
          Row(
            children: [
              Text(
                "Prompt文本",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              const Spacer(),
              ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.dramaVisualProjectStoryboardSheetPromptGenerate],
                child: ButtonWidget(
                  text: "生成提示词",
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                  height: 40.wMin,
                  borderRadius: 8.wMin,
                  sclae: 1.03,
                  color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                  border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
                  fontColor: AppTheme.cSurfaceBrand.color,
                  fontSize: 20.wMin,
                  onTap: OptimizeUtils.noneThrottle(() {
                    controller.generatePrompt();
                  }, 300),
                ),
              ),
              SizedBox(width: 16.wMin),
              ButtonWidget(
                text: "复制提示词",
                height: 40.wMin,
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                color: Colors.transparent,
                borderRadius: 6.wMin,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderTertiary.color),
                fontColor: AppTheme.cTextPrimary.color,
                fontSize: 18.wMin,
                sclae: 1.03,
                onTap: (){
                  if(controller.promptInput.text.isEmpty) return ToastUtils.showToast(text: "提示词为空，复制失败");
                  Clipboard.setData(ClipboardData(text: controller.promptInput.text));
                  ToastUtils.showToast(text: "复制成功", type: ToastType.success);
                },
              ),
              SizedBox(width: 16.wMin),
              
              Visibility(
                visible: !controller.isEditPrompt.value,
                child: ButtonWidget(
                  text: "修改提示词",
                  height: 40.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                  color: Colors.transparent,
                  borderRadius: 6.wMin,
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderTertiary.color),
                  fontColor: AppTheme.cTextPrimary.color,
                  fontSize: 18.wMin,
                  sclae: 1.03,
                  onTap: (){
                    controller.isEditPrompt.value = true;
                  },
                ),
              ),
              Visibility(
                visible: controller.isEditPrompt.value,
                child: ButtonWidget(
                  text: "保存提示词",
                  height: 40.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                  color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
                  borderRadius: 6.wMin,
                  border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSuccess.color),
                  fontColor: AppTheme.cSurfaceSuccess.color,
                  fontSize: 18.wMin,
                  sclae: 1.03,
                  onTap: (){
                    controller.savePrompt();
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 10.wMin),
      
          Expanded(
            child: ManageZhenduInputHeightWidget(
              hintText: "输入Prompt文本",
              height: 300.wMin,
              maxLines: 20,
              controller: controller.promptInput,
              readOnly: !controller.isEditPrompt.value,
              fillColor: !controller.isEditPrompt.value ? Colors.transparent : AppTheme.cSurfaceTertiary.color,
              borderColor: AppTheme.cBorderSecondary.color,
            ),
          ),
        ],
      );
    });
  }


  /// 参考图片
  Widget _buildReferenceImageWidget(BuildContext context){
    return Obx((){
      if(controller.sceneData.value.promptId == null) return Container();
      List<ManageVisualProjectPromptEntityReferenceImages?> referenceImages = controller.promptEntity.value.referenceImages??[];
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cSurfacePrimary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "原始参考图 (${referenceImages.length})",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                    Text(
                      "这些图会以锁定状态带去统一图片创建页，后续只能新增，不能删除",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextTertiary.color,
                      ),
                    ),

                  ],
                ),
                const Spacer(),
                ButtonWidget(
                  text: "打包下载",
                  height: 40.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                  color: Colors.transparent,
                  borderRadius: 6.wMin,
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderBrand.color),
                  fontColor: AppTheme.cTextBrand.color,
                  fontSize: 18.wMin,
                  sclae: 1.01,
                  onTap: (){
                    controller.downloadPromptImages();
                  },
                ),
              ],
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(
                top: 10.wMin,
                bottom: 10.wMin,
              ),
              child: IntrinsicHeight(
                child: Row(
                  spacing: 16.wMin,
                  children: List.generate(referenceImages.length, (index){
                    return _buildReferenceImageItemWidget(context, referenceImages[index]);
                  }),
                ),
              ),
            ),

          ],
        ),
      );
    });
  }


  Widget _buildReferenceImageItemWidget(BuildContext context, ManageVisualProjectPromptEntityReferenceImages? data){
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.wMin),
      child: Container(
        width: 200.wMin,
        color: AppTheme.cSurfaceSecondary.color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            SizedBox(
              width: 200.wMin,
              height: 200.wMin,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: TapScaleWidget(
                      onTap: () {
                        if(data?.url == null) return;
                        ShowBigResourceDialog.showImage(context: context, imageUrls: [data!.url!]);
                      },
                      sclae: 1,
                      child: CachedImageWidget(
                        data?.url??"",
                        fit: BoxFit.cover,
                        placeholder: buildEmptyWidget(),
                        errorWidget: buildEmptyWidget(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 4.wMin,
                    top: 4.wMin,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4.wMin,
                      children: [
                        ManageTagFS16Widget(
                          tag: "ref_${data?.refNo??''}",
                          fontColor: AppTheme.cTextSecondary.color,
                        ),
                        Visibility(
                          visible: data?.imageId != null,
                          child: ManageTagFS16Widget(
                            tag: "uid: ${data?.imageId??''}",
                            fontColor: AppTheme.cTextSecondary.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 10.wMin),
              child: Text(
                controller.getImageName(data),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
            ),
      
          ],
        ),
      ),
    );
  }




}