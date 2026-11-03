import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/elements.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../common/elements_public_widgets.dart';
import '../../common/elements_detail_layout.dart';
import '../../common/elements_cards/elements_type_card_widget.dart';
import '../../elements_detils/controllers/elements_detils_controller.dart';
import '../../model/elements_detils_data_model.dart';
import '../../model/elements_jump_module_type.dart';
import '../controllers/elements_sentence_detils_controller.dart';
import 'elements_sentence_pronunciation_widget.dart';
import 'elements_structure_widget.dart';
import 'elements_syntactic_analysis_widget.dart';

class ElementsSentenceDetilsContentWidget extends StatefulWidget {
  final ElementsSentenceDetilsController controller;
  final String tagText;

  const ElementsSentenceDetilsContentWidget({
    super.key,
    required this.controller,
    required this.tagText,
  });

  @override
  State<ElementsSentenceDetilsContentWidget> createState() =>
      _ElementsSentenceDetilsContentWidgetState();
}

class _ElementsSentenceDetilsContentWidgetState
    extends State<ElementsSentenceDetilsContentWidget> {
  Timer? _actionRailTimer;
  bool _isActionRailExpanded = true;
  bool _showLevelPanel = false;
  final GlobalKey _analysisSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleActionRailCollapse();
    });
  }

  @override
  void dispose() {
    _actionRailTimer?.cancel();
    super.dispose();
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

  Future<void> _scrollToAnalysisSection() async {
    final BuildContext? ctx = _analysisSectionKey.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      alignment: 0.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _handleMemoryAction() async {
    final CardSentencesDetilsEntity detils = widget.controller.sentencesDetils.value;

    final SimpleDictionaryAddCardParm parameter = SimpleDictionaryAddCardParm(
      uid: detils.contentId,
      type: detils.contentType,
      semanticId: detils.semanticId,
    );

    final bool? res = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: AppTheme.cBlackAlpha50,
      builder: (BuildContext dialogContext) {
        return _SentenceDetailsModuleDialog(
          title: '记句子',
          backgroundColor: AppTheme.cMemoryPrimary,
          imageUrl: detils.imageUrl,
          body: _buildMemoryDialogHeader(detils),
          footer: _buildMemoryDialogFooter(dialogContext, parameter),
        );
      },
    );

    if (res != true) return;
    if (Get.isRegistered<ElementsDetilsController>()) {
      final ElementsDetilsController detilsController =
          Get.find<ElementsDetilsController>();
      detilsController.refreshStudyListData();
    }
  }

  Widget _buildMemoryDialogHeader(CardSentencesDetilsEntity detils) {
    final ConfigController configController = Get.find<ConfigController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                detils.content ?? '',
                style: TextStyle(
                  fontSize: 32.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary,
                  height: 1.4,
                ),
              ),
            ),
            Visibility(
              visible: detils.difficulty != null,
              child: Container(
                margin: EdgeInsets.only(left: 12.wMin),
                child: StatusTagDifficultyWidget(
                  difficulty: detils.difficulty,
                  language: configController.userSetting.value.learningLang,
                  fontSize: 22.wMin,
                ),
              ),
            ),
          ],
        ),
        if ((detils.definition ?? '').isNotEmpty) ...[
          SizedBox(height: 12.wMin),
          Text(
            detils.definition ?? '',
            style: TextStyle(
              fontSize: 26.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMemoryDialogFooter(
    BuildContext dialogContext,
    SimpleDictionaryAddCardParm parameter,
  ) {
    return Obx(() {
      final bool isFavorited = widget.controller.isFavorited.value;
      final Color buttonColor =
          isFavorited ? AppTheme.cSurfaceQuaternary : AppTheme.cMemoryPrimary;
      final Color textColor =
          isFavorited ? AppTheme.cTextSecondary : AppTheme.cStaticWhite;

      return Align(
        alignment: Alignment.centerRight,
        child: TapScaleWidget(
          onTap: isFavorited
              ? null
              : () async {
                  final bool resp =
                      await SimpleDictionaryDialog.addKnowledgeCard(
                    context: dialogContext,
                    parameter: [parameter],
                  );
                  if (!resp) return;
                  widget.controller.isFavorited.value = true;
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
              isFavorited ? '已记忆' : '记句子',
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

  Widget _buildLanguageActionButton(_SentenceActionItem action) {
    final ConfigController configController = Get.find<ConfigController>();

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
        return _SentenceActionButton(
          item: action,
          expanded: _isActionRailExpanded,
        );
      }

      final List<IconDropdownCheckData<String>> items =
          _buildLanguageItems(dropdownMenu);

      int selectIndex =
          items.indexWhere((IconDropdownCheckData<String> item) => item.value == lang?.code);
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
          if (_showLevelPanel) {
            setState(() {
              _showLevelPanel = false;
            });
          }
        },
        onHideMenu: () {
          _scheduleActionRailCollapse();
        },
        child: _SentenceActionButton(
          item: action,
          expanded: _isActionRailExpanded,
          title: items[selectIndex].title,
        ),
        onTap: (IconDropdownCheckData data, int index) {
          configController.setLearLangSetting(
            data.value!,
            LearModePreference.extension,
          );
        },
      );
    });
  }

  Widget _buildLevelPanel(CardSentencesDetilsEntity detils) {
    final CardDetilsEntityStat? stat = detils.stat;
    final ElementsCardStar? cardStar = detils.cardStar;
    final Color starColor = cardStar?.color != null
        ? Color(int.tryParse(cardStar!.color!.replaceFirst('#', '0xff')) ??
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
        boxShadow: [
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
        children: [
          Text(
            '查看等级',
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w700,
              color: AppTheme.cTextPrimary,
            ),
          ),
          SizedBox(height: 18.wMin),
          if (cardStar != null) ...[
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 18.wMin, vertical: 16.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cBgSecondary,
                borderRadius: BorderRadius.circular(20.wMin),
              ),
              child: Row(
                children: [
                  StarRatingWidget(
                    litStars: cardStar.star ?? 0,
                    starSize: 16,
                    litStarColor: starColor,
                    unlitStarColor: AppTheme.cBorderSecondary,
                    spacing: 4,
                  ),
                  SizedBox(width: 14.wMin),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.wMin, vertical: 8.wMin),
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
          ],
          _buildLevelProgressItem(
            title: '听',
            type: LSRWEnum.listening,
            percent: stat?.listenPct,
            value: stat?.listen,
            exp: stat?.listenExp,
          ),
          SizedBox(height: 12.wMin),
          _buildLevelProgressItem(
            title: '说',
            type: LSRWEnum.speaking,
            percent: stat?.speakPct,
            value: stat?.speak,
            exp: stat?.speakExp,
          ),
          SizedBox(height: 12.wMin),
          _buildLevelProgressItem(
            title: '读',
            type: LSRWEnum.reading,
            percent: stat?.readPct,
            value: stat?.read,
            exp: stat?.readExp,
          ),
          SizedBox(height: 12.wMin),
          _buildLevelProgressItem(
            title: '写',
            type: LSRWEnum.writing,
            percent: stat?.writePct,
            value: stat?.write,
            exp: stat?.writeExp,
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
      children: [
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

  Widget _buildLeftPanel(CardSentencesDetilsEntity detils) {
    final double leftWidth = 560.wMin;
    return ElementsDetilsLeftPanel(
      width: leftWidth,
      mediaBuilder: (double size) {
        return _SentenceImagePanel(
          size: size,
          imageUrl: detils.imageUrl,
          relationVideo: detils.video,
          pronunciations: detils.pronunciations,
          semanticPlaybackKey: '${detils.contentId ?? 0}_${detils.semanticId ?? 0}',
        );
      },
      pronunciation: ElementsSentencePronunciationWidget(
        pronunciations: detils.pronunciations,
        contentType: detils.contentType,
        contentId: detils.contentId,
        content: detils.content,
        onTap: (index) {
          widget.controller.englishAmericanType.value = index;
        },
        englishAmericanType: widget.controller.englishAmericanType.value,
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context, CardSentencesDetilsEntity detils) {
    final ConfigController configController = Get.find<ConfigController>();

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollUpdateNotification &&
            (notification.scrollDelta ?? 0).abs() > 0) {
          _collapseActionRail();
        }
        return false;
      },
      child: Obx(() {
        return ListView(
          controller: widget.controller.autoScrollController,
          physics: widget.controller.isHoveringGraph.value
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: 156.wMin + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            _buildDefinitionSection(detils, configController),
            SizedBox(height: 32.wMin),
            KeyedSubtree(key: _analysisSectionKey, child: _buildAnalysisSection()),
            SizedBox(height: 24.wMin),
          ],
        );
      }),
    );
  }

  Widget _buildDefinitionSection(
    CardSentencesDetilsEntity detils,
    ConfigController configController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          margin: EdgeInsets.only(left: 16.wMin),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: detils.difficulty != null,
                child: Container(
                  margin: EdgeInsets.only(right: 8.wMin),
                  child: StatusTagDifficultyWidget(
                    difficulty: detils.difficulty,
                    language: configController.userSetting.value.learningLang,
                    fontSize: 24.wMin,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detils.content ?? '',
                      style: TextStyle(
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextPrimary,
                        height: 1.1,
                      ),
                    ),
                    Obx(() {
                      final bool showTranslation =
                          configController.userSetting.value.expandLang !=
                                  LangPreference.original &&
                              configController.userSetting.value.expandLang !=
                                  LangPreference.none;
                      return Visibility(
                        visible: showTranslation,
                        child: Container(
                          margin: EdgeInsets.only(top: 6.wMin),
                          child: Text(
                            detils.definition ?? '',
                            style: TextStyle(
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.cTextSecondary,
                            ),
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 16.wMin),
                    Obx(() {
                      return Row(
                        spacing: 8.wMin,
                        children: [
                          _buildSentenceTypeTag(
                              detils.sentenceTypeBasic,
                              detils.sentenceTypeBasicName,
                              0),
                          _buildSentenceTypeTag(
                              detils.sentenceTypeFunctional,
                              detils.sentenceTypeFunctionalName,
                              1),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSentenceTypeTag(
      String? tag, List<LanguageText?>? texts, int index) {
    final ConfigController configController = Get.find<ConfigController>();
    LanguageConfigColorModel? colorConfig;
    final List<LanguageConfigColorEntityInfo?>? basicLevels =
        configController.colorConfigs.value.basicLevels;
    final List<LanguageConfigColorEntityInfo?>? functionalLevels =
        configController.colorConfigs.value.functionalLevels;

    if (index == 0) {
      colorConfig = StatusUtils.getConfigColor(basicLevels, tag);
    } else {
      colorConfig = StatusUtils.getConfigColor(functionalLevels, tag);
    }

    if ((tag ?? '').isEmpty && (texts ?? []).isEmpty) return Container();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: colorConfig?.color?.bgColor,
        border: Border.all(
          width: 1.wMin,
          color: colorConfig?.color?.borderColor ?? Colors.transparent,
        ),
      ),
      child: Obx(() {
        final List<LanguageText> glossList =
            LearningLangUtils.getShowLBList(texts);
        return Text(
          glossList.map((e) => e.text).join(' '),
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: colorConfig?.color?.textColor,
          ),
        );
      }),
    );
  }

  Widget _buildAnalysisSection() {
    return Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(16.wMin),
      //   border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary),
      // ),
      child: Obx(() {
        final detils = widget.controller.sentencesDetils.value;
        final bool hasStructure =
            (detils.clauses?.isNotEmpty ?? false);
        final bool hasSyntactic =
            detils.constituency != null || (detils.structs?.isNotEmpty ?? false);
        if (!hasStructure && !hasSyntactic) {
          return const SizedBox.shrink();
        }
        if (_currentAnalysisTabIndex() == 2) {
          return hasSyntactic
              ? ElementsSyntacticAnalysisWidget(tagText: widget.tagText)
              : const SizedBox.shrink();
        }
        return hasStructure
            ? ElementsStructureWidget(tagText: widget.tagText)
            : const SizedBox.shrink();
      }),
    );
  }

  int _currentAnalysisTabIndex() {
    if (widget.controller.structuralSyntaxTabbarIndex.value == 1) {
      return 2;
    }
    return widget.controller.structureTabControllerIndex.value == 1 ? 1 : 0;
  }

  void _changeAnalysisTab(int index) {
    if (_currentAnalysisTabIndex() == index) return;
    if (index == 2) {
      widget.controller.changeStructuralSyntaxTabbarIndex(1);
    } else {
      widget.controller.changeStructuralSyntaxTabbarIndex(0);
      widget.controller.changeStructureTabControllerIndex(index);
    }
    _collapseActionRail();
  }

  _SentenceActionItem _languageActionItem = _SentenceActionItem(
    type: 'LANGUAGE',
    title: '双语对照',
    svg: 'assets/svg/public/icon_translation.svg',
    color: AppTheme.cBgBrand,
    borderColor: AppTheme.cBgBrand,
    backgroundColor: AppTheme.cBgBrand.color.withValues(alpha: 0.2),
    enabled: true,
  );

  Future<void> _handleModuleItemTap(String module) async {
    if (module == ElementsJumpModuleType.VIEW_LEVEL) {
      final bool nextVisible = !_showLevelPanel;
      if (nextVisible) {
        _expandLevelPanel();
      } else {
        _scheduleActionRailCollapse();
        _collapseActionRail();
      }
      return;
    }
    if (module == ElementsJumpModuleType.MEMORIZE_SENTENCE) {
      await _handleMemoryAction();
      return;
    }
    if (module == ElementsJumpModuleType.CORE_COMPONENTS) {
      final CardSentencesDetilsEntity detils = widget.controller.sentencesDetils.value;
      final ConfigController configController = Get.find<ConfigController>();
      if ((detils.contentType ?? '').isEmpty || detils.contentId == null) return;
      ToastUtils.showLoading();
      try {
        final CardContentModuleDetilsEntity? moduleDetils =
            await ElementsRequest.getContentModuleDetils(
          module: module,
          contentType: detils.contentType!,
          contentId: detils.contentId!,
          semanticId: detils.semanticId ?? 0,
          style: configController.currentStyleForRequest,
          mediaMode: configController.currentMediaMode,
        );
        final Map<String, dynamic> data =
            (moduleDetils?.data is Map<String, dynamic>)
                ? moduleDetils!.data as Map<String, dynamic>
                : <String, dynamic>{};
        final List<dynamic>? subRaw = data['subContents'] as List<dynamic>?;
        final List<ElementsCardEntityDatas> subContents = (subRaw ?? <dynamic>[])
            .map((dynamic e) =>
                ElementsCardEntityDatas.fromJson(e as Map<String, dynamic>))
            .toList();
        if (subContents.isEmpty) return;
        await showDialog<void>(
          context: context,
          barrierDismissible: true,
          barrierColor: AppTheme.cBlackAlpha50,
          builder: (BuildContext dialogContext) {
            return _SentenceDetailsModuleDialog(
              title: '核心组件',
              backgroundColor: const Color(0xffA78BFA),
              imageUrl: null,
              body: Wrap(
                spacing: 10.wMin,
                runSpacing: 24.wMin,
                children: List<Widget>.generate(subContents.length, (int index) {
                  return ElementsTypeCardWidget(
                    data: ElementsDetilsDataModel(
                      type: ElementsCardType.fromRawValue(
                          subContents[index].contentType ?? ''),
                      data: subContents[index],
                    ),
                  );
                }),
              ),
            );
          },
        );
      } finally {
        ToastUtils.hideLoading();
      }
      _scheduleActionRailCollapse();
      return;
    }
    if (module == ElementsJumpModuleType.SYNTACTIC_ANALYSIS) {
      widget.controller.changeStructuralSyntaxTabbarIndex(1);
      await _scrollToAnalysisSection();
      _collapseActionRail();
      return;
    }
    if (module == ElementsJumpModuleType.COMPONENT_ANALYSIS) {
      widget.controller.changeStructuralSyntaxTabbarIndex(0);
      widget.controller.changeStructureTabControllerIndex(1);
      await _scrollToAnalysisSection();
      _collapseActionRail();
      return;
    }
    if (module == ElementsJumpModuleType.CHUNK_ANALYSIS) {
      widget.controller.changeStructuralSyntaxTabbarIndex(0);
      widget.controller.changeStructureTabControllerIndex(0);
      await _scrollToAnalysisSection();
      _collapseActionRail();
      return;
    }
    if (module == ElementsJumpModuleType.GRID_VIEW) {
      widget.controller.changeStructuralSyntaxTabbarIndex(0);
      widget.controller.changeStructureTabControllerIndex(0);
      widget.controller.changeGridOrFoldTagIndex(0);
      await _scrollToAnalysisSection();
      _collapseActionRail();
      return;
    }
    if (module == ElementsJumpModuleType.COLLAPSE_VIEW) {
      widget.controller.changeStructuralSyntaxTabbarIndex(0);
      widget.controller.changeStructureTabControllerIndex(0);
      widget.controller.changeGridOrFoldTagIndex(1);
      await _scrollToAnalysisSection();
      _collapseActionRail();
      return;
    }
    if (module == ElementsJumpModuleType.STRUCTURE_ANALYSIS ||
        module == ElementsJumpModuleType.CORE_COMPONENTS) {
      await _scrollToAnalysisSection();
      _collapseActionRail();
      return;
    }
  }

  Widget _buildStructuralSyntaxTabWidget() {
    final List<_SentenceAnalysisTabItem> tabs = <_SentenceAnalysisTabItem>[
      const _SentenceAnalysisTabItem(
        title: '语块分析',
        color: Color(0xff10B981),
      ),
      const _SentenceAnalysisTabItem(
        title: '成分分析',
        color: Color(0xff8B5CF6),
      ),
      const _SentenceAnalysisTabItem(
        title: '句法分析',
        color: Color(0xff38BDF8),
      ),
    ];

    return Obx(() {
      final detils = widget.controller.sentencesDetils.value;
      final bool hasStructure =
          (detils.clauses?.isNotEmpty ?? false);
      final bool hasSyntactic =
          detils.constituency != null || (detils.structs?.isNotEmpty ?? false);
      if (!hasStructure && !hasSyntactic) {
        return const SizedBox.shrink();
      }
      final int currentIndex = _currentAnalysisTabIndex();
      final List<SemanticChipData> chips = List<SemanticChipData>.generate(
        tabs.length,
        (int index) => SemanticChipData(id: index, text: tabs[index].title),
      );
      return ElementsSemanticBottomBar(
        items: chips,
        currentId: currentIndex,
        showFilter: false,
        isFiltered: false,
        enableInitialScrollToCurrent: false,
        onTapItem: (int id) => _changeAnalysisTab(id),
      );
    });
  }

  List<_SentenceActionItem> _buildActionItems() {
    final bool isFavorited = widget.controller.isFavorited.value;
    return <_SentenceActionItem>[
      const _SentenceActionItem(
        type: 'LANGUAGE',
        title: '双语对照',
        svg: 'assets/svg/public/icon_translation.svg',
        color: Color(0xff8B5CF6),
        enabled: true,
      ),
      const _SentenceActionItem(
        type: 'LEVEL',
        title: '查看等级',
        svg: 'assets/svg/elements/icon_sparkle.svg',
        color: AppTheme.cBorderSecondary,
        enabled: true,
      ),
      _SentenceActionItem(
        type: 'MEMORY',
        title: isFavorited ? '已记忆' : '记句子',
        svg: 'assets/svg/public/icon_memory_m.svg',
        color: AppTheme.cMemoryPrimary,
        enabled: !isFavorited,
      ),
    ];
  }

  Widget _buildStyleActionButton() {
    final ConfigController controller = Get.find<ConfigController>();
    return Obx(() {
      final ResourceTypeEnum resource = controller.currentShowResource.value;
      final String styleName =
          controller.getCurrentStyleName(controller.currentShowStyleCode.value);
      final _SentenceActionItem action = _SentenceActionItem(
        type: 'STYLE',
        title: styleName.isNotEmpty ? styleName : '风格',
        svg: resource.svg,
        color: const Color(0xFF00D492),
        borderColor: const Color(0xFF00D492),
        backgroundColor: const Color(0xFF00D492).withValues(alpha: 0.2),
        enabled: true,
      );
      return _SentenceActionButton(
        item: action,
        expanded: _isActionRailExpanded,
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

  Widget _buildActionRail(CardSentencesDetilsEntity detils) {
    final List<CardWordSemanticModuleItem> moduleItems =
        (detils.moduleItems ?? <CardWordSemanticModuleItem?>[])
            .whereType<CardWordSemanticModuleItem>()
            .toList();
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
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _showLevelPanel
                  ? _buildLevelPanel(detils)
                  : const SizedBox.shrink(),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 16.wMin),
                  child: _buildStyleActionButton(),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 16.wMin),
                  child: _buildLanguageActionButton(_languageActionItem),
                ),
                ...List<Widget>.generate(moduleItems.length, (int index) {
                  final CardWordSemanticModuleItem moduleItem = moduleItems[index];
                  final String module = moduleItem.module ?? '';
                  final bool isMemorizeModule =
                      module == ElementsJumpModuleType.MEMORIZE_SENTENCE;
                  return Container(
                    margin: EdgeInsets.only(bottom: 16.wMin),
                    child: Obx(() {
                      final bool isFavorited =
                          widget.controller.isFavorited.value;
                      final bool disabled = isMemorizeModule && isFavorited;
                      return ElementsSemanticModuleActionButton(
                        moduleItem: moduleItem,
                        expanded: _isActionRailExpanded,
                        titleOverride: disabled ? '已记忆' : null,
                        onTap: disabled
                            ? null
                            : () {
                                _handleModuleItemTap(module);
                              },
                      );
                    }),
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
      if (widget.controller.isLoading.value) return Container();
      final CardSentencesDetilsEntity detils =
          widget.controller.sentencesDetils.value;

      return ElementsDetailLayout(
        leftPanel: _buildLeftPanel(detils),
        rightContent: _buildRightPanel(context, detils),
        bottomBar: _buildStructuralSyntaxTabWidget(),
        rightRail: _buildActionRail(detils),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SentenceImagePanel extends StatelessWidget {
  final double? size;
  final String? imageUrl;
  final EnKnowledgeEntityRelationVideo? relationVideo;
  final List<PronunciationsEntity?>? pronunciations;
  final String semanticPlaybackKey;

  const _SentenceImagePanel({
    this.size,
    this.imageUrl,
    this.relationVideo,
    this.pronunciations,
    required this.semanticPlaybackKey,
  });

  @override
  Widget build(BuildContext context) {
    return ElementsSemanticVideoCardWidget(
      imageUrl: imageUrl,
      relationVideo: relationVideo,
      pronunciations: pronunciations,
      semanticPlaybackKey: semanticPlaybackKey,
      size: size,
      showPronunciationOverlay: false,
    );
  }
}

class _SentenceActionItem {
  final String type;
  final String title;
  final String svg;
  final Color color;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool enabled;

  const _SentenceActionItem({
    required this.type,
    required this.title,
    required this.svg,
    required this.color,
    this.borderColor,
    this.backgroundColor,
    this.enabled = true,
  });
}

class _SentenceAnalysisTabItem {
  final String title;
  final Color color;

  const _SentenceAnalysisTabItem({
    required this.title,
    required this.color,
  });
}

class _SentenceActionButton extends StatelessWidget {
  final _SentenceActionItem item;
  final bool expanded;
  final String? title;
  final void Function()? onTap;

  const _SentenceActionButton({
    required this.item,
    required this.expanded,
    this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = item.enabled
        ? (item.borderColor ?? item.color)
        : AppTheme.cBorderSecondary;
    final Color backgroundColor = item.enabled
        ? (item.backgroundColor ?? item.color.withValues(alpha: 0.18))
        : AppTheme.cBgSecondary;
    final Color iconColor =
        item.enabled ? AppTheme.cTextPrimary : AppTheme.cTextSecondary;
    final Color textColor =
        item.enabled ? AppTheme.cTextPrimary : AppTheme.cTextSecondary;

    return TapScaleWidget(
      onTap: onTap,
      sclae: item.enabled ? 1.03 : 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999.wMin),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.wMin, sigmaY: 10.wMin),
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
              children: [
                SvgPicture.asset(
                  item.svg,
                  width: 30.wMin,
                  height: 30.wMin,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
                if (expanded) ...[
                  SizedBox(width: 10.wMin),
                  Expanded(
                    child: Text(
                      title ?? item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w600,
                        color: textColor,
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

class _SentenceDetailsModuleDialog extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final String? imageUrl;
  final Widget body;
  final Widget? footer;

  const _SentenceDetailsModuleDialog({
    required this.title,
    required this.backgroundColor,
    this.imageUrl,
    required this.body,
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
