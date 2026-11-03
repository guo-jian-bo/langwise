
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';


import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/enum/enum.dart';
import '../../../../../../../../theme/theme.dart';
import '../../../../../../../routes/routes.dart';
import '../../../../../common/commons.dart';
import '../../../../../dialog/select_clmu_dialog.dart';
import '../../../common/manage_select_persona_variants_dialog.dart';
import '../bindings/manage_create_unit_script_binding.dart';
import '../controllers/manage_create_unit_script_controller.dart';
import 'manage_create_unit_script_path_widget.dart';
import 'manage_script_knowledge_table_widget.dart';

class ManageCreateUnitScriptView extends GetView<ManageCreateUnitScriptController> {
  final String tagText;
  const ManageCreateUnitScriptView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CREATE_UNIT_SCRIPT}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageCreateUnitScriptView(tagText: tag),
      binding: ManageCreateUnitScriptBinding(tag: tag),
      routeName: Routes.MANAGE_CREATE_UNIT_SCRIPT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      showCollectButton: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 150.wMin,
              right: 150.wMin,
              top: 24.wMin,
              bottom: 200.wMin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSelectUnitWidget(context),
                _buildSelectCoreKnowledgeWidget(context),
                _buildSceneAreaWidget(),
                ManageCreateUnitScriptPathWidget(controller: controller),
                _buildCharacterVariantsWidget(context),
              ],
            ),
          ),
          Positioned(
            right: 8.wMin,
            bottom: 40.wMin,
            child: _buildToolButtonsWidget(),
          ),
        ],
      ),
    );
  }

  /// 工具按钮
  Widget _buildToolButtonsWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        ButtonWidget(
          text: "生成单元剧本",
          padding: EdgeInsets.symmetric(horizontal: 10.wMin),
          height: 44.wMin,
          color: const Color(0xff4ADE80).withValues(alpha: 0.2),
          border: Border.all(width: 1.wMin, color: const Color(0xff4ADE80)),
          borderRadius: 8.wMin,
          fontSize: 18.wMin,
          fontColor: const Color(0xff4ADE80),
          sclae: 1.03,
          onTap: OptimizeUtils.noneThrottle(() {
            controller.createScript();
          }, 300),
        ),
      ],
    );
  }

  /// 选择单元
  Widget _buildSelectUnitWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        children: [

          Container(
            margin: EdgeInsets.symmetric(horizontal: 24.wMin),
            child: Row(
              children: [
                Text(
                  "1. 选择单元",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                
              ],
            ),
          ),

          SizedBox(height: 12.wMin),
          TapScaleWidget(
            onTap: () {
              controller.selectCLMU(context);
            },
            sclae: 1,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 24.wMin),
              padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                color: const Color(0xff4ADE80).withValues(alpha: 0.1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx((){
                      String showText = "请选择 课程 > 等级 > 模块 > 单元";
                      SelectCLMUReslut clmu = controller.selectCLMUData.value;
                      if(clmu.unitId != null){
                        showText = "已选 ${clmu.courseName??''} > ${clmu.levelName??''} > ${clmu.moduleName??''} > ${clmu.unitName??''}";
                      }
                      return Text(
                        showText,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: clmu.unitId == null ? AppTheme.cTextSecondary.color : const Color(0xff4ADE80),
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }),
                  ),
                  SvgPicture.asset(
                    "assets/svg/public/icon_w_arrow_right.svg",
                    width: 28.wMin,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.wMin),
          Obx((){
            return Visibility(
              visible: controller.unitList.isNotEmpty,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 12.wMin),
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(
                    spacing: 16.wMin,
                    children: List.generate(controller.unitList.length, (index){
                      return _buildSelectUnitItemWidget(controller.unitList[index]);
                    }),
                  ),
                ),
              ),
            );
          }),

        ],
      ),
    );
  }

  Widget _buildSelectUnitItemWidget(NewUnitResponseEntity data){
    return TapScaleWidget(
      onTap: () {
        controller.selectUnit(data);
      },
      sclae: 1.01,
      child: Container(
        width: 430.wMin,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    data.name??"",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Obx((){
                  bool selected = controller.selectCLMUData.value.unitId == data.uid;
                  return SvgPicture.asset(
                    selected ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
                    width: 28.wMin,
                    colorFilter: !selected ? ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn) : null,
                  );
                }),
              ],
            ),
            SizedBox(height: 6.wMin),
            Text(
              data.description??"",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary.color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
            // SizedBox(height: 6.wMin),
            // Text(
            //   "适合 A1-A2，自然世界主题，偏观察描述。",
            //   maxLines: 2,
            //   overflow: TextOverflow.ellipsis,
            //   style: TextStyle(
            //     fontSize: 18.wMin,
            //     color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
            //     fontWeight: FontWeight.w400,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  /// 选择核心知识点
  Widget _buildSelectCoreKnowledgeWidget(BuildContext context){
    return Container(
      margin: EdgeInsets.only(top: 16.wMin),
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "2. 选择核心知识点",
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Obx((){
                return Text(
                  "已选择${controller.selectknowledgeIds.length}",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 12.wMin),
          Obx((){
            if(controller.selectCLMUData.value.unitId == null){
              return NotDataWidget(
                buttonText: "选择单元",
                onButton: () {
                  controller.selectCLMU(context);
                },
              );
            }
            if(controller.knowledgeList.isEmpty){
              return const NotDataWidget(
                message: "暂无知识点数据",
              );
            }
            return ManageScriptKnowledgeTableWidget(
              knowledgeList: controller.knowledgeList.toList(),
              selectknowledgeIds: controller.selectknowledgeIds.toSet(),
              onCheck: (data) {
                controller.selectUnitKnowledge(data);
              },
            );
          }),
          
        ],
      ),
    );
  }

  /// 故事场景地区
  Widget _buildSceneAreaWidget(){
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
          Text(
            "3. 故事场景地区",
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "这个参数会写入 `locale`，用于约束故事发生的文化与生活语境。",
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 16.wMin),

          GridView.builder(
            itemCount: LanguageCode.values.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.wMin,
              crossAxisSpacing: 12.wMin,
              mainAxisExtent: 100.wMin,
            ),
            itemBuilder: (context, index) {
              return _buildSceneAreaItemWidget(LanguageCode.values[index]);
            },
          )

        ],
      ),
    );
  }

  Widget _buildSceneAreaItemWidget(LanguageCode data){
    return TapScaleWidget(
      onTap: () {
        controller.selectSceneAreaFun(data);
      },
      sclae: 1,
      backColor: AppTheme.cSurfaceSecondary.color,
      borderRadius: 16.wMin,
      child: Obx((){
        bool selected = controller.selectSceneArea.value == data;
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
                    child: Text(
                      data.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ButtonWidget(
                    text: data.value,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
                    color: const Color(0xff00A6F4).withValues(alpha: 0.2),
                    fontColor: const Color(0xff00A6F4),
                    fontSize: 14.wMin,
                  ),
                ],
              ),
              // SizedBox(height: 4.wMin),
              // Text(
              //   "更偏中国日常生活与公共空间语境。",
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              //   style: TextStyle(
              //     fontSize: 16.wMin,
              //     color: AppTheme.cTextSecondary.color,
              //     fontWeight: FontWeight.w400,
              //   ),
              // ),
            ],
          ),
        );
      }),
    );
  }


  /// 指定角色变体
  Widget _buildCharacterVariantsWidget(BuildContext context){
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
          Row(
            children: [
              Text(
                "指定角色变体",
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Obx((){
                return Text(
                  "已选择${controller.selectPersonaVariant.length}",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 12.wMin),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx((){
              return Row(
                spacing: 24.wMin,
                children: [
                  ...List.generate(controller.selectPersonaVariant.length, (index){
                    return _buildCastMembersItemWidget(controller.selectPersonaVariant[index], index);
                  }),
                  _buildCastMembersAddWidget(context),
                ],
              );
            }),
          ),
          


        ],
      ),
    );
  }
  
  Widget _buildCastMembersItemWidget(ManageSelectPersonaVariantsReslut data, int index){

    String imageUrl = data.variant.images?.firstWhereOrNull((e) => e?.isCore == true)?.imageUrl??"";

    return SizedBox(
      width: 220.wMin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220.wMin,
            height: 220.wMin,
            child: CachedImageWidget(
              imageUrl,
              borderRadius: BorderRadius.circular(6.wMin),
              errorWidget: buildEmptyWidget(),
              placeholder: buildEmptyWidget(),
            ),
          ),
          SizedBox(height: 4.wMin),
          Text(
            data.variant.name??"",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.wMin),
          Text(
            data.variant.nid??"",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          TapScaleWidget(
            onTap: () {
              controller.removeVariant(index);
            },
            sclae: 1.1,
            child: Container(
              padding: EdgeInsets.all(4.wMin),
              child: Text(
                "移除",
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: AppTheme.cSurfaceError.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastMembersAddWidget(BuildContext context){
    return TapScaleWidget(
      onTap: () {
        controller.showVariants(context);
      },
      sclae: 1.01,
      child: DottedBorder(
        radius: Radius.circular(4.wMin),
        borderType: BorderType.RRect,
        padding: EdgeInsets.zero,
        color: AppTheme.cBorderSecondary.color,
        dashPattern: const [3, 3],
        child: Container(
          width: 220.wMin,
          height: 300.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: AppTheme.cSurfaceSecondary.color,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10.wMin,
            children: [
              SvgPicture.asset(
                "assets/svg/public/icon_add.svg",
                width: 40.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
              ),
              Text(
                "添加角色",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
