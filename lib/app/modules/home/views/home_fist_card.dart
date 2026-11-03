import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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

        ThemeColorEntity? cardColor = StyleUtils.getCurrentThemeColors(
            controller.homeFistCardData.value.bgColor);

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cBgSolid.color,
            borderRadius: BorderRadius.circular(16.wMin),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              border: Border.all(
                width: 1.wMin,
                color: ColorUtils.parseColor(cardColor?.borderColor) ??
                    Colors.transparent,
              ),
              gradient: getLinearGradient(),
            ),
            child: _buildTodayTaskWidget(),
          ),
        );
      });
    });
  }

  LinearGradient? getLinearGradient() {
    ThemeColorEntity? cardColor = StyleUtils.getCurrentThemeColors(
        controller.homeFistCardData.value.bgColor);
    if (cardColor?.color == null) return null;
    if (ColorUtils.isHexColor(cardColor?.color ?? '')) {
      Color? color = ColorUtils.parseColor(cardColor?.color);
      if (color == null) return null;
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.6],
        colors: [
          color.withValues(alpha: 0.35),
          color.withValues(alpha: 0),
        ],
      );
    } else {
      return StyleUtils.parseCssLinearGradient(cardColor?.color);
    }
  }

  Widget _buildTodayTaskWidget() {
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
                tabs:
                    controller.homeFistCardTabData.map((e) => e.title).toList(),
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
          child: Obx(() {
            return TabBarView(
              controller: controller.fistCardTabController,
              // physics: const NeverScrollableScrollPhysics(),
              children:
                  List.generate(controller.homeFistCardTabData.length, (index) {
                return HomeFistCardTabView(
                    data: controller.homeFistCardTabData[index], index: index);
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
    if (widget.data.data?.guideStepEnum != LearningSettingStepsEnum.START_LEARNING && widget.data.data?.guideStepPge != null) {
      // 显示设置计划步骤
      return HomeCardLearnSettingStepsWidget(
        stepData: widget.data.data!.guideStepPge!,
        controller: controller,
      );
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
                child: _buildLearnBodyWidget(),
              ),
            ],
          ),
        ),
      ],
    );

  }


  Widget _buildLearnBodyWidget(){
    if(widget.data.data?.finish == null) {
      return Container(); // 没有计划
    }
    if(widget.data.data?.finish == true) {
      // 已完成计划
      return _buildNotQuizDataWidget();
    }

    if(widget.data.data?.generateStatusEnum == null){
      if((widget.data.data?.missions??[]).isEmpty){
        // 加载中
        return _buildLoadingWidget();
      }
      return _buildQuizWidget();
    }

    if(widget.data.data?.generateStatusEnum != HomeGenerateStatusEnum.FINISHED){
      // 加载中
      return _buildLoadingWidget();
    }

    if((widget.data.data?.missions??[]).isEmpty){
      // 计划完成
      return _buildNotQuizDataWidget();
    }

    return _buildQuizWidget();

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

        const Spacer(),

        SizedBox(
          height: 60.wMin,
          child: GuideStepWidget(
            id: GuideWidgetIds.homeStartLearningButton,
            onTap: () async {
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
        ),

        SizedBox(height: 48.wMin),

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

  /// 已经完成计划
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

  /// 计划加载中
  Widget _buildLoadingWidget() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _GradientLoopProgressBar(),
          SizedBox(height: 32.wMin),
          Text(
            widget.data.data?.generateMessage ?? "正在根据您的学习计划生成专属今日任务",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientLoopProgressBar extends StatefulWidget {
  const _GradientLoopProgressBar();

  @override
  State<_GradientLoopProgressBar> createState() => _GradientLoopProgressBarState();
}

class _GradientLoopProgressBarState extends State<_GradientLoopProgressBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24.wMin,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          return ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceLayerBase.color,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: AppTheme.cBorderDefault.color,
                        width: 1.wMin,
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final double left = (maxWidth + 100.wMin) * _controller.value - 100.wMin;
                    return Positioned(
                      left: left,
                      top: 0,
                      bottom: 0,
                      child: child ?? Container(),
                    );
                  },
                  child: Container(
                    width: 100.wMin,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xff6366F1).withValues(alpha: 0),
                          Color(0xff3986ED).withValues(alpha: 0.5),
                          Color(0xff4E76EF).withValues(alpha: 0.75),
                          Color(0xff3986ED).withValues(alpha: 0.5),
                          Color(0xff6366F1).withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
