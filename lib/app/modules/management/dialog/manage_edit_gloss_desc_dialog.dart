
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/static/static_data.dart';
import '../../../../common/widgets/widgets.dart';
import '../common/commons.dart';

/// 编辑语义 (gloss,Descriptions) 
class ManageEditGlossDescDialog{

  static Future<bool> showEdit({
    required BuildContext context,
    List<LanguageText?>? gloss,
    List<LanguageText?>? descriptions,
    EducationalLevelEnum? eduTier,
    bool showEduTier = true,
    required int semanticId,
  }) async{
    bool? result = await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ManageEditGlossDescDialogWidget(
          semanticId: semanticId,
          eduTier: eduTier,
          showEduTier: showEduTier,
          gloss: gloss,
          descriptions: descriptions,
        );
      },
    );

    return result ?? false;
  }

}

class ManageEditGlossDescDialogWidget extends StatefulWidget {
  final int semanticId;
  final EducationalLevelEnum? eduTier;
  final bool showEduTier;
  final List<LanguageText?>? gloss;
  final List<LanguageText?>? descriptions;
  const ManageEditGlossDescDialogWidget({
    super.key, 
    this.eduTier,
    this.showEduTier = true,
    required this.semanticId,
    this.gloss,
    this.descriptions,
  });

  @override
  State<ManageEditGlossDescDialogWidget> createState() => _ManageEditGlossDescDialogWidgetState();
}

class _ManageEditGlossDescDialogWidgetState extends State<ManageEditGlossDescDialogWidget> {

  List<_ManageEditGlossDescModel> glossList = [];
  String? glossSelectLanguage;

  List<_ManageEditGlossDescModel> descriptionList = [];
  String? descriptionSelectLanguage;

  EducationalLevelEnum? selectLevelEnum;

  @override
  void initState() {
    super.initState();

    selectLevelEnum = widget.eduTier;

    for(int i = 0; i < (widget.gloss?.length??0); i++){
      glossList.add(_ManageEditGlossDescModel(
        lang: widget.gloss?[i]?.lang, 
        text: widget.gloss?[i]?.text, 
        controller: TextEditingController(text: widget.gloss?[i]?.text),
      ));
    }

    for(int i = 0; i < (widget.descriptions?.length??0); i++){
      descriptionList.add(_ManageEditGlossDescModel(
        lang: widget.descriptions?[i]?.lang, 
        text: widget.descriptions?[i]?.text, 
        controller: TextEditingController(text: widget.descriptions?[i]?.text),
      ));
    }

  }

  Future<void> _save() async{
    if(glossList.isEmpty || descriptionList.isEmpty){
     return ToastUtils.showManageToast(text: "请至少添加一个释义");
    }

    List<Map<String, dynamic>> gloss = [];
    List<Map<String, dynamic>> descriptions = [];

    for(int i = 0; i < glossList.length; i++){
      gloss.add({
        "lang": glossList[i].lang,
        "text": glossList[i].controller.text,
      });
    }
    
    for(int i = 0; i < descriptionList.length; i++){
      descriptions.add({
        "lang": descriptionList[i].lang,
        "text": descriptionList[i].controller.text,
      });
    }
    
    Map<String, dynamic> reqData = {
      "eduTier": selectLevelEnum?.value,
      "gloss": gloss,
      "descriptions": descriptions,
    };

    if(widget.showEduTier){
      if(selectLevelEnum == null) return ToastUtils.showToast(text: "请选择教育等级");
      reqData['eduTier'] = selectLevelEnum?.value;
    }

    try {
      ToastUtils.showLoading();
      bool res = await KnowledgeUtil.editSemantics(widget.semanticId, reqData);
      if(!res) return;
      ToastUtils.showManageToast(text: "编辑成功");
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }

    
  }


  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "编辑语义释义",
      width: 1000.wMin,
      onCancel: () => Get.back(),
      onConfirm: () => _save(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIdWidget(),
            SizedBox(height: 10.wMin),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderPrimary.color,
            ),
            Row(
              spacing: 24.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildBodyItemWidget(
                    title: "简明释义 (Gloss)",
                    list: glossList,
                    selectLanguage: glossSelectLanguage,
                    onChanged: (value, index) {
                      glossSelectLanguage = value;
                      if(mounted) setState(() {});
                    },
                    onAdd: (value) {
                      glossList.add(_ManageEditGlossDescModel(
                        lang: value, 
                        controller: TextEditingController(),
                      ));
                      glossSelectLanguage = null;
                      if(mounted) setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: _buildBodyItemWidget(
                    title: "详细释义 (Descriptions)",
                    list: descriptionList,
                    selectLanguage: descriptionSelectLanguage,
                    onChanged: (value, index) {
                      descriptionSelectLanguage = value;
                      if(mounted) setState(() {});
                    },
                    onAdd: (value) {
                      descriptionList.add(_ManageEditGlossDescModel(
                        lang: value, 
                        controller: TextEditingController(),
                      ));
                      descriptionSelectLanguage = null;
                      if(mounted) setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 语义id
  Widget _buildIdWidget(){
    return Container(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          SelectableText(
            "语义ID：${widget.semanticId}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),

          Visibility(
            visible: widget.showEduTier,
            child: Text(
              "教育等级：",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          Visibility(
            visible: widget.showEduTier,
            child: IconDropdownSelectWidget(
              width: 250.wMin,
              height: 44.wMin,
              borderRadius: BorderRadius.circular(8.wMin),
              selectValue: selectLevelEnum,
              valueStyle: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
              items: List.generate(EducationalLevelEnum.values.length, (index){
                return IconDropdownCheckData<EducationalLevelEnum>(
                  title: EducationalLevelEnum.values[index].name,
                  value: EducationalLevelEnum.values[index],
                );
              }),
              onChanged: (data, index) {
                selectLevelEnum = data.value;
                if(mounted) setState(() {});
              },
            ),
          ),

        ],
      ),
    );
  }

  /// 释义输入框
  Widget _buildBodyItemWidget({
    required String title,
    required List<_ManageEditGlossDescModel> list,
    required String? selectLanguage,
    void Function(String value, int index)? onChanged,
    void Function(String value)? onAdd,
  }){

    List<StaticDataEntity> languageList = StaticData.languageList.toList();
    languageList.removeWhere((element) => list.any((e) => e.lang == element.value));


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.wMin),
        SelectableText(
          "$title (${list.length})",
          style: TextStyle(
            color: AppTheme.cTextPrimary.color,
            fontSize: 16.wMin,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.wMin),
        Container(
          height: 0.5.wMin,
          color: AppTheme.cBorderPrimary.color,
        ),

        Container(
          constraints: BoxConstraints(
            maxHeight: 700.wMin,
            minHeight: 300.wMin,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 10.wMin),
            child: Column(
              spacing: 10.wMin,
              children: [
                ...List.generate(list.length, (index) {
                  return _buildItemWidget(list[index], list, index);
                }),

                Container(
                  height: 0.5.wMin,
                  color: AppTheme.cBorderPrimary.color,
                ),

                SizedBox(height: 10.wMin),

                Row(
                  spacing: 10.wMin,
                  children: [
                    Expanded(
                      child: IconDropdownSelectWidget(
                        height: 56.wMin,
                        hintText: languageList.isEmpty ? "无可添加语言" : "请选择语言",
                        selectValue: selectLanguage,
                        menuHeight: 300.wMin,
                        hintStyle: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cTextTertiary.color,
                          fontWeight: FontWeight.w400,
                        ),
                        valueStyle: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w400,
                        ),
                        items: List.generate(languageList.length, (index){
                          return IconDropdownCheckData(
                            title: languageList[index].name,
                            value: languageList[index].value,
                          );
                        }),
                        onChanged: (data, index) {
                          onChanged?.call(data.value, index);
                        },
                      ),
                    ),
                    ButtonWidget(
                      text: "添加",
                      width: 80.wMin,
                      height: 50.wMin,
                      sclae: 1.03,
                      borderRadius: 8.wMin,
                      color: const Color(0xff2388FF).withValues(alpha: selectLanguage == null ? 0.3 : 1),
                      fontColor: AppTheme.cInverseTextLight.color,
                      fontSize: 20.wMin,
                      onTap: selectLanguage == null ? null : () {
                        onAdd?.call(selectLanguage);
                      },
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
        SizedBox(height: 10.wMin),

      ],
    );
  }


  Widget _buildItemWidget(_ManageEditGlossDescModel model, List<_ManageEditGlossDescModel> list, int index){
    return Container(
      padding: EdgeInsets.all(10.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceSecondary.color,
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(color: AppTheme.cBorderSecondary.color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SelectableText(
                model.lang??"",
                style: TextStyle(
                  color: AppTheme.cTextPrimary.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TapScaleWidget(
                sclae: 1.03,
                onTap: (){
                  list.removeAt(index);
                  if(mounted) setState(() {});
                },
                child: SvgPicture.asset(
                  "assets/svg/public/icon_delete.svg",
                  width: 24.wMin,
                  height: 24.wMin,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.wMin),
          DraggableTextField(
            controller: model.controller,
            height: 80.wMin,
          ),
          SizedBox(height: 4.wMin),
          SelectableText(
            "字符数：${model.controller.text.length}",
            style: TextStyle(
              color: AppTheme.cTextTertiary.color,
              fontSize: 14.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
          
        ],
      ),
    );
  }



}

class _ManageEditGlossDescModel{
  String? lang;
  String? text;
  TextEditingController controller;

  _ManageEditGlossDescModel({
    this.lang,
    this.text,
    required this.controller,
  });
}