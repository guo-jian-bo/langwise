import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../app/modules/management/common/manage_title_input_widget.dart';
import '../public_controller/config_controller.dart';
import 'widgets.dart';

/// 新增单元弹窗
class AddUnitDialog {
  static Future<NewUnitResponseEntity<LessonResponseEntity>?> show({
    required BuildContext context,
    final int? moduleId,
    String? language,
    bool hidsDifficulty = false,
  }) async {
    return await showCupertinoDialog<NewUnitResponseEntity<LessonResponseEntity>?>(
      context: context,
      builder: (context) {
        return AddUnitDWidget(
          moduleId: moduleId,
          language: language,
          hidsDifficulty: hidsDifficulty,
        );
      },
    );
  }
}

class AddUnitDWidget extends StatefulWidget {
  final int? moduleId;
  final int? levelUid;
  final String? language;
  final bool hidsDifficulty;

  const AddUnitDWidget({
    super.key,
    this.moduleId,
    this.levelUid,
    this.language,
    this.hidsDifficulty = false,
  });

  @override
  State<AddUnitDWidget> createState() => _AddUnitDWidgetState();
}

class _AddUnitDWidgetState extends State<AddUnitDWidget> with SafeSetStateMixin {
  // 名称
  final TextEditingController createNameController = TextEditingController();

  // 描述
  final TextEditingController createDesController = TextEditingController();

  // 语言
  int _createSelectLanguageIndex = (-1);

  set createSelectLanguageIndex(value) => _createSelectLanguageIndex = value;

  int get createSelectLanguageIndex => _createSelectLanguageIndex;

  // cefr
  int _createSelectCefrIndex = (-1);

  set createSelectCefrIndex(value) => _createSelectCefrIndex = value;

  int get createSelectCefrIndex => _createSelectCefrIndex;

  // 上下架
  int _selectAccessIndex = (-1);

  set selectAccessIndex(value) => _selectAccessIndex = value;

  int get selectAccessIndex => _selectAccessIndex;

  int? _moduleId;

  /// 难度等级
  int selectDifficultyIndex = -1;

  final GlobalKey dialogKey = GlobalKey();

  /// 难度等级数据
  final List<DifficultieEntity> difficultieList = [];

  // 创建/语言是否只读
  bool get createLanguageReadOnly => _language != null;

  String? _language;

  @override
  void initState() {
    super.initState();
    _moduleId = widget.moduleId;
    _language = widget.language;
    if (_language != null) {
      for (int i = 0; i < CommonUtil.language.length; i++) {
        final Map<String, String> r = CommonUtil.language[i];
        if (r[_language] != null) {
          setCreateLanguage(i);
        }
      }
    }

    // (如果语言未命中)默认选中英语
    if (createSelectLanguageIndex == -1) {
      setCreateLanguage(0);
      _language = '';
    }

    selectAccessIndex = 1;

    getConfig();
  }

  @override
  Widget build(BuildContext context) {
    return DialogBoxWidget(
      title: "新增单元",
      define: "确定",
      width: 1080.wMin,
      child: buildContentWidget(),
      onCancel: () => Get.back(),
      onDefine: OptimizeUtils.noneThrottle(() {
        onCreateUnit();
      }, 200),
    );
  }

  Widget buildContentWidget() {
    return Container(
      margin: EdgeInsets.all(24.wMin),
      constraints: BoxConstraints(
        maxHeight: 700.wMin,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color(0xff22293C),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.wMin),
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ManageTitleInputWidget(
                title: "单元名",
                hintText: "请输入单元名",
                focusOrder: 0,
                required: true,
                controller: createNameController,
              ),
              SizedBox(height: 24.wh),
              ManageTitleInputWidget(
                title: "描述",
                hintText: "请输入单元描述",
                focusOrder: 1,
                required: true,
                controller: createDesController,
              ),
              SizedBox(height: 24.wh),
              ManageSelectWidget(
                title: "语言",
                hintText: '请选择语言',
                readOnly: createLanguageReadOnly,
                required: true,
                value: createLanguageTitle,
                options: CommonUtil.languageValues,
                onChanged: (String value, int index) {
                  setCreateLanguage(index);
                  print("接收index:$index");
                  // 切换语言时, 重置难度水平为-1
                  selectDifficultyIndex = -1;
                  // 重新获取难度等级数据
                  getConfig();
                },
              ),
              Visibility(
                visible: !widget.hidsDifficulty,
                child: Container(
                  margin: EdgeInsets.only(top: 24.wh),
                  child: ManageSelectWidget(
                    title: "难度水平",
                    hintText: '请选择难度水平',
                    readOnly: false,
                    required: true,
                    options: difficultieList.map((e) => e.name?.text ?? "").toList(),
                    onChanged: (String value, int index) {
                      selectDifficultyIndex = index;
                    },
                  ),
                ),
              ),
              Gaps.getHeight(24.wh),
              ManageSelectWidget(
                title: "上架状态",
                hintText: '请选择上架状态',
                value: newAccessName,
                readOnly: true,
                required: true,
                options: StaticData.getOnOffShelfForCreateOrEditNames,
                onChanged: (String value, int index) {
                  setAccess(index);
                },
              ),
              Gaps.getHeight(24.wh),
            ],
          ),
        ),
      ),
    );
  }

  // 难度等级
  void getConfig() {
    final ConfigEntity configData = Get.find<ConfigController>().appConfig.value;
    final String languageCode = StaticData.languageList[createSelectLanguageIndex].value;
    final List<DifficultieEntity>? diffList = DifficultieUtils.getDifficultieList(configData, languageCode);
    if (diffList != null && diffList.isNotEmpty) {
      difficultieList.clear();
      difficultieList.addAll(diffList);
    }

    safeSetState(() {});
  }

  // 创建
  void onCreateUnit() async {
    try {
      if (_moduleId == null) {
        ToastUtils.showManageToast(text: "moduleId为空");
        return;
      }

      final String name = createNameController.text.trim();
      if (ObjectUtil.isEmpty(name)) {
        ToastUtils.showManageToast(text: "请输入单元名");
        return;
      }

      final String des = createDesController.text.trim();
      if (ObjectUtil.isEmpty(des)) {
        ToastUtils.showManageToast(text: "请输入单元描述");
        return;
      }

      // 语言
      String? language;
      try {
        language = CommonUtil.languageKeys[createSelectLanguageIndex];
      } catch (e) {
        print('---语言e:$e---');
      }

      if (language == null) {
        ToastUtils.showManageToast(text: "请选择语言");
        return;
      }

      if(!widget.hidsDifficulty){
        if (selectDifficultyIndex == -1) {
          ToastUtils.showManageToast(text: "请选择难度等级", containerKey: dialogKey);
          return;
        }
      }
      
      Map<String, dynamic> reqData = {
        "moduleId": _moduleId,
        "name": name,
        "language": language,
        "description": des,
        "access": StaticData.onOffShelfForCreateOrEdit[selectAccessIndex].value,
      };

      if(!widget.hidsDifficulty){
        reqData['difficultyLevel'] = difficultieList[selectDifficultyIndex].level;
      }

      final response = await UnitUtil.create(
          config: RequestConfig(
        requireToken: true,
        data: reqData,
      ));
      if (response.data != null) {
        ToastUtils.showManageToast(text: "创建单元成功");
        Get.back(result: response.data);
      } else {
        ToastUtils.showManageToast(text: response.message ?? "创建单元失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "创建单元失败");
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // 手动创建/语言title
  String get createLanguageTitle {
    String title = '';
    try {
      title = CommonUtil.languageValues[createSelectLanguageIndex];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    print(title);

    return title;
  }

  // 上下架title
  String get newAccessName {
    return StaticData.getOnOffShelfForCreateOrEdit(selectAccessIndex);
  }

  // 上下架
  void setAccess(int index) {
    selectAccessIndex = index;
  }

  // 设置语言
  void setCreateLanguage(int index) {
    createSelectLanguageIndex = index;
  }
}
