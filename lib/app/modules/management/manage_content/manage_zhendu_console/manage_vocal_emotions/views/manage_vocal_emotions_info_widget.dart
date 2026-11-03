import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/commons.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../utils/utils.dart';
import '../../common/manage_zhendu_widgets.dart';
import '../controllers/manage_vocal_emotions_controller.dart';
import '../models/manage_vocal_emotions_model.dart';

class ManageVocalEmotionsInfoWidget extends StatelessWidget {
  final ManageVocalEmotionsController controller;
  const ManageVocalEmotionsInfoWidget({super.key, required this.controller});

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
        ManageVocalEmotionsModel data = controller.listData[controller.currentIndex.value];

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
                    _buildSlidersWidget(data),
                  ],
                ),
              ),
            ),

            _buildButtonsWidget(context, data),
          ],
        );
      }),
    );
  }

  Widget _buildTitleWidget(BuildContext context, ManageVocalEmotionsModel data) {
    bool isEditing = controller.isEditing.value;
    return Row(
      children: [
        Text(
          "基础信息",
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
            authCodes: const [ManageAuthCode.dramaVoiceEmotionEdit],
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
                    controller.deleteEmotions(context);
                  },
                ),
              ),
              SizedBox(width: 8.wMin),
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

  Widget _buildFromWidget(ManageVocalEmotionsModel data) {
    bool isEditing = controller.isEditing.value;
    return Row(
      spacing: 24.wMin,
      children: [
        Expanded(
          child: Column(
            spacing: 24.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ManageZhenduInputWidget(
                title: "nid",
                hintText: "nid",
                controller: data.nidInput,
                readOnly: true,
                onChanged: (value) {
                  controller.listData.refresh();
                },
              ),
              ManageZhenduInputWidget(
                title: "中文名称",
                hintText: "中文名称",
                controller: data.zhNameInput,
                readOnly: !isEditing,
                onChanged: (value) {
                  controller.listData.refresh();
                },
              ),
              ManageZhenduInputHeightWidget(
                title: "中文描述",
                hintText: "中文描述",
                controller: data.zhDescInput,
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
          ),
        ),
        Expanded(
          child: Column(
            spacing: 24.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ManageZhenduNumberInputWidget(
                title: "suggested_speed",
                hintText: "suggested_speed",
                jumpValue: 0.05,
                maxValue: 2,
                minValue: 0.05,
                controller: data.suggestedSpeedInput,
                readOnly: !isEditing,
              ),
              ManageZhenduInputWidget(
                title: "英文名称",
                hintText: "英文名称",
                controller: data.enNameInput,
                readOnly: !isEditing,
              ),
              ManageZhenduInputHeightWidget(
                title: "英文描述",
                hintText: "英文描述",
                controller: data.enDescInput,
                height: 120.wMin,
                maxLines: 5,
                readOnly: !isEditing,
                fillColor: !isEditing ? Colors.transparent : AppTheme.cSurfaceTertiary,
                borderColor: AppTheme.cBorderSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlidersWidget(ManageVocalEmotionsModel data) {
    bool isEditing = controller.isEditing.value;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 24.wMin),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 2.wMin,
            color: const Color(0xff00D492),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "8 维情绪向量",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 24.wMin),
          Row(
            spacing: 16.wMin,
            children: [
              Expanded(
                child: Column(
                  spacing: 16.wMin,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSliderItemWidget(
                      name: "HAPPY (快乐)",
                      value: data.happySlider,
                      onChanged: !isEditing ? null : (value) {
                        data.happySlider = value;
                        controller.listData.refresh();
                      },
                    ),
                    _buildSliderItemWidget(
                      name: "SAD (伤心、悲哀)",
                      value: data.sadSlider,
                      onChanged: !isEditing ? null : (value) {
                        data.sadSlider = value;
                        controller.listData.refresh();
                      },
                    ),
                    _buildSliderItemWidget(
                      name: "DISGUSTED (厌恶、讨厌)",
                      value: data.disgustedSlider,
                      onChanged: !isEditing ? null : (value) {
                        data.disgustedSlider = value;
                        controller.listData.refresh();
                      },
                    ),
                    _buildSliderItemWidget(
                      name: "SURPRISED  (意外、惊讶)",
                      value: data.surprisedSlider,
                      onChanged: !isEditing ? null : (value) {
                        data.surprisedSlider = value;
                        controller.listData.refresh();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 16.wMin,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSliderItemWidget(
                      name: "ANGRY (愤怒、生气)",
                      value: data.angrySlider,
                      onChanged: !isEditing ? null : (value) {
                        data.angrySlider = value;
                        controller.listData.refresh();
                      },
                    ),
                    _buildSliderItemWidget(
                      name: "AFRAID (害怕)",
                      value: data.afraidSlider,
                      onChanged: !isEditing ? null : (value) {
                        data.afraidSlider = value;
                        controller.listData.refresh();
                      },
                    ),
                    _buildSliderItemWidget(
                      name: "MELANCHOLIC (忧郁)",
                      value: data.melancholicSlider,
                      onChanged: !isEditing ? null : (value) {
                        data.melancholicSlider = value;
                        controller.listData.refresh();
                      },
                    ),
                    _buildSliderItemWidget(
                      name: "CALM (冷静)",
                      value: data.calmSlider,
                      onChanged: !isEditing ? null : (value) {
                        data.calmSlider = value;
                        controller.listData.refresh();
                      },
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

  Widget _buildSliderItemWidget({
    required String name,
    required double value,
    void Function(double value)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 2.wMin),
            Text(
              name,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            const Spacer(),
            Text(
              value.toStringAsFixed(2).padLeft(2, '0'),
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ],
        ),
        Opacity(
          opacity: onChanged != null ? 1 : 0.8,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 8.wMin,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.wMin),
              overlayShape: SliderComponentShape.noOverlay,
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              value: value,
              divisions: 20,
              activeColor: const Color(0xff00D492),
              inactiveColor: AppTheme.cSurfaceQuinary.color,
              onChanged: (value) {
                onChanged?.call(value);
              },
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildButtonsWidget(BuildContext context, ManageVocalEmotionsModel data){
    bool isEditing = controller.isEditing.value;
    bool enabled = data.data?.enabled??false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        Visibility(
          visible: data.data?.uid != null,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaVoiceEmotionPreview],
            child: ButtonWidget(
              text: "试听",
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
                  "assets/svg/public/icon_recording_playback.svg",
                  height: 24.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cFeedbackSuccessText.color, BlendMode.srcIn),
                ),
              ),
              sclae: 1.03,
              onTap: () {
                controller.audition(context, data);
              },
            ),
          ),
        ),

        Visibility(
          visible: isEditing,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaVoiceEmotionEdit],
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
                    controller.editEmotions(context);
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
