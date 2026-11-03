import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_module_detils_generate_article_binding.dart';
import '../controllers/manage_module_detils_generate_article_controller.dart';

class ManageModuleDetilsGenerateArticleView extends GetView<ManageModuleDetilsGenerateArticleController> {
  final String tagText;
  const ManageModuleDetilsGenerateArticleView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_MODULE_DETILS_GENERATE_ARTICLE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageModuleDetilsGenerateArticleView(tagText: tag),
      binding: ManageModuleDetilsGenerateArticleBinding(tag: tag),
      routeName: Routes.MANAGE_MODULE_DETILS_GENERATE_ARTICLE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.wMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleWidget(),
              SizedBox(height: 24.wMin),
              _buildThemeBodyWidget(),
              SizedBox(height: 24.wMin),
              _buildCombinationWidget(),
              SizedBox(height: 24.wMin),
              _buildKnowledgePointWidget(context),
              SizedBox(height: 24.wMin),
              _buildButtonGnerateWidget(context),
              SizedBox(height: 24.wMin),
            ],
          ),
        ),
      ),
    );
  }

  /// 标题
  Widget _buildTitleWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Remix 混搭生成",
          style: TextStyle(
            fontSize: 22.wMin,
            fontWeight: FontWeight.w400,
            color: const Color(0xffEBEEF3),
          ),
        ),
        Text(
          "选择主题、题材和难度级别，生成多篇不同风格的文章",
          style: TextStyle(
            fontSize: 14.wMin,
            fontWeight: FontWeight.w400,
            color: const Color(0xffBAC0CC),
          ),
        ),
      ],
    );
  }

  /// 选择主题和题材
  Widget _buildThemeBodyWidget() {
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: const Color(0xff181B25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "选择主题和题材",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: const Color(0xffEBEEF3),
            ),
          ),
          SizedBox(height: 8.wMin),
          Row(
            spacing: 32.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildThemeWidget()),
              Expanded(child: _buildGenreWidget()),
            ],
          ),
          SizedBox(height: 8.wMin),
          Container(
            alignment: Alignment.centerRight,
            child: ButtonWidget(
              text: "添加组合",
              fontColor: Colors.white,
              fontSize: 14.wMin,
              width: 120.wMin,
              height: 40.wMin,
              borderRadius: 6.wMin,
              sclae: 1.05,
              onTap: () {
                controller.addCombination();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 主题列表
  Widget _buildThemeWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.wMin,
      children: [
        Text(
          "主题",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: const Color(0xffEBEEF3),
          ),
        ),
        Obx(() {
          TextSubjectThemeEntityThemes? theme = controller.selectedTheme.value;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.themeList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8.wMin,
              crossAxisSpacing: 8.wMin,
              childAspectRatio: 250 / 110,
            ),
            itemBuilder: (context, index) {
              return _buildThemeItemWidget(
                name: controller.themeList[index].name,
                description: controller.themeList[index].description,
                selected: theme?.id == controller.themeList[index].id,
                onTap: () {
                  controller.selectTheme(controller.themeList[index]);
                },
              );
            },
          );
        }),
      ],
    );
  }

  /// 题材列表
  Widget _buildGenreWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.wMin,
      children: [
        Text(
          "题材",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: const Color(0xffEBEEF3),
          ),
        ),
        Obx(() {
          TextSubjectThemeEntityThemes? genre = controller.selectedGenre.value;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.genreList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8.wMin,
              crossAxisSpacing: 8.wMin,
              childAspectRatio: 250 / 110,
            ),
            itemBuilder: (context, index) {
              return _buildThemeItemWidget(
                name: controller.genreList[index].name,
                description: controller.genreList[index].description,
                selected: genre?.id == controller.genreList[index].id,
                onTap: () {
                  controller.selectGenre(controller.genreList[index]);
                },
              );
            },
          );
        }),
      ],
    );
  }

  /// 小卡片item
  Widget _buildThemeItemWidget({
    required List<LanguageText?>? name,
    required List<LanguageText?>? description,
    bool selected = false,
    void Function()? onTap,
  }) {
    LanguageText? nameEntity = LearningLangUtils.getLocalLang(name);
    LanguageText? descriptionEntity = LearningLangUtils.getLocalLang(description);

    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.01,
      child: Container(
        padding: EdgeInsets.all(10.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: selected ? const Color(0xff2388FF).withValues(alpha: 0.2) : const Color.fromRGBO(53, 62, 92, 0.35),
          border: Border.all(
            color: selected ? const Color(0xff2388FF) : Colors.transparent,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.wMin,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    nameEntity?.text ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  selected ? "assets/svg/manage/icon_radio.svg" : "assets/svg/manage/icon_unradio.svg",
                  width: 18.wMin,
                  height: 18.wMin,
                ),
              ],
            ),
            Text(
              descriptionEntity?.text ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
                color: const Color(0xff767E95),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 已添加组合
  Widget _buildCombinationWidget() {
    return Obx(() {
      if (controller.combinationList.isEmpty) return Container();
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.wMin),
          color: const Color(0xff181B25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "已添加组合",
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: const Color(0xffEBEEF3),
              ),
            ),
            SizedBox(height: 8.wMin),
            Column(
              spacing: 12.wMin,
              children: List.generate(controller.combinationList.length, (index) {
                return _buildCombinationItemWidget(controller.combinationList[index], index);
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCombinationItemWidget(Map<String, TextSubjectThemeEntityThemes> combination, int index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: const Color.fromRGBO(35, 136, 255, 0.05),
        border: Border.all(
          color: const Color.fromRGBO(35, 136, 255, 0.4),
          width: 1.wMin,
        ),
      ),
      child: Row(
        children: [
          Text(
            "${index + 1}",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: const Color(0xffFFFFFF),
            ),
          ),
          SizedBox(width: 24.wMin),
          Expanded(
            child: Text(
              combination.values.map((e) {
                return LearningLangUtils.getLocalLang(e.name)?.text ?? "";
              }).join("+"),
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: const Color(0xffBAC0CC),
              ),
            ),
          ),
          SizedBox(width: 24.wMin),
          TapScaleWidget(
            onTap: () {
              controller.removeCombination(index);
            },
            sclae: 1.1,
            child: Container(
              width: 32.wMin,
              height: 32.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.wMin),
                color: const Color.fromRGBO(255, 45, 70, 0.12),
              ),
              child: SvgPicture.asset(
                "assets/svg/public/icon_delete.svg",
                width: 20.wMin,
                height: 20.wMin,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 选择知识点
  Widget _buildKnowledgePointWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: const Color(0xff181B25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "选择知识点（可选）",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: const Color(0xffEBEEF3),
            ),
          ),
          Obx(() {
            return Visibility(
              visible: controller.knowledgeList.isEmpty,
              child: Container(
                margin: EdgeInsets.only(top: 8.wMin),
                child: Text(
                  "未选择知识点",
                  style: TextStyle(
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xffBAC0CC),
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: 8.wMin),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10.wMin,
                children: [
                  ...List.generate(controller.knowledgeList.length, (index) {
                    return _buildSelectKnowledgeListItemWidget(controller.knowledgeList[index], index);
                  }),
                  _buildAddOtherWidget(context),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 已选择知识点item
  Widget _buildSelectKnowledgeListItemWidget(EnKnowledgeEntity knowledge, int index) {
    String? content = knowledge.content;
    String? imageUrl = knowledge.selectedSemantic?.imageUrl;
    String? definition = knowledge.selectedSemantic?.definition;
    if (knowledge.isText) {
      imageUrl = knowledge.imageUrl;
      definition = knowledge.content;
      content = knowledge.title;
    }

    return SizedBox(
      height: 290.wMin,
      width: 180.wMin,
      child: ManagePublicKnowledeRowItemWidget(
        content: content,
        imageUrl: imageUrl,
        language: "en",
        difficulty: knowledge.difficulty?.min,
        audioUrl: knowledge.audioUrl,
        definition: definition,
        showTR: true,
        svg: "assets/svg/manage/icon_bg_delete.svg",
        onTR: () {
          controller.removeSelectedKnowledge(knowledge, index);
        },
      ),
    );
  }

  /// 添加知识点按钮
  Widget _buildAddOtherWidget(BuildContext context) {
    return Container(
      height: 290.wMin,
      alignment: Alignment.topCenter,
      child: TapScaleWidget(
        onTap: () {
          controller.showSelectKnowledgeDialog(context);
        },
        sclae: 1.01,
        child: Container(
          width: 180.wMin,
          height: 180.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: const Color(0xffBEC8D0).withValues(alpha: 0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/svg/manage/icon_add.svg",
                width: 40.wMin,
              ),
              Text(
                "添加知识点",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 确定生成的按钮
  Widget _buildButtonGnerateWidget(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      child: Obx(() {
        bool isEnable = controller.combinationList.isNotEmpty;
        return ButtonWidget(
          text: "生成文章",
          fontColor: Colors.white,
          fontSize: 14.wMin,
          width: 120.wMin,
          height: 40.wMin,
          borderRadius: 6.wMin,
          sclae: 1.05,
          color: const Color(0xff1AA6F3).withValues(alpha: isEnable ? 1 : 0.4),
          onTap: !isEnable
              ? null
              : OptimizeUtils.noneThrottle(() {
                  controller.generateArticle(context);
                }, 500),
        );
      }),
    );
  }
}
