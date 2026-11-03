import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../utils/utils.dart';

class CardsCouponsWidget extends StatefulWidget {
  final void Function()? onTap;
  final void Function(CouponEntityDatas data)? onTransfer;
  final CouponEntityDatas data;

  const CardsCouponsWidget({super.key, this.onTap, this.onTransfer, required this.data});

  @override
  State<CardsCouponsWidget> createState() => _CardsCouponsWidgetState();
}

class _CardsCouponsWidgetState extends State<CardsCouponsWidget> {
  

  @override
  Widget build(BuildContext context) {
    Color couponColor = StatusUtils.getCouponColor(widget.data.type);
    bool usable = widget.data.usable??false;
    bool transfer = widget.data.transfer??false;
    String? expired = widget.data.expired;
    String expiredText = "";
    if(expired != null){
      expiredText = DateFormatUtil.formatStrtoStr(expired, locale: Get.locale);
    }

    return IgnorePointer(
      ignoring: !usable && !transfer,
      child: Opacity(
        opacity: usable || transfer ? 1 : 0.8,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: AppTheme.cSurfaceSecondary.color,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.wMin),
                      Text(
                        widget.data.title??"",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: couponColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Visibility(
                        visible: widget.data.ad?.isNotEmpty??false,
                        child: Text(
                          widget.data.ad??"",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: couponColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.data.describe?.isNotEmpty??false,
                        child: Text(
                          widget.data.describe??"",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: AppTheme.cTextSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      
                      Visibility(
                        visible: widget.data.benefits?.isNotEmpty??false,
                        child: Container(
                          margin: EdgeInsets.only(top: 12.wMin),
                          child: Column(
                            children: List.generate(widget.data.benefits?.length??0, (index){
                              if(widget.data.benefits![index] == null) return Container();
                              return _buildRowTextWidget(
                                widget.data.benefits?[index]?.category??"", 
                                widget.data.benefits?[index]?.items,
                              );
                            }),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.data.tip?.isNotEmpty??false,
                        child: Container(
                          margin: EdgeInsets.only(top: 6.wMin),
                          child: Text(
                            widget.data.tip??"",
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: AppTheme.cFeedbackErrorText,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.data.expired?.isNotEmpty??false,
                        child: Container(
                          margin: EdgeInsets.only(top: 6.wMin),
                          child: Text(
                            "$expiredText 到期",
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: AppTheme.cTextTertiary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ),
            ),
            DottedBorder(
              borderType: BorderType.RRect,
              borderPadding: EdgeInsets.symmetric(horizontal: 24.wMin),
              padding: EdgeInsets.zero,
              color: AppTheme.cTextDisabled,
              strokeWidth: 1.wMin,
              dashPattern: [6.wMin, 6.wMin],
              customPath: (size) => Path()..moveTo(0, size.height)..relativeLineTo(size.width, 0),
              child: Container(),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 19.wMin, vertical: 16.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                color: AppTheme.cSurfaceSecondary.color,
              ),
              child: _buildButtonsWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowTextWidget(String name, List<String?>? values){
    return Row(
      spacing: 10.wMin,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: Text(
              values?.join("，")??"",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildButtonsWidget(){
    bool usable = widget.data.usable??false;
    bool transfer = widget.data.transfer??false;
    Color couponColor = StatusUtils.getCouponColor(widget.data.type);
    bool isUse = widget.data.isUse??false;

    List<Widget> buttons = [];
    if(usable){
      buttons.add(Expanded(
        child: ButtonWidget(
          text: isUse? "已使用" : "立即使用",
          height: 56.wMin,
          color: couponColor.withValues(alpha: isUse? 0.08 : 0.1),
          borderRadius: 8.wMin,
          fontColor: couponColor.withValues(alpha: isUse ? 0.6 : 1),
          fontSize: 24.wMin,
          fontWeight: FontWeight.w600,
          sclae: 1.01,
          onTap: OptimizeUtils.noneThrottle(() {
            widget.onTap?.call();
          }, 300),
        ),
      ));
    }
    if(transfer){
      buttons.add(Expanded(
        child: ButtonWidget(
          text: "去转送",
          height: 56.wMin,
          color: AppTheme.cSurfaceWarning.withValues(alpha: 0.1),
          borderRadius: 8.wMin,
          fontColor: AppTheme.cSurfaceWarning,
          fontSize: 24.wMin,
          fontWeight: FontWeight.w600,
          sclae: 1.01,
          onTap: OptimizeUtils.noneThrottle(() {
            widget.onTransfer?.call(widget.data);
          }, 300),
        ),
      ));
    }

    if(buttons.isEmpty){
      return Container(height: 56.wMin);
    }

    return Row(
      spacing: 10.wMin,
      children: buttons,
    );
  }


}

