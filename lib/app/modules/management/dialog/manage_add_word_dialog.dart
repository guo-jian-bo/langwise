import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/language_console.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../common/commons.dart';

/// 添加单词
class ManageAddWordDialog{

  static Future<bool> show({
    required BuildContext context,
  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return const ManageAddWordDialogWidget();
      },
    );

    return res??false;
  }

}


class ManageAddWordDialogWidget extends StatefulWidget {
  const ManageAddWordDialogWidget({super.key});

  @override
  State<ManageAddWordDialogWidget> createState() => _ManageAddWordDialogWidgetState();
}

class _ManageAddWordDialogWidgetState extends State<ManageAddWordDialogWidget> {

  List<PosResponseEntity> _posList = [];

  /// 单词
  final TextEditingController _wordController = TextEditingController();
  /// 释义
  final TextEditingController _descriptionController = TextEditingController();
  /// 选择的词性
  String? _selectedPos;
  


  @override
  void initState() {
    super.initState();
    _getPosList();
  }

  /// 获取词性列表
  Future<void> _getPosList() async {
    try {
      List<PosResponseEntity>? list = await LanguageConsoleRequest.getPosList();
      if(list == null) return;
      _posList = list;
      if(mounted) setState(() {});

    } finally{
    }
  }


  /// 创建单词
  Future<void> createConfirm() async{
    String word = _wordController.text.trim();
    if(word.isEmpty){
      ToastUtils.showToast(text: "请填写单词");
      return;
    }

    String description = _descriptionController.text.trim();
    if(description.isEmpty){
      ToastUtils.showToast(text: "请填写释义");
      return;
    }
    String pos = _selectedPos??"";
    if(pos.isEmpty){
      ToastUtils.showToast(text: "请选择词性");
      return;
    }

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "content": word,
        "contentType": KnowledgeType.EN_WORD.value,
        "definition": description,
        "bookType": BookType.TEXTBOOK.value,
        "pos": pos,
      };

      String? wordRes = await LanguageConsoleRequest.wordMath(data: reqData);
      if(wordRes == null) return;
      ToastUtils.showToast(text: wordRes, type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }

    
  }



  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "创建单词",
      width: 800.wMin,
      onCancel: () => Get.back(),
      onConfirm: () => createConfirm(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        constraints: BoxConstraints(
          minHeight: 400.wMin,
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

        _buildTitleWidget("单词"),
        SizedBox(height: 4.wMin),
        CardInputWidget(
          controller: _wordController,
          height: 64.wMin,
          hintText: "请填写单词",
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
            _wordController.clear();
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

        SizedBox(height: 20.wMin),

        _buildTitleWidget("词性"),
        SizedBox(height: 4.wMin),
        IconDropdownSelectWidget(
          menuHeight: 350.wMin,
          selectValue: _selectedPos,
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
          items: List.generate(_posList.length, (index){
            return IconDropdownCheckData(
              title: _posList[index].title??"",
              value: _posList[index].pos,
            );
          }),
          hintText: "请选择词性",
          onChanged: (data, index) {
            _selectedPos = data.value;
            if(mounted) setState(() {});
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