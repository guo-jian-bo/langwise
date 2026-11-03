import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/user_center_option_entity.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';

class PreviewSettingKnowledgeTypeItemModel {
  ElementsCardType type;
  String typeText;
  int count;

  PreviewSettingKnowledgeTypeItemModel({
    required this.type,
    required this.typeText,
    this.count = 0,
  });
}

class PreviewSettingModel {
  /// 所有的知识点类型
  List<PreviewSettingKnowledgeTypeItemModel> knowledgePoints;

  /// 选择的知识点类型
  List<ElementsCardType> selectedKnowledgePoints;

  /// 播放模式
  PlayerModeEnum playMode;

  /// 循环次数
  int playNum;

  /// 播放速度
  double playSpeed;

  double playInterval;

  /// 发音
  LanguageServiceCodeEnum national;

  /// 文本显示
  String textDisplayCode;

  /// 是否允许随机播放
  bool enableRandomPlayMode;

  PreviewSettingModel({
    this.knowledgePoints = const [],
    this.selectedKnowledgePoints = const [ElementsCardType.word, ElementsCardType.phrase, ElementsCardType.sentence],
    this.playMode = PlayerModeEnum.list,
    this.playNum = 1,
    this.playSpeed = 1.0,
    this.playInterval = 10.0,
    this.national = LanguageServiceCodeEnum.US,
    this.textDisplayCode = '',
    this.enableRandomPlayMode = true,
  });
}

class OfficialCourseDetailsPreviewSettingDialog {
  static Future<PreviewSettingModel?> show({
    required BuildContext context,
    PreviewSettingModel? initModel,
  }) async {
    return await showCupertinoDialog<PreviewSettingModel?>(
      context: context,
      builder: (context) => OfficialCourseDetailsPreviewSettingDialogWidget(
        initModel: initModel,
      ),
    );
  }
}

class OfficialCourseDetailsPreviewSettingDialogWidget extends StatefulWidget {
  final PreviewSettingModel? initModel;

  const OfficialCourseDetailsPreviewSettingDialogWidget({super.key, this.initModel});

  @override
  State<OfficialCourseDetailsPreviewSettingDialogWidget> createState() => _CustomCourseManageGradeAddGradeDialogWidgetState();
}

class _CustomCourseManageGradeAddGradeDialogWidgetState extends State<OfficialCourseDetailsPreviewSettingDialogWidget> {
  final List<int> playNumList = [1, 2, 3, 4, 5];
  final List<LanguageServiceCodeEnum> pronunciationList = [
    LanguageServiceCodeEnum.US,
    LanguageServiceCodeEnum.UK,
  ];
  final ConfigController controller = Get.find<ConfigController>();
  List<double> playSpeedList = [];
  List<UserPreferenceIntervalSpeedOption> menu = [];

  /// 选择的选项
  PreviewSettingModel selectedModel = PreviewSettingModel();
  late final PreviewSettingModel initialModel;

  @override
  void initState() {
    super.initState();
    playSpeedList = controller.userSetting.value.expandAudioSpeedList;
    menu = controller.userSetting.value.intervalMenu ?? [];
    initialModel = _cloneModel(widget.initModel ?? PreviewSettingModel());
    selectedModel = _cloneModel(initialModel);
    if (!selectedModel.enableRandomPlayMode && selectedModel.playMode == PlayerModeEnum.random) {
      selectedModel.playMode = PlayerModeEnum.list;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<UserPreferenceDefinitionDisplayModeOption> textDisplayOptions =
        (controller.userSetting.value.expandDropdownMenu ?? <UserPreferenceDefinitionDisplayModeOption>[])
            .where((item) => ((item.langPreference?.code ?? item.code) ?? '').isNotEmpty)
            .toList();
    return PopScope(
      canPop: false,
      child: Material(
        color: AppTheme.cOverlayBackground.color,
        child: Center(
          child: Container(
            width: 1080.wMin,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 64.wMin,
              maxHeight: MediaQuery.of(context).size.height - 64.wMin,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.wMin),
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(
                color: AppTheme.cBorderPrimary.color.withValues(alpha: 0.9),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(24.wMin, 20.wMin, 18.wMin, 20.wMin),
                  child: Row(
                    children: [
                      Text(
                        '听力设置',
                        style: TextStyle(
                          fontSize: 32.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TapScaleWidget(
                        sclae: 1.02,
                        onTap: () => Get.back(),
                        child: Container(
                          width: 36.wMin,
                          height: 36.wMin,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppTheme.cSurfaceTertiary.color,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/public/x.svg",
                            width: 18.wMin,
                            height: 18.wMin,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24.wMin, 20.wMin, 24.wMin, 24.wMin),
                    child: Column(
                      children: [
                        _buildSettingSection(
                          title: '发音',
                          child: Wrap(
                            spacing: 12.wMin,
                            runSpacing: 12.wMin,
                            children: pronunciationList.map((item) {
                              return _buildChipWidget(
                                value: item.text,
                                selected: selectedModel.national == item,
                                minWidth: 120.wMin,
                                onTap: () {
                                  selectedModel.national = item;
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        _buildSettingSection(
                          title: '文本显示',
                          child: Wrap(
                            spacing: 12.wMin,
                            runSpacing: 12.wMin,
                            children: textDisplayOptions.map((item) {
                              final String code = item.langPreference?.code ?? item.code ?? '';
                              return _buildChipWidget(
                                value: item.title ?? '',
                                selected: selectedModel.textDisplayCode == code,
                                minWidth: 170.wMin,
                                onTap: () {
                                  selectedModel.textDisplayCode = code;
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        if (menu.isNotEmpty)
                          _buildSettingSection(
                            title: '知识点切换节奏',
                            child: Wrap(
                              spacing: 12.wMin,
                              runSpacing: 12.wMin,
                              children: menu.map((item) {
                                return _buildChipWidget(
                                  value: item.title ?? '',
                                  selected: selectedModel.playInterval == item.value,
                                  minWidth: 120.wMin,
                                  onTap: () {
                                    selectedModel.playInterval = item.value ?? 0;
                                    setState(() {});
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        _buildSettingSection(
                          title: '播放顺序',
                          child: Wrap(
                            spacing: 12.wMin,
                            runSpacing: 12.wMin,
                            children: playModeList.map((item) {
                              return _buildChipWidget(
                                value: item.title,
                                selected: selectedModel.playMode == item,
                                minWidth: 170.wMin,
                                onTap: () {
                                  selectedModel.playMode = item;
                                  if (item == PlayerModeEnum.singleLoop) {
                                    selectedModel.playNum = 1;
                                  }
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        if (selectedModel.playMode != PlayerModeEnum.singleLoop)
                          _buildSettingSection(
                            title: '循环次数',
                            child: Wrap(
                              spacing: 12.wMin,
                              runSpacing: 12.wMin,
                              children: playNumList.map((item) {
                                return _buildChipWidget(
                                  value: item.toString(),
                                  selected: selectedModel.playNum == item,
                                  minWidth: 90.wMin,
                                  onTap: () {
                                    selectedModel.playNum = item;
                                    setState(() {});
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        _buildSettingSection(
                          title: '倍速',
                          showDivider: false,
                          child: Wrap(
                            spacing: 12.wMin,
                            runSpacing: 12.wMin,
                            children: playSpeedList.map((item) {
                              return _buildChipWidget(
                                value: '${_formatSpeed(item)}x',
                                selected: selectedModel.playSpeed == item,
                                minWidth: 96.wMin,
                                onTap: () {
                                  selectedModel.playSpeed = item;
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 20.wMin),
                  child: Row(
                    children: [
                      TapScaleWidget(
                        onTap: _resetSelection,
                        sclae: 1.01,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 12.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.wMin),
                            color: AppTheme.cSurfaceTertiary.color,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.replay_rounded,
                                size: 20.wMin,
                                color: AppTheme.cTextSecondary.color,
                              ),
                              SizedBox(width: 8.wMin),
                              Text(
                                '重置',
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: AppTheme.cTextSecondary.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      ButtonWidget(
                        text: "确认",
                        width: 132.wMin,
                        height: 64.wMin,
                        borderRadius: 12.wMin,
                        color: AppTheme.cBgBrand.color,
                        fontSize: 26.wMin,
                        fontColor: AppTheme.cInverseTextLight.color,
                        fontWeight: FontWeight.w500,
                        sclae: 1.01,
                        onTap: () {
                          if (selectedModel.selectedKnowledgePoints.isEmpty) {
                            ToastUtils.showToast(text: "请选择类别");
                            return;
                          }
                          Get.back(result: _cloneModel(selectedModel));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PlayerModeEnum> get playModeList {
    if (selectedModel.enableRandomPlayMode) {
      return const [
        PlayerModeEnum.list,
        PlayerModeEnum.random,
        PlayerModeEnum.singleLoop,
      ];
    }
    return const [
      PlayerModeEnum.list,
      PlayerModeEnum.singleLoop,
    ];
  }

  PreviewSettingModel _cloneModel(PreviewSettingModel model) {
    return PreviewSettingModel(
      knowledgePoints: model.knowledgePoints
          .map(
            (item) => PreviewSettingKnowledgeTypeItemModel(
              type: item.type,
              typeText: item.typeText,
              count: item.count,
            ),
          )
          .toList(),
      selectedKnowledgePoints: model.selectedKnowledgePoints.toList(),
      playMode: model.playMode,
      playNum: model.playNum,
      playSpeed: model.playSpeed,
      playInterval: model.playInterval,
      national: model.national,
      textDisplayCode: _resolveTextDisplayCode(model.textDisplayCode),
      enableRandomPlayMode: model.enableRandomPlayMode,
    );
  }

  /// 解析弹窗内使用的文本显示 code，保证优先命中当前配置菜单中的有效项。
  String _resolveTextDisplayCode(String code) {
    final List<UserPreferenceDefinitionDisplayModeOption> textDisplayOptions =
        controller.userSetting.value.expandDropdownMenu ?? <UserPreferenceDefinitionDisplayModeOption>[];
    if (code.isNotEmpty) {
      for (final item in textDisplayOptions) {
        final String itemCode = item.langPreference?.code ?? item.code ?? '';
        if (itemCode == code) return itemCode;
      }
    }
    final String currentCode = controller.userSetting.value.expandLang.code;
    for (final item in textDisplayOptions) {
      final String itemCode = item.langPreference?.code ?? item.code ?? '';
      if (itemCode == currentCode) return itemCode;
    }
    for (final item in textDisplayOptions) {
      final String itemCode = item.langPreference?.code ?? item.code ?? '';
      if (itemCode.isNotEmpty) return itemCode;
    }
    return currentCode;
  }

  void _resetSelection() {
    selectedModel = _cloneModel(initialModel);
    setState(() {});
  }

  Widget _buildSettingSection({
    required String title,
    required Widget child,
    bool showDivider = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.wMin),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: AppTheme.cBorderPrimary.color,
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180.wMin,
            child: Padding(
              padding: EdgeInsets.only(top: 12.wMin),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildChipWidget({
    required String value,
    bool selected = false,
    double? minWidth,
    void Function()? onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.01,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: BoxConstraints(minWidth: minWidth ?? 120.wMin),
        padding: EdgeInsets.symmetric(horizontal: 22.wMin, vertical: 14.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: selected ? AppTheme.cBgBrand.color.withValues(alpha: 0.18) : AppTheme.cSurfaceTertiary.color,
          border: Border.all(
            width: 1.wMin,
            color: selected ? AppTheme.cBorderBrand.color : AppTheme.cBorderPrimary.color.withValues(alpha: 0.8),
          ),
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.wMin,
            color: selected ? AppTheme.cTextBrand.color : AppTheme.cTextSecondary.color,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatSpeed(double value) {
    if (value == value.toInt()) {
      return value.toStringAsFixed(1);
    }
    return value.toString();
  }
}
