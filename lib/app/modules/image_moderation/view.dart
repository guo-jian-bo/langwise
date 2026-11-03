/// 图片审核页面
///
/// 功能概述：
/// 图片审核是一个独立功能模块，用于审核系统中的图片资源，确保图片内容符合要求。
/// 该功能需要同时在主APP和管理端的嵌套路由中使用，且两者之间的状态需要隔离。
///
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../common/values/values.dart';
import 'controller.dart';
import 'state.dart';

class ImageModerationPage extends GetView<ImageModerationController> {
  const ImageModerationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageModerationController>(
      init: controller,
      builder: (_) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppTheme.cBgPrimary,
          body: SafeArea(
              left: true,
              top: true,
              right: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.ww, 
                  right: 16.ww, 
                  top: 16.wh,
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              Assets.imageModerationStatisticsUser,
                              width: 23.ww,
                              height: 18.wh,
                            ),
                            SizedBox(width: 8.ww),
                            Text(
                              '我的审核统计',
                              style: TextStyle(
                                color: AppTheme.cTextPrimary,
                                fontSize: 18.wMin,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '当前审核员: ',
                                style: TextStyle(
                                  color: color_D1D5DC,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.wMin,
                                ),
                              ),
                              TextSpan(
                                text: controller.state.reviewerStatsEntity?.inspector ?? '',
                                style: TextStyle(
                                  color: color_51A2FF,
                                  fontSize: 14.wMin,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Gaps.getHeight(8.wh),
                    _buildStatisticsRow(),
                    Gaps.getHeight(16.wh),
                    Text(
                      '我的审核',
                      style: TextStyle(
                        color: AppTheme.cTextPrimary,
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gaps.getHeight(8.wh),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 状态筛选 - 过滤掉未审核状态
                        GetBuilder<ImageModerationController>(
                          init: controller,
                          id: ImageModerationState.knowledgeListId,
                          builder: (_) {
                            final state = controller.state;
                            return Container(
                              padding: EdgeInsets.only(left: 8.ww, top: 8.wh, bottom: 8.wh),
                              decoration: BoxDecoration(
                                color: AppTheme.cBgSecondary,
                                borderRadius: BorderRadius.circular(8.ww),
                              ),
                              child: Row(
                                children: ReviewStatus.values
                                    // 过滤掉未审核状态
                                    .where((status) => status != ReviewStatus.pending && status != ReviewStatus.abandon)
                                    .map((status) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: 8.ww),
                                    child: CustomChoiceChip(
                                      label: status.title,
                                      selected: state.statusFilter == status,
                                      selectedColor: AppTheme.cDifficultyBackgroundColor3,
                                      backgroundColor: Colors.transparent,
                                      hoverColor: Colors.black.withValues(alpha: 0.9),
                                      selectedTextColor: AppTheme.cTextPrimary,
                                      unselectedTextColor: AppTheme.cTextSecondary,
                                      fontSize: 14,
                                      onSelected: (selected) {
                                        if (selected) {
                                          controller.setStatusFilter(status);
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),

                        TapScaleWidget(
                            onTap: () {
                              controller.toMore();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.cDifficultyBackgroundColor3,
                                borderRadius: BorderRadius.circular(6.ww),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              margin: EdgeInsets.only(left: 20.ww),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "查看更多",
                                    style: TextStyle(
                                      color: AppTheme.cTextPrimary,
                                      fontSize: 14.wMin,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4.ww),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12.wMin,
                                    color: AppTheme.cTextPrimary,
                                  ),
                                ],
                              ),
                            )),
                        const Spacer(),
                        // 搜索框
                        SearchWidget(
                          width: 120.ww,
                          height: 36.wh,
                          hintText: '搜索',
                          color: color_364153,
                          onChanged: (String value) {
                            controller.setSearchTerm(value);
                          },
                          onSubmitted: (String value) {
                            controller.setSearchTerm(value, isSubmit: true);
                          },
                        ),
                        Gaps.getWidth(8.ww),
                        // 审核排行榜按钮
                        TapScaleWidget(
                          onTap: OptimizeUtils.noneThrottle(() {
                            controller.toShowRankingDialog(context);
                          }, 300),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 8.wh),
                            decoration: BoxDecoration(
                              color: color_364153,
                              borderRadius: BorderRadius.circular(8.ww),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  Assets.imageModerationRanking,
                                  width: 16.ww,
                                  height: 14.wh,
                                  colorFilter: const ColorFilter.mode(Color(0xFFFFD700), BlendMode.srcIn),
                                ),
                                SizedBox(width: 8.ww),
                                Text(
                                  '审核排行榜',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.wMin,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (UserStore.to.rolePermissions.value.userIsAdmin) Gaps.getWidth(8.ww),
                        // 管理按钮
                        if (UserStore.to.rolePermissions.value.userIsAdmin)
                          TapScaleWidget(
                            onTap: () {
                              controller.toAdmin();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 8.wh),
                              decoration: BoxDecoration(
                                color: color_364153,
                                borderRadius: BorderRadius.circular(8.ww),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    Assets.imageModerationAdmin,
                                    width: 16.ww,
                                    height: 14.wh,
                                    colorFilter: const ColorFilter.mode(Color(0xFF51A2FF), BlendMode.srcIn),
                                  ),
                                  SizedBox(width: 8.ww),
                                  Text(
                                    '管理',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.wMin,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                    Gaps.getHeight(16.wh),

                    // 我的审核列表
                    GetBuilder<ImageModerationController>(
                      id: ImageModerationState.myReviewsId,
                      builder: (c) {
                        final state = controller.state;
                        if (state.myReviews.isEmpty) {
                          return Container(
                            alignment: Alignment.center,
                            height: 128.wh,
                            margin: EdgeInsets.only(bottom: 16.wh),
                            child: Text(
                              "当前无数据",
                              style: TextStyle(
                                color: AppTheme.cTextSecondary,
                                fontSize: 18.wMin,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }

                        return Container(
                          margin: EdgeInsets.only(bottom: 16.wh),
                          height: 128.wh,
                          child: EasyRefresh(
                            header: null,
                            triggerAxis: Axis.horizontal,
                            child: GridView.builder(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              // 添加弹性滚动效果
                              physics: const BouncingScrollPhysics(),
                              itemCount: state.myReviews.length,
                              itemBuilder: (context, index) {
                                final item = state.myReviews[index];
                                return ImageModerationWidget(
                                  item: item,
                                  index: index,
                                  onTap: (int i, KnowledgePoint k) {
                                    controller.toKnowledgePointDetail(k, isFromUser: true);
                                  },
                                );
                              },
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisSpacing: 10.wMin,
                                childAspectRatio: 128.wh / 368.ww,
                              ),
                            ),
                            onRefresh: () {
                              controller.onRefresh();
                            },
                            onLoad: () {
                              controller.onLoadMore();
                            },
                            controller: controller.refreshController,
                          ),
                        );
                      },
                    ),

                    // 知识点列表标题
                    Text(
                      '知识点列表',
                      style: TextStyle(
                        color: AppTheme.cTextPrimary,
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Gaps.getHeight(8.wh),

                    // 知识点列表内容
                    Expanded(
                      child: GetBuilder<ImageModerationController>(
                        id: ImageModerationState.knowledgeListId,
                        builder: (c) {
                          if (controller.state.knowledgePoints.isEmpty) return const SizedBox.shrink();
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 10.wMin,
                              mainAxisSpacing: 10.wh,
                              childAspectRatio: 368.ww / 128.wh,
                            ),
                            itemCount: controller.state.knowledgePoints.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final item = controller.state.knowledgePoints[index];
                              return ImageModerationWidget(
                                item: item,
                                index: index,
                                onTap: (int i, KnowledgePoint k) {
                                  controller.toKnowledgePointDetail(k, isFromUser: false);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        );
      },
    );
  }


  /// 构建统计信息行
  Widget _buildStatisticsRow() {
    return GetBuilder<ImageModerationController>(
      id: ImageModerationState.statisticsId,
      builder: (_) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatisticsItem('今日单词数', '${controller.state.reviewerStatsEntity?.todayWordCount ?? 0}'),
            Gaps.getWidth(12.ww),
            _buildStatisticsItem('今日图片数', '${controller.state.reviewerStatsEntity?.todayImageCount ?? 0}'),
            Gaps.getWidth(12.ww),
            _buildStatisticsItem('总单词数', '${controller.state.reviewerStatsEntity?.reviewedWordCount ?? 0}'),
            Gaps.getWidth(12.ww),
            _buildStatisticsItem('总图片数', '${controller.state.reviewerStatsEntity?.newReviewedImageCount ?? 0}',
                showBadge: true),
          ],
        );
      },
    );
  }

  /// 构建单个统计项
  Widget _buildStatisticsItem(String title, String value, {bool showBadge = false}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary,
          borderRadius: BorderRadius.circular(8.ww),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.wh, horizontal: 12.ww),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (showBadge)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.ww, vertical: 2.wh),
                    decoration: BoxDecoration(
                      color: controller.state.canBatchReview ? color_0D542B.withValues(alpha: 0.5) : color_FFE2E2,
                      borderRadius: BorderRadius.circular(15.wMin),
                    ),
                    child: Text(
                      controller.state.canBatchReview ? "可批量审核" : '不可批量审核',
                      style: TextStyle(
                        color: controller.state.canBatchReview ? color_05DF72 : color_9F0712,
                        fontSize: 12.wMin,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            Gaps.getHeight(8.wh),
            Text(
              value,
              style: TextStyle(
                color: AppTheme.cTextPrimary,
                fontSize: 20.wMin,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
