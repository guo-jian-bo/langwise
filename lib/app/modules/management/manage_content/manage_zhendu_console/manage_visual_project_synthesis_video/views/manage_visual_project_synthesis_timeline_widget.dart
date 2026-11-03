
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:langwise/app/modules/management/common/manage_auth_box_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../../enums/manage_visual_video_status_enum.dart';
import '../controllers/manage_visual_project_synthesis_video_controller.dart';

class ManageVisualProjectSynthesisTimelineWidget extends StatelessWidget {
  final ManageVisualProjectSynthesisVideoController controller;
  final ManageVisualSceneVideoEntity data;
  const ManageVisualProjectSynthesisTimelineWidget({super.key, required this.controller, required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.wMin),
      child: Container(
        width: 330.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                _buildStatusWidget(context),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                  child: Column(
                    children: [
                      SizedBox(height: 8.wMin),
                      _buildContentWidget(),
                      SizedBox(height: 8.wMin),
                     
                    ],
                  ),
                ),
                SizedBox(height: 44.wMin),
            
              ],
            ),
            Positioned(
              bottom: 8.wMin,
              left: 0,
              right: 0,
              child:  _buildButtonWdiget(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWidget(BuildContext context){
    Widget body = Container();
    if(data.statusEnum == ManageVisualVideoStatusEnum.video_generating){
      body = _buildStatusGeneratingWidget();
    }else if(data.statusEnum == ManageVisualVideoStatusEnum.finished || data.statusEnum == ManageVisualVideoStatusEnum.checking){
      body = _buildStatusReviewWidget();
    }else if(data.statusEnum == ManageVisualVideoStatusEnum.checked){
      body = _buildStatusCheckedVideoWidget(context);
    }else if(data.statusEnum == ManageVisualVideoStatusEnum.failed){
      body = _buildStatusFailedWidget();
    }else{
      body = _buildStatusPendingWidget();
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: body,
        ),
        SizedBox(height: 10.wMin),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.wMin),
          child: Row(
            children: [
              ButtonWidget(
                text: data.typeEnum?.label ?? "",
                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                color: (data.typeEnum?.color??AppTheme.cSurfaceBrand.color).withValues(alpha: 0.2),
                borderRadius: 4.wMin,
                border: Border.all(width: 1.wMin, color: data.typeEnum?.color??AppTheme.cSurfaceBrand.color),
                fontSize: 16.wMin,
                fontColor: data.typeEnum?.color??AppTheme.cSurfaceBrand.color,
              ),
              const Spacer(),
              ButtonWidget(
                text: data.statusEnum?.name??"", // 已审核 待审核 生成中 失败
                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                color: (data.statusEnum?.color??AppTheme.cSurfaceBrand.color).withValues(alpha: 0.2),
                borderRadius: 4.wMin,
                border: Border.all(width: 1.wMin, color: data.statusEnum?.color??AppTheme.cSurfaceBrand.color),
                fontSize: 16.wMin,
                fontColor: data.statusEnum?.color??AppTheme.cSurfaceBrand.color,
              ),

            ],
          ),
        ),

      ],
    );
  }

  Widget _buildContentWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(data.scenes?.length??0, (index){
            return Text(
              "Scene ${data.scenes?[index]?.index??''} - ${data.scenes?[index]?.title??''}",
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary.color,
              ),
            );
          }),
        ),
        SizedBox(height: 8.wMin),
        Row(
          children: [
            SelectableText(
              "uid: ${data.uid??''}",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            const Spacer(),
            SelectableText(
              "${data.video?.duration??0}s",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ],
        ),
        Visibility(
          visible: data.directorialIntent != null,
          child: Container(
            margin: EdgeInsets.only(top: 8.wMin),
            width: double.infinity,
            padding: EdgeInsets.all(8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceQuaternary.color,
            ),
            child: SelectableText(
              data.directorialIntent??"",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  
  Widget _buildButtonWdiget(BuildContext context){
    return ManageAuthBoxWidget(
      authCodes: const [ManageAuthCode.dramaVisualProjectVideoSegmentDelete],
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.wMin),
        child: ButtonWidget(
          text: "删除",
          height: 34.wMin,
          padding: EdgeInsets.symmetric(horizontal: 8.wMin),
          color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
          borderRadius: 4.wMin,
          border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceError.color),
          fontSize: 16.wMin,
          fontColor: AppTheme.cSurfaceError.color,
          sclae: 1.05,
          onTap: () {
            controller.deleteVideo(context, data);
          },
        ),
      ),
    );
  }



  /// 视频 - 完成状态
  Widget _buildStatusCheckedVideoWidget(BuildContext context){
    return TapScaleWidget(
      onTap: () {
        controller.showPlayVideo(context, data);
      },
      sclae: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
      
          Positioned.fill(
            child: CachedImageWidget(
              data.scenes?.first?.startFrameUrl??"",
              placeholder: buildEmptyWidget(fit: BoxFit.cover),
              errorWidget: buildEmptyWidget(fit: BoxFit.cover),
            ),
          ),
      
          Container(
            width: 80.wMin,
            height: 80.wMin,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black45,
            ),
            child: Icon(
              Icons.play_arrow_sharp,
              size: 48.wMin,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }


  ///视频 - 待审核
  Widget _buildStatusReviewWidget(){
    return TapScaleWidget(
      onTap: () {
        controller.toReviewVideo(data);
      },
      sclae: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
      
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: CachedImageWidget(
                data.scenes?.first?.startFrameUrl??"",
                placeholder: buildEmptyWidget(fit: BoxFit.cover),
                errorWidget: buildEmptyWidget(fit: BoxFit.cover),
              ),
            ),
          ),
      
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10.wMin,
            children: [
              Icon(
                Icons.image_search,
                size: 48.wMin,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              Text(
                "待审核",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
      
        ],
      ),
    );
  }

  /// 视频 - 生成中
  Widget _buildStatusGeneratingWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10.wMin,
      children: [
        SpinKitFadingCircle(
          color: AppTheme.cBgBrand.color,
          size: 60.wMin,
        ),
        Text(
          "生成中",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
      ],
    );
  }

  /// 视频 - 待生成
  Widget _buildStatusPendingWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10.wMin,
      children: [
        Icon(
          Icons.generating_tokens_outlined,
          size: 60.wMin,
          color: AppTheme.cTextTertiary.color,
        ),
        Text(
          "待生成",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
      ],
    );
  }

  /// 视频 - 失败
  Widget _buildStatusFailedWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10.wMin,
      children: [
        Icon(
          Icons.warning_amber_rounded,
          size: 60.wMin,
          color: AppTheme.cSurfaceError.color,
        ),
        Text(
          "失败",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cSurfaceError.color,
          ),
        ),
      ],
    );
  }
  
  


}

