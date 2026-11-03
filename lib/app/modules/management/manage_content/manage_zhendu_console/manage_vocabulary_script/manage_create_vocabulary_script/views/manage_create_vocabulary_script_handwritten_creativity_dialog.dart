import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/manage_content/manage_zhendu_console/common/manage_zhendu_widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/public_controller/config_controller.dart';
import '../../../../../../../../common/widgets/widgets.dart';
import '../../../../../common/commons.dart';
import '../../../enums/manage_script_mode_enum.dart';

class ManageCreateVocabularyScriptHandwrittenCreativityResult{
  int sceneCount;
  /// 难度等级
  String cefr;
  /// 剧本模式
  ManageScriptModeEnum scriptMode;
  /// 故事创意
  String? story;
  /// 必须包含的语义列表
  List<ManageVocabularyCreativityEntityMustIncludeSemantics> mustIncludeSemantics;



  ManageCreateVocabularyScriptHandwrittenCreativityResult({
    required this.sceneCount,
    required this.cefr,
    required this.scriptMode,
    this.story,
    required this.mustIncludeSemantics,
  });
}

class ManageCreateVocabularyScriptHandwrittenCreativityDialog{

  /// 显示创建剧本手写创意弹窗
  /// [genre] 剧本题材
  /// [sceneCount] 场景数量
  /// 故事创意
  static Future<ManageCreateVocabularyScriptHandwrittenCreativityResult?> show({
    required BuildContext context,
    required ManageScriptGenreEntity genre,
    int? sceneCount,
    String? story,
    String? cefr,
    ManageScriptModeEnum? scriptMode,
    required List<EnKnowledgeEntitySemantics> semanticList,
    List<int>? selectedSemanticIds,
  }) async{

    return await showCupertinoDialog<ManageCreateVocabularyScriptHandwrittenCreativityResult?>(
      context: context, 
      builder: (context) {
        return ManageCreateVocabularyScriptHandwrittenCreativityDialogWidget(
          genre: genre,
          sceneCount: sceneCount,
          story: story,
          cefr: cefr,
          scriptMode: scriptMode,
          semanticList: semanticList,
          selectedSemanticIds: selectedSemanticIds,
        );
      },
    );

  }

}

class ManageCreateVocabularyScriptHandwrittenCreativityDialogWidget extends StatefulWidget {
  final ManageScriptGenreEntity genre;
  final int? sceneCount;
  final String? story;
  /// 难度等级
  final String? cefr;
  /// 剧本模式
  final ManageScriptModeEnum? scriptMode;
  /// 选中的语义
  final List<EnKnowledgeEntitySemantics> semanticList;
  /// 选中的语义nid
  final List<int>? selectedSemanticIds;

  const ManageCreateVocabularyScriptHandwrittenCreativityDialogWidget({
    super.key, 
    required this.genre, 
    this.sceneCount, 
    this.story, 
    this.cefr, this.scriptMode, 
    required this.semanticList,
    this.selectedSemanticIds,
  });

  @override
  State<ManageCreateVocabularyScriptHandwrittenCreativityDialogWidget> createState() => _ManageCreateVocabularyScriptHandwrittenCreativityDialogWidgetState();
}

class _ManageCreateVocabularyScriptHandwrittenCreativityDialogWidgetState extends State<ManageCreateVocabularyScriptHandwrittenCreativityDialogWidget> {

  /// 场景数量输入框
  final TextEditingController sceneCountController = TextEditingController(text: "3");

  /// 难度等级
  String cefr = "A1";

  /// 剧本模式
  ManageScriptModeEnum scriptMode = ManageScriptModeEnum.auto;

  /// 故事创意输入框
  final TextEditingController storyController = TextEditingController();

  /// 选中的语义nid
  List<int> selectedSemanticIds = [];



  @override
  void initState() {
    super.initState();
    sceneCountController.text = widget.sceneCount?.toString() ?? "3";
    storyController.text = widget.story ?? "";
    cefr = widget.cefr ?? "A1";
    scriptMode = widget.scriptMode ?? ManageScriptModeEnum.auto;

    selectedSemanticIds = widget.selectedSemanticIds ?? [];
  }

  @override
  Widget build(BuildContext context) {
    ConfigController configController = Get.find<ConfigController>();
    List<DifficultieEntity> difficultieList = DifficultieUtils.getDifficultieList(configController.appConfig.value, "en")??[];

    return ManageDialogBoxWidget(
      title: "编辑手写创意",
      width: 1200.wMin,
      onCancel: () => Get.back(),
      confirmText: "确认加入",
      confirmColor: AppTheme.cSurfaceWarning.color,
      onConfirm: () {
        int? sceneCount = int.tryParse(sceneCountController.text);
        if(sceneCount == null) return;
        String? story = storyController.text;

        List<ManageVocabularyCreativityEntityMustIncludeSemantics> mustIncludeSemantics = [];
        for(EnKnowledgeEntitySemantics semantic in widget.semanticList){
          if(semantic.uid == null) continue;
          if(!selectedSemanticIds.contains(semantic.uid)) continue;
          mustIncludeSemantics.add(ManageVocabularyCreativityEntityMustIncludeSemantics(
            uid: semantic.uid,
            text: semantic.definition,
          ));
        }

        Get.back(result: ManageCreateVocabularyScriptHandwrittenCreativityResult(
          sceneCount: sceneCount,
          story: story,
          cefr: cefr,
          scriptMode: scriptMode,
          mustIncludeSemantics: mustIncludeSemantics,
        ));

      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SelectableText(
              widget.genre.name?.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            SelectableText(
              widget.genre.nid??"",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),

            SizedBox(height: 16.wMin),

            Row(
              spacing: 16.wMin,
              children: [
                Expanded(
                  child: ManageZhenduNumberInputWidget(
                    title: "场景数量",
                    controller: sceneCountController,
                    isInt: true,
                    minValue: 1,
                  ),
                ),
                Expanded(
              child: ManageZhenduDropdownWidget(
                title: "难度等级",
                hintText: "请选择难度等级",
                selectValue: cefr,
                items: List.generate(difficultieList.length, (index){
                  return IconDropdownCheckData<String>(
                    title: difficultieList[index].name?.text??"",
                    value: difficultieList[index].name?.text??"",
                  );
                }),
                onChanged: (choiceData, index) {
                  cefr = choiceData.value;
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: ManageZhenduDropdownWidget(
                title: "剧本模式",
                selectValue: scriptMode,
                items: List.generate(ManageScriptModeEnum.values.length, (index){
                  return IconDropdownCheckData<ManageScriptModeEnum>(
                    title: ManageScriptModeEnum.values[index].label,
                    value: ManageScriptModeEnum.values[index],
                  );
                }),
                onChanged: (choiceData, index) {
                  scriptMode = choiceData.value;
                  setState(() {});
                },
              ),
            ),
              ],
            ),

            SizedBox(height: 16.wMin),

            ManageZhenduInputHeightWidget(
              title: "故事创意",
              hintText: "写清故事方向、冲突、角色行动和语言学习目标。留空则只按题材自由生成。",
              controller: storyController,
              maxLines: 20,
              height: 300.wMin,
            ),

            SizedBox(height: 16.wMin),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 4.wMin),
                  child: Text(
                    "必须包含的语义",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 10.wMin,
                  runSpacing: 6.wMin,
                  alignment: WrapAlignment.start,
                  children: List.generate(widget.semanticList.length, (index){
                    return _buildListItemFromSemanticItemWidget(widget.semanticList[index]);
                  }),
                ),
              ],
            ),

            SizedBox(height: 16.wMin),

          ],
        ),
      ),
    );
  }

  /// 语义列表
  Widget _buildListItemFromSemanticItemWidget(EnKnowledgeEntitySemantics semantic){
    bool isSelected = selectedSemanticIds.contains(semantic.uid);
    return ButtonWidget(
      text: "${semantic.uid??''} · ${semantic.definition??''}",
      alignment: null,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
      color: isSelected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2) : AppTheme.cSurfaceTertiary.color,
      border: Border.all(
        width: 1.wMin,
        color: isSelected ? AppTheme.cSurfaceBrand.color : AppTheme.cBorderPrimary.color,
      ),
      fontColor: isSelected ? AppTheme.cTextBrand.color : AppTheme.cTextTertiary.color,
      fontSize: 20.wMin,
      borderRadius: 4.wMin,
      sclae: 1.03,
      leftIcon: Container(
        margin: EdgeInsets.only(right: 4.wMin),
        child: SvgPicture.asset(
          isSelected ? "assets/svg/public/icon_check_b.svg" : "assets/svg/public/icon_uncheck_box.svg",
          width: 24.wMin,
          height: 24.wMin,
        ),
      ),
      onTap: () {
        if(semantic.uid == null){
          return;
        }
        if(isSelected){
          selectedSemanticIds.remove(semantic.uid);
        }else{
          selectedSemanticIds.add(semantic.uid!);
        }
        setState(() {});
      },
    );
  }


}