import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/user_center_option_entity.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';


class DictationSettingKnowledgeTypeItemModel {
  ElementsCardType type;
  String typeText;
  int count;

  DictationSettingKnowledgeTypeItemModel({
    required this.type,
    required this.typeText,
    this.count = 0,
  });
}

class DictationSettingModel {
  /// 所有的知识点类型
  List<DictationSettingKnowledgeTypeItemModel> knowledgePoints;

  /// 选择的知识点类型
  List<ElementsCardType> selectedKnowledgePoints;

  /// 每个知识点重复播放次数
  int playNum;

  /// 知识点停顿间隔
  double pauseInterval;

  /// 播放顺序
  PlayerModeEnum playOrder;

  /// 发音
  LanguageServiceCodeEnum national;

  /// 倍速
  double playSpeed;

  /// 文本显示
  String textDisplayCode;

  DictationSettingModel({
    this.knowledgePoints = const [],
    this.selectedKnowledgePoints = const [ElementsCardType.word, ElementsCardType.phrase, ElementsCardType.sentence],
    this.playNum = 1,
    this.pauseInterval = 5.0,
    this.playOrder = PlayerModeEnum.order,
    this.national = LanguageServiceCodeEnum.US,
    this.playSpeed = 1.0,
    this.textDisplayCode = '',
  });
}

class OfficialCourseDetailsDictationSettingDialog {
  static Future<DictationSettingModel?> show({
    required BuildContext context,
    DictationSettingModel? initSetting,
  }) async {
    return await showCupertinoDialog<DictationSettingModel?>(
      context: context,
      builder: (context) => OfficialCourseDetailsDictationSettingDialogWidget(
        initSetting: initSetting,
      ),
    );
  }
}

class OfficialCourseDetailsDictationSettingDialogWidget extends StatefulWidget {
  final DictationSettingModel? initSetting;
  const OfficialCourseDetailsDictationSettingDialogWidget({
    super.key,
    this.initSetting,
  });

  @override
  State<OfficialCourseDetailsDictationSettingDialogWidget> createState() => _CustomCourseManageGradeAddGradeDialogWidgetState();
}

class _CustomCourseManageGradeAddGradeDialogWidgetState extends State<OfficialCourseDetailsDictationSettingDialogWidget> {
  final List<int> playNumList = [1, 2, 3];
  final List<PlayerModeEnum> playModeList = [
    PlayerModeEnum.order,
    PlayerModeEnum.reverse,
    PlayerModeEnum.random,
  ];
  final List<LanguageServiceCodeEnum> pronunciationList = [LanguageServiceCodeEnum.US, LanguageServiceCodeEnum.UK];
  final ConfigController controller = Get.find<ConfigController>();
  List<double> playSpeedList = [];

  /// 选择的选项
  DictationSettingModel selectedModel = DictationSettingModel();
  List<UserPreferenceIntervalSpeedOption> menu = [];
  late final DictationSettingModel initialModel;

  @override
  void initState() {
    super.initState();
    menu = controller.userSetting.value.intervalMenu ?? [];
    playSpeedList = controller.userSetting.value.expandAudioSpeedList;
    initialModel = _cloneModel(widget.initSetting ?? DictationSettingModel(textDisplayCode: _bilingualCode));
    selectedModel = _cloneModel(initialModel);
  }

  @override
  Widget build(BuildContext context) {
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
              color: const Color(0xFF1B1E22),
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
                            children: _textDisplayOptions.map((item) {
                              return _buildChipWidget(
                                value: item.title,
                                selected: selectedModel.textDisplayCode == item.code,
                                minWidth: 170.wMin,
                                onTap: () {
                                  selectedModel.textDisplayCode = item.code;
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        if (selectedModel.knowledgePoints.isNotEmpty)
                          _buildSettingSection(
                            title: '知识点类型',
                            child: Wrap(
                              spacing: 12.wMin,
                              runSpacing: 12.wMin,
                              children: selectedModel.knowledgePoints.map((item) {
                                return _buildKnowledgeTypeItemWidget(item);
                              }).toList(),
                            ),
                          ),
                        _buildSettingSection(
                          title: '知识点切换节奏',
                          child: Wrap(
                            spacing: 12.wMin,
                            runSpacing: 12.wMin,
                            children: menu.map((item) {
                              return _buildChipWidget(
                                value: item.title ?? '',
                                selected: selectedModel.pauseInterval == item.value,
                                minWidth: 120.wMin,
                                onTap: () {
                                  selectedModel.pauseInterval = item.value ?? 0;
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
                                selected: selectedModel.playOrder == item,
                                minWidth: 170.wMin,
                                onTap: () {
                                  selectedModel.playOrder = item;
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                        ),
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

  List<_DictationSettingOption> get _textDisplayOptions => [
        _DictationSettingOption(code: _bilingualCode, title: '双语对照'),
        _DictationSettingOption(code: LangPreference.original.code, title: '原文语言'),
        _DictationSettingOption(code: LangPreference.translation.code, title: '译文语言'),
        _DictationSettingOption(code: LangPreference.none.code, title: '隐藏文本'),
      ];

  String get _bilingualCode {
    final menus = controller.userSetting.value.expandDropdownMenu ?? const [];
    for (final item in menus) {
      final String code = (item.code ?? '').trim();
      if (code.isEmpty) continue;
      if (code == LangPreference.original.code ||
          code == LangPreference.translation.code ||
          code == LangPreference.none.code) {
        continue;
      }
      return code;
    }
    final String currentCode = controller.userSetting.value.expandLang.code;
    if (currentCode.isNotEmpty &&
        currentCode != LangPreference.original.code &&
        currentCode != LangPreference.translation.code &&
        currentCode != LangPreference.none.code) {
      return currentCode;
    }
    return LangPreference.bilingual.code;
  }

  DictationSettingModel _cloneModel(DictationSettingModel model) {
    return DictationSettingModel(
      knowledgePoints: model.knowledgePoints
          .map(
            (item) => DictationSettingKnowledgeTypeItemModel(
              type: item.type,
              typeText: item.typeText,
              count: item.count,
            ),
          )
          .toList(),
      selectedKnowledgePoints: model.selectedKnowledgePoints.toList(),
      playNum: model.playNum,
      pauseInterval: model.pauseInterval,
      playOrder: model.playOrder,
      national: model.national,
      playSpeed: model.playSpeed,
      textDisplayCode: model.textDisplayCode.isEmpty ? _bilingualCode : model.textDisplayCode,
    );
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

  Widget _buildKnowledgeTypeItemWidget(DictationSettingKnowledgeTypeItemModel item) {
    final bool isSelected = selectedModel.selectedKnowledgePoints.contains(item.type);
    return _buildChipWidget(
      value: '${item.typeText} ${item.count}',
      selected: isSelected,
      minWidth: 140.wMin,
      onTap: () {
        final List<ElementsCardType> types = selectedModel.selectedKnowledgePoints.toList();
        if (types.contains(item.type)) {
          types.remove(item.type);
        } else {
          types.add(item.type);
        }
        selectedModel.selectedKnowledgePoints = types;
        setState(() {});
      },
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
          color: selected
              ? AppTheme.cBgBrand.color.withValues(alpha: 0.18)
              : AppTheme.cSurfaceTertiary.color,
          border: Border.all(
            width: 1.wMin,
            color: selected
                ? AppTheme.cBorderBrand.color
                : AppTheme.cBorderPrimary.color.withValues(alpha: 0.8),
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

class _DictationSettingOption {
  final String code;
  final String title;

  const _DictationSettingOption({
    required this.code,
    required this.title,
  });
}
