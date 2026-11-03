part of 'sentence_slot_map_model.dart';

/// 统一承接槽位图的模板解析、segment 组装和 dependsOn 边转换。
class SentenceSlotMapUtils {
  /// 开放槽 category 与主色的映射表，统一服务于槽位卡片视觉语义。
  static const Map<String, Color> _slotCategoryColorMap = <String, Color>{
    'controlled_verb': Color(0xffF59E0B),
    'subject_entity': Color(0xff0EA5E9),
    'object_entity': Color(0xff8B5CF6),
    'verb_predicate': Color(0xffF43F5E),
    'time_expression': Color(0xff10B981),
    'place_expression': Color(0xff14B8A6),
    'reason_expression': Color(0xffF97316),
    'purpose_expression': Color(0xff65A30D),
    'manner_expression': Color(0xffD946EF),
    'clause_content': Color(0xff6366F1),
    'noun_phrase': Color(0xff06B6D4),
    'prepositional_phrase': Color(0xff0891B2),
    'connector': Color(0xff78716C),
  };

  /// 基于蓝图实体构建槽位图，供 Widget 直接消费。
  static SentenceSlotMapEntity buildFromPatternBlueprint(
    PatternBlueprintEntity pattern,
  ) {
    List<PatternBlueprintControlledGrammarSlotEntity?> controlledSlots = pattern.controlledGrammarSlots??[];
    List<PatternBlueprintControlledGrammarSlotListItemEntity?> controlledSlotList = pattern.controlledGrammarSlotList??[];
    List<PatternBlueprintOpenSlotEntity?> openSlots = pattern.openSlots??[];
    List<PatternBlueprintOpenSlotListItemEntity?> openSlotList = pattern.openSlotList??[];
    Map<String, int> growthIndexMap = _buildGrowthIndexMap(openSlots);
    final List<_SentenceSlotTemplateToken> tokens = _parseTemplateTokens(
      template: pattern.template ?? '',
      controlledSlots: controlledSlots,
      openSlots: openSlots,
      growthIndexMap: growthIndexMap,
    );

    final List<SentenceSlotMapItemEntity> items = _buildItems(
      tokens: tokens,
      patternNid: pattern.nid,
      controlledSlotList: controlledSlotList,
      openSlotList: openSlotList,
    );
    final List<SentenceSlotMapDependEdgeEntity> dependEdges = _buildDependEdges(
      tokens: tokens,
      controlledSlotList: controlledSlotList,
      openSlotList: openSlotList,
    );

    return SentenceSlotMapEntity(items: items, dependEdges: dependEdges);
  }

  /// 按 slot category 获取主色，供详情弹窗等复用同一套色语义。
  static Color resolveSlotCategoryColor(
    String? categoryNid, {
    Color fallbackColor = const Color(0xff0EA5E9),
  }) {
    return _slotCategoryColorMap[categoryNid] ?? fallbackColor;
  }

  /// 根据槽位角色与分类收口卡片颜色、边框和文字样式。
  static SentenceSlotMapVisualEntity resolveSlotVisual(
    SentenceSlotMapItemEntity item,
  ) {
    if (item.role == SentenceSlotMapRole.controlled) {
      const Color primaryColor = Color(0xffF59E0B);
      return SentenceSlotMapVisualEntity(
        primaryColor: primaryColor,
        isDottedBorder: false,
      );
    }

    if (item.role == SentenceSlotMapRole.literal) {
      final Color primaryColor = AppTheme.cTextPrimary.color;
      return SentenceSlotMapVisualEntity(
        primaryColor: primaryColor,
        isDottedBorder: false,
      );
    }

    final Color primaryColor = _slotCategoryColorMap[item.categoryNid] ?? const Color(0xff0EA5E9);
    return SentenceSlotMapVisualEntity(
      primaryColor: primaryColor,
      isDottedBorder: item.role == SentenceSlotMapRole.optionalOpen,
    );
  }

  /// 将模板 token 转成最终可渲染的槽位项。
  static List<SentenceSlotMapItemEntity> _buildItems({
    required List<_SentenceSlotTemplateToken> tokens,
    required String? patternNid,
    required List<PatternBlueprintControlledGrammarSlotListItemEntity?> controlledSlotList,
    required List<PatternBlueprintOpenSlotListItemEntity?> openSlotList,
  }) {
    final List<SentenceSlotMapItemEntity> items = [];
    for (int index = 0; index < tokens.length; index++) {
      final _SentenceSlotTemplateToken token = tokens[index];
      if (token.type == _SentenceSlotTemplateTokenType.literal) {
        final String trimmed = _normalizeLiteral(token.text);
        if (trimmed.isEmpty) {
          continue;
        }
        items.add(SentenceSlotMapItemEntity(
          key: 'literal-$index',
          slotKey: '__literal__',
          label: '固定',
          text: trimmed,
          title: 'literal',
          role: SentenceSlotMapRole.literal,
        ));
        continue;
      }

      final String slotKey = token.slotKey;
      final String displayName = _resolveSlotDisplayName(
        slotKey: slotKey,
        controlledSlotList: controlledSlotList,
        openSlotList: openSlotList,
      );
      items.add(
        SentenceSlotMapItemEntity(
          key: 'slot-$slotKey-$index',
          slotKey: slotKey,
          label: _roleLabel(token.role),
          text: displayName,
          title: slotKey,
          role: token.role,
          categoryNid: _resolveCategoryNid(
            slotKey: slotKey,
            openSlotList: openSlotList,
          ),
          showCtrl: token.role == SentenceSlotMapRole.controlled,
          growthIndex: token.growthIndex,
          isRenderAlias: token.isRenderAlias,
          sourceControlledKeys: token.sourceControlledKeys,
          dependsOnSlotKeys: token.dependsOn,
          details: SentenceSlotMapItemDetailsEntity(
            blueprint: _buildBlueprintDetails(
              patternNid: patternNid,
              token: token,
              displayName: displayName,
              controlledSlotList: controlledSlotList,
              openSlotList: openSlotList,
            ),
          ),
        ),
      );
    }
    return items;
  }

  /// 将 token 上的 dependsOn 展开为边列表，避免 Widget 再做查名。
  static List<SentenceSlotMapDependEdgeEntity> _buildDependEdges({
    required List<_SentenceSlotTemplateToken> tokens,
    required List<PatternBlueprintControlledGrammarSlotListItemEntity?> controlledSlotList,
    required List<PatternBlueprintOpenSlotListItemEntity?> openSlotList,
  }) {
    final List<SentenceSlotMapDependEdgeEntity> dependEdges = [];
    for (final _SentenceSlotTemplateToken token in tokens) {
      if (token.type != _SentenceSlotTemplateTokenType.slot) {
        continue;
      }
      for (final String dep in token.dependsOn) {
        dependEdges.add(
          SentenceSlotMapDependEdgeEntity(
            fromSlotKey: dep,
            toSlotKey: token.slotKey,
            fromLabel: _resolveSlotDisplayName(
              slotKey: dep,
              controlledSlotList: controlledSlotList,
              openSlotList: openSlotList,
            ),
            toLabel: _resolveSlotDisplayName(
              slotKey: token.slotKey,
              controlledSlotList: controlledSlotList,
              openSlotList: openSlotList,
            ),
          ),
        );
      }
    }
    return dependEdges;
  }

  /// 按模板顺序切分 literal / slot token，并补齐角色和依赖信息。
  static List<_SentenceSlotTemplateToken> _parseTemplateTokens({
    required String template,
    required List<PatternBlueprintControlledGrammarSlotEntity?>? controlledSlots,
    required List<PatternBlueprintOpenSlotEntity?>? openSlots,
    required Map<String, int> growthIndexMap,
  }) {
    final RegExp tokenRegExp = RegExp(r'(\{[^}]+\}|[^{}]+)');
    final Iterable<RegExpMatch> matches = tokenRegExp.allMatches(template);
    final List<_SentenceSlotTemplateToken> tokens = [];
    for (final RegExpMatch match in matches) {
      final String part = match.group(0) ?? '';
      if (part.startsWith('{') && part.endsWith('}')) {
        final String slotKey = part.substring(1, part.length - 1);
        final List<PatternBlueprintControlledGrammarSlotEntity> sources = [];
        for (final PatternBlueprintControlledGrammarSlotEntity? slot in controlledSlots??[]) {
          if(slot == null) continue;
          final String currentSlotKey = slot.slotKey ?? '';
          final String rendersAs = slot.rendersAs ?? '';
          if (currentSlotKey == slotKey || rendersAs == slotKey) {
            sources.add(slot);
          }
        }
        PatternBlueprintOpenSlotEntity? openSlot;
        for (final PatternBlueprintOpenSlotEntity? slot in openSlots??[]) {
          if(slot == null) continue;
          if (slot.slotKey == slotKey) {
            openSlot = slot;
            break;
          }
        }
        bool isRenderAlias = false;
        final List<String> sourceControlledKeys = [];
        for (final PatternBlueprintControlledGrammarSlotEntity source in sources) {
          final String sourceSlotKey = source.slotKey ?? '';
          if (sourceSlotKey.isNotEmpty) {
            sourceControlledKeys.add(sourceSlotKey);
          }
          if ((source.rendersAs ?? '') == slotKey && sourceSlotKey != slotKey) {
            isRenderAlias = true;
          }
        }
        tokens.add(_SentenceSlotTemplateToken.slot(
          slotKey: slotKey,
          role: _resolveRole(
            slotKey: slotKey,
            controlledSlots: controlledSlots??[],
            openSlots: openSlots??[],
          ),
          growthIndex: growthIndexMap[slotKey],
          dependsOn: _compactStringList(openSlot?.dependsOn),
          isRenderAlias: isRenderAlias,
          sourceControlledKeys: sourceControlledKeys,
          ));
        continue;
      }
      tokens.add(_SentenceSlotTemplateToken.literal(text: part));
    }
    return tokens;
  }

  /// 统一生成开放槽增长序号，避免直接展示原始 growthPriority。
  static Map<String, int> _buildGrowthIndexMap(
    List<PatternBlueprintOpenSlotEntity?>? openSlots,
  ) {
    final List<_GrowthSlotEntry> sortable = [];
    for (int index = 0; index < (openSlots?.length??0); index++) {
      final PatternBlueprintOpenSlotEntity? slot = openSlots?[index];
      if(slot == null) continue;
      final String slotKey = slot.slotKey ?? '';
      final int? growthPriority = slot.growthPriority;
      if (slotKey.isEmpty || growthPriority == null) {
        continue;
      }
      sortable.add(
        _GrowthSlotEntry(
          slotKey: slotKey,
          growthPriority: growthPriority,
          sourceIndex: index,
        ),
      );
    }
    sortable.sort((a, b) {
      final int priorityResult = a.growthPriority.compareTo(b.growthPriority);
      if (priorityResult != 0) {
        return priorityResult;
      }
      return a.sourceIndex.compareTo(b.sourceIndex);
    });

    final Map<String, int> resp = {};
    for (int index = 0; index < sortable.length; index++) {
      resp[sortable[index].slotKey] = index + 1;
    }
    return resp;
  }

  /// 根据模板槽位命中情况判断当前槽位的展示角色。
  static SentenceSlotMapRole _resolveRole({
    required String slotKey,
    required List<PatternBlueprintControlledGrammarSlotEntity?> controlledSlots,
    required List<PatternBlueprintOpenSlotEntity?> openSlots,
  }) {
    for (final PatternBlueprintControlledGrammarSlotEntity? slot in controlledSlots) {
      if(slot == null) continue;
      if ((slot.slotKey ?? '') == slotKey || (slot.rendersAs ?? '') == slotKey) {
        return SentenceSlotMapRole.controlled;
      }
    }
    PatternBlueprintOpenSlotEntity? openSlot;
    for (final PatternBlueprintOpenSlotEntity? slot in openSlots) {
      if(slot == null) continue;
      if (slot.slotKey == slotKey) {
        openSlot = slot;
        break;
      }
    }
    if (openSlot == null) {
      return SentenceSlotMapRole.optionalOpen;
    }
    if (openSlot.required == false) {
      return SentenceSlotMapRole.optionalOpen;
    }
    return SentenceSlotMapRole.requiredOpen;
  }

  /// 解析槽位展示名，优先使用受控源槽名称，再回退到开放槽或 humanize。
  static String _resolveSlotDisplayName({
    required String slotKey,
    required List<PatternBlueprintControlledGrammarSlotListItemEntity?> controlledSlotList,
    required List<PatternBlueprintOpenSlotListItemEntity?> openSlotList,
  }) {
    final List<PatternBlueprintControlledGrammarSlotListItemEntity> controlled =[];
    for (final PatternBlueprintControlledGrammarSlotListItemEntity? slot in controlledSlotList) {
      if(slot == null) continue;
      if ((slot.slotKey ?? '') == slotKey || (slot.rendersAs ?? '') == slotKey) {
        controlled.add(slot);
      }
    }
    if (controlled.isNotEmpty) {
      final PatternBlueprintControlledGrammarSlotListItemEntity preferred = _pickControlledSource(controlled);
      String controlledName = LearningLangUtils.getLocalLang(preferred.slot?.name)?.text?? '';
      if (controlledName.isNotEmpty && controlledName != (preferred.slotKey ?? '')) {
        return controlledName;
      }
    }

    for (final PatternBlueprintOpenSlotListItemEntity? slot in openSlotList) {
      if(slot == null) continue;
      if ((slot.slotKey ?? '') != slotKey) {
        continue;
      }
      String openName = LearningLangUtils.getLocalLang(slot.slot?.name)?.text?? '';
      if (openName.isNotEmpty && openName != slotKey) {
        return openName;
      }
      break;
    }

    for (final PatternBlueprintControlledGrammarSlotListItemEntity? slot in controlledSlotList) {
      if(slot == null) continue;
      if ((slot.slotKey ?? '') != slotKey) {
        continue;
      }
      String controlledName = LearningLangUtils.getLocalLang(slot.slot?.name)?.text?? '';
      if (controlledName.isNotEmpty && controlledName != slotKey) {
        return controlledName;
      }
      break;
    }

    return _humanizeSlotKey(slotKey);
  }

  /// 在多个受控源槽中优先选取非 negative 的展示源。
  static PatternBlueprintControlledGrammarSlotListItemEntity
      _pickControlledSource(
    List<PatternBlueprintControlledGrammarSlotListItemEntity> controlled,
  ) {
    for (final PatternBlueprintControlledGrammarSlotListItemEntity slot
        in controlled) {
      final List<String> activationFeatures =
          _compactStringList(slot.activationFeatureNids);
      if (!activationFeatures.contains('negative')) {
        return slot;
      }
    }
    return controlled.first;
  }

  /// 读取开放槽的分类 nid，供颜色语义映射使用。
  static String? _resolveCategoryNid({
    required String slotKey,
    required List<PatternBlueprintOpenSlotListItemEntity?> openSlotList,
  }) {
    for (final PatternBlueprintOpenSlotListItemEntity? slot in openSlotList) {
      if(slot == null) continue;
      if ((slot.slotKey ?? '') == slotKey) {
        return slot.slot?.categoryNid;
      }
    }
    return null;
  }

  /// 为蓝图槽位项补齐弹窗所需详情。
  static SentenceSlotMapBlueprintDetailsEntity _buildBlueprintDetails({
    required String? patternNid,
    required _SentenceSlotTemplateToken token,
    required String displayName,
    required List<PatternBlueprintControlledGrammarSlotListItemEntity?> controlledSlotList,
    required List<PatternBlueprintOpenSlotListItemEntity?> openSlotList,
  }) {
    final PatternBlueprintOpenSlotListItemEntity? openSlot = _findOpenSlotDetail(
      slotKey: token.slotKey,
      openSlotList: openSlotList,
    );
    final List<PatternBlueprintControlledGrammarSlotListItemEntity> controlledItems = _findControlledSlotDetails(
      slotKey: token.slotKey,
      controlledSlotList: controlledSlotList,
    );
    final PatternBlueprintControlledGrammarSlotListItemEntity?
        preferredControlled = controlledItems.isNotEmpty
            ? _pickControlledSource(controlledItems)
            : null;
    final List<String> sourceControlledKeys =
        token.sourceControlledKeys.isNotEmpty
            ? token.sourceControlledKeys
            : _collectControlledKeys(controlledItems);

    return SentenceSlotMapBlueprintDetailsEntity(
      patternNid: patternNid,
      slotKey: token.slotKey,
      slot: openSlot?.slot ?? preferredControlled?.slot,
      displayName: displayName,
      roleLabel: _roleLabel(token.role),
      growthIndex: token.growthIndex,
      isRenderAlias: token.isRenderAlias,
      sourceControlledKeys: sourceControlledKeys,
      sourceControlledSlots: _resolveSourceControlledSlots(
        sourceControlledKeys: sourceControlledKeys,
        controlledSlotList: controlledSlotList,
      ),
      dependsOnSlots: _resolveDependsOnSlots(
        dependsOnKeys: token.dependsOn,
        openSlot: openSlot,
        openSlotList: openSlotList,
        controlledSlotList: controlledSlotList,
      ),
      openSlot: openSlot,
      controlledVariants: _buildControlledVariants(controlledItems),
      category: null,
    );
  }

  /// 查找当前槽位对应的开放槽详情。
  static PatternBlueprintOpenSlotListItemEntity? _findOpenSlotDetail({
    required String slotKey,
    required List<PatternBlueprintOpenSlotListItemEntity?> openSlotList,
  }) {
    for (final PatternBlueprintOpenSlotListItemEntity? slot in openSlotList) {
      if(slot == null) continue;
      if ((slot.slotKey ?? '') == slotKey) {
        return slot;
      }
    }
    return null;
  }

  /// 查找当前槽位对应的受控槽详情，兼容 rendersAs。
  static List<PatternBlueprintControlledGrammarSlotListItemEntity> _findControlledSlotDetails({
    required String slotKey,
    required List<PatternBlueprintControlledGrammarSlotListItemEntity?> controlledSlotList,
  }) {
    final List<PatternBlueprintControlledGrammarSlotListItemEntity> resp = [];
    for (final PatternBlueprintControlledGrammarSlotListItemEntity? slot in controlledSlotList) {
      if(slot == null) continue;
      if ((slot.slotKey ?? '') == slotKey || (slot.rendersAs ?? '') == slotKey) {
        resp.add(slot);
      }
    }
    return resp;
  }

  /// 组装受控槽详情卡片列表。
  static List<SentenceSlotMapControlledVariantEntity> _buildControlledVariants(
    List<PatternBlueprintControlledGrammarSlotListItemEntity> controlledItems,
  ) {
    final List<SentenceSlotMapControlledVariantEntity> resp = [];
    for (final PatternBlueprintControlledGrammarSlotListItemEntity item
        in controlledItems) {
      final List<SentenceSlotMapControlledOptionEntity> options = [];
      final List<String> rawOptions = _compactStringList(item.options);
      for (int index = 0; index < rawOptions.length; index++) {
        options.add(
          SentenceSlotMapControlledOptionEntity(
            value: rawOptions[index],
            order: index,
          ),
        );
      }
      resp.add(
        SentenceSlotMapControlledVariantEntity(
          slotKey: item.slotKey,
          rendersAs: item.rendersAs,
          slot: item.slot,
          activationFeatures: item.activationFeatures,
          options: options,
        ),
      );
    }
    return resp;
  }

  /// 收集受控源槽 key，供弹窗展示来源说明。
  static List<String> _collectControlledKeys(
    List<PatternBlueprintControlledGrammarSlotListItemEntity> controlledItems,
  ) {
    final List<String> resp = [];
    for (final PatternBlueprintControlledGrammarSlotListItemEntity item
        in controlledItems) {
      final String value = item.slotKey?.trim() ?? '';
      if (value.isEmpty || resp.contains(value)) {
        continue;
      }
      resp.add(value);
    }
    return resp;
  }

  /// 由源受控 key 回填完整槽位对象。
  static List<PatternBlueprintNamedInfoEntity?> _resolveSourceControlledSlots({
    required List<String> sourceControlledKeys,
    required List<PatternBlueprintControlledGrammarSlotListItemEntity?> controlledSlotList,
  }) {
    final List<PatternBlueprintNamedInfoEntity?> resp = [];
    for (final String key in sourceControlledKeys) {
      for (final PatternBlueprintControlledGrammarSlotListItemEntity? item in controlledSlotList) {
        if(item == null) continue;
        if ((item.slotKey ?? '') != key) {
          continue;
        }
        if (item.slot != null) {
          resp.add(item.slot);
        }
        break;
      }
    }
    return resp;
  }

  /// 将 dependsOn key 转成完整槽位对象。
  static List<PatternBlueprintNamedInfoEntity?> _resolveDependsOnSlots({
    required List<String> dependsOnKeys,
    required PatternBlueprintOpenSlotListItemEntity? openSlot,
    required List<PatternBlueprintOpenSlotListItemEntity?> openSlotList,
    required List<PatternBlueprintControlledGrammarSlotListItemEntity?> controlledSlotList,
  }) {
    if (openSlot?.dependsOnSlots != null && openSlot!.dependsOnSlots!.isNotEmpty) {
      return openSlot.dependsOnSlots!
          .whereType<PatternBlueprintNamedInfoEntity>()
          .toList();
    }

    final List<PatternBlueprintNamedInfoEntity?> resp = [];
    for (final String key in dependsOnKeys) {
      final PatternBlueprintNamedInfoEntity? slot = _resolveSlotNamedInfoByKey(
        slotKey: key,
        openSlotList: openSlotList,
        controlledSlotList: controlledSlotList,
      );
      if (slot != null) {
        resp.add(slot);
      }
    }
    return resp;
  }

  /// 按 slotKey 回填槽位详情对象，优先开放槽，再回退受控槽。
  static PatternBlueprintNamedInfoEntity? _resolveSlotNamedInfoByKey({
    required String slotKey,
    required List<PatternBlueprintOpenSlotListItemEntity?> openSlotList,
    required List<PatternBlueprintControlledGrammarSlotListItemEntity?> controlledSlotList,
  }) {
    for (final PatternBlueprintOpenSlotListItemEntity? slot in openSlotList) {
      if(slot == null) continue;
      if ((slot.slotKey ?? '') == slotKey) {
        return slot.slot;
      }
    }
    for (final PatternBlueprintControlledGrammarSlotListItemEntity? slot in controlledSlotList) {
      if(slot == null) continue;
      if ((slot.slotKey ?? '') == slotKey || (slot.rendersAs ?? '') == slotKey) {
        return slot.slot;
      }
    }
    return null;
  }

  /// 规范化模板字面量，压缩多余空白后再参与展示。
  static String _normalizeLiteral(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// 在缺少展示名时，将原始槽位 key 转为可读文案。
  static String _humanizeSlotKey(String slotKey) {
    return slotKey
        .replaceFirst(RegExp(r'_marking$'), '')
        .split('_')
        .where((String item) => item.trim().isNotEmpty)
        .join(' ');
  }

  /// 将槽位角色映射为卡片顶部标签文案。
  static String _roleLabel(SentenceSlotMapRole role) {
    switch (role) {
      case SentenceSlotMapRole.controlled:
        return '受控';
      case SentenceSlotMapRole.requiredOpen:
        return '必填';
      case SentenceSlotMapRole.optionalOpen:
        return '可选';
      case SentenceSlotMapRole.literal:
        return '固定';
    }
  }

  /// 清理字符串列表，过滤空值和空白项。
  static List<String> _compactStringList(List<String?>? source) {
    final List<String> resp = [];
    if (source == null) {
      return resp;
    }
    for (final String? item in source) {
      final String value = item?.trim() ?? '';
      if (value.isEmpty) {
        continue;
      }
      resp.add(value);
    }
    return resp;
  }
}

enum _SentenceSlotTemplateTokenType {
  literal,
  slot,
}

/// 模板解析后的中间 token，仅在转换阶段使用。
class _SentenceSlotTemplateToken {
  final _SentenceSlotTemplateTokenType type;
  final String text;
  final String slotKey;
  final SentenceSlotMapRole role;
  final int? growthIndex;
  final List<String> dependsOn;
  final bool isRenderAlias;
  final List<String> sourceControlledKeys;

  const _SentenceSlotTemplateToken.literal({
    required this.text,
  })  : type = _SentenceSlotTemplateTokenType.literal,
        slotKey = '',
        role = SentenceSlotMapRole.literal,
        growthIndex = null,
        dependsOn = const [],
        isRenderAlias = false,
        sourceControlledKeys = const [];

  const _SentenceSlotTemplateToken.slot({
    required this.slotKey,
    required this.role,
    required this.growthIndex,
    required this.dependsOn,
    required this.isRenderAlias,
    required this.sourceControlledKeys,
  })  : type = _SentenceSlotTemplateTokenType.slot,
        text = '';
}

class _GrowthSlotEntry {
  final String slotKey;
  final int growthPriority;
  final int sourceIndex;

  const _GrowthSlotEntry({
    required this.slotKey,
    required this.growthPriority,
    required this.sourceIndex,
  });
}
