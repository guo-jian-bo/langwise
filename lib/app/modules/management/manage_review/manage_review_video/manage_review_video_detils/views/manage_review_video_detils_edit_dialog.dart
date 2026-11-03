
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';


class ManageReviewVideoDetilsEditDialog{

  static Future<bool> show({
    required BuildContext context,
    required int promptId,
    required List<String> lines,
    required String prompt,
  }) async {
    bool? res = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return ManageReviewVideoDetilsEditDialogWidget(
          promptId: promptId,
          lines: lines,
          prompt: prompt,
        );
      },
    );
    return res ?? false;
  }

}

class ManageReviewVideoDetilsEditDialogWidget extends StatefulWidget {
  /// 提示词ID
  final int promptId;
  final List<String> lines;
  final String prompt;
  const ManageReviewVideoDetilsEditDialogWidget({super.key, required this.promptId, required this.lines, required this.prompt});

  @override
  State<ManageReviewVideoDetilsEditDialogWidget> createState() => _ManageReviewVideoDetilsEditDialogWidgetState();
}

class _ManageReviewVideoDetilsEditDialogWidgetState extends State<ManageReviewVideoDetilsEditDialogWidget> {
  /// 提示词
  final TextEditingController promptController = TextEditingController();

  /// 台词输入框
  List<TextEditingController> linesInputs = <TextEditingController>[];

  @override
  void initState(){
    super.initState();
    promptController.text = widget.prompt;
    linesInputs = widget.lines.map((e) => TextEditingController(text: e)).toList();
  }

  /// 确认新建视频
  Future<void> confirm() async{
    if(promptController.text.isEmpty){
      return ToastUtils.showToast(text: "请输入提示词");
    }

    try {
      ToastUtils.showLoading();

      List<String> lines = [];
      for (var element in linesInputs) {
        if(element.text.trim().isEmpty) continue;
        lines.add(element.text);
      }

      Map<String, dynamic> reqData = {
        "promptId": widget.promptId,
        "prompt": promptController.text,
        "lines": lines,
      };
      String? res = await LanguageConsoleRequest.createVideoByPrompt(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }

  }


  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "用提示词新建视频",
      onCancel: () => Get.back(),
      confirmText: "确认新建视频",
      onConfirm: () {
        confirm();
      },
      child: SizedBox(
        height: 800.wMin,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          child: Column(
            children: [
              _buildPromptWidget(),
              SizedBox(height: 16.wMin),
              _buildLinesWidget(),
              SizedBox(height: 16.wMin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptWidget(){
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.wMin),
      borderSide: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "提示词",
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.wMin),
        SizedBox(
          height: 400.wMin,
          child: TextField(
            controller: promptController,
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
              hintText: "请输入提示词",
              hintStyle: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w500,
              )
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinesWidget(){
    return Container(
      margin: EdgeInsets.only(top: 10.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "台词",
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.wMin),
          Column(
            children: [
              Column(
                spacing: 6.wMin,
                children: List.generate(linesInputs.length, (index){
              
                  return Row(
                    children: [
                      Expanded(
                        child: CardInputWidget(
                          hintText: "请输入台词",
                          controller: linesInputs[index],
                          height: 46.wMin,
                          borderRadius: BorderRadius.circular(8.wMin),
                          borderColor: Colors.transparent,
                          valueStyle: TextStyle(
                            fontSize: 18.wMin,
                            color: AppTheme.cTextBrand.color,
                            fontWeight: FontWeight.w500,
                          ),
                          hintStyle: TextStyle(
                            fontSize: 18.wMin,
                            color: AppTheme.cTextTertiary.color,
                            fontWeight: FontWeight.w500,
                          ),
                          onClean: () {
                            linesInputs[index].clear();
                          },
                        ),
                      ),
          
                      TapScaleWidget(
                        onTap: () {
                          linesInputs.removeAt(index);
                          if(mounted) setState(() {});
                        },
                        sclae: 1.03,
                        child: Container(
                          width: 46.wMin,
                          height: 46.wMin,
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          child: SvgPicture.asset(
                            "assets/svg/public/icon_delete.svg",
                            width: 28.wMin,
                          ),
                        ),
                      ),
          
                    ],
                  );
              
                }),
              ),
              Container(
                margin: EdgeInsets.only(top: 6.wMin, right: 46.wMin),
                child: ButtonWidget(
                  text: "添加台词",
                  height: 46.wMin,
                  color: AppTheme.cSurfaceTertiary.color,
                  borderRadius: 8.wMin,
                  fontColor: AppTheme.cSurfaceInfo.color,
                  fontSize: 18.wMin,
                  sclae: 1,
                  onTap: () {
                    linesInputs.add(TextEditingController());
                    if(mounted) setState(() {});
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  


}