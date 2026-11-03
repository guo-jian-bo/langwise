
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../entities/entities.dart';
import '../https/https.dart';
import 'widgets.dart';

/// 内容错误反馈
class FeedbackErrorContentDialog {

  static Future<bool> show({
    required BuildContext context,
    Duration? position,
    required String? name,
    required String? content,
    required String? contentType,
    required int? contentId,
    int? semanticId,
  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return FeedbackErrorContentDialogWidget(
          position: position,
          name: name,
          content: content,
          contentType: contentType,
          contentId: contentId,
          semanticId: semanticId,
        );
      },
    );
    return res ?? false;
  }

}

class FeedbackErrorContentButtonWidget extends StatelessWidget {
  final void Function()? onTap;
  final Color? fontColor;
  const FeedbackErrorContentButtonWidget({super.key, this.onTap, this.fontColor});

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.03,
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/svg/public/icon_warning_triangle.svg",
              width: 32.wMin,
              colorFilter: ColorFilter.mode(
                fontColor ?? AppTheme.cInverseTextLight.color.withValues(alpha: 0.8), 
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 6.wMin),
            Text(
              "错误反馈",
              style: TextStyle(
                fontSize: 24.wMin,
                color: fontColor ?? AppTheme.cInverseTextLight.color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ),
    );
  }
}


class FeedbackErrorContentDialogWidget extends StatefulWidget {
  final Duration? position;
  final String? name;
  final String? content;
  final String? contentType;
  final int? contentId;
  final int? semanticId;
  const FeedbackErrorContentDialogWidget({
    super.key, 
    this.position, 
    this.name, 
    this.content, 
    this.contentType, 
    this.contentId,
    this.semanticId,
    });

  @override
  State<FeedbackErrorContentDialogWidget> createState() => _FeedbackErrorContentDialogWidgetState();
}

class _FeedbackErrorContentDialogWidgetState extends State<FeedbackErrorContentDialogWidget> {

  final List<FeedbackContentTypeEntityReportTypes> errTypes = [];
  
  List<String> selectTypes = [];

  final TextEditingController contentController = TextEditingController();


  @override
  void initState() {
    super.initState();
    getFeedbackContentType();
  }

  Future<void> getFeedbackContentType() async{
    try {
      ToastUtils.showLoading();
      FeedbackContentTypeEntity? feedbackContentTypeEntity = await UserRequest.getFeedbackContentType();
      if(feedbackContentTypeEntity == null) return;
      List<FeedbackContentTypeEntityReportTypes?>? reportTypes = feedbackContentTypeEntity.reportTypes;
      if(reportTypes == null) return;

      errTypes.clear();
      for(var item in reportTypes){
        if(item == null) continue;
        errTypes.add(item);
      }

      if(mounted) setState(() {});
      
    } finally{
      ToastUtils.hideLoading();
    }
  }



  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  /// 提交
  Future<void> submit() async {
    if(errTypes.isNotEmpty){
      if(selectTypes.isEmpty){
        return ToastUtils.showToast(text: "请选择错误类型");
      } 
    }
   
    if(contentController.text.isEmpty){
      return ToastUtils.showToast(text: "请描述具体的错误");
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "content": {
          "uid": widget.contentId,
          "type": widget.contentType,
          "semanticId": widget.semanticId,
        },
        "types": selectTypes,
        "title": widget.name,
        "timing": widget.position?.inMilliseconds,
        "details": contentController.text,
      };
      bool res = await UserRequest.submitFeedbackContent(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "提交成功，感谢您的反馈", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
    
   
  }

  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Material(
        color: AppTheme.cOverlayBackground.color,
        child: Center(
          child: Stack(
            children: [
              Container(
                width: 950.wMin,
                padding: EdgeInsets.all(40.wMin),
                decoration: BoxDecoration(
                  color: AppTheme.cSurfaceSecondary.color,
                  borderRadius: BorderRadius.circular(16.wMin),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTitleWidget(),
                    _buildNameWidget(),
                    _buildErrorTypeWidget(),
                    _buildContentWidget(),
                    _buildButtonWidget(),
                  ],
                ),
              ),
              Positioned(
                top: 10.wMin,
                right: 10.wMin,
                child: TapScaleWidget(
                  sclae: 1.05,
                  onTap: () => Get.back(),
                  child: Container(
                    width: 42.wMin,
                    height: 42.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cSurfaceTertiary.color,
                    ),
                    child: SvgPicture.asset(
                      "assets/svg/public/x.svg",
                      width: 24.wMin,
                      height: 24.wMin,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTitleWidget(){
    return Center(
      child: Text(
        "错误反馈",
        style: TextStyle(
          fontSize: 28.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextPrimary.color,
        ),
      ),
    );
  }


  Widget _buildNameWidget(){
    if(widget.name == null){
      return const SizedBox();
    }
    return Container(
      margin: EdgeInsets.only(top: 32.wMin),
      alignment: Alignment.centerLeft,
      child: Text(
        "名称：${widget.name??""}",
        style: TextStyle(
          fontSize: 24.wMin,
          color: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 错误类型
  Widget _buildErrorTypeWidget(){
    if(errTypes.isEmpty) return Container();
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(TextSpan(
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: "*",
                style: TextStyle(
                  color: AppTheme.cFeedbackErrorText.color,
                ),
              ),
              const TextSpan(
                text: "错误类型",
              ),
            ],
          )),
          SizedBox(height: 8.wMin),

          Wrap(
            spacing: 16.wMin,
            runSpacing: 16.wMin,
            children: List.generate(errTypes.length, (index){
              return _buildErrorTypeItemWidget(errTypes[index]);
            }),
          ),

        ],
      ),
    ); 
  }

  Widget _buildErrorTypeItemWidget(FeedbackContentTypeEntityReportTypes data){
    return TapScaleWidget(
      onTap: () {
        if(data.code == null) return;
        if(selectTypes.contains(data.code)){
          selectTypes.remove(data.code);
        }else{
          selectTypes.add(data.code!);
        }
        if(mounted) setState(() {});
      },
      sclae: 1.01,
      child: Container(
        padding: EdgeInsets.all(8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              selectTypes.contains(data.code) ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
              width: 36.wMin,
            ),
            SizedBox(width: 8.wMin),
            Text(
              data.title??"",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 问题描述
  Widget _buildContentWidget(){
    return Container(
      margin: EdgeInsets.only(top: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(TextSpan(
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: "*",
                style: TextStyle(
                  color: AppTheme.cFeedbackErrorText.color,
                ),
              ),
              const TextSpan(
                text: "请描述您的问题",
              ),
            ],
          )),
          SizedBox(height: 8.wMin),

          Container(
            padding: EdgeInsets.all(16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cSurfaceTertiary.color,
            ),
            child: Column(
              children: [
                TextField(
                  controller: contentController,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLength: 500,
                  maxLines: 5,
                  decoration: InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: "请在这里描述具体的错误",
                    hintStyle: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextQuaternary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onChanged: (value) {
                    if(mounted) setState(() {});
                  },
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${contentController.text.length}/500",
                    style: TextStyle(
                      fontSize: 22.wMin,
                      color: AppTheme.cTextTertiary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                 
              ],
            ),
          ),


        ],
      ),
    );
  }

  Widget _buildButtonWidget(){
    return Container(
      margin: EdgeInsets.only(top: 32.wMin),
      child: ButtonWidget(
        text: "提交",
        sclae: 1.005,
        height: 56.wMin,
        borderRadius: 8.wMin,
        color: AppTheme.cSurfaceInfo.color,
        fontColor: AppTheme.cInverseTextLight.color,
        fontSize: 24.wMin,
        fontWeight: FontWeight.w600,
        onTap: OptimizeUtils.noneThrottle((){
          submit();
        }, 500),
      ),
    );
  }



}