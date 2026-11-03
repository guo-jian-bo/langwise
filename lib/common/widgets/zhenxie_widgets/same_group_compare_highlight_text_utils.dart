import '../../entities/entities.dart';

class SameGroupCompareHighlightTextUtils {
  /// 按 order 倒序整理已有对照组，便于页面按最新组优先展示。
  static List<SentencePatternCompareSentenceRealizationSetEntity> getSortedRealizationSetList(
    List<SentencePatternCompareSentenceRealizationSetEntity?>? sentenceRealizationSetList,
  ) {
    if (sentenceRealizationSetList == null || sentenceRealizationSetList.isEmpty) return const [];

    final list = sentenceRealizationSetList.whereType<SentencePatternCompareSentenceRealizationSetEntity>().toList();
    if (list.isEmpty) return const [];

    list.sort((a, b) => (b.order ?? 0).compareTo(a.order ?? 0));
    return list;
  }

  static SentencePatternCompareSentenceRealizationSetEntity? findBestRealizationSet(
    List<SentencePatternCompareSentenceRealizationSetEntity?>? sentenceRealizationSetList,
  ) {
    final list = getSortedRealizationSetList(sentenceRealizationSetList);
    if (list.isEmpty) return null;
    return list.first;
  }

  /// 从当前对照组中取可展示的成员信息，优先使用展开后的 memberList。
  static List<SentencePatternCompareMemberEntity> getDisplayMemberList(
    List<SentencePatternCompareSentenceRealizationSetEntity?>? sentenceRealizationSetList,
  ) {
    final bestSet = findBestRealizationSet(sentenceRealizationSetList);
    final memberList = bestSet?.memberList ?? bestSet?.members;
    if (memberList == null || memberList.isEmpty) return const [];
    return memberList.whereType<SentencePatternCompareMemberEntity>().toList();
  }

  /// 按 valueNid 从单个对照组内查找成员。
  static SentencePatternCompareMemberEntity? findMemberByValueNidInSet({
    required SentencePatternCompareSentenceRealizationSetEntity? sentenceRealizationSet,
    required String? valueNid,
  }) {
    if (valueNid == null || valueNid.isEmpty) return null;

    final memberList = sentenceRealizationSet?.members ?? sentenceRealizationSet?.memberList;
    if (memberList == null || memberList.isEmpty) return null;

    for (final member in memberList) {
      if (member?.valueNid == valueNid) return member;
    }
    return null;
  }

  static SentencePatternCompareSentenceBindingEntity? findBindingByValueNidInSet({
    required SentencePatternCompareSentenceRealizationSetEntity? sentenceRealizationSet,
    required String? valueNid,
  }) {
    if (valueNid == null || valueNid.isEmpty) return null;

    final bindingList = sentenceRealizationSet?.bindingList ?? sentenceRealizationSet?.bindings;
    if (bindingList == null || bindingList.isEmpty) return null;

    for (final binding in bindingList) {
      if (binding?.valueNid == valueNid) return binding;
    }
    return null;
  }

  static SentencePatternCompareSentenceBindingEntity? findBindingByValueNid({
    required List<SentencePatternCompareSentenceRealizationSetEntity?>? sentenceRealizationSetList,
    required String? valueNid,
  }) {
    final bestSet = findBestRealizationSet(sentenceRealizationSetList);
    return findBindingByValueNidInSet(
      sentenceRealizationSet: bestSet,
      valueNid: valueNid,
    );
  }

  static List<String> sanitizeStringList(List<String?>? list) {
    if (list == null || list.isEmpty) return const [];

    final result = <String>[];
    for (final item in list) {
      if (item == null || item.isEmpty || result.contains(item)) continue;
      result.add(item);
    }
    return result;
  }

  static List<SameGroupCompareFocusSearchToken> collectFocusSearchTokenList({
    required SentencePatternCompareContrastFocusEntity? contrastFocus,
    required PatternBlueprintSentenceBriefEntity? sentenceStruct,
  }) {
    final slotKeyList = sanitizeStringList(contrastFocus?.patternSlotKeys);
    final literalList = sanitizeStringList(contrastFocus?.templateLiterals);
    final segmentList = sentenceStruct?.segmentList;
    if ((slotKeyList.isEmpty && literalList.isEmpty) || segmentList == null || segmentList.isEmpty) return const [];

    final result = <SameGroupCompareFocusSearchToken>[];
    appendFocusSearchTokenList(
      result: result,
      segmentList: segmentList,
      slotKeyList: slotKeyList,
      literalList: literalList,
    );
    return result;
  }

  /// 递归遍历 segment，收集声明焦点对应的可搜索文本。
  static void appendFocusSearchTokenList({
    required List<SameGroupCompareFocusSearchToken> result,
    required List<PatternBlueprintSentenceBriefSegmentEntity?>? segmentList,
    required List<String> slotKeyList,
    required List<String> literalList,
  }) {
    if (segmentList == null || segmentList.isEmpty) return;

    for (final segment in segmentList) {
      if (segment == null) continue;

      final childList = segment.childStruct?.segmentList;
      if (childList != null && childList.isNotEmpty) {
        appendFocusSearchTokenList(
          result: result,
          segmentList: childList,
          slotKeyList: slotKeyList,
          literalList: literalList,
        );
        continue;
      }

      final text = segment.text;
      if (text == null || text.isEmpty) continue;

      for (final slotKey in slotKeyList) {
        if (!isMatchedPatternSlot(segment, slotKey)) continue;
        appendFocusSearchToken(
          result: result,
          text: text,
          source: SameGroupCompareFocusSourceType.slot,
          key: slotKey,
        );
      }

      for (final literal in literalList) {
        if (!isMatchedLiteralSegment(segment, literal)) continue;
        appendFocusSearchToken(
          result: result,
          text: text,
          source: SameGroupCompareFocusSourceType.literal,
          key: literal,
        );
      }
    }
  }

  static bool isMatchedPatternSlot(PatternBlueprintSentenceBriefSegmentEntity segment, String slotKey) {
    return segment.slotKey == slotKey || segment.sourceSlotKey == slotKey || segment.renderSlotKey == slotKey;
  }

  static bool isMatchedLiteralSegment(PatternBlueprintSentenceBriefSegmentEntity segment, String literal) {
    return segment.text == literal || segment.literal == true && segment.text == literal;
  }

  static void appendFocusSearchToken({
    required List<SameGroupCompareFocusSearchToken> result,
    required String text,
    required SameGroupCompareFocusSourceType source,
    required String key,
  }) {
    final exists = result.any((item) => item.text == text && item.source == source && item.key == key);
    if (exists) return;
    result.add(SameGroupCompareFocusSearchToken(text: text, source: source, key: key));
  }

  static List<SameGroupCompareFocusRange> buildFocusRangeList({
    required String sentenceText,
    required SentencePatternCompareContrastFocusEntity? contrastFocus,
    required PatternBlueprintSentenceBriefEntity? sentenceStruct,
  }) {
    final tokenList = collectFocusSearchTokenList(
      contrastFocus: contrastFocus,
      sentenceStruct: sentenceStruct,
    );
    if (tokenList.isEmpty) return const [];

    final result = <SameGroupCompareFocusRange>[];
    for (final token in tokenList) {
      appendMatchedRangeList(
        result: result,
        sentenceText: sentenceText,
        token: token,
      );
    }
    if (result.isEmpty) return const [];

    result.sort((a, b) {
      final startCompare = a.start.compareTo(b.start);
      if (startCompare != 0) return startCompare;
      return a.end.compareTo(b.end);
    });
    return mergeFocusRangeList(sentenceText, result);
  }

  /// 直接消费接口返回的 foci.ranges，高亮以服务端坐标为准。
  static List<SameGroupCompareFocusRange> buildRangeListFromFoci({
    required String sentenceText,
    required List<SentencePatternCompareFocusEntity?>? foci,
  }) {
    if (foci == null || foci.isEmpty) return const [];

    final result = <SameGroupCompareFocusRange>[];
    for (final focus in foci) {
      final rangeList = focus?.ranges;
      if (rangeList == null || rangeList.isEmpty) continue;

      for (final range in rangeList) {
        final start = range?.start;
        final end = range?.end;
        if (start == null || end == null || start < 0 || end <= start || end > sentenceText.length) continue;
        result.add(
          SameGroupCompareFocusRange(
            start: start,
            end: end,
            sourceList: [
              SameGroupCompareFocusSource(
                source: SameGroupCompareFocusSourceType.foci,
                key: focus?.focusKey ?? range?.key ?? '',
              ),
            ],
          ),
        );
      }
    }
    if (result.isEmpty) return const [];

    result.sort((a, b) {
      final startCompare = a.start.compareTo(b.start);
      if (startCompare != 0) return startCompare;
      return a.end.compareTo(b.end);
    });
    return mergeFocusRangeList(sentenceText, result);
  }

  static void appendMatchedRangeList({
    required List<SameGroupCompareFocusRange> result,
    required String sentenceText,
    required SameGroupCompareFocusSearchToken token,
  }) {
    int start = sentenceText.indexOf(token.text);
    while (start >= 0) {
      result.add(
        SameGroupCompareFocusRange(
          start: start,
          end: start + token.text.length,
          sourceList: [SameGroupCompareFocusSource(source: token.source, key: token.key)],
        ),
      );
      start = sentenceText.indexOf(token.text, start + 1);
    }
  }

  static List<SameGroupCompareFocusRange> mergeFocusRangeList(
    String sentenceText,
    List<SameGroupCompareFocusRange> rangeList,
  ) {
    final result = <SameGroupCompareFocusRange>[];
    for (final range in rangeList) {
      if (result.isEmpty) {
        result.add(
          SameGroupCompareFocusRange(
            start: range.start,
            end: range.end,
            sourceList: [...range.sourceList],
          ),
        );
        continue;
      }

      final previous = result.last;
      if (shouldMergeRange(
        sentenceText: sentenceText,
        previous: previous,
        current: range,
      )) {
        previous.end = previous.end > range.end ? previous.end : range.end;
        previous.sourceList.addAll(range.sourceList);
        continue;
      }

      result.add(
        SameGroupCompareFocusRange(
          start: range.start,
          end: range.end,
          sourceList: [...range.sourceList],
        ),
      );
    }
    return result;
  }

  static bool shouldMergeRange({
    required String sentenceText,
    required SameGroupCompareFocusRange previous,
    required SameGroupCompareFocusRange current,
  }) {
    if (current.start <= previous.end) return true;

    final gap = sentenceText.substring(previous.end, current.start);
    return gap.trim().isEmpty;
  }

  static List<SameGroupCompareSentenceFragment> buildSentenceFragmentList({
    required String sentenceText,
    required SentencePatternCompareContrastFocusEntity? contrastFocus,
    required PatternBlueprintSentenceBriefEntity? sentenceStruct,
    List<SentencePatternCompareFocusEntity?>? foci,
  }) {
    final fociRangeList = buildRangeListFromFoci(
      sentenceText: sentenceText,
      foci: foci,
    );
    final rangeList = fociRangeList.isNotEmpty
        ? fociRangeList
        : buildFocusRangeList(
            sentenceText: sentenceText,
            contrastFocus: contrastFocus,
            sentenceStruct: sentenceStruct,
          );
    if (rangeList.isEmpty) {
      return [SameGroupCompareSentenceFragment(text: sentenceText, isHighlight: false)];
    }

    final result = <SameGroupCompareSentenceFragment>[];
    int cursor = 0;
    for (final range in rangeList) {
      if (range.start > cursor) {
        result.add(
          SameGroupCompareSentenceFragment(
            text: sentenceText.substring(cursor, range.start),
            isHighlight: false,
          ),
        );
      }
      if (range.end > range.start) {
        result.add(
          SameGroupCompareSentenceFragment(
            text: sentenceText.substring(range.start, range.end),
            isHighlight: true,
          ),
        );
      }
      cursor = range.end;
    }
    if (cursor < sentenceText.length) {
      result.add(
        SameGroupCompareSentenceFragment(
          text: sentenceText.substring(cursor),
          isHighlight: false,
        ),
      );
    }
    return result;
  }
}

class SameGroupCompareFocusSearchToken {
  final String text;
  final SameGroupCompareFocusSourceType source;
  final String key;

  const SameGroupCompareFocusSearchToken({
    required this.text,
    required this.source,
    required this.key,
  });
}

class SameGroupCompareFocusSource {
  final SameGroupCompareFocusSourceType source;
  final String key;

  const SameGroupCompareFocusSource({
    required this.source,
    required this.key,
  });
}

class SameGroupCompareFocusRange {
  final int start;
  int end;
  final List<SameGroupCompareFocusSource> sourceList;

  SameGroupCompareFocusRange({
    required this.start,
    required this.end,
    required this.sourceList,
  });
}

class SameGroupCompareSentenceFragment {
  final String text;
  final bool isHighlight;

  const SameGroupCompareSentenceFragment({
    required this.text,
    required this.isHighlight,
  });
}

enum SameGroupCompareFocusSourceType {
  slot,
  literal,
  foci,
}
