
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';
import '../controllers/specialty_controller.dart';

class SpeciaityDefaultWidget extends GetView<SpecialtyController> {
  final HomeCardEntityItems data;
  const SpeciaityDefaultWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    
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

    return Container(
      padding: EdgeInsets.only(left: 32.wMin, top: 24.wMin),
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedImageWidget(
              bgImage?.imageUrl??"",
              errorWidget: Container(),
              placeholder: Container(),
              fadeInDuration: Duration.zero,
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: title??Container()),
                  HelpIVideoIconWidget(
                    padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                    helpVideoUrl: data.helpVideoUrl,
                  ),
                ],
              ),
              subTitle??Container(),
              const Spacer(),
              ...texts,
            ],
          ),
        ],
      ),
    );
  }


}
