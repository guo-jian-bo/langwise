import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/membership_card_manage.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class NewCodeDialogWidget extends StatefulWidget {
  const NewCodeDialogWidget({Key? key, required this.entity}) : super(key: key);

  final MembershipCardCancelActivateEntity entity;

  @override
  State<NewCodeDialogWidget> createState() => _NewCodeDialogWidgetState();
}

class _NewCodeDialogWidgetState extends State<NewCodeDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
        color: AppTheme.cOverlayBackground,
        child: Center(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(16.wMin),
                child: Container(
                    width: 640.wMin,
                    padding: EdgeInsets.all(32.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.wMin),
                      color: AppTheme.cBgSecondary,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('新激活码已生成!', style: TextStyle(fontSize: 32.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary)),
                        SizedBox(
                          height: 56.wMin,
                        ),
                        Row(
                          children: [
                            Text('原激活码', style: TextStyle(fontSize: 32.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary)),
                            Spacer(),
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppTheme.cFeedbackErrorBackground,
                                borderRadius: BorderRadius.circular(8.wMin),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 5.wMin),
                              child: Text('已作废', style: TextStyle(fontSize: 24.wMin, fontWeight: FontWeight.w600, color: AppTheme.cFeedbackErrorText)),
                            )
                          ],
                        ),
                        SizedBox(height: 8.wMin),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: widget.entity.oldCoupon??''));
                            ToastUtils.showToast(text: '复制成功',type: ToastType.success);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.cInverseOverlay,
                              borderRadius: BorderRadius.circular(12.wMin),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 16.wMin),
                            child: Row(
                              children: [
                                Text('${widget.entity.oldCoupon}', style: TextStyle(fontSize: 24.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary)),
                                Spacer(),
                                Container(width: 40.wMin, height: 40.wMin, alignment: Alignment.center, child: Icon(Icons.copy, color: AppTheme.cTextPrimary, size: 24.wMin)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24.wMin),
                        Row(
                          children: [
                            Text('新激活码', style: TextStyle(fontSize: 32.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary)),
                            Spacer(),
                          ],
                        ),
                        SizedBox(height: 8.wMin),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: widget.entity.newCoupon??''));
                            ToastUtils.showToast(text: '复制成功',type: ToastType.success);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.cInverseOverlay,
                              borderRadius: BorderRadius.circular(12.wMin),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 16.wMin),
                            child: Row(
                              children: [
                                Text('${widget.entity.newCoupon}', style: TextStyle(fontSize: 24.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary)),
                                Spacer(),
                                Container(width: 40.wMin, height: 40.wMin, alignment: Alignment.center, child: Icon(Icons.copy, color: AppTheme.cTextPrimary, size: 24.wMin)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8.wMin),
                        Text('该码已同步至您的卡密列表，可用于二次销售。',style: TextStyle(fontSize: 24.wMin,fontWeight: FontWeight.w400,color: AppTheme.cTextSecondary),),
                        SizedBox(height: 13.wMin),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.wMin),
                            color: AppTheme.cFeedbackInfoBackground,
                            border: Border.all(color: AppTheme.cFeedbackInfoBorder)
                          ),
                          padding: EdgeInsets.all(12.wMin),
                          child: Text('注：由于新码承袭了旧卡的创建日期，若需请在列表中查找。',style: TextStyle(fontSize: 18.wMin,fontWeight: FontWeight.w400,color: AppTheme.cTextBrand),),
                        ),
                        SizedBox(height: 32.wMin),
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(alignment: Alignment.center,height: 68.wMin,decoration: BoxDecoration(
                            color: AppTheme.cSurfaceInfo,
                            borderRadius: BorderRadius.circular(8.wMin),
                          ),child: Text('我知道了',style: TextStyle(fontSize: 24.wMin,fontWeight: FontWeight.w600,color: AppTheme.cInverseTextLight))),
                        )
                      ],
                    )))));
  }
}
