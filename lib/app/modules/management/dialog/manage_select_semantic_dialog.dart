
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../common/commons.dart';

/// 选择语义
class ManageSelectSemanticDialog{

  static Future<List<EnKnowledgeEntitySemantics>?> show({
    required BuildContext context,
    List<EnKnowledgeEntitySemantics?>? initSemantics,
    String? languageCode,
  }) async {
    return await showCupertinoDialog<List<EnKnowledgeEntitySemantics>?>(
      context: context,
      builder: (context) {
        return ManageSelectSemanticDialogWidget(
          initSemantics: initSemantics,
          languageCode: languageCode,
        );
      },
    );
  }

}


class ManageSelectSemanticDialogWidget extends StatefulWidget {
  final List<EnKnowledgeEntitySemantics?>? initSemantics;
  final String? languageCode;
  const ManageSelectSemanticDialogWidget({
    super.key,
    this.initSemantics,
    this.languageCode,
  });

  @override
  State<ManageSelectSemanticDialogWidget> createState() => _ManageSelectSemanticDialogWidgetState();
}

class _ManageSelectSemanticDialogWidgetState extends State<ManageSelectSemanticDialogWidget> {
  

  final TextEditingController uidController = TextEditingController();
  final TextEditingController semanticController = TextEditingController();

  int totalCount = 0;
  int offset = 0;
  int limit = 50;
  final PagerController pagerController = PagerController();
  List<EnKnowledgeEntitySemantics> semanticsList = [];

  List<EnKnowledgeEntitySemantics> selectList = [];

  @override
  void initState() {
    super.initState();
    if(widget.initSemantics != null){
      for(var semantic in widget.initSemantics!){
        if(semantic == null) continue;  
        selectList.add(semantic);
      }
    }

    getSemanticsList();
  }


  /// 分页器回调
  void pagerCallback(int page, int pageSize) {
    offset = (page - 1) * pageSize;
    limit = pageSize;
    getSemanticsList();
  }


  // 获取数据
  Future<void> getSemanticsList() async {
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        'offset': offset,
        'limit': limit,
        "order": "difficulty,-uid",
      };

      
      Map<String, dynamic> reqData = {};
      
      List<int>? uids = FilterDialog.stringToIntList(uidController.text);
      if(uids != null){
        reqData['uid'] = uids.length == 1 ? uids.first : uids;
      }
      if(semanticController.text.trim().isNotEmpty){
        reqData['descriptions'] = semanticController.text;
      }

      ListResponseEntity<EnKnowledgeEntitySemantics>? response = await LanguageConsoleRequest.getSemanticList(parameters: parameters, data: reqData);
      if(response == null) return;
      totalCount = response.count??0;
      semanticsList = response.datas??[];
      if(mounted) setState(() {});
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 确认选择
  void onConfirm(){
    Get.back(result: selectList);
  }



  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "选择语义",
      width: 1500.wMin,
      onCancel: () => Get.back(),
      onConfirm: onConfirm,
      confirmText: "选择 ${selectList.length} 个语义",
      child: Container(
        padding: EdgeInsets.only(bottom: 10.wMin),
        height: 900.wMin,
        child: Column(
          children: [
            _buildTitleWidget(),
            Expanded(child: _buildSemanticListWidget(context)),
          ],
        ),
        
      ),
    );
  }


  Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.wMin),
      child: Row(
        children: [
          SearchWidget(
            width: 150.wMin,
            height: 50.wMin,
            hintText: 'uid',
            controller: uidController,
            color: AppTheme.cSurfaceSecondary.color,
            borderColor: AppTheme.cBorderPrimary.color,
            fontColor: AppTheme.cTextPrimary.color,
            onSubmitted: (value) {
              getSemanticsList();
            },
          ),
          SizedBox(width: 10.wMin),
          SearchWidget(
            width: 200.wMin,
            height: 50.wMin,
            hintText: '语义',
            controller: semanticController,
            color: AppTheme.cSurfaceSecondary.color,
            borderColor: AppTheme.cBorderPrimary.color,
            fontColor: AppTheme.cTextPrimary.color,
            onSubmitted: (value) {
              getSemanticsList();
            },
          ),
          const Spacer(),
          PagerWidget(
            dataCount: totalCount,
            controller: pagerController,
            pageSize: limit,
            visiblePageCount: 3,
            activeColor: AppTheme.cTextPrimary.color,
            onPage: (page, pageSize) {
              pagerCallback(page, pageSize);
            },
          ),
        ],
      ),
    );
  }

  /// 语义列表
  Widget _buildSemanticListWidget(BuildContext context){
    return GridView.builder(
      itemCount: semanticsList.length,
      padding: EdgeInsets.only(left: 18.wMin, right: 18.wMin, bottom: 18.wMin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.wMin,
        mainAxisSpacing: 16.wMin,
        mainAxisExtent: 190.wMin,
      ), 
      itemBuilder: (context, index) {
        final semantic = semanticsList[index];
        return _buildSemanticItemWidget(context, semantic);
      },
    );
  }


  Widget _buildSemanticItemWidget(BuildContext context, EnKnowledgeEntitySemantics semantic){
    return TapScaleWidget(
      onTap: () {
        List<int> ids = selectList.map((e) => e.uid!).toList();

        if(ids.contains(semantic.uid)){
          selectList.removeWhere((e) => e.uid == semantic.uid);
        }else{
          if(semantic.uid == null) return;
          selectList.add(semantic);
        }
        if(mounted) setState(() {});
        
      },
      sclae: 1.01,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceSecondary.color,
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        ),
        child: Row(
          children: [
            _buildSemanticCardImageWidget(context, semantic),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSemanticTagWidget(semantic),
                    SizedBox(height: 4.wMin),
                    _buildSemanticGlossWidget(semantic),
                    const Spacer(),
                  ],
                ),
              ),
            ),
      
          ],
        ),
      ),
    );
  }

  /// 语义卡片图片部分
  Widget _buildSemanticCardImageWidget(BuildContext context, EnKnowledgeEntitySemantics? semantic){
    return TapScaleWidget(
      onTap: () {
        if(semantic?.imageUrl == null) return;
        ShowBigResourceDialog.showImage(
          context: context, 
          imageUrls: [semantic!.imageUrl!],
        );
      },
      sclae: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(12.wMin)),
        child: AspectRatio(
          aspectRatio: 1,
          child: SizedBox(
            width: 220.wMin,
            height: 220.wMin,
            child: Stack(
              children: [
                CachedImageWidget(
                  semantic?.imageUrl ?? "",
                  errorWidget: buildEmptyWidget(),
                  placeholder: buildLoadingWidget(),
                  fadeInDuration: Duration.zero,
                ),
                Positioned(
                  left: 4.wMin,
                  top: 4.wMin,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: semantic?.relationImage?.locked == true,
                        child: ManageTagFS14Widget(
                          tag: "已定稿",
                          bgColor: AppTheme.cInversePrimary.color,
                        ),
                      ),
                    ],
                  ),
                ),
      
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 语义标签部分
  Widget _buildSemanticTagWidget(EnKnowledgeEntitySemantics semantic){

    List<int> ids = selectList.map((e) => e.uid!).toList();


    return Row(
      children: [
        Visibility(
          visible: widget.languageCode != null && semantic.difficulty != null,
          child: Container(
            margin: EdgeInsets.only(right: 10.wMin),
            child: StatusTagDifficultyWidget(
              difficulty: semantic.difficulty,
              language: widget.languageCode,
            ),
          ),
        ),
        ManageTagFS14Widget(
          tag: "sid: ${semantic.uid??''}",
          fontColor: AppTheme.cTextPrimary.color,
        ),
        const Spacer(),

        SvgPicture.asset(
          ids.contains(semantic.uid) ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
          height: 24.wMin,
        ),

      ],
    );
  }

  /// 语义释义部分
  Widget _buildSemanticGlossWidget(EnKnowledgeEntitySemantics? semantic){
    List<LanguageText?> descriptions = semantic?.descriptions??[];
    return Column(
      spacing: 10.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(descriptions.length, (index){
        return Text(
          descriptions[index]?.text??"",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: index == 0 ? 22.wMin : 16.wMin,
            color: index == 0 ? AppTheme.cTextPrimary.color : AppTheme.cTextSecondary.color,
            fontWeight: index == 0 ? FontWeight.w600 : FontWeight.w400,
          ),
        );
      }),
    );
  }









}