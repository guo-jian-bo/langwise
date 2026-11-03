import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_word_inflection_details_binding.dart';
import '../controllers/manage_word_inflection_details_controller.dart';

class ManageWordInflectionDetailsView extends GetView<ManageWordInflectionDetailsController> {
  final String tagText;
  const ManageWordInflectionDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, String? tag}) async {
    final pageTag = tag ?? '${Routes.MANAGE_WORD_INFLECTION_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageWordInflectionDetailsView(tagText: pageTag),
      binding: ManageWordInflectionDetailsBinding(tag: pageTag),
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () async {
        await controller.getDetails();
      },
      body: Obx(() {
        WordInflectionDetailEntity data = controller.detail.value;
        if ((data.familyKey ?? '').isEmpty && controller.isLoading.value) {
          return const Center();
        }
        if ((data.familyKey ?? '').isEmpty) {
          return const NotDataWidget(message: "暂无详情数据");
        }

        List<WordInflectionDetailSlotEntity> slots = controller.getCurrentDisplaySlots();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(
              isCompatibleManage: true,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 90.wMin, vertical: 24.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderWidget(data),
                    SizedBox(height: 24.wMin),
                    Expanded(
                      child: WordInflectionSlotBoardWidget(
                          pos: data.pos ?? '',
                          slots: slots,
                          focusedBuilder: controller.isFocusedSlot,
                          footerBuilder: _buildSlotFooterWidget,
                        ),
                    ),
                    _buildSemanticTabsWidget(data),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderWidget(WordInflectionDetailEntity data) {
    List<String> grammaticalTypeNids = controller.getCurrentGrammaticalTypeNids();
    int linkedCount = controller.getLinkedCount();
    int missingCount = controller.getMissingCount();
    bool showHeaderSummary = !controller.isUserSide;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeaderSummary) ...[
          SizedBox(height: 8.wMin),
          Row(
            children: [
              if (!controller.isUserSide)
                Text(
                  "词族全形态",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextSecondary.color,
                    letterSpacing: 1.2.wMin,
                  ),
                ),
              if (!controller.isUserSide) SizedBox(width: 10.wMin),
              if (!controller.isUserSide && (data.familyKey ?? '').isNotEmpty)
                CopyTagWidget(
                  name: "词族",
                  value: data.familyKey ?? '',
                ),
              Spacer(),
              if (linkedCount > 0) WordInflectionInfoTagWidget("$linkedCount 个义项"),
              if (missingCount > 0) ...[
                SizedBox(height: 6.wMin),
                WordInflectionInfoTagWidget(
                  "缺失 $missingCount 个",
                  textColor: AppTheme.cAmber,
                  bgColor: AppTheme.cAmber.withValues(alpha: 0.12),
                  borderColor: AppTheme.cAmber.withValues(alpha: 0.2),
                ),
              ],
            ],
          ),
        ],
        Wrap(
          spacing: 8.wMin,
          runSpacing: 8.wMin,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              data.lemma ?? '',
              style: TextStyle(
                fontSize: 36.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            WordInflectionInfoTagWidget(
              WordInflectionMeta.getPosLabel(data.pos),
              tone: WordInflectionInfoTagTone.brand,
            ),
            ...grammaticalTypeNids.map((nid) {
              return WordInflectionInfoTagWidget(
                WordInflectionMeta.getGrammaticalTypeLabel(nid),
                tone: WordInflectionInfoTagTone.brand,
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildSemanticSummaryWidget(WordInflectionDetailSemanticEntity semantic) {
    String zhText = _getLanguageText(semantic.translate, 'zh');
    String enText = _getLanguageText(semantic.translate, 'en');
    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.wMin),
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((semantic.imageUrl ?? '').isNotEmpty)
            CachedImageWidget(
              semantic.imageUrl ?? '',
              width: 64.wMin,
              height: 64.wMin,
              borderRadius: BorderRadius.circular(16.wMin),
            ),
          if ((semantic.imageUrl ?? '').isNotEmpty) SizedBox(width: 12.wMin),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (enText.isNotEmpty)
                Text(
                  enText,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
              if (zhText.isNotEmpty)
                Text(
                  zhText,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSemanticTabsWidget(WordInflectionDetailEntity data) {
    List<WordInflectionDetailSemanticEntity> semantics = controller.getSemanticList();
    if (semantics.length <= 1) {
      return const SizedBox.shrink();
    }
    List<_SemanticTabItem> items = [];
    for (int i = 0; i < semantics.length; i++) {
      int semanticId = semantics[i].semanticId ?? -(i + 1);
      String text = _getLanguageText(semantics[i].translate, 'zh');
      if (text.isEmpty) {
        text = "义项 ${semantics[i].semanticId ?? ''}";
      }
      items.add(_SemanticTabItem(
        id: semanticId,
        text: text,
      ));
    }

    return Container(
      margin: EdgeInsets.only(top: 20.wMin),
      child: Align(
        alignment: Alignment.center,
        child: _ManageWordInflectionSemanticTabsBar(
          items: items,
          currentId: controller.selectedSemanticId.value,
          onTapItem: (id) {
            controller.selectSemantic(id);
          },
        ),
      ),
    );
  }

  Widget _buildSlotFooterWidget(WordInflectionDetailSlotEntity slot) {
    if (slot.kind == "linked" && slot.contentId != null) {
      if (controller.isUserSide) {
        return Text(
          "已关联",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary,
          ),
        );
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CopyTagWidget(
            name: slot.contentType == "EN_PHRASE" ? "短语ID" : "词ID",
            value: "${slot.contentId}",
          ),
        ],
      );
    }
    if (slot.kind == "missing") {
      if (controller.isUserSide) {
        return const SizedBox.shrink();
      }
      if (controller.isSlotCreated(slot)) {
        return Text(
          "已创建",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF22C55E),
          ),
        );
      }
      return Text(
        controller.getCreateActionLabel(slot),
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cSurfaceBrand.color,
        ),
      );
    }
    return Text(
      "暂无关联",
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 18.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cTextSecondary.color,
      ),
    );
  }

  Widget _buildChipWidget(String text, {required WordInflectionChipStyle style}) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.wMin),
        color: style.bgColor,
        border: Border.all(
          color: style.borderColor,
          width: 1.wMin,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w500,
          color: style.textColor,
        ),
      ),
    );
  }

  Widget _buildCountTagWidget(
    String text, {
    Color? textColor,
    Color? bgColor,
    Color? borderColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.wMin),
        color: bgColor ?? Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: borderColor ?? AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppTheme.cTextSecondary.color,
        ),
      ),
    );
  }

  WordInflectionDetailSemanticEntity? _getCurrentSemantic(WordInflectionDetailEntity data) {
    List<WordInflectionDetailSemanticEntity> semantics = controller.getSemanticList();
    if (semantics.isEmpty) return null;
    for (int i = 0; i < semantics.length; i++) {
      if (semantics[i].semanticId == controller.selectedSemanticId.value) {
        return semantics[i];
      }
    }
    return semantics.first;
  }

  String _getLanguageText(List<LanguageText?>? values, String lang) {
    if (values == null || values.isEmpty) return '';
    for (int i = 0; i < values.length; i++) {
      if (values[i]?.lang == lang) {
        return values[i]?.text ?? '';
      }
    }
    return '';
  }
}

class _SemanticTabItem {
  final int id;
  final String text;

  const _SemanticTabItem({required this.id, required this.text});
}

class _ManageWordInflectionSemanticTabsBar extends StatefulWidget {
  final List<_SemanticTabItem> items;
  final int? currentId;
  final ValueChanged<int>? onTapItem;

  const _ManageWordInflectionSemanticTabsBar({
    required this.items,
    this.currentId,
    this.onTapItem,
  });

  @override
  State<_ManageWordInflectionSemanticTabsBar> createState() => _ManageWordInflectionSemanticTabsBarState();
}

class _ManageWordInflectionSemanticTabsBarState extends State<_ManageWordInflectionSemanticTabsBar> {
  final Map<int, GlobalKey> _itemKeys = <int, GlobalKey>{};
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentIfNeeded());
  }

  @override
  void didUpdateWidget(covariant _ManageWordInflectionSemanticTabsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_didInitialScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentIfNeeded());
    }
  }

  void _scrollToCurrentIfNeeded() {
    if (_didInitialScroll) return;
    final int? currentId = widget.currentId;
    if (currentId == null) return;
    final GlobalKey? key = _itemKeys[currentId];
    final BuildContext? itemContext = key?.currentContext;
    if (itemContext == null) return;
    _didInitialScroll = true;
    Scrollable.ensureVisible(
      itemContext,
      alignment: 0.5,
      duration: Duration.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99.wMin),
      child: PlatformBackdropFilterWidget(
        sigmaX: 4.wMin,
        sigmaY: 4.wMin,
        child: Container(
          height: 80.wMin,
          padding: EdgeInsets.symmetric(horizontal: 12.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppTheme.cSurfaceSearchBackground.color,
            border: Border.all(
              color: AppTheme.cBorderDark.color,
              width: 1.wMin,
            ),
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildSemanticItemWidgets(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSemanticItemWidgets() {
    final List<Widget> children = <Widget>[];
    for (int index = 0; index < widget.items.length; index++) {
      final _SemanticTabItem item = widget.items[index];
      final bool selected = item.id == widget.currentId;
      _itemKeys.putIfAbsent(item.id, () => GlobalKey());
      children.add(
        KeyedSubtree(
          key: _itemKeys[item.id],
          child: _buildSemanticItemWidget(item, selected),
        ),
      );
      if (index < widget.items.length - 1) {
        children.add(SizedBox(width: 12.wMin));
      }
    }
    return children;
  }

  Widget _buildSemanticItemWidget(_SemanticTabItem item, bool selected) {
    final Color activeColor = AppTheme.cFeedbackSuccessBorder.color;
    final Color textColor = selected ? activeColor : AppTheme.cTextPrimary.color;
    return TapScaleWidget(
      onTap: () => widget.onTapItem?.call(item.id),
      sclae: 1,
      child: Container(
        height: 56.wMin,
        padding: EdgeInsets.only(left: 16.wMin, right: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
            color: selected ? activeColor.withValues(alpha: 0.2) : Colors.transparent,
            width: 0.8.wMin,
          ),
        ),
        child: Center(
          child: Text(
            item.text,
            style: TextStyle(
              color: textColor,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
