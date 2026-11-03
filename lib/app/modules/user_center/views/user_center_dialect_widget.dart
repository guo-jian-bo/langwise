

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../controllers/user_center_controller.dart';

class UserCenterDialectWidget extends GetView<UserCenterController> {
  /// 用户中心 语言方言设置
  const UserCenterDialectWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceSecondary.color,
        ),
        child: Obx((){
          UserCenterOptionEntityNationalConfigs? nationalConfigs = controller.userPreferenceOptionData.value.languageLearningPreference?.nationalConfigs;
          return Column(
            children: [
              UserSettingOpenTitleWidget(
                title: nationalConfigs?.title??"",
                subTitle: nationalConfigs?.description??"",
                svg: "assets/svg/user_center/icon_ear.svg",
                isOpen: controller.languageDialectOpen.value,
                onTap: () {
                  controller.openLanguageDialect(!controller.languageDialectOpen.value);
                },
              ),
              SizedBox(height: 24.wMin),
              Container(height: 1.wMin, color: AppTheme.cBorderPrimary),
              _buildPlaySpeedWidget(nationalConfigs?.exerciseAudioSpeed),
              // SizedBox(height: 8.wMin),
              // _buildPlaySpeedWidget(nationalConfigs?.songAudioSpeed),
              SizedBox(height: 32.wMin),
              Obx((){
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('英语方言设置',style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                    )),
                    SizedBox(height: 8.wMin),
                    _buildDialectSelectWidget(nationalConfigs?.options??[]),
                    // AnimatedCrossFade(
                    //   crossFadeState: !controller.languageDialectOpen.value ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    //   duration: const Duration(milliseconds: 200),
                    //   firstChild: Container(),
                    //   secondChild: Column(
                    //     spacing: 26.wMin,
                    //     children: [

                    //       _buildDialectSelectWidget(nationalConfigs?.options??[]),
                    //       UserSettingExampleWidget(
                    //         title: nationalConfigs?.exampleTitle??"",
                    //         datas: List.generate(nationalConfigs?.examples?.length??0, (index){
                    //           UserCenterOptionEntityNationalConfigsExamples? example = nationalConfigs?.examples?[index];
                    //           List<UserCenterOptionEntityNationalConfigsExamplesContentList?> contentList = example?.contentList??[];
                    //           return UserSettingExampleModel(
                    //             title: example?.title??"",
                    //             subTitle: example?.description??"",
                    //             example: List.generate(contentList.length, (index){
                    //               UserCenterOptionEntityNationalConfigsExamplesContentList? content = contentList[index];
                    //               return UserSettingExampleDataModel(
                    //                 image: content?.imageUrl,
                    //                 audio: content?.audioUrl,
                    //                 text: content?.content??"",
                    //               );
                    //             }),
                    //           );
                    //         }),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // AnimatedCrossFade(
                    //   crossFadeState: controller.languageDialectOpen.value ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    //   duration: const Duration(milliseconds: 200),
                    //   secondChild: _buildDialectSelectWidget(controller.userCenterOptionData.value.nationalConfigs?.options??[]),
                    //   firstChild: Container(),
                    // ),
                  ],
                );
              }),
            ],
          );
        }),
      ),
    );
  }


  Widget _buildDialectSelectWidget(List<UserCenterOptionEntityNationalConfigsOptions?> options){
    return IntrinsicHeight(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          spacing: 16.wMin,
          children: List.generate(options.length, (index){
            UserCenterOptionEntityNationalConfigsOptions? option = options[index];
            if(option == null) return Container();
            return UserSettingSelectCardWidget(
              title: option.title??"",
              subTitle: option.description??"",
              value: option.content??"",
              audio: option.audioUrl,
              showRecommendedTags: options[index]?.code == LanguageServiceCode.US,
              selected: controller.currentLanguageDialectCode.value == option.code,
              onTap: () => controller.changeLanguageDialect(option.code??""),
            );
          }),
        ),
      ),
    );
  }

  /// 播放速度按钮
  Widget _buildPlaySpeedWidget(UserCenterOptionEntityNationalConfigsSpeed? configSpeed){
    if(configSpeed == null) return Container();
    List<double?> playSpeeds = configSpeed.options??[];
    if(playSpeeds.isEmpty) return Container();

    double playSpeed = configSpeed.code=='playSpeed' ? controller.playSpeed.value : controller.otherPlaySpeed.value;
    return Container(
      margin: EdgeInsets.only(top: 24.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.wMin,
        children: [
          Text(
            configSpeed.title??"",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            width: double.infinity,
            height: 68.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cSurfaceTertiary.color,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
              child: Row(
                spacing: 60.wMin,
                children: List.generate(playSpeeds.length, (index){
                  
                  return TapScaleWidget(
                    onTap: () {
                      if(configSpeed.code=='playSpeed'){
                        controller.changePlaySpeed(playSpeeds[index]??1.0);
                      }else{
                        controller.changeOtherPlaySpeed(playSpeeds[index]??1.0);
                      }
                    },
                    sclae: 1,
                    child: Container(
                      height: 52.wMin,
                      width: 52.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: playSpeed == playSpeeds[index] ? AppTheme.cBgBrand.color : Colors.transparent,
                      ),
                      child: Text(
                        "${playSpeeds[index]??"1.0"}",
                        style: TextStyle(
                          fontSize: 22.wMin,
                          color: playSpeed == playSpeeds[index] ? AppTheme.cStaticWhite.color : AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );

                }),
              ),
            ),
          ),
          Text(configSpeed.description??"", style: TextStyle(
            fontSize: 22.wMin,
            color: AppTheme.cTextTertiary.color,
          ),),
        ],
      ),
    );
  }


}