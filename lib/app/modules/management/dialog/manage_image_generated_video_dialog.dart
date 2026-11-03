
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../common/commons.dart';
import '../enums/video_aspect_ratio_enum.dart';
import '../manage_review/manage_review_video/model/video_rame_mode_enum.dart';
import '../utils/utils.dart';

/// 根据图片生成视频
class ManageImageGeneratedVideoDialog{
  static Future<bool> show({
    required BuildContext context,
    required ContentReviewImage image,
    required String? type,
    required int? uid,
    required int? semanticId,
  }) async{

    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return ManageImageGeneratedVideoDialogWidget(
          image: image,
          uid: uid,
          type: type,
          semanticId: semanticId,
        );
      },
    );

    return res??false;
  }
}

class ManageImageGeneratedVideoDialogWidget extends StatefulWidget {
  final ContentReviewImage image;
  final String? type;
  final int? uid;
  final int? semanticId;
  const ManageImageGeneratedVideoDialogWidget({
    super.key, 
    required this.image, 
    this.type, 
    this.uid, 
    this.semanticId,
  });

  @override
  State<ManageImageGeneratedVideoDialogWidget> createState() => _ManageImageGeneratedVideoDialogWidgetState();
}

class _ManageImageGeneratedVideoDialogWidgetState extends State<ManageImageGeneratedVideoDialogWidget> {

  /// 选择的生成模式
  VideoRameModeEnum? selectMode;

  /// 视频分辨率宽
  int videoWidth = 0;
  /// 视频分辨率高
  int videoHeight = 0;
  /// 编辑分辨率 - 可选择的视频分辨率列表
  final List<VideoAspectRatioEnum> editVideoAspectRatioList = VideoAspectRatioEnum.values;
  /// 编辑分辨率 - 选择的视频分辨率
  VideoAspectRatioEnum editSelectVideoAspectRatio = VideoAspectRatioEnum.ratio_1_1;
  /// 编辑分辨率 - 可选择的视频清晰度
  final List<VideoQualityEnum> editVideoQualityList = VideoQualityEnum.values;
  /// 编辑分辨率 - 选择的视频清晰度值
  VideoQualityEnum editSelectVideoQualityValue = VideoQualityEnum.quality_2k;

  @override
  void initState() {
    super.initState();

    bool isAuthFirstFrame = ManageAuthUtils.isAuth(ManageAuthCode.videoReviewGenerateFrameStart);
    if(isAuthFirstFrame){
      selectMode = VideoRameModeEnum.firstFrame;
    }else{
      selectMode = VideoRameModeEnum.firstAndLastFrame;
    }

    Size size = VideoRatioQualityUtils.getSize(editSelectVideoAspectRatio, editSelectVideoQualityValue);
    videoWidth = size.width.toInt();
    videoHeight = size.height.toInt();

  }

  /// 开始生成
  Future<void> startGenerating() async{
    if(widget.type == null || widget.uid == null){
      return ToastUtils.showToast(text: "type或uid为null");
    }

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "styleIds": [widget.image.styleId],
        // "numberOfVideos": generatedQuantity,
        "startFrameRelation": widget.image.semanticImageRelationId,
        "subContent": {
          "type": widget.type,
          "uid": widget.uid,
          "semanticId": widget.semanticId,
        },
      };
      
      String? reqRes;
      if(selectMode == VideoRameModeEnum.firstFrame){
        reqRes = await LanguageConsoleRequest.videoGenerateFrameStart(data: reqData);
      }else{
        reqRes = await LanguageConsoleRequest.videoGenerateFrameStartEnd(data: reqData);
      }
      if(reqRes == null) return;
      ToastUtils.showToast(text: reqRes, type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }

  }
  
  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "生成视频",
      width: 1000.wMin,
      onCancel: () => Get.back(),
      onConfirm: () => startGenerating(),
      child: Column(
        children: [
          Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageWidget(),
                Container(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20.wMin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGenerationModeWidget(),
                        Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
                        _buildVideoRatioWidget(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
          SizedBox(height: 20.wMin),
        ],
      ),
    );
  }

  Widget _buildImageWidget(){
    return Container(
      padding: EdgeInsets.all(20.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildTitltWidget("已选首帧图片"),
          SizedBox(height: 12.wMin),

          SizedBox(
            width: 320.wMin,
            height: 320.wMin,
            child: Stack(
              children: [

                Positioned.fill(
                  child: CachedImageWidget(
                    widget.image.imageUrl??"",
                    borderRadius: BorderRadius.circular(6.wMin),
                  ),
                ),

                Positioned(
                  top: 6.wMin,
                  left: 6.wMin,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4.wMin,
                    children: [
                      ManageTagFS16Widget(
                        tag: widget.image.styleTitle,
                        fontColor: Colors.white,
                        bgColor: const Color(0xff1DA1F2).withValues(alpha: 0.8),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.wMin),
                          color: const Color(0xCC393F5A),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 22.wMin,
                              child: CachedImageWidget(
                                widget.image.iconUrl ?? "",
                                errorWidget: buildEmptyWidget(),
                                placeholder: buildEmptyWidget(),
                              ),
                            ),
                            SizedBox(width: 4.wMin),
                            Text(
                              widget.image.localeTitle ?? '',
                              style: TextStyle(color: Colors.white, fontSize: 16.wMin),
                            ),
                          ],
                        ),
                      ),
                      ManageTagFS16Widget(
                        tag: "id:${widget.image.semanticImageRelationId??''}",
                        fontColor: Colors.white,
                        bgColor: const Color(0xCC393F5A),
                      ),
                      Visibility(
                        visible: widget.image.prompt != null,
                        child: ButtonWidget(
                          text: "prompt",
                          borderRadius: 4.wMin,
                          height: 28.wMin,
                          padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                          fontSize: 16.wMin,
                          sclae: 1.05,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          width: 800.wMin,
                                          padding: EdgeInsets.all(24.wMin),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1D1D1D),
                                            borderRadius: BorderRadius.circular(12.wMin),
                                          ),
                                          child: SelectableText(
                                            widget.image.prompt ?? '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.wMin,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 6.wMin,
                  bottom: 6.wMin,
                  child: ManageTagFS16Widget(
                    tag: "已确认首帧",
                    fontColor: Colors.white,
                    bgColor: AppTheme.cSurfaceSuccess.color,
                  ),
                ),

              ],
            ),
          ),


        ],
      ),
      
    );
  }

  /// 生成模式
  Widget _buildGenerationModeWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitltWidget("生成模式"),
        SizedBox(height: 12.wMin),

        Container(
          height: 74.wMin,
          width: double.infinity,
          padding: EdgeInsets.all(4.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cSurfacePrimary.color,
            borderRadius: BorderRadius.circular(10.wMin),
          ),
          child: Row(
            children: [
              ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.videoReviewGenerateFrameStart],
                child: _buildModeButtonWidget(VideoRameModeEnum.firstFrame, "由首帧生成视频"),
              ),
              ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.videoReviewGenerateStartEndFrames],
                child: _buildModeButtonWidget(VideoRameModeEnum.firstAndLastFrame, "首帧 + 尾帧约束生成"),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.wMin),
        
      ],
    );
  }


  Widget _buildModeButtonWidget(VideoRameModeEnum mode, String suTitle){
    bool selected = mode == selectMode;
    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          selectMode = mode;
          if(mounted) setState(() {});
        },
        sclae: 1,
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: selected ? AppTheme.cSurfaceInfo.color : Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${mode.name}模式",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: selected ? Colors.white : AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                suTitle,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: selected ? Colors.white : AppTheme.cTextQuaternary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }


  /// 视频分辨率
  Widget _buildVideoRatioWidget(){
    Size size = VideoRatioQualityUtils.getSize(editSelectVideoAspectRatio, editSelectVideoQualityValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.wMin),
        _buildTitltWidget("视频分辨率"),
        SizedBox(height: 12.wMin),
        Text(
          "比例",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),

        SizedBox(height: 6.wMin),

        Wrap(
          spacing: 10.wMin,
          runSpacing: 10.wMin,
          children: List.generate(editVideoAspectRatioList.length, (index){
            VideoAspectRatioEnum aspectRatio = editVideoAspectRatioList[index];
            bool isSelect = editSelectVideoAspectRatio == aspectRatio;

            return TapScaleWidget(
              onTap: () {
                editSelectVideoAspectRatio = aspectRatio;
                if(mounted) setState(() {});
              },
              sclae: 1.03,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.wMin),
                  color: AppTheme.cSurfaceTertiary.color,
                  border: Border.all(
                    width: 1.wMin,
                    color: isSelect ? AppTheme.cBorderBrand.color : Colors.transparent,
                  ),
                ),
                child: Text(
                  "${aspectRatio.width}:${aspectRatio.height} (${aspectRatio.name})",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
              ),
            );
          }),
        ),

        SizedBox(height: 12.wMin),

        Text(
          "清晰度",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),

        SizedBox(height: 6.wMin),

        Wrap(
          spacing: 10.wMin,
          runSpacing: 10.wMin,
          children: List.generate(editVideoQualityList.length, (index){
            VideoQualityEnum quality = editVideoQualityList[index];
            bool isSelect = editSelectVideoQualityValue == quality;

            return TapScaleWidget(
              onTap: () {
                editSelectVideoQualityValue = quality;
                if(mounted) setState(() {});
              },
              sclae: 1.03,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.wMin),
                  color: AppTheme.cSurfaceTertiary.color,
                  border: Border.all(
                    width: 1.wMin,
                    color: isSelect ? AppTheme.cBorderBrand.color : Colors.transparent,
                  ),
                ),
                child: Text(
                  "${quality.name} (${quality.value}p)",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
              ),
            );
          }),
        ),

        SizedBox(height: 12.wMin),

        Row(
          children: [
            SelectableText(
              "计算分辨率: ",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            SelectableText(
              "${size.width.toInt()} x ${size.height.toInt()}",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ],
        ),
          
      ],
    );
  }

  Widget _buildTitltWidget(String text){
    return Text(
      text,
      style: TextStyle(
        fontSize: 20.wMin,
        color: AppTheme.cTextSecondary.color,
      ),
    );
  }




}