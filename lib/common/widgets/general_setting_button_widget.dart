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
import '../../app/modules/management/controllers/manage_setting_controller.dart';
import '../../app/routes/routes.dart';
import '../../app/routes/tag_routes.dart';
import '../entities/entities.dart';
import '../enum/enum.dart';
import '../https/https.dart';
import '../mixins/mixins.dart';
import '../public_controller/config_controller.dart';
import '../stores/user.dart';
import '../values/values.dart';

enum GeneralSettingGroup {
  /// 发音
  pronunciation,
  /// 文本显示
  textDisplay,
  /// 倍速
  speed,
  /// 视觉
  visual,
}

class GeneralSettingButtonWidget extends StatefulWidget {
  /// 显示的设置组 默认显示所有设置组
  final List<GeneralSettingGroup>? groups;
  final bool isManagement;

  /// * 通用设置按钮
  /// * 设置改变后会通知[PageRefreshAwareMixin]，页面在控制器中with PageRefreshAwareMixin，重写[onReturnPageRefresh]方法，在方法中调用刷新页面方法
  const GeneralSettingButtonWidget({
    super.key,
    this.groups,
    this.isManagement = false,
  });

  @override
  State<GeneralSettingButtonWidget> createState() => _GeneralSettingButtonWidgetState();
}

class _GeneralSettingButtonWidgetState extends State<GeneralSettingButtonWidget> {
  List<GeneralSettingGroup> get groups => widget.groups ?? GeneralSettingGroup.values;

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: () async {
        bool res = await GeneralSettingDialog.showSetting(
          context,
          groups: widget.groups,
          isManagement: widget.isManagement,
        );
        if (res) {}
      },
      sclae: 1,
      child: Container(
        height: 56.wMin,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999.wMin),
          color: AppTheme.cBgSecondary.color,
          border: Border.all(
            color: AppTheme.cBorderPrimary.color,
          ),
        ),
        child: _buildSettingWidget(),
      ),
    );
  }

  Widget _buildSettingWidget() {
    return Obx(() {
      ConfigController controller = Get.find<ConfigController>();
      String pronunciationCode = controller.userSetting.value.expandPronunciationCode;
      LanguageServiceCodeEnum languageServiceCode = LanguageServiceCodeEnum.fromValue(pronunciationCode);
      double playSpeed = controller.userSetting.value.expandAudioSpeed;
      LangPreference? langPreference = controller.userSetting.value.expandLang;
      List<Widget> children = [];

      if (groups.contains(GeneralSettingGroup.pronunciation)) {
        children.add(_buildSettingTextWidget(languageServiceCode.text));
      }
      if (groups.contains(GeneralSettingGroup.textDisplay)) {
        if (children.isNotEmpty) children.add(_buildDivWidget());
        children.add(_buildSettingTextWidget(langPreference.name));
      }
      if (groups.contains(GeneralSettingGroup.speed)) {
        if (children.isNotEmpty) children.add(_buildDivWidget());
        children.add(_buildSettingTextWidget("倍速 ${playSpeed}X"));
      }
      if (groups.contains(GeneralSettingGroup.visual)) {
        if (children.isNotEmpty) children.add(_buildDivWidget());
        children.add(_buildSettingTextWidget(_getVisualSummaryText(controller)));
      }
      if (children.isNotEmpty) {
        children.add(_buildIconWidget());
      }

      return Row(
        children: children,
      );
    });
  }

  /// 获取当前场景的视觉模式摘要文案
  String _getVisualSummaryText(ConfigController controller) {
    if (!widget.isManagement) {
      ResourceTypeEnum currentShowResource = controller.currentShowResource.value;
      String currentShowStyleName = controller.getCurrentStyleName(controller.currentShowStyleCode.value);
      return "${currentShowResource.name}·$currentShowStyleName";
    }
    final ManageSettingController manageController = Get.find<ManageSettingController>();
    String areaName = manageController.getCurrentStyleAreaName() ?? "";
    return "${manageController.defaultResources.value.name}·${manageController.selectedStyleKey.value}·$areaName";
  }

  Widget _buildSettingTextWidget(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 24.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cTextSecondary.color,
      ),
    );
  }

  Widget _buildDivWidget() {
    return Text(
      " ｜ ",
      style: TextStyle(
        fontSize: 24.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cTextSecondary.color,
      ),
    );
  }

  Widget _buildIconWidget() {
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

class GeneralSettingDialog {
  static Future<bool> showSetting(
    BuildContext context, {
    List<GeneralSettingGroup>? groups,
    bool isManagement = false,
  }) async {
    bool shouldFetchVisual = !isManagement && (groups == null || groups.contains(GeneralSettingGroup.visual));
    if (shouldFetchVisual) {
      ConfigController controller = Get.find<ConfigController>();
      await controller.getUserStyleList();
      controller.initUserStyleList();
    }
    if (!context.mounted) return false;
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return GeneralSettingDialogWidget(
          groups: groups,
          isManagement: isManagement,
        );
      },
    );
    return res ?? false;
  }
}

class GeneralSettingDialogWidget extends StatefulWidget {
  final List<GeneralSettingGroup>? groups;
  final bool isManagement;

  const GeneralSettingDialogWidget({
    super.key,
    this.groups,
    this.isManagement = false,
  });

  @override
  State<GeneralSettingDialogWidget> createState() => _GeneralSettingDialogWidgetState();
}

class _GeneralSettingDialogWidgetState extends State<GeneralSettingDialogWidget> {
  final ConfigController controller = Get.find<ConfigController>();
  ManageSettingController get manageController => Get.find<ManageSettingController>();

  List<GeneralSettingGroup> get groups => widget.groups ?? GeneralSettingGroup.values;

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

  /// 主风格
  String mainStyleUse = '';

  /// 是否开启混搭
  bool isMediaMix = false;

  /// 混搭风格集合
  List<String> mixStyleCodes = <String>[];

  /// 管理端地区列表
  List<ImageStyleConfigV2Item> manageStyleAreaList = <ImageStyleConfigV2Item>[];

  /// 管理端风格列表
  List<String> manageStyleKeyList = <String>[];

  /// 管理端选中的画风
  String selectedManageStyleKey = '';

  /// 管理端选中的地区
  String selectedManageStyleAreaCode = '';

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

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  Future<void> initData() async {
    speedList = controller.userSetting.value.expandAudioSpeedList;
    currentSpeed = controller.userSetting.value.expandAudioSpeed;
    selectLangPreference = controller.userSetting.value.expandLang;
    expandDropdownMenu = (controller.userSetting.value.expandDropdownMenu ?? []);
    selectPronunciation = LanguageServiceCodeEnum.fromValue(controller.userSetting.value.expandPronunciationCode);
    if (widget.isManagement) {
      selectMode = manageController.defaultResources.value;
      manageStyleAreaList = await manageController.getStyleAreaList();
      manageStyleKeyList = await manageController.getStyleKeyList();
      selectedManageStyleKey = manageController.selectedStyleKey.value;
      selectedManageStyleAreaCode = manageController.selectedStyleAreaCode.value;
    } else {
      selectMode = controller.currentShowResource.value;
      mainStyleUse = controller.originalStyleData.value.mainStyleUse ?? controller.currentShowStyleCode.value;
      selectStyle = mainStyleUse;
      isMediaMix = controller.originalStyleData.value.isMediaMix == true;
      mixStyleCodes = [];
      List<String?> imageStyleUses = controller.originalStyleData.value.imageStyleUses ?? [];
      for (int i = 0; i < imageStyleUses.length; i++) {
        String? code = imageStyleUses[i];
        if (code == null || code.isEmpty || mixStyleCodes.contains(code)) continue;
        mixStyleCodes.add(code);
      }
      if (selectMode == ResourceTypeEnum.image) {
        styleList = controller.allStyleImageList.toList();
      } else {
        styleList = controller.allStyleVideoList.toList();
      }
      final bool hasSelectedStyle = styleList.any((e) => e.style == selectStyle);
      if (!hasSelectedStyle) {
        selectStyle = styleList.firstOrNull?.style ?? "";
      }
      mainStyleUse = selectStyle;
      sanitizeMixStyleCodes();
      await setVideoResource();
    }
    if (mounted) setState(() {});
  }

  /// 监听视频播放
  void listenVideo() {
    player.stream.playing.listen((e) {
      isPlaying = e;
      if (mounted) setState(() {});
    });
    player.stream.position.listen((e) {
      isPlayVideo = e > Duration.zero;
      if (mounted) setState(() {});
    });
    player.stream.completed.listen((e) async {
      if (e) {
        isPlaying = false;
        isPlayVideo = false;
        await player.pause();
        await player.seek(Duration.zero);
        if (mounted) setState(() {});
      }
    });
  }

  /// 设置视频资源
  Future<void> setVideoResource() async {
    if (widget.isManagement) return;
    await player.pause();
    await player.seek(Duration.zero);

    if (selectMode == ResourceTypeEnum.image) return;
    TeamStyleEntityStyleItems? item = styleList.firstWhereOrNull((element) => element.style == selectStyle);
    if (item == null) return;
    String videoUrl = item.video?.videoUrl ?? '';
    if (videoUrl.isEmpty) return;
    isVideoReady = false;
    String? fileUrl = await CacheManagerUtils.instance.getFile(videoUrl, ResourceType.video);
    if (fileUrl == null) return;
    await player.open(Media(fileUrl), play: false);
    player.setRate(currentSpeed);
    isVideoReady = true;
    if (mounted) setState(() {});
  }

  void sanitizeMixStyleCodes() {
    List<String> validStyleCodes = [];
    for (int i = 0; i < styleList.length; i++) {
      String? styleCode = styleList[i].style;
      if (styleCode == null || styleCode.isEmpty || validStyleCodes.contains(styleCode)) continue;
      validStyleCodes.add(styleCode);
    }
    mixStyleCodes.removeWhere((code) => !validStyleCodes.contains(code));
    if (selectStyle.isNotEmpty && validStyleCodes.contains(selectStyle) && !mixStyleCodes.contains(selectStyle)) {
      mixStyleCodes.add(selectStyle);
    }
  }

  String getSavedMixSummaryText() {
    bool savedIsMediaMix = controller.originalStyleData.value.isMediaMix == true;
    if (!savedIsMediaMix) return "已关闭";

    ResourceTypeEnum savedMode = controller.originalStyleData.value.mediaModeUse == 1
        ? ResourceTypeEnum.video
        : ResourceTypeEnum.image;
    List<String> validStyleCodes = [];
    List<TeamStyleEntityStyleItems?> originalStyleItems = controller.originalStyleData.value.styleItems ?? [];
    for (int i = 0; i < originalStyleItems.length; i++) {
      TeamStyleEntityStyleItems? item = originalStyleItems[i];
      if (item == null) continue;
      bool isAvailable = savedMode == ResourceTypeEnum.video ? item.videoStatus == 1 : item.imageStatus == 1;
      String? styleCode = item.style;
      if (!isAvailable || styleCode == null || styleCode.isEmpty || validStyleCodes.contains(styleCode)) continue;
      validStyleCodes.add(styleCode);
    }

    List<String> savedMixStyleCodes = [];
    List<String?> imageStyleUses = controller.originalStyleData.value.imageStyleUses ?? [];
    for (int i = 0; i < imageStyleUses.length; i++) {
      String? code = imageStyleUses[i];
      if (code == null || code.isEmpty || !validStyleCodes.contains(code) || savedMixStyleCodes.contains(code)) continue;
      savedMixStyleCodes.add(code);
    }

    String savedMainStyleUse = controller.originalStyleData.value.mainStyleUse ?? controller.currentShowStyleCode.value;
    if (savedMainStyleUse.isNotEmpty &&
        validStyleCodes.contains(savedMainStyleUse) &&
        !savedMixStyleCodes.contains(savedMainStyleUse)) {
      savedMixStyleCodes.add(savedMainStyleUse);
    }
    return "已开启 · ${savedMixStyleCodes.length} 种画风";
  }

  /// 重置
  void reset() {
    initData();
    if (mounted) setState(() {});
  }

  /// 保存
  Future<void> save() async {
    bool isChanged = settingChanged();
    controller.setUserSetting(
      expandPronunciationCode: selectPronunciation.value,
      expandTranslationType: selectLangPreference.code,
      expandAudioSpeed: currentSpeed,
    );
    if (widget.isManagement) {
      manageController.switchResources(selectMode);
      manageController.setStyleIdByStyleKeyAndAreaCode(selectedManageStyleKey, selectedManageStyleAreaCode);
    } else {
      bool styleRes = await saveUserVisualPreference();
      if (!styleRes) return;
      controller.changeCurrentShowResource(selectMode);
      controller.changeCurrentStyleCode(selectStyle);
    }
    await editConfig();
    if (isChanged) {
      PageRefreshAwareMixin.notifyPageRefresh();
    }
    Get.back(result: true);
  }

  /// 编辑配置
  Future<void> editConfig() async {
    String userNational = UserStore.to.userInfo.value.config?.national ?? '';
    if (userNational == selectPronunciation.value) return;
    try {
      Map<String, dynamic> data = {
        "national": selectPronunciation.value,
      };
      bool res = await UserRequest.editUserTeamMemberConfig(data);
      if(!res) return;
      controller.getConfig();
    } catch (_) {}
  }

  Future<bool> saveUserVisualPreference() async {
    if (selectStyle.isEmpty) {
      ToastUtils.showToast(text: "请选择主风格");
      return false;
    }
    sanitizeMixStyleCodes();
    List<String> savedMixStyleCodes = mixStyleCodes.toList();
    Map<String, dynamic> reqData = {
      "mediaModeUse": selectMode == ResourceTypeEnum.image ? 0 : 1,
      "mainStyleUse": selectStyle,
      "isMediaMix": isMediaMix,
      "imageStyleUses": savedMixStyleCodes,
    };
    bool res = await AccountUtil.teamConfigStyleEdit(reqData);
    if (!res) return false;
    controller.originalStyleData.value.mediaModeUse = reqData["mediaModeUse"];
    controller.originalStyleData.value.mainStyleUse = reqData["mainStyleUse"];
    controller.originalStyleData.value.isMediaMix = reqData["isMediaMix"];
    controller.originalStyleData.value.imageStyleUses = savedMixStyleCodes;
    controller.originalStyleData.refresh();
    controller.initUserStyleList();
    return true;
  }

  /// 几个设置是否改变(不包括倍速 发音 文本显示)
  bool settingChanged() {
    if (widget.isManagement) {
      return manageController.defaultResources.value != selectMode ||
          manageController.selectedStyleKey.value != selectedManageStyleKey ||
          manageController.selectedStyleAreaCode.value != selectedManageStyleAreaCode;
    }else{
      List<String?> imageStyleUses = controller.originalStyleData.value.imageStyleUses ?? [];
      List<String> originalMixStyleCodes = [];
      for (int i = 0; i < imageStyleUses.length; i++) {
        String? code = imageStyleUses[i];
        if (code == null || code.isEmpty) continue;
        originalMixStyleCodes.add(code);
      }
      return controller.currentShowResource.value != selectMode ||
        (controller.originalStyleData.value.mainStyleUse ?? controller.currentShowStyleCode.value) != selectStyle ||
        (controller.originalStyleData.value.isMediaMix == true) != isMediaMix ||
        originalMixStyleCodes.join(",") != mixStyleCodes.join(",");
    }
    
  }


  @override
  Widget build(BuildContext context) {
    List<Widget> groupWidgets = [];
    if (groups.contains(GeneralSettingGroup.pronunciation)) {
      groupWidgets.add(_buildPronunciationWidget());
    }
    if (groups.contains(GeneralSettingGroup.textDisplay)) {
      if (groupWidgets.isNotEmpty) groupWidgets.add(_buildDivWidget());
      groupWidgets.add(_buildTextDisplayWidget());
    }
    if (groups.contains(GeneralSettingGroup.speed)) {
      if (groupWidgets.isNotEmpty) groupWidgets.add(_buildDivWidget());
      groupWidgets.add(_buildSpeedWidget());
    }
    if (groups.contains(GeneralSettingGroup.visual)) {
      if (groupWidgets.isNotEmpty) groupWidgets.add(_buildDivWidget());
      groupWidgets.add(_buildVisualWidget());
    }

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
                children: groupWidgets,
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
  Widget _buildPronunciationWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 24.wMin),
      child: Row(
        children: [
          _buildTitleWidget("发音"),
          Row(
            spacing: 12.wMin,
            children: List.generate(pronunciationList.length, (index) {
              bool selected = selectPronunciation == pronunciationList[index];
              return _buildTapWidget(
                text: pronunciationList[index].text,
                selected: selected,
                onTap: () {
                  // controller.setUserSetting(
                  //   expandPronunciationCode: LanguageServiceCodeEnum.values[index].value,
                  // );
                  selectPronunciation = pronunciationList[index];
                  if (mounted) setState(() {});
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 文本显示
  Widget _buildTextDisplayWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 24.wMin),
      child: Row(
        children: [
          _buildTitleWidget("文本显示"),
          Row(
            spacing: 12.wMin,
            children: List.generate(expandDropdownMenu.length, (index) {
              bool selected = selectLangPreference.code == expandDropdownMenu[index].code;
              return _buildTapWidget(
                text: expandDropdownMenu[index].title ?? '',
                selected: selected,
                onTap: () {
                  // controller.setUserSetting(
                  //   expandTranslationType: expandDropdownMenu[index].code,
                  // );
                  selectLangPreference = LangPreference.fromRawValue(expandDropdownMenu[index].code);
                  if (mounted) setState(() {});
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 倍速
  Widget _buildSpeedWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 24.wMin),
      child: Row(
        children: [
          _buildTitleWidget("倍速"),
          Wrap(
            spacing: 8.wMin,
            runSpacing: 6.wMin,
            children: List.generate(speedList.length, (index) {
              bool selected = currentSpeed == speedList[index];
              return _buildTapWidget(
                text: "${speedList[index].toString()}x",
                selected: selected,
                onTap: () {
                  // controller.setUserSetting(
                  //   expandAudioSpeed: speedList[index],
                  // );
                  currentSpeed = speedList[index];
                  player.setRate(currentSpeed);
                  if (mounted) setState(() {});
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 视觉模式
  Widget _buildVisualWidget() {
    if (widget.isManagement) {
      return _buildManageVisualWidget();
    }
    return _buildUserVisualWidget();
  }

  /// 用户端视觉模式
  Widget _buildUserVisualWidget() {
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
                      Text(
                        "主风格",
                      style: TextStyle(
                        fontSize: 18.wMin,
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
                      itemCount: styleList.length,
                      itemBuilder: (context, index) {
                        return _buildVisualStyleItemWidget(styleList[index]);
                      },
                    ),
                     
                  ],
                ),
              ),
              _buildVisualImageWidget(),
            ],
          ),
               SizedBox(height: 16.wMin),

           _buildMixSettingEntryWidget(),
        ],
      ),
    );
  }

  /// 管理端视觉模式
  Widget _buildManageVisualWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
      child: Column(
        children: [
          Row(
            children: [
              _buildTitleWidget("管理端\n视觉模式"),
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
                          _buildManageVisualModeItemWidget(
                            mode: ResourceTypeEnum.image,
                            tag: "快速学习",
                            desc: "精美高光图片，瞬间捕捉语义",
                            selected: selectMode == ResourceTypeEnum.image,
                          ),
                          _buildManageVisualModeItemWidget(
                            mode: ResourceTypeEnum.video,
                            tag: "推荐·沉浸体验",
                            desc: "真实语境演绎，把母语场景带到身边",
                            selected: selectMode == ResourceTypeEnum.video,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.wMin),
                    Text(
                      "画面偏好",
                      style: TextStyle(
                        fontSize: 18.wMin,
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
                      itemCount: manageStyleKeyList.length,
                      itemBuilder: (context, index) {
                        return _buildManageVisualStyleItemWidget(manageStyleKeyList[index]);
                      },
                    ),
                    SizedBox(height: 16.wMin),
                    Text(
                      "地区偏好",
                      style: TextStyle(
                        fontSize: 18.wMin,
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
                      itemCount: manageStyleAreaList.length,
                      itemBuilder: (context, index) {
                        return _buildManageStyleAreaItemWidget(manageStyleAreaList[index]);
                      },
                    ),
                  ],
                ),
              ),
              _buildManageVisualImageWidget(),
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
    VoidCallback? onTap,
  }) {
    String iconRadio = "assets/svg/public/icon_radio2.svg";
    if (mode == ResourceTypeEnum.video) {
      iconRadio = "assets/svg/public/icon_radio1.svg";
    }
    return Expanded(
      child: TapScaleWidget(
        onTap: onTap ??
            OptimizeUtils.noneThrottle(() {
              selectMode = mode;
              if (selectMode == ResourceTypeEnum.image) {
                styleList = controller.allStyleImageList.toList();
              } else {
                styleList = controller.allStyleVideoList.toList();
              }
              List<String> validStyleCodes = [];
              for (int i = 0; i < styleList.length; i++) {
                String? styleCode = styleList[i].style;
                if (styleCode == null || styleCode.isEmpty) continue;
                validStyleCodes.add(styleCode);
              }
              mixStyleCodes.removeWhere((code) => !validStyleCodes.contains(code));

              final bool hasSelectedStyle = styleList.any((e) => e.style == selectStyle);
              if (!hasSelectedStyle) {
                selectStyle = styleList.firstOrNull?.style ?? "";
              }
              if (selectStyle.isNotEmpty && !mixStyleCodes.contains(selectStyle)) {
                mixStyleCodes.add(selectStyle);
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

  Widget _buildManageVisualModeItemWidget({
    required ResourceTypeEnum mode,
    required String tag,
    required String desc,
    bool selected = false,
  }) {
    return _buildVisualModeItemWidget(
      mode: mode,
      tag: tag,
      desc: desc,
      selected: selected,
      onTap: OptimizeUtils.noneThrottle(() {
        selectMode = mode;
        if (mounted) setState(() {});
      }, 1000),
    );
  }

  Widget _buildVisualStyleItemWidget(TeamStyleEntityStyleItems item) {
    bool selected = item.style == selectStyle;
    LanguageText? styleTitle = LearningLangUtils.getLocalLang(item.styleTitle);
    LanguageText? styleDesc = LearningLangUtils.getLocalLang(item.styleDesc);
    return TapScaleWidget(
      onTap: () {
        if (item.style == null) return;
        selectStyle = item.style ?? '';
        if (!mixStyleCodes.contains(selectStyle)) {
          mixStyleCodes.add(selectStyle);
        }
        if (mounted) setState(() {});
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              styleTitle?.text ?? '',
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            SizedBox(height: 12.wMin),
            Text(
              styleDesc?.text ?? '',
              maxLines: 2,
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

  Widget _buildMixSettingEntryWidget() {
    String summaryText = getSavedMixSummaryText();
    return TapScaleWidget(
      onTap: () async {
        bool isPwdRight = await ParentPasswordialog.show(context: context);
        if (!isPwdRight) return;
        Get.back();
        await TagRoutes.toNamed(
          Routes.USER_CENTER,
          arguments: {"toUserModelIndex": 2},
        );
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderSubtle.color,
            width: 0.8.wMin,
          ),
        ),
        child: Row(
          
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    const TextSpan(text: "做题时风格混搭："),
                    TextSpan(
                      text: summaryText,
                      style: TextStyle(
                        color: AppTheme.cTextSecondary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.wMin),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "去设置",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 6.wMin),
                SvgPicture.asset(
                  "assets/svg/user_center/icon_chevron_right1.svg",
                  width: 16.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageVisualStyleItemWidget(String styleKey) {
    bool selected = styleKey == selectedManageStyleKey;
    ImageStyleConfigV2Item? currentItem = manageStyleAreaList.firstWhereOrNull((element) => element.locale == selectedManageStyleAreaCode);
    String styleDesc = currentItem?.localeTitle ?? "";
    return TapScaleWidget(
      onTap: () async {
        selectedManageStyleKey = styleKey;
        manageStyleAreaList = await manageController.getStyleAreaListByStyleKey(selectedManageStyleKey);
        ImageStyleConfigV2Item? item = manageStyleAreaList.firstWhereOrNull((element) => element.locale == selectedManageStyleAreaCode);
        if (item == null) {
          selectedManageStyleAreaCode = manageStyleAreaList.firstOrNull?.locale ?? "";
        }
        if (mounted) setState(() {});
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
              styleKey,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            Text(
              styleDesc,
              maxLines: 2,
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

  Widget _buildManageStyleAreaItemWidget(ImageStyleConfigV2Item item) {
    bool selected = item.locale == selectedManageStyleAreaCode;
    return TapScaleWidget(
      onTap: () {
        if (item.locale == null) return;
        selectedManageStyleAreaCode = item.locale ?? '';
        if (mounted) setState(() {});
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.localeTitle ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            Text(
              item.locale ?? '',
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

  Widget _buildVisualImageWidget() {
    // 当前选择的风格
    final TeamStyleEntityStyleItems? selectedStyle = styleList.firstWhereOrNull((e) => e.style == selectStyle);

    String imageUrl = selectedStyle?.image?.imageUrl ?? "";
    if (selectMode == ResourceTypeEnum.video) {
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
              if (selectMode != ResourceTypeEnum.video || !isVideoReady) return;
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

  Widget _buildManageVisualImageWidget() {
    final ImageStyleConfigV2Item? selectedArea = manageStyleAreaList.firstWhereOrNull((e) => e.locale == selectedManageStyleAreaCode);
    String imageUrl = selectedArea?.imageUrl?.firstOrNull ?? "";
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
        Container(
          width: 280.wMin,
          height: 280.wMin,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
          ),
          child: CachedImageWidget(
            imageUrl,
            errorWidget: buildEmptyWidget(),
            placeholder: buildLoadingWidget(),
            key: ValueKey(imageUrl),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsWidget() {
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
  }) {
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

  Widget _buildTitleWidget(String text) {
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

  Widget _buildDivWidget() {
    return Container(
      height: 0.8.wMin,
      color: AppTheme.cBorderPrimary.color,
    );
  }
}
