import 'package:flutter/material.dart';

import '../../../../common/entities/entities.dart';
import '../../../../utils/karaoke_subtitles_utils.dart';

/// 段落
class ReadingAssParagraphModel {
  /// 段落文本
  String text;

  /// 段落中的句子
  List<ReadingAssSentenceModel> sentences;

  /// 评测的分数
  int? evaluationScore;

  GlobalKey paragrapKey;

  ReadingAssParagraphModel({
    required this.text,
    required this.sentences,
    required this.paragrapKey,
  });
}

/// 句子
class ReadingAssSentenceModel {
  int id;

  List<ReadingAssWordModel> words;

  /// 句子开始时间
  int? startTime;

  /// 句子结束时间
  int? endTime;

  /// 释义
  ReadingAssWordModel? sentenceTranslate;

  /// 句子是否高亮
  bool isSentenceHighlight = false;

  /// 评测的分数
  int? evaluationScore;

  /// 录音文件地址
  String? recordFilePcmPath;

  List<SentenceParsingWordsEntityList>? wordsInfo;

  ReadingAssSentenceModel({
    required this.id,
    required this.words,
    required this.sentenceTranslate,
    this.startTime,
    this.endTime,
  });
}

class ReadingAssWordModel {
  AssSubtitle ass;

  /// 是否单独高亮
  bool isHighlight = false;

  /// 评测结果 [EvelResultScoreEnum]
  String? evaluationStatus;

  /// 全文模式评测结果 [EvelResultScoreEnum]
  String? isFullTextEvaluationStatus;

  SentenceParsingWordsEntityList? wordInfo;

  ReadingAssWordModel({
    required this.ass,
  });
}


