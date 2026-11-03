import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../common/commons.dart';
import 'dialogs.dart';

class ManageEditWordDialog{
  static Future<EnKnowledgeEntity?> show({
    required BuildContext context,
    required EnKnowledgeEntity knowledge,
  }) async{
    return await showCupertinoDialog<EnKnowledgeEntity?>(
      context: context,
      builder: (context) {
        return ManageEditWordDialogWidget(knowledge: knowledge);
      },
    );
  }

}


class ManageEditWordIpaModel{
  EnKnowledgeEntityIpaList data;
  TextEditingController controller;
  
  ManageEditWordIpaModel({
    required this.data,
    required this.controller,
  });
}

class ManageEditWordDialogWidget extends StatefulWidget {
  final EnKnowledgeEntity knowledge;
  const ManageEditWordDialogWidget({super.key, required this.knowledge});

  @override
  State<ManageEditWordDialogWidget> createState() => _ManageEditWordDialogWidgetState();
}

class _ManageEditWordDialogWidgetState extends State<ManageEditWordDialogWidget> {
  List<PosResponseEntity> _posList = [];
  List<FormResponseEntity> _formList = [];

  /// 语义
  List<EnKnowledgeEntitySemantics> _semanticList = [];

  /// 单词id
  final TextEditingController _wordIdController = TextEditingController();
  /// 单词
  final TextEditingController _wordController = TextEditingController();
  /// 释义
  final TextEditingController _descriptionController = TextEditingController();
  /// 原型
  final TextEditingController _lemmaController = TextEditingController();
  /// 选择的词性
  String? _selectedPos;
  /// 选择的语法形式
  String? _selectedForm;

  final List<ManageEditWordIpaModel> _ipaControllers = [];
  
  @override
  void initState() {
    super.initState();

    _wordIdController.text = widget.knowledge.uid?.toString() ?? '';
    _wordController.text = widget.knowledge.content ?? '';
    _descriptionController.text = widget.knowledge.definition ?? '';
    _lemmaController.text = widget.knowledge.lemma ?? '';
    _selectedPos = widget.knowledge.pos ?? '';
    _selectedForm = widget.knowledge.form ?? '';
    
    List<EnKnowledgeEntityIpaList?> ipaList = widget.knowledge.ipaList??[];
    if(ipaList.isNotEmpty) {
      for(var item in ipaList){
        if(item == null) continue;
        _ipaControllers.add(ManageEditWordIpaModel(
          controller: TextEditingController(text: item.text),
          data: item,
        ));
      }
    }

    List<EnKnowledgeEntitySemantics?> semantics = widget.knowledge.semantics??[];
    for(var item in semantics){
      if(item == null) continue;
      _semanticList.add(item);
    }

    _getPosList();
    _getFormList();
  }


  /// 获取词性列表
  Future<void> _getPosList() async {
    try {
      List<PosResponseEntity>? list = await LanguageConsoleRequest.getPosList();
      if(list == null) return;
      _posList = list;
      if(mounted) setState(() {});

    } finally{}
  }


  /// 获取语法形式列表
  Future<void> _getFormList() async {
    try {
      List<FormResponseEntity>? list = await LanguageConsoleRequest.getFormList();
      if(list == null) return;
      _formList = list;
      if(mounted) setState(() {});

    } finally{}
  }



  /// 添加语义
  Future<void> selectSemantic() async{
    List<EnKnowledgeEntitySemantics>? res = await ManageSelectSemanticDialog.show(
      context: context,
      initSemantics: _semanticList,
      languageCode: widget.knowledge.language,
    );
    if(res == null) return;
    _semanticList = res;
    if(mounted) setState(() {});
  }



  /// 保存提交
  Future<void> save() async{
    if(_wordIdController.text.trim().isEmpty){
      return ToastUtils.showToast(text: "请填写单词ID");
    }
    if(_wordController.text.trim().isEmpty){
      return ToastUtils.showToast(text: "请填写单词");
    }
    if(_descriptionController.text.trim().isEmpty){
      return ToastUtils.showToast(text: "请填写释义");
    }
    if(_lemmaController.text.trim().isEmpty){
      return ToastUtils.showToast(text: "请填写原型");
    }
    if(_selectedPos == null){
      return ToastUtils.showToast(text: "请选择词性");
    }
    if(_selectedForm == null){
      return ToastUtils.showToast(text: "请选择语法形式");
    }

    if(_semanticList.isEmpty){
      return ToastUtils.showToast(text: "请选择语义");
    }

    if(_ipaControllers.isEmpty){
      for(var item in _ipaControllers){
        if(item.controller.text.trim().isEmpty){
          return ToastUtils.showToast(text: "请填写${item.data.nationalTitle??''}");
        }
      }
    }

    try {
      ToastUtils.showLoading();

      List<Map<String, dynamic>> ipaList = [];

      for(var item in _ipaControllers){
        ipaList.add({
          "accent": item.data.accent,
          "text": item.controller.text.trim(),
        });
      }

      List<int> semanticIds = _semanticList.map((e) => e.uid!).toList();

      Map<String, dynamic> reqData = {
        "content": _wordController.text,
        "lemma": _lemmaController.text,
        "definition": _descriptionController.text,
        "pos": _selectedPos,
        "form": _selectedForm,
        "ipa": ipaList,
        "semanticIds": semanticIds,
      };

      EnKnowledgeEntity? res = await LanguageConsoleRequest.editWord(widget.knowledge.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "编辑成功", type: ToastType.success);
      Get.back(result: res);

    } finally{
      ToastUtils.hideLoading();
    }

  }




  
  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "编辑单词",
      width: 1200.wMin,
      onCancel: () => Get.back(),
      onConfirm: () => save(),
      child: Container(
        padding: EdgeInsets.only(bottom: 10.wMin),
        constraints: BoxConstraints(
          minHeight: 400.wMin,
          maxHeight: 900.wMin,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          child: _buildInputsWidget(context),
        ),
        
      ),
    );
  }


  Widget _buildInputsWidget(BuildContext context){
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(height: 10.wMin),

        _buildTitleWidget("单词ID"),
        SizedBox(height: 4.wMin),
        CardInputWidget(
          controller: _wordIdController,
          height: 64.wMin,
          hintText: "请填写单词ID",
          readOnly: true,
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
        ),

        SizedBox(height: 20.wMin),
        
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
        
        _buildTitleWidget("原型"),
        SizedBox(height: 4.wMin),
        CardInputWidget(
          controller: _lemmaController,
          height: 64.wMin,
          hintText: "请填写原型",
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
            _lemmaController.clear();
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

        SizedBox(height: 20.wMin),

        _buildTitleWidget("语法形式"),
        SizedBox(height: 4.wMin),
        IconDropdownSelectWidget(
          menuHeight: 350.wMin,
          selectValue: _selectedForm,
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
          items: List.generate(_formList.length, (index){
            return IconDropdownCheckData(
              title: _formList[index].title??"",
              value: _formList[index].form,
            );
          }),
          hintText: "请选择语法形式",
          onChanged: (data, index) {
            _selectedForm = data.value;
            if(mounted) setState(() {});
          },
        ),

        SizedBox(height: 20.wMin),
        _buildTitleWidget("选择语义"),
        SizedBox(height: 4.wMin),
        _buildSemanticsWidget(context),
        SizedBox(height: 20.wMin),

        Row(
          spacing: 16.wMin,
          children: List.generate(_ipaControllers.length, (index){
            return Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleWidget(_ipaControllers[index].data.nationalTitle??""),
                  SizedBox(height: 4.wMin),
                  CardInputWidget(
                    controller: _ipaControllers[index].controller,
                    height: 64.wMin,
                    readOnly: true,
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
                  ),
                ],
              ),
            );
          }),
        ),
        
        SizedBox(height: 60.wMin),


      ],
    );
  }

  Widget _buildSemanticsWidget(BuildContext context){
    return Row(
      children: [
        _buildSemanticAddWidget(context),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 10.wMin),
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 10.wMin,
              children: List.generate(_semanticList.length, (index){
                return _buildSemanticitemWidget(_semanticList[index], index);
              }),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildSemanticitemWidget(EnKnowledgeEntitySemantics data, int index){

    List<LanguageText?> descriptions = data.descriptions??[];

    return Container(
      height: 150.wMin,
      width: 450.wMin,
      decoration: BoxDecoration(
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        borderRadius: BorderRadius.circular(10.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.wMin),
              child: Stack(
                children: [
                  CachedImageWidget(
                    data.imageUrl??"",
                    placeholder: buildEmptyWidget(),
                    errorWidget: buildEmptyWidget(),
                  ),
                  Positioned(
                    top: 4.wMin,
                    left: 4.wMin,
                    child: StatusTagDifficultyWidget(
                      difficulty: data.difficulty,
                      language: widget.knowledge.language,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 8.wMin),
                    child: _buildLangTextWidget(descriptions),
                  ),
                ),

                Positioned(
                  right: 4.wMin,
                  top: 4.wMin,
                  child: TapScaleWidget(
                    onTap: () {
                      _semanticList.removeAt(index);
                      if(mounted) setState(() {});
                    },
                    sclae: 1.05,
                    child: Container(
                      width: 38.wMin,
                      height: 38.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cBgActive.color.withValues(alpha: 0.6),
                      ),
                      child: SvgPicture.asset(
                        "assets/svg/public/x.svg",
                        width: 24.wMin,
                        height: 24.wMin,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildLangTextWidget(List<LanguageText?> texts){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(texts.length, (index){
        return Text(
          texts[index]?.text ?? '',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: index == 0 ? 16.wMin : 14.wMin,
            color: AppTheme.cTextPrimary.color.withValues(alpha: index == 0 ? 1 : 0.6),
            fontWeight: FontWeight.w400,
          ),
        );
      }),
    );
  }

  Widget _buildSemanticAddWidget(BuildContext context){
    return TapScaleWidget(
      onTap: () {
        selectSemantic();
      },
      sclae: 1.01,
      child: Container(
        width: 120.wMin,
        height: 150.wMin,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
          borderRadius: BorderRadius.circular(10.wMin),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/svg/public/icon_add_plus.svg",
              width: 38.wMin,
            ),
            Text(
              "添加语义",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
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