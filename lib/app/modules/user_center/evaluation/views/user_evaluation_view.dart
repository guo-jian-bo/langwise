import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/guide_engine/guide_engine.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../bindings/user_evaluation_binding.dart';
import '../controllers/user_evaluation_controller.dart';

class UserEvaluationView extends GetView<UserEvaluationController> {
  final String tagText;
  const UserEvaluationView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => UserEvaluationView(tagText: tag),
      binding: UserEvaluationBinding(tagText: tag),
      routeName: Routes.USER_EVALUATION,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            const BreadcrumbWidget(),
            Expanded(
              child: Container(
                alignment: Alignment.topCenter,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 90.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    SizedBox(height: 10.wMin),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileCard(context),
                          SizedBox(width: 24.wMin),
                          Expanded(child: _buildEvaluationCard(context)),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.wMin),
                    _buildBottomBar(context),
                    SizedBox(height: 16.wMin),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '完善信息后开始精准评测，生成个性化学习计划',
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cTextQuaternary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }


  Widget _buildProfileCard(BuildContext context) {
    return Obx(() {
      Widget headWidget = Center(
        child: SvgPicture.asset(
          "assets/svg/public/icon_user.svg",
          width: 180.wMin,
          height: 180.wMin,
        ),
      );
      if (controller.avatarFile.value != "") {
        headWidget = Image.file(
          File(controller.avatarFile.value),
          fit: BoxFit.cover,
        );
      } else if (controller.avatarUrl.value.isNotEmpty) {
        headWidget = CachedImageWidget(
          controller.avatarUrl.value,
          errorWidget: Center(
            child: SvgPicture.asset(
              "assets/svg/public/icon_user.svg",
              width: 180.wMin,
              height: 180.wMin,
            ),
          ),
        );
      }

      return Container(
        width: 700.wMin,
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase.color,
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(color: AppTheme.cBorderThin.color, width: 1.wMin),
        ),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 238.wMin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.wMin)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff38BDF8).withValues(alpha: 0.2),
                    Color(0xff38BDF8).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('学员档案', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 32.wMin, fontWeight: FontWeight.w600)),
                      Text('长期信息', style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 22.wMin)),
                    ],
                  ),
                  SizedBox(height: 24.wMin),
                  Container(
                    padding: EdgeInsets.all(12.wMin),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/svg/manage/icon_info_circle.svg",
                          width: 24.wMin,
                          height: 24.wMin,
                          colorFilter: const ColorFilter.mode(AppTheme.cTextBrand, BlendMode.srcIn),
                        ),
                        SizedBox(width: 8.wMin),
                        Expanded(
                          child: Text(
                            '为了给孩子匹配最合适的学习计划，请完善以下信息',
                            style: TextStyle(color: AppTheme.cTextBrand.color, fontSize: 22.wMin, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.wMin),
                  Container(
                    width: 200.wMin,
                    height: 200.wMin,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 4.wMin, color: AppTheme.cBorderBrand),
                    ),
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: SizedBox(width: 180.wMin, height: 180.wMin, child: headWidget),
                    ),
                  ),
                  SizedBox(height: 32.wMin),
                  Text(
                    controller.nickName.value,
                    style: TextStyle(
                      color: AppTheme.cTextPrimary.color,
                      fontSize: 32.wMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.wMin),
                  Text(
                    controller.address.value,
                    style: TextStyle(
                      color: AppTheme.cTextTertiary.color,
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 12.wMin),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceTertiary.color,
                      borderRadius: BorderRadius.circular(4.wMin),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                    child: Text(
                      'ID:${controller.currentMember.value?.memberId}',
                      style: TextStyle(color: AppTheme.cTextSecondary.color, fontSize: 22.wMin, fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(height: 24.wMin),
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.wMin), color: AppTheme.cSurfaceTertiary),
                    padding: EdgeInsets.symmetric(vertical: 12.wMin),
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(children: [
                          Text(
                            '生日',
                            style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 24.wMin, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 8.wMin),
                          Text(
                            controller.birthday.value,
                            style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 28.wMin, fontWeight: FontWeight.w500),
                          ),
                        ])),
                        Container(
                          width: 1.wMin,
                          height: 48.wMin,
                          color: AppTheme.cBorderSecondary.color,
                        ),
                        Expanded(
                            child: Column(children: [
                          Text(
                            '年龄',
                            style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 24.wMin, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 8.wMin),
                          Text(
                            controller.age.value,
                            style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 28.wMin, fontWeight: FontWeight.w500),
                          ),
                        ])),
                        Container(
                          width: 1.wMin,
                          height: 48.wMin,
                          color: AppTheme.cBorderSecondary.color,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '年级',
                                style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 24.wMin, fontWeight: FontWeight.w400),
                              ),
                              SizedBox(height: 8.wMin),
                              Text(
                                StaticData.gradeList[controller.gradeIndex.value].name,
                                style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 28.wMin, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.wMin),
                  Expanded(
                    child: Center(
                      child: GuideStepWidget(
                        id: GuideWidgetIds.userEvaluationEditStudentInfoButton,
                        onTap: () async {
                          controller.toEditUserProfile(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('修改学员信息', style: TextStyle(color: AppTheme.cTextBrand.color, fontSize: 24.wMin, fontWeight: FontWeight.w600)),
                            SizedBox(width: 4.wMin),
                            SvgPicture.asset('assets/svg/user_center/icon_caret_right.svg', width: 32.wMin, height: 32.wMin)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEvaluationCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerBase.color,
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(color: AppTheme.cBorderThin.color, width: 1.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('本次评测信息', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 32.wMin, fontWeight: FontWeight.w600)),
              SizedBox(width: 12.wMin),
              Text('请选择当前的英语水平', style: TextStyle(color: AppTheme.cSurfaceError.color, fontSize: 24.wMin)),
              const Spacer(),
              Text('每次评测调整', style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 22.wMin)),
            ],
          ),
          SizedBox(height: 40.wMin),

          Expanded(
            child: GuideStepWidget(
              id: GuideWidgetIds.userEvaluationBaseSelectionModule,
              child: Row(
                spacing: 24.wMin,
                children: [
                  _buildZeroFoundationWidget(),
                  _buildExistingFoundationWidget(context),
                ],
              ),
            ),
          ),



          // Text('当前英语水平', style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 28.wMin, fontWeight: FontWeight.w500)),
          // SizedBox(height: 4.wMin),
          // GuideStepWidget(
          //   id: GuideWidgetIds.userEvaluationBaseSelectionModule,
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: _buildStartPointOption(
          //           title: '零基础',
          //           desc: '无需评测，按照年龄规划',
          //           value: UserEvaluationStartPoint.zero,
          //         ),
          //       ),
          //       SizedBox(width: 16.wMin),
          //       Expanded(
          //         child: _buildStartPointOption(
          //           title: '已有基础',
          //           desc: '做评测，按照年级成绩规划',
          //           value: UserEvaluationStartPoint.basic,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // SizedBox(height: 20.wMin),
          // if (controller.startPoint.value == UserEvaluationStartPoint.basic)
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text('校内英语成绩', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 24.wMin, fontWeight: FontWeight.w600)),
          //       Text('选填，可提升准确度', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 22.wMin, fontWeight: FontWeight.w400)),
          //     ],
          //   ),
          // SizedBox(height: 10.wMin),
          // if (controller.startPoint.value == UserEvaluationStartPoint.basic)
          //   Row(
          //     children: [
          //       Expanded(
          //         flex: 2,
          //         child: _buildInputBox(label: '科目', child: _buildReadonlyInput('英语')),
          //       ),
          //       SizedBox(width: 24.wMin),
          //       Expanded(
          //         flex: 3,
          //         child: _buildInputBox(
          //           label: '总分',
          //           padding: EdgeInsets.zero,
          //           child: IconDropdownSelectWidget(
          //             selectValue: controller.totalScore.value,
          //             borderColor: Colors.transparent,
          //             fillColor: Colors.transparent,
          //             valueStyle: TextStyle(
          //               color: AppTheme.cTextPrimary.color,
          //               fontSize: 28.wMin,
          //             ),
          //             itemFontSize: 24.wMin,
          //             items: List.generate(controller.totalScoreOptions.length, (index) {
          //               return IconDropdownCheckData<int>(
          //                 title: '${controller.totalScoreOptions[index]}分',
          //                 value: controller.totalScoreOptions[index],
          //               );
          //             }),
          //             onChanged: (data, index) {
          //               controller.setTotalScore(data.value);
          //             },
          //           ),
          //         ),
          //       ),
          //       SizedBox(width: 24.wMin),
          //       Expanded(
          //         flex: 3,
          //         child: _buildInputBox(
          //           label: '分数',
          //           child: TextField(
          //             controller: controller.scoreController,
          //             onChanged: (v) {
          //               if (v.isNotEmpty && ((int.tryParse(v) ?? 0) > controller.totalScore.value)) {
          //                 controller.scoreController.text = controller.totalScore.value.toString();
          //                 ToastUtils.showToast(text: '分数不能大于总分');
          //               }
          //             },
          //             keyboardType: TextInputType.number,
          //             inputFormatters: [
          //               FilteringTextInputFormatter.digitsOnly,
          //             ],
          //             style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 28.wMin),
          //             decoration: InputDecoration(
          //               border: InputBorder.none,
          //               isDense: true,
          //               hintText: '请输入分数',
          //               hintStyle: TextStyle(color: AppTheme.cTextDisabled.color, fontSize: 28.wMin),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
        ],
      ),
    );
  }

  /// 零基础卡片
  Widget _buildZeroFoundationWidget(){
    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          controller.setStartPoint(UserEvaluationStartPoint.zero);
        },
        sclae: 1.01,
        child: Obx((){
          bool selected = controller.startPoint.value == UserEvaluationStartPoint.zero;
          return Container(
            padding: EdgeInsets.all(24.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.wMin),
              color: selected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.1) : AppTheme.cSurfaceLayerBase.color,
              border: Border.all(
                color: selected ? AppTheme.cBorderBrand.color : AppTheme.cBorderThin.color, 
                width: 1.wMin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('我是零基础', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 40.wMin, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    SvgPicture.asset(
                      selected ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
                      width: 38.wMin,
                      colorFilter: selected ? ColorFilter.mode(Colors.transparent, BlendMode.srcATop) : null,
                    ),
                  ],
                ),
                Text(
                  '无需再填写成绩，系统会按年龄与年级做更稳妥的起点评估，后续题目会从更基础的难度开始。', 
                  style: TextStyle(color: AppTheme.cTextSecondary.color, fontSize: 24.wMin, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 24.wMin),
                Container(
                  padding: EdgeInsets.all(16.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.wMin),
                    color: AppTheme.cSurfaceLayerBase.color,
                    border: Border.all(color: AppTheme.cBorderSubtle.color, width: 1.wMin),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('什么是 ', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 24.wMin, fontWeight: FontWeight.w500)),
                          Text('‘零基础’', style: TextStyle(color: AppTheme.cSurfaceWarning.color, fontSize: 26.wMin, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      SizedBox(height: 12.wMin),
                      Container(height: 1.wMin, color: AppTheme.cBorderDefault.color),
                      SizedBox(height: 24.wMin),
                      _buildZeroFoundationTipsWidget('还没有正式接触英语'),
                      SizedBox(height: 24.wMin),
                      _buildZeroFoundationTipsWidget('不会做题评测'),
                      SizedBox(height: 24.wMin),
                      _buildZeroFoundationTipsWidget('根据学员的年龄和年级智能推荐'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildZeroFoundationTipsWidget(String text){
    return Row(
      spacing: 8.wMin,
      children: [
        Icon(Icons.check_circle, color: AppTheme.cSurfaceWarning.color, size: 24.wMin),
        Expanded(
          child: Text(text, style: TextStyle(color: AppTheme.cSurfaceWarning.color, fontSize: 24.wMin, fontWeight: FontWeight.w400)),
        ),
      ],
    );
  }


  /// 已有基础卡片
  Widget _buildExistingFoundationWidget(BuildContext context){
    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          controller.setStartPoint(UserEvaluationStartPoint.basic);
        },
        sclae: 1.01,
        child: Obx((){
          bool selected = controller.startPoint.value == UserEvaluationStartPoint.basic;
          return Container(
            padding: EdgeInsets.all(24.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.wMin),
              color: selected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.1) : AppTheme.cSurfaceLayerBase.color,
              border: Border.all(
                color: selected ? AppTheme.cBorderBrand.color : AppTheme.cBorderThin.color, 
                width: 1.wMin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('我已有基础', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 40.wMin, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    const Spacer(),
                    SvgPicture.asset(
                      selected ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
                      width: 38.wMin,
                      colorFilter: selected ? ColorFilter.mode(Colors.transparent, BlendMode.srcATop) : null,
                    ),
                  ],
                ),
                Expanded(
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    resizeToAvoidBottomInset: true,
                    body: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.viewInsetsOf(context).bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '补充当前校内英语成绩，系统能更准确判断孩子现阶段的理解与训练强度，评测起点也会更贴近真实水平。', 
                            style: TextStyle(color: AppTheme.cTextSecondary.color, fontSize: 24.wMin, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 24.wMin),
                          Container(
                            padding: EdgeInsets.all(16.wMin),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.wMin),
                              color: AppTheme.cSurfaceLayerBase.color,
                              border: Border.all(color: AppTheme.cBorderSubtle.color, width: 1.wMin),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('校内英语成绩', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 24.wMin, fontWeight: FontWeight.w500)),
                                    const Spacer(),
                                    Text('选填，可提升准确度', style: TextStyle(color: AppTheme.cTextSecondary.color, fontSize: 16.wMin, fontWeight: FontWeight.w400)),
                                  ],
                                ),
                                SizedBox(height: 12.wMin),
                                Container(height: 1.wMin, color: AppTheme.cBorderDefault.color),
                                SizedBox(height: 12.wMin),
                                Text('科目',style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 24.wMin, fontWeight: FontWeight.w500)),
                                SizedBox(height: 8.wMin),
                                Container(
                                  height: 58.wMin,
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.wMin),
                                    color: AppTheme.cSurfaceLayerBase.color,
                                    border: Border.all(color: AppTheme.cBorderThin.color, width: 1.wMin),
                                  ),
                                  child: Text("英语", style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 24.wMin, fontWeight: FontWeight.w500)),
                                ),
                                SizedBox(height: 16.wMin),
                                Text('总分',style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 24.wMin, fontWeight: FontWeight.w500)),
                                SizedBox(height: 8.wMin),
                                Container(
                                  height: 58.wMin,
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.wMin),
                                    color: AppTheme.cSurfaceLayerBase.color,
                                    border: Border.all(color: AppTheme.cBorderThin.color, width: 1.wMin),
                                  ),
                                  child: IconDropdownSelectWidget(
                                    selectValue: controller.totalScore.value,
                                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                                    borderColor: Colors.transparent,
                                    fillColor: Colors.transparent,
                                    valueStyle: TextStyle(
                                      color: AppTheme.cTextPrimary.color,
                                      fontSize: 24.wMin,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    itemFontSize: 24.wMin,
                                    items: List.generate(controller.totalScoreOptions.length, (index) {
                                      return IconDropdownCheckData<int>(
                                        title: '${controller.totalScoreOptions[index]}分',
                                        value: controller.totalScoreOptions[index],
                                      );
                                    }),
                                    onChanged: (data, index) {
                                      controller.setTotalScore(data.value);
                                      controller.setStartPoint(UserEvaluationStartPoint.basic);
                                    },
                                  ),
                                ),
                                SizedBox(height: 16.wMin),
                                Text('分数',style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 24.wMin, fontWeight: FontWeight.w500)),
                                SizedBox(height: 8.wMin),
                                Builder(
                                  builder: (inputContext) {
                                    return CardInputWidget(
                                      height: 58.wMin,
                                      borderRadius: BorderRadius.circular(8.wMin),
                                      borderColor: AppTheme.cBorderThin.color,
                                      borderWidth: 1.wMin,
                                      fillColor: AppTheme.cSurfaceLayerBase.color,
                                      controller: controller.scoreController,
                                      keyboardType: TextInputType.number,
                                      hintText: "请输入分数",
                                      hintStyle: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 24.wMin, fontWeight: FontWeight.w400),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (v) {
                                        if (v.isNotEmpty && ((int.tryParse(v) ?? 0) > controller.totalScore.value)) {
                                          controller.scoreController.text = controller.totalScore.value.toString();
                                          ToastUtils.showToast(text: '分数不能大于总分');
                                        }
                                      },
                                      onTap: () {
                                        controller.setStartPoint(UserEvaluationStartPoint.basic);
                                      },
                                    );
                                  },
                                ),
                                
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }


  Widget _buildBottomBar(BuildContext context) {
    final dateText = DateFormatUtil.formatStr(DateTime.now(), newPattern: 'yyyy年M月d日', locale: Get.locale);
    String langText = Get.locale?.languageCode == 'zh' ? '中文' : (Get.locale?.languageCode ?? '--');
    langText = "中文";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '时间：$dateText  -  语言：$langText',
              style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 24.wMin),
            ),
          ),
          Obx(() {
            int days = controller.remainingDays.value;
            int restFreeDays = controller.currentMember.value?.freeAssessmentCount ?? 0;
            if (days == -1) return const SizedBox.shrink();
            if (days > 0 && restFreeDays <= 0) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 12.wMin),
                    decoration: BoxDecoration(
                      color: AppTheme.cFeedbackWarningBackground.color,
                      borderRadius: BorderRadius.circular(12.wMin),
                      border: Border.all(color: AppTheme.cFeedbackWarningBorder.color, width: 0.8.wMin),
                    ),
                    child: Text(
                      '距离免费评测还有 $days 天，或使用 5,000 学点',
                      style: TextStyle(color: AppTheme.cFeedbackWarningText.color, fontSize: 22.wMin),
                    ),
                  ),
                  SizedBox(width: 24.wMin),
                  GuideStepWidget(
                    id: GuideWidgetIds.userEvaluationStartTestButton,
                    onTap: () async {
                      controller.onStartPointEvaluation(context);
                    },
                    child: _buildPrimaryButton(
                      text: '使用学点评测',
                      color: AppTheme.cSurfaceWarning.color,
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                _buildPrimaryButton(
                  text: '稍后评测',
                  txtColor: AppTheme.cTextTertiary.color,
                  color: AppTheme.cSurfaceTertiary.color,
                  onTap: controller.passEvaluation,
                ),
                SizedBox(width: 24.wMin),
                GuideStepWidget(
                  id: GuideWidgetIds.userEvaluationStartTestButton,
                  onTap: () async {
                    controller.onStartFreeEvaluation(context);
                  },
                  child: _buildPrimaryButton(
                    text: '开始免费评测${restFreeDays > 0 ? '(剩余$restFreeDays次)' : ""}',
                    color: AppTheme.cSurfaceInfo.color,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({required String text, required Color color, Color txtColor = Colors.white, VoidCallback? onTap}) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 15.wMin),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14.wMin),
        ),
        child: Text(text, style: TextStyle(color: txtColor, fontSize: 28.wMin, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
