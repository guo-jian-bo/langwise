import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../entities/entities.dart';
import '../https/https.dart';

/// 选择课时模版
class SelectLessonTemplateDialog {
  static Future<ManageLessonTemplateEntityDatas?> show(
      {required BuildContext context, int? difficultyLevel, String? language}) async {
    return await showCupertinoDialog<ManageLessonTemplateEntityDatas?>(
      context: context,
      builder: (context) {
        return SelectLessonTemplateDialogWidget(
          difficultyLevel: difficultyLevel,
          language: language,
        );
      },
    );
  }
}

class SelectLessonTemplateDialogWidget extends StatefulWidget {
  final int? difficultyLevel;
  final String? language;

  const SelectLessonTemplateDialogWidget(
      {super.key, this.difficultyLevel, this.language});

  @override
  State<SelectLessonTemplateDialogWidget> createState() => _SelectLessonTemplateDialogWidgetState();
}

class _SelectLessonTemplateDialogWidgetState extends State<SelectLessonTemplateDialogWidget> {
  final ScrollController scrollController = ScrollController();

  bool loadFlag = true;
  int offset = 0;
  int limit = 30;
  int dataCount = 0;
  List<ManageLessonTemplateEntityDatas> templateList = [];

  int selectIndex = -1;

  int? _difficulty;

  String? _language;

  // 搜索
  String? title;

  List<String> uids = [];

  @override
  void initState() {
    super.initState();
    _difficulty = widget.difficultyLevel;
    _language = widget.language;
    getLessonTemplateList();
    initKnowledgeScroll();
  }

  void initKnowledgeScroll() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100 &&
          !scrollController.position.outOfRange) {
        if (templateList.length < dataCount && loadFlag) {
          loadFlag = false;
          offset += 30;
          getLessonTemplateList();
        }
      }
    });
  }

  Future<void> getLessonTemplateList() async {
    ManageLessonTemplateEntity? template = await ManageLessonTemplateRequest.getLessonTemplateData({
      "language": _language,
      "uid": uids.isEmpty ? null : uids,
      "name": (title?.isEmpty ?? true) ? null : title
    }, {
      "offset": offset,
      "limit": limit,
      "difficulty": _difficulty,
    });
    if (template == null) {
      loadFlag = true;
      return;
    }
    dataCount = template.count ?? 0;
    List<ManageLessonTemplateEntityDatas?> datas = template.datas ?? [];
    for (var element in datas) {
      if (element != null) templateList.add(element);
    }
    loadFlag = true;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildListItemWidget(int index, ManageLessonTemplateEntityDatas data) {
      return TapScaleWidget(
        onTap: () {
          selectIndex = index;
          if (mounted) setState(() {});
        },
        sclae: 1.02,
        child: Container(
          padding: EdgeInsets.all(10.wMin),
          decoration: BoxDecoration(
            color: const Color(0xff353E5C).withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8.wMin),
            border: Border.all(
              width: 1.wMin,
              color: selectIndex == index ? const Color(0xff2388FF) : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6.wMin,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data.name ?? "",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: const Color.fromARGB(255, 170, 170, 170),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SvgPicture.asset(
                    selectIndex == index
                        ? "assets/svg/manage/icon_radio.svg"
                        : "assets/svg/manage/icon_unradio.svg",
                    width: 18.wMin,
                    height: 18.wMin,
                  ),
                ],
              ),
              Row(
                children: [
                  StatusTagDirectionWidget(direction: data.direction),
                  SizedBox(width: 12.wMin),
                  StatusTagDifficultyWidget(
                    difficulty: data.minDifficulty,
                    language: data.language,
                  ),
                  SizedBox(width: 5.wMin),
                  Text(
                    "-",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: const Color(0xff697179),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 5.wMin),
                  StatusTagDifficultyWidget(
                    difficulty: data.maxDifficulty,
                    language: data.language,
                  ),
                ],
              ),
              Expanded(
                child: AutoSizeText(
                  data.description ?? "",
                  minFontSize: 6,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: const Color(0xff767E95),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DialogBoxWidget(
      width: 1080.wMin,
      title: "选择课时模板",
      onCancel: () => Get.back(),
      define: "下一步",
      onDefine: () {
        if (selectIndex == -1) {
          ToastUtils.showToast(text: "请选择课时模版");
          return;
        }
        ManageLessonTemplateEntityDatas data = templateList[selectIndex];
        if (data.exerciseConfigs == null) {
          ToastUtils.showToast(text: "请先添加题目模版");
          return;
        }
        Get.back(result: data);
      },
      child: SizedBox(
        height: 688.wMin,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                itemCount: templateList.length,
                padding: EdgeInsets.all(24.wMin),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 18.wMin,
                  crossAxisSpacing: 18.wMin,
                  childAspectRatio: 332 / 160,
                ),
                itemBuilder: (context, index) {
                  return buildListItemWidget(index, templateList[index]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gaps.getWidth(24.wMin),
        SearchWidget(
          width: 160.ww,
          height: 42.wh,
          hintText: 'uid',
          onChanged: (String value) {
            onSetId(value);
          },
          onSubmitted: (String value) {
            onSetId(value, isSubmit: true);
          },
        ),
        Gaps.getWidth(12.ww),
        SearchWidget(
          width: 160.ww,
          height: 42.wh,
          hintText: '名称',
          onChanged: (String value) {
            onSetName(value);
          },
          onSubmitted: (String value) {
            onSetName(value, isSubmit: true);
          },
        ),
      ],
    );
  }

  // uid
  void onSetId(String uid, {bool isSubmit = false}) {
    // 单词/短语
    if (uid.trim().isEmpty) {
      uids = [];
    } else {
      if (uid.trim().contains(',')) {
        final List<String> s = uid.trim().split(',');
        uids = s;
      } else if (uid.trim().contains(' ')) {
        final List<String> s = uid.trim().split(' ');
        uids = s;
      } else {
        uids = [uid];
      }
    }

    if (isSubmit) {
      templateList.clear();
      getLessonTemplateList();
    }
  }

  // 名称
  void onSetName(String name, {bool isSubmit = false}) {
    // 单词/短语
    title = name;
    if (isSubmit) {
      templateList.clear();
      getLessonTemplateList();
    }
  }
}
