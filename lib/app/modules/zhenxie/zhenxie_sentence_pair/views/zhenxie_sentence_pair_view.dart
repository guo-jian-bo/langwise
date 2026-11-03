import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_sentence_pair_binding.dart';
import '../controllers/zhenxie_sentence_pair_controller.dart';
import 'zhenxie_sentence_fork_item_widget.dart';
import 'zhenxie_sentence_pair_item_widget.dart';

class ZhenxieSentencePairView extends GetView<ZhenxieSentencePairController> {
  final String tagText;
  const ZhenxieSentencePairView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 管理端入口跳转方法（生成唯一 tag，支持多实例）。
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_SENTENCE_PAIR}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxieSentencePairView(tagText: tag),
      binding: ZhenxieSentencePairBinding(tagText: tag),
      routeName: Routes.ZHENXIE_SENTENCE_PAIR,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  /// 标签路由跳转方法（外部传入 tag，支持实例隔离）。
  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieSentencePairView(tagText: tag),
      binding: ZhenxieSentencePairBinding(tagText: tag),
      routeName: Routes.ZHENXIE_SENTENCE_PAIR,
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
      child: ManageScaffold(
        onRefresh: () {
          controller.refreshList();
        },
        body: Column(
          children: [
            BreadcrumbWidget(isCompatibleManage: controller.isManagement),
            _buildTabWidget(),
            SizedBox(height: 10.wMin),
            Expanded(
              child: Obx((){
                if(controller.tab.value == 0){
                  return _buildPairListWidget();
                }
                return _buildForkListWidget();
              }),
            ),
          ],
        ),
        floatingActionButton: _buildFilterWidget(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx((){
        bool isPairTab = controller.tab.value == 0;
        return FilterStripWidget(
          sorts: isPairTab ? {...controller.pairFilterSorts} : {...controller.forkFilterSorts},
          conditions: isPairTab ? {...controller.pairFilterConditions} : {...controller.forkFilterConditions},
          searchs: isPairTab ? controller.pairFilterSearchs : controller.forkFilterSearchs,
          searchSingleWidth: 480.wMin,
          onSorts: (sorts) {
            if(isPairTab){
              controller.pairFilterSorts.value = sorts;
            }else{
              controller.forkFilterSorts.value = sorts;
            }
            controller.refreshList();
          },
          onConditions: (conditions) {
            if(isPairTab){
              controller.pairFilterConditions.value = conditions;
            }else{
              controller.forkFilterConditions.value = conditions;
            }
            controller.refreshList();
          },
          onReset: (sorts, conditions) {
            if(isPairTab){
              controller.pairFilterSorts.value = sorts;
              controller.pairFilterConditions.value = conditions;
            }else{
              controller.forkFilterSorts.value = sorts;
              controller.forkFilterConditions.value = conditions;
            }
            controller.refreshList();
          },
          onSearch: () {
            controller.refreshList();
          },
        );
      }),
    );
  }

  /// tab切换
  Widget _buildTabWidget(){
    return Container(
      margin: EdgeInsets.only(top: 16.wMin),
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx((){
            return Row(
              children: [
                _buildTabItemWidget(0, "配对", count: controller.pairTotal.value),
                _buildTabItemWidget(1, "分叉", count: controller.forkTotal.value),
              ],
            );
          }),
          SizedBox(height: 8.wMin),
          Obx((){
            String text = "两句对上，From → To。";
            if(controller.tab.value == 1){
              text = "同一句出发，拆成几种接法。";
            }
            return Text(
              text,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTabItemWidget(int value, String title, {int count = 0}){
    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          controller.switchTab(value);
        },
        sclae: 1,
        child: Obx((){
          bool selected = controller.tab.value == value;
          return Container(
            padding: EdgeInsets.all(12.wMin),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.cSurfaceBrand.color.withValues(alpha: selected ? 1 : 0),
                  width: 2.wMin,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 32.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                SizedBox(width: 16.wMin),
                Text(
                  "$count",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// 配对 列表
  Widget _buildPairListWidget(){
    return Obx((){
      if(controller.sentencePairList.isEmpty && !controller.pairIsLoading.value){
        return NotDataWidget(message: "暂无数据");
      }
      return ListView.separated(
        controller: controller.pairScrollController,
        itemCount: controller.sentencePairList.length,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 6.wMin),
        separatorBuilder: (context, index) {
          return SizedBox(height: 24.wMin);
        },
        itemBuilder: (context, index) {
          return ZhenxieSentencePairItemWidget(
            data: controller.sentencePairList[index],
            isManagement: controller.isManagement,
            onTap: () {
              controller.jumpToPairDetailPage(controller.sentencePairList[index]);
            },
          );
        },
      );
    });
  }

  /// 分叉 列表
  Widget _buildForkListWidget(){
    return Obx((){
      if(controller.sentenceForkList.isEmpty && !controller.forkIsLoading.value){
        return NotDataWidget(message: "暂无数据");
      }
      return ListView.separated(
        controller: controller.forkScrollController,
        itemCount: controller.sentenceForkList.length,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 6.wMin),
        separatorBuilder: (context, index) {
          return SizedBox(height: 24.wMin);
        },
        itemBuilder: (context, index) {
          return ZhenxieSentenceForkItemWidget(
            data: controller.sentenceForkList[index],
            isManagement: controller.isManagement,
            onTap: () {
              controller.toForkDetails(controller.sentenceForkList[index]);
            },
          );
        },
      );
    });
  }
  
}
