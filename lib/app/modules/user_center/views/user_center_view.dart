import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/app/modules/user_center/views/user_center_language_widget.dart';
import 'package:langwise/common/entities/user_center_option_entity.dart';
import 'package:langwise/common/widgets/guide_engine/guide_task_float_widget.dart';
import 'package:langwise/common/widgets/guide_engine/guide_manager.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../routes/routes.dart';
import '../bindings/user_center_binding.dart';
import '../controllers/user_center_controller.dart';
import 'user_center_activate_students_widget.dart';
import 'user_center_assets_widget.dart';
import 'user_center_basic_widget.dart';
import 'user_center_member_widget.dart';
import 'user_center_students_widget.dart';
import 'user_center_theme_setting_widget.dart';
import 'user_visual_style_widget.dart';

class UserCenterView extends GetView<UserCenterController> {
  final String tagText;
  const UserCenterView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      UserCenterView(tagText: tag),
      binding: UserCenterBinding(tagText: tag),
      routeName: Routes.USER_CENTER,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppTheme.cBgPrimary,
          body: Stack(
            children: [
              Container(
                alignment: Alignment.topCenter,
                child: Container(
                  alignment: Alignment.topCenter,
                  width: 1680.wMin,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 40.wMin,
                  ),
                  child: Column(
                    children: [
                      _buildTitleWidget(context),
                      SizedBox(height: 10.wMin),
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value) return Container();
                          return SingleChildScrollView(
                            controller: controller.autoScrollController,
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).padding.bottom + 105.wMin,
                              left: 10.wMin,
                              right: 10.wMin,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildPersonalDataWidget(context),
                                Obx(() {
                                  if (controller.userStore.userInfo.value.memberId == null) return Container();
                                  return AutoScrollTag(
                                    key: const ValueKey("AutoScrollTag1"),
                                    controller: controller.autoScrollController,
                                    index: 0,
                                    child: Container(
                                      margin: EdgeInsets.only(top: 24.wMin),
                                      child: UserCenterActivateStudentsWidget(tagText: tagText),
                                    ),
                                  );
                                }),
                                SizedBox(height: 24.wMin),
                                UserCenterStudentsWidget(tagText: tagText),
                                SizedBox(height: 16.wMin),
                                Obx(() {
                                  if (controller.userStore.userInfo.value.memberId == null) return Container();
                                  return _buildLearningSettingsWidget(context);
                                }),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              _taskFloat()
            ],
          ),
        );
      },
    );
  }

  Widget _taskFloat() {
    return Obx(() {
      GuideManager.instance.refreshTick.value;
      final tasks = GuideManager.instance.tasks;
      if (tasks.isEmpty) return const SizedBox.shrink();
      final allDone = tasks.every((t) => t.isDone);
      if (!allDone) return const SizedBox.shrink();
      return _DraggableDockedWidget(
        bottomPadding: 168.wMin,
        scrollController: controller.autoScrollController,
        retractVisibleFraction: 0.5,
        idleVisibleFraction: 1.0,
        child: const GuideTaskFloatWidget(text: '功能指南', showRepeat: true),
      );
    });
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Row(
      children: [
        const BackWidget(title: "用户中心"),
        const Spacer(),
        SizedBox(width: 16.wMin),
        _buildTitleButtonWidget(
          text: "推荐有礼",
          onTap: () {
            controller.toInviter();
          },
        ),
        SizedBox(width: 16.wMin),
        Obx(() {
          String? helperVideoUrl = controller.userPreferenceOptionData.value.helperVideoUrl;
          if (helperVideoUrl == null || helperVideoUrl == "") return Container();
          return Container(
            margin: EdgeInsets.only(right: 10.wMin),
            child: HelpIVideoIconWidget(
              size: 32.wMin,
              padding: EdgeInsets.symmetric(horizontal: 20.wMin),
              helpVideoUrl: helperVideoUrl,
            ),
          );
        }),
        TapScaleWidget(
          onTap: () {
            controller.toAboutUs();
          },
          sclae: 1.1,
          child: Container(
            padding: EdgeInsets.all(16.wMin),
            color: Colors.transparent,
            child: SvgPicture.asset(
              "assets/svg/public/icon_setting1.svg",
              width: 32.wMin,
              height: 32.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleButtonWidget({
    required String text,
    void Function()? onTap,
  }) {
    return TapScaleWidget(
      onTap: OptimizeUtils.noneThrottle(() {
        onTap?.call();
      }, 300),
      sclae: 1.01,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.wMin),
        height: 64.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.wMin),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.0, 0.5, 1.0],
            colors: [
              Color(0xFFA78BFA),
              Color(0xFF818CF8),
              Color(0xFFD946EF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA78BFA),
              blurRadius: 10.wMin,
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cInverseTextLight.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 个人资料
  Widget _buildPersonalDataWidget(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            spacing: 20.wMin,
            children: [
              UserCenterBasicWidget(tagText: tagText),
              UserCenterMemberWidget(tagText: tagText),
            ],
          ),
        ),
        SizedBox(height: 24.wMin),
        Obx(() {
          if (controller.userStore.userInfo.value.review == 0) {
            return Row(
              spacing: 20.wMin,
              children: [
                UserCenterCardCouponsWidget(tagText: tagText),
                UserCenterLearnPointsWidget(tagText: tagText),
                UserCenterNsCoinWidget(tagText: tagText),
              ],
            );
          }
          return Row(
            spacing: 20.wMin,
            children: [
              UserCenterLearnPointsWidget(tagText: tagText),
              UserCenterNsCoinWidget(tagText: tagText),
            ],
          );
        }),
      ],
    );
  }

  /// 学习设置
  Widget _buildLearningSettingsWidget(BuildContext context) {
    return AutoScrollTag(
      key: const ValueKey("AutoScrollTag2"),
      controller: controller.autoScrollController,
      index: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "学习偏好设置",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20.wMin),
          UserCenterLanguageWidget(tagText: tagText),
          SizedBox(height: 34.wMin),
          //设置显示，播放速度
          Row(
            spacing: 16.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // UserCenterDialectWidget(),
              _preferenceWidget(controller.userPreferenceOptionData.value.exercisePreference, true),
              _preferenceWidget(controller.userPreferenceOptionData.value.extensionPreference, false),
            ],
          ),
          UserVisualStyleWidget(tagText: tagText),
          SizedBox(height: 32.wMin),
          Row(
            spacing: 35.wMin,
            children: [UserCenterThemeSettingWidget(tagText: tagText), Expanded(child: Container())],
          ),
        ],
      ),
    );

    // return AutoScrollTag(
    //   key: const ValueKey("AutoScrollTag2"),
    //   controller: controller.autoScrollController,
    //   index: 1,
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(
    //         "学习设置",
    //         style: TextStyle(
    //           fontSize: 28.wMin,
    //           color: AppTheme.cTextPrimary,
    //           fontWeight: FontWeight.w600,
    //         ),
    //       ),
    //       SizedBox(height: 24.wMin),
    //       // UserCenterLangLearnSettingsWidget(),
    //       // SizedBox(height: 32.wMin),
    //       Row(
    //         spacing: 16.wMin,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: const [
    //           UserCenterDialectWidget(),
    //           UserCenterSyllableDivisionWidget(),
    //         ],
    //       ),
    //       SizedBox(height: 32.wMin),
    //       Row(
    //         spacing: 16.wMin,
    //         children: const [
    //           UserCenterVisualStyleWidget(),
    //           UserCenterThemeSettingWidget(),
    //         ],
    //       ),

    //     ],
    //   ),
    // );
  }

  Widget _preferenceWidget(UserPreferenceExercisePreference? preference, bool isStudy) {
    return Expanded(
        child: Container(
            padding: EdgeInsets.all(24.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cSurfaceSecondary.color,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50.wMin,
                    height: 50.wMin,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cFeedbackInfoBackground,
                    ),
                    child: SvgPicture.asset(
                      isStudy ? 'assets/svg/user_center/icon_preference_study.svg' : 'assets/svg/user_center/icon_preference_extension.svg',
                      width: 30.wMin,
                      height: 30.wMin,
                    ),
                  ),
                  SizedBox(width: 8.wMin),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preference!.title ?? "",
                          style: TextStyle(
                            fontSize: 28.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.wMin),
                        Text(
                          preference.description ?? "",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(preference.warning ?? '', style: TextStyle(fontSize: 24.wMin, color: AppTheme.cFeedbackWarningText))
                      ],
                    ),
                  ),
                  SizedBox(width: 8.wMin),
                ],
              ),
              Container(
                height: 1.wMin,
                color: AppTheme.cBorderPrimary,
                margin: EdgeInsets.symmetric(vertical: 24.wMin),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  preference.definitionDisplayMode!.title ?? "",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.wMin),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceTertiary,
                    borderRadius: BorderRadius.circular(16.wMin),
                  ),
                  padding: EdgeInsets.all(4.wMin),
                  child: Row(
                      spacing: 4.wMin,
                      children: List.generate(preference.definitionDisplayMode!.options!.length, (index) {
                        UserPreferenceDefinitionDisplayModeOption option = preference.definitionDisplayMode!.options![index]!;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (isStudy) {
                                controller.changeExerciseLanguagePreference(option.code!);
                              } else {
                                controller.changeExtensionLanguagePreference(option.code!);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.wMin),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isStudy
                                    ? option.code == controller.exercisePreference.value
                                        ? AppTheme.cSurfaceInfo
                                        : AppTheme.cSurfaceQuaternary
                                    : option.code == controller.extensionPreference.value
                                        ? AppTheme.cSurfaceInfo
                                        : AppTheme.cSurfaceQuaternary,
                                borderRadius: BorderRadius.circular(8.wMin),
                              ),
                              child: Text(preference.definitionDisplayMode!.options![index]!.title ?? "", style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextPrimary)),
                            ),
                          ),
                        );
                      })),
                ),
                SizedBox(height: 8.wMin),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/svg/manage/icon_info_circle.svg',
                      width: 24.wMin,
                      height: 24.wMin,
                    ),
                    SizedBox(width: 8.wMin),
                    Text(controller.getDescription(preference, isStudy), style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextBrand))
                  ],
                )
              ]),
              _buildPlaySpeedWidget(preference.playSpeed ?? UserCenterOptionEntityNationalConfigsSpeed(), isStudy),
            ])));
  }

  /// 播放速度按钮
  Widget _buildPlaySpeedWidget(UserCenterOptionEntityNationalConfigsSpeed configSpeed, bool isStudy) {
    List<double?> playSpeeds = configSpeed.options ?? [];
    if (playSpeeds.isEmpty) return Container();

    double playSpeed = isStudy ? controller.playSpeed.value : controller.otherPlaySpeed.value;
    return Container(
      margin: EdgeInsets.only(top: 24.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.wMin,
        children: [
          Text(
            configSpeed.title ?? "",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            width: double.infinity,
            height: 68.wMin,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cSurfaceTertiary.color,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(playSpeeds.length, (index) {
                return TapScaleWidget(
                  onTap: () {
                    if (isStudy) {
                      controller.changePlaySpeed(playSpeeds[index] ?? 1.0);
                    } else {
                      controller.changeOtherPlaySpeed(playSpeeds[index] ?? 1.0);
                    }
                  },
                  sclae: 1,
                  child: Container(
                    height: 52.wMin,
                    width: 52.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: playSpeed == playSpeeds[index] ? AppTheme.cBgBrand.color : Colors.transparent,
                    ),
                    child: Text(
                      "${playSpeeds[index] ?? "1.0"}",
                      style: TextStyle(
                        fontSize: 22.wMin,
                        color: playSpeed == playSpeeds[index] ? AppTheme.cStaticWhite.color : AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}

class _DraggableDockedWidget extends StatefulWidget {
  final Widget child;
  final double bottomPadding;
  final ScrollController? scrollController;
  final double retractVisibleFraction;
  final double idleVisibleFraction;

  const _DraggableDockedWidget({
    required this.child,
    required this.bottomPadding,
    this.scrollController,
    this.retractVisibleFraction = 0.5,
    this.idleVisibleFraction = 1.0,
  });

  @override
  State<_DraggableDockedWidget> createState() => _DraggableDockedWidgetState();
}

class _DraggableDockedWidgetState extends State<_DraggableDockedWidget> {
  final GlobalKey _childKey = GlobalKey();

  Offset? _offset;
  Size _childSize = const Size(180, 56);
  bool _scrolling = false;
  Timer? _scrollEndTimer;
  bool _relayoutScheduled = false;

  @override
  void initState() {
    super.initState();
    _childSize = Size(162.wMin, 66.wMin);
    widget.scrollController?.addListener(_onScrollChanged);
  }

  @override
  void didUpdateWidget(covariant _DraggableDockedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController == widget.scrollController) return;
    oldWidget.scrollController?.removeListener(_onScrollChanged);
    widget.scrollController?.addListener(_onScrollChanged);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScrollChanged);
    _scrollEndTimer?.cancel();
    super.dispose();
  }

  void _onScrollChanged() {
    _scrollEndTimer?.cancel();
    if (!_scrolling) {
      setState(() {
        _scrolling = true;
      });
    }
    _scrollEndTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() {
        _scrolling = false;
      });
    });
  }

  void _ensureChildSize() {
    final ctx = _childKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject();
    if (box is! RenderBox) return;
    final size = box.size;
    if (size.width <= 0 || size.height <= 0) return;

    if (_childSize == size) return;
    _childSize = size;

    if (_relayoutScheduled) return;
    _relayoutScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _relayoutScheduled = false;
      setState(() {
        _offset = null;
      });
    });
  }

  Offset _clampOffset(Offset raw, Size screenSize, EdgeInsets padding) {
    final minX = -_childSize.width / 2;
    final maxX = screenSize.width - _childSize.width / 2;
    final minY = padding.top;
    final maxY = screenSize.height - padding.bottom - _childSize.height;

    final dx = raw.dx.clamp(minX, maxX).toDouble();
    final dy = raw.dy.clamp(minY, maxY).toDouble();
    return Offset(dx, dy);
  }

  Offset _snapToEdge(Offset current, Size screenSize, EdgeInsets padding) {
    final dockLeft = current.dx + _childSize.width / 2 <= screenSize.width / 2;
    final dx = dockLeft ? -_childSize.width / 2 : (screenSize.width - _childSize.width / 2);
    return _clampOffset(Offset(dx, current.dy), screenSize, padding);
  }

  double _dockedDx(Size screenSize, {required double visibleFraction}) {
    final clamped = visibleFraction.clamp(0.05, 1.0);
    return screenSize.width - (_childSize.width * clamped);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screen = media.size;
    final padding = EdgeInsets.only(
      top: media.padding.top,
      bottom: media.padding.bottom + widget.bottomPadding,
    );

    _ensureChildSize();

    _offset ??= _snapToEdge(
      Offset(
        screen.width - _childSize.width / 2,
        (screen.height - padding.bottom - _childSize.height - 24.wMin).clamp(padding.top, double.infinity),
      ),
      screen,
      padding,
    );

    final pos = _clampOffset(_offset!, screen, padding);
    final visibleFraction = _scrolling ? widget.retractVisibleFraction : widget.idleVisibleFraction;
    final dx = _dockedDx(screen, visibleFraction: visibleFraction);
    final target = _clampOffset(Offset(dx, pos.dy), screen, padding);
    _offset = target;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      left: target.dx,
      top: target.dy,
      child: KeyedSubtree(
        key: _childKey,
        child: widget.child,
      ),
    );
  }
}
