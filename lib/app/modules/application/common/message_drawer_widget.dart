
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../controllers/message_controller.dart';

class MessageDrawerWidget extends GetView<MessageController> {
  const MessageDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(18.wMin),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.wMin),
        child: PlatformBackdropFilterWidget(
          sigmaX: 17.5.wMin,
          sigmaY: 17.5.wMin,
          child: Container(
            width: 672.wMin,
            color: AppTheme.cInverseOverlay.color,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _buildAppbarWidget(),
              body: _buildListWidget(context),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppbarWidget(){
    return AppBar(
      toolbarHeight: 60.wMin,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      foregroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 100.wMin,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: Center(
        child: TapScaleWidget(
          onTap: () => Get.back(),
          sclae: 1.03,
          child: Container(
            height: 50.wMin,
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 10.wMin),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  "assets/svg/public/icon_w_arrow_left.svg",
                  width: 28.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                ),
                Text(
                  "返回",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      title: Text(
        "消息中心",
        style: TextStyle(
          fontSize: 28.wMin,
          fontWeight: FontWeight.w600,
          color: AppTheme.cTextPrimary.color,
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16.wMin),
          child: TapScaleWidget(
            onTap: () {
              controller.allReadMessage();
            },
            sclae: 1.05,
            child: Container(
              color: Colors.transparent,
              width: 50.wMin,
              height: 50.wMin,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                "assets/svg/public/icon_broom.svg",
                width: 26.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListWidget(BuildContext context){
    return Obx((){
      if(!controller.loading.value && controller.messageList.isEmpty){
        return const NotDataWidget(
          message: "暂无消息",
        );
      }

      return Stack(
        children: [
          ListView.separated(
            controller: controller.scrollController,
            itemCount: controller.messageList.length,
            padding: EdgeInsets.all(16.wMin) + EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            separatorBuilder: (context, index) {
              return SizedBox(height: 12.wMin);
            },
            itemBuilder: (context, index) {
              return _buildItemWidget(controller.messageList[index]);
            },
          ),
          Visibility(
            visible: controller.loading.value,
            child: Container(
              alignment: Alignment.center,
              child: SpinKitFadingCircle(
                color: AppTheme.cBgBrand,
                size: 100.wMin,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildItemWidget(PushMessageEntity message){
    return TapScaleWidget(
      onTap: () {
        controller.toDetils(message);
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(20.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cInverseOverlay2.color,
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    message.title??"",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
      
                Visibility(
                  visible: message.read == 0,
                  child: Container(
                    width: 16.wMin,
                    height: 16.wMin,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cFeedbackErrorIcon.color,
                    ),
                  ),
                ),
      
              ],
            ),
            Visibility(
              visible: message.desc != null ,
              child: Container(
                margin: EdgeInsets.only(top: 6.wMin),
                child: Text(
                  message.desc ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22.wMin,
                    color: AppTheme.cTextPrimary.color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.wMin),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormatUtil.formatStrtoStr(message.created, newPattern: "yyyy-MM-dd HH:mm"),
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Visibility(
                  visible: (message.content??"").isNotEmpty || message.jump != null,
                  child: Row(
                    children: [
                      Text(
                        (message.content??"").isEmpty == true ? "去查看" : "查看详情",
                        style: TextStyle(
                          fontSize: 22.wMin,
                          color: AppTheme.cTextBrand.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SvgPicture.asset(
                        "assets/svg/public/icon_w_arrow_right.svg",
                        width: 24.wMin,
                        colorFilter: ColorFilter.mode(AppTheme.cTextBrand.color, BlendMode.srcIn),
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

  

}