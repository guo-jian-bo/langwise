import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../home/views/home_common_widget.dart';
import '../controllers/specialty_controller.dart';
import '../model/speciaity_phonics_model.dart';

class SpeciaityPhonicsCourseCardWidget extends GetView<SpecialtyController> {
  final HomeCardEntityItems data;

  /// 发音课
  const SpeciaityPhonicsCourseCardWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 24.wMin),
          child: Row(
            children: [
              Expanded(
                child: HomeCardTabbarWidget(
                  padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                  tabs: controller.phonicsDatas.map((e) => e.title).toList(),
                  selectIndex: controller.phonicsTabIndex.value,
                  onTap: (p0) {
                    controller.phonicsTabIndex.value = p0;
                    controller.phonicsTabController?.animateTo(p0);
                  },
                ),
              ),
              HelpIVideoIconWidget(
                padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                helpVideoUrl: data.helpVideoUrl,
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: controller.phonicsTabController,
            // physics: const NeverScrollableScrollPhysics(),
            children: List.generate(controller.phonicsDatas.length, (index) {
              return _buildViewWidget(controller.phonicsDatas[index]);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildViewWidget(SpeciaityPhonicsModel model) {
    List<PronunciationsEntity?> pronunciations = model.data?.moduleContentInfo?.pronunciations ?? [];

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 418.wMin,
            height: 418.wMin,
            color: Colors.transparent,
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.wMin),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CachedImageWidget(
                      model.data?.moduleCoverUrl ?? "",
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
                            ipa: model.data?.moduleTopic,
                            pronunciations: pronunciations,
                            national: LanguageServiceCode.US,
                            style: TextStyle(
                              fontSize: 110.wMin,
                              color: AppTheme.cInverseTextLight.color,
                              fontWeight: FontWeight.w700,
                              fontFamily: "AndikaRegular",
                            ),
                          ),
                          PronunciationsColorWidget(
                            content: model.data?.moduleContentInfo?.content,
                            ipa: model.data?.moduleTopic,
                            pronunciations: pronunciations,
                            national: LanguageServiceCode.US,
                            style: TextStyle(
                              fontSize: 70.wMin,
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
                          size: 68.wMin,
                          audioUrl: pronunciations[index]?.audioUrl,
                          backgroundImageUrl: pronunciations[index]?.nationalIconUrl,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 6.wMin),
          Text(
            model.data?.levelName ?? "",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.wMin),
          Text(
            model.data?.unitName ?? "",
            style: TextStyle(
              fontSize: 56.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
