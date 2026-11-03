import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/audio_play_ui_widget.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../../common/manage_zhendu_widgets.dart';
import '../../enums/manage_zhendu_enums.dart';
import '../controllers/manage_persona_controller.dart';
import '../models/manage_persona_model.dart';

class ManagePersonaInfoWidget extends StatelessWidget {
  final ManagePersonaController controller;
  const ManagePersonaInfoWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx((){
      if(controller.listData.isEmpty) {
        return const NotDataWidget(
          message: "暂无数据",
        );
      }
      if(controller.currentIndex.value >= controller.listData.length) {
        return Container();
      }
      ManagePersonaModel data = controller.listData[controller.currentIndex.value];
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 24.wMin),
        child: Column(
          spacing: 16.wMin,
          children: [
            _buildInfoWidget(context, data),
            _buildPersonaVariantWidget(context, data),
          ],
        ),
      );
    });
  }

  /// 基础信息
  Widget _buildInfoWidget(BuildContext context, ManagePersonaModel data){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        children: [
          _buildTitleWidget(context, data),
          SizedBox(height: 12.wMin),
          _buildFromWidget(context, data),
          Container(
            height: 1.wMin,
            color: AppTheme.cBorderPrimary.color,
            margin: EdgeInsets.symmetric(vertical: 24.wMin),
          ),
          _buildInfoButtonsWidget(context, data),
        ],
      ),
    );
  }


  Widget _buildTitleWidget(BuildContext context, ManagePersonaModel data) {
    return Row(
      children: [
        Text(
          "角色基础信息",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(width: 12.wMin),
        ManageTagFS16Widget(
          tag: "uid: ${data.data?.uid??''}",
          fontColor: AppTheme.cTextSecondary.color,
        ),
        
        const Spacer(),
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaPersonaDelete],
          child: ButtonWidget(
            text: "删除角色",
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
            borderRadius: 6.wMin,
            color: AppTheme.cFeedbackErrorBackground.color,
            border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackErrorBorder.color),
            fontColor: AppTheme.cFeedbackErrorText.color,
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: () {
              controller.deletePersona(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFromWidget(BuildContext context, ManagePersonaModel data){
    return Column(
      spacing: 24.wMin,
      children: [

        Row(
          spacing: 24.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                spacing: 24.wMin,
                children: [
                  ManageZhenduInputWidget(
                    title: "nid",
                    hintText: "nid",
                    controller: data.nidInput,
                    onChanged: (value) {
                      controller.listData.refresh();
                    },
                  ),
                  ManageZhenduInputWidget(
                    title: "中文名称",
                    hintText: "中文名称",
                    controller: data.zhNameInput,
                    onChanged: (value) {
                      controller.listData.refresh();
                    },
                  ),
                  ManageZhenduInputWidget(
                    title: "英文名称",
                    hintText: "英文名称",
                    controller: data.enNameInput,
                  ),
                  ManageZhenduDropdownWidget(
                    title: "gender",
                    hintText: "请选择",
                    selectValue: data.gender,
                    items: ManageZhenduDropdownEnums.genders,
                    onChanged: (choiceData, index) {
                      data.gender = choiceData.value;
                      controller.listData.refresh();
                    },
                  ),
                  ManageZhenduNumberInputWidget(
                    title: "scopeRefId",
                    hintText: "scopeRefId",
                    jumpValue: 1,
                    minValue: 1,
                    controller: data.scopeRefIdInput,
                  ),

                ],
              ),
            ),
            Expanded(
              child: Column(
                spacing: 24.wMin,
                children: [
                  ManageZhenduDropdownWidget(
                    title: "scope",
                    hintText: "请选择",
                    selectValue: data.scope,
                    items: ManageZhenduDropdownEnums.personaScopes,
                    onChanged: (choiceData, index) {
                      data.scope = choiceData.value;
                      controller.listData.refresh();
                    },
                  ),
                  ManageZhenduInputWidget(
                    title: "中文 dialect",
                    hintText: "中文 dialect",
                    controller: data.zhDialectInput,
                  ),
                  ManageZhenduInputWidget(
                    title: "英文 dialect",
                    hintText: "英文 dialect",
                    controller: data.enDialectInput,
                  ),
                  ManageZhenduInputWidget(
                    title: "species",
                    hintText: "species",
                    controller: data.speciesInput,
                  ),
                ],
              ),
            ),
          ],
        ),
        ManageZhenduInputHeightWidget(
          title: "personality",
          hintText: "personality",
          controller: data.personalityInput,
          height: 120.wMin,
          maxLines: 5,
          onChanged: (value) {
            controller.listData.refresh();
          },
        ),
        ManageZhenduInputHeightWidget(
          title: "appearance",
          hintText: "appearance",
          controller: data.appearanceInput,
          height: 120.wMin,
          maxLines: 5,
        ),
        ManageZhenduInputWidget(
          title: "tags",
          hintText: "以英文逗号分隔",
          controller: data.tagsInput,
          onChanged: (value) {
            controller.listData.refresh();
          },
        ),
      ],
    );
  }

  Widget _buildInfoButtonsWidget(BuildContext context, ManagePersonaModel data){
    bool enabled = data.data?.enabled ?? false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaPersonaEdit],
          margin: EdgeInsets.only(left: 8.wMin),
          child: Row(
            spacing: 8.wMin,
            children: [
              ButtonWidget(
                text: enabled ? "已启用" : "已停用",
                padding: EdgeInsets.only(left: 8.wMin, right: 12.wMin),
                height: 38.wMin,
                color: enabled ? AppTheme.cFeedbackSuccessBackground.color : AppTheme.cFeedbackErrorBackground.color,
                borderRadius: 8.wMin,
                fontColor: enabled ? AppTheme.cFeedbackSuccessText.color : AppTheme.cFeedbackErrorText.color,
                fontSize: 18.wMin,
                leftIcon: Container(
                  margin: EdgeInsets.only(right: 4.wMin),
                  child: SvgPicture.asset(
                    enabled ? "assets/svg/public/icon_enable.svg" : "assets/svg/public/icon_prohibit.svg",
                    height: 24.wMin,
                    colorFilter: ColorFilter.mode(
                      enabled ? AppTheme.cFeedbackSuccessText.color : AppTheme.cFeedbackErrorText.color,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                sclae: 1.03,
                onTap: () {
                  controller.editEnabled(context);
                },
              ),
              ButtonWidget(
                text: "保存",
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                height: 38.wMin,
                color: AppTheme.cTextPrimary.color,
                borderRadius: 8.wMin,
                fontColor: AppTheme.cBgPrimary.color,
                fontSize: 18.wMin,
                sclae: 1.03,
                onTap: () {
                  controller.editPersona(context);
                },
              ),
            ],
          ),
        ),

      ],
    );
  }


  /// PersonaVariant 角色变体
  Widget _buildPersonaVariantWidget(BuildContext context, ManagePersonaModel data){
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PersonaVariant 列表",
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 24.wMin),

          Column(
            spacing: 16.wMin,
            children: List.generate(data.variants.length, (index){
              return _buildVariantItemWidget(context, data, data.variants[index], index);
            }),
          ),

          SizedBox(height: 24.wMin),
          Row(
            children: [
              ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.dramaPersonaVariantCreate],
                child: ButtonWidget(
                  text: "新增变体",
                  padding: EdgeInsets.only(left: 8.wMin, right: 12.wMin),
                  height: 38.wMin,
                  color: AppTheme.cFeedbackSuccessBackground.color,
                  borderRadius: 8.wMin,
                  border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackSuccessBorder.color),
                  fontColor: AppTheme.cFeedbackSuccessText.color,
                  fontSize: 18.wMin,
                  leftIcon: Container(
                    margin: EdgeInsets.only(right: 4.wMin),
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_add.svg",
                      height: 24.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cFeedbackSuccessText.color, BlendMode.srcIn),
                    ),
                  ),
                  sclae: 1.03,
                  onTap: () {
                    controller.addVariant(context, data);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVariantItemWidget(BuildContext context, ManagePersonaModel data, ManagePersonaVariantModel variant, int index){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cBlackAlpha10.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVariantItemTitleWidget(context, data, variant, index),
          SizedBox(height: 16.wMin),
          _buildVariantItemBasicWidget(context, data, variant),
          SizedBox(height: 16.wMin),
          _buildVariantItemsettingDiagramWidget(context, data, variant),
          SizedBox(height: 16.wMin),
          _buildVariantItemToneBindingWidget(context, data, variant),
          SizedBox(height: 16.wMin),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaPersonaVariantEdit],
            child: _buildVariantItemButtonsWidget(context, data, variant, index),
          ),

        ],
      ),
    );
  }

  Widget _buildVariantItemTitleWidget(BuildContext context, ManagePersonaModel data, ManagePersonaVariantModel variant, int index){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [

            Text(
              variant.variantNameInput.text,
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(width: 4.wMin),
            if(variant.data?.isDefault == true)
              ButtonWidget(
                text: "默认变体",
                padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                color: AppTheme.cSurfaceSuccess.color,
                fontSize: 14.wMin,
                fontWeight: FontWeight.w600,
              ),
            SizedBox(width: 4.wMin),
            ButtonWidget(
              text: variant.data?.enabled == true ? "启用" : "停用",
              padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
              color: variant.data?.enabled == true ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2) : AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
              fontSize: 14.wMin,
              fontWeight: FontWeight.w600,
              fontColor: variant.data?.enabled == true ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceError.color,
            ),

            SizedBox(width: 16.wMin),

            ManageTagFS16Widget(
              tag: "vid: ${variant.data?.uid??''}",
              fontColor: AppTheme.cTextSecondary.color,
            ),

            const Spacer(),

            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.dramaPersonaVariantDelete],
              child: ButtonWidget(
                text: "删除变体",
                padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                borderRadius: 6.wMin,
                color: AppTheme.cFeedbackErrorBackground.color,
                border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackErrorBorder.color),
                fontColor: AppTheme.cFeedbackErrorText.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: () {
                  controller.deleteVariant(context, data, index);
                },
              ),
            ),

          ],
        ),

        Text(
          variant.nidInput.text,
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextPrimary.color.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),

      ],
    );
  }

  
  /// 变体基础信息
  Widget _buildVariantItemBasicWidget(BuildContext context, ManagePersonaModel data, ManagePersonaVariantModel variant){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "基础信息",
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.wMin),
          Row(
            spacing: 24.wMin,
            children: [
              Expanded(
                child: Column(
                  spacing: 24.wMin,
                  children: [
                    ManageZhenduInputWidget(
                      title: "nid",
                      hintText: "nid",
                      controller: variant.nidInput,
                      onChanged: (value) {
                        controller.listData.refresh();
                      },
                    ),
                    ManageZhenduDropdownWidget(
                      title: "age_group",
                      hintText: "请选择",
                      selectValue: variant.ageGroup,
                      items: ManageZhenduDropdownEnums.ageGroups,
                      onChanged: (choiceData, index) {
                        variant.ageGroup = choiceData.value;
                        controller.listData.refresh();
                      },
                    ),
                    ManageZhenduInputHeightWidget(
                      title: "中文描述",
                      hintText: "中文描述",
                      controller: variant.zhDescInput,
                      height: 120.wMin,
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 24.wMin,
                  children: [
                    ManageZhenduInputWidget(
                      title: "变体名称",
                      hintText: "变体名称",
                      controller: variant.variantNameInput,
                      onChanged: (value) {
                        controller.listData.refresh();
                      },
                    ),
                    ManageZhenduNumberInputWidget(
                      title: "speed_offset",
                      hintText: "speed_offset",
                      jumpValue: 0.05,
                      maxValue: 0.5,
                      minValue: -0.5,
                      controller: variant.speedOffsetInput,
                    ),
                    ManageZhenduInputHeightWidget(
                      title: "英文描述",
                      hintText: "英文描述",
                      controller: variant.enDescInput,
                      height: 120.wMin,
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  } 

  /// 变体设定图
  Widget _buildVariantItemsettingDiagramWidget(BuildContext context, ManagePersonaModel data, ManagePersonaVariantModel variant){

    List<MangePersonaEntityVariantsImages?> variantsImages = variant.data?.images??[];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "设定图",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Visibility(
                visible: UserStore.to.rolePermissions.value.userIsImageReviewer || UserStore.to.rolePermissions.value.userIsImageSuperReviewer,
                child: ButtonWidget(
                  text: "待审核 ${variant.data?.imageTaskIds?.length??0} 个",
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                  height: 40.wMin,
                  borderRadius: 6.wMin,
                  color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.1),
                  border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
                  fontColor: AppTheme.cSurfaceBrand.color,
                  fontSize: 18.wMin,
                  sclae: 1.05,
                  onTap: () {
                    controller.reviewSettingDiagramImage(data, variant);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8.wMin),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 24.wMin,
              children: [

                  ...List.generate(variantsImages.length, (index){
                    return _buildVariantItemsettingDiagramImageWidget(variantsImages[index]);
                  }),

                  ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.dramaPersonaVariantImageGenerate],
                    child: TapScaleWidget(
                      onTap: () {
                        controller.addSettingDiagram(context, variant);
                      },
                      sclae: 1.01,
                      child: DottedBorder(
                        radius: Radius.circular(4.wMin),
                        borderType: BorderType.RRect,
                        padding: EdgeInsets.zero,
                        color: const Color(0xffF43F5E),
                        dashPattern: const [3, 3],
                        child: Container(
                          width: 220.wMin,
                          height: 240.wMin,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.wMin),
                            color: const Color(0xffF43F5E).withValues(alpha: .2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/public/icon_add.svg",
                                width: 40.wMin,
                                colorFilter: const ColorFilter.mode(Color(0xffF43F5E), BlendMode.srcIn),
                              ),
                              Text(
                                "新增设定图",
                                style: TextStyle(
                                  fontSize: 18.wMin,
                                  color: const Color(0xffF43F5E),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildVariantItemsettingDiagramImageWidget(MangePersonaEntityVariantsImages? image){
    return SizedBox(
      width: 220.wMin,
      child: Column(
        children: [
          Container(
            width: 220.wMin,
            height: 220.wMin,
            color: AppTheme.cSurfaceSecondary.color,
            child: AspectRatio(
              aspectRatio: 1,
              child: CachedImageWidget(
                image?.imageUrl??"",
                fit: BoxFit.contain,
                errorWidget: buildEmptyWidget(),
                placeholder: buildLoadingWidget(),
                fadeInDuration: Duration.zero,
                borderRadius: BorderRadius.circular(6.wMin),
              ),
            ),
          ),
          SizedBox(height: 4.wMin),
          Row(
            children: [
              ButtonWidget(
                text: image?.viewTypeName??"",
                padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 2.wMin),
                borderRadius: 4.wMin,
                color: AppTheme.cWhiteAlpha20.color,
                fontColor: AppTheme.cTextPrimary.color,
                fontSize: 14.wMin,
              ),
              const Spacer(),
              Visibility(
                visible: image?.isCore == true,
                child: Text(
                  "core",
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: const Color(0xffF43F5E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 音色绑定
  Widget  _buildVariantItemToneBindingWidget(BuildContext context, ManagePersonaModel data, ManagePersonaVariantModel variant){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "音色绑定",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.dramaPersonaVariantEdit],
                child: ButtonWidget(
                  text: "调整",
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                  borderRadius: 6.wMin,
                  color: const Color(0xffF43F5E).withValues(alpha: 0.2),
                  border: Border.all(width: 1.wMin, color: const Color(0xffF43F5E)),
                  fontColor: const Color(0xffF43F5E),
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  sclae: 1.03,
                  onTap: () {
                    controller.adjustToneBinding(context, data, variant);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8.wMin),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceSecondary.color,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "当前绑定",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.wMin),

                Row(
                  children: [
                    Text(
                      variant.data?.timbreInfo?.name??"",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: AppTheme.cTextSecondary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      variant.data?.timbreInfo?.nid??"",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                Visibility(
                  visible: variant.data?.timbreInfo?.audios != null,
                  child: Container(
                    margin: EdgeInsets.only(top: 8.wMin),
                    child: Column(
                      spacing: 8.wMin,
                      children: List.generate(variant.data?.timbreInfo?.audios?.length??0, (index){
                        return _buildVariantItemToneBindingAudioItemWidget(variant.data?.timbreInfo?.audios?[index]);
                      }),
                    ),
                  ),
                ),

              ],
            ),
          ),


        ],
      ),
    );
  }


  Widget _buildVariantItemToneBindingAudioItemWidget(MangePersonaEntityVariantsTimbreInfoAudios? audio){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Row(
        children: [
          Text(
            audio?.dialect??"",
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 10.wMin),
          Expanded(
            child: SizedBox(
              child: AudioPlayUiWidget(
                audioUrl: audio?.audioUrl,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantItemButtonsWidget(BuildContext context, ManagePersonaModel data, ManagePersonaVariantModel variant, int index){
    bool isDefault = variant.data?.isDefault ?? false;
    bool enabled = variant.data?.enabled ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        ButtonWidget(
          text: enabled ? "已启用" : "已停用",
          padding: EdgeInsets.only(left: 8.wMin, right: 12.wMin),
          height: 38.wMin,
          color: enabled ? AppTheme.cFeedbackSuccessBackground.color : AppTheme.cFeedbackErrorBackground.color,
          borderRadius: 8.wMin,
          fontColor: enabled ? AppTheme.cFeedbackSuccessText.color : AppTheme.cFeedbackErrorText.color,
          fontSize: 18.wMin,
          leftIcon: Container(
            margin: EdgeInsets.only(right: 4.wMin),
            child: SvgPicture.asset(
              enabled ? "assets/svg/public/icon_enable.svg" : "assets/svg/public/icon_prohibit.svg",
              height: 24.wMin,
              colorFilter: ColorFilter.mode(
                enabled ? AppTheme.cFeedbackSuccessText.color : AppTheme.cFeedbackErrorText.color,
                BlendMode.srcIn,
              ),
            ),
          ),
          sclae: 1.03,
          onTap: () {
            controller.variantEditEnabled(context, data, variant);
          },
        ),

        SizedBox(width: 10.wMin),

        Visibility(
          visible: isDefault,
          child: ButtonWidget(
            text: "当前默认",
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            height: 38.wMin,
            color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
            borderRadius: 8.wMin,
            fontColor: AppTheme.cSurfaceSuccess.color,
            fontSize: 18.wMin,
            sclae: 1.03,
            onTap: () {
              controller.variantSetDefault(data, variant);
            },
          ),
        ),

        Visibility(
          visible: !isDefault,
          child: ButtonWidget(
            text: "设为默认",
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            height: 38.wMin,
            color: AppTheme.cSurfaceSecondary.color,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
            borderRadius: 8.wMin,
            fontColor: AppTheme.cTextPrimary.color,
            fontSize: 18.wMin,
            sclae: 1.03,
            onTap: () {
              controller.variantSetDefault(data, variant);
            },
          ),
        ),

        SizedBox(width: 10.wMin),

        ButtonWidget(
          text: "保存",
          padding: EdgeInsets.symmetric(horizontal: 16.wMin),
          height: 38.wMin,
          color: AppTheme.cTextPrimary.color,
          borderRadius: 8.wMin,
          fontColor: AppTheme.cBgPrimary.color,
          fontSize: 18.wMin,
          sclae: 1.03,
          onTap: () {
            controller.editVariant(context, data, index);
          },
        ),

      ],
    );
  }


}