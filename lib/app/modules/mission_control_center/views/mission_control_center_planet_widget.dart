import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../model/mission_model.dart';

class MissionControlCenterPlanetWidget extends StatefulWidget {
  final MissionModel missionModel;
  final int index;
  final int currentIndex;
  final void Function()? onTap;
  final void Function()? onAgainTap;

  const MissionControlCenterPlanetWidget({
    super.key,
    required this.missionModel,
    required this.index,
    required this.currentIndex,
    this.onTap,
    this.onAgainTap,
  });

  @override
  State<MissionControlCenterPlanetWidget> createState() => _MissionControlCenterPlanetWidgetState();
}

class _MissionControlCenterPlanetWidgetState extends State<MissionControlCenterPlanetWidget> {
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
        width: 350.wMin,
        height: 450.wMin,
        alignment: widget.index.isOdd ? Alignment.topCenter : Alignment.bottomCenter,
        child: missionWidget,
      ),
    );
  }

  /// 预习
  Widget _buildPreviewWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 210.wMin,
          height: 210.wMin,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              _buildLightBgWidget(),
              _buildBgWidget(),
            ],
          ),
        ),
        Text(
          widget.missionModel.missions.title ?? '',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 52.wMin,
          child: Text(
            "${widget.missionModel.missions.knowledgeCount ?? 0}个知识点",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  /// 测试
  Widget _buildTestWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 210.wMin,
          height: 210.wMin,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              _buildLightBgWidget(),
              _buildBgWidget(),
            ],
          ),
        ),
        Text(
          widget.missionModel.missions.title ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Visibility(
          visible: !widget.missionModel.missions.learned,
          child: SizedBox(
            height: 58.wMin,
            child: Visibility(
              visible: widget.missionModel.missions.estimatedTime != null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4.wMin,
                children: [
                  SvgPicture.asset(
                    "assets/svg/public/icon_countdown.svg",
                    height: 34.wMin,
                  ),
                  Text(
                    DateFormatUtil.convertSecondsToMinSec((widget.missionModel.missions.estimatedTime ?? 0).toInt()),
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: widget.missionModel.missions.learned,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 58.wMin,
                alignment: Alignment.center,
                child: Visibility(
                  visible: widget.missionModel.missions.score != null && widget.missionModel.missions.score != 0,
                  child: Text(
                    "得分:${widget.missionModel.missions.score ?? 0}",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              ButtonWidget(
                text: "再测一遍",
                width: 144.wMin,
                height: 52.wMin,
                borderRadius: 8.wMin,
                color: AppTheme.cFeedbackInfoBackground.color,
                fontColor: AppTheme.cTextBrand.color,
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: widget.onAgainTap,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 任务
  Widget _buildMissionWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GuideAnchor(
          id: widget.currentIndex == widget.index ? 'mission_btn' : '',
          route: Routes.MISSION_CONTROL_CENTER,
          child: SizedBox(
            width: 210.wMin,
            height: 210.wMin,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildLightBgWidget(),
                _buildBgWidget(),
                Positioned(
                  bottom: -3.wMin,
                  child: Visibility(
                    visible: widget.missionModel.missions.learned,
                    child: _buildMissionStarWidget(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: !widget.missionModel.missions.learned,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 58.wMin,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4.wMin,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/public/icon_countdown.svg",
                      height: 34.wMin,
                    ),
                    Text(
                      DateFormatUtil.convertSecondsToMinSec((widget.missionModel.missions.estimatedTime ?? 0).toInt()),
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 52.wMin),
            ],
          ),
        ),
        Visibility(
          visible: widget.missionModel.missions.learned,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 58.wMin,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/public/icon_countdown.svg",
                      height: 34.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                    ),
                    Text(
                      " ${DateFormatUtil.convertSecondsToMinSec((widget.missionModel.missions.duration ?? 0).toInt())}  得分:${widget.missionModel.missions.score ?? 0}",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              ButtonWidget(
                text: widget.missionModel.missions.isPerfect ? "已完美" : "再做一遍",
                width: 144.wMin,
                height: 52.wMin,
                borderRadius: 8.wMin,
                color: AppTheme.cFeedbackInfoBackground.color,
                fontColor: AppTheme.cTextBrand.color,
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: widget.onAgainTap,
              ),
            ],
          ),
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
          double angle = 0;
          if (index == 0) {
            angle = 0.48;
          } else if (index == 2) {
            angle = -0.48;
          }

          return Container(
            margin: EdgeInsets.only(top: index == 1 ? 30.wMin : 0),
            child: Transform.rotate(
              angle: angle,
              child: Image.asset(
                star > index ? "assets/images/public/icon_star.webp" : "assets/images/public/icon_star_un.webp",
                height: 50.wMin,
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 背景
  Widget _buildBgWidget() {
    String img = "assets/images/mission/mission.png";
    if (widget.missionModel.missions.isPreview) {
      img = "assets/images/mission/preview.png";
    } else if (widget.missionModel.missions.isTest) {
      img = "assets/images/mission/test.png";
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 1.wMin,
          height: 1.wMin,
          key: widget.missionModel.missionKey,
        ),
        TapScaleWidget(
          onTap: widget.onTap,
          sclae: 1.03,
          child: ListAnimationGridWidget(
            index: widget.index,
            columnCount: 1,
            duration: const Duration(milliseconds: 100),
            child: SizedBox(
              width: 210.wMin,
              height: 210.wMin,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Image.asset(img, width: 180.wMin),
                  _buildMissionContentTextWidget(),
                  Visibility(
                    visible: widget.missionModel.missions.notYetLearned && widget.index != widget.currentIndex,
                    child: Container(
                      width: 162.wMin,
                      height: 162.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cInverseOverlay.color,
                      ),
                      child: SvgPicture.asset(
                        "assets/svg/mission/icon_lock.svg",
                        fit: BoxFit.cover,
                        height: 32.wMin,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.missionModel.missions.learned,
                    child: Positioned(
                      right: 10.wMin,
                      top: 0.wMin,
                      child: SvgPicture.asset(
                        "assets/svg/mission/icon_flag.svg",
                        fit: BoxFit.cover,
                        height: 80.wMin,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 发光旋转背景(当前执行到的任务)
  Widget _buildLightBgWidget() {
    if (widget.index != widget.currentIndex) {
      return const SizedBox.shrink();
    }
    String img = "assets/images/mission/mission_light_bg.png";
    if (widget.missionModel.missions.isPreview) {
      img = "assets/images/mission/preview_light_bg.png";
    } else if (widget.missionModel.missions.isTest) {
      img = "assets/images/mission/test_light_bg.png";
    }

    return Opacity(
      opacity: 0.8,
      child: RotationTransitionWidget(
        autoStart: true,
        child: Image.asset(
          img,
          width: 210.wMin,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// 任务内容文字
  Widget _buildMissionContentTextWidget() {
    TextStyle style = TextStyle(
      fontSize: 36.wMin,
      color: AppTheme.cInverseTextLight.color,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );

    if (widget.missionModel.missions.isPreview) {
      return Text(
        widget.missionModel.missions.missionTitle ?? "",
        style: style,
        textAlign: TextAlign.center,
      );
    } else if (widget.missionModel.missions.isTest) {
      return Text(
        widget.missionModel.missions.missionTitle ?? "",
        style: style,
        textAlign: TextAlign.center,
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          widget.missionModel.missions.missionTitle ?? "",
          style: TextStyle(
            fontSize: 56.wMin,
            fontWeight: FontWeight.w800,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6.wMin
              ..color = const Color(0xFF7C3AED),
          ),
        ),
        Text(
          widget.missionModel.missions.missionTitle ?? "",
          style: TextStyle(
            fontSize: 56.wMin,
            color: AppTheme.cInverseTextLight.color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
