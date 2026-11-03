import 'package:flutter/material.dart';
import 'package:themed/themed.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';

class ElementsSentenceAnalysisGridViewModel{
  List<ElementsSentenceAnalysisGridViewWordModel> words;
  String topTag;
  String bottomTag;
  bool isConjunction; // 是否为连接词
  TextReference? textReference; // 文本引用
  bool show;

  ElementsSentenceAnalysisGridViewModel({
    required this.words,
    required this.topTag,
    required this.bottomTag,
    this.isConjunction = false,
    this.textReference,
    required this.show,
  });
}

class ElementsSentenceAnalysisGridViewWordModel{
  String text;
  bool isPunctuation;
  int? wordIndex; // 单词在句子中的索引

  ElementsSentenceAnalysisGridViewWordModel({
    required this.text,
    required this.isPunctuation,
    this.wordIndex,
  });
}

class ElementsSentenceAnalysisGridViewWidget extends StatefulWidget {
  final int selectIndex;
  final void Function(int index)? onSerialNumber;
  final void Function(int sentenceIndex, int sentenceWordsIndex, int wordIndex, TextReference? textReference, bool isConjunction)? onWord;
  final List<CardSentencesDetilsEntityClauses?>? clauses;
  final List<LanguageConfigColorEntityInfo?>? colorConfigs;
  final List<LanguageConfigColorEntityInfo?>? clausesColorConfigs;
  final String? sentenceText;
  /// 0：语块分析(Chunking) 1：成份分析(SVOCA)
  final int structureTabControllerIndex;
  /// 句子分析 表 网格视图
  const ElementsSentenceAnalysisGridViewWidget({
    super.key, 
    this.selectIndex = 0, 
    this.onSerialNumber, 
    this.onWord, 
    this.clauses,
    this.clausesColorConfigs,
    this.colorConfigs,
    this.sentenceText,
    this.structureTabControllerIndex = 0,
  });

  @override
  State<ElementsSentenceAnalysisGridViewWidget> createState() => _ElementsSentenceAnalysisGridViewWidgetState();
}

class _ElementsSentenceAnalysisGridViewWidgetState extends State<ElementsSentenceAnalysisGridViewWidget> {

  @override
  void initState() {
    super.initState();
  }

  List<List<ElementsSentenceAnalysisGridViewModel>> _getSegments(int index){
    // 根据当前选择的分析模式，返回不同的分段数据
    if (widget.structureTabControllerIndex == 0) {
      // 语块分析模式 (Chunking)
      return _getChunkings(index);
    } else {
      // 成分分析模式 (SVOCA)
      return _getSvoca(index);
    }
  }
  
  List<List<ElementsSentenceAnalysisGridViewModel>> _getChunkings(int index){
    List<CardSentencesDetilsEntityClausesChunking?> chunking = widget.clauses?[index]?.chunking ?? [];
    List<List<ElementsSentenceAnalysisGridViewModel>> models = [];
    
    // 处理连接词
    List<CardSentencesDetilsEntityClausesConjunctions?> conjunctions = widget.clauses?[index]?.conjunctions ?? [];
    for (var conjunction in conjunctions) {
      if (conjunction == null || conjunction.textReference == null) continue;
      models.addAll([_getConjunctionItem(conjunction)]);
    }
    
    // 处理语块
    for(int i = 0; i < chunking.length; i++){
      CardSentencesDetilsEntityClausesChunking? chunkingItem = chunking[i];
      if(chunkingItem == null) continue;
      List<ElementsSentenceAnalysisGridViewModel> resps = _getChunkingsItem(chunkingItem);
      models.add(resps);
    }

    return models;
  }

  List<ElementsSentenceAnalysisGridViewModel> _getChunkingsItem(CardSentencesDetilsEntityClausesChunking chunkingItem){
    List<ElementsSentenceAnalysisGridViewWordModel> words = _getWords();

    List<ElementsSentenceAnalysisGridViewModel> models = [];
    TextReference? textReference = chunkingItem.textReference;
    if(textReference == null) return models;
    int start = textReference.start??0;
    int end = textReference.end??0;
    
    // 确保索引在有效范围内
    if (start <= 0 || end > words.length || start > end) return models;
    
    String topTag = chunkingItem.type ?? "";
    List<ElementsSentenceAnalysisGridViewWordModel> fistWords = words.sublist(0, start - 1);
    List<ElementsSentenceAnalysisGridViewWordModel> seWords = words.sublist(start - 1, end);
    List<ElementsSentenceAnalysisGridViewWordModel> lastWords = words.sublist(end);

    if(fistWords.isNotEmpty){
      models.add(
        ElementsSentenceAnalysisGridViewModel(
          words: fistWords,
          topTag: topTag,
          bottomTag: "",
          isConjunction: false,
          textReference: null,
          show: false,
        ),
      );
    }

    models.add(
      ElementsSentenceAnalysisGridViewModel(
        words: seWords,
        topTag: topTag,
        bottomTag: "",
        isConjunction: false,
        textReference: textReference,
        show: true,
      ),
    );

    if(lastWords.isNotEmpty){
      models.add(
        ElementsSentenceAnalysisGridViewModel(
          words: lastWords,
          topTag: topTag,
          bottomTag: "",
          isConjunction: false,
          textReference: null,
          show: false,
        ),
      );
    }
    
    return models;
  }
  
  // 处理连接词
  List<ElementsSentenceAnalysisGridViewModel> _getConjunctionItem(CardSentencesDetilsEntityClausesConjunctions conjunction) {
    List<ElementsSentenceAnalysisGridViewWordModel> words = _getWords();
    List<ElementsSentenceAnalysisGridViewModel> models = [];
    TextReference? textReference = conjunction.textReference;
    if(textReference == null) return models;
    int start = textReference.start??0;
    int end = textReference.end??0;
    
    // 确保索引在有效范围内
    if (start <= 0 || end > words.length || start > end) return models;
    
    String bottomTag = conjunction.type ?? "";
    List<ElementsSentenceAnalysisGridViewWordModel> fistWords = words.sublist(0, start - 1);
    List<ElementsSentenceAnalysisGridViewWordModel> seWords = words.sublist(start - 1, end);
    List<ElementsSentenceAnalysisGridViewWordModel> lastWords = words.sublist(end);

    if(fistWords.isNotEmpty){
      models.add(
        ElementsSentenceAnalysisGridViewModel(
          words: fistWords,
          topTag: "",
          bottomTag: bottomTag,
          isConjunction: false,
          textReference: null,
          show: false,
        ),
      );
    }

    models.add(
      ElementsSentenceAnalysisGridViewModel(
        words: seWords,
        topTag: "",
        bottomTag: bottomTag,
        isConjunction: true,
        textReference: textReference,
        show: true,
      ),
    );

    if(lastWords.isNotEmpty){
      models.add(
        ElementsSentenceAnalysisGridViewModel(
          words: lastWords,
          topTag: "",
          bottomTag: bottomTag,
          isConjunction: false,
          textReference: null,
          show: false,
        ),
      );
    }
    
    return models;
  }
  
  // 处理SVOCA分析
  List<List<ElementsSentenceAnalysisGridViewModel>> _getSvoca(int index) {
    CardSentencesDetilsEntityClausesSvoca? svoca = widget.clauses?[index]?.svoca;
    if (svoca == null) return [];
    
    List<List<ElementsSentenceAnalysisGridViewModel>> models = [];
    
    // 处理连接词
    List<CardSentencesDetilsEntityClausesConjunctions?> conjunctions = widget.clauses?[index]?.conjunctions ?? [];
    for (var conjunction in conjunctions) {
      if (conjunction == null || conjunction.textReference == null) continue;
      models.addAll([_getConjunctionItem(conjunction)]);
    }
    
    // 处理SVOCA元素
    List<CardSentencesDetilsEntityClausesSvocaElements?> elements = svoca.elements ?? [];
    for (var element in elements) {
      if (element == null || element.textReference == null) continue;
      models.add(_getSvocaElementItem(element));
    }
    
    return models;
  }
  
  // 处理SVOCA元素
  List<ElementsSentenceAnalysisGridViewModel> _getSvocaElementItem(CardSentencesDetilsEntityClausesSvocaElements element) {
    List<ElementsSentenceAnalysisGridViewWordModel> words = _getWords();
    List<ElementsSentenceAnalysisGridViewModel> models = [];
    TextReference? textReference = element.textReference;
    if(textReference == null) return models;
    int start = textReference.start??0;
    int end = textReference.end??0;
    
    // 确保索引在有效范围内
    if (start <= 0 || end > words.length || start > end) return models;
    
    String topTag = element.type?.toUpperCase() ?? "";
    List<ElementsSentenceAnalysisGridViewWordModel> fistWords = words.sublist(0, start - 1);
    List<ElementsSentenceAnalysisGridViewWordModel> seWords = words.sublist(start - 1, end);
    List<ElementsSentenceAnalysisGridViewWordModel> lastWords = words.sublist(end);

    if(fistWords.isNotEmpty){
      models.add(
        ElementsSentenceAnalysisGridViewModel(
          words: fistWords,
          topTag: topTag,
          bottomTag: "",
          isConjunction: false,
          textReference: null,
          show: false,
        ),
      );
    }

    models.add(
      ElementsSentenceAnalysisGridViewModel(
        words: seWords,
        topTag: topTag,
        bottomTag: "",
        isConjunction: false,
        textReference: textReference,
        show: true,
      ),
    );

    if(lastWords.isNotEmpty){
      models.add(
        ElementsSentenceAnalysisGridViewModel(
          words: lastWords,
          topTag: topTag,
          bottomTag: "",
          isConjunction: false,
          textReference: null,
          show: false,
        ),
      );
    }
    
    return models;
  }

  /// 拆分句子 标点符号也要单独占一条
  List<ElementsSentenceAnalysisGridViewWordModel> _getWords(){
    List<String> words = widget.sentenceText?.split(" ") ?? [];
    List<ElementsSentenceAnalysisGridViewWordModel> newWords = [];
    List<String> punctuation = [".", "!", "?", ";", ":", ",", "-"];
    int wordIndex = 0;
    
    for(int i = 0; i < words.length; i++){
      String word = words[i];
      if(word.isEmpty) continue;
      
      bool containsPunctuation = punctuation.any((p) => word.contains(p));
      if(containsPunctuation){
        List<String> splitWords = splitByPunctuation(word, punctuation);
        for(int i = 0; i < splitWords.length; i++){
          String splitWord = splitWords[i];
          if(splitWord.isEmpty) continue;

          bool containsPunctuation = punctuation.any((p) => splitWord.contains(p));
          newWords.add(ElementsSentenceAnalysisGridViewWordModel(
            text: splitWord,
            isPunctuation: containsPunctuation,
            wordIndex: wordIndex++,
          ));
        }
       
      } else {
        // 普通单词
        newWords.add(ElementsSentenceAnalysisGridViewWordModel(
          text: word,
          isPunctuation: false,
          wordIndex: wordIndex++,
        ));
      }
    } 
    return newWords;
  }

  List<String> splitByPunctuation(String text, List<String> punctuation) {
    if (text.isEmpty) return [];

    // 1. 转义标点符号，构建正则表达式（使用捕获组）
    String pattern = punctuation.map((p) => RegExp.escape(p)).join('|');
    RegExp regex = RegExp('($pattern)'); // 关键：用括号捕获标点符号

    // 2. 用 splitMapJoin 拆分并保留标点
    List<String> parts = [];
    text.splitMapJoin(
      regex,
      onMatch: (m) {
        parts.add(m.group(0)!); // 标点符号
        return '';
      },
      onNonMatch: (s) {
        if (s.isNotEmpty) parts.add(s); // 非标点部分
        return '';
      },
    );

    return parts;
  }

  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 24.wMin),
      scrollDirection: Axis.horizontal,
      child: Column(
        spacing: 24.wMin,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(widget.clauses?.length ?? 0, (index){
          return _buildSentenceAnalysisItemWidget(index, widget.clauses?[index]);
        }),
      ),
    );
  }


  Widget _buildSentenceAnalysisItemWidget(int sentenceIndex, CardSentencesDetilsEntityClauses? clause){
    if(clause == null) return Container();

    // 根据当前选择的分析模式获取不同的数据
    List<List<ElementsSentenceAnalysisGridViewModel>> models = _getSegments(sentenceIndex);
    
    return Row(
      spacing: 8.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSerialNumberWidget(sentenceIndex),
        Column(
          spacing: 8.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 子句类型标签
            StatusSentenceChunksTagWidget(value: clause.type ?? "", type: clause.type, colorConfigs: widget.clausesColorConfigs),
            // 分段内容
            Stack(
              alignment: Alignment.centerLeft,
              children: List.generate(models.length, (sIndex){
                return Row(
                  // spacing: 4.wMin,
                  children: List.generate(models[sIndex].length, (index){
                    return _buildSentenceAnalysisItemContentWidget(models[sIndex][index], sentenceIndex, sIndex);
                  }),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSentenceAnalysisItemContentWidget(ElementsSentenceAnalysisGridViewModel data, int sentenceIndex, int wordsIndex){
 
    LanguageConfigColorModel? tagColorConfig = StatusUtils.getConfigColor(widget.colorConfigs, data.topTag);
    LanguageConfigColorModel? bottomTagColorConfig = StatusUtils.getConfigColor(widget.colorConfigs, data.bottomTag);
    
    return Opacity(
      opacity: data.show ? 1 : 0,
      child: IgnorePointer(
        ignoring: !data.show,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部标签
                SizedBox(
                  height: 30.wMin,
                  child: Visibility(
                    visible: data.topTag.isNotEmpty,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 2.wMin),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tagColorConfig?.color?.bgColor??AppTheme.cBgBrand.addOpacity(0.1),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4.wMin)),
                      ),
                      child: Text(
                        data.topTag,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: tagColorConfig?.color?.textColor??AppTheme.cBgBrand,
                        ),
                      ),
                    ),
                  ),
                ),
                // 单词内容
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(data.words.length, (index){
                        return TapScaleWidget(
                          onTap: (){
                            // 点击单词时触发回调，传递单词索引、分段类型和是否为连接词
                            if (data.words[index].wordIndex != null) {
                              widget.onWord?.call(
                                sentenceIndex,
                                wordsIndex,
                                data.words[index].wordIndex!,
                                data.textReference,
                                data.isConjunction
                              );
                            }
                          },
                          sclae: 1,
                          child: AnimatedContainer(
                            alignment: Alignment.center,
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                            decoration: BoxDecoration(
                              color: tagColorConfig?.color?.bgColor??AppTheme.cBgBrand.addOpacity(0.2),
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(index == 0 ? 4.wMin : 0),
                                right: Radius.circular(index == data.words.length - 1 ? 4.wMin : 0),
                              ),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 35.wMin,
                            ),
                            child: Text(
                              data.words[index].text,
                              style: TextStyle(
                                fontSize: 28.wMin,
                                fontWeight: FontWeight.w600,
                                color: tagColorConfig?.color?.textColor??AppTheme.cBgBrand,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    
                  ],
                ),
              ],
            ),
            // 底部标签
            Positioned(
              bottom: -30.wMin,
              child: SizedBox(
                height: 30.wMin,
                child: Visibility(
                  visible: data.bottomTag.isNotEmpty,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 2.wMin),
                    decoration: BoxDecoration(
                      color: bottomTagColorConfig?.color?.bgColor??AppTheme.cBgBrand.addOpacity(0.1),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4.wMin)),
                    ),
                    child: Text(
                      data.bottomTag,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: tagColorConfig?.color?.textColor??AppTheme.cBgBrand,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSerialNumberWidget(int index){
    

    return TapScaleWidget(
      onTap: (){
        widget.onSerialNumber?.call(index);
      },
      sclae: 1.1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        alignment: Alignment.center,
        constraints: BoxConstraints(
          minWidth: 36.wMin,
          minHeight: 36.wMin,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.selectIndex == index ? AppTheme.cFeedbackInfoBackground : AppTheme.cFeedbackDefaultBackground,
        ),
        child: Text(
          "${index + 1}",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: widget.selectIndex == index ? AppTheme.cFeedbackInfoText : AppTheme.cFeedbackDefaultText,
          ),
        ),
      ),
    );
  }

}