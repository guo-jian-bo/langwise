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
import '../../../../utils/utils.dart';
import '../bindings/manage_channel_binding.dart';
import '../controllers/manage_channel_controller.dart';

class ManageChannelView extends GetView<ManageChannelController> {
  final String tagText;
  const ManageChannelView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CHANNEL}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageChannelView(tagText: tag),
      binding: ManageChannelBinding(tag: tag),
      routeName: Routes.MANAGE_CHANNEL,
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
            authCodes: [ManageAuthCode.channelCreateV2],
            margin: EdgeInsets.only(left: 18.wMin),
            child: ButtonWidget(
              text: "新建一级渠道",
              height: 54.wMin,
              padding: EdgeInsets.symmetric(horizontal: 32.wMin),
              borderRadius: 99,
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
              fontColor: AppTheme.cSurfaceBrand.color,
              fontWeight: FontWeight.w500,
              fontSize: 24.wMin,
              sclae: 1.03,
              onTap: () async {
                await controller.createChannel();
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
            "渠道管理",
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(width: 24.wMin),
          Text(
            "两级购买渠道：一级是渠道大类，二级是具体来源（如 官方 · 社群、代理商 · 王五）。每个渠道拥有唯一 ID，供学员卡与权限引用。",
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
      if(controller.channelList.isEmpty && !controller.isLoading.value){
        return Center(
          child: NotDataWidget(
            message: "暂无通知模版",
          ),
        );
      }
      return ListView.separated(
        itemCount: controller.channelList.length,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 70.wMin, right: 70.wMin, top: 6.wMin),
        separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
        itemBuilder: (context, index) {
          return _buildListItemWidget(controller.channelList[index]);
        },
      );
    });
  }

  Widget _buildListItemWidget(ManageChannelEntity channel){
    bool isEnabled = channel.access == AccessEnum.NORMAL.value;

    List<ManageChannelEntityChildren> subChannels = channel.children??[];

    return TapScaleWidget(
      onTap: () {
        controller.editChannel(channel);
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
                _buildListItemTagWidget("uid:${channel.uid??''}"),
                SizedBox(width: 10.wMin),
                _buildListItemTagWidget("code:${channel.code??''}"),
                SizedBox(width: 10.wMin),
                SelectableText(
                  "${subChannels.length}个二级渠道 · 更新：${DateFormatUtil.getTimeAgoText(DateFormatUtil.tryParseDate(channel.updated))}",
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
              channel.name??'',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            SizedBox(height: 10.wMin),
            SelectableText(
              channel.description??'',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            Visibility(
              visible: subChannels.isNotEmpty,
              child: Container(
                margin: EdgeInsets.only(top: 10.wMin),
                child: Wrap(
                  spacing: 8.wMin,
                  runSpacing: 8.wMin,
                  children: List.generate(subChannels.length, (index){
                    String subChannelName = subChannels[index].name ?? "";
                    if(subChannels[index].ownerId != null){
                      if((subChannels[index].ownerName??"").isNotEmpty){
                        subChannelName += "·${subChannels[index].ownerName ?? ''}";
                      }else{
                        subChannelName += "·${subChannels[index].ownerId ?? ''}";
                      }
                    }
                    return _buildChannelTagWidget(subChannelName);
                  }),
                ),
              ),
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
        color: AppTheme.cSurfaceTertiary.color,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppTheme.cBorderSecondary.color,
          width: 1.wMin,
        ),
      ),
      child: SelectableText(
        text,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextSecondary.color,
        ),
      ),
    );
  }

  /// 二级渠道标签
  Widget _buildChannelTagWidget(String? text){
    if(text == null) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
          width: 1.wMin,
        ),
      ),
      child: SelectableText(
        text,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cSurfaceWarning.color,
        ),
      ),
    );
  }

}
