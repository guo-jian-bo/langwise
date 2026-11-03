import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/generated/assets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../routes/routes.dart';
import '../bindings/feedback_opinion_binding.dart';
import '../controllers/feedback_opinion_controller.dart';

class FeedbackOpinionView extends GetView<FeedbackOpinionController> {
  final String tagText;
  const FeedbackOpinionView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      FeedbackOpinionView(tagText: tag),
      binding: FeedbackOpinionBinding(tagText: tag),
      routeName: Routes.FEEDBACK_OPINION,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        backgroundColor: AppTheme.cBgPrimary,
        body: Container(
          alignment: Alignment.topCenter,
          child: Container(
            width: 1680.wMin,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 40.wMin,
            ),
            child: Column(
              children: [
                const BackWidget(title: "反馈意见"),
                Expanded(
                  child: SizedBox(
                    width: 880.wMin,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "您遇到什么问题了吗？",
                            style: TextStyle(
                              fontSize: 40.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextPrimary,
                            ),
                          ),
                          SizedBox(height: 32.wMin),
                          _buildProblemDescriptionWidget(),
                          SizedBox(height: 32.wMin),
                          _buildUploadImageWidget(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildButtonWidget(),
      ),
    );

  }

  Widget _buildButtonWidget(){
    return Container(
      height: 140.wMin,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 10.wMin, bottom: 50.wMin),
      child: ButtonWidget(
        text: "提交",
        width: 640.wMin,
        height: 80.wMin,
        borderRadius: 12.wMin,
        fontColor: AppTheme.cStaticWhite,
        color: AppTheme.cBgBrand,
        fontSize: 24.wMin,
        fontWeight: FontWeight.w600,
        sclae: 1.01,
        onTap: () {
          controller.submitFeedback();
        },
      ),
    );
  }


  Widget _buildProblemDescriptionWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "请描述您的问题",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary,
          ),
        ),
        SizedBox(height: 8.wMin),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cBgSecondary.color,
            borderRadius: BorderRadius.circular(12.wMin),
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
          ),
          height: 240.wMin,
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.feedbackController,
                  maxLines: 10,
                  maxLength: 500,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextPrimary,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "您可以详细描述问题或建议，我们会尽快帮您解决",
                    hintStyle: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary,
                    ),
                    contentPadding: EdgeInsets.only(left: 16.wMin, top: 16.wMin, right: 16.wMin),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  onChanged: (value) {
                    controller.feedbackLength.value = value.length;
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 4.wMin, horizontal: 16.wMin),
                alignment: Alignment.bottomRight,
                child: Obx((){
                  return Text(
                    "${controller.feedbackLength.value}/500",
                    style: TextStyle(
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildUploadImageWidget(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "上传图片（您可以上传4张）",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary,
          ),
        ),
        SizedBox(height: 8.wMin),
        TapScaleWidget(
          onTap: () {
            controller.selectImage(context);
          },
          sclae: 1.01,
          child: Container(
            width: double.infinity,
            height: 156.wMin,
            decoration: BoxDecoration(
              color: AppTheme.cBgSecondary.color,
              borderRadius: BorderRadius.circular(12.wMin),
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  Assets.publicIconAdd,
                  width: 28.wMin,
                ),
                Text(
                  "点击上传",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.wMin),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx((){
            return Row(
              spacing: 26.wMin,
              children: List.generate(controller.imageFileList.length, (index){
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4.wMin),
                  child: SizedBox(
                    width: 200.wMin,
                    height: 200.wMin,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.file(
                            controller.imageFileList[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 4.wMin,
                          top: 4.wMin,
                          child: TapScaleWidget(
                            onTap: () {
                              controller.deleteImage(index);
                            },
                            sclae: 1.1,
                            child: Container(
                              padding: EdgeInsets.all(6.wMin),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.cBlackAlpha50,
                              ),
                              child: SvgPicture.asset(
                                Assets.publicX,
                                width: 24.wMin,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ],
    );
  }



}
