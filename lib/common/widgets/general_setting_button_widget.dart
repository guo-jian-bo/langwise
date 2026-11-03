

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';
import '../enum/enum.dart';
import '../public_controller/config_controller.dart';
import '../values/values.dart';

class GeneralSettingButtonWidget extends StatefulWidget {
  final bool hideTranslationOption;

  /// 通用设置按钮
  const GeneralSettingButtonWidget({
    super.key,
    this.hideTranslationOption = false,
  });

  @override
  State<GeneralSettingButtonWidget> createState() => _GeneralSettingButtonWidgetState();
}

class _GeneralSettingButtonWidgetState extends State<GeneralSettingButtonWidget> {


  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: () {
        GeneralSettingDialog.showSetting(
          context,
          hideTranslationOption: widget.hideTranslationOption,
        );
      },
      sclae: 1,
      child: Container(
        height: 56.wMin,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: AppTheme.cSurfaceLayerElevated.color,
        ),
        child: _buildSettingWidget(),
      ),
    );
  }

  Widget _buildSettingWidget(){
    return Obx((){
      ConfigController controller = Get.find<ConfigController>();
      // 以下需要从ConfigController获取
      String pronunciationCode = controller.userSetting.value.expandPronunciationCode;
      LanguageServiceCodeEnum languageServiceCode = LanguageServiceCodeEnum.fromValue(pronunciationCode);
      double playSpeed = controller.userSetting.value.expandAudioSpeed;
      LangPreference? langPreference = controller.userSetting.value.expandLang;
      if (widget.hideTranslationOption && langPreference == LangPreference.translation) {
        langPreference = LangPreference.bilingual;
      }
      ResourceTypeEnum currentShowResource = controller.currentShowResource.value;
      String currentShowStyleName = controller.getCurrentStyleName(controller.currentShowStyleCode.value);
    
      return Row(
        children: [
          _buildSettingTextWidget(languageServiceCode.text),
          _buildDivWidget(),
          _buildSettingTextWidget(langPreference.name),
          _buildDivWidget(),
          _buildSettingTextWidget("倍速 ${playSpeed}X"),
          _buildDivWidget(),
          _buildSettingTextWidget("${currentShowResource.name}·$currentShowStyleName"),
          _buildIconWidget(),
        ],
      );
    });
  }

  Widget _buildSettingTextWidget(String text){
    return Text(
      text,
      style: TextStyle(
        fontSize: 24.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cTextSecondary.color,
      ),
    );
  }
  
  Widget _buildDivWidget(){
    return Text(
      " ｜ ",
      style: TextStyle(
        fontSize: 24.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cTextSecondary.color,
      ),
    );
  }

  Widget _buildIconWidget(){
    return Container(
      margin: EdgeInsets.only(left: 16.wMin),
      child: SvgPicture.asset(
        "assets/svg/public/icon_caret_down.svg",
        width: 24.wMin,
        colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
      ),
    );
  }

}


class GeneralSettingDialog{
  static Future<void> showSetting(
    BuildContext context, {
    bool hideTranslationOption = false,
  }) async{
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return GeneralSettingDialogWidget(
          hideTranslationOption: hideTranslationOption,
        );
      },
    );
  }

}


class GeneralSettingDialogWidget extends StatefulWidget {
  final bool hideTranslationOption;

  const GeneralSettingDialogWidget({
    super.key,
    this.hideTranslationOption = false,
  });

  @override
  State<GeneralSettingDialogWidget> createState() => _GeneralSettingDialogWidgetState();
}

class _GeneralSettingDialogWidgetState extends State<GeneralSettingDialogWidget> {
  final ConfigController controller = Get.find<ConfigController>();

  /// 发音模式
  final List<LanguageServiceCodeEnum> pronunciationList = LanguageServiceCodeEnum.values.toList();
  /// 选中的发音模式
  LanguageServiceCodeEnum selectPronunciation = LanguageServiceCodeEnum.US;

  /// 文本显示列表
  List<UserPreferenceDefinitionDisplayModeOption> expandDropdownMenu = [];
  /// 选中的文本显示
  LangPreference selectLangPreference = LangPreference.bilingual;

  /// 倍速列表
  List<double> speedList = [];

  /// 当前倍速
  double currentSpeed = 1.0;

  /// 选中的模式
  ResourceTypeEnum selectMode = ResourceTypeEnum.image;

  /// 所有风格列表
  List<TeamStyleEntityStyleItems> styleList = <TeamStyleEntityStyleItems>[];
  /// 选中的风格
  late String selectStyle;

  Player player = Player();
  late VideoController videoController;
  /// 是否正在播放视频
  bool isPlaying = false;
  /// 是否准备好视频资源
  bool isVideoReady = false;
  /// 视频是否正在播放中
  bool isPlayVideo = false;

  @override
  void initState() {
    super.initState();
    
    videoController = VideoController(player);
    listenVideo();
    initData();
  }

  Future<void> initData() async{
    speedList = controller.userSetting.value.expandAudioSpeedList;
    currentSpeed = controller.userSetting.value.expandAudioSpeed;
    selectLangPreference = controller.userSetting.value.expandLang;
    if (widget.hideTranslationOption && selectLangPreference == LangPreference.translation) {
      selectLangPreference = LangPreference.bilingual;
    } else if (selectLangPreference == LangPreference.none) {
      selectLangPreference = LangPreference.original;
    }
    expandDropdownMenu = (controller.userSetting.value.expandDropdownMenu ?? [])
        .where((e) =>
            e.code != LangPreference.none.code &&
            (!widget.hideTranslationOption || e.code != LangPreference.translation.code))
        .toList();
    selectPronunciation = LanguageServiceCodeEnum.fromValue(controller.userSetting.value.expandPronunciationCode);
    selectMode = controller.currentShowResource.value;
    selectStyle = controller.currentShowStyleCode.value;

    if (selectMode == ResourceTypeEnum.image) {
      styleList = controller.allStyleImageList.toList();
    } else {
      styleList = controller.allStyleVideoList.toList();
    }

    setVideoResource();
  }

  /// 监听视频播放
  void listenVideo(){
    player.stream.playing.listen((e){
      isPlaying = e;
      if(mounted) setState(() {});
    });
    player.stream.position.listen((e){
      isPlayVideo = e > Duration.zero;
      if(mounted) setState(() {});
    });
    player.stream.completed.listen((e) async{
      if(e){
        isPlaying = false;
        isPlayVideo = false;
        await player.pause();
        await player.seek(Duration.zero);
        if(mounted) setState(() {});
      }
    });
  }

  /// 设置视频资源
  Future<void> setVideoResource() async{
    await player.pause();
    await player.seek(Duration.zero);

    if(selectMode == ResourceTypeEnum.image) return;
    TeamStyleEntityStyleItems? item = styleList.firstWhereOrNull((element) => element.style == selectStyle);
    if(item == null) return;
    String videoUrl = item.video?.videoUrl??'';
    if(videoUrl.isEmpty) return;
    isVideoReady = false;
    String? fileUrl = await CacheManagerUtils.instance.getFile(videoUrl, ResourceType.video);
    if(fileUrl == null) return;
    await player.open(Media(fileUrl), play: false);
    isVideoReady = true;
    if(mounted) setState(() {});
  }


  /// 重置
  void reset(){
    initData();
    if(mounted) setState(() {});
  }

  /// 保存
  void save(){
    controller.setUserSetting(
      expandPronunciationCode: selectPronunciation.value,
      expandTranslationType: selectLangPreference.code,
      expandAudioSpeed: currentSpeed,
    );
    controller.changeCurrentShowResource(selectMode);
    controller.changeCurrentStyleCode(selectStyle);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "设置",
      width: 1200.wMin,
      titlePadding: EdgeInsets.only(
        left: 32.wMin,
        right: 32.wMin,
        top: 24.wMin,
        bottom: 10.wMin,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 800.wMin,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 32.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPronunciationWidget(),
                  _buildDivWidget(),
                  _buildTextDisplayWidget(),
                  _buildDivWidget(),
                  _buildSpeedWidget(),
                  _buildDivWidget(),
                  _buildVisualWidget(),
                ],
              ),
            ),
          ),
          Container(
            height: 1.wMin,
            color: AppTheme.cBorderPrimary.color,
          ),
          _buildButtonsWidget(),
        ],
      ),
    );
  }

  /// 发音
  Widget _buildPronunciationWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 24.wMin),
      child: Row(
        children: [
          _buildTitleWidget("发音"),
          Row(
            spacing: 12.wMin,
            children: List.generate(pronunciationList.length, (index){
              bool selected = selectPronunciation == pronunciationList[index];
              return _buildTapWidget(
                text: pronunciationList[index].text,
                selected: selected,
                onTap: () {
                  // controller.setUserSetting(
                  //   expandPronunciationCode: LanguageServiceCodeEnum.values[index].value,
                  // );
                  selectPronunciation = pronunciationList[index];
                  if(mounted) setState(() {});
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 文本显示
  Widget _buildTextDisplayWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 24.wMin),
      child: Row(
        children: [
          _buildTitleWidget("文本显示"),
          Row(
            spacing: 12.wMin,
            children: List.generate(expandDropdownMenu.length, (index){
              bool selected = selectLangPreference.code == expandDropdownMenu[index].code;
              return _buildTapWidget(
                text: expandDropdownMenu[index].title??'',
                selected: selected,
                onTap: () {
                  // controller.setUserSetting(
                  //   expandTranslationType: expandDropdownMenu[index].code,
                  // );
                  selectLangPreference = LangPreference.fromRawValue(expandDropdownMenu[index].code);
                  if(mounted) setState(() {});
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 倍速
  Widget _buildSpeedWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 24.wMin),
      child: Row(
        children: [
          _buildTitleWidget("倍速"),
          Wrap(
            spacing: 8.wMin,
            runSpacing: 6.wMin,
            children: List.generate(speedList.length, (index){
              bool selected = currentSpeed == speedList[index];
              return _buildTapWidget(
                text: "${speedList[index].toString()}x",
                selected: selected,
                onTap: () {
                  // controller.setUserSetting(
                  //   expandAudioSpeed: speedList[index],
                  // );
                  currentSpeed = speedList[index];
                  if(mounted) setState(() {});
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 视觉模式
  Widget _buildVisualWidget(){

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
      child: Column(
        children: [
          Row(
            children: [
              _buildTitleWidget("视觉模式"),
              Text(
                "模式优先：当切到视频模式时，如果选定的画风没有视频会优先展示其他画风的视频，如果没有才会显示当前风格的图片。",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.wMin),
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
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                    SizedBox(height: 10.wMin),
                    IntrinsicHeight(
                      child: Row(
                        spacing: 12.wMin,
                        children: [
                          _buildVisualModeItemWidget(
                            mode: ResourceTypeEnum.image,
                            tag: "快速学习",
                            desc: "精美高光图片，瞬间捕捉语义",
                            selected: selectMode == ResourceTypeEnum.image,
                          ),
                          _buildVisualModeItemWidget(
                            mode: ResourceTypeEnum.video,
                            tag: "推荐·沉浸体验",
                            desc: "真实语境演绎，把母语场景带到身边",
                            selected: selectMode == ResourceTypeEnum.video,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.wMin),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "画面偏好",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextSecondary.color,
                          ),
                        ),
                        Text(
                          "优先用这个，没有就自动换",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextSecondary.color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.wMin),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16.wMin,
                        crossAxisSpacing: 16.wMin,
                        mainAxisExtent: 100.wMin,
                      ),
                      itemCount: styleList.length,
                      itemBuilder: (context, index){
                        return _buildVisualStyleItemWidget(styleList[index]);
                      },
                    ),

                  ],
                ),
              ),
              _buildVisualImageWidget(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisualModeItemWidget({
    required ResourceTypeEnum mode,
    required String tag,
    required String desc,
    bool selected = false,
  }){
    String iconRadio = "assets/svg/public/icon_radio2.svg";
    if(mode == ResourceTypeEnum.video){
      iconRadio = "assets/svg/public/icon_radio1.svg";
    }
    return Expanded(
      child: TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() {
          selectMode = mode;
          if (selectMode == ResourceTypeEnum.image) {
            styleList = controller.allStyleImageList.toList();
          } else {
            styleList = controller.allStyleVideoList.toList();
          }

          final bool hasSelectedStyle = styleList.any((e) => e.style == selectStyle);
          if (!hasSelectedStyle) {
            selectStyle = styleList.firstOrNull?.style ?? "";
          }
          if (mounted) setState(() {});
          setVideoResource();
        }, 1000),
        sclae: 1,
        child: Container(
          padding: EdgeInsets.all(12.wMin),
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
              SizedBox(width: 10.wMin),
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
                    SizedBox(height: 4.wMin),
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

  Widget _buildVisualStyleItemWidget(TeamStyleEntityStyleItems item){
    bool selected = item.style == selectStyle;
    LanguageText? styleTitle = LearningLangUtils.getLocalLang(item.styleTitle);
    LanguageText? styleDesc = LearningLangUtils.getLocalLang(item.styleDesc);
    return TapScaleWidget(
      onTap: () {
        if(item.style == null) return;
        selectStyle = item.style??'';
        if(mounted) setState(() {});
        setVideoResource();
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.wMin),
          color: selected ? selectMode.color.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
            color: selected ? selectMode.color.withValues(alpha: 0.2) : AppTheme.cBorderSubtle.color,
            width: 0.8.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              styleTitle?.text??'',
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            Text(
              styleDesc?.text??'',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualImageWidget(){
    // 当前选择的风格
    final TeamStyleEntityStyleItems? selectedStyle = styleList.firstWhereOrNull((e) => e.style == selectStyle);

    String imageUrl = selectedStyle?.image?.imageUrl ?? "";
    if(selectMode == ResourceTypeEnum.video){
      imageUrl = selectedStyle?.video?.firstFrameUrl ?? "";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "最终视觉展示区",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        SizedBox(height: 10.wMin),
        IgnorePointer(
          ignoring: selectMode != ResourceTypeEnum.video || !isVideoReady,
          child: TapScaleWidget(
            onTap: () {
              if(selectMode != ResourceTypeEnum.video || !isVideoReady) return;
              player.playOrPause();
            },
            sclae: 1,
            child: Container(
              width: 280.wMin,
              height: 280.wMin,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
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
                          key: ValueKey(imageUrl),
                        ),
                      ),
                    ),
                  ),
            
                  IgnorePointer(
                    ignoring: true,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: (selectMode == ResourceTypeEnum.video && isVideoReady && !isPlaying) ? 1 : 0,
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

  Widget _buildButtonsWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ButtonWidget(
            text: "重置",
            width: 120.wMin,
            height: 60.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceLayerElevated.color,
            fontColor: AppTheme.cTextSecondary.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            leftIcon: Container(
              margin: EdgeInsets.only(right: 4.wMin),
              child: SvgPicture.asset(
                "assets/svg/public/icon_reset.svg",
                width: 24.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
              ),
            ),
            onTap: () {
              reset();
            },
          ),
          ButtonWidget(
            text: "确认",
            width: 120.wMin,
            height: 60.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceBrand.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: () {
              save();
            },
          ),
        ],
      ),
    );
  }


  Widget _buildTapWidget({
    required String text,
    bool selected = false,
    required Function()? onTap,
  }){
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: selected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.1) : AppTheme.cSurfaceBlurSubtle.color,
          border: Border.all(
            color: selected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2) : AppTheme.cBorderSubtle.color,
            width: 0.8.wMin,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            color: selected ? AppTheme.cSurfaceBrand.color : AppTheme.cTextSecondary.color,
          ),
        ),
      ),
    );
  }


  Widget _buildTitleWidget(String text){
    return SizedBox(
      width: 110.wMin,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextPrimary.color,
        ),
      ),
    );
  }

  Widget _buildDivWidget(){
    return Container(
      height: 0.8.wMin,
      color: AppTheme.cBorderPrimary.color,
    );
  }




}
