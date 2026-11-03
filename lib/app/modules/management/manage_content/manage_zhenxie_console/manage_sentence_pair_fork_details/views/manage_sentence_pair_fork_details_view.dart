import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_sentence_pair_fork_details_binding.dart';
import '../controllers/manage_sentence_pair_fork_details_controller.dart';

class ManageSentencePairForkDetailsView extends GetView<ManageSentencePairForkDetailsController> {
  final String tagText;
  const ManageSentencePairForkDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SENTENCE_PAIR_FORK_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSentencePairForkDetailsView(tagText: tag),
      binding: ManageSentencePairForkDetailsBinding(tag: tag),
      routeName: Routes.MANAGE_SENTENCE_PAIR_FORK_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 90.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.wMin),
            _buildInfoWidget(context),
            _buildForkChainWidget(),
            _buildHowToUseWidget(),
            SizedBox(height: 32.wMin),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoWidget(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SelectableText(
              "因果配对 · 目的：to 与 so that",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            CopyTagWidget(
              name: "维度",
              value: "purpose_realization",
            ),
          ],
        ),
        Row(
          spacing: 4.wMin,
          children: [
            SelectableText(
              "同一动作可以怎么接目的",
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            CopyTagWidget(
              name: "分叉",
              value: "action_to_purpose_packaging",
            ),
          ],
        ),
        SizedBox(height: 10.wMin),
        SelectableText(
          "说完动作后，可以用 so that 或 to 不定式说明目的。",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
        SizedBox(height: 10.wMin),
        Row(
          children: [
            _buildTagWidget(
              tagText: "换种答法",
            ),
            SizedBox(width: 6.wMin),
            _buildTagWidget(
              tagText: "可分叉也可抽一条",
            ),
            SizedBox(width: 6.wMin),
            _buildTagWidget(
              tagText: "2 种接法",
            ),
          ],
        ),

      ],
    );
  }

  /// 分叉表
  Widget _buildForkChainWidget() {
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
      child: SentencePairingLinkForkDetailsTableWidget(
        onTap: () {
          controller.toPairDetails();
        },
      ),
    );
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
          SelectableText(
            "肯否对照另走 polarity 家族，不要把 Yes./No. 和短答/整句混成肯否题。出题抽本家族 2–4 个 member。From 共用「Is he your brother?」；To 换壳：「Yes.」 / 「Yes, he is.」 / 「He is my brother.」。单条 pair 仍可按多场景练这一种推进。",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }){
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
