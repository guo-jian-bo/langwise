import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../bindings/subscribe_create_binding.dart';
import '../controllers/subscribe_create_controller.dart';

class SubscribeCreateView extends GetView<SubscribeCreateController> {
  final String tagText;
  const SubscribeCreateView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SUBSCRIBE_CREATE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      SubscribeCreateView(tagText: tag),
      binding: SubscribeCreateBinding(tag: tag),
      routeName: Routes.MANAGE_SUBSCRIBE_CREATE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (_) {
        return ManageScaffold(
          backgroundColor: const Color(0xFF050916),
          body: Container(
            padding: EdgeInsets.all(16.wMin),
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  '${controller.themeZh??""}-创建内容',
                  style: TextStyle(fontSize: 22.wMin, color: const Color(0xFFEBEEF3)),
                ),
                SizedBox(height: 4.wMin),
                Text(
                  '${controller.themeEn}',
                  style: TextStyle(fontSize: 20.wMin, color: const Color(0xFFBAC0CC)),
                ),
                SizedBox(height: 8.wMin),
                Text(
                  '${controller.description??""}',
                  style: TextStyle(fontSize: 14.wMin, color: const Color(0xFFBAC0CC)),
                ),
                SizedBox(height: 24.wMin),
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.wMin), color: const Color(0xFF181B25)),
                  padding: EdgeInsets.all(16.wMin),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      '参考网站（点击访问或复制链接）',
                      style: TextStyle(fontSize: 20.wMin, color: const Color(0xFFEBEEF3)),
                    ),
                    SizedBox(height: 12.wMin),
                    Wrap(
                        spacing: 12.wMin,
                        runSpacing: 12.wMin,
                        children: List.generate(controller.links?.length ?? 0, (index) {
                          var link = controller.links?[index]?.url;
                          return Container(
                            width: 768.wMin,
                            height: 44.wMin,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.wMin),
                                border: Border.all(color: const Color(0xFF2388FF).withOpacity(.4)),
                                color: const Color(0xFF2388FF).withOpacity(0.05)),
                            padding: EdgeInsets.symmetric(vertical: 8.wMin, horizontal: 24.wMin),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () async {
                                    await launchUrl(Uri.parse(link!), mode: LaunchMode.externalApplication);
                                  },
                                  child: SizedBox(
                                    width: 680.wMin,
                                    child: Text(
                                      '$link',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 18.wMin, decoration: TextDecoration.underline, decorationColor: const Color(0xFF2388FF), color: const Color(0xFF2388FF)),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: '$link')).then((_) {
                                      ToastUtils.showToast(text: '复制成功', type: ToastType.success);
                                    });
                                  },
                                  child: SvgPicture.asset('assets/svg/elements/icon_link_copy.svg', width: 24.wMin, height: 24.wMin)),
                            ]),
                          );
                        }).toList()),
                    SizedBox(height: 12.wMin),
                    Text(
                      '提示：可以从这些网站获取素材灵感，然后粘贴到下方的原文内容框中',
                      style: TextStyle(fontSize: 14.wMin, color: const Color(0xFFBAC0CC)),
                    ),
                    SizedBox(height: 28.wMin),
                    _title('原文'),
                    SizedBox(height: 8.wMin),
                    DraggableTextField(
                      controller: controller.contentCtrl,
                    ),
                    SizedBox(height: 8.wMin),
                    _title('原文链接'),
                    SizedBox(height: 2.wMin),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.wMin),
                          border: Border.all(
                            color: const Color(0xFF4B5268),
                          )),
                      child: TextField(
                        controller: controller.linkCtrl,
                        style: TextStyle(fontSize: 16.wMin, color: Colors.white),
                        decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: '请输入原文链接',
                            hintStyle: TextStyle(fontSize: 16.wMin, color: Colors.white38)),
                      ),
                    )
                  ]),
                ),
                SizedBox(height: 24.wMin),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.wMin), color: const Color(0xFF181B25)),
                  padding: EdgeInsets.all(16.wMin),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _title('选择题目难度级别'),
                    SizedBox(height: 8.wMin),
                    Text(
                      '选择要生成的文章难度级别（可多选）',
                      style: TextStyle(fontSize: 18.wMin, color: Colors.white),
                    ),
                    SizedBox(height: 8.wMin),
                    MultiRadioList(
                      levels: const ['Pre A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'],
                      controller: controller,
                    ),
                  ]),
                ),
                SizedBox(height: 24.wMin),
                Obx(() => _buildKnowledgeWidget(context)),
                SizedBox(height: 24.wMin),
                Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        controller.generalArticle();
                      },
                      child: Container(
                        width: 120.wMin,
                        height: 40.wMin,
                        margin: EdgeInsets.only(right: 16.wMin),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8.wMin),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: const Color(0xFF2388FF)),
                        child: Text('生成文章', style: TextStyle(fontSize: 14.wMin, color: Colors.white)),
                      ),
                    )),
                SizedBox(height: 56.wMin)
              ]),
            ),
          ),
        );
      },
    );
  }

  // 关联知识点
  Widget _buildKnowledgeWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 245,
      alignment: Alignment.centerLeft,
      child: GridView.builder(
        key: const PageStorageKey<String>('subscribe_knowledge'),
        itemCount: controller.relevanceKnowledgeList.length + 1,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 12.wMin,
          crossAxisSpacing: 0,
          childAspectRatio: 245 / 180,
        ),
        itemBuilder: (BuildContext c, int index) {
          if (index == 0) {
            return GestureDetector(
              onTap: () {
                controller.toRelevanceKnowledge(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  border: Border.all(color: const Color(0xFF2388FF).withOpacity(.4)),
                  color: const Color(0xFF2388FF).withOpacity(0.05),
                ),
                padding: EdgeInsets.all(16.wMin),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: const Color(0xFF2388FF), size: 32.wMin),
                    SizedBox(height: 8.wMin),
                    Text(
                      '添加知识点',
                      style: TextStyle(fontSize: 16.wMin, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }
          final Knowledge knowledge = controller.relevanceKnowledgeList[index - 1];
          return KnowledgeItemWidget(
            key: PageStorageKey(knowledge.uid),
            index: index - 1,
            knowledge: knowledge,
            showDelIcon: true,
            onTap: (int i, Knowledge k) {
              if (k.audioUrl != null && k.audioUrl!.isNotEmpty) {
                PlayAudioUtils.instance.playSingle(k.audioUrl!);
              }
            },
            onDeleteTap: (int i, Knowledge k) {
              controller.removeRelevanceKnowledge(i);
            },
          );
        },
      ),
    );
  }

  Widget _title(String titleTxt) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w400,
        ),
        children: [
          const TextSpan(
            text: '*',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          TextSpan(text: titleTxt, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class MultiRadioList extends StatefulWidget {
  final List<String> levels;
  final SubscribeCreateController controller;
  const MultiRadioList({super.key, required this.levels, required this.controller});

  @override
  State<MultiRadioList> createState() => _MultiRadioListState();
}

class _MultiRadioListState extends State<MultiRadioList> {
  List<String> _levels = [
    '入门',
    '初级',
    '中级',
    '高级',
    '专家',
  ];
  final Set<int> _selectedIndexes = {0, 1, 2, 3, 4};

  @override
  void initState() {
    super.initState();
    _levels = widget.levels;
    widget.controller.targetCefrLevels.value = _selectedIndexes.map((i) => _levels[i]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_levels.length, (index) {
          final bool selected = _selectedIndexes.contains(index);
          return InkWell(
            onTap: () {
              setState(() {
                if (selected) {
                  _selectedIndexes.remove(index);
                } else {
                  _selectedIndexes.add(index);
                }
                widget.controller.targetCefrLevels.value = _selectedIndexes.map((i) => _levels[i]).toList();
              });
            },
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.wMin), color: const Color(0x353E5C59)),
              margin: EdgeInsets.only(right: 24.wMin),
              padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 6.wMin),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _levels[index],
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 24.wMin),
                  Container(
                      width: 20.wMin,
                      height: 20.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: selected ? const Color(0xFF2388FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(4.wMin),
                          border: selected ? null : Border.all(color: const Color(0xFF616B85))),
                      child: selected ? SvgPicture.asset('assets/svg/manage/icon_check.svg') : null),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
