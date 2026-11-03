import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../bindings/manage_notice_temp_binding.dart';
import '../controllers/manage_notice_temp_controller.dart';

class ManageNoticeTempView extends GetView<ManageNoticeTempController> {
  final String tagText;
  const ManageNoticeTempView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_NOTICE_TEMP}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageNoticeTempView(tagText: tag),
      binding: ManageNoticeTempBinding(tag: tag),
      routeName: Routes.MANAGE_NOTICE_TEMP,
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
            authCodes: [ManageAuthCode.notifyTemplateCreate],
            margin: EdgeInsets.only(left: 18.wMin),
            child: ButtonWidget(
              text: "新建通知模版",
              height: 54.wMin,
              padding: EdgeInsets.symmetric(horizontal: 32.wMin),
              borderRadius: 99,
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
              fontColor: AppTheme.cSurfaceBrand.color,
              fontWeight: FontWeight.w500,
              fontSize: 24.wMin,
              sclae: 1.03,
              onTap: () {
                controller.navigateToCreateNoticeTemp();
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
            "通知管理",
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(width: 24.wMin),
          Text(
            "维护 push 模板：固有标题与内容、跳进 APP 的 Markdown 详情，以及无 / H5 / Deeplink 跳转配置。",
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
      if(controller.noticeTempList.isEmpty && !controller.isLoading.value){
        return Center(
          child: NotDataWidget(
            message: "暂无通知模版",
          ),
        );
      }
      return ListView.separated(
        itemCount: controller.noticeTempList.length,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 70.wMin, right: 70.wMin, top: 6.wMin),
        separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
        itemBuilder: (context, index) {
          return _buildListItemWidget(controller.noticeTempList[index]);
        },
      );
    });
  }

  Widget _buildListItemWidget(NotifyTempEntity item){
    bool isEnabled = item.access == AccessEnum.NORMAL.value;
    return TapScaleWidget(
      onTap: () {
        controller.editNoticeTemp(item);
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
                _buildListItemTagWidget(controller.getNotifyTempTypeTitle(item.type)),
                SizedBox(width: 10.wMin),
                _buildListItemTagWidget(item.notifyContentTypeTitle),
                SizedBox(width: 10.wMin),
                _buildListItemTagWidget(item.jumpType),
                SizedBox(width: 10.wMin),
                Text(
                  "更新：${DateFormatUtil.getTimeAgoText(DateTime.parse("2026-07-17 12:00:00"))}",
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
            SizedBox(height: 10.wMin),
            SelectableText(
              item.notifyTitle??"",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            SelectableText(
              item.notifyDesc??"",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            SizedBox(height: 10.wMin),
            Visibility(
              visible: item.jumpUrl != null,
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/svg/public/icon_deeplink.svg",
                    width: 18.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                  ),
                  SizedBox(width: 6.wMin),
                  SelectableText(
                    item.jumpPageCodeTitle??"",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
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

  Widget _buildListItemTagWidget(String? text){
    if(text == null) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.12),
          width: 1.wMin,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextBrand.color,
        ),
      ),
    );
  }


}
