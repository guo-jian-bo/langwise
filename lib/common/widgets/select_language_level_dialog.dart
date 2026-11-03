
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../theme/theme.dart';
import '../../utils/utils.dart';
import 'widgets.dart';

/// 选择语言水平
class SelectLanguageLevelDialog{

  static Future<DifficultieEntity?> show({
    required BuildContext context,
    DifficultieEntity? init,
  }) async {
    return await showCupertinoDialog<DifficultieEntity?>(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return SelectLanguageLevelDialogWidget(init: init);
      },
    );
  }

}

class SelectLanguageLevelDialogWidget extends StatefulWidget {
  final DifficultieEntity? init;
  const SelectLanguageLevelDialogWidget({super.key, this.init});

  @override
  State<SelectLanguageLevelDialogWidget> createState() => _SelectLanguageLevelDialogWidgetState();
}

class _SelectLanguageLevelDialogWidgetState extends State<SelectLanguageLevelDialogWidget> {
  final ConfigController config = Get.find<ConfigController>();
  List<DifficultieEntity> difficulties = [];
  DifficultieEntity? select;

  @override
  void initState() {
    super.initState();
    List<DifficultieEntity>? list = DifficultieUtils.getDifficultieList(config.appConfig.value, config.userSetting.value.learningLang);
    if(list != null){
      difficulties = list;
    }
    select = widget.init;
  }

  @override
  Widget build(BuildContext context) {
    return CardDialogBoxWidget(
      title: "语言水平",
      onCancel: () => Get.back(),
      onConfirm: () {
        if(select == null) return ToastUtils.showToast(text: "请选择语言水平");
        Get.back(result: select);
      },
      child: ListView.separated(
        itemCount: difficulties.length,
        padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 20.wMin),
        separatorBuilder: (context, index) {
          return Container(height: 1.wMin, color: AppTheme.cBorderPrimary);
        },
        itemBuilder: (context, index) {
          return _buildItemWidget(difficulties[index], index);
        },
      ),
    );
  }

  Widget _buildItemWidget(DifficultieEntity data, int index){
    return ListAnimationWidget(
      index: index,
      child: TapScaleWidget(
        onTap: () {
          select = data;
          if(mounted) setState(() {});
        },
        sclae: 1,
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 24.wMin),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  data.name?.text??"",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary,
                  ),
                ),
              ),
              SizedBox(width: 10.wMin),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: select?.level == data.level ? 1 : 0,
                child: SvgPicture.asset(
                  "assets/svg/public/icon_check.svg",
                  width: 32.wMin,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}