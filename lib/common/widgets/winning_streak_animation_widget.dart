import 'dart:math';

import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'widgets.dart';


class WinningStreakAnimationWidget extends StatefulWidget {
  final int groupNumber;
  final void Function()? onContinue;

  final void Function()? onRest;
  /// 答题连胜动画
  const WinningStreakAnimationWidget({super.key, this.groupNumber = 0, this.onContinue, this.onRest});

  @override
  State<WinningStreakAnimationWidget> createState() => _WinningStreakAnimationWidgetState();
}

class _WinningStreakAnimationWidgetState extends State<WinningStreakAnimationWidget> with SingleTickerProviderStateMixin {
  final List<String> images = [
    "assets/images/practice_questions/applaud.png",
    "assets/images/practice_questions/rocket.png",
    "assets/images/practice_questions/emoji_head1.png",
    "assets/images/practice_questions/emoji_head2.png",
  ];

  final List<String> encourages = [
    "太棒啦！继续加油！✨",
    "冲鸭！🐥 势不可挡！",
    "状态拉满！稳稳冲！💪",
    "答题火力全开中🔥",
    "答题小勇士，太给力啦！🏅",
  ];

  String currentImage = "";
  String currentEncourage = "";
  
  /// 动画控制器
  late AnimationController _animationController;
  
  /// 位置动画
  late Animation<Offset> _slideAnimation;
  
  /// 当前动画状态
  AnimationStatus _currentStatus = AnimationStatus.dismissed;
  
  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // 初始化位置动画，默认从左侧屏幕外到中间
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0), // 左侧屏幕外
      end: Offset.zero, // 中间位置
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // 监听动画状态变化
    _animationController.addStatusListener((status) {
      _currentStatus = status;
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      startAnimation();
      await Future.delayed(const Duration(seconds: 2));
      // endAnimation();
    });
  }

  void getImage(){
    int random = Random().nextInt(images.length);
    currentImage = images[random];
    if(mounted) setState(() {});
  }

  void getEncourage(){
    int random = Random().nextInt(encourages.length);
    currentEncourage = encourages[random];
    if(mounted) setState(() {});
  }
  
  /// 开始动画：从左侧滑入到中间
  void startAnimation() {
    getImage();
    getEncourage();
    // 重置动画为从左到中
    if (_currentStatus == AnimationStatus.completed) {
      _slideAnimation = Tween<Offset>(
        begin: const Offset(-1.5, 0), // 左侧屏幕外
        end: Offset.zero, // 中间位置
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      if(mounted) setState(() {});
    }
    _animationController.forward(from: 0.0);
  }
  
  /// 结束动画：从中间滑出到右侧
  void endAnimation() {
    // 设置动画为从中到右
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero, // 中间位置
      end: const Offset(1.5, 0), // 右侧屏幕外
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInCubic,
    ));
    if(mounted) setState(() {});
    _animationController.forward(from: 0.0);
  }

  void disposeAnimation(){
    _animationController.dispose();
  }
  
  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: SizedBox(
            height: 350.wMin,
            width: 1393.wMin,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      height: 4.wMin,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xffFF5200).withValues(alpha: 0),
                            const Color(0xffFF5200),
                            const Color(0xffFF5200).withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 346.wMin,
                      width: 1393.wMin,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xffFF5200).withValues(alpha: 0),
                            const Color(0xffFF5200).withValues(alpha: 0.09),
                            const Color(0xffFF5200).withValues(alpha: 0),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 120.wMin),
                          Text(
                            currentEncourage,
                            style: TextStyle(
                              fontSize: 80.wMin,
                              color: AppTheme.cTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 16.wMin),
                          Text(
                            "第 ${widget.groupNumber} 组完成!",
                            style: TextStyle(
                              fontSize: 34.wMin,
                              color: const Color(0xffFF5200),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: -120.wMin,
                  child: Image.asset(
                    // currentImage,
                    images[3],
                    height: 240.wMin,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildButtonsWidget(),
    );
  }


  Widget _buildButtonsWidget(){
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 100.wMin,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10.wMin,
        children: [
          ButtonWidget(
            text: "休息一下",
            width: 400.wMin,
            height: 64.wMin,
            color: AppTheme.cFeedbackDefaultBackground.color,
            borderRadius: 12.wMin,
            fontSize: 28.wMin,
            fontColor: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
            sclae: 1.01,
            onTap: () {
              widget.onRest?.call();
            },
          ),
          ButtonWidget(
            text: "继续学习",
            width: 400.wMin,
            height: 64.wMin,
            color: AppTheme.cBgBrand.color,
            borderRadius: 12.wMin,
            fontSize: 28.wMin,
            fontColor: AppTheme.cStaticWhite.color,
            fontWeight: FontWeight.w500,
            sclae: 1.01,
            onTap: () {
              widget.onContinue?.call();
            },
          ),
        ],
      ),
    );
  }


}