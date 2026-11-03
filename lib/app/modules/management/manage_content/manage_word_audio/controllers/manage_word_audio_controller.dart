import 'dart:io';

import 'package:api/entities/entities.dart';
import 'package:audio_player_ex/audio_player_ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:wise_http/wise_http.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../utils/oss_upload_file_utils/oss_update_response_entity.dart';
import '../../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../utils/utils.dart';

class ManageWordAudioController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageWordAudioController({required this.tag});

  List<EnKnowledgeEntityIpaAudioList>? audioList = [];
  int? currentAudioIndex;
  int? wordId;
  String? type;

  ManageEnglishContentManagementWordAudioModel? audioModel;
  bool wordPublishStatus = false;
  bool syllablePublishStatus = false;
  bool noNeedSyllables = false;

  List<bool> syllableOpenStatusList = [];

  AudioPlayerEx? audioPlayer; //音频播放器

  @override
  String get breadcrumbRoute => Routes.MANAGE_WORD_AUDIO;
  
  @override
  String get breadcrumbTitle => '发音管理';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if (Get.arguments != null) {
      currentAudioIndex = Get.arguments['currentAudioIndex'];
      audioList = Get.arguments['audioList'];
      wordId = Get.arguments['wordId'];
    }

    initAudioData();

    //初始化音频播放器
    audioPlayer = AudioPlayerEx();


  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    audioPlayer?.dispose();
    super.onClose();
  }


  /// 初始化数据
  void initAudioData() async {
    if (audioList == null || audioList!.isEmpty || currentAudioIndex == null || wordId == null) {
      return;
    }
    try {
      ToastUtils.showLoading();

      final ResponseEntity<ManageEnglishContentManagementWordAudioModel>? res = await ManageSelectQuziKnowledge.getWordAudioDetail(wordId!,
          parameters: {}, data: {"uid": audioList![currentAudioIndex!].uid, "accentId": audioList![currentAudioIndex!].accentId, "ipa": audioList![currentAudioIndex!].ipa});
      if (res == null) {
        return;
      }
      audioModel = res.data;
      dealIpaPositions();

      wordPublishStatus = audioModel?.wordPublished ?? false;
      audioList![currentAudioIndex!].wordPublished = audioModel?.wordPublished ?? false;
      syllablePublishStatus = audioModel?.soundBlockDTO?.published ?? false;
      noNeedSyllables = audioModel?.noNeedSyllables ?? false;
      audioList![currentAudioIndex!].syllablesPublished = audioModel?.soundBlockDTO?.published ?? false;

      syllableOpenStatusList.clear();
      for (var _ in audioModel!.soundBlockDTO!.syllables ?? []) {
        syllableOpenStatusList.add(true);
      }

      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //计算ipaPositions
  void dealIpaPositions() {
    int index = 0;
    String ipaStr = audioModel?.ipa ?? '';
    for (ManageEnglishContentManagementWordAudioSoundBlockDTOSyllableModel syllableModel in audioModel?.soundBlockDTO?.syllables ?? []) {
      List<int> ipaPositions = [];
      String syllableIpaStr = syllableModel.ipa ?? '';
      final firstIndex = ipaStr.indexOf(syllableIpaStr);
      if (firstIndex == -1) {
        continue;
      }
      for (int i = 0; i < syllableIpaStr.length; i++) {
        ipaPositions.add(index + firstIndex + i);
      }
      syllableModel.ipaPositions = ipaPositions;

      int subIndex = index + firstIndex;
      index += firstIndex + syllableIpaStr.length;
      ipaStr = ipaStr.substring(firstIndex + syllableIpaStr.length);

      for (ManageEnglishContentManagementWordAudioSoundBlockDTOSyllablePhonicModel phonicModel in syllableModel.phonics ?? []) {
        List<int> ipaPositions = [];
        String phonicIpaStr = phonicModel.ipa ?? '';
        final firstIndex = syllableIpaStr.indexOf(phonicIpaStr);
        if (firstIndex == -1) {
          continue;
        }
        for (int i = 0; i < phonicIpaStr.length; i++) {
          ipaPositions.add(subIndex + firstIndex + i);
        }
        phonicModel.ipaPositions = ipaPositions;

        subIndex += firstIndex + phonicIpaStr.length;
        syllableIpaStr = syllableIpaStr.substring(firstIndex + phonicIpaStr.length);
      }
    }
  }

  //播放音频
  void playAudio(String? audioUrl) {
    PlayAudioUtils.instance.playSingle(audioUrl);
  }

  //生成单词的AI音频
  void generateWordAiAudio() async {
    if (wordPublishStatus) {
      final ask = await AskDialog.showUserAsk(
        context: Get.context!,
        content: "该音频已发布，确认需要修改吗？",
        define: "继续修改",
        showCancel: true,
      );

      if (ask == false) {
        return;
      }
    }

    try {
      ToastUtils.showLoading();

      final ResponseEntity? res = await ManageSelectQuziKnowledge.generateAiAudio(parameters: {}, data: {
        "uid": audioModel!.uid,
        "contentType": audioModel!.contentType,
        "contentId": audioModel!.contentId,
        "accentId": audioModel!.accent?.uid,
      });
      if (res == null) {
        return;
      }

      final ask = await AskDialog.showAppDialog(
        context: Get.context!,
        title: "温馨提示",
        content: "音频正在生成中",
        showLastCountdown: true,
        showCancel: false,
      );
      if (ask) {
        initAudioData();
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //生成音节、音素的AI音频
  void generateSyllableAiAudio(String? ipa, String? graphemes, int syllableIndex, int? phonemeIndex) async {
    String? variant;
    if (phonemeIndex != null) {
      variant = audioModel!.soundBlockDTO!.syllables![syllableIndex].phonics![phonemeIndex].variant;

      if (audioModel!.soundBlockDTO!.syllables![syllableIndex].phonics![phonemeIndex].published == true) {
        final ask = await AskDialog.showUserAsk(
          context: Get.context!,
          content: "该音频已发布，确认需要修改吗？",
          define: "继续修改",
          showCancel: true,
        );

        if (ask == false) {
          return;
        }
      }
    } else {
      variant = audioModel!.soundBlockDTO!.syllables![syllableIndex].variant;

      if (audioModel!.soundBlockDTO!.syllables![syllableIndex].published == true) {
        final ask = await AskDialog.showUserAsk(
          context: Get.context!,
          content: "该音频已发布，确认需要修改吗？",
          define: "继续修改",
          showCancel: true,
        );

        if (ask == false) {
          return;
        }
      }
    }

    try {
      ToastUtils.showLoading();

      final ResponseEntity<ManageEnglishContentManagementWordAudioPhonemeModel>? res = await ManageSelectQuziKnowledge.generatePhonemeAiAudio(parameters: {}, data: {
        "ph": ipa,
        "text": graphemes,
        "accentId": audioModel!.accent?.uid,
        "contentId": audioModel!.contentId,
        "variant": variant,
      });
      if (res?.data == null) {
        return;
      }

      ManageEnglishContentManagementWordAudioPhonemeModel phonemeModel = res!.data!;
      if (phonemeModel.dialog == true) {
        final ask = await AskDialog.showAppDialog(
          context: Get.context!,
          title: "温馨提示",
          content: "音频正在生成中",
          showLastCountdown: true,
          showCancel: false,
        );
        if (ask) {
          initAudioData();
        }
      } else {
        initAudioData();
      }

      /*
      if (phonemeIndex != null) {
        //替换音素的音频信息
        ManageEnglishContentManagementWordAudioWordIpaModel ipaModel =
            ManageEnglishContentManagementWordAudioWordIpaModel();
        ipaModel.duration = phonemeModel.duration;
        ipaModel.size = phonemeModel.size;
        ipaModel.fileKey = phonemeModel.audio_key;

        ManageEnglishContentManagementWordAudioSoundBlockDTOSyllablePhonicModel
            phonicModel = audioModel!.soundBlockDTO!.syllables![syllableIndex]
                .phonics![phonemeIndex];
        phonicModel.url = phonemeModel.url;
        phonicModel.phoneme = ipaModel;
        phonicModel.published = false;

        audioModel!.soundBlockDTO!.syllables![syllableIndex]
            .phonics![phonemeIndex] = phonicModel;
      } else {
        //替换音节的音频信息
        ManageEnglishContentManagementWordAudioWordIpaModel ipaModel =
            ManageEnglishContentManagementWordAudioWordIpaModel();
        ipaModel.duration = phonemeModel.duration;
        ipaModel.size = phonemeModel.size;
        ipaModel.fileKey = phonemeModel.audio_key;

        ManageEnglishContentManagementWordAudioSoundBlockDTOSyllableModel
            syllableModel =
            audioModel!.soundBlockDTO!.syllables![syllableIndex];
        syllableModel.url = phonemeModel.url;
        syllableModel.phoneme = ipaModel;
        syllableModel.published = false;

        audioModel!.soundBlockDTO!.syllables![syllableIndex] = syllableModel;
      }

      syllablePublishStatus = false;
      audioModel!.soundBlockDTO!.published = false;
      audioList![currentAudioIndex!].syllablesPublished = false;
      update();
      */
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //AI划分音节、音素
  void aiDivisionSyllablePhoneme() async {
    try {
      ToastUtils.showLoading();

      final ResponseEntity<ManageEnglishContentManagementWordAudioSoundBlockDTOModel>? res = await ManageSelectQuziKnowledge.aiDivisionSyllablePhoneme(parameters: {}, data: {
        "uid": audioModel!.soundBlockDTO?.uid,
        "accentId": audioModel!.accent?.uid,
        "contentId": audioModel!.contentId,
        "audioId": audioModel!.uid,
      });
      if (res?.data == null) {
        return;
      }
      audioModel!.soundBlockDTO = res!.data;

      syllableOpenStatusList.clear();
      for (var _ in audioModel!.soundBlockDTO!.syllables ?? []) {
        syllableOpenStatusList.add(true);
      }
      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //修改音标
  void modifyPhonogram() async {
    final String? phonogram = await InputDialog.show(context: Get.context!, title: "修改音标", hintText: "请输入音标", realName: audioModel?.ipa ?? '');
    if (phonogram == null) {
      return;
    }
    audioModel!.ipa = phonogram;
    update();
  }

  //编辑单词
  void editWord() async {
    if (audioModel!.ipa == null) {
      ToastUtils.showManageToast(text: '单词的音标不能为空');
      return;
    }
    if (audioModel!.wordIpa == null) {
      ToastUtils.showManageToast(text: '单词的音频不能为空');
      return;
    }

    try {
      ToastUtils.showLoading();

      final ResponseEntity? res = await ManageSelectQuziKnowledge.editWord(parameters: {}, data: {
        "uid": audioModel!.uid,
        "fileKey": audioModel!.wordIpa?.fileKey,
        "duration": audioModel!.wordIpa?.duration,
        "size": audioModel!.wordIpa?.size,
        "ipa": audioModel!.ipa,
        "accentId": audioModel!.accent?.uid,
        "contentId": audioModel!.contentId,
      });
      if (res == null) {
        return;
      }
      ToastUtils.showManageToast(text: '单词保存成功');
      audioList![currentAudioIndex!].uid = (res.data as Map)['uid'] as int?;
      initAudioData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //保存单词
  void saveWord() async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "此操作会取消发布，您确定要进行此操作？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) {
      return;
    }
    editWord();
  }

  //发布单词
  void publishWord() async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "此操作会刷新界面，您确定要进行此操作？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) {
      return;
    }

    bool needTip = !wordPublishStatus;

    try {
      ToastUtils.showLoading();

      final ResponseEntity? res = await ManageSelectQuziKnowledge.publishWord(audioModel!.contentId!, audioModel!.uid!, parameters: {}, data: {
        "uid": audioModel!.uid,
        "accentId": audioModel!.accent?.uid,
      });
      if (res == null) {
        return;
      }

      initAudioData();
      if (needTip) {
        await AskDialog.showUserAsk(
          context: Get.context!,
          content: "发布成功",
          showCancel: false,
          define: "确认",
        );
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //编辑音节
  void editSyllable({bool needTip = false}) async {
    try {
      ToastUtils.showLoading();

      Map soundBlockDTO = audioModel!.soundBlockDTO!.toJson();
      Map<String, dynamic> data = {
        "uid": audioModel!.soundBlockDTO!.uid,
        "accentId": audioModel!.accent?.uid,
        "syllables": soundBlockDTO['syllables'],
        "contentId": audioModel!.contentId,
      };

      final ResponseEntity? res = await ManageSelectQuziKnowledge.editSyllable(parameters: {}, data: data);
      if (res?.data == null) {
        return;
      }
      syllablePublishStatus = false;

      initAudioData();
      if (needTip) {
        await AskDialog.showUserAsk(
          context: Get.context!,
          content: "保存成功",
          showCancel: false,
          define: "确认",
        );
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  // 保存音节
  void saveSyllable() async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "此操作会取消发布，您确定要进行此操作？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) {
      return;
    }
    editSyllable(needTip: true);
  }

  //发布音节
  void publishSyllable() async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "此操作会刷新界面，您确定要进行此操作？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) {
      return;
    }

    bool needTip = !syllablePublishStatus;

    try {
      ToastUtils.showLoading();

      Map soundBlockDTO = audioModel!.soundBlockDTO!.toJson();
      final ResponseEntity? res = await ManageSelectQuziKnowledge.publishSyllable(audioModel!.uid!, audioModel!.soundBlockDTO!.uid!, parameters: {}, data: {
        "uid": audioModel!.soundBlockDTO!.uid,
        "accentId": audioModel!.accent?.uid,
        "syllables": soundBlockDTO['syllables'],
        "contentId": audioModel!.contentId,
      });
      if (res == null) {
        return;
      }
      initAudioData();
      if (needTip) {
        await AskDialog.showUserAsk(
          context: Get.context!,
          content: "发布成功",
          showCancel: false,
          define: "确认",
        );
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //删除音节
  void deleteSyllable(int index) async {
    syllableOpenStatusList.removeAt(index);
    audioModel!.soundBlockDTO!.syllables!.removeAt(index);
    editSyllable();
  }

  //删除音素
  void deletePhoneme(int syllableIndex, int index) async {
    audioModel!.soundBlockDTO!.syllables![syllableIndex].phonics?.removeAt(index);
    editSyllable();
  }

  //上传音频
  void uploadAudio(BuildContext context, int type, {int? syllableIndex, int? index}) async {
    // 文件选择器
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );
    if (result == null) {
      return;
    }
    File file = File(result.files.single.path!);
    //加载音频资源到播放器
    await audioPlayer?.setSource(DeviceFileSource(file.path));

    //上传文件
    OssUpdateResponseEntity? record = await OssUploadFileUtils.uploadManageFile(
      filePath: file.path,
      fileModule: OssFileManageModule.enAudio,
      fileType: OssFileManageType.track,
    );
    
    if (record == null) return;

    //获取音频时长
    Duration? duration = await audioPlayer?.getDuration();
    double durationStr = duration != null ? double.parse((duration.inMilliseconds / 1000).toStringAsFixed(2)) : 0;

    //更新音频数据
    ManageEnglishContentManagementWordAudioWordIpaModel ipaModel = ManageEnglishContentManagementWordAudioWordIpaModel();
    ipaModel.fileKey = record.key;
    ipaModel.size = file.lengthSync();
    ipaModel.duration = durationStr;

    if (type == 1) {
      audioModel!.wordIpa = ipaModel;
      audioModel!.audioUrl = record.url;
      editWord();
    } else if (type == 2) {
      audioModel!.soundBlockDTO!.syllables![syllableIndex!].phoneme = ipaModel;
      audioModel!.soundBlockDTO!.syllables![syllableIndex].url = record.url;
      editSyllable();
    } else if (type == 3) {
      audioModel!.soundBlockDTO!.syllables![syllableIndex!].phonics![index!].phoneme = ipaModel;
      audioModel!.soundBlockDTO!.syllables![syllableIndex].phonics![index].url = record.url;
      editSyllable();
    }

    ToastUtils.showManageToast(text: '音频上传成功');
  }

  //下载音频
  void downLoad(String url, String name) async {
    String? path = await getTempDirPath();
    if (path == null) return;
    path += Platform.pathSeparator + name;
    WiseHttp().download(
      url,
      path,
      cancelToken: CancelToken(),
      onReceiveProgress: (count, total) {
        if (count >= total) {
          ToastUtils.showManageToast(text: '下载完成');
        }
      },
    );
  }

  Future<String?> getTempDirPath() async {
    if (Platform.isWindows || Platform.isMacOS) {
      return FilePicker.platform.getDirectoryPath();
    } else {
      // 其他平台（Android/iOS）
      return (await getTemporaryDirectory()).path + Platform.pathSeparator + "app";
    }
  }

  //新增音节
  void addSyllable(ManageEnglishContentManagementWordAudioModel? model) {
    List<ManageEnglishContentManagementWordAudioSoundBlockDTOSyllableModel>? syllables = model?.soundBlockDTO?.syllables;
    // 检查 phonics 是否非空并进行排序
    if (syllables != null) {
      syllables.sort((a, b) {
        // 获取 positions 的第一个元素进行比较
        int aPosition = (a.positions?.isNotEmpty ?? false) ? a.positions!.first : 0;
        int bPosition = (b.positions?.isNotEmpty ?? false) ? b.positions!.first : 0;
        return aPosition.compareTo(bPosition);
      });
    }

    audioModel = model;

    //因为不确定新增音节的顺序，所以每次进行新增音节操作，都把所有音节默认展开
    syllableOpenStatusList = [];
    for (var _ in audioModel!.soundBlockDTO!.syllables ?? []) {
      syllableOpenStatusList.add(true);
    }
    editSyllable();
  }

  //新增音素
  void addPhoneme(ManageEnglishContentManagementWordAudioModel? model, int syllableIndex) {
    List<ManageEnglishContentManagementWordAudioSoundBlockDTOSyllablePhonicModel>? phonics = model?.soundBlockDTO?.syllables?[syllableIndex].phonics;
    // 检查 phonics 是否非空并进行排序
    if (phonics != null) {
      phonics.sort((a, b) {
        // 获取 positions 的第一个元素进行比较
        int aPosition = (a.positions?.isNotEmpty ?? false) ? a.positions!.first : 0;
        int bPosition = (b.positions?.isNotEmpty ?? false) ? b.positions!.first : 0;
        return aPosition.compareTo(bPosition);
      });
    }
    audioModel = model;
    editSyllable();
  }

  //拼读积木、拼读拆解题型演示
  void questionExample(String type) async {
    ResponseEntity<List<QuizModel>>? responseEntity = await ManageSelectQuziKnowledge.getQuizList(
      data: {
        'contentType': audioModel!.contentType,
        "accentId": audioModel!.accent?.uid,
        "contentId": audioModel!.contentId,
        'exerciseTypes': [type],
      },
    );
    if (responseEntity?.data == null) return;
    List<QuizModel> list = responseEntity!.data!;

    if (list.isNotEmpty) {
      Get.toNamed(
        Routes.PRACTICE_QUESTIONS,
        preventDuplicates: false,
        arguments: {
          "quizDatas": list,
        },
      );
    } else {
      ToastUtils.showManageToast(text: '暂无相关题型');
    }
  }

  //无需发布按钮
  void noNeedPublish() async {
    try {
      ToastUtils.showLoading();

      final ResponseEntity? res = await ManageSelectQuziKnowledge.noNeedPublishWord(parameters: {}, data: {
        "uid": audioModel!.soundBlockDTO!.uid,
        "contentId": audioModel!.contentId,
        "audioId": audioModel!.uid,
        "noNeedSyllables": !noNeedSyllables,
      });
      if (res == null) {
        return;
      }
      noNeedSyllables = !noNeedSyllables;
      if (noNeedSyllables) {
        ToastUtils.showManageToast(text: '已设置为无需发布');
      } else {
        ToastUtils.showManageToast(text: '已设置为需要发布');
      }
      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

}
