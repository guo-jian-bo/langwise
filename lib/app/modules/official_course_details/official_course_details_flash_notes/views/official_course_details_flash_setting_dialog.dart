import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/user_center_option_entity.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';
enum FlashSettingCardShowType {
  /// 仅图片
  image("仅图片"),

  /// 图片+中文
  imageAndLocalText("图片+中文"),

  /// 图片+英语
  imageAndLearText("图片+英文");

  final String value;
  const FlashSettingCardShowType(this.value);
}

class FlashSettingKnowledgeTypeItemModel {
  ElementsCardType type;
  String typeText;
  int count;

  FlashSettingKnowledgeTypeItemModel({
    required this.type,
    required this.typeText,
    this.count = 0,
  });
}

class FlashSettingModel {
  /// 所有的知识点类型
  List<FlashSettingKnowledgeTypeItemModel> knowledgePoints;

  /// 选择的知识点类型
  List<ElementsCardType> selectedKnowledgePoints;

  double interval;

  /// 正面显示
  FlashSettingCardShowType showType;

  double playSpeed;

  LanguageServiceCodeEnum national;

  String textDisplayCode;

  FlashSettingModel(
      {this.knowledgePoints = const [],
      this.selectedKnowledgePoints = const [ElementsCardType.word, ElementsCardType.phrase, ElementsCardType.sentence],
      this.interval = 10,
      this.showType = FlashSettingCardShowType.image,
      this.playSpeed = 1.0,
      this.national = LanguageServiceCodeEnum.US,
      this.textDisplayCode = ''});
}

class OfficialCourseDetailsFlashSettingDialog {
  static Future<FlashSettingModel?> show({
    required BuildContext context,
    FlashSettingModel? initSetting,
    bool showKonwlede = false,
  }) async {
    return await showCupertinoDialog<FlashSettingModel?>(
      context: context,
      builder: (context) => OfficialCourseDetailsFlashSettingDialogWidget(
        initSetting: initSetting,
        showKonwlede: showKonwlede,
      ),
    );
  }
}

class OfficialCourseDetailsFlashSettingDialogWidget extends StatefulWidget {
  final FlashSettingModel? initSetting;
  final bool showKonwlede;
  const OfficialCourseDetailsFlashSettingDialogWidget({
    super.key,
    this.initSetting,
    this.showKonwlede = false,
  });

  @override
  State<OfficialCourseDetailsFlashSettingDialogWidget> createState() => _OfficialCourseDetailsFlashSettingDialogWidgetState();
}

class _OfficialCourseDetailsFlashSettingDialogWidgetState extends State<OfficialCourseDetailsFlashSettingDialogWidget> {
  static const String _bilingualCodeValue = 'bilingual';
  static const String _originalCode = 'original';
  static const String _translationCode = 'translation';
  static const String _noneCode = 'none';

  final List<FlashSettingCardShowType> showModeList = FlashSettingCardShowType.values;
  final List<LanguageServiceCodeEnum> pronunciationList = [
    LanguageServiceCodeEnum.US,
    LanguageServiceCodeEnum.UK,
  ];
  final ConfigController controller = Get.find<ConfigController>();
  List<UserPreferenceIntervalSpeedOption> menu = [];

  /// 选择的选项
  FlashSettingModel selectedModel = FlashSettingModel();
  List<double> playSpeedList = [];
  late final FlashSettingModel initialModel;

  @override
  void initState() {
    super.initState();
    menu = controller.userSetting.value.intervalMenu ?? [];
    playSpeedList = controller.userSetting.value.expandAudioSpeedList;
    initialModel = _cloneModel(widget.initSetting ?? FlashSettingModel(textDisplayCode: _bilingualCode));
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
                        _buildSettingSection(
                          title: '知识点切换节奏',
                          child: Wrap(
                            spacing: 12.wMin,
                            runSpacing: 12.wMin,
                            children: menu.map((item) {
                              return _buildChipWidget(
                                value: item.title ?? '',
                                selected: selectedModel.interval == item.value,
                                minWidth: 120.wMin,
                                onTap: () {
                                  selectedModel.interval = item.value ?? 0;
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

  List<_FlashSettingOption> get _textDisplayOptions => [
        _FlashSettingOption(code: _bilingualCode, title: '双语对照'),
        _FlashSettingOption(code: _originalCode, title: '原文语言'),
        _FlashSettingOption(code: _translationCode, title: '译文语言'),
        _FlashSettingOption(code: _noneCode, title: '隐藏文本'),
      ];

  String get _bilingualCode {
    final menus = controller.userSetting.value.expandDropdownMenu ?? const [];
    for (final item in menus) {
      final String code = (item.code ?? '').trim();
      if (code.isEmpty) continue;
      if (code == _originalCode ||
          code == _translationCode ||
          code == _noneCode) {
        continue;
      }
      return code;
    }
    final String currentCode = controller.userSetting.value.expandLang.code;
    if (currentCode.isNotEmpty &&
        currentCode != _originalCode &&
        currentCode != _translationCode &&
        currentCode != _noneCode) {
      return currentCode;
    }
    return _bilingualCodeValue;
  }

  FlashSettingModel _cloneModel(FlashSettingModel model) {
    return FlashSettingModel(
      knowledgePoints: model.knowledgePoints
          .map(
            (item) => FlashSettingKnowledgeTypeItemModel(
              type: item.type,
              typeText: item.typeText,
              count: item.count,
            ),
          )
          .toList(),
      selectedKnowledgePoints: model.selectedKnowledgePoints.toList(),
      interval: model.interval,
      showType: model.showType,
      playSpeed: model.playSpeed,
      national: model.national,
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

class _FlashSettingOption {
  final String code;
  final String title;

  const _FlashSettingOption({
    required this.code,
    required this.title,
  });
}
