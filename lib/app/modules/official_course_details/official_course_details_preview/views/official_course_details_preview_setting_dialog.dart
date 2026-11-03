import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/user_center_option_entity.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/static/static_data.dart';
import '../../../../../common/widgets/audio_control_widget.dart';

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
  AudioControlPlayOrder playMode;

  /// 循环次数
  int playNum;

  /// 播放速度
  double playSpeed;

  double playInterval;

  PreviewSettingModel({
    this.knowledgePoints = const [],
    this.selectedKnowledgePoints = const [ElementsCardType.word, ElementsCardType.phrase, ElementsCardType.sentence],
    this.playMode = AudioControlPlayOrder.sequential,
    this.playNum = 1,
    this.playSpeed = 1.0,
    this.playInterval = 10.0,
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
  List<AudioControlPlayOrder> playModeList = [
    AudioControlPlayOrder.loop,
    AudioControlPlayOrder.sequential,
    AudioControlPlayOrder.random,
    AudioControlPlayOrder.singleLoop,
  ];
  List<int> playNumList = [1, 2, 3, 4, 5];
  List<double> playSpeedList = StaticData.playSpeedList;
  final ConfigController controller = Get.find<ConfigController>();
  List<UserPreferenceIntervalSpeedOption> menu = [];

  /// 选择的选项
  PreviewSettingModel selectedModel = PreviewSettingModel();

  @override
  void initState() {
    super.initState();
    menu = controller.userSetting.value.intervalMenu ?? [];
    if (widget.initModel != null) {
      selectedModel = widget.initModel!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: AppTheme.cOverlayBackground.color,
        child: Center(
          child: Stack(
            children: [
              Container(
                width: 640.wMin,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.wMin),
                  color: AppTheme.cBgSecondary.color,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 32.wMin),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '预习播放设置',
                        style: TextStyle(
                          fontSize: 32.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.wMin),
                    _buildKnowledgeTypeWidget(),
                    SizedBox(height: 36.wMin),
                    _buildPlayModeWidget(),
                    SizedBox(height: 48.wMin),
                    _buildPlayIntervalWidget(),
                    SizedBox(height: 48.wMin),
                    _buildPlayNumWidget(),
                    SizedBox(height: 48.wMin),
                    _buildPlaySpeedWidget(),
                    SizedBox(height: 48.wMin),
                    Row(
                      spacing: 12.wMin,
                      children: [
                        Expanded(
                          child: ButtonWidget(
                            text: "取消",
                            height: 72.wMin,
                            borderRadius: 12.wMin,
                            color: AppTheme.cSurfaceQuaternary.color,
                            fontSize: 28.wMin,
                            fontColor: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w500,
                            sclae: 1.01,
                            onTap: () {
                              Get.back();
                            },
                          ),
                        ),
                        Expanded(
                          child: ButtonWidget(
                            text: "开始播放",
                            height: 72.wMin,
                            borderRadius: 12.wMin,
                            color: AppTheme.cBgBrand.color,
                            fontSize: 28.wMin,
                            fontColor: AppTheme.cInverseTextLight.color,
                            fontWeight: FontWeight.w500,
                            sclae: 1.01,
                            onTap: () {
                              if (selectedModel.selectedKnowledgePoints.isEmpty) {
                                ToastUtils.showToast(text: "请选择类别");
                                return;
                              }
                              Get.back(result: selectedModel);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.wMin),
                  ],
                ),
              ),
              Positioned(
                top: 16.wMin,
                right: 16.wMin,
                child: TapScaleWidget(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 28.wMin,
        color: AppTheme.cTextPrimary.color,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// 选择知识点类别
  Widget _buildKnowledgeTypeWidget() {
    if (selectedModel.knowledgePoints.isEmpty) return Container();

    int knowledgeCount = 0;
    for (var item in selectedModel.knowledgePoints) {
      if (selectedModel.selectedKnowledgePoints.contains(item.type)) {
        knowledgeCount += item.count;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleWidget("选择类别"),
        SizedBox(height: 8.wMin),
        Row(
          spacing: 8.wMin,
          children: List.generate(selectedModel.knowledgePoints.length, (i) {
            return _buildKnowledgeTypeItemWidget(selectedModel.knowledgePoints[i]);
          }),
        ),
        SizedBox(height: 8.wMin),
        Text.rich(TextSpan(
          style: TextStyle(
            fontSize: 22.wMin,
            color: AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w400,
          ),
          children: [
            const TextSpan(text: "已选择 "),
            TextSpan(
              text: "$knowledgeCount",
              style: TextStyle(
                color: AppTheme.cTextBrand.color,
              ),
            ),
            const TextSpan(text: " 个知识点"),
          ],
        )),
      ],
    );
  }

  Widget _buildKnowledgeTypeItemWidget(PreviewSettingKnowledgeTypeItemModel item) {
    bool isSelected = selectedModel.selectedKnowledgePoints.contains(item.type);

    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          List<ElementsCardType> types = selectedModel.selectedKnowledgePoints.map((e) => e).toList();

          if (types.contains(item.type)) {
            types.remove(item.type);
          } else {
            types.add(item.type);
          }
          selectedModel.selectedKnowledgePoints = types;
          if (mounted) setState(() {});
        },
        sclae: 1.01,
        child: AnimatedContainer(
          height: 82.wMin,
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cSurfaceTertiary.color,
            border: Border.all(
              width: 1.5.wMin,
              color: AppTheme.cBorderBrand.color.withValues(
                alpha: isSelected ? 1.0 : 0.0,
              ),
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cBgBrand.withValues(alpha: isSelected ? 0.2 : 0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.typeText,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: isSelected ? AppTheme.cTextBrand.color : AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${item.count}个",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: isSelected ? AppTheme.cTextBrand.color : AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 选择播放模式
  Widget _buildPlayModeWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleWidget("播放顺序"),
        SizedBox(height: 8.wMin),
        Row(
          spacing: 8.wMin,
          children: List.generate(playModeList.length, (index) {
            return _buildBoxWidget(
              value: playModeList[index].value,
              selected: selectedModel.playMode == playModeList[index],
              onTap: () {
                selectedModel.playMode = playModeList[index];
                if (mounted) setState(() {});
              },
            );
          }),
        ),
      ],
    );
  }

  ///切换节奏
  Widget _buildPlayIntervalWidget() {
    if(menu.isEmpty){
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleWidget("知识点切换节奏"),
        SizedBox(height: 6.wMin),
        Row(
          spacing: 8.wMin,
          children: List.generate(menu.length, (index) {
            return _buildBoxWidget(
              value: menu[index].title!,
              selected: selectedModel.playInterval == menu[index].value,
              onTap: () {
                selectedModel.playInterval = menu[index].value ?? 0;
                setState(() {});
              },
            );
          }),
        ),
        SizedBox(height: 6.wMin),
      ],
    );
  }

  /// 循环次数
  Widget _buildPlayNumWidget() {
    String loopText = selectedModel.playMode == AudioControlPlayOrder.singleLoop ? "∞" : "${selectedModel.playNum}";
    return AnimatedSize(
      alignment: Alignment.topLeft,
      duration: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget("循环次数 X $loopText"),
          Visibility(
            visible: selectedModel.playMode != AudioControlPlayOrder.singleLoop,
            child: Container(
              margin: EdgeInsets.only(top: 8.wMin),
              child: Row(
                spacing: 8.wMin,
                children: List.generate(playNumList.length, (index) {
                  return _buildBoxWidget(
                    value: playNumList[index].toString(),
                    selected: selectedModel.playNum == playNumList[index],
                    onTap: () {
                      selectedModel.playNum = playNumList[index];
                      if (mounted) setState(() {});
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 倍速
  Widget _buildPlaySpeedWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleWidget("倍速"),
        SizedBox(height: 8.wMin),
        Row(
          spacing: 20.wMin,
          children: List.generate(playSpeedList.length, (index) {
            return _buildBoxWidget(
              value: playSpeedList[index].toString(),
              selected: selectedModel.playSpeed == playSpeedList[index],
              onTap: () {
                selectedModel.playSpeed = playSpeedList[index];
                if (mounted) setState(() {});
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBoxWidget({
    required String value,
    bool selected = false,
    void Function()? onTap,
  }) {
    return Expanded(
      child: TapScaleWidget(
        onTap: onTap,
        sclae: 1.01,
        child: AnimatedContainer(
          height: 56.wMin,
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cSurfaceTertiary.color,
            border: Border.all(
              width: 1.5.wMin,
              color: AppTheme.cBorderBrand.color.withValues(
                alpha: selected ? 1.0 : 0.0,
              ),
            ),
          ),
          child: AnimatedContainer(
            alignment: Alignment.center,
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cBgBrand.withValues(alpha: selected ? 0.2 : 0),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24.wMin,
                color: selected ? AppTheme.cTextBrand.color : AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
