import '../../../../../common/entities/entities.dart';

enum SentenceChunkAnalysisMode {
  chunking,
  svoca,
}

enum SentenceChunkLayoutRowKind {
  clause,
  conjunction,
  residual,
}

enum SentenceChunkLayoutPillKind {
  analysis,
  conjunction,
  residual,
}

class SentenceChunkLayoutTokenSpan {
  final int id;
  final int start;
  final int end;
  final bool matched;

  const SentenceChunkLayoutTokenSpan({
    required this.id,
    required this.start,
    required this.end,
    required this.matched,
  });
}

class SentenceChunkLayoutColumn {
  String label;
  final List<int> tokenIds;
  final int startChar;
  int endChar;

  SentenceChunkLayoutColumn({
    required this.label,
    required this.tokenIds,
    required this.startChar,
    required this.endChar,
  });
}

class SentenceChunkLayoutPill {
  final String key;
  final int startTokenId;
  final int endTokenId;
  final int startColumnIndex;
  final int endColumnIndex;
  final String text;
  final String label;
  final SentenceChunkLayoutPillKind kind;
  final int? clauseId;
  final String sourceType;

  const SentenceChunkLayoutPill({
    required this.key,
    required this.startTokenId,
    required this.endTokenId,
    required this.startColumnIndex,
    required this.endColumnIndex,
    required this.text,
    required this.label,
    required this.kind,
    required this.clauseId,
    required this.sourceType,
  });
}

class SentenceChunkLayoutRow {
  final SentenceChunkLayoutRowKind kind;
  final EnSentenceStructureClause? clause;
  final EnSentenceStructureConjunction? conjunction;
  final int depth;
  final List<SentenceChunkLayoutPill> pills;

  const SentenceChunkLayoutRow({
    required this.kind,
    required this.clause,
    required this.conjunction,
    required this.depth,
    required this.pills,
  });
}

class SentenceChunkLayoutResult {
  final List<SentenceChunkLayoutColumn> columns;
  final List<SentenceChunkLayoutRow> rows;

  const SentenceChunkLayoutResult({
    required this.columns,
    required this.rows,
  });
}

class _SentenceChunkAnalysisSegment {
  final String id;
  final String type;
  final String label;
  final TextReference textReference;

  const _SentenceChunkAnalysisSegment({
    required this.id,
    required this.type,
    required this.label,
    required this.textReference,
  });
}

class _SentenceChunkRawPill {
  final int startTokenId;
  final int endTokenId;
  final String label;
  final SentenceChunkLayoutPillKind kind;
  final int? clauseId;
  final String sourceType;

  _SentenceChunkRawPill({
    required this.startTokenId,
    required this.endTokenId,
    required this.label,
    required this.kind,
    required this.clauseId,
    required this.sourceType,
  });
}

class _SurfaceIndex {
  final String sentence;
  final Map<int, SentenceChunkLayoutTokenSpan> spans;
  final List<SentenceChunkLayoutColumn> columns;
  final Map<int, int> columnOf;

  const _SurfaceIndex({
    required this.sentence,
    required this.spans,
    required this.columns,
    required this.columnOf,
  });
}

class SentenceChunkLayoutHelper {
  static const String residualSourceType = '__residual__';

  static String sliceSurface({
    required String? sentence,
    required List<EnSentenceStructureToken> tokens,
    required int start,
    required int end,
  }) {
    final List<EnSentenceStructureToken> orderedTokens = [...tokens]
      ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    final _SurfaceIndex? surface = _buildSurfaceIndex(sentence, orderedTokens);
    return _sliceSurface(surface, orderedTokens, start, end);
  }

  static SentenceChunkLayoutResult build({
    required String? sentence,
    required List<EnSentenceStructureToken> tokens,
    required List<EnSentenceStructureClause> clauses,
    SentenceChunkAnalysisMode mode = SentenceChunkAnalysisMode.chunking,
  }) {
    final List<EnSentenceStructureToken> orderedTokens = [...tokens]
      ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    final List<EnSentenceStructureClause> orderedClauses = [...clauses]
      ..sort((a, b) {
        final int byOrder = (a.orderInSentence ?? 0).compareTo(b.orderInSentence ?? 0);
        if (byOrder != 0) return byOrder;
        return (a.textReference?.start ?? 0).compareTo(b.textReference?.start ?? 0);
      });
    final _SurfaceIndex? surface = _buildSurfaceIndex(sentence, orderedTokens);
    final List<SentenceChunkLayoutColumn> columns = surface?.columns ?? _buildFallbackColumns(orderedTokens);
    final Map<int, EnSentenceStructureClause> clauseById = {
      for (final EnSentenceStructureClause clause in orderedClauses)
        if (clause.clauseId != null) clause.clauseId!: clause,
    };
    final Map<int, List<EnSentenceStructureClause>> childrenMap = _buildChildrenMap(orderedClauses, clauseById);
    final Set<int> reservedConjunctionTokenIds = _reservedStandaloneConjunctionTokenIds(
      orderedClauses,
      mode,
    );
    List<SentenceChunkLayoutRow> rows = [];
    for (final EnSentenceStructureClause clause in orderedClauses) {
      final int depth = _clauseDepth(clause, clauseById);
      final List<EnSentenceStructureConjunction> conjunctions = _standaloneConjunctions(clause, mode)
        ..sort((a, b) => (a.textReference?.start ?? 0).compareTo(b.textReference?.start ?? 0));
      for (final EnSentenceStructureConjunction conjunction in conjunctions) {
        rows.add(
          SentenceChunkLayoutRow(
            kind: SentenceChunkLayoutRowKind.conjunction,
            clause: clause,
            conjunction: conjunction,
            depth: depth,
            pills: _buildConjunctionPills(
              clause: clause,
              conjunction: conjunction,
              tokens: orderedTokens,
              surface: surface,
            ),
          ),
        );
      }
      rows.add(
        SentenceChunkLayoutRow(
          kind: SentenceChunkLayoutRowKind.clause,
          clause: clause,
          conjunction: null,
          depth: depth,
          pills: _buildClausePills(
            clause: clause,
            tokens: orderedTokens,
            reservedConjunctionTokenIds: reservedConjunctionTokenIds,
            childrenMap: childrenMap,
            surface: surface,
            mode: mode,
          ),
        ),
      );
    }
    rows = _placeOrphanResidualRows(rows, orderedTokens, surface);
    return SentenceChunkLayoutResult(
      columns: columns,
      rows: rows,
    );
  }

  static List<SentenceChunkLayoutColumn> _buildFallbackColumns(
    List<EnSentenceStructureToken> tokens,
  ) {
    return tokens.map((token) {
      final int tokenId = token.id ?? 0;
      return SentenceChunkLayoutColumn(
        label: token.text ?? '',
        tokenIds: [tokenId],
        startChar: 0,
        endChar: 0,
      );
    }).toList();
  }

  static _SurfaceIndex? _buildSurfaceIndex(
    String? sentence,
    List<EnSentenceStructureToken> tokens,
  ) {
    if ((sentence ?? '').isEmpty || tokens.isEmpty) return null;
    final String text = sentence!;
    final List<SentenceChunkLayoutTokenSpan> spans = _alignTokensToSentence(text, tokens);
    final Map<int, SentenceChunkLayoutTokenSpan> spanMap = {
      for (final SentenceChunkLayoutTokenSpan span in spans) span.id: span,
    };
    final List<SentenceChunkLayoutColumn> columns = [];
    for (final EnSentenceStructureToken token in tokens) {
      final int? tokenId = token.id;
      if (tokenId == null) continue;
      final SentenceChunkLayoutTokenSpan? span = spanMap[tokenId];
      if (span == null) continue;
      final SentenceChunkLayoutColumn? previous = columns.isEmpty ? null : columns.last;
      final int? previousTokenId = previous == null || previous.tokenIds.isEmpty
          ? null
          : previous.tokenIds.last;
      final EnSentenceStructureToken? previousToken = previousTokenId == null
          ? null
          : tokens.firstWhere(
              (item) => item.id == previousTokenId,
              orElse: () => EnSentenceStructureToken(),
            );
      final bool isGlued = previous != null &&
          previousToken != null &&
          previousToken.id != null &&
          span.start == previous.endChar &&
          !_isPunctToken(token) &&
          !_isPunctToken(previousToken);
      if (isGlued) {
        previous.tokenIds.add(tokenId);
        previous.endChar = span.end;
        previous.label = text.substring(previous.startChar, previous.endChar);
        continue;
      }
      columns.add(
        SentenceChunkLayoutColumn(
          label: text.substring(span.start, span.end).isEmpty
              ? (token.text ?? '')
              : text.substring(span.start, span.end),
          tokenIds: [tokenId],
          startChar: span.start,
          endChar: span.end,
        ),
      );
    }
    final Map<int, int> columnOf = {};
    for (int columnIndex = 0; columnIndex < columns.length; columnIndex++) {
      for (final int tokenId in columns[columnIndex].tokenIds) {
        columnOf[tokenId] = columnIndex;
      }
    }
    return _SurfaceIndex(
      sentence: text,
      spans: spanMap,
      columns: columns,
      columnOf: columnOf,
    );
  }

  static List<SentenceChunkLayoutTokenSpan> _alignTokensToSentence(
    String sentence,
    List<EnSentenceStructureToken> tokens,
  ) {
    int cursor = 0;
    return tokens.map((token) {
      final int tokenId = token.id ?? 0;
      final List<String> needles = _needlesFor(token.text ?? '');
      final _FoundNeedle? glued = _findNeedle(sentence, needles, cursor);
      if (glued != null && glued.index == cursor) {
        cursor = glued.index + glued.length;
        return SentenceChunkLayoutTokenSpan(
          id: tokenId,
          start: glued.index,
          end: glued.index + glued.length,
          matched: true,
        );
      }
      int searchFrom = cursor;
      while (searchFrom < sentence.length && _isWhitespace(sentence.codeUnitAt(searchFrom))) {
        searchFrom += 1;
      }
      final _FoundNeedle? hit =
          _findNeedle(sentence, needles, searchFrom) ?? _findNeedle(sentence, needles, cursor);
      if (hit == null) {
        final int fallbackLength = _maxNeedleLength(needles, token.text ?? '');
        final int start = searchFrom.clamp(0, sentence.length);
        final int end = (start + fallbackLength).clamp(0, sentence.length);
        cursor = end > cursor ? end : cursor;
        return SentenceChunkLayoutTokenSpan(
          id: tokenId,
          start: start,
          end: end,
          matched: false,
        );
      }
      cursor = hit.index + hit.length;
      return SentenceChunkLayoutTokenSpan(
        id: tokenId,
        start: hit.index,
        end: hit.index + hit.length,
        matched: true,
      );
    }).toList();
  }

  static List<String> _needlesFor(String raw) {
    const Map<String, String> ptbUnescape = {
      '-LRB-': '(',
      '-RRB-': ')',
      '-LSB-': '[',
      '-RSB-': ']',
      '-LCB-': '{',
      '-RCB-': '}',
      '``': '"',
      "''": '"',
    };
    final String text = ptbUnescape[raw] ?? raw;
    if (text.isEmpty) return [];
    final Set<String> values = {text};
    if (text.contains("'") || text.contains('’')) {
      values.add(text.replaceAll('’', "'"));
      values.add(text.replaceAll("'", '’'));
    }
    return values.toList();
  }

  static _FoundNeedle? _findNeedle(
    String sentence,
    List<String> needles,
    int from,
  ) {
    _FoundNeedle? best;
    void consider(int index, int length) {
      if (index < 0) return;
      if (best == null || index < best!.index || (index == best!.index && length > best!.length)) {
        best = _FoundNeedle(index: index, length: length);
      }
    }

    for (final String needle in needles) {
      if (needle.isEmpty) continue;
      consider(sentence.indexOf(needle, from), needle.length);
    }
    if (best != null) return best;
    final String sentenceLower = sentence.toLowerCase();
    for (final String needle in needles) {
      if (needle.isEmpty) continue;
      final String lower = needle.toLowerCase();
      consider(sentenceLower.indexOf(lower, from), lower.length);
    }
    return best;
  }

  static int _maxNeedleLength(List<String> needles, String raw) {
    int maxLength = raw.isEmpty ? 1 : raw.length;
    for (final String needle in needles) {
      if (needle.length > maxLength) {
        maxLength = needle.length;
      }
    }
    return maxLength;
  }

  static bool _isWhitespace(int codeUnit) {
    return codeUnit == 9 || codeUnit == 10 || codeUnit == 13 || codeUnit == 32;
  }

  static bool _isPunctToken(EnSentenceStructureToken token) {
    if ((token.upos ?? '').toUpperCase() == 'PUNCT') return true;
    final String text = (token.text ?? '').trim();
    if (RegExp(r'^[\.,;:!?\u2026]+$').hasMatch(text)) return true;
    return token.pos == '.' || token.pos == ',';
  }

  static Map<int, List<EnSentenceStructureClause>> _buildChildrenMap(
    List<EnSentenceStructureClause> clauses,
    Map<int, EnSentenceStructureClause> clauseById,
  ) {
    final Map<int, List<EnSentenceStructureClause>> data = {};
    for (final EnSentenceStructureClause clause in clauses) {
      final int? parentClauseId = clause.parentClauseId;
      if (parentClauseId == null || !clauseById.containsKey(parentClauseId)) continue;
      final List<EnSentenceStructureClause> children = data[parentClauseId] ?? [];
      children.add(clause);
      data[parentClauseId] = children;
    }
    return data;
  }

  static int _clauseDepth(
    EnSentenceStructureClause clause,
    Map<int, EnSentenceStructureClause> clauseById,
  ) {
    int depth = 0;
    int? parentClauseId = clause.parentClauseId;
    final Set<int> seen = {};
    while (parentClauseId != null && !seen.contains(parentClauseId)) {
      seen.add(parentClauseId);
      final EnSentenceStructureClause? parent = clauseById[parentClauseId];
      if (parent == null) break;
      depth += 1;
      parentClauseId = parent.parentClauseId;
    }
    return depth;
  }

  static Set<int> _reservedStandaloneConjunctionTokenIds(
    List<EnSentenceStructureClause> clauses,
    SentenceChunkAnalysisMode mode,
  ) {
    final Set<int> ids = {};
    for (final EnSentenceStructureClause clause in clauses) {
      for (final EnSentenceStructureConjunction conjunction in _standaloneConjunctions(clause, mode)) {
        final int? start = conjunction.textReference?.start;
        final int? end = conjunction.textReference?.end;
        if (start == null || end == null) continue;
        for (int tokenId = start; tokenId <= end; tokenId++) {
          ids.add(tokenId);
        }
      }
    }
    return ids;
  }

  static List<EnSentenceStructureConjunction> _standaloneConjunctions(
    EnSentenceStructureClause clause,
    SentenceChunkAnalysisMode mode,
  ) {
    final List<EnSentenceStructureConjunction> conjunctions =
        (clause.conjunctions ?? <EnSentenceStructureConjunction?>[])
            .whereType<EnSentenceStructureConjunction>()
            .toList();
    return conjunctions
        .where((conjunction) => !_conjunctionAbsorbedByAnalysis(clause, conjunction, mode))
        .toList();
  }

  static bool _conjunctionAbsorbedByAnalysis(
    EnSentenceStructureClause clause,
    EnSentenceStructureConjunction conjunction,
    SentenceChunkAnalysisMode mode,
  ) {
    final TextReference? conjunctionRef = conjunction.textReference;
    if (conjunctionRef == null) return false;
    final List<TextReference> references = _analysisSegments(clause, mode)
        .map((segment) => segment.textReference)
        .toList();
    for (final TextReference reference in references) {
      if (_spanContains(reference, conjunctionRef, strict: true)) {
        return true;
      }
    }
    return false;
  }

  static bool _spanContains(
    TextReference? outer,
    TextReference? inner, {
    required bool strict,
  }) {
    if (outer?.start == null ||
        outer?.end == null ||
        inner?.start == null ||
        inner?.end == null) {
      return false;
    }
    if (outer!.start! > inner!.start! || outer.end! < inner.end!) return false;
    if (!strict) return true;
    return outer.start! < inner.start! || outer.end! > inner.end!;
  }

  static List<SentenceChunkLayoutPill> _buildConjunctionPills({
    required EnSentenceStructureClause clause,
    required EnSentenceStructureConjunction conjunction,
    required List<EnSentenceStructureToken> tokens,
    required _SurfaceIndex? surface,
  }) {
    final int? start = conjunction.textReference?.start;
    final int? end = conjunction.textReference?.end;
    if (start == null || end == null) return const [];
    return [
      SentenceChunkLayoutPill(
        key: 'conj-${clause.clauseId}-$start-$end',
        startTokenId: start,
        endTokenId: end,
        startColumnIndex: _displayColumnIndex(surface, start),
        endColumnIndex: _displayColumnIndex(surface, end),
        text: _sliceSurface(surface, tokens, start, end),
        label: _conjunctionLabel(conjunction.typeNid),
        kind: SentenceChunkLayoutPillKind.conjunction,
        clauseId: clause.clauseId,
        sourceType: conjunction.typeNid ?? '',
      ),
    ];
  }

  static List<SentenceChunkLayoutPill> _buildClausePills({
    required EnSentenceStructureClause clause,
    required List<EnSentenceStructureToken> tokens,
    required Set<int> reservedConjunctionTokenIds,
    required Map<int, List<EnSentenceStructureClause>> childrenMap,
    required _SurfaceIndex? surface,
    required SentenceChunkAnalysisMode mode,
  }) {
    final int? start = clause.textReference?.start;
    final int? end = clause.textReference?.end;
    if (start == null || end == null) return const [];
    final List<_SentenceChunkAnalysisSegment> segments = _analysisSegments(clause, mode);
    final Set<int> skipTokenIds = {...reservedConjunctionTokenIds};
    _descendantTokenIds(clause, childrenMap).forEach(skipTokenIds.add);
    final List<_SentenceChunkRawPill> rawPills = [];
    for (int tokenId = start; tokenId <= end; tokenId++) {
      if (skipTokenIds.contains(tokenId)) continue;
      final EnSentenceStructureToken? token = tokens.where((item) => item.id == tokenId).firstOrNull;
      if (token == null) continue;
      final _SentenceChunkAnalysisSegment? winner = _winnerForToken(tokenId, segments);
      if (winner != null) {
        rawPills.add(
          _SentenceChunkRawPill(
            startTokenId: tokenId,
            endTokenId: tokenId,
            label: winner.label,
            kind: SentenceChunkLayoutPillKind.analysis,
            clauseId: clause.clauseId,
            sourceType: winner.type,
          ),
        );
        continue;
      }
      rawPills.add(
        _SentenceChunkRawPill(
          startTokenId: tokenId,
          endTokenId: tokenId,
          label: '余文',
          kind: SentenceChunkLayoutPillKind.residual,
          clauseId: clause.clauseId,
          sourceType: residualSourceType,
        ),
      );
    }
    final List<_SentenceChunkRawPill> mergedPills = _mergeRawPills(rawPills);
    return mergedPills.asMap().entries.map((entry) {
      final int index = entry.key;
      final _SentenceChunkRawPill pill = entry.value;
      return SentenceChunkLayoutPill(
        key:
            '${pill.kind.name}-${clause.clauseId}-${pill.startTokenId}-${pill.endTokenId}-$index',
        startTokenId: pill.startTokenId,
        endTokenId: pill.endTokenId,
        startColumnIndex: _displayColumnIndex(surface, pill.startTokenId),
        endColumnIndex: _displayColumnIndex(surface, pill.endTokenId),
        text: _sliceSurface(surface, tokens, pill.startTokenId, pill.endTokenId),
        label: pill.label,
        kind: pill.kind,
        clauseId: clause.clauseId,
        sourceType: pill.sourceType,
      );
    }).toList();
  }

  static Set<int> _descendantTokenIds(
    EnSentenceStructureClause clause,
    Map<int, List<EnSentenceStructureClause>> childrenMap,
  ) {
    final Set<int> ids = {};

    void walk(EnSentenceStructureClause current) {
      final List<EnSentenceStructureClause> children =
          current.clauseId == null ? const [] : (childrenMap[current.clauseId!] ?? const []);
      for (final EnSentenceStructureClause child in children) {
        final int? start = child.textReference?.start;
        final int? end = child.textReference?.end;
        if (start != null && end != null) {
          for (int tokenId = start; tokenId <= end; tokenId++) {
            ids.add(tokenId);
          }
        }
        walk(child);
      }
    }

    walk(clause);
    return ids;
  }

  static List<_SentenceChunkAnalysisSegment> _analysisSegments(
    EnSentenceStructureClause clause,
    SentenceChunkAnalysisMode mode,
  ) {
    if (mode == SentenceChunkAnalysisMode.svoca) {
      final List<EnSentenceStructureSvocaElement> elements =
          (clause.svoca?.elements ?? <EnSentenceStructureSvocaElement?>[])
              .whereType<EnSentenceStructureSvocaElement>()
              .toList();
      return elements
          .asMap()
          .entries
          .where((entry) => entry.value.textReference?.start != null && entry.value.textReference?.end != null)
          .map((entry) {
            final EnSentenceStructureSvocaElement element = entry.value;
            return _SentenceChunkAnalysisSegment(
              id: 'svoca-${clause.clauseId}-${entry.key}',
              type: element.typeNid ?? '',
              label: _namedShortText(
                element.type?.name,
                fallback: _svocaTypeShortLabel(element.typeNid),
              ),
              textReference: element.textReference!,
            );
          })
          .toList();
    }
    final List<EnSentenceStructureChunking> chunkings =
        (clause.chunking ?? <EnSentenceStructureChunking?>[])
            .whereType<EnSentenceStructureChunking>()
            .toList();
    return chunkings
        .asMap()
        .entries
        .where((entry) => entry.value.textReference?.start != null && entry.value.textReference?.end != null)
        .map((entry) {
          final EnSentenceStructureChunking chunk = entry.value;
          return _SentenceChunkAnalysisSegment(
            id: 'chunk-${clause.clauseId}-${entry.key}',
            type: chunk.type ?? '',
            label: _chunkTypeLabel(chunk.type),
            textReference: chunk.textReference!,
          );
        })
        .toList();
  }

  static _SentenceChunkAnalysisSegment? _winnerForToken(
    int tokenId,
    List<_SentenceChunkAnalysisSegment> segments,
  ) {
    final List<_SentenceChunkAnalysisSegment> hits = segments.where((segment) {
      final int start = segment.textReference.start ?? 0;
      final int end = segment.textReference.end ?? 0;
      return tokenId >= start && tokenId <= end;
    }).toList();
    if (hits.isEmpty) return null;
    hits.sort((a, b) {
      final int aSpan = (a.textReference.end ?? 0) - (a.textReference.start ?? 0);
      final int bSpan = (b.textReference.end ?? 0) - (b.textReference.start ?? 0);
      if (aSpan != bSpan) return aSpan.compareTo(bSpan);
      return (b.textReference.start ?? 0).compareTo(a.textReference.start ?? 0);
    });
    return hits.first;
  }

  static List<_SentenceChunkRawPill> _mergeRawPills(List<_SentenceChunkRawPill> pills) {
    final List<_SentenceChunkRawPill> merged = [];
    for (final _SentenceChunkRawPill pill in pills) {
      final _SentenceChunkRawPill? previous = merged.isEmpty ? null : merged.last;
      final bool shouldMerge = previous != null &&
          previous.kind == pill.kind &&
          previous.clauseId == pill.clauseId &&
          previous.sourceType == pill.sourceType &&
          previous.label == pill.label &&
          previous.endTokenId + 1 == pill.startTokenId;
      if (!shouldMerge) {
        merged.add(pill);
        continue;
      }
      merged[merged.length - 1] = _SentenceChunkRawPill(
        startTokenId: previous.startTokenId,
        endTokenId: pill.endTokenId,
        label: previous.label,
        kind: previous.kind,
        clauseId: previous.clauseId,
        sourceType: previous.sourceType,
      );
    }
    return merged;
  }

  static List<SentenceChunkLayoutRow> _placeOrphanResidualRows(
    List<SentenceChunkLayoutRow> rows,
    List<EnSentenceStructureToken> tokens,
    _SurfaceIndex? surface,
  ) {
    final Set<int> covered = {};
    for (final SentenceChunkLayoutRow row in rows) {
      for (final SentenceChunkLayoutPill pill in row.pills) {
        for (int tokenId = pill.startTokenId; tokenId <= pill.endTokenId; tokenId++) {
          covered.add(tokenId);
        }
      }
    }
    final List<int> orphanTokenIds = [];
    for (final EnSentenceStructureToken token in tokens) {
      final int? tokenId = token.id;
      if (tokenId == null || covered.contains(tokenId)) continue;
      orphanTokenIds.add(tokenId);
    }
    final List<List<int>> groups = [];
    for (final int tokenId in orphanTokenIds) {
      final List<int>? previous = groups.isEmpty ? null : groups.last;
      if (previous != null && previous.last == tokenId - 1) {
        previous.add(tokenId);
        continue;
      }
      groups.add([tokenId]);
    }
    final List<SentenceChunkLayoutRow> orphanRows = groups.map((group) {
      final int start = group.first;
      final int end = group.last;
      return SentenceChunkLayoutRow(
        kind: SentenceChunkLayoutRowKind.residual,
        clause: null,
        conjunction: null,
        depth: 0,
        pills: [
          SentenceChunkLayoutPill(
            key: 'orphan-$start-$end',
            startTokenId: start,
            endTokenId: end,
            startColumnIndex: _displayColumnIndex(surface, start),
            endColumnIndex: _displayColumnIndex(surface, end),
            text: _sliceSurface(surface, tokens, start, end),
            label: '余文',
            kind: SentenceChunkLayoutPillKind.residual,
            clauseId: null,
            sourceType: residualSourceType,
          ),
        ],
      );
    }).toList();
    final List<SentenceChunkLayoutRow> punctRows = [];
    final List<SentenceChunkLayoutRow> normalRows = [];
    for (final SentenceChunkLayoutRow row in orphanRows) {
      final String text = row.pills.map((pill) => pill.text).join(' ');
      if (_isPunctSurface(text)) {
        punctRows.add(row);
      } else {
        normalRows.add(row);
      }
    }
    final List<SentenceChunkLayoutRow> insertedRows = _insertRowsByStart(rows, normalRows);
    return _attachTrailingPunct(insertedRows, punctRows);
  }

  static List<SentenceChunkLayoutRow> _insertRowsByStart(
    List<SentenceChunkLayoutRow> rows,
    List<SentenceChunkLayoutRow> extras,
  ) {
    final List<SentenceChunkLayoutRow> output = [...rows];
    for (final SentenceChunkLayoutRow extra in extras) {
      final int start = _rowStart(extra);
      final int index = output.indexWhere((row) => _rowStart(row) > start);
      if (index < 0) {
        output.add(extra);
      } else {
        output.insert(index, extra);
      }
    }
    return output;
  }

  static List<SentenceChunkLayoutRow> _attachTrailingPunct(
    List<SentenceChunkLayoutRow> rows,
    List<SentenceChunkLayoutRow> punctRows,
  ) {
    final List<SentenceChunkLayoutRow> output = [...rows];
    for (final SentenceChunkLayoutRow punctRow in punctRows) {
      final int? start = punctRow.pills.firstOrNull?.startTokenId;
      if (start == null) continue;
      int? hostIndex;
      for (int index = output.length - 1; index >= 0; index--) {
        final SentenceChunkLayoutRow row = output[index];
        final bool matches = row.pills.any((pill) => pill.endTokenId == start - 1);
        if (matches) {
          hostIndex = index;
          break;
        }
      }
      if (hostIndex == null && output.isNotEmpty) {
        hostIndex = output.length - 1;
      }
      if (hostIndex == null) {
        output.add(punctRow);
        continue;
      }
      final SentenceChunkLayoutRow host = output[hostIndex];
      final List<SentenceChunkLayoutPill> mergedPills = [...host.pills, ...punctRow.pills]
        ..sort((a, b) => a.startTokenId.compareTo(b.startTokenId));
      output[hostIndex] = SentenceChunkLayoutRow(
        kind: host.kind,
        clause: host.clause,
        conjunction: host.conjunction,
        depth: host.depth,
        pills: mergedPills,
      );
    }
    return output;
  }

  static int _rowStart(SentenceChunkLayoutRow row) {
    if (row.kind == SentenceChunkLayoutRowKind.conjunction) {
      return row.conjunction?.textReference?.start ?? 1 << 30;
    }
    if (row.kind == SentenceChunkLayoutRowKind.clause) {
      return row.clause?.textReference?.start ?? 1 << 30;
    }
    return row.pills.firstOrNull?.startTokenId ?? 1 << 30;
  }

  static bool _isPunctSurface(String text) {
    return RegExp(r'^[\.,;:!?\u2026]+$').hasMatch(text.trim());
  }

  static int _displayColumnIndex(_SurfaceIndex? surface, int tokenId) {
    if (surface == null) return tokenId - 1;
    return surface.columnOf[tokenId] ?? (tokenId - 1);
  }

  static String _sliceSurface(
    _SurfaceIndex? surface,
    List<EnSentenceStructureToken> tokens,
    int start,
    int end,
  ) {
    final List<EnSentenceStructureToken> matchedTokens = tokens
        .where((token) {
          final int? tokenId = token.id;
          return tokenId != null && tokenId >= start && tokenId <= end;
        })
        .toList()
      ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    if (matchedTokens.isEmpty) return '';
    if (surface != null) {
      final SentenceChunkLayoutTokenSpan? first = surface.spans[matchedTokens.first.id];
      final SentenceChunkLayoutTokenSpan? last = surface.spans[matchedTokens.last.id];
      if (first != null && last != null && last.end >= first.start) {
        return surface.sentence.substring(first.start, last.end);
      }
    }
    return matchedTokens
        .map((token) => token.text ?? '')
        .where((text) => text.isNotEmpty)
        .join(' ');
  }

  static String _conjunctionLabel(String? typeNid) {
    switch (typeNid) {
      case 'coordinating':
      case 'coordinating_link_to_sibling':
        return '并列';
      case 'leading_conjunctive_adverb':
        return '连接副词';
      case 'leading_interjection':
        return '感叹';
      default:
        return '从属';
    }
  }

  static String _chunkTypeLabel(String? type) {
    switch (type) {
      case 'NP':
        return '名词短语';
      case 'VP':
        return '动词短语';
      case 'PP':
        return '介词短语';
      case 'ADJP':
        return '形容词短语';
      case 'ADVP':
        return '副词短语';
      case 'SBAR':
        return '从句';
      case 'WHNP':
        return '疑问名词短语';
      default:
        return type?.isNotEmpty == true ? type! : '语块';
    }
  }

  static String _svocaTypeShortLabel(String? typeNid) {
    switch ((typeNid ?? '').toLowerCase()) {
      case 's':
        return '主语';
      case 'v':
        return '谓语';
      case 'o':
        return '宾语';
      case 'oi':
        return '间接宾语';
      case 'od':
        return '直接宾语';
      case 'c':
        return '补语';
      case 'c_subj':
        return '主语补语';
      case 'c_obj':
        return '宾语补语';
      case 'a':
        return '状语';
      case 'pred_opt':
        return '谓语操作成分';
      case 'neg_part':
        return '否定成分';
      case 'voc':
        return '呼语';
      case 'disj':
        return '评注性状语';
      case 'conj':
        return '连接性状语';
      default:
        return typeNid?.isNotEmpty == true ? typeNid! : '成分';
    }
  }

  static String _namedShortText(
    List<LanguageText?>? texts, {
    required String fallback,
  }) {
    final List<LanguageText> list =
        (texts ?? <LanguageText?>[]).whereType<LanguageText>().where((item) => (item.text ?? '').trim().isNotEmpty).toList();
    for (final LanguageText item in list) {
      if ((item.lang ?? '').toLowerCase() == 'zh') return (item.text ?? '').trim();
    }
    for (final LanguageText item in list) {
      if ((item.lang ?? '').toLowerCase() == 'en') return (item.text ?? '').trim();
    }
    return list.isNotEmpty ? (list.first.text ?? '').trim() : fallback;
  }
}

class _FoundNeedle {
  final int index;
  final int length;

  const _FoundNeedle({
    required this.index,
    required this.length,
  });
}
