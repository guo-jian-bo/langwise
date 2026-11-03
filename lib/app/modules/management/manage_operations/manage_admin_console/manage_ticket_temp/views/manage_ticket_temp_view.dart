import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../utils/manage_auth_utils.dart';
import '../bindings/manage_ticket_temp_binding.dart';
import '../controllers/manage_ticket_temp_controller.dart';

class ManageTicketTempView extends GetView<ManageTicketTempController> {
  final String tagText;
  const ManageTicketTempView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_TICKET_TEMP}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageTicketTempView(tagText: tag),
      binding: ManageTicketTempBinding(tag: tag),
      routeName: Routes.MANAGE_TICKET_TEMP,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ManageScaffold(
        onRefresh: () {
          controller.refreshList();
        },
        body: Column(
          children: [
            _buildTitleWidget(),
            SizedBox(height: 10.wMin),
            Expanded(child: _buildListWidget()),
          ],
        ),
        floatingActionButton: _buildFilterWidget(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70.wMin),
      child: Row(
        children: [
          Expanded(
            child: Obx((){
              return FilterStripWidget(
                sorts: {...controller.filterSorts},
                conditions: {...controller.filterConditions},
                searchs: controller.filterSearchs,
                onSorts: (sorts) {
                  controller.filterSorts.value = sorts;
                  controller.refreshList();
                },
                onConditions: (conditions) {
                  controller.filterConditions.value = conditions;
                  controller.refreshList();
                },
                onReset: (sorts, conditions) {
                  controller.filterSorts.value = sorts;
                  controller.filterConditions.value = conditions;
                  controller.refreshList();
                },
                onSearch: () {
                  controller.refreshList();
                },
              );
            }),
          ),
          ManageAuthBoxWidget(
            authCodes: [ManageAuthCode.channelTicketTemplateCreate],
            margin: EdgeInsets.only(left: 18.wMin),
            child: ButtonWidget(
              text: "新建工单模版",
              height: 54.wMin,
              padding: EdgeInsets.symmetric(horizontal: 32.wMin),
              borderRadius: 99,
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
              fontColor: AppTheme.cSurfaceBrand.color,
              fontWeight: FontWeight.w500,
              fontSize: 24.wMin,
              sclae: 1.03,
              onTap: () async {
                await controller.createTicketTemp();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70.wMin),
      margin: EdgeInsets.only(top: 16.wMin),
      child: Row(
        children: [
          Text(
            "工单模版管理",
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(width: 24.wMin),
          Text(
            "像表单搭建器一样工单插入多种表单项，定义学员/工作人员填写工单时收集的字段。",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListWidget(){
    return Obx((){
      if(controller.ticketTempList.isEmpty && !controller.isLoading.value){
        return Center(
          child: NotDataWidget(
            message: "暂无工单模版",
          ),
        );
      }
      return ListView.separated(
        controller: controller.scrollController,
        itemCount: controller.ticketTempList.length,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 70.wMin, right: 70.wMin, top: 6.wMin),
        separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
        itemBuilder: (context, index) {
          return _buildListItemWidget(controller.ticketTempList[index]);
        },
      );
    });
  }

  Widget _buildListItemWidget(ManageTicketTempEntity item){
    bool isEnabled = item.access == AccessEnum.NORMAL.value;
    List<ManageTicketTempEntityOptions?> options = item.options ??[];

    return TapScaleWidget(
      onTap: () {
        controller.editTicketTemp(item);
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase.color,
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(
            color: AppTheme.cBorderNone.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            Row(
              children: [
                _buildListItemTagWidget("${item.options?.length??0}个表单项"),
                SizedBox(width: 10.wMin),
                Text(
                  "更新：${DateFormatUtil.getTimeAgoText(DateFormatUtil.tryParseDate(item.updated))}",
                  style: TextStyle(
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
      
                const Spacer(),
      
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                  decoration: BoxDecoration(
                    color: isEnabled ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2) : AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6.wMin),
                    border: Border.all(
                      color: isEnabled ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12) : AppTheme.cSurfaceError.color.withValues(alpha: .12),
                      width: 1.wMin,
                    ),
                  ),
                  child: Text(
                    isEnabled ? "已启用" : "已停用",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: isEnabled ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceError.color,
                    ),
                  ),
                ),
      
              ],
            ),
      
            SizedBox(height: 16.wMin),
            SelectableText(
              item.name??"",
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            Visibility(
              visible: item.introduce != null,
              child: Container(
                margin: EdgeInsets.only(top: 10.wMin),
                child: SelectableText(
                  item.introduce??"",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.wMin),
            Wrap(
              spacing: 8.wMin,
              runSpacing: 8.wMin,
              children: List.generate(options.length, (index){
                ManageTicketTempEntityOptions? option = options[index];
                if(option == null) return SizedBox.shrink();
                return _buildFormItemTagWidget(
                  option.name??"", 
                  option.formTypeEnum?.name??"", 
                  option.must??false,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItemTagWidget(String? text){
    if(text == null) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppTheme.cSurfaceError.color.withValues(alpha: 0.12),
          width: 1.wMin,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cSurfaceError.color,
        ),
      ),
    );
  }

  /// 表单项标签
  Widget _buildFormItemTagWidget(String text, String type, bool isRequired){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 0.8.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          SizedBox(width: 4.wMin),
          Text(
            type,
            style: TextStyle(
              fontSize: 14.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          Visibility(
            visible: isRequired,
            child: Container(
              margin: EdgeInsets.only(left: 4.wMin),
              child: Text(
                "必填",
                style: TextStyle(
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cSurfaceError.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
