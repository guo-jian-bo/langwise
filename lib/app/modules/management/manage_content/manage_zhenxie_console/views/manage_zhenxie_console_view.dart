import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../routes/routes.dart';
import '../../../common/manage_scaffold.dart';
import '../../../models/models.dart';
import '../bindings/manage_zhenxie_console_binding.dart';
import '../controllers/manage_zhenxie_console_controller.dart';

class ManageZhenxieConsoleView extends GetView<ManageZhenxieConsoleController> {
  final String tagText;
  const ManageZhenxieConsoleView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_ZHENXIE_CONSOLE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageZhenxieConsoleView(tagText: tag),
      binding: ManageZhenxieConsoleBinding(tag: tag),
      routeName: Routes.MANAGE_ZHENXIE_CONSOLE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 70.wMin, vertical: 40.wMin),
        child: Obx((){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "甄写管理台",
                style: TextStyle(
                  fontSize: 32.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                "围绕 Word → Phrase → Sentence → Paragraph → Composition 的统一写作资产管理后台",
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),

              _buildListWidget(
                title: "单词",
                subTitle: "零件准备层",
                desc: "认对、变对、拆对：义项透镜、屈折变化、构词网络。对齐 vocabulary.md 五交互与真相表。",
                list: controller.wordMenuList.toList(),
              ),

              _buildListWidget(
                title: "短语",
                subTitle: "Phrase",
                desc: "整块识别、整块入句。对照/搭配是一池签发，配对是一对一套；短语结构管块内切分，入句画像管槽位与补足。",
                list: controller.phraseMenuList.toList(),
              ),

              _buildListWidget(
                title: "句子",
                subTitle: "句型：蓝图 · 对照　｜　句间：配链　｜　坐标：全景 · 镜头",
                desc: "句型工作台（蓝图含生长金字塔、对照）· 句间配链 · 语法全景 / 时体镜头。建立在 en_sentence_structures 真相之上。",
                list: controller.sentenceMenuList.toList(),
              ),

              _buildListWidget(
                title: "段落",
                subTitle: "Paragraph",
                desc: "Blueprint-first：九类段型，每一段按起承转合摊开。不是加长的 Sentence Chain。",
                list: controller.paragraphMenuList.toList(),
              ),

              _buildListWidget(
                title: "文章",
                subTitle: "Composition",
                desc: "先选要写的文章，再看文首文末格式和正文四拍。格子里是段型，不是题目。",
                list: controller.articleMenuList.toList(),
              ),

            ],
          );
        }),
      ),
    );
  }

  Widget _buildListWidget({
    required String title,
    required String subTitle,
    required String desc,
    required List<ManageAuthMenuModel> list,
  }){
    if(list.isEmpty) return Container();

    return Container(
      margin: EdgeInsets.only(top: 32.wMin),
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceSecondary.color,
        borderRadius: BorderRadius.circular(24.wMin)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            spacing: 10.wMin,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subTitle,
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          Text(
            desc,
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
          ),

          Container(
            height: 1.wMin,
            color: AppTheme.cBorderPrimary.color,
            margin: EdgeInsets.symmetric(vertical: 16.wMin),
          ),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16.wMin,
              crossAxisSpacing: 16.wMin,
              mainAxisExtent: 160.wMin,
            ),
            itemBuilder: (context, index) {
              return _buildCardItemWidget(list[index]);
            },
          ),

        ],
      ),

    );

  }

  Widget _buildCardItemWidget(ManageAuthMenuModel data){
    return TapScaleWidget(
      onTap: () {
        controller.toPage(data);
      },
      sclae: 1.01,
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceTertiary.color,
          border: Border.all(
            color: AppTheme.cBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.wMin,
          children: [
      
            Text(
              data.name,
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
      
            Text(
              data.subtitle,
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
      
          ],
        ),
      ),
    );
  }



}
