import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_auth_box_widget.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../../theme/theme_quiz_utils.dart';
import '../../../../../routes/routes.dart';
import '../../../common/manage_scaffold.dart';
import '../../../utils/manage_auth_utils.dart';
import '../bindings/manage_review_exercises_binding.dart';
import '../controllers/manage_review_exercises_controller.dart';

class ManageReviewExercisesView extends GetView<ManageReviewExercisesController> {
  final String tagText;
  const ManageReviewExercisesView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_REVIEW_EXERCISES}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageReviewExercisesView(tagText: tag),
      binding: ManageReviewExercisesBinding(tag: tag),
      routeName: Routes.MANAGE_REVIEW_EXERCISES,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Column(
        children: [
          SizedBox(height: 10.wMin),
          _buildHeardWidget(),
          SizedBox(height: 10.wMin),
          Container(
            height: 1.wMin,
            color: AppTheme.cBorderPrimary.color,
          ),
          Expanded(
            child: _buildQuizListWidget(context),
          ),
          
        ],
      ),
    );
  }


  Widget _buildHeardWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Row(
        children: [
          SearchWidget(
            width: 500.wMin,
            height: 52.wMin,
            hintText: '搜索知识点',
            controller: controller.searchController,
            color: AppTheme.cSurfaceSecondary.color,
            borderColor: AppTheme.cBorderPrimary.color,
            fontColor: AppTheme.cTextPrimary.color,
            onChanged: (value) {
              controller.searchKnowledge();
            },
          ),
        
          const Spacer(),
      
          Obx((){
            return Text(
              "${controller.originalExerciseReviewList.length}个待审核",
              style: TextStyle(
                color: const Color(0xffFF781F),
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
              ),
            );
          }),

          SizedBox(width: 20.wMin),
      
          ManageButton(
            text: "开始审核",
            height: 54.wMin,
            padding: EdgeInsets.symmetric(horizontal: 20.wMin),
            color: AppTheme.cSurfaceBrand.color,
            borderColor: Colors.transparent,
            sclae: 1.03,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            onTap: () {
              controller.oneByOneExercise();
            },
          ),
      
          SizedBox(width: 20.wMin),
      
          ManageButton(
            text: "审核历史",
            height: 54.wMin,
            padding: EdgeInsets.symmetric(horizontal: 20.wMin),
            color: const Color(0xff353E5C),
            borderColor: Colors.transparent,
            sclae: 1.03,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            onTap: () {
              controller.toExerciseReviewHistory(false);
            },
          ),
      
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.exerciseReviewHistory],
            margin: EdgeInsets.only(left: 20.wMin),
            child: ManageButton(
              text: "管理员",
              height: 54.wMin,
              padding: EdgeInsets.symmetric(horizontal: 20.wMin),
              color: const Color(0xff353E5C),
              borderColor: Colors.transparent,
              sclae: 1.03,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              onTap: () {
                controller.toExerciseReviewHistory(true);
              },
            ),
          ),
      
        ],
      ),
    );
  }


  Widget _buildQuizListWidget(BuildContext context){
    return Obx((){

      if(!controller.hasMoreExercise.value){

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/svg/public/not_data.svg",
              width: 200.wMin,
            ),
            Text(
              "没有待审核的题目",
              style: TextStyle(
                fontSize: 32.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "所有题目都已审核完成",
              style: TextStyle(
                fontSize: 32.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 50.wMin),
            Visibility(
              visible: !controller.isFromTaskIds,
              child: ButtonWidget(
                text: "再审核一批",
                height: 58.wMin,
                width: 180.wMin,
                borderRadius: 6.wMin,
                color: AppTheme.cSurfaceBrand.color,
                sclae: 1.03,
                fontSize: 24.wMin,
                fontColor: Colors.white,
                onTap: () {
                  controller.getMoreExerciseReviewList();
                },
                
              ),
            ),
          ],
        );

      }

      return GridView.builder(
        padding: EdgeInsets.only(
          top: 24.wMin,
          bottom: 120.wMin,
          left: 24.wMin,
          right: 24.wMin,
        ),
        itemCount: controller.exerciseReviewList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.wMin,
          crossAxisSpacing: 16.wMin,
          childAspectRatio: 2.1,
        ),
        itemBuilder: (context, index) {
          return _buildQuizItemWidget(context, controller.exerciseReviewList[index], index);
        },
      );
    });
  }

  Widget _buildQuizItemWidget(BuildContext context, ExerciseReviewEntityList entity, int index){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Row(
        spacing: 8.wMin,
        children: [

          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  border: Border.all(
                    color: AppTheme.cBorderPrimary.color,
                    width: 1.wMin,
                  ),
                ),
                child: QuizPublicQuizWidget(
                  borderRadius: 12.wMin,
                  data: entity.exercise,
                  quizPlayStyle: ThemeQuizUtils.getQuizPlayStyle(),
                  bgColor: AppTheme.cBgSolid.color,
                ),
              ),
          
              Positioned(
                right: 0,
                bottom: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                      color: AppTheme.cSurfaceQuaternary.color,
                      child: SelectableText(
                        "taskId: ${entity.taskId??''}",
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: AppTheme.cTextSecondary.color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                      color: AppTheme.cSurfaceQuaternary.color,
                      child: SelectableText(
                        "ID: ${entity.exerciseId??''}",
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: AppTheme.cTextSecondary.color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                      color: AppTheme.cSurfaceQuaternary.color,
                      child: SelectableText(
                        entity.type??"",
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: AppTheme.cTextSecondary.color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          
            ],
          ),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                const Spacer(),

                ButtonWidget(
                  text: "演示题目",
                  height: 40.wMin,
                  borderRadius: 4.wMin,
                  color: const Color(0xff353E5C),
                  fontColor: Colors.white,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  sclae: 1.05,
                  onTap: OptimizeUtils.noneThrottle(() {
                    controller.demoExercise(context, entity);
                  }, 300),
                ),

                Container(
                  margin: EdgeInsets.only(top: 24.wMin),
                  child: ButtonWidget(
                    text: "题目错误(无法完成)",
                    height: 40.wMin,
                    borderRadius: 4.wMin,
                    color: AppTheme.cSurfaceError.color,
                    fontColor: Colors.white,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    sclae: 1.05,
                    onTap: OptimizeUtils.noneThrottle(() {
                      controller.exercisesErr(context, entity, 1);
                    }, 300),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 24.wMin),
                  child: ButtonWidget(
                    text: "题目错误(可以完成)",
                    height: 40.wMin,
                    borderRadius: 4.wMin,
                    color: AppTheme.cSurfaceError.color,
                    fontColor: Colors.white,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    sclae: 1.05,
                    onTap: OptimizeUtils.noneThrottle(() {
                      controller.exercisesErr(context, entity, 2);
                    }, 300),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 24.wMin),
                  child: ButtonWidget(
                    text: "图片/音频有瑕疵",
                    height: 40.wMin,
                    borderRadius: 4.wMin,
                    color: const Color(0xff2388FF),
                    fontColor: Colors.white,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    sclae: 1.05,
                    onTap: OptimizeUtils.noneThrottle(() {
                      controller.approved(context, entity, 4);
                    }, 300),
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 24.wMin),
                  child: ButtonWidget(
                    text: "一切完美",
                    height: 40.wMin,
                    borderRadius: 4.wMin,
                    color: const Color(0xff44AF5C),
                    fontColor: Colors.white,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    sclae: 1.05,
                    onTap: OptimizeUtils.noneThrottle(() {
                      controller.approved(context, entity, 5);
                    }, 300),
                  ),
                ),




              ],
            ),
          ),
        ],
      ),
    );
  }


}
