import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:langwise/app/modules/elements/common/elements_ai_animation_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class AILoadingDialog{
  static Future<void> show({
    required BuildContext context,
    void Function(bool result)? onComplete,
    Future<bool> Function()? onRequest,
    required String title,
    required List<AiAnimationModel> animationList,
  }) async{
     await showCupertinoDialog(
      context: context, 
      useRootNavigator: false,
      builder: (context) {
        return AILoadingDialogWidget(onComplete: onComplete, onRequest: onRequest, title: title, animationList: animationList);
      }
    );
  }
}

class AILoadingDialogWidget extends StatefulWidget {
  final void Function(bool result)? onComplete;
  final Future<bool> Function()? onRequest;
  final String title;
  final List<AiAnimationModel> animationList;
  const AILoadingDialogWidget({super.key, this.onComplete, this.onRequest, required this.title, required this.animationList});

  @override
  State<AILoadingDialogWidget> createState() => _AILoadingDialogWidgetState();
}

class _AILoadingDialogWidgetState extends State<AILoadingDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color.withValues(alpha: 0.9),
      child: Center(
        child: Container(
          width: 1000.wMin,
          height: 922.wMin,
          alignment: Alignment.center,
          child: ElementsAiAnimationWidget(
            introduce: widget.title,
            onRequest: widget.onRequest,
            onComplete: widget.onComplete,
            animationList: widget.animationList,
            // animationList: [
            //   AiAnimationModel(
            //     name: "全面扫描您的知识图谱",
            //     svgBackColor: const Color(0xffC084FC),
            //     iconSvg: "assets/svg/elements/icon_battle.svg",
            //     subName: "扫描知识网络",
            //   ),
            //   AiAnimationModel(
            //     name: "分析您的学习边界和潜力领域",
            //     svgBackColor: const Color(0xff38BDF8),
            //     iconSvg: "assets/svg/elements/icon_scan.svg",
            //     subName: "评估学习曲线",
            //   ),
            //   AiAnimationModel(
            //     name: "搜索知识网络中的关联知识点",
            //     svgBackColor: const Color(0xffFB923C),
            //     iconSvg: "assets/svg/elements/icon_search.svg",
            //     subName: "扫描知识网络",
            //   ),
            //   AiAnimationModel(
            //     name: "发现适合您学习的新知识点",
            //     svgBackColor: const Color(0xff2DD4BF),
            //     iconSvg: "assets/svg/elements/icon_push_pin.svg",
            //     subName: "构建知识关联图",
            //   ),
            //   AiAnimationModel(
            //     name: "集卡分析完成！",
            //     svgBackColor: AppTheme.cFeedbackSuccessIcon,
            //     iconSvg: "assets/svg/elements/icon_check_circle.svg",
            //     showProgress: false,
            //   ),
            // ],
          ),
        )
      ),
    );
  }
}