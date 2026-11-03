import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/segmented_circular_progress/animated_circle_view.dart';
import 'package:langwise/common/widgets/segmented_circular_progress/circle_painter.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../controllers/mission_control_center_milestone_challenge_controller.dart';

class MissionControlCenterMilestoneChallengeView extends GetView<MissionControlCenterMilestoneChallengeController> {
  final String tagText;
  const MissionControlCenterMilestoneChallengeView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.fromLTRB(90.wMin, 0, 90.wMin, 15.wMin),
        child: Column(
          children: [
            _buildRewardHeader(context),
            SizedBox(height: 16.wMin),
            Expanded(child: _buildContent(context)),
            SizedBox(height: 16.wMin),
            _buildRuleHeader(),
            SizedBox(height: 10.wMin),
            _buildRulePanel(),
          ],
        ),
      );
    });
  }

  Widget _buildContent(BuildContext context) {
    if (controller.loading.value && controller.activeGoals.isEmpty) {
      return Center(
        child: SizedBox(
          width: 48.wMin,
          height: 48.wMin,
          child: CircularProgressIndicator(
            strokeWidth: 3.wMin,
            color: const Color(0xFF8B5CF6),
          ),
        ),
      );
    }
    final goals = controller.activeGoals;
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 2 ? 0 : 16.wMin),
            child: index < goals.length
                ? _buildChallengeCard(context, goals[index])
                : _buildChallengePlaceholderCard(context),
          ),
        );
      }),
    );
  }

  Widget _buildRewardHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: const Color(0xFF6366F1).withValues(alpha: 0.12),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.20),
          width: 1.wMin,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/svg/mission/icon_present.svg',
            width: 100.wMin,
            height: 100.wMin,
          ),
          SizedBox(width: 14.wMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '里程碑挑战',
                  style: TextStyle(
                    fontSize: 40.wMin,
                    color: AppTheme.cStaticWhite.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.wMin),
                Text(
                  '最多同时进行 ${controller.activeLimit} 个挑战。奖励由家长承诺并兑现。',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4.wMin),
                Text(
                  '当前占用名额 ${controller.activeCount}/${controller.activeLimit}',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _buildRewardStat('已兑现', '${controller.claimedCount}'),
          _buildHeaderDivider(),
          _buildRewardStat('已作废', '${controller.voidedCount}'),
          _buildHeaderDivider(),
          _buildRewardStat('待兑现', '${controller.claimableCount}'),
          SizedBox(width: 16.wMin),
          _buildHeaderAction(
            text: '查看详情',
            onTap: () => _showHistoryDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardStat(String label, String value) {
    return SizedBox(
      width: 84.wMin,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 6.wMin),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cStaticWhite.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderDivider() {
    return Container(
      width: 1.wMin,
      height: 42.wMin,
      margin: EdgeInsets.symmetric(horizontal: 16.wMin),
      color: AppTheme.cStaticWhite.color.withValues(alpha: 0.15),
    );
  }

  Widget _buildHeaderAction({
    required String text,
    bool isPrimary = false,
    VoidCallback? onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      child: Container(
        height: 56.wMin,
        padding: EdgeInsets.symmetric(horizontal: 18.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.wMin),
          color: isPrimary
              ? const Color(0xFF8B5CF6)
              : AppTheme.cStaticWhite.color.withValues(alpha: 0.15),
          border: Border.all(
            color: isPrimary
                ? const Color(0xFF8B5CF6)
                : AppTheme.cStaticWhite.color.withValues(alpha: 0.15),
            width: 1.wMin,
          ),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 22.wMin,
                color: AppTheme.cStaticWhite.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8.wMin),
            Icon(
              Icons.chevron_right_rounded,
              size: 24.wMin,
              color: AppTheme.cStaticWhite.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengePlaceholderCard(BuildContext context) {
    return TapScaleWidget(
      onTap: controller.canCreate ? () => _showCreateDialog(context) : null,
      sclae: 1.01,
      child: Container(
        padding: EdgeInsets.all(18.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cBgSecondary.color,
          border: Border.all(
            color: AppTheme.cBgTertiary.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 84.wMin,
              height: 84.wMin,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0C2A3A),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 48.wMin,
                color: const Color(0xFF38BDF8),
              ),
            ),
            SizedBox(height: 20.wMin),
            Text(
              '新增一个成长悬赏',
              style: TextStyle(
                fontSize: 26.wMin,
                color: AppTheme.cStaticWhite.color,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10.wMin),
            Text(
              '只保留最值得冲刺的 1-3 个长期目标，让孩子每次都能清楚看到当下最重要的挑战。',
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                color: AppTheme.cBgPrimary.color,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '创建需要管理员密码',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cStaticWhite.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.wMin),
                  Text(
                    '目标一旦创建就不能修改，只能由家长确认作废或兑现奖励。',
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: AppTheme.cTextSecondary.color,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, MilestoneChallengeItemEntity item) {
    final subtasks = item.subtasks ?? const <MilestoneChallengeSubtaskEntity>[];
    return Container(
      padding: EdgeInsets.all(14.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cBgSecondary.color,
        border: Border.all(
          color: AppTheme.cBgTertiary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name ?? '挑战名称',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 32.wMin,
                          color: AppTheme.cStaticWhite.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.wMin),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999.wMin),
                        color: _statusAccentColor(item).withValues(alpha: 0.18),
                      ),
                      child: Text(
                        item.statusText,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: _statusAccentColor(item),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.wMin),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.isClaimable ? '可立即兑现' : '剩余 ${item.remainingDays ?? 0} 天',
                    style: TextStyle(
                      fontSize: 22.wMin,
                      color: AppTheme.cStaticWhite.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.wMin),
                  Text(
                    _dateRangeText(item),
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.wMin),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                color: AppTheme.cBgPrimary.color,
              ),
              child: subtasks.isEmpty
                  ? const Center(child: NotDataWidget(message: '暂无子任务'))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: subtasks
                          .map((metric) => Expanded(child: _buildMetricCircle(metric)))
                          .toList(),
                    ),
            ),
          ),
          SizedBox(height: 12.wMin),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.rewardName?.isNotEmpty == true ? item.rewardName! : '奖励名称待补充',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cStaticWhite.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.wMin),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '承诺者 ',
                            style: TextStyle(
                              fontSize: 18.wMin,
                              color: AppTheme.cTextTertiary.color,
                            ),
                          ),
                          TextSpan(
                            text: item.promiserName?.isNotEmpty == true ? item.promiserName! : '--',
                            style: TextStyle(
                              fontSize: 18.wMin,
                              color: AppTheme.cTextSecondary.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.wMin),
              if (item.canVoid)
                _buildCardAction(
                  text: '作废挑战',
                  onTap: () => _onVoidChallenge(context, item.uid),
                ),
              if (item.canVoid) SizedBox(width: 8.wMin),
              if (item.canClaim)
                _buildCardAction(
                  text: '兑换奖励',
                  isPrimary: true,
                  onTap: () => _onClaimChallenge(context, item.uid),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCircle(MilestoneChallengeSubtaskEntity metric) {
    final progress = ((metric.progressPct ?? 0).clamp(0, 1)).toDouble();
    final color = _metricColor(metric.metric);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 108.wMin,
          height: 108.wMin,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedCircleView(
                key: ValueKey('${metric.subtaskId}_${metric.progressPct}'),
                duration: Duration.zero,
                fadeInDuration: Duration.zero,
                curve: Curves.linear,
                isContinuous: true,
                progressValue: progress,
                borderWidth: 5.wMin,
                strokeWidth: 5.wMin,
                circlePainterConfig: CirclePainterConfig.full(
                  fillColor: color,
                  borderColor: color,
                  baseColor: AppTheme.cStaticWhite.color.withValues(alpha: 0.12),
                  strokeWidth: 5.wMin,
                  borderWidth: 5.wMin,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      fontSize: 22.wMin,
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.wMin),
                  Text(
                    controller.metricTitle(metric.metric),
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: AppTheme.cTextSecondary.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.wMin),
        Text(
          controller.subtaskSummary(metric),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cStaticWhite.color,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4.wMin),
        Text(
          controller.subtaskDescription(metric),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildCardAction({
    required String text,
    bool isPrimary = false,
    VoidCallback? onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: isPrimary ? const Color(0xFF8B5CF6) : AppTheme.cStaticWhite.color.withValues(alpha: 0.08),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cStaticWhite.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRuleHeader() {
    return Row(
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 24.wMin,
          color: const Color(0xFFFF4D6D),
        ),
        SizedBox(width: 8.wMin),
        Text(
          '规则提示',
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cStaticWhite.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRulePanel() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cBgSecondary.color,
        border: Border.all(
          color: AppTheme.cBgTertiary.color,
          width: 1.wMin,
        ),
      ),
      child: Text(
        '目标创建后不可修改，待兑现时整张挑战卡会高光显示，提醒家长尽快履约。',
        style: TextStyle(
          fontSize: 18.wMin,
          color: AppTheme.cTextSecondary.color,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await controller.ensureMeta();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MilestoneCreateDialog(controller: controller),
    );
  }

  Future<void> _showHistoryDialog(BuildContext context) async {
    await controller.loadHistory();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _MilestoneHistoryDialog(controller: controller),
    );
  }

  Future<void> _onClaimChallenge(BuildContext context, int? uid) async {
    if (uid == null) return;
    final verified = await ParentPasswordialog.show(context: context);
    if (!verified) return;
    await controller.claimChallenge(uid);
  }

  Future<void> _onVoidChallenge(BuildContext context, int? uid) async {
    if (uid == null) return;
    final verified = await ParentPasswordialog.show(context: context);
    if (!verified) return;
    await controller.voidChallenge(uid);
  }

  Color _statusAccentColor(MilestoneChallengeItemEntity item) {
    if (item.isClaimable) return const Color(0xFF8B5CF6);
    if (item.isClaimed) return const Color(0xFF10B981);
    if (item.isExpired) return const Color(0xFFF43F5E);
    if (item.isVoided) return const Color(0xFF6B7280);
    return _toneColor(item.tone);
  }

  Color _toneColor(String? tone) {
    switch (tone) {
      case 'GREEN':
        return const Color(0xFF10B981);
      case 'ORANGE':
        return const Color(0xFFF59E0B);
      case 'PURPLE':
        return const Color(0xFFC084FC);
      case 'BLUE':
      default:
        return const Color(0xFF60A5FA);
    }
  }

  Color _metricColor(String? metric) {
    switch (metric) {
      case 'STUDY_DAYS':
        return const Color(0xFF00D8A4);
      case 'MINUTES':
        return const Color(0xFF4B8CFF);
      case 'STARS':
        return const Color(0xFFFBBF24);
      case 'GEMS':
        return const Color(0xFFC084FC);
      case 'PLAN_DAYS':
        return const Color(0xFFFF5B7F);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  String _dateRangeText(MilestoneChallengeItemEntity item) {
    final start = (item.startDate ?? '').replaceAll('-', '.');
    final end = (item.endDate ?? '').replaceAll('-', '.');
    if (start.isEmpty && end.isEmpty) return '--';
    return '$start - $end';
  }
}

class _MilestoneHistoryDialog extends StatelessWidget {
  final MissionControlCenterMilestoneChallengeController controller;
  const _MilestoneHistoryDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    final list = controller.historyList;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 980.wMin,
        padding: EdgeInsets.all(20.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary.color,
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(color: AppTheme.cBgTertiary.color, width: 1.wMin),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogTitle(context, '历史挑战'),
            SizedBox(height: 12.wMin),
            Row(
              children: [
                _buildStatChip('已兑现', controller.claimedCount.toString()),
                SizedBox(width: 10.wMin),
                _buildStatChip('已作废', controller.voidedCount.toString()),
                SizedBox(width: 10.wMin),
                _buildStatChip('已过期', controller.expiredCount.toString()),
              ],
            ),
            SizedBox(height: 16.wMin),
            if (list.isEmpty)
              const SizedBox(
                height: 180,
                child: Center(child: NotDataWidget(message: '暂无历史挑战')),
              )
            else
              SizedBox(
                height: 420.wMin,
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.wMin),
                  itemBuilder: (_, index) {
                    final item = list[index];
                    return TapScaleWidget(
                      onTap: () async {
                        Navigator.of(context).pop();
                        final detail = await controller.loadDetail(item.uid ?? 0);
                        if (detail == null || !context.mounted) return;
                        await showDialog<void>(
                          context: context,
                          builder: (_) => _MilestoneDetailDialog(controller: controller, item: detail),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(14.wMin),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.wMin),
                          color: AppTheme.cBgPrimary.color,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name ?? '--',
                                    style: TextStyle(
                                      fontSize: 22.wMin,
                                      color: AppTheme.cStaticWhite.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4.wMin),
                                  Text(
                                    '${item.startDate ?? '--'} ~ ${item.endDate ?? '--'}',
                                    style: TextStyle(
                                      fontSize: 16.wMin,
                                      color: AppTheme.cTextTertiary.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999.wMin),
                                color: const Color(0xFF334155),
                              ),
                              child: Text(
                                item.statusText,
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  color: AppTheme.cStaticWhite.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogTitle(BuildContext context, String title) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cStaticWhite.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
          color: AppTheme.cTextSecondary.color,
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.wMin),
        color: AppTheme.cBgPrimary.color,
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          fontSize: 16.wMin,
          color: AppTheme.cTextSecondary.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MilestoneDetailDialog extends StatelessWidget {
  final MissionControlCenterMilestoneChallengeController controller;
  final MilestoneChallengeItemEntity item;
  const _MilestoneDetailDialog({required this.controller, required this.item});

  @override
  Widget build(BuildContext context) {
    final subtasks = item.subtasks ?? const <MilestoneChallengeSubtaskEntity>[];
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 920.wMin,
        padding: EdgeInsets.all(20.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary.color,
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(color: AppTheme.cBgTertiary.color, width: 1.wMin),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name ?? '--',
                        style: TextStyle(
                          fontSize: 28.wMin,
                          color: AppTheme.cStaticWhite.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6.wMin),
                      Text(
                        '${item.startDate ?? '--'} ~ ${item.endDate ?? '--'}',
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: AppTheme.cTextTertiary.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999.wMin),
                    color: AppTheme.cBgPrimary.color,
                  ),
                  child: Text(
                    item.statusText,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: AppTheme.cStaticWhite.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 8.wMin),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: AppTheme.cTextSecondary.color,
                ),
              ],
            ),
            SizedBox(height: 14.wMin),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                color: AppTheme.cBgPrimary.color,
              ),
              child: Row(
                children: [
                  Expanded(child: _buildInfoCell('奖励', item.rewardName ?? '--')),
                  Expanded(child: _buildInfoCell('承诺者', item.promiserName ?? '--')),
                  Expanded(child: _buildInfoCell('奖励状态', item.rewardStatus ?? '--')),
                  Expanded(child: _buildInfoCell('计划基线', '${item.planBaselineMinutes ?? 0} 分钟/天')),
                ],
              ),
            ),
            SizedBox(height: 16.wMin),
            Text(
              '子任务详情',
              style: TextStyle(
                fontSize: 22.wMin,
                color: AppTheme.cStaticWhite.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.wMin),
            if (subtasks.isEmpty)
              const SizedBox(
                height: 120,
                child: Center(child: NotDataWidget(message: '暂无子任务')),
              )
            else
              ...subtasks.map((subtask) {
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10.wMin),
                  padding: EdgeInsets.all(14.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.wMin),
                    color: AppTheme.cBgPrimary.color,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.metricTitle(subtask.metric),
                              style: TextStyle(
                                fontSize: 18.wMin,
                                color: AppTheme.cStaticWhite.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.wMin),
                            Text(
                              controller.subtaskDescription(subtask),
                              style: TextStyle(
                                fontSize: 15.wMin,
                                color: AppTheme.cTextSecondary.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        controller.subtaskSummary(subtask),
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cStaticWhite.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            SizedBox(height: 8.wMin),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (item.canVoid)
                  ButtonWidget(
                    text: '作废挑战',
                    width: 120.wMin,
                    height: 42.wMin,
                    borderRadius: 8.wMin,
                    color: AppTheme.cBgPrimary.color,
                    fontColor: AppTheme.cTextSecondary.color,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w600,
                    onTap: () async {
                      final verified = await ParentPasswordialog.show(context: context);
                      if (!verified) return;
                      final ok = await controller.voidChallenge(item.uid ?? 0);
                      if (ok && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                if (item.canVoid) SizedBox(width: 10.wMin),
                if (item.canClaim)
                  ButtonWidget(
                    text: '兑换奖励',
                    width: 120.wMin,
                    height: 42.wMin,
                    borderRadius: 8.wMin,
                    color: const Color(0xFF8B5CF6),
                    fontColor: AppTheme.cStaticWhite.color,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w600,
                    onTap: () async {
                      final verified = await ParentPasswordialog.show(context: context);
                      if (!verified) return;
                      final ok = await controller.claimChallenge(item.uid ?? 0);
                      if (ok && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCell(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.wMin,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
        SizedBox(height: 4.wMin),
        Text(
          value,
          style: TextStyle(
            fontSize: 17.wMin,
            color: AppTheme.cStaticWhite.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MilestoneCreateDialog extends StatefulWidget {
  final MissionControlCenterMilestoneChallengeController controller;
  const _MilestoneCreateDialog({required this.controller});

  @override
  State<_MilestoneCreateDialog> createState() => _MilestoneCreateDialogState();
}

class _MilestoneCreateDialogState extends State<_MilestoneCreateDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController();
  late List<_MilestoneDraftSubtaskForm> _subtasks;
  String? _startDate;
  String? _endDate;
  String? _promiserName;

  MissionControlCenterMilestoneChallengeController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = _formatDate(now);
    _endDate = _formatDate(now.add(const Duration(days: 6)));
    _promiserName = controller.meta.value.promiserOptions?.firstOrNull;
    _subtasks = [_buildDefaultSubtask()];
    controller.analyseResult.value = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerAnalyseIfPossible();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 1580.wMin,
        padding: EdgeInsets.all(32.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary.color,
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(color: AppTheme.cBgTertiary.color, width: 1.wMin),
        ),
        child: Obx(() {
          final meta = controller.meta.value;
          final analyseResult = controller.analyseResult.value;
          final maxSubtaskCount = (meta.maxSubtaskCount ?? 3).clamp(1, 3);
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '新建挑战奖励',
                        style: TextStyle(
                          fontSize: 32.wMin,
                          color: AppTheme.cStaticWhite.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ],
                ),
                SizedBox(height: 16.wMin),
                _buildTopSection(),
                SizedBox(height: 12.wMin),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final spacing = 12.wMin;
                    const slotCount = 3;
                    final itemWidth = (constraints.maxWidth - spacing * (slotCount - 1)) / slotCount;
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(slotCount * 2 - 1, (index) {
                          if (index.isOdd) return SizedBox(width: spacing);
                          final slotIndex = index ~/ 2;
                          return SizedBox(
                            width: itemWidth,
                            child: slotIndex < _subtasks.length
                                ? _buildSubtaskEditor(slotIndex, maxSubtaskCount, analyseResult)
                                : _buildSubtaskPlaceholder(maxSubtaskCount),
                          );
                        }),
                      ),
                    );
                  },
                ),
                SizedBox(height: 14.wMin),
                _buildBottomSection(meta.promiserOptions ?? const []),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      padding: EdgeInsets.fromLTRB(12.wMin, 10.wMin, 12.wMin, 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(color: const Color(0xFF3A4048), width: 1.wMin),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2B2F36),
            Color(0xFF25292F),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: _buildInput(
              title: '挑战名称',
              child: TextField(
                controller: _nameController,
                style: TextStyle(
                  color: AppTheme.cStaticWhite.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecoration('请输入挑战名称'),
              ),
            ),
          ),
          SizedBox(width: 12.wMin),
          Expanded(
            flex: 2,
            child: _buildInput(
              title: '开始日期',
              child: _buildDateField(
                text: _formatDisplayDate(_startDate),
                onTap: () => _pickDate(isStart: true),
              ),
            ),
          ),
          SizedBox(width: 12.wMin),
          Expanded(
            flex: 2,
            child: _buildInput(
              title: '结束时间',
              child: _buildDateField(
                text: _formatDisplayDate(_endDate),
                onTap: () => _pickDate(isStart: false),
              ),
            ),
          ),
          SizedBox(width: 12.wMin),
          SizedBox(width: 96.wMin, child: _buildRangePanel()),
        ],
      ),
    );
  }

  Widget _buildBottomSection(List<String> promiserOptions) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.wMin, 10.wMin, 12.wMin, 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(color: const Color(0xFF3A4048), width: 1.wMin),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2B2F36),
            Color(0xFF25292F),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _buildInput(
              title: '奖品',
              child: TextField(
                controller: _rewardController,
                style: TextStyle(
                  color: AppTheme.cStaticWhite.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecoration('请输入奖品名称'),
              ),
            ),
          ),
          SizedBox(width: 14.wMin),
          Expanded(
            flex: 5,
            child: _buildInput(
              title: '承诺人',
              child: _buildPromiserSelector(promiserOptions),
            ),
          ),
          SizedBox(width: 14.wMin),
          Padding(
            padding: EdgeInsets.only(top: 24.wMin),
            child: TapScaleWidget(
              onTap: () => _createChallenge(context),
              sclae: 1.01,
              child: Container(
                width: 148.wMin,
                height: 54.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.wMin),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF7C8CFB),
                      Color(0xFFB14DFF),
                    ],
                  ),
                ),
                child: Text(
                  '创建挑战',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cStaticWhite.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangePanel() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Range',
            style: TextStyle(
              fontSize: 14.wMin,
              color: const Color(0xFF8D9197),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.wMin),
          Text(
            '$_rangeDays天',
            style: TextStyle(
              fontSize: 40.wMin,
              color: AppTheme.cStaticWhite.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      )
    
    ;
  }

  Widget _buildInput({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 6.wMin),
        child,
      ],
    );
  }

  Widget _buildDateField({required String text, required VoidCallback onTap}) {
    return TapScaleWidget(
      onTap: onTap,
      child: _buildFieldShell(
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 16.wMin,
              color: const Color(0xFFB7BBC2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromiserSelector(List<String> options) {
    final isCustomPromiser = _promiserName != null && !options.contains(_promiserName);
    return Wrap(
      spacing: 8.wMin,
      runSpacing: 8.wMin,
      children: [
        ...options.map((item) {
          return _buildPromiserChip(
            label: item,
            selected: _promiserName == item,
            onTap: () {
              setState(() {
                _promiserName = item;
              });
            },
          );
        }),
        _buildPromiserChip(
          label: '+ 手动输入',
          selected: isCustomPromiser,
          outlined: true,
          onTap: _showPromiserInputDialog,
        ),
      ],
    );
  }

  Widget _buildPromiserChip({
    required String label,
    required VoidCallback onTap,
    bool selected = false,
    bool outlined = false,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.01,
      child: Container(
        height: 52.wMin,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99.wMin),
          color: selected
              ? const Color(0xFF7C8CFB)
              : outlined
                  ? Colors.transparent
                  : const Color(0xFF515864),
          border: outlined || selected
              ? Border.all(
                  color: selected ? const Color(0xFF7C8CFB) : const Color(0xFF515864),
                  width: 1.wMin,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 24.wMin,
                color: selected ? AppTheme.cStaticWhite.color : AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPromiserInputDialog() async {
    final textController = TextEditingController(
      text: (_promiserName?.isNotEmpty ?? false) ? _promiserName : '',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cBgSecondary.color,
          title: Text(
            '输入承诺人',
            style: TextStyle(color: AppTheme.cStaticWhite.color, fontSize: 20.wMin),
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            style: TextStyle(
              color: AppTheme.cTextPrimary.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
            ),
            decoration: _inputDecoration('请输入承诺人'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('取消', style: TextStyle(color: AppTheme.cTextSecondary.color)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(textController.text.trim()),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
    if ((result ?? '').isEmpty) return;
    setState(() {
      _promiserName = result;
    });
  }

  Widget _buildSubtaskEditor(
    int index,
    int maxSubtaskCount,
    MilestoneChallengeAnalyseEntity? analyseResult,
  ) {
    final item = _subtasks[index];
    final normalized = _normalizedSubtaskAt(index, item, analyseResult);
    final metricOptions = controller.meta.value.metrics ?? const <MilestoneChallengeMetricOption>[];
    final currentMetric = metricOptions.firstWhereOrNull((element) => element.metric == item.metric);
    final allowedKinds = currentMetric?.allowedKinds ?? const <String>[];
    if (item.kind != null && allowedKinds.isNotEmpty && !allowedKinds.contains(item.kind)) {
      item.kind = allowedKinds.first;
    }
    return Container(
      padding: EdgeInsets.fromLTRB(16.wMin, 14.wMin, 16.wMin, 16.wMin),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2B2F36),
            Color(0xFF25292F),
          ],
        ),
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(color: const Color(0xFF3A4048), width: 1.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '条件${index + 1}',
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: AppTheme.cStaticWhite.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_subtasks.length > 1)
                TapScaleWidget(
                  onTap: () {
                    setState(() {
                      _subtasks.removeAt(index);
                    });
                    _triggerAnalyseIfPossible();
                  },
                  child: Text(
                    '删除',
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: const Color(0xFFB7BBC2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 18.wMin),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  title: '1、设置指标',
                  value: item.metric,
                  values: metricOptions.map((e) => e.metric ?? '').where((e) => e.isNotEmpty).toList(),
                  labelBuilder: (value) =>
                      metricOptions.firstWhereOrNull((e) => e.metric == value)?.title ?? value,
                  colorBuilder: _metricColor,
                  onChanged: (value) {
                    setState(() {
                      item.metric = value;
                      final nextMetric = metricOptions.firstWhereOrNull((e) => e.metric == value);
                      item.kind = nextMetric?.allowedKinds?.firstOrNull;
                    });
                    _triggerAnalyseIfPossible();
                  },
                ),
              ),
              SizedBox(width: 12.wMin),
              Expanded(
                child: _buildDropdownField(
                  title: '统计方式',
                  value: item.kind,
                  values: allowedKinds,
                  labelBuilder: controller.kindTitle,
                  onChanged: (value) {
                    setState(() {
                      item.kind = value;
                    });
                    _triggerAnalyseIfPossible();
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12.wMin),
          _buildNumberField(
            title: '2、填入目标值',
            initialValue: item.targetValue?.toString(),
            hintText: '请输入',
            suffixText: _displaySubtaskUnit(item, normalized),
            trailingTitle: _displaySubtaskMaxTargetValue(item, normalized),
            onChanged: (value) => item.targetValue = int.tryParse(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtaskPlaceholder(int maxSubtaskCount) {
    final canAdd = _subtasks.length < maxSubtaskCount && _subtasks.length < 3;
    return TapScaleWidget(
      onTap: canAdd
          ? () {
              setState(() {
                _subtasks.add(_buildDefaultSubtask());
              });
              _triggerAnalyseIfPossible();
            }
          : null,
      sclae: 1.01,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cBgPrimary.color,
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(color: AppTheme.cBgTertiary.color, width: 1.wMin),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.wMin,
                height: 64.wMin,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0C2A3A),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 34.wMin,
                  color: const Color(0xFF38BDF8),
                ),
              ),
              SizedBox(height: 16.wMin),
              Text(
                canAdd ? '添加条件' : '条件已满',
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cStaticWhite.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String title,
    required String? value,
    required List<String> values,
    required String Function(String value) labelBuilder,
    Color Function(String value)? colorBuilder,
    required ValueChanged<String?> onChanged,
  }) {
    return _buildInput(
      title: title,
      child: _buildFieldShell(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: values.contains(value) ? value : null,
            isExpanded: true,
            dropdownColor: AppTheme.cBgSecondary.color,
            hint: Text(
              '请选择',
              style: TextStyle(
                color: AppTheme.cTextTertiary.color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
              ),
            ),
            iconEnabledColor: AppTheme.cTextSecondary.color,
            style: TextStyle(
              color: AppTheme.cTextPrimary.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
            ),
            selectedItemBuilder: (_) => values
                .map(
                  (item) => _buildDropdownOptionLabel(
                    text: labelBuilder(item),
                    color: colorBuilder?.call(item),
                  ),
                )
                .toList(),
            items: values
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: _buildDropdownOptionLabel(
                      text: labelBuilder(item),
                      color: colorBuilder?.call(item),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownOptionLabel({
    required String text,
    Color? color,
  }) {
    return Row(
      children: [
        if (color != null) ...[
          Container(
            width: 12.wMin,
            height: 12.wMin,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.wMin),
        ],
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String title,
    required String? initialValue,
    required String hintText,
    String? suffixText,
    String? trailingTitle,
    required ValueChanged<String> onChanged,
  }) {
    final controller = TextEditingController(text: initialValue);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if ((trailingTitle ?? '').isNotEmpty)
              Text(
                trailingTitle!,
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        SizedBox(height: 6.wMin),
        _buildFieldShell(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: AppTheme.cTextPrimary.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
            ),
            decoration: _inputDecoration(hintText, suffixText: suffixText),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldShell({required Widget child}) {
    return Container(
      height: 52.wMin,
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 12.wMin),
      decoration: BoxDecoration(
        color: const Color(0xFF191D23),
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      child: child,
    );
  }

  MilestoneChallengeNormalizedSubtask? _normalizedSubtaskAt(
    int index,
    _MilestoneDraftSubtaskForm item,
    MilestoneChallengeAnalyseEntity? analyseResult,
  ) {
    final subtasks = analyseResult?.normalizedSubtasks ?? const <MilestoneChallengeNormalizedSubtask>[];
    if (index < subtasks.length) {
      final current = subtasks[index];
      if (current.metric == item.metric && current.kind == item.kind) {
        return current;
      }
    }
    return subtasks.firstWhereOrNull((element) => element.metric == item.metric && element.kind == item.kind);
  }

  String _displaySubtaskUnit(
    _MilestoneDraftSubtaskForm item,
    MilestoneChallengeNormalizedSubtask? normalized,
  ) {
    final unit = normalized?.unit?.trim() ?? '';
    if (unit.isNotEmpty) {
      item.displayUnit = unit;
      return unit;
    }
    if ((item.displayUnit ?? '').isNotEmpty) {
      return item.displayUnit!;
    }
    return _fallbackUnit(item.metric, item.kind);
  }

  String? _displaySubtaskMaxTargetValue(
    _MilestoneDraftSubtaskForm item,
    MilestoneChallengeNormalizedSubtask? normalized,
  ) {
    final maxTargetValue = normalized?.maxTargetValue;
    if (maxTargetValue != null) {
      item.displayMaxTargetValue = maxTargetValue;
      return '上限：$maxTargetValue';
    }
    if (item.displayMaxTargetValue != null) {
      return '上限：${item.displayMaxTargetValue}';
    }
    return null;
  }

  String _fallbackUnit(String? metric, String? kind) {
    if (kind == 'QUALIFIED_DAYS' || kind == 'STREAK') {
      return '天';
    }
    switch (metric) {
      case 'MINUTES':
        return '分钟';
      case 'STARS':
      case 'GEMS':
        return '个';
      case 'STUDY_DAYS':
      case 'PLAN_DAYS':
        return '天';
      default:
        return '';
    }
  }

  Color _metricColor(String value) {
    switch (value) {
      case 'STUDY_DAYS':
        return const Color(0xFF00D8A4);
      case 'MINUTES':
        return const Color(0xFF4B8CFF);
      case 'STARS':
        return const Color(0xFFFBBF24);
      case 'GEMS':
        return const Color(0xFFC084FC);
      case 'PLAN_DAYS':
        return const Color(0xFFFF5B7F);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  _MilestoneDraftSubtaskForm _buildDefaultSubtask() {
    final metrics = controller.meta.value.metrics ?? const <MilestoneChallengeMetricOption>[];
    final metric = metrics.firstOrNull;
    return _MilestoneDraftSubtaskForm()
      ..metric = metric?.metric
      ..kind = metric?.allowedKinds?.firstOrNull;
  }

  int get _rangeDays {
    final start = DateFormatUtil.tryParseDate(_startDate);
    final end = DateFormatUtil.tryParseDate(_endDate);
    if (start == null || end == null) return 0;
    return end.difference(start).inDays + 1;
  }

  String _formatDisplayDate(String? value) {
    final date = DateFormatUtil.tryParseDate(value);
    if (date == null) return '--';
    return '${date.year}年${date.month}月${date.day}日';
  }

  Future<void> _triggerAnalyseIfPossible() async {
    final subtasks = _buildDraftSubtasks(showToast: false);
    if (subtasks == null || subtasks.isEmpty || _startDate == null || _endDate == null) {
      controller.resetAnalyseResult();
      return;
    }
    await controller.analyseDraft(
      startDate: _startDate!,
      endDate: _endDate!,
      subtasks: subtasks,
    );
  }

  InputDecoration _inputDecoration(String hintText, {String? suffixText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppTheme.cTextTertiary.color,
        fontSize: 24.wMin,
        fontWeight: FontWeight.w500,
      ),
      suffixIcon: suffixText == null
          ? null
          : Padding(
              padding: EdgeInsets.only(right: 12.wMin),
              child: Text(
                suffixText,
                style: TextStyle(
                  color: AppTheme.cTextPrimary.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
      suffixIconConstraints: BoxConstraints(minWidth: 64.wMin),
      filled: true,
      fillColor: const Color(0xFF191D23),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 12.wMin),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.wMin),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.wMin),
        borderSide: BorderSide.none,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.wMin),
        borderSide: BorderSide.none,
      ),
    );
  }
 
  Future<void> _pickDate({required bool isStart}) async {
    final initial = DateFormatUtil.tryParseDate(isStart ? _startDate : _endDate) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2035, 12, 31),
    );
    if (date == null) return;
    setState(() {
      if (isStart) {
        _startDate = _formatDate(date);
      } else {
        _endDate = _formatDate(date);
      }
    });
    _triggerAnalyseIfPossible();
  }

  Future<void> _createChallenge(BuildContext context) async {
    final name = _nameController.text.trim();
    final rewardName = _rewardController.text.trim();
    if (name.isEmpty) {
      ToastUtils.showToast(text: '请输入挑战名称');
      return;
    }
    if (rewardName.isEmpty) {
      ToastUtils.showToast(text: '请输入奖励名称');
      return;
    }
    if (_promiserName == null || _promiserName!.isEmpty) {
      ToastUtils.showToast(text: '请选择承诺者');
      return;
    }
    if (_startDate == null || _endDate == null) {
      ToastUtils.showToast(text: '请选择起止日期');
      return;
    }
    final subtasks = _buildDraftSubtasks(requireTargetValue: true);
    if (subtasks == null) return;
    final request = MilestoneChallengeCreateRequest(
      name: name,
      startDate: _startDate,
      endDate: _endDate,
      rewardName: rewardName,
      promiserName: _promiserName,
      subtasks: subtasks,
    );
    final result = await controller.createChallenge(request);
    if (result != null && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  List<MilestoneChallengeDraftSubtaskRequest>? _buildDraftSubtasks({
    bool requireTargetValue = false,
    bool showToast = true,
  }) {
    final drafts = <MilestoneChallengeDraftSubtaskRequest>[];
    for (final item in _subtasks) {
      if ((item.metric ?? '').isEmpty || (item.kind ?? '').isEmpty) {
        if (showToast) {
          ToastUtils.showToast(text: '请补全子任务指标和统计方式');
        }
        return null;
      }
      if (requireTargetValue && (item.targetValue ?? 0) <= 0) {
        if (showToast) {
          ToastUtils.showToast(text: '子任务目标值必须大于 0');
        }
        return null;
      }
      drafts.add(
        MilestoneChallengeDraftSubtaskRequest(
          metric: item.metric,
          kind: item.kind,
          targetValue: item.targetValue,
        ),
      );
    }
    return drafts;
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _MilestoneDraftSubtaskForm {
  String? metric;
  String? kind;
  int? targetValue;
  String? displayUnit;
  int? displayMaxTargetValue;
}
