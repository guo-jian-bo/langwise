import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../../common/enum/enum.dart';
import '../../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../../theme/theme.dart';
import '../../../../../../../routes/routes.dart';
import '../../../../../common/commons.dart';
import '../../../common/manage_select_persona_variants_dialog.dart';
import '../bindings/manage_create_vocabulary_script_binding.dart';
import '../controllers/manage_create_vocabulary_script_controller.dart';
import 'manage_create_vocabulary_script_path_widget.dart';
import 'manage_script_knowledge_table_widget.dart';

class ManageCreateVocabularyScriptView extends GetView<ManageCreateVocabularyScriptController> {
  final String tagText;
  const ManageCreateVocabularyScriptView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CREATE_VOCABULARY_SCRIPT}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageCreateVocabularyScriptView(tagText: tag),
      binding: ManageCreateVocabularyScriptBinding(tag: tag),
      routeName: Routes.MANAGE_CREATE_VOCABULARY_SCRIPT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
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
                _buildSelectVocabularyWidget(),
                _buildSceneAreaWidget(),
                ManageCreateVocabularyScriptPathWidget(controller: controller),
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
          text: "生成词汇剧本",
          padding: EdgeInsets.symmetric(horizontal: 10.wMin),
          height: 44.wMin,
          color: const Color(0xff00a6f4).withValues(alpha: 0.2),
          border: Border.all(width: 1.wMin, color: const Color(0xff00a6f4)),
          borderRadius: 8.wMin,
          fontSize: 18.wMin,
          fontColor: const Color(0xff00a6f4),
          sclae: 1.03,
          onTap: OptimizeUtils.noneThrottle(() {
            controller.createScript();
          }, 300),
        ),
      ],
    );
  }

  /// 选择词汇
  Widget _buildSelectVocabularyWidget(){
    return Container(
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
                "1. 选择词汇",
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Obx((){
                return Text(
                  "已选择${controller.selectKnowledgeList.length}",
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
          Row(
            children: [
              Expanded(
                child: Row(
                  spacing: 16.wMin,
                  children: [
                    SizedBox(
                      width: 260.wMin,
                      child: CardInputWidget(
                        hintText: "uid",
                        controller: controller.uidSearchInput,
                        textInputAction: TextInputAction.search,
                        height: 54.wMin,
                        valueStyle: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w400,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextTertiary.color,
                          fontWeight: FontWeight.w400,
                        ),
                        onSubmitted: (value) {
                          controller.reloadKnowledgeList();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 260.wMin,
                      child: CardInputWidget(
                        hintText: "知识点",
                        controller: controller.contentSearchInput,
                        textInputAction: TextInputAction.search,
                        height: 54.wMin,
                        valueStyle: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w400,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextTertiary.color,
                          fontWeight: FontWeight.w400,
                        ),
                        onSubmitted: (value) {
                          controller.reloadKnowledgeList();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 260.wMin,
                      child: CardInputWidget(
                        hintText: "知识点(精确)",
                        controller: controller.contentSearchInputExact,
                        textInputAction: TextInputAction.search,
                        height: 54.wMin,
                        valueStyle: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w400,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextTertiary.color,
                          fontWeight: FontWeight.w400,
                        ),
                        onSubmitted: (value) {
                          controller.reloadKnowledgeList();
                        },
                      ),
                    ),
                    Obx((){
                      return Visibility(
                        visible: controller.currentKnowledgeType.value == KnowledgeTypeEnum.EN_WORD,
                        child: SizedBox(
                          width: 260.wMin,
                          child: CardInputWidget(
                            hintText: "音标",
                            controller: controller.pronunciationSearchInput,
                            textInputAction: TextInputAction.search,
                            height: 54.wMin,
                            valueStyle: TextStyle(
                              fontSize: 20.wMin,
                              color: AppTheme.cTextPrimary.color,
                              fontWeight: FontWeight.w400,
                            ),
                            hintStyle: TextStyle(
                              fontSize: 20.wMin,
                              color: AppTheme.cTextTertiary.color,
                              fontWeight: FontWeight.w400,
                            ),
                            onSubmitted: (value) {
                              controller.reloadKnowledgeList();
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(width: 16.wMin),
              Obx((){
                return AnimatedToggleSwitch<KnowledgeTypeEnum>.size(
                  current: controller.currentKnowledgeType.value,
                  values: controller.knowledgeTypeList.toList(),
                  indicatorSize: Size.fromWidth(150.wMin),
                  height: 54.wMin,
                  iconBuilder: (data){
                    return Text(
                      data.name,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                  borderWidth: 6.wMin,
                  iconAnimationType: AnimationType.onHover,
                  iconOpacity: 1,
                  selectedIconScale: 1,
                  animationDuration: const Duration(milliseconds: 200),
                  style: ToggleStyle(
                    borderColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(10.wMin),
                    backgroundColor: AppTheme.cSurfaceTertiary.color,
                    indicatorBorderRadius: BorderRadius.circular(8.wMin),
                    indicatorColor: AppTheme.cSurfaceQuaternary.color,
                  ),
                  onChanged: (data) {
                    controller.switchKnowledgeType(data);
                  },
                );
              }),
            ],
          ),
          SizedBox(height: 12.wMin),
          ManageScriptKnowledgeTableWidget(
            controller: controller,
          ),
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
            "2. 故事场景地区",
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

