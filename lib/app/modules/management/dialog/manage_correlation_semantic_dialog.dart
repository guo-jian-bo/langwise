
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/https/https.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../common/commons.dart';

/// 单词短语关联语义
class ManageCorrelationSemanticDialog{

  static Future<bool> show({
    required BuildContext context,
    required int contentId,
    required String contentType,

  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return ManageCorrelationSemanticDialogWidget(
          contentId: contentId,
          contentType: contentType,
        );
      },
    );

    return res??false;
  }

}

class ManageCorrelationSemanticDialogWidget extends StatefulWidget {
  final int contentId;
  final String contentType;
  const ManageCorrelationSemanticDialogWidget({
    super.key, 
    required this.contentId, 
    required this.contentType
  });

  @override
  State<ManageCorrelationSemanticDialogWidget> createState() => _ManageCorrelationSemanticDialogWidgetState();
}

class _ManageCorrelationSemanticDialogWidgetState extends State<ManageCorrelationSemanticDialogWidget> {
  final TextEditingController _oldContentIdController = TextEditingController();
  final TextEditingController _semanticController = TextEditingController();

  /// 提交
  Future<void> submit() async{

    if(_oldContentIdController.text.trim().isEmpty){
      ToastUtils.showToast(text: "请填写原contentId");
      return;
    }

    if(_semanticController.text.trim().isEmpty){
      ToastUtils.showToast(text: "请填写semanticId");
      return;
    }

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "oldContentId": _oldContentIdController.text.trim(),
        "semanticId": _semanticController.text.trim(),
        "contentType": widget.contentType,
      };

      ElementsCardType type = ElementsCardType.fromRawValue(widget.contentType);
      bool result = false;
      if(type == ElementsCardType.word){
        result = await LanguageConsoleRequest.wordSemanticBind(widget.contentId, data: reqData);
      }else if(type == ElementsCardType.phrase){
        result = await LanguageConsoleRequest.phraseSemanticBind(widget.contentId, data: reqData);
      }
      if(!result) return;
      
      ToastUtils.showToast(text: "关联成功", type: ToastType.success);
      Get.back(result: true);

    } finally{
      ToastUtils.hideLoading();
    }
      

  }
  
  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "关联语义",
      width: 600.wMin,
      onCancel: () => Get.back(),
      onConfirm: () => submit(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
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

        _buildTitleWidget("原contentId"),
        SizedBox(height: 4.wMin),
        CardInputWidget(
          controller: _oldContentIdController,
          height: 64.wMin,
          hintText: "请填写原contentId",
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
            _oldContentIdController.clear();
          },
        ),

        SizedBox(height: 24.wMin),

        _buildTitleWidget("semanticId"),
        SizedBox(height: 4.wMin),
        CardInputWidget(
          controller: _semanticController,
          height: 64.wMin,
          hintText: "请填写semanticId",
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
            _semanticController.clear();
          },
        ),

        SizedBox(height: 24.wMin),

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
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: title,
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  
}