import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';

/// 选择工单
class ManageSelectTicketDialog{
  /// 显示选择工单模版弹窗
  static Future<ManageTicketTempEntity?> show({
    required BuildContext context,
    ManageTicketTempEntity? defaultTicketTemp,
  }){
    return showDialog<ManageTicketTempEntity?>(
      context: context,
      builder: (context){
        return ManageSelectTicketDialogWidget(defaultTicketTemp: defaultTicketTemp);
      },
    );
  }
}

class ManageSelectTicketDialogWidget extends StatefulWidget {
  final ManageTicketTempEntity? defaultTicketTemp;
  const ManageSelectTicketDialogWidget({super.key, this.defaultTicketTemp});

  @override
  State<ManageSelectTicketDialogWidget> createState() => _ManageSelectTicketDialogWidgetState();
}

class _ManageSelectTicketDialogWidgetState extends State<ManageSelectTicketDialogWidget> {
 
  List<ManageTicketTempEntity> ticketTempList = [];

  /// 搜索输入框
  final TextEditingController searchController = TextEditingController();

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();
  /// 总条数
  int total = 0;
  /// offset
  int offset = 0;
  /// limit
  int limit = 40;
  /// 是否加载中
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    listenScroll();
    refreshList();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange){
        if(!isLoading && ticketTempList.length < total){
          offset += limit;
          getTicketTempList();
        }
      }
    });
  }

  /// 刷新列表
  Future<void> refreshList() async{
    ticketTempList.clear();
    offset = 0;
    total = 0;
    getTicketTempList();
  }

  /// 获取工单模版列表
  Future<void> getTicketTempList() async {
    try {
      isLoading = true;
      ToastUtils.showLoading();
      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };

      Map<String, dynamic> reqData = {};

      if(searchController.text.trim().isNotEmpty){
        reqData['content'] = searchController.text.trim();
      }

      ListResponseEntity<ManageTicketTempEntity>? list = await AccountConsoleRequest.getManageTicketTempList(params: params, data: reqData);
      if(list == null) return;
      total = list.count??0;
      ticketTempList.addAll(list.datas??[]);
    }finally{
      isLoading = false;
      ToastUtils.hideLoading();
      if(mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "选择工单模版",
      width: 960.wMin,
      child: SizedBox(
        height: 900.wMin,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 32.wMin),
              child: CardInputWidget(
                controller: searchController,
                hintText: "搜索模版名称 / 说明",
                onSubmitted: (value) {
                  refreshList();
                },
                onClean: () {
                  searchController.clear();
                  refreshList();
                },
              ),
            ),
            SizedBox(height: 16.wMin),
            Expanded(child: _buildListWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildListWidget(){
    return ListView.separated(
      itemCount: ticketTempList.length,
      controller: scrollController,
      padding: EdgeInsets.only(bottom: 24.wMin, left: 32.wMin, right: 32.wMin),
      separatorBuilder: (context, index){
        return SizedBox(height: 16.wMin);
      },
      itemBuilder: (context, index){
        return _buildItemWidget(ticketTempList[index]);
      },
    );
  }

  Widget _buildItemWidget(ManageTicketTempEntity item){

    return TapScaleWidget(
      onTap: () {
        Get.back(result: item);
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderTranslucentNone.color,
            width: 1.wMin,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    item.name??"",
                    style: TextStyle(
                      color: AppTheme.cTextPrimary.color,
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Visibility(
                    visible: item.introduce != null,
                    child: Container(
                      margin: EdgeInsets.only(top: 6.wMin),
                      child: SelectableText(
                        item.introduce??'',
                        style: TextStyle(
                          color: AppTheme.cTextSecondary.color,
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.wMin),
            ButtonWidget(
              text: "选择此模版",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.1),
              border: Border.all(
                color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                width: 1.wMin,
              ),
              fontColor: AppTheme.cTextBrand.color,
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
  
}