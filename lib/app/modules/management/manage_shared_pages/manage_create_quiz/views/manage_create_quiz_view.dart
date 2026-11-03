import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/button_widgets.dart';
import 'package:langwise/common/widgets/not_data_widget.dart';
import 'package:langwise/common/widgets/quiz_public_widget.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:popover/popover.dart';
import 'package:quiz_play/models/quiz_model.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../../../utils/utils.dart';

import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_create_quiz_binding.dart';
import '../controllers/manage_create_quiz_controller.dart';

class ManageCreateQuizView extends GetView<ManageCreateQuizController> {
  final String tagText;
  const ManageCreateQuizView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CREATE_QUIZ}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageCreateQuizView(tagText: tag),
      binding: ManageCreateQuizBinding(tag: tag),
      routeName: Routes.MANAGE_CREATE_QUIZ,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: ManageScaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.wMin),
                    Text(
                      '从已有题目中选择',
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Obx(
                      () {
                        if (controller.quizList.isEmpty) {
                          return SizedBox(
                            height: 1000.wMin,
                            child: const NotDataWidget(
                              message: "暂无题目",
                            ),
                          );
                        }

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.wMin),
                          child: Wrap(
                            spacing: 14.wMin,
                            runSpacing: 14.wMin,
                            children: List.generate(controller.quizList.length, (index) {
                              return buildQuizWidget(context, index, controller.quizList[index]);
                            }),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: ClipRRect(
              borderRadius: BorderRadius.circular(16.wMin),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.wMin),
                padding: EdgeInsets.all(20.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  border: Border.all(width: 1.wMin, color: const Color(0xff353E5C)),
                  color: const Color(0xff141828).withValues(alpha: 0.5),
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    ButtonWidget(
                      text: "取消",
                      fontColor: const Color(0xffEBEFF5),
                      color: Colors.transparent,
                      border: Border.all(width: 2.wMin, color: const Color(0xff353E5C)),
                      fontSize: 18.wMin,
                      width: 100.wMin,
                      height: 45.wMin,
                      borderRadius: 4.wMin,
                      sclae: 1.05,
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                      onTap: () {
                        Get.back();
                      },
                    ),
                    SizedBox(width: 12.wMin),
                    ButtonWidget(
                      text: "新建",
                      fontColor: const Color(0xffEBEFF5),
                      fontSize: 18.wMin,
                      color: const Color(0xff2388FF),
                      width: 100.wMin,
                      height: 45.wMin,
                      borderRadius: 4.wMin,
                      sclae: 1.05,
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                      onTap: OptimizeUtils.noneThrottle(() {
                        controller.createQuiz(context);
                      }, 500),
                    ),
                    SizedBox(width: 12.wMin),
                    Visibility(
                      visible: controller.lessonId != null,
                      child: Obx(
                        () => Visibility(
                          visible: controller.quizList.isNotEmpty,
                          child: ButtonWidget(
                            text: "选择${controller.selectedCount.value}道题",
                            fontColor: const Color(0xff2388FF),
                            fontSize: 18.wMin,
                            color: const Color(0xff19213D),
                            width: 120.wMin,
                            height: 45.wMin,
                            borderRadius: 4.wMin,
                            sclae: 1.05,
                            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                            onTap: () {
                              controller.bindQuiz();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildQuizWidget(BuildContext context, int index, QuizModel model) {
    return Container(
      width: 383.wMin,
      padding: EdgeInsets.all(10.wMin),
      decoration: BoxDecoration(
        color: const Color(0xFF23283D),
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SelectableText(
                'ID: ${model.uid ?? 0}',
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              _buildAccessStatusCell(context, model),
              Visibility(
                visible: controller.lessonId != null,
                child: Container(
                  margin: EdgeInsets.only(left: 6.wMin),
                  child: TapScaleWidget(
                    onTap: () {
                      controller.selectList[index] = !controller.selectList[index];
                      controller.selectedCount.value = controller.selectList.where((element) => element).length;
                    },
                    sclae: 1.1,
                    child: Container(
                      padding: EdgeInsets.all(14.wMin),
                      color: Colors.transparent,
                      child: SvgPicture.asset(
                        (controller.selectList[index])
                            ? "assets/svg/manage/icon_check_box.svg"
                            : "assets/svg/manage/icon_uncheck_box.svg",
                        width: 25.5.wMin,
                        height: 25.5.wMin,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.wMin,
          ),
          AspectRatio(
            aspectRatio: 1.77,
            child: Stack(
              children: [
                TapScaleWidget(
                  onTap: () {
                    controller.toDemonstrate(index);
                  },
                  sclae: 1.03,
                  child: QuizPublicQuizWidget(
                    borderRadius: 12.wMin,
                    data: model,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessStatusCell(BuildContext context, QuizModel model) {
    return Builder(
      builder: (targetContext) {
        return GestureDetector(
          onTap: () {
            if (!ManageAuthUtils.isAuth(ManageAuthCode.exerciseOperationCode)) return;
            showPopover(
              context: targetContext,
              bodyBuilder: (context) => accessPopWidget(context, model),
              direction: PopoverDirection.bottom,
              width: 120.wMin,
              height: 100.wMin,
              arrowHeight: 10.wMin,
              arrowWidth: 20.wMin,
              barrierColor: Colors.transparent,
              backgroundColor: const Color(0xFF18191A),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonWidget(
                text: model.accessNormal ? '上架' : '下架',
                width: 80.wMin,
                height: 32.wMin,
                color: model.accessNormal ? const Color(0xFF63DE77) : const Color(0xFFFF2D46),
                fontSize: 14.wMin,
                fontColor: Colors.white,
                borderRadius: 8.wMin,
                rightIcon: !ManageAuthUtils.isAuth(ManageAuthCode.exerciseOperationCode) ? null : SvgPicture.asset(
                  "assets/svg/manage/icon_arrow_down.svg",
                  width: 20.wMin,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget accessPopWidget(BuildContext context, QuizModel model) {
    return Container(
      padding: EdgeInsets.all(10.wMin),
      decoration: BoxDecoration(
        color: const Color(0xF22B2F3C),
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ManageButton(
            text: '上架',
            width: 80.wMin,
            height: 32.wMin,
            color: const Color(0xFF63DE77),
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 14.wMin,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            onTap: () {
              Get.back();
              if (!model.accessNormal) {
                controller.accessQuiz(context, model);
              } else {
                ToastUtils.showToast(text: '题目已是上架状态');
              }
            },
          ),
          ManageButton(
            text: '下架',
            width: 80.wMin,
            height: 32.wMin,
            color: const Color(0xFFFF2D46),
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 14.wMin,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            onTap: () {
              Get.back();
              if (model.accessNormal) {
                controller.accessQuiz(context, model);
              } else {
                ToastUtils.showToast(text: '题目已是下架状态');
              }
            },
          ),
        ],
      ),
    );
  }
}
