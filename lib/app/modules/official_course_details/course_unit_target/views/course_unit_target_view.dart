import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../management/common/commons.dart';
import '../bindings/course_unit_target_binding.dart';
import '../controllers/course_unit_target_controller.dart';
import 'course_unit_target_comprehensive_page.dart';
import 'course_unit_target_list_page.dart';

class CourseUnitTargetView extends GetView<CourseUnitTargetController> {

  final String tagText;
  const CourseUnitTargetView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      CourseUnitTargetView(tagText: tag),
      binding: CourseUnitTargetBinding(tagText: tag),
      routeName: Routes.COURSE_UNIT_TARGET,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx((){
      return PopScope(
        canPop: controller.currentKnowledgeType.value == CourseUnitTargetEnum.overview,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          controller.checkBackToOverview();
        },
        child: ManageScaffold(
          onRefresh: () async{
            await controller.refreshUnitTarget();
          },
          onBack: () async{
            controller.checkBackToOverview(back: true);
            return false;
          },
          backgroundColor: AppTheme.cBgPrimary.color,
          body: Column(
            children: [
              Visibility(
                visible: !controller.isManagement,
                child: BreadcrumbWidget(
                  isCompatibleManage: controller.isManagement,
                  onBack: () {
                    controller.checkBackToOverview(back: true);
                  },
                  actionWidget: Container(
                    margin: EdgeInsets.only(left: 16.wMin),
                    child: GeneralSettingButtonWidget(
                      isManagement: controller.isManagement,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned.fill(
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleWidget(),
                            Expanded(
                              child: Obx((){
                                CourseUnitTargetEnum type = controller.currentKnowledgeType.value;
                                Widget body = CourseUnitTargetComprehensivePage(controller: controller);
                                if(type != CourseUnitTargetEnum.overview){
                                  body = CourseUnitTargetListPage(controller: controller);
                                }
                                return body;
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildBottomWidget(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }


  /// 构建页面标题区域
  Widget _buildTitleWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Obx((){
              if(controller.unitKnowledgePoints.value.description == null){
                return Container(height: 0);
              }
              return Text(
                controller.unitKnowledgePoints.value.description??'',
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextSecondary.color,
                ),
              );
            }),
          ),
          Visibility(
            visible: controller.isManagement,
            child: GeneralSettingButtonWidget(
              isManagement: controller.isManagement,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部锚点切换区域
  Widget _buildBottomWidget(BuildContext context){
    return Obx((){
      if(controller.anchorPositionList.isEmpty && !controller.isManagement) {
        return Container(height: 0);
      }
      return Container(
        margin: EdgeInsets.only(
          bottom: 16.wMin + MediaQuery.of(context).padding.bottom,
        ),
        padding: EdgeInsets.symmetric(horizontal: 90.wMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: controller.anchorPositionList.isNotEmpty,
              child: Center(
                child: AnchorPositionWidget(
                  datas: controller.anchorPositionList.toList(),
                  currentValue: controller.currentKnowledgeType.value,
                  menu: _buildAnchorMenuButtonWidget(context),
                  onIndexChanged: (data, index) {
                    controller.switchKnowledgeType(data.value);
                  },
                ),
              ),
            ),
            if(controller.isManagement) ... [
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      final manageController = controller.manageKnowledgeController;
                      return FilterStripWidget(
                        conditions: {...manageController.filterConditions},
                        searchs: manageController.filterSearchs,
                        searchSingleWidth: 480.wMin,
                        onConditions: (conditions) {
                          manageController.filterConditions.value = conditions;
                          manageController.executeFilter();
                        },
                        onReset: (sorts, conditions) {
                          manageController.filterConditions.value = conditions;
                          manageController.executeFilter();
                        },
                        onSearch: () {
                          manageController.executeSearch();
                        },
                      );
                    }),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 24.wMin),
                    padding: EdgeInsets.all(12.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: AppTheme.cSurfaceSearchBackground.color,
                      border: Border.all(
                        width: 1.wMin,
                        color: AppTheme.cBorderDefault.color,
                      ),
                    ),
                    child: _buildManageButtonsWidget(context),
                  ),
                ],
              ),
            ],
            
          ],
        ),
      );
    });
  }

  /// 构建锚点区域右侧下载按钮
  Widget _buildAnchorMenuButtonWidget(BuildContext context){
    return ButtonWidget(
      text: "下载",
      height: 64.wMin,
      padding: EdgeInsets.only(left: 28.wMin, right: 32.wMin),
      borderRadius: 99,
      color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12),
      border: Border.all(
        width: 1.wMin,
        color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
      ),
      fontColor: AppTheme.cSurfaceSuccess.color,
      fontSize: 28.wMin,
      leftIcon: Container(
        margin: EdgeInsets.only(right: 6.wMin),
        child: SvgPicture.asset(
          "assets/svg/public/icon_download.svg",
          width: 28.wMin,
          colorFilter: ColorFilter.mode(AppTheme.cSurfaceSuccess.color, BlendMode.srcIn),
        ),
      ),
      sclae: 1.03,
      onTap: () {
        controller.downloadAudio(context);
      },
    );
  }


  /// 管理端操作按钮
  Widget _buildManageButtonsWidget(BuildContext context){
    return Obx((){
      final adminController = controller.manageKnowledgeController;
      bool isSortingMode = adminController.isSortingMode.value;
      if(controller.currentKnowledgeType.value == CourseUnitTargetEnum.vocabulary){
        return Row(
          spacing: 6.wMin,
          children: [
            _buildButtonItem(
              text: "添加单词",
              onTap: () {
                adminController.adminAddKnowledgeFunction(context: context, knowledgeType: KnowledgeTypeEnum.EN_WORD);
              },
            ),
            _buildButtonItem(
              text: "添加短语",
              onTap: () {
                adminController.adminAddKnowledgeFunction(context: context, knowledgeType: KnowledgeTypeEnum.EN_PHRASE);
              },
            ),
            _buildButtonItem(
              text: isSortingMode ? "退出排序" : "排序模式",
              onTap: () {
                adminController.toggleSortMode();
              },
            ),
          ],
        );
      }else if(controller.currentKnowledgeType.value == CourseUnitTargetEnum.syntax){
        return Row(
          spacing: 6.wMin,
          children: [
            _buildButtonItem(
              text: "添加句子",
              onTap: () {
                adminController.adminAddKnowledgeFunction(context: context, knowledgeType: KnowledgeTypeEnum.EN_SENTENCE);
              },
            ),
            _buildButtonItem(
              text: "添加语法",
              onTap: () {
                adminController.adminAddSyntaxFunction();
              },
            ),
            _buildButtonItem(
              text: "语法管线",
              onTap: () {
                adminController.adminAddPipelineFunction();
              },
            ),
            _buildButtonItem(
              text: isSortingMode ? "退出排序" : "排序模式",
              onTap: () {
                adminController.toggleSortMode();
              },
            ),
          ],
        );
      }else if(controller.currentKnowledgeType.value == CourseUnitTargetEnum.listening){
        return Row(
          spacing: 6.wMin,
          children: [
            _buildButtonItem(
              text: "添加歌曲",
              onTap: () {
                adminController.adminAddSongFunction();
              },
            ),
            _buildButtonItem(
              text: "生成歌曲",
              onTap: () {
                adminController.generateLessonSong();
              },
            ),
            _buildButtonItem(
              text: isSortingMode ? "退出排序" : "排序模式",
              onTap: () {
                adminController.toggleSortMode();
              },
            ),
            Text(
              adminController.getKnowledgePublishProgressText(CourseUnitTargetEnum.listening),
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ],
        );
      }else if(controller.currentKnowledgeType.value == CourseUnitTargetEnum.reading){
        return Row(
          spacing: 6.wMin,
          children: [
            _buildButtonItem(
              text: "生成文章",
              onTap: () {
                adminController.generateLessonArticle();
              },
            ),
            _buildButtonItem(
              text: isSortingMode ? "退出排序" : "排序模式",
              onTap: () {
                adminController.toggleSortMode();
              },
            ),
            Text(
              adminController.getKnowledgePublishProgressText(CourseUnitTargetEnum.reading),
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ],
        );
      }else if(controller.currentKnowledgeType.value == CourseUnitTargetEnum.writing){
        return Row(
          spacing: 6.wMin,
          children: [
            _buildButtonItem(
              text: "挂范文",
              onTap: () {
                
              },
            ),
            _buildButtonItem(
              text: "编辑挂载",
              onTap: () {
                
              },
            ),
          ],
        );
      }else if(controller.currentKnowledgeType.value == CourseUnitTargetEnum.comprehensive){
        return Row(
          spacing: 6.wMin,
          children: [
            _buildButtonItem(
              text: "添加综合",
              onTap: () {
                adminController.addComprehensiveKnowledge();
              },
            ),
          ],
        );
      }
      return Container();
    });
  }

  Widget _buildButtonItem({
    required String text,
    void Function()? onTap,
  }){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: ButtonWidget(
        text: text,
        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
        height: 54.wMin,
        color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.12),
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
        ),
        fontColor: AppTheme.cSurfaceBrand.color,
        fontSize: 24.wMin,
        fontWeight: FontWeight.w500,
        sclae: 1.03,
        onTap: onTap,
      ),
    );
  }


  
}
