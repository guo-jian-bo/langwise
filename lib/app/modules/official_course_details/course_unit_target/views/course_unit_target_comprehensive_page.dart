import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../common/widgets/zhenxie_widgets/article_blueprint_min_table_widget.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/learning_lang_utils.dart';
import '../../../elements/common/elements_cards/elements_public_card.dart';
import '../controllers/course_unit_target_controller.dart';

class CourseUnitTargetComprehensivePage extends StatefulWidget {
  final CourseUnitTargetController controller;

  /// 综合
  const CourseUnitTargetComprehensivePage({super.key, required this.controller});

  @override
  State<CourseUnitTargetComprehensivePage> createState() => _CourseUnitTargetComprehensivePageState();
}

class _CourseUnitTargetComprehensivePageState extends State<CourseUnitTargetComprehensivePage> {
  @override
  Widget build(BuildContext context) {
    return _buildCardsWidget();
  }

  /// 构建课程目标卡片布局
  Widget _buildCardsWidget() {
    bool isManagement = widget.controller.isManagement;
    return Obx(() {
      final knowledgeController = widget.controller.knowledgeController;
      List<Widget> items = [];
      if (knowledgeController.allVocabularyKnowledgeList.isNotEmpty || isManagement) {
        items.add(CourseUnitTargetComprehensiveImageWidget(
          knowledgeList: knowledgeController.allVocabularyKnowledgeList,
          onTap: widget.controller.switchKnowledgeType,
        ));
      }
      if (knowledgeController.allSyntaxKnowledgeList.isNotEmpty || isManagement) {
        items.add(CourseUnitTargetComprehensiveSyntaxWidget(
          knowledgeList: knowledgeController.allSyntaxKnowledgeList,
          onTap: widget.controller.switchKnowledgeType,
        ));
      }
      if (knowledgeController.allListeningKnowledgeList.isNotEmpty || isManagement) {
        items.add(CourseUnitTargetComprehensiveHearingWidget(
          knowledgeList: knowledgeController.allListeningKnowledgeList,
          onTap: widget.controller.switchKnowledgeType,
        ));
      }
      if (knowledgeController.allReadingKnowledgeList.isNotEmpty || isManagement) {
        items.add(CourseUnitTargetComprehensiveReadingWidget(
          knowledgeList: knowledgeController.allReadingKnowledgeList,
          onTap: widget.controller.switchKnowledgeType,
        ));
      }
      if (knowledgeController.allWritingKnowledgeList.isNotEmpty || isManagement) {
        items.add(CourseUnitTargetComprehensiveWritingWidget(
          knowledgeList: knowledgeController.allWritingKnowledgeList,
          paragraphRhetoricalList: widget.controller.paragraphRhetoricalList.toList(),
          onTap: widget.controller.switchKnowledgeType,
        ));
      }
      if (knowledgeController.allComprehensiveKnowledgeList.isNotEmpty || isManagement) {
        items.add(CourseUnitTargetComprehensiveComplexWidget(
          knowledgeList: knowledgeController.allComprehensiveKnowledgeList,
          onTap: widget.controller.switchKnowledgeType,
        ));
      }

      if (items.isEmpty) {
        return SizedBox.shrink();
      }

      if (items.length == 5) {
        return Container(
          margin: EdgeInsets.only(top: 16.wMin),
          padding: EdgeInsets.only(
            bottom: 120.wMin + MediaQuery.of(context).padding.bottom,
            left: 90.wMin,
            right: 90.wMin,
          ),
          child: _buildFiveCardLayoutWidget(items),
        );
      }

      final rowConfigs = _getCardRowConfigs(items.length);
      var startIndex = 0;

      return Container(
        margin: EdgeInsets.only(top: 16.wMin),
        padding: EdgeInsets.only(
          bottom: 120.wMin + MediaQuery.of(context).padding.bottom,
          left: 90.wMin,
          right: 90.wMin,
        ),
        child: Column(
          children: List.generate(rowConfigs.length, (rowIndex) {
            final rowConfig = rowConfigs[rowIndex];
            final isLastRow = rowIndex == rowConfigs.length - 1;
            final currentStartIndex = startIndex;
            startIndex += rowConfig.length;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: isLastRow ? 0 : 16.wMin,
                ),
                child: _buildCardRowWidget(
                  items: items,
                  startIndex: currentStartIndex,
                  rowConfig: rowConfig,
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  /// 构建五张卡片时的专属布局，最后一张占据最右侧整列。
  Widget _buildFiveCardLayoutWidget(List<Widget> items) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(
                child: _buildCardRowWidget(
                  items: items,
                  startIndex: 0,
                  rowConfig: const [1, 1],
                ),
              ),
              SizedBox(height: 16.wMin),
              Expanded(
                child: _buildCardRowWidget(
                  items: items,
                  startIndex: 2,
                  rowConfig: const [1, 1],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16.wMin),
        Expanded(
          child: items[4],
        ),
      ],
    );
  }

  /// 按行配置构建卡片行
  Widget _buildCardRowWidget({
    required List<Widget> items,
    required int startIndex,
    required List<int> rowConfig,
  }) {
    return Row(
      children: List.generate(rowConfig.length * 2 - 1, (index) {
        if (index.isOdd) {
          return SizedBox(width: 16.wMin);
        }

        final cardIndex = startIndex + index ~/ 2;
        return Expanded(
          flex: rowConfig[index ~/ 2],
          child: items[cardIndex],
        );
      }),
    );
  }

  /// 根据卡片数量返回对应的行布局规则
  List<List<int>> _getCardRowConfigs(int count) {
    switch (count) {
      case 1:
        return const [
          [1],
        ];
      case 2:
        return const [
          [1, 1],
        ];
      case 3:
        return const [
          [1, 1, 1],
        ];
      case 4:
        return const [
          [1, 1],
          [1, 1],
        ];
      case 5:
        return const [
          [1, 1, 1],
          [1, 2],
        ];
      default:
        return const [
          [1, 1, 1],
          [1, 1, 1],
        ];
    }
  }
}

class CourseUnitTargetComprehensiveImageWidget extends StatelessWidget {
  final List<KnowledgeCommonEntityList> knowledgeList;
  final void Function(CourseUnitTargetEnum type)? onTap;

  /// 词汇
  const CourseUnitTargetComprehensiveImageWidget({super.key, required this.knowledgeList, this.onTap});

  @override
  Widget build(BuildContext context) {
    const targetType = CourseUnitTargetEnum.vocabulary;
    return CourseUnitTargetComprehensiveCardWidget(
      onTap: () {
        onTap?.call(targetType);
      },
      title: targetType.title,
      count: knowledgeList.length,
      primaryColor: targetType.primaryColor,
      primaryColor1: targetType.primaryColor1,
      child: CourseUnitTargetComprehensiveStampGridWidget(knowledgeList: knowledgeList),
    );
  }
}

class CourseUnitTargetComprehensiveSyntaxWidget extends StatelessWidget {
  final List<KnowledgeCommonEntityList> knowledgeList;
  final void Function(CourseUnitTargetEnum type)? onTap;

  /// 句法
  const CourseUnitTargetComprehensiveSyntaxWidget({super.key, required this.knowledgeList, this.onTap});

  @override
  Widget build(BuildContext context) {
    const targetType = CourseUnitTargetEnum.syntax;
    return CourseUnitTargetComprehensiveCardWidget(
      onTap: () {
        onTap?.call(targetType);
      },
      title: targetType.title,
      count: knowledgeList.length,
      primaryColor: targetType.primaryColor,
      primaryColor1: targetType.primaryColor1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final visibleCount = _getVisibleKnowledgeCount(context, constraints);
          return ListView.builder(
            itemCount: visibleCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ElementsDictCiteCard(
                data: knowledgeList[index],
                bgColor: Colors.transparent,
                borderColor: Colors.transparent,
              );
            },
          );
        },
      ),
    );
  }

  /// 按当前卡片可用高度计算可完整展示的条目数。
  int _getVisibleKnowledgeCount(BuildContext context, BoxConstraints constraints) {
    if (knowledgeList.isEmpty) return 0;

    final availableHeight = constraints.maxHeight;
    if (availableHeight <= 0) return 0;

    double usedHeight = 0;
    int visibleCount = 0;
    for (final knowledge in knowledgeList) {
      final itemHeight = _measureCiteCardHeight(context, constraints.maxWidth, knowledge);
      if (visibleCount > 0 && usedHeight + itemHeight > availableHeight) break;
      usedHeight += itemHeight;
      visibleCount++;
    }
    return visibleCount;
  }

  /// 估算句法卡片在当前宽度下的实际占高，避免写死展示数量。
  double _measureCiteCardHeight(BuildContext context, double maxWidth, KnowledgeCommonEntityList knowledge) {
    final direction = Directionality.of(context);
    final subTitle = LearningLangUtils.getShowLList(knowledge.subTitles)?.text;
    final titleStyle = TextStyle(
      fontSize: 24.wMin,
      color: AppTheme.cTextPrimary.color,
      fontWeight: FontWeight.w500,
    );
    final subtitleStyle = TextStyle(
      fontSize: 18.wMin,
      color: AppTheme.cTextTertiary.color,
      fontWeight: FontWeight.w400,
    );
    final posStyle = TextStyle(
      fontSize: 18.wMin,
      fontWeight: FontWeight.w400,
    );

    final double cardWidth = maxWidth;
    final double contentWidth = cardWidth - 24.wMin;
    final titleHeight = _measureTextHeight(
      text: knowledge.title?.isNotEmpty == true ? knowledge.title! : ' ',
      style: titleStyle,
      maxWidth: contentWidth > 0 ? contentWidth : 0,
      direction: direction,
    );

    final posTitle = knowledge.posTitle ?? '';
    final hasSubtitleRow = subTitle != null || knowledge.posTitle != null;
    if (!hasSubtitleRow) return 24.wMin + titleHeight;

    final double posBadgeWidth = posTitle.isEmpty
        ? 0
        : _measureTextWidth(
              text: posTitle,
              style: posStyle,
              direction: direction,
            ) +
            20.wMin;
    final double subtitleWidth = contentWidth - posBadgeWidth - (posTitle.isEmpty ? 0 : 4.wMin);
    final double subtitleHeight = _measureTextHeight(
      text: subTitle?.isNotEmpty == true ? subTitle! : ' ',
      style: subtitleStyle,
      maxWidth: subtitleWidth > 0 ? subtitleWidth : contentWidth,
      direction: direction,
    );
    final double posHeight = posTitle.isEmpty
        ? 0
        : _measureTextHeight(
              text: posTitle,
              style: posStyle,
              maxWidth: posBadgeWidth,
              direction: direction,
            ) +
            4.wMin;
    final double rowHeight = subtitleHeight > posHeight ? subtitleHeight : posHeight;

    return 24.wMin + titleHeight + rowHeight;
  }

  /// 计算文本在指定宽度下的高度。
  double _measureTextHeight({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required TextDirection direction,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
    )..layout(maxWidth: maxWidth);
    return painter.height;
  }

  /// 计算徽标文本的单行宽度。
  double _measureTextWidth({
    required String text,
    required TextStyle style,
    required TextDirection direction,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      maxLines: 1,
    )..layout();
    return painter.width;
  }
}

class CourseUnitTargetComprehensiveHearingWidget extends StatelessWidget {
  final void Function(CourseUnitTargetEnum type)? onTap;
  final List<KnowledgeCommonEntityList> knowledgeList;

  /// 听力
  const CourseUnitTargetComprehensiveHearingWidget({super.key, required this.knowledgeList, this.onTap});

  @override
  Widget build(BuildContext context) {
    const targetType = CourseUnitTargetEnum.listening;
    return CourseUnitTargetComprehensiveCardWidget(
      onTap: () {
        onTap?.call(targetType);
      },
      title: targetType.title,
      count: knowledgeList.length,
      primaryColor: targetType.primaryColor,
      primaryColor1: targetType.primaryColor1,
      child: CourseUnitTargetComprehensiveStampGridWidget(knowledgeList: knowledgeList),
    );
  }
}

class CourseUnitTargetComprehensiveReadingWidget extends StatelessWidget {
  final List<KnowledgeCommonEntityList> knowledgeList;
  final void Function(CourseUnitTargetEnum type)? onTap;

  /// 阅读
  const CourseUnitTargetComprehensiveReadingWidget({super.key, required this.knowledgeList, this.onTap});

  @override
  Widget build(BuildContext context) {
    const targetType = CourseUnitTargetEnum.reading;
    return CourseUnitTargetComprehensiveCardWidget(
      onTap: () {
        onTap?.call(targetType);
      },
      title: targetType.title,
      count: knowledgeList.length,
      primaryColor: targetType.primaryColor,
      primaryColor1: targetType.primaryColor1,
      child: CourseUnitTargetComprehensiveStampGridWidget(knowledgeList: knowledgeList),
    );
  }
}

class CourseUnitTargetComprehensiveWritingWidget extends StatelessWidget {
  final List<KnowledgeCommonEntityList> knowledgeList;
  final List<ParagraphRhetoricalEntityList> paragraphRhetoricalList;
  final void Function(CourseUnitTargetEnum type)? onTap;

  /// 写作
  const CourseUnitTargetComprehensiveWritingWidget(
      {super.key, required this.knowledgeList, required this.paragraphRhetoricalList, this.onTap});

  @override
  Widget build(BuildContext context) {
    const targetType = CourseUnitTargetEnum.writing;

    KnowledgeCommonEntityList? knowledge;
    if (knowledgeList.isNotEmpty) {
      knowledge = knowledgeList[0];
    }

    return CourseUnitTargetComprehensiveCardWidget(
      onTap: () {
        onTap?.call(targetType);
      },
      title: targetType.title,
      count: knowledgeList.length,
      primaryColor: targetType.primaryColor,
      primaryColor1: targetType.primaryColor1,
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        child: Visibility(
          visible: knowledge != null,
          child: Column(
            children: [
              _buildContentWidget(knowledge),
              SizedBox(height: 12.wMin),
              Container(
                height: 1.wMin,
                color: AppTheme.cBorderPrimary.color,
              ),
              _buildBlueprintWidget(knowledge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentWidget(KnowledgeCommonEntityList? knowledge) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 75.wMin,
          height: 75.wMin,
          child: CachedImageWidget(
            knowledge?.coverImage?.url ?? '',
            placeholder: buildEmptyWidget(),
            errorWidget: buildEmptyWidget(),
            borderRadius: BorderRadius.circular(8.wMin),
          ),
        ),
        SizedBox(width: 12.wMin),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.wMin,
            children: [
              Text(
                knowledge?.title ?? '',
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              Text(
                knowledge?.subTitle ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBlueprintWidget(KnowledgeCommonEntityList? knowledge) {
    final data = knowledge?.params?.data;

    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: CourseBlueprintTableWidget(
          paragraphRhetoricalList: paragraphRhetoricalList.toList(),
          data: data ?? KnowledgeCommonEntityListParamsData(),
        ),
      ),
    );
  }
}

class CourseUnitTargetComprehensiveComplexWidget extends StatelessWidget {
  final List<KnowledgeCommonEntityList> knowledgeList;
  final void Function(CourseUnitTargetEnum type)? onTap;

  /// 综合
  const CourseUnitTargetComprehensiveComplexWidget({super.key, required this.knowledgeList, this.onTap});

  @override
  Widget build(BuildContext context) {
    const targetType = CourseUnitTargetEnum.comprehensive;
    return CourseUnitTargetComprehensiveCardWidget(
      onTap: () {
        onTap?.call(targetType);
      },
      title: targetType.title,
      count: knowledgeList.length,
      primaryColor: targetType.primaryColor,
      primaryColor1: targetType.primaryColor1,
      child: CourseUnitTargetComprehensiveStampGridWidget(knowledgeList: knowledgeList),
    );
  }
}

class CourseUnitTargetComprehensiveStampGridWidget extends StatelessWidget {
  final List<KnowledgeCommonEntityList> knowledgeList;

  /// 封面类目标的自适应网格。
  const CourseUnitTargetComprehensiveStampGridWidget({super.key, required this.knowledgeList});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final config = _getGridConfig(constraints);
        if (config.visibleCount <= 0) return SizedBox.shrink();

        return GridView.builder(
          itemCount: config.visibleCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: config.crossAxisCount,
            mainAxisSpacing: 10.wMin,
            crossAxisSpacing: 10.wMin,
            childAspectRatio: config.childAspectRatio,
          ),
          itemBuilder: (context, index) {
            return ElementsDictStampCard(
              data: knowledgeList[index],
              subTitleMaxLines: config.childAspectRatio > 1 ? 1 : 2,
              titleMaxLines: config.childAspectRatio > 1 ? 2 : 3,
              settingShowVideo: false,
            );
          },
        );
      },
    );
  }

  /// 根据容器方向和数据量返回当前网格配置。
  _CourseUnitTargetStampGridConfig _getGridConfig(BoxConstraints constraints) {
    if (knowledgeList.isEmpty) {
      return const _CourseUnitTargetStampGridConfig(
        visibleCount: 0,
        crossAxisCount: 1,
        childAspectRatio: 1,
      );
    }

    final double spacing = 10.wMin;
    final double availableWidth = constraints.maxWidth;
    final double availableHeight = constraints.maxHeight;
    if (availableWidth <= 0 || availableHeight <= 0) {
      return const _CourseUnitTargetStampGridConfig(
        visibleCount: 0,
        crossAxisCount: 1,
        childAspectRatio: 1,
      );
    }

    final isLandscape = availableWidth > availableHeight;
    final priorityCandidates = _getPriorityGridCandidates(isLandscape);
    for (final candidate in priorityCandidates) {
      if (knowledgeList.length < candidate.visibleCount) continue;

      final rowCount = (candidate.visibleCount / candidate.crossAxisCount).ceil();
      final itemWidth = (availableWidth - spacing * (candidate.crossAxisCount - 1)) / candidate.crossAxisCount;
      final itemHeight = (availableHeight - spacing * (rowCount - 1)) / rowCount;
      if (itemWidth <= 0 || itemHeight <= 0) continue;

      final childAspectRatio = itemWidth / itemHeight;
      if (_isAspectRatioValid(childAspectRatio, isLandscape)) {
        return _CourseUnitTargetStampGridConfig(
          visibleCount: candidate.visibleCount,
          crossAxisCount: candidate.crossAxisCount,
          childAspectRatio: childAspectRatio,
        );
      }
    }

    return _getLinearGridConfig(
      totalCount: knowledgeList.length,
      availableWidth: availableWidth,
      availableHeight: availableHeight,
      spacing: spacing,
      isLandscape: isLandscape,
    );
  }

  /// 返回横竖方向下优先尝试的双行或双列候选方案。
  List<_CourseUnitTargetStampGridCandidate> _getPriorityGridCandidates(bool isLandscape) {
    if (isLandscape) {
      return const [
        _CourseUnitTargetStampGridCandidate(visibleCount: 6, crossAxisCount: 3),
        _CourseUnitTargetStampGridCandidate(visibleCount: 4, crossAxisCount: 2),
      ];
    }

    return const [
      _CourseUnitTargetStampGridCandidate(visibleCount: 6, crossAxisCount: 2),
      _CourseUnitTargetStampGridCandidate(visibleCount: 4, crossAxisCount: 2),
    ];
  }

  /// 双行或双列都不合适时，按固定顺序回退到单行或单列布局。
  _CourseUnitTargetStampGridConfig _getLinearGridConfig({
    required int totalCount,
    required double availableWidth,
    required double availableHeight,
    required double spacing,
    required bool isLandscape,
  }) {
    final visibleCount = totalCount >= 3
        ? 3
        : totalCount >= 2
            ? 2
            : 1;
    final crossAxisCount = isLandscape ? visibleCount : 1;
    final rowCount = (visibleCount / crossAxisCount).ceil();
    final itemWidth = (availableWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
    final itemHeight = (availableHeight - spacing * (rowCount - 1)) / rowCount;
    if (itemWidth <= 0 || itemHeight <= 0) {
      return const _CourseUnitTargetStampGridConfig(
        visibleCount: 1,
        crossAxisCount: 1,
        childAspectRatio: 1,
      );
    }

    return _CourseUnitTargetStampGridConfig(
      visibleCount: visibleCount,
      crossAxisCount: crossAxisCount,
      childAspectRatio: itemWidth / itemHeight,
    );
  }

  /// 校验单卡宽高比是否落在当前方向允许的区间内。
  bool _isAspectRatioValid(double childAspectRatio, bool isLandscape) {
    if (isLandscape) {
      return childAspectRatio >= 1 && childAspectRatio <= 4 / 3;
    }
    return childAspectRatio >= 1 / 4 && childAspectRatio <= 4;
  }
}

class _CourseUnitTargetStampGridCandidate {
  final int visibleCount;
  final int crossAxisCount;
  const _CourseUnitTargetStampGridCandidate({required this.visibleCount, required this.crossAxisCount});
}

class _CourseUnitTargetStampGridConfig {
  final int visibleCount;
  final int crossAxisCount;
  final double childAspectRatio;
  const _CourseUnitTargetStampGridConfig({
    required this.visibleCount,
    required this.crossAxisCount,
    required this.childAspectRatio,
  });
}

class CourseUnitTargetComprehensiveCardWidget extends StatefulWidget {
  final Widget? child;
  final Color primaryColor;
  final Color primaryColor1;
  final String title;
  final int count;
  final void Function()? onTap;
  const CourseUnitTargetComprehensiveCardWidget({
    super.key,
    this.child,
    required this.primaryColor,
    required this.primaryColor1,
    required this.title,
    required this.count,
    this.onTap,
  });

  @override
  State<CourseUnitTargetComprehensiveCardWidget> createState() => _CourseUnitTargetComprehensiveCardWidgetState();
}

class _CourseUnitTargetComprehensiveCardWidgetState extends State<CourseUnitTargetComprehensiveCardWidget> {
  /// 是否悬浮
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: TapScaleWidget(
        onTap: widget.onTap,
        sclae: 1,
        child: AnimatedScale(
          duration: Duration(milliseconds: 200),
          scale: _isHovered ? 1.015 : 1.0,
          alignment: Alignment.bottomCenter,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceLayerBase.color,
              borderRadius: BorderRadius.circular(20.wMin),
              border: Border.all(color: AppTheme.cBorderThin.color, width: 1.wMin),
            ),
            child: Column(
              children: [
                _buildTitleWidget(),
                Expanded(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    margin: EdgeInsets.only(
                      left: 16.wMin,
                      right: 16.wMin,
                      bottom: 16.wMin,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.wMin),
                      color: AppTheme.cSurfaceBg.color,
                    ),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Container(
      padding: EdgeInsets.only(top: 24.wMin, bottom: 16.wMin),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.primaryColor.withValues(alpha: 0.12),
            widget.primaryColor.withValues(alpha: 0),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8.wMin,
            height: 40.wMin,
            decoration: BoxDecoration(
              color: widget.primaryColor,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(4.wMin)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.primaryColor,
                  widget.primaryColor1,
                ],
              ),
            ),
          ),
          SizedBox(width: 18.wMin),
          Text(
            widget.title,
            style: TextStyle(
              color: AppTheme.cTextPrimary.color,
              fontSize: 32.wMin,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 18.wMin),
          Text(
            '${widget.count}个',
            style: TextStyle(
              color: AppTheme.cTextTertiary.color,
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
          Spacer(),
          ButtonWidget(
            text: "进入",
            height: 32.wMin,
            borderRadius: 99,
            padding: EdgeInsets.only(left: 14.wMin, right: 6.wMin),
            color: widget.primaryColor.withValues(alpha: 0.12),
            fontColor: widget.primaryColor,
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            rightIcon: SvgPicture.asset(
              "assets/svg/public/icon_w_arrow_right.svg",
              width: 20.wMin,
              colorFilter: ColorFilter.mode(widget.primaryColor, BlendMode.srcIn),
            ),
          ),
          SizedBox(width: 18.wMin),
        ],
      ),
    );
  }
}
