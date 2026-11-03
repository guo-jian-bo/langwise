import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../common/manage_button.dart';
import '../../common/manage_title_input_widget.dart';
import 'controller.dart';

class ManageCreatePhraseManager {
  static Future<EnPhraseEntity?> show({
    required BuildContext context,
    final String? content,
    final String? definition,
    bool showSelectKnowledgeAddButton = false,
    void Function(int index)? onTap,
  }) async {
    return await showCupertinoDialog<EnPhraseEntity?>(
      context: context,
      builder: (context) {
        return ManageCreatePhraseView(
          content: content,
          definition: definition,
          showSelectKnowledgeAddButton: showSelectKnowledgeAddButton,
        );
      },
    );
  }
}

class ManageCreatePhraseView extends GetView<ManageCreatePhraseController> {
  final String? content;
  final String? definition;
  final bool showSelectKnowledgeAddButton;

  const ManageCreatePhraseView(
      {super.key, this.content, this.definition, this.showSelectKnowledgeAddButton = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ManageCreatePhraseController(this.content, this.definition, showSelectKnowledgeAddButton),
        id: "manage_create_phrase",
        builder: (_) {
          return LayoutBuilder(builder: (context, constraints) {
            return Scaffold(
              backgroundColor: const Color(0xff040712).withValues(alpha: 0.8),
              body: Center(
                child: Container(
                  width: 1080.ww,
                  height: 600.wh,
                  padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 24.wh),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.wMin),
                    border: Border.all(
                      color: const Color(0xff444B5F),
                      width: 1.wMin, // 边框宽度
                    ),
                    color: const Color(0xff181B25),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ManageTitleWidget(
                        title: "创建短语",
                        onCloseTap: () {
                          Get.back();
                        },
                      ),
                      Gaps.getHeight(35.wh),
                      _buildContentWidget(context),
                      Gaps.getHeight(24.wh),
                      _buildBottomWidget(),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  /// 主视图
  Widget _buildContentWidget(BuildContext context) {
    return Container(
      height: 400.wh,
      padding: EdgeInsets.symmetric(horizontal: 16.ww, vertical: 16.wh),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color(0xff22293C),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            ManageTitleInputWidget(
              title: "短语",
              hintText: '请填写短语(以空格分割)',
              required: true,
              controller: controller.wordController,
              readOnly: false,
            ),
            Gaps.getHeight(24.wh),
            ManageTitleInputWidget(
              title: "释义",
              hintText: '请填写释义',
              required: true,
              controller: controller.definitionController,
              readOnly: false,
            ),
            Gaps.getHeight(24.wh),
            ManageSelectWidget(
              title: "词性",
              hintText: '请选择词性',
              value: controller.posTitle,
              readOnly: false,
              required: true,
              options: controller.poses.map((element) => element.title ?? '').toList(),
              onChanged: (String value, int index) {
                controller.setPos(index);
              },
            ),
            // Gaps.getHeight(24.wh),
            // ManageSelectWidget(
            //   title: "语法形式",
            //   hintText: '请选择语法形式',
            //   value: controller.formTitle,
            //   readOnly: false,
            //   required: false,
            //   options: controller.forms.map((element) => element.title ?? '').toList(),
            //   onChanged: (String value, int index) {
            //     controller.setForm(index);
            //   },
            // ),
            // Gaps.getHeight(24.wh),
            // _buildExtraWidget(title: "选择语义"),
            // _buildSemanticWidget(context),
            // Gaps.getHeight(24.wh),
            // _buildTitleWidget("关联知识点"),
            // Gaps.getHeight(24.wh),
            // _buildKnowledgeWidget(context),
            // Gaps.getHeight(24.wh),
            // _buildTitleWidget("组成结构"),
            // if (controller.composeCells.isNotEmpty) Gaps.getHeight(24.wh),
            // _buildComposeListWidget(context),
            // Gaps.getHeight(24.wh),
            // _buildAddWidget(() {
            //   controller.addCompose(context);
            // }),
            // Gaps.getHeight(24.wh),
            // _buildTitleWidget("学习核心"),
            // if (controller.learnCoreCells.isNotEmpty) Gaps.getHeight(24.wh),
            // _buildLearnCoreListWidget(context),
            // Gaps.getHeight(24.wh),
            // _buildAddWidget(() {
            //   controller.addLearnCore(context);
            // }),
            // Gaps.getHeight(24.wh),
            // ManageSelectWidget(
            //   title: "上架状态",
            //   hintText: '请选择上架状态',
            //   value: controller.newAccessName,
            //   readOnly: false,
            //   required: true,
            //   options: StaticData.getOnOffShelfForCreateOrEditNames,
            //   onChanged: (String value, int index) {
            //     controller.setAccess(index);
            //   },
            // ),
            // Gaps.getHeight(24.wh),
          ],
        ),
      ),
    );
  }

  // title
  // Widget _buildTitleWidget(String title) {
  //   return Row(
  //     children: [
  //       Text(
  //         title,
  //         style: TextStyle(
  //           fontSize: 14.wMin,
  //           color: const Color(0xffEBEEF3),
  //           fontWeight: FontWeight.w400,
  //         ),
  //       ),
  //       Gaps.getWidth(2.ww),
  //       Expanded(
  //         child: Divider(
  //           height: 1.wMin,
  //           color: const Color(0xff4B5268),
  //         ),
  //       )
  //     ],
  //   );
  // }

  // 关联知识点
  // Widget _buildKnowledgeWidget(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     height: 245,
  //     alignment: Alignment.centerLeft,
  //     child: GridView.builder(
  //       // 缓存键
  //       key: const PageStorageKey<String>("knowledge"),
  //       itemCount: controller.relevanceKnowledgeList.length + 1,
  //       padding: EdgeInsets.zero,
  //       physics: const ClampingScrollPhysics(),
  //       scrollDirection: Axis.horizontal,
  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: 1,
  //         mainAxisSpacing: 12.wMin,
  //         crossAxisSpacing: 0,
  //         childAspectRatio: 245 / 180,
  //       ),
  //       itemBuilder: (BuildContext c, int index) {
  //         if (index == 0) {
  //           return buildAddButton(context, "添加知识点", () {
  //             controller.toRelevanceKnowledge(context, controller.relevanceKnowledgeList);
  //           });
  //         }
  //         final Knowledge knowledge = controller.relevanceKnowledgeList[index - 1];
  //         return KnowledgeItemWidget(
  //           key: PageStorageKey(knowledge.uid),
  //           index: index - 1,
  //           knowledge: knowledge,
  //           showDelIcon: true,
  //           onTap: (int i, Knowledge k) {
  //             if (k.audioUrl != null && k.audioUrl!.isNotEmpty) {
  //               PlayAudioUtils.instance.playSingle(k.audioUrl!);
  //             }
  //           },
  //           onDeleteTap: (int i, Knowledge k) {
  //             controller.removeRelevanceKnowledge(i);
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }

  // 组成结构列表
  // Widget _buildComposeListWidget(BuildContext context) {
  //   return ListView.separated(
  //     shrinkWrap: true,
  //     padding: EdgeInsets.zero,
  //     physics: const NeverScrollableScrollPhysics(),
  //     itemCount: controller.composeCells.length,
  //     separatorBuilder: (_, i) => SizedBox(height: 12.wh),
  //     itemBuilder: (_, index) => ComposeCellWidget(
  //       key: ValueKey(controller.composeCells[index].uuid),
  //       // 使用UUID作为key
  //       index: index,
  //       data: controller.composeCells[index],
  //       onDelete: (int i) {
  //         controller.removeCompose(i);
  //       },
  //       onSelectKnowledge: (i, knowledge) {
  //         controller.toAddKnowledge(context, i, controller.knowledgeList);
  //       },
  //     ),
  //   );
  // }

  // 学习核心列表
  // Widget _buildLearnCoreListWidget(BuildContext context) {
  //   return ListView.separated(
  //     shrinkWrap: true,
  //     padding: EdgeInsets.zero,
  //     physics: const NeverScrollableScrollPhysics(),
  //     itemCount: controller.learnCoreCells.length,
  //     separatorBuilder: (_, i) => SizedBox(height: 12.wh),
  //     itemBuilder: (_, index) => LearnCoreCellWidget(
  //       key: ValueKey(controller.learnCoreCells[index].uuid),
  //       // 使用UUID作为key
  //       index: index,
  //       data: controller.learnCoreCells[index],
  //       onDelete: (int i) {
  //         controller.removeLearnCore(i);
  //       },
  //     ),
  //   );
  // }

  // 添加按钮
  // Widget _buildAddWidget(VoidCallback onTap) {
  //   return TapScaleWidget(
  //     onTap: () {
  //       onTap.call();
  //     },
  //     sclae: 1.03,
  //     child: DottedBorder(
  //       radius: Radius.circular(8.wMin),
  //       borderType: BorderType.RRect,
  //       padding: EdgeInsets.zero,
  //       color: const Color(0xff444B5F),
  //       dashPattern: const [1, 2],
  //       strokeWidth: 1.wMin,
  //       child: Container(
  //         alignment: Alignment.center,
  //         height: 48.wh,
  //         child: SvgPicture.asset(
  //           "assets/svg/manage/icon_add.svg",
  //           height: 22.ww,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // 语义
  // Widget _buildSemanticWidget(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     height: 188,
  //     alignment: Alignment.centerLeft,
  //     child: ListView.builder(
  //       // 缓存键
  //       key: const PageStorageKey<String>("semantic"),
  //       itemCount: controller.semantics.length + 1,
  //       padding: EdgeInsets.zero,
  //       physics: const ClampingScrollPhysics(),
  //       scrollDirection: Axis.horizontal,
  //       itemBuilder: (BuildContext c, int index) {
  //         if (index == 0) {
  //           return AspectRatio(
  //               aspectRatio: 160 / 188,
  //               child: buildAddButton(context, "添加语义", () {
  //                 controller.toAddSemantic(context, controller.semantics);
  //               }));
  //         }
  //         final EnEntitySemantics entitySemantics = controller.semantics[index - 1];
  //         return CombinedSemanticsWidget(
  //           key: PageStorageKey(entitySemantics.uid),
  //           entitySemantics: entitySemantics,
  //           index: index - 1,
  //           onDeleteTap: (int i, EnEntitySemantics semantics) {
  //             controller.onRemoveSemantic(semantics);
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }

  // Widget _buildExtraWidget({required String title}) {
  //   return Container(
  //     margin: EdgeInsets.only(bottom: 12.wh),
  //     alignment: Alignment.centerLeft,
  //     child: Text.rich(
  //       TextSpan(
  //         children: [
  //           TextSpan(
  //             text: title,
  //             style: TextStyle(
  //               fontSize: 14.wMin,
  //               color: const Color(0xffEBEEF3),
  //               fontWeight: FontWeight.w400,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // 添加知识点
  Widget buildAddButton(BuildContext context, String title, VoidCallback onTap) {
    return TapScaleWidget(
      onTap: OptimizeUtils.noneThrottle(() {
        onTap.call();
      }, 100),
      sclae: 1.03,
      child: DottedBorder(
        radius: Radius.circular(8.wMin),
        borderType: BorderType.RRect,
        padding: EdgeInsets.zero,
        color: const Color(0xff444B5F),
        dashPattern: const [1, 2],
        strokeWidth: 1.wMin,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildImage(Assets.managerAdd, width: 40.wMax, height: 40.wMax),
              Gaps.getHeight(10.wh),
              Text(
                title,
                style: TextStyleExtension.ts_12_w400_ACB4C0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageButton(
          text: "取消",
          width: 80.ww,
          height: 40.wh,
          borderColor: const Color(0xff666F8D),
          style: TextStyle(
            fontSize: 14.wMin,
            color: const Color(0xffEBEEF3),
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 11.ww),
        ManageButton(
          text: "确定",
          width: 80.ww,
          height: 40.wh,
          color: !controller.uploadButtonFlag ? const Color(0xff353E5C) : const Color(0xff2388FF),
          borderColor: Colors.transparent,
          style: TextStyle(
            fontSize: 14.wMin,
            color: controller.uploadButtonFlag ? const Color(0xffEBEEF3) : const Color(0xffACB4C0),
            fontWeight: FontWeight.w400,
          ),
          onTap: !controller.uploadButtonFlag
              ? null
              : OptimizeUtils.noneThrottle(() {
                  controller.onCreatePhrase();
                }, 100),
        ),
      ],
    );
  }
}
