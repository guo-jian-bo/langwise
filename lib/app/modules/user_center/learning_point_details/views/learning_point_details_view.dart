import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../routes/routes.dart';
import '../bindings/learning_point_details_binding.dart';
import '../controllers/learning_point_details_controller.dart';

class LearningPointDetailsView extends GetView<LearningPointDetailsController> {
  final String tagText;
  const LearningPointDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => LearningPointDetailsView(tagText: tag),
      binding: LearningPointDetailsBinding(tagText: tag),
      routeName: Routes.LEARNING_POINT_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
        children: [
          const BreadcrumbWidget(),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: 1680.wMin,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx((){
                      String? nextTime = UserStore.to.userInfo.value.nextIssueLearnSomethingTime;
                      String nextTimeStr = DateFormatUtil.formatStrtoStr(nextTime);
                      if(nextTimeStr.isEmpty) return Container();
                      return Text(
                        "下次发放赠送学点时间：$nextTimeStr",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextTertiary.color,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }),
                    SizedBox(height: 10.wMin),
                    Obx((){
                      int points = UserStore.to.userInfo.value.points??0;
                      int totalPoints = UserStore.to.userInfo.value.totalPoints??0;
                      int usePoints = totalPoints - points;
                      return Row(
                        spacing: 16.wMin,
                        children: [
                          _buildCountItemWidget(
                            AppTheme.cLearningPointBalance.color,
                            "当前余额",
                            points,//单位是分
                            "可用学点",
                            "assets/svg/user_center/icon_balance.svg",
                          ),
                          _buildCountItemWidget(
                            AppTheme.cLearningPointTotalIncome.color,
                            "总收入",
                            totalPoints,
                            "累计获得学点",
                            "assets/svg/user_center/icon_trend_up.svg",
                          ),
                          _buildCountItemWidget(
                            AppTheme.cLearningPointTotalExpenditure.color,
                            "总支出",
                            usePoints,
                            "累计消费学点",
                            "assets/svg/user_center/icon_trend_down.svg",
                          ),
                        ],
                      );
                    }),
              _buildRemindWidget(),
              SizedBox(height: 22.wMin),
              _buildTabbarWidget(),
              SizedBox(height: 11.wMin),
              Expanded(
                child: _buildListWidget(context),
              ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildListWidget(BuildContext context){
    return Obx((){
      return ListView.separated(
        itemCount: controller.transactionList.length,
        controller: controller.scrollController,
        padding: EdgeInsets.only(
          top: 10.wMin,
          bottom: 22.wMin + MediaQuery.of(context).padding.bottom,
        ),
        separatorBuilder: (context, index) {
          return Container(height: 1.wMin, color: AppTheme.cBorderSecondary);
        },
        itemBuilder: (context, index) {
          return _buildListItemWidget(context, index, controller.transactionList[index]);
        },
      );
    });
  }

  Widget _buildListItemWidget(BuildContext context, int index, TransactionDetailsEntityTransactions data){
    String points = NumberUtils.formatNumberWithCommas((data.points??0).toDouble());
    String pointsStr = (data.points??0) > 0 ? "+$points" : points;

    String credit = NumberUtils.formatNumberWithCommas((data.credit??0) / 100);
    String creditStr = (data.credit??0) > 0 ? "+$credit" : credit;

    return TapScaleWidget(
      onTap: () {
        controller.jumpTo(context, data);
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 16.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(index == 0 ? 16.wMin : 0),
            bottom: Radius.circular(index == controller.transactionList.length - 1 ? 16.wMin : 0),
          ),
        ),
        child: Row(
          spacing: 12.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SvgPicture.asset(
            //   "assets/svg/user_center/icon_crown1.svg",
            //   width: 38.wMin,
            //   height: 38.wMin,
            // ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        data.title??"",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextPrimary,
                        ),
                      ),
                      Visibility(
                        visible: data.jump != null,
                        child: SvgPicture.asset(
                          "assets/svg/public/icon_arrow_right_thin.svg",
                          width: 20.wMin,
                          colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormatUtil.formatStrtoStr(data.created),
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary,
                    ),
                  ),
                  // SizedBox(height: 8.wMin),
                  // Text(
                  //   "会员等级：Pro，每月赠送60000学点",
                  //   style: TextStyle(
                  //     fontSize: 16.wMin,
                  //     fontWeight: FontWeight.w400,
                  //     color: AppTheme.cTextTertiary,
                  //   ),
                  // ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Visibility(
                  visible: data.points != 0,
                  child: Row(
                    children: [
                      Text(
                        pointsStr,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w500,
                          color: (data.points??0) > 0 ? AppTheme.cLearningPointTotalIncome : AppTheme.cLearningPointTotalExpenditure,
                        ),
                      ),
                      Text(
                        " 学点",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
      
                Visibility(
                  visible: data.credit != 0,
                  child: Row(
                    children: [
                      Text(
                        creditStr,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w500,
                          color: (data.credit??0) > 0 ? AppTheme.cLearningPointTotalIncome : AppTheme.cLearningPointTotalExpenditure,
                        ),
                      ),
                      Text(
                        " 乃币",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),



          ],
        ),
      ),
    );
  }

  Widget _buildTabbarWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 9.wMin,
          children: [
            _buildTabbarItemWidget("全部", "all"),
            _buildTabbarItemWidget("收入", "income"),
            _buildTabbarItemWidget("支出", "spend"),
          ],
        ),
        // TapScaleWidget(
        //   onTap: (){},
        //   sclae: 1.05,
        //   child: Container(
        //     width: 42.wMin,
        //     height: 42.wMin,
        //     alignment: Alignment.center,
        //     decoration: BoxDecoration(
        //       borderRadius: BorderRadius.circular(8.wMin),
        //       color: AppTheme.cBgSecondary,
        //     ),
        //     child: SvgPicture.asset(
        //       "assets/svg/public/icon_filter.svg",
        //       width: 28.wMin,
        //       height: 28.wMin,
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildTabbarItemWidget(String text, String status){
    return TapScaleWidget(
      onTap: () {
        controller.changeTabbar(status);
      },
      sclae: 1.05,
      child: Obx((){
        return AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: controller.tabbarStatus.value == status ? AppTheme.cBorderSecondary : AppTheme.cBgSecondary,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRemindWidget(){
    return Obx((){
      if(controller.expireWrongs.isEmpty) return Container();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(controller.expireWrongs.length, (index){
          TransactionDetailsEntityExpireWrongs item = controller.expireWrongs[index];
          String points = NumberUtils.formatNumberWithCommas((item.points??0).toDouble());

          DateTime? expiredDate = DateFormatUtil.tryParseDate(item.expired);
          int days = expiredDate?.difference(DateTime.now()).inDays ?? 0;

          String expired = DateFormatUtil.formatStrtoStr(item.expired);

          return Container(
            margin: EdgeInsets.only(top: 12.wMin),
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cFeedbackWarningBackground,
            ),
            child: Row(
              spacing: 8.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  "assets/svg/public/icon_danger.svg",
                  width: 24.wMin,
                  height: 24.wMin,
                ),
                Expanded(
                  child: Text(
                    "您有 $points 学点将于 $expired 过期（还有 $days 天）",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cFeedbackWarningText,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      );
    });
  }

  Widget _buildCountItemWidget(Color prColor, String name, int val, String subName, String svg){
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.wMin),
        child: Container(
          height: 170.wMin,
          padding: EdgeInsets.all(20.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cBgSecondary,
            border: Border(top: BorderSide(width: 2.wMin, color: prColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 8.wMin,
                children: [
                  Container(
                    padding: EdgeInsets.all(2.wMin),
                    width: 26.wMin,
                    height: 26.wMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.wMin),
                      color: prColor,
                    ),
                    child: SvgPicture.asset(svg),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                NumberUtils.formatNumberWithCommas(val.toDouble()),
                style: TextStyle(
                  fontSize: 36.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary,
                ),
              ),
              SizedBox(height: 8.wMin),
              Text(
                subName,
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



}
