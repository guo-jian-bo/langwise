
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../common/visua_style_rules_dialog.dart';
import '../controllers/user_visual_style_controller.dart';
import 'user_visual_style_demo_dialog.dart';

class UserVisualStyleWidget extends GetView<UserVisualStyleController> {
  /// 视觉风格设置
  final String tagText;
  const UserVisualStyleWidget({super.key, required this.tagText});

  @override
  String? get tag => tagText;

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
            Container(height: 1.wMin, color: AppTheme.cBorderDefault.color),
            _buildModeWidget(context),
            _buildEffectiveStyleWidget(context),

            _buildStyleReviewWidget(context),
          ],
        ),
      );
    });
  }


  Widget _buildTitleWidget(){
    return Row(
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
          child: Text(
            "视觉风格偏好",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

      ],
    );
  }

  /// 模式切换
  Widget _buildModeWidget(BuildContext context){
    return Container(
      margin: EdgeInsets.only(top: 24.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "视觉模式",
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                "决定每道题目的视觉呈现方式",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TapScaleWidget(
                sclae: 1.05,
                onTap: OptimizeUtils.noneThrottle(() {
                  if(controller.teamStyleData.value.explain == null) return;
                  VisuaStyleRulesDialog.show(context: context, explain: controller.teamStyleData.value.explain??"");
                }, 1000),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    "assets/svg/user_center/icon_info.svg",
                    width: 32.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.wMin),
          Row(
            spacing: 16.wMin,
            children: [
              _buildModeItemWidget(
                mode: ResourceTypeEnum.image, 
                tag: "快速学习", 
                desc: "精美高光图片，瞬间捕捉语义，适合快速学习",
              ),
              _buildModeItemWidget(
                mode: ResourceTypeEnum.video, 
                tag: "推荐·沉浸体验", 
                desc: "不同口音不同人群演绎真实语境，配合多风格场景混搭，把母语场景带到你身边。",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeItemWidget({
    required ResourceTypeEnum mode,
    required String tag,
    required String desc,
  }){
    bool selected = mode == controller.resourceType.value;
    String iconRadio = "assets/svg/public/icon_radio2.svg";
    if(controller.resourceType.value == ResourceTypeEnum.video){
      iconRadio = "assets/svg/public/icon_radio1.svg";
    }

    return Expanded(
      child: TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() {
          controller.switchMode(mode);
        }, 1000),
        sclae: 1,
        child: Container(
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.wMin),
            color: selected ? mode.color.withValues(alpha: 0.12) : Colors.transparent,
            border: Border.all(
              color: selected ? mode.color.withValues(alpha: 0.2) : AppTheme.cBorderSubtle.color,
              width: 0.8.wMin,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64.wMin,
                height: 64.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: selected ? mode.color.withValues(alpha: 0.12) : AppTheme.cSurfaceLayerElevated.color,
                  border: Border.all(
                    color: selected ? mode.color.withValues(alpha: 0.2) : AppTheme.cBorderDefault.color,
                    width: 0.8.wMin,
                  ),
                ),
                child: SvgPicture.asset(
                  mode.svg,
                  width: 40.wMin,
                  colorFilter: ColorFilter.mode(
                    selected ? mode.color : AppTheme.cTextPrimary.color, 
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 16.wMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${mode.name}模式",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4.wMin),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 4.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.wMin),
                            color: mode.color.withValues(alpha: 0.12),
                            border: Border.all(
                              color: mode.color.withValues(alpha: 0.2),
                              width: 0.8.wMin,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: mode.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        SvgPicture.asset(
                          selected ? iconRadio : "assets/svg/public/icon_radio_un.svg",
                          width: 24.wMin,
                        ),
                      ],
                    ),
                    SizedBox(height: 6.wMin),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextSecondary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// 生效风格
  Widget _buildEffectiveStyleWidget(BuildContext context){
    return Container(
      margin: EdgeInsets.only(top: 24.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "生效风格",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false, // 隐藏滚动条
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(vertical: 12.wMin),
              child: Obx((){
                return Row(
                  spacing: 12.wMin,
                  children: List.generate(controller.ownStyleList.length, (index){
                    return _buildEffectiveStyleImageWidget(controller.ownStyleList[index]);
                  }),
                );
              }),
            ),
          ),

          Obx((){
            List<TeamStyleEntityStyleItems> effectiveStyleList = controller.getEffectiveStyleList();
            if(effectiveStyleList.length <= 1) return Container();
            
            return Container(
              padding: EdgeInsets.all(16.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: AppTheme.cSurfaceLayerBase.color,
              ),
              child: Row(
                spacing: 8.wMin,
                children: [
                  Row(
                    spacing: 8.wMin,
                    children: List.generate(effectiveStyleList.length, (index){
                      List<LanguageText?> styleTitle = effectiveStyleList[index].styleTitle??[];
                      LanguageText? localText = LearningLangUtils.getLocalLang(styleTitle);
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.wMin),
                          color: controller.resourceType.value.color.withValues(alpha: 0.12),
                          border: Border.all(
                            color: controller.resourceType.value.color.withValues(alpha: 0.2),
                            width: 0.8.wMin,
                          ),
                        ),
                        child: Text(
                          localText?.text??"",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: controller.resourceType.value.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }),
                  ),
                  Text(
                    "混搭中",
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Text.rich(TextSpan(
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(text: "语境 "),
                      TextSpan(
                        text: "${effectiveStyleList.length}X",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w600,
                        )
                      ),
                      TextSpan(text: " 加速"),
                    ],
                  )),
                ],
              ),
            );
          }),

        ],
      ),
    );
  }

  Widget _buildEffectiveStyleImageWidget(TeamStyleEntityStyleItems item){
    List<LanguageText?> styleTitle = item.styleTitle??[];
    LanguageText? localText = LearningLangUtils.getLocalLang(styleTitle);
    bool select = controller.takeEffectCodeList.contains(item.style??"");
    bool isSubscribed = controller.resourceType.value == ResourceTypeEnum.video ? item.videoRights == 1 : item.imageRights == 1;
    Color color = controller.resourceType.value.color;

    String checkSvg = "assets/svg/public/icon_check2.svg";
    if(controller.resourceType.value == ResourceTypeEnum.video){
      checkSvg = "assets/svg/public/icon_check1.svg";
    }

    // 资源
    String resourceName = "";
    if(item.imageRights == 1 && item.videoRights == 1){
      resourceName = "视频+图片";
    }else if(item.imageRights == 1){
      resourceName = "仅图片";
    }

    return Opacity(
      opacity: isSubscribed ? 1 : 0.6,
      child: TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() {
          controller.selectStyle(item);
        }, 1000),
        sclae: 1,
        child: Container(
          width: 180.wMin,
          height: 180.wMin,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            border: Border.all(
              color: select ? color : Colors.transparent,
              width: 2.wMin,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedImageWidget(
                  item.image?.imageUrl??"",
                  borderRadius: BorderRadius.circular(10.wMin),
                  errorWidget: buildEmptyWidget(),
                  placeholder: buildLoadingWidget(),
                ),
              ),
              Positioned(
                right: 6.wMin,
                top: 6.wMin,
                child: SvgPicture.asset(
                  select ? checkSvg : "assets/svg/public/icon_uncheck_box.svg",
                  width: 24.wMin,
                ),
              ),
              Positioned(
                bottom: 6.wMin,
                left: 6.wMin,
                child: Text(
                  localText?.text??"",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 6.wMin,
                right: 6.wMin,
                child: Text(
                  resourceName,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w400,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildStyleReviewWidget(BuildContext context){
    return Container(
      margin: EdgeInsets.only(top: 24.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "风格商店",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "不同画风 = 不同语境世界 · 一种场景，十种世界",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              Obx((){
                int subscribeCount = controller.teamStyleData.value.subscribeCount??0;
                int totalFee = controller.teamStyleData.value.totalFee??0;
                String totalFeeStr = NumberUtils.formatNumberWithCommas(totalFee.toDouble());

                return Text.rich(TextSpan(
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(text: "已订阅 $subscribeCount / ${controller.styleList.length}"),
                    TextSpan(text: " · 订阅消耗 "),
                    TextSpan(
                      text: totalFeeStr,
                      style: TextStyle(
                        color: AppTheme.cLearnSomethingPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(text: " 学点"),
                  ],
                ));
              }),

            ],
          ),
          SizedBox(height: 12.wMin),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Obx((){
                return Row(
                  spacing: 16.wMin,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(controller.styleList.length, (index){
                    return UserVisualStyleImageCardWidget(
                      data: controller.styleList[index], 
                      takeEffectCodeList: controller.takeEffectCodeList.toList(),
                      controller: controller,
                    );
                  }),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }



}


class UserVisualStyleImageCardWidget extends StatefulWidget {
  final TeamStyleEntityStyleItems data;
  final List<String> takeEffectCodeList;
  final UserVisualStyleController controller;
  const UserVisualStyleImageCardWidget({super.key, required this.data, required this.takeEffectCodeList, required this.controller});

  @override
  State<UserVisualStyleImageCardWidget> createState() => _UserVisualStyleImageCardWidgetState();
}

class _UserVisualStyleImageCardWidgetState extends State<UserVisualStyleImageCardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    
    return SizedBox(
      width: 320.wMin,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceTertiary.color,
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(
            color: AppTheme.cBorderSecondary.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          children: [

            _buildImageWidget(),
            
            _buildButtonsWidget(),
      
          ],
        ),
      ),
    );
  }


  Widget _buildImageWidget(){
    bool isSubscribed = widget.data.imageRights == 1 || widget.data.videoRights == 1;

    String? imageUrl = widget.data.image?.imageUrl;

    List<LanguageText?> styleTitle = widget.data.styleTitle??[];
    LanguageText? localText = LearningLangUtils.getLocalLang(styleTitle);

    List<LanguageText?> styleDesc = widget.data.styleDesc??[];
    LanguageText? localDescTextDesc = LearningLangUtils.getLocalLang(styleDesc);

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.wMin)),
            child: MouseRegion(
              onEnter: (event) {
                _isHovered = true;
                if(mounted) setState(() {});
              },
              onExit: (event) {
                _isHovered = false;
                if(mounted) setState(() {});
              },
              child: AnimatedScale(
                scale: _isHovered ? 1.08 : 1,
                duration: const Duration(milliseconds: 500),
                child: CachedImageWidget(
                  imageUrl??"",
                  errorWidget: buildEmptyWidget(),
                  placeholder: buildLoadingWidget(),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12.wMin,
            left: 12.wMin,
            child: Visibility(
              visible: widget.data.accessEnum == AccessEnum.NORMAL,
              child: Container(
                padding: EdgeInsets.all(4.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.wMin),
                  color: AppTheme.cStaticDeprecatedBlack60.color,
                  border: Border.all(
                    color: AppTheme.cStaticDeprecatedWhite50.color,
                    width: 0.8.wMin,
                  ),
                ),
                child: Text(
                  isSubscribed ? "已订阅" : "可订阅",
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.wMin),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localText?.text??"",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 4.wMin,
                      ),
                    ],
                  ),
                ),
                Text(
                  localDescTextDesc?.text??"",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w400,
                    shadows: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 4.wMin,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildButtonsWidget(){

    /// 是否为默认订阅
    bool isDefault = widget.data.imageForbidUnsubscribed == true && widget.data.videoForbidUnsubscribed == true;

    // 是否取消订阅
    bool unsubscribed = widget.data.unsubscribed == true;

    /// 是否有权限
    bool hasRights = widget.data.accessEnum == AccessEnum.NORMAL;

    /// 是否已经拥有
    bool isSubscribed = widget.data.imageRights == 1 || widget.data.videoRights == 1;

    // 是否过期
    bool expired = false;
    if(widget.data.expired != null){
      DateTime? expiredTime = DateFormatUtil.tryParseDate(widget.data.expired!);
      if(expiredTime != null){
        expired = expiredTime.isBefore(DateTime.now());
      }
    }


    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 16.wMin),
      child: Column(
        children: [
          Row(
            children: [
          
              ButtonWidget(
                text: "演示",
                width: 60.wMin,
                height: 40.wMin,
                borderRadius: 6.wMin,
                color: AppTheme.cSurfaceLayerBase.color,
                border: Border.all(
                  color: AppTheme.cBorderThin.color,
                  width: 0.8.wMin,
                ),
                fontColor: AppTheme.cTextBrand.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: OptimizeUtils.noneThrottle(() {
                  UserVisualStyleDemoDialog.show(
                    context: context, 
                    data: widget.data,
                  );
                }, 1000),
              ),
          
              SizedBox(width: 8.wMin),
              
              Expanded(
                child: _buildButtonsContentWidget(),
              ),
          
            ],
          ),

          SizedBox(height: 12.wMin),

          Row(
            children: [
              Visibility(
                visible: widget.data.expired != null,
                child: Text(
                  "到期 ${DateFormatUtil.formatStrtoStr(widget.data.expired??'')}",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: expired ? AppTheme.cSurfaceError.color : AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Spacer(),
              Visibility(
                visible: !expired && hasRights && !isDefault && isSubscribed,
                child: Text(
                  unsubscribed ? "已取消续费" : "自动续费中",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: unsubscribed ? AppTheme.cSurfaceError.color : AppTheme.cTextBrand.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Visibility(
                visible: expired,
                child: Text(
                  "已过期",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cSurfaceError.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }

  Widget _buildButtonsContentWidget(){
    /// 是否为默认订阅
    bool isDefault = widget.data.imageForbidUnsubscribed == true && widget.data.videoForbidUnsubscribed == true;

    if(isDefault){
      return ButtonWidget(
        text: "免费订阅",
        height: 40.wMin,
        borderRadius: 6.wMin,
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cSurfaceBlurSubtle.color,
          width: 0.8.wMin,
        ),
        fontColor: AppTheme.cTextTertiary.color,
        fontSize: 18.wMin,
        fontWeight: FontWeight.w500,
      );
    }

    if(widget.data.accessEnum != AccessEnum.NORMAL){
      return ButtonWidget(
        text: widget.data.statusHint??"制作中",
        height: 40.wMin,
        borderRadius: 6.wMin,
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cSurfaceBlurSubtle.color,
          width: 0.8.wMin,
        ),
        fontColor: AppTheme.cTextTertiary.color,
        fontSize: 18.wMin,
        fontWeight: FontWeight.w500,
      );
    }

    /// 是否订阅
    bool isSubscribed = widget.data.imageRights == 1 || widget.data.videoRights == 1;
    // 是否取消订阅
    bool unsubscribed = widget.data.unsubscribed == true;

    return ButtonWidget(
      text: isSubscribed ? (unsubscribed ? "重新订阅" : "管理风格") : "订阅此风格",
      height: 40.wMin,
      borderRadius: 6.wMin,
      color: AppTheme.cSurfaceBrand.color.withValues(alpha: isSubscribed && !unsubscribed ? 0.1 : 0.6),
      border: Border.all(
        color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.1),
        width: 0.8.wMin,
      ),
      fontColor: isSubscribed && !unsubscribed ? AppTheme.cTextBrand.color : Colors.white,
      fontSize: 18.wMin,
      fontWeight: FontWeight.w500,
      sclae: 1.03,
      onTap: OptimizeUtils.noneThrottle(() {
        widget.controller.styleActivation(context, widget.data);
      }, 1000),
    );


  }


}
