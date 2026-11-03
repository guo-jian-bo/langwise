import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'package:langwise/app/modules/management/common/commons.dart';
import '../bindings/manage_zhendu_generate_task_binding.dart';
import '../controllers/manage_zhendu_generate_task_controller.dart';

class ManageZhenduGenerateTaskView extends GetView<ManageZhenduGenerateTaskController> {
  final String tagText;
  const ManageZhenduGenerateTaskView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_ZHENDU_GENERATE_TASK}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageZhenduGenerateTaskView(tagText: tag),
      binding: ManageZhenduGenerateTaskBinding(tag: tag),
      routeName: Routes.MANAGE_ZHENDU_GENERATE_TASK,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.refreshListData(),
      body: Column(
        children: [
          _buildTitleWidget(),
          Expanded(
            child: Obx((){
              return ListView.separated(
                itemCount: controller.dataList.length,
                padding: EdgeInsets.only(
                  left: 150.wMin,
                  right: 150.wMin,
                  top: 10.wMin,
                  bottom: 200.wMin,
                ),
                separatorBuilder: (context, index) => SizedBox(height: 10.wMin),
                itemBuilder: (context, index) {
                  return _buildItemWidget(controller.dataList[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 150.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx((){
            return PagerWidget(
              dataCount: controller.totalCount.value,
              controller: controller.pagerController,
              pageSize: controller.limit,
              visiblePageCount: 3,
              activeColor: AppTheme.cTextPrimary.color,
              onPage: (page, pageSize) {
                controller.pagerCallback(page, pageSize);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemWidget(ManageZhenduGenerateTaskEntity entity){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
      decoration: BoxDecoration(
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        color: AppTheme.cSurfaceSecondary.color,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              ManageTagFS16Widget(
                tag: "taskId: ${entity.taskId ?? ''}",
                fontColor: AppTheme.cTextSecondary.color,
              ),
              Visibility(
                visible: entity.targetId != null,
                child: Container(
                  margin: EdgeInsets.only(left: 10.wMin),
                  child: ManageTagFS16Widget(
                    tag: "targetId: ${entity.targetId ?? ''}",
                    fontColor: AppTheme.cTextSecondary.color,
                  ),
                ),
              ),
              Visibility(
                visible: entity.imageId != null,
                child: Container(
                  margin: EdgeInsets.only(left: 10.wMin),
                  child: ManageTagFS16Widget(
                    tag: "imageId: ${entity.imageId ?? ''}",
                    fontColor: AppTheme.cTextSecondary.color,
                  ),
                ),
              ),
              Visibility(
                visible: entity.status != null,
                child: Container(
                  margin: EdgeInsets.only(left: 10.wMin),
                  child: ManageTagFS16Widget(
                    tag: "status: ${entity.status ?? ''}",
                    fontColor: AppTheme.cTextSecondary.color,
                  ),
                ),
              ),

            ],
          ),

          SizedBox(height: 6.wMin),

          Visibility(
            visible: entity.errMsg != null && entity.errMsg?.isNotEmpty == true,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.wMin),
              ),
              child: SelectableText(
                "errMsg: ${entity.errMsg ?? ''}",
                style: TextStyle(
                  color: AppTheme.cSurfaceError.color,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          

          Visibility(
            visible: entity.params?.title != null,
            child: Container(
              margin: EdgeInsets.only(top: 6.wMin),
              child: SelectableText(
                entity.params?.title ?? '',
                style: TextStyle(
                  color: AppTheme.cTextPrimary.color,
                  fontSize: 22.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          Visibility(
            visible: entity.contentList != null && entity.contentList?.isNotEmpty == true,
            child: Container(
              margin: EdgeInsets.only(top: 6.wMin),
              child: SelectableText(
                "contentList: ${entity.contentList?.map((e) => "uid: ${e?.uid ?? ''}, type: ${e?.type ?? ''}").toList()}",
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          Visibility(
            visible: entity.params?.content != null,
            child: Container(
              margin: EdgeInsets.only(top: 6.wMin),
              child: SelectableText(
                entity.params?.content ?? '',
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          Visibility(
            visible: entity.params?.lang != null,
            child: Container(
              margin: EdgeInsets.only(top: 6.wMin),
              child: SelectableText(
                "lang: ${entity.params?.lang ?? ''}",
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          Visibility(
            visible: entity.params?.courseInfo != null,
            child: Container(
              margin: EdgeInsets.only(top: 6.wMin),
              child: SelectableText(
                entity.params?.courseInfo ?? '',
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          Visibility(
            visible: entity.params?.scriptType != null,
            child: Container(
              margin: EdgeInsets.only(top: 6.wMin),
              child: SelectableText(
                entity.params?.scriptType ?? '',
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          Visibility(
            visible: entity.params?.audioProjectId != null,
            child: Container(
              margin: EdgeInsets.only(top: 6.wMin),
              child: SelectableText(
                "audioProjectId: ${entity.params?.audioProjectId ?? ''}",
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          Visibility(
            visible: entity.params?.styleId != null,
            child: Container(
              margin: EdgeInsets.only(top: 6.wMin),
              child: SelectableText(
                "styleId: ${entity.params?.styleId ?? ''}",
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          Visibility(
            visible: entity.params?.genres != null,
            child: Container(
              margin: EdgeInsets.only(top: 6.wMin),
              child: SelectableText(
                "genres: ${entity.params?.genres?.join(',') ?? ''}",
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: 6.wMin),
            child: SelectableText(
              "created: ${DateFormatUtil.formatStrtoStr(entity.created, newPattern: "yyyy-MM-dd HH:mm:ss")}",
              style: TextStyle(
                color: AppTheme.cTextSecondary.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),


        ],
      ),
    );
  }


  
}
