import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../bindings/select_learning_module_binding.dart';
import '../controllers/select_learning_module_controller.dart';

class SelectLearningModuleView extends GetView<SelectLearningModuleController> {
  final String tagText;
  const SelectLearningModuleView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => SelectLearningModuleView(tagText: tag),
      binding: SelectLearningModuleBinding(tagText: tag),
      routeName: Routes.SELECT_LEARNING_MODULE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BreadcrumbWidget(),
          _buildTipsWidget(),
          SizedBox(height: 16.wMin),
          Expanded(
            child: _buildListWidget(context),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ButtonWidget(
        text: "确定选择",
        sclae: 1.02,
        height: 64.wMin,
        width: 160.wMin,
        color: AppTheme.cSurfaceBrand,
        fontColor: AppTheme.cStaticWhite,
        borderRadius: 12.wMin,
        fontSize: 24.wMin,
        fontWeight: FontWeight.w500,
        onTap: () {
          controller.confirm();
        },
      ),
    );
  }

  Widget _buildTipsWidget(){
    return Obx((){
      if(controller.choicesList.isEmpty) return Container();
      int selectTipIndex = controller.selectTipsIndex.value;
      LanguageText? tips;
      if(selectTipIndex != -1){
        tips = LearningLangUtils.getLocalLang(controller.choicesList[selectTipIndex].tips);
      }
      return Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 80.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cBgSecondary.color,
            ),
            child: IntrinsicHeight(
              child: Row(
                children: List.generate(controller.choicesList.length, (index){
                  return _buildTipsItemWidget(controller.choicesList[index], index);
                }),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity,
              child: Visibility(
                visible: tips != null,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 80.wMin, right: 80.wMin, top: 16.wMin),
                  padding: EdgeInsets.all(16.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.wMin),
                    color: AppTheme.cFeedbackInfoBackground.color,
                  ),
                  child: Text(
                    tips?.text??"",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cFeedbackInfoText.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTipsItemWidget(LessonTypeEntityChoices data, int index){
    LanguageText? title = LearningLangUtils.getLocalLang(data.title);

    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          controller.selectTips(index);
        },
        sclae: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 12.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cBgQuaternary.color.withValues(alpha: controller.selectTipsIndex.value == index ? 1 : 0),
          ),
          child: Text(
            title?.text??"",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListWidget(BuildContext context){
    return Obx((){
      return GridView.builder(
        padding: EdgeInsets.only(
          left: 80.wMin,
          right: 80.wMin,
          bottom: MediaQuery.of(context).padding.bottom + 24.wMin,
        ),
        itemCount: controller.moduleList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 24.wMin,
          crossAxisSpacing: 24.wMin,
          mainAxisExtent: 276.wMin,
        ),
        itemBuilder: (context, index){
          return _buildModuleWidget(controller.moduleList[index]);
        },
      );
    });
  }

  Widget _buildModuleWidget(LessonTypeEntityList item){

    LanguageText? title = LearningLangUtils.getLocalLang(item.title);
    LanguageText? subtitle = LearningLangUtils.getLocalLang(item.subtitle);

    return TapScaleWidget(
      onTap: item.forceSelect ? null : () {
        controller.selectModule(item);
      },
      sclae: 1.01,
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary.color,
          borderRadius: BorderRadius.circular(16.wMin),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 64.wMin,
                  height: 64.wMin,
                  child: CachedImageWidget(
                    item.iconUrl??"",
                  ),
                ),
                Opacity(
                  opacity: item.forceSelect ? 0.6 : 1,
                  child: Obx((){
                    return SvgPicture.asset(
                      controller.selectDirections.contains(item.direction) ? "assets/svg/public/icon_check_b.svg" : "assets/svg/public/icon_uncheck_box.svg",
                      width: 32.wMin,
                      height: 32.wMin,
                    );
                  }),
                ),
              ],
            ),
            SizedBox(height: 16.wMin),
            Text(
              title?.text??"",
              style: TextStyle(
                fontSize: 32.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  subtitle?.text??"",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w400,
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
