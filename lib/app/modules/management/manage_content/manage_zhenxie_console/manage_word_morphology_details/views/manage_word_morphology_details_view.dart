import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../../elements/common/elements_morpheme_word_cover_card_widget.dart';
import '../bindings/manage_word_morphology_details_binding.dart';
import '../controllers/manage_word_morphology_details_controller.dart';

class ManageWordMorphologyDetailsView extends GetView<ManageWordMorphologyDetailsController> {
  final String tagText;
  const ManageWordMorphologyDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, String? tag}) async {
    final pageTag = tag ?? '${Routes.MANAGE_WORD_MORPHOLOGY_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageWordMorphologyDetailsView(tagText: pageTag),
      binding: ManageWordMorphologyDetailsBinding(tag: pageTag),
      routeName: Routes.MANAGE_WORD_MORPHOLOGY_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () async {
        await controller.refreshPage();
      },
      body: Obx(() {
        WordMorphologyWordsPageEntity data = controller.detail.value;
        if (!controller.hasDetailData() && controller.isLoading.value) {
          return const Center();
        }
        if (!controller.hasDetailData()) {
          return NotDataWidget(
            message: controller.isRootKeyMode()
                ? "未找到词根：${controller.getEmptyIdentifier()}"
                : "未找到词素：${controller.getEmptyIdentifier()}",
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 90.wMin, vertical: 24.wMin),
          child: _buildScrollWidget(data),
        );
      }),
    );
  }

  Widget _buildScrollWidget(WordMorphologyWordsPageEntity data) {
    return Obx(() {
      return CustomScrollView(
        controller: controller.scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderWidget(data)),
          SliverToBoxAdapter(child: SizedBox(height: 24.wMin)),
          if (controller.wordList.isEmpty && !controller.isLoading.value)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: NotDataWidget(message: "暂无成员词"),
            )
          else
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 24.wMin,
                crossAxisSpacing: 24.wMin,
                childAspectRatio: 346 / 546,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  CardMorphemeWordEntityDatas item = controller.wordList[index];
                  return ElementsMorphemeWordCoverCardWidget(
                    data: item,
                    morphemeContent: controller.detail.value.content ?? '',
                    morphemeType: controller.detail.value.morphemeTypeNid ?? '',
                    onTap: () {
                      controller.jumpToTreePage(item);
                    },
                  );
                },
                childCount: controller.wordList.length,
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 40.wMin)),
        ],
      );
    });
  }

  Widget _buildHeaderWidget(WordMorphologyWordsPageEntity data) {
    final headerDescription = controller.getHeaderDescription();
    final morphemeTypeTitle = controller.getMorphemeTypeTitle(data.morphemeTypeNid);
    final morphemeTypeTextColor = controller.getMorphemeTypeTextColor(data.morphemeTypeNid);
    final formPositionName = controller.getFormPositionName(data.formPosition);
    final posTitle = controller.getPosTitle(data.pos);
    final posTextColor = controller.getPosTextColor(data.pos);
    final isRootKeyMode = controller.isRootKeyMode();
    final contentIdText = data.contentId?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BreadcrumbWidget(
          isCompatibleManage: true,
          padding: EdgeInsets.zero,
        ),
        SizedBox(height: 8.wMin),
        Row(
          children: [
            Text(
              isRootKeyMode ? "共享词根" : "共享词素",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
                letterSpacing: 1.2.wMin,
              ),
            ),
            SizedBox(width: 10.wMin),
            if (isRootKeyMode && contentIdText.isNotEmpty)
              CopyTagWidget(
                name: "词",
                value: contentIdText,
              ),
            if (!isRootKeyMode && (data.nid ?? '').isNotEmpty)
              CopyTagWidget(
                name: "词素",
                value: data.nid ?? '',
              ),
          ],
        ),
        SizedBox(height: 10.wMin),
        Text(
          data.content ?? '',
          style: TextStyle(
            fontSize: 42.wMin,
            fontWeight: FontWeight.w700,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        if (headerDescription.isNotEmpty) ...[
          SizedBox(height: 12.wMin),
          Text(
            headerDescription,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
              height: 1.5,
            ),
          ),
        ],
        SizedBox(height: 16.wMin),
        Wrap(
          spacing: 8.wMin,
          runSpacing: 8.wMin,
          children: [
            if (morphemeTypeTitle.isNotEmpty)
              WordInflectionInfoTagWidget(
                morphemeTypeTitle,
                textColor: morphemeTypeTextColor,
                bgColor: morphemeTypeTextColor?.withValues(alpha: 0.12),
                borderColor: morphemeTypeTextColor?.withValues(alpha: 0.20),
              ),
            if (isRootKeyMode && posTitle.isNotEmpty)
              WordInflectionInfoTagWidget(
                posTitle,
                textColor: posTextColor,
                bgColor: posTextColor?.withValues(alpha: 0.12),
                borderColor: posTextColor?.withValues(alpha: 0.20),
              ),
            if (!isRootKeyMode && formPositionName.isNotEmpty) WordInflectionInfoTagWidget(formPositionName),
            if (data.difficulty?.min != null)
              _buildDifficultyTagWidget(
                minDifficulty: data.difficulty?.min,
                maxDifficulty: data.difficulty?.max,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyTagWidget({
    required int? minDifficulty,
    required int? maxDifficulty,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.wMin),
        color: AppTheme.cSurfaceSoildTertiary,
        border: Border.all(
          color: AppTheme.cBorderSoildSecondary,
          width: 1.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusTagDifficultyWidget(
            difficulty: minDifficulty,
            language: controller.getLearningLang(),
            fontSize: 16.wMin,
            defaultColor: Colors.transparent,
            fontColor: AppTheme.cTextSecondary,
            padding: EdgeInsets.zero,
          ),
          if (maxDifficulty != null && minDifficulty != null && maxDifficulty != minDifficulty)
            Text(
              "-",
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextSecondary,
              ),
            ),
          if (maxDifficulty != null && minDifficulty != null && maxDifficulty != minDifficulty)
            StatusTagDifficultyWidget(
              difficulty: maxDifficulty,
              language: controller.getLearningLang(),
              fontSize: 16.wMin,
              defaultColor: Colors.transparent,
              fontColor: AppTheme.cTextSecondary,
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
