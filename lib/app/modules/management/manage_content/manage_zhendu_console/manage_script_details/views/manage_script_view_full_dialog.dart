
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../common/commons.dart';

/// 剧本详情 查看全文
class ManageScriptViewFullDialog{

  static Future<void> show({
    required BuildContext context,
    required ManageScriptDetilEntity data,
  }) async{

    return await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ManageScriptViewFullDialogWidget(data: data);
      },
    );
  }

}

class ManageScriptViewFullDialogWidget extends StatefulWidget {
  final ManageScriptDetilEntity data;
  const ManageScriptViewFullDialogWidget({super.key, required this.data});

  @override
  State<ManageScriptViewFullDialogWidget> createState() => _ManageScriptViewFullDialogWidgetState();
}

class _ManageScriptViewFullDialogWidgetState extends State<ManageScriptViewFullDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "剧本全文",
      width: 1000.wMin,
      cancelText: "关闭",
      onCancel: () => Get.back(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
        alignment: Alignment.topLeft,
        width: double.infinity,
        height: 800.wMin,
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: SelectableText(
              widget.data.text ?? "",
              scrollPhysics: const NeverScrollableScrollPhysics(),
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}