
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';

/// 用户会员信息弹窗
class MembersInfoDialog{

  static Future<void> show({
    required BuildContext context,
  }) async{

    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return const MembersInfoDialogWidget();
      },
    );

  }

}


class MembersInfoDialogWidget extends StatefulWidget {
  const MembersInfoDialogWidget({super.key});

  @override
  State<MembersInfoDialogWidget> createState() => _MembersInfoDialogWidgetState();
}

class _MembersInfoDialogWidgetState extends State<MembersInfoDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Container(
          width: 756.wMin,
          padding: EdgeInsets.all(32.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cBgSecondary.color,
            borderRadius: BorderRadius.circular(16.wMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "我的会员",
                  style: TextStyle(
                    fontSize: 32.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 48.wMin),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.wMin),
                decoration: BoxDecoration(
                  color: AppTheme.cBgTertiary.color,
                  borderRadius: BorderRadius.circular(24.wMin),
                ),
                child: Obx((){
                  List<UserInfoEntityVipList?> vipList = UserStore.to.userInfo.value.vipList??[];
                  if(vipList.isEmpty) return Container();
                  /// 根据第一条数据的过期时间 去重vipList
                  String? firstEndTime = vipList[0]?.end;
                  if (firstEndTime != null) {
                    // 保留第一条数据，移除其他具有相同过期时间的数据
                    List<UserInfoEntityVipList?> uniqueList = [vipList[0]];
                    for (int i = 1; i < vipList.length; i++) {
                      if (vipList[i]?.end != firstEndTime) {
                        uniqueList.add(vipList[i]);
                      }
                    }
                    vipList = uniqueList;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 24.wMin,
                    children: List.generate(vipList.length, (index){
                      String vipEnd = DateFormatUtil.formatStrtoStr(vipList[index]?.end);
                      return Text(
                        "${vipList[index]?.type} 会员：$vipEnd",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }),
                  );
                }),
              ),
              SizedBox(height: 24.wMin),
              Obx((){
                String? vipType = UserStore.to.userInfo.value.vipType;
                List<UserInfoEntityVipList?> vipList = UserStore.to.userInfo.value.vipList??[];
                if(vipList.isEmpty) return Container();

                /// 根据第一条数据的过期时间 去重vipList
                String? firstEndTime = vipList[0]?.end;
                if (firstEndTime != null) {
                  // 保留第一条数据，移除其他具有相同过期时间的数据
                  List<UserInfoEntityVipList?> uniqueList = [vipList[0]];
                  for (int i = 1; i < vipList.length; i++) {
                    if (vipList[i]?.end != firstEndTime) {
                      uniqueList.add(vipList[i]);
                    }
                  }
                  vipList = uniqueList;
                }
                
                String? nextVipType;
                for(int i = 0; i < vipList.length; i++){
                  if(vipType == vipList[i]?.type) continue;
                  nextVipType = vipList[i]?.type;
                  break;
                }

                String tipText = "您正在使用${vipType??''}会员权益";
                if(nextVipType != null){
                  tipText += "，到期后$nextVipType会员权益生效。如果您再次购买${vipType??''}会员，$nextVipType会员时效顺延。";
                }

                return Text(
                  tipText,
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                );
              }),
              SizedBox(height: 56.wMin),
              ButtonWidget(
                text: "我知道了",
                borderRadius: 8.wMin,
                color: AppTheme.cSurfaceBrand.color,
                height: 64.wMin,
                fontColor: AppTheme.cStaticWhite.color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                sclae: 1.01,
                onTap: (){
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}