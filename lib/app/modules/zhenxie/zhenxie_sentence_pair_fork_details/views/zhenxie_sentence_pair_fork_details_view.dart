import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import 'package:langwise/app/routes/routes.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_sentence_pair_fork_details_binding.dart';
import '../controllers/zhenxie_sentence_pair_fork_details_controller.dart';

class ZhenxieSentencePairForkDetailsView extends GetView<ZhenxieSentencePairForkDetailsController> {
  final String tagText;
  const ZhenxieSentencePairForkDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 标签路由跳转方法（外部传入 tag，支持实例隔离）。
  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieSentencePairForkDetailsView(tagText: tag),
      binding: ZhenxieSentencePairForkDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_SENTENCE_PAIR_FORK_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () {
        controller.getForkDetail();
      },
      body: Column(
        children: [
          BreadcrumbWidget(isCompatibleManage: controller.isManagement),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 90.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32.wMin),
                  _buildInfoWidget(context),
                  _buildForkChainWidget(context),
                  _buildHowToUseWidget(),
                  SizedBox(height: 32.wMin),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoWidget(BuildContext context){
    return Obx((){
      SentenceForkEntity data = controller.forkDetail.value;
      LanguageText? pairTypeName = LearningLangUtils.getLocalLang(data.pairType?.name);
      LanguageText? contrastDimensionName = LearningLangUtils.getLocalLang(data.contrastDimension?.name);
      LanguageText? name = LearningLangUtils.getLocalLang(data.name);
      LanguageText? description = LearningLangUtils.getLocalLang(data.description);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SelectableText(
                "${pairTypeName?.text??''} · ${contrastDimensionName?.text??''}",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              CopyTagWidget(
                name: "维度",
                value: data.contrastDimensionNid??'',
                isShow: controller.isManagement,
              ),
            ],
          ),
          Row(
            spacing: 4.wMin,
            children: [
              SelectableText(
                name?.text??'',
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              CopyTagWidget(
                name: "分叉",
                value: data.nid??'',
                isShow: controller.isManagement,
              ),
            ],
          ),
          SizedBox(height: 10.wMin),
          SelectableText(
            description?.text??'',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          Row(
            children: [
              Visibility(
                visible: data.kindEnum != null,
                child: Container(
                  margin: EdgeInsets.only(right: 6.wMin),
                  child: _buildTagWidget(
                    tagText: data.kindEnum?.description??'',
                    textColor: data.kindEnum?.color,
                    bgColor: data.kindEnum?.color.withValues(alpha: 0.12),
                    borderColor: data.kindEnum?.color.withValues(alpha: 0.2),
                  ),
                ),
              ),
              _buildTagWidget(
                tagText: "${data.members?.length??0} 种接法",
              ),
              SizedBox(width: 6.wMin),
              _buildTagWidget(
                tagText: data.soloPairPracticeEnum?.description??'',
                textColor: data.soloPairPracticeEnum?.color,
                bgColor: data.soloPairPracticeEnum?.color.withValues(alpha: 0.12),
                borderColor: data.soloPairPracticeEnum?.color.withValues(alpha: 0.2),
              ),
            ],
          ),

        ],
      );
    });
  }

  /// 分叉表
  Widget _buildForkChainWidget(BuildContext context) {
    return Obx((){
      return SentencePairingLinkForkDetailsTableWidget(
        realizationSetList: controller.forkDetail.value.realizationSetList,
        isManagement: controller.isManagement,
        onShelfChange: (group) {
          controller.exampleSentenceGroupShelf(group);
        },
        onDelete: (group) {
          controller.exampleSentenceGroupDelete(context, group);
        },
        onSentenceShelfChange: (sentence) {
          controller.exampleSentenceShelf(sentence);
        },
      );
    });
  }


  /// 出题人怎么用
  Widget _buildHowToUseWidget(){
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 32.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 0.8.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            "出题人怎么用",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          Obx((){
            SentenceForkEntity data = controller.forkDetail.value;
            LanguageText? usage = LearningLangUtils.getLocalLang(data.usage);
            return SelectableText(
              usage?.text??'',
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


  Widget _buildTagWidget({
    required String tagText,
    Color? textColor = AppTheme.cTextSecondary,
    Color? bgColor = AppTheme.cSurfaceLayerBase,
    Color? borderColor = AppTheme.cBorderThin,
  }){
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: (borderColor??AppTheme.cBorderThin).withValues(alpha: 0.2),
          width: 0.5.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tagText,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

}
