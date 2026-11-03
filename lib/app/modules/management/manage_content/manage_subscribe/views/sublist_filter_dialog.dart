import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../common/manage_filter_multiple_selection_widget.dart';

class SubScribeFilterResult {
  List<int>? difficultys;
  int? isLaunch;
  int? isContentChecked;
  int? isAudioChecked;
  int? isImageChecked;
  int? imageLocked;
  int? videChecked;
  SubScribeFilterResult({
    this.difficultys,
    this.isLaunch,
    this.isAudioChecked,
    this.isImageChecked,
    this.isContentChecked,
    this.imageLocked,
    this.videChecked,
  });
}

class SublistFilterDialog {
  static void show({
    required BuildContext context,
    SubScribeFilterResult? initFilterResult,
    void Function(SubScribeFilterResult result)? onSure,
  }) {
    BotToast.showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      verticalOffset: 8.0,
      allowClick: false,
      onlyOne: true,
      attachedBuilder: (cancelFunc) {
        return _SubScribeFilterWidget(
          cancelFunc: cancelFunc,
          initFilterResult: initFilterResult,
          onSure: onSure,
        );
      },
    );
  }
}

class _SubScribeFilterWidget extends StatefulWidget {
  final void Function() cancelFunc;
  final SubScribeFilterResult? initFilterResult;
  final void Function(SubScribeFilterResult result)? onSure;
  const _SubScribeFilterWidget({
    required this.cancelFunc,
    this.onSure,
    this.initFilterResult,
  });

  @override
  State<_SubScribeFilterWidget> createState() => _SubScribeFilterWidgetState();
}

class _SubScribeFilterWidgetState extends State<_SubScribeFilterWidget> with WidgetsBindingObserver {
  int isLaunched = -1;
  int contentChecked = -1;
  int audioChecked = -1;
  int imageLocked = -1;
  int videChecked = -1;

  int imageChecked = -1;
  List<int> difficultyIndexs = [];
  List<String> launchList = ["上架", "下架"];
  List<String> difficultyList = ["Pre A1", "A1", "A2", "B1", "B2", "C1", "C2"];

  @override
  void initState() {
    super.initState();
    isLaunched = widget.initFilterResult?.isLaunch ?? -1;
    difficultyIndexs = widget.initFilterResult?.difficultys ?? [];
    contentChecked = widget.initFilterResult?.isContentChecked ?? -1;
    audioChecked = widget.initFilterResult?.isAudioChecked ?? -1;
    imageChecked = widget.initFilterResult?.isImageChecked ?? -1;
    imageLocked = widget.initFilterResult?.imageLocked ?? -1;
    videChecked = widget.initFilterResult?.videChecked ?? -1;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      widget.cancelFunc();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void resetAll() {
    isLaunched = -1;
    contentChecked = -1;
    audioChecked = -1;
    imageChecked = -1;
    imageLocked = -1;
    videChecked = -1;
    difficultyIndexs.clear();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget buildTitle(String text) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 18.wMin,
          color: const Color(0xffEBEEF3),
          fontWeight: FontWeight.w400,
        ),
      );
    }

    Widget buildLanguage() {
      return SizedBox(
          width: double.infinity,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            buildTitle('难度'),
            SizedBox(height: 10.wh),
            Container(
                constraints: BoxConstraints(
                  maxHeight: 250.wh,
                ),
                child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Wrap(
                        spacing: 8.ww,
                        runSpacing: 8.wh,
                        children: List.generate(difficultyList.length, (index) {
                          return TapScaleWidget(
                              onTap: () {
                                if (difficultyIndexs.contains(index)) {
                                  difficultyIndexs.remove(index);
                                } else {
                                  difficultyIndexs.add(index);
                                }
                                if (mounted) setState(() {});
                              },
                              sclae: 1,
                              child: Container(
                                  width: 116.ww,
                                  height: 36.wh,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.wMin),
                                    color: difficultyIndexs.contains(index) ? const Color(0xff2388FF).withValues(alpha: 0.1) : const Color(0xff41465A),
                                    border: Border.all(
                                      width: 1.wMin,
                                      color: difficultyIndexs.contains(index) ? const Color(0xff2388FF).withValues(alpha: 0.5) : Colors.transparent,
                                    ),
                                  ),
                                  child: Text(difficultyList[index],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18.wMin,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                      ))));
                        }))))
          ]));
    }

    Widget buildListingStatus() {
      return ManageFilterMultipleSelectionWidget(
        title: "上架状态",
        datas: [
          StaticDataEntity(name: "上架", value: "0"),
          StaticDataEntity(name: "下架", value: "1"),
        ],
        selecteds: [isLaunched],
        onTapIndex: (index) {
          if (isLaunched == index) {
            isLaunched = -1;
          } else {
            isLaunched = index;
          }
          if (mounted) setState(() {});
        },
      );
    }

    Widget buildContentChecked() {
      return ManageFilterMultipleSelectionWidget(
        title: "文章审核状态",
        datas: [
          StaticDataEntity(name: "待审核", value: "0"),
          StaticDataEntity(name: "已审核", value: "1"),
        ],
        selecteds: [contentChecked],
        onTapIndex: (index) {
          if (contentChecked == index) {
            contentChecked = -1;
          } else {
            contentChecked = index;
            audioChecked = -1;
          }
          if (mounted) setState(() {});
        },
      );
    }

    Widget buildAudioChecked() {
      return ManageFilterMultipleSelectionWidget(
        title: "音频审核状态",
        datas: [
          StaticDataEntity(name: "待审核", value: "0"),
          StaticDataEntity(name: "已审核", value: "1"),
        ],
        selecteds: [audioChecked],
        onTapIndex: (index) {
          if (audioChecked == index) {
            audioChecked = -1;
          } else {
            audioChecked = index;
            contentChecked = -1;
          }
          if (mounted) setState(() {});
        },
      );
    }

    Widget buildImageLoackedChecked() {
      return ManageFilterMultipleSelectionWidget(
        title: "图片定稿状态",
        datas: [
          StaticDataEntity(name: "未定稿", value: "0"),
          StaticDataEntity(name: "已定稿", value: "1"),
        ],
        selecteds: [imageLocked],
        onTapIndex: (index) {
          if (imageLocked == index) {
            imageLocked = -1;
          } else {
            imageLocked = index;
          }
          if (mounted) setState(() {});
        },
      );
    }

    Widget buildVideoChecked() {
      return ManageFilterMultipleSelectionWidget(
        title: "视频审核",
        datas: [
          StaticDataEntity(name: "已审核", value: "0"),
          StaticDataEntity(name: "未审核", value: "1"),
        ],
        selecteds: [videChecked],
        onTapIndex: (index) {
          if (videChecked == index) {
            videChecked = -1;
          } else {
            videChecked = index;
          }
          if (mounted) setState(() {});
        },
      );
    }


    return Container(
      width: 396.ww,
      padding: EdgeInsets.symmetric(horizontal: 16.ww, vertical: 16.wh),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color(0xff2B2F3C).withValues(alpha: 0.95),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildListingStatus(),
          SizedBox(height: 22.wh),
          buildLanguage(),
          SizedBox(height: 22.wh),
          buildContentChecked(),
          SizedBox(height: 22.wh),
          buildAudioChecked(),
          SizedBox(height: 22.wh),
          buildImageLoackedChecked(),
          SizedBox(height: 22.wh),
          buildVideoChecked(),
          SizedBox(height: 32.wh),
          Row(
            children: [
              Expanded(
                child: TapScaleWidget(
                  onTap: resetAll,
                  sclae: 1.05,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8.wh),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.wMin),
                      border: Border.all(width: 1.wMin, color: const Color(0xff4B5268)),
                      color: const Color(0xff23283D),
                    ),
                    child: Text(
                      "重置",
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: const Color(0xffE3E7ED),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.ww),
              Expanded(
                child: TapScaleWidget(
                  onTap: () {
                    widget.onSure?.call(SubScribeFilterResult(
                      isLaunch: isLaunched,
                      difficultys: difficultyIndexs,
                      isContentChecked: contentChecked,
                      isAudioChecked: audioChecked,
                      isImageChecked: imageChecked,
                      imageLocked: imageLocked,
                      videChecked: videChecked,
                    ));
                    widget.cancelFunc();
                  },
                  sclae: 1.05,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8.wh),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.wMin),
                      color: const Color(0xff0679FF),
                    ),
                    child: Text(
                      "确定",
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: const Color(0xffE3E7ED),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
