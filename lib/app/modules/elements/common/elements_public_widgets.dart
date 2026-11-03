import 'dart:ui';
import 'dart:async';

import 'package:audio_player_ex/audio_player_ex.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:quiz_play/component/tips_video_widget.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/painter/jigsaw_puzzle_box_painter.dart';
import 'package:langwise/common/painter/painter.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/utils/karaoke_subtitles_utils.dart';
import 'package:langwise/utils/utils.dart';
import '../../../../theme/theme_utils.dart';
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
          // SizedBox(height: 64.wMin),
          // ElemenetsTitleH1Widget(
          //   dotColor: const Color(0xff4ADE80),
          //   showDot: true,
          //   titles: [
          //     LanguageText(text: "Roots and Affixes", lang: "en"),
          //     LanguageText(text: "词根词缀", lang: "zh"),
          //   ],
          // ),
          // SizedBox(height: 40.wMin),
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
              type: boxType,
              // 选择拼图类型
              radius: 4.wMin,
              // 外层圆角
              color: color.withValues(alpha: 0.2),
              // 填充颜色
              exWidth: 10.wMin,
              // 凹凸宽度
              exHeight: 30.wMin,
              // 凹凸高度
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
    final list = grammatical ?? const [];
    if (list.isEmpty) return Container();
    return Container(
      margin: EdgeInsets.only(bottom: 64.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ElementsDashedLineWidget(),
          // SizedBox(height: 64.wMin),
          // ElemenetsTitleH1Widget(
          //   dotColor: const Color(0xffA78BFA),
          //   showDot: true,
          //   titles: [
          //     LanguageText(text: "Grammatical features", lang: "en"),
          //     LanguageText(text: "语法特性", lang: "zh"),
          //   ],
          // ),
          // SizedBox(height: 40.wMin),
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
                children: List.generate(list.length, (index) {
                  return _buildListItemWidget(list[index]);
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
        ElementsTypeCardWidget(
          jumpToDetail: false,
          data: ElementsDetilsDataModel(
            type: ElementsCardType.fromRawValue(data?.inflections?.pluralInfo?.contentType ?? ""),
            data: data?.inflections?.pluralInfo,
            hideStar: true,
          ),
        ),
        SizedBox(height: 24.wMin),
        () {
          final list = data?.inflections?.inflectionContentList;
          if (list == null || list.isEmpty) return SizedBox.shrink();
          return Wrap(
            spacing: 10.wMin,
            runSpacing: 24.wMin,
            children: List<Widget>.generate(list.length, (int index) {
              final item = list[index];
              return ElementsTypeCardWidget(
                jumpToDetail: false,
                data: ElementsDetilsDataModel(
                  type: ElementsCardType.fromRawValue(item.contentType ?? ""),
                  data: item,
                  hideStar: true,
                ),
              );
            }),
          );
        }(),
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
  final int? excludeContentId;
  final String? excludeContentType;

  const ElementsInterpretationModuleItemWidget({
    super.key,
    required this.index,
    this.semantics,
    this.onVisibilityChanged,
    this.excludeContentId,
    this.excludeContentType,
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
    List<ElementsCardEntityDatas?> synonyms = _filterSelf(widget.semantics?[widget.index]?.synonyms ?? const []);
    List<ElementsCardEntityDatas?> antonyms = _filterSelf(widget.semantics?[widget.index]?.antonyms ?? const []);

    return VisibilityDetector(
      key: ValueKey(widget.index),
      onVisibilityChanged: (info) {
        widget.onVisibilityChanged?.call(widget.index, info.visibleFraction);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(height: 48.wMin),
          _buildTitleInfoWidget(widget.semantics?[widget.index], widget.index),
          _buildExampleSentenceWidget(widget.semantics?[widget.index]),
          // ElementsTitleImagesWidget(
          //   title: "·类别",
          //   datas: topics,
          // ),
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
      margin: EdgeInsets.only(top: 30.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "·例句",
                style: TextStyle(
                  fontSize: 22.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.withValues(alpha: 0.8),
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
          SizedBox(height: 8.wMin),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              Visibility(
                visible: sentences.length > 3,
                child: TapScaleWidget(
                  onTap: () {
                    showMore = !showMore;
                    if (mounted) setState(() {});
                  },
                  sclae: 1.03,
                  child: Text(
                    showMore ? "收起例句" : "查看更多例句",
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
        // Text(
        //   "·释义${index + 1}",
        //   style: TextStyle(
        //     fontSize: 28.wMin,
        //     fontWeight: FontWeight.w400,
        //     color: AppTheme.cTextSecondary,
        //   ),
        // ),
        Obx(() {
          List<LanguageText> glossText = LearningLangUtils.getShowLBList(gloss);
          return Column(
            spacing: 8.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(glossText.length, (index) {
              if (index == 0) {
                return Row(
                  children: [
                    Text(
                      glossText[index].text ?? "",
                      style: TextStyle(
                        fontSize: 36.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextPrimary,
                      ),
                    ),
                    Visibility(
                      visible: semantic.difficulty != null,
                      child: Container(
                        margin: EdgeInsets.only(left: 12.wMin),
                        child: StatusTagDifficultyWidget(
                          difficulty: semantic.difficulty,
                          language: configController.userSetting.value.learningLang,
                          fontSize: 22.wMin,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Text(
                glossText[index].text ?? "",
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary,
                ),
              );
            }),
          );
        }),
        SizedBox(height: 24.wMin),
        // Container(
        //   height: 1.wMin,
        //   color: AppTheme.cBorderBrand,
        // ),
        // SizedBox(height: 16.wMin),
        Obx(() {
          List<LanguageText> descriptionsText = LearningLangUtils.getShowLBList(descriptions);
          return ElemenetsTitleH1Widget(titles: descriptionsText);
        }),
      ],
    );
  }

  List<ElementsCardEntityDatas?> _filterSelf(List<ElementsCardEntityDatas?> list) {
    final int? excludeId = widget.excludeContentId;
    final String? excludeType = widget.excludeContentType;
    final List<ElementsCardEntityDatas> valid = list.whereType<ElementsCardEntityDatas>().toList();
    if (excludeId == null) {
      return valid.cast<ElementsCardEntityDatas?>().toList();
    }
    final String type = excludeType ?? '';
    return valid
        .where((e) {
          if (e.contentId != excludeId) return true;
          if (type.isEmpty) return false;
          return (e.contentType ?? '') != type;
        })
        .cast<ElementsCardEntityDatas?>()
        .toList();
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

  String _normalizeUrl(String? url) {
    return (url ?? '').replaceAll('`', '').trim();
  }

  List<PronunciationsEntity> _resolveExamplePronunciations() {
    final List<PronunciationsEntity> raw = (widget.data?.pronunciations ?? const <PronunciationsEntity?>[]).whereType<PronunciationsEntity>().toList();
    if (raw.isEmpty) return const <PronunciationsEntity>[];

    final List<PronunciationsEntity> list = raw.where((e) => _normalizeUrl(e.audioUrl).isNotEmpty).toList();
    if (list.isEmpty) return const <PronunciationsEntity>[];

    final Map<String, PronunciationsEntity> byAudioUrl = <String, PronunciationsEntity>{};
    for (final PronunciationsEntity item in list) {
      final String key = _normalizeUrl(item.audioUrl);
      if (key.isEmpty) continue;
      byAudioUrl.putIfAbsent(key, () => item);
    }

    final List<PronunciationsEntity> unique = byAudioUrl.values.toList();
    unique.sort((a, b) {
      int score(PronunciationsEntity e) {
        final String national = (e.national ?? '').toUpperCase();
        if (national == 'US') return 0;
        if (national == 'UK') return 1;
        return 2;
      }

      return score(a).compareTo(score(b));
    });

    if (unique.length <= 2) return unique;
    return unique.take(2).toList();
  }

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
    final List<PronunciationsEntity> pronunciations = _resolveExamplePronunciations();
    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.wMin), border: Border.all(color: AppTheme.cBorderPrimary)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.wMin),
            child: Container(
              width: 180.wMin,
              height: 180.wMin,
              color: AppTheme.cBlackAlpha10,
              child: Stack(
                children: [
                  CachedImageWidget(
                    widget.data?.imageUrl ?? "",
                    errorWidget: buildEmptyWidget(),
                    placeholder: buildLoadingWidget(),
                  ),
                  if (pronunciations.isNotEmpty)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Row(
                        mainAxisAlignment: pronunciations.length == 1 ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                        children: List<Widget>.generate(pronunciations.length, (int index) {
                          final PronunciationsEntity pronunciation = pronunciations[index];
                          return PlayLottieIconWidget(
                            size: 48.wMin,
                            audioUrl: _normalizeUrl(pronunciation.audioUrl),
                            backgroundImageUrl: _normalizeUrl(pronunciation.nationalIconUrl),
                            backgroundColor: AppTheme.cInverseOverlay2.withValues(alpha: 0.6),
                            playSpeed: Get.find<ConfigController>().userSetting.value.expandAudioSpeed,
                          );
                        }),
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
                  minHeight: 180.wMin,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16.wMin),
                        constraints: BoxConstraints(
                          minHeight: 180.wMin,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Text(
                            //   "例句${widget.index + 1}",
                            //   style: TextStyle(
                            //     fontSize: 24.wMin,
                            //     fontWeight: FontWeight.w500,
                            //     color: AppTheme.cTextSecondary,
                            //   ),
                            // ),
                            // SizedBox(height: 6.wMin),
                            Obx(() {
                              List<LanguageText> glossText = LearningLangUtils.getShowLBList(widget.data?.gloss ?? []);
                              return ElemenetsTitleH1Widget(
                                titles: glossText,
                                fontSize0: 32.wMin,
                                fontSize1: 28.wMin,
                                spacing: 8.wMin,
                                type: 1,
                                DottedBorderWidth: 130.wMin,
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
    final list = datas ?? const [];
    if (list.isEmpty) return Container();
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
              children: List.generate(list.length, (index) {
                return _buildListWidget(list[index]);
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
      width: 180.wMin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.wMin),
            child: Container(
              width: 180.wMin,
              height: 180.wMin,
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
                  color: AppTheme.cTextSecondary.withValues(alpha: 0.6),
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
    final list = datas ?? const [];
    if (list.isEmpty) return Container();
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
              children: List.generate(list.length, (index) {
                return ElementsTypeCardWidget(
                  data: ElementsDetilsDataModel(
                    type: ElementsCardType.fromRawValue(list[index]?.contentType ?? ""),
                    data: list[index],
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
  final List<PronunciationsEntity?>? pronunciations;

  /// 短语发音模块
  const ElementsPhrasePronunciationWidget({super.key, required this.contentType, required this.contentId, this.pronunciations});

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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.wMin),
        border: Border.all(
          color: AppTheme.cBorderPrimary.color.withValues(alpha: 0.7),
          width: 2.wMin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            color: AppTheme.cBorderPrimary.color.withValues(alpha: 0.7),
          ),
          Padding(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 18.wMin),
                _buildContentWidget(),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildHasPracticeWidget(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: _buildAssWidget(),
        ),
        SizedBox(height: 12.wMin),
        ElementsPlayButtonCircle(
          onTap: playAudio,
          enabled: (widget.pronunciations?[englishAmericanType]?.audioUrl ?? '').isNotEmpty,
        ),
      ],
    );
  }

  Widget _buildAssWidget() {
    TextStyle style = TextStyle(
      fontSize: 50.wMin,
      fontWeight: FontWeight.w600,
      color: AppTheme.cTextPrimary.color,
    );

    // if (assSubtitles.isEmpty) {
    //   return Text(widget.content, style: style);
    // }

    return Wrap(
      runSpacing: 6.wMin,
      alignment: WrapAlignment.center,
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
      child: ElementsGoPracticeButton(
        height: 62,
        onTap: () async {
          await audioPlayEx.stop();
          cleanAssColor();
          ReviewExerciseUtils.toEval(
            widget.contentType,
            widget.contentId,
            widget.pronunciations?[englishAmericanType]?.national,
          );
        },
      ),
    );
  }
}

class ElementsPronunciationModuleWidget extends StatefulWidget {
  final String? contentType;
  final int? contentId;
  final String? content;
  final List<PronunciationsEntity?>? pronunciations;

  /// 发音模块
  const ElementsPronunciationModuleWidget({super.key, required this.contentType, required this.contentId, this.content, this.pronunciations});

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
    final PronunciationsEntity currentPronunciation = pronunciations[englishAmericanType];
    final List<PronunciationsEntityIpa> syllables = (currentPronunciation.syllables ?? <PronunciationsEntityIpa?>[]).whereType<PronunciationsEntityIpa>().toList();
    final List<PronunciationsEntityIpa> phonetics = (currentPronunciation.phonetics ?? <PronunciationsEntityIpa?>[]).whereType<PronunciationsEntityIpa>().toList();

    final bool hasSyllables = syllables.isNotEmpty;
    final bool hasPhonetics = phonetics.isNotEmpty;

    if (hasSyllables && syllables.length > 1) {
      syllableDividerType = 0;
      return;
    }
    if (hasPhonetics) {
      syllableDividerType = 1;
      return;
    }
    if (hasSyllables) {
      syllableDividerType = 0;
      return;
    }
  }

  bool _hasSyllables(List<PronunciationsEntityIpa?>? syllables) {
    if (syllables == null || syllables.isEmpty) return false;
    final List<PronunciationsEntityIpa> valid = syllables.whereType<PronunciationsEntityIpa>().toList();
    return valid.isNotEmpty;
  }

  bool _hasPhonetics(List<PronunciationsEntityIpa?>? phonetics) {
    if (phonetics == null || phonetics.isEmpty) return false;
    final List<PronunciationsEntityIpa> valid = phonetics.whereType<PronunciationsEntityIpa>().toList();
    return valid.isNotEmpty;
  }

  int _resolveDividerType({
    required bool hasSyllables,
    required bool hasPhonetics,
  }) {
    if (syllableDividerType == 0 && hasSyllables) return 0;
    if (syllableDividerType == 1 && hasPhonetics) return 1;
    if (hasSyllables) return 0;
    if (hasPhonetics) return 1;
    return 0;
  }

  String _normalizedContent() {
    final String raw = (widget.content ?? '').replaceAll(RegExp(r'\s+'), '').trim();
    if (raw.isNotEmpty) return raw;
    return _buildContentFromPronunciation();
  }

  String _buildContentFromPronunciation() {
    if (pronunciations.isEmpty) return '';
    final PronunciationsEntity currentPronunciation = pronunciations[englishAmericanType];
    final List<PronunciationsEntityIpa> phonetics = (currentPronunciation.phonetics ?? <PronunciationsEntityIpa?>[]).whereType<PronunciationsEntityIpa>().toList();
    final String fromPositions = _buildContentFromPhonetics(phonetics);
    if (fromPositions.isNotEmpty) return fromPositions;

    final List<PronunciationsEntityIpa> syllables = (currentPronunciation.syllables ?? <PronunciationsEntityIpa?>[]).whereType<PronunciationsEntityIpa>().toList();
    final String fromSyllables = syllables.map((PronunciationsEntityIpa e) => (e.graphemes ?? '').trim()).where((String e) => e.isNotEmpty).join('').trim();
    return fromSyllables;
  }

  String _buildContentFromPhonetics(List<PronunciationsEntityIpa> phonetics) {
    if (phonetics.isEmpty) return '';
    int maxIndex = -1;
    for (final PronunciationsEntityIpa item in phonetics) {
      final List<int> positions = item.positions?.whereType<int>().toList() ?? <int>[];
      if (positions.isEmpty) continue;
      final int localMax = positions.reduce((int a, int b) => a > b ? a : b);
      if (localMax > maxIndex) maxIndex = localMax;
    }
    if (maxIndex < 0) return '';

    final List<String> chars = List<String>.filled(maxIndex + 1, '');
    for (final PronunciationsEntityIpa item in phonetics) {
      final String graphemes = (item.graphemes ?? '').trim();
      final List<int> positions = item.positions?.whereType<int>().toList() ?? <int>[];
      if (graphemes.isEmpty || positions.isEmpty) continue;

      if (graphemes.length == positions.length) {
        for (int i = 0; i < positions.length; i++) {
          final int index = positions[i];
          if (index < 0 || index >= chars.length) continue;
          chars[index] = graphemes[i];
        }
        continue;
      }

      final String chunk = graphemes.replaceAll(RegExp(r'\s+'), '');
      final int start = positions.reduce((int a, int b) => a < b ? a : b);
      if (start >= 0 && start < chars.length && chars[start].isEmpty) {
        chars[start] = chunk;
      }
      for (final int index in positions.skip(1)) {
        if (index < 0 || index >= chars.length) continue;
        if (chars[index].isEmpty) chars[index] = '';
      }
    }

    return chars.join().trim();
  }

  String _buildDisplayContent() {
    final PronunciationsEntity currentPronunciation = pronunciations[englishAmericanType];
    final List<PronunciationsEntityIpa> syllables = (currentPronunciation.syllables ?? <PronunciationsEntityIpa?>[]).whereType<PronunciationsEntityIpa>().toList();
    if (_hasSyllables(syllables.cast<PronunciationsEntityIpa?>())) {
      final String text = syllables.map((PronunciationsEntityIpa e) => e.graphemes ?? '').join('-').trim();
      if (text.isNotEmpty) return text;
    }

    final List<PronunciationsEntityIpa> phonetics = (currentPronunciation.phonetics ?? <PronunciationsEntityIpa?>[]).whereType<PronunciationsEntityIpa>().toList();
    final String phoneticsText = phonetics.map((PronunciationsEntityIpa e) => e.graphemes ?? '').where((String e) => e.isNotEmpty).join(' · ').trim();
    if (phoneticsText.isNotEmpty) return phoneticsText;

    return widget.content ?? '';
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
    final String content = _normalizedContent();
    for (int i = 0; i < content.length; i++) {
      gradingLetters.add(DecodingGradingLetterModel(
        letter: content[i],
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

      // 确保按字母在单词中的先后顺序播放（根据 positions 最小值排序）
      int firstPos(PronunciationsEntityIpa? it, int fallback) {
        final List<int> pos = it?.positions?.whereType<int>().toList() ?? <int>[];
        if (pos.isEmpty) return fallback;
        int minVal = pos.first;
        for (final int v in pos) {
          if (v < minVal) minVal = v;
        }
        return minVal;
      }
      final List<int> order = List<int>.generate(phonetics.length, (i) => i)
        ..sort((int a, int b) {
          final int pa = firstPos(phonetics[a], a);
          final int pb = firstPos(phonetics[b], b);
          return pa.compareTo(pb);
        });

      for (final int idx in order) {
        final PronunciationsEntityIpa? item = phonetics[idx];
        if (item == null) continue;
        if ((item.audioUrl ?? '').isEmpty) continue;
        playingIndex = idx;
        if (mounted) setState(() {});
        await PlayAudioUtils.instance.playSingle(item.audioUrl);
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
    final bool hasSyllables = _hasSyllables(syllables);
    final bool hasPhonetics = _hasPhonetics(phonetics);
    final int effectiveDividerType = _resolveDividerType(
      hasSyllables: hasSyllables,
      hasPhonetics: hasPhonetics,
    );
    final bool showDividerTabs = hasSyllables && hasPhonetics;
    final Widget contentWidget = (!hasSyllables && !hasPhonetics)
        // tod
        ? _buildNotDataWidget()
        : (effectiveDividerType == 0 ? _buildSyllablesWidget() : _buildPhoneticsWidget());

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.wMin),
        border: Border.all(
          color: AppTheme.cBorderPrimary.color.withValues(alpha: 0.7),
          width: 2.wMin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 关键：让高度由子项决定
        children: [
          _buildPronunciationHeaderWidget(),
          Container(
            height: 2.wMin,
            color: AppTheme.cBorderPrimary.color.withValues(alpha: 0.7),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.wMin, 18.wMin, 20.wMin, 18.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Center(child: contentWidget),
                ),
                Row(
                    // 两端对齐，水平居中
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (showDividerTabs) Align(alignment: Alignment.centerLeft, child: _buildTabDividerWidget()),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildHasPracticeWidget(),
                      ),
                    ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPronunciationHeaderWidget() {
    return ElementsUSUKTabWidget(
      pronunciations: pronunciations,
      englishAmericanType: englishAmericanType,
      onTap: (int index) {
        setState(() {
          englishAmericanType = index;
          init();
          playingIndex = -1;
          isPause = true;
          setGradingLettersData();
          PlayAudioUtils.instance.stopAll();
        });
      },
    );
  }

  Widget _buildNotDataWidget() {
    if (pronunciations.isEmpty) return Container();
    PronunciationsEntity currentPronunciation = pronunciations[englishAmericanType];
    Color textColor = AppTheme.cTextPrimary;
    if (playingIndex == 999) {
      textColor = AppTheme.cTextBrand.color.withValues(alpha: 0.95);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 22.wMin, vertical: 12.wMin),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.cBorderPrimary),
            borderRadius: BorderRadius.circular(18.wMin),
            color: AppTheme.cSurfaceTertiary,
          ),
          child: Text(
            _buildDisplayContent(),
            style: TextStyle(
              fontSize: 54.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 16.wMin),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "/ ",
              style: TextStyle(
                fontSize: 30.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
                fontFamily: "AndikaRegular",
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    currentPronunciation.phonetic ?? '',
                    style: TextStyle(
                      fontSize: 30.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                      fontFamily: "AndikaRegular",
                    ),
                  ),
                ),
              ],
            ),
            Text(
              " /",
              style: TextStyle(
                fontSize: 30.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
                fontFamily: "AndikaRegular",
              ),
            ),
            SizedBox(width: 12.wMin),
            TapScaleWidget(
              onTap: () {
                playKnowledgePointItem();
              },
              sclae: 1.03,
              child: _buildPlayButtonWidget(),
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

    final bool hasSyllables = _hasSyllables(syllables);
    final bool hasPhonetics = _hasPhonetics(phonetics);
    if (!hasSyllables || !hasPhonetics) {
      return Container();
    }
    final List<IconDropdownCheckData<int>> items = [
      IconDropdownCheckData<int>(title: "音节划分", value: 0, isEnable: hasSyllables),
      IconDropdownCheckData<int>(title: "自然拼读", value: 1, isEnable: hasPhonetics),
    ];

    final int selectIndex = _resolveDividerType(
      hasSyllables: hasSyllables,
      hasPhonetics: hasPhonetics,
    );

    return IconDropdownCheckWidget(
      key: ValueKey<String>(
        'pronunciation_divider_${englishAmericanType}_${selectIndex}_${hasSyllables ? 1 : 0}_${hasPhonetics ? 1 : 0}',
      ),
      items: items,
      width: 180.wMin,
      itemHeight: 64.wMin,
      menuHeight: 128.wMin,
      selectIndex: selectIndex,
      // backColor:  AppTheme.cSurfaceTertiary.color,
      // hoverColor:  Colors.red,
      // highlightColor:  AppTheme.cSurfaceTertiary.color,
      // dividerColor: Colors.green,
      // borderolor: Colors.deepPurple,
      onTap: (data, index) {
        final int? value = data.value;
        if (value == null) return;
        setState(() {
          PlayAudioUtils.instance.stopAll();
          syllableDividerType = value;
          playingIndex = -1;
          isPause = true;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.cBorderPrimary),
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              items.elementAt(selectIndex).title,
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.wMin),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 24.wMin,
              color: AppTheme.cTextPrimary.withValues(alpha: 0.6),
            ),
          ],
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
      fontSize: 47.wMin,
      color: AppTheme.cTextPrimary,
      fontWeight: FontWeight.w500,
    );

    String original = _normalizedContent();
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
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 82.wMin,
          child: Center(
            child: Row(
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
                      color: isActive ? AppTheme.cFeedbackInfoBackground.color.withValues(alpha: 0.85) : AppTheme.cSurfaceTertiary,
                    ),
                    child: Text(
                      displayTexts[index],
                      style: textStyle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(
          height: 66.wMin,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "/ ",
                style: TextStyle(
                  fontSize: 30.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                  fontFamily: "AndikaRegular",
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(syllables.length, (index) {
                  Color textColor = AppTheme.cTextPrimary.color;
                  if (none) {
                    textColor = AppTheme.cTextPrimary;
                  } else if (all) {
                    textColor = AppTheme.cTextBrand.color;
                  } else {
                    if (playingIndex != -1 && playingIndex != 999) {
                      if (playingIndex == index) {
                        textColor = AppTheme.cTextBrand.color;
                      } else {
                        textColor = AppTheme.cTextPrimary;
                      }
                    }
                  }

                  return Text(
                    syllables[index]?.ipa ?? "",
                    style: TextStyle(
                      fontSize: 30.wMin,
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
                  fontSize: 30.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                  fontFamily: "AndikaRegular",
                ),
              ),
              SizedBox(width: 20.wMin),
              _buildPlayButtonWidget(onTap: startPlaySyllables),
            ],
          ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 82.wMin,
          child: Center(
            child: CustomPaint(
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
                    textColor = AppTheme.cTextPrimary;
                  } else if (all) {
                    textColor = AppTheme.cTextBrand.color;
                  } else {
                    if (playingIndex != -1 && playingIndex != 999) {
                      if (phoneticsPos[playingIndex].contains(index)) {
                        textColor = AppTheme.cTextBrand.color;
                      } else {
                        textColor = AppTheme.cTextPrimary;
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
                          fontSize: 47.wMin,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 66.wMin,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "/ ",
                style: TextStyle(
                  fontSize: 30.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                  fontFamily: "AndikaRegular",
                ),
              ),
              Row(
                children: List.generate(phoneticsStrs.length, (index) {
                  Color textColor = AppTheme.cTextPrimary;
                  if (none) {
                    textColor = AppTheme.cTextPrimary;
                  } else if (all) {
                    textColor = AppTheme.cTextBrand.color;
                  } else {
                    if (playingIndex != -1 && playingIndex != 999) {
                      if (playingIndex == index) {
                        textColor = AppTheme.cTextBrand.color;
                      } else {
                        textColor = AppTheme.cTextPrimary;
                      }
                    }
                  }
                  return Text(
                    phoneticsStrs[index],
                    style: TextStyle(
                      fontSize: 30.wMin,
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
                  fontSize: 30.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                  fontFamily: "AndikaRegular",
                ),
              ),
              SizedBox(width: 20.wMin),
              _buildPlayButtonWidget(onTap: startPlayPhonetics),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButtonWidget({VoidCallback? onTap}) {
    return ElementsPlayButtonCircle(
      onTap: onTap ?? () => PlayAudioUtils.instance.playSingle(pronunciations[englishAmericanType].audioUrl),
      enabled: (pronunciations[englishAmericanType].audioUrl ?? '').isNotEmpty || onTap != null,
    );
  }

  /// 是否有练习题按钮
  Widget _buildHasPracticeWidget() {
    if (pronunciations[englishAmericanType].isExercise != true) return Container();
    return ElementsGoPracticeButton(
      height: 32,
      onTap: () async {
        await PlayAudioUtils.instance.stopAll();
        playingIndex = -1;
        isPause = true;
        if (mounted) setState(() {});

        ReviewExerciseUtils.toEval(
          widget.contentType,
          widget.contentId,
          pronunciations[englishAmericanType].national,
        );
      },
    );
  }
}

class ElementsGoPracticeButton extends StatelessWidget {
  final double width;
  final double height;
  final double fontSize;
  final double sclae;
  final void Function()? onTap;

  const ElementsGoPracticeButton({
    super.key,
    this.width = 146,
    this.height = 62,
    this.fontSize = 24,
    this.sclae = 1.03,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ButtonWidget(
      text: "去练习",
      sclae: sclae,
      width: width.wMin,
      height: height.wMin,
      color: AppTheme.cBgPrimary,
      fontSize: fontSize.wMin,
      fontColor: AppTheme.cTextBrand,
      fontWeight: FontWeight.w600,
      onTap: onTap,
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
          height: 60.wMin,
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
                    (() {
                      String title = pronunciations[index]?.nationalTitle ?? "";
                      if (title == "美音") return "美式发音";
                      if (title == "英音") return "英式发音";
                      return title;
                    })(),
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

class ElementsPlayButtonCircle extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final bool enabled;
  const ElementsPlayButtonCircle({
    super.key,
    this.onTap,
    this.size = 44,
    this.iconSize = 28,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.03,
      child: Container(
        width: size.wMin,
        height: size.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.cBgQuaternary.color,
        ),
        child: SvgPicture.asset(
          "assets/svg/public/icon_speaker.svg",
          width: iconSize.wMin,
          height: iconSize.wMin,
          colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
        ),
      ),
    );
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
  final double? DottedBorderWidth;

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
    this.DottedBorderWidth = double.infinity,
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
                        fontSize: fontSize0 ?? 28.wMin,
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
                      color: AppTheme.cBorderPrimary,
                      strokeWidth: 1.wMin,
                      customPath: (size) => Path()
                        ..moveTo(0, size.height)
                        ..relativeLineTo(size.width, 0),
                      padding: EdgeInsets.zero,
                      child: SizedBox(height: 1.wMin, width: DottedBorderWidth),
                    ),
                    Text(
                      langText[index].text ?? "",
                      style: TextStyle(
                        fontSize: fontSize1 ?? 22.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextPrimary.withValues(alpha: 0.8),
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

class ElementsSemanticModuleActionButton extends StatelessWidget {
  final CardWordSemanticModuleItem moduleItem;
  final bool expanded;
  final void Function()? onTap;
  final String? titleOverride;

  const ElementsSemanticModuleActionButton({
    super.key,
    required this.moduleItem,
    required this.expanded,
    this.onTap,
    this.titleOverride,
  });

  static Color? _parseColor(String? value) {
    if (value == null || value.isEmpty) return null;
    final RegExp rgba = RegExp(
      r'rgba?\(\s*(\d+\.?\d*)\s*,\s*(\d+\.?\d*)\s*,\s*(\d+\.?\d*)\s*(?:,\s*(\d+\.?\d*))?\s*\)',
      caseSensitive: false,
    );
    final Match? match = rgba.firstMatch(value.trim());
    if (match != null) {
      final int r = (double.tryParse(match.group(1) ?? '0') ?? 0).round().clamp(0, 255);
      final int g = (double.tryParse(match.group(2) ?? '0') ?? 0).round().clamp(0, 255);
      final int b = (double.tryParse(match.group(3) ?? '0') ?? 0).round().clamp(0, 255);
      final double a = double.tryParse(match.group(4) ?? '1') ?? 1.0;
      return Color.fromRGBO(r, g, b, a.clamp(0.0, 1.0));
    }
    if (value.trim().startsWith('#')) {
      final String hex = value.trim().replaceFirst('#', '');
      if (hex.length == 6) return Color(int.parse('ff$hex', radix: 16));
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    }
    return null;
  }

  CardWordSemanticModuleItemTextStyle? _resolveStyle(BuildContext context) {
    // ThemeUtils.isCurrentTheme('DARK') ? 'DARK' : 'LIGHT';
    // final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String themeName = ThemeUtils.isCurrentTheme('DARK') ? 'DARK' : 'LIGHT';
    final List<CardWordSemanticModuleItemTextStyle?> styles = moduleItem.textStyle ?? <CardWordSemanticModuleItemTextStyle?>[];
    return styles.firstWhereOrNull(
          (CardWordSemanticModuleItemTextStyle? item) => item?.theme == themeName,
        ) ??
        (styles.isNotEmpty ? styles.first : null);
  }

  String _resolveTitle() {
    final List<LanguageText?> titles = moduleItem.moduleTitle ?? <LanguageText?>[];
    final LanguageText? local = LearningLangUtils.getLocalLang(titles);
    if ((local?.text ?? '').isNotEmpty) return local!.text!;
    final LanguageText? learning = LearningLangUtils.getLearningLang(titles);
    if ((learning?.text ?? '').isNotEmpty) return learning!.text!;
    return moduleItem.module ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final CardWordSemanticModuleItemTextStyle? style = _resolveStyle(context);
    final Color textColor = _parseColor(style?.color) ?? AppTheme.cTextPrimary;
    final Color backgroundColor = _parseColor(style?.backgroundColor) ?? AppTheme.cBgSecondary.withValues(alpha: 0.18);
    final Color borderColor = _parseColor(style?.borderColor) ?? AppTheme.cBorderSecondary;
    final String iconUrl = moduleItem.iconUrl ?? '';

    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.03,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999.wMin),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.wMin, sigmaY: 10.wMin),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: expanded ? 180.wMin : 72.wMin,
            height: 72.wMin,
            padding: EdgeInsets.symmetric(horizontal: expanded ? 18.wMin : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999.wMin),
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 2.wMin),
            ),
            child: Row(
              mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: <Widget>[
                if (iconUrl.isNotEmpty)
                  SvgPicture.network(
                    iconUrl,
                    width: 30.wMin,
                    height: 30.wMin,
                    placeholderBuilder: (_) => SizedBox(
                      width: 30.wMin,
                      height: 30.wMin,
                    ),
                    colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                  )
                else
                  SizedBox(width: 30.wMin, height: 30.wMin),
                if (expanded) ...<Widget>[
                  SizedBox(width: 10.wMin),
                  Expanded(
                    child: Text(
                      titleOverride ?? _resolveTitle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ElementsDetailsModuleDialog extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final String? imageUrl;
  final Widget body;
  final Widget? footer;

  final GlobalKey _contentKey = GlobalKey();

  ElementsDetailsModuleDialog({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.body,
    this.imageUrl,
    this.footer,
  });

  bool _isPointInside(RenderBox? box, Offset globalPos) {
    if (box == null) return false;
    final Offset topLeft = box.localToGlobal(Offset.zero);
    final Rect rect = topLeft & box.size;
    return rect.contains(globalPos);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = (imageUrl ?? '').isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 56.wMin, vertical: 40.wMin),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (PointerDownEvent e) {
          final RenderBox? contentBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
          final bool inContent = _isPointInside(contentBox, e.position);
          if (!inContent) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
        },
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceSecondary,
              borderRadius: BorderRadius.circular(32.wMin),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cBlackAlpha50.withValues(alpha: 0.24),
                  blurRadius: 40.wMin,
                  offset: Offset(0, 16.wMin),
                ),
              ],
            ),
            child: Container(
              width: 1808.wMin,
              constraints: BoxConstraints(maxHeight: 900.wMin),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    backgroundColor.withValues(alpha: 0.15),
                    backgroundColor.withValues(alpha: 0),
                  ],
                ),
                borderRadius: BorderRadius.circular(32.wMin),
              ),
              child: ClipRRect(
                key: _contentKey,
                borderRadius: BorderRadius.circular(32.wMin),
                child: Column(
                  mainAxisSize: title == '短语习语' || title == '语法特性' || title == '核心组件' ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(32.wMin, 28.wMin, 24.wMin, 16.wMin),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 40.wMin,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.cTextPrimary,
                              ),
                            ),
                          ),
                          TapScaleWidget(
                            onTap: () => Navigator.of(context).pop(),
                            sclae: 1.03,
                            child: Container(
                              width: 56.wMin,
                              height: 56.wMin,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(999.wMin),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.close_rounded,
                                size: 30.wMin,
                                color: AppTheme.cStaticWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1.wMin, color: AppTheme.cBorderSecondary),
                    title == '短语习语' || title == '语法特性' || title == '核心组件'
                        ? Expanded(
                            child: Padding(
                            padding: EdgeInsets.all(20.wMin),
                            child: SingleChildScrollView(child: body),
                          ))
                        : !hasImage
                            ? SizedBox(
                                height: 500.wMin,
                                child: Padding(
                                  padding: EdgeInsets.all(20.wMin),
                                  child: SingleChildScrollView(child: body),
                                ))
                            : SizedBox(
                                height: 500.wMin,
                                child: Padding(
                                  padding: EdgeInsets.all(20.wMin),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(28.wMin),
                                        child: SizedBox(
                                          width: 468.wMin,
                                          height: 468.wMin,
                                          child: CachedImageWidget(
                                            imageUrl ?? '',
                                            fit: BoxFit.cover,
                                            errorWidget: buildEmptyWidget(fit: BoxFit.cover),
                                            placeholder: buildLoadingWidget(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 32.wMin),
                                      Expanded(child: SingleChildScrollView(child: body)),
                                    ],
                                  ),
                                )),
                    if (footer != null) ...[
                      Divider(height: 1.wMin, color: AppTheme.cBorderSecondary),
                      Padding(
                        padding: EdgeInsets.fromLTRB(32.wMin, 24.wMin, 32.wMin, 28.wMin),
                        child: footer!,
                      ),
                    ] else
                      SizedBox(height: 30.wMin),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ElementsSemanticVideoCardWidget extends StatefulWidget {
  final String? imageUrl;
  final EnKnowledgeEntityRelationVideo? relationVideo;
  final List<PronunciationsEntity?>? pronunciations;
  final String semanticPlaybackKey;
  final bool isActive;
  final double? size;
  final bool showPronunciationOverlay;

  const ElementsSemanticVideoCardWidget({
    super.key,
    this.imageUrl,
    this.relationVideo,
    this.pronunciations,
    required this.semanticPlaybackKey,
    this.isActive = true,
    this.size,
    this.showPronunciationOverlay = true,
  });

  @override
  State<ElementsSemanticVideoCardWidget> createState() => _ElementsSemanticVideoCardWidgetState();
}

class _ElementsSemanticVideoCardWidgetState extends State<ElementsSemanticVideoCardWidget> {
  final TipsVideoWidgetController _videoController = TipsVideoWidgetController();
  final ValueNotifier<Duration> _subtitlePositionNotifier = ValueNotifier<Duration>(Duration.zero);
  bool _registeredToGlobal = false;

  @override
  void initState() {
    super.initState();
    TipsVideoManager.instance.register(_videoController);
    _registeredToGlobal = true;
  }

  @override
  void didUpdateWidget(covariant ElementsSemanticVideoCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      if (_hasVideo) {
        _videoController.playOnce(muted: widget.relationVideo?.isMute ?? false);
      }
    } else if (oldWidget.isActive && !widget.isActive) {
      if (_hasVideo) {
        _videoController.stopAndReset();
        _subtitlePositionNotifier.value = Duration.zero;
      }
    }
  }

  bool get _hasVideo => (widget.relationVideo?.videoUrl ?? '').trim().isNotEmpty;

  Duration get _clipStartDuration {
    final double seconds = widget.relationVideo?.startSeconds ?? 0;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  Duration _toSubtitlePosition(Duration position) {
    final Duration relative = position - _clipStartDuration;
    if (relative.isNegative) return Duration.zero;
    return relative;
  }

  void _handleVideoPositionChanged(Duration position) {
    _subtitlePositionNotifier.value = _toSubtitlePosition(position);
  }

  String get _posterUrl {
    if (_hasVideo) {
      final String firstFrame = widget.relationVideo?.firstFrameUrl?.trim() ?? '';
      if (firstFrame.isNotEmpty) {
        return firstFrame;
      }
      final String firstImage = widget.relationVideo?.firstImageUrl?.trim() ?? '';
      if (firstImage.isNotEmpty) {
        return firstImage;
      }
    }
    final String image = widget.imageUrl?.trim() ?? '';
    if (image.isNotEmpty) {
      return image;
    }
    final String firstFrame = widget.relationVideo?.firstFrameUrl?.trim() ?? '';
    if (firstFrame.isNotEmpty) {
      return firstFrame;
    }
    return widget.relationVideo?.firstImageUrl?.trim() ?? '';
  }

  bool get _hasSubtitles {
    final String ass = widget.relationVideo?.ass?.trim() ?? '';
    if (ass.isNotEmpty) return true;
    final List<LanguageText?> translate = widget.relationVideo?.translateAss ?? widget.relationVideo?.translate ?? const <LanguageText?>[];
    return translate.any((e) => (e?.text ?? '').trim().isNotEmpty);
  }

  @override
  void dispose() {
    if (_registeredToGlobal) {
      TipsVideoManager.instance.unregister(_videoController);
      _registeredToGlobal = false;
    }
    _videoController.stopAndReset();
    _subtitlePositionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size ?? 640.wMin;
    final ConfigController config = Get.find<ConfigController>();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.wMin),
        color: AppTheme.cBgSecondary,
        border: Border.all(color: AppTheme.cBorderSecondary, width: 1.wMin),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cBlackAlpha10,
            blurRadius: 28.wMin,
            offset: Offset(0, 10.wMin),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.wMin),
        child: Obx(() {
          final bool preferVideo = config.currentShowResource.value == ResourceTypeEnum.video;
          final LangPreference rawLang = config.userSetting.value.expandLang;
          final LangPreference lang = rawLang == LangPreference.none ? LangPreference.bilingual : rawLang;
          final bool showOriginalSubtitles = lang != LangPreference.translation;
          final bool showTranslateSubtitles = lang != LangPreference.original;
          final String localLang = config.userSetting.value.localLang;
          final bool hasVideo = preferVideo && (widget.relationVideo?.videoUrl ?? '').trim().isNotEmpty;
          String posterUrl;
          if (hasVideo) {
            final String firstFrame = widget.relationVideo?.firstFrameUrl?.trim() ?? '';
            if (firstFrame.isNotEmpty) {
              posterUrl = firstFrame;
            } else {
              final String firstImage = widget.relationVideo?.firstImageUrl?.trim() ?? '';
              posterUrl = firstImage.isNotEmpty ? firstImage : (widget.imageUrl ?? '');
            }
          } else {
            posterUrl = (widget.imageUrl?.trim().isNotEmpty ?? false)
                ? widget.imageUrl!.trim()
                : (widget.relationVideo?.firstImageUrl?.trim() ?? widget.relationVideo?.firstFrameUrl?.trim() ?? '');
          }
          final List<LanguageText?> translateList =
              (widget.relationVideo?.translateAss ?? widget.relationVideo?.translate ?? const <LanguageText?>[]).whereType<LanguageText>().cast<LanguageText?>().toList();
          final String translateAssText = translateList.firstWhereOrNull((e) => e?.lang == localLang)?.text ?? '';
          final bool hasSubtitles =
              hasVideo && ((showOriginalSubtitles && (widget.relationVideo?.ass ?? '').trim().isNotEmpty) || (showTranslateSubtitles && translateAssText.trim().isNotEmpty));
          return Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Container(color: AppTheme.cBlackAlpha10),
              if (hasVideo)
                TipsVideoWidget(
                  key: ValueKey<String>(widget.semanticPlaybackKey),
                  controller: _videoController,
                  posterPath: posterUrl,
                  videoPath: widget.relationVideo?.videoUrl ?? '',
                  width: size,
                  height: size,
                  borderRadius: 20.wMin,
                  backColor: AppTheme.cBlackAlpha10,
                  showLight: false,
                  showExpandButton: true,
                  autoPlayOnce: widget.isActive,
                  autoPlayMuted: widget.relationVideo?.isMute ?? false,
                  startSeconds: widget.relationVideo?.startSeconds,
                  endSeconds: widget.relationVideo?.endSeconds,
                  lines: widget.relationVideo?.lines,
                  ass: widget.relationVideo?.ass,
                  translateAss: translateAssText.trim().isNotEmpty ? translateAssText : null,
                  onPositionChanged: _handleVideoPositionChanged,
                  onBeforeExpand: () async {
                    await _videoController.stopAndReset();
                    _subtitlePositionNotifier.value = Duration.zero;
                    return true;
                  },
                  enableInternalTapToPlay: true,
                  hideCenterPlayButtonUntilFirstPlay: false,
                  showCenterPlayButton: true,
                )
              else
                CachedImageWidget(
                  posterUrl,
                  errorWidget: buildEmptyWidget(),
                  placeholder: buildLoadingWidget(),
                  fit: BoxFit.cover,
                ),
              if (hasSubtitles)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 10.wMin),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: <Color>[
                            AppTheme.cBlackAlpha50,
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: ValueListenableBuilder<Duration>(
                        valueListenable: _subtitlePositionNotifier,
                        builder: (context, position, child) {
                          return VideoAssTextWidget(
                            position: position,
                            ass: showOriginalSubtitles ? widget.relationVideo?.ass : null,
                            translate: showTranslateSubtitles ? translateList : null,
                            assColor: AppTheme.cStaticWhite,
                            assFontSize: 36.wMin,
                            translateColor: AppTheme.cStaticWhite.withValues(alpha: 0.82),
                            translateFontSize: 24.wMin,
                            translateLangCode: localLang,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              if (!hasVideo && widget.showPronunciationOverlay && (widget.pronunciations?.isNotEmpty ?? false))
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 10.wMin),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: <Color>[
                          AppTheme.cBlackAlpha50,
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List<Widget>.generate(widget.pronunciations?.length ?? 0, (int index) {
                        return PlayLottieIconWidget(
                          size: 60.wMin,
                          audioUrl: widget.pronunciations?[index]?.audioUrl,
                          backgroundImageUrl: widget.pronunciations?[index]?.nationalIconUrl,
                        );
                      }),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class SemanticChipData {
  final int id;
  final String? pos;
  final String? text;
  final List<ThemeTextStyleEntity?>? textStyle;
  const SemanticChipData({required this.id, this.pos, this.text, this.textStyle});
}

class ElementsSemanticBottomBar extends StatefulWidget {
  final List<SemanticChipData> items;
  final int? currentId;
  final bool showFilter;
  final bool isFiltered;
  final void Function(BuildContext context)? onTapFilter;
  final Color? filterColor;
  final ValueChanged<int>? onTapItem;
  final bool enableInitialScrollToCurrent;

  const ElementsSemanticBottomBar({
    super.key,
    required this.items,
    this.currentId,
    this.showFilter = false,
    this.isFiltered = false,
    this.onTapFilter,
    this.filterColor,
    this.onTapItem,
    this.enableInitialScrollToCurrent = true,
  });

  @override
  State<ElementsSemanticBottomBar> createState() => _ElementsSemanticBottomBarState();
}

class _ElementsSemanticBottomBarState extends State<ElementsSemanticBottomBar> {
  final Map<int, GlobalKey> _itemKeys = <int, GlobalKey>{};
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentIfNeeded());
  }

  @override
  void didUpdateWidget(covariant ElementsSemanticBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_didInitialScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentIfNeeded());
    }
  }

  void _scrollToCurrentIfNeeded() {
    if (_didInitialScroll) return;
    if (!widget.enableInitialScrollToCurrent) return;
    final int? currentId = widget.currentId;
    if (currentId == null) return;
    final GlobalKey? key = _itemKeys[currentId];
    final BuildContext? itemContext = key?.currentContext;
    if (itemContext == null) return;
    _didInitialScroll = true;
    Scrollable.ensureVisible(
      itemContext,
      alignment: 0.0,
      duration: Duration.zero,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double iconPaddingH = 10.wMin;
    final double iconSize = 32.wMin;
    final double chipPaddingH = 14.wMin;
    double maxFontPx = 28;
    for (final SemanticChipData item in widget.items) {
      final ThemeTextStyleEntity? themeText = StyleUtils.getCurrentThemeText(item.textStyle);
      final double fs = (28);
      if (fs > maxFontPx) maxFontPx = fs;
    }
    final double chipHeight = (maxFontPx.wMin + 20.wMin);
    return ClipRRect(
      borderRadius: BorderRadius.circular(99.wMin),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.wMin, sigmaY: 4.wMin),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceSecondary.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(99.wMin),
            border: Border.all(
              color: AppTheme.cBorderPrimary.withValues(alpha: 0.6),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: widget.showFilter ? 0 : 10.wMin, horizontal: widget.showFilter ? 0 : 5.wMin),
          child: Row(
            
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showFilter)
                TapScaleWidget(
                  onTap: widget.onTapFilter == null ? null : () => widget.onTapFilter?.call(context),
                  sclae: 1.03,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: iconPaddingH,
                    ),
                    constraints: BoxConstraints(minHeight: chipHeight),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/svg/elements/icon_filter.svg',
                      width: iconSize,
                      height: iconSize,
                      colorFilter: ColorFilter.mode(
                        widget.filterColor ?? (widget.isFiltered ? AppTheme.cBgBrand : AppTheme.cTextSecondary),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              if (widget.showFilter)
                Container(
                  color: AppTheme.cBorderSecondary,
                  height: chipHeight + 20.wMin,
                  width: 1.wMin,
                  margin: EdgeInsets.only(right: 3.wMin),
                ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final double screenWidth = MediaQuery.of(context).size.width;
                  final double maxWidth = (screenWidth - 160.wMin).clamp(200.wMin, screenWidth);
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: SizedBox(
                      height: chipHeight,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                          child: Builder(
                            builder: (context) {
                              final List<Widget> children = <Widget>[];
                              for (int index = 0; index < widget.items.length; index++) {
                                final SemanticChipData item = widget.items[index];
                                final bool selected = item.id == widget.currentId;
                                final ThemeTextStyleEntity? themeText = StyleUtils.getCurrentThemeText(item.textStyle);
                                final TextStyle baseTextStyle = TextStyle(
                                  fontSize: (28).wMin,
                                  fontWeight: StyleUtils.getFontWeight(
                                    themeText?.weight,
                                    defaultWeight: FontWeight.w500,
                                  ),
                                  fontStyle: StyleUtils.getFontStyle(themeText?.italic ?? false),
                                );
                                final Color selectedBg = ColorUtils.parseColor(themeText?.backgroundColor)?.withValues(alpha: 0.2) ?? AppTheme.cFeedbackInfoBackground.withValues(alpha: 0.2);
                                final Color selectedBorder = ColorUtils.parseColor(themeText?.borderColor) ?? AppTheme.cFeedbackInfoBorder;
                                final Color selectedText = ColorUtils.parseColor(themeText?.color) ?? AppTheme.cTextPrimary;
                                final Color normalText = AppTheme.cTextPrimary.withValues(alpha: 0.6);
                                final GlobalKey itemKey = _itemKeys.putIfAbsent(item.id, () => GlobalKey());
                                children.add(
                                  TapScaleWidget(
                                    onTap: () => widget.onTapItem?.call(item.id),
                                    sclae: 1.02,
                                    child: SizedBox(
                                      key: itemKey,
                                      height: chipHeight,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 180),
                                        padding: EdgeInsets.symmetric(horizontal: chipPaddingH),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: selected ? selectedBorder : Colors.transparent,
                                            width: 2.wMin,
                                          ),
                                          color: selected ? selectedBg : AppTheme.cStaticWhite.withValues(alpha: 0.06),
                                          borderRadius: BorderRadius.circular(99.wMin),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              if ((item.pos ?? '').isNotEmpty)
                                                TextSpan(
                                                  text: '${item.pos} ',
                                                  style: baseTextStyle.copyWith(
                                                    color: selected ? selectedText : normalText,
                                                  ),
                                                ),
                                              TextSpan(
                                                text: item.text ?? '',
                                                style: baseTextStyle.copyWith(
                                                  color: selected ? selectedText : normalText,
                                                ),
                                              ),
                                            ],
                                          ),
                                          style: baseTextStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                                if (index < widget.items.length - 1) {
                                  children.add(SizedBox(width: 12.wMin));
                                }
                              }
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: children,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ElementsPosSelectorOption {
  final String value;
  final String title;
  final ThemeTextStyleEntity? themeText;
  const ElementsPosSelectorOption({
    required this.value,
    required this.title,
    this.themeText,
  });
}

class ElementsPosSelectorDialog extends StatelessWidget {
  final String title;
  final String selectedValue;
  final List<ElementsPosSelectorOption> options;

  const ElementsPosSelectorDialog({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.options,
  });

  static Future<String?> show({
    required BuildContext context,
    required List<ElementsPosSelectorOption> options,
    required String selectedValue,
    String title = '选择词性',
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: AppTheme.cBlackAlpha50,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: 70.wMin,
            vertical: 40.wMin,
          ),
          child: ElementsPosSelectorDialog(
            title: title,
            selectedValue: selectedValue,
            options: options,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double optionHeight = 60.wMin;
    final double optionWidth = 200.wMin;
    return Container(
      width: 500.wMin,
      padding: EdgeInsets.fromLTRB(40.wMin, 32.wMin, 40.wMin, 40.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceSecondary,
        borderRadius: BorderRadius.circular(32.wMin),
        border: Border.all(
          color: AppTheme.cInverseOverlay4.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36.wMin,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.cTextPrimary,
                  ),
                ),
              ),
              TapScaleWidget(
                onTap: () => Navigator.of(context).pop(),
                sclae: 1.02,
                child: Container(
                  width: 48.wMin,
                  height: 48.wMin,
                  decoration: BoxDecoration(
                    color: AppTheme.cStaticWhite.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16.wMin,
                    color: AppTheme.cTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 36.wMin),
          Wrap(
            spacing: 12.wMin,
            runSpacing: 12.wMin,
            children: List<Widget>.generate(options.length, (int index) {
              final ElementsPosSelectorOption option = options[index];
              final bool isSelected = option.value == selectedValue;
              final ThemeTextStyleEntity? themeText = option.themeText;
              final Color selectedBg = ColorUtils.parseColor(themeText?.backgroundColor) ?? AppTheme.cFeedbackSuccessBorder.withValues(alpha: 0.2);
              final Color selectedBorder = ColorUtils.parseColor(themeText?.borderColor) ?? selectedBg;
              final Color selectedText = ColorUtils.parseColor(themeText?.color) ?? AppTheme.cTextPrimary;
              final TextStyle selectedTextStyle = TextStyle(
                fontSize: (24).wMin,
                fontWeight: StyleUtils.getFontWeight(
                  themeText?.weight,
                  defaultWeight: FontWeight.w600,
                ),
                fontStyle: StyleUtils.getFontStyle(themeText?.italic ?? false),
                color: selectedText,
              );
              final Color backgroundColor = isSelected ? selectedBg : AppTheme.cStaticWhite.withValues(alpha: 0.08);
              final Color borderColor = isSelected ? selectedBorder : Colors.transparent;
              final Color textColor = isSelected ? selectedText : AppTheme.cTextPrimary.withValues(alpha: 0.72);
              return SizedBox(
                width: optionWidth,
                child: TapScaleWidget(
                  onTap: () => Navigator.of(context).pop(option.value),
                  sclae: 1.02,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: optionHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(999.wMin),
                      border: Border.all(color: borderColor, width: 2.wMin),
                    ),
                    child: Text(
                      option.title,
                      style: isSelected ? selectedTextStyle : selectedTextStyle.copyWith(color: textColor),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ElementsDetilsLeftPanel extends StatelessWidget {
  final double width;
  final Widget Function(double size) mediaBuilder;
  final Widget pronunciation;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final double minPronunciationHeight;

  const ElementsDetilsLeftPanel({
    super.key,
    required this.width,
    required this.mediaBuilder,
    required this.pronunciation,
    this.spacing = 12,
    this.padding = EdgeInsets.zero,
    this.minPronunciationHeight = 320,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxHeight = constraints.hasBoundedHeight ? constraints.maxHeight : MediaQuery.of(context).size.height;
          final double spacingPx = spacing.wMin;
          final double minPronHeightPx = minPronunciationHeight.wMin;

          double mediaSize = width;
          if (maxHeight.isFinite && maxHeight > 0) {
            final double maxMedia = maxHeight - minPronHeightPx - spacingPx;
            mediaSize = maxMedia.clamp(320.wMin, width);
          }

          return Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: mediaSize,
                  height: mediaSize,
                  child: mediaBuilder(mediaSize),
                ),
                SizedBox(height: spacingPx),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: width,
                        child: pronunciation,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 60.wMin),
              ],
            ),
          );
        },
      ),
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
