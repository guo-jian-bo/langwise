import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../bindings.dart';
import '../controllers/zhendu_home_controller.dart';

class ZhenduHomeView extends GetView<ZhenduHomeController> {
  final String tagText;
  const ZhenduHomeView({
    super.key,
    this.tagText = Routes.ZHENDU_HOME,
  });

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return Get.to<T>(
      () => ZhenduHomeView(tagText: tag),
      binding: ZhenduBinding(tagText: tag),
      routeName: Routes.ZHENDU_HOME,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Obx(() {
        if (controller.loadStatus.value == -1) {
          return const Column(
            children: [
              BreadcrumbWidget(),
              Expanded(child: Center()),
            ],
          );
        }
        if (controller.loadStatus.value == 1) {
          return Column(
            children: [
              const BreadcrumbWidget(),
              Expanded(
                child: NotDataWidget(
                  message: '加载失败',
                  buttonText: '重试',
                  onButton: controller.initPage,
                ),
              ),
            ],
          );
        }
        if (controller.loadStatus.value == 4) {
          return Column(
            children: [
              const BreadcrumbWidget(),
              Expanded(
                child: NotDataWidget(
                  message: '暂无剧场',
                  buttonText: '刷新',
                  onButton: controller.initPage,
                ),
              ),
            ],
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final theaters = controller.theaters;

            return Column(
              children: [
                const BreadcrumbWidget(),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      52.wMin,
                      0,
                      52.wMin,
                      24.wMin + MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      children: [
                        _buildHeader(),
                        SizedBox(height: 22.wMin),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (theaters.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              if (theaters.length <= 3) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: theaters
                                      .map((e) => _ZhenduTheaterCard(theater: e))
                                      .toList(),
                                );
                              }

                              final children = <Widget>[];
                              for (final theater in theaters) {
                                if (children.isNotEmpty) {
                                  children.add(SizedBox(width: 18.wMin));
                                }
                                children.add(_ZhenduTheaterCard(theater: theater));
                              }
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                                child: Row(children: children),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildHeader() {
    final desc = controller.description.value.trim();
    return Column(
      children: [
        SizedBox(height: 6.wMin),
        _buildGradientTitle(),
        if (desc.isNotEmpty) ...[
          SizedBox(height: 12.wMin),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 720.wMin),
            child: Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.wMin,
                height: 1.6,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color.withValues(alpha: 0.80),
              ),
            ),
          ),
        ],
        SizedBox(height: 14.wMin),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 920.wMin),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.cBorderSecondary.color.withValues(alpha: 0.60),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '甄读',
          style: TextStyle(
            fontSize: 54.wMin,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFF6EE7B7),
                Color(0xFFF0ABFC),
                Color(0xFFFDE68A),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            ' 剧场',
            style: TextStyle(
              fontSize: 54.wMin,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ),
      ],
    );
  }

}

class _ZhenduTheaterCard extends StatefulWidget {
  final ZhenduTheaterEntity theater;
  const _ZhenduTheaterCard({required this.theater});

  @override
  State<_ZhenduTheaterCard> createState() => _ZhenduTheaterCardState();
}

class _ZhenduTheaterCardState extends State<_ZhenduTheaterCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theater = widget.theater;
    final isLocked = theater.rights?.allLock == true;
    final isComingSoon = theater.status == 2;
    final zhTitle = LearningLangUtils.getLocalLang(theater.title)?.text ?? '';
    final desc = LearningLangUtils.getLocalLang(theater.description)?.text ?? LearningLangUtils.getLearningLang(theater.description)?.text ?? '';
    final hallNote = LearningLangUtils.getLocalLang(theater.tip)?.text ?? LearningLangUtils.getLearningLang(theater.tip)?.text ?? '';

    final marquee = (theater.label ?? '').toUpperCase();
    final subtitle = (theater.categoryTitle ?? '').trim();
    final countText = _buildScriptCountText(theater);
    final gradientColors = _theaterAccentGradient(theater.category);
    final glow = _theaterGlow(theater.category);

    final borderAlpha = _hovered ? 0.24 : 0.10;
    final bgAlpha = _hovered ? 0.05 : 0.03;
    final translateY = _hovered ? -4.wMin : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: TapScaleWidget(
        onTap: () {
          if (isLocked) {
            ToastUtils.showToast(text: theater.rights?.message ?? '暂无权限');
            return;
          }
          if (isComingSoon) {
            ToastUtils.showToast(text: theater.statusTip ?? '敬请期待');
            return;
          }
          TagRoutes.toNamed(
            Routes.ZHENDU_THEATER_LIST,
            tagText:
                '${Routes.ZHENDU_THEATER_LIST}_${(theater.category ?? '').trim()}',
            arguments: {
              'theater': theater,
            },
          );
        },
        sclae: 1.01,
        child: Opacity(
          opacity: (isLocked || isComingSoon) ? 1 : 1,
          child: AnimatedContainer(
            width: 555.wMin,
            height: 718.wMin,
      
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, translateY, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32.wMin),
              border: Border.all(color: AppTheme.cBorderSecondary.color.withValues(alpha: borderAlpha)),
              color: AppTheme.cSurfacePrimary.color.withValues(alpha: bgAlpha),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32.wMin),
                    child: Transform.scale(
                      scale: _hovered ? 1.05 : 1.0,
                      child: theater.backgroundImage == null || theater.backgroundImage!.trim().isEmpty
                          ? Container(color: AppTheme.cBgTertiary.color)
                          : CachedImageWidget(
                             placeholder: buildLoadingWidget(fit: BoxFit.cover),
                              theater.backgroundImage ?? '',
                              fit: BoxFit.cover,
                              errorWidget:  buildNetworkWidget(fit: BoxFit.cover),
                            ),
                    ),
                  ),
                ),
               
                Positioned(
                  left: 24.wMin,
                  right: 24.wMin,
                  top: 24.wMin,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      _buildGlassPill(
                        minWidth: 270.wMin,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              marquee,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.wMin,
                                letterSpacing: 3.2,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.55),
                              ),
                            ),
                            SizedBox(height: 6.wMin),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 22.wMin,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.95),
                              ),
                            ),
                          ],
                        ),
                      ),

                      _buildGlassPill(
                        minWidth: 130.wMin,
                        alignment: Alignment.center,
                        child: Text(
                          countText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.wMin,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.88),
                          ),
                        ),
                      )
                    ],
                  ),
                ),


                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.wMin, 118.wMin, 24.wMin, 24.wMin),
                    child: Column(
                      children: [
                        SizedBox(height: 48.wMin),
                        _buildCrest(glow, theater.iconUrl),
                        const Spacer(),
                        _buildBottomPanel(
                          subtitle: subtitle,
                          title: zhTitle,
                          description: desc,
                          hallNote: hallNote,
                          hovered: _hovered,
                          accentGradient: gradientColors,
                          isComingSoon: isComingSoon,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Positioned(
                //   left: 32.wMin,
                //   right: 32.wMin,
                //   bottom: 0,
                //   child: AnimatedOpacity(
                //     duration: const Duration(milliseconds: 500),
                //     curve: Curves.easeOutCubic,
                //     opacity: _hovered ? 1.0 : 0.45,
                //     child: Container(
                //       height: 1.wMin,
                //       decoration: BoxDecoration(
                //         gradient: LinearGradient(
                //           colors: [
                //             gradientColors.first,
                //             gradientColors.last,
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),

                if (isLocked)
                  Positioned(
                    right: 18.wMin,
                    bottom: 18.wMin,
                    child: _buildLockBadge(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassPill({
    required Widget child,
    double? minWidth,
    AlignmentGeometry alignment = Alignment.centerLeft,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.wMin),
      child: PlatformBackdropFilterWidget(
        sigmaX: 14,
        sigmaY: 14,
        child: Container(
          alignment: alignment,
          height: 90.wMin,
          constraints: BoxConstraints(minWidth: (minWidth ?? 0)),
          padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
            border: Border.all(color: AppTheme.cBorderSecondary.color.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(18.wMin),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildCrest(Color glow, String? iconUrl) {
    final hasIconUrl = iconUrl != null && iconUrl.trim().isNotEmpty;
    return SizedBox(
      height: 120.wMin,
      width: 120.wMin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glow.withValues(alpha: 0.28),
              ),
            ),
          ),
       
          SizedBox(
            width: 100.wMin,
            height: 100.wMin,
            child: hasIconUrl
                ? CachedImageWidget(
              placeholder: SvgPicture.asset(
                "assets/svg/public/icon_user.svg",
                width: 60.wMin,
                height: 60.wMin,
              ),
              errorWidget: SvgPicture.asset(
                "assets/svg/public/icon_user.svg",
                width: 60.wMin,
                height: 60.wMin,
              ),
                    iconUrl,
                    fit: BoxFit.contain,

                  )
                : SvgPicture.asset(
              "assets/svg/public/icon_user.svg",
              width: 60.wMin,
              height: 60.wMin,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel({
    required String subtitle,
    required String title,
    required String description,
    required String hallNote,
    required bool hovered,
    required List<Color> accentGradient,
    required bool isComingSoon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28.wMin),
      child: PlatformBackdropFilterWidget(
        sigmaX: 14,
        sigmaY: 14,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(28.wMin),
            border: Border.all(color: AppTheme.cBorderSecondary.color.withValues(alpha: 0.30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle.toUpperCase(),
                style: TextStyle(
                  fontSize: 16.wMin,
                  letterSpacing: 4.2,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.55),
                ),
              ),
              SizedBox(height: 10.wMin),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 44.wMin,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.98),
                ),
              ),
              SizedBox(height: 12.wMin),
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22.wMin,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.76),
                ),
              ),
              if (hallNote.trim().isNotEmpty) ...[
                SizedBox(height: 12.wMin),
                Text(
                  hallNote,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.62),
                  ),
                ),
              ],
              SizedBox(height: 14.wMin),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(hovered ? 4.wMin : 0, 0, 0),
                child: Row(
                  mainAxisSize:(isComingSoon)? MainAxisSize.max:MainAxisSize.min,
                    mainAxisAlignment:(isComingSoon)? MainAxisAlignment.center:MainAxisAlignment.start,
                    children: [
                    if (isComingSoon) ...[
                      SvgPicture.asset(
                        'assets/svg/public/lock.svg',
                        width: 22.wMin,
                        height: 22.wMin,
                      ),
                      SizedBox(width: 8.wMin),
                      Text(
                        '敬请期待',
                        style: TextStyle(
                          fontSize: 22.wMin,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFF97316),
                        ),
                      ),
                    ] else ...[
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(colors: accentGradient).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          );
                        },
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          '步入剧场',
                          style: TextStyle(
                            fontSize: 22.wMin,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.wMin),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(colors: accentGradient).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          );
                        },
                        blendMode: BlendMode.srcIn,
                        child: Icon(Icons.chevron_right, size: 22.wMin, color: Colors.white),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockBadge() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.wMin),
      child: PlatformBackdropFilterWidget(
        sigmaX: 10,
        sigmaY: 10,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cInverseOverlay.color.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16.wMin),
            border: Border.all(color: AppTheme.cBorderSecondary.color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 18.wMin, color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.75)),
              SizedBox(width: 6.wMin),
              Text(
                '受限',
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildScriptCountText(ZhenduTheaterEntity theater) {
    final count = (theater.scriptCount ?? '').trim();
    final suffix = LearningLangUtils.getLocalLang(theater.scriptCountTitle)?.text ?? '部常驻';
    if (count.isEmpty) return suffix;
    return '$count $suffix';
  }

  List<Color> _theaterAccentGradient(String? category) {
    final c = (category ?? '').trim();
    if (c == 'context') {
      return const [Color(0xFF34D399), Color(0xFF34D399)];
    }
    if (c == 'semantic') {
      return const [Color(0xFFA855F7), Color(0xFFA855F7)];
    }
    if (c == 'picture_book') {
      return const [Color(0xFFF59E0B), Color(0xFFF59E0B)];
    }
    return const [Color(0xFF60A5FA), Color(0xFF60A5FA)];
  }

  Color _theaterGlow(String? category) {
    final c = (category ?? '').trim();
    if (c == 'context') return const Color(0xFF34D399);
    if (c == 'semantic') return const Color(0xFFA855F7);
    if (c == 'picture_book') return const Color(0xFFF59E0B);
    return const Color(0xFF60A5FA);
  }
}
