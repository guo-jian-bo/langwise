import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class CustomCourseManageGradeAddGradeDialog {
  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required int? courseId,
    int? studyTier,
  }) async {
    return await showCupertinoDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => CustomCourseManageGradeAddGradeDialogWidget(
        courseId: courseId,
        studyTier: studyTier,
      ),
    );
  }
}

class CustomCourseManageGradeAddGradeDialogWidget extends StatefulWidget {
  final int? courseId;
  final int? studyTier;

  const CustomCourseManageGradeAddGradeDialogWidget({
    super.key,
    required this.courseId,
    this.studyTier,
  });

  @override
  State<CustomCourseManageGradeAddGradeDialogWidget> createState() =>
      _CustomCourseManageGradeAddGradeDialogWidgetState();
}

class _CustomCourseManageGradeAddGradeDialogWidgetState
    extends State<CustomCourseManageGradeAddGradeDialogWidget> {
  static const Color _accentColor = Color(0xFFF59E0B);
  static const List<String> _stageOrder = <String>[
    '学龄前',
    '小学',
    '初中',
    '高中',
    '大学+',
  ];

  final TextEditingController courseNameInput = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<CourseLevelTierEntityList> _tierList = <CourseLevelTierEntityList>[];

  int? selectedTier;
  String? selectedStage;
  bool isLoading = true;
  bool _tierListRequested = false;

  @override
  void initState() {
    super.initState();
    selectedTier = widget.studyTier;
    _loadTierList();
  }

  @override
  void dispose() {
    courseNameInput.dispose();
    scrollController.dispose();
    super.dispose();
  }

  bool checkForm() {
    return courseNameInput.text.trim().isNotEmpty && selectedTier != null;
  }

  Future<void> _loadTierList() async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.courseLevelTierList)) return;
    if (_tierListRequested) return;
    _tierListRequested = true;
    try {
      ToastUtils.showLoading();
      final CourseLevelTierEntity? entity =
          await StudyPlanRequest.getCourseLevelTierList();
      final List<CourseLevelTierEntityList?> list =
          entity?.list ?? <CourseLevelTierEntityList?>[];
      _tierList
        ..clear()
        ..addAll(list.whereType<CourseLevelTierEntityList>());
      _initSelection();
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          ToastUtils.hideLoading();
        });
      }
    }
  }

  void _initSelection() {
    final CourseLevelTierEntityList? preferred = _findTierByTier(selectedTier);
    final CourseLevelTierEntityList? selectablePreferred =
        preferred != null && _isSelectable(preferred) ? preferred : null;
    final CourseLevelTierEntityList? currentSelectable =
        _firstWhere(_tierList, (item) => item.current == true && _isSelectable(item));
    final CourseLevelTierEntityList? fallbackSelectable =
        _firstSelectable(_tierList);
    final CourseLevelTierEntityList? baseItem =
        selectablePreferred ?? currentSelectable ?? fallbackSelectable ?? _tierList.firstOrNull;
    if (baseItem == null) return;
    selectedStage = _resolveStage(baseItem);
    selectedTier = _isSelectable(baseItem) ? baseItem.tier : null;
  }

  CourseLevelTierEntityList? _findTierByTier(int? tier) {
    if (tier == null) return null;
    return _firstWhere(_tierList, (item) => item.tier == tier);
  }

  T? _firstWhere<T>(List<T> list, bool Function(T item) test) {
    for (final item in list) {
      if (test(item)) return item;
    }
    return null;
  }

  bool _isSelectable(CourseLevelTierEntityList item) {
    return item.disable != true;
  }

  CourseLevelTierEntityList? _firstSelectable(List<CourseLevelTierEntityList> list) {
    return _firstWhere(list, _isSelectable);
  }

  List<String> get _availableStages {
    return _stageOrder
        .where((stage) => _tierList.any((item) => _resolveStage(item) == stage))
        .toList(growable: false);
  }

  List<CourseLevelTierEntityList> get _filteredTierList {
    final String? stage = selectedStage;
    if (stage == null) return _tierList;
    return _tierList
        .where((item) => _resolveStage(item) == stage)
        .toList(growable: false);
  }

  Map<String, List<CourseLevelTierEntityList>> get _groupedByCefr {
    final Map<String, List<CourseLevelTierEntityList>> grouped =
        <String, List<CourseLevelTierEntityList>>{};
    for (final item in _filteredTierList) {
      final String cefr = item.cefr?.trim().isNotEmpty == true
          ? item.cefr!.trim()
          : '未分组';
      grouped.putIfAbsent(cefr, () => <CourseLevelTierEntityList>[]).add(item);
    }
    return grouped;
  }

  void _onSelectStage(String stage) {
    final List<CourseLevelTierEntityList> stageItems = _tierList
        .where((item) => _resolveStage(item) == stage)
        .toList(growable: false);
    final bool keepCurrentSelection =
        stageItems.any((item) => item.tier == selectedTier && _isSelectable(item));
    final CourseLevelTierEntityList? firstSelectable =
        _firstSelectable(stageItems);
    setState(() {
      selectedStage = stage;
      if (!keepCurrentSelection) {
        selectedTier = firstSelectable?.tier;
      }
    });
  }

  void _onSelectTier(CourseLevelTierEntityList item) {
    if (!_isSelectable(item)) return;
    setState(() {
      selectedTier = item.tier;
    });
  }

  String _resolveStage(CourseLevelTierEntityList item) {
    final String gradeText = _primaryMappingText(item).trim();
    if (gradeText.isEmpty) return '大学+';
    if (gradeText.contains('学龄前')) return '学龄前';
    if (gradeText.contains('高中')) return '高中';
    if (const <String>['七年级', '八年级', '九年级'].contains(gradeText)) {
      return '初中';
    }
    if (RegExp(r'^[一二三四五六]年级$').hasMatch(gradeText)) {
      return '小学';
    }
    return '大学+';
  }

  CourseLevelTierEntityListVocabulary? _findMappingByEnTitle(
    CourseLevelTierEntityList item,
    String title,
  ) {
    final List<CourseLevelTierEntityListVocabulary?> mappings =
        item.mappings ?? <CourseLevelTierEntityListVocabulary?>[];
    for (final mapping in mappings) {
      final String enTitle = _languageText(mapping?.title, lang: 'en');
      if (enTitle == title) return mapping;
    }
    return null;
  }

  CourseLevelTierEntityListVocabulary? _firstFallbackMapping(
    CourseLevelTierEntityList item,
  ) {
    final List<CourseLevelTierEntityListVocabulary?> mappings =
        item.mappings ?? <CourseLevelTierEntityListVocabulary?>[];
    for (final mapping in mappings) {
      final String enTitle = _languageText(mapping?.title, lang: 'en');
      if (enTitle != 'Cambridge') return mapping;
    }
    return mappings.firstOrNull;
  }

  String _primaryMappingText(CourseLevelTierEntityList item) {
    final CourseLevelTierEntityListVocabulary? mapping =
        _findMappingByEnTitle(item, 'Grade') ?? _firstFallbackMapping(item);
    return _mappingDescribe(mapping);
  }

  String _cambridgeText(CourseLevelTierEntityList item) {
    return _mappingDescribe(_findMappingByEnTitle(item, 'Cambridge'));
  }

  String _mappingDescribe(CourseLevelTierEntityListVocabulary? mapping) {
    return (mapping?.describe ?? <String>[])
        .where((item) => item.trim().isNotEmpty)
        .join(' / ');
  }

  String _languageText(List<LanguageText?>? texts, {String lang = 'zh'}) {
    if (texts == null) return '';
    for (final item in texts) {
      if (item?.lang == lang && (item?.text?.trim().isNotEmpty ?? false)) {
        return item!.text!.trim();
      }
    }
    for (final item in texts) {
      if (item?.text?.trim().isNotEmpty ?? false) {
        return item!.text!.trim();
      }
    }
    return '';
  }

  CourseLevelTierEntityList? get _selectedTierItem {
    return _findTierByTier(selectedTier);
  }

  bool get _shouldShowSelectedTierSummary {
    final String? stage = selectedStage;
    if (stage == null) return false;
    return _tierList.any(
      (item) => _resolveStage(item) == stage && _isSelectable(item),
    );
  }

  String get _selectedTierSummary {
    final CourseLevelTierEntityList? item = _selectedTierItem;
    if (item == null) return '未选择';
    final String stage = _resolveStage(item);
    final String primary = stage == '大学+' ? stage : _primaryMappingText(item);
    final String levelText = item.tier == null ? '' : 'level ${item.tier}';
    if (primary.isEmpty) return levelText;
    if (levelText.isEmpty) return primary;
    return '$primary • $levelText';
  }

  void _confirm() {
    if (!checkForm()) {
      ToastUtils.showToast(text: '请先填写年级名称并选择等级');
      return;
    }
    Get.back(
      result: {
        'name': courseNameInput.text.trim(),
        'tier': selectedTier,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFormValid = checkForm();
    return Material(
      color: AppTheme.cStaticBlack.withValues(alpha: 0.55),
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 1200.wMin,
              constraints: BoxConstraints(maxHeight: 1000.wMin),
              padding: EdgeInsets.fromLTRB(36.wMin, 36.wMin, 36.wMin, 28.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.wMin),
                color: AppTheme.cBgSecondary,
                border: Border.all(
                  color: AppTheme.cBorderSecondary.withValues(alpha: 0.28),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.cStaticBlack.withValues(alpha: 0.24),
                    blurRadius: 22.wMin,
                    offset: Offset(0, 10.wMin),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '新增年级',
                    style: TextStyle(
                      fontSize: 44.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10.wMin),
                  Text(
                    '先按学段和年级选择，系统会同步显示对应的考试参考，并用 Level 标签标记位置。',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 18.wMin),
                  _buildSectionTitle('年级名称'),
                  SizedBox(height: 10.wMin),
                  _buildNameInput(),
                  SizedBox(height: 18.wMin),
                  _buildSectionTitle('选择适用学段'),
                  SizedBox(height: 10.wMin),
                  Wrap(
                    spacing: 12.wMin,
                    runSpacing: 12.wMin,
                    children: _availableStages
                        .map((stage) => _buildStageChip(stage))
                        .toList(growable: false),
                  ),
                  SizedBox(height: 18.wMin),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSectionTitle('按 CEFR 分组选择年级'),
                      ),
                      if (_shouldShowSelectedTierSummary)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.wMin,
                            vertical: 8.wMin,
                          ),
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8.wMin),
                            border: Border.all(
                              color: _accentColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            '当前：$_selectedTierSummary',
                            style: TextStyle(
                              fontSize: 20.wMin,
                              color: _accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10.wMin),
                  Expanded(
                    child: _buildTierContent(),
                  ),
                  SizedBox(height: 10.wMin),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 12.wMin),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.cBorderSecondary.withValues(alpha: 0.28),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Level 只影响默认排序位置，不影响任何学习逻辑。这里选错也没关系，后续仍然可以调整。',
                            style: TextStyle(
                              fontSize: 20.wMin,
                              color: AppTheme.cTextSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(width: 24.wMin),
                        _buildFooterButton(
                          title: '取消',
                          primary: false,
                          onTap: () => Get.back(),
                        ),
                        SizedBox(width: 16.wMin),
                        _buildFooterButton(
                          title: '确认新增',
                          primary: true,
                          enabled: isFormValid,
                          onTap: _confirm,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 18.wMin,
              right: 18.wMin,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 48.wMin,
                  height: 48.wMin,
                  decoration: BoxDecoration(
                    color: AppTheme.cBgTertiary.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 24.wMin,
                    color: AppTheme.cTextSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      height: 50.wMin,
      decoration: BoxDecoration(
        color: AppTheme.cBgTertiary,
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(
          color: AppTheme.cBorderSecondary.withValues(alpha: 0.24),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.wMin),
      child: TextField(
        controller: courseNameInput,
        maxLength: 20,
        style: TextStyle(
          fontSize: 24.wMin,
          color: AppTheme.cTextPrimary,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: '例如：Level 3 阅读进阶 / 八年级人教（新）',
          hintStyle: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextDisabled,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
        ),
        onChanged: (_) {
          if (mounted) setState(() {});
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 28.wMin,
        color: AppTheme.cTextPrimary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildStageChip(String stage) {
    final bool selected = selectedStage == stage;
    return GestureDetector(
      onTap: () => _onSelectStage(stage),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 12.wMin),
        decoration: BoxDecoration(
          color: selected
              ? _accentColor.withValues(alpha: 0.12)
              : AppTheme.cSurfaceLayerElevated.color.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(999.wMin),
          border: Border.all(
            color: selected
                ? _accentColor.withValues(alpha: 0.20)
                : AppTheme.cSurfaceLayerElevated.color.withValues(alpha: 0.16),
          ),
        ),
        child: Text(
          stage,
          style: TextStyle(
            fontSize: 24.wMin,
            color: selected ? _accentColor : AppTheme.cTextPrimary.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTierContent() {
    if (isLoading) {
      return Center(
        
      );
    }

    if (_tierList.isEmpty) {
      return Center(
        child: Text(
          '暂无可选等级数据',
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    final entries = _groupedByCefr.entries.toList(growable: false);
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: List.generate(entries.length, (index) {
            final entry = entries[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == entries.length - 1 ? 0 : 18.wMin,
              ),
              child: _buildCefrGroup(entry.key, entry.value),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCefrGroup(
    String cefr,
    List<CourseLevelTierEntityList> items,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerBase,
        borderRadius: BorderRadius.circular(18.wMin),
   
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'CEFR $cefr',
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${items.length}个年级',
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.wMin),
          LayoutBuilder(
            builder: (context, constraints) {
              final double spacing = 16.wMin;
              final double itemWidth = (constraints.maxWidth - spacing * 2) / 3;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: items
                    .map(
                      (item) => SizedBox(
                        width: itemWidth,
                        child: _buildTierCard(item),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(CourseLevelTierEntityList item) {
    final bool selected = item.tier == selectedTier;
    final bool disabled = item.disable == true;
    final String primaryText = _primaryMappingText(item);
    final String examText = _cambridgeText(item);

    return GestureDetector(
      onTap: disabled ? null : () => _onSelectTier(item),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: disabled ? 0.45 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(10.wMin),
          decoration: BoxDecoration(
            color: selected
                ? _accentColor.withValues(alpha: 0.12)
                : AppTheme.cSurfaceLayerElevated2,
            borderRadius: BorderRadius.circular(14.wMin),
            border: Border.all(
              color: selected
                  ? _accentColor.withValues(alpha: 0.2)
                  : AppTheme.cBorderSecondary.withValues(alpha: 0.2),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      primaryText.isNotEmpty ? primaryText : '未命名年级',
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.wMin),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.wMin,
                      vertical: 4.wMin,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? _accentColor.withValues(alpha: 0.18)
                          : AppTheme.cBlackAlpha20,
                      borderRadius: BorderRadius.circular(6.wMin),
                    ),
                    child: Text(
                      'Level ${item.tier ?? ''}',
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: selected
                            ? _accentColor
                            : AppTheme.cStaticWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.wMin),
              Text(
                examText.isNotEmpty ? '考试参考：$examText' : '考试参考：暂无',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: AppTheme.cTextSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterButton({
    required String title,
    required VoidCallback onTap,
    required bool primary,
    bool enabled = true,
  }) {
    final Color bgColor;
    final Color textColor;
    if (!enabled) {
      bgColor = AppTheme.cBgTertiary;
      textColor = AppTheme.cTextDisabled;
    } else if (primary) {
      bgColor = _accentColor.withValues(alpha: 0.12);
      textColor = _accentColor;
    } else {
      bgColor = AppTheme.cSurfaceLayerElevated.color.withValues(alpha: 0.28);
      textColor = _accentColor;
    }

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
  
        padding: EdgeInsets.symmetric(horizontal: 32.wMin,vertical: 12.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.wMin),
          border: Border.all(
            color: enabled
                ? _accentColor.withValues(alpha: primary ? 0.2 : 0.18)
                : AppTheme.cBorderSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 24.wMin,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
