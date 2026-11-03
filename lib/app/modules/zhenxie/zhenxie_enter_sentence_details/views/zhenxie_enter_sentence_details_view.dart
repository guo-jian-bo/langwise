import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../../elements/common/elements_cards/elements_public_card.dart';
import '../../../elements/common/elements_public_widgets.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_enter_sentence_details_binding.dart';
import '../controllers/zhenxie_enter_sentence_details_controller.dart';

class ZhenxieEnterSentenceDetailsView extends GetView<ZhenxieEnterSentenceDetailsController> {
  final String tagText;
  const ZhenxieEnterSentenceDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_ENTER_SENTENCE_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxieEnterSentenceDetailsView(tagText: tag),
      binding: ZhenxieEnterSentenceDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_ENTER_SENTENCE_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieEnterSentenceDetailsView(tagText: tag),
      binding: ZhenxieEnterSentenceDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_ENTER_SENTENCE_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () {
        controller.getDetails();
      },
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            BreadcrumbWidget(
              isCompatibleManage: controller.isManagement,
              actionWidget: GeneralSettingButtonWidget(
                isManagement: controller.isManagement,
              ),
            ),
          Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 90.wMin),
                child: _buildScrollWidget(context),
            ),
          ),
          _buildTabListWidget(),
          SizedBox(height: 24.wMin),

        ],
      ),
    );
  }

    Widget _buildScrollWidget(BuildContext context) {
      return Obx(() {
        if (controller.isLoading.value) return const SizedBox.shrink();
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 24.wMin)),
              SliverToBoxAdapter(child: _buildContentWidget(context)),
              SliverToBoxAdapter(child: SizedBox(height: 24.wMin)),
              SliverToBoxAdapter(child: _buildProfileContentWidget()),
              SliverToBoxAdapter(child: SizedBox(height: 24.wMin)),
            ],
          ),
        );
      });
    }

  Widget _buildContentWidget(BuildContext context){
      return Container(
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderThin.color,
            width: 1.wMin,
          ),
        ),
        child: Obx((){
          final data = controller.detailData.value;
          final preview = data.preview;
          final countText = (data.profileCount ?? 0) > 0 ? "${data.profileCount ?? 0}种入句形式" : "待标";

          final configController = Get.find<ConfigController>();
          final posColor = StatusUtils.getConfigColor(configController.colorConfigs.value.pos, data.pos ?? '');
          Color posBorderColor = posColor?.color?.borderColor ?? AppTheme.cSurfaceBrand.color;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    preview?.grammaticalTypeNameZh ?? '',
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                  Spacer(),
                  _buildTagWidget(
                    tagText: countText,
                  ),
                  SizedBox(width: 6.wMin),
                  _buildTagWidget(
                    tagText: posColor?.title ?? '',
                    textColor: posBorderColor,
                    bgColor: posBorderColor.withValues(alpha: 0.12),
                    borderColor: posBorderColor.withValues(alpha: 0.6),
                  ),
                ],
              ),
              SizedBox(height: 6.wMin),
              Row(
                spacing: 4.wMin,
                children: [
                  Text(
                    data.content ?? "",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                  CopyTagWidget(
                    name: "短语",
                    value: data.phraseId?.toString() ?? '',
                    isShow: controller.isManagement,
                  ),
                ],
              ),
              SizedBox(height: 10.wMin),
              Text(
                "先看这块短语能放在句子的哪里，再看它自己还要不要再接成分。",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ],
          );
        }),
    );
  }

  Widget _buildTabListWidget(){
    return Obx((){
      if(controller.profileTabs.isEmpty) return const SizedBox.shrink();
      return Center(
        child: ElementsSemanticBottomBar(
          items: List.generate(controller.profileTabs.length, (index){
            return SemanticChipData(id: index, text: controller.profileTabs[index].grammaticalTypeNameZh);
          }),
          currentId: controller.currentTabIndex.value,
          showFilter: false,
          isFiltered: false,
          filterColor: AppTheme.cSurfaceSuccess.color,
          onTapItem: (int index) {
            controller.switchTab(index);
          },
        ),
      );
    });
  }

  Widget _buildProfileContentWidget(){
    return Obx((){
      if(controller.profileContents.isEmpty) return _buildEmptyProfileWidget();
      if(controller.currentTabIndex.value >= controller.profileContents.length) return _buildEmptyProfileWidget();
      final profile = controller.profileContents[controller.currentTabIndex.value];
      LanguageText? descriptions = LearningLangUtils.getLocalLang(profile.descriptions);

      final data = controller.detailData.value;

        return Container(
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cSurfaceLayerBase.color,
            border: Border.all(
              color: AppTheme.cBorderThin.color,
              width: 1.wMin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                descriptions?.text??'',
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SizedBox(height: 12.wMin),
                PhraseEnterSentencePhraseWidget(
                  governedSlots: profile.governedSlots ?? const <EnterSentenceEntityPreviewGovernedSlots?>[],
                  content: data.content ?? '',
                ),
              SizedBox(height: 12.wMin),
              _buildSentenceContentWidget(profile),
            ],
          ),
      );
    });
  }

  /// 无画像空态。
  Widget _buildEmptyProfileWidget() {
    return Text(
      "这条短语还没有入句形式。",
      style: TextStyle(
        fontSize: 16.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cTextTertiary.color,
      ),
    );
  }

  /// 例句展示区：优先卡牌列表，其次单条例句，最后空态文案。
    Widget _buildSentenceContentWidget(EnterSentenceEntityProfiles profile) {
    final sentences = profile.sentences??[];
    final sentenceCardList = sentences.where((item) => item?.contentCard != null).toList();
    if (sentenceCardList.isNotEmpty) return _buildCardListWidget(sentenceCardList);

    if (profile.example?.isNotEmpty == true) {
        return _buildCardListWidget([
          EnterSentenceEntityPreviewSentence(
            contentCard: KnowledgeCommonEntityList(
              contentType: 'EN_SENTENCE',
              title: profile.example,
              content: KnowledgeCommonEntityListContent(type: 'EN_SENTENCE'),
            ),
            ranges: const [],
          ),
        ]);
    }

    return Text(
      "这个形式还没有入库的句子",
      style: TextStyle(
        fontSize: 16.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cTextTertiary.color,
      ),
    );
  }

  /// 卡牌列表。
  Widget _buildCardListWidget(List<EnterSentenceEntityPreviewSentence?> sentences){
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sentences.length,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 24.wMin,
        crossAxisSpacing: 24.wMin,
          childAspectRatio: 346 / 546,
      ),
      itemBuilder: (context, index) {
          return ElementsDictReadCard(
          data: sentences[index]?.contentCard,
          isManagement: controller.isManagement,
        );
      },
    );
  }

  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }) {
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: borderColor.withValues(alpha: 0.2),
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
