import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';

/// 工单列表弹窗
class WorkOrderListDialog{
  static Future<void> show(BuildContext context) async{
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return const WorkOrderListDialogWidget();
      },
    );
  }
}


class WorkOrderListDialogWidget extends StatefulWidget {
  const WorkOrderListDialogWidget({super.key});

  @override
  State<WorkOrderListDialogWidget> createState() => _WorkOrderListDialogWidgetState();
}

class _WorkOrderListDialogWidgetState extends State<WorkOrderListDialogWidget> {

  final ScrollController scrollController = ScrollController();
  int totalCount = 0;
  int offset = 0;
  int limit = 20;
  bool loading = true;
  /// 工单列表
  List<UserWordOrderEntity> workOrderList = <UserWordOrderEntity>[];
  

  @override
  void initState(){
    super.initState();
    getWorkOrderList();
    scrollController.addListener(scrollControllerListener);
  }

  @override
  void dispose(){
    try {
      scrollController.removeListener(scrollControllerListener);
    } catch (_) {}
    super.dispose();
  }

  void scrollControllerListener(){
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100 && !scrollController.position.outOfRange) {
      if ((offset + limit) < totalCount && !loading) {
        loading = true;
        offset += limit;
        getWorkOrderList();
      }
    }
  }

  Future<void> getWorkOrderList() async {
    try {
      ToastUtils.showLoading();
      loading = true;
      final ListResponseEntity<UserWordOrderEntity>? listResponseEntity = await AccountUtil.getWorkOrderList();
      if (listResponseEntity == null) return;
      totalCount = listResponseEntity.count ?? 0;
      workOrderList.addAll(listResponseEntity.datas ?? []);
    } finally{
      loading = false;
      ToastUtils.hideLoading();
      if(mounted) setState(() {});
    }
  }

  /// 刷新指定工单
  Future<void> getWorkOrderDetail(int? recordId) async{
    if(recordId == null) return;
    try {
      final UserWordOrderEntity? workOrderEntity = await AccountUtil.getWorkOrderDetail(recordId: recordId);
      if (workOrderEntity == null) return;
      final int index = workOrderList.indexWhere((element) => element.uid == recordId);
      if(index == -1) return;
      workOrderList[index] = workOrderEntity;
      if(mounted) setState(() {});
    } catch (_) {}
  }

  /// 查看
  Future<void> viewWorkOrder(UserWordOrderEntity workOrder) async{
    if(workOrder.jump == null){
      ToastUtils.showToast(text: "此工单信息异常");
      return;
    }
    await JumpPageUtils.jumpUserPages(workOrder.jump);
    await getWorkOrderDetail(workOrder.uid);
  }


  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "我的工单",
      width: 1680.wMin,
      child: SizedBox(
        height: 800.wMin,
        child: _buildListWidget(),
      ),
    );
  }

  Widget _buildListWidget(){
    if(workOrderList.isEmpty && !loading){
      return NotDataWidget(
        message: "暂无工单",
      );
    }
    return ListView.separated(
      controller: scrollController,
      itemCount: workOrderList.length,
      padding: EdgeInsets.only(
        left: 32.wMin,
        right: 32.wMin,
        bottom: 32.wMin,
      ),
      separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
      itemBuilder: (context, index) {
        return _buildItemWidget(workOrderList[index]);
      },
    );
  }

  Widget _buildItemWidget(UserWordOrderEntity workOrder){

    Color statusColor = workOrder.statusEnum?.color ?? AppTheme.cSurfaceError.color;
    String buttonText = "查看详情";
    if(workOrder.statusEnum == UserWordOrderStatusEnum.no_submit){
      buttonText = "查看并填写";
    }else if(workOrder.statusEnum == UserWordOrderStatusEnum.revision_required){
      buttonText = "修改";
    }

    return TapScaleWidget(
      onTap: () {
        viewWorkOrder(workOrder);
      },
      sclae: 1,
      child: Stack(
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            padding: EdgeInsets.all(24.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              border: Border.all(color: AppTheme.cBorderSubtle.color, width: 1.wMin),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        workOrder.name??"",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.wMin),
                    ButtonWidget(
                      text: workOrder.statusEnum?.label??"",
                      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                      color: statusColor.withValues(alpha: 0.1),
                      border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 0.8.wMin),
                      fontWeight: FontWeight.w400,
                      fontSize: 18.wMin,
                      fontColor: statusColor,
                    ),
                  ],
                ),
                Visibility(
                  visible: workOrder.introduce != null,
                  child: Container(
                    margin: EdgeInsets.only(top: 4.wMin),
                    child: Text(
                      workOrder.introduce??"",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextTertiary.color,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: workOrder.handleRemark != null,
                  child: Container(
                    margin: EdgeInsets.only(top: 4.wMin),
                    child: Text(
                      workOrder.handleRemark??"",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cSurfaceWarning.color,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4.wMin),
                Row(
                  children: [
                    Visibility(
                      visible: workOrder.submit != null,
                      child: Text(
                        "提交时间：${DateFormatUtil.formatStrtoStr(workOrder.submit, newPattern: "yyyy-MM-dd HH:mm:ss")}",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextTertiary.color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ButtonWidget(
                      text: buttonText,
                      width: 122.wMin,
                      padding: EdgeInsets.symmetric(vertical: 4.wMin),
                      color: AppTheme.cSurfaceBrand.color,
                      border: Border.all(color: AppTheme.cTextBrand.color, width: 0.8.wMin),
                      fontWeight: FontWeight.w400,
                      fontSize: 18.wMin,
                    ),
                  ],
                ),
          
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Visibility(
              visible: workOrder.statusEnum == UserWordOrderStatusEnum.no_submit || workOrder.statusEnum == UserWordOrderStatusEnum.revision_required,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 2.wMin),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.wMin),
                  ),
                ),
                child: Text(
                  "NEW",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: statusColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
