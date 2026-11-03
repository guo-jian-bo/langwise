import 'package:flutter/cupertino.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';

/// 视觉风格规则弹窗
class VisuaStyleRulesDialog{

  static Future<void> show({
    required BuildContext context,
    required String explain,
  }) async{

    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return VisuaStyleRulesDialogWidget(explain: explain);
      },
    );

  }

}


class VisuaStyleRulesDialogWidget extends StatefulWidget {
  final String explain;
  const VisuaStyleRulesDialogWidget({super.key, required this.explain});

  @override
  State<VisuaStyleRulesDialogWidget> createState() => _VisuaStyleRulesDialogWidgetState();
}

class _VisuaStyleRulesDialogWidgetState extends State<VisuaStyleRulesDialogWidget> {


  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "功能指南",
      width: 900.wMin,
      child: SizedBox(
        height: 900.wMin,
        child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.wMin),
          child: AppMarkdownWidget(data: widget.explain),
        ),
      ),
    );
  }

  
}