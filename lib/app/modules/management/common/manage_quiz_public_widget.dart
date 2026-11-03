import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:reorderables/reorderables.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../generated/assets.dart';
import '../utils/utils.dart';
import 'commons.dart';

class ManageQuizSettingButtons extends StatelessWidget {
  final String button0Text;
  final String button1Text;
  final Color button1Color;
  final Color button1BorderColor;
  final String button2Text;
  final String button3Text;
  final String button4Text;
  final void Function()? onButton0;
  final void Function()? onButton1;
  final void Function()? onButton2;
  final void Function()? onButton3;
  final void Function()? onButton4;
  const ManageQuizSettingButtons({
    super.key,
    this.button0Text = "取消",
    this.button1Text = "取消",
    this.button1Color = Colors.transparent,
    this.button1BorderColor = const Color(0xff767E95),
    this.button2Text = "完成",
    this.button3Text = "完成并继续添加",
    this.button4Text = "",
    this.onButton0,
    this.onButton1,
    this.onButton2,
    this.onButton3,
    this.onButton4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible: onButton0 != null,
            child: ButtonWidget(
              sclae: 1.05,
              text: button0Text,
              height: 40.wMin,
              borderRadius: 6.wMin,
              color: Colors.transparent,
              fontSize: 14.wMin,
              fontColor: const Color(0xffEBEEF3),
              padding: EdgeInsets.symmetric(horizontal: 24.wMin),
              border: Border.all(width: 1.wMin, color: const Color(0xff767E95)),
              onTap: onButton0,
            ),
          ),
          Visibility(
            visible: onButton1 != null,
            child: Container(
              margin: EdgeInsets.only(left: 13.wMin),
              child: ButtonWidget(
                sclae: 1.05,
                text: button1Text,
                height: 40.wMin,
                borderRadius: 6.wMin,
                color: button1Color,
                fontSize: 14.wMin,
                fontColor: const Color(0xffEBEEF3),
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                border: Border.all(width: 1.wMin, color: button1BorderColor),
                onTap: onButton1,
              ),
            ),
          ),
          Visibility(
            visible: onButton2 != null,
            child: Container(
              margin: EdgeInsets.only(left: 13.wMin),
              child: ButtonWidget(
                sclae: 1.05,
                text: button2Text,
                height: 40.wMin,
                borderRadius: 6.wMin,
                color: const Color(0xff353E5C),
                fontSize: 14.wMin,
                fontColor: const Color(0xffEBEEF3),
                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
                border: Border.all(width: 1.wMin, color: const Color(0xff353E5C)),
                onTap: onButton2,
              ),
            ),
          ),
          Visibility(
            visible: onButton3 != null,
            child: Container(
              margin: EdgeInsets.only(left: 13.wMin),
              child: ButtonWidget(
                text: button3Text,
                sclae: 1.05,
                height: 40.wMin,
                borderRadius: 6.wMin,
                color: const Color(0xff2388FF),
                fontSize: 14.wMin,
                fontColor: const Color(0xffEBEEF3),
                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
                border: Border.all(width: 1.wMin, color: const Color(0xff2388FF)),
                onTap: onButton3,
              ),
            ),
          ),
          Visibility(
            visible: onButton4 != null,
            child: Container(
              margin: EdgeInsets.only(left: 13.wMin),
              child: ButtonWidget(
                text: button4Text,
                sclae: 1.05,
                height: 40.wMin,
                borderRadius: 6.wMin,
                color: const Color(0xff2388FF),
                fontSize: 14.wMin,
                fontColor: const Color(0xffEBEEF3),
                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
                border: Border.all(width: 1.wMin, color: const Color(0xff2388FF)),
                onTap: onButton4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class ManageQuizStettingRotationWidget extends StatefulWidget {
  final int minNumber;
  final int maxNumber;
  final int value;
  final String title;
  final void Function(int value)? onchange;

  /// 场景轮换次数widget
  const ManageQuizStettingRotationWidget({
    super.key,
    this.minNumber = 1,
    this.maxNumber = 3,
    this.onchange,
    required this.value,
    required this.title,
  });

  @override
  State<ManageQuizStettingRotationWidget> createState() => _ManageQuizStettingRotationWidgetState();
}

class _ManageQuizStettingRotationWidgetState extends State<ManageQuizStettingRotationWidget> {
  @override
  Widget build(BuildContext context) {
    Widget textWidget(String svg) {
      return Container(
        width: 40.wMin,
        height: 40.wMin,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: SvgPicture.asset(
          "assets/svg/manage/$svg",
          width: 24.wMin,
        ),
      );
    }

    return ManageQuizStettingRowBoxWidget(
      title: widget.title,
      childWidth: 152.wMin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TapScaleWidget(
            child: textWidget("icon_minus_sign.svg"),
            onTap: () {
              if (widget.onchange == null) return;
              if (widget.value <= widget.minNumber) return;
              if (mounted) setState(() {});
              widget.onchange?.call(widget.value - 1);
            },
          ),
          Text(
            "${widget.value}",
            style: TextStyle(
              fontSize: 22.wMin,
              color: const Color(0xffEDF0F4),
              fontWeight: FontWeight.w400,
            ),
          ),
          TapScaleWidget(
            child: textWidget("icon_plus_sign.svg"),
            onTap: () {
              if (widget.onchange == null) return;
              if (widget.value >= widget.maxNumber) return;
              if (mounted) setState(() {});
              widget.onchange?.call(widget.value + 1);
            },
          ),
        ],
      ),
    );
  }
}

class ManageQuizStettingRowBoxWidget extends StatelessWidget {
  final String title;
  final Widget child;
  final double? childWidth;
  const ManageQuizStettingRowBoxWidget({
    super.key,
    required this.title,
    required this.child,
    this.childWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        color: const Color(0xff22293C),
        borderRadius: BorderRadius.circular(8.wMin),
        border: Border.all(width: 1.wMin, color: const Color(0xff353E5C)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22.wMin,
              color: const Color(0xffEDF0F4),
              fontWeight: FontWeight.w400,
            ),
          ),
          Container(
            width: childWidth,
            height: 48.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: const Color(0xff2E344E),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class ManageQuizPublicQuizListWidget extends StatelessWidget {
  final String? title;
  final void Function(int index)? onTap;
  final List<int>? selectIndexs;
  final bool isRadio;
  final bool hideOneBig;
  final List<QuizModel>? datas;
  const ManageQuizPublicQuizListWidget({
    super.key,
    this.title,
    this.onTap,
    this.selectIndexs,
    this.isRadio = false,
    this.hideOneBig = false,
    this.datas,
  });

  @override
  Widget build(BuildContext context) {
    if ((datas ?? []).length == 1 && !hideOneBig) {
      /// 只有一道题的时候
      return Center(
        child: SizedBox(
          height: 463.wMin,
          child: QuizPublicQuizWidget(
            borderRadius: 12.wMin,
            data: datas!.first,
          ),
        ),
      );
    }

    Widget buildQuizItemWidget(int index) {
      String iconUnCheck = "assets/svg/manage/icon_uncheck_box.svg";
      String iconCheck = "assets/svg/manage/icon_check_box.svg";
      if (isRadio) {
        iconUnCheck = "assets/svg/manage/icon_unradio.svg";
        iconCheck = "assets/svg/manage/icon_radio.svg";
      }

      return TapScaleWidget(
        onTap: onTap == null
            ? null
            : () {
                onTap?.call(index);
              },
        sclae: 1.01,
        child: Container(
          width: 400.wMin,
          padding: EdgeInsets.all(8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: const Color(0xff23283D),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      datas![index].reason ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: const Color(0xffEDF0F4),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: onTap != null,
                    child: SvgPicture.asset(
                      (selectIndexs?.contains(index) ?? false) ? iconCheck : iconUnCheck,
                      width: 24.wMin,
                      key: ValueKey(selectIndexs?.contains(index) ?? false),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: QuizPublicQuizWidget(
                    borderRadius: 12.wMin,
                    data: datas![index],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: title != null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            child: Text(
              title ?? "",
              style: TextStyle(
                fontSize: 22.wMin,
                color: const Color(0xffEBEFF5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.all(24.wMin),
          child: SizedBox(
            height: 270.wMin,
            child: Row(
              spacing: 16.wMin,
              children: List.generate((datas ?? []).length, (index) {
                return buildQuizItemWidget(index);
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class ManageQuizGridViewQuizWidget extends StatelessWidget {
  final EdgeInsets? padding;
  final double? itemWidth;
  final bool needsLongPressDraggable;
  final List<QuizModel> datas;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final void Function(int index)? onDel;
  final void Function(int index)? onTap;
  final void Function(int index)? onSelect;
  final bool showCheck;
  final List<int>? selectIds;
  final bool showStatus;
  final bool showId;
  final int? quizId;
  const ManageQuizGridViewQuizWidget({
    super.key,
    this.padding,
    this.itemWidth,
    this.onReorder,
    this.onDel,
    this.onTap,
    this.onSelect,
    required this.datas,
    this.needsLongPressDraggable = true,
    this.showCheck = false,
    this.showStatus = false,
    this.showId = true,
    this.selectIds,
    this.quizId,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildQuizWidget(int index, QuizModel data) {
      String statusText = "";
      Color? statusColor;

      if (data.reason == "1") {
        statusText = "上架";
        statusColor = const Color(0xff44AF5C); // 上架颜色
      } else if (data.reason == "0") {
        statusText = "下架";
        statusColor = const Color(0xffFF2D46); // 下架颜色
      }

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          border: Border.all(
            color: data.uid == quizId 
                ? const Color(0xff44AF5C) 
                : AppTheme.cDifficultyBackgroundColor00.withValues(alpha: 0.45),
            width: data.uid == quizId ? 2.wMin : 1.wMin,
          ),
        ),
        width: itemWidth ?? 383.wMin,
        child: AspectRatio(
          aspectRatio: 1.77,
          child: Stack(
            children: [
              TapScaleWidget(
                onTap: onTap != null ? () => onTap?.call(index) : null,
                sclae: 1.03,
                child: QuizPublicQuizWidget(
                  borderRadius: 8.wMin,
                  data: datas[index],
                ),
              ),
              Visibility(
                visible: showStatus && statusText.isNotEmpty,
                child: Positioned(
                  left: 7.wMin,
                  bottom: 7.wMin,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(2.wMin),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12.wMin,
                        color: const Color(0xffEBEFF5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 4.26.wMin,
                top: 4.26.wMin,
                child: ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.exerciseOperationCode],
                  child: IgnorePointer(
                    child: SvgPicture.asset(
                      "assets/svg/manage/icon_drag.svg",
                      width: 25.5.wMin,
                      height: 25.5.wMin,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 4.26.wMin,
                bottom: 4.26.wMin,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TapScaleWidget(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: data.uid?.toString()??""));
                        ToastUtils.showManageToast(text: '复制ID成功');
                      },
                      sclae: 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(27, 33, 60, 1),
                          borderRadius: BorderRadius.circular(4.wMin),
                        ),
                        child: Text(
                          "ID:${data.uid?.toString() ?? ''}",
                          style: TextStyle(
                            fontSize: 14.wMin,
                            color: const Color(0xffEBEFF5),
                            fontWeight: FontWeight.w400,
                            backgroundColor: const Color.fromRGBO(27, 33, 60, 1),
                          ),
                        ),
                      ),
                    ),
                    TapScaleWidget(
                      onTap: (){
                        Clipboard.setData(ClipboardData(text: data.type ?? ""));
                        ToastUtils.showManageToast(text: '复制type成功');
                      },
                      sclae: 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(27, 33, 60, 1),
                          borderRadius: BorderRadius.circular(4.wMin),
                        ),
                        child: Text(
                          data.type ?? '',
                          style: TextStyle(
                            fontSize: 14.wMin,
                            color: const Color(0xffEBEFF5),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: showCheck,
                child: Positioned(
                  left: 0,
                  top: 0,
                  child: TapScaleWidget(
                    onTap: () {
                      if (data.uid == null) return;
                      onSelect?.call(data.uid!);
                    },
                    sclae: 1.1,
                    child: Container(
                      padding: EdgeInsets.all(14.wMin),
                      color: Colors.transparent,
                      child: SvgPicture.asset(
                        (selectIds?.contains(data.uid) ?? false) ? "assets/svg/manage/icon_check_box.svg" : "assets/svg/manage/icon_uncheck_box.svg",
                        width: 25.5.wMin,
                        height: 25.5.wMin,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ReorderableWrap(
      spacing: 14.wMin,
      runSpacing: 14.wMin,
      padding: padding ?? EdgeInsets.zero,
      enableReorder: onReorder != null,
      needsLongPressDraggable: needsLongPressDraggable,
      onReorder: (oldIndex, newIndex) {
        onReorder?.call(oldIndex, newIndex);
      },
      buildDraggableFeedback: (context, constraints, child) {
        return Transform.scale(
          scale: 1.02,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: constraints,
              child: child,
            ),
          ),
        );
      },
      children: List.generate(datas.length, (index) {
        return buildQuizWidget(index, datas[index]);
      }),
    );
  }
}

class ManageQuizAiCardWidget extends StatelessWidget {
  final bool isSelect;
  final String name;
  final String tip;
  final double? width;
  final bool isAi;
  final void Function()? onTap;
  const ManageQuizAiCardWidget({
    super.key,
    this.isSelect = false,
    this.onTap,
    this.name = "",
    this.tip = "",
    this.isAi = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    String icon = "icon_unradio.svg";
    if (isSelect) {
      icon = "icon_radio.svg";
    }

    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.03,
      child: Container(
        // width: width??200.wMin,
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff353E5C).withValues(alpha: 0.35),
        ),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 6.wMin),
                      Visibility(
                        visible: isAi,
                        child: SvgPicture.asset(
                          "assets/svg/manage/icon_sart_ai.svg",
                          height: 24.wMin,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 6.wMin),
                  SvgPicture.asset(
                    "assets/svg/manage/$icon",
                    height: 18.wMin,
                  ),
                ],
              ),
              SizedBox(height: 8.wMin),
              Text(
                tip,
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: const Color(0xff767E95),
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

class ManagePublicKnowledeRowItemWidget extends StatefulWidget {
  final void Function()? onTap;
  final void Function()? onTR;
  final bool isSingle;
  final bool selected;
  final bool isFore;
  final String? content;
  final String? imageUrl;
  final String? svg;
  final bool showTR;
  final String? definition;
  final int? difficulty;
  final String? audioUrl;
  final String? language;
  final int contentMaxLines;
  final int definitionMaxLines;
  const ManagePublicKnowledeRowItemWidget({
    super.key,
    this.onTap,
    this.onTR,
    this.showTR = true,
    this.isSingle = false,
    this.selected = false,
    this.isFore = true,
    this.content,
    this.imageUrl,
    this.svg,
    this.definition,
    this.difficulty,
    this.audioUrl,
    this.language,
    this.contentMaxLines = 1,
    this.definitionMaxLines = 2,
  });

  @override
  State<ManagePublicKnowledeRowItemWidget> createState() => _ManagePublicKnowledeRowItemWidgetState();
}

class _ManagePublicKnowledeRowItemWidgetState extends State<ManagePublicKnowledeRowItemWidget> {
  void showTips(BuildContext ctx) {
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
            minWidth: 200.wMin,
            maxWidth: 500.wMin,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: const Color(0xff181B25),
            border: Border.all(width: 1.wMin, color: const Color(0xff444B5F)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.content ?? "",
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Visibility(
                visible: (widget.definition ?? "").isNotEmpty,
                child: Container(
                  margin: EdgeInsets.only(top: 8.wMin),
                  child: Text(
                    widget.definition ?? "",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: const Color(0xffF2F4F9),
                      fontWeight: FontWeight.w500,
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

  @override
  Widget build(BuildContext context) {
    String iconUnCheck = "assets/svg/manage/icon_uncheck_box.svg";
    String iconCheck = "assets/svg/manage/icon_check_box.svg";
    // String iconCheckDis = "assets/svg/manage/icon_check_box_dis.svg";

    if (widget.isSingle) {
      iconUnCheck = "assets/svg/manage/icon_unradio.svg";
      iconCheck = "assets/svg/manage/icon_radio.svg";
      // iconCheckDis = "assets/svg/manage/icon_radio_dis.svg";
    }
    if (widget.svg != null && widget.svg != "") {
      iconUnCheck = widget.svg ?? "";
    }

    return Opacity(
      opacity: widget.isFore ? 1 : 0.5,
      child: TapScaleWidget(
        onTap: !widget.isFore ? null : widget.onTap,
        sclae: 1.03,
        child: SizedBox(
          width: 172.wMin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.wMin),
                  child: Container(
                    width: double.infinity,
                    color: Colors.white.withValues(alpha: 0.18),
                    child: Stack(
                      children: [
                        CachedImageWidget(
                          widget.imageUrl ?? "",
                          // width: 172.wMin,
                          // height: 172.wMin,
                          fit: BoxFit.cover,
                          errorWidget: Image.asset(
                            Assets.managerImageNotFound,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                          ),
                          placeholder: Container(),
                        ),
                        Positioned(
                          right: 6.wMin,
                          top: 6.wMin,
                          child: Visibility(
                            visible: widget.showTR,
                            child: TapScaleWidget(
                              onTap: widget.onTR,
                              sclae: 1.1,
                              child: SvgPicture.asset(
                                widget.selected ? iconCheck : iconUnCheck,
                                height: 24.wMin,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 6.wMin,
                          top: 6.wMin,
                          child: StatusTagDifficultyWidget(
                            difficulty: widget.difficulty,
                            language: widget.language,
                          ),
                        ),
                        Positioned(
                          left: 6.wMin,
                          bottom: 6.wMin,
                          child: Visibility(
                            visible: widget.audioUrl != null && widget.audioUrl != "",
                            child: TapScaleWidget(
                              onTap: () {
                                PlayAudioUtils.instance.playSingle(widget.audioUrl!);
                              },
                              child: Container(
                                width: 24.wMin,
                                height: 24.wMin,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xff08AFE6),
                                ),
                                child: SvgPicture.asset(
                                  "assets/svg/public/icon_speaker.svg",
                                  height: 16.wMin,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.wMin),
              Expanded(
                child: Builder(
                  builder: (ctx) {
                    return MouseRegion(
                      onEnter: (event) {
                        showTips(ctx);
                      },
                      onExit: (event) {
                        BotToast.cleanAll();
                      },
                      child: TapScaleWidget(
                        onTap: Platform.isMacOS || Platform.isWindows || Platform.isLinux
                            ? null
                            : () {
                                showTips(ctx);
                              },
                        sclae: 1,
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.content ?? "",
                                maxLines: widget.contentMaxLines,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20.wMin,
                                  color: const Color(0xffF2F4F9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Visibility(
                                visible: (widget.definition ?? "").isNotEmpty,
                                child: Container(
                                  margin: EdgeInsets.only(top: 8.wMin),
                                  child: Text(
                                    widget.definition ?? "",
                                    maxLines: widget.definitionMaxLines,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16.wMin,
                                      color: const Color(0xffF2F4F9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
