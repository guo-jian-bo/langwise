import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_sentence_pair_binding.dart';
import '../controllers/manage_sentence_pair_controller.dart';
import 'manage_sentence_fork_item_widget.dart';
import 'manage_sentence_pair_item_widget.dart';

class ManageSentencePairView extends GetView<ManageSentencePairController> {
  final String tagText;
  const ManageSentencePairView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SENTENCE_PAIR}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSentencePairView(tagText: tag),
      binding: ManageSentencePairBinding(tag: tag),
      routeName: Routes.MANAGE_SENTENCE_PAIR,
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
        return FilterStripWidget(
          sorts: {...controller.filterSorts},
          conditions: {...controller.filterConditions},
          searchs: controller.filterSearchs,
          searchSingleWidth: 480.wMin,
          onSorts: (sorts) {
            controller.filterSorts.value = sorts;
            controller.refreshList();
          },
          onConditions: (conditions) {
            controller.filterConditions.value = conditions;
            controller.refreshList();
          },
          onReset: (sorts, conditions) {
            controller.filterSorts.value = sorts;
            controller.filterConditions.value = conditions;
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
          Row(
            children: [
              _buildTabItemWidget(0, "配对"),
              _buildTabItemWidget(1, "分叉"),
            ],
          ),
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
      if(controller.sentencePairList.isEmpty && !controller.isLoading.value){
        return NotDataWidget(message: "暂无数据");
      }
      return ListView.separated(
        controller: controller.scrollController,
        itemCount: controller.sentencePairList.length,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 6.wMin),
        separatorBuilder: (context, index) {
          return SizedBox(height: 24.wMin);
        },
        itemBuilder: (context, index) {
          return ManageSentencePairItemWidget(
            data: controller.sentencePairList[index],
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
      if(controller.sentenceForkList.isEmpty && !controller.isLoading.value){
        return NotDataWidget(message: "暂无数据");
      }
      return ListView.separated(
        controller: controller.scrollController,
        itemCount: controller.sentenceForkList.length,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 6.wMin),
        separatorBuilder: (context, index) {
          return SizedBox(height: 24.wMin);
        },
        itemBuilder: (context, index) {
          return ManageSentenceForkItemWidget(
            onTap: () {
              controller.toForkDetails(controller.sentenceForkList[index]);
            },
          );
        },
      );
    });
  }
  
}
