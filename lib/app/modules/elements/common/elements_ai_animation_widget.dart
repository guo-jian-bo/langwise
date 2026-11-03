import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/widgets/list_animation_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class AiAnimationModel {
  final String name;
  final String iconSvg;
  final Color svgBackColor;
  final String? subName;
  final String? completeSubName;
  final bool showProgress;
  
  AiAnimationModel({
    required this.name, 
    required this.iconSvg, 
    required this.svgBackColor, 
    this.subName,
    this.completeSubName,
    this.showProgress = true,
  });
}

class _AiAnimationRunModel{
  String name;
  String? subName;
  String? completeSubName;
  String iconSvg;
  Color svgBackColor;
  bool isCompleted = false;
  int process = 0;
  bool show = false;
  bool showProgress;
  _AiAnimationRunModel({
    required this.name,
    this.subName,
    this.completeSubName,
    required this.svgBackColor,
    required this.iconSvg,
    this.showProgress = true,
  });
}

class ElementsAiAnimationWidget extends StatefulWidget {
  final List<AiAnimationModel> animationList;
  final String introduce;
  final String? knowledge;
  final void Function(bool result)? onComplete;
  final Future<bool> Function()? onRequest;
  const ElementsAiAnimationWidget({
    super.key, 
    required this.animationList, 
    required this.introduce, 
    this.knowledge, 
    this.onComplete,
    this.onRequest,
  });

  @override
  State<ElementsAiAnimationWidget> createState() => _ElementsAiAnimationWidgetState();
}

class _ElementsAiAnimationWidgetState extends State<ElementsAiAnimationWidget> {

  List<_AiAnimationRunModel> animationRunList = [];

  @override
  void initState() {
    super.initState();
    if(widget.animationList.isNotEmpty){

      for(int i = 0; i < widget.animationList.length; i++){
        animationRunList.add(_AiAnimationRunModel(
          name: widget.animationList[i].name,
          svgBackColor: widget.animationList[i].svgBackColor,
          subName: widget.animationList[i].subName,
          completeSubName: widget.animationList[i].completeSubName,
          iconSvg: widget.animationList[i].iconSvg,
          showProgress: widget.animationList[i].showProgress,
        ));
      }
      animationRunList.first.show = true;
      run();
    }
    
  }

  Future<void> run() async{
    bool result = false;
    for(int i = 0; i < animationRunList.length; i++){
      
      if(!animationRunList[i].showProgress) {
        animationRunList[i].isCompleted = true;
        if(mounted) setState(() {});
        continue;
      }
      await Future.delayed(const Duration(milliseconds: 800));
      if(!mounted) break;
      for(int j = 0; j <= 10; j++){
        int randomDuration = Random().nextInt(10) + 100;
        await Future.delayed(Duration(milliseconds: randomDuration));
        if(!mounted) break;
        animationRunList[i].process = j * 10;
        if(mounted) setState(() {});
      }
      await Future.delayed(const Duration(milliseconds: 200));
      if(!mounted) break;
      animationRunList[i].isCompleted = true;
      if(mounted) setState(() {});
      if(i + 1 < widget.animationList.length){
        await Future.delayed(const Duration(milliseconds: 100));
        if(!mounted) break;
        animationRunList[i + 1].show = true;
        if(mounted) setState(() {});
      }

      if(i == widget.animationList.length - 3){
        result = (await widget.onRequest?.call())??false;
      }
    }

    await Future.delayed(const Duration(milliseconds: 2000));
    if(mounted) widget.onComplete?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.wMin),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.cFeedbackInfoBackground,
              borderRadius: BorderRadius.circular(8.wMin),
            ),
            child: Text(
              widget.introduce,
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cFeedbackInfoText,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Visibility(
            visible: widget.knowledge != null,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 40.wMin),
              padding: EdgeInsets.all(16.wMin),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.cBgTertiary,
                borderRadius: BorderRadius.circular(12.wMin),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "当前知识点",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextTertiary,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                        decoration: BoxDecoration(
                          color: AppTheme.cDifficultyBackgroundColor1,//动态颜色
                          borderRadius: BorderRadius.circular(4.wMin),
                        ),
                        child: Text(
                          "已掌握",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.cStaticWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.wMin),
                  Text(
                    widget.knowledge??"",
                    style: TextStyle(
                      fontSize: 40.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary,
                    ),
                  ),
                  SizedBox(height: 40.wMin),
                ],
              ),
            ),
          ),
          SizedBox(height: 40.wMin),

          Column(
            spacing: 40.wMin,
            children: List.generate(animationRunList.length, (index){
              return Visibility(
                visible: animationRunList[index].show,
                child: _buildAnimationItemWidget(animationRunList[index]),
              );
            }),
          ),
        ],
      ),
    );
  }


  Widget _buildAnimationItemWidget(_AiAnimationRunModel data){
    return ListAnimationWidget(
      verticalOffset: 20.wMin,
      child: Row(
        spacing: 12.wMin,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64.wMin,
            height: 64.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: data.isCompleted ? data.svgBackColor : AppTheme.cFeedbackDefaultBackground,
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: SvgPicture.asset(
                data.iconSvg,
                key: ValueKey(data.isCompleted),
                width: 32.wMin,
                height: 32.wMin,
                colorFilter: data.isCompleted ? null : const ColorFilter.mode(
                  AppTheme.cFeedbackDefaultIcon, 
                  BlendMode.srcIn,
                ),
            ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary,
                  ),
                ),
    
                Visibility(
                  visible: data.showProgress,
                  child: Container(
                    alignment: Alignment.topLeft,
                    height: 30.wMin,
                    child: Row(
                      spacing: 8.wMin,
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              if(data.process == 0 || data.isCompleted){
                                return Visibility(
                                  visible: data.subName != null,
                                  child: Text(
                                    data.isCompleted ? data.completeSubName??"" : data.subName??"",
                                    style: TextStyle(
                                      fontSize: 20.wMin,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.cTextSecondary.color,
                                    ),
                                  ),
                                );
                              }
                              return Container(
                                height: 8.wMin,
                                width: double.infinity,
                                alignment: Alignment.topLeft,
                                decoration: BoxDecoration(
                                  color: AppTheme.cFeedbackDefaultBackground,
                                  borderRadius: BorderRadius.circular(100.wMin),
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  width: constraints.maxWidth * (data.process / 100),
                                  decoration: BoxDecoration(
                                    color: data.svgBackColor,
                                    borderRadius: BorderRadius.circular(100.wMin),
                                  ),
                                ),
                              );
                          
                            },
                          ),
                        ),
                        Visibility(
                          visible: data.process != 0 && !data.isCompleted,
                          child: Text(
                            "${data.process}%",
                            style: TextStyle(
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.cTextPrimary,
                            ),
                          ),
                        )
                    
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: data.isCompleted ? SvgPicture.asset(
              "assets/svg/elements/icon_check.svg",
              key: ValueKey(data.isCompleted),
              width: 32.wMin,
              height: 32.wMin,
            ) : SpinKitDualRing(
              color: AppTheme.cFeedbackDefaultIcon,
              key: ValueKey(data.isCompleted),
              size: 32.wMin,
              lineWidth: 2.wMin,
              duration: const Duration(milliseconds: 300),
            ),
          ),
      
        ],
      ),
    );
  }


}