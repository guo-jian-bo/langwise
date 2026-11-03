
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../utils/utils.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';

/// 审核
class ManageReviewFrameDialog{

  /// * 审核帧图片
  /// * [reviewFrames] 要审核的数据
  /// * [compareFrames] 对比的数据
  static Future<bool> show({
    required BuildContext context,
    required VideoTaskEntityListFrames reviewFrames,
    VideoTaskEntityListFrames? compareFrames,
    required int videoTaskId,
    int initIndex = 0,
    void Function(String prompt)? onUpdatePrompt,
  }) async{
    bool? res = await showDialog<bool?>(
      context: context,
      builder: (context) {
        return ManageReviewFrameDialogWidget(
          frames: reviewFrames,
          compareFrames: compareFrames,
          initIndex: initIndex,
          videoTaskId: videoTaskId,
          onUpdatePrompt: onUpdatePrompt,
        );
      },
    );

    return res??false;
  }

}

class ManageReviewFrameDialogWidget extends StatefulWidget {
  final VideoTaskEntityListFrames frames;
  final VideoTaskEntityListFrames? compareFrames;
  final int initIndex;
  final int videoTaskId;
  final void Function(String prompt)? onUpdatePrompt;
  const ManageReviewFrameDialogWidget({
    super.key, 
    required this.frames, 
    this.initIndex = 0, 
    required this.videoTaskId, 
    this.onUpdatePrompt, 
    this.compareFrames,
  });

  @override
  State<ManageReviewFrameDialogWidget> createState() => _ManageReviewFrameDialogState();
}

class _ManageReviewFrameDialogState extends State<ManageReviewFrameDialogWidget> {
  int currentIndex = 0;
  final TextEditingController promptController = TextEditingController();
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initIndex;
    promptController.text = widget.frames.prompt??"";
    pageController = PageController(initialPage: currentIndex);
  }

  /// 编辑图片提示词
  Future<void> editImagePrompt() async{
    if(promptController.text.trim().isEmpty){
      return ToastUtils.showToast(text: "请输入prompt");
    }
    if(promptController.text == widget.frames.prompt){
      return ToastUtils.showToast(text: "prompt未发生改变");
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "promptId": widget.frames.promptId,
        "prompt": promptController.text,
      };
      bool response = await LanguageConsoleRequest.editImagePrompt(data: reqData);
      if(!response) return;
      widget.frames.prompt = promptController.text;
      ToastUtils.showToast(text: '修改成功', type: ToastType.success);
      widget.onUpdatePrompt?.call(promptController.text);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 重新生成图片提示词和图片
  Future<void> reGenerateImagePrompt() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "videoTaskId": widget.videoTaskId,
        "frameIndex": widget.frames.index,
      };
      String? response = await LanguageConsoleRequest.reGenerateImagePrompt(data: reqData);
      if(response == null) return;
      ToastUtils.showToast(text: response, type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 用提示词重新生成图片
  Future<void> reGenerateImageByPrompt() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "videoTaskId": widget.videoTaskId,
        "frameIndex": widget.frames.index,
        "imageTaskId": widget.frames.imageTaskId,
      };
      if(promptController.text != widget.frames.prompt){
        reqData['prompt'] = promptController.text;
      }
      String? response = await LanguageConsoleRequest.reGenerateImage(data: reqData);
      if(response == null) return;
      ToastUtils.showToast(text: response, type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 图片审核通过
  Future<void> imageReviewPass() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "imageIdSelected": widget.frames.frameImages?[currentIndex]?.imageId,
        "imageTaskId": widget.frames.imageTaskId,
        "videoTaskId": widget.videoTaskId ,
      };
      bool response = await LanguageUtil.videoImageReviewPass(data: reqData);
      if(!response) return;
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        
        children: [

          _buildTitleWidget(context),
          _buildImageRowWidget(),
          
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationWidget(context),
    );
  }

  Widget _buildBottomNavigationWidget(BuildContext context){
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.wMin),
      borderSide: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
    );

    return Container(
      height: 240.wMin,
      padding: EdgeInsets.symmetric(horizontal: 100.wMin, vertical: 12.wMin),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        ),
      ),
      child: Row(
        children: [

          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 136.wMin,
                  child: TextField(
                    controller: promptController,
                    maxLines: 15,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                    readOnly: !ManageAuthUtils.isAuth(ManageAuthCode.adminVideoReviewTaskRetryImagePrompt),
                    decoration: InputDecoration(
                      isDense: true,
                      counterText: "",
                      border: border,
                      focusedBorder: border,
                      enabledBorder: border,
                      disabledBorder: border,
                      contentPadding: EdgeInsets.all(16.wMin),
                    ),
                    onTapOutside: (event) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.adminContentReviewPromptEdit],
                    margin: EdgeInsets.only(top: 6.wMin),
                    child: ButtonWidget(
                      text: "保存prompt",
                      width: 116.wMin,
                      height: 40.wMin,
                      borderRadius: 6.wMin,
                      sclae: 1.03,
                      color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                      border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceWarning.color),
                      fontColor: AppTheme.cSurfaceWarning.color,
                      fontSize: 16.wMin,
                      onTap: () {
                        editImagePrompt();
                      },
                    ),
                  ),
                ),
                        
              ],
            ),
          ),

          SizedBox(width: 40.wMin),

          Column(
            children: [
              ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.adminVideoReviewTaskRetryImagePrompt],
                child: ButtonWidget(
                  text: "重新生成提示词和图片",
                  width: 205.wMin,
                  height: 54.wMin,
                  borderRadius: 6.wMin,
                  sclae: 1.03,
                  color: const Color(0xff8B5CF6).withValues(alpha: 0.2),
                  border: Border.all(width: 1.wMin, color: const Color(0xff8B5CF6)),
                  fontColor: const Color(0xff8B5CF6),
                  fontSize: 16.wMin,
                  onTap: () {
                    reGenerateImagePrompt();
                  },
                ),
              ),
              ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.adminVideoReviewTaskRetryImageGenerate],
                margin: EdgeInsets.only(top: 10.wMin),
                child: ButtonWidget(
                  text: "用提示词重新生成图片",
                  width: 205.wMin,
                  height: 54.wMin,
                  borderRadius: 6.wMin,
                  sclae: 1.03,
                  color: const Color(0xffF97316).withValues(alpha: 0.2),
                  border: Border.all(width: 1.wMin, color: const Color(0xffF97316)),
                  fontColor: const Color(0xffF97316),
                  fontSize: 16.wMin,
                  onTap: () {
                    reGenerateImageByPrompt();
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10.wMin),
                child: ButtonWidget(
                  text: "审核通过",
                  width: 205.wMin,
                  height: 54.wMin,
                  borderRadius: 6.wMin,
                  sclae: 1.03,
                  color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
                  border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSuccess.color),
                  fontColor: AppTheme.cSurfaceSuccess.color,
                  fontSize: 18.wMin,
                  onTap: () {
                    imageReviewPass();
                  },
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context){

    String name = "";
    if(widget.frames.index == 0){
      name = "首帧";
    }else if(widget.frames.index == -1){
      name = "尾帧";
    }else {
      name = "中间帧";
    }

    return Container(
      height: 60.wMin,
      padding: EdgeInsets.only(
        left: 24.wMin + MediaQuery.of(context).padding.left,
        right: 24.wMin + MediaQuery.of(context).padding.right,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        ),
      ),
      child: Row(
        children: [

          Text(
            "$name图片${widget.frames.imageId != null ? '重新审核' : '审核'}",
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),

          const Spacer(),

          TapScaleWidget(
            sclae: 1.05,
            onTap: () => Get.back(),
            child: Container(
              width: 60.wMin,
              height: 60.wMin,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: SvgPicture.asset(
                "assets/svg/public/x.svg",
                width: 32.wMin,
                height: 32.wMin,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildImageRowWidget(){

    String? compareImageUrl;
    if(widget.compareFrames != null){
      List<VideoTaskEntityListFramesFrameImages?> frameImages = widget.compareFrames?.frameImages??[];
      compareImageUrl = frameImages.firstWhereOrNull((e) => e?.option == true)?.imageUrl;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Visibility(
          visible: widget.compareFrames != null && compareImageUrl != null,
          child: Expanded(
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10.wMin),
                        _buildImageTitleWidget(widget.compareFrames),
                        SizedBox(height: 10.wMin),
                        SizedBox(
                          width: 720.wMin,
                          height: 720.wMin,
                          child: CachedImageWidget(
                            compareImageUrl??"",
                            borderRadius: BorderRadius.circular(14.wMin),
                            errorWidget: buildEmptyWidget(),
                            placeholder: buildEmptyWidget(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10.wMin),
              _buildImageTitleWidget(widget.frames),
              SizedBox(height: 10.wMin),
              _buildImageWidget(widget.frames),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageTitleWidget(VideoTaskEntityListFrames? frames){

    Color imageReviewColor = AppTheme.cSurfaceWarning.color;
    String imageReviewStatus = "待审核";
    if(frames?.imageId != null){
      imageReviewColor = AppTheme.cSurfaceSuccess.color;
      imageReviewStatus = "已审核";
    }

    if((frames?.frameImages??[]).isEmpty){
      imageReviewColor = AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.4);
      imageReviewStatus = "待生成";
    }

    String name = "";
    if(frames?.index == 0){
      name = "首帧";
    }else if(frames?.index == -1){
      name = "尾帧";
    }else {
      name = "中间帧";
    }

    return SizedBox(
      width: 720.wMin,
      child: Row(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(width: 8.wMin),
          Text(
            "index=${frames?.index??0}",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          SizedBox(width: 8.wMin),

          ManageTagFS14Widget(
            tag: imageReviewStatus,
            bgColor: imageReviewColor,
          ),

          const Spacer(),

          Visibility(
            visible: widget.compareFrames?.index != frames?.index,
            child: Text(
              "图片 ${currentIndex + 1}/${frames?.frameImages?.length??0}",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ),

        ],
      ),
    );
  }


  Widget _buildImageWidget(VideoTaskEntityListFrames frames){
    List<VideoTaskEntityListFramesFrameImages?> list = frames.frameImages??[];
    if(list.isEmpty) return Container();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16.wMin,
      children: [

        Visibility(
          visible: list.isNotEmpty && list.length != 1,
          child: IgnorePointer(
            ignoring: currentIndex <= 0,
            child: TapScaleWidget(
              onTap: () {
                pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.linear);
              },
              sclae: 1.1,
              child: _buildArrowWidget(
                "assets/svg/public/icon_w_arrow_left.svg",
                isOption: currentIndex <= 0,
              ),
            ),
          ),
        ),

        SizedBox(
          width: 720.wMin,
          height: 720.wMin,
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.wMin),
              child: PageView.builder(
                itemCount: list.length,
                controller: pageController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (value) {
                  currentIndex = value;
                  if(mounted) setState(() {});
                },
                itemBuilder: (context, index) {
                  return CachedImageWidget(
                    list[index]?.imageUrl??"",
                    borderRadius: BorderRadius.circular(14.wMin),
                    errorWidget: buildEmptyWidget(),
                    placeholder: buildEmptyWidget(),
                  );
                },
              ),
            ),
          ),
        ),

        Visibility(
          visible: list.isNotEmpty && list.length != 1,
          child: IgnorePointer(
            ignoring: currentIndex >= list.length - 1,
            child: TapScaleWidget(
              onTap: () {
                pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.linear);
              },
              sclae: 1.1,
              child: _buildArrowWidget(
                "assets/svg/public/icon_w_arrow_right.svg",
                isOption: currentIndex >= list.length - 1,
              ),
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildArrowWidget(String svg, {bool isOption = false}){
    return Opacity(
      opacity: isOption ? 0.6 : 1,
      child: Container(
        width: 56.wMin,
        height: 56.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1.wMin, color: AppTheme.cInverseOverlay3.color),
          color: AppTheme.cInverseOverlay2.color,
        ),
        child: SvgPicture.asset(
          svg, 
          width: 34.wMin,
          colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
        ),
      ),
    );
  }


}