
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/https/https.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../common/commons.dart';

class ManageAddSentenceDialog{
  static Future<bool> show({
    required BuildContext context,
  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return const ManageAddSentenceDialogWidget();
      },
    );

    return res??false;
  }
}

class ManageAddSentenceDialogWidget extends StatefulWidget {
  const ManageAddSentenceDialogWidget({super.key});

  @override
  State<ManageAddSentenceDialogWidget> createState() => _ManageAddSentenceDialogWidgetState();
}

class _ManageAddSentenceDialogWidgetState extends State<ManageAddSentenceDialogWidget> {
  /// 
  final TextEditingController _contentController = TextEditingController();
  /// 释义
  final TextEditingController _descriptionController = TextEditingController();


  Future<void> createConfirm() async{
    String content = _contentController.text.trim();
    if(content.isEmpty){
      ToastUtils.showToast(text: "请填写短语");
      return;
    }

    String description = _descriptionController.text.trim();
    if(description.isEmpty){
      ToastUtils.showToast(text: "请填写释义");
      return;
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "content": content,
        "contentType": KnowledgeType.EN_PHRASE.value,
        "definition": description,
        "bookType": BookType.TEXTBOOK.value,
      };

      String? res = await LanguageConsoleRequest.sentenceMath(data: reqData);
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
      title: "创建句子",
      width: 800.wMin,
      onCancel: () => Get.back(),
      onConfirm: () => createConfirm(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        constraints: BoxConstraints(
          minHeight: 300.wMin,
          maxHeight: 800.wMin,
        ),
        child: _buildInputsWidget(),
      ),
    );
  }

  Widget _buildInputsWidget(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(height: 10.wMin),

        _buildTitleWidget("句子"),
        SizedBox(height: 4.wMin),
        CardInputWidget(
          controller: _contentController,
          height: 64.wMin,
          hintText: "请填写句子(以空格分割)",
          valueStyle: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w500,
          ),
          onClean: () {
            _contentController.clear();
          },
        ),

        SizedBox(height: 20.wMin),

        _buildTitleWidget("释义"),
        SizedBox(height: 4.wMin),
        CardInputWidget(
          controller: _descriptionController,
          height: 64.wMin,
          hintText: "请填写释义",
          valueStyle: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w500,
          ),
          onClean: () {
            _descriptionController.clear();
          },
        ),

      ],
    );
  }


  Widget _buildTitleWidget(String title){
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '*',
            style: TextStyle(
              color: Colors.red,
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: title,
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

}