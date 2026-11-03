import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/user_center/common/create_student_dialog.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../controllers/user_evaluation_controller.dart';

class UserEvaluationView extends GetView<UserEvaluationController> {
  const UserEvaluationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      resizeToAvoidBottomInset: true,
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 24.wMin,
            left: 40.wMin,
            right: 40.wMin,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: 24.wMin),
                SizedBox(
                  height: 794.wMin,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 30.wMin),
                      Expanded(flex: 680, child: _buildProfileCard(context)),
                      SizedBox(width: 28.wMin),
                      Expanded(flex: 1072, child: _buildEvaluationCard(context)),
                      SizedBox(width: 30.wMin)
                    ],
                  ),
                ),
                SizedBox(height: 48.wMin),
                _buildBottomBar(context),
                SizedBox(height: 40.wMin),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BackWidget(
          title: '英语水平评测',
          fontSize: 32.wMin,
        ),
        SizedBox(height: 8.wMin),
        Padding(
          padding: EdgeInsets.only(left: 72.wMin),
          child: Text(
            '完善信息后开始精准评测，生成个性化学习计划',
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextQuaternary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cBgSecondary.color,
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(color: AppTheme.cBorderPrimary.color.withValues(alpha: 0.2), width: 1.wMin),
      ),
      child: child,
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return _cardContainer(
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: SizedBox(
              width: 20.wMin,
              height: 20.wMin,
              child: CircularProgressIndicator(strokeWidth: 2.wMin, color: AppTheme.cBgBrand.color),
            ),
          );
        }

        final member = controller.currentMember.value;

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

        return SizedBox(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.wMin)),
                    gradient: const LinearGradient(colors: [
                      Color(0x4D38BDF8),
                      Color(0x0038BDF8),
                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                width: double.infinity,
                height: 238.wMin,
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
                        child: ClipOval(child: SizedBox(width: 180.wMin, height: 180.wMin, child: headWidget))),
                    SizedBox(height: 32.wMin),
                    Text(controller.nickName.value, style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 32.wMin, fontWeight: FontWeight.w600)),
                    SizedBox(height: 12.wMin),
                    Text(controller.address.value, style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 24.wMin, fontWeight: FontWeight.w400)),
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
                      child: Row(children: [
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
                            child: Column(children: [
                          Text(
                            '年级',
                            style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 24.wMin, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 8.wMin),
                          Text(
                            StaticData.gradeList[controller.gradeIndex.value].name,
                            style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 28.wMin, fontWeight: FontWeight.w500),
                          ),
                        ])),
                      ]),
                    ),
                    SizedBox(height: 24.wMin),
                    Expanded(
                        child: Center(
                      child: GuideAnchor(
                        id: 'notice_edit_user_profile',
                        route: Routes.USER_EVALUATION,
                        child: GestureDetector(
                          onTap: () async {
                            controller.toEditUserProfile(context);
                          },
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('修改学员信息', style: TextStyle(color: AppTheme.cTextBrand.color, fontSize: 24.wMin, fontWeight: FontWeight.w600)),
                            SizedBox(width: 4.wMin),
                            SvgPicture.asset('assets/svg/user_center/icon_caret_right.svg', width: 32.wMin, height: 32.wMin)
                          ]),
                        ),
                      ),
                    ))
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileValueBox({required String hit, required String value}) {
    return Container(
      height: 74.wMin,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTertiary.color,
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
      ),
      child: Row(
        children: [
          Visibility(
            visible: value.isEmpty,
            child: Expanded(
              child: Text(
                hit,
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Visibility(
            visible: value.isNotEmpty,
            child: Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SvgPicture.asset(
            'assets/svg/public/icon_arrow_down.svg',
            width: 24.wMin,
            height: 24.wMin,
            color: AppTheme.cTextTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(BuildContext context) {
    return Obx(
      () => _cardContainer(
        child: Padding(
          padding: EdgeInsets.all(24.wMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('本次评测信息', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 32.wMin, fontWeight: FontWeight.w600)),
                  Text('每次评测调整', style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 22.wMin)),
                ],
              ),
              SizedBox(height: 40.wMin),
              Text('当前英语水平', style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 28.wMin, fontWeight: FontWeight.w500)),
              SizedBox(height: 4.wMin),
              GuideAnchor(
                id: 'choose_zerobase',
                route: Routes.USER_EVALUATION,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStartPointOption(
                        title: '零基础',
                        desc: '无需评测，按照年龄规划',
                        value: UserEvaluationStartPoint.zero,
                      ),
                    ),
                    SizedBox(width: 16.wMin),
                    Expanded(
                      child: _buildStartPointOption(
                        title: '已有基础',
                        desc: '做评测，按照年级成绩规划',
                        value: UserEvaluationStartPoint.basic,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.wMin),
              if (controller.startPoint.value == UserEvaluationStartPoint.basic)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('校内英语成绩', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 24.wMin, fontWeight: FontWeight.w600)),
                    Text('选填，可提升准确度', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 22.wMin, fontWeight: FontWeight.w400)),
                  ],
                ),
              SizedBox(height: 10.wMin),
              if (controller.startPoint.value == UserEvaluationStartPoint.basic)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildInputBox(label: '科目', child: _buildReadonlyInput('英语')),
                    ),
                    SizedBox(width: 24.wMin),
                    Expanded(
                      flex: 3,
                      child: _buildInputBox(
                        label: '总分',
                        child: Obx(() {
                          return DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: controller.totalScore.value,
                              dropdownColor: AppTheme.cBgSecondary.color,
                              iconEnabledColor: AppTheme.cTextTertiary.color,
                              icon: SvgPicture.asset(
                                'assets/svg/public/icon_arrow_down.svg',
                                colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                              ),
                              style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 28.wMin),
                              isExpanded: true,
                              items: controller.totalScoreOptions
                                  .map(
                                    (v) => DropdownMenuItem<int>(
                                      value: v,
                                      child: Text('${v}分', style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 28.wMin)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v == null) return;
                                controller.setTotalScore(v);
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(width: 24.wMin),
                    Expanded(
                      flex: 3,
                      child: _buildInputBox(
                        label: '分数',
                        child: TextField(
                          controller: controller.scoreController,
                          onChanged: (v){
                            if(v.isNotEmpty&&((int.tryParse(v)??0)>controller.totalScore.value)){
                              controller.scoreController.text = controller.totalScore.value.toString();
                              ToastUtils.showToast(text: '分数不能大于总分');
                            }
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 28.wMin),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: '请输入分数',
                            hintStyle: TextStyle(color: AppTheme.cTextDisabled.color, fontSize: 28.wMin),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 28.wMin, fontWeight: FontWeight.w500)),
        SizedBox(height: 6.wMin),
        Container(
          height: 74.wMin,
          padding: EdgeInsets.symmetric(horizontal: 16.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cBgTertiary.color,
            borderRadius: BorderRadius.circular(12.wMin),
            border: Border.all(color: AppTheme.cBorderPrimary.color.withValues(alpha: 0.15), width: 1.wMin),
          ),
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ],
    );
  }

  Widget _buildReadonlyInput(String text) {
    return Text(text, style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 28.wMin, fontWeight: FontWeight.w500));
  }

  Widget _buildStartPointOption({
    required String title,
    required String desc,
    required UserEvaluationStartPoint value,
  }) {
    return Obx(() {
      final selected = controller.startPoint.value == value;
      return TapScaleWidget(
        sclae: 1,
        onTap: () => controller.setStartPoint(value),
        child: Container(
          height: 126.wMin,
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceSecondary.color,
            borderRadius: BorderRadius.circular(12.wMin),
            border: Border.all(
              color: AppTheme.cBorderPrimary.color,
              width: 1.wMin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 28.wMin, fontWeight: FontWeight.w500)),
                  Container(
                    width: 32.wMin,
                    height: 32.wMin,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: selected ? AppTheme.cBgBrand.color : AppTheme.cBorderTertiary.color, width: 2.wMin),
                    ),
                    child: selected
                        ? Center(
                            child: Container(
                              width: 16.wMin,
                              height: 16.wMin,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.cBgBrand.color),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
              SizedBox(height: 8.wMin),
              Text(desc, style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 22.wMin)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBottomBar(BuildContext context) {
    final dateText = DateFormatUtil.formatStr(DateTime.now(), newPattern: 'yyyy年M月d日', locale: Get.locale);
    String langText = Get.locale?.languageCode == 'zh' ? '中文' : (Get.locale?.languageCode ?? '--');
    langText = "中文";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 30.wMin),
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
            int restFreeDays = controller.currentMember.value?.freeAssessmentCount??0;
            if(days==-1)return const SizedBox.shrink();
            if (days > 0&&restFreeDays<=0) {
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
                  GuideAnchor(
                id: 'start_free_evaluation',
                route: Routes.USER_EVALUATION,
                child: _buildPrimaryButton(
                      text: '使用学点评测',
                      color: AppTheme.cSurfaceWarning.color,
                      onTap: () {
                        controller.onStartPointEvaluation(context);
                      })),
                ],
              );
            }
            return Row(
                  children: [
                    _buildPrimaryButton(text: '稍后评测', txtColor: AppTheme.cTextTertiary.color, color: AppTheme.cSurfaceTertiary.color, onTap: controller.passEvaluation),
                    SizedBox(width: 24.wMin),
                    GuideAnchor(
                id: 'start_free_evaluation',
                route: Routes.USER_EVALUATION,
                child: _buildPrimaryButton(text: '开始免费评测'+(restFreeDays>0?'(剩余$restFreeDays次)':""), color: AppTheme.cSurfaceInfo.color, onTap: controller.onStartFreeEvaluation))
                  ],
                );
          }),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({required String text, required Color color, Color txtColor = Colors.white, required VoidCallback onTap}) {
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
