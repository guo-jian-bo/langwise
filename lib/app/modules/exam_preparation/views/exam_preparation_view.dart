
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../utils/utils.dart';
import '../../../routes/routes.dart';
import '../bindings/exam_preparation_binding.dart';
import '../controllers/exam_preparation_controller.dart';

class ExamPreparationView extends GetView<ExamPreparationController> {
  final String tagText;
  const ExamPreparationView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => ExamPreparationView(tagText: tag),
      binding: ExamPreparationBinding(tagText: tag),
      routeName: Routes.EXAM_PREPARATION,
      arguments: arguments,
      preventDuplicates: false,
    );
  }
  
  @override
  Widget build(BuildContext context) {

    Widget buildCourseSelect(){

      return CardBoxWidget(
        pageIndex: 0,
        height: 920.wMin,
        currentPageIndex: controller.currentPageIndex.value,
        buttonDisable: controller.planNameInputDisabled.value,
        onContinue: () => controller.planNameNext(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 32.wMin),
            const CardTitleIconTextWidget(
              title: "创建备考计划",
              svg: "assets/svg/exam_plan/exam_plan_title1.svg",
            ),
            SizedBox(height: 40.wMin),
            ListAnimationWidget(
              index: 1,
              child: CardInputWidget(
                controller: controller.planNameInput,
                title: "计划名称",
                hintText: "添加计划名称",
                maxLength: 40,
                onClean: () {
                  controller.planNameInput.clear();
                  controller.getPlanNameInputDisabled();
                },
                onChanged: (value) {
                  controller.getPlanNameInputDisabled();
                },
              ),
            ),
            SizedBox(height: 24.wMin),
            const ListAnimationWidget(
              index: 2,
              child: CardSelectChangeWidget(
                title: "语言",
                value: "英语",
                // onTap: () {
                //   controller.selectCourse(context);
                // },
              ),
            ),
            SizedBox(height: 40.wMin),
            // ListAnimationWidget(
            //   index: 3,
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         "将包含如下课程学过的内容",
            //         style: TextStyle(
            //           fontSize: 24.wMin,
            //           color: AppTheme.cTextPrimary,
            //           fontWeight: FontWeight.w400,
            //         ),
            //       ),
            //       SizedBox(height: 6.wMin),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: List.generate(3, (index){
            //           return SizedBox(
            //             width: 120.wMin,
            //             child: Column(
            //               children: [
            //                 Container(
            //                   width: 120.wMin,
            //                   height: 120.wMin,
            //                   alignment: Alignment.center,
            //                   padding: EdgeInsets.all(8.wMin),
            //                   decoration: BoxDecoration(
            //                     shape: BoxShape.circle,
            //                     border: Border.all(width: 6.wMin, color: const Color(0xffB3B5BE)),
            //                     color: Colors.white,
            //                   ),
            //                   child: Container(
            //                     decoration: const BoxDecoration(
            //                       shape: BoxShape.circle,
            //                       color: Color(0xffB3B5BE),
            //                     ),
            //                   )
            //                 ),
            //                 SizedBox(height: 16.wMin),
            //                 Text(
            //                   "讨论动物文字太多就隐藏了可以的",
            //                   maxLines: 2,
            //                   overflow: TextOverflow.ellipsis,
            //                   style: TextStyle(
            //                     fontSize: 18.wMin,
            //                     color: AppTheme.cTextPrimary,
            //                     fontWeight: FontWeight.w400,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           );
            //         }),
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox(height: 40.wMin),
            

          ],
        ),
      );
    }

    Widget buildCreateDate(){

      Widget playDateWidget(String title, String value){
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Visibility(
                visible: value!= "",
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Visibility(
                visible: value == "",
                child: Text(
                  "无",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextDisabled,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
          
            ],
          ),
        );
      }

      return CardBoxWidget(
        height: 920.wMin,
        pageIndex: 1,
        currentPageIndex: controller.currentPageIndex.value,
        buttonDisable: controller.planNameInputDisabled.value,
        onContinue: () => controller.editPreparationDateNext(context),
        child: Column(
          children: [
            SizedBox(height: 32.wMin),
            const CardTitleIconTextWidget(
              title: "编辑备考时间",
              svg: "assets/svg/exam_plan/exam_plan_title2.svg",
            ),
            SizedBox(height: 40.wMin),
            ListAnimationWidget(
              index: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "孩子何时考试？",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16.wMin),
                  CardMinBox2Widget(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            playDateWidget(
                              "备考开始时间", 
                              DateFormatUtil.formatStr(controller.preparationStartDate.value, locale: Get.locale),
                            ),
                            playDateWidget(
                              "考试当天时间", 
                              DateFormatUtil.formatStr(controller.testDayDate.value, locale: Get.locale),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.wMin),
                        TapScaleWidget(
                          onTap: () => controller.editPreparationDate(context),
                          sclae: 1.1,
                          child: Text(
                            "编辑",
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: AppTheme.cTextBrand,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.wMin),
            ListAnimationWidget(
              index: 2,
              child: CardMinBoxWidget(
                title: "每次复习需要时长",
                borderColor: AppTheme.cBgTertiary,
                backColor: AppTheme.cBgTertiary,
                child: TapScaleWidget(
                  onTap: () => controller.selectReviewTime(context),
                  sclae: 1.05,
                  child: Obx((){
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.wMin),
                        color: AppTheme.cBgQuaternary.color,
                      ),
                      child: Text(
                        "${controller.reviewTimeDurationMinute.value}分钟",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            SizedBox(height: 16.wMin),
            ListAnimationWidget(
              index: 3,
              child: CardMinBoxWidget(
                title: "每日计划复习时间",
                borderColor: AppTheme.cBgTertiary,
                backColor: AppTheme.cBgTertiary,
                child: TapScaleWidget(
                  onTap: () => controller.selectReviewTimeMinute(context),
                  sclae: 1.05,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.wMin),
                      color: AppTheme.cBgQuaternary.color,
                    ),
                    child: Text(
                      DateFormatUtil.formatHM(controller.planYourReviewTime.value, locale: Get.locale),
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    /// 复习日期
    Widget buildReviewDate(){
      return CardBoxWidget(
        height: 920.wMin,
        pageIndex: 2,
        currentPageIndex: controller.currentPageIndex.value,
        continueText: "创建",
        onContinue: () => controller.createPreparationPlan(context),
        padding: EdgeInsets.symmetric(horizontal: 80.wMin),
        child: Column(
          children: [
            SizedBox(height: 32.wMin),
            const CardTitleIconTextWidget(
              title: "复习日期",
              svg: "assets/svg/exam_plan/exam_plan_title3.svg",
            ),
            SizedBox(height: 32.wMin),
            ListAnimationWidget(
              index: 1,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.topCenter,
                child: Obx((){
                return GridView.builder(
                  itemCount: controller.slotsResultList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.wMin,
                      crossAxisSpacing: 16.wMin,
                      childAspectRatio: 272 / 120,
                    ),
                    itemBuilder: (context, index) {
                      return CardReviewWidget(
                        index: index, 
                        data: controller.slotsResultList[index],
                        onRemove: (index){
                          controller.removeReviewDate(index);
                        },
                      );
                    },
                  );
                }),
              ),
            ),
            SizedBox(height: 24.wMin),

          ],
        ),
      );
    }


    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Scaffold(
            backgroundColor: AppTheme.cBgPrimary,
            resizeToAvoidBottomInset: true,
            body: Column(
              children: [
                const BreadcrumbWidget(),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 920.wMin,
                        child: Obx((){
                          return PageView(
                            controller: controller.pageController,
                            // physics: const NeverScrollableScrollPhysics(),
                            children: [
                              buildCourseSelect(),
                              if(controller.showCreatePage.value) buildCreateDate(),
                              if(controller.showReviewDatePage.value) buildReviewDate(),
                            ],
                            onPageChanged: (value) {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
