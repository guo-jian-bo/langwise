import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import '../entities/entities.dart';
import '../enum/enum.dart';
import '../public_controller/config_controller.dart';
import 'widgets.dart';

class CardLearningButtonsWidget extends StatefulWidget {
  final bool showPreview;
  final void Function()? onPreview;

  final bool showFlash;
  final void Function()? onFlash;

  final bool showDictation;
  final void Function()? onDictation;

  final bool showDownload;
  final void Function()? onDownload;

  /// 预习 闪卡 听写 下载 按钮
  const CardLearningButtonsWidget({
    super.key,
    this.showPreview = true,
    this.onPreview,
    this.showFlash = true,
    this.onFlash,
    this.showDictation = true,
    this.onDictation,
    this.showDownload = true,
    this.onDownload,
  });

  @override
  State<CardLearningButtonsWidget> createState() =>
      _CardLearningButtonsWidgetState();
}

class _CardLearningButtonsWidgetState extends State<CardLearningButtonsWidget> {
  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    if (widget.showPreview) {
      widgetList.add(CardLearningButtonsItemWidget(
        title: '预习',
        svg: 'assets/svg/public/icons_eye.svg',
        color: const Color(0xff818CF8),
        index: 0,
        onTap: widget.onPreview,
      ));
    }

    if (widget.showDictation) {
      widgetList.add(CardLearningButtonsItemWidget(
        title: '听写',
        svg: 'assets/svg/public/icon_earphones.svg',
        color: AppTheme.cSurfaceInfo.color,
        index: widgetList.length,
        onTap: widget.onDictation,
      ));
    }

    if (widget.showFlash) {
      widgetList.add(CardLearningButtonsItemWidget(
        title: '闪记',
        svg: 'assets/svg/public/icon_lightning.svg',
        color: const Color(0xffEC4899),
        index: widgetList.length,
        onTap: widget.onFlash,
      ));
    }

    if (widget.showDownload) {
      widgetList.add(CardLearningButtonsItemWidget(
        title: '下载',
        svg: 'assets/svg/public/icon_download.svg',
        color: const Color(0xff4ADE80),
        index: widgetList.length,
        onTap: widget.onDownload,
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16.wMin,
      children: widgetList,
    );
  }
}

class CardLearningButtonsItemWidget extends StatelessWidget {
  final String title;
  final String? svg;
  final Color color;
  final int index;
  final void Function()? onTap;
  final int iconQuarterTurns;
  const CardLearningButtonsItemWidget({
    super.key,
    required this.title,
    this.svg,
    required this.color,
    required this.index,
    this.onTap,
    this.iconQuarterTurns = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasIcon = (svg ?? '').isNotEmpty;
    return ListAnimationWidget(
      index: index,
      horizontalOffset: 70.wMin,
      delay: const Duration(milliseconds: 100),
      child: TapScaleWidget(
        sclae: 1.05,
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: PlatformBackdropFilterWidget(
            sigmaX: 10.wMin,
            sigmaY: 10.wMin,
            child: Container(
              // width: width,
              height: 64.wMin,
              padding: EdgeInsets.symmetric(horizontal: 18.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: color.withValues(alpha: 0.15),
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                  width: 1.wMin,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasIcon)
                    RotatedBox(
                      quarterTurns: iconQuarterTurns,
                      child: SvgPicture.asset(
                        svg!,
                        width: 32.wMin,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      ),
                    ),
                  if (hasIcon) SizedBox(width: 4.wMin),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CardLearningStyleButtonWidget extends StatefulWidget {
  final void Function()? onSubmit;

  /// 风格切换按钮
  const CardLearningStyleButtonWidget({super.key, this.onSubmit});

  @override
  State<CardLearningStyleButtonWidget> createState() =>
      _CardLearningStyleButtonWidgetState();
}

class _CardLearningStyleButtonWidgetState
    extends State<CardLearningStyleButtonWidget> {
  @override
  Widget build(BuildContext context) {
    ConfigController controller = Get.find<ConfigController>();

    return Obx(() {
      if (controller.allStyleList.isEmpty) return Container();
      return CardLearningButtonsItemWidget(
        title: controller
            .getCurrentStyleName(controller.currentShowStyleCode.value),
        svg: controller.currentShowResource.value.svg,
        color: controller.currentShowResource.value.color,
        index: 0,
        onTap: () async {
          CardLearningStyleDialogReslut? reslut =
              await CardLearningStyleDialog.show(context: context);
          if (reslut == null) return;
          controller.changeCurrentShowResource(reslut.resource);
          controller.changeCurrentStyleCode(reslut.style);
          widget.onSubmit?.call();
        },
      );
    });
  }
}

class CardLearningStyleDialogReslut {
  ResourceTypeEnum resource;
  String style;

  CardLearningStyleDialogReslut({
    required this.resource,
    required this.style,
  });
}

class CardLearningStyleDialog {
  static Future<CardLearningStyleDialogReslut?> show({
    required BuildContext context,
  }) async {
    CardLearningStyleDialogReslut? res =
        await showDialog<CardLearningStyleDialogReslut?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return const CardLearningStyleDialogWidget();
      },
    );

    return res;
  }
}

class MeaningDisplayModeDialogResult {
  final String code;

  MeaningDisplayModeDialogResult({
    required this.code,
  });
}

class MeaningDisplayModeDialog {
  static Future<MeaningDisplayModeDialogResult?> show({
    required BuildContext context,
  }) async {
    return showDialog<MeaningDisplayModeDialogResult?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return const MeaningDisplayModeDialogWidget();
      },
    );
  }
}

class MeaningDisplayModeDialogWidget extends StatefulWidget {
  const MeaningDisplayModeDialogWidget({super.key});

  @override
  State<MeaningDisplayModeDialogWidget> createState() =>
      _MeaningDisplayModeDialogWidgetState();
}

class _MeaningDisplayModeDialogWidgetState
    extends State<MeaningDisplayModeDialogWidget> {
  final ConfigController controller = Get.find<ConfigController>();
  late String selectedCode;

  @override
  void initState() {
    super.initState();
    selectedCode = (controller.userSetting.value.expandLang.code).toString();
  }

  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "切换释义显示模式",
      width: 1200.wMin,
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: 750.wMin,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 32.wMin,
                right: 32.wMin,
                bottom: 24.wMin,
              ),
              child: _buildSectionWidget(
                title: "释义显示模式",
                child: Wrap(
                  spacing: 12.wMin,
                  runSpacing: 12.wMin,
                  children: _options.map((option) {
                    return _buildSelectChip(
                      name: option.title,
                      isSelected: selectedCode == option.code,
                      onTap: () {
                        selectedCode = option.code;
                        if (mounted) setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
          SizedBox(height: 32.wMin),
          _buildButtonsWidget(),
          SizedBox(height: 32.wMin),
        ],
      ),
    );
  }

  List<_MeaningDisplayModeOption> get _options => [
        _MeaningDisplayModeOption(
          code: _bilingualCode,
          title: '双语对照',
        ),
        const _MeaningDisplayModeOption(
          code: 'original',
          title: '原文语言',
        ),
        const _MeaningDisplayModeOption(
          code: 'translation',
          title: '译文语言',
        ),
        const _MeaningDisplayModeOption(
          code: 'none',
          title: '隐藏文本',
        ),
      ];

  String get _bilingualCode {
    final menus = controller.userSetting.value.expandDropdownMenu ?? const [];
    for (final item in menus) {
      final code = (item.code ?? '').trim();
      if (code.isEmpty) continue;
      if (code == 'original' || code == 'translation' || code == 'none') {
        continue;
      }
      return code;
    }
    final currentCode =
        (controller.userSetting.value.expandLang.code).toString();
    if (currentCode != 'original' &&
        currentCode != 'translation' &&
        currentCode != 'none' &&
        currentCode.isNotEmpty) {
      return currentCode;
    }
    return 'bilingual';
  }

  Widget _buildSectionWidget({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 180.wMin,
            padding: EdgeInsets.only(top: 6.wMin),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSelectChip({
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: isSelected
              ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2)
              : AppTheme.cSurfaceGhostBgSubtle.color.withValues(alpha: 0.1),
          border: Border.all(
            width: 1.wMin,
            color: isSelected
                ? AppTheme.cSurfaceBrand.color
                : AppTheme.cBorderDefault.color,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 20.wMin,
            color: isSelected
                ? AppTheme.cSurfaceBrand.color
                : AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildButtonsWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ButtonWidget(
            text: "重置",
            height: 56.wMin,
            borderRadius: 8.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            color: AppTheme.cSurfaceTertiary.color,
            border: Border.all(
              width: 0.8.wMin,
              color: AppTheme.cBorderDefault.color,
            ),
            fontSize: 20.wMin,
            fontWeight: FontWeight.w600,
            fontColor: AppTheme.cTextPrimary.color,
            sclae: 1.03,
            leftIcon: Container(
              margin: EdgeInsets.only(left: 4.wMin),
              child: SvgPicture.asset(
                "assets/svg/public/icon_reset.svg",
                width: 20.wMin,
                colorFilter: ColorFilter.mode(
                  AppTheme.cTextPrimary.color,
                  BlendMode.srcIn,
                ),
              ),
            ),
            onTap: () {
              selectedCode = _bilingualCode;
              if (mounted) setState(() {});
            },
          ),
          ButtonWidget(
            text: "确定",
            height: 56.wMin,
            borderRadius: 8.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            color: AppTheme.cSurfaceBrand.color,
            fontSize: 20.wMin,
            fontWeight: FontWeight.w600,
            sclae: 1.03,
            onTap: () {
              Get.back(
                result: MeaningDisplayModeDialogResult(code: selectedCode),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MeaningDisplayModeOption {
  final String code;
  final String title;

  const _MeaningDisplayModeOption({
    required this.code,
    required this.title,
  });
}

class CardLearningStyleDialogWidget extends StatefulWidget {
  const CardLearningStyleDialogWidget({super.key});

  @override
  State<CardLearningStyleDialogWidget> createState() =>
      _CardLearningStyleDialogWidgetState();
}

class _CardLearningStyleDialogWidgetState
    extends State<CardLearningStyleDialogWidget> {
  ConfigController controller = Get.find<ConfigController>();

  /// 所有风格列表
  List<TeamStyleEntityStyleItems> styleList = <TeamStyleEntityStyleItems>[];

  final List<ResourceTypeEnum> modeList = [
    ResourceTypeEnum.image,
    ResourceTypeEnum.video,
  ];
  ResourceTypeEnum selectMode = ResourceTypeEnum.image;
  late String selectStyle;

  @override
  void initState() {
    super.initState();
    selectMode = controller.currentShowResource.value;
    selectStyle = controller.currentShowStyleCode.value;

    if (selectMode == ResourceTypeEnum.image) {
      styleList = controller.allStyleImageList.toList();
    } else {
      styleList = controller.allStyleVideoList.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "切换模式与风格",
      width: 1200.wMin,
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: 750.wMin,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 32.wMin,
                right: 32.wMin,
                bottom: 24.wMin,
              ),
              child: Column(
                spacing: 16.wMin,
                children: [
                  _buildModeWidget(),
                  _buildStyleWidget(),
                ],
              ),
            ),
          ),
          Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
          SizedBox(height: 32.wMin),
          _buildButtonsWidget(),
          SizedBox(height: 32.wMin),
        ],
      ),
    );
  }

  Widget _buildModeWidget() {
    return _buildSectionWidget(
      title: "模式",
      showDivider: true,
      child: Wrap(
        spacing: 12.wMin,
        runSpacing: 12.wMin,
        children: List.generate(modeList.length, (index) {
          final bool selected = selectMode == modeList[index];
          return _buildSelectChip(
            name: modeList[index].name,
            isSelected: selected,
            onTap: () {
              _updateMode(modeList[index]);
            },
          );
        }),
      ),
    );
  }

  Widget _buildStyleWidget() {
    return _buildSectionWidget(
      title: "风格",
      showDivider: false,
      child: Wrap(
        spacing: 12.wMin,
        runSpacing: 12.wMin,
        children: List.generate(styleList.length, (index) {
          final TeamStyleEntityStyleItems item = styleList[index];
          final String styleCode = item.style ?? "";
          final bool selected = selectStyle == styleCode;
          return _buildSelectChip(
            name: controller.getCurrentStyleName(styleCode),
            isSelected: selected,
            onTap: () {
              if (styleCode.isEmpty) return;
              selectStyle = styleCode;
              if (mounted) setState(() {});
            },
          );
        }),
      ),
    );
  }

  Widget _buildSectionWidget({
    required String title,
    required Widget child,
    required bool showDivider,
  }) {
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  width: 1.wMin,
                  color: AppTheme.cBorderPrimary.color,
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 180.wMin,
            padding: EdgeInsets.only(top: 6.wMin),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSelectChip({
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: isSelected
              ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2)
              : AppTheme.cSurfaceGhostBgSubtle.color.withValues(alpha: 0.1),
          border: Border.all(
            width: 1.wMin,
            color: isSelected
                ? AppTheme.cSurfaceBrand.color
                : AppTheme.cBorderDefault.color,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 20.wMin,
            color: isSelected
                ? AppTheme.cSurfaceBrand.color
                : AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void _updateMode(ResourceTypeEnum mode) {
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
  }

  void _resetSelection() {
    _updateMode(ResourceTypeEnum.image);
  }

  Widget _buildButtonsWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ButtonWidget(
            text: "重置",
            height: 56.wMin,
            borderRadius: 8.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            color: AppTheme.cSurfaceTertiary.color,
            border: Border.all(
              width: 0.8.wMin,
              color: AppTheme.cBorderDefault.color,
            ),
            fontSize: 20.wMin,
            fontWeight: FontWeight.w600,
            fontColor: AppTheme.cTextPrimary.color,
            sclae: 1.03,
            leftIcon: Container(
              margin: EdgeInsets.only(left: 4.wMin),
              child: SvgPicture.asset(
                "assets/svg/public/icon_reset.svg",
                width: 20.wMin,
                colorFilter: ColorFilter.mode(
                  AppTheme.cTextPrimary.color,
                  BlendMode.srcIn,
                ),
              ),
            ),
            onTap: () {
              _resetSelection();
            },
          ),
          ButtonWidget(
            text: "确定",
            height: 56.wMin,
            borderRadius: 8.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            color: AppTheme.cSurfaceBrand.color,
            fontSize: 20.wMin,
            fontWeight: FontWeight.w600,
            sclae: 1.03,
            onTap: () {
              final CardLearningStyleDialogReslut reslut =
                  CardLearningStyleDialogReslut(
                resource: selectMode,
                style: selectStyle,
              );
              Get.back(result: reslut);
            },
          ),
        ],
      ),
    );
  }
}
