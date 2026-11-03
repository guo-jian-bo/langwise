import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../utils/utils.dart';
import '../../common/manage_button.dart';
import 'controller.dart';

class ManageCreateKnowledgeManager {
  /// String? special 专项课类型
  /// topic = ipa
  static Future<dynamic> show({
    required BuildContext context,
    required int unitId,
    int? moduleId,
    String? language,
    void Function(int index)? onTap,
    String? specialty,
    ModuleResponseEntity? moduleResponseEntity,
  }) async {
    return await showCupertinoDialog<dynamic>(
      context: context,
      builder: (context) {
        return ManageCreateKnowledgeView(
          unitId: unitId,
          moduleId: moduleId,
          language: language,
          specialty: specialty,
          moduleResponseEntity: moduleResponseEntity,
        );
      },
    );
  }
}

class ManageCreateKnowledgeView extends GetView<ManageCreateKnowledgeController> {
  final int unitId;
  final int? moduleId;
  final String? language;
  final String? specialty;
  final ModuleResponseEntity? moduleResponseEntity;

  const ManageCreateKnowledgeView({
    super.key,
    required this.unitId,
    required this.moduleId,
    this.language,
    this.specialty,
    this.moduleResponseEntity,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ManageCreateKnowledgeController(unitId, moduleId, language, specialty),
        id: "manage_knowledge_list",
        builder: (_) {
          return Scaffold(
            backgroundColor: const Color(0xff040712).withValues(alpha: 0.8),
            body: Center(
              child: Container(
                width: 1080.ww,
                height: 880.wh,
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
                      title: "管理知识点列表",
                      onCloseTap: () {
                        Get.back();
                      },
                    ),
                    Gaps.getHeight(27.wh),
                    buildAddKnowledgeWidget(context),
                    if (controller.units.isEmpty) const Spacer(),
                    Gaps.getHeight(24.wh),
                    _buildBottomWidget(),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget buildAddKnowledgeWidget(BuildContext context) {
    return Expanded(
        child: Container(
      margin: EdgeInsets.only(left: 2.ww, right: 2.ww),
      alignment: Alignment.topLeft,
      child: Obx(() {
        return AnimatedReorderableGridView(
          items: controller.units,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          // 垂直
          scrollDirection: Axis.vertical,
          // 绑定滚动控制器
          controller: controller.scrollController,
          primary: false,
          physics: const AlwaysScrollableScrollPhysics(),
          enterTransition: [SlideInDown()],
          exitTransition: [SlideInUp()],
          insertDuration: const Duration(milliseconds: 200),
          removeDuration: const Duration(milliseconds: 200),
          dragStartDelay: const Duration(milliseconds: 200),
          sliverGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              // 每行5列
              crossAxisCount: 5,
              // 行间距
              mainAxisSpacing: 32.wMin,
              // 列间距
              crossAxisSpacing: 32.wMin,
              // 子组件宽高比
              childAspectRatio: 180 / 245),
          proxyDecorator: proxyDecorator,
          lockedItems: controller.units.cast<Knowledge>().where((element) => element.isAddKnowledge).toList(),
          onReorder: (int oldIndex, int newIndex) {
            controller.onReorderKnowledge(oldIndex, newIndex);
          },
          isSameItem: (a, b) => a.uid == b.uid,
          itemBuilder: (context, index) {
            final oldEntity = controller.units[index];
            if (index == 0) {
              return buildTabViewAdd(context, unitId, oldEntity.uid, controller.units);
            }
            return CopyKnowledgeItemWidget(
              key: ValueKey(oldEntity.uid),
              moduleResponseEntity: moduleResponseEntity,
              index: index,
              knowledge: oldEntity,
              showDelIcon: true,
              onTap: (int i, Knowledge e) {
                // 播放音频
                if (e.audioUrl != null && e.audioUrl!.isNotEmpty) {
                  PlayAudioUtils.instance.playSingle(e.audioUrl!);
                }
              },
              onRefreshImage: (int i, Knowledge e) {
                controller.toKnowledgeModeration(e);
              },
              onUpdateDefinition: (int i, Knowledge e) {
                controller.onUpdateDefinition(i, e);
              },
              onDeleteTap: (int i, Knowledge e) {
                // 在外部显示弹出菜单，降低代码耦合度
                OptionMenuManager.showAtKey(
                  context: context,
                  key: e.deleteButtonKey,
                  backgroundColor: const Color(0xff19213D),
                  items: [
                    OptionMenuItem(
                      title: "从知识点列表删除",
                      onTap: () {
                        // 从当前知识点列表删除，不影响知识库
                        ManageCreateKnowledgeController.to.onDeleteFromCurrentList(i, e);
                      },
                    ),
                    OptionMenuItem(
                      title: "从知识库里删除",
                      onTap: () {
                        // 从知识库彻底删除
                        ManageCreateKnowledgeController.to.onDeleteFromKnowledgeBase(i, e);
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      }),
    ));
  }

  Widget buildTabViewAdd(BuildContext context, int unitId, int knowledgeId, List<Knowledge> list) {
    return TapScaleWidget(
      key: ValueKey(knowledgeId),
      onTap: () {
        controller.toAddKnowledge(
          context,
          [...list],
          hidePhrase: specialty == SpecialtyEnum.EN_PHONICS,
          hideSentence: specialty == SpecialtyEnum.EN_PHONICS,
          hideText: specialty == SpecialtyEnum.EN_PHONICS,
          topic: moduleResponseEntity?.topic,
          moduleId: controller.moduleId,
        );
      },
      sclae: 1.01,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/svg/manage/icon_add.svg",
                height: 22.ww,
              ),
              SizedBox(height: 12.wMin),
              Text(
                "添加知识点",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: const Color(0xffEAECFF),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomWidget() {
    return Container(
      alignment: Alignment.centerRight,
      child: ManageButton(
        text: "确定",
        width: 80.ww,
        height: 40.wh,
        color: const Color(0xff353E5C),
        borderColor: Colors.transparent,
        style: TextStyle(
          fontSize: 14.wMin,
          color: const Color(0xffACB4C0),
          fontWeight: FontWeight.w400,
        ),
        onTap: OptimizeUtils.noneThrottle(() {
          Get.back(result: controller.units);
        }, 100),
      ),
    );
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          elevation: 0,
          color: const Color(0xff23283D),
          borderRadius: BorderRadius.circular(6.wMin),
          child: child,
        );
      },
      child: child,
    );
  }
}
