import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/user_center_option_entity.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';

enum CourseDetailsDictationMode {
  /// 顺序
  order("顺序"),

  /// 倒序
  reverse("倒序"),

  /// 随机
  random("随机");

  final String value;
  const CourseDetailsDictationMode(this.value);
}

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
  CourseDetailsDictationMode playOrder;

  /// 发音
  LanguageServiceCodeEnum national;

  DictationSettingModel({
    this.knowledgePoints = const [],
    this.selectedKnowledgePoints = const [ElementsCardType.word, ElementsCardType.phrase, ElementsCardType.sentence],
    this.playNum = 1,
    this.pauseInterval = 5.0,
    this.playOrder = CourseDetailsDictationMode.order,
    this.national = LanguageServiceCodeEnum.US,
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
  List<int> playNumList = [1, 2, 3];
  List<String> rhythmList = ["极慢", "较慢", "适中", "较快", "极快"];
  List<double> pauseIntervalList = [15, 12.5, 10, 7.5, 5];
  List<CourseDetailsDictationMode> playModeList = CourseDetailsDictationMode.values;
  List<LanguageServiceCodeEnum> pronunciationList = [LanguageServiceCodeEnum.US, LanguageServiceCodeEnum.UK];
  final ConfigController controller = Get.find<ConfigController>();

  /// 选择的选项
  DictationSettingModel selectedModel = DictationSettingModel();
  List<UserPreferenceIntervalSpeedOption> menu = [];

  @override
  void initState() {
    super.initState();
    menu = controller.userSetting.value.intervalMenu ?? [];
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
                    SizedBox(height: 24.wMin),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '听写模式设置',
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
                    _buildPlayNumWidget(),
                    SizedBox(height: 24.wMin),
                    _buildPauseIntervalWidget(),
                    SizedBox(height: 24.wMin),
                    _buildPlayModeWidget(),
                    SizedBox(height: 24.wMin),
                    _buildPronunciationWidget(),
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
                            text: "开始听写",
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

  Widget _buildKnowledgeTypeItemWidget(DictationSettingKnowledgeTypeItemModel item) {
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

  /// 每个知识点重复播放次数
  Widget _buildPlayNumWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleWidget("每个知识点重复播放次数"),
        SizedBox(height: 6.wMin),
        Row(
          spacing: 8.wMin,
          children: List.generate(playNumList.length, (index) {
            return _buildBoxWidget(
              value: '${playNumList[index]}次',
              selected: selectedModel.playNum == playNumList[index],
              onTap: () {
                selectedModel.playNum = playNumList[index];
                setState(() {});
              },
            );
          }),
        ),
        SizedBox(height: 6.wMin),
        Text(
          "每个知识点会连续播放指定次数，帮助加深印象",
          style: TextStyle(
            fontSize: 22.wMin,
            color: AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// 知识点停顿间隔
  Widget _buildPauseIntervalWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleWidget("知识点听写节奏"),
        SizedBox(height: 6.wMin),
        Row(
          spacing: 8.wMin,
          children: List.generate(menu.length, (index) {
            return _buildBoxWidget(
              value: menu[index].title!,
              selected: selectedModel.pauseInterval == menu[index].value,
              onTap: () {
                selectedModel.pauseInterval = menu[index].value!;
                setState(() {});
              },
            );
          }),
        ),
        SizedBox(height: 6.wMin),
        // Text(
        //   "书写时长=当前知识点音频的长度 * 知识点停顿间隔",
        //   style: TextStyle(
        //     fontSize: 22.wMin,
        //     color: AppTheme.cTextTertiary.color,
        //     fontWeight: FontWeight.w400,
        //   ),
        // ),
      ],
    );
  }

  /// 播放顺序
  Widget _buildPlayModeWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleWidget("播放顺序"),
        SizedBox(height: 6.wMin),
        Row(
          spacing: 8.wMin,
          children: List.generate(playModeList.length, (index) {
            return _buildBoxWidget(
              value: playModeList[index].value,
              selected: selectedModel.playOrder == playModeList[index],
              onTap: () {
                selectedModel.playOrder = playModeList[index];
                setState(() {});
              },
            );
          }),
        ),
      ],
    );
  }

  /// 发音
  Widget _buildPronunciationWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleWidget("发音"),
        SizedBox(height: 6.wMin),
        Row(
          spacing: 8.wMin,
          children: List.generate(pronunciationList.length, (index) {
            return _buildBoxWidget(
              value: pronunciationList[index].text,
              selected: selectedModel.national == pronunciationList[index],
              onTap: () {
                selectedModel.national = pronunciationList[index];
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
