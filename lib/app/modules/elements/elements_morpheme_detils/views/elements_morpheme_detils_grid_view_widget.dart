import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../utils/utils.dart';
import '../controllers/elements_morpheme_detils_controller.dart';

class ElementsMorphemeDetilsGridViewWidget extends GetView<ElementsMorphemeDetilsController> {
  final String tagText;
  /// 网格视图
  const ElementsMorphemeDetilsGridViewWidget({super.key, required this.tagText});

  @override
  // String? get tag => Get.arguments['contentId']?.toString();
  // String? get tag => StorageUtil().getString("ElementsMorphemeDetilsDuplicatePagesId");
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24.wMin,
        right: 24.wMin,
        top: 110.wMin + MediaQuery.of(context).padding.top,
      ),
      child: Obx((){
        return GridView.builder(
          controller: controller.gridScrollController,
          itemCount: controller.gridDatas.length,
          padding: EdgeInsets.only(
            left: 24.wMin,
            right: 24.wMin,
            top: 24.wMin,
            bottom: 200.wMin,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 24.wMin,
            crossAxisSpacing: 24.wMin,
          ),
          itemBuilder: (context, index) {
            return ElementsMorphemeDetilsGridViewItemWidget(
              content: controller.morphemeDetils.value.content??"",
              type: controller.morphemeDetils.value.type??"",
              data: controller.gridDatas[index],
              onTap: () {
                controller.toWordDetils(context, controller.gridDatas[index]);
              },
            );
          },
        );
      }),
    );
  }
}

class ElementsMorphemeDetilsGridViewItemWidget extends StatefulWidget {
  final String content;
  final String type;
  final CardMorphemeWordEntityDatas data;
  final void Function()? onTap;
  const ElementsMorphemeDetilsGridViewItemWidget({super.key, this.onTap, required this.data, required this.content, required this.type});

  @override
  State<ElementsMorphemeDetilsGridViewItemWidget> createState() => _ElementsMorphemeDetilsGridViewItemWidgetState();
}

class _ElementsMorphemeDetilsGridViewItemWidgetState extends State<ElementsMorphemeDetilsGridViewItemWidget> {
  final ConfigController configController = Get.find<ConfigController>();
  
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    Color color = StatusUtils.getMorphemeTagColor(widget.type);

    LanguageConfigColorModel? colorModel = StatusUtils.getConfigColorForAbbr(configController.colorConfigs.value.pos, widget.data.pos);

    String? content = widget.content.replaceAll("-", "");
    int index = widget.data.content?.indexOf(content)??-1;

    String before = "";
    String after = "";

    if(index != -1){
      after = widget.data.content?.substring(index + (content.length))??""; // "dis" 之后的部分
      before = widget.data.content?.substring(0, index)??""; // "dis" 之前的部分
    }
    

    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          _isHovered = false;
        });
      },
      child: TapScaleWidget(
        onTap: widget.onTap,
        sclae: 1.02,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.wMin),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: _isHovered ? 1.1 : 1,
                child: CachedImageWidget(
                  widget.data.imageUrl??"",
                  errorWidget: buildEmptyWidget(),
                  placeholder: buildLoadingWidget(),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.wMin),
                color: AppTheme.cBlackAlpha50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 42.wMin,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.cStaticWhite,
                        ),
                        children: [
                          TextSpan(text: before),
                          TextSpan(
                            text: content,
                            style: TextStyle(
                              color: color,//根据前缀后缀改变颜色
                            ),
                          ),
                          TextSpan(text: after),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Obx((){
                      LanguageText? gloss = LearningLangUtils.getShowForNone(widget.data.gloss??[]);
                      if(gloss == null) return Container();
                      return Text(
                        gloss.text??"",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cStaticWhite,
                        ),
                      );
                    }),
                  ],
                ),
        
              ),
              Positioned(
                right: 16.wMin,
                top: 16.wMin,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.wMin),
                    color: colorModel?.color?.borderColor,
                  ),
                  child: Text(
                    widget.data.posTitle??"",
                    style: TextStyle(
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cStaticWhite,
                    ),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(widget.data.pronunciations?.length ?? 0, (index) {
                  return PlayLottieIconWidget(
                    size: 48.wMin,
                    audioUrl: widget.data.pronunciations?[index]?.audioUrl,
                    backgroundImageUrl: widget.data.pronunciations?[index]?.nationalIconUrl,
                  );
                }),
              )



            ],
          ),
        ),
      ),
    );
  }
}