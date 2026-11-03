import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/guide_engine/guide_step_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../model/mission_model.dart';

class MissionControlCenterPlanetWidget extends StatefulWidget {
  final MissionModel missionModel;
  final int index;
  final int currentIndex;
  final Future<void> Function()? onTap;
  final void Function()? onAgainTap;
  final String? widgetId;

  const MissionControlCenterPlanetWidget({
    super.key,
    required this.missionModel,
    required this.index,
    required this.currentIndex,
    this.onTap,
    this.onAgainTap,
    this.widgetId,
  });

  @override
  State<MissionControlCenterPlanetWidget> createState() =>
      _MissionControlCenterPlanetWidgetState();
}

class _MissionControlCenterPlanetWidgetState
    extends State<MissionControlCenterPlanetWidget> {
  bool get _shouldShowScore => (widget.missionModel.missions.star ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    Widget missionWidget = Container();
    if (widget.missionModel.missions.isTest) {
      missionWidget = _buildTestWidget();
    } else if (widget.missionModel.missions.isPreview) {
      missionWidget = _buildPreviewWidget();
    } else {
      missionWidget = _buildMissionWidget();
    }

    return Container(
      alignment: Alignment.center,
      child: Container(
        width: 180.wMin,
        height: 270.wMin,
        alignment:
            widget.index.isOdd ? Alignment.topCenter : Alignment.bottomCenter,
        child: missionWidget,
      ),
    );
  }

  /// 预习
  Widget _buildPreviewWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPreviewProgressBallWidget(),
        Visibility(
          visible: !widget.missionModel.missions.learned,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${widget.missionModel.missions.typeLabel} ",
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 28.wMin,
                child: Text(
                  widget.missionModel.missions.previewBottomLabel,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: widget.missionModel.missions.learned,
          child: SizedBox(
            width: 160.wMin,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${widget.missionModel.missions.typeLabel} ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.wMin),
                ButtonWidget(
                  text: widget.missionModel.missions.previewBottomLabel,
                  width: 96.wMin,
                  height: 30.wMin,
                  borderRadius: 8.wMin,
                  color: AppTheme.cFeedbackInfoBackground.color,
                  fontColor: AppTheme.cTextBrand.color,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w500,
                  sclae: 1.03,
                  onTap: widget.onAgainTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewProgressBallWidget() {
    final progress = widget.missionModel.missions.previewProgress;
    final ballSize = 96.wMin;
    final ringGap = 3.wMin;
    final ringStroke = 3.wMin;
    final ringSize = ballSize + ringGap * 2 + ringStroke;
    const ringColor = Color(0xFFD946EF);
    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: ringStroke,
              valueColor: const AlwaysStoppedAnimation<Color>(ringColor),
              backgroundColor: ringColor.withValues(alpha: 0.18),
            ),
          ),
          SizedBox(
            width: ballSize,
            height: ballSize,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                _buildLightBgWidget(),
                _buildBgWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 测试
  Widget _buildTestWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 164.wMin,
          height: 144.wMin,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 30.wMin,
                left: 26.wMin,
                child: SizedBox(
                  width: 138.wMin,
                  height: 112.wMin,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      _buildLightBgWidget(),
                      _buildBgWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: !widget.missionModel.missions.learned,
          child: SizedBox(
              width: 138.wMin,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 18.wMin),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.missionModel.missions.typeLabel} ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    ],
                  ),
                ],
              )),
        ),
        Visibility(
          visible: widget.missionModel.missions.learned,
          child: SizedBox(
              width: 160.wMin,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 18.wMin),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.missionModel.missions.typeLabel} ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Visibility(
                        visible: widget.missionModel.missions.learned,
                        child: Text(
                          "${widget.missionModel.missions.score ?? 0}分 ",
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: AppTheme.cTextPrimary.color,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.missionModel.missions.learned,
                        child: ButtonWidget(
                          text: '再测一遍',
                          width: 96.wMin,
                          height: 30.wMin,
                          borderRadius: 8.wMin,
                          color: AppTheme.cFeedbackInfoBackground.color,
                          fontColor: AppTheme.cTextBrand.color,
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w500,
                          sclae: 1.03,
                          onTap: widget.onAgainTap,
                        ),
                      ),
                      SizedBox(height: 14.wMin),
                    ],
                  ),
                ],
              )),
        ),
      ],
    );
  }

  /// 任务
  Widget _buildMissionWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 164.wMin,
          height: 144.wMin,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 38.wMin,
                width: 112.wMin,
                child: Visibility(
                  visible: widget.missionModel.missions.learned,
                  child: Center(
                    child: _buildMissionStarWidget(),
                  ),
                ),
              ),
              Positioned(
                top: 30.wMin,
                left: 26.wMin,
                child: GuideStepWidget(
                  id: 'mission_btn',
                  disableKey: widget.currentIndex != widget.index,
                  child: SizedBox(
                    width: 138.wMin,
                    height: 112.wMin,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        _buildLightBgWidget(),
                        _buildBgWidget(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: !widget.missionModel.missions.learned,
          child: SizedBox(
              width: 138.wMin,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 18.wMin),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.missionModel.missions.typeLabel} ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 32.wMin,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4.wMin,
                          children: [
                            SvgPicture.asset(
                              "assets/svg/public/icon_countdown.svg",
                              height: 24.wMin,
                              width: 24.wMin,
                              colorFilter: ColorFilter.mode(
                                  AppTheme.cTextTertiary.color,
                                  BlendMode.srcIn),
                            ),
                            Text(
                              " ${DateFormatUtil.convertSecondsToMinSec((widget.missionModel.missions.estimatedTime ?? 0).toInt())}",
                              style: TextStyle(
                                fontSize: 20.wMin,
                                color: AppTheme.cTextTertiary.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.wMin),
                    ],
                  ),
                ],
              )),
        ),
        Visibility(
          visible: widget.missionModel.missions.learned,
          child: SizedBox(
              width: 160.wMin,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 18.wMin),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.missionModel.missions.typeLabel} ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        height: 32.wMin,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Visibility(
                              visible: _shouldShowScore,
                              child: Text(
                                "${widget.missionModel.missions.score ?? 0}分 ",
                                style: TextStyle(
                                  fontSize: 20.wMin,
                                  color: AppTheme.cTextPrimary.color,
                                ),
                              ),
                            ),
                            SvgPicture.asset(
                              "assets/svg/public/icon_countdown.svg",
                              height: 24.wMin,
                              width: 24.wMin,
                              colorFilter: ColorFilter.mode(
                                  AppTheme.cTextTertiary.color,
                                  BlendMode.srcIn),
                            ),
                            Text(
                              " ${DateFormatUtil.convertSecondsToMinSec((widget.missionModel.missions.duration ?? 0).toInt())}",
                              style: TextStyle(
                                fontSize: 20.wMin,
                                color: AppTheme.cTextTertiary.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ButtonWidget(
                        text: widget.missionModel.missions.isPerfect
                            ? "已完美"
                            : "再做一遍",
                        width: 96.wMin,
                        height: 30.wMin,
                        borderRadius: 8.wMin,
                        color: AppTheme.cFeedbackInfoBackground.color,
                        fontColor: AppTheme.cTextBrand.color,
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w500,
                        sclae: 1.03,
                        onTap: widget.onAgainTap,
                      ),
                    ],
                  ),
                ],
              )),
        ),
      ],
    );
  }

  Widget _buildMissionStarWidget() {
    int star = widget.missionModel.missions.star ?? 0;
    return ListAnimationGridWidget(
      index: widget.index,
      columnCount: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.wMin),
            child: Image.asset(
              star > index
                  ? "assets/images/public/icon_star.webp"
                  : "assets/images/public/icon_star_un.webp",
              height: 28.wMin,
            ),
          );
        }),
      ),
    );
  }

  /// 背景
  Widget _buildBgWidget() {
    String img = "assets/images/mission/new.png";
    if (widget.missionModel.missions.isReview) {
      img = "assets/images/mission/revise.png";
    } else if (widget.missionModel.missions.isPreview) {
      img = "assets/images/mission/preview.png";
    } else if (widget.missionModel.missions.isTest) {
      img = "assets/images/mission/test.png";
    }

    Widget body = ListAnimationGridWidget(
      index: widget.index,
      columnCount: 1,
      duration: const Duration(milliseconds: 100),
      child: SizedBox(
        width: 112.wMin,
        height: 112.wMin,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Image.asset(img, width: 108.wMin),
            _buildMissionContentTextWidget(),
            Visibility(
              visible: widget.missionModel.missions.notYetLearned &&
                  widget.index != widget.currentIndex,
              child: Container(
                width: 108.wMin,
                height: 108.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cInverseOverlay.color,
                ),
                child: SvgPicture.asset(
                  "assets/svg/mission/icon_lock.svg",
                  fit: BoxFit.cover,
                  height: 20.wMin,
                ),
              ),
            ),
            // Visibility(
            //   visible: widget.missionModel.missions.learned,
            //   child: Positioned(
            //     right: 10.wMin,
            //     top: 0.wMin,
            //     child: SvgPicture.asset(
            //       "assets/svg/mission/icon_flag.svg",
            //       fit: BoxFit.cover,
            //       height: 44.wMin,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );

    Widget tapWidget = Container();
    if (widget.widgetId == null) {
      tapWidget = TapScaleWidget(
        onTap: widget.onTap,
        sclae: 1.03,
        child: body,
      );
    } else {
      tapWidget = GuideStepWidget(
        id: widget.widgetId!,
        onTap: widget.onTap,
        sclae: 1.03,
        child: body,
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 1.wMin,
          height: 1.wMin,
          key: widget.missionModel.missionKey,
        ),
        tapWidget,
      ],
    );
  }

  /// 发光旋转背景(当前执行到的任务)
  Widget _buildLightBgWidget() {
    if (widget.index != widget.currentIndex) {
      return const SizedBox.shrink();
    }
    double lightSize = 156.wMin;
    String img = "assets/images/mission/new_light_bg.png";
    if (widget.missionModel.missions.isReview) {
      img = "assets/images/mission/revise_light_bg.png";
      lightSize = 184.wMin;
    } else if (widget.missionModel.missions.isPreview) {
      img = "assets/images/mission/preview_light_bg.png";
    } else if (widget.missionModel.missions.isTest) {
      img = "assets/images/mission/test_light_bg.png";
    } else {
      lightSize = 184.wMin;
    }

    return Opacity(
      opacity: 0.92,
      child: OverflowBox(
        minWidth: 0,
        minHeight: 0,
        maxWidth: lightSize,
        maxHeight: lightSize,
        alignment: Alignment.center,
        child: RotationTransitionWidget(
          autoStart: true,
          child: SizedBox(
            width: lightSize,
            height: lightSize,
            child: Image.asset(
              img,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  /// 任务内容文字
  Widget _buildMissionContentTextWidget() {
    TextStyle style = TextStyle(
      fontSize: 20.wMin,
      color: AppTheme.cInverseTextLight.color,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );

    if (widget.missionModel.missions.isPreview) {
      if (widget.missionModel.missions.learned) {
        return SvgPicture.asset(
          "assets/svg/mission/icon_yes.svg",
          width: 28.wMin,
          height: 28.wMin,
          colorFilter: ColorFilter.mode(
            AppTheme.cInverseTextLight.color,
            BlendMode.srcIn,
          ),
        );
      }
      if (widget.index == widget.currentIndex) {
        return SvgPicture.asset(
          "assets/svg/mission/icon_calendar_konw.svg",
          width: 30.wMin,
          height: 30.wMin,
          colorFilter: ColorFilter.mode(
            AppTheme.cInverseTextLight.color,
            BlendMode.srcIn,
          ),
        );
      }
      return Text(
        widget.missionModel.missions.displayTitle,
        style: style,
        textAlign: TextAlign.center,
      );
    } else if (widget.missionModel.missions.isTest) {
      return Text(
        widget.missionModel.missions.displayTitle,
        style: style,
        textAlign: TextAlign.center,
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Text(
        //   widget.missionModel.missions.displayTitle,
        //   style: TextStyle(
        //     fontSize: 28.wMin,
        //     fontWeight: FontWeight.w800,
        //     foreground: Paint()
        //       ..style = PaintingStyle.stroke
        //       ..strokeWidth = 2.5.wMin
        //       ..color = const Color(0xFF7C3AED),
        //   ),
        // ),
        Text(
          widget.missionModel.missions.displayTitle,
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cInverseTextLight.color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }


}
