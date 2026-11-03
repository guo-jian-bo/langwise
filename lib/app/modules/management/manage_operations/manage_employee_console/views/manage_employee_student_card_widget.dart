
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../../utils/utils.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../controllers/manage_employee_console_controller.dart';

class ManageEmployeeStudentCardWidget extends StatelessWidget {
  final ManageEmployeeConsoleController controller;
  final ManageEmployeeConsoleMemberEntity item;
  const ManageEmployeeStudentCardWidget({super.key, required this.controller, required this.item});

  @override
  Widget build(BuildContext context) {
    List<String> statusTags = [];
    if(item.riskReasons?.isNotEmpty == true){
      statusTags.addAll(item.riskReasons!.where((reason) => reason.isNotEmpty));
    }

    Color? riskBgColor = ColorUtils.parseColor(item.riskStyle?.backgroundColor);
    Color? riskBorderColor = ColorUtils.parseColor(item.riskStyle?.borderColor);
    Color? riskFontColor = ColorUtils.parseColor(item.riskStyle?.textColor);

    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: riskBorderColor ?? Colors.red.withValues(alpha: .3),
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8.wMin,
            children: [
              _buildStudentCardTagWidget(
                text: item.riskTitle??"",
                bgColor: riskBgColor ?? Colors.red.withValues(alpha: .1),
                textColor: riskFontColor ?? Colors.red,
                borderColor: riskBorderColor ?? Colors.red.withValues(alpha: .2),
              ),
              // _buildStudentCardTagWidget(
              //   text: "PS",
              //   bgColor: AppTheme.cSurfaceTertiary.color,
              //   textColor: AppTheme.cTextSecondary.color,
              //   borderColor: AppTheme.cSurfaceSecondary.color,
              // ),
              Visibility(
                visible: item.stageTitle != null,
                child: _buildStudentCardTagWidget(
                  text: item.stageTitle??"",
                  bgColor: AppTheme.cSurfaceTertiary.color,
                  textColor: AppTheme.cTextSecondary.color,
                  borderColor: AppTheme.cSurfaceSecondary.color,
                ),
              ),
              const Spacer(),
              ManageAuthBoxWidget(
                authCodes: [ManageAuthCode.channelStaffAccountFollow],
                child: GestureDetector(
                  onTap: () async {
                    await controller.toggleFollowStaffAccount(context, item);
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.wMin),
                    child: Icon(
                      item.userRelationDTO?.followed == true ? Icons.star : Icons.star_border,
                      size: 26.wMin,
                      color: item.userRelationDTO?.followed == true ? const Color(0xffFBBF24) : AppTheme.cTextTertiary.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.wMin),
          _buildStudentCardTitleWidget(context, item),
          SizedBox(height: 10.wMin),
          _buildStudentCardIndicatorWidget(item),
          _buildStudentCardStatusWidget(statusTags, context),
          SizedBox(height: 10.wMin),
          _buildStudentCardStatisticsWidget(item),
          const Spacer(),
          _buildStudentCardButtonsWidget(context, item),


        ],
      ),
    );
  }

  Widget _buildStudentCardTagWidget({
    required String text,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: bgColor,
        border: Border.all(
          color: borderColor,
          width: 0.8.wMin,
        ),
      ),
      child: SelectableText(
        text,
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStudentCardTitleWidget(BuildContext context, ManageEmployeeConsoleMemberEntity item){
    // 是否领取
    bool isReceived = item.userRelationDTO != null;
    // 领取状态
    String statusText = !isReceived ? "待领取" : item.userRelationDTO?.staffName??'';
    // 领取人职位
    String roleText = item.userRelationDTO?.roleNames?.join('、')??'';
    // 领取时间
    String createTimeText = DateFormatUtil.getTimeAgoText(DateFormatUtil.tryParseDate(item.userRelationDTO?.created));

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SelectableText(
                    item.name??"",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                  SizedBox(width: 8.wMin),
                  SelectableText(
                    "UId:${item.userId??''}",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                  SizedBox(width: 8.wMin),
                  SelectableText(
                    "MId:${item.memberId??''}",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                ],
              ),
              SelectableText(
                "${item.phoneMasked??''} · 最近登陆 ${DateFormatUtil.getTimeAgoText(DateFormatUtil.tryParseDate(item.lastLoginAt))}",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
          
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cSurfaceLayerBase.color,
          ),
          child: Column(
            spacing: 6.wMin,
            children: [
              Row(
                children: [
                  ManageAuthBoxWidget(
                    authCodes: [ManageAuthCode.channelStaffAccountGet],
                    child: _buildStudentCardTitleButtonWidget(
                      text: !isReceived ? "领取" : "已领",
                      bgColor: !isReceived ? AppTheme.cSurfaceWarning.color.withValues(alpha: .1) : AppTheme.cSurfaceTertiary.color,
                      textColor: AppTheme.cTextSecondary.color,
                      borderColor: !isReceived ? AppTheme.cSurfaceWarning.color.withValues(alpha: .2) : AppTheme.cBorderSecondary.color,
                      onTap: isReceived ? null : () async {
                        await controller.receiveInspection(context, item);
                      },
                    ),
                  ),
                  ManageAuthBoxWidget(
                    authCodes: [ManageAuthCode.channelStaffAccountChange],
                    margin: EdgeInsets.only(left: 8.wMin),
                    child: _buildStudentCardTitleButtonWidget(
                      text: "转交",
                      bgColor: Color(0xff14B8A6).withValues(alpha: .1),
                      textColor: AppTheme.cTextSecondary.color,
                      borderColor: Color(0xff14B8A6).withValues(alpha: .2),
                      onTap: () async {
                        await controller.forwardInspection(context, item);
                      },
                    ),
                  ),
                  ManageAuthBoxWidget(
                    authCodes: [ManageAuthCode.channelUserLogPages],
                    margin: EdgeInsets.only(left: 8.wMin),
                    child: _buildStudentCardTitleButtonWidget(
                      text: "历史",
                      bgColor: AppTheme.cSurfaceTertiary.color,
                      textColor: AppTheme.cTextPrimary.color,
                      borderColor: AppTheme.cBorderSecondary.color,
                      onTap: () async {
                        await controller.viewInspectionHistory(context, item);
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SelectableText(
                    statusText,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                  SelectableText(
                    !isReceived? " · 暂无工作人员认领" : " · $roleText · $createTimeText",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildStudentCardTitleButtonWidget({
    required String text,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    Function()? onTap,
  }){
    return ButtonWidget(
      text: text,
      height: 30.wMin,
      width: 76.wMin,
      color: bgColor,
      border: Border.all(
        color: borderColor,
        width: 0.8.wMin,
      ),
      borderRadius: 6.wMin,
      fontColor: textColor,
      fontSize: 18.wMin,
      fontWeight: FontWeight.w600,
      sclae: 1.03,
      onTap: onTap,
    );
  }

  /// 指标
  Widget _buildStudentCardIndicatorWidget(ManageEmployeeConsoleMemberEntity item){
    String lastAssessmentAt = "无";
    if(item.lastAssessmentAt != null){
      lastAssessmentAt = DateFormatUtil.getTimeAgoText(DateFormatUtil.tryParseDate(item.lastAssessmentAt));
    }
    String lastPlanUpdatedAt = "无";
    if(item.lastPlanUpdatedAt != null){
      lastPlanUpdatedAt = DateFormatUtil.getTimeAgoText(DateFormatUtil.tryParseDate(item.lastPlanUpdatedAt));
    }
    String lastStudyAt = "无";
    if(item.lastStudyAt != null){
      lastStudyAt = DateFormatUtil.getTimeAgoText(DateFormatUtil.tryParseDate(item.lastStudyAt));
    }
    String studyDays7d = "无";
    if(item.studyDays7d != null){
      studyDays7d = "${item.studyDays7d?.toString()??'0'}天";
    }
    String avgStudyMinutes7d = "无";
    if(item.avgStudyMinutes7d != null){
      avgStudyMinutes7d = "${item.avgStudyMinutes7d??'0'}分钟";
    }
    String accuracy7d = "无";
    if(item.accuracy7d != null){
      accuracy7d = "${item.accuracy7d?.toString()??'0'}%";
    }
    
    return Row(
      spacing: 12.wMin,
      children: [
        _buildStudentCardIndicatorItemWidget(
          title: "销售指标",
          kvs: {
            "购买": item.purchaseStatus??"",
            "渠道": item.channelName??"",
            "会员": item.membershipText??"",
          },
        ),
        _buildStudentCardIndicatorItemWidget(
          title: "黄金指标",
          kvs: {
            "评测": lastAssessmentAt,
            "计划": lastPlanUpdatedAt,
            "学习": lastStudyAt,
          },
        ),
        _buildStudentCardIndicatorItemWidget(
          title: "学情数据",
          kvs: {
            "7天学习": studyDays7d,
            "7天平均": avgStudyMinutes7d,
            "7天正确": accuracy7d,
          },
        ),
      ],
    );
  }

  /// 状态标签组
  Widget _buildStudentCardStatusWidget(List<String> statusTags, BuildContext context){
    if(statusTags.isEmpty) return Container();

    Color? riskBgColor = ColorUtils.parseColor(item.riskStyle?.backgroundColor);
    Color? riskBorderColor = ColorUtils.parseColor(item.riskStyle?.borderColor);
    Color? riskFontColor = ColorUtils.parseColor(item.riskStyle?.textColor);

    return Container(
      margin: EdgeInsets.only(top: 10.wMin),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false, // 隐藏滚动条
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 8.wMin,
            children: statusTags.map((tag) => _buildStudentCardTagWidget(
              text: tag,
              bgColor: riskBgColor ?? Colors.red.withValues(alpha: .1),
              textColor: riskFontColor ?? Colors.red,
              borderColor: riskBorderColor ?? Colors.red.withValues(alpha: .2),
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCardIndicatorItemWidget({
    required String title,
    required Map<String, dynamic> kvs,
  }){
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderNone.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              title,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            SizedBox(height: 10.wMin),
            Container(height: 1, color: AppTheme.cBorderSubtle.color),
            SizedBox(height: 10.wMin),
            Column(
              spacing: 10.wMin,
              children: List.generate(kvs.length, (index){
                return Row(
                  children: [
                    SelectableText(
                      kvs.keys.toList()[index],
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: SelectableText(
                          kvs.values.toList()[index].toString(),
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.cTextPrimary.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// 统计
  Widget _buildStudentCardStatisticsWidget(ManageEmployeeConsoleMemberEntity item){
    final ManageEmployeeConsoleMemberEntitySuperMemoSummary? summary = item.superMemoSummary;
    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildStudentCardStatisticsItemWidget(
              title: "总知识",
              value: summary?.totalMemoryContentCount,
              suffix: "个",
              valueColor: AppTheme.cSurfaceBrand.color,
            ),
            Container(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
            _buildStudentCardStatisticsItemWidget(
              title: "总时长",
              value: DateFormatUtil.convertSecondsToMinutes(summary?.totalDuration),
              suffix: "分钟",
              valueColor: Color(0xff60A5FA),
            ),
            _buildStudentCardStatisticsItemWidget(
              title: "总星星",
              value: summary?.totalStars,
              suffix: "个",
              valueColor: Color(0xffFBBF24),
            ),
            _buildStudentCardStatisticsItemWidget(
              title: "总钻石",
              value: summary?.totalDiamond,
              suffix: "个",
              valueColor: Color(0xffC084FC),
            ),
            _buildStudentCardStatisticsItemWidget(
              title: "总记忆",
              value: summary?.totalMemoryDay,
              suffix: "天",
              valueColor: Color(0xff00D492),
            ),
            _buildStudentCardStatisticsItemWidget(
              title: "连续记忆",
              value: summary?.continueMemoryDay,
              suffix: "天",
              valueColor: Color(0xffFB7185),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCardStatisticsItemWidget({
    required String title,
    required int? value,
    required String suffix,
    Color? valueColor,
  }){

    Color vColor = valueColor ?? AppTheme.cTextPrimary.color;
    if(value == null || value == 0){
      vColor = AppTheme.cTextPrimary.color;
    }

    return Expanded(
      child: Column(
        children: [
          SelectableText(
            title,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          SizedBox(height: 6.wMin),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                NumberUtils.formatNumberWithCommas(value?.toDouble() ?? 0),
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  color: vColor,
                ),
              ),
              SelectableText(
                suffix,
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildStudentCardButtonsWidget(BuildContext context, ManageEmployeeConsoleMemberEntity item){
    return Row(
      spacing: 12.wMin,
      children: [

        Expanded(
          child: ManageAuthBoxWidget(
            authCodes: [ManageAuthCode.channelUserImpersonateMember],
            child: ButtonWidget(
              text: "进入学员",
              height: 40.wMin,
              borderRadius: 8.wMin,
              color: AppTheme.cSurfaceLayerBase.color,
              border: Border.all(
                color: AppTheme.cBorderSubtle.color,
                width: 0.8.wMin,
              ),
              fontSize: 18.wMin,
              fontColor: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
              sclae: 1.03,
              leftIcon: Container(
                margin: EdgeInsets.only(right: 4.wMin),
                child: SvgPicture.asset(
                  "assets/svg/public/icon_arrow_back.svg",
                  height: 24.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                ),
              ),
              onTap: () {
                controller.enterStudent(context, item);
              },
            ),
          ),
        ),

        Expanded(
          child: ManageAuthBoxWidget(
            authCodes: [ManageAuthCode.channelUserImpersonateMember],
            child: ButtonWidget(
              text: "管理学员教材",
              height: 40.wMin,
              borderRadius: 8.wMin,
              color: AppTheme.cSurfaceLayerBase.color,
              border: Border.all(
                color: AppTheme.cBorderSubtle.color,
                width: 0.8.wMin,
              ),
              fontSize: 18.wMin,
              fontColor: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
              sclae: 1.03,
              leftIcon: Container(
                margin: EdgeInsets.only(right: 4.wMin),
                child: SvgPicture.asset(
                  "assets/svg/public/icon_arrow_back.svg",
                  height: 24.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                ),
              ),
              onTap: () {
                controller.enterStudent(context, item, isEditBook: true);
              },
            ),
          ),
        ),

        Expanded(
          child: ManageAuthBoxWidget(
            authCodes: [ManageAuthCode.notifyTemplateSendableList, ManageAuthCode.notifyTemplateSend],
            child: ButtonWidget(
              text: "发送通知",
              height: 40.wMin,
              borderRadius: 8.wMin,
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: .1),
              border: Border.all(
                color: AppTheme.cSurfaceBrand.color.withValues(alpha: .2),
                width: 0.8.wMin,
              ),
              fontSize: 18.wMin,
              fontColor: AppTheme.cSurfaceBrand.color,
              fontWeight: FontWeight.w500,
              sclae: 1.03,
              leftIcon: Container(
                margin: EdgeInsets.only(right: 4.wMin),
                child: SvgPicture.asset(
                  "assets/svg/public/icon_notice.svg",
                  height: 18.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cSurfaceBrand.color, BlendMode.srcIn),
                ),
              ),
              onTap: () {
                controller.sendNotify(context, item);
              },
            ),
          ),
        ),
        Expanded(
          child: ManageAuthBoxWidget(
            authCodes: [ManageAuthCode.channelTicketRecordPages],
            child: ButtonWidget(
              text: "查看工单",
              height: 40.wMin,
              borderRadius: 8.wMin,
              color: Color(0xffA855F7).withValues(alpha: .12),
              border: Border.all(
                color: Color(0xffA855F7).withValues(alpha: .2),
                width: 0.8.wMin,
              ),
              fontSize: 18.wMin,
              fontColor: Color(0xffA855F7),
              fontWeight: FontWeight.w500,
              sclae: 1.03,
              leftIcon: Container(
                margin: EdgeInsets.only(right: 4.wMin),
                child: SvgPicture.asset(
                  "assets/svg/public/icon_ticket.svg",
                  height: 18.wMin,
                  colorFilter: ColorFilter.mode(Color(0xffA855F7), BlendMode.srcIn),
                ),
              ),
              rightIcon: Container(
                margin: EdgeInsets.only(left: 4.wMin),
                padding: EdgeInsets.all(6.wMin),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cSurfaceSearchBackground.color,
                ),
                child: Text(
                  item.pendingTicketCount?.toString() ?? "",
                  style: TextStyle(
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
              ),
              onTap: () {
                controller.viewInspectionTicket(context, item);
              },
            ),
          ),
        ),
      ],
    );
  }
  
}
