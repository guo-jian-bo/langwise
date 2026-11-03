import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../common/elements_cards/elements_type_card_widget.dart';
import '../../common/elements_public_widgets.dart';
import '../../common/elements_detail_layout.dart';
import '../../dictionary/controllers/dictionary_controller.dart';
import '../../model/elements_detils_data_model.dart';
import '../../../../../common/https/https.dart';
import '../../model/elements_jump_module_type.dart';
import '../controllers/elements_word_detils_controller.dart';

class ElementsWordDetilsContentWidget extends StatefulWidget {
  final ElementsWordDetilsController controller;
  final Widget? memberButton;

  const ElementsWordDetilsContentWidget({
    super.key,
    required this.controller,
    this.memberButton,
  });

  @override
  State<ElementsWordDetilsContentWidget> createState() =>
      _ElementsWordDetilsContentWidgetState();
}

class _ElementsWordDetilsContentWidgetState
    extends State<ElementsWordDetilsContentWidget> {
  final ScrollController _semanticScrollController = ScrollController();
  Timer? _actionRailTimer;
  bool _isActionRailExpanded = true;
  bool _showLevelPanel = false;
  bool _didHandleEntryContext = false;
  CardDetilsEntityStat? _levelStat;
  ElementsCardStar? _levelCardStar;
  int? _levelSemanticId;
  bool _levelDataLoaded = false;

  final Set<String> _selectedPoses = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncSelectedPosWithCurrentSemantic();
      _handleEntryContext();
      _scheduleActionRailCollapse();
    });
  }

  @override
  void didUpdateWidget(covariant ElementsWordDetilsContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncSelectedPosWithCurrentSemantic();
      _handleEntryContext();
    });
  }

  @override
  void dispose() {
    _actionRailTimer?.cancel();
    _semanticScrollController.dispose();
    super.dispose();
  }

  /// 切换释义（调用新接口）
  Future<void> _switchSemantic(int semanticId) async {
    _semanticScrollController.jumpTo(0);
    _collapseActionRail();
    _resetLevelPanelState();
    await widget.controller.switchSemantic(semanticId);
  }

  void _resetLevelPanelState() {
    _levelStat = null;
    _levelCardStar = null;
    _levelSemanticId = null;
    _levelDataLoaded = false;
    _showLevelPanel = false;
  }

  Future<CardContentModuleDetilsEntity?> _requestModuleDetils(
    String moduleType, {
    bool showLoading = true,
  }) async {
    final ConfigController configController = Get.find<ConfigController>();
    final CardWordSemanticDetilsEntity detils = widget.controller.cardDetils.value;
    if ((detils.contentType ?? '').isEmpty || detils.contentId == null) return null;
    if (showLoading) ToastUtils.showLoading();
    try {
      return await ElementsRequest.getContentModuleDetils(
        module: moduleType,
        contentType: detils.contentType!,
        contentId: detils.contentId!,
        semanticId: widget.controller.currentSemanticId.value,
        style: configController.currentStyleForRequest,
        mediaMode: configController.currentMediaMode,
      );
    } finally {
      if (showLoading) ToastUtils.hideLoading();
    }
  }

  Map<String, dynamic> _resolveLevelData(Map<String, dynamic>? rawData) {
    Map<String, dynamic> result = rawData ?? <String, dynamic>{};
    for (int index = 0; index < 2; index++) {
      if (result['stat'] is Map || result['cardStar'] is Map) {
        return result;
      }
      final dynamic nested = result['data'];
      if (nested is Map) {
        result = Map<String, dynamic>.from(nested);
        continue;
      }
      break;
    }
    return result;
  }

  Future<void> _ensureLevelPanelData() async {
    final CardWordDetilsEntityPosListSemantics semantic =
        widget.controller.currentSemantic.value;
    final int semanticId = widget.controller.currentSemanticId.value;
    if (semantic.stat != null || semantic.cardStar != null) {
      _levelSemanticId = semanticId;
      _levelDataLoaded = true;
      return;
    }
    if (_levelSemanticId == semanticId && _levelDataLoaded) {
      return;
    }
    final CardContentModuleDetilsEntity? moduleDetils =
        await _requestModuleDetils(
      ElementsJumpModuleType.VIEW_LEVEL,
      showLoading: false,
    );
    if (!mounted || moduleDetils == null) return;
    final Map<String, dynamic> data = _resolveLevelData(moduleDetils.data);
    setState(() {
      _levelSemanticId = semanticId;
      _levelDataLoaded = true;
      _levelStat = data['stat'] is Map<String, dynamic>
          ? CardDetilsEntityStat.fromJson(data['stat'] as Map<String, dynamic>)
          : null;
      _levelCardStar = data['cardStar'] is Map<String, dynamic>
          ? ElementsCardStar.fromJson(data['cardStar'] as Map<String, dynamic>)
          : null;
    });
  }

  /// 返回经词性筛选后的语义列表
  List<CardWordSemanticItem> _filteredSemanticItems() {
    final List<CardWordSemanticItem> all = widget.controller.semanticItems;
    if (_selectedPoses.isEmpty) return all;
    return all
        .where((CardWordSemanticItem e) => _selectedPoses.contains(e.pos ?? ''))
        .toList();
  }

  /// 返回所有不重复词性列表（用于筛选菜单）
  List<String> _allPosList() {
    final Set<String> seen = <String>{};
    final List<String> result = <String>[];
    for (final CardWordSemanticItem item in widget.controller.semanticItems) {
      final String pos = item.pos ?? '';
      if (pos.isNotEmpty && seen.add(pos)) result.add(pos);
    }
    return result;
  }

  /// 获取词性的本地化显示文字
  String _posDisplayText(String pos) {
    final CardWordSemanticItem? item = widget.controller.semanticItems
        .firstWhereOrNull((CardWordSemanticItem e) => e.pos == pos);
    if (item == null) return pos;
    final List<LanguageText?> titles = item.posTitle ?? <LanguageText?>[];
    final LanguageText? local = LearningLangUtils.getLocalLang(titles);
    if ((local?.text ?? '').isNotEmpty) return local!.text!;
    final LanguageText? learning = LearningLangUtils.getLearningLang(titles);
    if ((learning?.text ?? '').isNotEmpty) return learning!.text!;
    return item.posAddr ?? pos;
  }

  void _syncSelectedPosWithCurrentSemantic() {
    final List<String> allPos = _allPosList();
    if (allPos.isEmpty) {
      _selectedPoses.clear();
      return;
    }
    _selectedPoses.removeWhere((e) => !allPos.contains(e));
  }

  String _posDialogTitle(String pos) {
    final CardWordSemanticItem? item = widget.controller.semanticItems
        .firstWhereOrNull((CardWordSemanticItem e) => e.pos == pos);
    if (item == null) return pos;
    final List<LanguageText?> titles = item.posTitle ?? <LanguageText?>[];
    final String short = titles.isNotEmpty ? (titles[0]?.text ?? '') : '';
    final String long = titles.length > 1 ? (titles[1]?.text ?? '') : '';
    final String title = '$short$long'.trim();
    if (title.isNotEmpty) return title;
    return item.posAddr ?? pos;
  }

  List<String> _selectedPosLabels() {
    return _selectedPoses.map(_posDisplayText).toList();
  }

  Future<void> _applySelectedPoses(Set<String> values) async {
    final List<String> allPos = _allPosList();
    final Set<String> normalized = values.where(allPos.contains).toSet();
    if (normalized.length == allPos.length) {
      normalized.clear();
    }
    if (_selectedPoses.length == normalized.length &&
        _selectedPoses.containsAll(normalized)) {
      return;
    }
    setState(() {
      _selectedPoses
        ..clear()
        ..addAll(normalized);
    });
    if (_selectedPoses.isEmpty) return;
    final int currentId = widget.controller.currentSemanticId.value;
    final CardWordSemanticItem? currentSemanticItem = widget.controller.semanticItems
        .firstWhereOrNull((CardWordSemanticItem e) => e.semanticId == currentId);
    if (_selectedPoses.contains(currentSemanticItem?.pos ?? '')) return;
    final CardWordSemanticItem? firstItem = widget.controller.semanticItems
        .firstWhereOrNull((CardWordSemanticItem e) => _selectedPoses.contains(e.pos ?? ''));
    if (firstItem?.semanticId == null) return;
    await _switchSemantic(firstItem!.semanticId!);
  }

  Future<void> _showPosSelectorDialog(BuildContext anchorContext) async {
    final List<String> allPos = _allPosList();
    if (allPos.length <= 1) return;
    final int currentId = widget.controller.currentSemanticId.value;
    final CardWordSemanticItem? currentSemanticItem = widget.controller.semanticItems
        .firstWhereOrNull((CardWordSemanticItem e) => e.semanticId == currentId);
    final ThemeTextStyleEntity? currentThemeText =
        StyleUtils.getCurrentThemeText(currentSemanticItem?.textStyle);
    final Map<String, FilterConditionsData> result =
        await FilterStripUtils.showCondition(
              context: anchorContext,
              conditionsData: {
                'pos': FilterConditionsData(
                  title: '词性',
                  isSingle: false,
                  color: ColorUtils.parseColor(currentThemeText?.backgroundColor),
                  conditions: allPos.map((String value) {
                    return FilterConditionsItem(
                      name: _posDialogTitle(value),
                      value: value,
                      selected: _selectedPoses.contains(value),
                    );
                  }).toList(),
                ),
              },
              scrollConditionKey: 'pos',
            ) ??
            <String, FilterConditionsData>{};
    if (!mounted || result.isEmpty) return;
    final Set<String> selectedValues = result['pos']?.conditions
            .where((e) => e.selected)
            .map((e) => e.value?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toSet() ??
        <String>{};
    await _applySelectedPoses(selectedValues);
  }

  Future<void> _removeSelectedPos(String label) async {
    String? value;
    for (final item in _selectedPoses) {
      if (_posDisplayText(item) == label) {
        value = item;
        break;
      }
    }
    if (value == null) return;
    final Set<String> next = Set<String>.from(_selectedPoses)..remove(value);
    await _applySelectedPoses(next);
  }

  void _handleEntryContext() {
    if (_didHandleEntryContext) return;
    final String? module = widget.controller.cardDetils.value.module;
    if ((module ?? '').isEmpty) return;
    if (!_canHandleModule(module!)) return;
    _didHandleEntryContext = true;
    if (_shouldSkipAutoOpen(module)) {
      return;
    }
    Future.delayed(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      _openModuleByType(module);
    });
  }

  bool _shouldSkipAutoOpen(String module) {
    return module == ElementsJumpModuleType.PRONUNCIATION ||
        module == ElementsJumpModuleType.PRONUNCIATION_MEANING ||
        module == ElementsJumpModuleType.SEMANTICS ||
        module == ElementsJumpModuleType.LANGUAGE ||
        module == ElementsJumpModuleType.MEMORIZE_WORD;
  }

  bool _canHandleModule(String module) {
    if (module == ElementsJumpModuleType.LANGUAGE ||
        module == ElementsJumpModuleType.VIEW_LEVEL ||
        module == ElementsJumpModuleType.MEMORIZE_WORD) {
      return true;
    }
    return widget.controller.moduleItems.any(
      (CardWordSemanticModuleItem item) => item.module == module,
    );
  }

  void _expandActionRail() {
    _actionRailTimer?.cancel();
    if (!_isActionRailExpanded || _showLevelPanel) {
      setState(() {
        _isActionRailExpanded = true;
        _showLevelPanel = false;
      });
    }
  }

  void _expandLevelPanel() {
    _actionRailTimer?.cancel();
    if (!_isActionRailExpanded || !_showLevelPanel) {
      setState(() {
        _isActionRailExpanded = true;
        _showLevelPanel = true;
      });
    }
  }

  void _collapseActionRail() {
    _actionRailTimer?.cancel();
    if (_isActionRailExpanded || _showLevelPanel) {
      setState(() {
        _isActionRailExpanded = false;
        _showLevelPanel = false;
      });
    }
  }

  void _scheduleActionRailCollapse(
      [Duration delay = const Duration(seconds: 3)]) {
    _actionRailTimer?.cancel();
    _actionRailTimer = Timer(delay, () {
      if (!mounted) return;
      _collapseActionRail();
    });
  }


  Widget _buildMemoryDialogHeader(
      CardWordDetilsEntityPosListSemantics? semantic) {
    if (semantic == null) {
      return const SizedBox.shrink();
    }

    final ConfigController configController = Get.find<ConfigController>();
    final List<LanguageText> glossText =
        LearningLangUtils.getShowLBList(semantic.gloss);
    final List<LanguageText> descriptionsText =
        LearningLangUtils.getShowLBList(semantic.descriptions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(glossText.length, (int index) {
            if (index == 0) {
              return Row(
                children: [
                  Flexible(
                    child: Text(
                      glossText[index].text ?? '',
                      style: TextStyle(
                        fontSize: 36.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextPrimary,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: semantic.difficulty != null,
                    child: Container(
                      margin: EdgeInsets.only(left: 12.wMin),
                      child: StatusTagDifficultyWidget(
                        difficulty: semantic.difficulty,
                        language:
                            configController.userSetting.value.learningLang,
                        fontSize: 22.wMin,
                      ),
                    ),
                  ),
                ],
              );
            }
            return Padding(
              padding: EdgeInsets.only(top: 8.wMin),
              child: Text(
                glossText[index].text ?? '',
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary,
                ),
              ),
            );
          }),
        ),
        if (descriptionsText.isNotEmpty) ...[
          SizedBox(height: 24.wMin),
          ElemenetsTitleH1Widget(titles: descriptionsText),
        ],
      ],
    );
  }


  List<IconDropdownCheckData<String>> _buildLanguageItems(
    List<UserPreferenceDefinitionDisplayModeOption> dropdownMenu,
  ) {
    return dropdownMenu
        .where((UserPreferenceDefinitionDisplayModeOption e) =>
            e.code != LangPreference.none.code)
        .map((UserPreferenceDefinitionDisplayModeOption e) =>
            IconDropdownCheckData<String>(
              value: e.code ?? '',
              title: e.title ?? '',
            ))
        .toList();
  }

  _FixedActionItem _buildLanguageActionItem() {
    return _FixedActionItem(
      type: ElementsJumpModuleType.LANGUAGE,
      title: '双语对照',
      svg: 'assets/svg/public/icon_translation.svg',
      color: AppTheme.cBgBrand,
      borderColor: AppTheme.cBgBrand,
      backgroundColor: AppTheme.cBgBrand.color.withValues(alpha: 0.2),
    );
  }

  Widget _buildStyleActionButton() {
    final ConfigController controller = Get.find<ConfigController>();
    return Obx(() {
      final ResourceTypeEnum resource = controller.currentShowResource.value;
      final String styleName =
          controller.getCurrentStyleName(controller.currentShowStyleCode.value);
      final _FixedActionItem item = _FixedActionItem(
        type: ElementsJumpModuleType.LANGUAGE,
        title: '风格',
        svg: resource.svg,
        color: const Color(0xFF00D492),
        borderColor: const Color(0xFF00D492),
        backgroundColor: const Color(0xFF00D492).withValues(alpha: 0.2),
      );
      return _FixedActionButton(
        item: item,
        expanded: _isActionRailExpanded,
        title: styleName.isNotEmpty ? styleName : item.title,
        onTap: () async {
          final CardLearningStyleDialogReslut? reslut =
              await CardLearningStyleDialog.show(context: context);
          if (reslut == null) return;
          controller.changeCurrentShowResource(reslut.resource);
          controller.changeCurrentStyleCode(reslut.style);
          await widget.controller.reloadForStyleChange();
        },
      );
    });
  }

  Widget _buildLanguageActionButton() {
    final ConfigController configController = Get.find<ConfigController>();
    final _FixedActionItem actionItem = _buildLanguageActionItem();
    return Obx(() {
      final List<UserPreferenceDefinitionDisplayModeOption>? dropdownMenu =
          configController.userSetting.value.expandDropdownMenu;
      final LangPreference? lang = configController.userSetting.value.expandLang;
      if (lang == LangPreference.none) {
        Future.microtask(() {
          configController.setLearLangSetting(
            LangPreference.bilingual.code,
            LearModePreference.extension,
          );
        });
      }
      if (dropdownMenu == null || dropdownMenu.isEmpty) {
        return _FixedActionButton(
          item: actionItem,
          expanded: _isActionRailExpanded,
        );
      }
      final List<IconDropdownCheckData<String>> items =
          _buildLanguageItems(dropdownMenu);
      int selectIndex = items.indexWhere(
          (IconDropdownCheckData<String> e) => e.value == lang?.code);
      if (selectIndex < 0) selectIndex = 0;
      return IconDropdownCheckWidget(
        items: items,
        width: 240.wMin,
        selectIndex: selectIndex,
        sclae: 1.03,
        fontSize: 24.wMin,
        itemHeight: 70.wMin,
        left: -168.wMin,
        alignRight: true,
        onShowMenu: () {
          _actionRailTimer?.cancel();
          if (_showLevelPanel) setState(() => _showLevelPanel = false);
        },
        onHideMenu: () => _scheduleActionRailCollapse(),
        child: _FixedActionButton(
          item: actionItem,
          expanded: _isActionRailExpanded,
          title: items[selectIndex].title,
        ),
        onTap: (IconDropdownCheckData<dynamic> data, int index) {
          configController.setLearLangSetting(
            data.value as String,
            LearModePreference.extension,
          );
        },
      );
    });
  }

  Future<void> _handleMemoryAction() async {
    final CardWordSemanticDetilsEntity detils = widget.controller.cardDetils.value;
    final CardWordDetilsEntityPosListSemantics semantic =
        widget.controller.currentSemantic.value;
    final int semanticId = widget.controller.currentSemanticId.value;
    final SimpleDictionaryAddCardParm parameter = SimpleDictionaryAddCardParm(
      uid: detils.contentId,
      type: detils.contentType,
      semanticId: semanticId > 0 ? semanticId : null,
    );

    final bool? res = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: AppTheme.cBlackAlpha50,
      builder: (BuildContext dialogContext) {
        return _WordDetailsModuleDialog(
          title: '记单词',
          backgroundColor: AppTheme.cMemoryPrimary,
          imageUrl: semantic.imageUrl ?? widget.controller.leftCardImage.value,
          body: _buildMemoryDialogHeader(semantic),
          footer: _buildMemoryDialogFooter(dialogContext, parameter),
        );
      },
    );
    if (res != true) {
      return;
    }

    final DictionaryController? dictionaryController =
        DictionaryController.registered;
    if (dictionaryController != null) {
      await dictionaryController.refreshList(showLoading: false);
    }
  }

  Widget _buildMemoryDialogFooter(
      BuildContext dialogContext,
      SimpleDictionaryAddCardParm parameter) {

    return Obx(() {
      final bool isFavorited = parameter.semanticId == null
          ? false
          : widget.controller.isCurrentSemanticFavorited();
      final Color buttonColor = isFavorited
          ? AppTheme.cSurfaceQuaternary
          : AppTheme.cMemoryPrimary;
      final Color textColor =
          isFavorited ? AppTheme.cTextSecondary : AppTheme.cStaticWhite;

      return Align(
        alignment: Alignment.centerRight,
        child: TapScaleWidget(
          onTap: isFavorited || parameter.semanticId == null
              ? null
              : () async {
                  final bool resp = await SimpleDictionaryDialog.addKnowledgeCard(
                    context: dialogContext,
                    parameter: [parameter],
                  );
                  if (!resp) {
                    return;
                  }
                  widget.controller.setCurrentSemanticFavorited(true);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
          sclae: isFavorited ? 1 : 1.02,
          child: Container(
            width: 220.wMin,
            height: 72.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(999.wMin),
            ),
            child: Text(
              isFavorited ? '已记忆' : '记单词',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLevelPanel() {
    final CardWordDetilsEntityPosListSemantics semantic =
        widget.controller.currentSemantic.value;
    final bool useCachedLevel =
        _levelSemanticId == widget.controller.currentSemanticId.value;
    final CardDetilsEntityStat stat = semantic.stat ??
        (useCachedLevel ? _levelStat : null) ??
        CardDetilsEntityStat(
          listen: 0,
          listenPct: 0,
          speak: 0,
          speakPct: 0,
          read: 0,
          readPct: 0,
          write: 0,
          writePct: 0,
        );
    final ElementsCardStar cardStar = semantic.cardStar ??
        (useCachedLevel ? _levelCardStar : null) ??
        ElementsCardStar(
          star: 0,
          title: 'Lv.0',
        );
    final Color starColor = cardStar.color != null
        ? Color(int.tryParse(cardStar.color!.replaceFirst('#', '0xff')) ??
            0xffF59E0B)
        : const Color(0xffF59E0B);

    return Container(
      key: const ValueKey<String>('level_panel'),
      width: 430.wMin,
      margin: EdgeInsets.only(right: 16.wMin),
      padding: EdgeInsets.symmetric(horizontal: 22.wMin, vertical: 22.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceSecondary,
        borderRadius: BorderRadius.circular(24.wMin),
        border: Border.all(color: AppTheme.cBorderSecondary, width: 1.wMin),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.cBlackAlpha10,
            blurRadius: 20.wMin,
            offset: Offset(0, 8.wMin),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '查看等级',
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w700,
              color: AppTheme.cTextPrimary,
            ),
          ),
          SizedBox(height: 18.wMin),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 16.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cBgSecondary,
              borderRadius: BorderRadius.circular(20.wMin),
            ),
            child: Row(
              children: <Widget>[
                StarRatingWidget(
                  litStars: cardStar.star ?? 0,
                  starSize: 16,
                  litStarColor: starColor,
                  unlitStarColor: AppTheme.cBorderSecondary,
                  spacing: 4,
                ),
                SizedBox(width: 14.wMin),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 8.wMin),
                  decoration: BoxDecoration(
                    color: starColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999.wMin),
                  ),
                  child: Text(
                    cardStar.title?.isNotEmpty ?? false
                        ? cardStar.title!
                        : 'Lv.${cardStar.star ?? 0}',
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w700,
                      color: starColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.wMin),
          _buildLevelProgressItem(
            title: '听',
            type: LSRWEnum.listening,
            percent: stat.listenPct,
            value: stat.listen,
            exp: stat.listenExp,
          ),
          SizedBox(height: 12.wMin),
          _buildLevelProgressItem(
            title: '说',
            type: LSRWEnum.speaking,
            percent: stat.speakPct,
            value: stat.speak,
            exp: stat.speakExp,
          ),
          SizedBox(height: 12.wMin),
          _buildLevelProgressItem(
            title: '读',
            type: LSRWEnum.reading,
            percent: stat.readPct,
            value: stat.read,
            exp: stat.readExp,
          ),
          SizedBox(height: 12.wMin),
          _buildLevelProgressItem(
            title: '写',
            type: LSRWEnum.writing,
            percent: stat.writePct,
            value: stat.write,
            exp: stat.writeExp,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressItem({
    required String title,
    required String type,
    required double? percent,
    required int? value,
    required int? exp,
  }) {
    final LSRWStatusColor color = StatusUtils.getLSRWStatusColor(type);
    final double progress = percent != null
        ? (percent / 100).clamp(0, 1).toDouble()
        : (value != null ? (value / 5).clamp(0, 1).toDouble() : 0.0);

    return Row(
      children: <Widget>[
        Container(
          width: 52.wMin,
          height: 52.wMin,
          decoration: BoxDecoration(
            color: color.bg1.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16.wMin),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w700,
              color: color.primary,
            ),
          ),
        ),
        SizedBox(width: 14.wMin),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999.wMin),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14.wMin,
              backgroundColor: color.bg1.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation<Color>(color.bg2),
            ),
          ),
        ),
        SizedBox(width: 14.wMin),
        SizedBox(
          width: 72.wMin,
          child: Text(
            '+${exp ?? 0}',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 22.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextSecondary,
            ),
          ),
        ),
      ],
    );
  }


  /// 按需加载模块内容（调新接口）
  Future<void> _openModuleByType(String moduleType) async {
    if (moduleType == ElementsJumpModuleType.MEMORIZE_WORD) {
      await _handleMemoryAction();
      return;
    }
    if (moduleType == ElementsJumpModuleType.VIEW_LEVEL) {
      final bool nextVisible = !_showLevelPanel;
      if (nextVisible) {
        _expandLevelPanel();
        await _ensureLevelPanelData();
      } else {
        _collapseActionRail();
      }
      return;
    }
    if (!_canHandleModule(moduleType)) return;

    final CardWordSemanticDetilsEntity detils = widget.controller.cardDetils.value;
    final CardContentModuleDetilsEntity? moduleDetils =
        await _requestModuleDetils(moduleType);
    if (moduleDetils == null) return;
    if (!mounted) return;

    final Map<String, dynamic> data = moduleDetils.data ?? <String, dynamic>{};
    Widget? body;
    String title = '';
    Color backgroundColor = AppTheme.cBgSecondary;
    String? imageUrl;

    if (moduleType == ElementsJumpModuleType.GRAMMAR_FEATURES) {
      final List<dynamic>? raw =
          (data['grammatical'] ?? data['feature']) as List<dynamic>?;
      if (raw == null || raw.isEmpty) return;
      final List<CardWordDetilsEntityPosListGrammatical> grammatical = raw
          .map((dynamic e) => CardWordDetilsEntityPosListGrammatical.fromJson(
              e as Map<String, dynamic>))
          .toList();
      imageUrl = grammatical
              .firstWhereOrNull((CardWordDetilsEntityPosListGrammatical e) =>
                  e.inflections?.pluralInfo?.imageUrl?.isNotEmpty == true)
              ?.inflections
              ?.pluralInfo
              ?.imageUrl;
      title = '语法特性';
      backgroundColor = const Color(0xff06B6D4);
      body = ElementsGrammarCharacteristicsModuleWidget(
        grammatical: grammatical,
        pos: _getPosForCurrentSemantic(),
        word: detils.content,
        colorConfig: Get.find<ConfigController>().colorConfigs.value.pos,
      );
    } else if (moduleType == ElementsJumpModuleType.ETYMOLOGY) {
      final CardWordDetilsEntityPosListMorphology morphology =
          CardWordDetilsEntityPosListMorphology.fromJson(data);
      imageUrl = morphology.imageUrl;
      title = '词根词缀';
      backgroundColor = const Color(0xff22C55E);
      body = ElementsEtymologicalAnalysisModuleWidget(
        morphology: morphology,
        colorConfig: Get.find<ConfigController>().colorConfigs.value.pos,
        onTap: (CardWordDetilsEntityPosListMorphologyMorphemes? morpheme) {
            final int currentSemanticId = widget.controller.currentSemanticId.value;
          widget.controller.toMorphemeDetils(
              context,
              morpheme,
              _getPosForCurrentSemantic(),
              currentSemanticId > 0 ? currentSemanticId : null,
            );
        },
      );
    } else if (moduleType == ElementsJumpModuleType.BACKSTORY) {
      final CardWordDetilsEntityPosListStory story =
          CardWordDetilsEntityPosListStory.fromJson(data);
      imageUrl = story.imageUrl;
      title = '来源故事';
      backgroundColor = const Color(0xffF43F5E);
      body = _buildStoryDialogBody(story);
    } else if (moduleType == ElementsJumpModuleType.MNEMONICS) {
      final CardWordDetilsEntityPosListMemory memory =
          CardWordDetilsEntityPosListMemory.fromJson(data);
      imageUrl = memory.imageUrl;
      title = '记忆提示';
      backgroundColor = const Color(0xffF97316);
      body = _buildMemoryDialogBody(memory);
    } else if (moduleType == ElementsJumpModuleType.PHRASES_IDIOMS) {
      final List<dynamic>? phrasesRaw = data['phrases'] as List<dynamic>?;
      final List<ElementsCardEntityDatas> phrases = (phrasesRaw ?? <dynamic>[])
          .map((dynamic e) =>
              ElementsCardEntityDatas.fromJson(e as Map<String, dynamic>))
          .toList();
      final List<dynamic>? idiomRaw = data['phraseIdioms'] as List<dynamic>?;
      final List<ElementsCardEntityDatas> idioms = (idiomRaw ?? <dynamic>[])
          .map((dynamic e) =>
              ElementsCardEntityDatas.fromJson(e as Map<String, dynamic>))
          .toList();
      if (phrases.isEmpty && idioms.isEmpty) return;
      title = '短语习语';
      backgroundColor = const Color(0xffEC4899);
      body = _buildPhraseDialogBody(phrases, idioms);
    }

    if (body == null) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: AppTheme.cBlackAlpha50,
      builder: (dialogContext) {
        return _WordDetailsModuleDialog(
          title: title,
          backgroundColor: backgroundColor,
          imageUrl: imageUrl,
          body: body!,
        );
      },
    );

    if (!mounted) return;
    _scheduleActionRailCollapse();
  }

  Widget _buildStoryDialogBody(CardWordDetilsEntityPosListStory? story) {
    final List<LanguageText> descriptions =
        LearningLangUtils.getShowLBList(story?.descriptions);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   '来源故事',
        //   style: TextStyle(
        //     fontSize: 40.wMin,
        //     fontWeight: FontWeight.w700,
        //     color: AppTheme.cTextPrimary,
        //   ),
        // ),
        // SizedBox(height: 24.wMin),
        ...List<Widget>.generate(descriptions.length, (int index) {
          if (index == 0) {
            return Text(
              descriptions[index].text ?? '',
              style: TextStyle(
                fontSize: 32.wMin,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: AppTheme.cTextPrimary,
                height: 1.5,
              ),
            );
          }
          return Container(
            margin: EdgeInsets.only(top: 20.wMin),
            padding: EdgeInsets.all(20.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cStaticWhite.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(16.wMin),
              border: Border(
                  left: BorderSide(
                      width: 4.wMin, color: const Color(0xffFB7185))),
            ),
            child: Text(
              descriptions[index].text ?? '',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w400,
                color: const Color(0xffBE123C),
                height: 1.7,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMemoryDialogBody(CardWordDetilsEntityPosListMemory? memory) {
    final List<LanguageText> descriptions =
        LearningLangUtils.getShowLBList(memory?.descriptions);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cFeedbackWarningBackground,
            borderRadius: BorderRadius.circular(999.wMin),
          ),
          child: Text(
            '学习小帖士',
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: const Color(0xffFB923C),
            ),
          ),
        ),
        SizedBox(height: 24.wMin),
        ...List<Widget>.generate(descriptions.length, (int index) {
          if (index == 0) {
            return Text(
              descriptions[index].text ?? '',
              style: TextStyle(
                fontSize: 32.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary,
                height: 1.6,
              ),
            );
          }
          return Container(
            margin: EdgeInsets.only(top: 20.wMin),
            padding: EdgeInsets.all(20.wMin),
            decoration: BoxDecoration(
              // color: AppTheme.cStaticWhite.withValues(alpha: 0.8),
              // borderRadius: BorderRadius.circular(16.wMin),
              border: Border(
                  left: BorderSide(
                      width: 4.wMin, color: const Color(0xffFB923C))),
            ),
            child: Text(
              descriptions[index].text ?? '',
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cFeedbackDefaultText,
                height: 1.7,
              ),
            ),
          );
        }),
      ],
    );
  }

  String _getPosForCurrentSemantic() {
    final int id = widget.controller.currentSemanticId.value;
    final CardWordSemanticItem? item = widget.controller.semanticItems
        .firstWhereOrNull((CardWordSemanticItem e) => e.semanticId == id);
    return item?.pos ?? '';
  }

  Widget _buildPhraseDialogBody(
      List<ElementsCardEntityDatas> phrases,
      List<ElementsCardEntityDatas> idioms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildPhraseSection('短语组',
            phrases.cast<ElementsCardEntityDatas?>().toList()),
        Visibility(
          visible: phrases.isNotEmpty && idioms.isNotEmpty,
          child: SizedBox(height: 32.wMin),
        ),
        _buildPhraseSection('习语组',
            idioms.cast<ElementsCardEntityDatas?>().toList()),
      ],
    );
  }

  Widget _buildPhraseSection(
      String title, List<ElementsCardEntityDatas?> datas) {
    final List<ElementsCardEntityDatas> validDatas =
        datas.whereType<ElementsCardEntityDatas>().toList();
    if (validDatas.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 32.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary,
          ),
        ),
        SizedBox(height: 20.wMin),
        Wrap(
          spacing: 10.wMin,
          runSpacing: 24.wMin,
          children: List<Widget>.generate(validDatas.length, (int index) {
            return ElementsTypeCardWidget(
              data: ElementsDetilsDataModel(
                type: ElementsCardType.fromRawValue(
                    validDatas[index].contentType ?? ''),
                data: validDatas[index],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLeftPanel(CardWordDetilsEntityPosListSemantics semantic) {
    final double leftWidth = 560.wMin;
    return ElementsDetilsLeftPanel(
      width: leftWidth,
      mediaBuilder: (double size) {
        return IndexedStack(
          index: widget.controller.semanticItems
              .indexWhere((e) => e.semanticId == semantic.uid),
          children: widget.controller.semanticItems.map((item) {
            final bool isActive = item.semanticId == semantic.uid;
            final CardWordSemanticDetilsEntity? detils =
                widget.controller.cachedDetils[item.semanticId];
            final CardWordDetilsEntityPosListSemantics? s = detils?.semantic;
            return _WordImagePanel(
              size: size,
              imageUrl: widget.controller.leftCardImage.value,
              relationVideo: s?.video,
              pronunciations: s?.pronunciations,
              semanticPlaybackKey:
                  '${widget.controller.cardDetils.value.contentId ?? 0}_${item.semanticId}',
              isActive: isActive,
            );
          }).toList(),
        );
      },
      pronunciation: ElementsPronunciationModuleWidget(
        pronunciations: semantic.pronunciations,
        contentType: widget.controller.cardDetils.value.contentType,
        contentId: widget.controller.cardDetils.value.contentId,
        content: widget.controller.cardDetils.value.content,
      ),
    );
  }

  Widget _buildSemanticContent(CardWordDetilsEntityPosListSemantics semantic) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification n) {
        if (n is ScrollUpdateNotification && (n.scrollDelta ?? 0).abs() > 0) {
          _collapseActionRail();
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _semanticScrollController,
        padding: EdgeInsets.only(bottom: 220.wMin),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Container(
            key: ValueKey<int>(widget.controller.currentSemanticId.value),
            child: ElementsInterpretationModuleItemWidget(
              semantics: <CardWordDetilsEntityPosListSemantics?>[semantic],
              index: 0,
              excludeContentId: widget.controller.cardDetils.value.contentId,
              excludeContentType: widget.controller.cardDetils.value.contentType,
              onVisibilityChanged: (int index, double visibleFraction) {
                if (visibleFraction > 0.2 &&
                    (semantic.imageUrl ?? '').isNotEmpty) {
                  widget.controller.updateLeftImage(semantic.imageUrl!);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(List<CardWordSemanticItem> filteredItems) {
    final List<String> allPos = _allPosList();
    final int currentSemanticId = widget.controller.currentSemanticId.value;
    final CardWordSemanticItem? currentSemanticItem = widget.controller.semanticItems
        .firstWhereOrNull((CardWordSemanticItem e) => e.semanticId == currentSemanticId);
    final ThemeTextStyleEntity? currentThemeText =
        StyleUtils.getCurrentThemeText(currentSemanticItem?.textStyle);
    final Color? filterColor = ColorUtils.parseColor(currentThemeText?.backgroundColor);
    final List<SemanticChipData> chips = filteredItems
        .where((e) => e.semanticId != null)
        .map((e) => SemanticChipData(
              id: e.semanticId!,
              pos: (e.posTitle?.isNotEmpty ?? false) ? e.posTitle?.first?.text : e.posAddr,
              text: e.translate ?? '',
              textStyle: e.textStyle,
            ))
        .toList();

    final bool isFiltered =
        _selectedPoses.isNotEmpty && _selectedPoses.length < allPos.length;
    final List<String> activeFilterLabels =
        isFiltered ? _selectedPosLabels() : const <String>[];

    return ElementsSemanticBottomBar(
      items: chips,
      currentId: currentSemanticId,
      showFilter: allPos.length > 1,
      isFiltered: isFiltered,
      filterColor: filterColor,
      activeFilterLabels: activeFilterLabels,
      onTapFilter: (BuildContext ctx) {
        _showPosSelectorDialog(ctx);
      },
      onRemoveFilter: _removeSelectedPos,
      onResetFilters: () => _applySelectedPoses(<String>{}),
      onTapItem: (int id) => _switchSemantic(id),
    );
  }

  Widget _buildActionRail() {
    final List<CardWordSemanticModuleItem> items = widget.controller.moduleItems
        .where((CardWordSemanticModuleItem item) {
      final String moduleType = item.module ?? '';
      return moduleType.isNotEmpty &&
          moduleType != ElementsJumpModuleType.LANGUAGE &&
          moduleType != ElementsJumpModuleType.PRONUNCIATION_MEANING;
    }).toList();

    return MouseRegion(
      onEnter: (_) => _expandActionRail(),
      onExit: (_) => _scheduleActionRailCollapse(),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          _expandActionRail();
          _scheduleActionRailCollapse();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _showLevelPanel
                  ? _buildLevelPanel()
                  : const SizedBox.shrink(),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 16.wMin),
                  child: _buildStyleActionButton(),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 16.wMin),
                  child: _buildLanguageActionButton(),
                ),
                ...List<Widget>.generate(items.length, (int index) {
                  final CardWordSemanticModuleItem moduleItem = items[index];
                  final String moduleType = moduleItem.module ?? '';
                  final bool isMemoryModule =
                      moduleType == ElementsJumpModuleType.MEMORIZE_WORD;
                  final bool isFavorited = isMemoryModule &&
                      widget.controller.isCurrentSemanticFavorited();

                  return Container(
                    margin: EdgeInsets.only(bottom: 16.wMin),
                    child: ElementsSemanticModuleActionButton(
                      moduleItem: moduleItem,
                      expanded: _isActionRailExpanded,
                      titleOverride: isFavorited ? '已记忆' : null,
                      onTap:
                          isFavorited ? null : () => _openModuleByType(moduleType),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.controller.currentSemantic.value.uid == null &&
          widget.controller.semanticItems.isEmpty) {
        return Container();
      }
      _syncSelectedPosWithCurrentSemantic();
      final CardWordDetilsEntityPosListSemantics semantic =
          widget.controller.currentSemantic.value;
      final List<CardWordSemanticItem> filteredItems = _filteredSemanticItems();

      return ElementsDetailLayout(
        leftPanel: _buildLeftPanel(semantic),
        rightContent: _buildSemanticContent(semantic),
        title: Text(
          "·释义",
          style: TextStyle(
            fontSize: 22.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextPrimary.withValues(alpha: 0.8),
          ),
        ),
        bottomBar: _buildBottomBar(filteredItems),
        rightRail: _buildActionRail(),
      );
    });
  }
}

class _WordImagePanel extends StatelessWidget {
  final double? size;
  final String? imageUrl;
  final EnKnowledgeEntityRelationVideo? relationVideo;
  final List<PronunciationsEntity?>? pronunciations;
  final String semanticPlaybackKey;
  final bool isActive;

  const _WordImagePanel({
    this.size,
    required this.imageUrl,
    this.relationVideo,
    this.pronunciations,
    required this.semanticPlaybackKey,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElementsSemanticVideoCardWidget(
      imageUrl: imageUrl,
      relationVideo: relationVideo,
      pronunciations: pronunciations,
      semanticPlaybackKey: semanticPlaybackKey,
      isActive: isActive,
      size: size,
      showPronunciationOverlay: false,
    );
  }
}

class _FixedActionItem {
  final String type;
  final String title;
  final String svg;
  final Color color;
  final Color? borderColor;
  final Color? backgroundColor;

  const _FixedActionItem({
    required this.type,
    required this.title,
    required this.svg,
    required this.color,
    this.borderColor,
    this.backgroundColor,
  });
}

class _FixedActionButton extends StatelessWidget {
  final _FixedActionItem item;
  final bool expanded;
  final String? title;
  final void Function()? onTap;

  const _FixedActionButton({
    required this.item,
    required this.expanded,
    this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = item.borderColor ?? item.color;
    final Color backgroundColor = item.backgroundColor ?? item.color.withValues(alpha: 0.18);

    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.03,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999.wMin),
        child: PlatformBackdropFilterWidget(
          sigmaX: 10.wMin,
          sigmaY: 10.wMin,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: expanded ? 180.wMin : 72.wMin,
            height: 72.wMin,
            padding: EdgeInsets.symmetric(horizontal: expanded ? 18.wMin : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999.wMin),
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 2.wMin),
            ),
            child: Row(
              mainAxisAlignment:
                  expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  item.svg,
                  width: 30.wMin,
                  height: 30.wMin,
                  colorFilter: ColorFilter.mode(
                    AppTheme.cTextPrimary,
                    BlendMode.srcIn,
                  ),
                ),
                if (expanded) ...<Widget>[
                  SizedBox(width: 10.wMin),
                  Expanded(
                    child: Text(
                      title ?? item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WordDetailsModuleDialog extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final String? imageUrl;
  final Widget body;
  final Widget? footer;

  const _WordDetailsModuleDialog({
    required this.title,
    required this.backgroundColor,
    required this.body,
    this.imageUrl,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return ElementsDetailsModuleDialog(
      title: title,
      backgroundColor: backgroundColor,
      imageUrl: imageUrl,
      body: body,
      footer: footer,
    );
  }
}
