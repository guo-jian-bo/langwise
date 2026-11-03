import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../theme/theme_quiz_utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/manage_auth_box_widget.dart';
import '../../../../common/manage_scaffold.dart';
import '../../../../utils/manage_auth_utils.dart';
import '../bindings/manage_review_exercises_history_binding.dart';
import '../controllers/manage_review_exercises_history_controller.dart';

class ManageReviewExercisesHistoryView extends GetView<ManageReviewExercisesHistoryController> {
  final String tagText;
  const ManageReviewExercisesHistoryView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async{
    final tag = '${Routes.MANAGE_REVIEW_EXERCISES_HISTORY}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageReviewExercisesHistoryView(tagText: tag),
      binding: ManageReviewExercisesHistoryBinding(tag: tag),
      routeName: Routes.MANAGE_REVIEW_EXERCISES_HISTORY,
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
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.exerciseReviewStatistics],
            child: _buildAdministratorFilteringWidget(context),
          ),
          SizedBox(height: 10.wMin),
          Container(
            height: 1.wMin,
            color: AppTheme.cBorderPrimary.color,
          ),
          Expanded(child: _buildQuizListWidget(context)),
          
        ],
      ),
    );
  }

  Widget _buildHeardWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Row(
        children: [

          Builder(
            builder: (context) {
              return TapScaleWidget(
                onTap: () {
                  controller.filterTime(context);
                },
                sclae: 1.02,
                child: Container(
                  height: 50.wMin,
                  padding: EdgeInsets.only(left: 16.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: AppTheme.cSurfaceSecondary.color,
                    border: Border.all(
                      color: AppTheme.cBorderPrimary.color,
                      width: 1.wMin,
                    ),
                  ),
                  child: Obx((){

                    String startDate = "";
                    String endDate = "";
                    
                    if(controller.startDate.value == null || controller.endDate.value == null){
                      startDate = "开始日期";
                      endDate = "结束日期";
                    }else{
                      startDate = DateFormatUtil.formatStr(controller.startDate.value!);
                      endDate = DateFormatUtil.formatStr(controller.endDate.value!);
                    }


                    return Row(
                    children: [
                      Text(
                        "$startDate ～ $endDate",
                          style: TextStyle(
                            color: AppTheme.cTextPrimary.color,
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TapScaleWidget(
                          onTap: () {
                            controller.clearFilterTime();
                          },
                          sclae: 1.1,
                          child: Container(
                            width: 50.wMin,
                            height: 50.wMin,
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              "assets/svg/public/x.svg",
                              width: 28.wMin,
                            ),
                          ),
                          
                        ),

                      ],
                    );
                  }),
                ),
              );
            },
          ),

          SizedBox(width: 20.wMin),
          IconDropdownMenuWidget(
            sclae: 1.03,
            width: 250.wMin,
            menuHeight: 800.wMin,
            textStyle: TextStyle(
              color: AppTheme.cTextPrimary.color,
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
            ),
            items: controller.filterScoreList,
            onTap: (data, index) {
              controller.filterScore(data);
            },
            child: Container(
              height: 54.wMin,
              width: 250.wMin,
              padding: EdgeInsets.only(right: 10.wMin),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.cSurfaceSecondary.color,
                borderRadius: BorderRadius.circular(10.wMin),
                border: Border.all(color: AppTheme.cBorderPrimary.color, width: 1.wMin),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Center(
                      child: Obx((){
                        int selectedScore = controller.selectedScore.value;
                        List<IconDropdownIconData<int>> filterScoreList = controller.filterScoreList;
                        return Text(
                          filterScoreList.firstWhere((element) => element.value == selectedScore).title,
                          style: TextStyle(
                            color: AppTheme.cTextPrimary.color,
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }),
                    ),
                  ),
                  SvgPicture.asset(
                    "assets/svg/manage/icon_arrow_down.svg",
                    width: 24.wMin,
                    height: 24.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 20.wMin),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.exerciseTypeList],
            child: Obx((){
              return IconDropdownMenuWidget(
                sclae: 1.03,
                width: 250.wMin,
                menuHeight: 900.wMin,
                textStyle: TextStyle(
                  color: AppTheme.cTextPrimary.color,
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                ),
                items: controller.exerciseFilerList.toList(),
                onTap: (data, index) {
                  controller.filterExerciseType(data);
                },
                child: Container(
                  height: 54.wMin,
                  width: 250.wMin,
                  padding: EdgeInsets.only(right: 10.wMin),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceSecondary.color,
                    borderRadius: BorderRadius.circular(10.wMin),
                    border: Border.all(color: AppTheme.cBorderPrimary.color, width: 1.wMin),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Center(
                          child: Obx((){
                            String selectedExerciseType = controller.selectedExerciseType.value;
                            List<IconDropdownIconData<String>> exerciseFilerList = controller.exerciseFilerList;
                            String? title = exerciseFilerList.firstWhereOrNull((element) => element.value == selectedExerciseType)?.title;
                            return Text(
                              title??"",
                              style: TextStyle(
                                color: AppTheme.cTextPrimary.color,
                                fontSize: 20.wMin,
                                fontWeight: FontWeight.w400,
                              ),
                            );
                          }),
                        ),
                      ),
                      SvgPicture.asset(
                        "assets/svg/manage/icon_arrow_down.svg",
                        width: 24.wMin,
                        height: 24.wMin,
                        colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          const Spacer(),
      
         Obx((){
          return PagerWidget(
            dataCount: controller.totalCount.value,
            controller: controller.pagerController,
            activeColor: AppTheme.cTextPrimary.color,
            onPage: (page, pageSize) {
              controller.pagerCallback(page, pageSize);
            },
          );
         }),
      
        ],
      ),
    );
  }


  Widget _buildAdministratorFilteringWidget(BuildContext context){
    if(!controller.fromAdmin) return Container();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [


          Text(
            "审核员：",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w400,
            ),
          ),

          Obx((){

            String? selectedAuditor = controller.auditorList.firstWhereOrNull((element) => element.userId == controller.selectedUserId.value)?.userName;

            return IconDropdownMenuWidget(
              sclae: 1.03,
              width: 200.wMin,
              textStyle: TextStyle(
                color: AppTheme.cTextPrimary.color,
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
              ),
              items: List.generate(controller.auditorList.length, (index){
                return IconDropdownIconData<int?>(
                  title: controller.auditorList[index].userName,
                  value: controller.auditorList[index].userId,
                );
              }),
              onTap: (data, index) {
                controller.filterAuditor(data.value);
              },
              child: Container(
                height: 54.wMin,
                width: 200.wMin,
                padding: EdgeInsets.only(right: 10.wMin),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.cSurfaceSecondary.color,
                  borderRadius: BorderRadius.circular(10.wMin),
                  border: Border.all(color: AppTheme.cBorderPrimary.color, width: 1.wMin),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          selectedAuditor??"",
                          style: TextStyle(
                            color: AppTheme.cTextPrimary.color,
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      "assets/svg/manage/icon_arrow_down.svg",
                      width: 24.wMin,
                      height: 24.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            );
          }),

          SizedBox(width: 20.wMin),

          ButtonWidget(
            text: "查看统计",
            height: 50.wMin,
            width: 120.wMin,
            borderRadius: 10.wMin,
            color: const Color(0xff353E5C),
            fontColor: Colors.white,
            fontSize: 20.wMin,
            fontWeight: FontWeight.w400,
            sclae: 1.05,
            onTap: () {
              controller.toStatistics();
            },
          ),
      
          
      
        ],
      ),
    );
  }



  Widget _buildQuizListWidget(BuildContext context){
    return Obx((){
      if(controller.exerciseReviewList.isEmpty){
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/svg/public/not_data.svg",
              width: 200.wMin,
            ),
            Text(
              "暂无数据",
              style: TextStyle(
                fontSize: 32.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
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
          childAspectRatio: 2.09,
        ),
        itemBuilder: (context, index) {
          return _buildQuizItemWidget(context, controller.exerciseReviewList[index], index);
        },
      );
    });
  }

  Widget _buildQuizItemWidget(BuildContext context, ExerciseReviewEntityList entity, int index){

    String checkedStr = DateFormatUtil.formatStrtoStr(entity.checked, newPattern: "yyyy-MM-dd HH:mm");

    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Row(
        spacing: 10.wMin,
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(12.wMin),
            child: Stack(
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
                  left: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                    color: AppTheme.cSurfaceQuaternary.color,
                    child: SelectableText(
                      "审核时间：$checkedStr  审核员：${entity.userName??''}",
                      style: TextStyle(
                        color: AppTheme.cSurfaceWarning.color,
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
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
            
                Visibility(
                  visible: entity.statusScoreStr.isNotEmpty,
                  child: Positioned(
                    right: 8.wMin,
                    top: 8.wMin,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                      decoration: BoxDecoration(
                        color: entity.statusScoreColor,
                        borderRadius: BorderRadius.circular(4.wMin),
                      ),
                      child: SelectableText(
                        entity.statusScoreStr,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
            
            
              ],
            ),
          ),



          Expanded(
            child: Obx((){
              bool isEdit = index == controller.reReviewTaskIndex.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  Visibility(
                    visible: isEdit && controller.fromAdmin,
                    child: ManageAuthBoxWidget(
                      authCodes: const [ManageAuthCode.exerciseDelete],
                      child: TapScaleWidget(
                        sclae: 1.1,
                        onTap: OptimizeUtils.noneThrottle(() {
                          controller.deleteExercis(context, entity);
                        }, 300),
                        child: SvgPicture.asset(
                          "assets/svg/public/icon_delete.svg",
                          width: 32.wMin,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),

                  ButtonWidget(
                    text: "演示题目",
                    height: 38.wMin,
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

                  Visibility(
                    visible: !isEdit,
                    child: Container(
                      margin: EdgeInsets.only(top: 10.wMin),
                      child: ButtonWidget(
                        text: "重新审核",
                        height: 38.wMin,
                        borderRadius: 4.wMin,
                        color: const Color(0xffFF781F),
                        fontColor: Colors.white,
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        sclae: 1.05,
                        onTap: OptimizeUtils.noneThrottle(() {
                          controller.reReview(index);
                        }, 300),
                      ),
                    ),
                  ),

                  Visibility(
                    visible: isEdit,
                    child: Column(
                      children: [
                    
                        Visibility(
                          visible: entity.exercise?.editable == true && controller.fromAdmin,
                          child: ManageAuthBoxWidget(
                            authCodes: const [ManageAuthCode.exerciseEdit],
                            margin: EdgeInsets.only(top: 10.wMin),
                            child: ButtonWidget( // 部分题目可编辑
                              text: "编辑题目",
                              height: 38.wMin,
                              borderRadius: 4.wMin,
                              color: const Color(0xff353E5C),
                              fontColor: Colors.white,
                              fontSize: 16.wMin,
                              fontWeight: FontWeight.w400,
                              sclae: 1.05,
                              onTap: OptimizeUtils.noneThrottle(() {
                                controller.editExercises(entity);
                              }, 300),
                            ),
                          ),
                        ),
                    
                        Visibility(
                          visible: entity.exercise?.regenerable == true && controller.fromAdmin,
                          child: ManageAuthBoxWidget(
                            authCodes: const [ManageAuthCode.exerciseRegenerate],
                            margin: EdgeInsets.only(top: 10.wMin),
                            child: ButtonWidget( // 部分题目可重新生成
                              text: "重新生成",
                              height: 38.wMin,
                              borderRadius: 4.wMin,
                              color: const Color(0xffFF781F),
                              fontColor: Colors.white,
                              fontSize: 16.wMin,
                              fontWeight: FontWeight.w400,
                              sclae: 1.05,
                              onTap: OptimizeUtils.noneThrottle(() {
                                controller.reGenerate(context, entity);
                              }, 300),
                            ),
                          ),
                        ),
                  

                        Container(
                          margin: EdgeInsets.only(top: 16.wMin),
                          child: ButtonWidget(
                            text: "题目错误(无法完成)",
                            height: 38.wMin,
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
                          margin: EdgeInsets.only(top: 16.wMin),
                          child: ButtonWidget(
                            text: "题目错误(可以完成)",
                            height: 38.wMin,
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
                          margin: EdgeInsets.only(top: 16.wMin),
                          child: ButtonWidget(
                            text: "图片/音频有瑕疵",
                            height: 38.wMin,
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
                          margin: EdgeInsets.only(top: 16.wMin),
                          child: ButtonWidget(
                            text: "一切完美",
                            height: 38.wMin,
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
              );
            }),
          ),
        ],
      ),
    );
  }




}
