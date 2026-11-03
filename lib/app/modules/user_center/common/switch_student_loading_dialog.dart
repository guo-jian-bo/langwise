import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';

/// 切换学员加载弹窗
class SwitchStudentLoadingDialog{

  static Future<void> show({
    required BuildContext context,
    String? currentAvatarUrl,
    String? currentName,
    String? targetAvatarUrl,
    String? targetName,
    Future<void> Function()? onComplete,
  }) async{
    await showCupertinoDialog(
      context: context, 
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SwitchStudentLoadingDialogWidget(
          currentAvatarUrl: currentAvatarUrl,
          currentName: currentName,
          targetAvatarUrl: targetAvatarUrl,
          targetName: targetName,
          onComplete: onComplete,
        );
      },
    );
  }

}

class SwitchStudentLoadingDialogWidget extends StatefulWidget {
  final String? currentAvatarUrl;
  final String? currentName;
  final String? targetAvatarUrl;
  final String? targetName;
  final Future<void> Function()? onComplete;

  const SwitchStudentLoadingDialogWidget({
    super.key, 
    this.currentAvatarUrl, 
    this.currentName, 
    this.targetAvatarUrl, 
    this.targetName, 
    this.onComplete
  });

  @override
  State<SwitchStudentLoadingDialogWidget> createState() => _SwitchStudentLoadingDialogWidgetState();
}

class _SwitchStudentLoadingDialogWidgetState extends State<SwitchStudentLoadingDialogWidget> {
  List<Color> colors = [
    const Color(0xffBC82F3),
    const Color(0xffF5B9EA),
    const Color(0xff8D99FF),
    const Color(0xffAA6EEE),
    const Color(0xffFF6778),
    const Color(0xffFFBA71),
    const Color(0xffC686FF),
  ];

  List<String> texts = [
    "加载学习数据",
    "加载学习计划",
    "加载学习记录",
    "加载用户设置",
  ];
  int textIndex = 0;

  int? durationSeconds;

  Timer? _timer;

  double progress = 0;
  

  @override
  void initState() {
    super.initState();
    durationSeconds = Random().nextInt(1000) + 500; // 500~1500ms
    _startProgressAnimation();
  }


  void _startProgressAnimation() {
    if (durationSeconds == null) return;
    
    const updateInterval = Duration(milliseconds: 16); // 约60fps
    final totalDurationMs = durationSeconds!;
    final totalFrames = totalDurationMs ~/ updateInterval.inMilliseconds;
    final progressPerFrame = 1.0 / totalFrames;
    
    // 计算文本切换的时机
    final textSwitchInterval = totalFrames ~/ texts.length;
    int frameCount = 0;
    
    _timer = Timer.periodic(updateInterval, (timer) async{
      progress += progressPerFrame;
      frameCount++;
      
      // 根据进度更新文本索引
      int newTextIndex = (frameCount ~/ textSwitchInterval).clamp(0, texts.length - 1);
      if (newTextIndex != textIndex) {
        textIndex = newTextIndex;
      }
      
      if (progress >= 1.0) {
        progress = 1.0;
        textIndex = texts.length - 1; // 确保显示最后一个文本
        if(mounted) setState(() {});
        timer.cancel();
        
        // 进度完成后的操作
        await widget.onComplete?.call();
        Get.back();
      }
      
      if(mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: (){
          Get.back();
        },
        child: Material(
          color: AppTheme.cOverlayBackground,
          child: Center(
            child: Container(
              width: 1080.wMin,
              height: 466.wMin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cBgSecondary,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildUserInfoWidget(widget.currentAvatarUrl, widget.currentName),
                          
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            "assets/svg/public/icon_switch_arrow.svg",
                            width: 72.wMin,
                            height: 72.wMin,
                          ),
                          SizedBox(height: 24.wMin),
                          Text(
                            "正在为您切换账号...",
                            style: TextStyle(
                              color: AppTheme.cTextPrimary,
                              fontSize: 32.wMin,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 16.wMin),
                          Text(
                            texts[textIndex], // 使用动态文本
                            style: TextStyle(
                              color: AppTheme.cTextPrimary,
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                          
                          
                      _buildUserInfoWidget(widget.targetAvatarUrl, widget.targetName),
                    ],
                  ),

                  Positioned(
                    top: 0,
                    child: Container(
                      height: 6.wMin,
                      width: 950.wMin,
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 50),
                        height: 6.wMin,
                        width: 950.wMin * progress,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: colors,
                          ),
                          borderRadius: BorderRadius.circular(3.wMin),
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

  Widget _buildUserInfoWidget(String? avatarUrl, String? name){
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: SizedBox(
              width: 145.wMin,
              height: 145.wMin,
              child: CachedImageWidget(
                avatarUrl??"",
                fit: BoxFit.cover,
                errorWidget: Center(
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_user.svg",
                    width: 145.wMin,
                    height: 145.wMin,
                  ),
                ),
                placeholder: Center(
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_user.svg",
                    width: 145.wMin,
                    height: 145.wMin,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 26.wMin),
          Text(
            name??"",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.cTextPrimary,
              fontSize: 32.wMin,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }

}