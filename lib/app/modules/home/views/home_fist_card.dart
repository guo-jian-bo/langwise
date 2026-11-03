import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lottie/lottie.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme_quiz_utils.dart';
import '../../../../utils/utils.dart';
import '../controllers/home_controller.dart';
import '../model/home_card_fist_tab_model.dart';
import 'home_card_learn_setting_steps_widget.dart';
import 'home_common_widget.dart';

class HomeFistCard extends GetView<HomeController> {
  const HomeFistCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Obx(() {
        if (!controller.fistCardTabInit.value) return Container();

        ThemeColorEntity? cardColor = StyleUtils.getCurrentThemeColors(controller.homeFistCardData.value.bgColor);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            border: Border.all(
              width: 1.wMin,
              color: ColorUtils.parseColor(cardColor?.borderColor) ?? Colors.transparent,
            ),
            gradient: getLinearGradient(),
          ),
          child: _buildTodayTaskWidget(),
        );
      });
    });
  }

  LinearGradient? getLinearGradient(){
    ThemeColorEntity? cardColor = StyleUtils.getCurrentThemeColors(controller.homeFistCardData.value.bgColor);
    if(cardColor?.color == null) return null;
    if(ColorUtils.isHexColor(cardColor?.color ?? '')){
      Color? color = ColorUtils.parseColor(cardColor?.color);
      if(color == null) return null;
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.6],
        colors: [
          color.withValues(alpha: 0.35), 
          color.withValues(alpha: 0),
        ],
      );
    }else{
      return StyleUtils.parseCssLinearGradient(cardColor?.color);
    }
  }


  Widget _buildTodayTaskWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32.wMin),
        Row(
          children: [
            Expanded(
              child: HomeCardTabbarWidget(
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                selectIndex: controller.fistCardTabIndex.value,
                tabs: controller.homeFistCardTabData.map((e) => e.title).toList(),
                onTap: (p0) {
                  controller.fistCardTabIndex.value = p0;
                  controller.fistCardTabController?.animateTo(p0);
                },
              ),
            ),
            HelpIVideoIconWidget(
              padding: EdgeInsets.symmetric(horizontal: 20.wMin),
              helpVideoUrl: controller.homeFistCardData.value.helpVideoUrl,
            ),
          ],
        ),
        Expanded(
          child: Obx((){
            return TabBarView(
              controller: controller.fistCardTabController,
              // physics: const NeverScrollableScrollPhysics(),
              children: List.generate(controller.homeFistCardTabData.length, (index) {
                return HomeFistCardTabView(data: controller.homeFistCardTabData[index], index: index);
              }),
            );
          }),
        ),
      ],
    );
  }



}

class HomeFistCardTabView extends StatefulWidget {
  final HomeCardFistTabModel data;
  final int index;
  const HomeFistCardTabView({super.key, required this.data, required this.index});

  @override
  State<HomeFistCardTabView> createState() => _HomeFistCardTabViewState();
}

class _HomeFistCardTabViewState extends State<HomeFistCardTabView> {
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    if(widget.data.data?.guideStepEnum != LearningSettingStepsEnum.START_LEARNING && widget.data.data?.guideStepPge != null){
      return HomeCardLearnSettingStepsWidget(
        stepData: widget.data.data!.guideStepPge!,
        controller: controller,
      );
    }else{
      return _buildLearnWidget();
    }
  }

  Widget _buildLearnWidget(){
    Widget bodyWidget = Container();
    Widget buttonWidget = Container();
    if (widget.data.data?.finish != null) {
      if (widget.data.data?.finish ?? true) {
        bodyWidget = _buildNotQuizDataWidget();
      } else {
        bodyWidget = _buildQuizWidget();
        buttonWidget = SizedBox(
          height: 60.wMin,
          child: GuideStepWidget(
            id: GuideWidgetIds.homeStartLearningButton,
            onTap: () async{
              controller.checkFistCard(context);
            },
            sclae: 1.03,
            child: ContinueButtonWidget(
              text: "开始学习",
              fontSize: 24.wMin,
              height: 60.wMin,
              width: 488.wMin,
              fontColor: AppTheme.cStaticWhite,
            ),
          ),
        );
      }
    } else {
      if (widget.data.data?.exercises?.isEmpty ?? true) {
        bodyWidget = _buildNotPlanWidget();
        buttonWidget = ContinueButtonWidget(
          text: "去添加",
          fontSize: 24.wMin,
          height: 60.wMin,
          width: 488.wMin,
          fontColor: AppTheme.cStaticWhite,
          onTap: () => controller.toCreateStudyPlan(context),
        );
      }
    }

    return Column(
      children: [
        SizedBox(height: 10.wMin),
        Expanded(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                child: StyleUtils.getText(widget.data.subTitle),
              ),
              Expanded(
                child: bodyWidget,
              ),
            ],
          ),
        ),
        buttonWidget,
        SizedBox(height: 48.wMin),
      ],
    );
  }

  Widget _buildQuizWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          child: CarouselSlider(
            key: ValueKey(widget.data.hashCode),
            carouselController: CarouselSliderController(),
            options: CarouselOptions(
              autoPlay: true,
              viewportFraction: 1,
            ),
            items: List.generate(widget.data.data?.exercises?.length ?? 0, (index) {
              return Container(
                width: 560.wMin,
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: QuizPublicQuizWidget(
                    borderRadius: 18.wMin,
                    data: widget.data.data?.exercises?[index]?.exercise,
                    quizPlayStyle: ThemeQuizUtils.getQuizPlayStyle(),
                    bgColor: AppTheme.cBgSolid.color,
                  ),
                ),
              );
            }),
          ),
        ),

        Row(
          children: [
            _buildQuizInfoItem(
              "任务总数",
              "${widget.data.data?.missions?.length ?? 0}",
            ),
            _buildQuizInfoItem(
              "预计用时",
              "约 ${((widget.data.data?.exerciseDuration ?? 0) / 60).round()} 分钟",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuizInfoItem(String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 4.wMin),
                  width: 6.wMin,
                  height: 6.wMin,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 10.wMin),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextBrand.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotPlanWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/svg/public/home_not_plan.svg",
          height: 200.wMin,
        ),
        SizedBox(height: 24.wMin),
        Text(
          "请先添加学习计划",
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cStaticWhite,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
  }

  Widget _buildNotQuizDataWidget() {
    ThemeTextStyleEntity? titleStyle = StyleUtils.getCurrentThemeText(widget.data.title?.style);
    Color? titleColor = ColorUtils.parseColor(titleStyle?.color);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Visibility(
          visible: controller.fistFinishSvg.isNotEmpty,
          child: Lottie.asset(
            controller.fistFinishSvg.value,
            height: 250.wMin,
          ),
        ),
        Text(
          "太棒啦！\n今日计划已完成！",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40.wMin,
            fontWeight: FontWeight.w600,
            color: titleColor ?? AppTheme.cTextPrimary,
          ),
        ),
        TapScaleWidget(
          onTap: () => controller.overlearning(context),
          sclae: 1.02,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.wMin),
            child: Text(
              "巩固今日",
              style: TextStyle(
                fontSize: 25.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextBrand,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
