
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/https/https.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../../../routes/routes.dart';
import '../utils/utils.dart';

class ManageAssStatusWidget extends StatefulWidget {
  final int? assState;
  final int? assTranslateState;
  final int? videoId;
  final int? assId;
  final void Function()? onRefresh;
  const ManageAssStatusWidget({
    super.key, 
    this.assState, 
    this.assTranslateState, 
    this.onRefresh,
    required this.videoId,
    required this.assId,
  });

  @override
  State<ManageAssStatusWidget> createState() => _ManageAssStatusWidgetState();
}

class _ManageAssStatusWidgetState extends State<ManageAssStatusWidget> {


  /// 新建字幕
  Future<void> assReviewCreateAlign() async{
    bool isAuth = ManageAuthUtils.isAuth(ManageAuthCode.adminAssReviewTaskAlignVideoCreate);
    if(!isAuth) return;

    if(widget.videoId == null) return;

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "videoUid": widget.videoId,
      };
      String? res = await LanguageConsoleRequest.assReviewCreateVideoAlign(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      widget.onRefresh?.call();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 编辑字幕
  Future<void> editAssAlign() async{
    bool isAuth = ManageAuthUtils.isAuth(ManageAuthCode.adminAssReviewAssDetail);
    if(!isAuth) return;

    if(widget.assId == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_ASS_DETILS,
      arguments: {
        "assId": widget.assId,
      },
    );
    widget.onRefresh?.call();
  }


  /// 新建翻译
  Future<void> assReviewCreateTranslate() async{
    bool isAuth = ManageAuthUtils.isAuth(ManageAuthCode.adminAssReviewTaskTranslateCreate);
    if(!isAuth) return;

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "assId": widget.assId,
      };
      String? res = await LanguageConsoleRequest.assReviewCreateTranslate(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      widget.onRefresh?.call();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 编辑翻译
  Future<void> editAssTranslate() async{
     bool isAuth = ManageAuthUtils.isAuth(ManageAuthCode.adminAssReviewAssDetail);
    if(!isAuth) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_ASS_TRANSLATE,
      arguments: {
        "assId": widget.assId,
      },
    );
    widget.onRefresh?.call();
  }


  @override
  Widget build(BuildContext context) {
    if(widget.assState == null && widget.assTranslateState == null) return Container();
    return  _buildAssButtonWidget();
  }

  Widget _buildAssButtonWidget(){
    if(widget.assState == -1 && widget.assTranslateState == -1){
      return Container(
        height: 28.wMin,
        padding: EdgeInsets.symmetric(horizontal: 4.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.wMin),
          color: AppTheme.cInverseOverlay.color,
        ),
        child: Text(
          "无台词",
          style: TextStyle(
            fontSize: 16.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    return Column(
      spacing: 4.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAssButtonItemWidget(
          status: widget.assState??-1,
          name: "字幕",
          onTap: () {
            if(widget.assState == 0){
              assReviewCreateAlign();
            }else if(widget.assState == 2){
              editAssAlign();
            }
          },
        ),
        _buildAssButtonItemWidget(
          status: widget.assTranslateState??-1,
          name: "翻译",
          onTap: () {
            if(widget.assTranslateState == 0){
              assReviewCreateTranslate();
            }else if(widget.assTranslateState == 2){
              editAssTranslate();
            } 
          },
        ),
      ],
    );

  }


  Widget _buildAssButtonItemWidget({
    required int status,
    required String name,
    void Function()? onTap,
  }){

    if(status == -1){
      return Container(
        height: 28.wMin,
        padding: EdgeInsets.symmetric(horizontal: 4.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.wMin),
          color: AppTheme.cInverseOverlay.color.withValues(alpha: 0.2),
        ),
        child: Text(
          "$name无需生成",
          style: TextStyle(
            fontSize: 16.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    String svg = "assets/svg/manage/icon_to_be_generated.svg"; //待生成
    String arrowSvg = "assets/svg/manage/icon_add_blue.svg";
    String statusText = "待生成";
    if(status == 1){
      svg = "assets/svg/manage/icon_pending_review.svg"; //待审核
      statusText = "待审核";
    }else if(status == 2){
      svg = "assets/svg/manage/icon_reviewed.svg"; //已审核
      statusText = "已审核";
      arrowSvg = "assets/svg/manage/icon_edit.svg";
    }

    return TapScaleWidget(
      onTap: onTap,
      sclae: 1,
      child: Container(
        height: 28.wMin,
        padding: EdgeInsets.symmetric(horizontal: 4.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.wMin),
          color: AppTheme.cInverseOverlay.color.withValues(alpha: 0.2),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              svg,
              width: 16.wMin,
            ),
            SizedBox(width: 4.wMin),
            Text(
              "$name$statusText",
              style: TextStyle(
                fontSize: 16.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            Visibility(
              visible: status != 1,
              child: Container(
                margin: EdgeInsets.only(left: 4.wMin),
                child: Container(
                  width: 24.wMin,
                  height: 24.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.wMin),
                    color: AppTheme.cInverseOverlay2.color,
                  ),
                  child: SvgPicture.asset(
                    arrowSvg,
                    width: 18.wMin,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}