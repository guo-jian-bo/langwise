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

  /// 按 order 倒序整理 realizationSets，便于同组对照优先展示最新数据。
  static List<ZhenxieRealizationSetsEntity> getSortedCommonRealizationSetList(
    List<ZhenxieRealizationSetsEntity?>? realizationSets,
  ) {
    if (realizationSets == null || realizationSets.isEmpty) return const [];

    final list = realizationSets.whereType<ZhenxieRealizationSetsEntity>().toList();
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

  /// 从 realizationSets 中取当前应展示的最佳集合。
  static ZhenxieRealizationSetsEntity? findBestCommonRealizationSet(
    List<ZhenxieRealizationSetsEntity?>? realizationSets,
  ) {
    final list = getSortedCommonRealizationSetList(realizationSets);
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

  /// 按 valueNid 从 realizationSets 的成员列表中查找对应成员。
  static ZhenxieSentenceMemberEntity? findSentenceMemberByValueNidInRealizationSet({
    required ZhenxieRealizationSetsEntity? realizationSet,
    required String? valueNid,
  }) {
    if (valueNid == null || valueNid.isEmpty) return null;

    final memberList = realizationSet?.members;
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

  /// 按 valueNid 从 realizationSets 中查找对应例句绑定。
  static SentencePatternCompareSentenceBindingEntity? findBindingByValueNidInRealizationSet({
    required ZhenxieRealizationSetsEntity? realizationSet,
    required String? valueNid,
  }) {
    if (valueNid == null || valueNid.isEmpty) return null;

    final bindingList = realizationSet?.bindingList;
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

  /// 将 sentence member 的 foci 适配成旧对照成员结构仍在使用的高亮类型。
  static List<SentencePatternCompareFocusEntity?>? buildCompareFocusList(
    List<ZhenxieSentenceMemberFocusEntity?>? foci,
  ) {
    if (foci == null || foci.isEmpty) return null;

    final result = foci.map((focus) {
      if (focus == null) return null;
      return SentencePatternCompareFocusEntity(
        focusKey: focus.focusKey,
        ranges: focus.ranges?.map((range) {
          if (range == null) return null;
          return SentencePatternCompareFocusRangeEntity(
            start: range.start,
            end: range.end,
            text: range.text,
            key: range.key,
          );
        }).toList(),
      );
    }).toList();

    return result.every((item) => item == null) ? null : result;
  }

  /// 直接消费接口返回的 foci.ranges，高亮以服务端坐标为准。
  static List<SameGroupCompareFocusRange> buildRangeListFromFoci({
    required String sentenceText,
    required List<ZhenxieSentenceMemberFocusEntity?>? foci,
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
    required ZhenxieSentenceMemberSentenceEntity? sentenceStruct,
    List<ZhenxieSentenceMemberFocusEntity?>? foci,
  }) {
    final fociRangeList = buildRangeListFromFoci(
      sentenceText: sentenceText,
      foci: foci,
    );
    final rangeList = fociRangeList;
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
  foci,
}
