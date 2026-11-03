

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../app/modules/management/common/manage_button.dart';
import '../../theme/theme.dart';
import 'widgets.dart';


class FilterButtonCondition{
  String? name;
  String? value;
  bool isClose;
  Color? color;
  void Function()? onClear;

  FilterButtonCondition({this.name, this.value, this.color, this.isClose = true, this.onClear});
}

class FilterButtonWidget extends StatelessWidget {
  final List<FilterButtonCondition>? filters;
  final void Function()? onTap;
  /// 筛选按钮
  const FilterButtonWidget({super.key, this.onTap, this.filters});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72.wMin,
      padding: EdgeInsets.only(left: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xff1D2021).withValues(alpha: 0.95),
        border:  Border.all(width: 1.wMin, color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
        
            TapScaleWidget(
              onTap: onTap,
              sclae: 1.03,
              child: Container(
                width: 56.wMin,
                height: 56.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  "assets/svg/manage/icon_filter.svg",
                  width: 24.wMin,
                  height: 24.wMin,
                ),
              ),
            ),
        
            Container(
              constraints: BoxConstraints(
                maxWidth: 1000.wMin,
                minWidth: 500.wMin,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                child: Row(
                  spacing: 16.wMin,
                  children: List.generate(filters?.length??0, (index){
                    return Container(
                      height: 56.wMin,
                      padding: EdgeInsets.only(left: 16.wMin, right: 8.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: filters?[index].color?.withValues(alpha: 0.12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            filters?[index].name??"",
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: filters?[index].color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Visibility(
                            visible: filters?[index].isClose??true,
                            child: TapScaleWidget(
                              sclae: 1.03,
                              onTap: (){
                                if(filters?[index] == null) return;
                                filters?[index].onClear?.call();
                              },
                              child: Container(
                                width: 32.wMin,
                                height: 32.wMin,
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  "assets/svg/public/x.svg",
                                  width: 24.wMin,
                                  height: 24.wMin,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
        
        
        
          ],
        ),
      ),
    );
  }

}

class FilterConditionData{
  String title;
  List<FilterConditionItem> conditions;
  bool isSingle;
  int crossAxisCount;

  FilterConditionData({
    required this.title,
    required this.conditions,
    this.isSingle = false,
    this.crossAxisCount = 3,
  });
}

class FilterConditionItem{
  String name;
  dynamic value;
  bool selected;
  Color? color;

  FilterConditionItem({
    required this.name,
    required this.value,
    this.selected = false,
    this.color,
  });
}


class FilterInputData{
  TextEditingController controller;
  String? hintText;

  FilterInputData({
    required this.controller,
    this.hintText,
  });

}


class FilterDialog{

  static Future<Map<String, FilterConditionData>?> show({
    required BuildContext context,
    required Map<String, FilterConditionData> conditions,
    void Function(Map<String, FilterConditionData> datas)? onChange,
    String? scroConditionKey,
  }) async{
    return await showCupertinoDialog<Map<String, FilterConditionData>?>(
      context: context,
      builder: (context) {
        return FilterDialogWidget(
          conditions: conditions,
          onChange: onChange,
          scroConditionKey: scroConditionKey,
        );
      },
    );
  }


  /// 获取筛选数据
  static List<FilterConditionItem>? getFilterData({
   required String key,
    required Map<String, FilterConditionData> filterConditionData,
  }) {
    FilterConditionData? filterResolved = filterConditionData[key];
    if(filterResolved == null) return null;
    if(filterResolved.conditions.isEmpty) return null;
    List<FilterConditionItem> conditions = filterResolved.conditions;
    List<FilterConditionItem> selectedConditions = conditions.where((e) => e.selected).toList();
    if(selectedConditions.isEmpty) return null;
    return selectedConditions;
  }


  /// 获取搜索的值
  static String? getSearchStr({
    required String key,
    required Map<String, FilterInputData> filterInputDatas,
  }){
    FilterInputData? filterInputData = filterInputDatas[key];
    if(filterInputData == null) return null;
    String text = filterInputData.controller.text.trim();
    if(text.isEmpty) return null;
    return text;
  }


  /// 字符串转int数组
  static List<int>? stringToIntList(String? input) {
    // 1. 如果输入为空，直接返回空列表
    if (input == null) return null;
    if (input.isEmpty) return null;

    List<int> result = [];

    // 2. 使用正则表达式按照 中文逗号(，) 或 英文逗号(,) 分割字符串
    List<String> rawList = input.split(RegExp(r'[,，]'));

    for (String item in rawList) {
      // 3. 去除每个元素前后的空格（防止 " 12 " 这种情况）
      String cleanItem = item.trim();

      // 4. 只有在字符串不为空时才处理（防止 "1,,2" 产生空元素）
      if (cleanItem.isNotEmpty) {
        // 5. 核心：使用 int.tryParse
        // 如果是数字，返回整数；如果不是数字（如 "abc"），返回 null
        int? parsedNumber = int.tryParse(cleanItem);

        if (parsedNumber != null) {
          // 只有成功转换才加入结果集
          result.add(parsedNumber);
        } else {
          // 这里可以根据需求决定：是打印警告，还是直接跳过
          print("跳过非法数字: '$cleanItem'");
        }
      }
    }

    if(result.isEmpty) return null;

    return result;
  }

}

class FilterDialogWidget extends StatefulWidget {
  final Map<String, FilterConditionData> conditions;
  final void Function(Map<String, FilterConditionData> datas)? onChange;
  final String? scroConditionKey;
  const FilterDialogWidget({
    super.key,
    required this.conditions,
    this.onChange,
    this.scroConditionKey,
  });

  @override
  State<FilterDialogWidget> createState() => _FilterDialogWidgetState();
}

class _FilterDialogWidgetState extends State<FilterDialogWidget> {
  Map<String, FilterConditionData> filterConditionDatas = {};

  Map<String, GlobalKey> filterKeyMap = {};

  @override
  void initState(){
    super.initState();
    
    widget.conditions.forEach((key, value) {
      filterConditionDatas[key] = value;
      filterKeyMap[key] = GlobalKey();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToTarget();
    });

  }

  void _scrollToTarget() {
    if(widget.scroConditionKey == null) return;
    final targetKey = filterKeyMap[widget.scroConditionKey];
    if (targetKey?.currentContext == null) return;
    
    // 使用 Scrollable.ensureVisible 滚动到目标 widget
    Scrollable.ensureVisible(
      targetKey!.currentContext!,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: 0.5, // 0.0 顶部对齐，0.5 居中对齐，1.0 底部对齐
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.wMin),
          child: Stack(
            children: [
              Container(
                width: 1200.wMin,
                height: 800.wMin,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.wMin),
                  color: AppTheme.cSurfaceSecondary.color,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24.wMin),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 24.wMin,
                          children: List.generate(filterConditionDatas.length, (index){
                            
                            return _buildConditionListWidget(filterConditionDatas.keys.elementAt(index), filterConditionDatas.values.elementAt(index), index);
                          }),
                        ),
                      ),
                    ),
                    _buildButtonsWidget(),
                  ],
                ),
              ),
              Positioned(
                right: 16.wMin,
                top: 16.wMin,
                child: TapScaleWidget(
                  sclae: 1.05,
                  onTap: () => Get.back(),
                  child: Container(
                    width: 42.wMin,
                    height: 42.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cSurfaceTertiary.color,
                    ),
                    child: SvgPicture.asset(
                      "assets/svg/public/x.svg",
                      width: 24.wMin,
                      height: 24.wMin,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionListWidget(String key, FilterConditionData condition, int datasIndex){

    return Column(
      key: filterKeyMap[key],
      spacing: 8.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleTextWidget(condition.title),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: condition.conditions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: condition.crossAxisCount,
            mainAxisSpacing: 12.wMin,
            crossAxisSpacing: 12.wMin,
            mainAxisExtent: 64.wMin,
          ),
          itemBuilder: (context, index) {
            bool selected = condition.conditions[index].selected;

            return TapScaleWidget(
              sclae: 1,
              onTap: () {

                String key = filterConditionDatas.keys.toList()[datasIndex];

                if(!selected){

                  if(condition.isSingle){
                    for(var element in condition.conditions){
                      element.selected = false;
                    }
                  }

                  filterConditionDatas[key]?.conditions[index].selected = true;
                  
                  
                }else{
                  filterConditionDatas[key]?.conditions[index].selected = false;
                }
                
                if (mounted) setState(() {});

                widget.onChange?.call(filterConditionDatas);
              },
              child: _buildFilterItemWidget(
                name: condition.conditions[index].name,
                isSelected: selected,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTitleTextWidget(String value) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 24.wMin,
        color: AppTheme.cTextSecondary.color,
        fontWeight: FontWeight.w400,
      ),
    );
  }


  Widget _buildFilterItemWidget({required String name, bool isSelected = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: 64.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: isSelected ? AppTheme.cSurfaceTertiary.color : AppTheme.cSurfaceSecondary.color,
      ),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 24.wMin,
          color: isSelected ? AppTheme.cTextBrand.color : AppTheme.cTextSecondary.color,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }


  /// 按钮
  Widget _buildButtonsWidget() {
    return Container(
      padding: EdgeInsets.all(24.wMin),
      child: Row(
        spacing: 12.wMin,
        children: [
          ManageButton(
            text: "重置",
            width: 350.wMin,
            height: 72.wMin,
            radius: 12.wMin,
            color: AppTheme.cSurfaceTertiary.color,
            borderColor: Colors.transparent,
            sclae: 1.02,
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
            onTap: () {

              for(var item in filterConditionDatas.values){
                for(var element in item.conditions){
                  element.selected = false;
                }
              }

              if (mounted) setState(() {});

            },
          ),
          Expanded(
            child: ManageButton(
              text: "确定",
              height: 72.wMin,
              radius: 12.wMin,
              color: AppTheme.cSurfaceInfo.color,
              borderColor: Colors.transparent,
              sclae: 1.005,
              style: TextStyle(
                fontSize: 28.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              onTap: () {
                Get.back(result: filterConditionDatas);
              },
            ),
          ),
        ],
      ),
    );
  }
  
}


class FilterFloatWidget extends StatefulWidget {
  final Map<String, FilterConditionData>? conditions;
  final Map<String, FilterInputData>? inputs;
  final double? width;
  final double? conditionMaxWidth;
  final void Function(Map<String, FilterConditionData> datas)? onChange;
  final void Function()? onSubmitted;
  const FilterFloatWidget({
    super.key, 
    this.conditions, 
    this.inputs, 
    this.onChange, 
    this.conditionMaxWidth,
    this.width,
    this.onSubmitted,
  });

  @override
  State<FilterFloatWidget> createState() => _FilterFloatWidgetState();
}

class _FilterFloatWidgetState extends State<FilterFloatWidget> {

  /// 筛选
  Future<void> showFilter(BuildContext context, {String? conditionKey}) async{
    FocusScope.of(context).requestFocus(FocusNode());
    if(widget.conditions == null) return;

    Map<String, FilterConditionData>? res = await FilterDialog.show(
      context: context, 
      conditions: widget.conditions!,
      scroConditionKey: conditionKey,
    );
    if(res == null) return;

    widget.onChange?.call(res);
  }


  @override
  Widget build(BuildContext context) {

    // 条件是否都为false
    bool isAllConditionFalse = widget.conditions?.values.every((element) => element.conditions.every((element) => !element.selected)) ?? false;

    double conditionMaxWidth = widget.conditionMaxWidth ?? (600.wMin);

    double? width;
    if(widget.inputs != null){
      width = (widget.width ?? (1000.wMin));
    }

    return Container(
      height: 72.wMin,
      width: width,
      padding: EdgeInsets.only(left: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppTheme.cSurfaceSecondary.color,
        border:  Border.all(width: 1.wMin, color: AppTheme.cTextPrimary.color.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
        
            Visibility(
              visible: widget.conditions != null,
              child: Container(
                margin: EdgeInsets.only(right: 8.wMin),
                child: TapScaleWidget(
                  onTap: () => showFilter(context),
                  sclae: 1.03,
                  child: Container(
                    width: 56.wMin,
                    height: 56.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceQuaternary.color,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      "assets/svg/manage/icon_filter.svg",
                      width: 24.wMin,
                      height: 24.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ),

            Visibility(
              visible: widget.inputs == null && isAllConditionFalse,
              child: Container(
                margin: EdgeInsets.only(right: 8.wMin),
                child: Text(
                  "筛选与排序",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            Visibility(
              visible: widget.inputs == null,
              child: Container(
                padding: EdgeInsets.only(right: 8.wMin),
                child: _buildConditionWidget(),
              ),
            ),

            Visibility(
              visible: widget.inputs != null,
              child: Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Visibility(
                      visible: !isAllConditionFalse,
                      child: Container(
                        padding: EdgeInsets.only(right: 8.wMin),
                        constraints: BoxConstraints(
                          maxWidth: conditionMaxWidth,
                        ),
                        child: _buildConditionWidget(),
                      ),
                    ),

                    Visibility(
                      visible: widget.inputs != null,
                      child: Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: 8.wMin),
                          child: Row(
                            spacing: 8.wMin,
                            children: List.generate(widget.inputs?.length??0, (index){
                              String key = widget.inputs!.keys.toList()[index];
                              FilterInputData? data = widget.inputs?[key];
                              return _buildInputItemWidget(key, data);
                            }),
                          ),
                        ),
                      ),
                    ),



                  ],
                ),
              ),
            ),
        
          ],
        ),
      ),
    );
  }


  /// 条件模块
  Widget _buildConditionWidget(){
    
    Map<String, FilterConditionData> conditions = {};  

    // 已经选择的
    widget.conditions?.forEach((key, value) {
      if(value.conditions.where((e) => e.selected).isNotEmpty){
        conditions[key] = value;
      }
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8.wMin,
        mainAxisSize: MainAxisSize.min,
        children: conditions.entries.map((entry){
          String key = entry.key;
          List<FilterConditionItem> itemList = entry.value.conditions.where((e) => e.selected).toList();
          
          return Row(
            spacing: 8.wMin,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(itemList.length, (itemIndex){
              return _buildButtonItemWidget(itemList, itemList[itemIndex], key);
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputItemWidget(String key, FilterInputData? data){
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 56.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppTheme.cSurfaceTertiary.color,
          ),
          child: Row(
            children: [
              SizedBox(width: 8.wMin),
              SvgPicture.asset(
                "assets/svg/public/icon_search.svg",
                width: 32.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cSurfaceQuinary.color, BlendMode.srcIn),
              ),
              SizedBox(width: 8.wMin),
              Expanded(
                child: TextField(
                  controller: data?.controller,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                  textInputAction: TextInputAction.search,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    counterText: "",
                    hintText: data?.hintText,
                    hintStyle: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextTertiary.color,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                
                  onTapOutside: (event) {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  onSubmitted: (value) {
                    widget.onSubmitted?.call();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonItemWidget(List<FilterConditionItem> itemList, FilterConditionItem item, String conditionKey){
    return TapScaleWidget(
      onTap: () {
        showFilter(context, conditionKey: conditionKey);
      },
      sclae: 1,
      child: Container(
        height: double.infinity,
        alignment: Alignment.centerLeft,
        // margin: EdgeInsets.only(left: 8.wMin),
        child: Container(
          height: 56.wMin,
          padding: EdgeInsets.only(left: 16.wMin, right: 8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: item.color?.withValues(alpha: 0.12),
          ),
          child: Row(
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: item.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TapScaleWidget(
                sclae: 1.03,
                onTap: (){
      
                  // 找到item在原始conditions中的真实索引
                  int? realItemIndex = widget.conditions?[conditionKey]?.conditions.indexOf(item);
                  if(realItemIndex == null || realItemIndex == -1) return;
                  
                  // 创建深拷贝
                  Map<String, FilterConditionData> filterConditionDatas = {};
                  widget.conditions?.forEach((key, value) {
                    filterConditionDatas[key] = FilterConditionData(
                      title: value.title,
                      conditions: value.conditions.map((condition) => FilterConditionItem(
                        name: condition.name,
                        value: condition.value,
                        selected: condition.selected,
                        color: condition.color,
                      )).toList(),
                      isSingle: value.isSingle,
                    );
                  });
                  // 使用key直接访问
                  filterConditionDatas[conditionKey]?.conditions[realItemIndex].selected = false;
                  widget.onChange?.call(filterConditionDatas);
                  
                },
                child: Container(
                  width: 32.wMin,
                  height: 32.wMin,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    "assets/svg/public/x.svg",
                    width: 24.wMin,
                    height: 24.wMin,
                    colorFilter: ColorFilter.mode(item.color??AppTheme.cTextPrimary.color, BlendMode.srcIn),
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