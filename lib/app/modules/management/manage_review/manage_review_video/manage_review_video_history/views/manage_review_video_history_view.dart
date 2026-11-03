import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../bindings/manage_review_video_history_binding.dart';
import '../controllers/manage_review_video_history_controller.dart';
import 'manage_video_history_review_item_widget.dart';

class ManageReviewVideoHistoryView extends GetView<ManageReviewVideoHistoryController> {
  final String tagText;
  const ManageReviewVideoHistoryView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_REVIEW_VIDEO_HISTORY}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageReviewVideoHistoryView(tagText: tag),
      binding: ManageReviewVideoHistoryBinding(tag: tag),
      routeName: Routes.MANAGE_REVIEW_VIDEO_HISTORY,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Column(
        children: [
          SizedBox(height: 10.wMin),
          _buildHeardWidget(),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.videoReviewAuditStatistics],
            child: _buildAdministratorFilteringWidget(context),
          ),
          SizedBox(height: 10.wMin),
          Container(
            height: 1.wMin,
            color: AppTheme.cBorderPrimary.color,
          ),
          Expanded(child: _buildHistoryListWidget(context)),
          
        ],
      ),
    );
  }

  Widget _buildHeardWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Row(
        children: [

          Builder(
            builder: (context) {
              return TapScaleWidget(
                onTap: () {
                  controller.filterTime(context);
                },
                sclae: 1.02,
                child: Container(
                  height: 50.wMin,
                  padding: EdgeInsets.only(left: 16.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: AppTheme.cSurfaceSecondary.color,
                    border: Border.all(
                      color: AppTheme.cBorderPrimary.color,
                      width: 1.wMin,
                    ),
                  ),
                  child: Obx((){

                    String startDate = "";
                    String endDate = "";
                    
                    if(controller.startDate.value == null || controller.endDate.value == null){
                      startDate = "开始日期";
                      endDate = "结束日期";
                    }else{
                      startDate = DateFormatUtil.formatStr(controller.startDate.value!);
                      endDate = DateFormatUtil.formatStr(controller.endDate.value!);
                    }


                    return Row(
                    children: [
                      Text(
                        "$startDate ～ $endDate",
                          style: TextStyle(
                            color: AppTheme.cTextPrimary.color,
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TapScaleWidget(
                          onTap: () {
                            controller.clearFilterTime();
                          },
                          sclae: 1.1,
                          child: Container(
                            width: 50.wMin,
                            height: 50.wMin,
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              "assets/svg/public/x.svg",
                              width: 28.wMin,
                            ),
                          ),
                          
                        ),

                      ],
                    );
                  }),
                ),
              );
            },
          ),

          const Spacer(),
      
         Obx((){
          return PagerWidget(
            pageSize: controller.limit,
            dataCount: controller.totalCount.value,
            controller: controller.pagerController,
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


  Widget _buildAdministratorFilteringWidget(BuildContext context){
    if(!controller.fromAdmin) return Container();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [


          Text(
            "审核员：",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w400,
            ),
          ),

          Obx((){

            String? selectedAuditor = controller.auditorList.firstWhereOrNull((element) => element.userId == controller.selectedUserId.value)?.userName;

            return IconDropdownMenuWidget(
              sclae: 1.03,
              width: 200.wMin,
              textStyle: TextStyle(
                color: AppTheme.cTextPrimary.color,
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
              ),
              items: List.generate(controller.auditorList.length, (index){
                return IconDropdownIconData<int?>(
                  title: controller.auditorList[index].userName,
                  value: controller.auditorList[index].userId,
                );
              }),
              onTap: (data, index) {
                controller.filterAuditor(data.value);
              },
              child: Container(
                height: 54.wMin,
                width: 200.wMin,
                padding: EdgeInsets.only(right: 10.wMin),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.cSurfaceSecondary.color,
                  borderRadius: BorderRadius.circular(10.wMin),
                  border: Border.all(color: AppTheme.cBorderPrimary.color, width: 1.wMin),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          selectedAuditor??"",
                          style: TextStyle(
                            color: AppTheme.cTextPrimary.color,
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      "assets/svg/manage/icon_arrow_down.svg",
                      width: 24.wMin,
                      height: 24.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            );
          }),

          SizedBox(width: 20.wMin),

          ButtonWidget(
            text: "查看统计",
            height: 50.wMin,
            width: 120.wMin,
            borderRadius: 10.wMin,
            color: const Color(0xff353E5C),
            fontColor: Colors.white,
            fontSize: 20.wMin,
            fontWeight: FontWeight.w400,
            sclae: 1.05,
            onTap: () {
              controller.toStatistics();
            },
          ),
      
          
      
        ],
      ),
    );
  }


  Widget _buildHistoryListWidget(BuildContext context){
    return Obx((){
      return ListView.separated(
        itemCount: controller.videoReviewList.length,
        padding: EdgeInsets.only(
          top: 16.wMin,
          bottom: 120.wMin + MediaQuery.of(context).padding.bottom,
          left: 40.wMin,
          right: 40.wMin,
        ),
        separatorBuilder: (context, index) {
          return SizedBox(height: 24.wMin);
        },
        itemBuilder: (context, index) {
          return ManageVideoHistoryReviewItemWidget(
            data: controller.videoReviewList[index],
            controller: controller,
          );
        },
      );
    });
  }


}
