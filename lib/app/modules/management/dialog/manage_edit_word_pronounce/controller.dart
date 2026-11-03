import 'package:api/entities/entities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';

class ManageEditWordPronounceController extends BaseController {
  final EnWordPronounceEntity entity;

  ManageEditWordPronounceController(this.entity);

  /// 上传所有信息按钮
  bool get uploadButtonFlag => (wordController.text.trim().isNotEmpty &&
      ipaController.text.trim().isNotEmpty &&
      syllables.isNotEmpty &&
      phonics.isNotEmpty);

  /// 单词ID
  final TextEditingController wordIdController = TextEditingController();

  /// 单词
  final TextEditingController wordController = TextEditingController(text: '');

  /// IPA
  final TextEditingController ipaController = TextEditingController(text: '');

  // 音节列表
  RxList<EnWordPronounceEntitySyllable> syllables = <EnWordPronounceEntitySyllable>[].obs;

  // 音素列表
  RxList<EnWordPronounceEntityPhonic> phonics = <EnWordPronounceEntityPhonic>[].obs;

  final RxInt _nationalIpaIndex = (-1).obs;

  set nationalIpaIndex(value) => _nationalIpaIndex.value = value;

  int get nationalIpaIndex => _nationalIpaIndex.value;

  /// 口音
  final TextEditingController nationalIpaController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    wordIdController.text = entity.uid.toString();
    wordController.text = entity.content?.trim() ?? '';
    ipaController.text = entity.ipa?.trim() ?? '';

    if (entity.nationalIpa != null) {
      for (int i = 0; i < CommonUtil.nationalIpa.length; i++) {
        final Map<String, String> r = CommonUtil.nationalIpa[i];
        if (r[entity.nationalIpa] != null) {
          setNationalIpa(i);
        }
      }
    }

    // 复制音节列表
    if (entity.syllables != null) {
      for (var syllable in entity.syllables!) {
        // 创建音节实体
        syllables.add(EnWordPronounceEntitySyllable(
            ipa: syllable.ipa,
            graphemes: syllable.graphemes,
            positions: List<int>.from(syllable.positions ?? []),
            ipaTextController: TextEditingController(text: syllable.ipa),
            graphemesTextController: TextEditingController(text: syllable.graphemes),
            positionController: TextEditingController(text: syllable.positions?.join(","))));
      }
    }

    // 复制音素列表
    if (entity.phonics != null) {
      for (var phonic in entity.phonics!) {
        // 创建音素实体
        phonics.add(EnWordPronounceEntityPhonic(
            ipa: phonic.ipa,
            graphemes: phonic.graphemes,
            positions: List<int>.from(phonic.positions ?? []),
            audioUrl: phonic.audioUrl,
            ipaTextController: TextEditingController(text: phonic.ipa),
            graphemesTextController: TextEditingController(text: phonic.graphemes),
            positionController: TextEditingController(text: phonic.positions?.join(","))));
      }
    }

    _onListener();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(['manage_edit_word_pronounce']);
  }

  void _onListener() {
    wordController.addListener(() {
      _initData();
    });
    ipaController.addListener(() {
      _initData();
    });
  }

  // 创建/更新单词发音
  void onSave() async {
    try {
      final String content = wordController.text.trim();
      if (content.isEmpty) {
        ToastUtils.showManageToast(text: "请填写单词");
        return;
      }

      final String ipa = ipaController.text.trim();
      if (ipa.isEmpty) {
        ToastUtils.showManageToast(text: "请填写IPA");
        return;
      }

      if (syllables.isEmpty) {
        ToastUtils.showManageToast(text: "请添加至少一个音节");
        return;
      }

      if (phonics.isEmpty) {
        ToastUtils.showManageToast(text: "请添加至少一个自拼");
        return;
      }

      // 验证音节
      var (syllableHasError, syllableErrorMessage) = validateSyllables(content);
      if (syllableHasError) {
        _initData();
        ToastUtils.showManageToast(
          text: syllableErrorMessage,
          type: ManageToastType.error,
        );
        return;
      }

      // 验证音素
      var (phonicHasError, phonicErrorMessage) = validatePhonics(content);
      if (phonicHasError) {
        _initData();
        ToastUtils.showManageToast(
          text: phonicErrorMessage,
          type: ManageToastType.error,
        );
        return;
      }

      // 构建请求数据
      final Map<String, dynamic> data = {
        "ipa": ipa,
        "syllables": syllables.map((s) => s.toJsonFromControllers()).toList(),
        "phonics": phonics.map((p) => p.toJsonFromControllers()).toList(),
      };

      // 编辑现有记录
      var response = await WordPronounceUtil.edit(
          uid: entity.uid.toString(),
          config: RequestConfig(data: data, requireToken: true, cancelToken: cancelToken));

      if (response.data != null) {
        Get.back(result: response.data);
      } else {
        ToastUtils.showManageToast(text: response.message ?? '编辑单词发音失败', type: ManageToastType.error);
      }
    } catch (e) {
      ToastUtils.showManageToast(text: '保存单词发音失败', type: ManageToastType.error);
    }
  }

  String get nationalIpaTitle {
    String title = '';
    try {
      title = CommonUtil.nationalIpaValues[nationalIpaIndex];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return title;
  }

  // 导入模板/设置语言
  void setNationalIpa(int index) {
    nationalIpaIndex = index;
    _initData();
  }

  /// 重置音节的IPA错误状态
  void resetIpaError(EnWordPronounceEntitySyllable syllable) {
    if (syllable.ipaError) {
      syllable.ipaError = false;
      update(['manage_edit_word_pronounce']);
    }
  }

  /// 重置音节的字母错误状态
  void resetGraphemesError(EnWordPronounceEntitySyllable syllable) {
    if (syllable.graphemesError) {
      syllable.graphemesError = false;
      update(['manage_edit_word_pronounce']);
    }
  }

  /// 重置音节的位置错误状态
  void resetPositionError(EnWordPronounceEntitySyllable syllable) {
    if (syllable.positionError) {
      syllable.positionError = false;
      update(['manage_edit_word_pronounce']);
    }
  }

  /// 重置音素的IPA错误状态
  void resetPhonicIpaError(EnWordPronounceEntityPhonic phonic) {
    if (phonic.ipaError) {
      phonic.ipaError = false;
      update(['manage_edit_word_pronounce']);
    }
  }

  /// 重置音素的字母错误状态
  void resetPhonicGraphemesError(EnWordPronounceEntityPhonic phonic) {
    if (phonic.graphemesError) {
      phonic.graphemesError = false;
      update(['manage_edit_word_pronounce']);
    }
  }

  /// 重置音素的位置错误状态
  void resetPhonicPositionError(EnWordPronounceEntityPhonic phonic) {
    if (phonic.positionError) {
      phonic.positionError = false;
      update(['manage_edit_word_pronounce']);
    }
  }

  /// 验证音节输入
  /// 返回元组: (bool hasError, String errorMessage)
  (bool, String) validateSyllables(String word) {
    bool hasIpaError = false;
    bool hasGraphemesError = false;
    bool hasPositionError = false;
    bool hasGraphemesNotInWord = false;

    for (var syllable in syllables) {
      syllable.ipaError = syllable.isIpaEmpty;
      syllable.graphemesError = syllable.isGraphemesEmpty;
      syllable.positionError = syllable.isPositionEmpty;

      if (syllable.ipaError) hasIpaError = true;
      if (syllable.graphemesError) hasGraphemesError = true;
      if (syllable.positionError) hasPositionError = true;
      if (!syllable.isGraphemesEmpty && !syllable.containsInWord(word)) {
        hasGraphemesNotInWord = true;
        syllable.graphemesError = true;
      }
    }

    if (hasIpaError) return (true, "音节IPA不能为空");
    if (hasGraphemesError) return (true, "音节字母不能为空");
    if (hasGraphemesNotInWord) return (true, "音节字母必须在单词中");
    if (hasPositionError) return (true, "音节位置不能为空");

    return (false, "");
  }

  /// 验证音素输入
  /// 返回元组: (bool hasError, String errorMessage)
  (bool, String) validatePhonics(String word) {
    bool hasIpaError = false;
    bool hasGraphemesError = false;
    bool hasPositionError = false;
    bool hasGraphemesNotInWord = false;

    for (var phonic in phonics) {
      phonic.ipaError = phonic.isIpaEmpty;
      phonic.graphemesError = phonic.isGraphemesEmpty;
      phonic.positionError = phonic.isPositionEmpty;

      if (phonic.ipaError) hasIpaError = true;
      if (phonic.graphemesError) hasGraphemesError = true;
      if (phonic.positionError) hasPositionError = true;
      if (!phonic.isGraphemesEmpty && !phonic.containsInWord(word)) {
        hasGraphemesNotInWord = true;
        phonic.graphemesError = true;
      }
    }

    if (hasIpaError) return (true, "音素IPA不能为空");
    if (hasGraphemesError) return (true, "音素字母不能为空");
    if (hasGraphemesNotInWord) return (true, "音素字母必须在单词中");
    if (hasPositionError) return (true, "音素位置不能为空");

    return (false, "");
  }

  @override
  void onClose() {
    for (final EnWordPronounceEntitySyllable syllable in entity.syllables ?? []) {
      syllable.ipaTextController?.dispose();
      syllable.graphemesTextController?.dispose();
      syllable.positionController?.dispose();
    }
    for (final EnWordPronounceEntityPhonic phonic in entity.phonics ?? []) {
      phonic.ipaTextController?.dispose();
      phonic.graphemesTextController?.dispose();
      phonic.positionController?.dispose();
    }
    wordController.dispose();
    ipaController.dispose();
    wordIdController.dispose();
    nationalIpaController.dispose();
    cancelToken.cancel("取消编辑");
    super.onClose();
  }
}
