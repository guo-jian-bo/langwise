import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 选择知识点弹窗
class SelectKnowledgeDialog{
  static Future<bool?> show({
    required BuildContext context,
  }) async{
    return await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return const SelectKnowledgeWidget();
      },
    );
  }
}

class SelectKnowledgeWidget extends StatefulWidget {
  const SelectKnowledgeWidget({super.key});

  @override
  State<SelectKnowledgeWidget> createState() => _SelectKnowledgeWidgetState();
}

class _SelectKnowledgeWidgetState extends State<SelectKnowledgeWidget> with TickerProviderStateMixin{
  late final TabController _tabController;
  int tabCurrentIndex = 0;
  List<String> tabBarNames = ["单词", "短语", "句子", "习语"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener((){
      tabCurrentIndex = _tabController.index;
      if(mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {

    Widget buildSearchWidget(){
      return ManageTitleInputWidget(
        hintText: tabBarNames[tabCurrentIndex],
        prefixWidget: Container(
          margin: EdgeInsets.only(right: 5.wMin),
          child: SvgPicture.asset(Assets.manageIconSearch, width: 18.wMin),
        ),
      );
    }

    Widget buildTabBarWidget(){
      return TabBar(
        controller: _tabController,
        indicatorPadding: EdgeInsets.only(bottom: 5.wMin),
        indicator: UnderlineTabIndicator(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(width: 3.wMin, color: const Color(0xff2388FF))
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
      );
    }


    return DialogBoxWidget(
      title: "选择知识点",
      width: 1080.ww,
      onCancel: () => Get.back(),
      onDefine: () {
        Get.back(result: true);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSearchWidget(),

              SizedBox(height: 16.wMin),
              buildTabBarWidget(),
              SizedBox(
                height: 500.wMin,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    const SelectKnowledgeTabViewWidget(),
                    const SelectKnowledgeTabViewWidget(),
                    const SelectKnowledgeTabViewWidget(),
                    const SelectKnowledgeTabViewWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}

class SelectKnowledgeTabViewWidget extends StatefulWidget {
  const SelectKnowledgeTabViewWidget({super.key});

  @override
  State<SelectKnowledgeTabViewWidget> createState() => _SelectKnowledgeTabViewWidgetState();
}

class _SelectKnowledgeTabViewWidgetState extends State<SelectKnowledgeTabViewWidget> with AutomaticKeepAliveClientMixin{
  bool isSelectAll = false;

  List<_SelectKnowledgeModel> dataList = [];
  
  @override
  void initState() {
    super.initState();
    dataList = List.generate(20, (index){
      return _SelectKnowledgeModel(
        knowledge: "Oranage",
        partOfSpeech: "名词",
        interpretation: "橙色",
      );
    });
  }

  void selectAll(){
    isSelectAll = !isSelectAll;
    for (var element in dataList) {
      element.selected = isSelectAll;
    }
    if(mounted) setState(() {});
  }

  Future<void> selectItem(_SelectKnowledgeModel data) async{
    
    if(data.selected){
      data.selected = false;
      isSelectAll = false;
      if(mounted) setState(() {});
    }else{
      // dynamic res = await SelectSemanticsDialog.show(context: context);
      // if(res == null) return;
      // data.selected = true;
      // isSelectAll = true;
      // for (var element in dataList) {
      //   if(!element.selected){
      //     isSelectAll = false;
      //     break;
      //   }
      // }
      // if(mounted) setState(() {});
    }
    
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget _checkTitleWidget(){
      return TapScaleWidget(
        onTap: selectAll,
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.all(16.wMin),
          child: Container(
            width: 18.wMin,
            height: 18.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xff2388FF),
              borderRadius: BorderRadius.circular(5.wMin),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isSelectAll ? Icons.check : Icons.remove, 
                key: ValueKey(isSelectAll),
                size: 15.wMin, 
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    

    Widget tabViewRowWidget(_SelectKnowledgeModel data, {bool isTitle = false}){

      Widget _checkItemWidget(){
        return TapScaleWidget(
          onTap: () => selectItem(data),
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.all(16.wMin),
            child: Container(
              width: 18.wMin,
              height: 18.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: data.selected ? const Color(0xff2388FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(5.wMin),
                border: Border.all(
                  width: 1.wMin,
                  color: data.selected ? Colors.transparent : const Color(0xff616B85),
                )
              ),
              child: Icon(
                data.selected ? Icons.check : null, 
                key: ValueKey(isSelectAll),
                size: 15.wMin, 
                color: Colors.white,
              ),
            ),
          ),
        );
      }

      Widget _textWidget(String text){
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

      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1.wMin, 
              color: const Color(0xff4B5268).withValues(alpha: isTitle ? 1 : 0.4),
            ),
          ),
        ),
        child: Row(
          children: [
            isTitle ? _checkTitleWidget() : _checkItemWidget(),
            Expanded(
              flex: 3,
              child: _textWidget(data.knowledge??""),
            ),
            Expanded(
              flex: 3,
              child: _textWidget(data.partOfSpeech??""),
            ),
            Expanded(
              flex: 4,
              child: _textWidget(data.interpretation??""),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(top: 10.wMin),
      child: Column(
        children: [
          tabViewRowWidget(
            _SelectKnowledgeModel(knowledge: "知识点", partOfSpeech: "词性", interpretation: "释义"), 
            isTitle: true,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                return tabViewRowWidget(dataList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}

class _SelectKnowledgeModel{
  bool selected = false;
  String? knowledge;
  String? partOfSpeech;
  String? interpretation;
  
  _SelectKnowledgeModel({
    this.knowledge,
    this.partOfSpeech,
    this.interpretation,
  });
}