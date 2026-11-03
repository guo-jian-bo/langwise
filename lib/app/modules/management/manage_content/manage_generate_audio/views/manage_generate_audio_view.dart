import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/generated/assets.dart';

import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_generate_audio_binding.dart';
import '../controllers/manage_generate_audio_controller.dart';

class ManageGenerateAudioView extends GetView<ManageGenerateAudioController> {
  final String tagText;
  const ManageGenerateAudioView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_GENERATE_AUDIO}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageGenerateAudioView(tagText: tag),
      binding: ManageGenerateAudioBinding(tag: tag),
      routeName: Routes.MANAGE_GENERATE_AUDIO,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFF0E0F0F),
        body: GetBuilder(
          init: controller,
          builder: (_) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              margin: EdgeInsets.all(16.wMin),
              padding: EdgeInsets.all(20.wMin),
              decoration: BoxDecoration(
                color: const Color(0xFF181B25),
                borderRadius: BorderRadius.circular(12.wMin),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "生成模式",
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: const Color(0xffEBEEF3),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 15.wMin),
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: _buildItem(
                              title: "文本模式",
                              index: 0,
                              mode: 'mode',
                            ),
                          ),
                          SizedBox(width: 20.wMin),
                          Expanded(
                            child: _buildItem(
                              title: "音标模式",
                              index: 1,
                              mode: 'mode',
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 30.wMin),
                    Text(
                      "生成平台",
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: const Color(0xffEBEEF3),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 15.wMin),
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: _buildItem(
                              title: "字节跳动",
                              index: 0,
                              mode: 'platform',
                            ),
                          ),
                          SizedBox(width: 20.wMin),
                          Expanded(
                            child: _buildItem(
                              title: "微软 Azure",
                              index: 1,
                              mode: 'platform',
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 30.wMin),
                    Text(
                      "音色选择",
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: const Color(0xffEBEEF3),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 15.wMin),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.isCustomSound.value =
                                !controller.isCustomSound.value;
                          },
                          child: Obx(
                            () => Container(
                              width: 22.wMin,
                              height: 22.wMin,
                              decoration: BoxDecoration(
                                color: controller.isCustomSound.value
                                    ? const Color(0xFF4285F4)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4.wMin),
                                border: !controller.isCustomSound.value
                                    ? Border.all(
                                        color: const Color(0xFF616B85),
                                        width: 1.wMin)
                                    : null,
                              ),
                              child: controller.isCustomSound.value
                                  ? Icon(Icons.check,
                                      color: Colors.white, size: 16.wMin)
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.wMin),
                        Text(
                          "使用自定义音色",
                          style: TextStyle(
                            fontSize: 14.wMin,
                            color: const Color(0xFFBAC0CC),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.wMin),
                    Obx(
                      () => !controller.isCustomSound.value
                          ? ManageSelectWidget(
                              height: 60.wMin,
                              hintText: '请选择音色',
                              value: controller.soundList.isNotEmpty
                                  ? controller.soundList[
                                      controller.selectedAccentIndex.value]
                                  : null,
                              readOnly: false,
                              required: false,
                              options: controller.soundList,
                              onChanged: (String value, int index) {
                                controller.selectedAccentIndex.value = index;
                              },
                            )
                          : ManageTitleInputWidget(
                              height: 60.wMin,
                              hintText: '请输入自定义音色',
                              required: false,
                              controller: controller.customSoundController,
                              readOnly: false,
                            ),
                    ),
                    Obx(
                      () => Visibility(
                        visible: controller.selectedMode.value == 1,
                        child: Column(
                          children: [
                            SizedBox(height: 30.wMin),
                            ManageTitleInputWidget(
                              height: 60.wMin,
                              title: "输入音标",
                              hintText: '例如:/ha\'lou/',
                              required: false,
                              controller: controller.phoneticController,
                              readOnly: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30.wMin),
                    ManageTitleInputWidget(
                      height: 60.wMin,
                      title: "输入文本",
                      hintText: '例如:Hello, world!',
                      required: false,
                      controller: controller.textController,
                      readOnly: false,
                    ),
                    SizedBox(height: 30.wMin),
                    ManageAuthBoxWidget(
                      authCodes: const [ManageAuthCode.audioCustomGenerate],
                      child: GestureDetector(
                        onTap: () {
                          controller.generateAudio();
                        },
                        child: Container(
                          height: 50.wMin,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4285F4),
                            borderRadius: BorderRadius.circular(8.wMin),
                          ),
                          child: Center(
                            child: Text(
                              "生成音频",
                              style: TextStyle(
                                fontSize: 14.wMin,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: controller.audioModel != null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 50.wMin),
                          Text(
                            "生成结果",
                            style: TextStyle(
                              fontSize: 14.wMin,
                              color: const Color(0xffEBEEF3),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 20.wMin),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF23283D), //#23283D
                              borderRadius: BorderRadius.circular(28.wMin),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 15.wMin),
                            height: 56.wMin,
                            child: Row(
                              children: [
                                // 播放按钮
                                Obx(
                                  () => GestureDetector(
                                    onTap: () {
                                      controller.audioPlayAndPause();
                                    },
                                    child: Icon(
                                      controller.playStatus.value
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 30.wMin,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.wMin),
                                // 时间文本
                                Obx(
                                  () => Text(
                                    "${DateFormatUtil.convertMillisecondsToSeconds(controller.currentTime.value)} / ${DateFormatUtil.convertMillisecondsToSeconds(controller.totalDurationTime.value)}",
                                    style: TextStyle(
                                      fontSize: 16.wMin,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.wMin),
                                // 进度条
                                Expanded(
                                  child: Obx(
                                    () => SliderTheme(
                                      data: SliderThemeData(
                                        trackHeight: 2.wMin,
                                        thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: 4.wMin),
                                        overlayShape:
                                            SliderComponentShape.noOverlay,
                                        inactiveTrackColor:
                                            Colors.grey.shade600,
                                        activeTrackColor: Colors.grey.shade300,
                                        thumbColor: Colors.white,
                                      ),
                                      child: Slider(
                                        value: controller.progress.value,
                                        onChangeEnd: (v) {
                                          controller.setAudioPosition(v);
                                        },
                                        onChanged: (v) {
                                          controller.progress.value = v;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30.wMin),
                          GestureDetector(
                            onTap: () {
                              controller.downloadAudioFile();
                            },
                            child: Container(
                              height: 50.wMin,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF353E5C),
                                borderRadius: BorderRadius.circular(8.wMin),
                              ),
                              child: Center(
                                child: Text(
                                  "下载音频",
                                  style: TextStyle(
                                    fontSize: 14.wMin,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
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
          },
        ),
    );
  }

  Widget _buildItem({
    required String title,
    required int index,
    required String mode,
  }) {
    bool isSelected = mode == 'mode'
        ? controller.selectedMode.value == index
        : controller.selectedPlatform.value == index;
    return GestureDetector(
      onTap: () {
        if (mode == 'mode') {
          controller.selectedMode.value = index;
        } else {
          controller.selectedPlatform.value = index;
          controller.initServiceData();
        }
      },
      child: Container(
        height: 60.wMin,
        padding: EdgeInsets.symmetric(
          vertical: 12.wMin,
          horizontal: 20.wMin,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2E344E),
          borderRadius: BorderRadius.circular(8.wMin),
          border: Border.all(
            width: 1.wMin,
            color: isSelected
                ? const Color.fromRGBO(35, 136, 255, 0.65)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.wMin,
                color: const Color(0xffEBEEF3),
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            isSelected
                ? SvgPicture.asset(
                    Assets.publicIconRadio,
                    width: 22.wMin,
                    colorFilter: const ColorFilter.mode(
                      Color.fromRGBO(35, 136, 255, 0.65),
                      BlendMode.srcIn,
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
  
}
