import 'package:flutter/cupertino.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';

/// 学员操作历史
class ManageInspectionHistoryDialog{
  static Future<void> show({
    required BuildContext context,
    required ManageEmployeeConsoleMemberEntity data,
  }) async{
    return await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ManageInspectionHistoryDialogWidget(data: data);
      },
    );
  }
}

class ManageInspectionHistoryDialogWidget extends StatefulWidget {
  final ManageEmployeeConsoleMemberEntity data;
  const ManageInspectionHistoryDialogWidget({super.key, required this.data});

  @override
  State<ManageInspectionHistoryDialogWidget> createState() => _ManageInspectionHistoryDialogWidgetState();
}

class _ManageInspectionHistoryDialogWidgetState extends State<ManageInspectionHistoryDialogWidget> {


  /// 操作历史列表
  List<ManageInspectionHistoryEntity> historyList = [];

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
        if(!isLoading && historyList.length < total){
          offset += limit;
          _queryUserList();
        }
      }
    });
  }

  /// 刷新列表
  Future<void> refreshList() async{
    historyList.clear();
    offset = 0;
    total = 0;
    _queryUserList();
  }

  /// 查询用户列表
  Future<void> _queryUserList() async{
    try {
      isLoading = true;
      ToastUtils.showLoading();

      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
        "order": "-created",
      };
      Map<String, dynamic> reqData = {
        "userId": widget.data.userId,
        "teamId": widget.data.teamId,
        "memberId": widget.data.memberId,
      };

      ListResponseEntity<ManageInspectionHistoryEntity>? list = await AccountConsoleRequest.getInspectionHistory(params: params, data: reqData);
      if(list == null) return;
      total = list.count??0;
      historyList.addAll(list.datas??[]);
    } finally{
      isLoading = false;
      if(mounted) setState(() {});
      ToastUtils.hideLoading();
    }
  }  



  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "历史操作·${widget.data.name??''}",
      width: 960.wMin,
      child: SizedBox(
        height: 800.wMin,
        child: _buildListWidget(),
      ),
    );
  }

  Widget _buildListWidget(){
    if(historyList.isEmpty && !isLoading){
      return NotDataWidget(
        message: "暂无历史记录",
      );
    }

    return ListView.separated(
      itemCount: historyList.length,
      controller: scrollController,
      padding: EdgeInsets.only(bottom: 24.wMin, left: 32.wMin, right: 32.wMin),
      separatorBuilder: (context, index){
        return SizedBox(height: 24.wMin);
      },
      itemBuilder: (context, index){
        return _buildItemWidget(historyList[index]);
      },
    );
  }

  Widget _buildItemWidget(ManageInspectionHistoryEntity item){
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderTranslucentNone.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title??'',
                  style: TextStyle(
                    color: AppTheme.cTextPrimary.color,
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // SizedBox(width: 10.wMin),
              // Container(
              //   padding: EdgeInsets.all(6.wMin),
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(99),
              //     color: AppTheme.cSurfaceTertiary.color,
              //     border: Border.all(
              //       color: AppTheme.cBorderSecondary.color,
              //       width: 0.8.wMin,
              //     ),
              //   ),
              //   child: Text(
              //     "转交",
              //     style: TextStyle(
              //       color: AppTheme.cTextSecondary.color,
              //       fontSize: 18.wMin,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 4.wMin),
          Text(
            // "${item.actorName??''} · 值班专员",
            item.actorName??'',
            style: TextStyle(
              color: AppTheme.cTextTertiary.color,
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 12.wMin),
          Text(
            item.content??'',
            style: TextStyle(
              color: AppTheme.cTextSecondary.color,
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 12.wMin),
          Text(
            DateFormatUtil.formatStrtoStr(item.created, newPattern: "yyyy-MM-dd HH:mm:ss"),
            style: TextStyle(
              color: AppTheme.cTextTertiary.color,
              fontSize: 14.wMin,
              fontWeight: FontWeight.w400,
            ),
          ), 


        ],
      ),
    );
  }

}