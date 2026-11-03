import 'dart:async';

import 'package:audio_player_ex/audio_player_ex.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/painter/jigsaw_puzzle_box_painter.dart';
import '../../../../common/painter/painter.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../utils/karaoke_subtitles_utils.dart';
import '../../../../utils/utils.dart';
import '../elements_sentence_detils/bindings/elements_sentence_detils_binding.dart';
import '../elements_sentence_detils/views/elements_sentence_detils_view.dart';
import '../model/elements_detils_data_model.dart';
import '../model/elements_tabview_tag_model.dart';
import 'elements_card_star_level_widget.dart';
import 'elements_cards/elements_type_card_widget.dart';
import 'elements_progress_widget.dart';

class ElementsCoreComponentModuleWidget extends StatelessWidget {
  final List<ElementsCardEntityDatas?>? subContents;

  /// 核心组件模块
  const ElementsCoreComponentModuleWidget({
    super.key,
    required this.subContents,
  });

  @override
  Widget build(BuildContext context) {
    if (subContents?.isEmpty ?? true) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ElementsDashedLineWidget(),
        SizedBox(height: 40.wMin),
        ElemenetsTitleH1Widget(
          showDot: true,
          dotColor: const Color(0xffA78BFA),
          titles: [
            LanguageText(text: "Core Components", lang: "en"),
            LanguageText(text: "核心组件", lang: "zh"),
          ],
        ),
        SizedBox(height: 16.wMin),
        Container(
          padding: EdgeInsets.only(left: 16.wMin),
          child: ElementsCardListWidget(
            datas: subContents,
          ),
        ),
        SizedBox(height: 264.wMin),
      ],
    );
  }
}

class ElementsPhraseModuleWidget extends StatelessWidget {
  final List<ElementsCardEntityDatas?>? phrases;
  final List<ElementsCardEntityDatas?>? phraseIdioms;

  /// 短语模块
  const ElementsPhraseModuleWidget({
    super.key,
    this.phrases,
    this.phraseIdioms,
  });

  @override
  Widget build(BuildContext context) {
    if ((phrases?.isEmpty ?? true) && (phraseIdioms?.isEmpty ?? true)) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ElementsDashedLineWidget(),
        SizedBox(height: 56.wMin),
        ElemenetsTitleH1Widget(
          dotColor: const Color(0xffE879F9),
          showDot: true,
          titles: [
            LanguageText(text: "Phrase Idioms", lang: "en"),
            LanguageText(text: "短语习语", lang: "zh"),
          ],
        ),
        Container(
          margin: EdgeInsets.only(left: 16.wMin),
          child: Column(
            children: [
              Visibility(
                visible: phrases?.isNotEmpty ?? false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.wMin),
                    ElementsCardListWidget(
                      title: "·短语组",
                      datas: phrases,
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: phraseIdioms?.isNotEmpty ?? false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.wMin),
                    ElementsCardListWidget(
                      title: "·习语组",
                      datas: phraseIdioms,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 264.wMin),
      ],
    );
  }
}

class ElementsEtymologicalAnalysisModuleWidget extends StatelessWidget {
  final void Function(CardWordDetilsEntityPosListMorphologyMorphemes morpheme)? onTap;
  final CardWordDetilsEntityPosListMorphology? morphology;
  final List<LanguageConfigColorEntityInfo?>? colorConfig;

  /// 词源分析模块
  const ElementsEtymologicalAnalysisModuleWidget({
    super.key,
    this.onTap,
    this.morphology,
    this.colorConfig,
  });

  List<JigsawPuzzleBoxType> determineBoxTypes(List<CardWordDetilsEntityPosListMorphologyMorphemes?>? morphemes) {
    if (morphemes == null) return [];
    // 1. 找出所有词根的位置
    List<int> rootIndices = [];
    for (int i = 0; i < morphemes.length; i++) {
      if (morphemes[i] == null) continue;
      if (morphemes[i]!.type?.toUpperCase() == "ROOT") {
        rootIndices.add(i);
      }
    }

    List<JigsawPuzzleBoxType> boxTypes = List.filled(morphemes.length, JigsawPuzzleBoxType.none);

    // 2. 处理每个语素
    for (int i = 0; i < morphemes.length; i++) {
      if (morphemes[i] == null) continue;

      bool isRoot = rootIndices.contains(i);
      bool hasLeft = i > 0 && morphemes[i - 1] != null;
      bool hasRight = i < morphemes.length - 1 && morphemes[i + 1] != null;

      // 如果是词根
      if (isRoot) {
        // 处理左边
        if (hasLeft) {
          bool leftIsRoot = rootIndices.contains(i - 1);
          if (leftIsRoot) {
            // 左边是词根：两边都不挖空
            boxTypes[i] = boxTypes[i] == JigsawPuzzleBoxType.none ? JigsawPuzzleBoxType.none : boxTypes[i]; // 保持原有
          } else {
            // 左边不是词根：词根左边凹，左边元素右边凸
            boxTypes[i] = _addLeftConcave(boxTypes[i]);
            boxTypes[i - 1] = _addRightConvex(boxTypes[i - 1]);
          }
        }

        // 处理右边
        if (hasRight) {
          bool rightIsRoot = rootIndices.contains(i + 1);
          if (rightIsRoot) {
            // 右边是词根：两边都不挖空
            boxTypes[i] = boxTypes[i] == JigsawPuzzleBoxType.none ? JigsawPuzzleBoxType.none : boxTypes[i];
          } else {
            // 右边不是词根：词根右边凹，右边元素左边凸
            boxTypes[i] = _addRightConcave(boxTypes[i]);
            boxTypes[i + 1] = _addLeftConvex(boxTypes[i + 1]);
          }
        }
      }
      // 如果不是词根
      else {
        // 处理与右边元素的连接（朝向词根方向的凸出）
        if (hasRight) {
          bool shouldConnect = true;
          // 如果右边是词根，且当前不是词根，则当前元素右边凸
          if (rootIndices.contains(i + 1)) {
            boxTypes[i] = _addRightConvex(boxTypes[i]);
            shouldConnect = false;
          }

          // 普通元素之间的连接：前凹后凸
          if (shouldConnect && !rootIndices.contains(i) && !rootIndices.contains(i + 1)) {
            boxTypes[i] = _addRightConcave(boxTypes[i]);
            boxTypes[i + 1] = _addLeftConvex(boxTypes[i + 1]);
          }
        }
      }
    }

    return boxTypes;
  }

  // 辅助函数：在现有类型上添加左凹
  JigsawPuzzleBoxType _addLeftConcave(JigsawPuzzleBoxType current) {
    if (current == JigsawPuzzleBoxType.none) return JigsawPuzzleBoxType.leftConcaave;
    if (current == JigsawPuzzleBoxType.rightConcaave) return JigsawPuzzleBoxType.bothConcaave;
    if (current == JigsawPuzzleBoxType.rightConvex) return JigsawPuzzleBoxType.leftConcaaveRightConvex;
    return current;
  }

  // 辅助函数：在现有类型上添加右凹
  JigsawPuzzleBoxType _addRightConcave(JigsawPuzzleBoxType current) {
    if (current == JigsawPuzzleBoxType.none) return JigsawPuzzleBoxType.rightConcaave;
    if (current == JigsawPuzzleBoxType.leftConcaave) return JigsawPuzzleBoxType.bothConcaave;
    if (current == JigsawPuzzleBoxType.leftConvex) return JigsawPuzzleBoxType.leftConvexRightConcaave;
    return current;
  }

  // 辅助函数：在现有类型上添加左凸
  JigsawPuzzleBoxType _addLeftConvex(JigsawPuzzleBoxType current) {
    if (current == JigsawPuzzleBoxType.none) return JigsawPuzzleBoxType.leftConvex;
    if (current == JigsawPuzzleBoxType.rightConvex) return JigsawPuzzleBoxType.bothConvex;
    if (current == JigsawPuzzleBoxType.rightConcaave) return JigsawPuzzleBoxType.leftConvexRightConcaave;
    return current;
  }

  // 辅助函数：在现有类型上添加右凸
  JigsawPuzzleBoxType _addRightConvex(JigsawPuzzleBoxType current) {
    if (current == JigsawPuzzleBoxType.none) return JigsawPuzzleBoxType.rightConvex;
    if (current == JigsawPuzzleBoxType.leftConvex) return JigsawPuzzleBoxType.bothConvex;
    if (current == JigsawPuzzleBoxType.leftConcaave) return JigsawPuzzleBoxType.leftConcaaveRightConvex;
    return current;
  }

  @override
  Widget build(BuildContext context) {
    if (morphology == null) return Container();
    List<CardWordDetilsEntityPosListMorphologyMorphemes?> morphemes = morphology!.morphemes ?? [];

    List<JigsawPuzzleBoxType> boxTypes = determineBoxTypes(morphemes);

    return Container(
      margin: EdgeInsets.only(bottom: 64.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ElementsDashedLineWidget(),
          SizedBox(height: 64.wMin),
          ElemenetsTitleH1Widget(
            dotColor: const Color(0xff4ADE80),
            showDot: true,
            titles: [
              LanguageText(text: "Roots and Affixes", lang: "en"),
              LanguageText(text: "词根词缀", lang: "zh"),
            ],
          ),
          SizedBox(height: 40.wMin),
          Container(
            margin: EdgeInsets.only(left: 16.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "·构成成分",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary,
                  ),
                ),
                SizedBox(height: 16.wMin),
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 24.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.wMin),
                    color: AppTheme.cBgSecondary,
                  ),
                  child: Wrap(
                    children: List.generate(morphemes.length, (index) {
                      JigsawPuzzleBoxType boxType = boxTypes[index];
                      return _buildCompositionWidget(morphemes[index], boxType);
                    }),
                  ),
                ),
                SizedBox(height: 56.wMin),
                _buildEtymologyWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 词源解释
  Widget _buildEtymologyWidget() {
    List<LanguageText?> explanations = morphology?.explanations ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "·词源解释",
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary,
          ),
        ),
        SizedBox(height: 16.wMin),
        Container(
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cBgSecondary,
          ),
          child: Obx(() {
            List<LanguageText> explanationTexts = LearningLangUtils.getShowLBList(explanations);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(explanationTexts.length, (index) {
                if (index == 0) {
                  return Text(
                    explanationTexts[index].text ?? "",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextPrimary,
                    ),
                  );
                }
                return Container(
                  margin: EdgeInsets.only(top: 16.wMin),
                  child: Text(
                    explanationTexts[index].text ?? "",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff4ADE80),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ],
    );
  }

  /// 构成成分
  /// type: 1 前缀 2 词根 3 后缀
  Widget _buildCompositionWidget(CardWordDetilsEntityPosListMorphologyMorphemes? morpheme, JigsawPuzzleBoxType boxType) {
    if (morpheme == null) {
      return Container();
    }

    Color color = StatusUtils.getMorphemeTagColor(morpheme.type ?? "");

    String text = morpheme.content ?? "";
    text = text.replaceAll("-", "");

    return Column(
      spacing: 7.wMin,
      children: [
        TapScaleWidget(
          onTap: () {
            onTap?.call(morpheme);
          },
          sclae: 1,
          child: CustomPaint(
            painter: JigsawPuzzleBoxPainter(
              type: boxType, // 选择拼图类型
              radius: 4.wMin, // 外层圆角
              color: color.withValues(alpha: 0.2), // 填充颜色
              exWidth: 10.wMin, // 凹凸宽度
              exHeight: 30.wMin, // 凹凸高度
              exRadius: 4.wMin, // 凹凸圆角
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.wMin),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 56.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: morpheme.typeName != null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.wMin),
              color: color.withValues(alpha: 0.2),
              border: Border.all(width: 1.wMin, color: color),
            ),
            child: Text(
              morpheme.typeName ?? "",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ElementsMemoryTipWidget extends StatefulWidget {
  final CardWordDetilsEntityPosListMemory? memory;

  /// 记忆提示模块
  const ElementsMemoryTipWidget({super.key, this.memory});

  @override
  State<ElementsMemoryTipWidget> createState() => _ElementsMemoryTipWidgetState();
}

class _ElementsMemoryTipWidgetState extends State<ElementsMemoryTipWidget> {

  @override
  Widget build(BuildContext context) {
    if (widget.memory == null) return Container();

    List<LanguageText?> explanation = widget.memory?.descriptions ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 56.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ElementsDashedLineWidget(),
          SizedBox(height: 56.wMin),
          ElemenetsTitleH1Widget(
            dotColor: const Color(0xffFB923C),
            showDot: true,
            titles: [
              LanguageText(text: "Memory Prompt", lang: "en"),
              LanguageText(text: "记忆提示", lang: "zh"),
            ],
          ),
          SizedBox(height: 24.wMin),
          Container(
            margin: EdgeInsets.only(left: 16.wMin),
            decoration: BoxDecoration(
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary),
              borderRadius: BorderRadius.circular(16.wMin),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 340.wMin,
                    height: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: 340.wMin,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(16.wMin)),
                      child: CachedImageWidget(
                        widget.memory?.imageUrl ?? "",
                        errorWidget: buildEmptyWidget(fit: BoxFit.cover),
                        placeholder: buildEmptyWidget(fit: BoxFit.cover),
                        width: 340.wMin,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(24.wMin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.wMin),
                              color: AppTheme.cFeedbackWarningBackground,
                            ),
                            child: Text(
                              "学习小帖士",
                              style: TextStyle(
                                fontSize: 24.wMin,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xffFB923C),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.wMin),
                          Obx(() {
                            List<LanguageText> explanationTexts = LearningLangUtils.getShowLBList(explanation);
              
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: List.generate(explanationTexts.length, (index) {
                                if (index == 0) {
                                  return Text(
                                    explanationTexts[index].text ?? "",
                                    style: TextStyle(
                                      fontSize: 28.wMin,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.cTextPrimary,
                                    ),
                                  );
                                }
                                return Container(
                                  margin: EdgeInsets.only(top: 16.wMin),
                                  padding: EdgeInsets.all(16.wMin),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cSurfacePrimary,
                                    border: Border(left: BorderSide(width: 2.wMin, color: const Color(0xffFB923C))),
                                  ),
                                  child: Text(
                                    explanationTexts[index].text ?? "",
                                    style: TextStyle(
                                      fontSize: 24.wMin,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.cFeedbackDefaultText,
                                    ),
                                  ),
                                );
                              }),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ElementsPhraseOriginModel {
  String? imageUrl;
  List<LanguageText?> descriptions;

  ElementsPhraseOriginModel({
    this.imageUrl,
    this.descriptions = const [],
  });
}

class ElementsSourceStoryWidget extends StatelessWidget {
  final ElementsPhraseOriginModel? data;

  /// 来源故事
  const ElementsSourceStoryWidget({
    super.key,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data == null) return Container();

    return Container(
      margin: EdgeInsets.only(bottom: 65.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ElementsDashedLineWidget(),
          SizedBox(height: 40.wMin),
          ElemenetsTitleH1Widget(
            dotColor: const Color(0xffFB7185),
            showDot: true,
            titles: [
              LanguageText(text: "Source Story", lang: "en"),
              LanguageText(text: "来源故事", lang: "zh"),
            ],
          ),
          SizedBox(height: 16.wMin),
          Container(
            margin: EdgeInsets.only(left: 16.wMin),
            child: AspectRatio(
              aspectRatio: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary),
                  borderRadius: BorderRadius.circular(16.wMin),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.wMin),
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      CachedImageWidget(
                        data?.imageUrl ?? "",
                        errorWidget: buildEmptyWidget(),
                        placeholder: buildLoadingWidget(),
                      ),
                      Container(
                        color: AppTheme.cBlackAlpha50,
                      ),
                      Container(
                        padding: EdgeInsets.all(24.wMin),
                        child: Obx(() {
                          List<LanguageText> descriptionsTexts = LearningLangUtils.getShowLBList(data!.descriptions);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(descriptionsTexts.length, (index) {
                              if (index == 0) {
                                return Text(
                                  descriptionsTexts[index].text ?? "",
                                  style: TextStyle(
                                    fontSize: 26.wMin,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.cStaticWhite,
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                              }
                              return Container(
                                margin: EdgeInsets.only(top: 16.wMin),
                                padding: EdgeInsets.all(16.wMin),
                                decoration: BoxDecoration(
                                  color: AppTheme.cBlackAlpha50,
                                  border: Border(left: BorderSide(width: 2.wMin, color: AppTheme.cFeedbackInfoIcon)),
                                ),
                                child: Text(
                                  descriptionsTexts[index].text ?? "",
                                  style: TextStyle(
                                    fontSize: 24.wMin,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xffFB7185),
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ElementsGrammarCharacteristicsModuleWidget extends StatelessWidget {
  final List<CardWordDetilsEntityPosListGrammatical?>? grammatical;
  final String pos;
  final String? word;
  final void Function(double visibleFraction)? onVisibilityChanged;
  final List<LanguageConfigColorEntityInfo?>? colorConfig;

  /// 语法特性模块
  const ElementsGrammarCharacteristicsModuleWidget({
    super.key,
    this.grammatical,
    required this.pos,
    this.word,
    this.colorConfig,
    this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (grammatical == null || (grammatical?.isEmpty ?? true)) return Container();
    return Container(
      margin: EdgeInsets.only(bottom: 64.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ElementsDashedLineWidget(),
          SizedBox(height: 64.wMin),
          ElemenetsTitleH1Widget(
            dotColor: const Color(0xffA78BFA),
            showDot: true,
            titles: [
              LanguageText(text: "Grammatical features", lang: "en"),
              LanguageText(text: "语法特性", lang: "zh"),
            ],
          ),
          SizedBox(height: 40.wMin),
          Container(
            padding: EdgeInsets.only(left: 16.wMin),
            child: VisibilityDetector(
              key: const ValueKey("grammar_characteristics"),
              onVisibilityChanged: (info) {
                onVisibilityChanged?.call(info.visibleFraction);
              },
              child: Column(
                spacing: 24.wMin,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(grammatical!.length, (index) {
                  return _buildListItemWidget(grammatical![index]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItemWidget(CardWordDetilsEntityPosListGrammatical? data) {
    LanguageConfigColorModel? color = StatusUtils.getConfigColor(colorConfig, pos);

    List<LanguageText?> explanation = data?.notes?.explanation ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.wMin),
                color: color?.color?.bgColor,
                border: Border.all(width: 1.wMin, color: color?.color?.borderColor ?? AppTheme.cBgBrand),
              ),
              child: Text(
                data?.type ?? "",
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: color?.color?.textColor ?? AppTheme.cTextPrimary.color,
                ),
              ),
            ),
            SizedBox(width: 12.wMin),
            _buildListTitleTextWidget("复数形式:", data?.inflections?.plural),
            _buildListTitleTextWidget("比较级:", data?.inflections?.comparative),
            _buildListTitleTextWidget("最高级:", data?.inflections?.superlative),
          ],
        ),
        SizedBox(height: 24.wMin),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: AppTheme.cBgSecondary,
          ),
          child: Text(
            '"${data?.notes?.example ?? ''}"',
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(24.wMin),
          child: Obx(() {
            List<LanguageText> explanationTexts = LearningLangUtils.getShowLBList(explanation);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16.wMin,
              children: List.generate(explanationTexts.length, (index) {
                if (index == 0) {
                  return Text(
                    explanationTexts[index].text ?? "",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextPrimary,
                    ),
                  );
                }
                return Container(
                  margin: EdgeInsets.only(top: 2.wMin),
                  child: Text(
                    explanationTexts[index].text ?? "",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary,
                    ),
                  ),
                );
              }),
            );
          }),
        ),
        _buildVerbFormWidget(data?.inflections),
        Visibility(
          visible: data?.inflections?.pluralInfo != null,
          child: ElementsTypeCardWidget(
            jumpToDetail: false,
            data: ElementsDetilsDataModel(
              type: ElementsCardType.fromRawValue(data?.inflections?.pluralInfo?.contentType ?? ""),
              data: data?.inflections?.pluralInfo,
              hideStar: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerbFormWidget(CardWordDetilsEntityPosListGrammaticalInflections? inflections) {
    if (pos != "VERB") return Container();
    if (inflections == null) return Container();
    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cBgSecondary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "动词形式：",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary,
            ),
          ),
          SizedBox(height: 16.wMin),
          Row(
            children: [
              Expanded(child: _buildListTitleTextWidget("原形：", word)),
              Expanded(child: _buildListTitleTextWidget("过去式：", inflections.pastTense)),
            ],
          ),
          SizedBox(height: 8.wMin),
          Row(
            children: [
              Expanded(child: _buildListTitleTextWidget("过去分词：", inflections.pastParticiple)),
              Expanded(child: _buildListTitleTextWidget("第三人称单数：", inflections.thirdPersonSingular)),
            ],
          ),
          SizedBox(height: 8.wMin),
          Row(
            children: [
              Expanded(child: _buildListTitleTextWidget("现在分词：", inflections.presentParticiple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListTitleTextWidget(String name, String? value) {
    if (value == null || value.isEmpty) return Container();
    return Row(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary,
          ),
        ),
        SizedBox(width: 12.wMin),
      ],
    );
  }
}

class ElementsInterpretationModuleItemWidget extends StatefulWidget {
  final List<CardWordDetilsEntityPosListSemantics?>? semantics;
  final int index;
  final void Function(int index, double visibleFraction)? onVisibilityChanged;
  const ElementsInterpretationModuleItemWidget({
    super.key,
    required this.index,
    this.semantics,
    this.onVisibilityChanged,
  });

  @override
  State<ElementsInterpretationModuleItemWidget> createState() => _ElementsInterpretationModuleItemWidgetState();
}

class _ElementsInterpretationModuleItemWidgetState extends State<ElementsInterpretationModuleItemWidget> {
  ConfigController configController = Get.find<ConfigController>();

  bool showMore = false;

  @override
  Widget build(BuildContext context) {
    List<CardWordDetilsEntityPosListSemanticsTopics?> topics = widget.semantics?[widget.index]?.topics ?? [];
    List<ElementsCardEntityDatas?> synonyms = widget.semantics?[widget.index]?.synonyms ?? [];
    List<ElementsCardEntityDatas?> antonyms = widget.semantics?[widget.index]?.antonyms ?? [];

    return VisibilityDetector(
      key: ValueKey(widget.index),
      onVisibilityChanged: (info) {
        widget.onVisibilityChanged?.call(widget.index, info.visibleFraction);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 48.wMin),
          _buildTitleInfoWidget(widget.semantics?[widget.index], widget.index),
          _buildExampleSentenceWidget(widget.semantics?[widget.index]),
          ElementsTitleImagesWidget(
            title: "·类别",
            datas: topics,
          ),
          ElementsCardListWidget(
            title: "·同义词",
            datas: synonyms,
          ),
          ElementsCardListWidget(
            title: "·反义词",
            datas: antonyms,
          ),
          SizedBox(height: 64.wMin),
        ],
      ),
    );
  }

  Widget _buildExampleSentenceWidget(CardWordDetilsEntityPosListSemantics? semantic) {
    List<ElementsCardEntityDatas?> sentences = semantic?.sentences ?? [];
    if (sentences.isEmpty) return Container();
    List<ElementsCardEntityDatas?> showSentences = [];
    if (showMore) {
      showSentences = sentences;
    } else {
      showSentences = sentences.length > 3 ? sentences.take(3).toList() : sentences;
    }

    return Container(
      margin: EdgeInsets.only(top: 48.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "·例句",
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary,
                ),
              ),
              Visibility(
                visible: sentences.length > 3,
                child: TapScaleWidget(
                  onTap: () {
                    showMore = !showMore;
                    if (mounted) setState(() {});
                  },
                  sclae: 1.03,
                  child: Text(
                    "查看更多例句",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cBgBrand,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.wMin),
          Column(
            spacing: 16.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(showSentences.length, (index) {
              return ExampleSentenceItemWidget(data: showSentences[index], index: index);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInfoWidget(CardWordDetilsEntityPosListSemantics? semantic, int index) {
    if (semantic == null) {
      return const SizedBox();
    }

    List<LanguageText?> gloss = semantic.gloss ?? [];
    List<LanguageText?> descriptions = semantic.descriptions ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "·释义${index + 1}",
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary,
          ),
        ),
        Obx(() {
          List<LanguageText> glossText = LearningLangUtils.getShowLBList(gloss);
          return Column(
            spacing: 8.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(glossText.length, (index) {
              if (index == 0) {
                return Row(
                  children: [
                    Visibility(
                      visible: semantic.difficulty != null,
                      child: Container(
                        margin: EdgeInsets.only(right: 12.wMin),
                        child: StatusTagDifficultyWidget(
                          difficulty: semantic.difficulty,
                          language: configController.userSetting.value.learningLang,
                          fontSize: 32.wMin,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        glossText[index].text ?? "",
                        style: TextStyle(
                          fontSize: 40.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cBorderBrand,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Text(
                glossText[index].text ?? "",
                style: TextStyle(
                  fontSize: 32.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cBorderBrand,
                ),
              );
            }),
          );
        }),
        SizedBox(height: 24.wMin),
        Container(
          height: 1.wMin,
          color: AppTheme.cBorderBrand,
        ),
        SizedBox(height: 16.wMin),
        Obx(() {
          List<LanguageText> descriptionsText = LearningLangUtils.getShowLBList(descriptions);
          return ElemenetsTitleH1Widget(titles: descriptionsText);
        }),
      ],
    );
  }
}

class ExampleSentenceItemWidget extends StatefulWidget {
  final ElementsCardEntityDatas? data;
  final int index;
  const ExampleSentenceItemWidget({super.key, required this.data, required this.index});

  @override
  State<ExampleSentenceItemWidget> createState() => _ExampleSentenceItemWidgetState();
}

class _ExampleSentenceItemWidgetState extends State<ExampleSentenceItemWidget> {
  bool isPlaying = false;

  void toLearn() {
    if (widget.data?.contentId == null) return;
    Map<String, dynamic> args = {
      "contentId": widget.data?.contentId,
    };
    if (widget.data?.semanticId != null) {
      args["semanticIds"] = [widget.data?.semanticId];
    }
    Get.to(
      ElementsSentenceDetilsView(tagText: widget.data?.contentId?.toString() ?? ""),
      binding: ElementsSentenceDetilsBinding(tagText: widget.data?.contentId?.toString() ?? ""),
      arguments: args,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cBgSecondary,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.wMin),
            child: Container(
              width: 320.wMin,
              height: 320.wMin,
              color: AppTheme.cBlackAlpha10,
              child: Stack(
                children: [
                  CachedImageWidget(
                    widget.data?.imageUrl ?? "",
                    errorWidget: buildEmptyWidget(),
                    placeholder: buildLoadingWidget(),
                  ),
                  Visibility(
                    visible: widget.data?.pronunciations?.isNotEmpty ?? false,
                    child: Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(widget.data?.pronunciations?.length ?? 0, (index) {
                          return PlayLottieIconWidget(
                            size: 48.wMin,
                            audioUrl: widget.data?.pronunciations?[index]?.audioUrl,
                            backgroundImageUrl: widget.data?.pronunciations?[index]?.nationalIconUrl,
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TapScaleWidget(
              onTap: () {
                toLearn();
              },
              sclae: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                constraints: BoxConstraints(
                  minHeight: 320.wMin,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16.wMin),
                        constraints: BoxConstraints(
                          minHeight: 320.wMin,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "例句${widget.index + 1}",
                              style: TextStyle(
                                fontSize: 24.wMin,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.cTextSecondary,
                              ),
                            ),
                            SizedBox(height: 6.wMin),
                            Obx(() {
                              List<LanguageText> glossText = LearningLangUtils.getShowLBList(widget.data?.gloss ?? []);
                              return ElemenetsTitleH1Widget(
                                titles: glossText,
                                fontSize0: 32.wMin,
                                fontSize1: 28.wMin,
                                spacing: 8.wMin,
                                type: 1,
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.cFeedbackInfoBackground.color,
                        borderRadius: BorderRadius.circular(12.wMin),
                      ),
                      child: Text(
                        "去学习",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cFeedbackInfoText.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ElementsInterpretationModuleWidget extends StatefulWidget {
  final List<CardWordDetilsEntityPosListSemantics?>? semantics;
  final void Function(int index, double visibleFraction)? onVisibilityChanged;
  final bool showTitle;

  /// 释义模块
  const ElementsInterpretationModuleWidget({
    super.key,
    this.semantics,
    this.onVisibilityChanged,
    this.showTitle = true,
  });

  @override
  State<ElementsInterpretationModuleWidget> createState() => _ElementsInterpretationModuleWidgetState();
}

class _ElementsInterpretationModuleWidgetState extends State<ElementsInterpretationModuleWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.semantics == null || widget.semantics!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: [
        Visibility(
          visible: widget.showTitle,
          child: Container(
            margin: EdgeInsets.only(top: 16.wMin),
            child: ElemenetsTitleH1Widget(
              showDot: true,
              dotColor: const Color(0xff38BDF8),
              fontColor0: AppTheme.cTextSecondary,
              titles: [
                LanguageText(text: "Definition", lang: "en"),
                LanguageText(text: "释义", lang: "zh"),
              ],
            ),
          ),
        ),
        ListView.separated(
            itemCount: widget.semantics!.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 16.wMin),
            separatorBuilder: (context, index) {
              return ElementsDashedLineWidget(strokeWidth: 0.5.wMin);
            },
            itemBuilder: (context, index) {
              return ElementsInterpretationModuleItemWidget(
                semantics: widget.semantics,
                index: index,
                onVisibilityChanged: widget.onVisibilityChanged,
              );
            }),
      ],
    );
  }
}

class ElementsTitleImagesWidget extends StatelessWidget {
  final String title;
  final List<CardWordDetilsEntityPosListSemanticsTopics?>? datas;

  const ElementsTitleImagesWidget({
    super.key,
    required this.title,
    this.datas,
  });

  @override
  Widget build(BuildContext context) {
    if (datas == null || (datas?.isEmpty ?? true)) return Container();
    return Container(
      margin: EdgeInsets.only(top: 48.wMin),
      child: Column(
        spacing: 16.wMin,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 32.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(datas!.length, (index) {
                return _buildListWidget(datas![index]);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListWidget(CardWordDetilsEntityPosListSemanticsTopics? data) {
    if (data == null) return Container();

    ConfigController configController = Get.find<ConfigController>();

    return SizedBox(
      width: 240.wMin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.wMin),
            child: Container(
              width: 240.wMin,
              height: 240.wMin,
              color: AppTheme.cBlackAlpha10,
              child: CachedImageWidget(
                data.imageUrl ?? "",
                errorWidget: buildEmptyWidget(),
                placeholder: buildLoadingWidget(),
              ),
            ),
          ),
          SizedBox(height: 8.wMin),
          Text(
            data.content ?? "",
            maxLines: data.definition == null ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary,
            ),
          ),
          Visibility(
            visible: configController.userSetting.value.expandLang != LangPreference.original,
            child: Container(
              margin: EdgeInsets.only(top: 4.wMin),
              child: Text(
                data.definition ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ElementsCardListWidget extends StatelessWidget {
  final String? title;
  final List<ElementsCardEntityDatas?>? datas;

  const ElementsCardListWidget({
    super.key,
    this.title,
    this.datas,
  });

  @override
  Widget build(BuildContext context) {
    if (datas == null || (datas?.isEmpty ?? true)) return Container();
    return Container(
      margin: EdgeInsets.only(top: 16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: title != null,
            child: Container(
              margin: EdgeInsets.only(bottom: 8.wMin),
              child: Text(
                title ?? "",
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 8.wMin),
            child: Row(
              spacing: 32.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(datas!.length, (index) {
                return ElementsTypeCardWidget(
                  data: ElementsDetilsDataModel(
                    type: ElementsCardType.fromRawValue(datas![index]?.contentType ?? ""),
                    data: datas![index],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class ElementsPhrasePronunciationWidget extends StatefulWidget {
  final String? contentType;
  final int? contentId;
  final String content;
  final List<PronunciationsEntity?>? pronunciations;

  /// 短语发音模块
  const ElementsPhrasePronunciationWidget({super.key, required this.contentType, required this.contentId, required this.content, this.pronunciations});

  @override
  State<ElementsPhrasePronunciationWidget> createState() => _ElementsPhrasePronunciationWidgetState();
}

class _ElementsPhrasePronunciationWidgetState extends State<ElementsPhrasePronunciationWidget> {
  AudioPlayerEx audioPlayEx = AudioPlayerEx();
  StreamSubscription<Duration>? positionSubscription;
  StreamSubscription<void>? completeSubscription;
  List<AssSubtitle> assSubtitles = [];

  /// 英音/美音选择下标
  int englishAmericanType = 0;

  @override
  void initState() {
    super.initState();
    if (widget.pronunciations != null && (widget.pronunciations ?? []).isNotEmpty) {
      assSubtitles = widget.pronunciations?[englishAmericanType]?.assSubtitles ?? [];
    }

    initAudio();
  }

  @override
  void dispose() {
    positionSubscription?.cancel();
    completeSubscription?.cancel();
    audioPlayEx.dispose();
    super.dispose();
  }

  Future<void> initAudio() async {
    positionSubscription = audioPlayEx.onPositionChanged.listen((event) {
      if (audioPlayEx.isPlaying) {
        cleanAssColor();
        int? index = findIndexByTime(event.inMilliseconds);
        if (index == null) return;
        setState(() {
          assSubtitles[index].isRead = true;
        });
      }
    });

    completeSubscription = audioPlayEx.onPlayerComplete.listen((_) {
      cleanAssColor();
    });
  }

  void cleanAssColor() {
    setState(() {
      for (var element in assSubtitles) {
        element.isRead = false;
      }
    });
  }

  int? findIndexByTime(int time) {
    for (int i = 0; i < assSubtitles.length; i++) {
      if (assSubtitles[i].startTime <= time && assSubtitles[i].endTime >= time) {
        return i;
      }
    }
    return null;
  }

  Future<void> playAudio() async {
    if (widget.pronunciations == null || (widget.pronunciations?.isEmpty ?? true)) return;

    String audioUrl = widget.pronunciations?[englishAmericanType]?.audioUrl ?? "";
    String? fileUrl = await CacheManagerUtils.instance.getFile(audioUrl, ResourceType.audio);
    audioPlayEx.playFileOrNet(
      url: audioUrl,
      filePath: fileUrl,
      playbackRate: Get.find<ConfigController>().userSetting.value.expandAudioSpeed,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pronunciations == null || (widget.pronunciations?.isEmpty ?? true)) return Container();

    return Column(
      children: [
        SizedBox(height: 16.wMin),
        ElemenetsTitleH1Widget(
          showDot: true,
          dotColor: const Color(0xff38BDF8),
          fontColor0: AppTheme.cTextSecondary,
          titles: [
            LanguageText(text: "Pronunciation", lang: Get.find<ConfigController>().userSetting.value.learningLang),
            LanguageText(text: "发音", lang: Get.find<ConfigController>().userSetting.value.localLang),
          ],
        ),
        SizedBox(height: 32.wMin),
        Container(
          margin: EdgeInsets.only(left: 16.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cBgSecondary.color,
            borderRadius: BorderRadius.circular(10.wMin),
          ),
          child: Column(
            children: [
              ElementsUSUKTabWidget(
                pronunciations: widget.pronunciations ?? [],
                onTap: (index) async {
                  await audioPlayEx.stop();
                  setState(() {
                    englishAmericanType = index;
                    assSubtitles = widget.pronunciations?[englishAmericanType]?.assSubtitles ?? [];
                    cleanAssColor();
                  });
                },
                englishAmericanType: englishAmericanType,
              ),
              Container(
                height: 2.wMin,
                color: AppTheme.cBorderPrimary.color.withValues(alpha: 0.6),
              ),
              SizedBox(height: 24.wMin),
              _buildContentWidget(),
              _buildHasPracticeWidget(),
              SizedBox(height: 40.wMin),
            ],
          ),
        ),
        SizedBox(height: 40.wMin),
        const ElementsDashedLineWidget(),
      ],
    );
  }

  Widget _buildContentWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAssWidget(),
        SizedBox(width: 40.wMin),
        Visibility(
          visible: widget.pronunciations?[englishAmericanType]?.audioUrl != null,
          child: TapScaleWidget(
            onTap: () {
              playAudio();
            },
            sclae: 1.03,
            child: Container(
              width: 64.wMin,
              height: 64.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cBgQuaternary.color,
              ),
              child: SvgPicture.asset(
                "assets/svg/public/icon_speaker.svg",
                width: 40.wMin,
                height: 40.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssWidget() {
    TextStyle style = TextStyle(
      fontSize: 64.wMin,
      fontWeight: FontWeight.w600,
      color: AppTheme.cTextPrimary.color,
    );

    if (assSubtitles.isEmpty) {
      return Text(widget.content, style: style);
    }

    return Wrap(
      children: List.generate(assSubtitles.length, (index) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(assSubtitles[index].leftSpace, style: style),
            Container(
              decoration: BoxDecoration(color: AppTheme.cTextBrand.color.withValues(alpha: assSubtitles[index].isRead ? 0.8 : 0), borderRadius: BorderRadius.circular(4.wMin)),
              child: Text(
                assSubtitles[index].text,
                style: style,
              ),
            ),
          ],
        );
      }),
    );
  }

  /// 是否有练习题按钮
  Widget _buildHasPracticeWidget() {
    if (widget.pronunciations?[englishAmericanType]?.isExercise != true) return Container();
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.only(top: 24.wMin, right: 40.wMin),
      child: ButtonWidget(
        text: "去练习",
        sclae: 1.03,
        width: 120.wMin,
        height: 60.wMin,
        borderRadius: 12.wMin,
        color: AppTheme.cFeedbackInfoBackground.color,
        fontSize: 24.wMin,
        fontColor: AppTheme.cFeedbackInfoText.color,
        fontWeight: FontWeight.w400,
        onTap: () async {
          await audioPlayEx.stop();
          cleanAssColor();
          ReviewExerciseUtils.toEval(widget.contentType, widget.contentId, widget.pronunciations?[englishAmericanType]?.national);
        },
      ),
    );
  }
}

class ElementsPronunciationModuleWidget extends StatefulWidget {
  final String? contentType;
  final int? contentId;
  final String content;
  final List<PronunciationsEntity?>? pronunciations;

  /// 发音模块
  const ElementsPronunciationModuleWidget({super.key, required this.contentType, required this.contentId, required this.content, this.pronunciations});

  @override
  State<ElementsPronunciationModuleWidget> createState() => _ElementsPronunciationModuleWidgetState();
}

class _ElementsPronunciationModuleWidgetState extends State<ElementsPronunciationModuleWidget> {
  List<PronunciationsEntity> pronunciations = [];

  /// 英音/美音选择下标
  int englishAmericanType = 0;

  /// 音节划分/自然拼读 选择下标
  int syllableDividerType = 0;

  /// 自然拼读 字母
  List<DecodingGradingLetterModel> gradingLetters = [];

  /// 自然拼读 音节
  List<String> phoneticsStrs = [];

  /// 自然拼读 位置
  List<List<int?>> phoneticsPos = [];

  /// 正在播放的下标 999=全部亮起 -1=没有读
  int playingIndex = -1;

  /// 播放是否暂停
  bool isPause = false;

  @override
  void initState() {
    super.initState();
    if (widget.pronunciations != null && widget.pronunciations!.isNotEmpty) {
      for (var item in widget.pronunciations!) {
        if (item == null) continue;
        pronunciations.add(item);
      }
      init();
      setGradingLettersData();
    }
  }

  void init() {
    List<PronunciationsEntityIpa?>? syllables = pronunciations[englishAmericanType].syllables; //音节
    List<PronunciationsEntityIpa?>? phonetics = pronunciations[englishAmericanType].phonetics; //自然拼读

    if (syllables != null && syllables.isNotEmpty) {
      syllableDividerType = 0;
      if ((syllables.length) <= 1) {
        syllableDividerType = 1;
      }
    } else if (phonetics != null && phonetics.isNotEmpty) {
      syllableDividerType = 1;
    }
  }

  void setGradingLettersData() {
    List<PronunciationsEntityIpa?> phonetics = pronunciations[englishAmericanType].phonetics ?? [];

    if (phonetics.isEmpty) return;
    phoneticsStrs.clear();
    phoneticsPos.clear();
    for (var item in phonetics) {
      if (item == null) continue;
      phoneticsStrs.add(item.ipa ?? "");
      List<int?> positions = item.positions ?? [];
      if (item.ipa == null || item.ipa == "") {
        positions = [];
      }
      phoneticsPos.add(positions);
    }

    gradingLetters.clear();
    for (int i = 0; i < widget.content.length; i++) {
      gradingLetters.add(DecodingGradingLetterModel(
        letter: widget.content[i],
        key: GlobalKey(),
      ));
    }
    if (mounted) setState(() {});
  }

  /// 开始播放音节
  Future<void> startPlaySyllables() async {
    try {
      if (playingIndex != -1) return;
      isPause = false;
      if (isPause) return;
      List<PronunciationsEntityIpa?> syllables = pronunciations[englishAmericanType].syllables ?? [];
      for (int i = 0; i < syllables.length; i++) {
        if (syllables[i] == null) continue;
        if (syllables[i]?.audioUrl == null) continue;
        playingIndex = i;
        if (mounted) setState(() {});
        await PlayAudioUtils.instance.playSingle(syllables[i]?.audioUrl ?? "");
        if (!mounted) return;
        if (isPause) return;
      }

      if (syllables.length == 1) {
        playingIndex = -1;
        if (mounted) setState(() {});
        return;
      }

      playingIndex = 999;
      if (mounted) setState(() {});
      await PlayAudioUtils.instance.playSingle(pronunciations[englishAmericanType].audioUrl);
      if (!mounted) return;
      if (isPause) return;
      playingIndex = -1;
      if (mounted) setState(() {});
    } catch (_) {
      playingIndex = -1;
      if (mounted) setState(() {});
    }
  }

  /// 播放音节Item
  Future<void> playSyllablesItem(int index) async {
    if (playingIndex != -1) return;
    List<PronunciationsEntityIpa?> syllables = pronunciations[englishAmericanType].syllables ?? [];
    if (index >= syllables.length) return;
    if (syllables[index] == null) return;
    if (syllables[index]?.audioUrl == null) return;
    playingIndex = index;
    if (mounted) setState(() {});
    await PlayAudioUtils.instance.playSingle(syllables[index]?.audioUrl ?? "");
    if (!mounted) return;
    if (syllableDividerType == 1) return;
    playingIndex = -1;
    if (mounted) setState(() {});
  }

  /// 开始播放自然拼读
  Future<void> startPlayPhonetics() async {
    try {
      if (playingIndex != -1) return;
      isPause = false;
      if (isPause) return;
      List<PronunciationsEntityIpa?> phonetics = pronunciations[englishAmericanType].phonetics ?? [];
      for (int i = 0; i < phonetics.length; i++) {
        if (phonetics[i] == null) continue;
        if (phonetics[i]?.audioUrl == null) continue;
        playingIndex = i;
        if (mounted) setState(() {});
        await PlayAudioUtils.instance.playSingle(phonetics[i]?.audioUrl);
        if (!mounted) return;
        if (isPause) return;
      }

      playingIndex = 999;
      if (mounted) setState(() {});
      await PlayAudioUtils.instance.playSingle(pronunciations[englishAmericanType].audioUrl);
      if (!mounted) return;
      if (isPause) return;
      playingIndex = -1;
      if (mounted) setState(() {});
    } catch (_) {
      playingIndex = -1;
      if (mounted) setState(() {});
    }
  }

  /// 点击单个自然拼读字母播放
  Future<void> playPhoneticsItem(int index) async {
    if (playingIndex != -1) return;
    List<PronunciationsEntityIpa?> phonetics = pronunciations[englishAmericanType].phonetics ?? [];

    for (int i = 0; i < phonetics.length; i++) {
      if (phoneticsPos[i].contains(index)) {
        if (phonetics[i] == null) continue;
        if (phonetics[i]?.audioUrl == null) continue;
        playingIndex = i;
        if (mounted) setState(() {});
        await PlayAudioUtils.instance.playSingle(phonetics[i]?.audioUrl);
        break;
      }
    }
    playingIndex = -1;
    if (mounted) setState(() {});
  }

  /// 播放单独知识点
  Future<void> playKnowledgePointItem() async {
    isPause = false;
    if (playingIndex != -1) return;

    PronunciationsEntity pronunciation = pronunciations[englishAmericanType];
    if (pronunciation.audioUrl == null) return;
    playingIndex = 999;
    if (mounted) setState(() {});
    await PlayAudioUtils.instance.playSingle(pronunciation.audioUrl);
    if (!mounted) return;
    if (isPause) return;
    playingIndex = -1;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (pronunciations.isEmpty) {
      return Container();
    }

    PronunciationsEntity currentPronunciation = pronunciations[englishAmericanType];

    List<PronunciationsEntityIpa?> syllables = currentPronunciation.syllables ?? []; //音节
    List<PronunciationsEntityIpa?> phonetics = currentPronunciation.phonetics ?? []; //自然拼读

    return Column(
      children: [
        SizedBox(height: 16.wMin),
        ElemenetsTitleH1Widget(
          showDot: true,
          dotColor: const Color(0xff38BDF8),
          fontColor0: AppTheme.cTextSecondary,
          titles: [
            LanguageText(text: "Pronunciation", lang: Get.find<ConfigController>().userSetting.value.learningLang),
            LanguageText(text: "发音", lang: Get.find<ConfigController>().userSetting.value.localLang),
          ],
        ),
        SizedBox(height: 32.wMin),
        Container(
          margin: EdgeInsets.only(left: 16.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cBgSecondary.color,
            borderRadius: BorderRadius.circular(10.wMin),
          ),
          child: Column(
            children: [
              ElementsUSUKTabWidget(
                pronunciations: pronunciations,
                onTap: (index) {
                  setState(() {
                    englishAmericanType = index;
                    playingIndex = -1;
                    isPause = true;
                    setGradingLettersData();
                    PlayAudioUtils.instance.stopAll();
                  });
                },
                englishAmericanType: englishAmericanType,
              ),
              Container(
                height: 2.wMin,
                color: AppTheme.cBorderPrimary.color,
              ),
              SizedBox(height: 24.wMin),
              _buildTabDividerWidget(),
              SizedBox(height: 24.wMin),
              Visibility(
                visible: !(syllables.isEmpty && phonetics.isEmpty),
                child: syllableDividerType == 0 ? _buildSyllablesWidget() : _buildPhoneticsWidget(),
              ),
              Visibility(
                visible: (syllables.isEmpty && phonetics.isEmpty),
                child: _buildNotDataWidget(),
              ),
              _buildHasPracticeWidget(),
              SizedBox(height: 40.wMin),
            ],
          ),
        ),
        SizedBox(height: 40.wMin),
      ],
    );
  }

  Widget _buildNotDataWidget() {
    if (pronunciations.isEmpty) return Container();
    PronunciationsEntity currentPronunciation = pronunciations[englishAmericanType];
    Color textColor = AppTheme.cTextPrimary.color;
    if (playingIndex == 999) {
      textColor = AppTheme.cTextBrand.color.withValues(alpha: 0.8);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 24.wMin,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: playingIndex == 999 ? AppTheme.cTextBrand.color.withValues(alpha: 0.8) : AppTheme.cBgTertiary.color,
          ),
          child: Text(
            widget.content,
            style: TextStyle(
              fontSize: 80.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 24.wMin,
          children: [
            Text(
              "/ ${currentPronunciation.phonetic ?? ''} /",
              style: TextStyle(
                fontSize: 40.wMin,
                color: textColor,
                fontWeight: FontWeight.w500,
                fontFamily: "AndikaRegular",
              ),
            ),
            Visibility(
              visible: currentPronunciation.audioUrl != null,
              child: TapScaleWidget(
                onTap: () {
                  playKnowledgePointItem();
                },
                sclae: 1.03,
                child: _buildPlayButtonWidget(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 划分tab
  Widget _buildTabDividerWidget() {
    PronunciationsEntity currentPronunciation = pronunciations[englishAmericanType];

    List<PronunciationsEntityIpa?>? syllables = currentPronunciation.syllables; //音节
    List<PronunciationsEntityIpa?>? phonetics = currentPronunciation.phonetics; //自然拼读

    if ((syllables?.isEmpty ?? true) && (phonetics?.isEmpty ?? true)) {
      return Container();
    }

    return Container(
      height: 74.wMin,
      width: 400.wMin,
      padding: EdgeInsets.all(4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cBgTertiary.color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSyllableDividerButtonWidget("音节划分", 0, syllables?.isEmpty ?? true),
          _buildSyllableDividerButtonWidget("自然拼读", 1, phonetics?.isEmpty ?? true),
        ],
      ),
    );
  }

  /// 划分tabItem
  Widget _buildSyllableDividerButtonWidget(String name, int index, bool isDisabled) {
    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          if (isDisabled) return;
          setState(() {
            PlayAudioUtils.instance.stopAll();
            syllableDividerType = index;
            playingIndex = -1;
            isPause = true;
          });
        },
        sclae: 1.01,
        child: Container(
          height: 74.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cBgQuaternary.color.withValues(alpha: syllableDividerType == index ? 1 : 0),
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cTextPrimary.color.withValues(alpha: isDisabled ? 0.5 : 1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 音节划分widget
  Widget _buildSyllablesWidget() {
    PronunciationsEntity currentPronunciation = pronunciations[englishAmericanType];
    List<PronunciationsEntityIpa?> syllables = currentPronunciation.syllables ?? []; //音节
    if (syllables.isEmpty) {
      return Container();
    }

    bool all = playingIndex == 999;
    bool none = playingIndex == -1;

    TextStyle textStyle = TextStyle(
      fontSize: 80.wMin,
      color: AppTheme.cTextPrimary.color,
      fontWeight: FontWeight.w500,
    );

    String original = widget.content;
    int letters = 0;
    Map<int, int> hyphenMap = {};
    for (int i = 0; i < original.length; i++) {
      String ch = original[i];
      if (ch == '-') {
        hyphenMap[letters] = (hyphenMap[letters] ?? 0) + 1;
      } else {
        letters++;
      }
    }

    final List<String> displayTexts = [];
    final List<int?> displaySources = [];
    int acc = 0;
    for (int sourceIndex = 0; sourceIndex < syllables.length; sourceIndex++) {
      String g = syllables[sourceIndex]?.graphemes ?? "";
      displayTexts.add(g);
      displaySources.add(sourceIndex);
      acc += g.length;
      int hyphenCount = hyphenMap[acc] ?? 0;
      for (int h = 0; h < hyphenCount; h++) {
        displayTexts.add("-");
        displaySources.add(null);
      }
    }

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6.wMin,
          children: List.generate(displayTexts.length, (index) {
            int? srcIdx = displaySources[index];
            bool isActive = playingIndex == 999 || (srcIdx != null && playingIndex == srcIdx);
            if (srcIdx == null) {
              return Text(displayTexts[index], style: textStyle);
            }
            return TapScaleWidget(
              onTap: () {
                playSyllablesItem(srcIdx);
              },
              sclae: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: isActive ? AppTheme.cTextBrand.color.withValues(alpha: 0.8) : AppTheme.cBgTertiary.color,
                ),
                child: Text(
                  displayTexts[index],
                  style: textStyle,
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 40.wMin),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "/ ",
              style: TextStyle(
                fontSize: 40.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
                fontFamily: "AndikaRegular",
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(syllables.length, (index) {
                Color textColor = AppTheme.cTextPrimary.color;
                if (none) {
                  textColor = AppTheme.cTextPrimary.color;
                } else if (all) {
                  textColor = AppTheme.cTextBrand.color;
                } else {
                  if (playingIndex != -1 && playingIndex != 999) {
                    if (playingIndex == index) {
                      textColor = AppTheme.cTextBrand.color;
                    } else {
                      textColor = AppTheme.cTextPrimary.color;
                    }
                  }
                }

                return Text(
                  syllables[index]?.ipa ?? "",
                  style: TextStyle(
                    fontSize: 40.wMin,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontFamily: "AndikaRegular",
                  ),
                );
              }),
            ),
            Text(
              " /",
              style: TextStyle(
                fontSize: 40.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
                fontFamily: "AndikaRegular",
              ),
            ),
            SizedBox(width: 20.wMin),
            TapScaleWidget(
              onTap: () {
                startPlaySyllables();
              },
              sclae: 1.03,
              child: _buildPlayButtonWidget(),
            ),
          ],
        ),
      ],
    );
  }

  /// 自然拼读widget
  Widget _buildPhoneticsWidget() {
    bool all = playingIndex == 999;
    bool none = playingIndex == -1;

    if (gradingLetters.isEmpty) {
      return Container();
    }

    return Column(
      children: [
        CustomPaint(
          painter: DecodingGradingPainter(
            strokeWidth: 5.wMin,
            curveRadius: 25.wMin,
            letterBottomHeight: 4.wMin,
            models: gradingLetters,
            positions: phoneticsPos,
            color: AppTheme.cTextBrand.color,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(gradingLetters.length, (index) {
              Color textColor = AppTheme.cTextPrimary.color;
              if (none) {
                textColor = AppTheme.cTextPrimary.color;
              } else if (all) {
                textColor = AppTheme.cTextBrand.color;
              } else {
                if (playingIndex != -1 && playingIndex != 999) {
                  if (phoneticsPos[playingIndex].contains(index)) {
                    textColor = AppTheme.cTextBrand.color;
                  } else {
                    textColor = AppTheme.cTextPrimary.color;
                  }
                }
              }

              return TapScaleWidget(
                onTap: () {
                  playPhoneticsItem(index);
                },
                sclae: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.wMin),
                  color: Colors.transparent,
                  child: Text(
                    gradingLetters[index].letter,
                    key: gradingLetters[index].key,
                    style: TextStyle(
                      fontSize: 80.wMin,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 40.wMin),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "/ ",
              style: TextStyle(
                fontSize: 40.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
                fontFamily: "AndikaRegular",
              ),
            ),
            Row(
              children: List.generate(phoneticsStrs.length, (index) {
                Color textColor = AppTheme.cTextPrimary.color;
                if (none) {
                  textColor = AppTheme.cTextPrimary.color;
                } else if (all) {
                  textColor = AppTheme.cTextBrand.color;
                } else {
                  if (playingIndex != -1 && playingIndex != 999) {
                    if (playingIndex == index) {
                      textColor = AppTheme.cTextBrand.color;
                    } else {
                      textColor = AppTheme.cTextPrimary.color;
                    }
                  }
                }
                return Text(
                  phoneticsStrs[index],
                  style: TextStyle(
                    fontSize: 40.wMin,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontFamily: "AndikaRegular",
                  ),
                );
              }),
            ),
            Text(
              " /",
              style: TextStyle(
                fontSize: 40.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
                fontFamily: "AndikaRegular",
              ),
            ),
            SizedBox(width: 20.wMin),
            TapScaleWidget(
              onTap: () {
                startPlayPhonetics();
              },
              sclae: 1.03,
              child: _buildPlayButtonWidget(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayButtonWidget() {
    return Container(
      width: 64.wMin,
      height: 64.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.cBgQuaternary.color,
      ),
      child: SvgPicture.asset(
        "assets/svg/public/icon_speaker.svg",
        width: 40.wMin,
        height: 40.wMin,
        colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
      ),
    );
  }

  /// 是否有练习题按钮
  Widget _buildHasPracticeWidget() {
    if (pronunciations[englishAmericanType].isExercise != true) return Container();
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.only(top: 24.wMin, right: 40.wMin),
      child: ButtonWidget(
        text: "去练习",
        sclae: 1.03,
        width: 120.wMin,
        height: 60.wMin,
        borderRadius: 12.wMin,
        color: AppTheme.cFeedbackInfoBackground.color,
        fontSize: 24.wMin,
        fontColor: AppTheme.cFeedbackInfoText.color,
        fontWeight: FontWeight.w400,
        onTap: () async {
          await PlayAudioUtils.instance.stopAll();
          playingIndex = -1;
          isPause = true;
          if (mounted) setState(() {});

          ReviewExerciseUtils.toEval(widget.contentType, widget.contentId, pronunciations[englishAmericanType].national);
        },
      ),
    );
  }
}

class ElementsUSUKTabWidget extends StatelessWidget {
  final List<PronunciationsEntity?> pronunciations;
  final void Function(int index) onTap;
  final int englishAmericanType;
  const ElementsUSUKTabWidget({super.key, required this.pronunciations, required this.onTap, required this.englishAmericanType});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth - (pronunciations.length - 1) * 2.wMin;
        double itemWidth = width / pronunciations.length;
        return Container(
          height: 90.wMin,
          width: double.infinity,
          alignment: Alignment.center,
          child: ListView.separated(
            itemCount: pronunciations.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return Center(
                child: Container(
                  width: 2.wMin,
                  height: 42.wMin,
                  color: AppTheme.cBorderPrimary.color,
                ),
              );
            },
            itemBuilder: (context, index) {
              return TapScaleWidget(
                onTap: () {
                  onTap(index);
                },
                sclae: 1,
                child: Container(
                  width: itemWidth,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Text(
                    pronunciations[index]?.nationalTitle ?? "",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: englishAmericanType == index ? AppTheme.cTextBrand.color : AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    // return Row(
    //   children: List.generate(pronunciations.length, (index){
    //     return Expanded(
    //       child: TapScaleWidget(
    //         onTap: (){
    //           onTap(index);
    //         },
    //         sclae: 1,
    //         child: Container(
    //           alignment: Alignment.center,
    //           height: 42.wMin,
    //           decoration: BoxDecoration(
    //             color: Colors.transparent,
    //             border: Border(
    //               right: BorderSide(
    //                 color:AppTheme.cBorderPrimary.color.withValues(alpha: index == pronunciations.length - 1 ? 0 : 0.6),
    //                 width: 1.wMin,
    //               ),
    //             ),
    //           ),
    //           child: Text(
    //             pronunciations[index]?.nationalTitle??"",
    //             style: TextStyle(
    //               fontSize: 28.wMin,
    //               color: englishAmericanType == index ? AppTheme.cTextBrand.color : AppTheme.cTextPrimary.color,
    //               fontWeight: FontWeight.w500,
    //             ),
    //           ),

    //         ),
    //       ),
    //     );
    //   }),
    // );
  }
}

class ElemenetsTitleH1Widget extends StatelessWidget {
  final List<LanguageText> titles;
  final bool showDot;
  final Color? dotColor;
  final Color? fontColor0;
  final double? fontSize0;
  final double? fontSize1;
  final double? spacing;
  final int type;
  const ElemenetsTitleH1Widget({
    super.key,
    required this.titles,
    this.dotColor,
    this.showDot = false,
    this.fontColor0,
    this.fontSize0,
    this.fontSize1,
    this.spacing,
    this.type = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: showDot,
          child: Container(
            height: 54.wMin,
            margin: EdgeInsets.only(right: 8.wMin),
            alignment: Alignment.centerLeft,
            child: Container(
              width: 16.wMin,
              height: 16.wMin,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            List<LanguageText> langText = [];
            if (type == 0) {
              langText = LearningLangUtils.getShowLBList(titles);
            } else if (type == 1) {
              langText = LearningLangUtils.getShowLBList(titles);
            }
            if (langText.isEmpty) return Container();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: spacing ?? 12.wMin,
              children: List.generate(langText.length, (index) {
                if (index == 0) {
                  return Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      langText[index].text ?? "",
                      style: TextStyle(
                        fontSize: fontSize0 ?? 36.wMin,
                        fontWeight: FontWeight.w600,
                        color: fontColor0 ?? AppTheme.cTextPrimary,
                      ),
                    ),
                  );
                }
                return Column(
                  spacing: 8.wMin,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DottedBorder(
                      borderType: BorderType.RRect,
                      dashPattern: [5.wMin, 3.5.wMin],
                      color: AppTheme.cTextSecondary,
                      strokeWidth: 1.wMin,
                      customPath: (size) => Path()
                        ..moveTo(0, size.height)
                        ..relativeLineTo(size.width, 0),
                      padding: EdgeInsets.zero,
                      child: SizedBox(height: 1.wMin, width: 134.wMin),
                    ),
                    Text(
                      langText[index].text ?? "",
                      style: TextStyle(
                        fontSize: fontSize1 ?? 32.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary,
                      ),
                    ),
                  ],
                );
              }),
            );
          }),
        ),
      ],
    );
  }
}

class ElementsDashedLineWidget extends StatelessWidget {
  final double? strokeWidth;
  const ElementsDashedLineWidget({super.key, this.strokeWidth});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      dashPattern: [8.wMin, 6.wMin],
      color: AppTheme.cBorderPrimary,
      strokeWidth: strokeWidth ?? 1.wMin,
      customPath: (size) => Path()
        ..moveTo(0, size.height)
        ..relativeLineTo(size.width, 0),
      padding: EdgeInsets.zero,
      child: Container(height: 1.wMin),
    );
  }
}

class ElementsTagTapWidget extends StatelessWidget {
  final List<ElementsTabViewTagModel> tabs;
  final int currentIndex;
  final void Function(int index)? onTap;
  const ElementsTagTapWidget({super.key, required this.tabs, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 20.wMin,
        children: List.generate(tabs.length, (index) {
          return TapScaleWidget(
            onTap: onTap == null ? null : () => onTap?.call(index),
            sclae: 1.03,
            child: Container(
              color: Colors.transparent,
              child: Text(
                tabs[index].title ?? "",
                style: TextStyle(
                  fontSize: currentIndex == index ? 40.wMin : 28.wMin,
                  color: currentIndex == index ? (tabs[index].color ?? AppTheme.cTextBrand) : AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ElementsTagTap1Widget extends StatelessWidget {
  final List<String> tabs;
  final int currentIndex;
  final void Function(int index)? onTap;
  const ElementsTagTap1Widget({super.key, required this.tabs, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8.wMin,
        children: List.generate(tabs.length, (index) {
          return TapScaleWidget(
            onTap: onTap == null ? null : () => onTap?.call(index),
            sclae: 1.03,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 8.wMin, horizontal: 20.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: currentIndex == index ? AppTheme.cBgTertiary : Colors.transparent,
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: currentIndex == index ? AppTheme.cTextPrimary : AppTheme.cTextTertiary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ElementsTabBarWidget extends StatelessWidget {
  final TabController? controller;
  final List<List<LanguageText?>> tabList;
  const ElementsTabBarWidget({super.key, this.controller, required this.tabList});

  @override
  Widget build(BuildContext context) {
    if (tabList.isEmpty) return Container();
    return TabBar(
      controller: controller,
      automaticIndicatorColorAdjustment: false,
      isScrollable: true,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      indicatorPadding: EdgeInsets.symmetric(horizontal: 20.wMin),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.zero,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.cTextPrimary,
            width: 4.wMin,
          ),
        ),
      ),
      tabAlignment: TabAlignment.start,
      dividerHeight: 0,
      dividerColor: Colors.transparent,
      labelPadding: EdgeInsets.symmetric(horizontal: 16.wMin),
      labelStyle: TextStyle(
        fontSize: 32.wMin,
        color: AppTheme.cTextPrimary,
        fontWeight: FontWeight.w400,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 32.wMin,
        color: AppTheme.cTextPrimary,
        fontWeight: FontWeight.w400,
      ),
      tabs: List.generate(tabList.length, (index) {
        return Obx(() {
          List<LanguageText> learningLangTexts = LearningLangUtils.getShowLBList(tabList[index]);
          return Container(
            margin: EdgeInsets.only(bottom: 4.wMin),
            child: Text(learningLangTexts.map((e) => e.text).join(" ")),
          );
        });
      }),
    );
  }
}

class ElementsLeftInfoWidget extends StatelessWidget {
  final String value;
  final double? fontSize;
  final String? imageUrl;
  final FontWeight? fontWeight;
  final int? maxLines;
  final CardDetilsEntityStat? stat;
  final ElementsCardStar? star;
  final List<PronunciationsEntity?>? pronunciations;
  const ElementsLeftInfoWidget({
    super.key,
    required this.value,
    this.fontSize,
    this.imageUrl,
    this.fontWeight,
    this.maxLines,
    this.stat,
    this.star,
    this.pronunciations,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420.wMin,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: 8.wMin,
          bottom: MediaQuery.of(context).padding.bottom + 40.wMin,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.wMin),
              child: Container(
                width: 420.wMin,
                height: 420.wMin,
                color: AppTheme.cBlackAlpha10,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedImageWidget(
                      imageUrl ?? "",
                      errorWidget: buildEmptyWidget(),
                      placeholder: buildLoadingWidget(),
                    ),
                    Visibility(
                      visible: pronunciations?.isNotEmpty ?? false,
                      child: Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(pronunciations?.length ?? 0, (index) {
                            return PlayLottieIconWidget(
                              size: 48.wMin,
                              audioUrl: pronunciations?[index]?.audioUrl,
                              backgroundImageUrl: pronunciations?[index]?.nationalIconUrl,
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.wMin),
            AutoSizeText(
              value,
              maxLines: maxLines,
              minFontSize: 4,
              style: TextStyle(
                fontSize: fontSize ?? 80.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: fontWeight ?? FontWeight.w600,
              ),
            ),
            SizedBox(height: 40.wMin),
            ElemenetsCardStarLevelWidget(fontSize: 24.wMin, star: star),
            SizedBox(height: 32.wMin),
            ElementsProgressWidget(
              name: "听",
              svg: "assets/svg/elements/icon_listen.svg",
              value: stat?.listenExp == null ? "" : "+${stat?.listenExp?.toString() ?? ''}",
              progress: stat?.listenPct?.toDouble() ?? 0,
            ),
            SizedBox(height: 18.wMin),
            ElementsProgressWidget(
              name: "说",
              svg: "assets/svg/elements/icon_speak.svg",
              value: stat?.speakExp == null ? "" : "+${stat?.speakExp?.toString() ?? ''}",
              progress: stat?.speakPct?.toDouble() ?? 0,
            ),
            SizedBox(height: 18.wMin),
            ElementsProgressWidget(
              name: "读",
              svg: "assets/svg/elements/icon_read.svg",
              value: stat?.readExp == null ? "" : "+${stat?.readExp?.toString() ?? ''}",
              progress: stat?.readPct?.toDouble() ?? 0,
            ),
            SizedBox(height: 18.wMin),
            ElementsProgressWidget(
              name: "写",
              svg: "assets/svg/elements/icon_write.svg",
              value: stat?.writeExp == null ? "" : "+${stat?.writeExp?.toString() ?? ''}",
              progress: stat?.writePct?.toDouble() ?? 0,
            ),
          ],
        ),
      ),
    );
  }
}
