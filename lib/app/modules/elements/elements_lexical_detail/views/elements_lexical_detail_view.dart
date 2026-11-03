import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/elements/common/elements_cards/elements_public_card.dart';
import 'package:langwise/app/modules/elements/common/elements_public_widgets.dart';
import 'package:langwise/app/modules/elements/utils/elements_page_utils.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/widgets.dart'
    hide WordInflectionInfoTagTone, WordInflectionInfoTagWidget;
import 'package:langwise/common/widgets/zhenxie_widgets/word_inflection_info_tag_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../routes/routes.dart';
import '../bindings/elements_lexical_detail_binding.dart';
import '../controllers/elements_lexical_detail_controller.dart';

class ElementsLexicalDetailView extends GetView<ElementsLexicalDetailController> {
  static const Color _synonymPanelBorderColor = Color(0x33F43F5E);
  static const Color _antonymPanelBorderColor = Color(0x333B82F6);
  static const Color _poleAColor = Color(0xFF93C5FD);
  static const Color _poleABorderColor = Color(0x333B82F6);
  static const Color _poleABackgroundColor = Color(0x1F3B82F6);
  static const Color _poleBColor = Color(0xFFFDA4AF);
  static const Color _poleBBorderColor = Color(0x33F43F5E);
  static const Color _poleBBackgroundColor = Color(0x1FF43F5E);

  final String tagText;

  const ElementsLexicalDetailView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return Get.to<T>(
      () => ElementsLexicalDetailView(tagText: tag),
      binding: ElementsLexicalDetailBinding(tagText: tag),
      routeName: Routes.EN_LEXICAL_DETAIL,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: AppTheme.cBgPrimary,
        body: Column(
          children: [
            const BreadcrumbWidget(
              actionWidget: GeneralSettingButtonWidget(),
            ),
            Expanded(
              child: controller.isLoading.value
                  ? const SizedBox.expand()
                  : Padding(
                      padding: EdgeInsets.fromLTRB(
                        90.wMin,
                        0,
                        90.wMin,
                        24.wMin + MediaQuery.of(context).padding.bottom,
                      ),
                      child: _buildBody(),
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBody() {
    final LexicalDetailEntity detail = controller.detailData.value;
    final List<LexicalDetailSetGroup> synonymSets =
        detail.synonymSets?.whereType<LexicalDetailSetGroup>().toList() ?? <LexicalDetailSetGroup>[];
    final List<LexicalDetailSetGroup> antonymSets =
        detail.antonymSets?.whereType<LexicalDetailSetGroup>().toList() ?? <LexicalDetailSetGroup>[];
    final List<LexicalDetailSemanticItem> semanticItems = controller.semanticItems;
    final String headword = (detail.headword ?? '').trim();

    if (headword.isEmpty && synonymSets.isEmpty && antonymSets.isEmpty) {
      return const NotDataWidget(message: '暂无同义反义详情');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(detail),
        SizedBox(height: 16.wMin),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildSynonymPanel(synonymSets),
              ),
              SizedBox(width: 16.wMin),
              Expanded(
                child: _buildAntonymPanel(antonymSets),
              ),
            ],
          ),
        ),
        if (semanticItems.isNotEmpty) ...[
          SizedBox(height: 16.wMin),
          Align(
            alignment: Alignment.center,
            child: _buildSemanticBottomBar(semanticItems),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader(LexicalDetailEntity detail) {
    final String translate = _findLanguageText(detail.translate, 'zh');
    final String description = _findLanguageText(detail.descriptions, 'zh');
    final String pos = (detail.pos ?? '').trim();
    final bool showSecondLine = translate.isNotEmpty || pos.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.wMin),
        color: AppTheme.cSurfaceTranslucentBase.color,
        border: Border.all(
          color: AppTheme.cBorderTranslucentThin.color,
          width: 1.wMin,
        ),
      ),
      padding: EdgeInsets.all(17.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.headword ?? '',
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          if (showSecondLine) ...[
            SizedBox(height: 12.wMin),
            Row(
              children: [
                if (translate.isNotEmpty)
                 Text(
                      translate,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
            
                if (translate.isNotEmpty && pos.isNotEmpty) SizedBox(width: 12.wMin),
                if (pos.isNotEmpty) _buildPosTag(pos),
              ],
            ),
          ],
          if (description.isNotEmpty) ...[
            SizedBox(height: 12.wMin),
            Text(
              description,
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextTertiary.color,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPosTag(String pos) {
    final ConfigController configController = Get.find<ConfigController>();
    final LanguageConfigColorModel? posColor =
        StatusUtils.getConfigColor(configController.colorConfigs.value.pos, pos);
    final String title = (posColor?.title ?? '').trim().isNotEmpty
        ? posColor!.title!.trim()
        : pos;
    final Color baseColor =
        posColor?.color?.borderColor ?? AppTheme.cTextSecondary.color;
    return WordInflectionInfoTagWidget(
      title,
      textColor: baseColor,
      bgColor: baseColor.withValues(alpha: 0.12),
      borderColor: baseColor.withValues(alpha: 0.20),
      fontSize: 16.wMin,
      fontWeight: FontWeight.w500,
    );
  }

  Widget _buildSynonymPanel(List<LexicalDetailSetGroup> sets) {
    return _buildPanelContainer(
      title: '同义',
      borderColor: _synonymPanelBorderColor,
      child: sets.isEmpty
          ? _buildEmptyState('这一义项还没有同义组')
          : SingleChildScrollView(
              child: Column(
                children: [
                  for (int index = 0; index < sets.length; index++) ...[
                    _buildSynonymGroup(sets[index]),
                    if (index < sets.length - 1) SizedBox(height: 12.wMin),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildAntonymPanel(List<LexicalDetailSetGroup> sets) {
    return _buildPanelContainer(
      title: '反义',
      borderColor: _antonymPanelBorderColor,
      child: sets.isEmpty
          ? _buildEmptyState('这一义项还没有反义组')
          : SingleChildScrollView(
              child: Column(
                children: [
                  for (int index = 0; index < sets.length; index++) ...[
                    _buildAntonymGroup(sets[index]),
                    if (index < sets.length - 1) SizedBox(height: 12.wMin),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildPanelContainer({
    required String title,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.wMin),
        color: AppTheme.cSurfaceTranslucentBase.color,
        border: Border.all(
            color: borderColor,
          width: 1.wMin,
        ),
      ),
      padding: EdgeInsets.all(17.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPanelTitle(title),
          SizedBox(height: 12.wMin),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildPanelTitle(String title) {
    return Container(
      padding: EdgeInsets.only(bottom: 15.wMin),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.cBorderTranslucentSubtle.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 28.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextPrimary.color,
        ),
      ),
    );
  }

  Widget _buildSynonymGroup(LexicalDetailSetGroup group) {
    final List<LexicalDetailMember> members = group.members?.whereType<LexicalDetailMember>().toList() ?? <LexicalDetailMember>[];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.wMin),
        color: AppTheme.cSurfaceTranslucentBase.color,
        border: Border.all(
          color: AppTheme.cBorderTranslucentThin.color,
          width: 1.wMin,
        ),
      ),
      padding: EdgeInsets.all(17.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _findLanguageText(group.concept, 'zh'),
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          _buildGroupDescription(group.descriptions),
          if (members.isNotEmpty) ...[
            SizedBox(height: 12.wMin),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12.wMin,
                crossAxisSpacing: 12.wMin,
                childAspectRatio: 1,
              ),
              itemBuilder: (BuildContext context, int index) {
                return _buildMemberCard(members[index]);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAntonymGroup(LexicalDetailSetGroup group) {
    final List<LexicalDetailMember> members = group.members?.whereType<LexicalDetailMember>().toList() ?? <LexicalDetailMember>[];
    final String leftPole = (group.display?.left ?? '').trim();
    final String rightPole = (group.display?.right ?? '').trim();
    final List<LexicalDetailMember> leftMembers = members.where((item) => (item.pole ?? '').trim() == leftPole).toList();
    final List<LexicalDetailMember> rightMembers = members.where((item) => (item.pole ?? '').trim() == rightPole).toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.wMin),
        color: AppTheme.cSurfaceTranslucentBase.color,
        border: Border.all(
          color: AppTheme.cBorderTranslucentThin.color,
          width: 1.wMin,
        ),
      ),
      padding: EdgeInsets.all(17.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _findLanguageText(group.concept, 'zh'),
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          _buildGroupDescription(group.descriptions),
          SizedBox(height: 12.wMin),
          _buildAntonymCompareHeader(
              leftPole: leftPole,
            leftTitle: _findLanguageTextByPole(
              group.poleLabels,
              leftPole,
            ),
              rightPole: rightPole,
            rightTitle: _findLanguageTextByPole(
              group.poleLabels,
              rightPole,
            ),
          ),
          SizedBox(height: 12.wMin),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildAntonymPoleSection(
                    pole: leftPole,
                  members: leftMembers,
                ),
              ),
              SizedBox(width: 12.wMin),
              Expanded(
                child: _buildAntonymPoleSection(
                    pole: rightPole,
                  members: rightMembers,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAntonymPoleSection({
    required String pole,
    required List<LexicalDetailMember> members,
  }) {
    final bool isPoleB = pole == 'b';
    final Color borderColor = isPoleB ? _poleBBorderColor : _poleABorderColor;
    final Color backgroundColor = isPoleB ? _poleBBackgroundColor : _poleABackgroundColor;
    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 1.wMin,
        ),
      ),
      child: members.isEmpty
          ? SizedBox(
              height: 120.wMin,
              child: _buildEmptyState('暂无数据'),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.wMin,
                crossAxisSpacing: 12.wMin,
                childAspectRatio: 1,
              ),
              itemBuilder: (BuildContext context, int index) {
                  final LexicalDetailMember member = members[index];
                  return _buildMemberCard(
                    member,
                    borderColor: isPoleB && member.isCurrent == true ? _poleBColor : null,
                  );
              },
            ),
    );
  }

  Widget _buildAntonymCompareHeader({
    required String leftPole,
    required String leftTitle,
    required String rightPole,
    required String rightTitle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            leftTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
              color: _resolvePoleLabelColor(leftPole),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8.wMin),
          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999.wMin),
            color: AppTheme.cSurfaceTranslucentBase.color,
            border: Border.all(
              color: AppTheme.cBorderTranslucentThin.color,
              width: 1.wMin,
            ),
          ),
          child: Text(
            'VS',
            style: TextStyle(
              fontSize: 10.wMin,
              fontWeight: FontWeight.w900,
              color: AppTheme.cTextPrimary.color.withValues(alpha: 0.55),
              letterSpacing: 1.8.wMin,
            ),
          ),
        ),
        Expanded(
          child: Text(
            rightTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
              color: _resolvePoleLabelColor(rightPole),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupDescription(List<LanguageText?>? descriptions) {
    final String description = _findLanguageText(descriptions, 'zh');
    if (description.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(top: 12.wMin),
      child: Text(
        description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16.wMin,
          color: AppTheme.cTextTertiary.color,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildMemberCard(LexicalDetailMember member, {Color? borderColor}) {
    final KnowledgeCommonEntityList? card = member.card;
    final String badgeText = _resolveMemberBadgeText(member);
    return TapScaleWidget(
      sclae: 1.01,
      onTap: card == null ? null : () => _openMemberCard(card),
      child: ElementsDictStampCard(
        data: card,
        badgeText: badgeText.isEmpty ? null : badgeText,
        titleMaxLines: 1,
        subTitleMaxLines: 1,
        borderColor: borderColor,
      ),
    );
  }

  Color _resolvePoleLabelColor(String pole) {
    if (pole == 'b') return _poleBColor;
    if (pole == 'a') return _poleAColor;
    return AppTheme.cTextPrimary.color.withValues(alpha: 0.8);
  }

  Future<void> _openMemberCard(KnowledgeCommonEntityList card) async {
    final KnowledgeCommonEntityListContent? content = card.content;
    final int? targetContentId = content?.uid ?? card.contentId;
    final String? targetContentType = content?.type ?? card.contentType;
    if (targetContentId == null || (targetContentType ?? '').isEmpty) return;
    await ElementsPageUtils.jumpElementsPage(
      contentId: targetContentId,
      contentType: targetContentType,
      semanticId: content?.semanticId,
      styleId: content?.styleId,
      dialect: content?.dialect,
    );
  }

  Widget _buildSemanticBottomBar(List<LexicalDetailSemanticItem> items) {
    final LexicalDetailSemanticItem? currentItem = controller.findCurrentSemanticItem();
    final ThemeTextStyleEntity? currentThemeText = StyleUtils.getCurrentThemeText(currentItem?.textStyle);
    final Color? filterColor = ColorUtils.parseColor(currentThemeText?.backgroundColor);
    final List<SemanticChipData> chips = items
        .where((item) => item.semanticId != null)
        .map(
          (item) => SemanticChipData(
            id: item.semanticId!,
            pos: _resolvePosText(item),
            text: item.translate ?? '',
            textStyle: item.textStyle,
          ),
        )
        .toList();

    return ElementsSemanticBottomBar(
      items: chips,
      currentId: controller.currentSemanticId.value,
      filterColor: filterColor,
      onTapItem: controller.switchSemantic,
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18.wMin,
          color: AppTheme.cTextTertiary.color,
        ),
      ),
    );
  }

  String _resolveMemberBadgeText(LexicalDetailMember member) {
    if (member.isCurrent == true) return '当前';
    final String chinese = _findLanguageText(member.roleName, 'zh');
    if (chinese.isNotEmpty) return chinese;
    return _findLanguageText(member.roleName, 'en');
  }

  String _resolvePosText(LexicalDetailSemanticItem? item) {
    if (item == null) return '';
    final String english = _findLanguageText(item.posTitle, 'en');
    if (english.isNotEmpty) return english;
    final String chinese = _findLanguageText(item.posTitle, 'zh');
    if (chinese.isNotEmpty) return chinese;
    if ((item.posAddr ?? '').isNotEmpty) return item.posAddr!;
    return item.pos ?? '';
  }

  String _findLanguageTextByPole(
    LexicalDetailPoleLabels? labels,
    String pole,
  ) {
    if (pole == 'a') return _findLanguageText(labels?.a, 'zh');
    if (pole == 'b') return _findLanguageText(labels?.b, 'zh');
    return '';
  }

  String _findLanguageText(List<LanguageText?>? texts, String lang) {
    if (texts == null || texts.isEmpty) return '';
    for (final LanguageText? item in texts) {
      if ((item?.lang ?? '').toLowerCase() == lang.toLowerCase()) {
        return item?.text ?? '';
      }
    }
    return '';
  }
}
