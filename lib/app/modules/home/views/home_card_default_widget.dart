import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/enum/home_card_code.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';
import '../controllers/home_controller.dart';


class HomeCardDefaultWidget extends GetView<HomeController> {
  final HomeCardEntityItems data;
  const HomeCardDefaultWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    ThemeColorEntity? cardColor = StyleUtils.getCurrentThemeColors(data.bgColor);

    Text? title = StyleUtils.getText(data.title);
    Text? subTitle = StyleUtils.getText(data.subTitle);

    ThemeImageEntity? bgImage = StyleUtils.getCurrentThemeImage(data.bgImage);
    
    
    List<ThemeTextEntity?> descriptions = data.descriptions??[];
    List<Text> texts = [];
    for (int i = 0; i < descriptions.length; i++) {
      if(descriptions[i] == null) continue;
      Text? text = StyleUtils.getText(descriptions[i]);
      if(text == null) continue;
      texts.add(text);
    }

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GuideAnchor(
            id: data.code == HomeCardCode.coursePlan?"to_study_plan":'',
            route: Routes.APPLICATION,
            child: TapScaleWidget(
              onTap: () {
                controller.toPageByCode(data, context);
              },
              sclae: 1.01,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  border: Border.all(
                    width: 1.wMin,
                    color: ColorUtils.parseColor(cardColor?.borderColor)??Colors.transparent,
                  ),
                  gradient: StyleUtils.parseCssLinearGradient(cardColor?.color),
                ),
                child: Stack(
                  children: [
                    Visibility(
                      visible: bgImage != null,
                      child: Positioned.fill(
                        right: 0,
                        bottom: 0,
                        child: CachedImageWidget(
                          bgImage?.imageUrl??"",
                          errorWidget: Container(),
                          placeholder: Container(),
                          fadeInDuration: Duration.zero,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(24.wMin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(child: title),
                              const Spacer(),
                              data.code == HomeCardCode.coursePlan?const SizedBox.shrink():HelpIVideoIconWidget(helpVideoUrl: data.helpVideoUrl),  
                            ],
                          ),
                          Visibility(
                            visible: subTitle != null,
                            child: Container(
                              margin: EdgeInsets.only(top: 12.wMin),
                              child: subTitle,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.bottomLeft,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: List.generate(texts.length, (index){
                                    return texts[index];
                                  }),
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
            ),
          );
        },
      ),
    );
  }
}