
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_tag_widget.dart';
import 'package:langwise/app/modules/management/manage_content/manage_zhendu_console/common/manage_zhendu_widgets.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../theme/theme.dart';
import '../../../enums/manage_script_mode_enum.dart';
import '../controllers/manage_create_vocabulary_script_controller.dart';
import '../models/manage_create_vocabulary_patha_model.dart';
import '../models/manage_create_vocabulary_pathb_model.dart';

class ManageCreateVocabularyScriptPathWidget extends StatelessWidget {
  final ManageCreateVocabularyScriptController controller;
  const ManageCreateVocabularyScriptPathWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 16.wMin),
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleTabWidget(),
          SizedBox(height: 12.wMin),
          Obx((){
            int mode = controller.selectProductionPath.value;
            if(mode == 0){
              return ManageCreateVocabularyScriptPathAWidget(controller: controller);
            } else if(mode == 1){
              return ManageCreateVocabularyScriptPathBWidget(controller: controller);
            } else if(mode == 2){
              return ManageCreateVocabularyScriptPathCWidget(controller: controller);
            }

            return Container();
            
          }),
        ],
      ),
    );
  }

  Widget _buildTitleTabWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "3. 选择生产路径",
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 12.wMin),
            SelectableText(
              "先确定内容和地区，再选择本次生成要走的控制粒度。",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.wMin),
        Row(
          spacing: 16.wMin,
          children: [
            _buildTitleTabItemWidget(
              type: 0,
              color: AppTheme.cSurfaceSuccess.color,
              title: "路径 A：先生成创意再生成",
              desc: "先返回多个创意候选，人工挑选、微调后再一把正式生成。",
            ),
            _buildTitleTabItemWidget(
              type: 1,
              color: AppTheme.cSurfaceWarning.color,
              title: "路径 B：选题材写创意",
              desc: "每个题材一张创意卡，适合需要明确故事方向的生产。",
            ),
            _buildTitleTabItemWidget(
              type: 2,
              color: AppTheme.cSurfaceBrand.color,
              title: "路径 C：只选题材",
              desc: "最懒模式。不写创意，让后端按题材自动补齐。",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleTabItemWidget({
    required int type,
    required Color color,
    required String title,
    required String desc,
  }){
    return Obx((){
      bool isSelected = controller.selectProductionPath.value == type;
      return Expanded(
        child: TapScaleWidget(
          onTap: () {
            controller.selectProductionPathFun(type);
          },
          sclae: 1,
          child: Container(
            padding: EdgeInsets.all(16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: isSelected ? color.withValues(alpha: 0.2) : AppTheme.cSurfaceSecondary.color,
              border: Border.all(width: 1.wMin, color: isSelected ? color : AppTheme.cBorderPrimary.color),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6.wMin,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color:AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color:AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }


}


class ManageCreateVocabularyScriptPathAWidget extends StatelessWidget {
  final ManageCreateVocabularyScriptController controller;
  const ManageCreateVocabularyScriptPathAWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.05),
        border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          _buildTitleWidget(),
          SizedBox(height: 10.wMin),
          _buildListWidget(context),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ManageTagFS16Widget(
              tag: "路径A",
              bgColor: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
              fontColor: AppTheme.cSurfaceSuccess.color,
              borderRadius: 999,
            ),

            SizedBox(height: 8.wMin),

            SelectableText(
              "先生成创意，返回后挑选/修改",
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const Spacer(),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 200.wMin,
              child: ManageZhenduNumberInputWidget(
                title: "创意候选数量",
                isInt: true,
                minValue: 1,
                height: 50.wMin,
                controller: controller.pathACandidateCountController,
              ),
            ),

            SizedBox(width: 16.wMin),

            Obx((){
              return ButtonWidget(
                text: controller.pathARequestStatus.value == 1 ? "取消等待" : "创意候选",
                height: 50.wMin,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                color: controller.pathARequestStatus.value == 1 ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.6) : AppTheme.cSurfaceSuccess.color,
                fontSize: 20.wMin,
                borderRadius: 10.wMin,
                sclae: 1.03,
                onTap: () {
                  controller.getPathAList();
                },
              );
            }),
          ],
        ),

      ],
    );
  }

  Widget _buildListWidget(BuildContext context){
    return Obx((){
      if(controller.selectKnowledgeList.isEmpty){
        return _buildListNotDataWidget("请先选择请选择词汇知识点");
      }
      if(controller.pathARequestStatus.value == 0){
        return _buildListNotDataWidget("请先生成创意");
      }
      if(controller.pathARequestStatus.value == 1){
        return _buildListNotDataWidget("等待创意候选返回", showLoading: true);
      }
      if(controller.pathARequestStatus.value == 3){
        return _buildListNotDataWidget("暂无创意");
      }
      return ListView.separated(
        itemCount: controller.pathAList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => SizedBox(height: 10.wMin),
        itemBuilder: (context, index) {
          return _buildListItemWidget(context, controller.pathAList[index], index);
        },
      );
    });
  }

  Widget _buildListNotDataWidget(String text, {bool showLoading = false}){
    return Container(
      height: 200.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: showLoading,
            child: SpinKitFadingCircle(
              color: AppTheme.cBgBrand,
              size: 100.wMin,
            ),
          ),
          SelectableText(
            text,
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildListItemWidget(BuildContext context, ManageCreateVocabularyPathAModel item, int index){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
        border: Border.all(
          width: 1.wMin,
          color: item.isSelected ? AppTheme.cSurfaceSuccess.color : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildListItemTitleWidget(item, index),

          _buildListItemFromWidget(item, context),

        ],
      ),
    );
  }

  Widget _buildListItemTitleWidget(ManageCreateVocabularyPathAModel item, int index){
    ManageScriptGenreEntity? genre = controller.getGenreDetail(item.genreNid);

    return Row(
      children: [
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ManageTagFS16Widget(
                  tag: "#${index+1}",
                  fontColor: AppTheme.cTextSecondary.color,
                  borderRadius: 999,
                ),
                SizedBox(width: 10.wMin),
                ManageTagFS16Widget(
                  tag: "创意候选",
                  fontColor: AppTheme.cSurfaceSuccess.color,
                  borderRadius: 999,
                ),
                SizedBox(width: 10.wMin),
                ManageTagFS16Widget(
                  tag: item.cefr,
                  fontColor: AppTheme.cTextSecondary.color,
                  borderRadius: 999,
                ),
              ],
            ),

            SizedBox(height: 6.wMin),

            Row(
              spacing: 6.wMin,
              children: [
                SelectableText(
                  genre?.name?.firstWhereOrNull((element) => element?.lang == "zh")?.text??"",
                  style: TextStyle(
                    fontSize: 22.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SelectableText(
                  item.genreNid??"",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

          ],
        ),

        const Spacer(),

        ButtonWidget(
          text: item.isSelected ? "已加入生成计划" : "选中这个创意",
          height: 50.wMin,
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          color: item.isSelected ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceTertiary.color,
          fontColor: item.isSelected ? Colors.white : AppTheme.cTextSecondary.color,
          fontSize: 20.wMin,
          borderRadius: 10.wMin,
          sclae: 1.03,
          leftIcon: Visibility(
            visible: !item.isSelected,
            child: SvgPicture.asset(
              "assets/svg/public/icon_add.svg",
              width: 24.wMin,
            ),
          ),
          onTap: () {
            controller.selectPathA(item);
          },
        ),

      ],
    );
  }

  Widget _buildListItemFromWidget(ManageCreateVocabularyPathAModel item, BuildContext context){

    ConfigController configController = Get.find<ConfigController>();
    
    List<DifficultieEntity> difficultieList = DifficultieUtils.getDifficultieList(configController.appConfig.value, "en")??[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.wMin,
      children: [

        Row(
          children: [
            Expanded(
              child: ManageZhenduDropdownWidget(
                title: "题材",
                selectValue: item.genreNid,
                items: List.generate(controller.scriptGenreList.length, (index){
                  String genreName = controller.scriptGenreList[index].name?.firstWhereOrNull((element) => element?.lang == "zh")?.text??"";
                  String genreNid = controller.scriptGenreList[index].nid??"";
                  return IconDropdownCheckData(
                    title: "$genreName · $genreNid",
                    value: genreNid,
                  );
                }),
                onChanged: (choiceData, index) {
                  item.genreNid = choiceData.value;
                  controller.pathAList.refresh();
                },
              ),
            ),
            SizedBox(width: 16.wMin),
            Expanded(
              child: ManageZhenduNumberInputWidget(
                title: "场景数量",
                controller: item.sceneCountController,
                isInt: true,
                minValue: 1,
              ),
            ),
            SizedBox(width: 16.wMin),
            Expanded(
              child: ManageZhenduDropdownWidget(
                title: "难度等级",
                selectValue: item.cefr,
                items: List.generate(difficultieList.length, (index){
                  return IconDropdownCheckData<String>(
                    title: difficultieList[index].name?.text??"",
                    value: difficultieList[index].name?.text??"",
                  );
                }),
                onChanged: (choiceData, index) {
                  item.cefr = choiceData.value;
                  controller.pathAList.refresh();
                },
              ),
            ),
            SizedBox(width: 16.wMin),
            Expanded(
              child: ManageZhenduDropdownWidget(
                title: "剧本模式",
                selectValue: item.scriptMode,
                items: List.generate(ManageScriptModeEnum.values.length, (index){
                  return IconDropdownCheckData<ManageScriptModeEnum>(
                    title: ManageScriptModeEnum.values[index].label,
                    value: ManageScriptModeEnum.values[index],
                  );
                }),
                onChanged: (choiceData, index) {
                  item.scriptMode = choiceData.value;
                  controller.pathAList.refresh();
                },
              ),
            ),
          ],
        ),

        ManageZhenduInputHeightWidget(
          title: "故事创意",
          height: 100.wMin,
          maxLines: 10,
          hintText: "写清故事方向、冲突、角色行动和语言学习目标。留空则只按题材自由生成。",
          controller: item.storyCreativityController,
        ),

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
              children: List.generate(item.mustIncludeSemantics.length, (index){
                return _buildListItemFromSemanticItemWidget(item.mustIncludeSemantics[index]);
              }),
            ),
          ],
        ),


      ],
    );
  }


  /// 语义列表
  Widget _buildListItemFromSemanticItemWidget(ManageCreateVocabularyPathASemanticModel semantic){
    return ButtonWidget(
      text: "${semantic.data.uid??''} · ${semantic.data.text??''}",
      alignment: null,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
      color: semantic.isSelected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2) : AppTheme.cSurfaceTertiary.color,
      border: Border.all(
        width: 1.wMin,
        color: semantic.isSelected ? AppTheme.cSurfaceBrand.color : AppTheme.cBorderPrimary.color,
      ),
      fontColor: semantic.isSelected ? AppTheme.cTextBrand.color : AppTheme.cTextTertiary.color,
      fontSize: 20.wMin,
      borderRadius: 4.wMin,
      sclae: 1.03,
      leftIcon: Container(
        margin: EdgeInsets.only(right: 4.wMin),
        child: SvgPicture.asset(
          semantic.isSelected ? "assets/svg/public/icon_check_b.svg" : "assets/svg/public/icon_uncheck_box.svg",
          width: 24.wMin,
          height: 24.wMin,
        ),
      ),
      onTap: () {
        semantic.isSelected = !semantic.isSelected;
        controller.pathAList.refresh();
      },
    );
  }

}


class ManageCreateVocabularyScriptPathBWidget extends StatelessWidget {
  final ManageCreateVocabularyScriptController controller;
  const ManageCreateVocabularyScriptPathBWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.05),
        border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget(),
          SizedBox(height: 10.wMin),
          _buildListWidget(context),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    
        ManageTagFS16Widget(
          tag: "路径B",
          bgColor: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
          fontColor: AppTheme.cSurfaceWarning.color,
          borderRadius: 999,
        ),
    
        SizedBox(height: 8.wMin),
    
        SelectableText(
          "点击题材，直接写创意",
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        
      ],
    );
  }

  Widget _buildListWidget(BuildContext context){
    return Obx((){
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.pathBList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.wMin,
          crossAxisSpacing: 10.wMin,
          mainAxisExtent: 210.wMin,
        ),
        itemBuilder: (context, index) {
          return _buildListItemWidget(context, controller.pathBList[index]);
        },
      );
    });
  }

  Widget _buildListItemWidget(BuildContext context, ManageCreateVocabularyPathBModel item){
    return TapScaleWidget(
      onTap: item.isSelected ? null : () {
        controller.editHandwrittenCreativity(context, item);
      },
      sclae: 1.01,
      backColor: AppTheme.cSurfaceSecondary.color,
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: Colors.transparent,
          border: Border.all(
            width: 1.wMin, 
            color: item.isSelected ? AppTheme.cSurfaceWarning.color: AppTheme.cBorderPrimary.color,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.genre.name?.firstWhereOrNull((element) => element?.lang == "zh")?.text ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        item.genre.nid??"",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: AppTheme.cTextSecondary.color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
    
                ButtonWidget(
                  text: "已存在剧本数量: ${item.genre.existCount??0}",
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
                  color: AppTheme.cSurfaceSuccess.color.withValues(alpha: (item.genre.existCount??0) == 0 ? 0.1 : 0.2),
                  fontColor: (item.genre.existCount??0) == 0 ? AppTheme.cTextTertiary.color : AppTheme.cSurfaceSuccess.color,
                  fontSize: 14.wMin,
                ),
    
                SizedBox(width: 6.wMin),
    
                ButtonWidget(
                  text: "${item.genre.difficulty?.min??0}-${item.genre.difficulty?.max??0}",
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
                  color: const Color(0xff00A6F4).withValues(alpha: 0.2),
                  fontColor: const Color(0xff00A6F4),
                  fontSize: 14.wMin,
                ),

                Visibility(
                  visible: item.isSelected,
                  child: Container(
                    margin: EdgeInsets.only(left: 6.wMin),
                    child: ButtonWidget(
                      text: "已加入",
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
                      color: AppTheme.cSurfaceWarning,
                      fontSize: 14.wMin,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.wMin),
            Text(
              item.genre.description?.firstWhereOrNull((element) => element?.lang == "zh")?.text ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4.wMin),

            Visibility(
              visible: item.isSelected,
              child: Container(
                height: 44.wMin,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: AppTheme.cSurfacePrimary.color,
                ),
                child: SelectableText(
                  item.storyCreativityController.text,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            const Spacer(),

            Row(
              children: [

                Visibility(
                  visible: !item.isSelected,
                  child: ButtonWidget(
                    text: "选择并写创意",
                    height: 44.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
                    border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSuccess.color),
                    borderRadius: 8.wMin,
                    fontSize: 18.wMin,
                    fontColor: AppTheme.cSurfaceSuccess.color,
                  ),
                ),

                Visibility(
                  visible: item.isSelected,
                  child: ButtonWidget(
                    text: "编辑创意",
                    height: 44.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                    border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceWarning.color),
                    borderRadius: 8.wMin,
                    fontSize: 18.wMin,
                    fontColor: AppTheme.cSurfaceWarning.color,
                    sclae: 1.01,
                    onTap: () {
                      controller.editHandwrittenCreativity(context, item);
                    },
                  ),
                ),

                Visibility(
                  visible: item.isSelected,
                  child: Container(
                    margin: EdgeInsets.only(left: 8.wMin),
                    child: ButtonWidget(
                      text: "取消选择",
                      height: 44.wMin,
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                      color: AppTheme.cSurfaceTertiary.color.withValues(alpha: 0.2),
                      border: Border.all(width: 1.wMin, color: AppTheme.cBorderTertiary.color),
                      borderRadius: 8.wMin,
                      fontSize: 18.wMin,
                      fontColor: AppTheme.cTextSecondary.color,
                      sclae: 1.01,
                      onTap: () {
                        controller.cancelSelectHandwrittenCreativity(item);
                      },
                    ),
                  ),
                ),
              ],
            ),



          ],
        ),
      ),
    );
  }

}



class ManageCreateVocabularyScriptPathCWidget extends StatelessWidget {
  final ManageCreateVocabularyScriptController controller;
  const ManageCreateVocabularyScriptPathCWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.05),
        border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget(),
          SizedBox(height: 10.wMin),
          _buildListWidget(context),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    
        ManageTagFS16Widget(
          tag: "路径C",
          bgColor: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
          fontColor: AppTheme.cSurfaceBrand.color,
          borderRadius: 999,
        ),
    
        SizedBox(height: 8.wMin),
    
        SelectableText(
          "只选题材，直接生成",
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        
      ],
    );
  }


  Widget _buildListWidget(BuildContext context){
    return Obx((){
      return GridView.builder(
        itemCount: controller.scriptGenreList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.wMin,
          crossAxisSpacing: 12.wMin,
          mainAxisExtent: 120.wMin,
        ),
        itemBuilder: (context, index) {
          return _buildSelectGenreItemWidget(controller.scriptGenreList[index]);
        },
      );
    });
  }

  Widget _buildSelectGenreItemWidget(ManageScriptGenreEntity data){
    return TapScaleWidget(
      onTap: () {
        controller.selectGenre(data);
      },
      sclae: 1,
      backColor: AppTheme.cSurfaceSecondary.color,
      borderRadius: 16.wMin,
      child: TapScaleLongHoverWidget(
        onLongPressStart: (details, ctx) {
          ManageCreateVocabularyScriptShowTip.showTips(ctx: ctx, curriculumGuidance: data.curriculumGuidance);
        },
        onLongPressEnd: (details, context) {
          BotToast.cleanAll();
        },
        onEnter: (event, ctx) {
          ManageCreateVocabularyScriptShowTip.showTips(ctx: ctx, curriculumGuidance: data.curriculumGuidance);
        },
        onExit: (event, context) {
          BotToast.cleanAll();
        },
        child: Obx((){
          bool selected = controller.selectGenreNids.contains(data.nid);
          return Container(
            padding: EdgeInsets.all(16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: Colors.transparent,
              border: Border.all(
                width: 1.wMin, 
                color: selected ? const Color(0xff00A6F4) : AppTheme.cBorderPrimary.color,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.name?.firstWhereOrNull((e) => e?.lang == "zh")?.text??"",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18.wMin,
                              color: AppTheme.cTextPrimary.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            data.nid??"",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: AppTheme.cTextSecondary.color,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
        
                    ButtonWidget(
                      text: "已存在剧本数量: ${data.existCount??0}",
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
                      color: AppTheme.cSurfaceSuccess.color.withValues(alpha: (data.existCount??0) == 0 ? 0.1 : 0.2),
                      fontColor: (data.existCount??0) == 0 ? AppTheme.cTextTertiary.color : AppTheme.cSurfaceSuccess.color,
                      fontSize: 14.wMin,
                    ),
        
                    SizedBox(width: 6.wMin),
        
                    ButtonWidget(
                      text: "${data.difficulty?.min??0}-${data.difficulty?.max??0}",
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
                      color: const Color(0xff00A6F4).withValues(alpha: 0.2),
                      fontColor: const Color(0xff00A6F4),
                      fontSize: 14.wMin,
                    ),
                  ],
                ),
                SizedBox(height: 4.wMin),
                Text(
                  data.description?.firstWhereOrNull((e) => e?.lang == "zh")?.text??"",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }


}


class ManageCreateVocabularyScriptShowTip{

  static void showTips({
    required BuildContext ctx, 
    required ManageScriptGenreEntityCurriculumGuidance? curriculumGuidance,
  }) {
    if(curriculumGuidance == null) return;
    BotToast.showAttachedWidget(
      targetContext: ctx,
      backgroundColor: Colors.transparent,
      onlyOne: true,
      preferDirection: PreferDirection.topCenter,
      verticalOffset: 4.wMin,
      attachedBuilder: (cancelFunc) {
        return Container(
          padding: EdgeInsets.all(16.wMin),
          constraints: BoxConstraints(
            minWidth: 780.wMin,
            maxWidth: 780.wMin,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.wMin),
            color: AppTheme.cSurfaceQuaternary.color,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: curriculumGuidance.whyItFits != null,
                child: SelectableText(
                  "why_it_fits: ${curriculumGuidance.whyItFits??''}",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Visibility(
                visible: curriculumGuidance.whyItFits != null,
                child: Container(
                  margin: EdgeInsets.only(top: 12.wMin),
                  child: SelectableText(
                    "generalization_rule: ${curriculumGuidance.generalizationRule??''}",
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
