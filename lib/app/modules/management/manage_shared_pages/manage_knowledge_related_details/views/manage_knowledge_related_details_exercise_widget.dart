

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/stores/stores.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../controllers/manage_knowledge_related_details_controller.dart';

class ManageKnowledgeRelatedDetailsExerciseWidget extends StatelessWidget {
  final String controllerTag;
  const ManageKnowledgeRelatedDetailsExerciseWidget({super.key, required this.controllerTag});

  ManageKnowledgeRelatedDetailsController get controller => 
      Get.find<ManageKnowledgeRelatedDetailsController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            _buildExerciseTypeList(),
            Expanded(child: _buildExerciseListWidget(context)),
          ],
        ),

        Obx((){
          if(!controller.loading.value){
            return const SizedBox.shrink();
          }
          return Container(
            alignment: Alignment.center,
            color: Colors.transparent,
            child: const CircularProgressIndicator(),
          );
        }),

      ],
    );
  }


  


  Widget _buildOptionWidget(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: color),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18.wMin,
          color: const Color(0xffEBEFF5),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  /// 题型列表
  Widget _buildExerciseTypeList() {
    return Container(
      width: 262.wMin,
      padding: EdgeInsets.only(top: 24.wMin),
      decoration: BoxDecoration(
        color: const Color(0xff19213D).withValues(alpha: 0.6),
        border: Border(
          right: BorderSide(
            color: const Color(0xff353E5C),
            width: 1.wMin,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.wMin,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            child: Text(
              "题型列表",
              style: TextStyle(
                fontSize: 18.wMin,
                color: const Color(0xffFFFFFF),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: 24.wMin,
                left: 24.wMin,
                right: 24.wMin,
              ),
              child: Obx((){
                return Column(
                  spacing: 8.wMin,
                  children: List.generate(controller.exerciseTypeList.length, (index){
                    return _buildExerciseTypeItemWidget(controller.exerciseTypeList[index]);
                  }),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTypeItemWidget(ExerciseTypeListEntity entity) {
    return TapScaleWidget(
      onTap: () {
        controller.setSelectedExerciseType(entity.type);
      },
      sclae: 1,
      child: Obx((){
        bool selected = controller.selectedExerciseType.value == entity.type;
        int count = entity.count??0;
      
        Color bgColor = const Color(0xff19213D).withValues(alpha: 0.5);

        if(count == 0){
          bgColor = Colors.transparent;
        }

        if(selected){
          bgColor = const Color(0xff2388FF);
        }
        
      
        return Container(
          height: 41.wMin,
          padding: EdgeInsets.symmetric(horizontal: 6.wMin),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.wMin),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entity.name??"",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: selected ? const Color(0xffFFFFFF) : const Color(0xff767E95),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
      
              Text(
                "${entity.count??''}",
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: selected ? const Color(0xffFFFFFF) : const Color(0xff767E95),
                  fontWeight: FontWeight.w400,
                ),
              )
      
            ],
          ),
        );
      
      }),
    );
  }


  /// 题目列表
  Widget _buildExerciseListWidget(BuildContext context) {
    return Stack(
      children: [

        Obx((){
          return GridView.builder(
            controller: controller.exerciseScrollController,
            itemCount: controller.exerciseList.length,
            padding: EdgeInsets.only(top: 24.wMin, left: 24.wMin, right: 24.wMin, bottom: 100.wMin),
            itemBuilder: (context, index) {
              return _buildExerciseItemWidget(context, controller.exerciseList[index], index);
            },
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 32.wMin,
              crossAxisSpacing: 32.wMin,
              childAspectRatio: 1.76,
            ),
          );
        }),

        Positioned(
          right: 16.wMin,
          bottom: 16.wMin,
          child: _buildBatchOperationWidget(context),
        ),

      ],
    );
  }

  Widget _buildExerciseItemWidget(BuildContext context, QuizModel entity, int index) {
    String statusText = "";
    Color statusColor = const Color(0xffEBEFF5);

    if(entity.access == "NORMAL"){
      statusText = "上架";
      statusColor = const Color(0xff44AF5C); // 上架颜色
    }else if(entity.access == "INTERNAL"){
      statusText = "下架";
      statusColor = const Color(0xffFF2D46); // 下架颜色
    }

    return Obx((){
      bool selected = controller.exerciseSelectIds.contains(entity.uid);
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff19213D).withValues(alpha: 0.5),
          border: Border.all(width: 5.wMin, color: const Color(0xff19213D)),
        ),
        child: AspectRatio(
          aspectRatio: 1.76,
          child: Stack(
            children: [
              TapScaleWidget(
                onTap: (){
                  controller.toDemonstrate(controller.exerciseList, current: entity);
                },
                sclae: 1.01,
                child: QuizPublicQuizWidget(
                  borderRadius: 12.wMin,
                  data: entity,
                ),
              ),
              Visibility(
                visible: statusText.isNotEmpty,
                child: Positioned(
                  left: 7.wMin,
                  bottom: 7.wMin,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(2.wMin),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12.wMin,
                        color: const Color(0xffEBEFF5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 4.wMin,
                top: 4.wMin,
                child: Row(
                  children: [
                  
                    Visibility(
                      visible: entity.accessNormal,
                      child: ManageAuthBoxWidget(
                        authCodes: const [ManageAuthCode.exerciseLessonBind],
                        child: TapScaleWidget(
                          onTap: () {
                            controller.toSendToCourse(context, entity);
                          },
                          sclae: 1.1,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                            color: const Color(0xff2388FF),
                            child: Text(
                              "发送",
                              style: TextStyle(
                                fontSize: 16.wMin,
                                color: const Color(0xffEBEFF5),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Visibility(
                      visible: entity.editable == true,
                      child: ManageAuthBoxWidget(
                        authCodes: const [ManageAuthCode.exerciseEdit],
                        margin: EdgeInsets.only(left: 6.wMin),
                        child: TapScaleWidget(
                          onTap: () {
                            controller.editQuiz(entity);
                          },
                          sclae: 1.1,
                          child: Container(
                            padding: EdgeInsets.all(6.wMin),
                            color: Colors.transparent,
                            child: SvgPicture.asset(
                              "assets/svg/public/icon_edit.svg",
                              width: 25.5.wMin,
                              height: 25.5.wMin,
                            ),
                          ),
                        ),
                      ),
                    ),

                    ManageAuthBoxWidget(
                      authCodes: const [ManageAuthCode.exerciseOperationCode],
                      margin: EdgeInsets.only(left: 6.wMin),
                      child: TapScaleWidget(
                        onTap: (){
                          controller.showDeleteQuizDialog(context, index, entity);
                        },
                        child: SvgPicture.asset(
                          "assets/svg/manage/icon_bg_delete.svg",
                          width: 25.5.wMin,
                          height: 25.5.wMin,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              Positioned(
                right: 4.26.wMin,
                bottom: 4.26.wMin,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(27, 33, 60, 0.6),
                        borderRadius: BorderRadius.circular(4.wMin),
                      ),
                      child: SelectableText(
                        "ID:${entity.uid?.toString() ?? ''}",
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: const Color(0xffEBEFF5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(27, 33, 60, 1),
                        borderRadius: BorderRadius.circular(4.wMin),
                      ),
                      child: SelectableText(
                        entity.type ?? '',
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: const Color(0xffEBEFF5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: controller.isBatchOperation.value,
                child: Positioned(
                  left: 0,
                  top: 0,
                  child: TapScaleWidget(
                    onTap: () {
                      if (entity.uid == null) return;
                      controller.selectExerciseIds(entity.uid!);
                    },
                    sclae: 1.1,
                    child: Container(
                      padding: EdgeInsets.all(14.wMin),
                      color: Colors.transparent,
                      child: SvgPicture.asset(
                        selected ? "assets/svg/manage/icon_check_box.svg" : "assets/svg/manage/icon_uncheck_box.svg",
                        width: 25.5.wMin,
                        height: 25.5.wMin,
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      );
    });
  }


  /// 操作菜单
  Widget _buildBatchOperationWidget(BuildContext context){
    return Container(
      child: Row(
        children: [

          Visibility(
            visible: UserStore.to.rolePermissions.value.userIsExerciseReviewer,
            child: Obx((){
              return ButtonWidget(
                text: "待审核 ${controller.exercisePendingReviewIds.length} 个",
                fontColor: Colors.white,
                color: const Color(0xffFF781F),
                fontSize: 18.wMin,
                height: 56.wMin,
                borderRadius: 4.wMin,
                sclae: 1.05,
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                onTap: () {
                  controller.toQuizReview();
                },
              );
            }),
          ),

          Obx((){
            if(!controller.isBatchOperation.value){
              return const SizedBox.shrink();
            }
            return Row(
              children: [
                SizedBox(width: 12.wMin),
                TapScaleWidget(
                  onTap: () {
                    controller.exerciseBatchDelete(context);
                  },
                  sclae: 1.05,
                  child: _buildOptionWidget(
                    "删除已选",
                    const Color(0xffFF2D46),
                  ),
                ),
                SizedBox(width: 12.wMin),
                TapScaleWidget(
                  onTap: () {
                    controller.upDownLessonQuiz(true);
                  },
                  sclae: 1.05,
                  child: _buildOptionWidget("上架已选", const Color(0xff44AF5C)),
                ),
                SizedBox(width: 12.wMin),
                TapScaleWidget(
                  onTap: () {
                    controller.upDownLessonQuiz(false);
                  },
                  sclae: 1.05,
                  child: _buildOptionWidget("下架已选", const Color(0xffFF2D46)),
                ),
                SizedBox(width: 12.wMin),
                TapScaleWidget(
                  onTap: () {
                    controller.selectAllQuiz();
                  },
                  sclae: 1.05,
                  child: _buildOptionWidget(
                    controller.exerciseIsSelectAll.value ? "取消全选" : "全选",
                    const Color(0xff465070),
                  ),
                ),
              ],
            );
          }),

          SizedBox(width: 12.wMin),

          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.exerciseOperationCode],
            child: ButtonWidget(
              text: "批量操作",
              fontColor: Colors.white,
              color: const Color(0xff465070),
              fontSize: 18.wMin,
              height: 56.wMin,
              borderRadius: 4.wMin,
              sclae: 1.05,
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              onTap: () {
                controller.batchOperationButton();
              },
            ),
          ),
          SizedBox(width: 12.wMin),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.exerciseV2Create],
            child: ButtonWidget(
              text: "新建题目",
              fontColor: Colors.white,
              color: const Color(0xff2388FF),
              fontSize: 18.wMin,
              height: 56.wMin,
              borderRadius: 4.wMin,
              sclae: 1.05,
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              onTap: () {
                controller.toNewQuiz(context);
              },
            ),
          ),
          SizedBox(width: 12.wMin),
          ButtonWidget(
            text: "模拟体验",
            fontColor: Colors.white,
            color: const Color(0xff6D39E4),
            fontSize: 18.wMin,
            height: 56.wMin,
            borderRadius: 4.wMin,
            sclae: 1.05,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            onTap: () {
              controller.toDemonstrate(controller.exerciseList);
            },
          ),
        ],
      ),
    );
  }



}
