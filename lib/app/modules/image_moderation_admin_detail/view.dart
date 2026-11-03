import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../common/values/values.dart';
import 'index.dart';

class ImageModerationAdminDetailPage extends GetView<ImageModerationAdminDetailController> {
  const ImageModerationAdminDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color_101828,
      body: SafeArea(
        left: true,
        top: true,
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GetBuilder<ImageModerationAdminDetailController>(
                id: "image_moderation_admin_nickname",
                builder: (ImageModerationAdminDetailController controller) {
                  return Container(
                    color: color_1E2939,
                    child: BackWidget(
                      title: controller.isUser ? '审核员详情: ${controller.state.reviewer?.nickName ?? ''}' : '审核员详情',
                    ),
                  );
                }),
            Expanded(
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建审核员信息卡片
  Widget _buildReviewerCard() {
    return GetBuilder<ImageModerationAdminDetailController>(
      id: "image_moderation_admin_detail",
      builder: (ImageModerationAdminDetailController controller) {
        final reviewer = controller.state.reviewer;
        if (reviewer == null) return const SizedBox();
        return Container(
          margin: EdgeInsets.only(top: 16.wh),
          padding: EdgeInsets.only(left: 16.ww, right: 16.ww, top: 16.wh, bottom: 16.wh),
          decoration: BoxDecoration(
            color: color_1E2939,
            borderRadius: BorderRadius.circular(8.ww),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 左侧头像和用户信息
              if (controller.isUser)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 头像占位
                    Container(
                      width: 60.ww,
                      height: 60.ww,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        reviewer.firstLetter,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.ww,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.ww),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          reviewer.nickName ?? '',
                          style: TextStyle(
                            fontSize: 20.ww,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.wh),
                        Text(
                          'ID: ${reviewer.userId ?? ''}',
                          style: TextStyle(fontSize: 14.ww, color: color_99A1AF, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ],
                ),
              if (controller.isUser) Gaps.getWidth(24.ww),
              // 右侧统计信息卡片 - 使用Flex布局在一行中展示所有卡片
              Expanded(
                child: Row(
                  children: [
                    // 总审核知识点
                    Expanded(
                      flex: 1,
                      child: _buildStatCard(
                        '总审核知识点',
                        "${reviewer.reviewedCount ?? 0}",
                        '今日: +${reviewer.additionCount ?? 0}',
                      ),
                    ),
                    Gaps.getWidth(8.ww),
                    // 总审核图片
                    Expanded(
                      flex: 1,
                      child: _buildStatCard(
                          '总审核图片', "${reviewer.reviewedImageCount ?? 0}", '今日: +${reviewer.additionImageCount ?? 0}'),
                    ),
                    Gaps.getWidth(8.ww),
                    // 批量审核资格
                    if (controller.isUser)
                      Expanded(
                        flex: 1,
                        child: _buildStatCard('批量审核资格', reviewer.canBatchReview ? '已获得' : '未获得',
                            reviewer.canBatchReview ? '可以使用批量审核功能' : '还需 ${reviewer.remainingImages} 张'),
                      ),
                    if (!controller.isUser)
                      Expanded(
                        flex: 1,
                        child: _buildStatCard('批量审核资格', '已获得', '${reviewer.batchCount ?? 0}人可以使用批量审核功能'),
                      ),
                    Gaps.getWidth(8.ww),
                    // 最近活跃
                    Expanded(
                      flex: 1,
                      child: _buildStatCard(
                        '最近活跃',
                        reviewer.newActiveDay,
                        '活跃度: 高',
                        iconPath: Assets.imageModerationCalendar,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建统计信息卡片
  /// 参数:
  /// [title] - 卡片标题
  /// [value] - 卡片主要数值
  /// [subtext] - 卡片副文本
  /// [iconPath] - 可选的副文本前图标路径
  Widget _buildStatCard(String title, String value, String subtext, {String? iconPath}) {
    // 根据不同类型的卡片选择颜色
    final Color valueColor = _getStatCardValueColor(title, value);
    final Color subtextColor = _getStatCardSubtextColor(title, value);
    return Container(
      padding: EdgeInsets.only(left: 12.ww, right: 12.ww, top: 12.wh, bottom: 12.wh),
      decoration: BoxDecoration(
        color: color_364153,
        borderRadius: BorderRadius.circular(8.ww),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            title,
            style: TextStyle(
              fontSize: 14.wMin,
              color: color_99A1AF,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // 副文本
          Row(
            children: [
              // 如果有图标则显示
              if (iconPath != null) ...[
                SvgPicture.asset(
                  iconPath,
                  width: 14.ww,
                  height: 14.ww,
                ),
                SizedBox(width: 4.ww),
              ],
              Expanded(
                child: Text(
                  subtext,
                  style: TextStyle(fontSize: 12.wMin, color: subtextColor, fontWeight: FontWeight.w400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.ww),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewerCard(),
          Gaps.getHeight(16.wh),
          _buildSearchFilterBar(context),
          Gaps.getHeight(32.wh),
          Text(
            '知识点列表',
            style: TextStyle(
              fontSize: 18.ww,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Gaps.getHeight(12.wh),
          // 知识点列表使用Expanded确保其能滚动
          Expanded(
            child: _buildKnowledgePointsList(),
          ),
        ],
      ),
    );
  }

  /// 构建搜索和筛选栏
  Widget _buildSearchFilterBar(BuildContext context) {
    return Container(
        height: 71.wh,
        padding: EdgeInsets.only(left: 16.ww, right: 16.ww),
        decoration: BoxDecoration(
          color: color_1E2939,
          borderRadius: BorderRadius.circular(8.ww),
        ),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 40.wh,
              width: 160.ww,
              padding: EdgeInsets.only(left: 12.ww, right: 12.ww),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color_364153,
                borderRadius: BorderRadius.circular(8.wMin),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: color_99A1AF, size: 20.wMin),
                  Gaps.getWidth(2.ww),
                  Expanded(
                      child: TextField(
                    onSubmitted: controller.setSearchTerm,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.white, fontSize: 14.wMin, fontWeight: FontWeight.w400),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: '搜索知识点...',
                      hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14.wMin,
                          height: 1.0,
                          fontWeight: FontWeight.w400,
                          textBaseline: TextBaseline.alphabetic),
                      border: InputBorder.none,
                    ),
                    cursorColor: Colors.white,
                  ))
                ],
              ),
            ),
            // 搜索和筛选行
            SizedBox(width: 12.ww),
            const Spacer(),
            // 状态筛选下拉框
            GetBuilder<ImageModerationAdminDetailController>(
              id: "status_filter",
              builder: (ImageModerationAdminDetailController controller) {
                // 使用ReviewStatus枚举值作为选项
                final statusOptions = [null, ...ReviewStatus.values.where((element) => !element.isPending)];

                // 使用枚举的label属性作为显示文本
                String getStatusLabel(ReviewStatus? status) {
                  return status?.title ?? '全部状态';
                }

                // 获取当前选中的索引
                final selectedIndex = statusOptions.indexOf(controller.state.statusFilter);

                final statusFilterKey = GlobalKey();

                return GestureDetector(
                  onTap: () {
                    ButtonDropdownMenu.show<ReviewStatus?>(
                      context: context,
                      options: statusOptions,
                      labelBuilder: (option) => getStatusLabel(option),
                      selectedIndex: selectedIndex,
                      onSelected: (index, option) => controller.setStatusFilter(option),
                      anchorKey: statusFilterKey,
                      backgroundColor: color_1E2939,
                      borderColor: color_4A5565,
                      borderRadius: 8.ww,
                      width: 132.ww,
                    );
                  },
                  child: Container(
                    key: statusFilterKey,
                    height: 40.wh,
                    width: 102.ww,
                    padding: EdgeInsets.symmetric(horizontal: 12.ww),
                    decoration: BoxDecoration(
                      color: color_364153,
                      borderRadius: BorderRadius.circular(8.wMin),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          Assets.imageModerationStatus,
                          width: 14.wMin,
                          height: 14.wMin,
                        ),
                        Gaps.getWidth(6.ww),
                        Text(
                          getStatusLabel(controller.state.statusFilter),
                          style: TextStyle(color: Colors.white, fontSize: 14.wMin, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Gaps.getWidth(12.ww),
            // 排序按钮行
            _buildSortButton('reviewDate', '按审核日期'),
            SizedBox(width: 12.ww),
            _buildSortButton('imageCount', '按图片数量'),
          ],
        ));
  }

  /// 构建排序按钮
  Widget _buildSortButton(String field, String label) {
    return GetBuilder<ImageModerationAdminDetailController>(
      id: "sort_buttons",
      builder: (ImageModerationAdminDetailController controller) {
        final isActive = controller.state.sortField == field;
        final isAsc = controller.state.sortDirection == 'asc';
        return SortButton(
          text: label,
          isActive: isActive,
          isAsc: isAsc,
          width: 111.ww,
          height: 40.wh,
          onTap: () => controller.setSort(field),
        );
      },
    );
  }

  /// 构建知识点列表
  Widget _buildKnowledgePointsList() {
    return GetBuilder<ImageModerationAdminDetailController>(
      id: "knowledge_points_list",
      builder: (ImageModerationAdminDetailController controller) {
        final points = controller.state.knowledgePoints;

        if (points.isEmpty) {
          return Center(
            child: Text(
              '暂无数据',
              style: TextStyle(color: Colors.white, fontSize: 16.ww),
            ),
          );
        }

        return EasyRefresh(
          triggerAxis: Axis.vertical,
          controller: controller.refreshController,
          onRefresh: () {
            controller.onRefresh();
          },
          onLoad: () {
            controller.onLoadMore();
          },
          child: CustomScrollView(
            scrollDirection: Axis.vertical,
            reverse: false,
            controller: controller.scrollController,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(bottom: 16.wh),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return KnowledgePointItemWidget(
                        point: points[index],
                        onTap: (targetPint) {
                          controller.toKnowledgePointDetail(targetPint);
                        },
                      );
                    },
                    childCount: points.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16.ww,
                    mainAxisSpacing: 16.wh,
                    childAspectRatio: 460.ww / 135.wh,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 获取统计卡片值的颜色
  Color _getStatCardValueColor(String title, String value) {
    if (title == '批量审核资格') {
      return value == '已获得' ? color_05DF72 : color_FB2C36;
    }
    return Colors.white;
  }

  /// 获取统计卡片副文本的颜色
  Color _getStatCardSubtextColor(String title, String value) {
    if (title == '批量审核资格') {
      return value == '已获得' ? Colors.white : color_FB2C36;
    }
    if (title == '最近活跃') {
      return Colors.white;
    }
    return color_05DF72;
  }
}
