import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../common/visua_style_rules_dialog.dart';
import '../controllers/user_visual_style_controller.dart';

class UserVisualStyleWidget extends GetView<UserVisualStyleController> {
  /// 视觉风格设置
  final String tagText;
  const UserVisualStyleWidget({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.styleList.isEmpty) return Container();
      return Container(
        margin: EdgeInsets.only(top: 32.wMin),
        width: double.infinity,
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceSecondary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(context),
            SizedBox(height: 24.wMin),
            Container(height: 1.wMin, color: AppTheme.cBorderDefault.color),
            _buildVisualPanelWidget(context),
            _buildMixSectionWidget(),
          ],
        ),
      );
    });
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50.wMin,
          height: 50.wMin,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cFeedbackInfoBackground,
          ),
          child: SvgPicture.asset(
            'assets/svg/user_center/icon_user_style.svg',
            width: 30.wMin,
            height: 30.wMin,
          ),
        ),
        SizedBox(width: 8.wMin),
        Expanded(
          child: Text(
            "视觉风格偏好",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),),
              Text(
                "决定每道题目的视觉呈现方式",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TapScaleWidget(
                sclae: 1.05,
                onTap: OptimizeUtils.noneThrottle(() {
                  if (controller.teamStyleData.value.explain == null) return;
                  VisuaStyleRulesDialog.show(
                    context: context,
                    explain: controller.teamStyleData.value.explain ?? "",
                  );
                }, 1000),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    "assets/svg/user_center/icon_info.svg",
                    width: 32.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                  ),
                ),
              ),
            
      ],
    );
  }

  Widget _buildVisualPanelWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24.wMin),
      child: Column(
        children: [
          Row(
            spacing: 16.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "切换模式",
                      style: TextStyle(
                        fontSize: 22.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                    SizedBox(height: 10.wMin),
                    IntrinsicHeight(
                      child: Row(
                        spacing: 12.wMin,
                        children: [
                          _buildModeItemWidget(
                            mode: ResourceTypeEnum.image,
                            tag: "快速学习",
                            desc: "精美高光图片，瞬间捕捉语义",
                          ),
                          _buildModeItemWidget(
                            mode: ResourceTypeEnum.video,
                            tag: "推荐·沉浸体验",
                            desc: "真实语境演绎，把母语场景带到身边",
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.wMin),
                    Text(
                      "主风格",
                      style: TextStyle(
                        fontSize: 22.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                    SizedBox(height: 12.wMin),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16.wMin,
                        crossAxisSpacing: 16.wMin,
                        mainAxisExtent: 112.wMin,
                      ),
                      itemCount: controller.styleList.length,
                      itemBuilder: (context, index) {
                        return _buildMainStyleItemWidget(controller.styleList[index]);
                      },
                    ),
                  ],
                ),
              ),
              _buildPreviewWidget(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeItemWidget({
    required ResourceTypeEnum mode,
    required String tag,
    required String desc,
  }) {
    bool selected = mode == controller.resourceType.value;
    String iconRadio = "assets/svg/public/icon_radio2.svg";
    if (controller.resourceType.value == ResourceTypeEnum.video) {
      iconRadio = "assets/svg/public/icon_radio1.svg";
    }

    return Expanded(
      child: TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() {
          controller.switchMode(mode);
        }, 1000),
        sclae: 1,
        child: Container(
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.wMin),
            color: selected ? mode.color.withValues(alpha: 0.12) : Colors.transparent,
            border: Border.all(
              color: selected ? mode.color.withValues(alpha: 0.2) : AppTheme.cBorderSubtle.color,
              width: 0.8.wMin,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64.wMin,
                height: 64.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: selected ? mode.color.withValues(alpha: 0.12) : AppTheme.cSurfaceLayerElevated.color,
                  border: Border.all(
                    color: selected ? mode.color.withValues(alpha: 0.2) : AppTheme.cBorderDefault.color,
                    width: 0.8.wMin,
                  ),
                ),
                child: SvgPicture.asset(
                  mode.svg,
                  width: 40.wMin,
                  colorFilter: ColorFilter.mode(
                    selected ? mode.color : AppTheme.cTextPrimary.color,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 16.wMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${mode.name}模式",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4.wMin),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 4.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.wMin),
                            color: mode.color.withValues(alpha: 0.12),
                            border: Border.all(
                              color: mode.color.withValues(alpha: 0.2),
                              width: 0.8.wMin,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: mode.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        SvgPicture.asset(
                          selected ? iconRadio : "assets/svg/public/icon_radio_un.svg",
                          width: 24.wMin,
                        ),
                      ],
                    ),
                    SizedBox(height: 6.wMin),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextSecondary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainStyleItemWidget(TeamStyleEntityStyleItems item) {
    bool selected = item.style == controller.mainStyleCode.value;
    bool isAvailable = controller.isStyleAvailable(item);
    LanguageText? styleTitle = LearningLangUtils.getLocalLang(item.styleTitle);
    LanguageText? styleDesc = LearningLangUtils.getLocalLang(item.styleDesc);
    return TapScaleWidget(
      onTap: !isAvailable ? null : OptimizeUtils.noneThrottle(() {
        controller.selectMainStyle(item);
      }, 1000),
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.wMin),
          color: !isAvailable
              ? null
              : selected
                  ? controller.resourceType.value.color.withValues(alpha: 0.12)
                  : null,
          border: Border.all(
            color: !isAvailable
                ? AppTheme.cBorderSubtle.color
                : selected
                    ? controller.resourceType.value.color.withValues(alpha: 0.2)
                    : AppTheme.cBorderSubtle.color,
            width: 0.8.wMin,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      styleTitle?.text ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w500,
                        color: !isAvailable ? AppTheme.cTextTertiary : AppTheme.cTextPrimary.color,
                      ),
                    ),
                  ),
                  if (!isAvailable && (item.statusHint ?? '').isNotEmpty) ...[
                    SizedBox(width: 8.wMin),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999.wMin),
                        color: AppTheme.cSurfaceTranslucentElevated,
                        border: Border.all(
                          color: AppTheme.cBorderTranslucentThin,
                          width: 0.8.wMin,
                        ),
                      ),
                      child: Text(
                        item.statusHint ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextTertiary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12.wMin),
              Text(
                styleDesc?.text ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: !isAvailable ? AppTheme.cTextDisabled : AppTheme.cTextSecondary.color,
                ),
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildPreviewWidget() {
    TeamStyleEntityStyleItems? item = controller.getMainStyleItem();
    return _UserVisualStylePreviewWidget(
      item: item,
      resourceType: controller.resourceType.value,
    );
  }

  Widget _buildMixSectionWidget() {
    return Container(
      padding: EdgeInsets.only(top: 24.wMin),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "风格混搭",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.wMin),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999.wMin),
                            border: Border.all(
                              color: AppTheme.cBorderSubtle.color,
                              width: 0.8.wMin,
                            ),
                          ),
                          child: Text(
                            "仅做题",
                            style: TextStyle(
                              fontSize: 14.wMin,
                              color: AppTheme.cTextTertiary.color,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.wMin),
                    Text(
                      "以主风格为主，穿插其他画风。同一个意思换个场景再遇到，更不枯燥，也更容易用到真实生活里。",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        height: 1.5,
                        color: AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.wMin),
              _buildMixSwitchWidget(),
            ],
          ),
          Obx(() {
            if (!controller.isMediaMix.value) return Container();
            List<TeamStyleEntityStyleItems> availableStyleList = controller.getAvailableStyleList();
              availableStyleList.sort((a, b) {
                if (a.style == controller.mainStyleCode.value) return -1;
                if (b.style == controller.mainStyleCode.value) return 1;
                return 0;
              });
            return Container(
              margin: EdgeInsets.only(top: 20.wMin),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 96.wMin,
                    margin: EdgeInsets.only(top: 2.wMin),
                    child: Text(
                      "一起混搭",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 24.wMin,
                      runSpacing: 12.wMin,
                      children: List.generate(availableStyleList.length, (index) {
                        return _buildMixOptionWidget(availableStyleList[index]);
                      }),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMixSwitchWidget() {
    return Obx(() {
      bool enabled = controller.isMediaMix.value;
      return CardSwitchWidget(
         switchInactiveColor:AppTheme.cBorderSecondary,
        value: enabled,
        onChanged: (value) {
          controller.switchMediaMix(value);
        },
      );
    });
  }

  Widget _buildMixOptionWidget(TeamStyleEntityStyleItems item) {
    String styleCode = item.style ?? "";
    bool isMainStyle = styleCode == controller.mainStyleCode.value;
    bool checked = controller.mixStyleCodeList.contains(styleCode);
    LanguageText? styleTitle = LearningLangUtils.getLocalLang(item.styleTitle);
    return TapScaleWidget(
      onTap: isMainStyle ? null : OptimizeUtils.noneThrottle(() {
        controller.toggleMixStyle(item);
      }, 1000),
      sclae: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IgnorePointer(
            child: Checkbox(
              value: checked,
              side: BorderSide(
                color: AppTheme.cBorderTranslucentSubtle.color,
                width: 1.5.wMin,
              ),
              activeColor: AppTheme.cBgBrand.color,
              checkColor: Colors.white,
              overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (_) {},
            ),
          ),
          SizedBox(width: 8.wMin),
          Text(
            styleTitle?.text ?? "",
            style: TextStyle(
              fontSize: 18.wMin,
              color: isMainStyle ? AppTheme.cTextPrimary.color : AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (isMainStyle) ...[
            SizedBox(width: 8.wMin),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999.wMin),
                border: Border.all(
                  color: AppTheme.cBorderSubtle.color,
                  width: 0.8.wMin,
                ),
              ),
              child: Text(
                "主风格",
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UserVisualStylePreviewWidget extends StatefulWidget {
  final TeamStyleEntityStyleItems? item;
  final ResourceTypeEnum resourceType;

  const _UserVisualStylePreviewWidget({
    required this.item,
    required this.resourceType,
  });

  @override
  State<_UserVisualStylePreviewWidget> createState() => _UserVisualStylePreviewWidgetState();
}

class _UserVisualStylePreviewWidgetState extends State<_UserVisualStylePreviewWidget> {
  final Player player = Player();
  late VideoController videoController;

  bool isPlaying = false;
  bool isVideoReady = false;
  bool isPlayVideo = false;

  @override
  void initState() {
    super.initState();
    videoController = VideoController(player);
    _listenVideo();
    _setVideoResource();
  }

  @override
  void didUpdateWidget(covariant _UserVisualStylePreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resourceType != widget.resourceType ||
        oldWidget.item?.style != widget.item?.style ||
        oldWidget.item?.video?.videoUrl != widget.item?.video?.videoUrl) {
      _setVideoResource();
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void _listenVideo() {
    player.stream.playing.listen((e) {
      isPlaying = e;
      if (mounted) setState(() {});
    });
    player.stream.position.listen((e) {
      isPlayVideo = e > Duration.zero;
      if (mounted) setState(() {});
    });
    player.stream.completed.listen((e) async {
      if (!e) return;
      isPlaying = false;
      isPlayVideo = false;
      await player.pause();
      await player.seek(Duration.zero);
      if (mounted) setState(() {});
    });
  }

  Future<void> _setVideoResource() async {
    isVideoReady = false;
    isPlaying = false;
    isPlayVideo = false;
    await player.pause();
    await player.seek(Duration.zero);
    if (widget.resourceType != ResourceTypeEnum.video) {
      if (mounted) setState(() {});
      return;
    }
    String videoUrl = widget.item?.video?.videoUrl ?? '';
    if (videoUrl.isEmpty) {
      if (mounted) setState(() {});
      return;
    }
    if (mounted) setState(() {});
    String? fileUrl = await CacheManagerUtils.instance.getFile(videoUrl, ResourceType.video);
    if (!mounted || fileUrl == null) return;
    await player.open(Media(fileUrl), play: false);
    isVideoReady = true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = "";
    if (widget.item != null) {
      imageUrl = widget.resourceType == ResourceTypeEnum.video
          ? (widget.item?.video?.firstFrameUrl ?? "")
          : (widget.item?.image?.imageUrl ?? "");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "最终视觉展示区",
          style: TextStyle(
            fontSize: 22.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        SizedBox(height: 10.wMin),
        IgnorePointer(
          ignoring: widget.resourceType != ResourceTypeEnum.video || !isVideoReady,
          child: TapScaleWidget(
            onTap: () {
              if (widget.resourceType != ResourceTypeEnum.video || !isVideoReady) return;
              player.playOrPause();
            },
            sclae: 1,
            child: Container(
              width: 400.wMin,
              height: 400.wMin,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cSurfaceLayerBase.color,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Video(
                    controller: videoController,
                    fill: Colors.transparent,
                    controls: (state) => Container(),
                  ),
                  IgnorePointer(
                    ignoring: true,
                    child: Opacity(
                      opacity: isPlaying || isPlayVideo ? 0 : 1,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: CachedImageWidget(
                          imageUrl,
                          errorWidget: buildEmptyWidget(),
                          placeholder: buildLoadingWidget(),
                          key: ValueKey("${widget.resourceType.name}_${widget.item?.style}_$imageUrl"),
                        ),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    ignoring: true,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: (widget.resourceType == ResourceTypeEnum.video && isVideoReady && !isPlaying) ? 1 : 0,
                      child: Container(
                        padding: EdgeInsets.all(16.wMin),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 60.wMin,
                          color: Colors.white,
                        ),
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
}
