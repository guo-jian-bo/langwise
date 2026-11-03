import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../../utils/utils.dart';
import 'manage_sentence_add_widgets.dart';

/// 候选句弹窗需要的展示数据。
class ManageSentenceAddSelectDialogModel {
  /// 当前页面对应的句法类型，决定候选接口分流。
  final ZhenxieEnSentenceType pageType;

  /// 弹窗标题。
  final String title;

  /// 当前资产 nid，弹窗内部用它请求候选句。
  final String nid;

  /// 当前形态已纳入的基态槽。
  final List<String> baseSlotKeys;

  /// 当前要拧的槽。
  final List<String> dialSlotKeys;

  /// 当前页面已经绑上的句子 id，用于候选排重。
  final List<int> boundSentenceIds;

  /// 单元入口传入的 unitId，只用于限制候选范围。
  final int? unitId;

  /// 金字塔模式下当前格位层号，`0` 代表基句层。
  final int? layerIndex;

  /// 金字塔模式下当前已锁定的基句 id。
  final int? baseSentenceId;

  /// 金字塔模式下当前有序增长槽。
  final List<String> growthSlotKeys;

  /// 当前句型名称。
  final String? patternName;

  /// 顶部样句提示。
  final ZhenxieSentenceMemberSentenceEntity? exampleSentence;

  /// 对照模式下当前格位的 valueNid。
  final String? valueNid;

  /// 对照模式下当前格位的高亮焦点。
  final SentencePatternCompareContrastFocusEntity? contrastFocus;

  /// 对照模式下服务端直接返回的高亮区间。
  final List<ZhenxieSentenceMemberFocusEntity?>? foci;

  /// 配对模式下当前格位标识，如 from / to。
  final String? pairCellKey;

  /// 全景模式下当前格位的轴值映射。
  final Map<String, String>? gridAxisValues;

  const ManageSentenceAddSelectDialogModel({
    required this.pageType,
    required this.title,
    required this.nid,
    required this.baseSlotKeys,
    required this.dialSlotKeys,
    required this.boundSentenceIds,
    this.unitId,
    this.layerIndex,
    this.baseSentenceId,
    this.growthSlotKeys = const [],
    this.patternName,
    this.exampleSentence,
    this.valueNid,
    this.contrastFocus,
    this.foci,
    this.pairCellKey,
    this.gridAxisValues,
  });
}

/// 甄写句子 选择句子
class ManageSentenceAddSelectDialog {
  static Future<PatternBlueprintSentenceBriefEntity?> show({
    required BuildContext context,
    required ManageSentenceAddSelectDialogModel model,
  }) async {
    return await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ManageSentenceAddSelectDialogWidget(model: model);
      },
    );
  }
}

class ManageSentenceAddSelectDialogWidget extends StatefulWidget {
  /// 当前格位对应的弹窗展示数据。
  final ManageSentenceAddSelectDialogModel model;

  const ManageSentenceAddSelectDialogWidget({
    super.key,
    required this.model,
  });

  @override
  State<ManageSentenceAddSelectDialogWidget> createState() => _ManageSentenceAddSelectDialogWidgetState();
}

class _ManageSentenceAddSelectDialogWidgetState extends State<ManageSentenceAddSelectDialogWidget> {
  final TextEditingController searchInput = TextEditingController();

  /// 当前候选句接口结果。
  PatternRealizationSetPatternCellCandidatesEntity? candidateEntity;

  /// 弹窗是否还在加载候选句。
  bool isLoading = true;

  /// 当前搜索词，只在弹窗内部参与本地过滤。
  String searchText = "";

  /// 当前候选范围是否继续带单元限制。
  bool useUnitScope = true;

  @override
  void initState() {
    super.initState();
    useUnitScope = widget.model.unitId != null;
    _loadCandidates();
  }

  @override
  void dispose() {
    searchInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<PatternBlueprintSentenceBriefEntity> visibleList = candidateEntity?.candidateList.where((item) {
          if (searchText.isEmpty) {
            return true;
          }
          final String keyword = searchText.toLowerCase();
          final String sentenceId = "${item.sentenceId ?? ''}";
          final String content = (item.content ?? "").toLowerCase();
          return sentenceId.contains(keyword) || content.contains(keyword);
        }).toList() ??
        const [];
    return DialogUserWidget(
      title: widget.model.title,
      width: 1000.wMin,
      titlePadding: EdgeInsets.only(
        top: 24.wMin,
        left: 24.wMin,
        right: 24.wMin,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(),
            SizedBox(height: 10.wMin),
            Container(height: 1.wMin, color: AppTheme.cBorderDefault.color),
            _buildSearchWidget(),
            _buildListTitleWidget(),
            Container(height: 1.wMin, color: AppTheme.cBorderDefault.color),
            _buildListWidget(visibleList),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.model.patternName?.isNotEmpty == true ? widget.model.patternName! : "当前句型",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          Text(
            isLoading ? "正在加载可绑句..." : "库里 ${candidateEntity?.candidateList.length ?? 0} 句能绑到这一格",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          ManageSentenceAddExampleWidget(
            sentence: widget.model.exampleSentence,
            contrastFocus: widget.model.contrastFocus,
            foci: widget.model.foci,
          ),
        ],
      ),
    );
  }

  /// 搜索输入框
  Widget _buildSearchWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
      child: CardInputWidget(
        hintText: "筛选uid或句面",
        controller: searchInput,
        textInputAction: TextInputAction.search,
        height: 54.wMin,
        valueStyle: TextStyle(
          fontSize: 20.wMin,
          color: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: TextStyle(
          fontSize: 20.wMin,
          color: AppTheme.cTextTertiary.color,
          fontWeight: FontWeight.w400,
        ),
        onSubmitted: (value) {
          setState(() {
            searchText = value.trim();
          });
        },
        onChanged: (value) {
          setState(() {
            searchText = value.trim();
          });
        },
      ),
    );
  }

  Widget _buildListTitleWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 6.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            useUnitScope ? "单元内" : "全库",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          Visibility(
            visible: widget.model.unitId != null,
            child: ButtonWidget(
              text: useUnitScope ? "切换为全库" : "切换为单元",
              height: 42.wMin,
              width: 140.wMin,
              borderRadius: 10.wMin,
              color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12),
              border: Border.all(
                width: 0.8.wMin,
                color: AppTheme.cSurfaceSuccess.color,
              ),
              fontSize: 18.wMin,
              fontColor: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
              sclae: 1.03,
              onTap: OptimizeUtils.noneThrottle(() {
                if (isLoading) return;
                setState(() {
                  useUnitScope = !useUnitScope;
                });
                _loadCandidates();
              }, 1000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListWidget(List<PatternBlueprintSentenceBriefEntity> visibleList) {
    final bool hasCandidates = candidateEntity?.candidateList.isNotEmpty == true;
    return SizedBox(
      height: 750.wMin,
      child: isLoading
          ? Center(
              child: SpinKitFadingCircle(
              color: AppTheme.cBgBrand,
              size: 100.wMin,
            ))
          : !hasCandidates
              ? _buildEmptyWidget(_emptyReasonText(candidateEntity?.emptyReason))
              : visibleList.isEmpty
                  ? _buildEmptyWidget("没有匹配「$searchText」的句")
                  : ListView.separated(
                      itemCount: visibleList.length,
                      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
                      separatorBuilder: (context, index) => SizedBox(height: 6.wMin),
                      itemBuilder: (context, index) {
                        return _buildItemWidget(visibleList[index]);
                      },
                    ),
    );
  }

  /// 拉取当前格位的候选句列表。
  Future<void> _loadCandidates() async {
    isLoading = true;
    setState(() {});
    try {
      PatternRealizationSetPatternCellCandidatesEntity? response;
      if (widget.model.pageType == ZhenxieEnSentenceType.EN_SENTENCE_PARADIGM) {
        final String? valueNid = widget.model.valueNid;
        if (valueNid == null || valueNid.isEmpty) {
          ToastUtils.showToast(text: '当前格位缺少 valueNid');
          if (!mounted) return;
          setState(() {
            candidateEntity = null;
          });
          return;
        }
        response = await LanguageConsoleRequest.queryPatternRealizationSetParadigmCellCandidates(
          nid: widget.model.nid,
          data: _buildRequestData(),
        );
      } else if (widget.model.pageType == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID) {
        final int? layerIndex = widget.model.layerIndex;
        if (layerIndex == null) {
          ToastUtils.showToast(text: '当前格位缺少 layerIndex');
          if (!mounted) return;
          setState(() {
            candidateEntity = null;
          });
          return;
        }
        response = await LanguageConsoleRequest.queryPatternRealizationSetPyramidCellCandidates(
          nid: widget.model.nid,
          data: _buildRequestData(),
        );
      } else if (widget.model.pageType == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR) {
        final String? pairCellKey = widget.model.pairCellKey;
        if (pairCellKey == null || pairCellKey.isEmpty) {
          ToastUtils.showToast(text: '当前格位缺少 cell');
          if (!mounted) return;
          setState(() {
            candidateEntity = null;
          });
          return;
        }
        response = await LanguageConsoleRequest.queryPatternRealizationSetPairCellCandidates(
          nid: widget.model.nid,
          data: _buildRequestData(),
        );
      } else if (widget.model.pageType == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK) {
        final String? pairCellKey = widget.model.pairCellKey;
        final String? valueNid = widget.model.valueNid;
        if (pairCellKey == null || pairCellKey.isEmpty) {
          ToastUtils.showToast(text: '当前格位缺少 cell');
          if (!mounted) return;
          setState(() {
            candidateEntity = null;
          });
          return;
        }
        if (valueNid == null || valueNid.isEmpty) {
          ToastUtils.showToast(text: '当前格位缺少 valueNid');
          if (!mounted) return;
          setState(() {
            candidateEntity = null;
          });
          return;
        }
        response = await LanguageConsoleRequest.queryPatternRealizationSetPairForkCellCandidates(
          nid: widget.model.nid,
          data: _buildRequestData(),
        );
      } else if (widget.model.pageType == ZhenxieEnSentenceType.EN_SENTENCE_GRAMMAR_GRID) {
        final String? pairCellKey = widget.model.pairCellKey;
        final String? valueNid = widget.model.valueNid;
        if (pairCellKey == null || pairCellKey.isEmpty) {
          ToastUtils.showToast(text: '当前格位缺少 cell');
          if (!mounted) return;
          setState(() {
            candidateEntity = null;
          });
          return;
        }
        if (valueNid == null || valueNid.isEmpty) {
          ToastUtils.showToast(text: '当前格位缺少 valueNid');
          if (!mounted) return;
          setState(() {
            candidateEntity = null;
          });
          return;
        }
        response = await LanguageConsoleRequest.queryPatternRealizationSetGridCellCandidates(
          nid: widget.model.nid,
          data: _buildRequestData(),
        );
      } else {
        response = await LanguageConsoleRequest.queryPatternRealizationSetPatternCellCandidates(
          nid: widget.model.nid,
          data: _buildRequestData(),
        );
      }
      if (!mounted) return;
      if (response?.emptyReason != null) {
        setState(() {
          candidateEntity = response;
        });
        ToastUtils.showToast(text: response!.emptyReason!);
        return;
      }
      setState(() {
        candidateEntity = response;
      });
    } finally {
      isLoading = false;
      if (mounted) setState(() {});
    }
  }

  /// 组装候选句请求参数，让弹窗入口一眼能看清会带什么字段。
  Map<String, dynamic> _buildRequestData() {
    if (widget.model.pageType == ZhenxieEnSentenceType.EN_SENTENCE_PARADIGM) {
      return {
        'valueNid': widget.model.valueNid,
        'boundSentenceIds': widget.model.boundSentenceIds,
        if (useUnitScope && widget.model.unitId != null) 'unitId': widget.model.unitId,
      };
    }
    if (widget.model.pageType == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID) {
      return {
        'layerIndex': widget.model.layerIndex,
        'baseSentenceId': widget.model.baseSentenceId,
        'growthSlotKeys': widget.model.growthSlotKeys,
        'boundSentenceIds': widget.model.boundSentenceIds,
        if (useUnitScope && widget.model.unitId != null) 'unitId': widget.model.unitId,
      };
    }
    if (widget.model.pageType == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR) {
      return {
        'cell': widget.model.pairCellKey,
        'boundSentenceIds': widget.model.boundSentenceIds,
        if (useUnitScope && widget.model.unitId != null) 'unitId': widget.model.unitId,
      };
    }
    if (widget.model.pageType == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK) {
      return {
        'cell': widget.model.pairCellKey,
        'valueNid': widget.model.valueNid,
        'boundSentenceIds': widget.model.boundSentenceIds,
        if (useUnitScope && widget.model.unitId != null) 'unitId': widget.model.unitId,
      };
    }
    if (widget.model.pageType == ZhenxieEnSentenceType.EN_SENTENCE_GRAMMAR_GRID) {
      return {
        'cell': widget.model.pairCellKey,
        'valueNid': widget.model.valueNid,
        'axisValues': widget.model.gridAxisValues,
        'boundSentenceIds': widget.model.boundSentenceIds,
        if (useUnitScope && widget.model.unitId != null) 'unitId': widget.model.unitId,
      };
    }

    final Map<String, dynamic> data = {
      'baseSlotKeys': widget.model.baseSlotKeys,
      'dialSlotKeys': widget.model.dialSlotKeys,
      'boundSentenceIds': widget.model.boundSentenceIds,
    };
    if (useUnitScope && widget.model.unitId != null) {
      data['unitId'] = widget.model.unitId;
    }
    return data;
  }

  /// 把 emptyReason 转成弹窗可直接展示的文案。
  String _emptyReasonText(String? emptyReason) {
    switch (emptyReason) {
      case 'no_unit_sentences':
        return '这个单元还没有可用英语句子';
      case 'no_unit_candidates':
        return '这个单元有英语句子，但没有句子能绑到这一格';
      case 'no_corpus_candidates':
        return '全库都没有能绑到这一格的句子';
      default:
        return '库里没有能绑到这一格的句子，只能补句落库';
    }
  }

  Widget _buildEmptyWidget(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.wMin,
          color: AppTheme.cTextTertiary.color,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildItemWidget(PatternBlueprintSentenceBriefEntity item) {
    return TapScaleWidget(
      onTap: () {
        Get.back(result: item);
      },
      sclae: 1,
      borderRadius: 10.wMin,
      backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.08),
      child: Container(
        padding: EdgeInsets.all(10.wMin),
        child: Row(
          children: [
            Text(
              "${item.sentenceId ?? ''}",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 10.wMin),
            Expanded(
              child: Text(
                item.content ?? "",
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
