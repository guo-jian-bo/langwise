
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../theme/theme.dart';
import '../entities/entities.dart';
import '../https/https.dart';
import 'widgets.dart';

/// 国际区号弹窗
class InternationalAreaCodeDialog{

  static Future<String?> show({
    required BuildContext context,
    required String initialSelectedCode,
  }) async{
    String? selectedCode = await showCupertinoDialog<String?>(
      context: context,
      builder: (context) {
        return InternationalAreaCodeDialogWidget(
          initialSelectedCode: initialSelectedCode,
        );
      },
    );
    
    return selectedCode;
  }

}

class InternationalAreaCodeDialogWidget extends StatefulWidget {
  final String initialSelectedCode;
  const InternationalAreaCodeDialogWidget({super.key, required this.initialSelectedCode});

  @override
  State<InternationalAreaCodeDialogWidget> createState() => _InternationalAreaCodeDialogWidgetState();
}

class _InternationalAreaCodeDialogWidgetState extends State<InternationalAreaCodeDialogWidget> {
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  List<InternationalAreaCodeEntityList> internationalAreaCodes = [];
  List<InternationalAreaCodeEntityList> showInternationalAreaCodes = [];

  String? selectedCode;

  @override
  void initState() {
    super.initState();
    selectedCode = widget.initialSelectedCode;
    getInternationalAreaCodeList();
  }

  Future<void> getInternationalAreaCodeList() async{
    try {
      InternationalAreaCodeEntity? entity = await AccountUtil.getInternationalAreaCodeList();
      if(entity == null) return;
      if(entity.list == null) return;
      List<InternationalAreaCodeEntityList?> list = entity.list!;
      internationalAreaCodes.clear();
      for(int i = 0; i < list.length; i++){
        if(list[i] == null) continue;
        if(list[i]!.callingCode == null) continue;
        internationalAreaCodes.add(list[i]!);
      }
      showInternationalAreaCodes = internationalAreaCodes.toList();
    } finally{
      isLoading = false;
      if(mounted) setState(() {});
    }
  }


  /// 搜索国家名称或区号
  void searchInternationalAreaCode(){
    String searchText = searchController.text.trim().toLowerCase();
    if(searchText.isEmpty){
      showInternationalAreaCodes = internationalAreaCodes.toList();
      if(mounted) setState(() {});
      return;
    }
    showInternationalAreaCodes.clear();

    for(int i = 0; i < internationalAreaCodes.length; i++){
      String chinese = internationalAreaCodes[i].chinese?.toLowerCase()??"";
      String english = internationalAreaCodes[i].english?.toLowerCase()??"";
      String callingCode = internationalAreaCodes[i].callingCode?.toLowerCase()??"";
      if(chinese.contains(searchText) || english.contains(searchText) || callingCode.contains(searchText)){
        showInternationalAreaCodes.add(internationalAreaCodes[i]);
      }
    }
    
    if(mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CardDialogBoxWidget(
      title: "选择国家地区",
      onCancel: () => Get.back(),
      onConfirm: () {
        if(selectedCode == null) return;
        Get.back(result: selectedCode);
      },
      child: isLoading ? Center(
        child: SpinKitFadingCircle(
          color: AppTheme.cBgBrand.color,
          size: 100.wMin,
        ),
      ) : _buildBodyWidget(),
    );
  }

  /// 构建弹窗内容
  Widget _buildBodyWidget() {
    return Column(
      children: [
        _buildSearchWidget(),
        Expanded(
          child: ListView.separated(
            itemCount: showInternationalAreaCodes.length,
            padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 8.wMin),
            separatorBuilder: (context, index) {
              return Container(height: 1.wMin, color: AppTheme.cBorderPrimary);
            },
            itemBuilder: (context, index) {
              return _buildItemWidget(index, showInternationalAreaCodes[index]);
            },
          ),
        ),
      ],
    );
  }

  /// 搜索框
  Widget _buildSearchWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.wMin),
      child: CardInputWidget(
        hintText: "搜索国家名称或区号",
        controller: searchController,
        onClean: (){
          searchController.clear();
          if(mounted) setState(() {});
        },
        onChanged: (value) {
          searchInternationalAreaCode();
        },
      ),
    );
  }

  Widget _buildItemWidget(int index, InternationalAreaCodeEntityList data){
    return TapScaleWidget(
      onTap: () {
        selectedCode = data.callingCode;
        if(mounted) setState(() {});
      },
      sclae: 1,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 16.wMin),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    constraints: BoxConstraints(minWidth: 90.wMin),
                    child: Text(
                      "+${data.callingCode??''}",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w400,
                        color: selectedCode == data.callingCode ? AppTheme.cTextBrand.color : AppTheme.cTextPrimary.color,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.wMin),
                  Text(
                    data.chinese??'',
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                      color: selectedCode == data.callingCode ? AppTheme.cTextBrand.color : AppTheme.cTextPrimary.color,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.wMin),
            Visibility(
              visible: selectedCode == data.callingCode,
              child: SvgPicture.asset(
                "assets/svg/public/icon_check.svg",
                width: 32.wMin,
              ),
            )
          ],
        ),
      ),
    );
  }

}