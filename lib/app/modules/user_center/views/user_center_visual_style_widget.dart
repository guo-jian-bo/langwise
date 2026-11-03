
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../controllers/user_center_controller.dart';

class UserCenterVisualStyleWidget extends GetView<UserCenterController> {
  /// 用户中心 视觉风格
  const UserCenterVisualStyleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TapScaleWidget(
        onTap: (){
          controller.toVisualStyleSettings();
        },
        sclae: 1.01,
        child: Container(
          padding: EdgeInsets.all(24.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cBgSecondary.color,
          ),
          child: Obx((){
            List<UserInfoEntityConfigImageStyles?> imageStyles = controller.userStore.userInfo.value.config?.imageStyles??[];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const UserTapTitleWidget(
                  title: "课程视觉风格",
                  subTitle: "当前课程使用的视觉风格",
                  value: "混合风格",
                  svg: "assets/svg/user_center/icon_image_style.svg",
                ),
                SizedBox(height: 24.wMin),
                Container(height: 1.wMin, color: AppTheme.cBorderPrimary),
                SizedBox(height: 24.wMin),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 16.wMin,
                    children: List.generate(imageStyles.length, (index){
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8.wMin),
                        child: Container(
                          width: 204.wMin,
                          height: 204.wMin,
                          color: AppTheme.cBlackAlpha10,
                          child: CachedImageWidget(
                            imageStyles[index]!.imageUrl??"",
                            errorWidget: Container(),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}