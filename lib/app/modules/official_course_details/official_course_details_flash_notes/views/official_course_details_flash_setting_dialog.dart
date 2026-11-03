import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/user_center_option_entity.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';

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

  FlashSettingModel(
      {this.knowledgePoints = const [],
      this.selectedKnowledgePoints = const [ElementsCardType.word, ElementsCardType.phrase, ElementsCardType.sentence],
      this.interval = 10,
      this.showType = FlashSettingCardShowType.image,
      this.playSpeed = 1.0});
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
  List<FlashSettingCardShowType> showModeList = FlashSettingCardShowType.values;
  final ConfigController controller = Get.find<ConfigController>();
  List<UserPreferenceIntervalSpeedOption> menu = [];

  /// 选择的选项
  FlashSettingModel selectedModel = FlashSettingModel();
  List<double> playSpeedList = [];

  @override
  void initState() {
    super.initState();
    menu = controller.userSetting.value.intervalMenu ?? [];
    playSpeedList = controller.userSetting.value.expandAudioSpeedList;
    if (widget.initSetting != null) {
      selectedModel = widget.initSetting!;
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
                width: 700.wMin,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.wMin),
                  color: AppTheme.cBgSecondary.color,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 24.wMin),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '闪记播放设置',
                        style: TextStyle(
                          fontSize: 32.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.wMin),
                    _buildKnowledgeTypeWidget(),
                    SizedBox(height: 24.wMin),
                    _buildPlayIntervalWidget(),
                    SizedBox(height: 24.wMin),
                    _buildPlaySpeedWidget(),
                    SizedBox(height: 24.wMin),
                    _buildShowModeWidget(),
                    SizedBox(height: 24.wMin),
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
                            text: "确定",
                            height: 72.wMin,
                            borderRadius: 12.wMin,
                            color: AppTheme.cBgBrand.color,
                            fontSize: 28.wMin,
                            fontColor: AppTheme.cInverseTextLight.color,
                            fontWeight: FontWeight.w500,
                            sclae: 1.01,
                            onTap: () {
                              if (selectedModel.selectedKnowledgePoints.isEmpty && widget.showKonwlede) {
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

  ///切换节奏
  Widget _buildPlayIntervalWidget() {
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
              selected: selectedModel.interval == menu[index].value,
              onTap: () {
                selectedModel.interval = menu[index].value!;
                setState(() {});
              },
            );
          }),
        ),
        SizedBox(height: 6.wMin),
      ],
    );
  }

  /// 选择知识点类别
  Widget _buildKnowledgeTypeWidget() {
    if (!widget.showKonwlede) return Container();
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
        SizedBox(height: 6.wMin),
        Row(
          spacing: 8.wMin,
          children: List.generate(selectedModel.knowledgePoints.length, (i) {
            return _buildKnowledgeTypeItemWidget(selectedModel.knowledgePoints[i]);
          }),
        ),
        SizedBox(height: 6.wMin),
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

  Widget _buildKnowledgeTypeItemWidget(FlashSettingKnowledgeTypeItemModel item) {
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

  /// 显示设置
  Widget _buildShowModeWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleWidget("正面显示"),
        SizedBox(height: 6.wMin),
        Row(
          spacing: 8.wMin,
          children: List.generate(showModeList.length, (index) {
            return _buildBoxWidget(
              value: showModeList[index].value,
              selected: selectedModel.showType == showModeList[index],
              onTap: () {
                selectedModel.showType = showModeList[index];
                setState(() {});
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

  /// 倍速
  Widget _buildPlaySpeedWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleWidget("倍速"),
        SizedBox(height: 8.wMin),
        Row(
          spacing: 10.wMin,
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
}
