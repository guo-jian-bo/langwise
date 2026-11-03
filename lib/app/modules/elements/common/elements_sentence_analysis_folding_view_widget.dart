
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:themed/themed.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';

class SentenceAnalysisFoldingModel{
  /// 是否展开
  bool isOpen;

  /// 标签
  String tag;

  /// 值
  String value;

  /// 悬浮
  bool isHover;

  List<SentenceAnalysisFoldingModel> children;

  SentenceAnalysisFoldingModel({
    this.isOpen = false,
    this.isHover = false,
    required this.tag,
    required this.value,
    this.children = const [],
  });
}

class ElementsSentenceAnalysisFoldingViewWidget extends StatefulWidget {
  final void Function(int index)? onDetil;
  final String? sentenceText;
  final CardSentencesDetilsEntityClauses? clause;
  final List<LanguageConfigColorEntityInfo?>? colorConfigs;
  /// 句子分析 折叠视图
  const ElementsSentenceAnalysisFoldingViewWidget({super.key, this.onDetil, this.clause, this.sentenceText, this.colorConfigs});

  @override
  State<ElementsSentenceAnalysisFoldingViewWidget> createState() => _ElementsSentenceAnalysisFoldingViewWidgetState();
}

class _ElementsSentenceAnalysisFoldingViewWidgetState extends State<ElementsSentenceAnalysisFoldingViewWidget> {
  List<SentenceAnalysisFoldingModel> datas = [];

  /// 全局索引
  int globalIndex = 0;

  List<SentenceAnalysisFoldingModel> _buildFoldingModels(CardSentencesDetilsEntityClauses? clause){
    // 检查数据有效性
    if (clause == null) {
      return [];
    }
    
    // 获取活动子句（这里使用第一个子句）
    final activeClause = clause;
    if (activeClause.chunking == null || activeClause.chunking!.isEmpty) {
      return [];
    }
    
    // 按照从左到右的顺序排序（按照起始位置排序）
    final sortedChunks = [...activeClause.chunking!]
      ..sort((a, b) {
        final aStart = a?.textReference?.start ?? 0;
        final bStart = b?.textReference?.start ?? 0;
        return aStart - bStart; // 从左到右排序
      });
    
    // 构建树结构
    final List<SentenceAnalysisFoldingModel> treeNodes = [];
    final processedRanges = <Map<String, int>>[];
    
    // 从标记中获取文本的函数
    String getTextFromTokens(TextReference? reference) {
      if (reference == null) {
        return '';
      }
      
      // 获取完整句子的tokens
      final tokens = widget.sentenceText?.split(' ') ?? [];
      if (tokens.isEmpty) {
        return '';
      }
      
      // 注意：start和end是从1开始的索引，需要转换为从0开始的数组索引
      final start = (reference.start ?? 1) - 1; // 从1开始转换为从0开始
      final end = (reference.end ?? 1) - 1; // 从1开始转换为从0开始
      
      // 确保索引在有效范围内
      final validStart = start < 0 ? 0 : start;
      final validEnd = end >= tokens.length ? tokens.length - 1 : end;
      
      // 获取指定范围内的标记文本
      final List<String> textTokens = [];
      for (int i = validStart; i <= validEnd; i++) {
        if (i < tokens.length) {
          textTokens.add(tokens[i]);
        }
      }
      
      // 拼接文本
      return textTokens.join(' ');
    }
        // 处理所有块
    for (final chunk in sortedChunks) {
      if (chunk == null || chunk.type == null || chunk.textReference == null) continue;
      
      final start = chunk.textReference!.start ?? 0;
      final end = chunk.textReference!.end ?? 0;
      
      // 注意：start和end是从1开始的索引
      // 检查是否已经处理过这个范围
      final isContained = processedRanges.any((range) => 
        start >= range['start']! && end <= range['end']!
      );
      
      // 如果这个范围已经被包含在其他节点中，就不创建新节点
      if (!isContained) {
        processedRanges.add({'start': start, 'end': end});
        
        // 获取节点文本
        String nodeText = getTextFromTokens(chunk.textReference);
        
        // 只有当文本非空时才创建节点
        if (nodeText.isNotEmpty) {
          // 创建节点
          final node = SentenceAnalysisFoldingModel(
            tag: chunk.type!,
            value: nodeText,
            isOpen: false,
            isHover: false,
            children: [],
          );
          
          // 收集子节点
          final List<SentenceAnalysisFoldingModel> childNodes = [];
          
          for (final childChunk in sortedChunks) {
            if (childChunk == null || childChunk.type == null || childChunk.textReference == null) continue;
            
            final childStart = childChunk.textReference!.start ?? 0;
            final childEnd = childChunk.textReference!.end ?? 0;
            
            // 如果这个范围被包含在当前节点中，但不等于当前节点
            if (childStart >= start && childEnd <= end && 
                !(childStart == start && childEnd == end)) {
              // 获取子节点文本
              String childText = getTextFromTokens(childChunk.textReference);
              
              // 只有当文本非空时才创建并添加子节点
              if (childText.isNotEmpty) {
                // 创建子节点
                final childNode = SentenceAnalysisFoldingModel(
                  tag: childChunk.type!,
                  value: childText,
                  isOpen: false,
                  isHover: false,
                  children: [],
                );
                
                childNodes.add(childNode);
              }
            }
          }
        
          // 将子节点按照从左到右的顺序排序（根据原始的start索引）
          childNodes.sort((a, b) {
            // 查找对应的原始chunk以获取正确的start索引进行排序
            final aChunk = sortedChunks.firstWhere(
              (c) => c?.type == a.tag && getTextFromTokens(c?.textReference) == a.value,
              orElse: () => null,
            );
            
            final bChunk = sortedChunks.firstWhere(
              (c) => c?.type == b.tag && getTextFromTokens(c?.textReference) == b.value,
              orElse: () => null,
            );
            
            if (aChunk != null && bChunk != null) {
              final aStart = aChunk.textReference?.start ?? 0;
              final bStart = bChunk.textReference?.start ?? 0;
              return aStart.compareTo(bStart); // 从左到右排序
            }
            
            return 0;
          });
          
          // 将排序后的子节点添加到当前节点
          node.children = childNodes;
          
          treeNodes.add(node);
        }
      }
    }
    
    return treeNodes;
  }


  @override
  void initState() {
    super.initState();
    // 初始化数据
    if (widget.clause != null) {
      datas = _buildFoldingModels(widget.clause!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 24.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.sentenceText??"",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary,
            ),
          ),
          SizedBox(height: 24.wMin),
          Text(
            "语块结构(点击展开/折叠)",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary,
            ),
          ),
          SizedBox(height: 16.wMin),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildNestedWidgets(datas, indentLevel: 0, gIndex: 0),
          ),
        ],
      ),
    );
  }

  /// 递归构建嵌套的可折叠 Widget
  List<Widget> _buildNestedWidgets(
    List<SentenceAnalysisFoldingModel> models, {
    required int indentLevel, // 当前缩进层级
    required int gIndex,
  }) {
    List<Widget> widgets = [];
    
    for (int i = 0; i < models.length; i++) {
      final model = models[i];
      // 1. 添加当前层级的 Widget（带缩进）
      widgets.add(_buildFoldingItemWidget(model, indentLevel: indentLevel, gIndex: gIndex));
      gIndex++;
      

      // 2. 如果当前项展开且有子项，递归添加子项（缩进层级 +1）
      if (model.isOpen && model.children.isNotEmpty) {
        widgets.add(
          Container(
            padding: EdgeInsets.only(left: 36.wMin + (indentLevel == 0 ? 0 : 16.wMin)),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 1.wMin,
                    color: AppTheme.cWhiteAlpha10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildNestedWidgets(model.children, indentLevel: indentLevel + 1, gIndex: gIndex),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }


  Widget _buildFoldingItemWidget(SentenceAnalysisFoldingModel model, {required int indentLevel, required int gIndex}){
    LanguageConfigColorModel? configColor = StatusUtils.getConfigColor(widget.colorConfigs, model.tag);

    return TapScaleWidget(
      onTap: () {
        if(model.children.isNotEmpty){
          model.isOpen = !model.isOpen;
          if(mounted) setState(() {});
        }
      },
      sclae: 1,
      child: MouseRegion(
        onEnter: (event) {
          model.isHover = true;
          if(mounted) setState(() {});
        },
        onExit: (event) {
          model.isHover = false;
          if(mounted) setState(() {});
        },
        child: AnimatedContainer(
          width: double.infinity,
          duration: const Duration(milliseconds: 50),
          padding: EdgeInsets.only(
            top: 12.wMin,
            bottom: 12.wMin,
            left: 24.wMin * indentLevel,
          ),
          decoration: BoxDecoration(
            color: AppTheme.cBgTertiary.withValues(alpha: model.isHover ? 0.5 : 0),
          ),
          child: Row(
            children: [
              Visibility(
                visible: model.children.isNotEmpty,
                child: Container(
                  margin: EdgeInsets.only(right: 6.wMin),
                  child: Transform.rotate(
                    angle: model.isOpen ? 1.59 : 0, 
                    child: Icon(Icons.play_arrow_rounded, color: AppTheme.cTextDisabled, size: 30.wMin),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                decoration: BoxDecoration(
                  color: configColor?.color?.bgColor??AppTheme.cBgBrand.addOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.wMin),
                ),
                child: Text(
                  model.tag,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: configColor?.color?.textColor??AppTheme.cBgBrand,
                  ),
                ),
              ),
              SizedBox(width: 6.wMin),
              Container(
                constraints: BoxConstraints(
                  maxWidth: 750.wMin - (24.wMin * indentLevel),
                ),
                child: Text(
                  model.value,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary,
                  ),
                ),
              ),
              SizedBox(width: 6.wMin),
              TapScaleWidget(
                onTap: () {
                  widget.onDetil?.call(gIndex);
                },
                sclae: 1.05,
                child: Text(
                  "查看详情",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cBorderBrand,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}