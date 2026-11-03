import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../../home/views/home_common_widget.dart';
import '../controllers/specialty_controller.dart';
import '../model/speciaity_default_phonics_model.dart';

class SpeciaityDefaultPhonicsCourseCardWidget extends GetView<SpecialtyController> {
  final HomeCardEntityItems data;
  const SpeciaityDefaultPhonicsCourseCardWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<SpeciaityDefaultPhonicsModel> defaultPhonicsDatas = controller.defaultPhonicsDatas.toList();

    Text? subTitle = StyleUtils.getText(data.subTitle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 24.wMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: HomeCardTabbarWidget(
                      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                      tabs: controller.defaultPhonicsDatas.map((e) => e.title).toList(),
                      selectIndex: controller.defaultPhonicsTabIndex.value,
                      onTap: (p0) {
                        controller.defaultPhonicsTabIndex.value = p0;
                        controller.defaultPhonicsTabController?.animateTo(p0);
                      },
                    ),
                  ),
                  HelpIVideoIconWidget(
                    padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                    helpVideoUrl: data.helpVideoUrl,
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 4.wMin),
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                child: subTitle,
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: controller.defaultPhonicsTabController,
            children: List.generate(defaultPhonicsDatas.length, (index) {
              return _buildTabViewWidget(defaultPhonicsDatas[index]);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTabViewWidget(SpeciaityDefaultPhonicsModel model) {
    List<SpeciaityDefaultPhonicsModelDataModuleInfoList?> moduleInfoList = model.data?.moduleInfoList ?? [];

    return FutureBuilder(
      initialData: false,
      future: Future.delayed(const Duration(milliseconds: 500), () => true),
      builder: (context, snapshot) {
        return CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            viewportFraction: 0.7,
            aspectRatio: 1,
            autoPlayAnimationDuration: const Duration(seconds: 3),
            autoPlayInterval: snapshot.data == true ? const Duration(seconds: 3) : const Duration(milliseconds: 400),
            autoPlayCurve: Curves.linear,
            pageSnapping: false,
            clipBehavior: Clip.none,
          ),
          items: List.generate(moduleInfoList.length, (index) {
            return _buildViewWidget(moduleInfoList[index]);
          }),
        );
      },
    );
  }

  Widget _buildViewWidget(SpeciaityDefaultPhonicsModelDataModuleInfoList? data) {
    List<PronunciationsEntity?> pronunciations = data?.contentInfo?.pronunciations ?? [];

    return Container(
      color: Colors.transparent,
      width: 360.wMin,
      height: 360.wMin,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.wMin),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CachedImageWidget(
                data?.moduleCoverUrl ?? "",
                placeholder: buildEmptyWidget(),
                errorWidget: buildEmptyWidget(),
              ),
              Container(
                width: double.infinity,
                color: AppTheme.cBlackAlpha50.color,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PronunciationsPlayIpaTextWidget(
                      ipa: data?.topic,
                      pronunciations: pronunciations,
                      national: LanguageServiceCode.US,
                      style: TextStyle(
                        fontSize: 114.wMin,
                        color: AppTheme.cInverseTextLight.color,
                        fontWeight: FontWeight.w700,
                        fontFamily: "AndikaRegular",
                      ),
                    ),
                    PronunciationsColorWidget(
                      content: data?.contentInfo?.content,
                      ipa: data?.topic,
                      pronunciations: pronunciations,
                      national: LanguageServiceCode.US,
                      style: TextStyle(
                        fontSize: 63.wMin,
                        color: AppTheme.cInverseTextLight.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 60.wMin),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(pronunciations.length, (index) {
                  return PlayLottieIconWidget(
                    size: 64.wMin,
                    audioUrl: pronunciations[index]?.audioUrl,
                    backgroundImageUrl: pronunciations[index]?.nationalIconUrl,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
