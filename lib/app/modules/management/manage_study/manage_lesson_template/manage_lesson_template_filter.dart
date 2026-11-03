import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import 'package:langwise/app/modules/management/common/manage_filter_multiple_selection_widget.dart';

class ManageLessonTemplateFilterResult{
  List<StaticDataEntity>? launguageList;
  List<int>? languageIndexs;
  StaticDataEntity? offShelf;
  int? offShelfIndex;
  List<StaticDataEntity>? assessmentDirectionList;
  List<int>? assessmentDirectionIndexs;
  /// 课时类型数据
  List<LessonTypeEnum>? lessonTypes;

  ManageLessonTemplateFilterResult({
    this.launguageList,
    this.languageIndexs,
    this.offShelf,
    this.offShelfIndex,
    this.assessmentDirectionList,
    this.assessmentDirectionIndexs,
    this.lessonTypes,
  });
}

class ManageLessonTemplateFilter {
  static void show({
    required BuildContext context,
    ManageLessonTemplateFilterResult? initFilterResult,
    void Function(ManageLessonTemplateFilterResult result)? onSure,
  }) {
    BotToast.showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      verticalOffset: 8.0,
      allowClick: false,
      onlyOne: true,
      attachedBuilder: (cancelFunc) {
        return _ManageLessonTemplateWidget(
          cancelFunc: cancelFunc,
          initFilterResult: initFilterResult,
          onSure: onSure,
        );
      },
    );
  }
}

class _ManageLessonTemplateWidget extends StatefulWidget {
  final void Function() cancelFunc;
  final ManageLessonTemplateFilterResult? initFilterResult;
  final void Function(ManageLessonTemplateFilterResult result)? onSure;
  const _ManageLessonTemplateWidget({
    required this.cancelFunc, 
    this.onSure, 
    this.initFilterResult,
    });

  @override
  State<_ManageLessonTemplateWidget> createState() => __ManageLessonTemplateWidgetState();
}

class __ManageLessonTemplateWidgetState extends State<_ManageLessonTemplateWidget> with WidgetsBindingObserver {
  List<StaticDataEntity> showLaunguageList = [];
  List<int> selectLanguageIndex = [];
  bool openLanguage = true;

  int selectListingStatusIndex = -1;

  List<int> assessmentDirectionIndexs = [];

  List<int> lessonTypesIndexs = [];


  @override
  void initState() {
    super.initState();
    openCloseLaunage();
    WidgetsBinding.instance.addObserver(this);
    widget.initFilterResult?.launguageList?.forEach((element) {
      int? index = StaticData.getLanguageIndex(element.value);
      if(index != null) selectLanguageIndex.add(index);
    });
    if(widget.initFilterResult?.offShelf != null){
      int? index = StaticData.getOnOffShelfIndex(widget.initFilterResult?.offShelf?.value);
      if(index != null) selectListingStatusIndex = index;
    }
    widget.initFilterResult?.assessmentDirectionList?.forEach((element) {
      int? index = StaticData.getAssessmentDirectionIndex(element.value);
      if(index != null) assessmentDirectionIndexs.add(index);
    });

    widget.initFilterResult?.lessonTypes?.forEach((element) {
      int index = LessonTypeEnum.values.indexOf(element);
      if(index > -1) lessonTypesIndexs.add(index);
    });

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

  void openCloseLaunage(){
    openLanguage = !openLanguage;
    if(openLanguage){
      showLaunguageList = StaticData.languageList;
    }else{
      showLaunguageList = StaticData.languageList.length > 6 ? StaticData.languageList.sublist(0, 6) : StaticData.languageList;
    }
    if(mounted) setState(() {});
  }



  void resetAll() {
    selectLanguageIndex.clear();
    selectListingStatusIndex = -1;
    assessmentDirectionIndexs.clear();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildTitle("课程"),
                Visibility(
                  visible: (StaticData.languageList.length > 6),
                  child: TapScaleWidget(
                    sclae: 1.1,
                    onTap: () {
                      openCloseLaunage();
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 5.wh),
                      child: Row(
                        children: [
                          Text(
                            openLanguage ? "收起" : "展开",
                            style: TextStyle(
                              fontSize: 12.wMin,
                              color: const Color(0xffCFD5DF),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Icon(
                            openLanguage ? Icons.north : Icons.south,
                            color: const Color(0xffD9D9D9),
                            size: 20.wMin,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.wh),
            Container(
              // height: openLanguage ? null : 36.wh * 2 + 8.wh,
              constraints: BoxConstraints(
                maxHeight: 250.wh,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                physics: !openLanguage ? const NeverScrollableScrollPhysics() : null,
                child: Wrap(
                  spacing: 8.ww,
                  runSpacing: 8.wh,
                  children: List.generate(showLaunguageList.length, (index) {
                    return TapScaleWidget(
                      onTap: () {
                        if (selectLanguageIndex.contains(index)) {
                          selectLanguageIndex.remove(index);
                        } else {
                          selectLanguageIndex.add(index);
                        }
                        if (mounted) setState(() {});
                      },
                      sclae: 1,
                      child: Container(
                        width: 116.ww,
                        height: 36.wh,
                        padding: EdgeInsets.symmetric(horizontal: 8.ww),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.wMin),
                          color: selectLanguageIndex.contains(index)
                              ? const Color(0xff2388FF).withValues(alpha: 0.1)
                              : const Color(0xff41465A),
                          border: Border.all(
                            width: 1.wMin,
                            color: selectLanguageIndex.contains(index)
                                ? const Color(0xff2388FF).withValues(alpha: 0.5)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildImage(Assets.managerOfficialCourseLogo, width: 16.ww, height: 16.ww),
                            SizedBox(width: 4.ww),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: 78.ww,
                              ),
                              child: Text(
                                showLaunguageList[index].name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18.wMin,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildListingStatus() {
      return ManageFilterMultipleSelectionWidget(
        title: "上架状态",
        datas: StaticData.onOffShelfList,
        selecteds: [selectListingStatusIndex],
        onTapIndex: (index) {
          if (selectListingStatusIndex == index) {
            selectListingStatusIndex = -1;
          } else {
            selectListingStatusIndex = index;
          }
          if (mounted) setState(() {});
        },
      );
    }

    /// 考核方向
    Widget buildAssessmentDirection(){
      return ManageFilterMultipleSelectionWidget(
        title: "考核方向",
        datas: StaticData.assessmentDirection,
        selecteds: assessmentDirectionIndexs,
        onTapIndex: (index) {
          if (assessmentDirectionIndexs.contains(index)) {
            assessmentDirectionIndexs.remove(index);
          } else {
            assessmentDirectionIndexs.add(index);
          }
          if (mounted) setState(() {});
        },
      );
    }

    /// 课时类型
    Widget buildLessonTypeWidget(){
      return ManageFilterMultipleSelectionWidget(
        title: "课时类型",
        datas: LessonTypeEnum.values.map((e) => StaticDataEntity(name: e.name, value: e.value)).toList(),
        selecteds: lessonTypesIndexs,
        onTapIndex: (index) {
          if (lessonTypesIndexs.contains(index)) {
            lessonTypesIndexs.remove(index);
          } else {
            lessonTypesIndexs.add(index);
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
          buildLanguage(),
          SizedBox(height: 22.wh),
          buildListingStatus(),
          SizedBox(height: 22.wh),
          buildAssessmentDirection(),
          SizedBox(height: 22.wh),
          buildLessonTypeWidget(),
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
                    List<StaticDataEntity> launuage = [];
                    for(int i = 0; i < selectLanguageIndex.length; i++){
                      launuage.add(StaticData.languageList[selectLanguageIndex[i]]);
                    }
                    List<StaticDataEntity> assessmentDirection = [];
                    for(int i = 0; i < assessmentDirectionIndexs.length; i++){
                      assessmentDirection.add(StaticData.assessmentDirection[assessmentDirectionIndexs[i]]);
                    }

                    List<LessonTypeEnum> lessonTypes = [];
                    for(int i = 0; i < lessonTypesIndexs.length; i++){
                      lessonTypes.add(LessonTypeEnum.values[lessonTypesIndexs[i]]);
                    }

                    widget.onSure?.call(ManageLessonTemplateFilterResult(
                      launguageList: launuage,
                      languageIndexs: selectLanguageIndex,
                      offShelf: selectListingStatusIndex == -1 ? null : StaticData.onOffShelfList[selectListingStatusIndex],
                      offShelfIndex: selectListingStatusIndex == -1 ? null : selectListingStatusIndex,
                      assessmentDirectionList: assessmentDirection,
                      assessmentDirectionIndexs: assessmentDirectionIndexs,
                      lessonTypes: lessonTypes,
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
