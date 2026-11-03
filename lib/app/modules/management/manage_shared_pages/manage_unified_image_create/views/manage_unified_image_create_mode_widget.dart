
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/commons.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/enum/enum.dart';
import '../../../../../../theme/theme.dart';
import '../controllers/manage_unified_image_create_controller.dart';
import '../enums/manage_unified_image_create_enums.dart';

class ManageUnifiedImageCreateModeWidget extends StatelessWidget {
  final ManageUnifiedImageCreateController controller;
  const ManageUnifiedImageCreateModeWidget({super.key, required this.controller});

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
          _buildTabWidget(),
          SizedBox(height: 8.wMin),
          Expanded(child: _buildPromptWidget(context)),
        ],
      ),
    );
  }

  Widget _buildTabWidget(){
    return Row(
      spacing: 12.wMin,
      children: List.generate(GenerationModeEnum.values.length, (index) {
        return _buildTabItemWidget(GenerationModeEnum.values[index]);
      }),
    );
  }

  Widget _buildTabItemWidget(GenerationModeEnum modeEnum){
    return Obx((){
      /// 是否禁用编辑 
      // bool isDisabledImageEdit = modeEnum == GenerationModeEnum.imageEdit && (controller.referenceImages.isEmpty);
      bool isDisabledImageEdit = false;
      /// 是否禁用文生图
      bool isDisabledTextToImage = modeEnum == GenerationModeEnum.textToImage && (controller.referenceImages.isNotEmpty);

      // 是否禁用转换风格
      bool isDisabledConvertStyle = false;

      if(controller.sceneType != null){
        if(controller.sceneType == SceneStoryboardTypeEnum.storyboard_sheet){
          isDisabledTextToImage = modeEnum == GenerationModeEnum.textToImage;
          isDisabledImageEdit = modeEnum == GenerationModeEnum.imageEdit;
          isDisabledConvertStyle = modeEnum == GenerationModeEnum.convertStyle;
        }
      }

      // 是否禁用 复用提示词和转换风格
      bool isDisabledReusePromptAndConvertStyle = false;
      if(modeEnum == GenerationModeEnum.reusePrompt || modeEnum == GenerationModeEnum.convertStyle){
        if(controller.sceneType != null){
          if(controller.sceneType != SceneStoryboardTypeEnum.storyboard_sheet){
            isDisabledReusePromptAndConvertStyle = true;
          }
        }
      }

      bool isSelected = controller.generationMode.value == modeEnum;

      return IgnorePointer(
        ignoring: isDisabledImageEdit || isDisabledTextToImage || isDisabledReusePromptAndConvertStyle || isDisabledConvertStyle,
        child: Opacity(
          opacity: isDisabledImageEdit || isDisabledTextToImage || isDisabledReusePromptAndConvertStyle || isDisabledConvertStyle ? 0.5 : 1,
          child: TapScaleWidget(
            onTap: () {
              controller.switchGenerationMode(modeEnum);
            },
            sclae: 1.03,
            child: Container(
              padding: EdgeInsets.all(8.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: isSelected ? AppTheme.cSurfaceBrand.color : AppTheme.cSurfaceLayerElevated.color,
                border: Border.all(
                  color: isSelected ? AppTheme.cSurfaceBrand.color : AppTheme.cBorderDefault.color,
                  width: 1.wMin,
                ),
              ),
              child: Text(
                modeEnum.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.cTextPrimary.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPromptWidget(BuildContext context){
    

    return Obx((){
      GenerationModeEnum generationMode = controller.generationMode.value;
      // bool readOnly = generationMode == GenerationModeEnum.reusePrompt;
      bool isConvertStyle = generationMode == GenerationModeEnum.convertStyle;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visibility(
          //   visible: readOnly,
          //   child: ManageTagFS16Widget(
          //     tag: "只读 promptId: ${controller.imageDetail.value.promptId??''}",
          //     bgColor: AppTheme.cSurfaceWarning.withValues(alpha: 0.2),
          //     fontColor: AppTheme.cSurfaceWarning.color,
          //   ),
          // ),
          Visibility(
            visible: isConvertStyle,
            child: ManageTagFS16Widget(
              tag: "不需要输入 prompt",
              bgColor: AppTheme.cSurfaceWarning.withValues(alpha: 0.2),
              fontColor: AppTheme.cSurfaceWarning.color,
            ),
          ),
          SizedBox(height: 6.wMin),
          Expanded(
            child: _buildPromptInputWidget(context),
          ),
        ],
      );
    });
  }

  Widget _buildPromptInputWidget(BuildContext context){
    return Obx((){
      if(controller.generationMode.value == GenerationModeEnum.textToImage){
        return _buildInputPromptItemWidget(
          context: context, 
          inputController: controller.promptTextController,
          hintText: "可以不写提示词，AI会根据绑定对象和风格先生成 prompt 再生图；如果你已经写好了 prompt，也可以直接用当前 prompt 生图。",
        );  
      }else if(controller.generationMode.value == GenerationModeEnum.imageEdit){
        return _buildInputPromptItemWidget(
          context: context, 
          inputController: controller.promptEditController,
          hintText: "例如：保持人物身份与镜头方向不变，让开场动作更有张力，服装细节更统一。",
        );  
      }else if(controller.generationMode.value == GenerationModeEnum.reusePrompt){
        return _buildInputPromptItemWidget(
          context: context, 
          inputController: controller.promptReuseController,
          hintText: "",
        );  
      } else if(controller.generationMode.value == GenerationModeEnum.convertStyle){
        return Visibility(
          visible: false,
          child: _buildInputPromptItemWidget(
            context: context, 
            inputController: controller.promptConvertStyleController,
            readOnly: true,
            hintText: "",
          ),
        );  
      }
      return Container();
    });
  }


  Widget _buildInputPromptItemWidget({
    required BuildContext context, 
    required TextEditingController inputController, 
    bool readOnly = false, 
    required String hintText,
  }){
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.wMin),
      borderSide: BorderSide(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
    );

    return TextField(
      controller: inputController,
      maxLines: 20,
      style: TextStyle(
        fontSize: 18.wMin,
        color: AppTheme.cTextPrimary.color,
        fontWeight: FontWeight.w600,
      ),
      onTapOutside: (event) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      readOnly: readOnly,
      decoration: InputDecoration(
        isDense: true,
        counterText: "",
        fillColor: AppTheme.cSurfaceTertiary.color.withValues(alpha: readOnly ? 0.2 : 1),
        filled: true,
        border: border,
        focusedBorder: border,
        enabledBorder: border,
        disabledBorder: border,
        hintText: hintText,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
        hintStyle: TextStyle(
          fontSize: 18.wMin,
          color: AppTheme.cTextTertiary.color,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }


}