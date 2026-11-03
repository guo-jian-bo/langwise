import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
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
    String? expired = widget.data.expired;
    String expiredText = "";
    if(expired != null){
      expiredText = DateFormatUtil.formatStrtoStr(expired, locale: Get.locale);
    }

    return IgnorePointer(
      ignoring: !usable,
      child: Opacity(
        opacity: usable ? 1 : 0.8,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: AppTheme.cBgSecondary,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.wMin),
                      Text(
                        widget.data.title??"",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: couponColor,
                          fontWeight: FontWeight.w600,
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
                          margin: EdgeInsets.only(top: 20.wMin),
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
                color: AppTheme.cBgSecondary,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.wMin),
                      child: ButtonWidget(
                        text: widget.data.isUse??false ? "已使用" : "立即使用",
                        height: 42.wMin,
                        color: widget.data.isUse??false ? AppTheme.cSurfaceTertiary : couponColor,
                        borderRadius: 8.wMin,
                        fontColor: AppTheme.cStaticWhite,
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        sclae: 1.01,
                        onTap: widget.onTap,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.data.transfer??false,
                    child: Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5.wMin),
                        child: ButtonWidget(
                          text: "去转送",
                          height: 42.wMin,
                          color: AppTheme.cFeedbackWarningIcon,
                          borderRadius: 8.wMin,
                          fontColor: AppTheme.cStaticWhite,
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          sclae: 1.01,
                          onTap: () => widget.onTransfer?.call(widget.data),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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


}


class CouponsWidget extends StatefulWidget {
  final void Function()? onTap;
  final HotspotsActivityEntity data;
  const CouponsWidget({super.key, this.onTap, required this.data});

  @override
  State<CouponsWidget> createState() => _CouponsWidgetState();
}

class _CouponsWidgetState extends State<CouponsWidget> {


  @override
  Widget build(BuildContext context) {
    String? expired = widget.data.expired;
    DateTime? date = DateFormatUtil.tryParseDate(expired);
    String expiredText = "";
    if(date != null){
      expiredText = DateFormatUtil.formatLocale(date, locale: Get.locale);
    }

    return TapScaleWidget(
      onTap: (){
        widget.onTap?.call();
      },
      sclae: 1.02,
      child: Container(
        width: 420.wMin,
        height: 207.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: (widget.data.bgIconUrl?.isNotEmpty??false) ? Colors.transparent : AppTheme.cBgBrand,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedImageWidget(
                widget.data.bgIconUrl??"",
                placeholder: Container(),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data.title??"",
                    style: TextStyle(
                      fontSize: 36.wMin,
                      color: AppTheme.cStaticWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "截止日期：$expiredText",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: const Color(0xff075985),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                    decoration: BoxDecoration(
                      color: AppTheme.cStaticWhite,
                      borderRadius: BorderRadius.circular(999.wMin),
                    ),
                    child: Row(
                      spacing: 6.wMin,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "立即参与",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: AppTheme.cBgBrand,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          width: 14.wMin,
                          height: 14.wMin,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff38BDF8),
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/user_center/icon_chevron_right1.svg",
                            width: 12.wMin,
                            height: 12.wMin,
                            colorFilter: const ColorFilter.mode(
                              AppTheme.cStaticWhite,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}