import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';

class ElementsSentenceRelationsContentWidget extends StatelessWidget {
  final EnSentenceStructureDetailEntity detils;
  const ElementsSentenceRelationsContentWidget({
    super.key,
    required this.detils,
  });

  static const Map<String, int> _moduleOrder = {
    'pattern': 1,
    'pyramid': 2,
    'paradigm': 3,
    'pair': 4,
    'pair_fork': 5,
  };

  static const Map<String, IconData> _moduleIcons = {
    'pattern': Icons.account_tree_outlined,
    'pyramid': Icons.layers_outlined,
    'paradigm': Icons.compare_arrows_outlined,
    'pair': Icons.link_outlined,
    'pair_fork': Icons.alt_route_outlined,
  };

  static const Map<String, List<Color>> _moduleGradients = {
    'pattern': [Color(0xFFF87171), Color(0xFFF59E0B)],
    'pyramid': [Color(0xFF34D399), Color(0xFF06B6D4)],
    'paradigm': [Color(0xFFD946EF), Color(0xFF8B5CF6)],
    'pair': [Color(0xFFFB7185), Color(0xFFF97316)],
    'pair_fork': [Color(0xFFF59E0B), Color(0xFFD946EF)],
  };

  @override
  Widget build(BuildContext context) {
    final List<EnSentenceStructureRelationGroup> groups = _visibleGroups();
    if (groups.isEmpty) {
      return Container(
      alignment: Alignment.center,
      child: Text(
        '当前句子暂无关联',
        style: TextStyle(
          fontSize: 22.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cStaticWhite,
        ),
      ),
    );
    }

    return SingleChildScrollView(
      child: Column(
        children: List.generate(groups.length, (index) {
          final EnSentenceStructureRelationGroup group = groups[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index == groups.length - 1 ? 0 : 16.wMin),
            child: _buildGroupCard(group),
          );
        }),
      ),
    );
  }

  List<EnSentenceStructureRelationGroup> _visibleGroups() {
    final List<EnSentenceStructureRelationGroup> groups =
        (detils.analysisData?.relations ?? <EnSentenceStructureRelationGroup?>[])
            .whereType<EnSentenceStructureRelationGroup>()
            .where((group) => (group.items ?? <EnSentenceStructureRelationItem?>[]).whereType<EnSentenceStructureRelationItem>().isNotEmpty)
            .toList();
    groups.sort((a, b) => _groupOrder(a).compareTo(_groupOrder(b)));
    return groups;
  }

  int _groupOrder(EnSentenceStructureRelationGroup group) {
    return _moduleOrder[_normalizedCode(group.code ?? group.type)] ?? 99;
  }

  Widget _buildGroupCard(EnSentenceStructureRelationGroup group) {
    final String code = _normalizedCode(group.code ?? group.type);
    final List<EnSentenceStructureRelationItem> items =
        (group.items ?? <EnSentenceStructureRelationItem?>[]).whereType<EnSentenceStructureRelationItem>().toList();
    final List<Color> colors = _groupGradient(group);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase,
        borderRadius: BorderRadius.circular(24.wMin),
        border: Border.all(color: AppTheme.cBorderTranslucentThin, width: 1.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.wMin, 16.wMin, 16.wMin, 14.wMin),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56.wMin,
                  height: 56.wMin,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.wMin),
                    gradient: LinearGradient(colors: colors),
                  ),
                  alignment: Alignment.center,
                  child: _buildGroupIcon(code, group.icon),
                ),
                SizedBox(width: 12.wMin),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            group.title?.isNotEmpty == true ? group.title! : _moduleTitle(code),
                            style: TextStyle(
                              fontSize: 28.wMin,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.cTextPrimary,
                            ),
                          ),
                          SizedBox(width: 10.wMin),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
                            decoration: BoxDecoration(
                              color: colors.first.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999.wMin),
                              border: Border.all(
                                color: colors.first.withValues(alpha: 0.28),
                                width: 0.8.wMin,
                              ),
                            ),
                            child: Text(
                              '${items.length} 套',
                              style: TextStyle(
                                fontSize: 14.wMin,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.cTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if ((group.description ?? '').isNotEmpty) ...[
                        SizedBox(height: 6.wMin),
                        Text(
                          group.description ?? '',
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextSecondary.color,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.wMin, 0, 16.wMin, 16.wMin),
            child: Column(
              children: List.generate(items.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 16.wMin),
                  child: _buildRelationItemCard(code, items[index]),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupIcon(String code, String? iconUrl) {
    if ((iconUrl ?? '').isNotEmpty) {
      return SvgPicture.network(
        iconUrl!,
        width: 24.wMin,
        height: 24.wMin,
        placeholderBuilder: (_) => Icon(
          _moduleIcons[code] ?? Icons.auto_awesome_motion_outlined,
          size: 24.wMin,
          color: Colors.white,
        ),
      );
    }
    return Icon(
      _moduleIcons[code] ?? Icons.auto_awesome_motion_outlined,
      size: 24.wMin,
      color: Colors.white,
    );
  }

  List<Color> _groupGradient(EnSentenceStructureRelationGroup group) {
    final Color? from = ColorUtils.parseColor(group.gradientFrom);
    final Color? to = ColorUtils.parseColor(group.gradientTo);
    if (from != null && to != null) return [from, to];
    return _moduleGradients[_normalizedCode(group.code ?? group.type)] ?? const [Color(0xFF38BDF8), Color(0xFF2DD4BF)];
  }

  Widget _buildRelationItemCard(String code, EnSentenceStructureRelationItem item) {
    if (code == 'pattern' || code == 'pyramid') {
      return _buildPatternItemCard(code, item);
    }
    if (code == 'paradigm') {
      return _buildParadigmItemCard(item);
    }
    if (code == 'pair') {
      return _buildPairItemCard(item);
    }
    if (code == 'pair_fork') {
      return _buildPairForkItemCard(item);
    }
    return _buildFallbackItemCard(item);
  }

  Widget _buildPatternItemCard(String code, EnSentenceStructureRelationItem item) {
    final PatternBlueprintEntity? pattern = _patternPayload(item);
    if (pattern == null) return _buildFallbackItemCard(item);
    final SentenceSlotMapEntity slotMap = SentenceSlotMapUtils.buildFromPatternBlueprint(pattern);
    final List<PatternBlueprintSentenceBriefEntity> sentences =
        (pattern.sentenceRealizationList ?? <PatternBlueprintSentenceBriefEntity?>[])
            .whereType<PatternBlueprintSentenceBriefEntity>()
            .toList()
          ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    return _buildItemShell(
      title: _languageText(pattern.name, fallback: item.nid ?? ''),
      description: _languageText(pattern.description, fallback: ''),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((pattern.blueprintScope ?? '').isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 12.wMin),
              child: _buildChip(
                text: pattern.blueprintScope == 'sentence' ? '跨子句组合' : '子句内装配',
                color: const Color(0xFF38BDF8),
              ),
            ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceLayerBase.color,
              border: Border.all(color: AppTheme.cBorderThin.color, width: 0.8.wMin),
            ),
            child: SentenceSlotMapWidget(
              data: slotMap,
            ),
          ),
          if (sentences.isNotEmpty) ...[
            SizedBox(height: 16.wMin),
            Column(
              children: List.generate(sentences.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index == sentences.length - 1 ? 0 : 12.wMin),
                  child: _buildPatternSentenceCard(code, sentences[index]),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatternSentenceCard(String code, PatternBlueprintSentenceBriefEntity sentence) {
    final bool isCurrent = sentence.sentenceId != null && sentence.sentenceId == detils.contentId;
    final bool canJump = !isCurrent && sentence.sentenceId != null;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: isCurrent ? const Color(0xFF34D399).withValues(alpha: 0.34) : AppTheme.cBorderThin.color,
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
                child: Wrap(
                  spacing: 6.wMin,
                  runSpacing: 6.wMin,
                  children: [
                    _buildChip(
                      text: isCurrent ? '本句' : (code == 'pyramid' ? '生长句' : '代表句'),
                      color: isCurrent ? const Color(0xFF10B981) : const Color(0xFF64748B),
                    ),
                    if (sentence.sentenceId != null)
                      _buildChip(
                        text: '句子 ${sentence.sentenceId}',
                        color: AppTheme.cTextTertiary.color,
                      ),
                  ],
                ),
              ),
              if (canJump)
                TapScaleWidget(
                  sclae: 1.01,
                  onTap: () {
                    TagRoutes.toNamed(
                      Routes.EN_SENTENCE_ANALYSIS,
                      arguments: {
                        'contentId': sentence.sentenceId,
                        'layer': 'relations',
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999.wMin),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.26),
                        width: 0.8.wMin,
                      ),
                    ),
                    child: Text(
                      '拓展学习',
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFBAE6FD),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.wMin),
          if ((sentence.segmentList ?? const []).isNotEmpty)
            SentenceSlotExampleWidget(
              segmentList: sentence.segmentList,
              showCopyTags: false,
            )
          else
            Text(
              sentence.content ?? '',
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary,
              ),
            ),
          if ((sentence.definition ?? '').isNotEmpty) ...[
            SizedBox(height: 10.wMin),
            Text(
              sentence.definition ?? '',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParadigmItemCard(EnSentenceStructureRelationItem item) {
    final SentencePatternCompareEntity? data = _paradigmPayload(item);
    if (data == null) return _buildFallbackItemCard(item);
    final List<SentencePatternCompareMemberEntity?>? members =
        (data.memberList?.isNotEmpty ?? false) ? data.memberList : data.members;
    final List<SentencePatternCompareSentenceRealizationSetEntity?>? sets =
        (data.realizationSetList?.isNotEmpty ?? false)
            ? data.realizationSetList
            : ((data.sentenceRealizationSetList?.isNotEmpty ?? false)
                ? data.sentenceRealizationSetList
                : data.sentenceRealizationSets);
    return _buildItemShell(
      title: _languageText(data.name, fallback: item.nid ?? ''),
      description: _languageText(data.description, fallback: ''),
      body: SameGroupCompareSentenceTableWidget(
        memberList: members,
        sentenceRealizationSetList: sets,
        showCopyTags: false,
      ),
    );
  }

  Widget _buildPairItemCard(EnSentenceStructureRelationItem item) {
    final SentencePairEntity? data = _pairPayload(item);
    if (data == null) return _buildFallbackItemCard(item);
    return _buildItemShell(
      title: _languageText(data.name, fallback: item.nid ?? ''),
      description: _languageText(data.description, fallback: ''),
      body: SentencePairingLinkTableWidget(
        pairOrderConstraint: data.orderConstraintEnum,
        realizationSetList: data.realizationSetList,
        fromRealization: data.fromRealization,
        toRealization: data.toRealization,
        showCopyTags: false,
      ),
    );
  }

  Widget _buildPairForkItemCard(EnSentenceStructureRelationItem item) {
    final SentenceForkEntity? data = _pairForkPayload(item);
    if (data == null) return _buildFallbackItemCard(item);
    return _buildItemShell(
      title: _languageText(data.name, fallback: item.nid ?? ''),
      description: _languageText(data.description, fallback: ''),
      body: SentencePairingLinkForkTableWidget(
        realizationSetList: data.realizationSetList,
        showCopyTags: false,
      ),
    );
  }

  Widget _buildFallbackItemCard(EnSentenceStructureRelationItem item) {
    return _buildItemShell(
      title: _languageText(item.name, fallback: item.nid ?? ''),
      description: _languageText(item.description, fallback: ''),
      body: Text(
        '当前关联数据暂不支持该展示类型。',
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextSecondary.color,
        ),
      ),
    );
  }

  Widget _buildItemShell({
    required String title,
    required String description,
    required Widget body,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(color: AppTheme.cBorderThin.color, width: 0.8.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6.wMin,
                  runSpacing: 6.wMin,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 26.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            SizedBox(height: 8.wMin),
            Text(
              description,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
                height: 1.45,
              ),
            ),
          ],
          SizedBox(height: 16.wMin),
          body,
        ],
      ),
    );
  }

  Widget _buildChip({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(color: color.withValues(alpha: 0.26), width: 0.8.wMin),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.wMin,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  PatternBlueprintEntity? _patternPayload(EnSentenceStructureRelationItem item) {
    final Map<String, dynamic>? payload = _payloadMap(item);
    if (payload == null) return null;
    return PatternBlueprintEntity.fromJson(payload);
  }

  SentencePatternCompareEntity? _paradigmPayload(EnSentenceStructureRelationItem item) {
    final Map<String, dynamic>? payload = _payloadMap(item);
    if (payload == null) return null;
    return SentencePatternCompareEntity.fromJson(payload);
  }

  SentencePairEntity? _pairPayload(EnSentenceStructureRelationItem item) {
    final Map<String, dynamic>? payload = _payloadMap(item);
    if (payload == null) return null;
    return SentencePairEntity.fromJson(payload);
  }

  SentenceForkEntity? _pairForkPayload(EnSentenceStructureRelationItem item) {
    final Map<String, dynamic>? payload = _payloadMap(item);
    if (payload == null) return null;
    return SentenceForkEntity.fromJson(payload);
  }

  Map<String, dynamic>? _payloadMap(EnSentenceStructureRelationItem item) {
    if (item.payload is Map<String, dynamic>) return item.payload as Map<String, dynamic>;
    if (item.payload is Map) return Map<String, dynamic>.from(item.payload as Map);
    return null;
  }

  String _languageText(List<LanguageText?>? texts, {required String fallback}) {
    final List<LanguageText> list = LearningLangUtils.getShowLBList(texts);
    String zhText = '';
    String enText = '';
    for (final LanguageText item in list) {
      final String lang = (item.lang ?? '').toLowerCase();
      final String text = (item.text ?? '').trim();
      if (text.isEmpty) continue;
      if (lang == 'zh' && zhText.isEmpty) zhText = text;
      if (lang == 'en' && enText.isEmpty) enText = text;
    }
    if (zhText.isNotEmpty && enText.isNotEmpty) return '$zhText / $enText';
    if (zhText.isNotEmpty) return zhText;
    if (enText.isNotEmpty) return enText;
    final String merged = list.map((item) => item.text ?? '').join(' / ').trim();
    return merged.isNotEmpty ? merged : fallback;
  }

  String _normalizedCode(String? value) {
    final String raw = (value ?? '').trim();
    if (raw.isEmpty) return '';
    final String normalized = raw.toLowerCase().replaceAll('-', '_');
    if (normalized.contains('pattern')) return 'pattern';
    if (normalized.contains('pyramid')) return 'pyramid';
    if (normalized.contains('paradigm')) return 'paradigm';
    if (normalized == 'pair_fork' || normalized.contains('fork')) return 'pair_fork';
    if (normalized.contains('pair')) return 'pair';
    return normalized;
  }

  String _moduleTitle(String code) {
    switch (code) {
      case 'pattern':
        return '句子蓝图';
      case 'pyramid':
        return '句子金字塔';
      case 'paradigm':
        return '句型对照';
      case 'pair':
        return '句间配链';
      case 'pair_fork':
        return '配链分叉';
      default:
        return '关联';
    }
  }
}
