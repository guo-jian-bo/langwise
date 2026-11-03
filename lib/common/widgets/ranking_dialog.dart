import 'package:api/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:collection/collection.dart';
import 'package:wise_http/wise_http.dart';
import '../values/values.dart';

/// 排行榜弹框组件
///
/// 使用Overlay实现，可以在任何页面中显示
/// 支持总榜和日榜切换
class RankingDialog {
  /// 显示排行榜弹框
  ///
  /// [context] 上下文
  /// [title] 标题
  static void show({
    required BuildContext context,
    String title = '审核排行榜',
  }) {
    final OverlayState overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;

    // 创建遮罩层和弹框
    overlayEntry = OverlayEntry(
      builder: (context) => _RankingDialogWidget(
        title: title,
        onClose: () {
          /// 安全移除Overlay
          ///
          /// 防止重复移除或已销毁的情况
          try {
            if (overlayEntry != null && overlayEntry.mounted) {
              overlayEntry.remove();
            }
          } catch (e) {
            debugPrint('移除排行榜弹框失败: $e');
          }
        },
      ),
    );

    // 插入Overlay
    overlayState.insert(overlayEntry);
  }
}

/// 排行榜弹框内部实现
class _RankingDialogWidget extends StatefulWidget {
  final String title;
  final VoidCallback onClose;

  const _RankingDialogWidget({
    Key? key,
    required this.title,
    required this.onClose,
  }) : super(key: key);

  @override
  State<_RankingDialogWidget> createState() => _RankingDialogWidgetState();
}

class _RankingDialogWidgetState extends State<_RankingDialogWidget> with SafeSetStateMixin {
  final CancelToken _cancelToken = CancelToken();

  /// 当前选中的标签索引 (0: 总榜, 1: 日榜)
  int _currentTabIndex = 0;

  /// 记录每个标签的鼠标悬停状态
  final List<bool> _hoveringStates = [false, false];

  /// PageView控制器
  final PageController _pageController = PageController();

  /// 总榜数据
  final List<RankingResponseEntity> _totalRankingItems = [];

  /// 日榜数据
  final List<RankingResponseEntity> _dailyRankingItems = [];

  @override
  void initState() {
    super.initState();
    _loadTotalRankingData();
    _loadDailyRankingData();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            width: 668.ww,
            height: 530.wh,
            padding: EdgeInsets.only(left: 24.ww, right: 24.ww, top: 24.wh, bottom: 24.wh),
            decoration: BoxDecoration(
              color: color_1E2939,
              borderRadius: BorderRadius.circular(8.wMin),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildHeader(),
                _buildTabs(),
                Expanded(child: _buildPageView()),
                Gaps.getHeight(8.wh),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建PageView
  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (index) {
        safeSetState(() => _currentTabIndex = index);
      },
      children: [
        // 总榜
        _buildRankingPage(_totalRankingItems),
        // 日榜
        _buildRankingPage(_dailyRankingItems),
      ],
    );
  }

  /// 构建单个排行榜页面
  ///
  /// [items] 排行榜数据列表
  Widget _buildRankingPage(List<RankingResponseEntity> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          '暂无排行数据',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 16.wMin,
          ),
        ),
      );
    }
    return RankingTable(items: items);
  }

  /// 构建弹框头部
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              Assets.imageModerationRanking,
              width: 24.ww,
              height: 24.wh,
            ),
            SizedBox(width: 8.ww),
            Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.wMin,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: widget.onClose,
          child: Icon(
            Icons.close,
            color: Colors.white.withValues(alpha: 0.6),
            size: 24.wMin,
          ),
        ),
      ],
    );
  }

  /// 构建标签栏
  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.wh),
      child: Row(
        children: [
          _buildTab('总榜', 0),
          SizedBox(width: 16.ww),
          _buildTab('日榜', 1),
        ],
      ),
    );
  }

  /// 构建单个标签
  Widget _buildTab(String text, int index) {
    final bool isSelected = _currentTabIndex == index;

    return MouseRegion(
      onEnter: (_) => safeSetState(() => _hoveringStates[index] = true),
      onExit: (_) => safeSetState(() => _hoveringStates[index] = false),
      child: GestureDetector(
        onTap: () {
          if (_currentTabIndex == index) {
            return;
          }

          safeSetState(() {
            _currentTabIndex = index;
          });

          if (!_pageController.hasClients) {
            return;
          }

          // 切换PageView页面 - 检查PageController是否已关联
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.ww, vertical: 8.wh),
          decoration: BoxDecoration(
            color: isSelected
                ? color_155DFC
                : (_hoveringStates[index] ? Colors.white.withValues(alpha: 0.1) : Colors.transparent),
            borderRadius: BorderRadius.circular(8.wMin),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                index == 0 ? Assets.imageModerationRank1 : Assets.imageModerationDay,
                width: 16.ww,
                height: 14.wh,
              ),
              Gaps.getWidth(8.ww),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : color_D1D5DC,
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 构建底部
  Widget _buildFooter() {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        width: 80.ww,
        height: 36.wh,
        decoration: BoxDecoration(
          color: color_155DFC,
          borderRadius: BorderRadius.circular(4.ww),
        ),
        alignment: Alignment.center,
        child: Text(
          '关闭',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.wMin,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 加载总榜排行榜数据
  Future<void> _loadTotalRankingData() async {
    try {
      ToastUtils.showLoading();
      final response =
          await ImageUtil.leaderboardsTotal(config: RequestConfig(cancelToken: _cancelToken, requireToken: true));
      safeSetState(() {
        _totalRankingItems.clear();
        _totalRankingItems.addAll(response.data?.list ?? []);
      });
    } catch (e) {
      debugPrint('加载排行榜数据失败: $e');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 加载今日排行榜数据
  Future<void> _loadDailyRankingData() async {
    try {
      final response =
          await ImageUtil.leaderboardsDaily(config: RequestConfig(cancelToken: _cancelToken, requireToken: true));
      safeSetState(() {
        _dailyRankingItems.clear();
        _dailyRankingItems.addAll(response.data?.list ?? []);
      });
    } catch (e) {
      debugPrint('加载排行榜数据失败: $e');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cancelToken.cancel("排行榜取消请求");
    super.dispose();
  }
}

/// 排行榜表格组件
///
/// 用于在排行榜弹框中显示数据
class RankingTable extends StatelessWidget {
  final List<RankingResponseEntity> items;

  const RankingTable({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTableHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: items.mapIndexed((index, entry) {
                return RankingTableRow(
                  item: entry,
                  isLastRow: index == items.length - 1,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建表格头部
  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.ww, vertical: 12.wh),
      child: Row(
        children: [
          SizedBox(
            width: 142.ww,
            child: Text(
              '排名',
              style: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              '审核员',
              style: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            width: 177.ww,
            alignment: Alignment.centerRight,
            child: Text(
              '图片数',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
              width: 177.ww,
              alignment: Alignment.centerRight,
              child: Text(
                '单词数',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w600),
              )),
        ],
      ),
    );
  }
}

/// 排行榜表格行组件
///
/// 处理每一行的鼠标悬停效果
class RankingTableRow extends StatefulWidget {
  final RankingResponseEntity item;
  final bool isLastRow;

  const RankingTableRow({
    Key? key,
    required this.item,
    this.isLastRow = false,
  }) : super(key: key);

  @override
  State<RankingTableRow> createState() => _RankingTableRowState();
}

class _RankingTableRowState extends State<RankingTableRow> with SafeSetStateMixin {
  /// 鼠标悬停状态
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // 根据排名显示不同的图标和颜色
    Widget rankWidget;
    if (widget.item.hasRank && widget.item.rank! <= 3) {
      rankWidget = Row(
        children: [
          SvgPicture.asset(
            widget.item.rank == 1
                ? Assets.imageModerationRank1
                : (widget.item.rank == 2 ? Assets.imageModerationRank2 : Assets.imageModerationRank3),
            width: 18.ww,
            height: 16.wh,
          ),
          Gaps.getWidth(2.ww),
          Text(
            widget.item.rank.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      );
    } else {
      rankWidget = Text(
        "${widget.item.rank ?? 0}",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.wMin,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final defaultColor = color_364153.withValues(alpha: 0.3);
    return MouseRegion(
      onEnter: (_) => safeSetState(() => _isHovering = true),
      onExit: (_) => safeSetState(() => _isHovering = false),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.ww, vertical: 12.wh),
        decoration: BoxDecoration(
          // 悬停时使用高亮颜色，否则使用默认颜色
          color: _isHovering ? Colors.white.withValues(alpha: 0.1) : defaultColor,
          // 只有最后一行有左下和右下圆角
          borderRadius: widget.isLastRow
              ? BorderRadius.only(
                  bottomLeft: Radius.circular(4.ww),
                  bottomRight: Radius.circular(4.ww),
                )
              : BorderRadius.zero,
          // 只有非最后一行有底边框
          border: widget.isLastRow
              ? null
              : Border(
                  bottom: BorderSide(
                    width: 1.wMin,
                    color: color_4A5565,
                  ),
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 142.ww,
              alignment: Alignment.centerLeft,
              child: rankWidget,
            ),
            Expanded(
              child: Text(
                widget.item.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              width: 177.ww,
              child: Text(
                "${widget.item.imageCount ?? 0}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              width: 177.ww,
              child: Text(
                "${widget.item.wordCount ?? 0}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
