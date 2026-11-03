import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../common/manage_scaffold.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_core_knowledge_binding.dart';
import '../controllers/manage_core_knowledge_controller.dart';

class ManageCoreKnowledgeView extends GetView<ManageCoreKnowledgeController> {
  final String tagText;
  const ManageCoreKnowledgeView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CORE_KNOWLEDGE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageCoreKnowledgeView(tagText: tag),
      binding: ManageCoreKnowledgeBinding(tag: tag),
      routeName: Routes.MANAGE_CORE_KNOWLEDGE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: GetBuilder(
        init: controller,
        tag: tagText,
        builder: (_) {
          return Padding(
            padding: EdgeInsets.all(15.wMin),
            child: Column(
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '核心知识点管理',
                          style: TextStyle(fontSize: 24.wMin, color: Colors.white),
                        ),
                        SizedBox(height: 4.wMin),
                        SelectableText(
                          '${controller.knowledgeData.value.title ?? ''}  UID: ${controller.knowledgeData.value.uid}',
                          style: TextStyle(fontSize: 18.wMin, color: Colors.white),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ManageAuthBoxWidget(
                      authCodes: const [ManageAuthCode.enContentKnowledgeOperation],
                      child: ManageButton(
                        text: "添加知识点",
                        width: 130.wMin,
                        height: 50.wMin,
                        color: const Color(0xFF2388FF),
                        borderColor: Colors.transparent,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                        onTap: () {
                          controller.addKnowledge(context);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.wMin),
                _buildStatisticWidget(),
                SizedBox(height: 20.wMin),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF23253A),
                            borderRadius: BorderRadius.circular(12.wMin),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: _buildContentWidget(),
                        ),
                      ),
                      SizedBox(
                        width: 15.wMin,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF23253A),
                            borderRadius: BorderRadius.circular(12.wMin),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: _buildKnowledgeListWidget(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKnowledgeListWidget() {
    List<ManageEnglishContentManagementSongKnowledgeModel> knowledgeList = [];
    if (controller.currentSelectOption.value == "全部") {
      knowledgeList = controller.allList;
    } else if (controller.currentSelectOption.value == "单词") {
      knowledgeList = controller.wordList;
    } else if (controller.currentSelectOption.value == "短语") {
      knowledgeList = controller.phraseList;
    } else if (controller.currentSelectOption.value == "句子") {
      knowledgeList = controller.sentenceList;
    }

    List<String> titleList = ['全部'];
    if (controller.wordList.isNotEmpty) {
      titleList.add("单词");
    }
    if (controller.phraseList.isNotEmpty) {
      titleList.add("短语");
    }
    if (controller.sentenceList.isNotEmpty) {
      titleList.add("句子");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(20.wMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('知识点列表', style: TextStyle(fontSize: 20.wMin, color: Colors.white)),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        "显示未匹配",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: const Color(0xffACB4C0),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: controller.hasUnmatched,
                          onChanged: (value) {
                            controller.hasUnmatched = value;
                            controller.update();
                          },
                          activeColor: const Color(0xff2388FF),
                          inactiveThumbColor: const Color(0xff353E5C),
                          inactiveTrackColor: const Color(0xff22293C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15.wMin),
              Row(
                children: [
                  ...titleList.map((e) {
                    return Padding(
                      padding: EdgeInsets.only(right: 15.wMin),
                      child: ManageButton(
                        text: e,
                        width: 80.wMin,
                        height: 40.wMin,
                        color: controller.currentSelectOption.value == e ? const Color(0xFF2388FF) : const Color(0xFF353E5C),
                        borderColor: Colors.transparent,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: controller.currentSelectOption.value == e ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                        onTap: () {
                          controller.currentSelectOption.value = e;
                          controller.update();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          height: 1.wMin,
          color: Colors.white10,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.wMin),
              child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      ...knowledgeList.map((e) {
                        bool isOk;
                        if (controller.hasUnmatched) {
                          isOk = true;
                        } else {
                          if (e.matchSign == -1) {
                            isOk = false;
                          } else {
                            isOk = true;
                          }
                        }
                        int index = knowledgeList.indexOf(e);
                        return Visibility(visible: isOk, child: _buildKnowledgeItemWidget(index, e));
                      }),
                    ],
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKnowledgeItemWidget(int index, ManageEnglishContentManagementSongKnowledgeModel knowledge) {
    String typeStr = "";
    Color fontColor = const Color(0xff63DE77);
    if (knowledge.contentType == "EN_WORD") {
      typeStr = "单词";
      fontColor = const Color(0xff2388FF);
    } else if (knowledge.contentType == "EN_PHRASE") {
      typeStr = "短语";
      fontColor = const Color(0xff6D39E4);
    } else if (knowledge.contentType == "EN_SENTENCE") {
      typeStr = "句子";
      fontColor = const Color(0xff63DE77);
    }

    String svg = "";
    Color backColor = const Color(0xF22B2F3C);
    if (knowledge.matchSign == 0) {
      backColor = const Color.fromRGBO(23, 201, 100, 0.12);
      svg = "assets/svg/manage/icon_exact_match.svg";
    } else if (knowledge.matchSign == 1) {
      backColor = const Color.fromRGBO(255, 120, 31, 0.12);
      svg = "assets/svg/manage/icon_partial_match.svg";
    } else if (knowledge.matchSign == -1) {
      backColor = const Color.fromRGBO(255, 45, 70, 0.12);
      svg = "assets/svg/manage/icon_no_match.svg";
    }

    return GestureDetector(
      onTap: () {
        if (controller.selectedIndex == index) {
          controller.selectedIndex = null;
        } else {
          controller.selectedIndex = index;
        }
        controller.update();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.wMin),
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          color: controller.selectedIndex == index ? backColor : const Color(0xF22B2F3C),
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 90.wMin,
              height: 90.wMin,
              child: CachedImageWidget(
                knowledge.imageUrl ?? "",
                fit: BoxFit.fill,
                borderRadius: BorderRadius.circular(6.wMin),
                errorWidget: buildEmptyWidget(),
                placeholder: buildEmptyWidget(),
              ),
            ),
            SizedBox(width: 10.wMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.wMin),
                        padding: EdgeInsets.only(left: 8.wMin, right: 8.wMin, top: 4.wMin, bottom: 2.wMin),
                        decoration: BoxDecoration(
                          color: fontColor,
                          borderRadius: BorderRadius.circular(4.wMin),
                        ),
                        child: Text(typeStr, style: TextStyle(fontSize: 14.wMin, color: Colors.white)),
                      ),
                      SvgPicture.asset(
                        svg,
                        width: 18.wMin,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.wMin),
                  Text(knowledge.content ?? '', style: TextStyle(fontSize: 18.wMin, color: Colors.white)),
                  SizedBox(height: 8.wMin),
                  Text(knowledge.definition ?? '', style: TextStyle(fontSize: 16.wMin, color: Colors.white)),
                ],
              ),
            ),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.enContentKnowledgeOperation],
              child: IconButton(
                  onPressed: () {
                    controller.deleteKnowledge(knowledge);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentWidget() {
    String title = "";
    if (controller.type == "EN_PHRASE") {
      title = "短语内容";
    } else if (controller.type == "EN_SENTENCE") {
      title = "句子内容";
    } else if (controller.type == "EN_TEXT") {
      title = "文章内容";
    } else if (controller.type == "EN_SONG") {
      title = "歌曲内容";
    }

    List<ManageEnglishContentManagementSongKnowledgeModel> knowledgeList = [];
    if (controller.currentSelectOption.value == "全部") {
      knowledgeList = controller.allList;
    } else if (controller.currentSelectOption.value == "单词") {
      knowledgeList = controller.wordList;
    } else if (controller.currentSelectOption.value == "短语") {
      knowledgeList = controller.phraseList;
    } else if (controller.currentSelectOption.value == "句子") {
      knowledgeList = controller.sentenceList;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(20.wMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 20.wMin, color: Colors.white)),
              SizedBox(height: 10.wMin),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 8.wMin),
                    padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(23, 201, 100, 0.12),
                      borderRadius: BorderRadius.circular(4.wMin),
                    ),
                    child: Text('完全匹配', style: TextStyle(fontSize: 16.wMin, color: const Color(0xff63DE77))),
                  ),
                  SizedBox(width: 8.wMin),
                  Container(
                    margin: EdgeInsets.only(right: 8.wMin),
                    padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 120, 31, 0.12),
                      borderRadius: BorderRadius.circular(4.wMin),
                    ),
                    child: Text('部分匹配', style: TextStyle(fontSize: 16.wMin, color: const Color(0xffFF781F))),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          height: 1.wMin,
          color: Colors.white10,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.wMin),
              child: SizedBox(
                width: double.infinity,
                child: SelectableText.rich(
                  TextSpan(
                      style: const TextStyle(
                        height: 2,
                      ),
                      children: buildSpans(controller.knowledgeData.value.content ?? '', knowledgeList)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<InlineSpan> buildSpans(String text, List<ManageEnglishContentManagementSongKnowledgeModel> rules) {
    final lower = text.toLowerCase();

    List<_MatchRange> matches = [];

    for (int ruleIndex = 0; ruleIndex < rules.length; ruleIndex++) {
      final rule = rules[ruleIndex];
      if (rule.matchSign == -1) {
        continue;
      }
      final keyLower = rule.content?.toLowerCase() ?? '';
      int start = 0;

      while (true) {
        final index = lower.indexOf(keyLower, start);
        if (index == -1) break;

        final end = index + keyLower.length;

        int wordStart = index;
        while (wordStart > 0 && _isWordChar(text[wordStart - 1])) {
          wordStart--;
        }
        int wordEnd = end;
        while (wordEnd < text.length && _isWordChar(text[wordEnd])) {
          wordEnd++;
        }

        final word = text.substring(wordStart, wordEnd).toLowerCase();

        if (rule.matchSign == 0) {
          final original = word;
          if (original == keyLower) {
            matches.add(_MatchRange(wordStart, wordEnd, const Color(0xff63DE77), ruleIndex));
          }
        } else if (rule.matchSign == 1) {
          final original = word;
          if (original.contains(keyLower) && original != keyLower) {
            matches.add(_MatchRange(wordStart, wordEnd, const Color(0xffFF781F), ruleIndex));
          }
        }

        start = index + 1;
      }
    }

    matches.sort((a, b) => a.start.compareTo(b.start));

    List<_MatchRange> merged = [];
    for (var m in matches) {
      if (merged.isEmpty || m.start > merged.last.end) {
        merged.add(m);
      } else {
        merged.last = merged.last.merge(m);
      }
    }

    List<InlineSpan> spans = [];
    int index = 0;

    for (var m in merged) {
      if (index < m.start) {
        spans.add(normal(text.substring(index, m.start)));
      }

      final bool isSelectedRule = controller.selectedIndex != null && m.ruleIndex == controller.selectedIndex;

      spans.add(highlight(
        text.substring(m.start, m.end),
        m.color,
        isSelectedRule,
      ));
      index = m.end;
    }

    if (index < text.length) {
      spans.add(normal(text.substring(index)));
    }

    return spans;
  }

  bool _isWordChar(String ch) {
    return RegExp(r'[A-Za-z0-9]').hasMatch(ch);
  }

  InlineSpan normal(String t) => TextSpan(
        text: t,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      );

  InlineSpan highlight(String t, Color color, bool isSelectedRule) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: isSelectedRule ? Border.all(color: Colors.blue[500]!, width: 3) : Border.all(color: Colors.transparent, width: 3),
            borderRadius: BorderRadius.circular(2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
          child: Text(
            t,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticWidget() {
    return Row(
      children: [
        _buildStatisticCard('总计', controller.allList),
        Visibility(visible: controller.wordList.isNotEmpty, child: _buildStatisticCard('单词', controller.wordList)),
        Visibility(visible: controller.phraseList.isNotEmpty, child: _buildStatisticCard('短语', controller.phraseList)),
        Visibility(visible: controller.sentenceList.isNotEmpty, child: _buildStatisticCard('句子', controller.sentenceList)),
      ],
    );
  }

  Widget _buildStatisticCard(String title, List<ManageEnglishContentManagementSongKnowledgeModel> list) {
    int exactMatchCount = 0;
    int partialMatchCount = 0;
    int noMatchCount = 0;
    for (var element in list) {
      if (element.matchSign == 0) {
        exactMatchCount++;
      }
      if (element.matchSign == 1) {
        partialMatchCount++;
      }
      if (element.matchSign == -1) {
        noMatchCount++;
      }
    }

    return Container(
      width: 380.wMin,
      margin: EdgeInsets.only(right: 20.wMin),
      padding: EdgeInsets.all(15.wMin),
      decoration: BoxDecoration(
        color: const Color(0xFF23253A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16.wMin, color: Colors.white)),
          SizedBox(height: 6.wMin),
          Text(list.length.toString(), style: TextStyle(fontSize: 30.wMin, color: Colors.white)),
          SizedBox(height: 6.wMin),
          Row(
            children: [
              _buildMatchWidget('完全匹配', exactMatchCount),
              _buildMatchWidget('部分匹配', partialMatchCount),
              _buildMatchWidget('未匹配', noMatchCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchWidget(String type, int number) {
    Color backColor = const Color.fromRGBO(23, 201, 100, 0.12);
    Color fontColor = const Color(0xff63DE77);
    String svg = "";
    if (type == '完全匹配') {
      backColor = const Color.fromRGBO(23, 201, 100, 0.12);
      fontColor = const Color(0xff63DE77);
      svg = "assets/svg/manage/icon_exact_match.svg";
    } else if (type == '部分匹配') {
      backColor = const Color.fromRGBO(255, 120, 31, 0.12);
      fontColor = const Color(0xffFF781F);
      svg = "assets/svg/manage/icon_partial_match.svg";
    } else if (type == '未匹配') {
      backColor = const Color.fromRGBO(255, 45, 70, 0.12);
      fontColor = const Color(0xffFF2D46);
      svg = "assets/svg/manage/icon_no_match.svg";
    }

    return Container(
      margin: EdgeInsets.only(right: 8.wMin),
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        color: backColor,
        borderRadius: BorderRadius.circular(4.wMin),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            svg,
            width: 18.wMin,
          ),
          SizedBox(width: 4.wMin),
          Text(type, style: TextStyle(fontSize: 14.wMin, color: fontColor)),
          SizedBox(width: 4.wMin),
          Text(number.toString(), style: TextStyle(fontSize: 18.wMin, color: fontColor)),
        ],
      ),
    );
  }
}

class MatchRule {
  final String key;
  final int matchType; // 0 = 完全匹配；1 = 部分匹配；-1 = 完全不匹配
  const MatchRule(this.key, {required this.matchType});
}

// 区间 model
class _MatchRange {
  final int start;
  final int end;
  final Color color;
  final int ruleIndex;

  _MatchRange(this.start, this.end, this.color, this.ruleIndex);

  _MatchRange merge(_MatchRange other) => _MatchRange(start, end > other.end ? end : other.end, color, ruleIndex);
}
