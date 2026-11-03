import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/dialog/manage_select_semantic_table/view.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/utils/utils.dart';

class ManageCreateSingleWordController extends BaseController {
  final String? content;
  final String? definition;

  ManageCreateSingleWordController(this.content, this.definition);

  /// 上传所有信息按钮
  // bool get uploadButtonFlag => (wordController.text.trim().isNotEmpty &&
  //     lemmaController.text.trim().isNotEmpty &&
  //     (definitionController.text.trim().isNotEmpty) &&
  //     americanController.text.trim().isNotEmpty &&
  //     britishController.text.trim().isNotEmpty);
  bool get uploadButtonFlag => (wordController.text.trim().isNotEmpty && (definitionController.text.trim().isNotEmpty));

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

  // 词性
  List<PosResponseEntity> poses = <PosResponseEntity>[];

  // 语法形式
  List<FormResponseEntity> forms = <FormResponseEntity>[];

  // 语义list
  List<EnEntitySemantics> semantics = <EnEntitySemantics>[];

  @override
  void onInit() {
    super.onInit();
    wordController.text = content?.trim() ?? '';
    definitionController.text = definition?.trim() ?? '';
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
    update(['manage_create_single_word']);
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

      // final String lemma = lemmaController.text.trim();
      // if (ObjectUtil.isEmpty(lemma)) {
      //   ToastUtils.showManageToast(text: "请填写原形");
      //   return;
      // }
      final String definition = definitionController.text.trim();
      if (ObjectUtil.isEmpty(definition)) {
        ToastUtils.showManageToast(text: "请填写释义");
        return;
      }

      // final String american = americanController.text.trim();
      // if (ObjectUtil.isEmpty(american)) {
      //   ToastUtils.showManageToast(text: "请填写美音");
      //   return;
      // }

      // final String british = britishController.text.trim();
      // if (ObjectUtil.isEmpty(british)) {
      //   ToastUtils.showManageToast(text: "请填写英音");
      //   return;
      // }

      if (posIndex == -1) {
        ToastUtils.showManageToast(text: "请选择词性");
        return;
      }

      // if (formIndex == -1) {
      //   ToastUtils.showManageToast(text: "请选择语法形式");
      //   return;
      // }

      // 词性/语法形式  form;
      String? pos;
      try {
        pos = poses[posIndex].pos;
      } catch (e) {
        print('---词性e:$e---');
      }
      //
      // try {
      //   form = forms[formIndex].form;
      // } catch (e) {
      //   print('---语法形式e:$e---');
      // }

      // if (semantics.isEmpty) {
      //   ToastUtils.showManageToast(text: "请选择语义");
      //   return;
      // }

      ToastUtils.showLoading();
      var response = await WordUtil.match(
          config: RequestConfig(data: {
        "content": content,
        "contentType": KnowledgeType.EN_WORD.value,
        "definition": definition,
        "bookType": BookType.TEXTBOOK.value,
        "pos": pos,
      }, requireToken: true, cancelToken: cancelToken));

      if (response.data != null) {
        ToastUtils.showManageToast(text: response.data.toString());
        Get.back(result: null);
      } else {
        ToastUtils.showManageToast(text: response.message ?? '创建短语失败', type: ManageToastType.error);
      }
    } on FormatException catch (error) {
      ToastUtils.showManageToast(text: error.source?.message ?? '', type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: '创建短语失败', type: ManageToastType.error);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  // 获取词性列表
  void onGetPos() async {
    try {
      final response = await LanguageUtil.pos(config: RequestConfig(requireToken: true, cancelToken: cancelToken));
      if (response.data != null) {
        poses = response.data?.list ?? [];
      } else {
        ToastUtils.showManageToast(text: response.message ?? '获取词性列表失败');
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "获取词性列表失败");
    } finally {
      _initData();
    }
  }

// 获取语法形式列表
  void onGetForm() async {
    try {
      final response = await LanguageUtil.form(config: RequestConfig(requireToken: true, cancelToken: cancelToken));
      if (response.data != null) {
        forms = response.data?.list ?? [];
      } else {
        ToastUtils.showManageToast(text: response.message ?? '获取语法形式列表失败');
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "获取语法形式列表失败");
    } finally {
      _initData();
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

  @override
  void onClose() {
    super.onClose();
    cancelToken.cancel("取消创建");
    wordController.dispose();
    lemmaController.dispose();
    americanController.dispose();
    britishController.dispose();
  }
}
