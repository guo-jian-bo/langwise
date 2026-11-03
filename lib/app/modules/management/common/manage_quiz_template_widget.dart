

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/components/widget/wise_switch.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';

class ManageQuizTemplateWidget extends StatefulWidget {
  final ManageLessonQuizTemplateEntity data;
  final bool selected;
  final void Function()? onTap;
  /// 是否显示知识点下有没有这个配置的题目
  final bool showIsExistExercise;

  const ManageQuizTemplateWidget({
    super.key, 
    this.onTap,
    this.selected = false,
    required this.data,
    this.showIsExistExercise = false,

  });

  @override
  State<ManageQuizTemplateWidget> createState() => __ManageQuizTemplateWidgetState();
}

class __ManageQuizTemplateWidgetState extends State<ManageQuizTemplateWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ManageLessonTemplateEntityDatasExerciseConfigs? config = widget.data.config;
    String stemDisplay = QuizDeformationUtils.typeNameMap[config?.stemDisplay ?? ""] ?? "";
    String optionDisplay = QuizDeformationUtils.typeNameMap[config?.optionDisplay ?? ""] ?? "";
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

    Widget itemRowText(String name, String value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          itemText(name),
          Container(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.wMin,
                color: const Color(0xffEBEEF3),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      );
    }

    Widget itemSwitcher(String name, bool value) {
      return Container(
        margin: EdgeInsets.only(top: 8.wMin),
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
      sclae: 1.01,
      child: Container(
        width: 416.wMin,
        height: 480.wMin,
        padding: EdgeInsets.symmetric(vertical: 15.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(width: 1.wMin, color: const Color(0xff4B5268)),
          color: const Color(0xff22293C),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15.wMin),
              child: Row(
                children: [
                  Expanded(
                    child: AutoSizeText(
                      widget.data.template?.name ?? "",
                      maxLines: 1,
                      minFontSize: 6,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: const Color(0xffEBEFF5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    widget.selected ? "assets/svg/manage/icon_radio.svg" : "assets/svg/manage/icon_unradio.svg",
                    key: ValueKey(widget.selected),
                    width: 24.wMin,
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.wMin),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 15.wMin,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: widget.data.description != null && widget.data.description!.isNotEmpty,
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
                    SizedBox(
                      width: double.infinity,
                      child: Stack(
                        children: [
                          QuizPublicQuizWidget(
                            data: widget.data.exercise,
                            borderRadius: 8.wMin,
                          ),
                          Positioned(
                            top: 6.wMin,
                            left: 6.wMin,
                            child: Visibility(
                              visible: widget.showIsExistExercise && widget.data.isExistExercise == true,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.wMin),
                                  color: Colors.green,
                                ),
                                child: Text(
                                  "有题目",
                                  style: TextStyle(
                                    fontSize: 16.wMin,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.wMin),
                    Visibility(
                      visible: stemDisplay != "" && optionDisplay != "",
                      child: itemRowText(
                        "显示模式",
                        "题干=$stemDisplay，选项=$optionDisplay",
                      ),
                    ),
                    Visibility(
                      visible: widget.data.template?.optionQuantityScope != null,
                      child: Container(
                        margin: EdgeInsets.only(top: 8.wMin),
                        child: itemRowText("选项数", "${widget.data.config?.optionCount ?? ''}"),
                      ),
                    ),
                    Visibility(
                      visible: widget.data.template?.inputModeScope != null,
                      child: Container(
                        margin: EdgeInsets.only(top: 8.wMin),
                        child: itemRowText("输入方式", inputModel),
                      ),
                    ),
                    Visibility(
                      visible: widget.data.template?.breakdownLevel != null,
                      child: Container(
                        margin: EdgeInsets.only(top: 8.wMin),
                        child: itemRowText("拆分等级", breakdownLevel),
                      ),
                    ),
                    Visibility(
                      visible: widget.data.template?.allowPreTeaching != null,
                      child: itemSwitcher("预先学习", config?.preTeaching ?? false),
                    ),
                    Visibility(
                      visible: widget.data.template?.stemAudioScope != null,
                      child: itemSwitcher("题干发音", config?.stemAudio ?? false),
                    ),
                    Visibility(
                      visible: widget.data.template?.optionAudioScope != null,
                      child: itemSwitcher("选项发音", config?.optionAudio ?? false),
                    ),
                    Visibility(
                      visible: widget.data.template?.questionAudioScope != null,
                      child: itemSwitcher("问题发音", config?.questionAudio ?? false),
                    ),
                    Visibility(
                      visible: widget.data.template?.allowFollowSentence != null,
                      child: itemSwitcher("逐句显示", config?.followSentence ?? false),
                    ),
                    Visibility(
                      visible: widget.data.template?.hintsScope != null,
                      child: itemSwitcher("是否高亮", config?.highlight ?? false),
                    ),
                    
                    Container(
                      margin: EdgeInsets.only(top: 4.wMin),
                      child: Text(
                        widget.data.lessonTemplateNames?.join(",  ") ?? "",
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: const Color(0xffBAC0CC),
                          fontWeight: FontWeight.w400,
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
