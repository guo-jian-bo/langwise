import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_word_audio_binding.dart';
import '../controllers/manage_word_audio_controller.dart';
import 'manage_en_word_audio_phoneme_dialog.dart';
import 'manage_en_word_audio_syllable_dialog.dart';

class ManageWordAudioView extends GetView<ManageWordAudioController> {
  final String tagText;
  const ManageWordAudioView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_WORD_AUDIO}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageWordAudioView(tagText: tag),
      binding: ManageWordAudioBinding(tag: tag),
      routeName: Routes.MANAGE_WORD_AUDIO,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: ManageScaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: const Color(0xff050916),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Column(
                children: [
                  SizedBox(
                    height: 100.wMin,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            color: Colors.grey[500],
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 30.wMin, top: 20.wMin, right: 30.wMin),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 80.wMin,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: controller.audioList?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildAudioCard(index),
                                          SizedBox(width: 30.wMin),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 20.wMin),
                              SelectableText(
                                '单词: ${controller.audioModel?.content}',
                                style: TextStyle(
                                  fontSize: 18.wMin,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10.wMin),
                              SelectableText(
                                'ID: ${controller.audioModel?.contentId}',
                                style: TextStyle(
                                  fontSize: 18.wMin,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10.wMin),
                              SelectableText(
                                'AudioID: ${controller.audioModel?.uid}',
                                style: TextStyle(
                                  fontSize: 18.wMin,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildAudioContent(context)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 音频内容
  Widget _buildAudioContent(context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 100.wMin),
      child: Padding(
        padding: EdgeInsets.all(15.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${controller.audioModel?.accent?.name} (${controller.audioModel?.accent?.national})',
              style: TextStyle(
                fontSize: 22.wMin,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10.wMin),
            Text(
              controller.audioModel?.accent?.description ?? '',
              style: TextStyle(
                fontSize: 15.wMin,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 15.wMin),
            Container(
              padding: EdgeInsets.all(20.wMin),
              decoration: BoxDecoration(
                color: const Color(0xFF181B25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.volume_up_rounded,
                            color: Colors.white,
                            size: 24.wMin,
                          ),
                          SizedBox(width: 8.wMin),
                          Text(
                            '单词发音',
                            style: TextStyle(
                              fontSize: 18.wMin,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Wrap(
                        children: [
                          Visibility(
                            visible: controller.audioModel?.audioUrl?.isNotEmpty == true,
                            child: GestureDetector(
                              onTap: () {
                                controller.playAudio(controller.audioModel?.audioUrl);
                              },
                              child: _buildActionIcon(const Color(0xFF10B981), Icons.play_arrow),
                            ),
                          ),
                          ManageAuthBoxWidget(
                            authCodes: const [ManageAuthCode.audioGenerate],
                            margin: EdgeInsets.only(left: 8.wMin),
                            child: GestureDetector(
                              onTap: () {
                                controller.generateWordAiAudio();
                              },
                              child: _buildActionIcon(const Color(0xFF3B82F6), Icons.auto_awesome),
                            ),
                          ),
                          ManageAuthBoxWidget(
                            authCodes: const [ManageAuthCode.audioWordEdit],
                            margin: EdgeInsets.only(left: 8.wMin),
                            child: GestureDetector(
                              onTap: () {
                                //上传
                                controller.uploadAudio(context, 1);
                              },
                              child: _buildActionIcon(const Color(0xFF8B5CF6), Icons.upload),
                            ),
                          ),
                          SizedBox(width: 8.wMin),
                          GestureDetector(
                            onTap: () {
                              //下载
                              DateTime now = DateTime.now();
                              String timestamp = now.millisecondsSinceEpoch.toString();
                              controller.downLoad(
                                controller.audioModel?.audioUrl ?? '',
                                '${controller.audioModel?.content}$timestamp.mp3',
                              );
                            },
                            child: _buildActionIcon(const Color(0xFFFF781F), Icons.download),
                          ),
                          ManageAuthBoxWidget(
                            authCodes: const [ManageAuthCode.audioWordIpaPublish],
                            margin: EdgeInsets.only(left: 8.wMin),
                            child: GestureDetector(
                              onTap: () {
                                controller.publishWord();
                              },
                              child: _buildActionWidget(controller.wordPublishStatus == true ? '已发布' : '发布', controller.wordPublishStatus == true ? Colors.green : Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.wMin),
                  Container(
                    padding: EdgeInsets.all(50.wMin),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22293C),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          controller.audioModel?.content ?? '',
                          style: TextStyle(
                            fontSize: 40.wMin,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10.wMin),
                        GestureDetector(
                          onTap: () {
                            controller.modifyPhonogram();
                          },
                          child: Text(
                            controller.audioModel?.ipa ?? '',
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'AndikaRegular',
                            ),
                          ),
                        ),
                        SizedBox(height: 20.wMin),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ManageAuthBoxWidget(
                              authCodes: const [ManageAuthCode.audioWordEdit],
                              child: GestureDetector(
                                onTap: () {
                                  controller.saveWord();
                                },
                                child: _buildActionWidget('保存', const Color.fromRGBO(255, 255, 255, 0.10)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.wMin),
            Container(
              padding: EdgeInsets.all(20.wMin),
              decoration: BoxDecoration(
                color: const Color(0xFF181B25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24.wMin,
                      ),
                      SizedBox(width: 8.wMin),
                      Text(
                        '音节划分',
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 20.wMin),
                      Container(
                        padding: EdgeInsets.all(5.wMin),
                        decoration: BoxDecoration(
                          color: const Color(0xFF004990),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SvgPicture.asset(
                          "assets/svg/manage/icon_websters.svg",
                          width: 26.wMin,
                          height: 26.wMin,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      SizedBox(width: 20.wMin),
                      ...List.generate(
                        controller.audioModel?.websters?.length ?? 0,
                        (index) => Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.wMin,
                                vertical: 2.wMin,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF393F5A),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                controller.audioModel?.websters?[index] ?? '',
                                style: TextStyle(
                                  fontSize: 18.wMin,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.wMin),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ManageAuthBoxWidget(
                        authCodes: const [ManageAuthCode.audioWordExerciseList],
                        child: Row(
                          children: [
                            ManageButton(
                              text: "拼读积木",
                              width: 120.wMin,
                              height: 50.wMin,
                              color: const Color(0xFF393F5A),
                              borderColor: Colors.transparent,
                              style: TextStyle(
                                fontSize: 20.wMin,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                              onTap: () {
                                controller.questionExample('SOUND_BLOCKS');
                              },
                            ),
                            SizedBox(width: 20.wMin),
                            ManageButton(
                              text: "拼读拆解",
                              width: 120.wMin,
                              height: 50.wMin,
                              color: const Color(0xFF393F5A),
                              borderColor: Colors.transparent,
                              style: TextStyle(
                                fontSize: 20.wMin,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                              onTap: () {
                                controller.questionExample('PRONUNCIATION_BREAKDOWN');
                              },
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ManageAuthBoxWidget(
                        authCodes: const [ManageAuthCode.audioWordBlockMark],
                        child: ManageButton(
                          text: controller.noNeedSyllables == true ? "音节无需发布" : "音节需要发布",
                          width: 150.wMin,
                          height: 50.wMin,
                          color: const Color(0xFF393F5A),
                          borderColor: Colors.transparent,
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                          onTap: () {
                            controller.noNeedPublish();
                          },
                        ),
                      ),
                      const Spacer(),
                      ManageAuthBoxWidget(
                        authCodes: const [ManageAuthCode.audioSoundBlocks],
                        child: GestureDetector(
                          onTap: () {
                            controller.aiDivisionSyllablePhoneme();
                          },
                          child: _buildActionWidget('AI划分', Colors.purple, icon: Icons.auto_awesome),
                        ),
                      ),
                      ManageAuthBoxWidget(
                        authCodes: const [ManageAuthCode.audioWordIpaBlockPublish],
                        margin: EdgeInsets.only(left: 10.wMin),
                        child: GestureDetector(
                          onTap: () {
                            controller.publishSyllable();
                          },
                          child: _buildActionWidget(controller.syllablePublishStatus == true ? '已发布' : '发布', controller.syllablePublishStatus == true ? Colors.green : Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.wMin),
                  Container(
                    padding: EdgeInsets.all(20.wMin),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22293C),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.audioModel?.soundBlockDTO?.syllables?.length ?? 0,
                          itemBuilder: (context, index) {
                            return _buildSyllableCell(index, context);
                          },
                        ),
                        SizedBox(height: 20.wMin),
                        ManageAuthBoxWidget(
                          authCodes: const [ManageAuthCode.audioWordBlockEdit],
                          child: GestureDetector(
                            onTap: () {
                              controller.saveSyllable();
                            },
                            child: _buildActionWidget('保存', const Color.fromRGBO(255, 255, 255, 0.10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.wMin),
                  ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.audioWordBlockEdit],
                    child: GestureDetector(
                      onTap: () async {
                        //添加音节
                        ManageEnglishContentManagementWordAudioModel? model = await ManageEnWordAudioSyllableDialog.show(
                          context: Get.context!,
                          item: controller.audioModel!,
                        );
                        if (model != null) {
                          //添加音节
                          controller.addSyllable(model);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(20.wMin),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22293C),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 24.wMin, color: Colors.white),
                              SizedBox(width: 4.wMin),
                              Text(
                                '添加分类',
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 音节项
  Widget _buildSyllableCell(int index, context) {
    final syllable = controller.audioModel?.soundBlockDTO?.syllables?[index];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1725),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20.wMin),
            onTap: () {
              controller.syllableOpenStatusList[index] = !controller.syllableOpenStatusList[index];
              controller.update();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Text(
                    syllable?.graphemes ?? '',
                    style: TextStyle(fontSize: 28.wMin, color: Colors.white),
                  ),
                  const SizedBox(width: 30),
                  Text(
                    '/${syllable?.ipa ?? ''}/',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 20.wMin,
                      fontFamily: 'AndikaRegular',
                    ),
                  ),
                  const SizedBox(width: 5),
                  Visibility(
                    visible: syllable?.variant != null,
                    child: GestureDetector(
                      onTap: () {
                        if (syllable?.variant == 'LIGHT') {
                          controller.audioModel?.soundBlockDTO?.syllables?[index].variant = 'DARK';
                        } else {
                          controller.audioModel?.soundBlockDTO?.syllables?[index].variant = 'LIGHT';
                        }
                        controller.update();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.wMin),
                          border: Border.all(color: Colors.blue, width: 1),
                        ),
                        child: Text(
                          syllable?.variant ?? '',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14.wMin,
                            fontFamily: 'AndikaRegular',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Text(
                    syllable?.positions?.isNotEmpty == true ? '位置: ${syllable?.positions?.join(",")}' : '',
                    style: TextStyle(color: Colors.white54, fontSize: 16.wMin),
                  ),
                  const Spacer(),
                  Visibility(
                    visible: syllable?.published == true,
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18.wMin,
                        ),
                        SizedBox(width: 4.wMin),
                        Text(
                          '已发布',
                          style: TextStyle(color: Colors.green, fontSize: 16.wMin),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.wMin),
                  Visibility(
                    visible: syllable?.url?.isNotEmpty == true,
                    child: GestureDetector(
                      onTap: () {
                        controller.playAudio(syllable?.url);
                      },
                      child: _buildActionIcon(const Color(0xFF10B981), Icons.play_arrow),
                    ),
                  ),
                  ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.audioPhoneme],
                    margin: EdgeInsets.only(left: 6.wMin),
                    child: GestureDetector(
                      onTap: () {
                        controller.generateSyllableAiAudio(syllable?.ipa, syllable?.graphemes, index, null);
                      },
                      child: _buildActionIcon(const Color(0xFF3B82F6), Icons.auto_awesome),
                    ),
                  ),
                  ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.audioWordBlockEdit],
                    margin: EdgeInsets.only(left: 6.wMin),
                    child: GestureDetector(
                      onTap: () {
                        //上传
                        controller.uploadAudio(context, 2, syllableIndex: index);
                      },
                      child: _buildActionIcon(const Color(0xFF8B5CF6), Icons.upload),
                    ),
                  ),
                  SizedBox(width: 6.wMin),
                  GestureDetector(
                    onTap: () {
                      //下载
                      DateTime now = DateTime.now();
                      String timestamp = now.millisecondsSinceEpoch.toString();
                      controller.downLoad(
                        syllable?.url ?? '',
                        '${syllable?.graphemes}$timestamp.mp3',
                      );
                    },
                    child: _buildActionIcon(const Color(0xFFFF781F), Icons.download),
                  ),
                  ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.audioWordBlockEdit],
                    margin: EdgeInsets.only(left: 6.wMin),
                    child: GestureDetector(
                      onTap: () {
                        //删除音节
                        controller.deleteSyllable(index);
                      },
                      child: _buildActionIcon(const Color(0xFFEC4899), Icons.delete),
                    ),
                  ),
                  SizedBox(width: 6.wMin),
                  Icon(
                    controller.syllableOpenStatusList[index] ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          if (controller.syllableOpenStatusList[index]) const Divider(height: 1, color: Colors.white12),
          if (controller.syllableOpenStatusList[index])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '音素列表',
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w700,
                          color: Colors.white54,
                        ),
                      ),
                      const Spacer(),
                      ManageAuthBoxWidget(
                        authCodes: const [ManageAuthCode.audioWordBlockEdit],
                        child: GestureDetector(
                          onTap: () async {
                            //添加音素
                            ManageEnglishContentManagementWordAudioModel? model = await ManageEnWordAudioPhonemeDialog.show(
                              context: Get.context!,
                              item: controller.audioModel!,
                              syllableIndex: index,
                            );
                            if (model != null) {
                              controller.addPhoneme(model, index);
                            }
                          },
                          child: _buildActionWidget('添加音素', const Color(0xFF22293C), icon: Icons.add),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.wMin),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: syllable?.phonics?.length ?? 0,
                    itemBuilder: (context, subIndex) {
                      return _buildPhonemeCell(subIndex, syllable, index, context);
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 音素项
  Widget _buildPhonemeCell(int index, ManageEnglishContentManagementWordAudioSoundBlockDTOSyllableModel? syllable, int syllableIndex, context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.wMin),
      padding: EdgeInsets.all(15.wMin),
      decoration: BoxDecoration(
        color: const Color(0xFF22293C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '${syllable!.phonics![index].graphemes}',
            style: TextStyle(fontSize: 28.wMin, color: Colors.white),
          ),
          const SizedBox(width: 30),
          Text(
            'IPA:${syllable.phonics![index].ipa}',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20.wMin,
              fontFamily: 'AndikaRegular',
            ),
          ),
          const SizedBox(width: 5),
          Visibility(
            visible: syllable.phonics?[index].variant != null,
            child: GestureDetector(
              onTap: () {
                if (syllable.phonics?[index].variant == 'LIGHT') {
                  controller.audioModel?.soundBlockDTO?.syllables?[syllableIndex].phonics?[index].variant = 'DARK';
                } else {
                  controller.audioModel?.soundBlockDTO?.syllables?[syllableIndex].phonics?[index].variant = 'LIGHT';
                }
                controller.update();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.wMin),
                  border: Border.all(color: Colors.blue, width: 1),
                ),
                child: Text(
                  syllable.phonics?[index].variant ?? '',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14.wMin,
                    fontFamily: 'AndikaRegular',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 30),
          Text(
            syllable.phonics?[index].positions?.isNotEmpty == true ? '位置: ${syllable.phonics?[index].positions?.join(",")}' : '',
            style: TextStyle(color: Colors.white54, fontSize: 16.wMin),
          ),
          const Spacer(),
          Visibility(
            visible: syllable.phonics?[index].published == true,
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 18.wMin,
                ),
                SizedBox(width: 4.wMin),
                Text(
                  '已发布',
                  style: TextStyle(color: Colors.green, fontSize: 16.wMin),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.wMin),
          Visibility(
            visible: syllable.phonics?[index].url?.isNotEmpty == true,
            child: GestureDetector(
              onTap: () {
                controller.playAudio(syllable.phonics?[index].url);
              },
              child: _buildActionIcon(const Color(0xFF10B981), Icons.play_arrow),
            ),
          ),
          SizedBox(width: 6.wMin),
          Visibility(
            visible: syllable.phonics?[index].ipa?.isNotEmpty == true,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.audioPhoneme],
              child: GestureDetector(
                onTap: () {
                  controller.generateSyllableAiAudio(syllable.phonics?[index].ipa, syllable.phonics?[index].graphemes, syllableIndex, index);
                },
                child: _buildActionIcon(const Color(0xFF3B82F6), Icons.auto_awesome),
              ),
            ),
          ),
          SizedBox(width: 6.wMin),
          Visibility(
            visible: syllable.phonics?[index].ipa?.isNotEmpty == true,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.audioWordBlockEdit],
              child: GestureDetector(
                onTap: () {
                  //上传
                  controller.uploadAudio(context, 3, syllableIndex: syllableIndex, index: index);
                },
                child: _buildActionIcon(const Color(0xFF8B5CF6), Icons.upload),
              ),
            ),
          ),
          SizedBox(width: 6.wMin),
          Visibility(
            visible: syllable.phonics?[index].url?.isNotEmpty == true,
            child: GestureDetector(
              onTap: () {
                //下载
                DateTime now = DateTime.now();
                String timestamp = now.millisecondsSinceEpoch.toString();
                controller.downLoad(
                  syllable.phonics?[index].url ?? '',
                  '${syllable.phonics![index].graphemes}$timestamp.mp3',
                );
              },
              child: _buildActionIcon(const Color(0xFFFF781F), Icons.download),
            ),
          ),
          SizedBox(width: 6.wMin),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.audioWordBlockEdit],
            child: GestureDetector(
              onTap: () {
                //删除音素
                controller.deletePhoneme(syllableIndex, index);
              },
              child: _buildActionIcon(const Color(0xFFEC4899), Icons.delete),
            ),
          ),
        ],
      ),
    );
  }

  /// 通用文字按钮
  Widget _buildActionWidget(String title, Color color, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 10.wMin),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 18.wMin, color: Colors.white),
          if (icon != null) SizedBox(width: 4.wMin),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.wMin,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 通用图标按钮
  Widget _buildActionIcon(Color color, IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  /// 顶部音频切换组件
  Widget _buildAudioCard(int index) {
    return GestureDetector(
      onTap: () {
        controller.currentAudioIndex = index;
        controller.update();
        controller.initAudioData();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: controller.currentAudioIndex == index ? Colors.blue : Colors.transparent, // 边框颜色
              width: 1.0, // 边框宽度
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${controller.audioList![index].name ?? ''} (${controller.audioList![index].accent ?? ''})',
              style: TextStyle(
                fontSize: 18.wMin,
                color: controller.currentAudioIndex == index ? Colors.blue : Colors.white,
              ),
            ),
            SizedBox(height: 10.wMin),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      controller.audioList![index].wordPublished ?? false ? Icons.check_circle : Icons.check_circle_outline,
                      color: controller.audioList![index].wordPublished ?? false ? Colors.green : Colors.grey,
                      size: 16.wMin,
                    ),
                    SizedBox(width: 4.wMin),
                    Text(
                      '单词',
                      style: TextStyle(color: controller.audioList![index].wordPublished ?? false ? Colors.green : Colors.grey, fontSize: 12.wMin),
                    ),
                  ],
                ),
                SizedBox(width: 10.wMin),
                Row(
                  children: [
                    Icon(
                      controller.audioList![index].syllablesPublished ?? false ? Icons.check_circle : Icons.check_circle_outline,
                      color: controller.audioList![index].syllablesPublished ?? false ? Colors.green : Colors.grey,
                      size: 16.wMin,
                    ),
                    SizedBox(width: 4.wMin),
                    Text(
                      '音节',
                      style: TextStyle(color: controller.audioList![index].syllablesPublished ?? false ? Colors.green : Colors.grey, fontSize: 12.wMin),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.wMin),
          ],
        ),
      ),
    );
  }
}
