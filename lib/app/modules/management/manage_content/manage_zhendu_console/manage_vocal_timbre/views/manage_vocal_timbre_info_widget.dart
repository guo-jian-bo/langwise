
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/audio_play_ui_widget.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../../common/manage_zhendu_widgets.dart';
import '../../enums/manage_zhendu_enums.dart';
import '../controllers/manage_vocal_timbre_controller.dart';
import '../models/manage_vocal_timbre_model.dart';

class ManageVocalTimbreInfoWidget extends StatelessWidget {
  final ManageVocalTimbreController controller;
  const ManageVocalTimbreInfoWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Obx((){
        if(controller.listData.isEmpty) {
          return const NotDataWidget(
            message: "暂无数据",
          );
        }
        if(controller.currentIndex.value >= controller.listData.length) {
          return Container();
        }
        ManageVocalTimbreModel data = controller.listData[controller.currentIndex.value];

        return Column(
          children: [
            _buildTitleWidget(context, data),
            SizedBox(height: 12.wMin),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 12.wMin),
                child: Column(
                  children: [
                    _buildFromWidget(data),
                    Container(
                      height: 1.wMin,
                      color: AppTheme.cBorderPrimary.color,
                      margin: EdgeInsets.symmetric(vertical: 32.wMin),
                    ),
                    _buildDialectTimbreListWidget(context, data),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.wMin),

            _buildButtonsWidget(context, data),
          ],
        );
      }),
    );
  }


  Widget _buildTitleWidget(BuildContext context, ManageVocalTimbreModel data) {
    bool isEditing = controller.isEditing.value;
    return Row(
      children: [
        Text(
          "基础信息与维度",
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
        SizedBox(width: 12.wMin),
        Visibility(
          visible: data.data?.uid == null,
          child: ManageTagFS16Widget(
            tag: "新增未保存",
            bgColor: AppTheme.cFeedbackErrorBackground.color,
            fontColor: AppTheme.cFeedbackErrorText.color,
          ),
        ),
        const Spacer(),
        Visibility(
          visible: isEditing,
          replacement: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaVoiceTimbreEdit],
            child: ButtonWidget(
              text: "编辑",
              padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
              borderRadius: 6.wMin,
              color: AppTheme.cSurfaceTertiary.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
              fontColor: AppTheme.cTextPrimary.color,
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.03,
              onTap: () {
                controller.startEdit();
              },
            ),
          ),
          child: Row(
            children: [
              Visibility(
                visible: data.data?.uid == null,
                child: ButtonWidget(
                  text: "删除",
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                  borderRadius: 6.wMin,
                  color: AppTheme.cFeedbackErrorBackground.color,
                  border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackErrorBorder.color),
                  fontColor: AppTheme.cFeedbackErrorText.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  sclae: 1.03,
                  onTap: () {
                    controller.deleteTimbre(context);
                  },
                ),
              ),
              SizedBox(width: 12.wMin),
              ButtonWidget(
                text: "取消编辑",
                padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                borderRadius: 6.wMin,
                color: AppTheme.cSurfaceTertiary.color,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
                fontColor: AppTheme.cTextPrimary.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: () {
                  controller.cancelEdit(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFromWidget(ManageVocalTimbreModel data) {
    bool isEditing = controller.isEditing.value;
    return Column(
      spacing: 24.wMin,
      children: [

        Row(
          spacing: 24.wMin,
          children: [
            Expanded(
              child: ManageZhenduInputWidget(
                title: "nid",
                hintText: "nid",
                controller: data.nidInput,
                readOnly: true,
                onChanged: (value) {
                  controller.listData.refresh();
                },
              ),
            ),
            Expanded(child: Container()),
          ],
        ),

        Row(
          spacing: 24.wMin,
          children: [
            Expanded(
              child: ManageZhenduInputWidget(
                title: "中文名称",
                hintText: "中文名称",
                controller: data.zhNameInput,
                readOnly: !isEditing,
                onChanged: (value) {
                  controller.listData.refresh();
                },
              ),
            ),
            Expanded(
              child: ManageZhenduInputWidget(
                title: "英文名称",
                hintText: "英文名称",
                controller: data.enNameInput,
                readOnly: !isEditing,
              ),
            ),
          ],
        ),

        Row(
          spacing: 24.wMin,
          children: [
            Expanded(
              child: ManageZhenduDropdownWidget(
              title: "category",
              hintText: "请选择",
              selectValue: data.category,
              items: ManageZhenduDropdownEnums.categorys,
              readOnly: !isEditing,
              onChanged: (choiceData, index) {
                data.category = choiceData.value;
                controller.listData.refresh();
              },
              ),
            ),
            Expanded(
              child: ManageZhenduDropdownWidget(
              title: "gender",
              hintText: "请选择",
              selectValue: data.gender,
              items: ManageZhenduDropdownEnums.genders,
              readOnly: !isEditing,
              onChanged: (choiceData, index) {
                data.gender = choiceData.value;
                controller.listData.refresh();
              },
              ),
            ),
            Expanded(
              child: ManageZhenduDropdownWidget(
              title: "age_group",
              hintText: "请选择",
              selectValue: data.ageGroup,
              items: ManageZhenduDropdownEnums.ageGroups,
              readOnly: !isEditing, 
              onChanged: (choiceData, index) {
                data.ageGroup = choiceData.value;
                controller.listData.refresh();
              },
              ),
            ),
          ],
        ),

        Row(
          spacing: 24.wMin,
          children: [
            Expanded(
              child: ManageZhenduDropdownWidget(
              title: "manner",
              hintText: "请选择",
              selectValue: data.manner,
              items: ManageZhenduDropdownEnums.manners,
              readOnly: !isEditing,
              onChanged: (choiceData, index) {
                data.manner = choiceData.value;
                controller.listData.refresh();
              },
              ),
            ),
            Expanded(
              child: ManageZhenduDropdownWidget(
              title: "morality",
              hintText: "请选择",
              selectValue: data.morality,
              items: ManageZhenduDropdownEnums.moralities,
              readOnly: !isEditing,
              onChanged: (choiceData, index) {
                data.morality = choiceData.value;
                controller.listData.refresh();
              },
              ),
            ),
            Expanded(
              child: ManageZhenduDropdownWidget(
              title: "background",
              hintText: "请选择",
              selectValue: data.background,
              items: ManageZhenduDropdownEnums.backgrounds,
              readOnly: !isEditing,
              onChanged: (choiceData, index) {
                data.background = choiceData.value;
                controller.listData.refresh();
              },
              ),
            ),

          ],
        ),

        ManageZhenduInputHeightWidget(
          title: "label",
          hintText: "label",
          controller: data.labelInput,
          height: 120.wMin,
          maxLines: 5,
          readOnly: !isEditing,
          fillColor: !isEditing ? Colors.transparent : AppTheme.cSurfaceTertiary,
          borderColor: AppTheme.cBorderSecondary,
          onChanged: (value) {
            controller.listData.refresh();
          },
        ),

      ],
    );
  }


  /// 方言音色列表
  Widget _buildDialectTimbreListWidget(BuildContext context, ManageVocalTimbreModel data){
    bool isEditing = controller.isEditing.value;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 24.wMin),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 2.wMin,
            color: const Color(0xffFB923C),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "方言音色",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 24.wMin),
          
          Column(
            spacing: 16.wMin,
            children: List.generate(data.dialectTimbres.length, (index){
              return _buildDialectTimbreItemWidget(context, data, data.dialectTimbres[index], index);
            }),
          ),


          SizedBox(height: 24.wMin),
          Visibility(
            visible: isEditing && data.data != null,
            child: Row(
              children: [
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.dramaVoiceTimbreEdit],
                  child: ButtonWidget(
                    text: "新增方言音色",
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
                      controller.addDialectTimbre(context, data);
                    },
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }


  Widget _buildDialectTimbreItemWidget(BuildContext context, ManageVocalTimbreModel data, ManageVocalDialectTimbreModel timbre, int index){
    bool isEditing = controller.isEditing.value;
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cBlackAlpha20.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Text(
                "方言音色${index + 1}",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.dramaVoiceTimbreEdit],
                child: Visibility(
                  visible: isEditing,
                  child: ButtonWidget(
                    text: "删除",
                    padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                    borderRadius: 6.wMin,
                    color: AppTheme.cFeedbackErrorBackground.color,
                    border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackErrorBorder.color),
                    fontColor: AppTheme.cFeedbackErrorText.color,
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                    sclae: 1.03,
                    onTap: () {
                      controller.deleteDialectTimbre(context, data, index);
                    },
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.wMin),

          Row(
            spacing: 12.wMin,
            children: [

              SizedBox(
                width: 350.wMin,
                child: IgnorePointer(
                  ignoring: !isEditing,
                  child: ManageZhenduDropdownWidget(
                  title: "dialect",
                  hintText: "请选择",
                  selectValue: timbre.dialect,
                  readOnly: !isEditing,
                  items: List.generate(data.dialectTimbreCodes.length, (index){
                    String title = data.dialectTimbreCodes[index].code;
                    if(data.dialectTimbreCodes[index].isOccupy && title != timbre.dialect){
                      title += "(已占用)";
                    }
                    return IconDropdownCheckData(
                      title: title,
                      value: data.dialectTimbreCodes[index].code,
                      isEnable: !data.dialectTimbreCodes[index].isOccupy,
                    );
                  }),
                  onChanged: (choiceData, index) {
                    controller.updateDialectIsoccupy(data, timbre.dialect, choiceData.value);
                    timbre.dialect = choiceData.value;
                    controller.listData.refresh();
                  },
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 4.wMin),
                      child: Text(
                        "音频播放",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextSecondary.color,
                        ),
                      ),
                    ),
                    Container(
                      height: 54.wMin,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                        border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
                        color: AppTheme.cSurfaceTertiary.color,
                      ),
                      child: Visibility(
                        visible: timbre.audio?.audioUrl != null,
                        child: Row(
                          children: [
                            Expanded(
                              child: AudioPlayUiWidget(
                                key: ValueKey(timbre.dialect),
                                audioUrl: timbre.audio?.audioUrl ?? "",
                              ),
                            ),
                             ManageAuthBoxWidget(
                              authCodes: [timbre.audio?.locked == true ? ManageAuthCode.adminAudioReviewAudioUnlock : ManageAuthCode.adminAudioReviewAudioLock],
                              margin: EdgeInsets.only(left: 10.wMin),
                              child: TapScaleWidget(
                                onTap: () {
                                  if(timbre.audio?.locked == true){
                                    controller.audioUnLocked(context, timbre.audio);
                                  }else{
                                    controller.audioLocked(context, timbre.audio);
                                  }
                                },
                                sclae: 1.03,
                                child: Container(
                                  width: 36.wMin,
                                  height: 36.wMin,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.wMin),
                                    color: AppTheme.cInverseOverlay2.color,
                                    border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                                  ),
                                  child: SvgPicture.asset(
                                    timbre.audio?.locked == true ? "assets/svg/manage/icon_resource_lock.svg" : "assets/svg/manage/icon_resource_unlock.svg",
                                    width: 18.wMin,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.wMin),

          ManageZhenduInputHeightWidget(
            title: "description",
            hintText: "description",
            controller: timbre.descriptionInput,
            height: 100.wMin,
            maxLines: 5,
            readOnly: !isEditing,
            fillColor: !isEditing ? Colors.transparent : AppTheme.cSurfaceTertiary,
            borderColor: AppTheme.cBorderSecondary,
          ),

          SizedBox(height: 16.wMin),

          ManageZhenduInputHeightWidget(
            title: "设计台词 `audio_text`",
            hintText: "设计台词 `audio_text`",
            controller: timbre.audioTextInput,
            height: 100.wMin,
            maxLines: 5,
            readOnly: !isEditing,
            fillColor: !isEditing ? Colors.transparent : AppTheme.cSurfaceTertiary,
            borderColor: AppTheme.cBorderSecondary,
          ),

          SizedBox(height: 16.wMin),

          Row(
            spacing: 12.wMin,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 250.wMin,
                child: ManageZhenduInputWidget(
                  title: "参考演员",
                  hintText: "参考演员",
                  controller: timbre.actorInput,
                  readOnly: !isEditing,
                ),
              ),
              Expanded(
                child: ManageZhenduInputWidget(
                  title: "参考链接",
                  hintText: "参考链接",
                  controller: timbre.urlInput,
                  readOnly: !isEditing,
                ),
              ),
              ButtonWidget(
                text: "打开链接",
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                height: 54.wMin,
                color: AppTheme.cSurfaceBrand.withValues(alpha: 0.2),
                borderRadius: 8.wMin,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderBrand.color),
                fontColor: AppTheme.cTextBrand.color,
                fontSize: 18.wMin,
                sclae: 1.03,
                onTap: () {
                  controller.openReferenceLink(context, timbre);
                },
              ),
            ],
          ),

          SizedBox(height: 16.wMin),

          Visibility(
            visible: data.data != null,
            child: Row(
              children: [
            
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.dramaVoiceTimbreUploadAudio],
                  child: ButtonWidget(
                    text: "上传音频",
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    height: 38.wMin,
                    color: const Color(0xffFB923C).withValues(alpha: 0.2),
                    borderRadius: 8.wMin,
                    border: Border.all(width: 1.wMin, color: const Color(0xffFB923C)),
                    fontColor: const Color(0xffFB923C),
                    fontSize: 18.wMin,
                    sclae: 1.03,
                    onTap: () {
                      controller.uploadAudio(context, data, timbre);
                    },
                  ),
                ),
            
                const Spacer(),
            
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.dramaVoiceTimbreAudioTextDesign],
                  child: ButtonWidget(
                    text: "设计台词",
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    height: 38.wMin,
                    color: const Color(0xffFB923C).withValues(alpha: 0.2),
                    borderRadius: 8.wMin,
                    fontColor: const Color(0xffFB923C),
                    fontSize: 18.wMin,
                    sclae: 1.03,
                    onTap: () {
                      controller.designialogueLines(context, data, timbre);
                    },
                  ),
                ),
            
                SizedBox(width: 8.wMin),
            
                ButtonWidget(
                  text: "待审核 ${timbre.data?.audio?.audioTaskIds?.length??0} 个",
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                  height: 38.wMin,
                  color: Colors.transparent,
                  border: Border.all(
                    width: 1.wMin, 
                    color: (timbre.data?.audio?.audioTaskIds??[]).isEmpty ? AppTheme.cBorderSecondary.color : AppTheme.cBorderBrand.color,
                  ),
                  borderRadius: 8.wMin,
                  fontColor: (timbre.data?.audio?.audioTaskIds??[]).isEmpty ? AppTheme.cTextSecondary.color : AppTheme.cTextBrand.color,
                  fontSize: 18.wMin,
                  sclae: 1.03,
                  onTap: () {
                    controller.reviewAudio(data, timbre);
                  },
                ),
            
                SizedBox(width: 8.wMin),
            
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.dramaVoiceTimbreAudioGenerate],
                  child: ButtonWidget(
                    text: "生成音频",
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    height: 38.wMin,
                    color: AppTheme.cTextPrimary.color,
                    borderRadius: 8.wMin,
                    fontColor: AppTheme.cBgPrimary.color,
                    fontSize: 18.wMin,
                    sclae: 1.03,
                    onTap: () {
                      controller.generateAudio(context, data, timbre);
                    },
                  ),
                ),
            
            
              ],
            ),
          ),
          
        ],
      ),
    );
  }



  Widget _buildButtonsWidget(BuildContext context, ManageVocalTimbreModel data){
    bool isEditing = controller.isEditing.value;
    bool enabled = data.data?.enabled??false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        Visibility(
          visible: isEditing,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaVoiceTimbreEdit],
            margin: EdgeInsets.only(left: 8.wMin),
            child: Row(
              spacing: 8.wMin,
              children: [
                Visibility(
                  visible: data.data?.uid != null,
                  child: ButtonWidget(
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
                    controller.editTimbre();
                  },
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }


}
