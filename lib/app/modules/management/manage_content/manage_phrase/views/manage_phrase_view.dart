import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_phrase_binding.dart';
import '../controllers/manage_phrase_controller.dart';
import 'manage_phrase_card_widget.dart';

class ManagePhraseView extends GetView<ManagePhraseController> {
  final String tagText;
  const ManagePhraseView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_PHRASE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManagePhraseView(tagText: tag),
      binding: ManagePhraseBinding(tag: tag),
      routeName: Routes.MANAGE_PHRASE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.getKnowledgeList(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeardWidget(context),
              Expanded(child: _buildListWidget(context)),
            ],
          ),
          Positioned(
            right: 10.wMin,
            bottom: 200.wMin,
            child: Obx((){
              return ManageListToolButtonWidget(
                isExpand: controller.isAllExpand.value,
                onExpand: controller.onAllExpand,
                onSubmit: controller.getKnowledgeList,
              );
            }),
          ),

        ],
      ),
      floatingActionButton: _buildFilterWidget(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context){
    return Obx((){
      return FilterStripWidget(
        sorts: {...controller.filterSorts},
        conditions: {...controller.filterConditions},
        searchs: controller.filterSearchs,
        onSorts: (sorts) {
          controller.filterSorts.value = sorts;
          controller.pagerController.jumpToPage(1);
        },
        onConditions: (conditions) {
          controller.filterConditions.value = conditions;
          controller.pagerController.jumpToPage(1);
        },
        onReset: (sorts, conditions) {
          controller.filterSorts.value = sorts;
          controller.filterConditions.value = conditions;
          controller.pagerController.jumpToPage(1);
        },
        onSearch: () {
          controller.pagerController.jumpToPage(1);
        },
      );
    });
  }


  Widget _buildHeardWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.cBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Row(
        children: [
      
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.enPhraseMatchDetail],
            child: ButtonWidget(
              text: "创建短语",
              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
              borderRadius: 6.wMin,
              color: Colors.transparent,
              fontColor: AppTheme.cTextSecondary.color,
              tapColor: AppTheme.cTextSecondary.color.withValues(alpha: 0.1),
              sclae: 1.05,
              fontSize: 18.wMin,
              leftIcon: Container(
                margin: EdgeInsets.only(right: 4.wMin),
                child: SvgPicture.asset(
                  "assets/svg/public/icon_add.svg",
                  width: 24.wMin,
                  height: 24.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextQuaternary.color, BlendMode.srcIn),
                ),
              ),
              onTap: (){
                controller.showCreatePhrase(context);
              },
            ),
          ),

          SizedBox(width: 16.wMin),

          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.enContentKnowledgeCreateHistory],
            child: ButtonWidget(
              text: "添加记录",
              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
              borderRadius: 6.wMin,
              color: Colors.transparent,
              fontColor: AppTheme.cTextSecondary.color,
              tapColor: AppTheme.cTextSecondary.color.withValues(alpha: 0.1),
              sclae: 1.05,
              fontSize: 18.wMin,
              onTap: (){
                controller.jumpToCreateHistory(context);
              },
            ),
          ),

          const Spacer(),

          Obx((){
            return PagerWidget(
              dataCount: controller.totalCount.value,
              controller: controller.pagerController,
              visiblePageCount: 3,
              activeColor: AppTheme.cTextPrimary.color,
              onPage: (page, pageSize) {
                controller.pagerCallback(page, pageSize);
              },
            );
          }),
      
        ],
      ),
    );
  }


  /// 列表
  Widget _buildListWidget(BuildContext context){
    return Obx((){
      return ListView.separated(
        padding: EdgeInsets.only(
          top: 24.wMin,
          left: 140.wMin,
          right: 140.wMin,
          bottom: MediaQuery.of(context).viewInsets.bottom + 140.wMin,
        ),
        itemCount: controller.knowledgeList.length,
        separatorBuilder: (context, index) {
          return SizedBox(height: 16.wMin);
        },
        itemBuilder: (context, index) {
          return ManagePhraseCardWidget(
            entity: controller.knowledgeList[index],
            languageCode: controller.languageCode,
            onToggleSemantic: () {
              controller.toggleSemantic(controller.knowledgeList[index]);
            },
            onDeleteKnowledge: () {
              controller.deleteKnowledge(context, controller.knowledgeList[index]);
            },
            onEditKnowledge: () {
              controller.editKnowledge(context, controller.knowledgeList[index]);
            },
            onKnowledgeCore: () {
              controller.onKnowledgeCore(context, controller.knowledgeList[index]);
            },
            onDeleteSemantic: (semantic) {
              controller.deleteSemantic(context,controller.knowledgeList[index], semantic);
            },
            onEditSemantic: (semantic) {
              controller.editSemantic(context, semantic);
            },
            onSemanticVideo: (semantic) {
              controller.onSemanticVideo(controller.knowledgeList[index].data, semantic);
            },
            onSemanticImage: (semantic) {
              controller.onSemanticImage(controller.knowledgeList[index].data, semantic);
            },
            onSemanticExercises: (semantic) {
              controller.onSemanticExercises(controller.knowledgeList[index].data, semantic);
            },
            onSemanticQuote: (semantic) {
              controller.onSemanticQuote(controller.knowledgeList[index].data, semantic);
            },
            onAddSemantic: () {
              controller.addSemantic(context, controller.knowledgeList[index]);
            },
            onCorrelationSemantic: () {
              controller.onCorrelationSemantic(context, controller.knowledgeList[index]);
            },
            onRefreshData: () {
              controller.knowledgeList.refresh();
            },
            onRefreshServiceData: () {
              controller.getKnowledgeList();
            },
          );
        },
      );
    });
  }


}
