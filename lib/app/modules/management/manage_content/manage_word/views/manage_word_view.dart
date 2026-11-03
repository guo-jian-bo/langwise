import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_word_binding.dart';
import '../controllers/manage_word_controller.dart';
import 'manage_word_card_widget.dart';

class ManageWordView extends GetView<ManageWordController> {
  final String tagText;
  const ManageWordView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_WORD}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageWordView(tagText: tag),
      binding: ManageWordBinding(tag: tag),
      routeName: Routes.MANAGE_WORD,
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
      Map<String, FilterConditionData> filterConditionDatas = {...controller.filterConditionDatas};
      Map<String, FilterInputData> filterInputDatas = {...controller.filterInputDatas};
      return FilterFloatWidget(
        width: 1400.wMin,
        conditions: filterConditionDatas,
        inputs: filterInputDatas,
        onChange: (datas) {
          controller.changeFilterConditionData(datas);
        },
        onSubmitted: () {
          controller.searchSubmitted();
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
            authCodes: const [ManageAuthCode.enWordMatchDetail],
            child: ButtonWidget(
              text: "创建单词",
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
                controller.showCreateWord(context);
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
          return ManageWordCardWidget(
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
            onListingAndDelisting: () {
              controller.onListingAndDelisting(context, controller.knowledgeList[index]);
            },
            onDeleteSemantic: (semantic) {
              controller.deleteWordSemantic(context, controller.knowledgeList[index], semantic);
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
            onAudioListClick: (data) {
              controller.jumpToAudioManage(controller.knowledgeList[index].data, data);
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
