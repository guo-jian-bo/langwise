import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../controllers/zhendu_player_controller.dart';

class ZhenduPlayerView extends GetView<ZhenduPlayerController> {
  const ZhenduPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
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

        return GestureDetector(
          onTap: controller.toggleSystemUi,
          child: Stack(
            children: [
              _buildContent(context),
              Obx(() {
                final mode = controller.mode.value;
                if (mode != ZhenduLearnMode.listen) return const SizedBox.shrink();
                return Positioned(
                  right: 20.wMin,
                  bottom: 92.wMin + MediaQuery.of(context).padding.bottom,
                  child: _buildReadEntryButton(),
                );
              }),
              Obx(() {
                if (!controller.systemUiVisible.value) return const SizedBox.shrink();
                return Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: _buildTopBar(context),
                );
              }),
              Obx(() {
                if (!controller.systemUiVisible.value) return const SizedBox.shrink();
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomPlayer(context),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildContent(BuildContext context) {
    final mode = controller.mode.value;
    final detail = controller.detail.value;
    final accent = _modeAccent(mode);
    final coverUrl = detail?.coverUrl?.trim() ?? '';
    return Stack(
      children: [
        Positioned.fill(
          child: coverUrl.isEmpty
              ? Container(color: const Color(0xFF030712))
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
              color: const Color(0xFF020617).withValues(alpha: 0.82),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.82, 0.88),
                radius: 0.9,
                colors: [
                  accent.withValues(alpha: 0.20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.wMin, 72.wMin, 24.wMin, 110.wMin + MediaQuery.of(context).padding.bottom),
            child: mode == ZhenduLearnMode.read ? _buildReadBody(detail) : _buildListenBody(detail, mode),
          ),
        ),
      ],
    );
  }

  String _buildModeHint(ZhenduLearnMode mode) {
    if (mode == ZhenduLearnMode.listen) return '听：更偏音频消费，视觉辅助。';
    if (mode == ZhenduLearnMode.read) return '读：文字为主体，适合精读，系统 UI 常显。';
    if (mode == ZhenduLearnMode.watch) return '看：画面与字幕共同构成主体验，系统 UI 自动显隐。';
    if (mode == ZhenduLearnMode.perform) return '演：沉浸式画面与字幕带，弱化干扰元素。';
    return '练：任务态页面，系统 UI 常显，节目切换禁用。';
  }

  Widget _buildListenBody(ZhenduScriptDetailEntity? detail, ZhenduLearnMode mode) {
    final title = _getTitle(detail);
    final desc = (detail?.description ?? '').trim();
    final accent = _modeAccent(mode);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 960.wMin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeBadge(mode),
            SizedBox(height: 18.wMin),
            Container(
              width: 220.wMin,
              height: 220.wMin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32.wMin),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.92),
                    accent.withValues(alpha: 0.45),
                  ],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.24),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Icon(Icons.play_arrow_rounded, size: 88.wMin, color: Colors.white),
            ),
            SizedBox(height: 24.wMin),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34.wMin,
                fontWeight: FontWeight.w800,
                color: Colors.white.withValues(alpha: 0.94),
                height: 1.1,
              ),
            ),
            if (desc.isNotEmpty) ...[
              SizedBox(height: 12.wMin),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.72),
                  height: 1.5,
                ),
              ),
            ],
            SizedBox(height: 24.wMin),
            _buildInfoPanel(
              title: '时文模式',
              content: _buildModeHint(mode),
              accent: accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadBody(ZhenduScriptDetailEntity? detail) {
    final title = _getTitle(detail);
    final learningTitle = _getLearningTitle(detail);
    final desc = (detail?.description ?? '').trim();
    final sourceName = _readSourceName(detail);
    final accent = _modeAccent(ZhenduLearnMode.read);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1040.wMin),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.wMin),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(28.wMin),
            border: Border.all(color: accent.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModeBadge(ZhenduLearnMode.read),
              SizedBox(height: 18.wMin),
              Text(
                title,
                style: TextStyle(
                  fontSize: 34.wMin,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.94),
                  height: 1.1,
                ),
              ),
              if (learningTitle.isNotEmpty) ...[
                SizedBox(height: 10.wMin),
                Text(
                  learningTitle,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w600,
                    color: accent.withValues(alpha: 0.92),
                  ),
                ),
              ],
              SizedBox(height: 18.wMin),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReadSection(
                        title: '文本说明',
                        content: desc.isEmpty ? '当前接口还没有返回逐句正文，这里先显示作品说明，后续可直接替换成全文阅读内容。' : desc,
                      ),
                      SizedBox(height: 14.wMin),
                      _buildReadSection(
                        title: '内容来源',
                        content: sourceName.isEmpty ? '暂无来源信息' : sourceName,
                      ),
                      SizedBox(height: 14.wMin),
                      _buildReadSection(
                        title: '阅读提示',
                        content: '当前为剧场模式，保留系统 UI 常显，方便在阅读内容与播放器控制之间切换。',
                      ),
                      if ((detail?.tags ?? const <ZhenduTagEntity>[]).isNotEmpty) ...[
                        SizedBox(height: 16.wMin),
                        Wrap(
                          spacing: 10.wMin,
                          runSpacing: 10.wMin,
                          children: (detail?.tags ?? const <ZhenduTagEntity>[])
                              .map((tag) => _buildTag(tag, accent))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadEntryButton() {
    final enabled = controller.isModeAvailable(ZhenduLearnMode.read);
    final accent = _modeAccent(ZhenduLearnMode.read);
    return TapScaleWidget(
      onTap: controller.openReadMode,
      sclae: 1.02,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999.wMin),
          color: accent.withValues(alpha: enabled ? 0.94 : 0.24),
          border: Border.all(
            color: enabled ? accent.withValues(alpha: 0.94) : Colors.white.withValues(alpha: 0.10),
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.24),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, size: 20.wMin, color: Colors.white),
            SizedBox(width: 8.wMin),
            Text(
              '读',
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeBadge(ZhenduLearnMode mode) {
    final accent = _modeAccent(mode);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
        color: accent.withValues(alpha: 0.14),
      ),
      child: Text(
        '当前模式 ${mode.zhName}',
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w700,
          color: accent,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildInfoPanel({
    required String title,
    required String content,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 900.wMin),
      padding: EdgeInsets.all(18.wMin),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18.wMin),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            content,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadSection({
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.wMin),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.wMin),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17.wMin,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            content,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.74),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(ZhenduTagEntity tag, Color accent) {
    final text = _getTagText(tag);
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.wMin),
        color: accent.withValues(alpha: 0.12),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w700,
          color: accent.withValues(alpha: 0.92),
          height: 1.0,
        ),
      ),
    );
  }

  Color _modeAccent(ZhenduLearnMode mode) {
    final item = controller.findLearnItem(mode);
    final from = ColorUtils.parseColor(item?.color?.from);
    final to = ColorUtils.parseColor(item?.color?.to);
    return from ?? to ?? AppTheme.cSurfaceBrand.color;
  }

  String _getLearningTitle(ZhenduScriptDetailEntity? detail) {
    final learning = LearningLangUtils.getLearningLang(detail?.detailTitle)?.text;
    return learning?.trim() ?? '';
  }

  String _readSourceName(ZhenduScriptDetailEntity? detail) {
    final source = detail?.source;
    final data = source?.data ?? const <String, dynamic>{};
    final sourceName = data['content']?.toString().trim() ?? source?.name?.trim() ?? '';
    return sourceName;
  }

  String _getTagText(ZhenduTagEntity tag) {
    final local = LearningLangUtils.getLocalLang(tag.gloss)?.text;
    if (local != null && local.trim().isNotEmpty) return local.trim();
    final learning = LearningLangUtils.getLearningLang(tag.gloss)?.text;
    if (learning != null && learning.trim().isNotEmpty) return learning.trim();
    if (tag.gloss != null && tag.gloss!.isNotEmpty) return tag.gloss!.first.text?.trim() ?? '';
    return '';
  }

  Widget _buildTopBar(BuildContext context) {
    final title = _getTitle(controller.detail.value);
    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.wMin, 10.wMin, 16.wMin, 10.wMin),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        ),
        child: Row(
          children: [
            TapScaleWidget(
              onTap: () => Get.back(),
              sclae: 1.02,
              child: Container(
                padding: EdgeInsets.all(10.wMin),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.wMin),
                ),
                child: Icon(Icons.arrow_back, size: 22.wMin, color: Colors.white),
              ),
            ),
            SizedBox(width: 12.wMin),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22.wMin,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPlayer(BuildContext context) {
    final mode = controller.mode.value;
    final disableShowSwitch = mode == ZhenduLearnMode.practice;
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.wMin, 12.wMin, 16.wMin, 12.wMin),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.40),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        ),
        child: Row(
          children: [
            _buildLeftControls(disableShowSwitch),
            SizedBox(width: 10.wMin),
            Expanded(child: _buildCenterControls(context, mode)),
            SizedBox(width: 10.wMin),
            _buildRightControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftControls(bool disableShowSwitch) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(
          icon: Icons.skip_previous,
          enabled: !disableShowSwitch,
          onTap: controller.onUserInteraction,
        ),
        SizedBox(width: 6.wMin),
        Obx(() {
          return _buildIconButton(
            icon: controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
            enabled: true,
            onTap: controller.togglePlay,
          );
        }),
        SizedBox(width: 6.wMin),
        _buildIconButton(
          icon: Icons.skip_next,
          enabled: !disableShowSwitch,
          onTap: controller.onUserInteraction,
        ),
      ],
    );
  }

  Widget _buildCenterControls(BuildContext context, ZhenduLearnMode mode) {
    return Row(
      children: [
        TapScaleWidget(
          onTap: () => _showModeSheet(context),
          sclae: 1.02,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 10.wMin),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.wMin),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.grid_view_rounded, size: 18.wMin, color: Colors.white.withValues(alpha: 0.9)),
                SizedBox(width: 8.wMin),
                Text(
                  mode.zhName,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10.wMin),
        Expanded(
          child: Text(
            _modeSubLabel(mode),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  String _modeSubLabel(ZhenduLearnMode mode) {
    if (mode == ZhenduLearnMode.listen) return '音频优先';
    if (mode == ZhenduLearnMode.read) return '文本优先';
    if (mode == ZhenduLearnMode.watch) return '画面优先';
    if (mode == ZhenduLearnMode.perform) return '沉浸表演';
    return '任务练习';
  }

  Widget _buildRightControls(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(
          icon: Icons.settings,
          enabled: true,
          onTap: () {
            controller.onUserInteraction();
            ToastUtils.showToast(text: '设置（占位）');
          },
        ),
        SizedBox(width: 6.wMin),
        _buildIconButton(
          icon: Icons.queue_music,
          enabled: true,
          onTap: () {
            controller.onUserInteraction();
            _showPlaylistSheet(context);
          },
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: IgnorePointer(
        ignoring: !enabled,
        child: TapScaleWidget(
          onTap: onTap,
          sclae: 1.02,
          child: Container(
            width: 44.wMin,
            height: 44.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.wMin),
            ),
            child: Icon(icon, size: 22.wMin, color: Colors.white.withValues(alpha: 0.9)),
          ),
        ),
      ),
    );
  }

  void _showModeSheet(BuildContext context) {
    final detail = controller.detail.value;
    final learnItems = detail?.learnItems ?? <ZhenduLearnItemEntity>[];
    final availableModes = learnItems
        .where((e) => e.status == 1)
        .map((e) => ZhenduLearnMode.fromType(e.type))
        .whereType<ZhenduLearnMode>()
        .toList();
    if (availableModes.isEmpty) {
      ToastUtils.showToast(text: '暂无可用模式');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cSurfacePrimary.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.wMin))),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.wMin, 12.wMin, 16.wMin, 12.wMin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60.wMin,
                  height: 6.wMin,
                  decoration: BoxDecoration(
                    color: AppTheme.cBorderTertiary.color,
                    borderRadius: BorderRadius.circular(6.wMin),
                  ),
                ),
                SizedBox(height: 14.wMin),
                Row(
                  children: [
                    Text(
                      '切换模式',
                      style: TextStyle(
                        fontSize: 26.wMin,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.wMin),
                Wrap(
                  spacing: 12.wMin,
                  runSpacing: 12.wMin,
                  children: availableModes.map((m) {
                    final active = controller.mode.value == m;
                    return TapScaleWidget(
                      onTap: () {
                        controller.switchMode(m);
                        Navigator.of(context).pop();
                      },
                      sclae: 1.02,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 12.wMin),
                        decoration: BoxDecoration(
                          color: active ? AppTheme.cSurfaceBrand.color : AppTheme.cSurfaceSecondary.color,
                          borderRadius: BorderRadius.circular(14.wMin),
                          border: Border.all(color: AppTheme.cBorderSecondary.color),
                        ),
                        child: Text(
                          m.zhName,
                          style: TextStyle(
                            fontSize: 22.wMin,
                            fontWeight: FontWeight.w700,
                            color: active ? AppTheme.cInverseTextLight.color : AppTheme.cTextPrimary.color,
                            height: 1.0,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPlaylistSheet(BuildContext context) {
    final title = _getTitle(controller.detail.value);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cSurfacePrimary.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.wMin))),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.wMin, 12.wMin, 16.wMin, 12.wMin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60.wMin,
                  height: 6.wMin,
                  decoration: BoxDecoration(
                    color: AppTheme.cBorderTertiary.color,
                    borderRadius: BorderRadius.circular(6.wMin),
                  ),
                ),
                SizedBox(height: 14.wMin),
                Row(
                  children: [
                    Text(
                      '节目单',
                      style: TextStyle(
                        fontSize: 26.wMin,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.wMin),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceSecondary.color,
                    borderRadius: BorderRadius.circular(14.wMin),
                    border: Border.all(color: AppTheme.cBorderSecondary.color),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 22.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                ),
                SizedBox(height: 12.wMin),
                Text(
                  '节目单数据后续可接入同剧场节目列表，这里先占位保证交互骨架可落地。',
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextTertiary.color,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 10.wMin),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getTitle(ZhenduScriptDetailEntity? detail) {
    final local = LearningLangUtils.getLocalLang(detail?.detailTitle)?.text;
    if (local != null && local.trim().isNotEmpty) return local.trim();
    final learning = LearningLangUtils.getLearningLang(detail?.detailTitle)?.text;
    if (learning != null && learning.trim().isNotEmpty) return learning.trim();
    return '';
  }
}
