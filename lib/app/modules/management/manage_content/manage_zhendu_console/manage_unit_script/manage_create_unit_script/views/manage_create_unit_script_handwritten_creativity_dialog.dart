import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/manage_content/manage_zhendu_console/common/manage_zhendu_widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../common/commons.dart';

class ManageCreateUnitScriptHandwrittenCreativityResult{
  int sceneCount;
  String? story;

  ManageCreateUnitScriptHandwrittenCreativityResult({
    required this.sceneCount,
    this.story,
  });
}

class ManageCreateUnitScriptHandwrittenCreativityDialog{

  /// 显示创建剧本手写创意弹窗
  /// [genre] 剧本题材
  /// [sceneCount] 场景数量
  /// 故事创意
  static Future<ManageCreateUnitScriptHandwrittenCreativityResult?> show({
    required BuildContext context,
    required ManageScriptGenreEntity genre,
    int? sceneCount,
    String? story,
  }) async{

    return await showCupertinoDialog<ManageCreateUnitScriptHandwrittenCreativityResult?>(
      context: context, 
      builder: (context) {
        return ManageCreateUnitScriptHandwrittenCreativityDialogWidget(
          genre: genre,
          sceneCount: sceneCount,
          story: story,
        );
      },
    );

  }

}

class ManageCreateUnitScriptHandwrittenCreativityDialogWidget extends StatefulWidget {
  final ManageScriptGenreEntity genre;
  final int? sceneCount;
  final String? story;

  const ManageCreateUnitScriptHandwrittenCreativityDialogWidget({super.key, required this.genre, this.sceneCount, this.story});

  @override
  State<ManageCreateUnitScriptHandwrittenCreativityDialogWidget> createState() => _ManageCreateUnitScriptHandwrittenCreativityDialogWidgetState();
}

class _ManageCreateUnitScriptHandwrittenCreativityDialogWidgetState extends State<ManageCreateUnitScriptHandwrittenCreativityDialogWidget> {

  /// 场景数量输入框
  final TextEditingController sceneCountController = TextEditingController(text: "3");

  /// 故事创意输入框
  final TextEditingController storyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    sceneCountController.text = widget.sceneCount?.toString() ?? "3";
    storyController.text = widget.story ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "编辑手写创意",
      width: 1200.wMin,
      onCancel: () => Get.back(),
      confirmText: "确认加入",
      confirmColor: AppTheme.cSurfaceWarning.color,
      onConfirm: () {
        int? sceneCount = int.tryParse(sceneCountController.text);
        if(sceneCount == null) return;
        String? story = storyController.text;
        Get.back(result: ManageCreateUnitScriptHandwrittenCreativityResult(
          sceneCount: sceneCount,
          story: story,
        ));

      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SelectableText(
              widget.genre.name?.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            SelectableText(
              widget.genre.nid??"",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),

            SizedBox(height: 16.wMin),

            ManageZhenduNumberInputWidget(
              title: "场景数量",
              controller: sceneCountController,
              isInt: true,
              minValue: 1,
            ),

            SizedBox(height: 16.wMin),

            ManageZhenduInputHeightWidget(
              title: "故事创意",
              hintText: "写清故事方向、冲突、角色行动和语言学习目标。留空则只按题材自由生成。",
              controller: storyController,
              maxLines: 20,
              height: 300.wMin,
            ),

            SizedBox(height: 16.wMin),

          ],
        ),
      ),
    );
  }
}