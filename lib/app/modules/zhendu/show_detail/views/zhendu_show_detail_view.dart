import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/modules/elements/utils/elements_page_utils.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/common/widgets/player_widgets/player_jump_page_utils.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/theme/theme_utils.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../utils/play_record_utils/play_record_constants.dart';
import '../../player/bindings/zhendu_player_binding.dart';
import '../../player/views/zhendu_player_view.dart';
import '../controllers/zhendu_show_detail_controller.dart';

Color _themeBgPrimary([double alpha = 1]) => AppTheme.cBgPrimary.color.withValues(alpha: alpha);
Color _themeSurfacePrimary([double alpha = 1]) => AppTheme.cSurfacePrimary.color.withValues(alpha: alpha);
Color _themeSurfaceSecondary([double alpha = 1]) => AppTheme.cBgPrimary.color.withValues(alpha: alpha);
Color _themeBorderPrimary([double alpha = 1]) => AppTheme.cBorderPrimary.color.withValues(alpha: alpha);
Color _themeTextPrimary([double alpha = 1]) => AppTheme.cTextPrimary.color.withValues(alpha: alpha);
Color _themeTextSecondary([double alpha = 1]) => AppTheme.cTextSecondary.color.withValues(alpha: alpha);
Color _themeTextTertiary([double alpha = 1]) => AppTheme.cTextTertiary.color.withValues(alpha: alpha);
Color _staticWhite([double alpha = 1]) => AppTheme.cStaticWhite.color.withValues(alpha: alpha);
double _leftTextSize(num base) => base.wMin;

class ZhenduShowDetailView extends GetView<ZhenduShowDetailController> {
  const ZhenduShowDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Stack(
        children: [
          Positioned.fill(child: Obx(() => _buildBackground(controller.detail.value))),
          Stack(
              children: [
                Positioned.fill(
                  child: Obx(() {
                    if (controller.loadStatus.value == -1) {
                      return const Center();
                    }
                    if (controller.loadStatus.value == 1) {
                      return NotDataWidget(
                        message: '加载失败',
                        buttonText: '重试',
                        onButton: controller.initPage,
                      );
                    }

                    final detail = controller.detail.value;
                    if (detail == null) {
                      return NotDataWidget(
                        message: '暂无数据',
                        buttonText: '刷新',
                        onButton: controller.initPage,
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.fromLTRB(24.wMin, 82.wMin, 24.wMin, 20.wMin),
                      child: _buildBody(context, detail),
                    );
                  }),
                ),
                Positioned(
                  left: 24.wMin,
                  right: 24.wMin,
                  top: 8.wMin,
                  child: Obx(() => _buildTopBar(controller.detail.value)),
                ),
              ],
            ),
          
        ],
      ),
    );
  }

  Widget _buildBackground(ZhenduScriptDetailEntity? detail) {
    final coverUrl = controller.getPreferredCoverUrl(detail);
    return Stack(
      children: [
        Positioned.fill(
          child: coverUrl.isEmpty
              ? Container(color: AppTheme.cBgPrimary.color)
              : CachedImageWidget(
                  coverUrl,
                  fit: BoxFit.cover,
                  placeholder: buildLoadingWidget(fit: BoxFit.cover),
                  errorWidget: buildNetworkWidget(fit: BoxFit.cover),
                ),
        ),
        Positioned.fill(
          child: Container(
            color: _themeBgPrimary(0.64),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _themeBgPrimary(0.42),
                  _themeBgPrimary(0.82),
                  _themeBgPrimary(),
                ],
                stops: const [0.0, 0.48, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.8, -1.0),
                radius: 0.9,
                colors: [
                  AppTheme.cReadBg1.color.withValues(alpha: 0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.88, -0.92),
                radius: 0.95,
                colors: [
                  AppTheme.cReadBg2.color.withValues(alpha: 0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(ZhenduScriptDetailEntity? detail) {
    final theaterName = _getTitle(detail?.scriptType?.title);
    final crestAccent = _scriptCategoryAccent(detail?.scriptType?.category);
    return Row(
      children: [
        BackWidget(
          title: '',
          showBorder: false,
          tapSize: 88,
          onTap: () => Get.back(),
        ),
    ],
    );
  }

  Widget _buildBody(BuildContext context, ZhenduScriptDetailEntity detail) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1100.wMin;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 48,
                child: Column(
                  children: [
                    Expanded(flex: 11, child: _buildHeroCard(detail)),
                    SizedBox(height: 16.wMin),
                    Expanded(flex: 9, child: _buildSourceCard(detail)),
                  ],
                ),
              ),
              SizedBox(width: 16.wMin),
              Expanded(
                flex: 52,
                child: _buildModePanel(context, detail),
              ),
            ],
          );
        }

        return Column(
          children: [
            Expanded(flex: 10, child: _buildHeroCard(detail)),
            SizedBox(height: 16.wMin),
            Expanded(flex: 7, child: _buildModePanel(context, detail)),
            SizedBox(height: 16.wMin),
            Expanded(flex: 6, child: _buildSourceCard(detail)),
          ],
        );
      },
    );
  }

  Widget _buildHeroCard(ZhenduScriptDetailEntity detail) {
    final title = _getTitle(detail.detailTitle);
    final enSubtitle = LearningLangUtils.getLearningLang(detail.detailTitle)?.text?.trim() ?? '';
    final subtitle = enSubtitle.isNotEmpty ? enSubtitle : (detail.description ?? '').trim();
    final recommended = _recommendedLearnItem(detail);
    final accent = _learnAccentByItem(recommended);
    final coverUrl = controller.getPreferredCoverUrl(detail);

    return ClipRRect(
      borderRadius: BorderRadius.circular(32.wMin),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color: AppTheme.cSurfaceLayerBase,
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.wMin),
            border: Border.all(color: _themeBorderPrimary(0.72)),
            // color: _themeSurfacePrimary(0.72),
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: coverUrl.isEmpty
                          ? Container(color: AppTheme.cBgTertiary.color)
                          : CachedImageWidget(
                              coverUrl,
                              fit: BoxFit.cover,
                              placeholder: buildLoadingWidget(fit: BoxFit.cover),
                              errorWidget: buildNetworkWidget(fit: BoxFit.cover),
                            ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                            // stops: const [0.0, 0.50, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16.wMin,
                      right: 16.wMin,
                      bottom: 16.wMin,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTagRow(detail.tags, outlined: true),
                          SizedBox(height: 10.wMin),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: _leftTextSize(38),
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                              color: AppTheme.cStaticWhite.color,
                              height: 1.02,
                            ),
                          ),
                          if (subtitle.isNotEmpty) ...[
                            SizedBox(height: 6.wMin),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20.wMin,
                                color: _staticWhite(0.78),
                              ),
                            ),
                          ],
                          _buildHeroMetricsRow(detail),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.wMin),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '建议开始方式',
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  letterSpacing: 3.2,
                                  fontWeight: FontWeight.w600,
                                  color: _themeTextTertiary(0.82),
                                ),
                              ),
                              SizedBox(height: 8.wMin),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 20.wMin,
                                    color: _themeTextSecondary(0.92),
                                    height: 1.5,
                                  ),
                                  children: [
                                    if (recommended != null) ...[
                                      const TextSpan(text: '根据当前来源类型，建议先从 '),
                                      TextSpan(
                                        text: _modeZhName(recommended),
                                        style: TextStyle(
                                          color: _learnAccentByItem(recommended).text,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const TextSpan(text: ' 层进入。'),
                                    ] else
                                      const TextSpan(text: '当前作品暂未配置可进入的学习方式。'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.wMin),
                        if (recommended != null)
                          AccessActionButtonWidget(
                            showIcon: true,
                            text: '进入${_modeZhName(recommended)}层',
                            backgroundColor: accent.bg.withValues(alpha: 0.10),
                            borderColor: accent.border,
                            textColor: accent.text,
                            iconColor: accent.text,
                            onTap: () => _openLearnItem(detail, recommended),
                          )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModePanel(BuildContext context, ZhenduScriptDetailEntity detail) {
    final recommended = _recommendedLearnItem(detail);
    final items = detail.learnItems;
    if (items.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(32.wMin),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: EdgeInsets.all(16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32.wMin),
              border: Border.all(color: _themeBorderPrimary(0.72)),
              color: _themeSurfacePrimary(0.72),
            ),
            child: NotDataWidget(
              message: '暂无学习模式',
              buttonText: '刷新',
              onButton: controller.initPage,
            ),
          ),
        ),
      );
    }
    final rows = <List<ZhenduLearnItemEntity>>[];
    if (items.length >= 4) {
      rows.add(items.take(2).toList());
      rows.add(items.skip(2).take(2).toList());
      if (items.length > 4) rows.add(items.skip(4).toList());
    } else {
      rows.addAll(items.map((e) => [e]));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(32.wMin),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.wMin),
            border: Border.all(color: _themeBorderPrimary(0.72)),
            color: AppTheme.cSurfaceLayerBase,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '学习方式',
                          style: TextStyle(
                            fontSize: 16.wMin,
                       
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextSecondary,
                          ),
                        ),
                  
                        Text(
                          '选择开始方式',
                          style: TextStyle(
                            fontSize: 24.wMin,
                            fontWeight: FontWeight.w500,
                       
                            color:AppTheme.cTextPrimary,
                          ),
                        ),
          
                        Text(
                          '同一内容可以从听、读、看、演、练五种方式进入，按你现在最想要的学习方式开始就可以。',
                          style: TextStyle(
                            fontSize: 16.wMin,
                     
                            color: AppTheme.cTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.wMin),
                  _buildRecommendedHint(detail, recommended),
                ],
              ),
              SizedBox(height: 16.wMin),
              Expanded(
                child: Column(
                  children: rows.map((row) {
                    final single = row.length == 1;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: row == rows.last ? 0 : 12.wMin),
                        child: single
                            ? _buildLearnCard(context, detail, row.first, recommended, expand: true)
                            : Row(
                                children: [
                                  Expanded(child: _buildLearnCard(context, detail, row.first, recommended)),
                                  SizedBox(width: 12.wMin),
                                  Expanded(child: _buildLearnCard(context, detail, row[1], recommended)),
                                ],
                              ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroMetricsRow(ZhenduScriptDetailEntity detail) {
    final labelStyle = TextStyle(
      fontSize: _leftTextSize(11),
      color: _staticWhite(0.82),
    );
    final valueStyle = TextStyle(
      fontSize: _leftTextSize(15),
      fontWeight: FontWeight.w700,
      color: _staticWhite(0.98),
    );

    Widget buildItem({required String label, required Widget value}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w700,
                color: _staticWhite(0.68),
              )),
          SizedBox(height: 4.wMin),
          value,
        ],
      );
    }

    Widget buildDivider() {
      return Container(
        width: 1.wMin,
        height: 40.wMin,
        margin: EdgeInsets.symmetric(horizontal: 14.wMin),
        color: _staticWhite(0.40),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 14.wMin),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80.wMin,
            child: buildItem(
              label: '时长',
              value: Row(
                children: [
                  Icon(Icons.schedule, size: 16.wMin, color: _staticWhite(0.88)),
                  SizedBox(width: 6.wMin),
                  Text(_durationText(detail),
                      style: TextStyle(
                        fontSize: 20.wMin,
                   
                        color: _staticWhite(0.98),
                      )),
                ],
              ),
            ),
          ),
          buildDivider(),
          SizedBox(
            width: 120.wMin,
            child: buildItem(
              label: '场景',
              value: Row(
                children: [
                  SvgPicture.asset(
          'assets/svg/public/Storyboard.svg',
          width: 20.wMin,
          colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
        ),
                  SizedBox(width: 6.wMin),
                  Text('${detail.sceneCount ?? '-'} 幕内容',
                      style: TextStyle(
                        fontSize: 20.wMin,
                 
                        color: _staticWhite(0.98),
                      )),
                ],
              ),
            ),
          ),
          buildDivider(),
          SizedBox(
            width: 150.wMin,
            child: buildItem(
              label: '学习方式',
              value: Text(
                '${_availableLearnCount(detail)} / 5 已就绪',
                style: TextStyle(
                  fontSize: 20.wMin,
   
                  color: _staticWhite(0.98),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedHint(ZhenduScriptDetailEntity detail, ZhenduLearnItemEntity? recommended) {
    final accent = _learnAccentByItem(recommended);
    final title =
        recommended == null ? '暂未开放学习方式' : ((detail.preferredNoticeTitle ?? '').trim().isEmpty ? '推荐先从${_modeZhName(recommended)}开始' : detail.preferredNoticeTitle!.trim());
    final content = (detail.preferredNotice ?? '').trim();
    return Container(
      width: 360.wMin,
     height: 118.wMin,
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.wMin),
        border: Border.all(color: AppTheme.cBorderSubtle),
        color: AppTheme.cSurfaceGhostBgSubtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '推荐',
            style: TextStyle(
              fontSize: 16.wMin,
            

              color: AppTheme.cTextSecondary,
            ),
          ),
          SizedBox(height: 8.wMin),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w700,
              color: accent.text,
            ),
          ),
          if (content.isNotEmpty) ...[
            SizedBox(height: 6.wMin),
            Text(
              recommended == null ? '接口当前没有返回可进入的五位一体学习模式。' : content,
              style: TextStyle(
                fontSize: 16.wMin,
                height: 1.5,
                color: AppTheme.cTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLearnCard(
    BuildContext context,
    ZhenduScriptDetailEntity detail,
    ZhenduLearnItemEntity item,
    ZhenduLearnItemEntity? recommended, {
    bool expand = false,
  }) {
    final accent = _learnAccentByItem(item);
    final active = recommended != null && item.type == recommended.type;
    final available = (item.status ?? 0) == 1;
    final making = !available;
    final label = _modeZhName(item);
    final enLabel = _modeEnName(item);
    final desc = (item.description ?? '').trim();
    final tip = (item.learnTip ?? item.statusTip ?? '').trim();
    final subtitle = _statusSubtitle(item, active, available);
    // final cornerBadge = _cornerBadge(item, active, available);

    return Opacity(
      opacity: making ? 0.7 : 1,
      child: TapScaleWidget(
        onTap: () => _openLearnItem(detail, item),
        sclae: 1.01,
        child: Container(
          width: expand ? double.infinity : null,
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26.wMin),
            border: Border.all(
              color: active ? accent.border : _themeBorderPrimary(making ? 0.62 : 0.72),
            ),
            color: active ? accent.bg.withValues(alpha: 0.1) : AppTheme.cSurfaceLayerBase.color,
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     making ? _themeSurfaceSecondary(0.62) : accent.bg.withValues(alpha: active ? 0.20 : 0.12),
            //     _themeSurfaceSecondary(0.76),
            //     _themeSurfacePrimary(0.92),
            //   ],
            // ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLearnIconCircle(item, accent, making: making),
                SizedBox(width: 10.wMin),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 32.wMin,
                              fontWeight: FontWeight.w600,
                              color: _themeTextPrimary(0.98),
                              height: 1.0,
                            ),
                          ),
                          SizedBox(width: 8.wMin),
                          Text(
                            enLabel,
                            style: TextStyle(
                              fontSize: 14.wMin,
                              letterSpacing: 2.8,
                            
                              color: _themeTextTertiary(0.82),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.wMin),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: making ? _themeTextTertiary(0.76) : _themeTextSecondary(0.88),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // if (cornerBadge != null) ...[
                    //   cornerBadge,
                    //   SizedBox(height: 6.wMin),
                    // ],
                    Text(
                      '${item.index ?? 0}'.padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: _themeTextTertiary(0.70),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.wMin),
            Text(
              desc,
              maxLines: expand ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20.wMin,
                height: 1.5,
                color: _themeTextSecondary(0.90),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                _buildAvailabilityPill(item, active, available, accent),
                const Spacer(),
                if (_actionLabel(item, available).isNotEmpty)
                  Text(
                    _actionLabel(item, available),
                    style: TextStyle(
                      fontSize: 22.wMin,
                      fontWeight: FontWeight.w700,
                      color: available ? _themeTextPrimary(0.96) : _themeTextTertiary(0.78),
                    ),
                  ),
                        SvgPicture.asset('assets/svg/user_center/icon_chevron_right1.svg',
                              width: 22.wMin,
                              height: 22.wMin,
                        )
              ],
            ),
            // if (tip.isNotEmpty && !available) ...[
            //   SizedBox(height: 10.wMin),
            //   Align(
            //     alignment: Alignment.centerLeft,
            //     child: Text(
            //       tip,
            //       style: TextStyle(
            //         fontSize: 17.wMin,
            //         color: _themeTextTertiary(0.80),
            //       ),
            //     ),
            //   ),
            // ],
          ],
            ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityPill(
    ZhenduLearnItemEntity item,
    bool active,
    bool available,
    _LearnAccent accent,
  ) {
    final text = active ? '推荐开始' : (available ? '可进入' : '制作中');
    return TagButtonWidget(
      text: text,
      borderColor: active
          ? accent.border
          : null,
      backgroundColor: active
          ? accent.bg.withValues(alpha: 0.16)
       : null,
      textColor: active
          ? accent.text
        : null,
    );
  }

  Widget _buildSourceCard(ZhenduScriptDetailEntity detail) {
    final source = detail.source;
    final type = (source?.type ?? '').trim().toUpperCase();
    final sourceData = source?.data ?? const <String, dynamic>{};
    final narrative = _sourceNarrative(type);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28.wMin),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28.wMin),
            border: Border.all(color: narrative.border),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                narrative.bg.withValues(alpha: 0.14),
                narrative.bg.withValues(alpha: 0.06),
                Colors.transparent,
              ],
            ),
            color: _themeSurfacePrimary(0.72),
          ),
          child: _buildSourceBody(type, source, sourceData, narrative, detail),
        ),
      ),
    );
  }

  Widget _buildSourceBody(
    String type,
    ZhenduScriptSourceEntity? source,
    Map<String, dynamic> data,
    _SourceNarrative narrative,
    ZhenduScriptDetailEntity detail,
  ) {
    if (type == 'SEMANTIC') {
      final content = _readSourceValue(data['content'], fallback: source?.name ?? '');
      final pronunciations = _parseSemanticPronunciations(data['pronunciations']);
      final rawPronunciations = _readSourceValue(data['pronunciations']);
      final translate = _readSourceValue(data['translate']);
      final contentTypeLabel = _readSourceValue(data['contentTypeLabel'], fallback: '词汇');
      final semanticCount = _readSourceValue(data['semanticCount'], fallback: '');
      final semanticChips = _semanticChipItems(data, detail.tags);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSourceHeader(narrative),
          SizedBox(height: 14.wMin),
          Row(
            children: [
              Flexible(
                child: _OverflowBubbleText(
                  text: content,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: _leftTextSize(36),
                    fontWeight: FontWeight.w900,
                    color: _themeTextPrimary(1),
                  ),
                ),
              ),
              SizedBox(width: 10.wMin),
              Expanded(
                child: pronunciations.isEmpty
                    ? _OverflowBubbleText(
                        text: rawPronunciations,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: _leftTextSize(20),
                          color: _themeTextSecondary(0.8),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _buildPronunciationWidgets(pronunciations),
                        ),
                      ),
              ),
            ],
          ),
          if (translate.isNotEmpty) ...[
            SizedBox(height: 10.wMin),
            _OverflowBubbleText(
              text: translate,
              maxLines: 1,
              style: TextStyle(
                fontSize: _leftTextSize(20),
                color: _themeTextSecondary(0.8),
              ),
            ),
          ],
          SizedBox(height: 14.wMin),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22.wMin),
                border: Border.all(color: _themeBorderPrimary(0.70)),
                color: _themeSurfaceSecondary(0.72),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '相关义项',
                          style: TextStyle(
                            fontSize: _leftTextSize(16),
                            letterSpacing: 2.8,
                            color: _themeTextTertiary(0.82),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TagButtonWidget(text: contentTypeLabel),
                    ],
                  ),
                  if (semanticCount.isNotEmpty)
                    Text(
                      '$semanticCount 个义项',
                      style: TextStyle(
                        fontSize: _leftTextSize(16),
                        color: _themeTextSecondary(1),
                      ),
                    ),
                  SizedBox(height: 10.wMin),
                  if (semanticChips.isEmpty)
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '当前暂无更多义项数据',
                          style: TextStyle(
                            fontSize: _leftTextSize(16),
                            color: _themeTextTertiary(0.82),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Wrap(
                          spacing: 8.wMin,
                          runSpacing: 8.wMin,
                          children: semanticChips
                              .map((item) => 

                                         AccessActionButtonWidget(
                            borderRadius: 999.wMin,
                            borderColor: _semanticChipBorderColor(item),
                            backgroundColor: _semanticChipBackgroundColor(item).withValues(alpha: 0.2),
                         
                            text: item.label,
                            onTap: () =>item.canJump ? _openSemanticChip(item) : null,
                          )

                         )
                              .toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final courseName = _readSourceValue(data['courseName'], fallback: source?.name ?? 'LangWise官方课程');
    final levelName = _readSourceValue(data['levelName']);
    final moduleName = _readSourceValue(data['moduleName']);
    final unitName = _readSourceValue(data['unitName']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSourceHeader(narrative),
        SizedBox(height: 12.wMin),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSourceMetric(
                        label: '所属课程',
                        value: courseName,
                        helper: '当前内容来自课程学习路径',
                      ),
                    ),
                    SizedBox(width: 12.wMin),
                    Expanded(
                      child: _buildSourceMetric(
                        label: '难度',
                        value: levelName.isEmpty ? '当前阶段' : levelName,
                        helper: '按当前课程阶段继续学习',
                        valueColor: narrative.accent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.wMin),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.wMin),
                    border: Border.all(color: _themeBorderPrimary(0.70)),
                    color: _themeSurfaceSecondary(0.72),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '学习位置',
                        style: TextStyle(
                          fontSize: _leftTextSize(16),
                          letterSpacing: 2.8,
                          color: _themeTextTertiary(0.82),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 14.wMin),
                      Wrap(
                        spacing: 10.wMin,
                        runSpacing: 10.wMin,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          AccessActionButtonWidget(
                            borderRadius: 999.wMin,
                            borderColor: Color(0xFF34D399),
                            backgroundColor: Color(0xFF34D399).withValues(alpha: 0.2),
                         
                            text: moduleName.isEmpty ? '课程模块' : moduleName,
                            onTap: () => _openCourseLevel(data),
                          ),
                          Text('→', style: TextStyle(fontSize: _leftTextSize(20), color: _themeTextTertiary(0.70))),
                          
                          AccessActionButtonWidget(
                            borderRadius: 999.wMin,
                              borderColor: Color(0xFF34D399),
                            backgroundColor: Color(0xFF34D399).withValues(alpha: 0.2),
                        
                            text: unitName.isEmpty ? '当前单元' : unitName,
                            onTap: () => _openCourseUnit(data),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceHeader(_SourceNarrative narrative) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '内容来源',
                style: TextStyle(
                  fontSize: _leftTextSize(13),
                  letterSpacing: 2.8,
                  color: _themeTextTertiary(0.82),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.wMin),
              Text(
                narrative.title,
                style: TextStyle(
                  fontSize: _leftTextSize(24),
                  fontWeight: FontWeight.w800,
                  color: _themeTextPrimary(0.98),
                ),
              ),
            ],
          ),
        ),
        TagButtonWidget(text: '语义词汇')
      ],
    );
  }

  Widget _buildSourceMetric({
    required String label,
    required String value,
    required String helper,
    Color? valueColor,
  }) {
    return Container(
      padding: EdgeInsets.all(14.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.wMin),
        border: Border.all(color: _themeBorderPrimary(0.70)),
        color: _themeSurfaceSecondary(0.72),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: _leftTextSize(16),
              letterSpacing: 2.8,
              color: _themeTextTertiary(0.82),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.wMin),
          _OverflowBubbleText(
            text: value,
            maxLines: 1,
            style: TextStyle(
              fontSize: _leftTextSize(24),
              fontWeight: FontWeight.w700,
              color:  _themeTextPrimary(0.98),
            ),
          ),
          SizedBox(height: 4.wMin),
          Text(
            helper,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: _leftTextSize(20),
              height: 1.4,
              color: _themeTextSecondary(0.88),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceChip(
    String text,
    _SourceNarrative narrative, {
    Color? altColor,
    VoidCallback? onTap,
  }) {
    final color = altColor ?? narrative.accent;
    final chip = TagButtonWidget(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
      borderRadius: 999.wMin,
      borderColor: color.withValues(alpha: 0.20),
      backgroundColor: color.withValues(alpha: 0.10),
      child: _OverflowBubbleText(
        text: text,
        maxLines: 1,
        style: TextStyle(
          fontSize: _leftTextSize(20),
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    if (onTap == null) return chip;
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.02,
      child: chip,
    );
  }

  Widget _buildLearnIconCircle(ZhenduLearnItemEntity item, _LearnAccent accent, {required bool making}) {
    return Container(
      width: 56.wMin,
      height: 56.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17.wMin),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: making
              ? [
                  accent.text.withValues(alpha: 0.32),
                  accent.bg.withValues(alpha: 0.16),
                ]
              : [
                  accent.text,
                  accent.bg,
                ],
        ),
        boxShadow: making
            ? null
            : [
                BoxShadow(
                  color: accent.text.withValues(alpha: 0.30),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: _buildLearnIconAsset(item, accent: accent, making: making),
    );
  }

  Widget _buildLearnIconAsset(ZhenduLearnItemEntity item, {required _LearnAccent accent, required bool making}) {
    final iconUrl = item.iconUrl?.trim() ?? '';
    final iconColor = making ? accent.text.withValues(alpha: 0.62) : Colors.white;
    if (iconUrl.endsWith('.svg')) {
      return Center(
        child: SvgPicture.network(
          iconUrl,
          width: 40.wMin,
          height: 40.wMin,
          colorFilter: ColorFilter.mode(
            iconColor,
            BlendMode.srcIn,
          ),
          placeholderBuilder: (_) => Icon(_learnIcon(item.type), size: 23.wMin, color: iconColor),
        ),
      );
    }
    if (iconUrl.isNotEmpty) {
      return Center(
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          child: CachedImageWidget(
            iconUrl,
            width: 25.wMin,
            height: 25.wMin,
            fit: BoxFit.contain,
            placeholder: buildLoadingWidget(fit: BoxFit.cover),
            errorWidget: buildNetworkWidget(fit: BoxFit.cover),
          ),
        ),
      );
    }
    return Icon(_learnIcon(item.type), size: 23.wMin, color: iconColor);
  }

  Widget? _cornerBadge(ZhenduLearnItemEntity item, bool active, bool available) {
    if (active) return null;
    final tip = (item.learnTip ?? item.statusTip ?? '').trim();
    if (tip.isEmpty) return null;
    if (available) return null;
    return TagButtonWidget(
      text: tip,
      fontSize: 16.wMin,
      fontWeight: FontWeight.w600,
      textColor: _themeTextSecondary(0.88),
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
      borderRadius: 999.wMin,
      backgroundColor: _themeSurfaceSecondary(0.72),
      borderColor: _themeBorderPrimary(0.72),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    String? helper,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      height: 124.wMin,
      padding: EdgeInsets.all(14.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.wMin),
        border: Border.all(color: _themeBorderPrimary(0.70)),
        color: _themeSurfaceSecondary(0.72),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: _leftTextSize(11),
              letterSpacing: 2.8,
              color: _themeTextTertiary(0.82),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.wMin),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14.wMin, color: iconColor ?? _themeTextSecondary(0.92)),
                SizedBox(width: 8.wMin),
              ],
              Expanded(
                child: _OverflowBubbleText(
                  text: value,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: _leftTextSize(15),
                    fontWeight: FontWeight.w700,
                    color: _themeTextPrimary(0.98),
                  ),
                ),
              ),
            ],
          ),
          if (helper != null) ...[
            SizedBox(height: 4.wMin),
            Text(
              helper,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: _leftTextSize(11),
                height: 1.4,
                color: _themeTextSecondary(0.88),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrimaryAction({
    required String label,
    required _LearnAccent accent,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.02,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 14.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(color: accent.border),
          // gradient: LinearGradient(
          //   colors: [
          //     accent.bg.withValues(alpha: 0.22),
          //     _themeSurfaceSecondary(0.72),
          //   ],
          // ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OverflowBubbleText(
              text: label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w800,
                color: _themeTextPrimary(0.98),
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(width: 10.wMin),
            Icon(
              Icons.chevron_right_rounded,
              size: 28.wMin,
              color: _themeTextPrimary(0.98),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledAction() {
    return TagButtonWidget(
      text: '暂无可进入方式',
      fontSize: 14.wMin,
      fontWeight: FontWeight.w700,
      textColor: _themeTextTertiary(0.82),
      padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 14.wMin),
      borderRadius: 18.wMin,
      backgroundColor: _themeSurfaceSecondary(0.72),
      borderColor: _themeBorderPrimary(0.72),
    );
  }

  Widget _buildTagRow(List<ZhenduTagEntity>? tags, {bool outlined = false}) {
    if (tags == null || tags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8.wMin,
      runSpacing: 8.wMin,
      children: tags.take(4).map((tag) => _buildTagChip(tag, outlined: outlined)).toList(),
    );
  }

  Widget _buildTagChip(ZhenduTagEntity tag, {bool outlined = false}) {
    final text = _getTitle(tag.gloss);

    return VideoImageInnerButtonWidget(
      text: text,
    );
  }

  ThemeTextStyleEntity? _pickThemeStyle(List<ThemeTextStyleEntity>? styles) {
    if (styles == null || styles.isEmpty) return null;
    for (final style in styles) {
      final theme = (style.theme ?? '').trim();
      if (theme.isNotEmpty && ThemeUtils.isCurrentTheme(theme)) return style;
    }
    return styles.first;
  }

  Widget _buildTheaterCrest(String? iconUrl, {required Color accent}) {
    return SizedBox(
      width: 33.wMin,
      height: 33.wMin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 28.wMin,
              height: 28.wMin,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.40),
              ),
            ),
          ),
          Container(
            width: 33.wMin,
            height: 33.wMin,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              color: Colors.white.withValues(alpha: 0.03),
            ),
          ),
          Container(
            width: 24.wMin,
            height: 24.wMin,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.40),
                  Colors.black.withValues(alpha: 0.40),
                ],
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: iconUrl == null || iconUrl.trim().isEmpty
                ? Icon(Icons.theaters, size: 24.wMin, color: Colors.white.withValues(alpha: 0.88))
                : CachedImageWidget(
                    iconUrl,
                    fit: BoxFit.contain,
                    placeholder: buildLoadingWidget(fit: BoxFit.cover),
                    errorWidget: buildNetworkWidget(fit: BoxFit.cover),
                  ),
          ),
        ],
      ),
    );
  }

  ZhenduLearnItemEntity? _recommendedLearnItem(ZhenduScriptDetailEntity detail) {
    if (detail.learnItems.isEmpty) return null;
    final availableItems = detail.learnItems.where((item) => (item.status ?? 0) == 1).toList();
    if (availableItems.isEmpty) return detail.learnItems.first;
    final title = (detail.preferredNoticeTitle ?? '').trim();
    for (final item in availableItems) {
      final zh = _modeZhName(item);
      if (title.contains(zh)) return item;
    }
    return availableItems.first;
  }

  int _availableLearnCount(ZhenduScriptDetailEntity detail) {
    return detail.learnItems.where((item) => (item.status ?? 0) == 1).length;
  }

  void _openLearnItem(ZhenduScriptDetailEntity detail, ZhenduLearnItemEntity item) {
    final sid = detail.uid;
    if ((item.status ?? 0) != 1) {
      final tip = (item.learnTip ?? item.statusTip ?? '').trim();
      ToastUtils.showToast(text: tip.isEmpty ? '暂未开放' : tip);
      return;
    }
    if (sid == null) return;
    final pageType = ZhenduPageTypeEnum.fromValue((item.type ?? '').trim());
    if (pageType != null) {
      PlayerJumpPageUtils.jumpZhenduDetail(
        contents: [
          {"contentId": sid, "contentType": 'SCRIPT', "styleId": controller.styleId, "dialect": controller.dialect}
        ],
        contentType: 'SCRIPT',
        pageType: pageType,
        contentId: sid,
        semanticId: null,
        styleId: controller.styleId,
        dialect: controller.dialect,
        collectionId: controller.collectionId,
        difficulty: controller.difficulty,
        locate: controller.locate,
        traceAdminHeader: controller.traceAdminHeader,
      );
      return;
    }
    Get.to(
      () => const ZhenduPlayerView(),
      binding: ZhenduPlayerBinding(scriptId: sid, initialMode: item.type ?? ''),
    );
  }

  _LearnAccent _learnAccentFromType(String? type) {
    switch ((type ?? '').trim()) {
      case 'listen':
        return const _LearnAccent(
          text: Color(0xFF38BDF8),
          bg: Color(0xFF06B6D4),
          border: Color(0x3338BDF8),
        );
      case 'read':
        return const _LearnAccent(
          text: Color(0xFF34D399),
          bg: Color(0xFF10B981),
          border: Color(0x3334D399),
        );
      case 'watch':
        return const _LearnAccent(
          text: Color(0xFFE879F9),
          bg: Color(0xFFD946EF),
          border: Color(0x33E879F9),
        );
      case 'perform':
        return const _LearnAccent(
          text: Color(0xFFFBBF24),
          bg: Color(0xFFF59E0B),
          border: Color(0x33FBBF24),
        );
      default:
        return const _LearnAccent(
          text: Color(0xFFFB7185),
          bg: Color(0xFFF43F5E),
          border: Color(0x33FB7185),
        );
    }
  }

  _LearnAccent _learnAccentByItem(ZhenduLearnItemEntity? item) {
    final fallback = _learnAccentFromType(item?.type);
    final from = ColorUtils.parseColor(item?.color?.from);
    final to = ColorUtils.parseColor(item?.color?.to);
    if (from == null && to == null) return fallback;
    final start = from ?? fallback.text;
    final end = to ?? fallback.bg;
    return _LearnAccent(
      text: start,
      bg: end,
      border: start.withValues(alpha: 0.30),
    );
  }

  Color _scriptCategoryAccent(String? category) {
    switch ((category ?? '').trim()) {
      case 'context':
        return const Color(0xFF34D399);
      case 'semantic':
        return const Color(0xFFA855F7);
      case 'picture_book':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF60A5FA);
    }
  }

  String _modeZhName(ZhenduLearnItemEntity item) {
    final title = _getTitle(item.title);
    return title.isEmpty ? '学' : title;
  }

  String _modeEnName(ZhenduLearnItemEntity item) {
    final en = LearningLangUtils.getLearningLang(item.title)?.text?.trim() ?? '';
    return en;
  }

  String _actionLabel(ZhenduLearnItemEntity item, bool available) {
    if (!available) return '';
    switch ((item.type ?? '').trim()) {
      case 'listen':
        return '打开听';
      case 'read':
        return '打开读';
      case 'watch':
        return '打开看';
      case 'perform':
        return '打开演';
      case 'practice':
        return '开始练习';
      default:
        return '打开${_modeZhName(item)}';
    }
  }

  String _statusSubtitle(ZhenduLearnItemEntity item, bool active, bool available) {
    if (active) return '建议先从${_modeZhName(item)}开始';
    if (available) {
      if ((item.type ?? '') == 'practice') return '最后一步：巩固与输出';
      return '点击进入';
    }
    return '制作中';
  }

  IconData _learnIcon(String? type) {
    switch ((type ?? '').trim()) {
      case 'listen':
        return Icons.headset;
      case 'read':
        return Icons.menu_book_rounded;
      case 'watch':
        return Icons.visibility_rounded;
      case 'perform':
        return Icons.videocam_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }

  _SourceNarrative _sourceNarrative(String type) {
    if (type == 'SEMANTIC') {
      return const _SourceNarrative(
        badge: '语义词汇',
        title: '词汇来源',
        accent: Color(0xFFC084FC),
        border: Color(0x33C084FC),
        bg: Color(0xFF7C3AED),
      );
    }

    if (type == 'CONTEXT') {
      return const _SourceNarrative(
        badge: '课程节点',
        title: '课程来源',
        accent: Color(0xFF6EE7B7),
        border: Color(0x336EE7B7),
        bg: Color(0xFF059669),
      );
    }

    return const _SourceNarrative(
      badge: '绘本作品',
      title: '绘本来源',
      accent: Color(0xFFFCD34D),
      border: Color(0x33FCD34D),
      bg: Color(0xFFD97706),
    );
  }

  String _durationText(ZhenduScriptDetailEntity detail) {
    final duration = detail.duration;
    if (duration != null && duration > 0) {
      final seconds = duration.round();
      final minutes = seconds ~/ 60;
      final remain = seconds % 60;
      return '$minutes:${remain.toString().padLeft(2, '0')}';
    }
    final sceneCount = detail.sceneCount ?? 0;
    final seconds = sceneCount * 35;
    final minutes = seconds ~/ 60;
    final remain = seconds % 60;
    return '$minutes:${remain.toString().padLeft(2, '0')}';
  }

  List<String> _readStringList(dynamic value) {
    if (value == null) return <String>[];
    if (value is List) {
      return value.map((e) => _readSourceValue(e)).where((e) => e.isNotEmpty).toList();
    }
    return <String>[];
  }

  List<String> _semanticChipValues(Map<String, dynamic> data, List<ZhenduTagEntity>? tags) {
    final semantics = _readStringList(data['semantics']);
    if (semantics.isNotEmpty) return semantics;
    if (tags == null || tags.isEmpty) return <String>[];
    return tags.map((tag) => _getTitle(tag.gloss)).where((e) => e.trim().isNotEmpty).toList();
  }

  List<_SemanticChipItem> _semanticChipItems(Map<String, dynamic> data, List<ZhenduTagEntity>? tags) {
    final rawSemantics = data['semanticList'] ?? data['semantics'];
    if (rawSemantics is List && rawSemantics.isNotEmpty) {
      final resp = <_SemanticChipItem>[];
      for (var i = 0; i < rawSemantics.length; i++) {
        final item = rawSemantics[i];
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final label = _readSemanticLabel(map);
          if (label.isEmpty) continue;
          resp.add(
            _SemanticChipItem(
              label: label,
              semanticId: _readSourceInt(map['semanticId']),
              contentId: _readSourceInt(map['contentId']),
              contentType: _readSourceValue(map['contentType']),
              style: _readThemeTextStyles(map['style']),
            ),
          );
          continue;
        }
      }
      if (resp.isNotEmpty) return resp;
    }
    final fallbackValues = _semanticChipValues(data, tags);
    return fallbackValues
        .map(
          (item) => _SemanticChipItem(
            label: item,
          ),
        )
        .toList();
  }

  List<_SemanticPronunciationData> _parseSemanticPronunciations(dynamic raw) {
    if (raw is! List) return const [];
    final resp = <_SemanticPronunciationData>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final ipaTags = _parseSemanticIpaTags(e['ipa']);
      if (ipaTags.isEmpty) continue;
      final posRaw = e['pos'];
      final posList = <String>[];
      if (posRaw is List) {
        for (final p in posRaw) {
          final text = _normalizePosText(p?.toString());
          if (text.isNotEmpty) posList.add(text);
        }
      } else if (posRaw != null) {
        final text = _normalizePosText(posRaw.toString());
        if (text.isNotEmpty) posList.add(text);
      }
      resp.add(
        _SemanticPronunciationData(
          ipaTags: ipaTags,
          posTags: posList,
        ),
      );
    }
    return resp;
  }

  List<Widget> _buildPronunciationWidgets(List<_SemanticPronunciationData> items) {
    final widgets = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      if (i > 0) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.wMin),
            child: Container(
              width: 4.wMin,
              height: 4.wMin,
              decoration: BoxDecoration(
                color: _themeTextTertiary(0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }
      widgets.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(items[i].ipaTags.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == items[i].ipaTags.length - 1 ? 0 : 8.wMin,
                  ),
                  child: Text(
                    items[i].ipaTags[index],
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: _themeTextSecondary(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }),
            ),
            if (items[i].posTags.isNotEmpty) ...[
              SizedBox(width: 10.wMin),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(items[i].posTags.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == items[i].posTags.length - 1 ? 0 : 8.wMin,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                        border: Border.all(color: _themeBorderPrimary(0.9)),
                        color: _themeSurfaceSecondary(0.75),
                      ),
                      child: Text(
                        items[i].posTags[index],
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: _themeTextSecondary(0.95),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      );
    }
    return widgets;
  }

  String _normalizePosText(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return '';
    return text.replaceAll(RegExp(r'^/+|/+$'), '');
  }

  List<String> _parseSemanticIpaTags(dynamic value) {
    final resp = <String>[];

    void addValue(dynamic item) {
      if (item == null) return;
      if (item is List) {
        for (final sub in item) {
          addValue(sub);
        }
        return;
      }
      var text = item.toString().trim();
      if (text.isEmpty) return;
      if (text.startsWith('[') && text.endsWith(']')) {
        text = text.substring(1, text.length - 1).trim();
      }
      final parts = text
          .split(RegExp(r'\s+/\s+|[,;|、，；]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);
      for (final part in parts) {
        final normalized = _normalizePosText(part);
        if (normalized.isEmpty) continue;
        resp.add('/$normalized/');
      }
    }

    addValue(value);
    return resp;
  }

  List<ThemeTextStyleEntity>? _readThemeTextStyles(dynamic value) {
    if (value is! List || value.isEmpty) return null;
    final resp = <ThemeTextStyleEntity>[];
    for (final item in value) {
      if (item is Map) {
        resp.add(ThemeTextStyleEntity.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return resp.isEmpty ? null : resp;
  }

  Color _semanticChipTextColor(_SemanticChipItem item) {
    final style = _pickThemeStyle(item.style);
    return ColorUtils.parseColor(style?.color) ?? AppTheme.cTextPrimary.color;
  }

  Color _semanticChipBackgroundColor(_SemanticChipItem item) {
    final style = _pickThemeStyle(item.style);
    return ColorUtils.parseColor(style?.backgroundColor) ??
        Colors.amber;
  }

  Color _semanticChipBorderColor(_SemanticChipItem item) {
    final style = _pickThemeStyle(item.style);
    return ColorUtils.parseColor(style?.borderColor) ??
        _semanticChipTextColor(item).withValues(alpha: 0.24);
  }

  double _semanticChipFontSize(_SemanticChipItem item) {
    final style = _pickThemeStyle(item.style);
    final size = style?.fontsize;
    if (size == null || size <= 0) return 22.wMin;
    return size.wMin;
  }

  FontWeight _semanticChipFontWeight(_SemanticChipItem item) {
    final style = _pickThemeStyle(item.style);
    final weight = style?.weight;
    switch (weight) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      case 400:
      default:
        return FontWeight.w400;
    }
  }

  String _readSemanticLabel(Map<String, dynamic> data) {
    final direct = _readSourceValue(
      data['label'],
      fallback: _readSourceValue(
        data['name'],
        fallback: _readSourceValue(data['text']),
      ),
    );
    if (direct.isNotEmpty) return direct;
    final gloss = _readLanguageTextTitle(data['gloss']);
    if (gloss.isNotEmpty) return gloss;
    final descriptions = _readLanguageTextTitle(data['descriptions']);
    if (descriptions.isNotEmpty) return descriptions;
    return '';
  }

  String _readLanguageTextTitle(dynamic value) {
    if (value is! List || value.isEmpty) return '';
    final texts = <LanguageText>[];
    for (final item in value) {
      if (item is Map) {
        texts.add(LanguageText.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    if (texts.isEmpty) return '';
    return _getTitle(texts);
  }

  Future<void> _openCourseLevel(Map<String, dynamic> data) async {
    final courseId = _readSourceInt(data['courseId']);
    final levelId = _readSourceInt(data['levelId']);
    if (courseId == null || levelId == null) {
      ToastUtils.showToast(text: '未找到课程模块定位信息');
      return;
    }
    if (AppPages.history.contains(Routes.OFFICIAL_COURSE_DETAILS_LEVEL)) {
      Get.until((route) => route.settings.name == Routes.OFFICIAL_COURSE_DETAILS_LEVEL);
      return;
    }
    await Get.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_LEVEL,
      arguments: {
        'courseId': courseId,
        'levelId': levelId,
        'moduleId': _readSourceInt(data['moduleId']),
        'scrollToLevelId': levelId,
      },
    );
  }

  Future<void> _openCourseUnit(Map<String, dynamic> data) async {
    final courseId = _readSourceInt(data['courseId']);
    final levelId = _readSourceInt(data['levelId']);
    final moduleId = _readSourceInt(data['moduleId']);
    final unitId = _readSourceInt(data['unitId']);
    if (courseId == null || levelId == null || moduleId == null || unitId == null) {
      ToastUtils.showToast(text: '未找到当前单元定位信息');
      return;
    }
    if (AppPages.history.contains(Routes.OFFICIAL_COURSE_DETAILS)) {
      Get.until((route) => route.settings.name == Routes.OFFICIAL_COURSE_DETAILS);
      return;
    }
    await Get.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS,
      arguments: {
        'courseId': courseId,
        'levelId': levelId,
        'moduleId': moduleId,
        'unitId': unitId,
        'isSwitchCourse': false,
        'goCustomCourseProgress': false,
      },
    );
  }

  Future<void> _openSemanticChip(_SemanticChipItem item) async {
    final contentType = item.contentType;
    final contentId = item.contentId;
    final semanticId = item.semanticId;
    if (contentType == null || contentType.isEmpty || contentId == null || semanticId == null) {
      ToastUtils.showToast(text: '当前义项暂不支持跳转');
      return;
    }
    await ElementsPageUtils.jumpElementsPage(
      contentId: contentId,
      contentType: contentType,
      semanticId: semanticId,
      styleId: null,
      dialect: null,
      semanticIds: <int?>[semanticId],
    );
  }

  int? _readSourceInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString().trim());
  }

  String _readSourceValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    if (value is String) {
      final v = value.trim();
      return v.isEmpty ? fallback : v;
    }
    if (value is List) {
      final values = value.map((e) => _readSourceValue(e)).where((e) => e.isNotEmpty).toList();
      return values.isEmpty ? fallback : values.join(' / ');
    }
    if (value is Map<String, dynamic>) {
      final values = value.values.map((e) => _readSourceValue(e)).where((e) => e.isNotEmpty).toList();
      return values.isEmpty ? fallback : values.join(' / ');
    }
    return value.toString();
  }

  String _getTitle(List<LanguageText>? list) {
    if (list == null || list.isEmpty) return '';
    String? chineseText;
    for (final item in list) {
      final code = (item.lang ?? '').trim().toLowerCase();
      final text = (item.text ?? '').trim();
      if (text.isEmpty) continue;
      if (code == 'zh') return text;
      if (chineseText == null &&
          (code.startsWith('zh-') || code.startsWith('zh_'))) {
        chineseText = text;
      }
    }
    if (chineseText != null) return chineseText;
    if (list.isNotEmpty) return list.first.text ?? '';
    return '';
  }
}

class _SourceNarrative {
  final String badge;
  final String title;
  final Color accent;
  final Color border;
  final Color bg;

  const _SourceNarrative({
    required this.badge,
    required this.title,
    required this.accent,
    required this.border,
    required this.bg,
  });
}

class _SemanticChipItem {
  final String label;
  final int? semanticId;
  final int? contentId;
  final String? contentType;
  final List<ThemeTextStyleEntity>? style;

  const _SemanticChipItem({
    required this.label,
    this.semanticId,
    this.contentId,
    this.contentType,
    this.style,
  });

  bool get canJump {
    return contentId != null && semanticId != null && contentType != null && contentType!.isNotEmpty;
  }
}

class _SemanticPronunciationData {
  final List<String> ipaTags;
  final List<String> posTags;

  const _SemanticPronunciationData({
    required this.ipaTags,
    required this.posTags,
  });
}

class _OverflowBubbleText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;

  const _OverflowBubbleText({
    required this.text,
    required this.style,
    this.maxLines = 1,
  });

  @override
  State<_OverflowBubbleText> createState() => _OverflowBubbleTextState();
}

class _OverflowBubbleTextState extends State<_OverflowBubbleText> {
  final GlobalKey _anchorKey = GlobalKey();
  CancelFunc? _cancel;

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  void _show() {
    if (_cancel != null) return;
    final ctx = _anchorKey.currentContext;
    if (ctx == null) return;
    _cancel = BotToast.showAttachedWidget(
      targetContext: ctx,
      backgroundColor: Colors.transparent,
      onlyOne: true,
      preferDirection: PreferDirection.topCenter,
      attachedBuilder: (cancelFunc) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: cancelFunc,
          child: Container(
            constraints: BoxConstraints(
              minWidth: 200.wMin,
              maxWidth: 520.wMin,
            ),
            child: BubbleBox(
              backgroundColor: AppTheme.cSurfaceSecondary.color,
              padding: EdgeInsets.all(12.wMin),
              shape: BubbleShapeBorder(
                direction: BubbleDirection.bottom,
                arrowQuadraticBezierLength: 1,
                radius: BorderRadius.circular(16.wMin),
                arrowHeight: 18.wMin,
                arrowAngle: 12.wMin,
                smooth: 0,
                border: BubbleBoxBorder(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
              ),
              child: Text(
                widget.text,
                style: widget.style.copyWith(
                  color: widget.style.color ?? AppTheme.cTextPrimary.color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _hide() {
    _cancel?.call();
    _cancel = null;
  }

  void _toggle() {
    if (_cancel != null) {
      _hide();
      return;
    }
    _show();
  }

  bool _didExceedMaxLines(BoxConstraints constraints) {
    if (!constraints.maxWidth.isFinite) return false;
    final maxWidth = constraints.maxWidth;
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: widget.maxLines,
      textDirection: Directionality.of(context),
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final overflowed = _didExceedMaxLines(constraints);
        return MouseRegion(
          onEnter: (_) {
            if (!overflowed) return;
            _show();
          },
          onExit: (_) {
            _hide();
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: overflowed ? _toggle : null,
            child: Container(
              key: _anchorKey,
              child: Text(
                widget.text,
                maxLines: widget.maxLines,
                overflow: TextOverflow.ellipsis,
                style: widget.style,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LearnAccent {
  final Color text;
  final Color bg;
  final Color border;

  const _LearnAccent({
    required this.text,
    required this.bg,
    required this.border,
  });
}
