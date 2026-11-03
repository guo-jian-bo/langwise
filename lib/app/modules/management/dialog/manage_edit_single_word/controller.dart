import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/dialog/manage_select_semantic_table/view.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';

class ManageEditSingleWordController extends BaseController {
  final EnWordEntity entity;

  ManageEditSingleWordController(this.entity);

  /// 上传所有信息按钮
  // bool get uploadButtonFlag => (wordController.text.trim().isNotEmpty &&
  //     lemmaController.text.trim().isNotEmpty &&
  //     (definitionController.text.trim().isNotEmpty) &&
  //     americanController.text.trim().isNotEmpty &&
  //     britishController.text.trim().isNotEmpty &&
  //     posIndex != -1);

  bool get uploadButtonFlag => (wordController.text.trim().isNotEmpty && (posIndex != -1));

  /// 单词ID
  final TextEditingController wordIdController = TextEditingController();

  /// word
  final TextEditingController wordController = TextEditingController(text: '');

  /// 原形
  final TextEditingController lemmaController = TextEditingController(text: '');

  /// 释义
  final TextEditingController definitionController = TextEditingController(text: '');

  // 美音
  final TextEditingController americanController = TextEditingController(text: '');

  // 英音
  final TextEditingController britishController = TextEditingController(text: '');

  // 词性
  final RxInt _posIndex = (-1).obs;

  set posIndex(value) => _posIndex.value = value;

  int get posIndex => _posIndex.value;

  // 语法形式
  final RxInt _formIndex = (-1).obs;

  set formIndex(value) => _formIndex.value = value;

  int get formIndex => _formIndex.value;

  // 上下架
  final RxInt _selectAccessIndex = (-1).obs;

  set selectAccessIndex(value) => _selectAccessIndex.value = value;

  int get selectAccessIndex => _selectAccessIndex.value;

  // 词性
  List<PosResponseEntity> poses = <PosResponseEntity>[];

  // 语法形式
  List<FormResponseEntity> forms = <FormResponseEntity>[];

  // 语义list
  List<EnEntitySemantics> semantics = <EnEntitySemantics>[];

  @override
  void onInit() {
    super.onInit();
    wordIdController.text = entity.uid.toString();
    wordController.text = entity.content?.trim() ?? '';
    lemmaController.text = entity.lemma?.trim() ?? '';
    definitionController.text = entity.definition?.trim() ?? '';
    if (entity.ipaList != null && entity.ipaList!.isNotEmpty) {
      // 英音
      britishController.text =
          entity.ipaList!.firstWhereOrNull((element) => element?.accent == CommonUtil.uk)?.text ?? '';
      // 美音
      americanController.text =
          entity.ipaList!.firstWhereOrNull((element) => element?.accent == CommonUtil.us)?.text ?? '';
    }

    for (final e in entity.semantics ?? []) {
      if (e != null) {
        semantics.add(e);
      }
    }
    print('---$entity---');
    try {
      selectAccessIndex = StaticData.getOnOffShelfForCreateOrEditIndex(entity.access) ?? 0;
    } catch (e) {
      print(e);
    }
    onGetPos();
    onGetForm();
    _onListener();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(['manage_edit_single_word']);
  }

  void _onListener() {
    wordController.addListener(() {
      _initData();
    });
    definitionController.addListener(() {
      _initData();
    });
    lemmaController.addListener(() {
      _initData();
    });
    americanController.addListener(() {
      _initData();
    });
    britishController.addListener(() {
      _initData();
    });
  }

  // 创建单词
  void onCreateWord() async {
    try {
      final String content = wordController.text.trim();
      if (ObjectUtil.isEmpty(content)) {
        ToastUtils.showManageToast(text: "请填写单词");
        return;
      }

      final String lemma = lemmaController.text.trim();
      if (ObjectUtil.isEmpty(lemma)) {
        ToastUtils.showManageToast(text: "请填写原形");
        return;
      }
      final String definition = definitionController.text.trim();
      if (ObjectUtil.isEmpty(definition)) {
        ToastUtils.showManageToast(text: "请填写释义");
        return;
      }

      final String american = americanController.text.trim();
      if (ObjectUtil.isEmpty(american)) {
        ToastUtils.showManageToast(text: "请填写美音");
        return;
      }

      final String british = britishController.text.trim();
      if (ObjectUtil.isEmpty(british)) {
        ToastUtils.showManageToast(text: "请填写英音");
        return;
      }

      if (posIndex == -1) {
        ToastUtils.showManageToast(text: "请选择词性");
        return;
      }

      if (formIndex == -1) {
        ToastUtils.showManageToast(text: "请选择语法形式");
        return;
      }

      // 词性/语法形式
      String? pos, form;
      try {
        pos = poses[posIndex].pos;
      } catch (e) {
        print('---词性e:$e---');
      }

      try {
        form = forms[formIndex].form;
      } catch (e) {
        print('---语法形式e:$e---');
      }

      if (semantics.isEmpty) {
        ToastUtils.showManageToast(text: "请选择语义");
        return;
      }

      var response = await WordUtil.edit(
          uid: entity.uid.toString(),
          config: RequestConfig(data: {
            "content": content,
            "lemma": lemma,
            "definition": definition,
            "pos": pos,
            "form": form,
            "ipa": [
              // 英音
              if (british.isNotEmpty) {"text": british, "accent": CommonUtil.uk},
              // 美音
              if (american.isNotEmpty) {"text": american, "accent": CommonUtil.us},
            ],
            "semanticIds": semantics.map((element) => element.uid).toList(),
            "access": StaticData.onOffShelfForCreateOrEdit[selectAccessIndex].value
          }, requireToken: true, cancelToken: cancelToken));

      if (response.data != null) {
        Get.back(result: response.data);
      } else {
        ToastUtils.showManageToast(text: response.message ?? '编辑单词失败');
      }
    } catch (e) {
      ToastUtils.showManageToast(text: '编辑单词失败');
    }
  }

  /// 获取词性列表
  /// 使用早期返回减少嵌套层级
  void onGetPos() async {
    try {
      final response = await LanguageUtil.pos(config: RequestConfig(requireToken: true, cancelToken: cancelToken));

      // 早期返回：处理失败情况
      if (response.data == null) {
        throw response.message ?? '获取词性列表失败';
      }

      // 设置词性列表
      poses = response.data?.list ?? [];

      // 设置当前实体的词性索引
      _setPosIndexFromEntity();
    } catch (e) {
      ToastUtils.showManageToast(text: "获取词性列表失败");
    } finally {
      _initData();
    }
  }

  /// 从实体中设置词性索引
  /// 拆分复杂逻辑，降低函数复杂度
  void _setPosIndexFromEntity() {
    // 提前返回
    if (entity.pos == null || poses.isEmpty) return;

    // 查找匹配的词性索引
    for (int i = 0; i < poses.length; i++) {
      if (poses[i].pos == entity.pos) {
        posIndex = i;
        break; // 找到后立即退出
      }
    }
  }

  /// 获取语法形式列表
  /// 使用早期返回减少嵌套层级
  void onGetForm() async {
    try {
      final response = await LanguageUtil.form(config: RequestConfig(requireToken: true, cancelToken: cancelToken));

      // 早期返回：处理失败情况
      if (response.data == null) {
        throw response.message ?? '获取语法形式列表失败';
      }

      // 设置语法形式列表
      forms = response.data?.list ?? [];

      // 设置当前实体的语法形式索引
      _setFormIndexFromEntity();
    } catch (e) {
      ToastUtils.showManageToast(text: "获取语法形式列表失败");
    } finally {
      _initData();
    }
  }

  /// 从实体中设置语法形式索引
  /// 拆分复杂逻辑，降低函数复杂度
  void _setFormIndexFromEntity() {
    // 提前返回
    if (entity.form == null || forms.isEmpty) return;

    // 查找匹配的语法形式索引
    for (int i = 0; i < forms.length; i++) {
      if (forms[i].form == entity.form) {
        formIndex = i;
        break; // 找到后立即退出
      }
    }
  }

  // 添加语义
  Future<void> toAddSemantic(BuildContext context, List<EnEntitySemantics> existList) async {
    var value = await ManageSelectSemanticTableManager.show(
        context: context,
        defaultDessert: [],
        dataDisableCallback: (EnEntitySemantics targetEntity) {
          bool isDisable = false;
          for (final EnEntitySemantics exist in existList) {
            if (exist == targetEntity) {
              isDisable = true;
              break;
            }
          }
          return isDisable;
        });
    if (value != null) {
      semantics.addAll(value);
      _initData();
    }
  }

  // 移除语义
  void onRemoveSemantic(EnEntitySemantics entity) {
    if (semantics.isNotEmpty) {
      semantics.remove(entity);
      _initData();
    }
  }

  // 词性
  String get posTitle {
    String title = '';
    try {
      title = poses.map((element) => element.title ?? '').toList()[posIndex];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    print(title);

    return title;
  }

// 设置词性
  void setPos(int index) {
    posIndex = index;
    _initData();
  }

// 语法形式
  String get formTitle {
    String title = '';
    try {
      title = forms.map((element) => element.title ?? '').toList()[formIndex];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    print(title);

    return title;
  }

// 语法形式
  void setForm(int index) {
    formIndex = index;
    _initData();
  }

  // 上下架
  void setAccess(int index) {
    selectAccessIndex = index;
    _initData();
  }

  // 上下架title
  String get newAccessName {
    return StaticData.getOnOffShelfForCreateOrEdit(selectAccessIndex);
  }

  @override
  void onClose() {
    super.onClose();
    cancelToken.cancel("取消创建");
    wordController.dispose();
    lemmaController.dispose();
    americanController.dispose();
    britishController.dispose();
    wordIdController.dispose();
  }
}
