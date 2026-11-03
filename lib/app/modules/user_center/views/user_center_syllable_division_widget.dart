
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ui_essentials/ui_essentials.dart';

// import '../../../../common/entities/entities.dart';
// import '../../../../common/widgets/widgets.dart';
// import '../../../../theme/theme.dart';
// import '../controllers/user_center_controller.dart';

// class UserCenterSyllableDivisionWidget extends GetView<UserCenterController> {
//   /// 用户中心 音节划分
//   const UserCenterSyllableDivisionWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.all(24.wMin),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16.wMin),
//           color: AppTheme.cBgSecondary,
//         ),
//         child: Obx((){
//           UserCenterOptionEntitySyllableConfigs? syllableConfigs = controller.userPreferenceOptionData.value.syllableConfigs;
//           return Column(
//             children: [
//               UserSettingOpenTitleWidget(
//                 title: syllableConfigs?.title??"",
//                 subTitle: syllableConfigs?.description??"",
//                 svg: "assets/svg/user_center/icon_speaker.svg",
//                 isOpen: controller.syllableDivisionOpen.value,
//                 onTap: () {
//                   controller.openSyllableDivision(!controller.syllableDivisionOpen.value);
//                 },
//               ),
//               SizedBox(height: 24.wMin),
//               Container(height: 1.wMin, color: AppTheme.cBorderPrimary),
//               SizedBox(height: 24.wMin),
//               Obx((){
//                 return Column(
//                   children: [
//                     AnimatedCrossFade(
//                       crossFadeState: !controller.syllableDivisionOpen.value ? CrossFadeState.showFirst : CrossFadeState.showSecond,
//                       duration: const Duration(milliseconds: 200),
//                       firstChild: Container(),
//                       secondChild: Column(
//                         spacing: 26.wMin,
//                         children: [
//                           _buildSyllableDivisionSelectWidget(syllableConfigs?.options??[]),
//                           UserSettingExampleWidget(
//                             title: syllableConfigs?.exampleTitle??"",
//                             datas: List.generate(syllableConfigs?.examples?.length??0, (index){
//                               UserCenterOptionEntitySyllableConfigsExamples? example = syllableConfigs?.examples?[index];
//                               List<UserCenterOptionEntitySyllableConfigsExamplesContentList?> contentList = example?.contentList??[];
//                               return UserSettingExampleModel(
//                                 title: example?.title??"",
//                                 subTitle: example?.description??"",
//                                 example: List.generate(contentList.length, (index){
//                                   UserCenterOptionEntitySyllableConfigsExamplesContentList? content = contentList[index];
//                                   return UserSettingExampleDataModel(
//                                     image: content?.imageUrl,
//                                     audio: content?.audioUrl,
//                                     text: content?.content??"",
//                                   );
//                                 }),
//                               );
//                             }),
//                           ),
//                         ],
//                       ),
//                     ),
//                     AnimatedCrossFade(
//                       crossFadeState: controller.syllableDivisionOpen.value ? CrossFadeState.showFirst : CrossFadeState.showSecond,
//                       duration: const Duration(milliseconds: 200),
//                       secondChild: _buildSyllableDivisionSelectWidget(syllableConfigs?.options??[]),
//                       firstChild: Container(),
//                     ),
//                   ],
//                 );
//               }),
//             ],
//           );
//         }),
//       ),
//     );
//   }


//   Widget _buildSyllableDivisionSelectWidget(List<UserCenterOptionEntitySyllableConfigsOptions?> options){
//     return IntrinsicHeight(
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.zero,
//         child: Row(
//           spacing: 16.wMin,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: List.generate(options.length, (index){
//             UserCenterOptionEntitySyllableConfigsOptions? option = options[index];
//             if(option == null) return Container();
//             return UserSettingSelectCardWidget(
//               title: option.title??"",
//               subTitle: option.description??"",
//               value: option.content??"",
//               audio: option.audioUrl,
//               selected: controller.currentSyllableDivisionCode.value == option.code,
//               onTap: () => controller.changeSyllableDivision(option.code??""),
//             );
//           }),
//         ),
//       ),
//     );
//   }


// }