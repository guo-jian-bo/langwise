import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:popover/popover.dart';
import '../controllers/membership_card_manage_code_manage_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../models/membership_card_manage_code_manage_model.dart';
import 'package:intl/intl.dart';

import 'membership_card_manage_code_manage_dialog.dart';

class MembershipCardManageCodeManageView extends GetView<MembershipCardManageCodeManageController> {
  final String tagText;
  const MembershipCardManageCodeManageView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        filterWidget(context),
        Expanded(
          child: EasyRefresh(
            controller: controller.refreshController,
            header: const ClassicHeader(
              dragText: "下拉刷新",
              armedText: "释放刷新",
              readyText: "正在刷新...",
              processingText: "加载中...",
              processedText: "刷新完成",
              failedText: "刷新失败",
              showMessage: false,
            ),
            footer: const ClassicFooter(
              dragText: "上拉加载",
              armedText: "释放加载",
              readyText: "正在加载...",
              processingText: "加载中...",
              processedText: "加载完成",
              noMoreText: "没有更多数据了",
              failedText: "加载失败",
              showMessage: false,
            ),
            onRefresh: () async {
              await controller.onRefresh();
            },
            onLoad: () async {
              await controller.onLoadMore();
            },
            child: SingleChildScrollView(
              controller: controller.scrollController,
              child: Obx(
                () => GridView.builder(
                  key: const PageStorageKey('manage_scroll_grid'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 520.wMin,
                    crossAxisSpacing: 30.wMin,
                    mainAxisSpacing: 30.wMin,
                  ),
                  itemCount: controller.codeList.length,
                  itemBuilder: (context, index) {
                    return cardWidget(controller.codeList[index], index, context);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget filterWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '卡密管理',
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          height: 10.wMin,
        ),
        Row(
          children: [
            Obx(
              () => Row(
                children: [
                  ManageButton(
                    text: "全部",
                    width: 120.wMin,
                    height: 50.wMin,
                    color: controller.currentIndex.value == 0 ? AppTheme.cMemberCardInactiveBackground : Colors.transparent,
                    borderColor: Colors.transparent,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: controller.currentIndex.value == 0 ? AppTheme.cIconHelp : AppTheme.cMemberCardLevelFont,
                      fontWeight: FontWeight.w400,
                    ),
                    onTap: () {
                      if (controller.currentIndex.value != 0) {
                        controller.currentIndex.value = 0;
                        controller.onRefresh();
                      }
                    },
                  ),
                  SizedBox(width: 20.wMin),
                  ManageButton(
                    text: "Plus",
                    width: 120.wMin,
                    height: 50.wMin,
                    color: controller.currentIndex.value == 1 ? AppTheme.cMemberCardInactiveBackground : Colors.transparent,
                    borderColor: Colors.transparent,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: controller.currentIndex.value == 1 ? AppTheme.cIconHelp : AppTheme.cMemberCardLevelFont,
                      fontWeight: FontWeight.w400,
                    ),
                    onTap: () {
                      if (controller.currentIndex.value != 1) {
                        controller.currentIndex.value = 1;
                        controller.onRefresh();
                      }
                    },
                  ),
                  SizedBox(width: 20.wMin),
                  ManageButton(
                    text: "Pro",
                    width: 120.wMin,
                    height: 50.wMin,
                    color: controller.currentIndex.value == 2 ? AppTheme.cMemberCardInactiveBackground : Colors.transparent,
                    borderColor: Colors.transparent,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: controller.currentIndex.value == 2 ? AppTheme.cIconHelp : AppTheme.cMemberCardLevelFont,
                      fontWeight: FontWeight.w400,
                    ),
                    onTap: () {
                      if (controller.currentIndex.value != 2) {
                        controller.currentIndex.value = 2;
                        controller.onRefresh();
                      }
                    },
                  ),
                  SizedBox(width: 20.wMin),
                  ManageButton(
                    text: "Max",
                    width: 120.wMin,
                    height: 50.wMin,
                    color: controller.currentIndex.value == 3 ? AppTheme.cMemberCardInactiveBackground : Colors.transparent,
                    borderColor: Colors.transparent,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: controller.currentIndex.value == 3 ? AppTheme.cIconHelp : AppTheme.cMemberCardLevelFont,
                      fontWeight: FontWeight.w400,
                    ),
                    onTap: () {
                      if (controller.currentIndex.value != 3) {
                        controller.currentIndex.value = 3;
                        controller.onRefresh();
                      }
                    },
                  ),
                  SizedBox(width: 20.wMin),
                  ManageButton(
                    text: "体验卡",
                    width: 120.wMin,
                    height: 50.wMin,
                    color: controller.currentIndex.value == 4 ? AppTheme.cMemberCardInactiveBackground : Colors.transparent,
                    borderColor: Colors.transparent,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: controller.currentIndex.value == 4 ? AppTheme.cIconHelp : AppTheme.cMemberCardLevelFont,
                      fontWeight: FontWeight.w400,
                    ),
                    onTap: () {
                      if (controller.currentIndex.value != 4) {
                        controller.currentIndex.value = 4;
                        controller.onRefresh();
                      }
                    },
                  ),
                  SizedBox(width: 20.wMin),
                  ManageButton(
                    text: "席位卡",
                    width: 120.wMin,
                    height: 50.wMin,
                    color: controller.currentIndex.value == 5 ? AppTheme.cMemberCardInactiveBackground : Colors.transparent,
                    borderColor: Colors.transparent,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: controller.currentIndex.value == 5 ? AppTheme.cIconHelp : AppTheme.cMemberCardLevelFont,
                      fontWeight: FontWeight.w400,
                    ),
                    onTap: () {
                      if (controller.currentIndex.value != 5) {
                        controller.currentIndex.value = 5;
                        controller.onRefresh();
                      }
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(builder: (buttonContext) {
                  return GestureDetector(
                    onTap: () {
                      // 筛选逻辑
                      showPopover(
                        context: buttonContext,
                        bodyBuilder: (context) => filterPopWidget(context),
                        direction: PopoverDirection.bottom,
                        width: 450.wMin,
                        height: 260.wMin,
                        arrowHeight: 10.wMin,
                        arrowWidth: 20.wMin,
                        barrierColor: Colors.transparent,
                        backgroundColor: AppTheme.cBgSecondary,
                      );
                    },
                    child: SvgPicture.asset(
                      Assets.manageIconFilter,
                      width: 40.wMin,
                      height: 40.wMin,
                      colorFilter: ColorFilter.mode(
                        AppTheme.cIconHelp.color,
                        BlendMode.srcIn,
                      ),
                    ),
                  );
                }),
                SizedBox(width: 30.wMin),
                Builder(builder: (buttonContext) {
                  return GestureDetector(
                    onTap: () {
                      // 排序逻辑
                      showPopover(
                        context: buttonContext,
                        bodyBuilder: (context) => sortPopWidget(context),
                        direction: PopoverDirection.bottom,
                        width: 300.wMin,
                        height: 360.wMin,
                        arrowHeight: 10.wMin,
                        arrowWidth: 20.wMin,
                        barrierColor: Colors.transparent,
                        backgroundColor: AppTheme.cBgSecondary,
                      );
                    },
                    child: SvgPicture.asset(
                      Assets.manageIconSort,
                      width: 40.wMin,
                      height: 40.wMin,
                      colorFilter: ColorFilter.mode(
                        AppTheme.cIconHelp.color,
                        BlendMode.srcIn,
                      ),
                    ),
                  );
                }),
                SizedBox(width: 30.wMin),
                Container(
                  height: 50.wMin,
                  padding: EdgeInsets.only(left: 25.wMin, right: 10.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cMemberCardSearchBackground,
                    borderRadius: BorderRadius.circular(25.wMin),
                    border: Border.all(
                      color: AppTheme.cMemberCardInactiveBackground,
                      width: 2.wMin,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 220.wMin,
                        child: TextField(
                          controller: controller.textFieldController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: "搜索用户ID/手机尾号",
                            hintStyle: const TextStyle(color: AppTheme.cQuizDefaultBackground),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.wMin,
                            ),
                          ),
                          onSubmitted: (value) {
                            // 搜索逻辑
                            controller.onRefresh();
                          },
                          onTapOutside: (event) {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // 搜索逻辑
                          controller.onRefresh();
                        },
                        child: Icon(
                          Icons.search,
                          color: AppTheme.cQuizDefaultBackground,
                          size: 30.wMin,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
        SizedBox(height: 20.wMin),
      ],
    );
  }

  Widget sortPopWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "排序方式",
              style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 24.wMin, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20.wMin),
            GestureDetector(
              onTap: () {
                if (controller.sort1Index.value == 0) {
                  controller.sort1Index.value = -1;
                } else {
                  controller.sort1Index.value = 0;
                }
                controller.onRefresh();
                Get.back();
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: 10.wMin,
                  top: 10.wMin,
                  bottom: 10.wMin,
                ),
                decoration: BoxDecoration(
                  color: controller.sort1Index.value == 0 ? AppTheme.cBgQuaternary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.wMin),
                ),
                child: Text("创建时间", style: TextStyle(color: AppTheme.cTextSecondary, fontSize: 20.wMin, fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(height: 15.wMin),
            GestureDetector(
              onTap: () {
                if (controller.sort1Index.value == 1) {
                  controller.sort1Index.value = -1;
                } else {
                  controller.sort1Index.value = 1;
                }
                controller.onRefresh();
                Get.back();
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: 10.wMin,
                  top: 10.wMin,
                  bottom: 10.wMin,
                ),
                decoration: BoxDecoration(
                  color: controller.sort1Index.value == 1 ? AppTheme.cBgQuaternary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.wMin),
                ),
                child: Text("激活时间", style: TextStyle(color: AppTheme.cTextSecondary, fontSize: 20.wMin, fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(height: 15.wMin),
            GestureDetector(
              onTap: () {
                if (controller.sort1Index.value == 2) {
                  controller.sort1Index.value = -1;
                } else {
                  controller.sort1Index.value = 2;
                }
                controller.onRefresh();
                Get.back();
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: 10.wMin,
                  top: 10.wMin,
                  bottom: 10.wMin,
                ),
                decoration: BoxDecoration(
                  color: controller.sort1Index.value == 2 ? AppTheme.cBgQuaternary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.wMin),
                ),
                child: Text("价格", style: TextStyle(color: AppTheme.cTextSecondary, fontSize: 20.wMin, fontWeight: FontWeight.w600)),
              ),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cBgTertiary,
                borderRadius: BorderRadius.circular(12.wMin),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ManageButton(
                      text: "升序",
                      height: 50.wMin,
                      color: controller.sort2Index.value == 0 ? AppTheme.cBgQuaternary : Colors.transparent,
                      borderColor: Colors.transparent,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: () {
                        if (controller.sort2Index.value == 0) {
                          controller.sort2Index.value = -1;
                        } else {
                          controller.sort2Index.value = 0;
                        }
                        controller.onRefresh();
                        Get.back();
                      },
                    ),
                  ),
                  SizedBox(width: 20.wMin),
                  Expanded(
                    child: ManageButton(
                      text: "降序",
                      height: 50.wMin,
                      color: controller.sort2Index.value == 1 ? AppTheme.cBgQuaternary : Colors.transparent,
                      borderColor: Colors.transparent,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: () {
                        if (controller.sort2Index.value == 1) {
                          controller.sort2Index.value = -1;
                        } else {
                          controller.sort2Index.value = 1;
                        }
                        controller.onRefresh();
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget filterPopWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "筛选条件",
            style: TextStyle(
              color: AppTheme.cTextPrimary,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20.wMin),
          Text(
            "卡片状态",
            style: TextStyle(
              color: AppTheme.cTextSecondary,
              fontSize: 20.wMin,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.wMin),
          Wrap(
            spacing: 10.wMin,
            runSpacing: 10.wMin,
            children: [
              _buildChip("未激活", 0),
              _buildChip("已激活", 1),
              _buildChip("已撤销", 2),
              _buildChip("已过期", 3),
            ],
          ),
          SizedBox(height: 20.wMin),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ManageButton(
                  text: "重置",
                  height: 50.wMin,
                  color: AppTheme.cBgTertiary,
                  borderColor: Colors.transparent,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: () {
                    controller.filterIndex.value = -1;
                  },
                ),
              ),
              SizedBox(width: 20.wMin),
              Expanded(
                child: ManageButton(
                  text: "确认",
                  height: 50.wMin,
                  color: AppTheme.cBgBrand,
                  borderColor: Colors.transparent,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: () {
                    controller.onRefresh();
                    Get.back();
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChip(String label, int index) {
    return GestureDetector(
      onTap: () {
        if (controller.filterIndex.value == index) {
          controller.filterIndex.value = -1;
        } else {
          controller.filterIndex.value = index;
        }
      },
      child: Obx(
        () => Container(
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
          decoration: BoxDecoration(
            color: controller.filterIndex.value == index ? AppTheme.cMemberCardInactiveBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(6.wMin),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget cardWidget(MembershipCardManageCodeManageModel item, int index, context) {
    bool canUndo = item.isActivate ?? false;
    bool isExpired = item.isExpired ?? false;
    String vipType = item.vipType ?? 'Plus';
    Color vipColor = AppTheme.cTextPrimary;
    String title;
    Color titleColor;

    Color levelColor = AppTheme.cBgTertiary;
    Color levelDarkColor = AppTheme.cEditBookBackground;

    if (vipType == 'Plus') {
      vipColor = const Color(0xff3B82F6);
    } else if (vipType == 'Pro') {
      vipColor = const Color(0xffA855F7);
    } else if (vipType == 'Max') {
      vipColor = const Color(0xffF97316);
    } else if (vipType == '成员席位') {
      vipColor = const Color(0xff94A3B8);
    }

    bool gradient = false;
    if (isExpired) {
      title = "已过期";
      titleColor = AppTheme.cUserMaxMember2;
    } else {
      if (canUndo) {
        vipColor = AppTheme.cTextPrimary;
        title = "已激活";
        titleColor = AppTheme.cFeedbackSuccessText;

        if (vipType == 'Plus') {
          gradient = true;
          levelColor = const Color(0xff38BDF8);
          levelDarkColor = const Color(0xFF3C7CAC);
        } else if (vipType == 'Pro') {
          gradient = true;
          levelColor = const Color(0xffC084FC);
          levelDarkColor = const Color(0xFF7B48BD);
        } else if (vipType == 'Max') {
          gradient = true;
          levelColor = const Color(0xffFB923C);
          levelDarkColor = const Color(0xFFB35E29);
        } else if (vipType == '成员席位') {
          gradient = true;
          levelColor = const Color(0xff94A3B8);
          levelDarkColor = const Color(0xff475569);
        }
      } else {
        title = "未激活";
        titleColor = AppTheme.cIconHelp;
      }
    }

    bool isDark = UserStore.to.userInfo.value.config?.theme == AppThemeKey.dark.value;
    List<Color> colors;
    if (isDark) {
      colors = [
        levelColor.withValues(alpha: 1),
        levelColor.withValues(alpha: 0.7),
      ];
    } else {
      colors = [
        levelColor.withValues(alpha: 0.7),
        levelColor.withValues(alpha: 1),
      ];
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cBgQuaternary,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      padding: EdgeInsets.all(12.wMin),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary,
          borderRadius: BorderRadius.circular(12.wMin),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.wMin),
              width: double.infinity,
              decoration: BoxDecoration(
                color: (canUndo && gradient) ? null : AppTheme.cBgTertiary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.wMin), // 设置左上角圆角
                  topRight: Radius.circular(12.wMin), // 设置右上角圆角
                ),
                gradient: (canUndo && gradient)
                    ? LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: colors,
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Visibility(
                        visible: item.isSendCoupon == true,
                        child: Text(
                          '体验卡',
                          style: TextStyle(
                            fontSize: 32.wMin,
                            color: vipColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${item.vipType ?? ''} 会员卡',
                        style: TextStyle(
                          fontSize: 32.wMin,
                          color: vipColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Visibility(
                            visible: item.isRefund != true,
                            child: ManageButton(
                              text: title,
                              width: 120.wMin,
                              height: 44.wMin,
                              color: AppTheme.cMemberCardActiveBackground,
                              borderColor: Colors.transparent,
                              style: TextStyle(
                                fontSize: 20.wMin,
                                color: titleColor,
                                fontWeight: FontWeight.w400,
                              ),
                              onTap: () {},
                            ),
                          ),
                          Visibility(
                            visible: item.isFailureRefund == true && item.isRefund != true,
                            child: Row(
                              children: [
                                SizedBox(width: 10.wMin),
                                ManageButton(
                                  text: "30天销毁退款",
                                  width: 140.wMin,
                                  height: 44.wMin,
                                  color: AppTheme.cFeedbackErrorText,
                                  borderColor: Colors.transparent,
                                  style: TextStyle(
                                    fontSize: 20.wMin,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  onTap: () {
                                    controller.destroyRefund(item);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: item.refundStatus,
                            child: Row(
                              children: [
                                SizedBox(width: 10.wMin),
                                ManageButton(
                                  text: "30天可退款",
                                  width: 140.wMin,
                                  height: 44.wMin,
                                  color: AppTheme.cFeedbackErrorText,
                                  borderColor: Colors.transparent,
                                  style: TextStyle(
                                    fontSize: 20.wMin,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  onTap: () {
                                    controller.cancelActivate(item);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: item.isRefund ?? false,
                            child: Row(
                              children: [
                                SizedBox(width: 10.wMin),
                                ManageButton(
                                  text: "已退款",
                                  width: 120.wMin,
                                  height: 44.wMin,
                                  color: AppTheme.cMemberCardActiveBackground,
                                  borderColor: Colors.transparent,
                                  style: TextStyle(
                                    fontSize: 20.wMin,
                                    color: AppTheme.cIconHelp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.wMin,
                  ),
                  Row(
                    children: [
                      Text(
                        '${item.quantity ?? ''}个学员•${item.description ?? ''}',
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Visibility(
                        visible: item.refundStatus,
                        child: Text(
                          '激活后${item.refundExpirationDate ?? 0}天内',
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.wMin,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '激活码',
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(width: 20.wMin),
                      Expanded(
                        child: Text(
                          '备注',
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.wMin),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 70.wMin,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.wMin,
                          ),
                          decoration: BoxDecoration(
                            color: levelDarkColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12.wMin),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                item.code ?? '',
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  MembershipCardManageCodeManageDialog.show(
                                    context: Get.context!,
                                    item: item,
                                    tagText: tagText,
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.wMin,
                                    vertical: 10.wMin,
                                  ),
                                  decoration: BoxDecoration(
                                    color: canUndo ? AppTheme.cBgSecondary.withOpacity(0.1) : AppTheme.cBgQuaternary,
                                    borderRadius: BorderRadius.circular(8.wMin),
                                  ),
                                  child: Icon(
                                    Icons.copy,
                                    color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                                    size: 20.wMin,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 20.wMin),
                      Expanded(
                        child: Container(
                          height: 70.wMin,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.wMin,
                          ),
                          decoration: BoxDecoration(
                            color: levelDarkColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12.wMin),
                          ),
                          child: Center(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.remarks?.isNotEmpty ?? false ? item.remarks! : '未添加备注',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 20.wMin,
                                      color: item.remarks != null ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: item.remarks != null,
                                  child: GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: item.remarks!));
                                      ToastUtils.showToast(text: "复制成功", type: ToastType.success);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.wMin,
                                        vertical: 10.wMin,
                                      ),
                                      decoration: BoxDecoration(
                                        color: canUndo ? AppTheme.cBgSecondary.withOpacity(0.1) : AppTheme.cBgQuaternary,
                                        borderRadius: BorderRadius.circular(8.wMin),
                                      ),
                                      child: Icon(
                                        Icons.copy,
                                        color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                                        size: 20.wMin,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.wMin),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.wMin),
              child: Stack(
                children: [
                  Visibility(
                    visible: item.isFailure ?? false,
                    child: Positioned(
                      right: 0,
                      bottom: 0,
                      child: Image.asset(
                        "assets/svg/membership_card/card_expired.png",
                        fit: BoxFit.cover,
                        width: 80.wMin,
                        height: 80.wMin,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '创建时间',
                              style: TextStyle(
                                fontSize: 20.wMin,
                                color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '价格',
                              style: TextStyle(
                                fontSize: 20.wMin,
                                color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.wMin),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.created != null ? DateFormat('yyyy-MM-dd').format(item.created!) : '',
                              style: TextStyle(
                                fontSize: 24.wMin,
                                color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: item.originalPrice == null
                                ? Text(
                                    '${item.priceStr ?? 0}元',
                                    style: TextStyle(
                                      fontSize: 24.wMin,
                                      color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${item.priceStr ?? 0} ',
                                          style: TextStyle(
                                            fontSize: 24.wMin,
                                            color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${item.originalPriceStr ?? 0}',
                                          style: TextStyle(
                                            fontSize: 24.wMin,
                                            color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextSecondary,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.lineThrough, // 添加横线
                                            decorationThickness: 2.0, // 设置横线高度
                                            decorationColor: AppTheme.cTextSecondary, // 设置横线颜色
                                          ),
                                        ),
                                        TextSpan(
                                          text: '元',
                                          style: TextStyle(
                                            fontSize: 24.wMin,
                                            color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.wMin),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '激活时间',
                              style: TextStyle(
                                fontSize: 20.wMin,
                                color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '激活用户',
                              style: TextStyle(
                                fontSize: 20.wMin,
                                color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.wMin),
                      Visibility(
                        visible: item.activated != null,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.activated != null ? DateFormat('yyyy-MM-dd').format(item.activated!) : '',
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: SelectableText(
                                '${item.activateUserName ?? ''}•${item.userId ?? ''}•${item.activateUserPhone ?? ''}',
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: isExpired ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
