
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../common/commons.dart';
import '../../common/manage_zhendu_widgets.dart';

/// 剧本详情 查看全文
class ManageScriptViewFullDialog{

  static Future<bool> show({
    required BuildContext context,
    required ManageScriptDetilEntity data,
  }) async{

    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return ManageScriptViewFullDialogWidget(data: data);
      },
    );
    return res ?? false;
  }

}

class ManageScriptViewFullDialogWidget extends StatefulWidget {
  final ManageScriptDetilEntity data;
  const ManageScriptViewFullDialogWidget({super.key, required this.data});

  @override
  State<ManageScriptViewFullDialogWidget> createState() => _ManageScriptViewFullDialogWidgetState();
}

class _ManageScriptViewFullDialogWidgetState extends State<ManageScriptViewFullDialogWidget> {

  /// 标题
  Map<String, TextEditingController> titleControllers = {};

  /// 剧本文章
  TextEditingController scriptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (LanguageText? element in widget.data.title??[]) {
      if(element?.lang == null) continue;
      titleControllers[element!.lang!] = TextEditingController(text: element.text ?? "");
    }

    scriptController.text = widget.data.text ?? "";
  }


  /// 保存
  Future<void> _save() async{
    if(widget.data.uid == null){
      ToastUtils.showToast(text: "剧本id不能为空");
      return;
    }

    if(titleControllers.values.any((element) => element.text.isEmpty)){
      ToastUtils.showToast(text: "请输入标题");
      return;
    }
    if(scriptController.text.isEmpty){
      ToastUtils.showToast(text: "请输入剧本文章");
      return;
    }

    Map<String, dynamic> reqData = {
      "title": List.generate(titleControllers.length, (index){
        return {
          "lang": titleControllers.keys.elementAt(index),
          "text": titleControllers.values.elementAt(index).text,
        };
      }),
      "text": scriptController.text,
    };

    try{
      ToastUtils.showLoading();
      bool res = await LanguageConsoleDramaRequest.scriptEdit(widget.data.uid!, data: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      Get.back(result: true);
    } finally {
      ToastUtils.hideLoading();
    }

  }


  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "剧本全文",
      width: 1300.wMin,
      cancelText: "关闭",
      onCancel: () => Get.back(),
      confirmText: "保存",
      onConfirm: () {
        _save();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
        alignment: Alignment.topLeft,
        width: double.infinity,
        height: 800.wMin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(),
            SizedBox(height: 20.wMin,),
            _buildContentWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Column(
      spacing: 10.wMin,
      children: List.generate(titleControllers.length, (index){

        return ManageZhenduInputWidget(
          title: "${titleControllers.keys.elementAt(index)} 标题",
          controller: titleControllers.values.elementAt(index),
          hintText: "请输入 ${titleControllers.keys.elementAt(index)} 标题",
        );

      })
      ,
    );
  }


  Widget _buildContentWidget(){
    return ManageZhenduInputHeightWidget(
      title: "剧本文章",
      controller: scriptController,
      hintText: "请输入剧本文章",
      maxLines: 20,
      height: 500.wMin,
    );
  }



}