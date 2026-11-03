import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../models/manage_create_quiz_model.dart';

class ManageCreateQuizTextSettingDialog {
  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    ManageCreateQuizModel? configModel,
  }) {
    return showCupertinoDialog(
      context: context,
      builder: (context) => ManageCreateQuizTextSettingDialogWidget(
        configModel: configModel,
      ),
    );
  }
}

class ManageCreateQuizTextSettingDialogWidget extends StatefulWidget {
  final ManageCreateQuizModel? configModel;
  const ManageCreateQuizTextSettingDialogWidget({super.key, required this.configModel});

  @override
  State<ManageCreateQuizTextSettingDialogWidget> createState() => _ManageCreateQuizTextSettingDialogWidgetState();
}

class _ManageCreateQuizTextSettingDialogWidgetState extends State<ManageCreateQuizTextSettingDialogWidget> {
  String? cefrStr;
  List<String> cefrList = [];
  List<String> themeList = [];
  String? themeStr;
  int? themeIndex;
  List<String> genreList = [];
  String? genreStr;
  int? genreIndex;

  @override
  void initState() {
    super.initState();
    if (widget.configModel!.cefrLevels != null) {
      cefrList = widget.configModel!.cefrLevels!;
    }

    for (ManageCreateQuizThemesModel theme in widget.configModel!.themes!) {
      for (LanguageText element in theme.name!) {
        if (element.lang == 'zh') {
          themeList.add(element.text!);
        }
      }
    }

    for (ManageCreateQuizGenresModel genre in widget.configModel!.genres!) {
      for (LanguageText element in genre.name!) {
        if (element.lang == 'zh') {
          genreList.add(element.text!);
        }
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.ww, vertical: 30.wh),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            border: Border.all(
              color: const Color(0xff444B5F),
              width: 1.wMin, // 边框宽度
            ),
            color: const Color(0xff181B25),
          ),
          width: 600.ww,
          height: 520.wh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '创建题目',
                style: TextStyle(fontSize: 20.wMin, color: Colors.white),
              ),
              SizedBox(height: 20.wMin),
              Expanded(
                child: Column(
                  children: [
                    ManageSelectWidget(
                      title: "CEFR等级",
                      hintText: '请选择CEFR等级',
                      value: cefrStr,
                      readOnly: false,
                      required: true,
                      options: cefrList,
                      onChanged: (String value, int index) {
                        cefrStr = value;
                      },
                    ),
                    SizedBox(height: 20.wMin),
                    ManageSelectWidget(
                      title: "主题",
                      hintText: '请选择主题',
                      value: themeStr,
                      readOnly: false,
                      required: true,
                      options: themeList,
                      onChanged: (String value, int index) {
                        themeIndex = index;
                        themeStr = value;
                      },
                    ),
                    SizedBox(height: 20.wMin),
                    ManageSelectWidget(
                      title: "体裁",
                      hintText: '请选择体裁',
                      value: genreStr,
                      readOnly: false,
                      required: true,
                      options: genreList,
                      onChanged: (String value, int index) {
                        genreIndex = index;
                        genreStr = value;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.wMin),
              _buildBottomWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageButton(
          text: "取消",
          width: 80.ww,
          height: 40.wh,
          borderColor: const Color(0xff666F8D),
          style: TextStyle(
            fontSize: 14.wMin,
            color: const Color(0xffEBEEF3),
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 15.wMin),
        ManageButton(
          text: "确定",
          width: 80.ww,
          height: 40.wh,
          color: const Color(0xff2388FF),
          borderColor: Colors.transparent,
          style: TextStyle(
            fontSize: 14.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            if (cefrStr == null) {
              ToastUtils.showManageToast(text: '请选择CEFR等级', type: ManageToastType.error);
              return;
            }

            if (themeIndex == null) {
              ToastUtils.showManageToast(text: '请选择主题', type: ManageToastType.error);
              return;
            }

            if (genreIndex == null) {
              ToastUtils.showManageToast(text: '请选择体裁', type: ManageToastType.error);
              return;
            }

            String theme = '';
            ManageCreateQuizThemesModel themeModel = widget.configModel!.themes![themeIndex!];
            for (var element in themeModel.name!) {
              if (element.lang == 'en') {
                theme = element.text!;
                break;
              }
            }
            String genre = '';
            ManageCreateQuizGenresModel genreModel = widget.configModel!.genres![genreIndex!];
            for (var element in genreModel.name!) {
              if (element.lang == 'en') {
                genre = element.text!;
                break;
              }
            }

            Get.back(result: {
              'cefr': cefrStr,
              'theme': theme,
              'genre': genre,
            });
          },
        ),
      ],
    );
  }
}
