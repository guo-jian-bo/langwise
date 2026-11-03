import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';

class CourseUnitTargetKnowledgeController extends GetxController {
  final String tagText;
  CourseUnitTargetKnowledgeController({required this.tagText});

  /// 知识点原始列表，后续搜索和筛选都基于这份数据派生。
  final RxList<KnowledgeCommonEntityList> allKnowledgeList = <KnowledgeCommonEntityList>[].obs;

  /// 当前展示中的知识点列表，搜索和筛选结果都会落在这里。
  final RxList<KnowledgeCommonEntityList> displayKnowledgeList = <KnowledgeCommonEntityList>[].obs;


  /// 更新知识点原始列表。
  void updateKnowledgeList(List<KnowledgeCommonEntityList> list) {
    allKnowledgeList.assignAll(list);
    displayKnowledgeList.assignAll(list);
  }

  /// 更新当前展示中的知识点列表。
  void updateDisplayKnowledgeList(List<KnowledgeCommonEntityList> list) {
    displayKnowledgeList.assignAll(list);
  }

  /// 原始语法列表，搜索时作为基准数据源。
  final RxList<CourseUnitTargetSentenceGrammarPointEntity> allSentenceGrammarList = <CourseUnitTargetSentenceGrammarPointEntity>[].obs;

  /// 当前展示中的语法列表。
  final RxList<CourseUnitTargetSentenceGrammarPointEntity> sentenceGrammarList = <CourseUnitTargetSentenceGrammarPointEntity>[].obs;

  /// 更新语法原始列表和展示列表。
  void updateSentenceGrammarList(List<CourseUnitTargetSentenceGrammarPointEntity> list) {
    allSentenceGrammarList.assignAll(list);
    sentenceGrammarList.assignAll(list);
  }

  /// 更新当前展示中的语法列表。
  void updateDisplaySentenceGrammarList(List<CourseUnitTargetSentenceGrammarPointEntity> list) {
    sentenceGrammarList.assignAll(list);
  }

  /// 原始词汇知识点列表（单词、短语）。
  List<KnowledgeCommonEntityList> get allVocabularyKnowledgeList => _getKnowledgeListByType(
        CourseUnitTargetEnum.vocabulary,
        sourceList: allKnowledgeList,
      );

  /// 原始句法知识点列表（句子）。
  List<KnowledgeCommonEntityList> get allSyntaxKnowledgeList => _getKnowledgeListByType(
        CourseUnitTargetEnum.syntax,
        sourceList: allKnowledgeList,
      );

  /// 原始听力知识点列表（歌曲）。
  List<KnowledgeCommonEntityList> get allListeningKnowledgeList => _getKnowledgeListByType(
        CourseUnitTargetEnum.listening,
        sourceList: allKnowledgeList,
      );

  /// 原始阅读知识点列表（文章、专栏）。
  List<KnowledgeCommonEntityList> get allReadingKnowledgeList => _getKnowledgeListByType(
        CourseUnitTargetEnum.reading,
        sourceList: allKnowledgeList,
      );

  /// 原始写作知识点列表。
  List<KnowledgeCommonEntityList> get allWritingKnowledgeList => _getKnowledgeListByType(
        CourseUnitTargetEnum.writing,
        sourceList: allKnowledgeList,
      );

  /// 原始综合知识点列表（未命中明确分类的类型）。
  List<KnowledgeCommonEntityList> get allComprehensiveKnowledgeList => _getKnowledgeListByType(
        CourseUnitTargetEnum.comprehensive,
        sourceList: allKnowledgeList,
      );

  /// 词汇知识点列表（单词、短语）。
  List<KnowledgeCommonEntityList> get vocabularyKnowledgeList => _getKnowledgeListByType(CourseUnitTargetEnum.vocabulary);

  /// 句法知识点列表（句子）。
  List<KnowledgeCommonEntityList> get syntaxKnowledgeList => _getKnowledgeListByType(CourseUnitTargetEnum.syntax);

  /// 听力知识点列表（歌曲）。
  List<KnowledgeCommonEntityList> get listeningKnowledgeList => _getKnowledgeListByType(CourseUnitTargetEnum.listening);

  /// 阅读知识点列表（文章、专栏）。
  List<KnowledgeCommonEntityList> get readingKnowledgeList => _getKnowledgeListByType(CourseUnitTargetEnum.reading);

  /// 写作知识点列表。
  List<KnowledgeCommonEntityList> get writingKnowledgeList => _getKnowledgeListByType(CourseUnitTargetEnum.writing);

  /// 综合知识点列表（未命中明确分类的类型）。
  List<KnowledgeCommonEntityList> get comprehensiveKnowledgeList => _getKnowledgeListByType(CourseUnitTargetEnum.comprehensive);

  /// 按综合页分类规则筛出对应知识点。
  List<KnowledgeCommonEntityList> _getKnowledgeListByType(
    CourseUnitTargetEnum type, {
    List<KnowledgeCommonEntityList>? sourceList,
  }) {
    final List<KnowledgeCommonEntityList> currentSourceList = sourceList ?? displayKnowledgeList;
    return currentSourceList.where((item) => getSeparatedKnowledgeType(item.contentTypeEnum) == type).toList();
  }

  /// 将原始知识点类型归并为综合页使用的分类类型。
  CourseUnitTargetEnum getSeparatedKnowledgeType(KnowledgeTypeEnum? type) {
    if (type == KnowledgeTypeEnum.EN_WORD || type == KnowledgeTypeEnum.EN_PHRASE) {
      return CourseUnitTargetEnum.vocabulary;
    } else if (type == KnowledgeTypeEnum.EN_SENTENCE) {
      return CourseUnitTargetEnum.syntax;
    } else if (type == KnowledgeTypeEnum.EN_SONG) {
      return CourseUnitTargetEnum.listening;
    } else if (type == KnowledgeTypeEnum.EN_TEXT || type == KnowledgeTypeEnum.EN_REVEAL) {
      return CourseUnitTargetEnum.reading;
    } else if (type == KnowledgeTypeEnum.EN_COMPOSITION) {
      return CourseUnitTargetEnum.writing;
    }
    return CourseUnitTargetEnum.comprehensive;
  }
}
