
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../controllers/user_visual_style_controller.dart';

class UserVisualStyleWidget extends GetView<UserVisualStyleController> {
  /// 视觉风格设置
  const UserVisualStyleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx((){
      if(controller.styleList.isEmpty) return Container();
      return Container(
        margin: EdgeInsets.only(top: 32.wMin),
        width: double.infinity,
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceSecondary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(),
            SizedBox(height: 24.wMin),
            Container(height: 1.wMin, color: AppTheme.cBorderPrimary),
            _buildErrWidget(context),

            _buildShowStyleListWidget(context),

            _buildStyleReviewWidget(context),
          ],
        ),
      );
    });
  }


  Widget _buildTitleWidget(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50.wMin,
          height: 50.wMin,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cFeedbackInfoBackground,
          ),
          child: SvgPicture.asset(
            'assets/svg/user_center/icon_user_style.svg',
            width: 30.wMin,
            height: 30.wMin,
          ),
        ),
        SizedBox(width: 8.wMin),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.wMin,
            children: [
              Text(
                "视觉风格偏好",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '自定义内容风格',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.wMin),

        Obx((){
          return _buildNumberWidget("我的风格", controller.teamStyleData.value.activateCount?.toString());
        }),
        SizedBox(width: 24.wMin),
        Obx((){
          String? totalFee = NumberUtils.formatNumberWithCommas((controller.teamStyleData.value.totalFee??0).toDouble());
          return _buildNumberWidget("每日消耗总数", totalFee);
        }),

      ],
    );
  }


  Widget _buildNumberWidget(String name, String? value){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      height: 48.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Row(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
              fontWeight: FontWeight.w400,
            ),
          ),
          Container(
            width: 1.wMin,
            height: 16.wMin,
            margin: EdgeInsets.symmetric(horizontal: 16.wMin),
            color: AppTheme.cBorderTertiary.color,
          ),
          Text(
            value??"",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrWidget(BuildContext context){

    return Obx((){
      if(controller.teamStyleData.value.paymentStatus == 1) return Container();
      return Container(
        margin: EdgeInsets.only(top: 24.wMin),
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cFeedbackWarningBackground.color,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/svg/public/icon_danger.svg",
              width: 24.wMin,
              height: 24.wMin,
            ),
            SizedBox(width: 12.wMin),
            Text(
              controller.teamStyleData.value.paymentHint??"",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cFeedbackWarningText.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            ButtonWidget(
              text: "去充值",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              height: 40.wMin,
              borderRadius: 6.wMin,
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
              fontColor: AppTheme.cFeedbackWarningText.color,
              fontSize: 22.wMin,
              fontWeight: FontWeight.w600,
              sclae: 1.03,
              onTap: () {
                controller.toRecharge();
              },
            ),
            SizedBox(width: 12.wMin),
            ButtonWidget(
              text: "重试订阅",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              height: 40.wMin,
              borderRadius: 6.wMin,
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
              fontColor: AppTheme.cTextSecondary.color,
              fontSize: 22.wMin,
              fontWeight: FontWeight.w600,
              sclae: 1.03,
              onTap: () {
                controller.retry(context);
              },
            ),
          ],
        ),
      );
    });
  }


  Widget _buildShowStyleListWidget(BuildContext context){
    return Obx((){
      return Container(
        margin: EdgeInsets.only(top: 24.wMin),
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(width: 4.wMin, color: controller.resourceType.value.color),
          ),
          borderRadius: BorderRadius.horizontal(right: Radius.circular(16.wMin)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              controller.resourceType.value.color.withValues(alpha: 0.15),
              controller.resourceType.value.color.withValues(alpha: 0),
            ],
          ),
        ),
        child: Column(
          spacing: 16.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
            
                Text(
                  "当前生效风格",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            
                const Spacer(),
            
                TapScaleWidget(
                  onTap: () {
                    controller.manageVisualStyle(context);
                  },
                  sclae: 1.03,
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Text(
                          "管理生效风格",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: controller.resourceType.value.color,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SvgPicture.asset(
                          "assets/svg/public/icon_arrow_right_thin.svg",
                          width: 32.wMin,
                          colorFilter: ColorFilter.mode(controller.resourceType.value.color, BlendMode.srcIn),
                        ),
                      ],
                    ),
                  ),
                ),
            
              ],
            ),


            Row(
              children: [

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                  height: 44.wMin,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: controller.resourceType.value.color,
                  ),
                  child: Row(
                    spacing: 6.wMin,
                    children: [
                      SvgPicture.asset(
                        controller.resourceType.value.svg,
                        width: 28.wMin,
                      ),
                      Text(
                        "${controller.resourceType.value.name}模式",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                    child: Obx((){
                      return Row(
                        spacing: 24.wMin,
                        children: List.generate(controller.takeEffectList.length, (index){
                  
                          List<LanguageText?> styleTitle = controller.takeEffectList[index].styleTitle??[];
                          LanguageText? localText = LearningLangUtils.getLocalLang(styleTitle);
                  
                          return Container(
                            height: 44.wMin,
                            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.wMin),
                              color: controller.resourceType.value.color.withValues(alpha: 0.05),
                            ),
                            child: Row(
                              spacing: 6.wMin,
                              children: [
                                Container(
                                  width: 14.wMin,
                                  height: 14.wMin,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: controller.resourceType.value.color,
                                  ),
                                ),
                                Text(
                                  localText?.text??"",
                                  style: TextStyle(
                                    fontSize: 24.wMin,
                                    color: AppTheme.cTextPrimary.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ],
            ),

          ],
        ),
      );
    });
  }


  Widget _buildStyleReviewWidget(BuildContext context){
    return Container(
      margin: EdgeInsets.only(top: 24.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "视觉风格预览",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.wMin),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx((){
              return Row(
                spacing: 16.wMin,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(controller.styleList.length, (index){
                  return _buildStyleItemWidget(context, controller.styleList[index]);
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleItemWidget(BuildContext context, UserVisualStyleModel data){

    String? imageUrl = data.data.image?.imageUrl;

    if(data.showResource == ResourceTypeEnum.video){
      imageUrl = data.data.video?.firstFrameUrl;
    }

    List<LanguageText?> styleTitle = data.data.styleTitle??[];
    LanguageText? localText = LearningLangUtils.getLocalLang(styleTitle);

    return SizedBox(
      width: 380.wMin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.wMin),
        child: Container(
          color: AppTheme.cSurfaceTertiary.color,
          child: Column(
            children: [
      
              Obx((){
                bool isPlayCurrent = data.data.uid == controller.videoPlayId.value;
                bool playing = isPlayCurrent && controller.videoPlaying.value;
                return SizedBox(
                  width: 380.wMin,
                  height: 380.wMin,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [

                        Visibility(
                          visible: isPlayCurrent,
                          child: Video(
                            controller: controller.videoController,
                            fill: AppTheme.cSurfaceTertiary.color,
                            controls: (p0) {
                              return Container();
                            },
                          ),
                        ),

                        IgnorePointer(
                          ignoring: data.showResource == ResourceTypeEnum.image,
                          child: TapScaleWidget(
                            onTap: () {
                              controller.playVideo(data);
                            },
                            sclae: 1,
                            child: Opacity(
                              opacity: isPlayCurrent ? 0 : 1,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: CachedImageWidget(
                                  imageUrl??"",
                                  errorWidget: buildEmptyWidget(),
                                  placeholder: buildLoadingWidget(),
                                  key: ValueKey(imageUrl),
                                ),
                              ),
                            ),
                          ),
                        ),

                        

                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: (data.showResource == ResourceTypeEnum.video && data.data.video?.videoUrl != null) && !playing ? 1 : 0,
                          child: IgnorePointer(
                            ignoring: true,
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 80.wMin,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 12.wMin,
                          child: _buildStyleItemSwitchWidget(data),
                        ),
        
                      ],
                    ),
                  ),
                );
              }),
      
              SizedBox(height: 12.wMin),
      
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                child: Row(
                  children: [
                      
                    Expanded(
                      child: Text(
                        localText?.text??"",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                
                    Visibility(
                      visible: data.data.imageRights == 1,
                      child: _buildStyleTagWidget(
                        text: "图片已激活",
                        color: const Color(0xff00BC7D),
                      ),
                    ),
                
                    Visibility(
                      visible: data.data.videoRights == 1,
                      child: Container(
                        margin: EdgeInsets.only(left: 4.wMin),
                        child: _buildStyleTagWidget(
                          text: "视频已激活",
                          color: const Color(0xffA855F7),
                        ),
                      ),
                    ),
                      
                  ],
                ),
              ),

              SizedBox(height: 16.wMin),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                child: _buildStyleItemButtonWidget(context, data),
              ),

              SizedBox(height: 16.wMin),

            ],
          ),
        ),
      ),
    );
  }


  Widget _buildStyleItemButtonWidget(BuildContext context, UserVisualStyleModel data){

    int status = data.data.imageStatus??1;
    if(data.showResource == ResourceTypeEnum.video){
      status = data.data.videoStatus??1;
    }

    if(status == 2){
      return ButtonWidget(
        text: data.data.statusHint??"",
        height: 48.wMin,
        color: AppTheme.cInverseOverlay4.color,
        fontColor: AppTheme.cTextPrimary.color,
        fontSize: 22.wMin,
        borderRadius: 8.wMin,
      );
    }

    if(status == 3){
      return ButtonWidget(
        text: "未开放",
        height: 48.wMin,
        color: AppTheme.cInverseOverlay4.color,
        fontColor: AppTheme.cTextPrimary.color,
        fontSize: 22.wMin,
        borderRadius: 8.wMin,
      );
    }

    if(status != 1){
      return Container();
    }

    ResourceTypeEnum showResource = data.showResource;

    bool rights = data.data.imageRights == 1;
    if(showResource == ResourceTypeEnum.video){
      rights = data.data.videoRights == 1;
    }

    if(!rights || (data.data.unsubscribed??false)){
      return ButtonWidget(
        text: "去订阅",
        height: 48.wMin,
        color: AppTheme.cInverseOverlay4.color,
        fontColor: AppTheme.cTextPrimary.color,
        fontSize: 22.wMin,
        borderRadius: 8.wMin,
        sclae: 1.03,
        onTap: () {
          controller.styleActivation(context, data);
        },
      );
    }

    return ButtonWidget(
      text: "订阅中",
      height: 48.wMin,
      color: AppTheme.cInverseOverlay4.color,
      fontColor: AppTheme.cTextPrimary.color,
      fontSize: 22.wMin,
      borderRadius: 8.wMin,
      sclae: 1.03,
      onTap: () {
        controller.unsubscribe(context, data);
      },
    );

  }


  Widget _buildStyleTagWidget({
    required String text,
    required Color color,
  }){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        border: Border.all(width: 1.wMin, color: color),
        color: color.withValues(alpha: 0.2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18.wMin,
          color: color,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }


  Widget _buildStyleItemSwitchWidget(UserVisualStyleModel data){

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.wMin, sigmaY: 5.wMin),
        child: Container(
          height: 48.wMin,
          width: 356.wMin,
          padding: EdgeInsets.symmetric(horizontal: 4.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: Colors.black.withValues(alpha: 0.1),
            border: Border.all(width: 1.wMin, color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Visibility(
                visible: data.data.imageStatus != 0 && data.data.videoStatus != 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: data.showResource == ResourceTypeEnum.image ? Alignment.centerLeft : Alignment.centerRight,
                  child: AnimatedContainer(
                    width: 356.wMin / 2,
                    height: 40.wMin,
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: data.showResource.color.withValues(alpha: 0.2),
                      border: Border.all(
                        width: 1.wMin,
                        color: data.showResource.color,
                      ),
                    ),
                  ),
                ),
              ),
              
              Row(
                children: [
                  _buildStyleItemSwitchItemWidget(data, ResourceTypeEnum.image),
                  _buildStyleItemSwitchItemWidget(data, ResourceTypeEnum.video),
                ],
              ),
              
            ],
          ),
        ),
      ),
    );

  }

  Widget _buildStyleItemSwitchItemWidget(UserVisualStyleModel data, ResourceTypeEnum type){
    if(type == ResourceTypeEnum.image){
      if(data.data.imageStatus == 0){
        return Container();
      }
    }else{
      if(data.data.videoStatus == 0){
        return Container();
      }
    }

    bool selected = data.showResource == type;

    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          controller.switchResourceType(data, type);
        },
        sclae: 1.03,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: selected ? 1 : 0.6,
          child: SizedBox(
            height: double.infinity,
            child: Row(
              spacing: 8.wMin,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  type.svg,
                  width: 28.wMin,
                ),
                Text(
                  type.name,
                  style: TextStyle(
                    fontSize: 22.wMin,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}