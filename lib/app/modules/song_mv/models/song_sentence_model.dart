import 'package:flutter/material.dart';

import '../../../../common/entities/entities.dart';
import '../../../../utils/karaoke_subtitles_utils.dart';

class SongSentenceModel {
  List<AssSubtitle> sentence;
  String sentenceText;

  /// 句子开始时间
  int? startTime;

  /// 句子结束时间
  int? endTime;

  /// 当前选中的单词下标
  int selectedWordIndex;

  GlobalKey key;

  AssSubtitle? translate;

  /// 句子中的单词信息
  List<SentenceParsingWordsEntityList>? wordInfos;

  /// 句子对应的知识点
  List<SongEntityListSubContentList> knowledgeList;

  SongSentenceModel({
    required this.sentence,
    required this.sentenceText,
    required this.translate,
    this.wordInfos,
    required this.knowledgeList,
    required this.key,
    this.selectedWordIndex = -1,
    this.startTime,
    this.endTime,
  });
}
