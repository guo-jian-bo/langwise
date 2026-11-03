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
        const Spacer(),
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaVoiceEmotionCreate],
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
      ],
    );
  }

  Widget _buildFromWidget(ManageVocalEmotionsModel data) {
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
              ManageZhenduInputHeightWidget(
                title: "中文描述",
                hintText: "中文描述",
                controller: data.zhDescInput,
                height: 120.wMin,
                maxLines: 5,
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
              ),
              ManageZhenduInputWidget(
                title: "英文名称",
                hintText: "英文名称",
                controller: data.enNameInput,
              ),
              ManageZhenduInputHeightWidget(
                title: "英文描述",
                hintText: "英文描述",
                controller: data.enDescInput,
                height: 120.wMin,
                maxLines: 5,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlidersWidget(ManageVocalEmotionsModel data) {
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
                      name: "HAPPY",
                      value: data.happySlider,
                      onChanged: (value) {
                        data.happySlider = value;
                        controller.listData.refresh();
                      },
                    ),
                    _buildSliderItemWidget(
                      name: "SAD",
                      value: data.sadSlider,
                      onChanged: (value) {
                        data.sadSlider = value;
                        controller.listData.refresh();
                      },
                    ),
                    _buildSliderItemWidget(
                      name: "DISGUSTED",
                      value: data.disgustedSlider,
                      onChanged: (value) {
                        data.disgustedSlider = value;
                        controller.listData.refresh();
                      },
                    ),
                    _buildSliderItemWidget(
                      name: "SURPRISED",
                      value: data.surprisedSlider,
                      onChanged: (value) {
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
                      name: "ANGRY",
                      value: data.angrySlider,
                      onChanged: (value) {
                        data.angrySlider = value;
                        controller.listData.refresh();
                      },
                    ),
                    _buildSliderItemWidget(
                      name: "AFRAID",
                      value: data.afraidSlider,
                      onChanged: (value) {
                        data.afraidSlider = value;
                        controller.listData.refresh();
                      },
                    ),
                    _buildSliderItemWidget(
                      name: "MELANCHOLIC",
                      value: data.melancholicSlider,
                      onChanged: (value) {
                        data.melancholicSlider = value;
                        controller.listData.refresh();
                      },
                    ),
                    _buildSliderItemWidget(
                      name: "CALM",
                      value: data.calmSlider,
                      onChanged: (value) {
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
        SliderTheme(
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
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }


  Widget _buildButtonsWidget(BuildContext context, ManageVocalEmotionsModel data){

    bool enabled = data.data?.enabled??false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        ManageAuthBoxWidget(
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

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaVoiceEmotionEdit],
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
                  controller.editEmotions(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

}
