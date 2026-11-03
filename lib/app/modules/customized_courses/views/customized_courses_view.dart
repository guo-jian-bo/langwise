import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../generated/assets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../controllers/customized_courses_controller.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'customized_courses_identify_book_widget.dart';

class CustomizedCoursesView extends GetView<CustomizedCoursesController> {
  const CustomizedCoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getCurrentLocation(context);
    });
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.showExitConfirmation(context);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: AppTheme.cBgPrimary,
              body: Column(
                children: [
                  _buildTitleWidget(context),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          height: 1000.wMin,
                          child: Obx(() {
                            if (!controller.isInitPageController.value) {
                              return const SizedBox.shrink();
                            }

                            return PageView(
                              controller: controller.pageController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                buildCourseName(context),
                                if (controller.levelCardShow.value)
                                  buildLevel(context),
                                // if (controller.scanISBNCardShow.value)
                                //   buildScanISBN(context),
                                // if (controller.courseInfoCardShow.value)
                                //   buildBooks(context),
                                if (controller.scanISBNCardShow.value)
                                  buildAddBook(context),
                                if (controller.knowledgeAddCardShow.value)
                                  buildAddKnowledge(context),
                                if (controller.scanTipCardShow.value)
                                  buildScanTip(context),
                              ],
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
        },
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 80.wMin,
        right: 80.wMin + 64.wMin,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BackWidget(onTap: () => controller.showExitConfirmation(context)),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 24.wMin),
              alignment: Alignment.center,
              child: Obx(() {
                return StepProgressWidget(
                  steps: controller.steps.toList(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// 课程名称
  Widget buildCourseName(BuildContext context) {
    return CardBoxWidget(
      pageIndex: 0,
      currentPageIndex: controller.currentPageIndex.value,
      buttonDisable: controller.courseButtonDisable.value,
      onContinue: OptimizeUtils.noneThrottle(() {
        controller.courseNameContinue(context);
      }, 300),
      child: Column(
        children: [
          SizedBox(height: 64.wMin),
          const CardTitleIconTextWidget(
            title: "自建课程",
            svg: Assets.customCourseIconSetting,
          ),
          SizedBox(height: 40.wMin),
          ListAnimationWidget(
            index: 1,
            child: CardInputWidget(
              title: "自定义课程名称",
              hintText: "请输入课程名称，如宝宝的校内同步课堂",
              controller: controller.courseNameInput,
              enabled: controller.pageType == 0,
              maxLength: 10,
              onClean: () {
                controller.courseNameInput.clear();
                controller.getCourseCardButtonFlag();
              },
              onChanged: (value) {
                controller.getCourseCardButtonFlag();
              },
            ),
          ),
          SizedBox(height: 10.wMin),
          Padding(
            padding: EdgeInsets.only(left: 10.0.wMin, right: 10.0.wMin),
            child: Text(
              "为您的专属学习空间命名。创建后，即可在其中添加多本校内教材进行学习。",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextTertiary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 24.wMin),
          const ListAnimationWidget(
            index: 2,
            child: CardSelectChangeWidget(
              title: "语言",
              value: "英语",
              // onTap: () {
              //   // controller.selectLanguage(context);
              // },
            ),
          ),
          SizedBox(height: 24.wMin),
          ListAnimationWidget(
            index: 3,
            child: Obx(() {
              return CardAddImageBoxWidget(
                title: "课程封面",
                imageRadius: 6.wMin,
                showUpdateImage: controller.pageType == 0,
                fileUrl: controller.courseCoverFileUrl.value,
                netUrl: controller.courseCoverNetWorkUrl.value,
                onTap: () => controller.selectCourseCover(context),
              );
            }),
          ),
          SizedBox(height: 24.wMin),
        ],
      ),
    );
  }

  /// 等级card
  Widget buildLevel(BuildContext context) {
    return CardBoxWidget(
      pageIndex: 1,
      currentPageIndex: controller.currentPageIndex.value,
      buttonDisable: controller.levelButtonDisable.value,
      onContinue: OptimizeUtils.noneThrottle(() {
        controller.levelContinue(context);
      }, 300),
      child: Column(
        children: [
          SizedBox(height: 64.wMin),
          const CardTitleIconTextWidget(
            title: "设置自建课程等级",
            svg: Assets.customCourseIconLevel,
          ),
          SizedBox(height: 40.wMin),
          ListAnimationWidget(
            index: 1,
            child: CardInputWidget(
              title: "等级",
              hintText: "请输入类似 一年级 新概念1",
              controller: controller.levelNameInput,
              enabled: controller.pageType == 0 || controller.pageType == 1,
              maxLength: 10,
              onClean: () {
                controller.levelNameInput.clear();
                controller.getLevelCardButtonFlag();
              },
              onChanged: (value) {
                controller.getLevelCardButtonFlag();
              },
            ),
          ),
          SizedBox(height: 24.wMin),
          ListAnimationWidget(
            index: 2,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "你可以后续创建更多等级",
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextTertiary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 扫描ISBN---(已废弃)
  Widget buildScanISBN(BuildContext context) {
    return CardBoxWidget(
      pageIndex: 2,
      currentPageIndex: controller.currentPageIndex.value,
      buttonDisable: controller.scanISBNButtonDisable.value,
      continueText: "下一步",
      onContinue: OptimizeUtils.noneThrottle(() {
        //controller.scanISBNContinue(context);
      }, 300),
      showButton1: true,
      button1Text: "扫描",
      //onButton1: () => controller.scanISBN(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 88.wMin, width: double.infinity),
          Text(
            "扫描书籍ISBN",
            style: TextStyle(
              fontSize: 36.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 58.wMin),
          SizedBox(
            width: 180.wMin,
            height: 180.wMin,
            child: Image.asset(
              "assets/images/custom_course/isbn_demo.png",
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 48.wMin),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "示例",
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.wMin),
              Text.rich(TextSpan(
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cWhiteAlpha70,
                  fontWeight: FontWeight.w500,
                ),
                children: const [
                  TextSpan(text: "请扫描"),
                  TextSpan(
                      text: "教材背面条形码",
                      style: TextStyle(color: AppTheme.cTextBrand)),
                  TextSpan(text: "，仅用于识别教材内容，信息安全可控，识别后自动匹配学习资料。"),
                ],
              )),
              SizedBox(height: 24.wMin),
              CardInputWidget(
                title: "ISBN",
                hintText: "ISBN",
                controller: controller.scanBookISBNInput,
                onClean: () {
                  controller.scanBookISBNInput.clear();
                  controller.getScanISBNButtonFlag();
                },
                onChanged: (value) {
                  controller.getScanISBNButtonFlag();
                },
              ),
              SizedBox(height: 24.wMin),
            ],
          ),
        ],
      ),
    );
  }

  /// 添加书籍---(已废弃)
  Widget buildBooks(BuildContext context) {
    return CardBoxWidget(
      pageIndex: 3,
      currentPageIndex: controller.currentPageIndex.value,
      buttonDisable: controller.bookInfoButtonDisable.value,
      onContinue: OptimizeUtils.noneThrottle(() {
        controller.courseInfoContinue(context);
      }, 300),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 32.wMin),
          const CardTitleIconTextWidget(
            title: "课程信息",
            hideIcon: true,
          ),
          ListAnimationWidget(
            index: 1,
            child: CardInputWidget(
              title: "ISBN",
              hintText: "请输入ISBN",
              controller: controller.scanBookISBNInput,
              onClean: () {
                controller.scanBookISBNInput.clear();
                controller.getCourseInfoCardButtonFlag();
              },
              onChanged: (value) {
                controller.getCourseInfoCardButtonFlag();
              },
            ),
          ),
          SizedBox(height: 24.wMin),
          ListAnimationWidget(
            index: 2,
            child: CardInputWidget(
              title: "书籍名称",
              hintText: "请输入类似 一年级 新概念1",
              controller: controller.bookInfoNameInput,
              maxLength: 30,
              onClean: () {
                controller.bookInfoNameInput.clear();
                controller.getCourseInfoCardButtonFlag();
              },
              onChanged: (value) {
                controller.getCourseInfoCardButtonFlag();
              },
            ),
          ),
          SizedBox(height: 24.wMin),
          ListAnimationWidget(
            index: 3,
            child: DifficultyDropdownWidget(
              difficulties: controller.difficultyList.toList(),
              selectedIndex: controller.selectDifficultyIndex.value,
              onSelected: (int index, DifficultieEntity difficulty) {
                controller.onUpdateDifficultyIndex(index, difficulty);
              },
            ),
          ),
          SizedBox(height: 24.wMin),
          ListAnimationWidget(
            index: 4,
            child: CardAddImageBoxWidget(
              title: "书籍封面",
              fileUrl: controller.frontCover.value,
              netUrl: controller.frontCoverNetWorkUrl.value,
              imageWidth: 200.wMin * (3 / 4),
              imageHeight: 200.wMin,
              imageRadius: 6.wMin,
              onTap: () {
                //controller.selectBooksCover(context);
              },
            ),
          ),
          SizedBox(height: 24.wMin),
        ],
      ),
    );
  }

  //添加教材---(改版后)
  Widget buildAddBook(BuildContext context) {
    return CardBoxWidget(
      continueText: controller.buttonTitle.value,
      pageIndex: 2,
      currentPageIndex: controller.currentPageIndex.value,
      buttonDisable: controller.bookInfoButtonDisable.value,
      onContinue: OptimizeUtils.noneThrottle(() {
        controller.courseInfoContinue(context);
      }, 300),
      scrollController: controller.addBookScrollController,
      child: const CustomizedCoursesIdentifyBookWidget(),
    );
  }

  /// 添加知识点
  Widget buildAddKnowledge(BuildContext context) {
    return CardBoxWidget(
      pageIndex: 3,
      currentPageIndex: controller.currentPageIndex.value,
      buttonDisable: controller.knowledgeButtonDisable.value,
      onContinue: OptimizeUtils.noneThrottle(() {
        controller.knowledgeContinue(context);
      }, 1000),
      child: Column(
        children: [
          SizedBox(height: 64.wMin),
          const CardTitleIconTextWidget(
            title: "添加知识点",
          ),
          SizedBox(height: 40.wMin),
          KnowledgeSelectionContainer(
            selectedIndex: controller.knowledgeSelectIndex.value,
            onSelectionChanged: (index) =>
                controller.selectAddKnowledgeMethod(index),
            items: [
              KnowledgeSelectionItem(
                title: "复用其他用户词汇表",
                showAiIcon: true,
                subtitle: Text(
                  "已有${controller.scanTimes.value}位用户扫描过相同书籍，并由AI交叉确认，无需等待和再次核对",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextDisabled,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              KnowledgeSelectionItem(
                title: "手动扫描词汇表",
                subtitle: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cTextDisabled,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      const TextSpan(text: "手动拍照上传，系统识别后，还需要再次手动核对词汇表，用时较长，"),
                      TextSpan(
                        text: "大约需要${controller.manualScanTime.value}",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cFeedbackErrorBorder,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 第二条路的提示卡片
  Widget buildScanTip(BuildContext context) {
    return CardBoxWidget(
      continueText: '扫描',
      pageIndex: 3,
      currentPageIndex: controller.currentPageIndex.value,
      buttonDisable: false,
      onContinue: OptimizeUtils.noneThrottle(() {
        //扫描单词
        controller.scanWord(context);
      }, 1000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 64.wMin),
          const Center(
            child: CardTitleIconTextWidget(
              title: "添加单词表",
              hideIcon: true,
            ),
          ),
          SizedBox(height: 40.wMin),
          Center(
            child: Image.asset(
              'assets/images/custom_course/custom_course_example.png',
              height: 300.wMin,
            ),
          ),
          SizedBox(height: 40.wMin),
          Text(
            '示例',
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.wMin),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
              ),
              children: [
                const TextSpan(
                  text: "请扫描",
                ),
                TextSpan(
                  text: "教材背面单词表",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextBrand,
                  ),
                ),
                const TextSpan(text: "，必须包含单元信息"),
                TextSpan(
                  text: "Unit1",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextBrand,
                  ),
                ),
                const TextSpan(text: "，信息安全可控，识别后自动匹配学习资料。"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
