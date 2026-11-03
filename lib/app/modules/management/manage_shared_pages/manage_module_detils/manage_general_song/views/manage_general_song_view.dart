import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/song_theme_entity.dart';
import 'package:langwise/utils/play_audio_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_general_song_binding.dart';
import '../controllers/manage_general_song_controller.dart';

class ManageGeneralSongView extends GetView<ManageGeneralSongController> {
  final String tagText;
  const ManageGeneralSongView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_GENERAL_SONG_PAGE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageGeneralSongView(tagText: tag),
      binding: ManageGeneralSongBinding(tag: tag),
      routeName: Routes.MANAGE_GENERAL_SONG_PAGE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Obx(() {
        if (controller.songUnitInfo.value == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final info = controller.songUnitInfo.value!.unitKnowledgeDTO;
        final knowledgeList = info!.knowledgeList ?? [];

        return Container(
          padding: EdgeInsets.all(16.wMin),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '歌曲生成',
                  style: TextStyle(fontSize: 22.wMin, color: const Color(0xFFEBEEF3)),
                ),
                SizedBox(height: 4.wMin),
                Text(
                  '选择歌曲数量和风格，AI将为您生成教学歌曲',
                  style: TextStyle(fontSize: 20.wMin, color: const Color(0xFFBAC0CC)),
                ),
                SizedBox(height: 24.wMin),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.wMin),
                    color: const Color(0xFF181B25),
                  ),
                  padding: EdgeInsets.all(16.wMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.unitName ?? '',
                        style: TextStyle(fontSize: 20.wMin, color: const Color(0xFFEBEEF3)),
                      ),
                      SizedBox(height: 12.wMin),
                      Text(
                        info.description ?? '',
                        style: TextStyle(fontSize: 14.wMin, color: const Color(0xFFBAC0CC)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.wMin),
                _songStyle(),
                SizedBox(height: 24.wMin),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.wMin),
                    color: const Color(0xFF181B25),
                  ),
                  padding: EdgeInsets.all(16.wMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '当前单元已有歌曲（${knowledgeList.length}首）',
                        style: TextStyle(fontSize: 20.wMin, color: const Color(0xFFEBEEF3)),
                      ),
                      SizedBox(height: 12.wMin),
                      Wrap(
                        spacing: 8.wMin,
                        runSpacing: 8.wMin,
                        children: List.generate(knowledgeList.length, (e) {
                          final mKnow = knowledgeList[e];
                          return Container(
                            width: 514.wMin,
                            padding: EdgeInsets.all(12.wMin),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.wMin),
                              color: const Color(0x59353E5C),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${mKnow.title}",
                                  style: TextStyle(fontSize: 16.wMin, color: Colors.white),
                                ),
                                SizedBox(height: 8.wMin),
                                Row(
                                  spacing: 8.wMin,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 3.wMin),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4.wMin),
                                        color: const Color(0x1F17C964),
                                      ),
                                      child: Text(
                                        '${mKnow.genre}',
                                        style: TextStyle(fontSize: 12.wMin, color: const Color(0xFF63DE77)),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 3.wMin),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4.wMin),
                                        color: const Color(0x1F2388FF),
                                      ),
                                      child: Text(
                                        '${mKnow.theme}',
                                        style: TextStyle(fontSize: 12.wMin, color: const Color(0xFF2388FF)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 12.wMin),
                      Text(
                        '生成新歌曲时，建议参考已有歌曲的风格和主题，保持内容多样性',
                        style: TextStyle(fontSize: 14.wMin, color: const Color(0xFFBAC0CC)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.wMin),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.wMin),
                    color: const Color(0xFF181B25),
                  ),
                  padding: EdgeInsets.all(16.wMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('使用说明', style: TextStyle(fontSize: 20.wMin, color: const Color(0xFFEBEEF3))),
                      SizedBox(height: 12.wMin),
                      Text('• 选择要生成的歌曲数量（1-12首）', style: TextStyle(fontSize: 14.wMin, color: const Color(0xFFBAC0CC))),
                      SizedBox(height: 4.wMin),
                      Text('• 选择一个或多个歌曲风格，AI将从中随机选择', style: TextStyle(fontSize: 14.wMin, color: const Color(0xFFBAC0CC))),
                      SizedBox(height: 4.wMin),
                      Text('• 风格越多样，生成的歌曲越丰富', style: TextStyle(fontSize: 14.wMin, color: const Color(0xFFBAC0CC))),
                      SizedBox(height: 4.wMin),
                      Text('• 生成过程可能需要几分钟，请耐心等待', style: TextStyle(fontSize: 14.wMin, color: const Color(0xFFBAC0CC))),
                    ],
                  ),
                ),
                SizedBox(height: 40.wMin),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _songStyle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: const Color(0xFF181B25),
      ),
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '歌曲数量',
            style: TextStyle(fontSize: 20.wMin, color: const Color(0xFFEBEEF3)),
          ),
          SizedBox(height: 12.wMin),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  controller.subSong();
                },
                child: Container(
                  width: 36.wMin,
                  height: 36.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    border: Border.all(color: const Color(0x662388FF)),
                  ),
                  child: SvgPicture.asset(
                    'assets/svg/manage/icon_minus_sign.svg',
                    width: 20.wMin,
                    height: 20.wMin,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 12.wMin, right: 12.wMin),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x662388FF)),
                  borderRadius: BorderRadius.circular(6.wMin),
                ),
                padding: EdgeInsets.symmetric(vertical: 4.wMin),
                alignment: Alignment.center,
                width: 74.wMin,
                child: TextFormField(
                  key: ValueKey(controller.songNumber.value),
                  textAlign: TextAlign.center,
                  controller: controller.songNumberController,
                  style: TextStyle(fontSize: 18.wMin, color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed == null) {
                      return;
                    }
                    final minVal = controller.songMin.value;
                    final maxVal = controller.songMax.value;
                    int newVal = parsed;
                    if (newVal < minVal) newVal = minVal;
                    if (newVal > maxVal) newVal = maxVal;
                    controller.songNumberController.text = newVal.toString();
                    controller.songNumber.value = newVal;
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.addSong();
                },
                child: Container(
                  width: 36.wMin,
                  height: 36.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    border: Border.all(color: const Color(0x662388FF)),
                  ),
                  child: SvgPicture.asset('assets/svg/manage/icon_add.svg', width: 20.wMin, height: 20.wMin),
                ),
              ),
              SizedBox(width: 12.wMin),
              Text(
                '首歌曲',
                style: TextStyle(fontSize: 14.wMin, color: const Color(0xFFBAC0CC)),
              ),
            ],
          ),
          SizedBox(height: 12.wMin),
          Obx(() => Text(
                'AI将从选中的风格中随机选择生成（${controller.songMin.value}-${controller.songMax.value} 首）',
                style: TextStyle(fontSize: 14.wMin, color: const Color(0xFFBAC0CC)),
              )),
          SizedBox(height: 12.wMin),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '歌曲风格',
                style: TextStyle(fontSize: 20.wMin, color: const Color(0xFFEBEEF3)),
              ),
              GestureDetector(
                onTap: () {
                  controller.toggleAllGenres();
                },
                child: Text('全选', style: TextStyle(fontSize: 20.wMin, color: const Color(0xFF2388FF))),
              ),
            ],
          ),
          SizedBox(height: 8.wMin),
          _songStyleList(),
          SizedBox(height: 8.wMin),
          Row(
            children: [
              Text('请至少选择一种曲风', style: TextStyle(fontSize: 16.wMin, color: Colors.white)),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    controller.createSongs();
                  },
                  child: Container(
                    width: 120.wMin,
                    height: 40.wMin,
                    margin: EdgeInsets.only(right: 16.wMin),
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.wMin),
                      color: const Color(0xFF2388FF),
                    ),
                    child: Text('开始生成', style: TextStyle(fontSize: 14.wMin, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _songStyleList() {
    final genres = controller.songUnitInfo.value?.genres ?? [];
    return Obx(() => Wrap(
          spacing: 8.wMin,
          runSpacing: 8.wMin,
          children: List.generate(genres.length, (index) {
            final mGenre = genres[index];
            final bool isSelected = controller.selectedGenreIndexes.contains(index);
            return GestureDetector(
              onTap: () {
                controller.toggleGenre(index);
              },
              child: Container(
                width: 384.wMin,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: isSelected ? const Color(0xFF2388FF).withAlpha(64) : const Color(0x59353E5C),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2388FF) : Colors.transparent,
                  ),
                ),
                padding: EdgeInsets.all(12.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            mGenre.name?.first.text ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16.wMin, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 6.wMin),
                        if ((mGenre.inUnitCount ?? 0) > 0)
                          Text(
                            '已生成${mGenre.inUnitCount}首',
                            style: TextStyle(fontSize: 16.wMin, color: const Color(0xFF2388FF)),
                          ),
                        const Spacer(),
                        Container(
                          width: 20.wMin,
                          height: 20.wMin,
                          margin: EdgeInsets.only(right: 8.wMin, top: 2.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.wMin),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2388FF) : const Color(0xFF6F7483),
                            ),
                            color: isSelected ? const Color(0xFF2388FF) : Colors.transparent,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 14.wMin,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4.wMin),
                      child: Text(
                        getZh(mGenre.description!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.wMin, color: const Color(0xFF767E95)),
                      ),
                    ),
                    SizedBox(height: 4.wMin),
                    GestureDetector(
                      onTap: () async {
                        var audioUrl = mGenre.audioUrl;

                        if (controller.isPlaying.value == index) {
                          controller.isPlaying.value = -1;
                          await PlayAudioUtils.instance.stopAll();
                        } else {
                          controller.isPlaying.value = index;
                          await PlayAudioUtils.instance.playSingle(audioUrl);
                        }
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 7.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.wMin),
                            color: controller.isPlaying.value == index ? const Color(0x1F17C964) : const Color(0x1F2388FF),
                          ),
                          child: Text(
                            controller.isPlaying.value == index ? '播放中' : '试听',
                            style: TextStyle(
                              fontSize: 12.wMin,
                              color: controller.isPlaying.value == index ? const Color(0xFF63DE77) : const Color(0xFF2388FF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ));
  }

  String getZh(List<LangTextEntity> list) {
    for (var item in list) {
      if (item.lang == 'zh') {
        return item.text!;
      }
    }
    return '';
  }
}
