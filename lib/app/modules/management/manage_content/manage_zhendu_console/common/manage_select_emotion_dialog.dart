import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';

/// 选择情绪
class ManageSelectEmotionDialog{

  static Future<ManageVocalEmotionsEntity?> show({
    required BuildContext context,
    String? initEmotionNid,
  }) async{
    return await showCupertinoDialog<ManageVocalEmotionsEntity?>(
      context: context,
      builder: (context) {
        return ManageSelectEmotionDialogWidget(initEmotionNid: initEmotionNid);
      },
    );
  }

}

class ManageSelectEmotionDialogWidget extends StatefulWidget {
  final String? initEmotionNid;
  const ManageSelectEmotionDialogWidget({super.key, this.initEmotionNid});

  @override
  State<ManageSelectEmotionDialogWidget> createState() => _ManageSelectEmotionDialogWidgetState();
}

class _ManageSelectEmotionDialogWidgetState extends State<ManageSelectEmotionDialogWidget> {

  final ScrollController scrollController = ScrollController();

  /// 搜索输入框
  final TextEditingController searchInput = TextEditingController();

  int limit = 30;
  int offset = 0;
  int total = 0;
  bool isLoading = true;
  /// 数据列表
  List<ManageVocalEmotionsEntity> listData = <ManageVocalEmotionsEntity>[];

  @override
  void initState() {
    super.initState();
    listenScroll();
    refreshListData();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange){
        if(!isLoading && listData.length < total){
          offset += limit;
          getListData();
        }
      }
    });
  }
  

  /// 刷新列表数据
  Future<void> refreshListData() async{
    total = 0;
    offset = 0;
    listData.clear();
    await getListData();
  }

  /// 获取列表数据
  Future<void> getListData() async{
    try {
      isLoading = true;
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "limit": limit,
        "offset": offset,
        "order": "-uid",
      };
      Map<String, dynamic> reqData = {
        "enabled": true,
      };
      if(searchInput.text.isNotEmpty){
        reqData["keyword"] = searchInput.text;
      }
      ListResponseEntity<ManageVocalEmotionsEntity>? res = await LanguageConsoleDramaRequest.getVocalEmotionsList(parameters: parameters, data: reqData);
      if(res == null) return;
      total = res.count ?? 0;
      List<ManageVocalEmotionsEntity> list = res.datas??[];
      for(ManageVocalEmotionsEntity item in list){
        listData.add(item);
      }
      if(mounted) setState(() {});
    } finally{
      isLoading = false;
      ToastUtils.hideLoading();
    }
  }


  Future<void> manageEmotion() async{
    await ManagePageRegistry.jumpTo(Routes.MANAGE_VOCAL_EMOTIONS);
    refreshListData();
  }
  
  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "选择情绪",
      width: 1000.wMin,
      onCancel: () => Get.back(),
      titleWidget: Container(
        margin: EdgeInsets.only(right: 16.wMin),
        child: ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaVoiceEmotionPages],
          child: ButtonWidget(
            text: "管理情绪",
            width: 160.wMin,
            height: 44.wMin,
            borderRadius: 10.wMin,
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
            border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
            fontColor: AppTheme.cSurfaceBrand.color,
            fontSize: 18.wMin,
            sclae: 1.03,
            onTap: () {
              manageEmotion();
            },
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
        height: 900.wMin,
        child: Column(
          children: [

            CardInputWidget(
              hintText: "搜索nid / 中英文名称",
              controller: searchInput,
              textInputAction: TextInputAction.search,
              height: 54.wMin,
              valueStyle: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
              hintStyle: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
              onSubmitted: (value)  {
                refreshListData();
              },
            ),
      

            Expanded(
              child: ListView.separated(
                itemCount: listData.length,
                controller: scrollController,
                padding: EdgeInsets.symmetric(vertical: 24.wMin),
                separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
                itemBuilder: (context, index) {
                  return _buildListItemWidget(listData[index]);
                },
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildListItemWidget(ManageVocalEmotionsEntity data){

    List<double?> vector = data.vector??[];

    return IgnorePointer(
      ignoring: widget.initEmotionNid == data.nid,
      child: Opacity(
        opacity: widget.initEmotionNid == data.nid ? 0.6 : 1,
        child: TapScaleWidget(
          onTap: () {
            Get.back(result: data);
          },
          sclae: 1,
          borderRadius: 10.wMin,
          backColor: AppTheme.cSurfaceTertiary.color.withValues(alpha: 0.6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.all(10.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.wMin),
              border: Border.all(
                width: 1.wMin,
                color: AppTheme.cBorderSecondary.color,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
        
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
          
                    Expanded(
                      child: Text(
                        data.name?.firstWhereOrNull((e) => e?.lang == "zh")?.text??"",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
          
                    ButtonWidget(
                      text: data.enabled == true ? "启用" : "停用",
                      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
                      color: data.enabled == true ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.1) : AppTheme.cSurfaceError.color.withValues(alpha: 0.1),
                      fontColor: data.enabled == true ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceError.color,
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w600,
                    ),
          
                  ],
                ),
        
                Text(
                    data.nid??"",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: AppTheme.cTextSecondary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
            
                  SizedBox(height: 8.wMin),
            
                  Text(
                    data.description?.firstWhereOrNull((e) => e?.lang == "zh")?.text??"",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: AppTheme.cTextSecondary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
            
                  SizedBox(height: 10.wMin),
        
                  Row(
                    spacing: 12.wMin,
                    children: [
                      _buildConfigItemWidget("HAP", vector.isNotEmpty ? vector[0]??0 : 0),
                      _buildConfigItemWidget("ANG", vector.length >= 2 ? vector[1]??0 : 0),
                      _buildConfigItemWidget("SAD", vector.length >= 3 ? vector[2]??0 : 0),
                      _buildConfigItemWidget("AFR", vector.length >= 4 ? vector[3]??0 : 0),
        
                      _buildConfigItemWidget("DIS", vector.length >= 5 ? vector[4]??0 : 0),
                      _buildConfigItemWidget("MEL", vector.length >= 6 ? vector[5]??0 : 0),
                      _buildConfigItemWidget("SUR", vector.length >= 7 ? vector[6]??0 : 0),
                      _buildConfigItemWidget("CAL", vector.length >= 8 ? vector[7]??0 : 0),
                    ],
                  ),
        
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildConfigItemWidget(String name, double value){
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Column(
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              value.toStringAsFixed(2).padLeft(2, '0'),
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

}