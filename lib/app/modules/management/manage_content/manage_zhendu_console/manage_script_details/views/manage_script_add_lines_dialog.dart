import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../common/commons.dart';
import '../../common/manage_select_emotion_dialog.dart';
import '../../common/manage_zhendu_widgets.dart';

class ManageScriptAddLinesReslut{
  ManageScriptDetilEntityScenesPersonas persona;
  ManageVocalEmotionsEntity emotion;
  String delayAfter;
  String lines;
  ManageScriptAddLinesReslut({
    required this.persona,
    required this.emotion,
    required this.delayAfter,
    required this.lines,
  });
}

/// 新增台词
class ManageScriptAddLinesDialog{

  static Future<ManageScriptAddLinesReslut?> show({
    required BuildContext context,
    required List<ManageScriptDetilEntityScenesPersonas> personas,
  }) async{

    return await showCupertinoDialog<ManageScriptAddLinesReslut?>(
      context: context,
      builder: (context) {
        return ManageScriptAddLinesDialogWidget(personas: personas);
      },
    );
  }

}

class ManageScriptAddLinesDialogWidget extends StatefulWidget {
  final List<ManageScriptDetilEntityScenesPersonas> personas;
  const ManageScriptAddLinesDialogWidget({super.key, required this.personas});

  @override
  State<ManageScriptAddLinesDialogWidget> createState() => _ManageScriptAddLinesDialogWidgetState();
}

class _ManageScriptAddLinesDialogWidgetState extends State<ManageScriptAddLinesDialogWidget> {

  /// 选择的演员
  ManageScriptDetilEntityScenesPersonas? selectPersona;

  /// 选择的情绪
  ManageVocalEmotionsEntity? selectEmotionData;

  /// delayAfter
  final TextEditingController delayAfterInput = TextEditingController(text: "1");

  /// 台词
  final TextEditingController linesInput = TextEditingController();


  /// 选择情绪
  Future<void> selectEmotion() async{
    ManageVocalEmotionsEntity? res = await ManageSelectEmotionDialog.show(
      context: context,
      initEmotionNid: selectEmotionData?.nid,
    );
    if(res == null) return;
    selectEmotionData = res;
    if(mounted) setState(() {});
  }


  /// 确认
  void confirm(){

    if(selectPersona == null) return ToastUtils.showToast(text: "请选择参演人员");
    if(selectEmotionData == null) return ToastUtils.showToast(text: "请选择情绪");
    if(delayAfterInput.text.trim().isEmpty) return ToastUtils.showToast(text: "请输入delay_after");
    if(linesInput.text.trim().isEmpty) return ToastUtils.showToast(text: "请输入台词");

    ManageScriptAddLinesReslut reslut = ManageScriptAddLinesReslut(
      persona: selectPersona!,
      emotion: selectEmotionData!,
      delayAfter: delayAfterInput.text,
      lines: linesInput.text,
    );
    Get.back(result: reslut);
  }

  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "新增台词",
      width: 1400.wMin,
      onCancel: () => Get.back(),
      confirmText: "保存并插入首位",
      onConfirm: () {
        confirm();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
        height: 600.wMin,
        child: Column(
          children: [
        
            _buildConfigWidget(),
            SizedBox(height: 24.wMin),
            _buildLinesWidget(),

          ],
        ),
      ),
    );
  }

  Widget _buildConfigWidget(){
    return Row(
      spacing: 16.wMin,
      children: [
        Expanded(
          child: ManageZhenduDropdownWidget(
            title: "参演人物",
            hintText: "请选择",
            selectValue: selectPersona,
            items: List.generate(widget.personas.length, (index){
              return IconDropdownCheckData<ManageScriptDetilEntityScenesPersonas>(
                title: widget.personas[index].speaker??"",
                value: widget.personas[index],
              );
            }),
            onChanged: (choiceData, index) {
              selectPersona = choiceData.value;
              if(mounted) setState(() {});
            },
          ),
        ),
        Expanded(
          child: ManageZhenduSelectWidget(
            title: "情绪",
            hintText: "请选择情绪",
            value: "${selectEmotionData?.name?.firstWhereOrNull((e) => e?.lang == "zh")?.text??''} (nid: ${selectEmotionData?.nid??''})",
            onTap: () {
              selectEmotion();
            },
          ),
        ),
        Expanded(
          child: ManageZhenduNumberInputWidget(
            title: "delay_after",
            controller: delayAfterInput,
            jumpValue: 0.1,
            minValue: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildLinesWidget(){
    return ManageZhenduInputHeightWidget(
      title: "台词",
      hintText: "输入新增台词内容",
      height: 400.wMin,
      maxLines: 20,
      controller: linesInput,
    );
  }

}