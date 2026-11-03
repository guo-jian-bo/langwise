
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/widgets/audio_play_ui_widget.dart';
import '../../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../../theme/theme.dart';
import '../../../../../common/commons.dart';
import '../../../enums/manage_audio_project_status_enum.dart';
import '../controllers/manage_create_visual_project_controller.dart';

class ManageCreateVisualProjectAudioItemWidget extends StatelessWidget {
  final ManageCreateVisualProjectController controller;
  final ManageAudioProjectEntity data;
  const ManageCreateVisualProjectAudioItemWidget({super.key, required this.controller, required this.data});

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: () {
        controller.selectAudioProject(data);
      },
      sclae: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
          color: AppTheme.cSurfaceTertiary.color,
          borderRadius: BorderRadius.circular(12.wMin),
        ),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(12.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListitemTagsWidget(data),
                  SizedBox(height: 16.wMin),
                  _buildListitemContentWidget(data),
                  SizedBox(height: 10.wMin),
                  _buildListItemInfoWidget(data),
                ],
              ),
            ),
            Positioned(
              top: 10.wMin,
              right: 10.wMin,
              child: Obx((){
                bool selected = controller.selectAudioData.value?.uid == data.uid;
                return SvgPicture.asset(
                  selected ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
                  width: 28.wMin,
                  height: 28.wMin,
                  colorFilter: selected ? null : ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListitemTagsWidget(ManageAudioProjectEntity data){
    String checkStr = "未审核";
    Color checkColor = AppTheme.cSurfaceError.color;
    if(data.statusEnum == ManageAudioProjectStatusEnum.finished){
      checkStr = "待审核";
      checkColor = AppTheme.cSurfaceWarning.color;
    }else if(data.statusEnum == ManageAudioProjectStatusEnum.checked){
      checkStr = "已审核";
      checkColor = AppTheme.cSurfaceSuccess.color;
    }

    String userName = data.userName?.trim() ?? "";
    String creator = userName.isNotEmpty ? userName : (data.userId?.toString() ?? "-");

    return Row(
      children: [
        ManageTagFS16Widget(
          tag: "project_uid: ${data.uid ?? "-"}",
          bgColor: AppTheme.cSurfaceTertiary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
        SizedBox(width: 6.wMin),
        ManageTagFS16Widget(
          tag: "创建人: $creator",
          bgColor: AppTheme.cSurfaceTertiary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
        SizedBox(width: 6.wMin),
        ManageTagFS16Widget(
          tag: data.statusEnum?.value,
          bgColor: _statusBgColor(data),
          fontColor: _statusFontColor(data),
        ),

        const Spacer(),
        ManageTagFS16Widget(
          tag: data.statusEnum?.label ?? "-",
          bgColor: _statusBgColor(data),
          fontColor: _statusFontColor(data),
        ),
        SizedBox(width: 6.wMin),
        ManageTagFS16Widget(
          tag: checkStr,
          bgColor: checkColor.withValues(alpha: 0.2),
          fontColor: checkColor,
        ),
        SizedBox(width: 48.wMin),
      ],
    );
  }

  Widget _buildListitemContentWidget(ManageAudioProjectEntity data){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SelectableText(
          data.title??"",
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.wMin),
        SelectableText(
          "来源剧本: ${data.scriptTitle??''}",
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildListItemInfoWidget(ManageAudioProjectEntity data){
    String userName = data.userName?.trim() ?? "";
    String creator = userName.isNotEmpty ? userName : (data.userId?.toString() ?? "-");
    return Row(
      spacing: 16.wMin,
      children: [
        _buildListItemInfoItemWidget("创建用户: ", creator),
        _buildListItemInfoItemWidget("对话数: ", "${data.dialogueRelations?.length ?? 0}"),
        Visibility(
          visible: data.failedStage != null,
          child: _buildListItemInfoItemWidget("失败阶段: ", data.failedStage??""),
        ),
        Visibility(
          visible: data.statusEnum == ManageAudioProjectStatusEnum.failed,
          child: _buildListItemInfoItemWidget("失败原因: ", data.failedReason??""),
        ),
        const Spacer(),

        Visibility(
          visible: data.audioInfo?.audioUrl != null,
          child: Container(
            width: 500.wMin,
            height: 44.wMin,
            padding: EdgeInsets.symmetric(horizontal: 8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
              color: AppTheme.cSurfaceSecondary.color,
            ),
            child: AudioPlayUiWidget(
              audioUrl: data.audioInfo?.audioUrl,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListItemInfoItemWidget(String name, String value){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.wMin),
        color: AppTheme.cSurfaceQuaternary.color,
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
      ),
      child: Row(
        children: [
          SelectableText(
            name,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 4.wMin),
          SelectableText(
            value,
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusBgColor(ManageAudioProjectEntity data){
    ManageAudioProjectStatusEnum? status = data.statusEnum;
    if(status == ManageAudioProjectStatusEnum.failed){
      return AppTheme.cFeedbackErrorBackground.color;
    }
    if(status == ManageAudioProjectStatusEnum.checked){
      return AppTheme.cFeedbackSuccessBackground.color;
    }
    return AppTheme.cFeedbackWarningBackground.color;
  }

  Color _statusFontColor(ManageAudioProjectEntity data){
    ManageAudioProjectStatusEnum? status = data.statusEnum;
    if(status == ManageAudioProjectStatusEnum.failed){
      return AppTheme.cFeedbackErrorText.color;
    }
    if(status == ManageAudioProjectStatusEnum.checked){
      return AppTheme.cFeedbackSuccessText.color;
    }
    return AppTheme.cFeedbackWarningText.color;
  }

  
}