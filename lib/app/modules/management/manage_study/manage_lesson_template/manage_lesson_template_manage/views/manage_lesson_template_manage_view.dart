import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:lib_common/components/widget/wise_switch.dart';
import 'package:reorderables/reorderables.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../bindings/manage_lesson_template_manage_binding.dart';
import '../controllers/manage_lesson_template_manage_controller.dart';

class ManageLessonTemplateManageView extends GetView<ManageLessonTemplateManageController> {
  final String tagText;
  const ManageLessonTemplateManageView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_LESSON_TEMPLATE_MANAGE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageLessonTemplateManageView(tagText: tag),
      binding: ManageLessonTemplateManageBinding(tag: tag),
      routeName: Routes.MANAGE_LESSON_TEMPLATE_MANAGE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildGridAddWidget() {
      return TapScaleWidget(
        onTap: () {
          controller.selectQuizTemplate(context);
        },
        sclae: 1.02,
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(10.wMin),
          dashPattern: [6.wMin, 5.wMin],
          padding: EdgeInsets.zero,
          strokeCap: StrokeCap.round,
          strokeWidth: 2.wMin,
          color: const Color(0xff4B5268),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xff22293C),
              borderRadius: BorderRadius.circular(10.wMin),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/svg/manage/icon_add_blue.svg",
                  height: 80.wMin,
                ),
                SizedBox(height: 20.wMin),
                Text(
                  "绑定题目模版",
                  style: TextStyle(
                    fontSize: 22.wMin,
                    color: const Color(0xffACB4C0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = (constraints.maxWidth - 96.wMin) / 2 - 15.wMin;
        return ManageScaffold(
          backgroundColor: const Color(0xff050916),
          resizeToAvoidBottomInset: false,
          body: Obx(() {
            return SizedBox(
              width: constraints.maxWidth,
              child: ReorderableWrap(
                spacing: 24.wMin,
                runSpacing: 24.wMin,
                padding: EdgeInsets.all(48.wMin),
                enableReorder: ManageAuthUtils.isAuth(ManageAuthCode.courseLessonTemplateConfigSort),
                header: !ManageAuthUtils.isAuth(ManageAuthCode.courseLessonTemplateConfigBindV2) ? null : [
                  SizedBox(
                    width: width,
                    child: AspectRatio(
                      aspectRatio: 720 / 313,
                      child: buildGridAddWidget(),
                    ),
                  ),
                ],
                onReorder: (oldIndex, newIndex) {
                  controller.onReorder(oldIndex, newIndex);
                },
                children: List.generate(controller.quizList.length, (index) {
                  return SizedBox(
                    width: width,
                    child: AspectRatio(
                      aspectRatio: 720 / 313,
                      child: _ManageLessonTemplateManageQuizWidget(
                        data: controller.quizList[index],
                        onTap: () {
                          if (!ManageAuthUtils.isAuth(ManageAuthCode.courseLessonTemplateConfigEdit)) {
                            return;
                          }
                          controller.showQuizDialog(context, controller.quizList[index], index);
                        },
                        onDelete: () {
                          controller.deleteQuiz(context, controller.quizList[index]);
                        },
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ManageLessonTemplateManageQuizWidget extends StatefulWidget {
  final ManageLessonQuizTemplateEntity data;
  final void Function()? onTap;
  final void Function()? onDelete;
  const _ManageLessonTemplateManageQuizWidget({required this.data, this.onTap, this.onDelete});

  @override
  State<_ManageLessonTemplateManageQuizWidget> createState() => __ManageLessonTemplateManageQuizWidgetState();
}

class __ManageLessonTemplateManageQuizWidgetState extends State<_ManageLessonTemplateManageQuizWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ManageQuizTemplateEntityTemplate? template = widget.data.template;
    ManageLessonTemplateEntityDatasExerciseConfigs? config = widget.data.config;

    String stemName = QuizDeformationUtils.typeNameMap[config?.stemDisplay ?? ""] ?? "";
    String optionName = QuizDeformationUtils.typeNameMap[config?.optionDisplay ?? ""] ?? "";
    String inputModel = QuizDeformationUtils.typeNameMap[config?.inputMode ?? ""] ?? "";
    String breakdownLevel = QuizDeformationUtils.typeNameMap[config?.breakdownLevel ?? ""] ?? "";

    Widget itemText(String text) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 16.wMin,
          color: const Color(0xffACB4C0),
          fontWeight: FontWeight.w400,
        ),
      );
    }

    Widget itemSwitcher(String name, bool value) {
      return Container(
        margin: EdgeInsets.only(top: 1.5.wMin),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            itemText(name),
            Row(
              children: [
                SizedBox(
                  height: 24.wMin,
                  child: IgnorePointer(
                    child: WiseSwitch(
                      value,
                      (value) {},
                      activeColor: Colors.white,
                      inactiveColor: Colors.white,
                      activeFrameColor: const Color(0xff2FB2FF),
                      activeTrackColor: const Color(0xff2FB2FF),
                      inactiveFrameColor: const Color(0xff00436D),
                      inactiveTrackColor: const Color(0xff00436D),
                    ),
                  ),
                ),
                SizedBox(width: 8.wMin),
                itemText(value ? "开启" : "关闭"),
              ],
            ),
          ],
        ),
      );
    }

    return TapScaleWidget(
      onTap: widget.onTap,
      sclae: 1.02,
      child: Container(
        padding: EdgeInsets.all(8.wMin),
        decoration: BoxDecoration(
          color: const Color(0xff22293C),
          borderRadius: BorderRadius.circular(10.wMin),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 55,
              child: Container(
                height: double.infinity,
                alignment: Alignment.topLeft,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template?.name ?? '',
                            style: TextStyle(
                              fontSize: 18.wMin,
                              color: const Color(0xffEBEFF5),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight / 6.5,
                            ),
                            child: Text(
                              widget.data.description ?? "",
                              style: TextStyle(
                                fontSize: 16.wMin,
                                color: const Color(0xffACB4C0),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.wMin),
                          QuizPublicQuizWidget(
                            key: ValueKey(widget.data.exercise?.toJson().toString()),
                            borderRadius: 8.wMin,
                            data: widget.data.exercise,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 8.wMin),
            Expanded(
              flex: 45,
              child: Container(
                padding: EdgeInsets.all(8.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: const Color(0xff1E2436),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "配置项信息",
                          style: TextStyle(
                            fontSize: 16.wMin,
                            color: const Color(0xffEBEFF5),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        ManageAuthBoxWidget(
                          authCodes: const [ManageAuthCode.courseLessonTemplateEdit],
                          child: TapScaleWidget(
                            onTap: widget.onDelete,
                            child: Container(
                              color: Colors.transparent,
                              padding: EdgeInsets.all(8.wMin),
                              child: Icon(Icons.clear, color: const Color(0xffBAC0CC), size: 26.wMin),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(height: 1.wMin, color: const Color(0xff444B5F)),
                    SizedBox(height: 4.wMin),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                itemText("configId"),
                                SelectableText(
                                  "${widget.data.config?.uid ?? ""}",
                                  style: TextStyle(
                                    fontSize: 16.wMin,
                                    color: const Color(0xffEBEEF3),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Visibility(
                              visible: stemName != "" && optionName != "",
                              child: Container(
                                margin: EdgeInsets.only(top: 1.5.wMin),
                                width: double.infinity,
                                child: Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    itemText("显示模式"),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "题干=$stemName,选项=$optionName",
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 16.wMin,
                                          color: const Color(0xffEBEEF3),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: template?.optionQuantityScope != null,
                              child: Container(
                                margin: EdgeInsets.only(top: 1.5.wMin),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    itemText("选项数"),
                                    Text(
                                      "${config?.optionCount ?? ""}",
                                      style: TextStyle(
                                        fontSize: 16.wMin,
                                        color: const Color(0xffEBEEF3),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: inputModel != "",
                              child: Container(
                                margin: EdgeInsets.only(top: 1.5.wMin),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    itemText("输入方式"),
                                    Text(
                                      inputModel,
                                      style: TextStyle(
                                        fontSize: 16.wMin,
                                        color: const Color(0xffEBEEF3),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: breakdownLevel != "",
                              child: Container(
                                margin: EdgeInsets.only(top: 1.5.wMin),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    itemText("拆分等级"),
                                    Text(
                                      breakdownLevel,
                                      style: TextStyle(
                                        fontSize: 16.wMin,
                                        color: const Color(0xffEBEEF3),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: template?.allowPreTeaching != null,
                              child: itemSwitcher("预先学习", config?.preTeaching ?? false),
                            ),
                            Visibility(
                              visible: template?.stemAudioScope != null,
                              child: itemSwitcher("题干发音", config?.stemAudio ?? false),
                            ),
                            Visibility(
                              visible: template?.optionAudioScope != null,
                              child: itemSwitcher("选项发音", config?.optionAudio ?? false),
                            ),
                            Visibility(
                              visible: template?.questionAudioScope != null,
                              child: itemSwitcher("问题发音", config?.questionAudio ?? false),
                            ),
                            Visibility(
                              visible: template?.allowFollowSentence != null,
                              child: itemSwitcher("逐句显示", config?.followSentence ?? false),
                            ),
                            Visibility(
                              visible: template?.hintsScope != null,
                              child: itemSwitcher("是否高亮", config?.highlight ?? false),
                            ),
                          ],
                        ),
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
