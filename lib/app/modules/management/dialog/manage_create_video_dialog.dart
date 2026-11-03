
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/utils/utils.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../theme/theme.dart';
import '../common/commons.dart';
import '../enums/video_aspect_ratio_enum.dart';
import '../manage_review/manage_review_video/model/video_rame_mode_enum.dart';

/// 新建视频
class ManageCreateVideoDialog{

  /// * 新建视频
  /// * videoTaskId 如果不为空 那么就是删除任务并新建
  static Future<bool> show({
    required BuildContext context,
    required String? type,
    required int? uid,
    required int? semanticId,
    int? videoTaskId,
    String subTitle = "选择风格和地区",
  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return ManageCreateVideoDialogWidget(
          uid: uid,
          type: type,
          semanticId: semanticId,
          videoTaskId: videoTaskId,
          subTitle: subTitle,
        );
      },
    );

    return res??false;
  }

}

class ManageCreateVideoDialogWidget extends StatefulWidget {
  final String? type;
  final int? uid;
  final int? semanticId;
  final int? videoTaskId;
  final String? subTitle;
  const ManageCreateVideoDialogWidget({
    super.key, 
    this.type, 
    this.uid, 
    this.semanticId,
    this.videoTaskId,
    this.subTitle,
  });

  @override
  State<ManageCreateVideoDialogWidget> createState() => _ManageCreateVideoDialogWidgetState();
}

class _ManageCreateVideoDialogWidgetState extends State<ManageCreateVideoDialogWidget> {

  /// 视频风格列表
  Map<String, List<ImageStyleConfigV2Item>> styleGroups = {};
  /// 选择的风格id列表
  Set<int> selectStyleIds = {};
  /// 分组展开列表
  Set<String> openGroups = {};


  /// 选择的生成模式
  VideoRameModeEnum? selectMode;

  /// 检查现有图片是否可以当首帧
  bool isCheckImage = false;

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

  /// 每个风格生成数量
  int generatedQuantity = 4;

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

    if(widget.videoTaskId == null){
      getStyleListV2();
    }
    
  }

  Future<void> getStyleListV2() async{
    try {
      ToastUtils.showLoading();
      ImageStyleConfigV2ResponseData? res = await LanguageUtil.getStyleListV2();
      if(res == null) return;
      styleGroups = res.groups;
      
      openGroups.addAll(styleGroups.keys.toList());

      if(mounted) setState(() {});
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 开始生成
  Future<void> startGenerating() async{
    if(widget.type == null || widget.uid == null){
      return ToastUtils.showToast(text: "type或uid为null");
    }

    if(selectStyleIds.isEmpty && widget.videoTaskId == null){
      return ToastUtils.showToast(text: "请选择风格");
    }

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "styleIds": selectStyleIds.toList(),
        "numberOfVideos": generatedQuantity,
        "width": videoWidth,
        "height": videoHeight,
        "subContent": {
          "type": widget.type,
          "uid": widget.uid,
          "semanticId": widget.semanticId,
        },
        "startFrameRelation": isCheckImage ? 0 : -1,
      };
      if(widget.videoTaskId != null){
        reqData['videoTaskId'] = widget.videoTaskId;
      }
      
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
      title: "新建视频 - ${widget.subTitle}",
      width: 800.wMin,
      onCancel: () => Get.back(),
      confirmText: "开始生成",
      onConfirm: () {
        startGenerating();
      },
      child: Container(
        padding: EdgeInsets.only(bottom: 16.wMin),
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 400.wMin,
          maxHeight: 800.wMin,
        ),
        child: Column(
          children: [
            Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGenerationModeWidget(),
                    Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
                    _buildCheckImageCheckboxWidget(),
                    Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
                    _buildVideoRatioWidget(),
                    Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
                    _buildGeneratedQuantityWidget(),
                    Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
                    _buildStyleListWidget(),
                  ],
                ),
              ),
            ),
            Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
          ],
        ),
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

  /// 检查现有图片是否可以当首帧
  Widget _buildCheckImageCheckboxWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.wMin),
        TapScaleWidget(
          onTap: () {
            isCheckImage = !isCheckImage;
            if(mounted) setState(() {});
          },
          sclae: 1,
          child: Container(
            color: Colors.transparent,
            child: Row(
              spacing: 10.wMin,
              children: [
                SvgPicture.asset(
                  isCheckImage ? "assets/svg/manage/icon_check_box.svg" : "assets/svg/manage/icon_uncheck_box.svg",
                  width: 24.wMin,
                  height: 24.wMin,
                ),
                _buildTitltWidget("检查现有图片是否可以当首帧"),
              ],
            ),
          ),
        ),
        SizedBox(height: 20.wMin),
      ],
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

        SizedBox(height: 20.wMin),
          
      ],
    );
  }

  /// 每个生成数量
  Widget _buildGeneratedQuantityWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.wMin),
        Row(
          children: [
            _buildTitltWidget("每个风格生成数量"),
            const Spacer(),
            TapScaleWidget(
              onTap: () {
                if(generatedQuantity <= 1) return;
                generatedQuantity --;
                if(mounted) setState(() {});
              },
              sclae: 1.1,
              child: _buildNumberButtonWidget(Icons.remove),
            ),

            Container(
              width: 60.wMin,
              alignment: Alignment.center,
              child: Text(
                "$generatedQuantity",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ),

            TapScaleWidget(
              onTap: () {
                if(generatedQuantity >= 4) return;
                generatedQuantity ++;
                if(mounted) setState(() {});
              },
              sclae: 1.1,
              child: _buildNumberButtonWidget(Icons.add),
            ),

          ],
        ),
        SizedBox(height: 20.wMin),
      ],
    );
  }


  /// 风格列表
  Widget _buildStyleListWidget(){
    if(widget.videoTaskId != null) return Container();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.wMin),
      child: Column(
        spacing: 16.wMin,
        children: List.generate(styleGroups.keys.length, (index){

          return _buildStyleListGroupWidget(styleGroups.keys.toList()[index]);

        }),
      ),
    );
  }

  Widget _buildStyleListGroupWidget(String group){
    bool selected = openGroups.contains(group);

    List<ImageStyleConfigV2Item> list = styleGroups[group]??[];

    return Column(
      children: [

        TapScaleWidget(
          onTap: () {
            if(selected){
              openGroups.remove(group);
            }else{
              openGroups.add(group);
            }
            if(mounted) setState(() {});
          },
          sclae: 1,
          child: Container(
            height: 44.wMin,
            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.wMin),
              color: AppTheme.cSurfaceTertiary.color,
            ),
            child: Row(
              children: [
                Text(
                  group,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: selected ? AppTheme.cTextBrand.color : AppTheme.cTextPrimary.color,
                  ),
                ),
              ],
            ),
          ),
        ),

        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          secondChild: Container(width: double.infinity), 
          firstChild: Container(
            padding: EdgeInsets.symmetric(vertical: 8.wMin),
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6.wMin,
              runSpacing: 6.wMin,
              children: List.generate(list.length, (index){
                return _buildStyleListGroupItemWidget(list[index]);
              }),
            ),
          ), 
          crossFadeState: selected ? CrossFadeState.showFirst : CrossFadeState.showSecond, 
        ),



      ],
    );
  }

  Widget _buildStyleListGroupItemWidget(ImageStyleConfigV2Item style){
    bool isSelect = selectStyleIds.contains(style.uid);

    List<String> flagList = style.iconUrls??[];

    return TapScaleWidget(
      onTap: () {
        if(isSelect){
          selectStyleIds.remove(style.uid);
        }else{
          selectStyleIds.add(style.uid);
        }
        if(mounted) setState(() {});
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          color: AppTheme.cSurfaceTertiary.color,
          border: Border.all(
            width: 1.wMin,
            color: isSelect ? AppTheme.cBorderBrand.color : Colors.transparent,
          ),
        ),
        child: Row(
          spacing: 4.wMin,
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              spacing: 2.wMin,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(flagList.length, (index){
                return SizedBox(
                  width: 28.wMin,
                  child: CachedImageWidget(
                    flagList[index],
                    errorWidget: buildEmptyWidget(),
                    placeholder: buildEmptyWidget(),
                  ),
                );
              }),
            ),

            Text(
              style.localeTitle??"",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),

          ],
        ),
      ),
    );
  }


  Widget _buildNumberButtonWidget(IconData icon){
    return Container(
      width: 40.wMin,
      height: 40.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Icon(icon, color: AppTheme.cTextPrimary, size: 20.wMin),
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