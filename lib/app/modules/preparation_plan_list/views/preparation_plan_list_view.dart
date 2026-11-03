
import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../routes/routes.dart';
import '../bindings/preparation_plan_list_binding.dart';
import '../controllers/preparation_plan_list_controller.dart';

class PreparationPlanListView extends GetView<PreparationPlanListController> {
  final String tagText;
  const PreparationPlanListView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => PreparationPlanListView(tagText: tag),
      binding: PreparationPlanListBinding(tagText: tag),
      routeName: Routes.PREPARATION_PLAN_LIST,
      arguments: arguments,
      preventDuplicates: false,
    );
  }
  @override
  Widget build(BuildContext context) {

    Widget buildListPage(int planIndex, PreparationPlanModel data){

      return CardBoxWidget(
        height: 920.wMin,
        pageIndex: planIndex,
        currentPageIndex: controller.currentPageIndex.value,
        padding: EdgeInsets.symmetric(horizontal: 80.wMin),
        buttonDisable: data.buttonDisabled.value,
        buttonNotCurrentOption: true,
        continueText: "保存编辑",
        onClose: () {
          controller.removePlan(context, planIndex);
        },
        onContinue: () {
          controller.editPlan(planIndex);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 32.wMin),
            const CardTitleIconTextWidget(
              title: "备考计划",
              svg: "assets/svg/exam_plan/exam_plan_title3.svg",
            ),
            SizedBox(height: 40.wMin),
            ListAnimationWidget(
              index: 1,
              child: CardInputWidget(
                controller: data.planNameInput,
                title: "计划名称",
                hintText: "添加计划名称",
                // readOnly: true,
                enabledColor: AppTheme.cTextPrimary,
                onChanged: (value){
                  data.buttonDisabled.value = value.trim().isEmpty;
                },
                onClean: () {
                  data.planNameInput.clear();
                  data.buttonDisabled.value = true;
                },
              ),
            ),
        
            SizedBox(height: 24.wMin),
        
            const ListAnimationWidget(
              index: 2,
              child: CardSelectChangeWidget(
                title: "语言",
                value: "英语",
              ),
            ),
        
            SizedBox(height: 24.wMin),
        
            ListAnimationWidget(
              index: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "复习日期",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16.wMin),
                  GridView.builder(
                    itemCount: data.data.timeSlots?.length??0,
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
                        data: data.data.timeSlots?[index],
                        showLock: data.data.timeSlots?[index]?.isWaiting??false,
                        showOption: data.data.timeSlots?[index]?.isFinish??false,
                        onTap: (index) {
                          
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
        
            SizedBox(height: 24.wMin),
        
            ListAnimationWidget(
              index: 4,
              child: CardMinBoxWidget(
                title: "每次复习需要",
                borderColor: AppTheme.cBgTertiary,
                backColor: AppTheme.cBgTertiary,
                child: TapScaleWidget(
                  onTap: () => controller.selectReviewTime(context, planIndex),
                  sclae: 1.03,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.wMin),
                      color: AppTheme.cWhiteAlpha10,
                    ),
                    child: Text(
                      "${(data.data.dailyDuration??0) ~/ 60}分钟",
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
                  child: Stack(
                    children: [
                      Center(
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 920.wMin,
                            child: Obx((){
                              return PageView(
                                controller: controller.pageController,
                                children: List.generate(controller.planDataList.length, (index){
                                  return buildListPage(index, controller.planDataList[index]);
                                }),
                                onPageChanged: (value) {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                },
                              );
                            }),
                          ),
                        ),
                      ),
                      // Positioned(
                      //   top: 0,
                      //   right: 50.wMin,
                      //   child: ButtonWidget(
                      //     text: "添加",
                      //     borderRadius: 8.wMin,
                      //     width: 113.wMin,
                      //     height: 48.wMin,
                      //     fontSize: 24.wMin,
                      //     color: const Color(0xff00A1D6),
                      //     sclae: 1.05,
                      //     onTap: () {
                      //       controller.addPlan();
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
