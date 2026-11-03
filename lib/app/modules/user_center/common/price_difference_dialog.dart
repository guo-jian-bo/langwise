import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/stores/stores.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';

/// 需要补差价的提示
class PriceDifferenceDialog{

  static Future<bool> getCompletionMemberInfo(BuildContext context) async{
    try {
      ToastUtils.showLoading();
      CompletionMemberEntity? data = await PayRequest.getCompletionMemberInfo();
      if(data == null) return false;
      if(data.isAlign != 1) return false;
      return await show(context: context, data: data);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  static Future<bool> show({
    required BuildContext context,
    required CompletionMemberEntity data,
  }) async{

      bool? res = await showCupertinoDialog(
        context: context, 
        builder: (context) {
          return PriceDifferenceDialogWidget(data: data);
        },
      );

      return res??false;

  }

}


class PriceDifferenceDialogWidget extends StatefulWidget {
  final CompletionMemberEntity data;
  const PriceDifferenceDialogWidget({super.key, required this.data});

  @override
  State<PriceDifferenceDialogWidget> createState() => _PriceDifferenceDialogWidgetState();
}

class _PriceDifferenceDialogWidgetState extends State<PriceDifferenceDialogWidget> {
  @override
  Widget build(BuildContext context) {

    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Container(
          width: 906.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cBgSecondary.color,
          ),
          child: Stack(
            children: [
              Container(
                height: 313.wMin,
                width: 906.wMin,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.cBgBrand.color.withValues(alpha: 0.2),
                      AppTheme.cBgBrand.color.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(32.wMin),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Center(
                      child: Text(
                        '简化您的会员方案',
                        style: TextStyle(
                          fontSize: 32.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.wMin),
                    Text(
                      "我们发现您的账户包含多个会员方案。为了更清晰的管理和不间断的高级体验，我们建议您将所有方案整合为统一的 ${widget.data.vipCalculate?.needType??''} 会员。",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                    SizedBox(height: 32.wMin),

                    _buildTitleTextWidget("当前会员权益", null),
                    SizedBox(height: 10.wMin),
                    Column(
                      spacing: 8.wMin,
                      children: List.generate(widget.data.vipList?.length??0, (index){
                        return _buildRowTextWidget(
                          widget.data.vipList?[index]?.type??'',
                          widget.data.vipList?[index]?.end??'',
                        );
                      }),
                    ),
                    SizedBox(height: 22.wMin),
                    _buildTitleTextWidget("推荐整合方案", null),
                    SizedBox(height: 8.wMin),
                    Text(
                      "将 ${widget.data.vipCalculate?.needType??''} 会员期限补齐到跟 ${widget.data.vipCalculate?.targetType??''} 会员期限一致，账户将变为：",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                    SizedBox(height: 6.wMin),
                    // Column(
                    //   spacing: 8.wMin,
                    //   children: List.generate(widget.data.vipCalculateList?.length??0, (index){
                    //     return _buildRowTextWidget(
                    //       widget.data.vipCalculateList?[index]?.needType??'',
                    //       widget.data.vipCalculateList?[index]?.needTime??'',
                    //     );
                    //   }),
                    // ),
                    _buildRowTextWidget(
                      widget.data.vipCalculate?.needType??'',
                      widget.data.vipCalculate?.targetTime??'',
                    ),

                    SizedBox(height: 22.wMin),

                    _buildTitleTextWidget("您需要支付的差价", "${NumberUtils.formatNumberWithCommas((widget.data.vipCalculate?.price??0) / 100)} 乃币"),

                    SizedBox(height: 40.wMin),

                    Row(
                      spacing: 12.wMin,
                      children: [
                        Expanded( 
                          child: ButtonWidget(
                            text: "取消",
                            height: 68.wMin,
                            borderRadius: 8.wMin,
                            color: AppTheme.cBgTertiary.color,
                            fontColor: AppTheme.cTextPrimary.color,
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w500,
                            sclae: 1.02,
                            onTap: () {
                              Get.back(result: false);
                            },
                          ),
                        ),
                        Expanded( 
                          child: ButtonWidget(
                            text: "去支付",
                            height: 68.wMin,
                            borderRadius: 8.wMin,
                            color: AppTheme.cSurfaceBrand.color,
                            fontColor: AppTheme.cStaticWhite.color,
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w500,
                            sclae: 1.02,
                            onTap: () {
                              Get.back(result: true);
                            },
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowTextWidget(String member, String expire){
    MemberLevelColor memberLevelColor = StatusUtils.getMemberColorsByVipConfigs(
      UserStore.to.userInfo.value.vipConfigs, 
      member,
    );
      
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$member会员",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: memberLevelColor.deep,
          ),
        ),
        Text(
          "有效期至：${DateFormatUtil.formatStrtoStr(expire)}",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
      ],
    );
  }


  Widget _buildTitleTextWidget(String name, String? subName){
    return Row(
      children: [
        Container(
          width: 8.wMin,
          height: 32.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: AppTheme.cBgBrand.color,
          ),
        ),
        SizedBox(width: 8.wMin),
        Text(
          name,
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        const Spacer(),
        Visibility(
          visible: subName != null,
          child: Text(
            subName??"",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ),
      ],
    );
  }

}