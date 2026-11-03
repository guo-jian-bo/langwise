import 'package:api/api.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/entities/module.dart';
import '../../../../common/https/https.dart';
import '../../../../common/static/static_data.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../generated/assets.dart';
import '../../../../utils/utils.dart';
import '../common/manage_select_option_widget.dart';
import '../common/manage_select_phonetic_symbol.dart';
import '../common/manage_title_input_widget.dart';

/// 创建自然拼读课弹窗
class ManagePhonicsCreateModuleDialog {
  static Future<List<ModuleResponseEntity?>?> show({
    required BuildContext context,
    required String? language,
    required int levelUid,
    ModuleResponseEntity? module,
  }) async {
    List<ModuleResponseEntity?>? res = await showCupertinoDialog<List<ModuleResponseEntity?>?>(
      context: context,
      builder: (context) {
        return ManagePhonicsCreateModuleDialogWidget(
          language: language,
          levelUid: levelUid,
          module: module,
        );
      },
    );

    return res;
  }
}

class ManagePhonicsCreateModuleDialogWidget extends StatefulWidget {
  final String? language;
  final int levelUid;
  final ModuleResponseEntity? module;

  const ManagePhonicsCreateModuleDialogWidget({
    super.key,
    required this.language,
    required this.levelUid,
    this.module,
  });

  @override
  State<ManagePhonicsCreateModuleDialogWidget> createState() => _ManagePhonicsCreateModuleDialogWidgetState();
}

class _ManagePhonicsCreateModuleDialogWidgetState extends State<ManagePhonicsCreateModuleDialogWidget> {
  final GlobalKey containerKey = GlobalKey();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  int selectLanguageIndex = 0;

  int selectAccessIndex = 0;

  String? topic;

  @override
  void initState() {
    super.initState();
    selectLanguageIndex = StaticData.languageList.indexWhere((element) => element.value == widget.language);

    if(widget.module != null){
      nameController.text = widget.module?.name ?? "";
      descriptionController.text = widget.module?.description ?? "";
      topic = widget.module?.topic;
      selectAccessIndex = StaticData.getOnOffShelfForCreateOrEditIndex(widget.module?.access) ?? 0;
    }

  }

  Future<void> onSubmit() async {
    final String name = nameController.text.trim();
    if (ObjectUtil.isEmpty(name)) {
      ToastUtils.showManageToast(text: "请输入模块名称", containerKey: containerKey);
      return;
    }
    if (topic == null) {
      ToastUtils.showManageToast(text: "请选择关联的ipa", containerKey: containerKey);
      return;
    }

    try {
      ToastUtils.showLoading();

      ResponseEntity<ModuleResponseEntity<dynamic>?> response;
      if(widget.module != null){
        response = await ModuleUtil.edit(
          uid: widget.module!.uid.toString(),
          config: RequestConfig(
            requireToken: true,
            data: {
              "name": name,
              "access": StaticData.onOffShelfForCreateOrEdit[selectAccessIndex].value,
              "description": descriptionController.text.trim(),
              "topic": topic,
            },
          ),
        );
      }else{
        response = await ModuleUtil.create(config: RequestConfig(
          requireToken: true,
          data: {
            "name": name,
            "language": widget.language,
            "description": descriptionController.text.trim(),
            "levelId": widget.levelUid,
            "topic": topic, // 关联的ipa
          },
        ));
      }

      if (response.data != null) {
        ToastUtils.showManageToast(text: widget.module != null ? "编辑模块成功" : "创建模块成功", containerKey: containerKey);
        Get.back(result: [response.data]);
      } else {
        ToastUtils.showManageToast(text: widget.module != null ? "编辑模块失败" : "创建模块失败", containerKey: containerKey);
      }
    } catch (e) {
      ToastUtils.showManageToast(text: widget.module != null ? "编辑模块失败" : "创建模块失败", containerKey: containerKey);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 选择IPA
  Future<void> selectTopic(BuildContext context) async {
    PhonicsEntityDatas? res = await ManageSelectPhoneticSymbol.show(context: context);
    if(res == null) return;
    topic = res.ipa;
    if(mounted) setState(() {});
  
  }

  void setAccess(int index) {
    selectAccessIndex = index;
    if(mounted) setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return DialogBoxWidget(
      onCancel: () {
        Get.back();
      },
      onDefine: () {
        onSubmit();
      },
      title: widget.module != null ? "编辑模块" : "添加模块",
      width: 1000.wMin,
      child: Container(
        key: containerKey,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: _buildFromWidget(),
      ),
    );
  }

  Widget _buildFromWidget() {
    return Container(
      height: 640.wMin,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color(0xff22293C),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ManageTitleInputWidget(
              title: "模块名称",
              hintText: '请输入模块名称',
              controller: nameController,
              required: true,
              maxLength: 20,
            ),
            SizedBox(height: 24.wMin),
            ManageTitleInputWidget(
              title: "模块描述",
              hintText: '请输入模块描述',
              controller: descriptionController,
            ),
            SizedBox(height: 24.wMin),
            ManageSelectWidget(
              title: "语言",
              hintText: '请选择语言',
              readOnly: true,
              required: true,
              value: StaticData.languageList[selectLanguageIndex].name,
              options: StaticData.languageList.map((e) => e.name).toList(),
            ),
            SizedBox(height: 24.wMin),

            Visibility(
              visible: widget.module != null,
              child: Container(
                margin: EdgeInsets.only(bottom: 24.wMin),
                child: ManageSelectWidget(
                  title: "上架状态",
                  hintText: '请选择上架状态',
                  value: StaticData.getOnOffShelfForCreateOrEdit(selectAccessIndex),
                  readOnly: false,
                  required: true,
                  options: StaticData.getOnOffShelfForCreateOrEditNames,
                  onChanged: (String value, int index) {
                    setAccess(index);
                  },
                ),
              ),
            ),

            Text(
              "关联IPA",
              style: TextStyle(
                fontSize: 14.wMin,
                color: const Color(0xffEBEEF3),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 12.wMin),
            TapScaleWidget(
              onTap: () {
                selectTopic(context);
              },
              sclae: 1.01,
              child: DottedBorder(
                radius: Radius.circular(10.wMin),
                borderType: BorderType.RRect,
                padding: EdgeInsets.zero,
                color: const Color(0xff4B5268),
                dashPattern: const [4, 2],
                child: SizedBox(
                  width: 250.wMin,
                  height: 250.wMin,
                  child: topic == null ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildImage(Assets.managerAdd, width: 40.wMax, height: 40.wMax),
                      SizedBox(height: 12.wh),
                      Text(
                        "选择音标",
                        style: TextStyle(
                          fontSize: 12.wMin,
                          color: const Color(0xffACB4C0),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ) : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        topic ?? '',
                        style: TextStyle(
                          fontSize: 80.wMin,
                          color: const Color(0xffEBEEF3),
                          fontWeight: FontWeight.w400,
                          fontFamily: "AndikaRegular",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
  
}
