import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../../theme/theme.dart';
import '../../../../../../../routes/routes.dart';
import '../../../../../common/commons.dart';
import '../bindings/manage_create_audio_project_binding.dart';
import '../controllers/manage_create_audio_project_controller.dart';
import 'manage_create_audio_project_script_item_widget.dart';

class ManageCreateAudioProjectView extends GetView<ManageCreateAudioProjectController> {
  final String tagText;
  const ManageCreateAudioProjectView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CREATE_AUDIO_PROJECT}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageCreateAudioProjectView(tagText: tag),
      binding: ManageCreateAudioProjectBinding(tag: tag),
      routeName: Routes.MANAGE_CREATE_AUDIO_PROJECT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 150.wMin,
              right: 150.wMin,
              top: 10.wMin,
              bottom: 24.wMin + 90.wMin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSelectScriptWidget()),
                _buildAudioNumberWidget(),
              ],
            ),
          ),
          Positioned(
            right: 8.wMin,
            bottom: 200.wMin,
            child: _buildToolButtonsWidget(),
          ),
        ],
      ),
      floatingActionButton: _buildFilterWidget(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context){
    return Obx((){
      return FilterStripWidget(
        sorts: {...controller.filterSorts},
        conditions: {...controller.filterConditions},
        searchs: controller.filterSearchs,
        onSorts: (sorts) {
          controller.filterSorts.value = sorts;
          controller.getScriptDataList();
        },
        onConditions: (conditions) {
          controller.filterConditions.value = conditions;
          controller.getScriptDataList();
        },
        onReset: (sorts, conditions) {
          controller.filterSorts.value = sorts;
          controller.filterConditions.value = conditions;
          controller.getScriptDataList();
        },
        onSearch: () {
          controller.getScriptDataList();
        },
      );
    });
  }

  /// 工具按钮
  Widget _buildToolButtonsWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        ButtonWidget(
          text: "创建音频项目",
          padding: EdgeInsets.symmetric(horizontal: 10.wMin),
          height: 44.wMin,
          color: const Color(0xff00bc7d).withValues(alpha: 0.2),
          border: Border.all(width: 1.wMin, color: const Color(0xff00bc7d)),
          borderRadius: 8.wMin,
          fontSize: 18.wMin,
          fontColor: const Color(0xff00bc7d),
          sclae: 1.03,
          onTap: OptimizeUtils.noneThrottle(() {
            controller.createAudioProject();
          }, 300),
        ),
      ],
    );
  }

  /// 选择剧本
  Widget _buildSelectScriptWidget(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "选择剧本",
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Obx((){
                return AnimatedToggleSwitch<int>.size(
                  current: controller.scriptType.value,
                  values: const [0, 1, 2],
                  indicatorSize: Size.fromWidth(150.wMin),
                  height: 54.wMin,
                  iconBuilder: (index){
                    List<String> modeList = ['全部', '单元剧本', '词汇剧本'];
                    return Text(
                      modeList[index],
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                  borderWidth: 6.wMin,
                  iconAnimationType: AnimationType.onHover,
                  iconOpacity: 1,
                  selectedIconScale: 1,
                  animationDuration: const Duration(milliseconds: 200),
                  style: ToggleStyle(
                    borderColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(10.wMin),
                    backgroundColor: AppTheme.cSurfaceTertiary.color,
                    indicatorBorderRadius: BorderRadius.circular(8.wMin),
                    indicatorColor: AppTheme.cSurfaceQuaternary.color,
                  ),
                  onChanged: (i) {
                    controller.scriptType.value = i;
                    controller.refreshScriptListData();
                  },
                );
              }),
            ],
          ),

          SizedBox(height: 16.wMin),

          Container(
            height: 54.wMin,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.wMin),
              color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.1),
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSuccess.color),
            ),
            child: Obx((){

              String title = controller.selectScriptData.value?.title?.firstWhereOrNull((e) => e?.lang == "en")?.text??"";
              int? uid = controller.selectScriptData.value?.uid;

              if(uid == null){
                return SelectableText(
                  "请选择剧本",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cFeedbackWarningText.color,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }

              return SelectableText(
                "已选择：$title （uid: $uid）",
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cFeedbackSuccessText.color,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ),

          SizedBox(height: 16.wMin),

          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.wMin),
              child: Container(
                color: AppTheme.cSurfaceSecondary.color,
                child: Obx((){
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
                    controller: controller.scriptScrollController,
                    itemCount: controller.scriptList.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
                    itemBuilder: (context, index) {
                      return ManageCreateAudioProjectScriptItemWidget(
                        controller: controller,
                        data: controller.scriptList[index],
                      );
                    },
                  );
                }),
              ),
            ),
          ),

        ],
      ),
    );
  }


  /// 生成音频数量
  Widget _buildAudioNumberWidget(){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10.wMin),
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "生成音频数量",
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 10.wMin),

          Row(
            children: [

              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 8.wMin,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.wMin),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Obx((){
                    return Slider(
                      value: controller.audioNumber.value.toDouble(),
                      max: 4,
                      min: 1,
                      divisions: 3,
                      activeColor: AppTheme.cSurfaceBrand.color,
                      inactiveColor: AppTheme.cSurfaceQuinary.color,
                      onChanged: (value) {
                        controller.audioNumber.value = value.toInt();
                      },
                    );
                  }),
                ),
              ),

              Container(
                alignment: Alignment.centerRight,
                width: 100.wMin,
                child: Obx((){
                  return Text(
                    "${controller.audioNumber.value} 条",
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }),
              ),

            ],
          ),

        ],
      ),
    );
  }

}
