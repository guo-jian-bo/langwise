
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../utils/utils.dart';
import '../common/commons.dart';

class PromptInputDialog{

  static Future<String?> show({
    required BuildContext context,
    required String? prompt,
  }) async{
    return await showCupertinoDialog<String?>(
      context: context,
      builder: (context) {
        return PromptInputDialogWidget(prompt: prompt);
      },
    );
  }

}

class PromptInputDialogWidget extends StatefulWidget {
  final String? prompt;
  const PromptInputDialogWidget({super.key, required this.prompt});

  @override
  State<PromptInputDialogWidget> createState() => _PromptInputDialogWidgetState();
}

class _PromptInputDialogWidgetState extends State<PromptInputDialogWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.prompt??"";
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.wMin),
      borderSide: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
    );

    return ManageDialogBoxWidget(
      title: "修改提示词",
      width: 1200.wMin,
      onCancel: () => Get.back(),
      onConfirm: () {
        if(_controller.text.isEmpty){
          ToastUtils.showToast(text: "请输入提示词");
          return;
        }
        Get.back(result: _controller.text);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
        constraints: BoxConstraints(
          minHeight: 400.wMin,
          maxHeight: 800.wMin,
        ),
        child: TextField(
          controller: _controller,
          maxLines: 15,
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
              counterText: "",
              fillColor: AppTheme.cSurfaceTertiary.color,
              filled: true,
              border: border,
              focusedBorder: border,
              enabledBorder: border,
              disabledBorder: border,
              contentPadding: EdgeInsets.all(16.wMin),
          ),
        ),
      ),
    );
  }
}