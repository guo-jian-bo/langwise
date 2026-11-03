import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/back_widget.dart';
import 'package:langwise/common/widgets/data_table_widget/data_table_widget.dart';
import 'package:langwise/common/widgets/search_widget.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'controller.dart';
import 'state.dart';

/// 审核人管理页面
class ImageModerationAdminPage extends GetView<ImageModerationAdminController> {
  const ImageModerationAdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageModerationAdminController>(
      init: controller,
      builder: (_) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: color_101828,
          body: SafeArea(
            left: true,
            top: true,
            right: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部导航栏
                Container(
                  color: color_1E2939,
                  child: const BackWidget(title: '审核人员管理'),
                ),

                // 搜索和排序区域
                _buildSearchAndSortBar(),

                // 审核人员列表
                Expanded(
                  child: _buildReviewersTable(),
                ),
                Gaps.getHeight(20.wh)
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建搜索和排序栏
  Widget _buildSearchAndSortBar() {
    return GetBuilder<ImageModerationAdminController>(
      id: ImageModerationAdminState.searchId,
      builder: (_) {
        return Container(
          color: color_1E2939,
          padding: EdgeInsets.symmetric(horizontal: 16.ww, vertical: 16.wh),
          child: Row(
            children: [
              // 搜索框
              SearchWidget(
                width: 200.ww,
                height: 36.wh,
                hintText: '搜索审核人员ID或姓名',
                color: color_364153,
                onChanged: (String value) {
                  controller.setSearchTerm(value, isSubmit: false);
                },
                onSubmitted: (String value) {
                  controller.setSearchTerm(value, isSubmit: true);
                },
              ),
              Gaps.getWidth(8.ww),
              TapScaleWidget(
                  onTap: () {
                    controller.toReviewerDetail(null);
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
                          "查看所有审核人员",
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
              // 排序按钮区域
              _buildSortButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortButtons() {
    return GetBuilder<ImageModerationAdminController>(
      id: ImageModerationAdminState.sortId,
      builder: (_) {
        return Row(
          children: [
            // 按单词数排序按钮
            SortButton(
              text: '按单词数',
              field: 'reviewedContentCount',
              isActive: controller.state.sortField == 'reviewedContentCount',
              isAsc: controller.state.sortDirection == 'asc',
              onTap: () => controller.setSort("reviewedContentCount"),
            ),
            Gaps.getWidth(8.ww),
            // 按图片数排序按钮
            SortButton(
              text: '按图片数',
              field: 'reviewedImageCount',
              isActive: controller.state.sortField == 'reviewedImageCount',
              isAsc: controller.state.sortDirection == 'asc',
              onTap: () => controller.setSort("reviewedImageCount"),
            ),
          ],
        );
      },
    );
  }

  /// 构建审核人员表格
  Widget _buildReviewersTable() {
    return GetBuilder<ImageModerationAdminController>(
      id: ImageModerationAdminState.reviewersListId,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.ww),
          child: AsyncDataTableWidget<ReviewerEntity>(
            dataRowHeight: 57.wh,
            headingRowHeight: 45.wh,
            defaultRowBgColor: color_1E2939,
            pageNumPosition: PageNumPosition.bottom,
            // 垂直方向的表格边框样式
            verticalInside: BorderSide(color: Colors.transparent, width: 0.5.wMin),
            columns: _buildColumns(),
            dataCellBuilder: _buildDataCell,
            fetchData: (int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) {
              // 根据搜索词是否为空选择不同的数据获取方法
              return controller.state.isSearchEmpty
                  ? controller.onFetchPages(currentPage, startingAt, count, sortedBy, sortedAsc, noData)
                  : controller.onFetchSearchPages(currentPage, startingAt, count, sortedBy, sortedAsc, noData);
            },
            sourceCallback: (AsyncDataTableSource source) {
              controller.onSetDataSourceAsync(source);
            },
            showCheckboxColumn: false,
            // rowsPerPage: 10,
          ),
        );
      },
    );
  }

  /// 构建表格列
  List<DataColumn> _buildColumns() {
    return [
      DataColumn(
        label: Text(
          '审核人员ID',
          style: TextStyle(
            color: AppTheme.cTextPrimary,
            fontSize: 14.wMin,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          '姓名',
          style: TextStyle(
            color: AppTheme.cTextPrimary,
            fontSize: 14.wMin,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      DataColumn(
        label: GestureDetector(
          onTap: OptimizeUtils.noneThrottle(() {
            controller.setSort('reviewedContentCount');
          }, 100),
          child: Row(
            children: [
              Text(
                '总审核知识点数',
                style: TextStyle(
                  color: AppTheme.cTextPrimary,
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4.ww),
              SvgPicture.asset(
                controller.state.sortField == 'reviewedContentCount'
                    ? (controller.state.sortDirection == 'asc'
                        ? Assets.imageModerationUpWhite
                        : Assets.imageModerationDownWhite)
                    : Assets.imageModerationDownWhite,
                width: 14.ww,
                height: 14.wh,
                colorFilter: controller.state.sortField == 'reviewedContentCount'
                    ? ColorFilter.mode(color_51A2FF, BlendMode.srcIn)
                    : ColorFilter.mode(color_6A7282, BlendMode.srcIn),
              )
            ],
          ),
        ),
      ),
      DataColumn(
        label: GestureDetector(
          onTap: OptimizeUtils.noneThrottle(() {
            controller.setSort('reviewedImageCount');
          }, 100),
          child: Row(
            children: [
              Text(
                '总审核图片数',
                style: TextStyle(
                  color: AppTheme.cTextPrimary,
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4.ww),
              SvgPicture.asset(
                controller.state.sortField == 'reviewedImageCount'
                    ? (controller.state.sortDirection == 'asc'
                        ? Assets.imageModerationUpWhite
                        : Assets.imageModerationDownWhite)
                    : Assets.imageModerationDownWhite,
                width: 14.ww,
                height: 14.wh,
                colorFilter: controller.state.sortField == 'reviewedImageCount'
                    ? ColorFilter.mode(color_51A2FF, BlendMode.srcIn)
                    : ColorFilter.mode(color_6A7282, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
      DataColumn(
        label: Text(
          '最近活跃',
          style: TextStyle(
            color: AppTheme.cTextPrimary,
            fontSize: 14.wMin,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          '操作',
          style: TextStyle(
            color: AppTheme.cTextPrimary,
            fontSize: 14.wMin,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ];
  }

  /// 构建数据单元格
  List<DataCell> _buildDataCell(ReviewerEntity reviewer, int index) {
    return [
      // 审核人员ID
      DataCell(Text(
        "${reviewer.userId ?? ''}",
        style: TextStyle(
          color: AppTheme.cTextPrimary,
          fontSize: 16.wMin,
          fontWeight: FontWeight.w400,
        ),
      )),

      // 姓名
      DataCell(
        Text(
          reviewer.nickName ?? '',
          style: TextStyle(
            color: AppTheme.cTextPrimary,
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),

      // 总审核单词数
      DataCell(
        Text(
          "${reviewer.reviewedCount ?? '0'}",
          style: TextStyle(
            color: AppTheme.cTextPrimary,
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),

      // 总审核图片数
      DataCell(
        Row(
          children: [
            Text(
              "${reviewer.reviewedImageCount ?? '0'}",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: reviewer.canBatchReview ? color_05DF72 : color_D1D5DC,
              ),
            ),
            if (reviewer.canBatchReview) ...[
              SizedBox(width: 8.ww),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.ww, vertical: 2.wh),
                decoration: BoxDecoration(
                  color: color_0D542B.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10.ww),
                ),
                child: Text(
                  '可批量审核',
                  style: TextStyle(
                    fontSize: 12.wMin,
                    fontWeight: FontWeight.w400,
                    color: color_05DF72,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),

      // 最近活跃
      DataCell(Text(
        reviewer.newActiveDay,
        style: TextStyle(
          color: AppTheme.cTextPrimary,
          fontSize: 16.wMin,
          fontWeight: FontWeight.w400,
        ),
      )),

      // 操作
      DataCell(
        TapScaleWidget(
          onTap: () => controller.toReviewerDetail(reviewer),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.remove_red_eye_sharp,
                color: color_51A2FF,
                size: 18.wMin,
              ),
              SizedBox(width: 4.ww),
              Text(
                '查看详情',
                style: TextStyle(
                  color: color_51A2FF,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}

/// 排序按钮组件
class SortButton extends StatefulWidget {
  final String text;
  final String field;
  final bool isActive;
  final bool isAsc;
  final VoidCallback onTap;

  const SortButton({
    Key? key,
    required this.text,
    required this.field,
    required this.isActive,
    required this.isAsc,
    required this.onTap,
  }) : super(key: key);

  @override
  State<SortButton> createState() => _SortButtonState();
}

class _SortButtonState extends State<SortButton> with SafeSetStateMixin {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    Color buttonColor = widget.isActive ? color_155DFC : (_isHovering ? Colors.white.withOpacity(0.3) : color_364153);

    return MouseRegion(
      onEnter: (_) => safeSetState(() => _isHovering = true),
      onExit: (_) => safeSetState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 8.wh),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(8.ww),
          ),
          child: Row(
            children: [
              Text(
                widget.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (widget.isActive) ...[
                SizedBox(width: 4.ww),
                SvgPicture.asset(
                  widget.isAsc ? Assets.imageModerationUpWhite : Assets.imageModerationDownWhite,
                  width: 14.ww,
                  height: 14.wh,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
