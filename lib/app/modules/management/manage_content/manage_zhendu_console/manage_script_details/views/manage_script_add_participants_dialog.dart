import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../common/commons.dart';

/// 新增参演人员
class ManageScriptAddParticipantsDialog{

  static Future<MangePersonaEntity?> show({
    required BuildContext context,
    List<String>? initVariantNids,
  }) async{

    return await showCupertinoDialog<MangePersonaEntity?>(
      context: context,
      builder: (context) {
        return ManageScriptAddParticipantsDialogWidget(initVariantNids: initVariantNids);
      },
    );
  }

}

class ManageScriptAddParticipantsDialogWidget extends StatefulWidget {
  final List<String>? initVariantNids;
  const ManageScriptAddParticipantsDialogWidget({super.key, this.initVariantNids});

  @override
  State<ManageScriptAddParticipantsDialogWidget> createState() => _ManageScriptAddParticipantsDialogWidgetState();
}

class _ManageScriptAddParticipantsDialogWidgetState extends State<ManageScriptAddParticipantsDialogWidget> {
  
  final ScrollController scrollController = ScrollController();

  /// 搜索输入框
  final TextEditingController searchInput = TextEditingController();

  int limit = 30;
  int offset = 0;
  int total = 0;
  bool isLoading = true;
  /// 数据列表
  List<MangePersonaEntity> listData = <MangePersonaEntity>[];

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
      ListResponseEntity<MangePersonaEntity>? res = await LanguageConsoleDramaRequest.getPersonaList(parameters: parameters, data: reqData);
      if(res == null) return;
      total = res.count ?? 0;
      List<MangePersonaEntity> list = res.datas??[];
      for(MangePersonaEntity item in list){
        listData.add(item);
      }
      if(mounted) setState(() {});
    } finally{
      isLoading = false;
      ToastUtils.hideLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "选择角色",
      width: 1500.wMin,
      onCancel: () => Get.back(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
        height: 900.wMin,
        child: Column(
          children: [

            CardInputWidget(
              hintText: "搜索 speaker / variantNid / 描述",
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
              child: GridView.builder(
                itemCount: listData.length,
                controller: scrollController,
                padding: EdgeInsets.symmetric(vertical: 24.wMin),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16.wMin,
                  crossAxisSpacing: 16.wMin,
                  childAspectRatio: 30 / 10,
                ),
                itemBuilder: (context, index) {
                  return _buildActorWidget(listData[index]);
                },
              ),
            ),

          ],
        ),
      ),
    );
  }


  Widget _buildActorWidget(MangePersonaEntity data){

    String imageUrl = "";
    MangePersonaEntityVariants? variant = data.variants?.firstWhereOrNull((e) => e?.isDefault == true);
    if(variant != null){
      List<MangePersonaEntityVariantsImages?> images = variant.images??[];
      if(images.isNotEmpty){
        imageUrl = images.firstWhereOrNull((e) => e?.isCore == true)?.imageUrl??"";
      }
    }

    return TapScaleWidget(
      onTap: () {
        Get.back(result: data);
      },
      sclae: 1,
      borderRadius: 10.wMin,
      backColor: AppTheme.cSurfaceTertiary.color,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.all(10.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.wMin),
          // color: AppTheme.cSurfaceTertiary.color,
          border: Border.all(
            width: 1.wMin,
            color: AppTheme.cBorderSecondary.color,
          ),
        ),
        child: Row(
          children: [
    
            ClipRRect(
              borderRadius: BorderRadius.circular(4.wMin),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedImageWidget(
                  imageUrl,
                  errorWidget: buildEmptyWidget(),
                  placeholder: buildEmptyWidget(),
                ),
              ),
            ),
    
            SizedBox(width: 6.wMin),
    
            Expanded(
              child: Column(
                spacing: 2.wMin,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name?.firstWhereOrNull((e) => e?.lang == "zh")?.text??"",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    data.nid??"",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: AppTheme.cTextSecondary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    data.tags?.join(",")??"",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: AppTheme.cTextSecondary.color,
                      fontWeight: FontWeight.w400,
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

}