import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_dialog_box_widget.dart';

import '../../common/manage_zhendu_widgets.dart';
import '../models/manage_vocal_timbre_model.dart';

enum ManageAddDialectTimberCreateType{
  /// ai
  ai,
  /// 手动
  manual,
}


/// 新增方言音色选择方式弹窗
class ManageAddDialectTimberDialog{

  static Future<ManageAddDialectTimberCreateType?> show({
    required BuildContext context,
  }) async{

    return await showCupertinoDialog<ManageAddDialectTimberCreateType?>(
      context: context,
      builder: (context) {
        return const ManageAddDialectTimberDialogWidget();
      },
    );
  }


  static Future<ManageVocalDialectTimbreCodeModel?> showAiCreate({
    required BuildContext context,
    required List<ManageVocalDialectTimbreCodeModel> dialectTimbreCodes,
    required ManageVocalDialectTimbreCodeModel selectCode,
  }) async{

    return await showCupertinoDialog<ManageVocalDialectTimbreCodeModel?>(
      context: context,
      builder: (context) {
        return ManageAddDialectTimberAiCreateDialogWidget(
          dialectTimbreCodes: dialectTimbreCodes,
          selectCode: selectCode,
        );
      },
    );
  }

}


class ManageAddDialectTimberDialogWidget extends StatefulWidget {
  const ManageAddDialectTimberDialogWidget({super.key});

  @override
  State<ManageAddDialectTimberDialogWidget> createState() => _ManageAddDialectTimberDialogWidgetState();
}

class _ManageAddDialectTimberDialogWidgetState extends State<ManageAddDialectTimberDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "新增方言音色",
      width: 700.wMin,
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        child: Column(
          spacing: 16.wMin,
          children: [
        
            TapScaleWidget(
              onTap: () {
                Get.back(result: ManageAddDialectTimberCreateType.ai);
              },
              sclae: 1.01,
              backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
              borderRadius: 16.wMin,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  border: Border.all(width: 1.wMin, color: const Color(0xffFB923C)),
                  color: const Color(0xffFB923C).withValues(alpha: 0.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.wMin,
                  children: [
        
                    Text(
                      "AI 生成",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
        
                    Text(
                      "先选择 dialect，再发起 AI 设计。",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
        
                  ],
                ),
              ),
            ),

            TapScaleWidget(
              onTap: () {
                Get.back(result: ManageAddDialectTimberCreateType.manual);
              },
              sclae: 1.01,
              backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
              borderRadius: 16.wMin,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderTertiary.color),
                  color: AppTheme.cSurfaceTertiary.withValues(alpha: 0.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.wMin,
                  children: [
        
                    Text(
                      "手动填",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
        
                    Text(
                      "直接新增一条方言音色，手工填写 description 与设计台词。",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
        
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}


class ManageAddDialectTimberAiCreateDialogWidget extends StatefulWidget {
  final List<ManageVocalDialectTimbreCodeModel> dialectTimbreCodes;
  final ManageVocalDialectTimbreCodeModel selectCode;
  const ManageAddDialectTimberAiCreateDialogWidget({super.key, required this.dialectTimbreCodes, required this.selectCode});

  @override
  State<ManageAddDialectTimberAiCreateDialogWidget> createState() => _ManageAddDialectTimberAiCreateDialogWidgetState();
}

class _ManageAddDialectTimberAiCreateDialogWidgetState extends State<ManageAddDialectTimberAiCreateDialogWidget> {

  late ManageVocalDialectTimbreCodeModel dialect;

  @override
  void initState() {
    super.initState();
    dialect = widget.selectCode;
  }

  

  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "AI 生成方言音色",
      width: 700.wMin,
      confirmText: "确认生成",
      confirmColor: const Color(0xffFB923C),
      onConfirm: () {
        Get.back(result: dialect);
      },
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ManageZhenduDropdownWidget(
              title: "dialect",
              hintText: "请选择",
              selectValue: dialect,
              items: List.generate(widget.dialectTimbreCodes.length, (index){
                String title = widget.dialectTimbreCodes[index].code;
                if(widget.dialectTimbreCodes[index].isOccupy){
                  title += "(已占用)";
                }
                return IconDropdownCheckData(
                  title: title,
                  value: widget.dialectTimbreCodes[index],
                  isEnable: !widget.dialectTimbreCodes[index].isOccupy,
                );
              }),
              onChanged: (choiceData, index) {
                dialect = choiceData.value;
                if(mounted) setState(() {});
              },
            ),

            SizedBox(height: 50.wMin),

          ],
        ),
      ),
    );
  }
}