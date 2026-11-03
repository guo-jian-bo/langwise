import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/elements/elements_enums/elements_card_mode.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:flutter/material.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/widgets.dart';
import '../dialog/elements_card_sort_dialog.dart';

class ElementsListModelWidget extends StatefulWidget {
  final List<CardDictModeEntityList> modeList;
  final StartEndCalenderData filter;
  final void Function(StartEndCalenderData data)? onFilterConfirm;
  final String mode;
  final void Function(String mode)? onModeChange;
  /// 筛选总数
  final int count;
  /// 总数
  final int cardTotal;
  /// 词典模式是否筛选和搜索
  final bool dictIsFilter;
  final List<NameValueModel> dictModeSort;
  final NameValueModel? initSort;
  final bool? initIsAsc;
  final void Function(NameValueModel sort, bool isAsc)? onSort;
  const ElementsListModelWidget({
    super.key, 
    required this.modeList,
    required this.mode, 
    this.onModeChange, 
    required this.filter, 
    this.onFilterConfirm, 
    this.count = 0,
    this.cardTotal = 0,
    this.dictIsFilter = false,
    required this.dictModeSort,
    this.initIsAsc,
    this.onSort,
    this.initSort,
  });

  @override
  State<ElementsListModelWidget> createState() => _ElementsListModelWidgetState();
}

class _ElementsListModelWidgetState extends State<ElementsListModelWidget> {

  LinearGradient? currentGradient;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    initMode();
  }

  void initMode(){
    if(widget.modeList.isNotEmpty){
      for(int i = 0; i < widget.modeList.length; i++){
        CardDictModeEntityList item = widget.modeList[i];
        if(item.module == widget.mode){
          currentIndex = i;
          ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(item.moduleBgColors);
          currentGradient = StyleUtils.parseCssLinearGradient(colors?.color);
          break;
        }
      }
    }
  }

  Future<void> switchMode(CardDictModeEntityList mode, int index) async{
    // await StorageUtil().remove(NOT_REMIND_CARD_KEY);
    if(widget.mode == mode.module) return;

    bool isChecked = StorageUtil().getBool(NOT_REMIND_CARD_KEY);
    if(isChecked){
      bool res = await LockUtils.checkLock(mode.rights, context);
      if(res) return;
      ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(mode.moduleBgColors);
      currentGradient = StyleUtils.parseCssLinearGradient(colors?.color);
      currentIndex = index;
      if(mounted) setState(() {});
      widget.onModeChange?.call(mode.module??"");
      return;
    }

    String? res = await ElementsListModelDialog.show(
      context: context,
      modeList: widget.modeList,
    );
    if(res == null) return;
    if(res == widget.mode) return;
    ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(mode.moduleBgColors);
    currentGradient = StyleUtils.parseCssLinearGradient(colors?.color);
    currentIndex = index;
    if(mounted) setState(() {});
    widget.onModeChange?.call(mode.module??"");
  }

  @override
  void didUpdateWidget(covariant ElementsListModelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.modeList != oldWidget.modeList){
      initMode();
    }

  }

  @override
  Widget build(BuildContext context) {
    if(widget.modeList.isEmpty) return const SizedBox();
    return Container(
      width: 340.wMin,
      padding: EdgeInsets.all(4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cBgSecondary.color,
        boxShadow: [
          BoxShadow(
            color: AppTheme.cDark.color.withValues(alpha: 0.1),
            blurRadius: 4.wMin,
            offset: Offset(0, 2.wMin),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeWidget(),
          SizedBox(height: 8.wMin),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: widget.mode == ElementsCardMode.studyCard ? _buildReviewCountWidget() : _buildDictCountWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildDictCountWidget(){
    return Container(
      key: ValueKey(widget.mode),
      height: 48.wMin,
      padding: EdgeInsets.all(4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cBgTertiary.color,
      ),
      child: Row(
        children: [
          ElementsSortButtonWidget(
            initIsAsc: widget.initIsAsc,
            initSort: widget.initSort,
            sortList: widget.dictModeSort,
            onSort: widget.onSort,
          ),
          SizedBox(width: 4.wMin),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                !widget.dictIsFilter ? '总数 ' : '当前 ',
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                !widget.dictIsFilter ? '${widget.cardTotal}' : '${widget.count}',
                style: TextStyle(
                  color: AppTheme.cFeedbackSuccessText.color,
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCountWidget(){
    return Container(
      key: ValueKey(widget.mode),
      height: 48.wMin,
      padding: EdgeInsets.all(4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cBgTertiary.color,
      ),
      child: Row(
        children: [
          StartEndMinButtonWidget(
            data: widget.filter,
            count: widget.count,
            onConfirm: widget.onFilterConfirm,
          ),
          SizedBox(width: 4.wMin),
          const Spacer(),
          Row(
            children: [
              Text(
                '累计获得 ',
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${widget.cardTotal}',
                style: TextStyle(
                  color: AppTheme.cFeedbackSuccessText.color,
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      
        ],
      ),
    );
  }


  Widget _buildModeWidget(){
    return Container(
      padding: EdgeInsets.all(4.wMin),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: currentIndex * (162.wMin),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 162.wMin,
              height: 52.wMin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                gradient: currentGradient,
              ),
            ),
          ),
          Row(
            children: List.generate(widget.modeList.length, (index){
              CardDictModeEntityList item = widget.modeList[index];
          
              return TapScaleWidget(
                onTap: () {
                  switchMode(item, index);
                },
                sclae: 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 162.wMin,
                  height: 52.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: Colors.transparent
                  ),
                  child: _buildTextWidget(item, index),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTextWidget(CardDictModeEntityList data, int index){
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      child: Text(data.title??""),
      style: TextStyle(
        color: widget.mode == data.module ? AppTheme.cStaticWhite.color : AppTheme.cFeedbackDefaultText.color,
        fontSize: 24.wMin,
        fontWeight: FontWeight.w600,
      ),
    );
  }

}

class ElementsListModelDialog{

  static Future<String?> show({
    required BuildContext context,
    required List<CardDictModeEntityList> modeList,
  }) async{
    return await showCupertinoDialog<String?>(
      context: context,
      builder: (context) {
        return ElementsListModelDialogWidget(modeList: modeList);
      },
    );
  }

}

class ElementsListModelDialogWidget extends StatefulWidget {
  final List<CardDictModeEntityList> modeList;
  const ElementsListModelDialogWidget({super.key, required this.modeList});

  @override
  State<ElementsListModelDialogWidget> createState() => _ElementsListModelDialogWidgetState();
}

class _ElementsListModelDialogWidgetState extends State<ElementsListModelDialogWidget> {

  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Material(
        color: AppTheme.cOverlayBackground.color,
        child: Center(
          child: GestureDetector(
            onTap: (){},
            child: Container(
              width: 932.wMin,
              padding: EdgeInsets.all(32.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.wMin),
                color: AppTheme.cSurfaceSecondary.color,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "切换模式",
                    style: TextStyle(
                      color: AppTheme.cTextPrimary.color,
                      fontSize: 32.wMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 24.wMin),
                  IntrinsicHeight(
                    child: Row(
                      spacing: 16.wMin,
                      children: List.generate(widget.modeList.length, (index){
                        return _buildModeWidget(widget.modeList[index]);
                      }),
                    ),
                  ),
                  SizedBox(height: 24.wMin),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: TapScaleWidget(
                      onTap: () {
                        isChecked = !isChecked;
                        if(mounted) setState(() {});
                      },
                      sclae: 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            isChecked ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
                            width: 24.wMin,
                            height: 24.wMin,
                          ),
                          SizedBox(width: 8.wMin),
                          Text(
                            "不再提醒",
                            style: TextStyle(
                              color: AppTheme.cTextSecondary,
                              fontSize: 20.wMin,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeWidget(CardDictModeEntityList mode){

    ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(mode.moduleBgColors);
    LinearGradient? gradient = StyleUtils.parseCssLinearGradient(colors?.color);


    return Expanded(
      child: TapScaleWidget(
        onTap: () async{
          bool res = await LockUtils.checkLock(mode.rights, context);
          if(res) return;
          if(isChecked){
            StorageUtil().setBool(NOT_REMIND_CARD_KEY, true);
          }else{
            StorageUtil().remove(NOT_REMIND_CARD_KEY);
          }
          Get.back(result: mode.module);
        },
        sclae: 1.005,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(12.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.wMin),
                border: Border.all(width: 2.wMin, color: AppTheme.cBorderPrimary.color),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 90.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.wMin),
                      gradient: gradient,
                    ),
                    child: Text(
                      mode.title??"",
                      style: TextStyle(
                        color: AppTheme.cStaticWhite.color,
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.wMin),
                  Text(
                    mode.benefit?.category??"",
                    style: TextStyle(
                      color: AppTheme.cTextPrimary.color,
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.wMin),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: 250.wMin,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: 6.wMin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(mode.benefit?.items?.length??0, (index){
                          String item = mode.benefit?.items?[index]??"";
                          return Row(
                            spacing: 4.wMin,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 30.wMin,
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  "assets/svg/public/icon_check_min.svg",
                                  width: 18.wMin,
                                  height: 18.wMin,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 20.wMin,
                                    color: AppTheme.cTextSecondary.color,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        
            Visibility(
              visible: mode.rights?.allLock??false,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.cOverlayBackground.color,
                  borderRadius: BorderRadius.circular(24.wMin),
                  border: Border.all(width: 2.wMin, color: AppTheme.cBorderPrimary.color),
                ),
                child: SvgPicture.asset(
                  "assets/svg/public/icon_kockkey.svg",
                  width: 64.wMin,
                ),
              ),
            ),
        
          ],
        ),
      ),
    );
  }

}


class ElementsSortButtonWidget extends StatefulWidget {
  final List<NameValueModel> sortList;
  final NameValueModel? initSort;
  final bool? initIsAsc;
  final void Function(NameValueModel sort, bool isAsc)? onSort;
  const ElementsSortButtonWidget({
    super.key, 
    required this.sortList, 
    this.initSort, 
    this.initIsAsc, 
    this.onSort,
  });

  @override
  State<ElementsSortButtonWidget> createState() => _ElementsSortButtonWidgetState();
}

class _ElementsSortButtonWidgetState extends State<ElementsSortButtonWidget> {


  void _show(BuildContext ctx) {
    BotToast.showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.leftBottom,
      attachedBuilder: (cancelFunc) {
        return ElementsCardSortDialogIconBodyWidget(
          initSort: widget.initSort,
          initIsAsc: widget.initIsAsc,
          onSort: widget.onSort,
          sortList: widget.sortList,
          showDescAsc: false,
          cancelFunc: cancelFunc,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Builder(
      builder: (context) {
        return TapScaleWidget(
          onTap: () {
            _show(context);
          },
          sclae: 1,
          child: Container(
            height: 40.wMin,
            padding: EdgeInsets.symmetric(horizontal: 4.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.wMin),
              color: AppTheme.cBgQuaternary.color,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/svg/public/icon_caret_down.svg",
                  width: 24.wMin,
                ),
                Text(
                  "${widget.initSort?.name??''} ",
                  style: TextStyle(
                    color: AppTheme.cTextSecondary.color,
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}