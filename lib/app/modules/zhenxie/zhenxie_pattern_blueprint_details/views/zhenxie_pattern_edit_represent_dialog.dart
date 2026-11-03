import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';

class ZhenxiePatternEditRepresentDialog{

  static Future<PatternBlueprintEntity?> show({
    required BuildContext context,
    required String nid,
    required List<PatternBlueprintSentenceBriefEntity?> sentenceRealizationList,
  }) async{
    return await showCupertinoDialog<PatternBlueprintEntity?>(
      context: context,
      builder: (context) {
        return PatternEditRepresentDialogWidget(
          nid: nid,
          sentenceRealizationList: sentenceRealizationList,
        );
      },
    );
  }

}

class PatternEditRepresentDialogWidget extends StatefulWidget {
  final String nid;
  final List<PatternBlueprintSentenceBriefEntity?> sentenceRealizationList;

  const PatternEditRepresentDialogWidget({
    required this.nid,
    required this.sentenceRealizationList,
    super.key,
 });

  @override
  State<PatternEditRepresentDialogWidget> createState() => _PatternEditRepresentDialogWidgetState();
}

class _PatternEditRepresentDialogWidgetState extends State<PatternEditRepresentDialogWidget> {
  List<PatternBlueprintSentenceBriefEntity?> _sentenceRealizationList = [];
  /// 代表句滚动控制器
  final ScrollController representScrollController = ScrollController();

  List<EnKnowledgeEntity> sentencePoolList = <EnKnowledgeEntity>[];
  /// 搜索输入框
  final TextEditingController searchController = TextEditingController();
  /// 滚动控制器
  final ScrollController scrollController = ScrollController();
  /// 总条数
  int total = 0;
  /// offset
  int offset = 0;
  /// limit
  int limit = 40;
  /// 是否加载中
  bool isLoading = false;

  @override
  void initState(){
    super.initState();
    _sentenceRealizationList = widget.sentenceRealizationList.toList();
    refreshList();
    listenScroll();
  }

  @override
  void dispose(){
    representScrollController.dispose();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

   /// 监听列表滚动进行分页加载
  void listenScroll(){
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange){
        if(!isLoading && sentencePoolList.length < total){
          offset += limit;
          _queryLocalPool();
        }
      }
    });
  }

  /// 刷新列表
  Future<void> refreshList() async{
    sentencePoolList.clear();
    offset = 0;
    total = 0;
    _queryLocalPool();
  }

  /// 查询句子池
  Future<void> _queryLocalPool() async {
    try {
      isLoading = true;
      ToastUtils.showLoading();
      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      Map<String, dynamic> reqData = {
        "patternNid": widget.nid,
        "content": searchController.text,
      };
      ListResponseEntity<EnKnowledgeEntity>? resp = await LanguageConsoleRequest.queryPatternBlueprintSentencePool(
        data: reqData,
        parameters: params,
      );
      if(resp == null) return;
      total = resp.count ?? 0;
      sentencePoolList.addAll(resp.datas ?? []);
      if(mounted) setState(() {});
    } finally {
      ToastUtils.hideLoading();
      isLoading = false;
    }
  }

  /// 保存代表句
  Future<void> _saveRepresent() async{
    try {
      ToastUtils.showLoading();
      List<Map<String, dynamic>> sentenceIds = [];
      for (var element in _sentenceRealizationList) {
        if(element?.sentenceId == null) continue;
        sentenceIds.add({"sentenceId": element!.sentenceId!});
      }

      Map<String, dynamic> reqData = {
        "sentenceRealizations": sentenceIds,
      };
      PatternBlueprintEntity? resp = await LanguageConsoleRequest.editPatternBlueprintRepresent(
        nid: widget.nid,
        data: reqData,
      );
      if(resp == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      Get.back(result: resp);
    } finally{
      ToastUtils.hideLoading();
    }


  }


   @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "编辑代表句",
      width: 1680.wMin,
      titlePadding: EdgeInsets.only(
        left: 32.wMin,
        right: 32.wMin,
        top: 32.wMin,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 32.wMin),
        height: 950.wMin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTieleWidget(),
            SizedBox(height: 12.wMin),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderThin.color,
            ),
            SizedBox(height: 12.wMin),
            Expanded(
              flex: 45,
              child: _buildRepresentWidget(),
            ),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderSubtle.color,
            ),
            SizedBox(height: 12.wMin),
            Expanded(
              flex: 55,
              child: _buildLocalPoolWidget(),
            ),
            SizedBox(height: 12.wMin),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderThin.color,
            ),
            SizedBox(height: 12.wMin),
            _buildButtonsWidget(),
            SizedBox(height: 32.wMin),
          ],
        ),
      ),
    );
  }

  Widget _buildTieleWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "上方调整当前代表句（拖动排序/删除）；下方从本 pattern 句子池挑选添加。",
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
      ],
    );
  }

  /// 当前代表句
  Widget _buildRepresentWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "当前代表句",
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        Expanded(
          child: PrimaryScrollController(
            controller: representScrollController,
            child: ReorderableColumn(
              padding: EdgeInsets.symmetric(vertical: 12.wMin),
              onReorder: (oldIndex, newIndex) {
                if(oldIndex == newIndex) return;
                final item = _sentenceRealizationList.removeAt(oldIndex);
                final targetIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
                _sentenceRealizationList.insert(targetIndex, item);
                setState(() {});
              },
              buildDraggableFeedback: (context, constraints, child) {
                return Transform.scale(
                  scale: 1.01,
                  child: Container(
                    constraints: constraints,
                    child: child,
                  ),
                );
              },
              children: List.generate(_sentenceRealizationList.length, (index){
                return Container(
                  key: Key(index.toString()),
                  margin: EdgeInsets.only(bottom: 12.wMin),
                  child: _buildRepresentItemWidget(_sentenceRealizationList[index], index),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepresentItemWidget(PatternBlueprintSentenceBriefEntity? data, int index){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/svg/manage/icon_drag.svg",
            width: 14.wMin,
            colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
          ),
          SizedBox(width: 8.wMin),
          Container(
            width: 32.wMin,
            height: 32.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cSurfaceLayerBase.color,
              border: Border.all(
                color: AppTheme.cBorderThin.color,
                width: 0.8.wMin,
              ),
            ),
            child: AutoSizeText(
              "${index + 1}",
              minFontSize: 4,
              style: TextStyle(
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
          SizedBox(width: 8.wMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  data?.content??'',
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                SelectableText(
                  data?.definition??'',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
              ],
            ),
          ),
          TapScaleWidget(
            onTap: () {
              _sentenceRealizationList.removeAt(index);
              if(mounted) setState(() {});
            },
            sclae: 1.03,
            child: Container(
              width: 48.wMin,
              height: 48.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cSurfaceError.color.withValues(alpha: 0.12),
              ),
              child: SvgPicture.asset(
                "assets/svg/public/icon_delete.svg",
                width: 24.wMin,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 本地句子池
  Widget _buildLocalPoolWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "本 pattern 句子池",
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            SizedBox(
              width: 363.wMin,
              child: CardInputWidget(
                controller: searchController,
                borderRadius: BorderRadius.circular(99),
                height: 52.wMin,
                hintText: "搜索句子 / 中文 / uid",
                onSubmitted: (value) {
                  refreshList();
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 12.wMin),
        Expanded(
          child: _buildLocalPoolListWidget(),
        ),
      ],
    );
  }

  Widget _buildLocalPoolListWidget(){
    if(sentencePoolList.isEmpty && !isLoading) {
      return NotDataWidget(
        message: "没有可添加的句子（可能都已在上方，或被搜索过滤）",
      );
    }
    return ListView.separated(
        itemCount: sentencePoolList.length,
        separatorBuilder: (context, index) {
          return SizedBox(height: 12.wMin);
        },
        itemBuilder: (context, index) {
          return _buildLocalPoolItemWidget(sentencePoolList[index]);
        },
      );
  }

  Widget _buildLocalPoolItemWidget(EnKnowledgeEntity data){
    bool isExist = false;
    for (var element in _sentenceRealizationList) {
      if(element?.sentenceId == data.uid) {
        isExist = true;
        break;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Opacity(
        opacity: isExist ? 0.6 : 1,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    data.content??'',
                    style: TextStyle(
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                  SelectableText(
                    data.definition??'',
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                ],
              ),
            ),
            ButtonWidget(
              text: "添加",
              padding: EdgeInsets.only(right: 8.wMin),
              height: 34.wMin,
              color: AppTheme.cSurfaceLayerBase.color,
              border: Border.all(
                width: 0.8.wMin,
                color: AppTheme.cBorderSubtle.color,
              ),
              fontSize: 18.wMin,
              fontColor: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
              leftIcon: Container(
                margin: EdgeInsets.only(left: 6.wMin),
                child: SvgPicture.asset(
                  "assets/svg/public/icon_add.svg",
                  width: 24.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                ),
              ),
              sclae: 1.03,
              onTap: () {
                for (var element in _sentenceRealizationList) {
                  if(element?.sentenceId == data.uid) {
                    return ToastUtils.showToast(text: "该句子已存在");
                  }
                }
        
                _sentenceRealizationList.add(PatternBlueprintSentenceBriefEntity(
                  sentenceId: data.uid,
                  content: data.content,
                  definition: data.definition,
                ));

                if(mounted) setState(() {});

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  representScrollController.jumpTo(representScrollController.position.maxScrollExtent);
                });

              },
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildButtonsWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ButtonWidget(
          text: "取消",
          width: 112.wMin,
          height: 56.wMin,
          borderRadius: 8.wMin,
          color: AppTheme.cSurfaceLayerElevated.color,
          fontColor: AppTheme.cTextSecondary.color,
          fontSize: 24.wMin,
          fontWeight: FontWeight.w500,
          sclae: 1.03,
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 12.wMin),
        ButtonWidget(
          text: "保存",
          width: 112.wMin,
          height: 56.wMin,
          borderRadius: 8.wMin,
          color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.8),
          fontSize: 24.wMin,
          fontWeight: FontWeight.w500,
          sclae: 1.03,
          onTap: () {
            _saveRepresent();
          },
        ),
      ],
    );
  }


}
