import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/music/controllers/music_controller.dart';
import 'package:langwise/app/modules/subscribe_and_listening_details/controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';

class DifficultyChooseDialog {
  static Future<bool> show(BuildContext context, String source, {String? tagText}) async {
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return DifficultyChooseDialogWidget(source: source, tagText: tagText);
      },
    );
    return res ?? false;
  }
}

class DifficultyChooseDialogWidget extends StatefulWidget {
  const DifficultyChooseDialogWidget({super.key, this.source, this.tagText});

  final String? source;
  final String? tagText;

  @override
  State<DifficultyChooseDialogWidget> createState() => _DifficultyChooseDialogWidgetState();
}

class _DifficultyChooseDialogWidgetState extends State<DifficultyChooseDialogWidget> {
  List<String> difficultyList = ["Pre A1", "A1", "A2", "B1", "B2", "C1", "C2"];
  List<String> cefrList = ["L0-L3", "L4-L6", "L7-L9", "L10-L12", "L13-L15", "L16-L18", "L19-L21"];
  List<String> instruction = [];
  List<String> difInstruction = [];
  var ctrl;
  int selectedDifficulty = 0;
  var initDif = 0;

  @override
  void initState() {
    super.initState();
    if (widget.source == 'sublisten') {
      ctrl = Get.find<SubListenDetailsController>(tag: widget.tagText);
      instruction = ['页面将显示对应难度的文章', '不影响订阅推送内容', '随时切换，方便查看不同难度'];
      difInstruction = ['根据您的学习水平推荐', '推送内容按此难度匹配', '可在「个人设置」中修改'];
    } else if (widget.source == 'music') {
      ctrl = Get.find<MusicController>();
      instruction = ['页面将显示对应难度的歌曲', '随时切换，方便查看不同难度'];
      difInstruction = ['根据您的学习水平推荐', '可在「个人设置」中修改'];
    }
    initDif = ctrl.settingDifficulty.value;
    if (initDif < 0) initDif = 0;
    selectedDifficulty = initDif;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Container(
          width: 1080.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            color: AppTheme.cSurfaceSecondary.color,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
          ),
          child: Stack(children: [
            Padding(
              padding: EdgeInsets.all(40.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('选择浏览难度', style: TextStyle(fontSize: 32.wMin, color: AppTheme.cTextPrimary, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6.wMin),
                  Row(
                    children: [
                      Text('当前浏览难度:', style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextTertiary)),
                      Text(difficultyList[initDif],
                          style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: StatusUtils.getCefrBackgroundColor(difficultyList[initDif]).color2)),
                    ],
                  ),
                  SizedBox(height: 40.wMin),
                  Text('${widget.source == 'sublisten' ? '文章' : '歌曲'}等级对应', style: TextStyle(fontSize: 24.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextSecondary)),
                  SizedBox(height: 8.wMin),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(difficultyList.length, (e) {
                        // 推荐难度索引（从 0 开始）
                        final int recommendIndex = ctrl.userDifficulty.value;

                        return GestureDetector(
                          onTap: () {
                            if (e == difficultyList.length - 1 || e == difficultyList.length - 2) return;
                            setState(() {
                              selectedDifficulty = e;
                              ctrl.settingDifficulty.value = e;
                              if (widget.source == 'sublisten') {
                                ctrl.loadPage(reset: true);
                              } else if (widget.source == 'music') {
                                ctrl.loadSong(reset: true);
                              }
                              Get.back();
                            });
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                  width: 136.wMin,
                                  height: 140.wMin,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.wMin),
                                    color: e == difficultyList.length - 1 || e == difficultyList.length - 2 ? AppTheme.cBgDisabled.color : AppTheme.cSurfaceTertiary.color,
                                    border: selectedDifficulty == e ? Border.all(width: 2.wMin, color: StatusUtils.getCefrBackgroundColor(difficultyList[e]).color2) : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        difficultyList[e],
                                        style: TextStyle(
                                            fontSize: 32.wMin,
                                            fontWeight: FontWeight.w600,
                                            color: e == difficultyList.length - 1 || e == difficultyList.length - 2
                                                ? AppTheme.cTextDisabled.color
                                                : selectedDifficulty == e
                                                    ? StatusUtils.getCefrBackgroundColor(difficultyList[e]).color2
                                                    : AppTheme.cTextTertiary.color),
                                      ),
                                      Divider(indent: 18.wMin, endIndent: 18.wMin, color: Color(0xFF5B6167)),
                                      Text(
                                        cefrList[e],
                                        style: TextStyle(
                                            fontSize: 24.wMin,
                                            fontWeight: FontWeight.w400,
                                            color: e == difficultyList.length - 1 || e == difficultyList.length - 2
                                                ? AppTheme.cTextDisabled.color
                                                : selectedDifficulty == e
                                                    ? StatusUtils.getCefrBackgroundColor(difficultyList[e]).color2
                                                    : AppTheme.cTextTertiary.color),
                                      ),
                                    ],
                                  )),
                              if (e == recommendIndex)
                                Positioned(
                                  top: 0.wMin,
                                  right: 0.wMin,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                                    decoration: BoxDecoration(color: AppTheme.cFeedbackWarningBorder.color, borderRadius: BorderRadius.circular(8.wMin)),
                                    child: Text(
                                      '推荐',
                                      style: TextStyle(
                                        fontSize: 18.wMin,
                                        color: AppTheme.cInverseTextLight.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList()),
                  SizedBox(height: 8.wMin),
                  Text('课程系统等级将国际通用的 CEFR 标准与课程 L 级别深度对齐，确保您${widget.source == 'sublisten' ? '读到的每篇文章' : '听到的每首歌曲'}都符合当前水平。',
                      style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextTertiary)),
                  SizedBox(height: 16.wMin),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _card('浏览难度说明', AppTheme.cTextBrand.color, AppTheme.cFeedbackInfoBackground.color, instruction),
                    _card(
                        '推荐难度:${difficultyList[max(ctrl.userDifficulty.value, 0)]}', AppTheme.cFeedbackWarningText.color, AppTheme.cFeedbackWarningBackground.color, difInstruction)
                  ])
                ],
              ),
            ),
            Positioned(top: 6.wMin, right: 6.wMin, child: _backIcon()),
          ]),
        ),
      ),
    );
  }

  Widget _card(String title, Color titleColor, Color bgColor, List<String> menu) {
    return Container(
      width: 452.wMin,
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: bgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 28.wMin, color: titleColor, fontWeight: FontWeight.w500)),
          SizedBox(height: 16.wMin),
          Column(
              children: List.generate(menu.length, (e) {
            return Row(
              children: [
                Container(width: 8.wMin, height: 8.wMin, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.cTextQuaternary.color)),
                SizedBox(width: 8.wMin),
                Text(menu[e], style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextSecondary.color)),
              ],
            );
          }))
        ],
      ),
    );
  }

  Widget _backIcon() {
    return TapScaleWidget(
      sclae: 1.05,
      onTap: () => Get.back(),
      child: Container(
        width: 42.wMin,
        height: 42.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: SvgPicture.asset(
          "assets/svg/public/x.svg",
          width: 24.wMin,
          height: 24.wMin,
        ),
      ),
    );
  }
}
