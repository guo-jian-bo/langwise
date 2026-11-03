import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/app/modules/management/dialog/manage_create_phrase/view.dart';
import 'package:langwise/app/modules/management/dialog/manage_create_sentence/view.dart';
import 'package:langwise/app/modules/management/dialog/manage_create_single_word/view.dart';
import 'package:langwise/app/modules/management/dialog/manage_create_text/view.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'views/cached_data_table_widget.dart';
import 'views/select_semantic_widget.dart';

/// 知识点类型枚举
enum NewKnowledgeType { WORD, PHRASE, SENTENCE, ARTICLE }

/// 按钮显示策略接口
abstract class AddButtonVisibilityStrategy {
  bool shouldShowButton(KnowledgeTableContext context);
}

/// 固定显示策略（由外部参数决定）
class FixedVisibilityStrategy implements AddButtonVisibilityStrategy {
  final bool isVisible;

  FixedVisibilityStrategy(this.isVisible);

  @override
  bool shouldShowButton(KnowledgeTableContext context) => isVisible;
}

/// 数据驱动显示策略（根据数据状态决定）
class DataDrivenVisibilityStrategy implements AddButtonVisibilityStrategy {
  @override
  bool shouldShowButton(KnowledgeTableContext context) {
    switch (context.currentNewKnowledgeType) {
      case NewKnowledgeType.WORD:
        return context.wordList.isEmpty;
      case NewKnowledgeType.PHRASE:
        return context.phraseList.isEmpty;
      case NewKnowledgeType.SENTENCE:
        return context.sentenceList.isEmpty;
      case NewKnowledgeType.ARTICLE:
        return context.articleList.isEmpty;
    }
  }
}

/// 知识表格配置
class KnowledgeTableConfig {
  final bool showAddButton;
  final bool hasFixedButtonVisibility;

  /// 是否启用单选模式（默认为false，即非单选模式）
  final bool singleSelectionMode;

  KnowledgeTableConfig({
    this.showAddButton = true,
    this.hasFixedButtonVisibility = true,
    this.singleSelectionMode = false,
  });

  /// 从外部参数创建配置
  factory KnowledgeTableConfig.fromParams({required bool showSelectKnowledgeAddButton, bool singleSelectionMode = false}) {
    return KnowledgeTableConfig(
      showAddButton: showSelectKnowledgeAddButton,
      hasFixedButtonVisibility: true,
      singleSelectionMode: singleSelectionMode,
    );
  }
}

/// 知识表格上下文
class KnowledgeTableContext {
  final KnowledgeTableConfig config;
  List<EnWordEntity> wordList = [];
  List<EnPhraseEntity> phraseList = [];
  List<EnSentenceEntity> sentenceList = [];
  List<EnTextEntity> articleList = [];
  NewKnowledgeType currentNewKnowledgeType = NewKnowledgeType.WORD;
  bool isLoading = false;

  KnowledgeTableContext({required this.config});

  bool get hasData {
    switch (currentNewKnowledgeType) {
      case NewKnowledgeType.WORD:
        return wordList.isNotEmpty;
      case NewKnowledgeType.PHRASE:
        return phraseList.isNotEmpty;
      case NewKnowledgeType.SENTENCE:
        return sentenceList.isNotEmpty;
      case NewKnowledgeType.ARTICLE:
        return articleList.isNotEmpty;
    }
  }

  /// 创建按钮显示策略
  AddButtonVisibilityStrategy createVisibilityStrategy() {
    if (config.hasFixedButtonVisibility) {
      return FixedVisibilityStrategy(config.showAddButton);
    } else {
      return DataDrivenVisibilityStrategy();
    }
  }
}

/// 管理-添加级别-关联-添加知识点
class ManageSelectKnowledgeTableManager {
  /// 使用自定义按钮显示策略显示知识点表格
  ///
  /// @param context 上下文
  /// @param unitId 单元ID
  /// @param defaultDessert 默认知识点列表
  /// @param buttonConfig 按钮显示策略配置
  /// @param word 单词
  /// @param language 语言
  /// @param tabCurrentIndex 当前标签索引
  /// @param dataDisableCallback 数据禁用回调
  static Future<List<BaseKnowledge>?> showWithButtonStrategy({
    required BuildContext context,
    //required int unitId,
    required List<BaseKnowledge> defaultDessert,
    required KnowledgeTableConfig buttonConfig,
    final String? word,
    final String? definition,
    final String? language,
    int tabCurrentIndex = 0,
    final bool Function(BaseKnowledge)? dataDisableCallback,
  }) async {
    return await showCupertinoDialog<List<BaseKnowledge>?>(
      context: context,
      builder: (context) {
        return ManageSelectKnowledgeTablePage(
          //unitId: unitId,
          defaultDessert: defaultDessert,
          word: word,
          definition: definition,
          language: language,
          tabCurrentIndex: tabCurrentIndex,
          dataDisableCallback: dataDisableCallback,
          buttonConfig: buttonConfig,
        );
      },
    );
  }

  static Future<List<BaseKnowledge>?> show(
      {required BuildContext context,
      required List<BaseKnowledge> defaultDessert,
      bool showSelectKnowledgeAddButton = false,
      final String? word,
      final String? definition,
      String? language,
      int tabCurrentIndex = 0,
      bool hidePhrase = false,
      bool hideSentence = false,
      bool hideText = false,
      String? topic, //专项课 自然拼读课音标
      String? searchContent, //固定搜索内容
      String? searchInputContent, //固定搜索内容1 填充到输入框
      int? selectMax,
      bool? singleSelectionMode, //是否启用单选模式（默认为false，即非单选模式）
      String? defaultContent, //默认知识点内容
      bool showEmptyTip = true,
      final bool Function(BaseKnowledge)? dataDisableCallback}) async {
    return await showCupertinoDialog<List<BaseKnowledge>?>(
      context: context,
      builder: (context) {
        return ManageSelectKnowledgeTablePage(
          defaultDessert: defaultDessert,
          word: word,
          definition: definition,
          language: language,
          showSelectKnowledgeAddButton: showSelectKnowledgeAddButton,
          tabCurrentIndex: tabCurrentIndex,
          dataDisableCallback: dataDisableCallback,
          hidePhrase: hidePhrase,
          hideSentence: hideSentence,
          hideText: hideText,
          topic: topic,
          searchContent: searchContent,
          searchInputContent: searchInputContent,
          singleSelectionMode: singleSelectionMode,
          defaultContent: defaultContent,
          selectMax: selectMax,
          showEmptyTip: showEmptyTip,
        );
      },
    );
  }
}

class ManageSelectKnowledgeTablePage extends StatefulWidget {
  //final int unitId;
  final List<BaseKnowledge> defaultDessert;
  final String? word;
  final String? definition;
  final String? language;
  final bool showSelectKnowledgeAddButton;
  final int tabCurrentIndex;
  final bool Function(BaseKnowledge)? dataDisableCallback;
  final KnowledgeTableConfig? buttonConfig;
  final bool hidePhrase;
  final bool hideSentence;
  final bool hideText;
  final String? topic; //专项课 自然拼读课音标
  final String? searchContent; //固定搜索内容
  final String? searchInputContent; //固定搜索内容1 填充到输入框
  final bool? singleSelectionMode; //是否启用单选模式（默认为false，即非单选模式）
  final int? selectMax; //最大选择数量
  final String? defaultContent; //默认知识点内容
  final bool showEmptyTip;

  const ManageSelectKnowledgeTablePage({
    Key? key,
    //required this.unitId,
    required this.defaultDessert,
    this.word,
    this.definition,
    this.language,
    this.showSelectKnowledgeAddButton = false,
    this.tabCurrentIndex = 0,
    this.dataDisableCallback,
    this.buttonConfig,
    this.hidePhrase = false,
    this.hideSentence = false,
    this.hideText = false,
    this.topic, //专项课 自然拼读课音标
    this.searchContent, //固定搜索内容
    this.searchInputContent, //固定搜索内容
    this.singleSelectionMode, //是否启用单选模式（默认为false，即非单选模式）
    this.selectMax,
    this.defaultContent,
    this.showEmptyTip = true,
  }) : super(key: key);

  @override
  State<ManageSelectKnowledgeTablePage> createState() => _ManageSelectKnowledgeTablePageState();
}

class _ManageSelectKnowledgeTablePageState extends State<ManageSelectKnowledgeTablePage> with SingleTickerProviderStateMixin, SafeSetStateMixin {
  AsyncDataTableSource? _wordDataSourceAsync, _phraseDataSourceAsync, _sentenceDataSourceAsync, _textDataSourceAsync;

  // 知识点搜索控制器
  final TextEditingController knowledgeController = TextEditingController(), fullKnowledgeController = TextEditingController();

  final TextEditingController phoneticController = TextEditingController();

  TabController? tabController;
  int tabCurrentIndex = 0;

  final List<String> tabList = <String>["单词"];

  // 选中的单词
  final List<BaseKnowledge> selectedRows = <BaseKnowledge>[];

  // 搜索
  String? title, des;

  List<String> uids = [];

  String? fullTitle;

  // 知识表格上下文，用于策略模式
  late KnowledgeTableContext _tableContext;

  // 按钮显示策略
  late AddButtonVisibilityStrategy _buttonVisibilityStrategy;

  @override
  void initState() {
    super.initState();
    if (!widget.hidePhrase) {
      tabList.add("短语");
    }
    if (!widget.hideSentence) {
      tabList.add("句子");
    }
    if (!widget.hideText) {
      tabList.add("文章");
    }

    phoneticController.text = widget.topic ?? '';
    knowledgeController.text = widget.searchInputContent ??'';

    print("[$runtimeType] 是否显示新增按钮 showSelectKnowledgeAddButton: ${widget.showSelectKnowledgeAddButton}");

    // 初始化知识表格配置和上下文
    _tableContext = KnowledgeTableContext(config: widget.buttonConfig ?? KnowledgeTableConfig.fromParams(showSelectKnowledgeAddButton: widget.showSelectKnowledgeAddButton));

    // 初始化按钮显示策略
    _buttonVisibilityStrategy = _tableContext.createVisibilityStrategy();

    // 设置当前知识类型
    _updateCurrentNewKnowledgeType();

    // word尽量不要从是复制过来的.手动输入更好.
    tabCurrentIndex = widget.tabCurrentIndex;
    if (widget.word?.trim() != null) {
      // 精确搜索
      fullKnowledgeController.text = widget.word ?? '';
      onSetFullName(widget.word!.trim(), isSubmit: false);
    }
    tabController = TabController(initialIndex: tabCurrentIndex, vsync: this, length: tabList.length);
    addTabListener();

    if (widget.searchContent != null) {
      onSetName(widget.searchContent ?? '');
      //onSetFullName(widget.searchContent ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xff040712).withValues(alpha: 0.8),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Center(
              child: Container(
                width: 1500.wMin,
                height: 1000.wMin,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  border: Border.all(
                    color: const Color(0xff444B5F),
                    width: 1.wMin, // 边框宽度
                  ),
                  color: const Color(0xff181B25),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ManageTitleWidget(
                      title: "选择知识点",
                      onCloseTap: () {
                        onCloseDialog(context);
                      },
                    ),

                    Visibility(
                      visible: widget.defaultContent != null,
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 6.wMin),
                        padding: EdgeInsets.symmetric(vertical: 4.wMin),
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: const Color(0xff444B5F),
                              width: 1.wMin,
                            ),
                          ),
                        ),
                        child: Row(
                          spacing: 10.wMin,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "默认知识点: ",
                              style: TextStyle(
                                color: const Color.fromARGB(187, 255, 255, 255),
                                fontSize: 14.wMin,
                              ),
                            ),
                            Expanded(
                              child: SelectableText(
                                widget.defaultContent??'',
                                maxLines: 5,
                                style: TextStyle(
                                  color: const Color.fromARGB(223, 255, 255, 255),
                                  fontSize: 14.wMin,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Gaps.getHeight(20.wMin),
                    _buildHeader(context),
                    Expanded(
                        child: TabBarView(
                      controller: tabController,
                      children: List.generate(tabList.length, (index) {
                        if (index == 0) {
                          return _buildWordTable(context);
                        } else if (index == 1) {
                          return _buildPhraseTable(context);
                        } else if (index == 2) {
                          return _buildSentenceTable(context);
                        }
                        return _buildTextTable(context);
                      }),
                    )),
                    Gaps.getHeight(24.wMin),
                    _buildBottomWidget(context),
                  ],
                ),
              ),
            )));
  }

  Widget buildTabBar() {
    return TabBar(
      controller: tabController,
      indicatorPadding: EdgeInsets.only(bottom: -10.wh),
      indicator: UnderlineTabIndicator(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(width: 5.wMin, color: const Color(0xff2388FF))),
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      dividerHeight: 0,
      labelStyle: TextStyle(
        fontSize: 18.wMin,
        color: Colors.white,
        fontWeight: FontWeight.w400,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 18.wMin,
        color: const Color(0xffACB4C0),
        fontWeight: FontWeight.w400,
      ),
      tabs: List.generate(tabList.length, (index) {
        final String title = tabList[index];
        return Text(
          title,
          style: TextStyle(
            fontSize: 18.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        );
      }),
    );
  }

  Widget _buildWordTable(BuildContext context) {
    return CachedDataTable<EnWordEntity>(
      columns: _buildColumns(),
      dataDisableCallback: widget.dataDisableCallback,
      sourceCallback: (source) => onSetWordDataSourceAsync(source),
      fetchData: (currentPage, start, count, sortedBy, asc, noData) => onFetchWordPages(currentPage, start, count, sortedBy, asc, noData),
      onRowSelectChanged: (selected, id, value) => onWordRowSelectChanged(context, selected, id, value),
      dataCellBuilder: (item, index) => [
        _buildDataCell('${item.uid}'),
        _buildDataCell(item.content ?? ''),
        _buildDataCell(item.posTitle ?? ''),
        DataCell(DataGeneralColumnWidget(
          child: StatusTagDifficultyWidget(
            difficulty: item.minDifficulty,
            language: widget.language,
          ),
        )),
        DataCell(DataGeneralColumnWidget(
          child: StatusTagDifficultyWidget(
            difficulty: item.maxDifficulty,
            language: widget.language,
          ),
        )),
        _buildDataCell(item.allGlossZhTitle),
      ],
    );
  }

  Widget _buildPhraseTable(BuildContext context) {
    return CachedDataTable<EnPhraseEntity>(
      columns: _buildColumns(),
      dataDisableCallback: widget.dataDisableCallback,
      sourceCallback: (source) => onSetEnPhraseDataSourceAsync(source),
      fetchData: (currentPage, start, count, sortedBy, asc, noData) => onFetchPhrasePages(currentPage, start, count, sortedBy, asc, noData),
      onRowSelectChanged: (selected, id, value) => onPhraseRowSelectChanged(context, selected, id, value),
      dataCellBuilder: (item, index) => [
        _buildDataCell('${item.uid}'),
        _buildDataCell(item.content ?? ''),
        _buildDataCell(item.posTitle ?? ''),
        DataCell(DataGeneralColumnWidget(
          child: StatusTagDifficultyWidget(
            difficulty: item.minDifficulty,
            language: widget.language,
          ),
        )),
        DataCell(DataGeneralColumnWidget(
          child: StatusTagDifficultyWidget(
            difficulty: item.maxDifficulty,
            language: widget.language,
          ),
        )),
        _buildDataCell(item.allGlossZhTitle),
      ],
    );
  }

  Widget _buildSentenceTable(BuildContext context) {
    return CachedDataTable<EnSentenceEntity>(
      columns: _buildColumns(isSentence: true),
      autoSelected: true,
      dataDisableCallback: widget.dataDisableCallback,
      sourceCallback: (source) => onSetEnSentenceDataSourceAsync(source),
      fetchData: (currentPage, start, count, sortedBy, asc, noData) => onFetchSentencePages(currentPage, start, count, sortedBy, asc, noData),
      onRowSelectChanged: (selected, id, value) => onSentenceRowSelectChanged(context, selected, id, value),
      dataCellBuilder: (item, index) => [
        _buildDataCell('${item.uid}'),
        _buildDataCell(item.content ?? ''),
        DataCell(DataGeneralColumnWidget(
          child: StatusTagDifficultyWidget(
            difficulty: (item.minDifficulty),
            language: widget.language,
          ),
        )),
        DataCell(DataGeneralColumnWidget(
          child: StatusTagDifficultyWidget(
            difficulty: (item.maxDifficulty),
            language: widget.language,
          ),
        )),
        _buildDataCell(item.definition ?? ''),
      ],
    );
  }

  Widget _buildTextTable(BuildContext context) {
    return CachedDataTable<EnTextEntity>(
      columns: _buildTextColumns(),
      autoSelected: true,
      dataDisableCallback: widget.dataDisableCallback,
      sourceCallback: (source) => onSetEnSentenceDataSourceAsync(source),
      fetchData: (currentPage, start, count, sortedBy, asc, noData) => onFetchTextPages(currentPage, start, count, sortedBy, asc, noData),
      onRowSelectChanged: (selected, id, value) => onTextRowSelectChanged(context, selected, id, value),
      dataCellBuilder: (item, index) {
        int? difficulty;
        if(item.difficulty is Map){
          difficulty = item.difficulty['min'];
        }else{
          difficulty = item.difficulty;
        }
        return [
          _buildDataCell('${item.uid}'),
          _buildDataCell(item.title ?? ''),
          _buildDataCell(item.content ?? ''),
          DataCell(DataGeneralColumnWidget(
            child: StatusTagDifficultyWidget(
              difficulty: difficulty,
              language: widget.language,
            ),
          )),
        ];
      },
    );
  }

  DataCell _buildDataCell(String text) {
    return DataCell(DataGeneralColumnWidget(
      child: Text(
        text,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xffEBEEF3),
          fontSize: 18.wMin,
          fontWeight: FontWeight.w400,
        ),
      ),
    ));
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: widget.searchContent == null,
          child: Row(
            children: [
              SearchWidget(
                width: 160.ww,
                height: 42.wh,
                hintText: 'uid',
                onChanged: (String value) {
                  onSetId(value);
                },
                onSubmitted: (String value) {
                  onSetId(value, isSubmit: true);
                },
              ),
              Gaps.getWidth(12.ww),
              SearchWidget(
                width: 160.ww,
                height: 42.wh,
                hintText: '知识点',
                controller: knowledgeController,
                onChanged: (String value) {
                  onSetName(value);
                },
                onSubmitted: (String value) {
                  onSetName(value, isSubmit: true);
                },
              ),
              Gaps.getWidth(12.ww),
              if (tabCurrentIndex == 3) const SizedBox(),
              if (tabCurrentIndex == 0 || tabCurrentIndex == 1 || tabCurrentIndex == 2)
                SearchWidget(
                  width: 160.ww,
                  height: 42.wh,
                  hintText: '知识点(精确搜索)',
                  controller: fullKnowledgeController,
                  onChanged: (String value) {
                    onSetFullName(value);
                  },
                  onSubmitted: (String value) {
                    onSetFullName(value, isSubmit: true);
                  },
                ),
              Gaps.getWidth(12.ww),
              Visibility(
                visible: tabCurrentIndex == 0,
                child: SearchWidget(
                  width: 160.ww,
                  height: 42.wh,
                  hintText: '音标',
                  controller: phoneticController,
                  onSubmitted: (String value) {
                    onSetPhonetic();
                  },
                ),
              ),
            ],
          ),
        ),
        Gaps.getHeight(16.wh),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildTabBar(),
            // 使用策略模式决定是否显示按钮
            if (_buttonVisibilityStrategy.shouldShowButton(_tableContext))
              ManageButton(
                text: "新增",
                width: 80.ww,
                height: 32.wh,
                color: const Color(0xff2388FF),
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: const Color(0xffEBEEF3),
                  fontWeight: FontWeight.w400,
                ),
                borderColor: Colors.transparent,
                onTap: OptimizeUtils.noneThrottle(() {
                  onConfirm(context);
                }, 100),
              )
          ],
        )
      ],
    );
  }

  List<DataColumn> _buildColumns({bool isSentence = false}) {
    return [
      DataColumn2(
        label: DataGeneralColumnWidget(
          child: Text(
            'uid',
            style: TextStyle(fontSize: 18.wMin, color: const Color(0xffACB4C0), fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis),
          ),
        ),
        headingRowAlignment: MainAxisAlignment.start,
        size: ColumnSize.S,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: DataGeneralColumnWidget(
            child: Text(
          '知识点',
          style: TextStyle(fontSize: 18.wMin, color: const Color(0xffACB4C0), fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis),
        )),
        size: ColumnSize.M,
      ),
      if (!isSentence)
        DataColumn2(
          headingRowAlignment: MainAxisAlignment.start,
          label: DataGeneralColumnWidget(
              child: Text(
            '词性',
            style: TextStyle(fontSize: 18.wMin, color: const Color(0xffACB4C0), fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis),
          )),
          size: ColumnSize.S,
        ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: DataGeneralColumnWidget(
            child: Text(
          '最小难度水平',
          style: TextStyle(fontSize: 18.wMin, color: const Color(0xffACB4C0), fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis),
        )),
        size: ColumnSize.M,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: DataGeneralColumnWidget(
            child: Text(
          '最大难度水平',
          style: TextStyle(fontSize: 18.wMin, color: const Color(0xffACB4C0), fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis),
        )),
        size: ColumnSize.M,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: DataGeneralColumnWidget(
            child: Text(
          '语义',
          style: TextStyle(
            fontSize: 18.wMin,
            color: const Color(0xffACB4C0),
            fontWeight: FontWeight.w400,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        size: ColumnSize.L,
      ),
    ];
  }

  List<DataColumn> _buildTextColumns() {
    return [
      DataColumn2(
        label: DataGeneralColumnWidget(
          child: Text(
            'uid',
            style: TextStyle(fontSize: 18.wMin, color: const Color(0xffACB4C0), fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis),
          ),
        ),
        headingRowAlignment: MainAxisAlignment.start,
        size: ColumnSize.S,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: DataGeneralColumnWidget(
            child: Text(
          '标题',
          style: TextStyle(
            fontSize: 18.wMin,
            color: const Color(0xffACB4C0),
            fontWeight: FontWeight.w400,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        size: ColumnSize.S,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: DataGeneralColumnWidget(
            child: Text(
          '知识点',
          style: TextStyle(
            fontSize: 18.wMin,
            color: const Color(0xffACB4C0),
            fontWeight: FontWeight.w400,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        size: ColumnSize.M,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: DataGeneralColumnWidget(
            child: Text(
          '难度水平',
          style: TextStyle(
            fontSize: 18.wMin,
            color: const Color(0xffACB4C0),
            fontWeight: FontWeight.w400,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        size: ColumnSize.M,
      ),
    ];
  }

  Widget _buildBottomWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageButton(
          text: "取消",
          width: 80.ww,
          height: 40.wh,
          borderColor: const Color(0xff666F8D),
          style: TextStyle(
            fontSize: 14.wMin,
            color: const Color(0xffEBEEF3),
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            onCloseDialog(context);
          },
        ),
        SizedBox(width: 11.ww),
        ManageButton(
          text: "添加${selectedRows.length}个知识点",
          height: 40.wh,
          padding: EdgeInsets.only(left: 16.ww, right: 16.ww),
          color: selectedRows.isEmpty ? const Color(0xff353E5C) : const Color(0xff2388FF),
          borderColor: Colors.transparent,
          style: TextStyle(
            fontSize: 14.wMin,
            color: selectedRows.isNotEmpty ? const Color(0xffEBEEF3) : const Color(0xffACB4C0),
            fontWeight: FontWeight.w400,
          ),
          onTap: selectedRows.isEmpty
              ? null
              : OptimizeUtils.noneThrottle(() {
                  onAdd();
                }, 100),
        )
      ],
    );
  }

  void addTabListener() {
    tabController?.addListener(() {
      if (tabController?.index == tabController?.animation?.value) {
        tabCurrentIndex = tabController?.index ?? 0;
        // 更新当前知识类型
        _updateCurrentNewKnowledgeType();
        safeSetState(() {});
        if (tabCurrentIndex == 0) {
          phoneticController.text = widget.topic ?? '';
        } else {
          phoneticController.clear();
        }
      }
    });
  }

  // 获取单词数据
  Future<DesertsFakeWebServiceResponse<EnWordEntity>> onFetchWordPages(int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    try {
      final ListResponseEntity<EnWordEntity>? res = await ManageSelectQuziKnowledge.getEnWordKnowledgeList(parameters: {
        'offset': startingAt,
        'limit': count,
        "order": "-wordFreq",
      }, data: {
        "uid": uids.isEmpty ? null : uids,
        "content": title?.trim(),
        "fullContent": fullTitle?.trim(),
        "phonicsIpa": phoneticController.text.trim(),
      });
      if (res == null) {
        _tableContext.wordList = [];
        safeSetState(() {});
        return DesertsFakeWebServiceResponse<EnWordEntity>(0, []);
      }

      final List<EnWordEntity> _entities = <EnWordEntity>[];
      _entities.addAll((res.datas ?? [])
          .map((element) => element.copyWith(language: widget.language, semantics: element.semantics?.map((s) => s.copyWith(language: widget.language)).toList())));

      // 更新上下文中的单词列表
      _tableContext.wordList = _entities;
      // 刷新按钮显示状态
      safeSetState(() {});

      return DesertsFakeWebServiceResponse<EnWordEntity>(res.count!, _entities);
    } catch (e) {
      _tableContext.wordList = [];
      safeSetState(() {});
      return DesertsFakeWebServiceResponse<EnWordEntity>(0, []);
    }
  }

  // 获取短语数据
  Future<DesertsFakeWebServiceResponse<EnPhraseEntity>> onFetchPhrasePages(int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    try {
      final ListResponseEntity<EnPhraseEntity>? res = await ManageSelectQuziKnowledge.getEnPhraseKnowledgeList(
          parameters: {'offset': startingAt, 'limit': count, "order": "-wordFreq,-uid"},
          data: {"uid": uids.isEmpty ? null : uids, "content": title, "fullContent": fullTitle?.trim()});
      if (res == null) {
        _tableContext.phraseList = [];
        safeSetState(() {});
        return DesertsFakeWebServiceResponse<EnPhraseEntity>(0, []);
      }

      final List<EnPhraseEntity> _entities = <EnPhraseEntity>[];
      _entities.addAll((res.datas ?? [])
          .map((element) => element.copyWith(language: widget.language, semantics: element.semantics?.map((s) => s.copyWith(language: widget.language)).toList())));

      // 更新上下文中的短语列表
      _tableContext.phraseList = _entities;
      // 刷新按钮显示状态
      safeSetState(() {});

      return DesertsFakeWebServiceResponse<EnPhraseEntity>(res.count!, _entities);
    } catch (e) {
      _tableContext.phraseList = [];
      safeSetState(() {});
      return DesertsFakeWebServiceResponse<EnPhraseEntity>(0, []);
    }
  }

  // 获取句子数据
  Future<DesertsFakeWebServiceResponse<EnSentenceEntity>> onFetchSentencePages(int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    print("---😆😆获取句子数据😆😆---");
    try {
      final ListResponseEntity<EnSentenceEntity>? res = await ManageSelectQuziKnowledge.getEnSentenceKnowledgeList(
          parameters: {'offset': startingAt, 'limit': count, "order": "-uid"}, data: {"uid": uids.isEmpty ? null : uids, "content": title, "fullContent": fullTitle?.trim()});
      if (res == null) {
        _tableContext.sentenceList = [];
        safeSetState(() {});
        return DesertsFakeWebServiceResponse<EnSentenceEntity>(0, []);
      }

      final List<EnSentenceEntity> _entities = <EnSentenceEntity>[];
      _entities.addAll((res.datas ?? []).map((element) => element.copyWith(language: widget.language)));

      // 更新上下文中的句子列表
      _tableContext.sentenceList = _entities;
      // 刷新按钮显示状态
      safeSetState(() {});

      return DesertsFakeWebServiceResponse<EnSentenceEntity>(res.count!, _entities);
    } catch (e) {
      _tableContext.sentenceList = [];
      safeSetState(() {});
      return DesertsFakeWebServiceResponse<EnSentenceEntity>(0, []);
    }
  }

  // 获取文章数据
  Future<DesertsFakeWebServiceResponse<EnTextEntity>> onFetchTextPages(int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    try {
      final ListResponseEntity<EnTextEntity>? res = await ManageSelectQuziKnowledge.getEnTextKnowledgeList(
          parameters: {'offset': startingAt, 'limit': count, "order": "-uid"}, data: {"uid": uids.isEmpty ? null : uids, "content": title});
      if (res == null) {
        _tableContext.articleList = [];
        safeSetState(() {});
        return DesertsFakeWebServiceResponse<EnTextEntity>(0, []);
      }

      final List<EnTextEntity> _entities = <EnTextEntity>[];
      _entities.addAll((res.datas ?? []).map((element) => element.copyWith(language: widget.language)));

      // 更新上下文中的文章列表
      _tableContext.articleList = _entities;
      // 刷新按钮显示状态
      safeSetState(() {});

      return DesertsFakeWebServiceResponse<EnTextEntity>(res.count!, _entities);
    } catch (e) {
      _tableContext.articleList = [];
      safeSetState(() {});
      return DesertsFakeWebServiceResponse<EnTextEntity>(0, []);
    }
  }

  // uid
  void onSetId(String uid, {bool isSubmit = false}) {
    // 单词/短语
    if (uid.trim().isEmpty) {
      uids = [];
    } else {
      if (uid.trim().contains(',')) {
        final List<String> s = uid.trim().split(',');
        uids = s;
      } else if (uid.trim().contains(' ')) {
        final List<String> s = uid.trim().split(' ');
        uids = s;
      } else {
        uids = [uid];
      }
    }

    if (isSubmit) {
      _wordDataSourceAsync?.refresh();
      _phraseDataSourceAsync?.refresh();
      _sentenceDataSourceAsync?.refresh();
      _textDataSourceAsync?.refresh();
    }
  }

  // 名称
  void onSetName(String name, {bool isSubmit = false}) {
    // 单词/短语
    title = name;
    if (isSubmit) {
      _wordDataSourceAsync?.refresh();
      _phraseDataSourceAsync?.refresh();
      _sentenceDataSourceAsync?.refresh();
      _textDataSourceAsync?.refresh();
    }
  }

  // 精确搜索
  void onSetFullName(String name, {bool isSubmit = false}) {
    fullTitle = name;
    if (isSubmit) {
      _wordDataSourceAsync?.refresh();
      _phraseDataSourceAsync?.refresh();
      _sentenceDataSourceAsync?.refresh();
      _textDataSourceAsync?.refresh();
    }
  }

  /// 音标
  void onSetPhonetic() {
    _wordDataSourceAsync?.refresh();
  }

  // 异步数据处理器
  void onSetWordDataSourceAsync(AsyncDataTableSource? source) {
    _wordDataSourceAsync = source;
  }

  // 异步数据处理器
  void onSetEnPhraseDataSourceAsync(AsyncDataTableSource? source) {
    _phraseDataSourceAsync = source;
  }

  // 异步数据处理器
  void onSetEnSentenceDataSourceAsync(AsyncDataTableSource? source) {
    _sentenceDataSourceAsync = source;
  }

  // 异步数据处理器
  void onSetEnTextDataSourceAsync(AsyncDataTableSource? source) {
    _textDataSourceAsync = source;
  }

  // 添加/移除
  void onAdd() {
    Get.back(result: [...selectedRows]);
  }

  /// 清除所有选中项（单选模式下使用）
  void _clearAllSelections() {
    for (var item in List<BaseKnowledge>.from(selectedRows)) {
      if (item is EnWordEntity) {
        onSetWordRowSelected(item, value: false);
        // 语义取消选中
        item.semantics = item.semantics?.map((e) => e.copyWith(isSelected: false)).toList();
      } else if (item is EnPhraseEntity) {
        onSetPhraseRowSelected(item, value: false);
        item.semantics = item.semantics?.map((e) => e.copyWith(isSelected: false)).toList();
      } else if (item is EnSentenceEntity) {
        onSetSentenceRowSelected(item, value: false);
      } else if (item is EnTextEntity) {
        onSetTextRowSelected(item, value: false);
      }
    }
    safeSetState(() {
      selectedRows.clear();
    });
  }

  // 选中/未选中单词
  void onWordRowSelectChanged(BuildContext context, bool selected, int id, EnWordEntity value) {
    // 如果是单选模式，先清除所有已选项
    if (_tableContext.config.singleSelectionMode && selected) {
      _clearAllSelections();
    }

    if (widget.singleSelectionMode == true && selected) {
      _clearAllSelections();
    }

    print(value);
    // 外部传入word, 判断word是否跟单元格选中的word一致,一致就继续, 不一致提示
    if (widget.word != null && value.content != null && widget.word!.toLowerCase().trim() != value.content!.toLowerCase().trim()) {
      ToastUtils.showManageToast(text: "不是目标单词,请重新选择");
      return;
    }

    if (value.semantics != null && value.semantics!.isNotEmpty && value.semantics!.length > 1) {
      if (selectedRows.contains(value)) {
        // 包含知识点,取消选中
        onSetWordRowSelected(value, value: false);
        // 移除数据
        selectedRows.remove(value);
        // 语义取消选中
        value.semantics = value.semantics?.map((e) => e.copyWith(isSelected: false)).toList();
      } else {
        if(widget.selectMax != null){
          if(widget.selectMax! < selectedRows.length + 1){
            ToastUtils.showManageToast(text: "最多只能选择${widget.selectMax}个");
            return;
          }
        }
        // 选择语义
        onSelectSemantic(context, semantics: value.semantics!, onOkTap: (List<EnEntitySemantics> semantics) {
          value.semantics = semantics;
          onSetWordRowSelected(value, value: true);

          safeSetState(() {
            // 添加数据
            if (selected) {
              selectedRows.add(value);
            }
          });
        });
      }
    } else {
      if (selected) {
        onSetWordRowSelected(value, value: true);
        selectedRows.add(value);
      } else {
         if(widget.selectMax != null){
          if(widget.selectMax! < selectedRows.length + 1){
            ToastUtils.showManageToast(text: "最多只能选择${widget.selectMax}个");
            return;
          }
        }
        onSetWordRowSelected(value, value: false);
        selectedRows.remove(value);
      }
    }
    safeSetState(() {});
  }

  // 选中/未选中短语
  void onPhraseRowSelectChanged(BuildContext context, bool selected, int id, EnPhraseEntity value) {
    print(value.semantics);
    // 如果是单选模式，先清除所有已选项
    if (_tableContext.config.singleSelectionMode && selected) {
      _clearAllSelections();
    }

    if (widget.singleSelectionMode == true && selected) {
      _clearAllSelections();
    }

    // 外部传入word, 判断word是否跟单元格选中的word一致,一致就继续, 不一致提示
    if (widget.word != null && value.content != null && widget.word!.toLowerCase().trim() != value.content!.toLowerCase().trim()) {
      ToastUtils.showManageToast(text: "不是目标单词,请重新选择");
      return;
    }

    if (value.semantics != null && value.semantics!.isNotEmpty && value.semantics!.length > 1) {
      if (selectedRows.contains(value)) {
        // 包含知识点,取消选中
        onSetPhraseRowSelected(value, value: false);
        // 移除数据
        selectedRows.remove(value);
        // 语义取消选中
        value.semantics = value.semantics?.map((e) => e.copyWith(isSelected: false)).toList();
      } else {
        // 选择语义
        onSelectSemantic(context, semantics: value.semantics!, onOkTap: (List<EnEntitySemantics> semantics) {
          value.semantics = semantics;
          onSetPhraseRowSelected(value, value: true);
          safeSetState(() {
            // 添加数据
            if (selected) {
              selectedRows.add(value);
            }
          });
        });
      }
    } else {
      if (selected) {
        onSetPhraseRowSelected(value, value: true);
        selectedRows.add(value);
      } else {
        onSetPhraseRowSelected(value, value: false);
        selectedRows.remove(value);
      }
    }
    safeSetState(() {});
  }

  // 选中/未选中句子
  void onSentenceRowSelectChanged(BuildContext context, bool selected, int id, EnSentenceEntity value) {
    // 如果是单选模式，先清除所有已选项
    if (_tableContext.config.singleSelectionMode) {
      _clearAllSelections();
    }

    if (widget.singleSelectionMode == true && selected) {
      _clearAllSelections();
    }

    // 外部传入word, 判断word是否跟单元格选中的word一致,一致就继续, 不一致提示
    if (widget.word != null && value.content != null && widget.word!.toLowerCase().trim() != value.content!.toLowerCase().trim()) {
      ToastUtils.showManageToast(text: "不是目标句子,请重新选择");
      return;
    }

    if (selected) {
      onSetSentenceRowSelected(value, value: true);
      selectedRows.add(value);
    } else {
      onSetSentenceRowSelected(value, value: false);
      selectedRows.remove(value);
    }

    safeSetState(() {});
  }

  // 选中/未选中文章
  void onTextRowSelectChanged(BuildContext context, bool selected, int id, EnTextEntity value) {
    // 如果是单选模式，先清除所有已选项
    if (_tableContext.config.singleSelectionMode) {
      _clearAllSelections();
    }

    if (widget.singleSelectionMode == true && selected) {
      _clearAllSelections();
    }

    // 外部传入word, 判断word是否跟单元格选中的word一致,一致就继续, 不一致提示
    if (widget.word != null && value.content != null && widget.word!.toLowerCase().trim() != value.content!.toLowerCase().trim()) {
      ToastUtils.showManageToast(text: "不是目标文章,请重新选择");
      return;
    }

    if (selected) {
      onSetTextRowSelected(value, value: true);
      selectedRows.add(value);
    } else {
      onSetTextRowSelected(value, value: false);
      selectedRows.remove(value);
    }

    safeSetState(() {});
  }

  // 选择语义
  void onSelectSemantic(BuildContext context, {required List<EnEntitySemantics> semantics, Function(List<EnEntitySemantics>)? onOkTap}) {
    SelectSemanticManager.show(context: context, semantics: semantics, onOkTap: onOkTap);
  }

  // 设置单词行选中
  void onSetWordRowSelected(Dessert dessert, {required bool value}) {
    if (_wordDataSourceAsync is DessertDataSourceAsync) {
      // 设置选中
      (_wordDataSourceAsync as DessertDataSourceAsync).setRowSelect(dessert, value: value);
    }
  }

  // 设置短语行选中
  void onSetPhraseRowSelected(Dessert dessert, {required bool value}) {
    if (_phraseDataSourceAsync is DessertDataSourceAsync) {
      // 设置选中
      (_phraseDataSourceAsync as DessertDataSourceAsync).setRowSelect(dessert, value: value);
    }
  }

  // 设置句子行选中
  void onSetSentenceRowSelected(Dessert dessert, {required bool value}) {
    if (_sentenceDataSourceAsync is DessertDataSourceAsync) {
      // 设置选中
      (_sentenceDataSourceAsync as DessertDataSourceAsync).setRowSelect(dessert, value: value);
    }
  }

  // 设置文章行选中
  void onSetTextRowSelected(Dessert dessert, {required bool value}) {
    if (_textDataSourceAsync is DessertDataSourceAsync) {
      // 设置选中
      (_textDataSourceAsync as DessertDataSourceAsync).setRowSelect(dessert, value: value);
    }
  }

  void onCloseDialog(BuildContext context) async {
    if (selectedRows.isNotEmpty && widget.showEmptyTip) {
      final bool ask = await AskDialog.show(
        context: context,
        title: "温馨提示",
        content: "您有未保存的知识点内容，确定退出吗?",
        askLevel: AskLevelType.message,
      );
      if (!ask) return;
    }

    Get.back();
  }

  // 新增单词/短语/句子/文章
  void onConfirm(BuildContext context) {
    if (tabCurrentIndex == 0) {
      ManageCreateSingleWordManager.show(context: context, content: widget.word?.trim(), definition: widget.definition?.trim()).then((value) {
        if (value ??false) {
          // 刷新
          _wordDataSourceAsync?.refresh();
        }
      });
    } else if (tabCurrentIndex == 1) {
      ManageCreatePhraseManager.show(
              context: context, content: widget.word?.trim(), definition: widget.definition?.trim(), showSelectKnowledgeAddButton: false)
          .then((value) {
        if (value != null) {
          // 刷新
          _phraseDataSourceAsync?.refresh();
        }
      });
    } else if (tabCurrentIndex == 2) {
      ManageCreateSentenceManager.show(
              context: context, content: widget.word?.trim(), definition: widget.definition?.trim(), showSelectKnowledgeAddButton: false)
          .then((value) {
        if (value != null) {
          // 刷新
          _sentenceDataSourceAsync?.refresh();
        }
      });
    } else if (tabCurrentIndex == 3) {
      ManageCreateTextManager.show(context: context, showSelectKnowledgeAddButton: false).then((value) {
        if (value != null) {
          // 刷新
          _textDataSourceAsync?.refresh();
        }
      });
    }
  }

  /// 更新当前知识类型
  void _updateCurrentNewKnowledgeType() {
    switch (tabCurrentIndex) {
      case 0:
        _tableContext.currentNewKnowledgeType = NewKnowledgeType.WORD;
        break;
      case 1:
        _tableContext.currentNewKnowledgeType = NewKnowledgeType.PHRASE;
        break;
      case 2:
        _tableContext.currentNewKnowledgeType = NewKnowledgeType.SENTENCE;
        break;
      case 3:
        _tableContext.currentNewKnowledgeType = NewKnowledgeType.ARTICLE;
        break;
    }
  }

  @override
  void dispose() {
    tabController?.dispose();
    // 清理资源
    _tableContext.wordList.clear();
    _tableContext.phraseList.clear();
    _tableContext.sentenceList.clear();
    _tableContext.articleList.clear();
    knowledgeController.dispose();
    fullKnowledgeController.dispose();
    super.dispose();
  }
}
