import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/generated/assets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../app/modules/management/common/manage_title_input_widget.dart';
import 'dialog_box_widget.dart';
import 'tap_scale_widget.dart';

/// 管理-添加模块-关联-添加模块
class SelectModuleTableDialog{
  static Future<bool?> show({
    required BuildContext context,
  }) async {
    
    return await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return const SelectModuleTableDialogWidget();
      },
    );
  }
}

class SelectModuleTableDialogWidget extends StatefulWidget {
  const SelectModuleTableDialogWidget({super.key});

  @override
  State<SelectModuleTableDialogWidget> createState() => _SelectModuleTableDialogWidgetState();
}

class _SelectModuleTableDialogWidgetState extends State<SelectModuleTableDialogWidget> {
  List<_SelectModuleTableDialogModel> dataList = [];
  bool isSelectAll = false;

  @override
  void initState() {
    super.initState();
    dataList = List.generate(20, (index){
      return _SelectModuleTableDialogModel(
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

  Future<void> selectItem(_SelectModuleTableDialogModel data) async{
    
    data.selected = !data.selected;
    if(!data.selected){
      isSelectAll = false;
      if(mounted) setState(() {});
    }else{

      isSelectAll = true;
      for (var element in dataList) {
        if(!element.selected){
          isSelectAll = false;
          break;
        }
      }
      if(mounted) setState(() {});
    }
    
  }

  int getSelectCount(){
    int count = 0;
    for (var element in dataList) {
      if(element.selected){
        count++;
      }
    }
    return count;
  }
  
  @override
  Widget build(BuildContext context) {
    
    Widget buildSearchsWidget(){
      return FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Row(
          children: [
            // SizedBox(
            //   width: 222.ww,
            //   child: ManageTitleInputWidget(
            //     hintText: "模块名称",
            //     height: 40.wMin,
            //     focusOrder: 0,
            //     prefixWidget: Container(
            //       margin: EdgeInsets.only(right: 5.wMin),
            //       child: SvgPicture.asset(Assets.manageIconSearch, width: 18.wMin),
            //     ),
            //   ),
            // ),
            // SizedBox(width: 8.ww),
            SizedBox(
              width: 222.ww,
              child: ManageTitleInputWidget(
                hintText: "模块ID",
                height: 40.wMin,
                focusOrder: 1,
                prefixWidget: Container(
                  margin: EdgeInsets.only(right: 5.wMin),
                  child: SvgPicture.asset(Assets.manageIconSearch, width: 18.wMin),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
    

    Widget tabViewRowWidget(_SelectModuleTableDialogModel data, {bool isTitle = false}){

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


    return DialogBoxWidget(
      title: "模块",
      width: 1080.ww,
      define: "添加${getSelectCount()}个模块",
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
              buildSearchsWidget(),
              SizedBox(
                height: 500.wMin,
                child: Container(
                  padding: EdgeInsets.only(top: 10.wMin),
                  child: Column(
                    children: [
                      tabViewRowWidget(
                        _SelectModuleTableDialogModel(knowledge: "知识点", partOfSpeech: "词性", interpretation: "释义"), 
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
                ),
              ),

              
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectModuleTableDialogModel{
  bool selected = false;
  String? knowledge;
  String? partOfSpeech;
  String? interpretation;
  
  _SelectModuleTableDialogModel({
    this.knowledge,
    this.partOfSpeech,
    this.interpretation,
  });
}