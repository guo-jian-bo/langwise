import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/language.dart';
import 'package:langwise/common/https/zhenxie.dart';
import 'package:langwise/theme/theme_utils.dart';
import 'package:langwise/utils/utils.dart';

import '../zhenxie_composition_stages/models/zhenxie_composition_discourse_models.dart';

final Map<String, ParagraphRhetoricalEntityList> zhenxieBeatMap = <String, ParagraphRhetoricalEntityList>{};
final List<String> zhenxieBeatOrderList = <String>[];
final Map<String, CompositionGenreSummaryModel> zhenxieGenreMap = <String, CompositionGenreSummaryModel>{};
final Map<String, Color> zhenxieGenreColorMap = <String, Color>{};

Future<void>? _zhenxieBeatFuture;

Future<void> ensureZhenxieBeatData() async {
  if (zhenxieBeatMap.isNotEmpty && zhenxieBeatOrderList.isNotEmpty && zhenxieGenreMap.isNotEmpty) return;
  if (_zhenxieBeatFuture != null) {
    await _zhenxieBeatFuture;
    return;
  }
  _zhenxieBeatFuture = _loadZhenxieBeatData();
  await _zhenxieBeatFuture;
}

Future<void> _loadZhenxieBeatData() async {
  try {
    final ParagraphRhetoricalEntity? beatEntity = await LanguageUtil.getParagraphRhetoricalList();
    updateZhenxieBeatData(beatEntity);
    final Map<String, dynamic>? homeResponse = await ZhenxieRequest.getCompositionDiscourseHome();
    updateZhenxieGenreData(
      homeResponse == null ? null : CompositionDiscourseHomeModel.fromJson(homeResponse),
    );
  } finally {
    _zhenxieBeatFuture = null;
  }
}

void updateZhenxieBeatData(ParagraphRhetoricalEntity? beatEntity) {
  final List<ParagraphRhetoricalEntityList> beatList = (beatEntity?.list ?? const <ParagraphRhetoricalEntityList?>[])
      .whereType<ParagraphRhetoricalEntityList>()
      .toList();
  zhenxieBeatOrderList
    ..clear()
    ..addAll(
      beatList.map((item) => item.nid ?? '').where((item) => item.isNotEmpty),
    );
  zhenxieBeatMap
    ..clear()
    ..addEntries(
      beatList.where((item) => (item.nid ?? '').isNotEmpty).map((item) => MapEntry(item.nid!, item)),
    );
}

void updateZhenxieGenreData(CompositionDiscourseHomeModel? home) {
  zhenxieGenreMap.clear();
  zhenxieGenreColorMap.clear();
  if (home == null) return;
  final String themeName = ThemeUtils.isCurrentTheme('DARK') ? 'DARK' : 'LIGHT';
  for (final CompositionGenreSummaryModel item in home.genres) {
    final String nid = item.genre?.nid ?? '';
    if (nid.isEmpty) continue;
    zhenxieGenreMap[nid] = item;
    final Color? color = ColorUtils.parseColor(item.themeColorCode(themeName));
    if (color != null) zhenxieGenreColorMap[nid] = color;
  }
}

String getZhenxieBeatName(String? beatNid) {
  if (beatNid == 'head') return '文首';
  if (beatNid == 'tail') return '文末';
  final ParagraphRhetoricalEntityList? beat = zhenxieBeatMap[beatNid];
  final List<LanguageText> names = (beat?.name ?? const <LanguageText?>[]).whereType<LanguageText>().toList();
  for (final LanguageText item in names) {
    if (item.lang == 'zh') return item.text ?? '';
  }
  return '';
}

String getZhenxieGenreName(String? genreNid, {String lang = 'zh'}) {
  final List<LanguageText> names = zhenxieGenreMap[genreNid]?.genre?.name ?? const <LanguageText>[];
  for (final LanguageText item in names) {
    if ((item.lang ?? '').toLowerCase() == lang.toLowerCase()) return item.text ?? '';
  }
  return '';
}

Color? getZhenxieGenreColor(String? genreNid) {
  return zhenxieGenreColorMap[genreNid ?? ''];
}
