
import 'dart:async';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:flutter/material.dart';

class PracticeQuestionsStartCountdownWidget extends StatefulWidget {
  final void Function()? onCountdownEnd;
  /// 开始组做题之前的倒计时
  const PracticeQuestionsStartCountdownWidget({
    super.key, 
    this.onCountdownEnd,
  });

  @override
  State<PracticeQuestionsStartCountdownWidget> createState() => _PracticeQuestionsStartCountdownWidgetState();
}

class _PracticeQuestionsStartCountdownWidgetState extends State<PracticeQuestionsStartCountdownWidget> {

  /// 0显示空白 1=显示ready 2=显示go
  int showType = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        showType = 1;
      });
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        showType = 2;
      });
      await Future.delayed(const Duration(seconds: 1));
      widget.onCountdownEnd?.call();

    });
  }



  @override
  Widget build(BuildContext context) {
    Widget child = Container();
    if(showType == 0){
      child = Container();
    }else if(showType == 1){
      child = _buildReadyWidget();
    }else if(showType == 2){
      child = _buildGoWidget();
    }

    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff0369A1),
            Color(0xff082F49),
          ],
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          final isNewWidget = child.key == ValueKey(showType);
          Animation<double> tween = Tween(begin: 2.0, end: 1.0).animate(animation);
          
          if(isNewWidget){
            tween = Tween(begin: 2.0, end: 1.0).animate(animation);
          }else{
            tween = Tween(begin: 0.0, end: 1.0).animate(animation);
          }
          return ScaleTransition(
            scale: tween,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }

  Widget _buildReadyWidget(){
    return SvgPicture.asset(
      "assets/svg/practice_questions/icon_ready.svg",
      height: 168.wMin,
      key: const ValueKey(1),
    );
  }

  Widget _buildGoWidget(){
    return SvgPicture.asset(
      "assets/svg/practice_questions/icon_go.svg",
      height: 168.wMin,
      key: const ValueKey(2),
    );
  }


}