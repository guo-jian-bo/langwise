import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../routes/routes.dart';
import '../bindings/elements_morpheme_detils_binding.dart';
import '../controllers/elements_morpheme_detils_controller.dart';
import 'elements_morpheme_detils_grid_view_widget.dart';

class ElementsMorphemeDetilsView
    extends GetView<ElementsMorphemeDetilsController> {
  final String tagText;
  const ElementsMorphemeDetilsView({super.key, required this.tagText});

  @override
  // String? get tag => Get.arguments['contentId']?.toString();
  // String? get tag => StorageUtil().getString("ElementsMorphemeDetilsDuplicatePagesId");
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => ElementsMorphemeDetilsView(tagText: tag),
      binding: ElementsMorphemeDetilsBinding(tagText: tag),
      routeName: Routes.EN_MORPHEME_DETAIL,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool hasLock =
          controller.morphemeDetils.value.rights?.isLock == true ||
          controller.morphemeDetils.value.rights?.isNoRights == true;
      final bool isNebulaView = controller.gridMenuIndex.value == 0;
      return Scaffold(
        backgroundColor: AppTheme.cSurfacePrimary,
        body: isNebulaView
            ? _buildNebulaScaffold(context, hasLock)
            : Column(
                children: [
                  _buildTitleButtonsWidget(context),
                  Expanded(
                    child: _buildContentStack(context, hasLock),
                  ),
                ],
              ),
        floatingActionButton: IgnorePointer(
          ignoring: hasLock,
          child: _buildBottomRightActions(context),
        ),
      );
    });
  }

  Widget _buildBottomRightActions(BuildContext context) {
    return Obx(() {
      final bool showExtraActions = controller.gridMenuIndex.value == 1;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showExtraActions) ...[
            _wrapFloatingAction(_buildStyleMediaButton(context)),
            SizedBox(height: 12.wMin),
            _wrapFloatingAction(_buildPosFilterButton()),
            SizedBox(height: 12.wMin),
            _wrapFloatingAction(_buildDisplayLanguageButton(context)),
            SizedBox(height: 16.wMin),
          ],
          _buildViewSwitchWidget(),
        ],
      );
    });
  }

  Widget _buildNebulaScaffold(BuildContext context, bool hasLock) {
    return Stack(
      children: [
        Positioned.fill(
          child: _buildContentStack(context, hasLock),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: _buildTitleButtonsWidget(context),
        )
      ],
    );
  }

  Widget _buildContentStack(BuildContext context, bool hasLock) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: hasLock,
            child: StarrySkyBackgroundWidget(
              starCount: 11,
              minStarSize: 1.wMin,
              maxStarSize: 3.wMin,
              minTwinkleSpeed: 0.5,
              maxTwinkleSpeed: 0.6,
              minBrightness: 0.1,
              maxBrightness: 0.2,
              child: Obx(() {
                Widget body = Container();
                if (controller.gridMenuIndex.value == 0) {
                  if (controller.morphemeDetils.value.content == null) {
                    return Container();
                  }
                  body = NebulaViewWidget(
                    key: ValueKey(controller.posMenuIndex.value),
                    colorConfigs: Get.find<ConfigController>()
                        .colorConfigs
                        .value
                        .pos,
                    content: controller.morphemeDetils.value.content,
                    type: controller.morphemeDetils.value.type,
                    orbits: controller.nebulaData,
                    onTapCenter: () {
                      controller.showAffixDialog(context);
                    },
                    onTapWord: (data) {
                      controller.onTapWord(context, data);
                    },
                  );
                } else {
                  body = ElementsMorphemeDetilsGridViewWidget(
                    tagText: tagText,
                    key: const ValueKey(1),
                  );
                }
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: body,
                );
              }),
            ),
          ),
        ),
        if (hasLock)
          Positioned.fill(
            child: LockOverlayWidget(
              rights: controller.morphemeDetils.value.rights,
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }

  Widget _wrapFloatingAction(Widget child) {
    return Align(
      alignment: Alignment.centerRight,
      child: child,
    );
  }

  Widget _buildViewSwitchWidget() {
    return 


    
    Container(
      width: 175.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.wMin),
        color: AppTheme.cBgSecondary.withValues(alpha: 0.92),
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cBorderPrimary,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cBlackAlpha10,
            blurRadius: 18.wMin,
            offset: Offset(0, 8.wMin),
          ),
        ],
      ),
      child:

      ClipRRect(
   borderRadius: BorderRadius.circular(32.wMin),
     child:BackdropFilter(filter: ImageFilter.blur(
      sigmaX: 10,
      sigmaY: 10,
     ),
     child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewSwitchItem("网格视图", 1, isTop: true),
          _buildViewSwitchItem("星云视图", 0, isTop: false),
        ],
      ),
    ),
     ) ,


);
  
  
  }

  Widget _buildViewSwitchItem(String title, int index, {required bool isTop}) {
    return Obx(() {
      final bool isSelected = controller.gridMenuIndex.value == index;
      return TapScaleWidget(
        onTap: () {
          controller.switchView(index);
        },
        sclae: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999.wMin),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isSelected ? 10.wMin : 0,
              sigmaY: isSelected ? 10.wMin : 0,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 64.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999.wMin),
                color: isSelected
                    ? AppTheme.cSurfaceInfo.color.withValues(alpha: 0.15)
                    : Colors.transparent,
                border: Border.all(
                  width: isSelected ? 1.wMin : 0,
                  color: isSelected
                      ? AppTheme.cSurfaceInfo.color.withValues(alpha: 0.35)
                      : Colors.transparent,
                ),
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppTheme.cSurfaceInfo.color
                      : AppTheme.cTextPrimary.withValues(alpha: 0.88),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTitleButtonsWidget(BuildContext context) {
    return const BreadcrumbWidget();
  }

  Widget _buildNebulaFloatingTitleWidget() {
    return Obx(() {
      final String content =
          (controller.morphemeDetils.value.content ?? '').trim().isEmpty
              ? controller.breadcrumbTitle
              : (controller.morphemeDetils.value.content ?? '').trim();
      final String type = (controller.morphemeDetils.value.type ?? '').trim();
      final Color accent = StatusUtils.getMorphemeTagColor(type);
      return IgnorePointer(
        ignoring: true,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.wMin),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 14.wMin,
                sigmaY: 14.wMin,
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: 560.wMin),
                padding: EdgeInsets.symmetric(
                  horizontal: 24.wMin,
                  vertical: 18.wMin,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.wMin),
                  color: AppTheme.cBgSecondary.withValues(alpha: 0.7),
                  border: Border.all(
                    color: AppTheme.cBorderPrimary.withValues(alpha: 0.9),
                    width: 1.wMin,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (type.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.wMin,
                          vertical: 6.wMin,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999.wMin),
                          color: accent.withValues(alpha: 0.18),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.36),
                            width: 1.wMin,
                          ),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (type.isNotEmpty) SizedBox(height: 10.wMin),
                    Text(
                      content,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 36.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStyleMediaButton(BuildContext context) {
    final ConfigController configController = Get.find<ConfigController>();
    return Obx(() {
      if (configController.allStyleList.isEmpty) return Container();
      final String styleName = configController.getCurrentStyleName(
        configController.currentShowStyleCode.value,
      );
      return TapScaleWidget(
        sclae: 1.05,
        onTap: () async {
          final CardLearningStyleDialogReslut? reslut =
              await CardLearningStyleDialog.show(context: context);
          if (reslut == null) return;
          configController.changeCurrentShowResource(reslut.resource);
          configController.changeCurrentStyleCode(reslut.style);
          await controller.reloadForStyleChange();
        },
        child: _buildCapsuleActionButton(
          title: styleName.isNotEmpty ? styleName : "风格媒体",
          color: configController.currentShowResource.value.color,
          svg: configController.currentShowResource.value.svg,
        ),
      );
    });
  }

  Widget _buildPosFilterButton() {
    return Obx(() {
      if (controller.posMenuList.length <= controller.posMenuIndex.value) {
        return Container();
      }
      return IconDropdownCheckWidget(
        items: controller.posMenuList,
        fontSize: 28.wMin,
        width: 260.wMin,
        selectIndex: controller.posMenuIndex.value,
        sclae: 1.01,
        alignRight: true,
        child: _buildCapsuleDropdownButton(
          title: controller.posMenuList[controller.posMenuIndex.value].title,
          color: AppTheme.cTextPrimary,
          svg: 'assets/svg/public/icon_translation.svg',
        ),
        onTap: (data, index) {
          controller.switchPos(index);
        },
      );
    });
  }

  Widget _buildDisplayLanguageButton(BuildContext context) {
    final ConfigController configController = Get.find<ConfigController>();
    return Obx(() {
      final dynamic lang = configController.userSetting.value.expandLang;
      return TapScaleWidget(
        sclae: 1.01,
        onTap: () async {
          final MeaningDisplayModeDialogResult? result =
              await MeaningDisplayModeDialog.show(context: context);
          if (result == null) return;
          configController.setLearLangSetting(
            result.code,
            LearModePreference.extension,
          );
        },
        child: _buildCapsuleDropdownButton(
          title: _displayLanguageTitle(lang),
          color: AppTheme.cSurfaceInfo.color,
          svg: 'assets/svg/public/icon_translation.svg',
        ),
      );
    });
  }

  Widget _buildCapsuleDropdownButton({
    required String title,
    required Color color,
    required String svg,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10.wMin,
          sigmaY: 10.wMin,
        ),
        child: Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                svg,
                width: 32.wMin,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              SizedBox(width: 4.wMin),
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
    );
  }

  Widget _buildCapsuleActionButton({
    required String title,
    required Color color,
    required String svg,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10.wMin,
          sigmaY: 10.wMin,
        ),
        child: Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                svg,
                width: 32.wMin,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              SizedBox(width: 4.wMin),
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
    );
  }

  String _displayLanguageTitle(dynamic preference) {
    final String code = (preference?.code ?? '').toString();
    if (code == 'original') return '原文语言';
    if (code == 'translation') return '译文语言';
    if (code == 'none') return '隐藏文本';
    return '双语对照';
  }
}
