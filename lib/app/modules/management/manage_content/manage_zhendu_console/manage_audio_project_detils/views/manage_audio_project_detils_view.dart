import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';


import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../../enums/manage_audio_project_status_enum.dart';
import '../bindings/manage_audio_project_detils_binding.dart';
import '../controllers/manage_audio_project_detils_controller.dart';
import 'manage_audio_project_detils_scene_widget.dart';

class ManageAudioProjectDetilsView extends GetView<ManageAudioProjectDetilsController> {
  final String tagText;
  const ManageAudioProjectDetilsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_AUDIO_PROJECT_DETILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageAudioProjectDetilsView(tagText: tag),
      binding: ManageAudioProjectDetilsBinding(tag: tag),
      routeName: Routes.MANAGE_AUDIO_PROJECT_DETILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.getDetilData(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 150.wMin,
              right: 150.wMin,
              top: 24.wMin,
              bottom: 200.wMin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNameWidget(),
                _buildStatusWidget(),
                _buildProjectInfoWidget(context),
              ],
            ),
          ),
          Positioned(
            right: 8.wMin,
            bottom: 40.wMin,
            child: _buildToolButtonsWidget(),
          ),
        ],
      ),
    );
  }

    /// 工具按钮
  Widget _buildToolButtonsWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaAudioProjectCompose],
          child: ButtonWidget(
            text: "触发合成",
            padding: EdgeInsets.symmetric(horizontal: 10.wMin),
            height: 44.wMin,
            color: const Color(0xff00a6f4).withValues(alpha: 0.2),
            border: Border.all(width: 1.wMin, color: const Color(0xff00a6f4)),
            borderRadius: 8.wMin,
            fontSize: 18.wMin,
            fontColor: const Color(0xff00a6f4),
            sclae: 1.03,
            onTap: () {
              controller.composeAudioProject();
            },
          ),
        ),
      ],
    );
  }

  /// 名称
  Widget _buildNameWidget(){
    return Obx((){
      ManageAudioProjectDetilEntity data = controller.detilData.value;
      String userName = data.userName?.trim() ?? "";
      String creator = userName.isNotEmpty ? userName : (data.userId?.toString() ?? "-");

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                tag: "${data.statusEnum?.value??''}: ${data.statusEnum?.label??'-'}",
                bgColor: _statusBgColor(data),
                fontColor: _statusFontColor(data),
              ),
            ],
          ),
          SizedBox(height: 6.wMin),
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
          SizedBox(height: 6.wMin),
        ],
      );
    });
  }

  Color _statusBgColor(ManageAudioProjectDetilEntity data){
    ManageAudioProjectStatusEnum? status = data.statusEnum;
    if(status == ManageAudioProjectStatusEnum.failed){
      return AppTheme.cFeedbackErrorBackground.color;
    }
    if(status == ManageAudioProjectStatusEnum.checked){
      return AppTheme.cFeedbackSuccessBackground.color;
    }
    return AppTheme.cFeedbackWarningBackground.color;
  }

  Color _statusFontColor(ManageAudioProjectDetilEntity data){
    ManageAudioProjectStatusEnum? status = data.statusEnum;
    if(status == ManageAudioProjectStatusEnum.failed){
      return AppTheme.cFeedbackErrorText.color;
    }
    if(status == ManageAudioProjectStatusEnum.checked){
      return AppTheme.cFeedbackSuccessText.color;
    }
    return AppTheme.cFeedbackWarningText.color;
  }

  Widget _buildStatusWidget(){
    return Obx((){
      ManageAudioProjectDetilEntity data = controller.detilData.value;
      String checkStr = "未审核";
      // Color checkColor = AppTheme.cSurfaceError.color;
      if(data.statusEnum == ManageAudioProjectStatusEnum.finished){
        checkStr = "待审核";
        // checkColor = AppTheme.cSurfaceWarning.color;
      }else if(data.statusEnum == ManageAudioProjectStatusEnum.checked){
        checkStr = "已审核";
        // checkColor = AppTheme.cSurfaceSuccess.color;
      }
    
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildStatusItemWidget("创建人", data.userName??"", "userId: ${data.userId??""}"),
          ),
          SizedBox(width: 24.wMin),
          Expanded(
            child: _buildStatusItemWidget("当前状态", data.status??"", data.statusEnum?.label??""),
          ),
          SizedBox(width: 24.wMin),
          Visibility(
            visible: data.statusEnum == ManageAudioProjectStatusEnum.failed,
            child: Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 24.wMin),
                child: _buildStatusItemWidget("失败原因", data.failedStage??"", data.failedReason??""),
              ),
            ),
          ),
          Expanded(
            child: _buildStatusItemWidget("是否审核", checkStr, "checked: ${DateFormatUtil.formatStrtoStr(data.checked)}"),
          ),
        ],
      );
    });
  }

  Widget _buildStatusItemWidget(String name, String value, String value1){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4.wMin,
        children: [
          SelectableText(
            name,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SelectableText(
            value,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SelectableText(
            value1,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProjectInfoWidget(BuildContext context){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 16.wMin),
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            "脚本内容与台词音频状态",
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.wMin),
          _buildListWidget(),

          
        ],
      ),
    );
  }

  Widget _buildListWidget(){
    return Obx((){
      return ListView.separated(
        itemCount: controller.sceneList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => SizedBox(height: 24.wMin),
        itemBuilder: (context, index) {
          return ManageAudioProjectDetilsSceneWidget(controller: controller, data: controller.sceneList[index]);
        },
      );
    });
  }


}
