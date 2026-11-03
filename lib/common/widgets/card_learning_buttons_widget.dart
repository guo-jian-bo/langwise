
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../app/modules/management/common/commons.dart';
import '../../theme/theme.dart';
import '../entities/entities.dart';
import '../enum/enum.dart';
import '../public_controller/config_controller.dart';
import 'widgets.dart';

class CardLearningButtonsWidget extends StatefulWidget {
  final bool showPreview;
  final void Function()? onPreview;
  
  final bool showFlash;
  final void Function()? onFlash;
  
  final bool showDictation;
  final void Function()? onDictation;
  
  final bool showDownload;
  final void Function()? onDownload;
  

  /// 预习 闪卡 听写 下载 按钮
  const CardLearningButtonsWidget({
    super.key,
    this.showPreview = true,
    this.onPreview,
    this.showFlash = true,
    this.onFlash,
    this.showDictation = true,
    this.onDictation,
    this.showDownload = true,
    this.onDownload,

  });

  @override
  State<CardLearningButtonsWidget> createState() => _CardLearningButtonsWidgetState();
}

class _CardLearningButtonsWidgetState extends State<CardLearningButtonsWidget> {

  @override
  Widget build(BuildContext context) {

    List<Widget> widgetList = [];
    if(widget.showPreview){
      widgetList.add(CardLearningButtonsItemWidget(
        title: '预习',
        svg: 'assets/svg/public/icons_eye.svg',
        color: const Color(0xff818CF8),
        index: 0,
        onTap: widget.onPreview,
      ));
    }

    if(widget.showDictation){
      widgetList.add(CardLearningButtonsItemWidget(
        title: '听写',
        svg: 'assets/svg/public/icon_earphones.svg',
        color: AppTheme.cSurfaceInfo.color,
        index: widgetList.length,
        onTap: widget.onDictation,
      ));
    }

    if(widget.showFlash){
      widgetList.add(CardLearningButtonsItemWidget(
        title: '闪记',
        svg: 'assets/svg/public/icon_lightning.svg',
        color: const Color(0xffEC4899),
        index: widgetList.length,
        onTap: widget.onFlash,
      ));
    }

    if(widget.showDownload){
      widgetList.add(CardLearningButtonsItemWidget(
        title: '下载',
        svg: 'assets/svg/public/icon_download.svg',
        color: const Color(0xff4ADE80),
        index: widgetList.length,
        onTap: widget.onDownload,
      ));
    }


    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16.wMin,
      children: widgetList,
    );
  }


}

class CardLearningButtonsItemWidget extends StatelessWidget {
  final String title;
  final String svg;
  final Color color;
  final int index;
  final void Function()? onTap;
  final int iconQuarterTurns;
  const CardLearningButtonsItemWidget({
    super.key, 
    required this.title, 
    required this.svg, 
    required this.color, 
    required this.index, 
    this.onTap,
    this.iconQuarterTurns = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListAnimationWidget(
      index: index,
      horizontalOffset: 70.wMin,
      delay: const Duration(milliseconds: 100),
      child: TapScaleWidget(
        sclae: 1.05,
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10.wMin,
              sigmaY: 10.wMin,
            ),
            child: Container(
              // width: width,
              height: 64.wMin,
              padding: EdgeInsets.symmetric(horizontal: 18.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: color.withValues(alpha: 0.15),
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                  width: 1.wMin,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4.wMin,
                children: [
                  RotatedBox(
                    quarterTurns: iconQuarterTurns,
                    child: SvgPicture.asset(
                      svg,
                      width: 32.wMin,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class CardLearningStyleButtonWidget extends StatefulWidget {
  final void Function()? onSubmit;
  /// 风格切换按钮
  const CardLearningStyleButtonWidget({super.key, this.onSubmit});

  @override
  State<CardLearningStyleButtonWidget> createState() => _CardLearningStyleButtonWidgetState();
}

class _CardLearningStyleButtonWidgetState extends State<CardLearningStyleButtonWidget> {
  @override
  Widget build(BuildContext context) {
    ConfigController controller = Get.find<ConfigController>();

    return Obx((){
      if(controller.allStyleList.isEmpty) return Container();
      return CardLearningButtonsItemWidget(
        title: controller.getCurrentStyleName(controller.currentShowStyleCode.value),
        svg: controller.currentShowResource.value.svg,
        color: controller.currentShowResource.value.color,
        index: 0,
        onTap: () async{
          CardLearningStyleDialogReslut? reslut = await CardLearningStyleDialog.show(context: context);
          if(reslut == null) return;
          controller.changeCurrentShowResource(reslut.resource);
          controller.changeCurrentStyleCode(reslut.style);
          widget.onSubmit?.call();
        },
      );
    });
  }
}

class CardLearningStyleDialogReslut{
  ResourceTypeEnum resource;
  String style;

  CardLearningStyleDialogReslut({
    required this.resource,
    required this.style,
  });
}

class CardLearningStyleDialog{

  static Future<CardLearningStyleDialogReslut?> show({
    required BuildContext context,
  }) async{
    CardLearningStyleDialogReslut? res = await showCupertinoDialog<CardLearningStyleDialogReslut?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return const CardLearningStyleDialogWidget();
      },
    );

    return res;
  }

}

class CardLearningStyleDialogWidget extends StatefulWidget {
  const CardLearningStyleDialogWidget({super.key});

  @override
  State<CardLearningStyleDialogWidget> createState() => _CardLearningStyleDialogWidgetState();
}

class _CardLearningStyleDialogWidgetState extends State<CardLearningStyleDialogWidget> {
  ConfigController controller = Get.find<ConfigController>();

  /// 所有风格列表
  List<TeamStyleEntityStyleItems> styleList = <TeamStyleEntityStyleItems>[];

  final List<ResourceTypeEnum> modeList = [
    ResourceTypeEnum.image,
    ResourceTypeEnum.video,
  ];
  ResourceTypeEnum selectMode = ResourceTypeEnum.image;
  late String selectStyle;

  @override
  void initState() {
    super.initState();
    selectMode = controller.currentShowResource.value;
    selectStyle = controller.currentShowStyleCode.value;

    if(selectMode == ResourceTypeEnum.image){
      styleList = controller.allStyleImageList.toList();
    }else{
      styleList = controller.allStyleVideoList.toList();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.wMin),
              child: Stack(
                children: [
                  Container(
                    width: 1200.wMin,
                    
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.wMin),
                      color: AppTheme.cSurfaceSecondary.color,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
    
                        SizedBox(height: 10.wMin),
                        
                        Container(
                          constraints: BoxConstraints(
                            minHeight: 400.wMin,
                            maxHeight: 800.wMin,
                          ),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(24.wMin),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 24.wMin,
                              children: [
                                _buildModeWidget(),
                                _buildImageStyleWidget(),
                              ],
                            ),
                          ),
                        ),
                        _buildButtonsWidget(),
                        
                      ],
                    ),
                  ),
                  Positioned(
                    right: 16.wMin,
                    top: 16.wMin,
                    child: TapScaleWidget(
                      sclae: 1.05,
                      onTap: () => Get.back(),
                      child: Container(
                        width: 42.wMin,
                        height: 42.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.cSurfaceTertiary.color,
                        ),
                        child: SvgPicture.asset(
                          "assets/svg/public/x.svg",
                          width: 24.wMin,
                          height: 24.wMin,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  /// 模式
  Widget _buildModeWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.wMin,
      children: [
        _buildTitleTextWidget("模式"),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modeList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.wMin,
            crossAxisSpacing: 12.wMin,
            mainAxisExtent: 64.wMin,
          ),
          itemBuilder: (context, index) {
            bool selected = selectMode == modeList[index];

            return TapScaleWidget(
              sclae: 1,
              onTap: () {

                selectMode = modeList[index];
                if(selectMode == ResourceTypeEnum.image){
                  styleList = controller.allStyleImageList.toList();
                }else{
                  styleList = controller.allStyleVideoList.toList();
                }

                bool isHave = false;
                for(int i = 0; i < styleList.length; i++){
                  if(styleList[i].style == selectStyle){
                    isHave = true;
                  }
                }

                if(!isHave){
                  selectStyle = styleList.first.style??"";
                }

                if(mounted) setState(() {});
              },
              child: _buildFilterItemWidget(
                name: modeList[index].name,
                isSelected: selected,
              ),
            );
          },
        ),
      ],
    );
  }

  /// 风格
  Widget _buildImageStyleWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.wMin,
      children: [
        _buildTitleTextWidget("风格"),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: styleList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12.wMin,
            crossAxisSpacing: 12.wMin,
            mainAxisExtent: 64.wMin,
          ),
          itemBuilder: (context, index) {
            bool selected = selectStyle == styleList[index].style;

            return TapScaleWidget(
              sclae: 1,
              onTap: () {
                if(styleList[index].style == null) return;
                selectStyle = styleList[index].style??"";
                if(mounted) setState(() {});
              },
              child: _buildFilterItemWidget(
                name: controller.getCurrentStyleName(styleList[index].style??""),
                isSelected: selected,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterItemWidget({required String name, bool isSelected = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: 64.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: isSelected ? AppTheme.cSurfaceTertiary.color : AppTheme.cSurfaceSecondary.color,
      ),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 24.wMin,
          color: isSelected ? AppTheme.cTextBrand.color : AppTheme.cTextSecondary.color,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildTitleTextWidget(String value) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 24.wMin,
        color: AppTheme.cTextSecondary.color,
        fontWeight: FontWeight.w400,
      ),
    );
  }



  /// 按钮
  Widget _buildButtonsWidget() {
    return Container(
      padding: EdgeInsets.all(24.wMin),
      child: Row(
        spacing: 12.wMin,
        children: [
          ManageButton(
            text: "重置",
            width: 350.wMin,
            height: 72.wMin,
            radius: 12.wMin,
            color: AppTheme.cSurfaceTertiary.color,
            borderColor: Colors.transparent,
            sclae: 1.02,
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
            onTap: () {
              
              selectMode = ResourceTypeEnum.image;
              selectStyle = styleList.first.style??"";
              if(selectMode == ResourceTypeEnum.image){
                styleList = controller.allStyleImageList.toList();
              }else{
                styleList = controller.allStyleVideoList.toList();
              }
              if(mounted) setState(() {});

            },
          ),
          Expanded(
            child: ManageButton(
              text: "确定",
              height: 72.wMin,
              radius: 12.wMin,
              color: AppTheme.cSurfaceInfo.color,
              borderColor: Colors.transparent,
              sclae: 1.005,
              style: TextStyle(
                fontSize: 28.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              onTap: () {
                CardLearningStyleDialogReslut reslut = CardLearningStyleDialogReslut(
                  resource: selectMode,
                  style: selectStyle,
                );
                Get.back(result: reslut);
              },
            ),
          ),
        ],
      ),
    );
  }



}
