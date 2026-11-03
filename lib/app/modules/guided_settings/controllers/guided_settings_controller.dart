import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';

import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/stores/stores.dart';

class GuidedSettingsController extends GetxController {
  final PageController pageController = PageController(viewportFraction: 0.4);
  final RxDouble currentPageIndex = 0.0.obs;


  /// 所处等级card
  final RxBool yourLevelShow = false.obs;
  /// 语言水平选择下标
  final RxInt selectLanguageLevelIndex = (-1).obs;
  /// 选择的语言等级
  final RxInt selectedLanguageLevel = (-1).obs;
  
  /// 喜欢的口音card
  final RxBool likeAccentShow = false.obs;
  /// 喜欢的口音
  final RxInt accentIndex = (-1).obs;

  /// 音节划分模式card
  final RxBool syllableDivisionShow = false.obs;
  /// 音节划分模式
  final RxInt syllableDivisionIndex = (-1).obs;

  /// 喜欢的风格card
  final RxBool likeStyleShow = false.obs;



  


  /// 按钮
  bool buttonFlag = false;

  @override
  void onInit() {
    super.onInit();
    Get.lazyPut(() => ConfigController(), fenix: true);
    pageController.addListener((){
      currentPageIndex.value = pageController.page??0;
    });
  }

  Future<void> nextPage() async{
    await pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }


  /// 切换语言水平
  Future<void> switchLanguageLevel(int index) async{
    selectLanguageLevelIndex.value = index;
  }

  /// 语言水平卡片继续按钮
  Future<void> languageLevelContinue() async{
    if(buttonFlag) return;
    buttonFlag = true;
    yourLevelShow.value = true;
    await nextPage();
    buttonFlag = false;
  }

  /// 选择所处等级
  Future<void> switchYouLevel(int index, BuildContext context) async{
    if(index == 0){
      await SelectUserLanguageLevelDialog.show(context: context);
    }else if(index == 1){
      await Get.toNamed(Routes.PRACTICE_QUESTIONS);
    }
    selectedLanguageLevel.value = index;
  }

  /// 所处等级卡片继续按钮
  Future<void> youLevelContinue() async{
    if(buttonFlag) return;
    buttonFlag = true;
    likeAccentShow.value = true;
    await nextPage();
    buttonFlag = false;
  }

  /// 切换口音
  Future<void> switchAccent(int index) async{
    if(buttonFlag) return;
    buttonFlag = true;
    accentIndex.value = index;
    Future.delayed(const Duration(milliseconds: 500), (){
      buttonFlag = false;
    });
  }

  /// 选择口音卡片继续按钮
  Future<void> accentContinue() async{
    if(buttonFlag) return;
    buttonFlag = true;
    syllableDivisionShow.value = true;
    await nextPage();
    buttonFlag = false;
  }

  /// 切换音节划分模式
  Future<void> switchSyllableDivision(int index) async{
    if(buttonFlag) return;
    buttonFlag = true;
    syllableDivisionIndex.value = index;
    Future.delayed(const Duration(milliseconds: 500), (){
      buttonFlag = false;
    });
  }

  /// 音节划分模式卡片继续按钮
  Future<void> syllableDivisionContinue() async{
    if(buttonFlag) return;
    buttonFlag = true;
    likeStyleShow.value = true;
    await nextPage();
    buttonFlag = false;
  }


  /// 跳转至设置视觉风格页面
  Future<void> toStyleSetting() async{
    await Get.toNamed(Routes.VISUAL_STYLE_SETTINGS);
  }

  /// 风格卡片继续按钮
  Future<void> styleContinue() async{
    if(buttonFlag) return;
    buttonFlag = true;
    completeButton();
  }


  Future<void> showVideo(BuildContext context) async{
    await PlayVideoDialog.show(
      context: context, 
      videoUrl: "http://vjs.zencdn.net/v/oceans.mp4",
    );
  }


  void completeButton(){
    UserStore.to.setHasLoggedInBefore(true);
    Get.offAndToNamed(Routes.APPLICATION);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
  
}
