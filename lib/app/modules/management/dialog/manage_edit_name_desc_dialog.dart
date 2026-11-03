import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/common/widgets/widgets.dart';

import '../../../../common/entities/entities.dart';

class ManageEditNameDescDialogResult{
  final List<LanguageText?>? name;
  final List<LanguageText?>? description;

  ManageEditNameDescDialogResult({
    this.name,
    this.description,
  });
}

/// 编辑名称说明
class ManageEditNameDescDialog{

  static Future<ManageEditNameDescDialogResult?> show({
    required BuildContext context,
    List<LanguageText?>? name,
    List<LanguageText?>? description,
  }) async{
    return await showCupertinoDialog<ManageEditNameDescDialogResult?>(
      context: context,
      builder: (context) {
        return ManageEditNameDescDialogWidget(
          name: name,
          description: description,
        );
      },
    );
  }

}

class ManageEditNameDescDialogWidget extends StatefulWidget {
  final List<LanguageText?>? name;
  final List<LanguageText?>? description;
  const ManageEditNameDescDialogWidget({super.key, this.name, this.description});

  @override
  State<ManageEditNameDescDialogWidget> createState() => _ManageEditNameDescDialogWidgetState();
}

class _ManageEditNameDescDialogWidgetState extends State<ManageEditNameDescDialogWidget> {
  List<_ManageEditGlossDescModel> nameList = [];
  List<_ManageEditGlossDescModel> descriptionList = [];

  @override
  void initState() {
    super.initState();

    for(int i = 0; i < (widget.name?.length??0); i++){
      nameList.add(_ManageEditGlossDescModel(
        lang: widget.name?[i]?.lang, 
        text: widget.name?[i]?.text, 
        controller: TextEditingController(text: widget.name?[i]?.text),
      ));
    }

    for(int i = 0; i < (widget.description?.length??0); i++){
      descriptionList.add(_ManageEditGlossDescModel(
        lang: widget.description?[i]?.lang, 
        text: widget.description?[i]?.text, 
        controller: TextEditingController(text: widget.description?[i]?.text),
      ));
    }
  }


  /// 保存
  void _save(){
    if(nameList.every((e) => e.controller.text.isEmpty)){
      ToastUtils.showToast(text: "名称不能为空");
      return;
    }

    if(descriptionList.every((e) => e.controller.text.isEmpty)){
      ToastUtils.showToast(text: "说明不能为空");
      return;
    }

    ManageEditNameDescDialogResult result = ManageEditNameDescDialogResult(
      name: nameList.map((e) => LanguageText(lang: e.lang, text: e.controller.text)).toList(),
      description: descriptionList.map((e) => LanguageText(lang: e.lang, text: e.controller.text)).toList(),
    );
    Get.back(result: result);
  }


  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "编辑名称说明",
      width: 1200.wMin,
      titlePadding: EdgeInsets.only(
        left: 32.wMin,
        right: 32.wMin,
        top: 32.wMin,
      ),
      child: Container(
        height: 800.wMin,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 32.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.wMin),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderThin.color,
            ),
            Expanded(child: _buildFormWidget()),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderThin.color,
            ),
            SizedBox(height: 16.wMin),
            _buildButtonsWidget(),
            SizedBox(height: 16.wMin),
          ],
        ),
      ),
    );
  }


  Widget _buildFormWidget(){
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16.wMin),
      child: Column(
        spacing: 42.wMin,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            spacing: 24.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(nameList.length, (index){
              return _buildInputWidget(
                title: "名称 ·${nameList[index].lang}",
                controller: nameList[index].controller,
              );
            }),
          ),
          Column(
            spacing: 24.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(descriptionList.length, (index){
              return _buildInputWidget(
                title: "说明 ·${descriptionList[index].lang}",
                controller: descriptionList[index].controller,
                isMultipleLines: true,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ButtonWidget(
          text: "取消",
          width: 112.wMin,
          height: 56.wMin,
          borderRadius: 8.wMin,
          color: AppTheme.cSurfaceLayerElevated.color,
          fontColor: AppTheme.cTextSecondary.color,
          fontSize: 24.wMin,
          fontWeight: FontWeight.w500,
          sclae: 1.03,
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 12.wMin),
        ButtonWidget(
          text: "保存",
          width: 112.wMin,
          height: 56.wMin,
          borderRadius: 8.wMin,
          color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.8),
          fontSize: 24.wMin,
          fontWeight: FontWeight.w500,
          sclae: 1.03,
          onTap: () {
            _save();
          },
        ),
      ],
    );
  }

  Widget _buildInputWidget({
    TextEditingController? controller,
    String? hintText,
    String? title,
    bool isMultipleLines = false,
  }){
    return CardInputWidget(
      title: title,
      maxLines: isMultipleLines ? 2 : 1,
      fillColor: AppTheme.cSurfaceLayerBase.color,
      borderColor: AppTheme.cBorderThin.color,
      titleStyle: TextStyle(
        fontSize: 24.wMin,
        fontWeight: FontWeight.w500,
        color: AppTheme.cTextSecondary.color,
      ),
      controller: controller,
      hintText: hintText,
      height: isMultipleLines ? 120.wMin : 68.wMin,
      borderRadius: BorderRadius.circular(12.wMin),
      valueStyle: TextStyle(
        fontSize: 28.wMin,
        color: AppTheme.cTextPrimary.color,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        fontSize: 28.wMin,
        color: AppTheme.cTextTertiary.color,
        fontWeight: FontWeight.w400,
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