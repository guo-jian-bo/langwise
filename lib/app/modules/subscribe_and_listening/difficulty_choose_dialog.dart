import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/music/controllers/music_controller.dart';
import 'package:langwise/app/modules/new_music/controllers/new_music_controller.dart';
import 'package:langwise/app/modules/subscribe_and_listening/controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../theme/theme.dart';
import '../../../utils/utils.dart';

class DifficultyChooseDialog {
  static Future<bool> show(
    BuildContext context,
    String source, {
    String? tagText,
  }) async {
    final bool? res = await showCupertinoDialog<bool?>(
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
  State<DifficultyChooseDialogWidget> createState() =>
      _DifficultyChooseDialogWidgetState();
}

class _DifficultyChooseDialogWidgetState
    extends State<DifficultyChooseDialogWidget> {
  final List<String> difficultyList = <String>[
    'Pre A1',
    'A1',
    'A2',
    'B1',
    'B2',
    'C1',
    'C2',
  ];
  final List<String> cefrList = <String>[
    'L0-L3',
    'L4-L6',
    'L7-L9',
    'L10-L12',
    'L13-L15',
    'L16-L18',
    'L19-L21',
  ];
  List<String> instruction = <String>[];
  List<String> difInstruction = <String>[];
  dynamic ctrl;
  int selectedDifficulty = 0;
  int initDif = 0;

  @override
  void initState() {
    super.initState();
    if (widget.source == 'sublisten') {
      ctrl = Get.find<SubListenController>(tag: widget.tagText);
      instruction = <String>['页面将显示对应难度的文章', '不影响订阅推送内容', '随时切换，方便查看不同难度'];
      difInstruction = <String>['根据您的学习水平推荐', '推送内容按此难度匹配', '可在「个人设置」中修改'];
    } else if (widget.source == 'new_music') {
      ctrl = Get.find<NewMusicController>(tag: widget.tagText);
      instruction = <String>['页面将显示对应难度的歌曲', '随时切换，方便查看不同难度'];
      difInstruction = <String>['根据您的学习水平推荐', '可在「个人设置」中修改'];
    } else if (widget.source == 'music') {
      ctrl = Get.find<MusicController>();
      instruction = <String>['页面将显示对应难度的歌曲', '随时切换，方便查看不同难度'];
      difInstruction = <String>['根据您的学习水平推荐', '可在「个人设置」中修改'];
    }
    initDif = ctrl.settingDifficulty.value;
    if (initDif < 0) {
      initDif = 0;
    }
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
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(40.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '选择浏览难度',
                      style: TextStyle(
                        fontSize: 32.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.wMin),
                    Row(
                      children: [
                        Text(
                          '当前浏览难度:',
                          style: TextStyle(
                            fontSize: 22.wMin,
                            color: AppTheme.cTextTertiary,
                          ),
                        ),
                        Text(
                          difficultyList[initDif],
                          style: TextStyle(
                            fontSize: 28.wMin,
                            fontWeight: FontWeight.w500,
                            color: StatusUtils.getCefrBackgroundColor(
                              difficultyList[initDif],
                            ).color2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40.wMin),
                    Text(
                      '${widget.source == 'sublisten' ? '文章' : '歌曲'}等级对应',
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextSecondary,
                      ),
                    ),
                    SizedBox(height: 8.wMin),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(difficultyList.length, (e) {
                        final int recommendIndex = ctrl.userDifficulty.value;

                        return GestureDetector(
                          onTap: () {
                            if (e == difficultyList.length - 1 ||
                                e == difficultyList.length - 2) {
                              return;
                            }
                            setState(() {
                              selectedDifficulty = e;
                              if (widget.source == 'sublisten') {
                                ctrl.setDifficultySelection(e);
                              } else if (widget.source == 'music' ||
                                  widget.source == 'new_music') {
                                ctrl.settingDifficulty.value = e;
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
                                  color: e == difficultyList.length - 1 ||
                                          e == difficultyList.length - 2
                                      ? AppTheme.cBgDisabled.color
                                      : AppTheme.cSurfaceTertiary.color,
                                  border: selectedDifficulty == e
                                      ? Border.all(
                                          width: 2.wMin,
                                          color: StatusUtils
                                              .getCefrBackgroundColor(
                                                difficultyList[e],
                                              )
                                              .color2,
                                        )
                                      : null,
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
                                        color: e == difficultyList.length - 1 ||
                                                e == difficultyList.length - 2
                                            ? AppTheme.cTextDisabled.color
                                            : selectedDifficulty == e
                                                ? StatusUtils
                                                    .getCefrBackgroundColor(
                                                      difficultyList[e],
                                                    )
                                                    .color2
                                                : AppTheme.cTextTertiary.color,
                                      ),
                                    ),
                                    Divider(
                                      indent: 18.wMin,
                                      endIndent: 18.wMin,
                                      color: const Color(0xFF5B6167),
                                    ),
                                    Text(
                                      cefrList[e],
                                      style: TextStyle(
                                        fontSize: 24.wMin,
                                        fontWeight: FontWeight.w400,
                                        color: e == difficultyList.length - 1 ||
                                                e == difficultyList.length - 2
                                            ? AppTheme.cTextDisabled.color
                                            : selectedDifficulty == e
                                                ? StatusUtils
                                                    .getCefrBackgroundColor(
                                                      difficultyList[e],
                                                    )
                                                    .color2
                                                : AppTheme.cTextTertiary.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (e == recommendIndex && e != initDif)
                                Positioned(
                                  top: -14.wMin,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.wMin,
                                        vertical: 4.wMin,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(999.wMin),
                                        color: AppTheme.cTextBrand.color,
                                      ),
                                      child: Text(
                                        '推荐',
                                        style: TextStyle(
                                          fontSize: 18.wMin,
                                          color:
                                              AppTheme.cInverseTextLight.color,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 32.wMin),
                    Container(
                      padding: EdgeInsets.all(20.wMin),
                      decoration: BoxDecoration(
                        color: AppTheme.cSurfaceTertiary.color,
                        borderRadius: BorderRadius.circular(16.wMin),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '浏览难度说明',
                            style: TextStyle(
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextSecondary,
                            ),
                          ),
                          SizedBox(height: 12.wMin),
                          ...instruction.map(
                            (e) => Padding(
                              padding: EdgeInsets.only(bottom: 8.wMin),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 8.wMin),
                                    width: 8.wMin,
                                    height: 8.wMin,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          AppTheme.cTextSecondary.withOpacity(
                                        0.6,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.wMin),
                                  Expanded(
                                    child: Text(
                                      e,
                                      style: TextStyle(
                                        fontSize: 22.wMin,
                                        color: AppTheme.cTextTertiary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.source == 'sublisten')
                            Padding(
                              padding: EdgeInsets.only(top: 8.wMin),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(
                                    height: 32.wMin,
                                    color: AppTheme.cBorderTertiary,
                                  ),
                                  Text(
                                    '推荐难度说明',
                                    style: TextStyle(
                                      fontSize: 24.wMin,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.cTextSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 12.wMin),
                                  ...difInstruction.map(
                                    (e) => Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 8.wMin),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin:
                                                EdgeInsets.only(top: 8.wMin),
                                            width: 8.wMin,
                                            height: 8.wMin,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppTheme
                                                  .cTextSecondary
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                          SizedBox(width: 12.wMin),
                                          Expanded(
                                            child: Text(
                                              e,
                                              style: TextStyle(
                                                fontSize: 22.wMin,
                                                color: AppTheme.cTextTertiary,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 18.wMin,
                right: 18.wMin,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 56.wMin,
                    height: 56.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cSurfaceTertiary.color,
                    ),
                    child: Transform.rotate(
                      angle: pi / 4,
                      child: SvgPicture.asset(
                        'assets/svg/public/icon_add.svg',
                        width: 30.wMin,
                        height: 30.wMin,
                        colorFilter: ColorFilter.mode(
                          AppTheme.cTextPrimary.color,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

