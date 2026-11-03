
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../generated/assets.dart';
import '../entities/en_phrase_entity.dart';

/// 选择语义
class SelectSemanticsDialog{
  static Future<List<EnEntitySemantics>?> show({
    required BuildContext context,
    required List<EnEntitySemantics> datas,
    bool knowledgeSingle = false,
    /// 多选情况下最大选择知识点数量
    int knowledgeMaxSelect = 4,
    /// 已经选择的知识点数量
    int knowledgeSelectCount = 0,
    void Function(List<EnEntitySemantics> datas)? onResult,
    String? language,
  }) async{
    return await showCupertinoDialog<List<EnEntitySemantics>?>(
      context: context,
      builder: (context) {
        return SelectSemanticsWidget(
          datas: datas, 
          onResult: onResult, 
          knowledgeSingle: knowledgeSingle,
          knowledgeMaxSelect: knowledgeMaxSelect,
          knowledgeSelectCount: knowledgeSelectCount,
          language: language,
        );
      },
    );
  }
}

class SelectSemanticsWidget extends StatefulWidget {
  final List<EnEntitySemantics> datas;
  final bool knowledgeSingle;
  /// 多选情况下最大选择知识点数量
  final int knowledgeMaxSelect;
  final int knowledgeSelectCount;
  final void Function(List<EnEntitySemantics> datas)? onResult;
  final String? language;
  const SelectSemanticsWidget({
    super.key, 
    required this.datas, 
    this.onResult, 
    this.knowledgeSingle = false, 
    this.knowledgeMaxSelect = 2, 
    this.knowledgeSelectCount = 0, 
    this.language,
  });

  @override
  State<SelectSemanticsWidget> createState() => _SelectSemanticsWidgetState();
}

class _SelectSemanticsWidgetState extends State<SelectSemanticsWidget> {
  final GlobalKey dialogKey = GlobalKey();

  List<EnEntitySemantics> list = [];

  @override
  void initState() {
    super.initState();
    list = widget.datas;
  }

  int getSelectCount(){
    int count = 0;
    for(int i = 0; i < list.length; i++){
      if(list[i].isSelected) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {

    Widget buildKnowledgeItem(int index, EnEntitySemantics data){
      String iconUnCheck = "assets/svg/manage/icon_uncheck_box.svg";
      String iconCheck = "assets/svg/manage/icon_check_box.svg";
      if(widget.knowledgeSingle){
        iconUnCheck = "assets/svg/manage/icon_unradio.svg";
        iconCheck = "assets/svg/manage/icon_radio.svg";
      }
      return TapScaleWidget(
        sclae: 1.01,
        onTap: (){
          if(widget.knowledgeSingle){
            for(int i = 0; i < list.length; i++){
              list[i].isSelected = false;
            }
          }
          if(!data.isSelected){
            if(getSelectCount() >= widget.knowledgeMaxSelect - widget.knowledgeSelectCount) {
              ToastUtils.showManageToast(text: "最多可选择${widget.knowledgeMaxSelect}个知识点", containerKey: dialogKey);
              return;
            }
          } 
          
          data.isSelected = !data.isSelected;
          if(mounted) setState(() {});
        },
        child: Container(
          padding: EdgeInsets.all(12.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: const Color(0xff22293C),
            border: Border.all(
              width: 1.wMin,
              color: data.isSelected ? const Color(0xff2388FF) : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: SvgPicture.asset(
                  data.isSelected ? iconCheck : iconUnCheck,
                  width: 18.wMin,
                ),
              ),
              SizedBox(height: 6.wMin),
              Expanded(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.478.wMin),
                      child: Container(
                        width: 140.wMin,
                        height: 140.wMin,
                        color: Colors.white.withValues(alpha: 0.1),
                        child: CachedImageWidget(
                          data.imageUrl??"",
                          fit: BoxFit.cover,
                          errorWidget: Image.asset(
                            Assets.managerImageNotFound, 
                            width: double.infinity, 
                            height: double.infinity, 
                            fit: BoxFit.contain,
                          ),
                          placeholder: Container(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.wMin),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Visibility(
                            visible: data.difficulty != null,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 16.wMin),
                              child: StatusTagDifficultyWidget(
                                difficulty: data.difficulty,
                                language: widget.language,
                                fontSize: 12.wMin,
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                spacing: 12.wMin,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: List.generate(data.descriptions?.length??0, (index){
                                  return Text(
                                    data.descriptions?[index].text??"",
                                    style: TextStyle(
                                      fontSize: 16.wMin,
                                      color: const Color(0xffffffff),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DialogBoxWidget(
      title: "选择语义",
      width: 1385.wMin,
      onCancel: () => Get.back(),
      define: "添加${getSelectCount()}个知识点",
      onDefine: () {
        List<EnEntitySemantics> datas = [];
        for(int i = 0; i < list.length; i++){
          if(list[i].isSelected) datas.add(list[i]);
        }
        if(datas.isEmpty){
          ToastUtils.showManageToast(text: "请选择语义", containerKey: dialogKey);
          return;
        }
        widget.onResult?.call(datas);
        Get.back(result: datas);
      },
      child: Container(
        key: dialogKey,
        height: 600.wMin,
        alignment: Alignment.centerLeft,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 24.wMin,
            crossAxisSpacing: 24.wMin,
            childAspectRatio: 432 / 188,
          ),
          itemBuilder: (context, index) {
            return buildKnowledgeItem(index, list[index]);
          },
          itemCount: list.length,
        ),

      ),
    );
  }
}

class SelectSemanticsModel<T>{
  String name;
  String? description;
  String? image;
  String? language;
  int? difficulty;
  bool isSelected;
  int? id;
  T? data;
  SelectSemanticsModel({
    required this.name,
    this.description,
    this.image,
    this.language,
    this.difficulty,
    this.isSelected = false,
    this.data,
    this.id,
  });
}