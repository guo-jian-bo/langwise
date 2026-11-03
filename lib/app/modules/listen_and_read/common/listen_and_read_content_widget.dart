
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/enum/enum.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../models/reading_ass_model.dart';

class ListenAndReadContentWidget extends StatelessWidget {
  final double contentFontSizeMultiple;
  final LangPreference translateStatus;
  final List<ReadingAssParagraphModel> readingAssTextList;
  final bool isShowEvelResultColor;
  final double paddingTop;
  final void Function(ReadingAssSentenceModel sentence)? clickSelectSentence;
  final void Function(ReadingAssSentenceModel sentence, ReadingAssWordModel word, BuildContext context)? hoverSelectWord;
  const ListenAndReadContentWidget({
    super.key, 
    this.contentFontSizeMultiple = 1.0,
    required this.translateStatus,
    required this.readingAssTextList,
    this.isShowEvelResultColor = false,
    this.clickSelectSentence,
    this.paddingTop = 0,
    this.hoverSelectWord,
  });

  @override
  Widget build(BuildContext context) {
    if(translateStatus == LangPreference.none){
      return _buildListeningModeWidget(context);
    }
    return _buildSentenceContent();
  }

  /// 听力模式
  Widget _buildListeningModeWidget(BuildContext context){
    if(translateStatus != LangPreference.none) return Container();
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "纯听力模式",
            style: TextStyle(
              color: AppTheme.cTextSecondary.color,
              fontSize: 36.wMin,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            "文本已隐藏",
            style: TextStyle(
              color: AppTheme.cTextSecondary.color,
              fontSize: 28.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// 句子内容
  Widget _buildSentenceContent() {
    if(translateStatus == LangPreference.none) return Container();

    return LayoutBuilder(
      builder: (context, constraints) {
        double maxHeight = constraints.maxHeight;
        return Stack(
          children: [
            _buildContentListWidget(context),
            Visibility(
              visible: translateStatus == LangPreference.bilingual,
              child: Positioned(
                right: 600.wMin + 64.wMin + 24.wMin,
                height: maxHeight,
                child: _buildSpaceContent(),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 原文模式
  Widget _buildContentListWidget(BuildContext context){
    List<ReadingAssParagraphModel> paragraphs = readingAssTextList;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 28.wMin + paddingTop,
        left: 64.wMin,
        right: 64.wMin,
        bottom: 28.wMin + 200.wMin + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        spacing: 36.wMin,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(paragraphs.length, (index){
      
          return _buildContentListItemWidget(paragraphs[index]);
      
        }),
      ),
    );
  }


  /// 文字内容
  Widget _buildContentListItemWidget(ReadingAssParagraphModel paragraphs){
    if(translateStatus == LangPreference.translation){
      return Container(
        key: paragraphs.paragrapKey,
        child: Text.rich(
          TextSpan(
            children: _buildTranslationParagraph(paragraphs),
          ),
        ),
      );
    }else if(translateStatus == LangPreference.original){
      return Wrap(
        key: paragraphs.paragrapKey,
        alignment: WrapAlignment.start,
        runSpacing: 4.wMin,
        children: _buildSentenceWidgets(paragraphs.sentences),
      );
    }
    
    return Row(
      key: paragraphs.paragrapKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 48.wMin,
      children: [
    
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.start,
            runSpacing: 4.wMin,
            children: _buildSentenceWidgets(paragraphs.sentences),
          ),
        ),
        
    
        Container(
          width: 600.wMin,
          margin: EdgeInsets.only(top: 10.wMin),
          child: Text.rich(
            TextSpan(
              children: _buildTranslationParagraph(paragraphs),
            ),
          ),
        ),
        
      ],
    );
  }


  List<Widget> _buildSentenceWidgets(List<ReadingAssSentenceModel> sentences){
    List<Widget> widgets = [];
    for(int i = 0; i < sentences.length; i++){
      for(int j = 0; j < sentences[i].words.length; j++){
        
        if(i != 0 && j == 0){
          widgets.add(SizedBox(width: 10.wMin));
        }
        widgets.add(_buildWordContent(sentences[i], sentences[i].words[j]));
      }
    }
    return widgets;
  }


  List<InlineSpan> _buildTranslationParagraph(ReadingAssParagraphModel paragraphs){
    List<InlineSpan> widgets = [];
    
    for(int j = 0; j < paragraphs.sentences.length; j++){
      widgets.add(_buildSentenceTranslation(paragraphs.sentences[j]));
    }

    return widgets;
  }

  /// 释义内容
  InlineSpan _buildSentenceTranslation(ReadingAssSentenceModel sentence){
    return TextSpan(
      style: TextStyle(
        fontSize: (30 * contentFontSizeMultiple).wMin,
        color: AppTheme.cTextSecondary.color,
        fontWeight: FontWeight.w300,
        backgroundColor: AppTheme.cTextBrand.color.withValues(alpha: sentence.isSentenceHighlight ? 0.2 : 0),
        fontFamily: "LXGWWenKaiGBScreen",
      ),
      children: [
        TextSpan(
          text: sentence.sentenceTranslate?.ass.text ?? "",
          recognizer: TapGestureRecognizer()..onTap = () {
            clickSelectSentence?.call(sentence);
          },
        ),
      ],
    );

  }

  /// 单词内容
  Widget _buildWordContent(ReadingAssSentenceModel sentence, ReadingAssWordModel word){

    Color wordColor = AppTheme.cTextPrimary.color;
    if(word.isFullTextEvaluationStatus != null && isShowEvelResultColor){
      wordColor = EvelResultScoreEnum.getJudgmentColor(word.isFullTextEvaluationStatus!);
    }


    TextStyle style = TextStyle(
      color: wordColor,
      fontSize: (50 * contentFontSizeMultiple).wMin,
      fontWeight: FontWeight.w300,
      height: 1.2,
      fontFamily: "SourceSerif4",
    );

    return TapScaleWidget(
      onTap: (){
        clickSelectSentence?.call(sentence);
      },
      sclae: 1,
      child: Container(
        color: AppTheme.cTextBrand.color.withValues(alpha: sentence.isSentenceHighlight ? 0.2 : 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(word.ass.leftSpace, style: style),
            Builder(
              builder: (ctx) {
                return TapScaleLongRightWidget(
                  onLongSecondaryTap: (globalPosition, localPosition) {
                    hoverSelectWord?.call(sentence, word, ctx);
                  },
                  sclae: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.wMin),
                      color: AppTheme.cTextBrand.color.withValues(alpha: word.ass.isRead || word.isHighlight ? 0.8 : 0),
                    ),
                    child: Text(word.ass.text, style: style),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

    /// 中间许仙
  Widget _buildSpaceContent(){
    return DottedBorder(
      borderType: BorderType.RRect,
      dashPattern: [5.wMin, 3.5.wMin],
      color: AppTheme.cBorderTertiary.color,
      strokeWidth: 1.wMin,
      customPath: (size) => Path()
        ..moveTo(0, size.width)
        ..relativeLineTo(0, size.height),
      padding: EdgeInsets.zero,
      child: Container(),
    );
  }





}