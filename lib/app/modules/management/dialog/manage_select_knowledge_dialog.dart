import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:quiz_play/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../generated/assets.dart';
import '../../../../utils/utils.dart';
import 'package:langwise/app/modules/management/common/manage_quiz_public_widget.dart';
import '../common/manage_title_input_widget.dart';

/// 选择知识点和额外知识点
class ManageSelectKnowledgeDialog {
  static Future<List<ManageUnitKnowledgeEntity>?> show({
    required BuildContext context,
    required int? unitId,
    List<ManageUnitKnowledgeEntity>? initKnowledges,
    List<ManageUnitKnowledgeEntity>? unKnowledgeList,
    List<String?>? contentScope,
    String? language,

    /// 题目模版类型
    String? exerciseType,
    bool knowledgeSingle = false,

    /// 多选情况下最大选择知识点数量
    int knowledgeMaxSelect = 4,

    /// 多选情况下最小选择知识点数量
    int knowledgeMinSelect = 1,
    bool showHaveKnowledge = true,
    String title = "选择已有知识点",
  }) async {
    return await showCupertinoDialog<List<ManageUnitKnowledgeEntity>?>(
      context: context,
      builder: (context) {
        return ManageSelectKnowledgeDialogWidget(
          unitId: unitId,
          initKnowledges: initKnowledges ?? [],
          unKnowledgeList: unKnowledgeList ?? [],
          contentScope: contentScope,
          knowledgeSingle: knowledgeSingle,
          knowledgeMinSelect: knowledgeMinSelect,
          knowledgeMaxSelect: knowledgeMaxSelect,
          language: language,
          showHaveKnowledge: showHaveKnowledge,
          title: title,
          exerciseType: exerciseType,
        );
      },
    );
  }
}

class ManageSelectKnowledgeDialogWidget extends StatefulWidget {
  final int? unitId;
  final List<ManageUnitKnowledgeEntity> initKnowledges;
  final List<ManageUnitKnowledgeEntity> unKnowledgeList;
  final List<String?>? contentScope;
  final bool knowledgeSingle;
  final String? language;

  /// 多选情况下最大选择知识点数量
  final int knowledgeMaxSelect;

  /// 多选情况下最小选择知识点数量
  final int knowledgeMinSelect;
  final bool showHaveKnowledge;
  final String title;
  final String? exerciseType;

  const ManageSelectKnowledgeDialogWidget({
    super.key,
    required this.unitId,
    required this.initKnowledges,
    required this.unKnowledgeList,
    this.language,
    this.contentScope,
    required this.knowledgeSingle,
    required this.knowledgeMaxSelect,
    required this.knowledgeMinSelect,
    this.showHaveKnowledge = true,
    required this.title,
    required this.exerciseType,
  });

  @override
  State<ManageSelectKnowledgeDialogWidget> createState() => _ManageSelectKnowledgeDialogWidgetState();
}

class _ManageSelectKnowledgeDialogWidgetState extends State<ManageSelectKnowledgeDialogWidget>
    with TickerProviderStateMixin {
  final GlobalKey dialogKey = GlobalKey();

  late final TabController _tabController;
  int tabCurrentIndex = 0;

  List<String> tabBarNames = ["单词", "短语", "句子", "文章"];

  final ScrollController knowledgeScrollController = ScrollController();
  bool loadFlag = true;
  int knowledgeOffset = 0;
  int knowledgeCount = 0;
  List<ManageUnitKnowledgeEntity> selectKnowledgeList = [];
  List<_SelectKnowledgeSelectModel> knowledgeList = <_SelectKnowledgeSelectModel>[];
  List<_SelectKnowledgeSelectModel> showKnowledgeList = <_SelectKnowledgeSelectModel>[];
  bool knowledgeEnTextSelected = false;
  final TextEditingController searchKnowledginput = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectKnowledgeList = widget.initKnowledges.toList();
    if (widget.showHaveKnowledge && widget.unitId != null) {
      initKnowledgeScroll();
      getKnowledgeList();
    }

    _tabController = TabController(length: tabBarNames.length, vsync: this);
    _tabController.addListener(() {
      tabCurrentIndex = _tabController.index;
      if (mounted) setState(() {});
    });
  }

  void initKnowledgeScroll() {
    knowledgeScrollController.addListener(() {
      if (knowledgeScrollController.position.pixels >= knowledgeScrollController.position.maxScrollExtent - 100 &&
          !knowledgeScrollController.position.outOfRange) {
        if (knowledgeList.length < knowledgeCount && loadFlag) {
          loadFlag = false;
          knowledgeOffset += 1000;
          getKnowledgeList();
        }
      }
    });
  }

  /// 获取知识点列表
  Future<void> getKnowledgeList() async {
    Map<String, dynamic> reqData = {
      "order": "order",
      "display": 1,
      "offset": knowledgeOffset,
      "limit": 1000,
    };
    ListResponseEntity<ManageUnitKnowledgeEntity>? res =
        await ManageSelectQuziKnowledge.getKnowledgeList(widget.unitId!, reqData);
    if (res == null || res.datas == null) {
      loadFlag = true;
      return;
    }
    knowledgeCount = res.count ?? 0;
    for (int i = 0; i < res.datas!.length; i++) {
      bool select = false;
      for (int j = 0; j < selectKnowledgeList.length; j++) {
        if (selectKnowledgeList[j].uid == res.datas![i].uid &&
            selectKnowledgeList[j].content == res.datas![i].content &&
            selectKnowledgeList[j].contentType == res.datas![i].contentType) {
          select = true;
          break;
        }
      }

      knowledgeList.add(_SelectKnowledgeSelectModel(
        data: res.datas![i],
        select: select,
      ));
    }

    showKnowledgeList = knowledgeList.toList();

    loadFlag = true;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    knowledgeScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void searchKnowledg(){
    showKnowledgeList.clear();
    if(searchKnowledginput.text.isEmpty){
      showKnowledgeList = knowledgeList.toList();
      if(mounted) setState(() {});
      return;
    }
    String text = searchKnowledginput.text.toLowerCase();
    for(int i = 0; i < knowledgeList.length; i++){
      String content = (knowledgeList[i].data.content??"").toLowerCase();
      String definition = (knowledgeList[i].data.definition??"").toLowerCase();
      if(content.contains(text) || definition.contains(text)){
        showKnowledgeList.add(_SelectKnowledgeSelectModel(
          select: knowledgeList[i].select,
          data: ManageUnitKnowledgeEntity.fromJson(knowledgeList[i].data.toJson()),
        ));
      }
    }
    if(mounted) setState(() {});
  }

  /// 判断知识点是否可以点击
  bool isKnowledgeFore(ManageUnitKnowledgeEntity data) {
    if (data.semanticId == null && !data.isEnText) return false; //语义id为null

    // 题目支持的知识点类型(单词 短语 句子) 判断题目是否支持该知识点
    List<String?> contentScope = widget.contentScope ?? [];
    contentScope.removeWhere((e) => e == null);
    if (data.contentType != null) {
      bool type = contentScope.contains(data.contentType);
      if (!type) return false; //题目模版不支持该知识点类型
    }
    // 判断unKnowledgeList 禁用的知识点
    for (int i = 0; i < widget.unKnowledgeList.length; i++) {
      if (widget.unKnowledgeList[i].uid == data.uid &&
          widget.unKnowledgeList[i].content == data.content &&
          widget.unKnowledgeList[i].contentType == data.contentType) {
        return false;
      }
    }
    return true;
  }

  void selectKnowledge(int index) {
    if (widget.knowledgeSingle) {
      for (int i = 0; i < showKnowledgeList.length; i++) {
        showKnowledgeList[i].select = false;
      }
      selectKnowledgeList.clear();
      if (mounted) setState(() {});
    }

    if (knowledgeEnTextSelected) {
      for (int i = 0; i < showKnowledgeList.length; i++) {
        if (!showKnowledgeList[i].select) continue;
        showKnowledgeList[i].select = false;
      }
      selectKnowledgeList.clear();
      knowledgeEnTextSelected = false;
      if (mounted) setState(() {});
    }

    if (getKnowledgeTextSingle(showKnowledgeList[index].data)) {
      for (int i = 0; i < showKnowledgeList.length; i++) {
        if (!showKnowledgeList[i].select) continue;
        showKnowledgeList[i].select = false;
      }
      selectKnowledgeList.clear();
      knowledgeEnTextSelected = true;
      if (mounted) setState(() {});
    }

    if (showKnowledgeList[index].select) {
      showKnowledgeList[index].select = false;
      for (int i = 0; i < selectKnowledgeList.length; i++) {
        ManageUnitKnowledgeEntity item = selectKnowledgeList[i];
        if (item.uid == showKnowledgeList[index].data.uid &&
            item.content == showKnowledgeList[index].data.content &&
            item.contentType == showKnowledgeList[index].data.contentType) {
          selectKnowledgeList.removeAt(i);
        }
      }
    } else {
      if (selectKnowledgeList.length >= widget.knowledgeMaxSelect) {
        ToastUtils.showManageToast(text: "最多可选择${widget.knowledgeMaxSelect}个知识点");
        return;
      }
      showKnowledgeList[index].select = true;
      selectKnowledgeList.add(showKnowledgeList[index].data);
    }
    if (mounted) setState(() {});
  }

  /// 判断知识点是TEXT时是否是单选
  bool getKnowledgeTextSingle(ManageUnitKnowledgeEntity data) {
    if (widget.exerciseType == ExerciseType.CLOZE_TEST) {
      return data.isEnSentence || data.isEnText;
    }
    return data.isEnText;
  }

  void syncSelect(ManageUnitKnowledgeEntity data, bool value) {
    if (widget.knowledgeSingle) {
      for (int i = 0; i < showKnowledgeList.length; i++) {
        showKnowledgeList[i].select = false;
      }
      selectKnowledgeList.clear();
      if (mounted) setState(() {});
    } else {
      for (int i = 0; i < showKnowledgeList.length; i++) {
        ManageUnitKnowledgeEntity item = showKnowledgeList[i].data;
        if (item.uid == data.uid && item.content == data.content && item.contentType == data.contentType) {
          showKnowledgeList[i].select = value;
        }
      }
    }

    if (getKnowledgeTextSingle(data)) {
      for (int i = 0; i < showKnowledgeList.length; i++) {
        showKnowledgeList[i].select = false;
      }
      selectKnowledgeList.clear();
      if (mounted) setState(() {});
    } else {
      for (int i = 0; i < selectKnowledgeList.length; i++) {
        if (getKnowledgeTextSingle(selectKnowledgeList[i])) {
          selectKnowledgeList.removeAt(i);
        }
      }
      if (mounted) setState(() {});
    }

    if (value) {
      for (int i = 0; i < selectKnowledgeList.length; i++) {
        ManageUnitKnowledgeEntity item = selectKnowledgeList[i];
        if (item.uid == data.uid && item.content == data.content && item.contentType == data.contentType) {
          break;
        }
      }
      selectKnowledgeList.add(data);
      if (mounted) setState(() {});
    } else {
      for (int i = 0; i < selectKnowledgeList.length; i++) {
        ManageUnitKnowledgeEntity item = selectKnowledgeList[i];
        if (item.uid == data.uid && item.content == data.content && item.contentType == data.contentType) {
          selectKnowledgeList.removeAt(i);
        }
      }
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildKnowledgeItem(int index, _SelectKnowledgeSelectModel data) {
      bool fore = isKnowledgeFore(data.data);
      return ManagePublicKnowledeRowItemWidget(
        onTap: () => selectKnowledge(index),
        isSingle: widget.knowledgeSingle || getKnowledgeTextSingle(data.data),
        selected: data.select,
        isFore: fore,
        content: data.data.isEnText ? data.data.definition : data.data.content,
        definition: data.data.isEnText ? data.data.content : data.data.definition,
        imageUrl: data.data.imageUrl,
        language: widget.language,
        difficulty: data.data.difficulty?.min,
        audioUrl: data.data.audioUrl,
      );
    }

    Widget buildTabBarWidget() {
      return Container(
        width: 1080.wMin,
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: TabBar(
          controller: _tabController,
          indicatorPadding: EdgeInsets.only(bottom: 5.wMin),
          indicator: UnderlineTabIndicator(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(width: 3.wMin, color: const Color(0xff2388FF)),
          ),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerHeight: 0,
          labelPadding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 10.wMin),
          labelStyle: TextStyle(
            fontSize: 18.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 18.wMin,
            color: const Color(0xffACB4C0),
            fontWeight: FontWeight.w500,
          ),
          tabs: List.generate(tabBarNames.length, (index) {
            return Text(tabBarNames[index]);
          }),
        ),
      );
    }

    return DialogBoxWidget(
      title: widget.title,
      width: 1080.wMin,
      onCancel: () => Get.back(),
      define: widget.knowledgeSingle ? "确认" : "添加${selectKnowledgeList.length}个知识点",
      onDefine: () {
        if (!widget.knowledgeSingle) {
          bool isEnText = false;
          if (selectKnowledgeList.length == 1 && getKnowledgeTextSingle(selectKnowledgeList[0])) {
            isEnText = true;
          }
          if (selectKnowledgeList.length < widget.knowledgeMinSelect && !isEnText) {
            ToastUtils.showManageToast(text: "请至少选择${widget.knowledgeMinSelect}个知识点", containerKey: dialogKey);
            return;
          }
        } else {
          if (selectKnowledgeList.isEmpty) {
            ToastUtils.showManageToast(text: "请选择知识点", containerKey: dialogKey);
            return;
          }
        }
        Get.back(result: selectKnowledgeList);
      },
      subTitle: ManageTitleInputWidget(
        height: 40.wMin,
        width: 250.wMin,
        hintText: "搜索知识点",
        controller: searchKnowledginput,
        onSubmitted: (text) {
          searchKnowledg();
        },
      ),
      child: SizedBox(
        key: dialogKey,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: widget.showHaveKnowledge,
              child: Container(
                height: 290.wMin,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                margin: EdgeInsets.only(bottom: 6.wMin),
                child: ListView.separated(
                  padding: EdgeInsets.only(bottom: 10.wMin),
                  itemCount: showKnowledgeList.length,
                  controller: knowledgeScrollController,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => SizedBox(width: 24.wMin),
                  itemBuilder: (context, index) {
                    return buildKnowledgeItem(index, showKnowledgeList[index]);
                  },
                ),
              ),
            ),
            Visibility(
              visible: widget.showHaveKnowledge,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                margin: EdgeInsets.only(bottom: 6.wMin),
                child: Text(
                  "添加额外知识点",
                  style: TextStyle(
                    fontSize: 22.wMin,
                    color: const Color(0xffEBEEF3),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Stack(
              children: [
                SizedBox(
                  height: widget.showHaveKnowledge ? 500.wMin : 700.wMin,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SelectKnowledgeTabViewEnWordWidget(
                        knowledgeSingle: widget.knowledgeSingle,
                        selectKnowledgeList: selectKnowledgeList,
                        unKnowledgeList: widget.unKnowledgeList,
                        contentScope: widget.contentScope,
                        knowledgeMinSelect: widget.knowledgeMinSelect,
                        knowledgeMaxSelect: widget.knowledgeMaxSelect,
                        language: widget.language,
                        onSelect: (ManageUnitKnowledgeEntity data, bool value) {
                          syncSelect(data, value);
                        },
                      ),
                      SelectKnowledgeTabViewEnPhraseWidget(
                        knowledgeSingle: widget.knowledgeSingle,
                        selectKnowledgeList: selectKnowledgeList,
                        unKnowledgeList: widget.unKnowledgeList,
                        contentScope: widget.contentScope,
                        knowledgeMinSelect: widget.knowledgeMinSelect,
                        knowledgeMaxSelect: widget.knowledgeMaxSelect,
                        language: widget.language,
                        onSelect: (ManageUnitKnowledgeEntity data, bool value) {
                          syncSelect(data, value);
                        },
                      ),
                      SelectKnowledgeTabViewEnSentenceWidget(
                        knowledgeSingle: widget.knowledgeSingle,
                        selectKnowledgeList: selectKnowledgeList,
                        unKnowledgeList: widget.unKnowledgeList,
                        contentScope: widget.contentScope,
                        knowledgeMinSelect: widget.knowledgeMinSelect,
                        knowledgeMaxSelect: widget.knowledgeMaxSelect,
                        language: widget.language,
                        onSelect: (ManageUnitKnowledgeEntity data, bool value) {
                          syncSelect(data, value);
                        },
                      ),
                      SelectKnowledgeTabViewEnTextWidget(
                        knowledgeSingle: true,
                        selectKnowledgeList: selectKnowledgeList,
                        unKnowledgeList: widget.unKnowledgeList,
                        contentScope: widget.contentScope,
                        knowledgeMinSelect: widget.knowledgeMinSelect,
                        knowledgeMaxSelect: widget.knowledgeMaxSelect,
                        language: widget.language,
                        onSelect: (ManageUnitKnowledgeEntity data, bool value) {
                          knowledgeEnTextSelected = getKnowledgeTextSingle(data);
                          syncSelect(data, value);
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 74.wMin,
                  child: buildTabBarWidget(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SelectKnowledgeTabViewEnTextWidget extends StatefulWidget {
  final bool knowledgeSingle;
  final List<ManageUnitKnowledgeEntity>? selectKnowledgeList;
  final void Function(ManageUnitKnowledgeEntity data, bool value)? onSelect;
  final List<String?>? contentScope;
  final String? language;

  /// 多选情况下最大选择知识点数量
  final int knowledgeMaxSelect;

  /// 多选情况下最小选择知识点数量
  final int knowledgeMinSelect;
  final List<ManageUnitKnowledgeEntity> unKnowledgeList;

  const SelectKnowledgeTabViewEnTextWidget({
    super.key,
    this.knowledgeSingle = false,
    this.onSelect,
    this.selectKnowledgeList,
    required this.unKnowledgeList,
    this.contentScope,
    this.knowledgeMaxSelect = 4,
    this.knowledgeMinSelect = 1,
    this.language,
  });

  @override
  State<SelectKnowledgeTabViewEnTextWidget> createState() => _SelectKnowledgeTabViewEnTextWidgetState();
}

class _SelectKnowledgeTabViewEnTextWidgetState extends State<SelectKnowledgeTabViewEnTextWidget>
    with AutomaticKeepAliveClientMixin {
  bool isSelectAll = false;
  final ScrollController knowledgeScrollController = ScrollController();
  bool loadFlag = true;
  int knowledgeOffset = 0;
  int knowledgeCount = 0;
  String searchText = "";

  List<_SelectKnowledgeModel<EnTextEntity>> dataList = [];

  @override
  void initState() {
    super.initState();
    getEnTextKnowledgeList();
    initKnowledgeScroll();
  }

  @override
  void didUpdateWidget(covariant SelectKnowledgeTabViewEnTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncSelect();
  }

  /// 同步选择
  void syncSelect() {
    List<ManageUnitKnowledgeEntity> selectData = widget.selectKnowledgeList ?? [];
    for (int i = 0; i < dataList.length; i++) {
      bool select = false;
      for (int j = 0; j < selectData.length; j++) {
        if (selectData[j].uid == dataList[i].data?.uid &&
            selectData[j].content == dataList[i].data?.content &&
            selectData[j].contentType == dataList[i].data?.contentType) {
          select = true;
          break;
        }
      }
      dataList[i].selected = select;
    }
  }

  void initKnowledgeScroll() {
    knowledgeScrollController.addListener(() {
      if (knowledgeScrollController.position.pixels >= knowledgeScrollController.position.maxScrollExtent - 100 &&
          !knowledgeScrollController.position.outOfRange) {
        if (dataList.length < knowledgeCount && loadFlag) {
          loadFlag = false;
          knowledgeOffset += 100;
          getEnTextKnowledgeList();
        }
      }
    });
  }

  Future<void> getEnTextKnowledgeList() async {
    Map<String, dynamic> parameters = {
      "offset": knowledgeOffset,
      "limit": 100,
    };
    Map<String, dynamic> data = {
      "content": searchText,
    };
    ListResponseEntity<EnTextEntity>? res =
        await ManageSelectQuziKnowledge.getEnTextKnowledgeList(parameters: parameters, data: data);
    if (res == null) return;
    knowledgeCount = res.count ?? 0;
    List<EnTextEntity> datas = res.datas ?? [];
    List<_SelectKnowledgeModel<EnTextEntity>> list = [];
    for (var element in datas) {
      bool select = false;
      if (widget.selectKnowledgeList != null) {
        for (int i = 0; i < widget.selectKnowledgeList!.length; i++) {
          if (element.uid == widget.selectKnowledgeList![i].uid &&
              element.content == widget.selectKnowledgeList![i].content &&
              element.contentType == widget.selectKnowledgeList![i].contentType) {
            select = true;
          }
        }
      }

      list.add(_SelectKnowledgeModel(
        title: element.title,
        knowledge: element.content,
        selected: select,
        fore: isKnowledgeFore(element),
        data: element,
        minDifficulty: element.difficulty,
        language: widget.language,
        difficultyTitle: "难度等级",
      ));
    }
    dataList.addAll(list);
    loadFlag = true;
    if (mounted) setState(() {});
  }

  /// 判断知识点是否可以点击
  bool isKnowledgeFore(EnTextEntity data) {
    // 题目支持的知识点类型(单词 短语 句子) 判断题目是否支持该知识点
    List<String?> contentScope = widget.contentScope ?? [];
    contentScope.removeWhere((e) => e == null);
    if (data.contentType != null) {
      bool type = contentScope.contains(data.contentType);
      if (!type) return false; //题目模版不支持该知识点类型
    }
    // 判断unKnowledgeList 禁用的知识点
    for (int i = 0; i < widget.unKnowledgeList.length; i++) {
      if (widget.unKnowledgeList[i].uid == data.uid &&
          widget.unKnowledgeList[i].content == data.content &&
          widget.unKnowledgeList[i].contentType == data.contentType) {
        return false;
      }
    }
    return true;
  }

  /// 判断知识点是TEXT时是否是单选
  bool getKnowledgeTextSingle(EnTextEntity data) {
    return true;
  }

  Future<void> selectItem(int index) async {
    if (!dataList[index].selected) {
      if ((widget.selectKnowledgeList ?? []).length >= widget.knowledgeMaxSelect) {
        ToastUtils.showManageToast(text: "最多可选择${widget.knowledgeMaxSelect}个知识点");
        return;
      }
    }

    if (widget.knowledgeSingle || getKnowledgeTextSingle(dataList[index].data!)) {
      if (dataList[index].selected) return;
      for (var element in dataList) {
        element.selected = false;
      }
    }

    dataList[index].selected = !dataList[index].selected;
    if (dataList[index].data != null) {
      ManageUnitKnowledgeEntity know = ManageUnitKnowledgeEntity(
        uid: dataList[index].data!.uid,
        contentId: dataList[index].data!.uid,
        contentType: dataList[index].data!.contentType,
        content: dataList[index].data!.content,
        definition: dataList[index].data!.definition,
        difficulty: dataList[index].data!.difficulty,
      );
      widget.onSelect?.call(know, dataList[index].selected);
    }
    if (mounted) setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SelectKnowledgeTabViewTableWidget(
      hintText: "文章",
      title: _SelectKnowledgeModel(
        title: "标题",
        knowledge: "知识点",
        difficultyTitle: "难度等级",
      ),
      knowledgeSingle: widget.knowledgeSingle,
      scrollController: knowledgeScrollController,
      datas: dataList,
      onTap: (index) {
        selectItem(index);
      },
      onSubmitted: (text) async {
        searchText = text;
        knowledgeOffset = 0;
        dataList.clear();
        try {
          ToastUtils.showLoading();
          await getEnTextKnowledgeList();
          if (mounted) setState(() {});
        } finally {
          ToastUtils.hideLoading();
        }
      },
    );
  }
}

class SelectKnowledgeTabViewEnPhraseWidget extends StatefulWidget {
  final bool knowledgeSingle;
  final List<ManageUnitKnowledgeEntity>? selectKnowledgeList;
  final void Function(ManageUnitKnowledgeEntity data, bool value)? onSelect;
  final List<String?>? contentScope;
  final String? language;

  /// 多选情况下最大选择知识点数量
  final int knowledgeMaxSelect;

  /// 多选情况下最小选择知识点数量
  final int knowledgeMinSelect;
  final List<ManageUnitKnowledgeEntity> unKnowledgeList;

  const SelectKnowledgeTabViewEnPhraseWidget({
    super.key,
    this.knowledgeSingle = false,
    this.onSelect,
    this.selectKnowledgeList,
    required this.unKnowledgeList,
    this.contentScope,
    this.knowledgeMaxSelect = 4,
    this.knowledgeMinSelect = 1,
    this.language,
  });

  @override
  State<SelectKnowledgeTabViewEnPhraseWidget> createState() => _SelectKnowledgeTabViewEnPhraseWidgetState();
}

class _SelectKnowledgeTabViewEnPhraseWidgetState extends State<SelectKnowledgeTabViewEnPhraseWidget>
    with AutomaticKeepAliveClientMixin {
  bool isSelectAll = false;
  final ScrollController knowledgeScrollController = ScrollController();
  bool loadFlag = true;
  int knowledgeOffset = 0;
  int knowledgeCount = 0;
  String searchText = "";

  List<_SelectKnowledgeModel<EnPhraseEntity>> dataList = [];

  @override
  void initState() {
    super.initState();
    getEnPhraseKnowledgeList();
    initKnowledgeScroll();
  }

  @override
  void didUpdateWidget(covariant SelectKnowledgeTabViewEnPhraseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncSelect();
  }

  /// 同步选择
  void syncSelect() {
    List<ManageUnitKnowledgeEntity> selectData = widget.selectKnowledgeList ?? [];
    for (int i = 0; i < dataList.length; i++) {
      bool select = false;
      for (int j = 0; j < selectData.length; j++) {
        if (selectData[j].uid == dataList[i].data?.uid &&
            selectData[j].content == dataList[i].data?.content &&
            selectData[j].contentType == dataList[i].data?.contentType) {
          select = true;
          break;
        }
      }
      dataList[i].selected = select;
    }
  }

  void initKnowledgeScroll() {
    knowledgeScrollController.addListener(() {
      if (knowledgeScrollController.position.pixels >= knowledgeScrollController.position.maxScrollExtent - 100 &&
          !knowledgeScrollController.position.outOfRange) {
        if (dataList.length < knowledgeCount && loadFlag) {
          loadFlag = false;
          knowledgeOffset += 100;
          getEnPhraseKnowledgeList();
        }
      }
    });
  }

  Future<void> getEnPhraseKnowledgeList() async {
    Map<String, dynamic> parameters = {
      "offset": knowledgeOffset,
      "limit": 100,
    };
    Map<String, dynamic> data = {
      "content": searchText,
    };
    ListResponseEntity<EnPhraseEntity>? res =
        await ManageSelectQuziKnowledge.getEnPhraseKnowledgeList(parameters: parameters, data: data);
    if (res == null) return;
    knowledgeCount = res.count ?? 0;
    List<_SelectKnowledgeModel<EnPhraseEntity>> list = [];
    List<EnPhraseEntity> datas = res.datas ?? [];
    for (var element in datas) {
      bool select = false;
      if (widget.selectKnowledgeList != null) {
        for (int i = 0; i < widget.selectKnowledgeList!.length; i++) {
          if (element.uid == widget.selectKnowledgeList![i].uid &&
              element.content == widget.selectKnowledgeList![i].content &&
              element.contentType == widget.selectKnowledgeList![i].contentType) {
            select = true;
          }
        }
      }
      String pos = element.posTitle ?? "";
      list.add(_SelectKnowledgeModel(
        knowledge: element.content,
        partOfSpeech: pos,
        interpretation: element.definition,
        selected: select,
        fore: isKnowledgeFore(element),
        data: element,
        minDifficulty: element.minDifficulty,
        maxDifficulty: element.maxDifficulty,
        language: widget.language,
        difficultyTitle: "",
      ));
    }
    dataList.addAll(list);
    loadFlag = true;
    if (mounted) setState(() {});
  }

  /// 判断知识点是否可以点击
  bool isKnowledgeFore(EnPhraseEntity data) {
    if ((data.semanticIds ?? []).isEmpty) return false; //语义id为null

    // 题目支持的知识点类型(单词 短语 句子) 判断题目是否支持该知识点
    List<String?> contentScope = widget.contentScope ?? [];
    contentScope.removeWhere((e) => e == null);
    if (data.contentType != null) {
      bool type = contentScope.contains(data.contentType);
      if (!type) return false; //题目模版不支持该知识点类型
    }
    // 判断unKnowledgeList 禁用的知识点
    for (int i = 0; i < widget.unKnowledgeList.length; i++) {
      if (widget.unKnowledgeList[i].uid == data.uid &&
          widget.unKnowledgeList[i].content == data.content &&
          widget.unKnowledgeList[i].contentType == data.contentType) {
        return false;
      }
    }
    return true;
  }

  Future<void> selectItem(int index) async {
    if (!dataList[index].selected) {
      if ((widget.selectKnowledgeList ?? []).length >= widget.knowledgeMaxSelect) {
        ToastUtils.showManageToast(text: "最多可选择${widget.knowledgeMaxSelect}个知识点");
        return;
      }
    }

    if (widget.knowledgeSingle) {
      if (dataList[index].selected) return;
      for (var element in dataList) {
        element.selected = false;
      }
    }

    if ((dataList[index].data?.semantics ?? []).isEmpty) return;
    List<EnEntitySemantics> semantics = dataList[index].data?.semantics ?? [];
    if (semantics.length == 1) {
      dataList[index].selected = !dataList[index].selected;
      if (dataList[index].data != null) {
        String description = semantics.first.description ?? "";
        List<LanguageText> descriptions = semantics.first.descriptions ?? [];
        for (var e in descriptions) {
          if (e.lang == "zh") {
            description = e.text ?? "";
          }
        }
        ManageUnitKnowledgeEntity know = ManageUnitKnowledgeEntity(
          uid: dataList[index].data!.uid,
          contentId: dataList[index].data!.uid,
          contentType: dataList[index].data!.contentType,
          semanticId: semantics.first.uid,
          content: dataList[index].data!.content,
          definition: description,
          imageUrl: semantics.first.imageUrl,
          audioUrl: dataList[index].data!.audioUrl,
        );
        widget.onSelect?.call(know, dataList[index].selected);
      }
      if (mounted) setState(() {});
      return;
    }

    //多个语义 要选择语义
    if (dataList[index].selected) {
      dataList[index].selected = false;
      if (mounted) setState(() {});
      if (dataList[index].selectDatas != null) {
        for (int i = 0; i < dataList[index].selectDatas!.length; i++) {
          widget.onSelect?.call(dataList[index].selectDatas![i], false);
        }
      }
      return;
    }

    List<EnEntitySemantics> datas = [];
    for (int i = 0; i < semantics.length; i++) {
      datas.add(semantics[i]);
    }
    List<EnEntitySemantics>? resDatas = await SelectSemanticsDialog.show(
      context: context,
      knowledgeSingle: widget.knowledgeSingle,
      datas: datas,
      knowledgeMaxSelect: widget.knowledgeMaxSelect,
      knowledgeSelectCount: widget.selectKnowledgeList?.length ?? 0,
      language: widget.language,
    );
    if (resDatas == null) return;
    dataList[index].selectDatas = [];
    dataList[index].selected = true;
    for (int i = 0; i < resDatas.length; i++) {
      EnEntitySemantics item = resDatas[i];
      String description = item.description ?? "";
      List<LanguageText> descriptions = item.descriptions ?? [];
      for (var e in descriptions) {
        if (e.lang == "zh") {
          description = e.text ?? "";
        }
      }

      ManageUnitKnowledgeEntity know = ManageUnitKnowledgeEntity(
        uid: dataList[index].data!.uid,
        contentId: dataList[index].data!.uid,
        contentType: dataList[index].data!.contentType,
        semanticId: item.uid,
        content: dataList[index].data!.content,
        definition: description,
        imageUrl: item.imageUrl,
        audioUrl: dataList[index].data!.audioUrl,
      );
      widget.onSelect?.call(know, dataList[index].selected);
      dataList[index].selectDatas?.add(know);
    }
    if (mounted) setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SelectKnowledgeTabViewTableWidget(
      hintText: "短语",
      title: _SelectKnowledgeModel(
        knowledge: "知识点",
        partOfSpeech: "词性",
        interpretation: "释义",
        difficultyTitle: "难度等级",
      ),
      knowledgeSingle: widget.knowledgeSingle,
      scrollController: knowledgeScrollController,
      datas: dataList,
      onTap: (index) {
        selectItem(index);
      },
      onSubmitted: (text) async {
        searchText = text;
        knowledgeOffset = 0;
        dataList.clear();
        try {
          ToastUtils.showLoading();
          await getEnPhraseKnowledgeList();
          if (mounted) setState(() {});
        } finally {
          ToastUtils.hideLoading();
        }
      },
    );
  }
}

class SelectKnowledgeTabViewEnWordWidget extends StatefulWidget {
  final bool knowledgeSingle;
  final void Function(ManageUnitKnowledgeEntity data, bool value)? onSelect;
  final List<ManageUnitKnowledgeEntity>? selectKnowledgeList;
  final List<ManageUnitKnowledgeEntity> unKnowledgeList;
  final List<String?>? contentScope;
  final String? language;

  /// 多选情况下最大选择知识点数量
  final int knowledgeMaxSelect;

  /// 多选情况下最小选择知识点数量
  final int knowledgeMinSelect;

  const SelectKnowledgeTabViewEnWordWidget({
    super.key,
    this.knowledgeSingle = false,
    this.onSelect,
    this.selectKnowledgeList,
    required this.unKnowledgeList,
    this.contentScope,
    this.knowledgeMaxSelect = 4,
    this.knowledgeMinSelect = 1,
    this.language,
  });

  @override
  State<SelectKnowledgeTabViewEnWordWidget> createState() => _SelectKnowledgeTabViewEnWordWidgetState();
}

class _SelectKnowledgeTabViewEnWordWidgetState extends State<SelectKnowledgeTabViewEnWordWidget>
    with AutomaticKeepAliveClientMixin {
  bool isSelectAll = false;
  final ScrollController knowledgeScrollController = ScrollController();
  bool loadFlag = true;
  int knowledgeOffset = 0;
  int knowledgeCount = 0;
  String searchText = "";

  List<_SelectKnowledgeModel<EnWordEntity>> dataList = [];

  @override
  void initState() {
    super.initState();
    getEnWordKnowledgeList();
    initKnowledgeScroll();
  }

  @override
  void didUpdateWidget(covariant SelectKnowledgeTabViewEnWordWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncSelect();
  }

  /// 同步选择
  void syncSelect() {
    List<ManageUnitKnowledgeEntity> selectData = widget.selectKnowledgeList ?? [];
    for (int i = 0; i < dataList.length; i++) {
      bool select = false;
      for (int j = 0; j < selectData.length; j++) {
        if (selectData[j].uid == dataList[i].data?.uid &&
            selectData[j].content == dataList[i].data?.content &&
            selectData[j].contentType == dataList[i].data?.contentType) {
          select = true;
          break;
        }
      }
      dataList[i].selected = select;
    }
  }

  void initKnowledgeScroll() {
    knowledgeScrollController.addListener(() {
      if (knowledgeScrollController.position.pixels >= knowledgeScrollController.position.maxScrollExtent - 100 &&
          !knowledgeScrollController.position.outOfRange) {
        if (dataList.length < knowledgeCount && loadFlag) {
          loadFlag = false;
          knowledgeOffset += 100;
          getEnWordKnowledgeList();
        }
      }
    });
  }

  Future<void> getEnWordKnowledgeList() async {
    Map<String, dynamic> parameters = {
      "offset": knowledgeOffset,
      "limit": 100,
    };
    Map<String, dynamic> data = {
      "content": searchText,
    };
    ListResponseEntity<EnWordEntity>? res =
        await ManageSelectQuziKnowledge.getEnWordKnowledgeList(parameters: parameters, data: data);
    if (res == null) return;
    knowledgeCount = res.count ?? 0;
    List<EnWordEntity> datas = res.datas ?? [];
    List<_SelectKnowledgeModel<EnWordEntity>> list = [];
    for (var element in datas) {
      bool select = false;
      if (widget.selectKnowledgeList != null) {
        for (int i = 0; i < widget.selectKnowledgeList!.length; i++) {
          if (element.uid == widget.selectKnowledgeList![i].uid &&
              element.content == widget.selectKnowledgeList![i].content &&
              element.contentType == widget.selectKnowledgeList![i].contentType) {
            select = true;
          }
        }
      }

      list.add(_SelectKnowledgeModel(
        knowledge: element.content,
        partOfSpeech: element.posTitle,
        interpretation: element.definition,
        selected: select,
        fore: isKnowledgeFore(element),
        data: element,
        minDifficulty: element.minDifficulty,
        maxDifficulty: element.maxDifficulty,
        language: widget.language,
        difficultyTitle: "难度等级",
      ));
    }
    dataList.addAll(list);
    loadFlag = true;
    if (mounted) setState(() {});
  }

  /// 判断知识点是否可以点击
  bool isKnowledgeFore(EnWordEntity data) {
    if ((data.semanticIds ?? []).isEmpty) return false; //语义id为null

    // 题目支持的知识点类型(单词 短语 句子) 判断题目是否支持该知识点
    List<String?> contentScope = widget.contentScope ?? [];
    contentScope.removeWhere((e) => e == null);
    if (data.contentType != null) {
      bool type = contentScope.contains(data.contentType);
      if (!type) return false; //题目模版不支持该知识点类型
    }
    // 判断unKnowledgeList 禁用的知识点
    for (int i = 0; i < widget.unKnowledgeList.length; i++) {
      if (widget.unKnowledgeList[i].uid == data.uid &&
          widget.unKnowledgeList[i].content == data.content &&
          widget.unKnowledgeList[i].contentType == data.contentType) {
        return false;
      }
    }
    return true;
  }

  Future<void> selectItem(int index) async {
    if (!dataList[index].selected) {
      if ((widget.selectKnowledgeList ?? []).length >= widget.knowledgeMaxSelect) {
        ToastUtils.showManageToast(text: "最多可选择${widget.knowledgeMaxSelect}个知识点");
        return;
      }
    }

    if (widget.knowledgeSingle) {
      if (dataList[index].selected) return;
      for (var element in dataList) {
        element.selected = false;
      }
    }

    if ((dataList[index].data?.semantics ?? []).isEmpty) return;
    List<EnEntitySemantics?> semantics = dataList[index].data?.semantics ?? [];
    if (semantics.length == 1) {
      dataList[index].selected = !dataList[index].selected;
      if (dataList[index].data != null) {
        String description = semantics.first?.description ?? "";
        List<LanguageText> descriptions = semantics.first?.descriptions ?? [];
        for (var e in descriptions) {
          if (e.lang == "zh") {
            description = e.text ?? "";
          }
        }
        ManageUnitKnowledgeEntity know = ManageUnitKnowledgeEntity(
          uid: dataList[index].data!.uid,
          contentId: dataList[index].data!.uid,
          contentType: dataList[index].data!.contentType,
          semanticId: semantics.first?.uid,
          content: dataList[index].data!.content,
          definition: description,
          imageUrl: semantics.first?.imageUrl,
          audioUrl: dataList[index].data!.audioUrl,
        );
        widget.onSelect?.call(know, dataList[index].selected);
      }
      if (mounted) setState(() {});
      return;
    }

    //多个语义 要选择语义
    if (dataList[index].selected) {
      dataList[index].selected = false;
      if (mounted) setState(() {});
      if (dataList[index].selectDatas != null) {
        for (int i = 0; i < dataList[index].selectDatas!.length; i++) {
          widget.onSelect?.call(dataList[index].selectDatas![i], false);
        }
      }
      return;
    }

    List<EnEntitySemantics> datas = [];
    for (int i = 0; i < semantics.length; i++) {
      if (semantics[i] == null) continue;
      datas.add(semantics[i]!);
    }
    List<EnEntitySemantics>? resDatas = await SelectSemanticsDialog.show(
      context: context,
      knowledgeSingle: widget.knowledgeSingle,
      datas: datas,
      knowledgeMaxSelect: widget.knowledgeMaxSelect,
      knowledgeSelectCount: widget.selectKnowledgeList?.length ?? 0,
      language: widget.language,
    );
    if (resDatas == null) return;
    dataList[index].selectDatas = [];
    dataList[index].selected = true;
    for (int i = 0; i < resDatas.length; i++) {
      EnEntitySemantics item = resDatas[i];
      String description = item.description ?? "";
      List<LanguageText> descriptions = item.descriptions ?? [];
      for (var e in descriptions) {
        if (e.lang == "zh") {
          description = e.text ?? "";
        }
      }
      ManageUnitKnowledgeEntity know = ManageUnitKnowledgeEntity(
        uid: dataList[index].data!.uid,
        contentId: dataList[index].data!.uid,
        contentType: dataList[index].data!.contentType,
        semanticId: item.uid,
        content: dataList[index].data!.content,
        definition: description,
        imageUrl: item.imageUrl,
        audioUrl: dataList[index].data!.audioUrl,
      );
      widget.onSelect?.call(know, dataList[index].selected);
      dataList[index].selectDatas?.add(know);
    }
    if (mounted) setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SelectKnowledgeTabViewTableWidget(
      hintText: "单词",
      title: _SelectKnowledgeModel(
        knowledge: "知识点",
        partOfSpeech: "词性",
        interpretation: "释义",
        difficultyTitle: "难度等级",
      ),
      knowledgeSingle: widget.knowledgeSingle,
      scrollController: knowledgeScrollController,
      datas: dataList,
      onTap: (index) {
        selectItem(index);
      },
      onSubmitted: (text) async {
        searchText = text;
        knowledgeOffset = 0;
        dataList.clear();
        try {
          ToastUtils.showLoading();
          await getEnWordKnowledgeList();
          if (mounted) setState(() {});
        } finally {
          ToastUtils.hideLoading();
        }
      },
    );
  }
}

class SelectKnowledgeTabViewEnSentenceWidget extends StatefulWidget {
  final bool knowledgeSingle;
  final void Function(ManageUnitKnowledgeEntity data, bool value)? onSelect;
  final List<ManageUnitKnowledgeEntity>? selectKnowledgeList;
  final List<ManageUnitKnowledgeEntity> unKnowledgeList;
  final List<String?>? contentScope;
  final String? language;

  /// 多选情况下最大选择知识点数量
  final int knowledgeMaxSelect;

  /// 多选情况下最小选择知识点数量
  final int knowledgeMinSelect;

  const SelectKnowledgeTabViewEnSentenceWidget({
    super.key,
    this.knowledgeSingle = false,
    this.onSelect,
    this.selectKnowledgeList,
    required this.unKnowledgeList,
    this.contentScope,
    this.knowledgeMaxSelect = 4,
    this.knowledgeMinSelect = 1,
    this.language,
  });

  @override
  State<SelectKnowledgeTabViewEnSentenceWidget> createState() => _SelectKnowledgeTabViewEnSentenceWidgetState();
}

class _SelectKnowledgeTabViewEnSentenceWidgetState extends State<SelectKnowledgeTabViewEnSentenceWidget>
    with AutomaticKeepAliveClientMixin {
  bool isSelectAll = false;
  final ScrollController knowledgeScrollController = ScrollController();
  bool loadFlag = true;
  int knowledgeOffset = 0;
  int knowledgeCount = 0;
  String searchText = "";

  List<_SelectKnowledgeModel<EnSentenceEntity>> dataList = [];

  @override
  void initState() {
    super.initState();
    getEnSentenceKnowledgeList();
    initKnowledgeScroll();
  }

  @override
  void didUpdateWidget(covariant SelectKnowledgeTabViewEnSentenceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncSelect();
  }

  /// 同步选择
  void syncSelect() {
    List<ManageUnitKnowledgeEntity> selectData = widget.selectKnowledgeList ?? [];
    for (int i = 0; i < dataList.length; i++) {
      bool select = false;
      for (int j = 0; j < selectData.length; j++) {
        if (selectData[j].uid == dataList[i].data?.uid &&
            selectData[j].content == dataList[i].data?.content &&
            selectData[j].contentType == dataList[i].data?.contentType) {
          select = true;
          break;
        }
      }
      dataList[i].selected = select;
    }
  }

  void initKnowledgeScroll() {
    knowledgeScrollController.addListener(() {
      if (knowledgeScrollController.position.pixels >= knowledgeScrollController.position.maxScrollExtent - 100 &&
          !knowledgeScrollController.position.outOfRange) {
        if (dataList.length < knowledgeCount && loadFlag) {
          loadFlag = false;
          knowledgeOffset += 100;
          getEnSentenceKnowledgeList();
        }
      }
    });
  }

  Future<void> getEnSentenceKnowledgeList() async {
    Map<String, dynamic> parameters = {
      "offset": knowledgeOffset,
      "limit": 100,
    };
    Map<String, dynamic> data = {
      "content": searchText,
    };
    ListResponseEntity<EnSentenceEntity>? res =
        await ManageSelectQuziKnowledge.getEnSentenceKnowledgeList(parameters: parameters, data: data);
    if (res == null) return;
    knowledgeCount = res.count ?? 0;
    List<EnSentenceEntity> datas = res.datas ?? [];
    List<_SelectKnowledgeModel<EnSentenceEntity>> list = [];
    for (var element in datas) {
      bool select = false;
      if (widget.selectKnowledgeList != null) {
        for (int i = 0; i < widget.selectKnowledgeList!.length; i++) {
          if (element.uid == widget.selectKnowledgeList![i].uid &&
              element.content == widget.selectKnowledgeList![i].content &&
              element.contentType == widget.selectKnowledgeList![i].contentType) {
            select = true;
          }
        }
      }

      list.add(_SelectKnowledgeModel(
        knowledge: element.content,
        // partOfSpeech: element.semantic?.posTitle,
        interpretation: element.definition,
        selected: select,
        fore: isKnowledgeFore(element),
        data: element,
        minDifficulty: element.minDifficulty,
        maxDifficulty: element.maxDifficulty,
        language: widget.language,
        difficultyTitle: "",
      ));
    }
    dataList.addAll(list);
    loadFlag = true;
    if (mounted) setState(() {});
  }

  /// 判断知识点是否可以点击
  bool isKnowledgeFore(EnSentenceEntity data) {
    if (data.semantics == null) return false; //语义id为null

    // 题目支持的知识点类型(单词 短语 句子) 判断题目是否支持该知识点
    List<String?> contentScope = widget.contentScope ?? [];
    contentScope.removeWhere((e) => e == null);
    if (data.contentType != null) {
      bool type = contentScope.contains(data.contentType);
      if (!type) return false; //题目模版不支持该知识点类型
    }
    // 判断unKnowledgeList 禁用的知识点
    for (int i = 0; i < widget.unKnowledgeList.length; i++) {
      if (widget.unKnowledgeList[i].uid == data.uid &&
          widget.unKnowledgeList[i].content == data.content &&
          widget.unKnowledgeList[i].contentType == data.contentType) {
        return false;
      }
    }
    return true;
  }

  Future<void> selectItem(int index) async {
    if (!dataList[index].selected) {
      if ((widget.selectKnowledgeList ?? []).length >= widget.knowledgeMaxSelect) {
        ToastUtils.showManageToast(text: "最多可选择${widget.knowledgeMaxSelect}个知识点");
        return;
      }
    }

    if (widget.knowledgeSingle) {
      if (dataList[index].selected) return;
      for (var element in dataList) {
        element.selected = false;
      }
    }

    if (dataList[index].data?.semantics == null) return;
    EnEntitySemantics? semantic = dataList[index].data?.selectedSemantics;
    if (semantic == null) return;
    dataList[index].selected = !dataList[index].selected;
    if (dataList[index].data != null) {
      String description = semantic.description ?? "";
      List<LanguageText> descriptions = semantic.descriptions ?? [];
      for (var e in descriptions) {
        if (e.lang == "zh") {
          description = e.text ?? "";
        }
      }
      ManageUnitKnowledgeEntity know = ManageUnitKnowledgeEntity(
        uid: dataList[index].data!.uid,
        contentId: dataList[index].data!.uid,
        contentType: dataList[index].data!.contentType,
        semanticId: semantic.uid,
        content: dataList[index].data!.content,
        definition: description,
        audioUrl: dataList[index].data!.audioUrl,
        imageUrl: semantic.imageUrl,
      );
      widget.onSelect?.call(know, dataList[index].selected);
    }
    if (mounted) setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SelectKnowledgeTabViewTableWidget(
      hintText: "句子",
      title: _SelectKnowledgeModel(
        knowledge: "知识点",
        interpretation: "释义",
        difficultyTitle: "难度等级",
      ),
      knowledgeSingle: widget.knowledgeSingle,
      scrollController: knowledgeScrollController,
      datas: dataList,
      onTap: (index) {
        selectItem(index);
      },
      onSubmitted: (text) async {
        searchText = text;
        knowledgeOffset = 0;
        dataList.clear();
        try {
          ToastUtils.showLoading();
          await getEnSentenceKnowledgeList();
          if (mounted) setState(() {});
        } finally {
          ToastUtils.hideLoading();
        }
      },
    );
  }
}

class SelectKnowledgeTabViewTableWidget extends StatelessWidget {
  final bool knowledgeSingle;
  final _SelectKnowledgeModel title;
  final List<_SelectKnowledgeModel> datas;
  final void Function(int index)? onTap;
  final ScrollController? scrollController;
  final String hintText;
  final void Function(String text)? onSubmitted;

  const SelectKnowledgeTabViewTableWidget({
    super.key,
    this.knowledgeSingle = false,
    required this.datas,
    this.onTap,
    this.scrollController,
    this.hintText = "",
    this.onSubmitted,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    String iconUnCheck = "assets/svg/manage/icon_uncheck_box.svg";
    String iconCheck = "assets/svg/manage/icon_check_box.svg";
    if (knowledgeSingle) {
      iconUnCheck = "assets/svg/manage/icon_unradio.svg";
      iconCheck = "assets/svg/manage/icon_radio.svg";
    }

    Widget tabViewRowWidget(_SelectKnowledgeModel data, int index, {bool isTitle = false}) {
      Widget _checkItemWidget() {
        return Container(
          color: Colors.transparent,
          padding: EdgeInsets.all(16.wMin),
          child: SvgPicture.asset(
            data.selected ? iconCheck : iconUnCheck,
            width: 18.wMin,
          ),
        );
      }

      Widget _textWidget(String text) {
        return Container(
          padding: EdgeInsets.all(5.wMin),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18.wMin,
              color: isTitle ? const Color(0xffACB4C0) : const Color(0xffEBEEF3),
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }

      return Opacity(
        opacity: data.fore ? 1 : 0.6,
        child: IgnorePointer(
          ignoring: !data.fore || isTitle,
          child: TapScaleWidget(
            onTap: () => onTap?.call(index),
            sclae: 1,
            child: Container(
              decoration: BoxDecoration(
                color: index.isEven ? const Color.fromRGBO(29, 31, 43, 1) : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    width: 1.wMin,
                    color: const Color(0xff4B5268).withValues(alpha: isTitle ? 1 : 0.4),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // isTitle ? _checkTitleWidget() : _checkItemWidget(),
                  isTitle ? Container(width: 50.wMin) : _checkItemWidget(),
                  Visibility(
                    visible: title.title != null,
                    child: Expanded(
                      flex: 2,
                      child: _textWidget(data.title ?? ""),
                    ),
                  ),
                  Expanded(
                    flex: data.interpretation == null ? 8 : 3,
                    child: _textWidget(data.knowledge ?? ""),
                  ),
                  Visibility(
                    visible: data.partOfSpeech != null,
                    child: Expanded(
                      flex: 3,
                      child: _textWidget(data.partOfSpeech ?? ""),
                    ),
                  ),
                  Visibility(
                    visible: data.interpretation != null,
                    child: Expanded(
                      flex: 4,
                      child: _textWidget(data.interpretation ?? ""),
                    ),
                  ),
                  Visibility(
                    visible: data.difficultyTitle != null,
                    child: Expanded(
                      flex: 1,
                      child: isTitle
                          ? _textWidget(data.difficultyTitle ?? "")
                          : Row(
                              children: [
                                StatusTagDifficultyWidget(
                                  difficulty: data.minDifficulty,
                                  language: data.language,
                                ),
                                Visibility(
                                  visible: data.maxDifficulty != null,
                                  child: Text(
                                    "-",
                                    style: TextStyle(
                                      fontSize: 18.wMin,
                                      color: const Color(0xffEBEEF3),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                StatusTagDifficultyWidget(
                                  difficulty: data.maxDifficulty,
                                  language: data.language,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget buildSearchWidget() {
      return ManageTitleInputWidget(
        hintText: hintText,
        prefixWidget: Container(
          margin: EdgeInsets.only(right: 5.wMin),
          child: SvgPicture.asset(Assets.manageIconSearch, width: 18.wMin),
        ),
        onSubmitted: onSubmitted,
      );
    }

    return Container(
      padding: EdgeInsets.only(top: 10.wMin, left: 24.wMin, right: 24.wMin),
      child: Column(
        children: [
          buildSearchWidget(),
          SizedBox(height: 60.wMin),
          tabViewRowWidget(
            title,
            -1,
            isTitle: true,
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: datas.length,
              itemBuilder: (context, index) {
                return tabViewRowWidget(datas[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectKnowledgeSelectModel {
  ManageUnitKnowledgeEntity data;
  bool select;

  _SelectKnowledgeSelectModel({
    required this.data,
    this.select = false,
  });

}

class _SelectKnowledgeModel<T> {
  bool selected;
  List<ManageUnitKnowledgeEntity>? selectDatas;
  bool fore;
  String? title;
  String? knowledge;
  String? partOfSpeech;
  String? interpretation;
  String? difficultyTitle;
  int? minDifficulty;
  int? maxDifficulty;
  String? language;
  T? data;

  _SelectKnowledgeModel({
    this.title,
    this.knowledge,
    this.partOfSpeech,
    this.interpretation,
    this.selected = false,
    this.fore = true,
    this.difficultyTitle,
    this.minDifficulty,
    this.maxDifficulty,
    this.language,
    this.data,
  });
}
