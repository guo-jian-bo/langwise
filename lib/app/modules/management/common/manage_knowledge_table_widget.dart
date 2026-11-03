



import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/app/modules/management/utils/konwledge_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import 'package:langwise/app/modules/management/common/manage_select_knowledge_table/views/select_semantic_widget.dart';
import 'package:langwise/app/modules/management/models/manage_knowledge_table_model.dart';


class ManageKnowledgeTableController{
  _ManageKnowledgeTableWidgetState? _state;

  /// 设置支持的知识点类型
  void setSupportedTypes(List<ElementsCardType> types) {
    _state?._setSupportedTypes(types);
  }


}

class ManageKnowledgeTableWidget extends StatefulWidget {
  final String langage;
  final EdgeInsetsGeometry padding;
  /// 是否是单选
  final bool isSingleSelect;
  /// 最大选择数量
  final int? maxSelectCount;
  /// 表格控制器
  final ManageKnowledgeTableController? controller;
  /// 选择的知识点
  final List<ManageKnowledgeTableModel>? selectedKnowledge;
  /// 选择回调
  final void Function(List<ManageKnowledgeTableModel> selectedKnowledgeList)? onSelected;


  /// 单词短语句子文章知识点列表
  const ManageKnowledgeTableWidget({
    super.key, 
    this.padding = EdgeInsets.zero,
    this.isSingleSelect = false,
    this.maxSelectCount,
    this.controller,
    this.selectedKnowledge,
    this.onSelected,
    this.langage = "en",
  });

  @override
  State<ManageKnowledgeTableWidget> createState() => _ManageKnowledgeTableWidgetState();
}

class _ManageKnowledgeTableWidgetState extends State<ManageKnowledgeTableWidget> {

  /// 支持的知识点类型
  List<ElementsCardType> _supportedTypes = [
    ElementsCardType.word,
    ElementsCardType.phrase,
    ElementsCardType.sentence,
    ElementsCardType.text,
  ];

  final ScrollController _scrollController = ScrollController();

  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _knowledgeController = TextEditingController();
  final TextEditingController _knowledgeExactController = TextEditingController();
  final TextEditingController _phoneticController = TextEditingController();

  int knowledgeOffset = 0;
  int knowledgeLimit = 40;
  int knowledgeCount = 0;
  bool loadFlag = false;

  /// 选择的知识点类型下标
  ElementsCardType _selectedType = ElementsCardType.word;

  List<ManageKnowledgeTableModel> _allKnowledgeList = [];

  /// 选择的知识点
  List<ManageKnowledgeTableModel> _selectedKnowledgeList = [];

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    loadFlag = true;
    _selectedKnowledgeList = widget.selectedKnowledge ?? [];
    getEnKnowledgeList();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ManageKnowledgeTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedKnowledge != oldWidget.selectedKnowledge) {
      _selectedKnowledgeList = widget.selectedKnowledge ?? [];
      for(int i = 0; i < _allKnowledgeList.length; i++){
        _allKnowledgeList[i].isSelected = _selectedKnowledgeList.any((element) => element.id == _allKnowledgeList[i].id);
      }
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _uidController.dispose();
    _knowledgeController.dispose();
    _knowledgeExactController.dispose();
    _phoneticController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  /// 滚动监听
  void _onScroll() {

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 20 && !_scrollController.position.outOfRange) {
      if((knowledgeOffset + knowledgeLimit) < knowledgeCount && !loadFlag) {
        loadFlag = true;
        if (mounted) setState(() {});
        knowledgeOffset += knowledgeLimit;
        getEnKnowledgeList();
      }
    }

  }


  /// 筛选知识点类型
  void _filterKnowledgeType(ElementsCardType type) {
    loadFlag = true;
    _selectedType = type;
    if(mounted) setState(() {});
    knowledgeOffset = 0;
    knowledgeCount = 0;
    _allKnowledgeList.clear();
    getEnKnowledgeList();
  }
  

  /// 查询短语列表
  Future<void> getEnKnowledgeList() async {

    try {
      List<String>? uids = getInputIds();
      ManageKnowledgePagerModel? res = await KonwledgeUtils.getKnowledgeListByType(
        type: _selectedType,
        knowledgeOffset: knowledgeOffset,
        knowledgeLimit: knowledgeLimit,
        content: _knowledgeController.text,
        uids: uids,
        fullContent: _knowledgeExactController.text,
        phonicsIpa: _phoneticController.text,
        initSelectedIds: _selectedKnowledgeList,
      );

      if(res == null) return;
      if (res.datas == null) return;
      knowledgeCount = res.count;

      _allKnowledgeList.addAll(res.datas??[]);

    } finally{
      loadFlag = false;
      if (mounted) setState(() {});
    }
  }

  

  List<String>? getInputIds() {
    String uid = _uidController.text;
    List<String> uids = [];
    // 单词/短语
    if (uid.trim().isEmpty) {
      return null;
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
    return uids;
  }

  /// 清空选择
  void _clearSelect(){
    for(int i = 0; i < _allKnowledgeList.length; i++){
      _allKnowledgeList[i].isSelected = false;
      _allKnowledgeList[i].selectSemantics = null;
    }
    _selectedKnowledgeList.clear();
    widget.onSelected?.call(_selectedKnowledgeList);
  }

  /// 选择某一行
  Future<void> _onSelectRow(ManageKnowledgeTableModel model) async {
    if(widget.maxSelectCount != null && _selectedKnowledgeList.length >= widget.maxSelectCount!){
      ToastUtils.showManageToast(text: "最多只能选择${widget.maxSelectCount}个知识点");
      return;
    }
    if(widget.isSingleSelect){
      _clearSelect();
    }
    if(model.isSelected){
      // 已经选中，取消选中
      model.isSelected = false;
      model.selectSemantics = null;
      _selectedKnowledgeList.removeWhere((element) => element.id == model.id);
      if (mounted) setState(() {});
      widget.onSelected?.call(_selectedKnowledgeList);
      return;
    }

    List<EnEntitySemantics> semantics = [];
    if(model.type == ElementsCardType.word){
      semantics = model.word!.semantics ?? [];
    }else if(model.type == ElementsCardType.phrase){
      semantics = model.phrase!.semantics ?? [];
    }else if(model.type == ElementsCardType.sentence){
      semantics = model.sentence?.semantics ?? [];
    }
    if(model.type == ElementsCardType.text){
      ManageKnowledgeTableModel select = model.copy();
      _selectedKnowledgeList.add(select);
      model.isSelected = true;
      widget.onSelected?.call(_selectedKnowledgeList);
      return;
    }

    if(semantics.length == 1){
      // 只有一个语义 直接选择
      ManageKnowledgeTableModel select = model.copy();
      select.selectSemantics = [semantics.first];
      _selectedKnowledgeList.add(select);
      model.isSelected = true;
      widget.onSelected?.call(_selectedKnowledgeList);
      return;
    }

    SelectSemanticManager.show(
      context: context, 
      semantics: semantics, 
      onOkTap: (semantics) {
        List<EnEntitySemantics> selectSemantics = semantics.where((e) => e.isSelected == true).toList();
        ManageKnowledgeTableModel select = model.copy();
        select.selectSemantics = selectSemantics;
        _selectedKnowledgeList.add(select);
        model.isSelected = true;
        if (mounted) setState(() {});
        widget.onSelected?.call(_selectedKnowledgeList);
      },
    );
  }

  /// 设置支持的知识点类型
  void _setSupportedTypes(List<ElementsCardType> types) {
    if(types.isEmpty) return;
    _supportedTypes = types;
    if(!_supportedTypes.contains(_selectedType)){
      _selectedType = _supportedTypes.first;
      _filterKnowledgeType(_selectedType);
    }
    if (mounted) setState(() {});
  }




  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: Column(
        children: [
          _buildTitleWidget(),
          _buildTableTitleWidget(),
          Container(
            height: 1.wMin,
            color: const Color(0xff4B5268),
          ),
          SizedBox(
            height: 500.wMin,
            child: Stack(
              children: [
                ListView.separated(
                  controller: _scrollController,
                  itemCount: _allKnowledgeList.length,
                  separatorBuilder: (context, index) {
                    return Container(
                      height: 1.wMin,
                      color: const Color.fromRGBO(75, 82, 104, 0.40),
                    );
                  },
                  itemBuilder: (context, index) {
                    return _buildTableContentRowWidget(_allKnowledgeList[index], index);
                  },
                ),
                Positioned.fill(
                  child: Visibility(
                    visible: loadFlag,
                    child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: SpinKitFadingCircle(
                        color: AppTheme.cBgBrand.color,
                        size: 80.wMin,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Row(
      children: [
        Container(
          width: 300.wMin,
          margin: EdgeInsets.only(right: 16.wMin),
          child: ManageTitleInputWidget(
            height: 50.wMin,
            hintText: "uid",
            controller: _uidController,
            textInputAction: TextInputAction.search,
            onSubmitted: (text) {
              _filterKnowledgeType(_selectedType);
            },
          ),
        ),
        Container(
          width: 300.wMin,
          margin: EdgeInsets.only(right: 16.wMin),
          child: ManageTitleInputWidget(
            height: 50.wMin,
            hintText: "知识点",
            controller: _knowledgeController,
            textInputAction: TextInputAction.search,
            onSubmitted: (text) {
              _filterKnowledgeType(_selectedType);
            },
          ),
        ),
        Visibility(
          visible: _selectedType == ElementsCardType.word || _selectedType == ElementsCardType.phrase || _selectedType == ElementsCardType.sentence,
          child: Container(
            width: 300.wMin,
            margin: EdgeInsets.only(right: 16.wMin),
            child: ManageTitleInputWidget(
              height: 50.wMin,
              hintText: "知识点(精确搜索)",
              controller: _knowledgeExactController,
              textInputAction: TextInputAction.search,
              onSubmitted: (text) {
                _filterKnowledgeType(_selectedType);
              },
            ),
          ),
        ),
        Visibility(
          visible: _selectedType == ElementsCardType.word,
          child: SizedBox(
            width: 300.wMin,
            child: ManageTitleInputWidget(
              height: 50.wMin,
              hintText: "音标",
              controller: _phoneticController,
              textInputAction: TextInputAction.search,
              onSubmitted: (text) {
                _filterKnowledgeType(_selectedType);
              },
            ),
          ),
        ),
        
        const Spacer(),
    
        _buildButtonWidget(
          type: ElementsCardType.word,
          onTap: () => _filterKnowledgeType(ElementsCardType.word),
        ),
        _buildButtonWidget(
          type: ElementsCardType.phrase,
          onTap: () => _filterKnowledgeType(ElementsCardType.phrase),
        ),
        _buildButtonWidget(
          type: ElementsCardType.sentence,
          onTap: () => _filterKnowledgeType(ElementsCardType.sentence),
        ),
        _buildButtonWidget(
          type: ElementsCardType.text,
          onTap: () => _filterKnowledgeType(ElementsCardType.text),
        ),
    
      ],
    );
  }


  Widget _buildButtonWidget({
    required ElementsCardType type,
    required VoidCallback onTap,
  }){
    if(!_supportedTypes.contains(type)) return Container();
    return ManageButton(
      text: type.name,
      width: 60.wMin,
      height: 40.wMin,
      color: _selectedType == type ? const Color(0xff22293C) : Colors.transparent,
      borderColor: Colors.transparent,
      style: TextStyle(
        fontSize: 16.wMin,
        color: Colors.white,
        fontWeight: FontWeight.w400,
      ),
      onTap: onTap,
    );
  }

  Widget _buildTableTitleWidget(){
    Widget body = Container();
    if(_selectedType == ElementsCardType.word || _selectedType == ElementsCardType.phrase){
      body = Row(
        spacing: 20.wMin,
        children: [
          _buildTableTitleItemWidget(title: "uid", flex: 10),
          _buildTableTitleItemWidget(title: "知识点", flex: 10),
          _buildTableTitleItemWidget(title: "词性", flex: 10),
          _buildTableTitleItemWidget(title: "难度", flex: 10),
          _buildTableTitleItemWidget(title: "语义", flex: 60),
        ],
      );
    }else if(_selectedType == ElementsCardType.sentence){
      body = Row(
        spacing: 20.wMin,
        children: [
          _buildTableTitleItemWidget(title: "uid", flex: 10),
          _buildTableTitleItemWidget(title: "知识点", flex: 30),
          _buildTableTitleItemWidget(title: "难度", flex: 10),
          _buildTableTitleItemWidget(title: "语义", flex: 50),
        ],
      );
    }else if(_selectedType == ElementsCardType.text){
      body = Row(
        spacing: 20.wMin,
        children: [
          _buildTableTitleItemWidget(title: "uid", flex: 10),
          _buildTableTitleItemWidget(title: "标题", flex: 20),
          _buildTableTitleItemWidget(title: "难度", flex: 10),
          _buildTableTitleItemWidget(title: "知识点", flex: 60),
        ],
      );
    }
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.wMin),
      child: Row(
        children: [
          SizedBox(width: 60.wMin),

          Expanded(child: body),
        ],
      ),
    );
  }


  Widget _buildTableContentRowWidget(ManageKnowledgeTableModel model, int index){
    Widget body = Container();
    if(_selectedType == ElementsCardType.word){
      EnWordEntity? word = model.word;
      int? minDifficulty, maxDifficulty;
      if(word?.difficulty is Map){
        minDifficulty = word?.difficulty?['min'];
        maxDifficulty = word?.difficulty?['max'];
      }
      
      body = Row(
        spacing: 20.wMin,
        children: [
          _buildTableContentItemWidget(value: word?.uid.toString(), flex: 10),
          _buildTableContentItemWidget(value: word?.content, flex: 10),
          _buildTableContentItemWidget(value: word?.posTitle, flex: 10),
          _buildTableDifficultyItemWidget(min: minDifficulty, max: maxDifficulty, language: widget.langage, flex: 10),
          _buildTableContentItemWidget(value: word?.allGlossZhTitle, flex: 60),
        ],
      );
    }else if(_selectedType == ElementsCardType.phrase){
      EnPhraseEntity? phrase = model.phrase;
      int? minDifficulty, maxDifficulty;
      if(phrase?.difficulty is Map){
        minDifficulty = phrase?.difficulty?['min'];
        maxDifficulty = phrase?.difficulty?['max'];
      }
      body = Row(
        spacing: 20.wMin,
        children: [
          _buildTableContentItemWidget(value: phrase?.uid.toString(), flex: 10),
          _buildTableContentItemWidget(value: phrase?.content, flex: 10),
          _buildTableContentItemWidget(value: phrase?.posTitle, flex: 10),
          _buildTableDifficultyItemWidget(min: minDifficulty, max: maxDifficulty, language: widget.langage, flex: 10),
          _buildTableContentItemWidget(value: phrase?.allGlossZhTitle, flex: 60),
        ],
      );
    }else if(_selectedType == ElementsCardType.sentence){
      EnSentenceEntity? sentence = model.sentence;
      body = Row(
        spacing: 20.wMin,
        children: [
          _buildTableContentItemWidget(value: sentence?.uid.toString(), flex: 10),
          _buildTableContentItemWidget(value: sentence?.content, flex: 30),
          _buildTableDifficultyItemWidget(min: sentence?.minDifficulty, max: sentence?.maxDifficulty, language: widget.langage, flex: 10),
          _buildTableContentItemWidget(value: sentence?.definition, flex: 50),
        ],
      );
    }else if(_selectedType == ElementsCardType.text){
      EnTextEntity? text = model.text;
      int? difficulty;
      if(text?.difficulty is Map){
        difficulty = text?.difficulty['min'];
      }else{
        difficulty = text?.difficulty;
      }
      body = Row(
        spacing: 20.wMin,
        children: [
          _buildTableContentItemWidget(value: text?.uid.toString(), flex: 10),
          _buildTableContentItemWidget(value: text?.title, flex: 20),
          _buildTableDifficultyItemWidget(min: difficulty, language: widget.langage, flex: 10),
          _buildTableContentItemWidget(value: text?.content, flex: 60),
        ],
      );
    }


    
    return TapScaleWidget(
      onTap: () {
        if(model.enableSelect){
          _onSelectRow(model);
        }
      },
      sclae: 1,
      child: Container(
        color: index.isEven ? const Color.fromRGBO(27, 29, 38, 1) : Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 16.wMin),
        child: Row(
          children: [
      
          _buildTableSelectItemWidget(
            selected: model.isSelected,
            enabled: model.enableSelect,
          ),
      
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
  

  Widget _buildTableTitleItemWidget({
    required String title,
    int flex = 1,
  }){
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.wMin,
          color: const Color(0xffACB4C0),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildTableContentItemWidget({
    String? value,
    int flex = 1,
  }){
    return Expanded(
      flex: flex,
      child: Text(
        value ?? '',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 18.wMin,
          color: const Color(0xffEBEEF3),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  /// 难度item
  Widget _buildTableDifficultyItemWidget({
    int? min,
    int? max,
    String? language,
    int flex = 1,
  }){
    return Expanded(
      flex: flex,
      child: Row(
        spacing: 4.wMin,
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusTagDifficultyWidget(
            difficulty: min,
            language: language,
          ),
          Visibility(
            visible: max != null,
            child: Container(
              width: 8.wMin,
              height: 1.wMin,
              color: const Color(0xffACB4C0),
            ),
          ),
          Visibility(
            visible: max != null,
            child: StatusTagDifficultyWidget(
              difficulty: max,
              language: language,
            ),
          ),
        ],
      ),
    );
  }


  /// 选择框
  Widget _buildTableSelectItemWidget({
    bool selected = false,
    bool enabled = true,
  }){
    // 未选择
    String svg = "assets/svg/manage/icon_uncheck_box.svg";

    if(widget.isSingleSelect){
      // 未选择
      svg = "assets/svg/manage/icon_unradio.svg";
      
      if(selected){
        // 已选择
        svg = "assets/svg/manage/icon_radio.svg";
      }
      
      if(!enabled){
        // 不可选
        svg = "assets/svg/manage/icon_radio_dis.svg";
      }

    }else{
      // 未选择
      svg = "assets/svg/manage/icon_uncheck_box.svg";
      
      if(selected){
        // 已选择
        svg = "assets/svg/manage/icon_check_box.svg";
      }
      
      if(!enabled){
        // 不可选
        svg = "assets/svg/manage/icon_check_box_dis.svg";
      }

    }
    

    return Container(
      width: 60.wMin,
      alignment: Alignment.center,
      color: Colors.transparent,
      child: SvgPicture.asset(
        svg,
        width: 18.wMin,
      ),
    );
  }




}

