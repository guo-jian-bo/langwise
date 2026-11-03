
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';

class ManageSelectPersonaVariantsReslut{
  MangePersonaEntity persona;
  MangePersonaEntityVariants variant;

  ManageSelectPersonaVariantsReslut({
    required this.persona,
    required this.variant,
  });
}

/// 选择角色变体
class ManageSelectPersonaVariantsDialog{


  static Future<ManageSelectPersonaVariantsReslut?> show({
    required BuildContext context,
    List<String?>? initVariantNid,
    LanguageCode? languageCode,
  }) async{
    return await showCupertinoDialog<ManageSelectPersonaVariantsReslut?>(
      context: context,
      builder: (context) {
        return ManageSelectPersonaVariantsDialogWidget(initVariantNid: initVariantNid, languageCode: languageCode);
      },
    );
  }

  static Future<MangePersonaEntityVariants?> showVariants({
    required BuildContext context,
    required MangePersonaEntity data,
    List<String?>? initVariantNid,
  }) async{
    return await showCupertinoDialog<MangePersonaEntityVariants?>(
      context: context,
      builder: (context) {
        return ManageSelectPersonaVariantsVariantsDialog(data: data, initVariantNid: initVariantNid);
      },
    );
  }

}

class ManageSelectPersonaVariantsDialogWidget extends StatefulWidget {
  final List<String?>? initVariantNid;
  final LanguageCode? languageCode;

  const ManageSelectPersonaVariantsDialogWidget({super.key, this.initVariantNid, this.languageCode});

  @override
  State<ManageSelectPersonaVariantsDialogWidget> createState() => _ManageSelectPersonaVariantsDialogWidgetState();
}

class _ManageSelectPersonaVariantsDialogWidgetState extends State<ManageSelectPersonaVariantsDialogWidget> {

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
        "order": "uid",
      };
      Map<String, dynamic> reqData = {
        "enabled": true,
        "lang": widget.languageCode?.value,
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

  /// 选择变体
  Future<void> showVariants(MangePersonaEntity data) async{
    MangePersonaEntityVariants? variantRes = await ManageSelectPersonaVariantsDialog.showVariants(
      context: context, 
      data: data,
      initVariantNid: widget.initVariantNid,
    );
    if(variantRes == null) return;
    ManageSelectPersonaVariantsReslut reslut = ManageSelectPersonaVariantsReslut(
      persona: data,
      variant: variantRes,
    );
    Get.back(result: reslut);
  }

  /// 管理角色
  Future<void> manageEmotion() async{
    await ManagePageRegistry.jumpTo(Routes.MANAGE_PERSONA);
    refreshListData();
  }


  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "选择角色变体",
      width: 1500.wMin,
      onCancel: () => Get.back(),
      titleWidget: Container(
        margin: EdgeInsets.only(right: 16.wMin),
        child: ButtonWidget(
          text: "管理角色",
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
        // TTOD: 弹出选择变体
        showVariants(data);
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


class ManageSelectPersonaVariantsVariantsDialog extends StatefulWidget {
  final MangePersonaEntity data;
  final List<String?>? initVariantNid;
  const ManageSelectPersonaVariantsVariantsDialog({super.key, required this.data, this.initVariantNid});

  @override
  State<ManageSelectPersonaVariantsVariantsDialog> createState() => _ManageSelectPersonaVariantsVariantsDialogState();
}

class _ManageSelectPersonaVariantsVariantsDialogState extends State<ManageSelectPersonaVariantsVariantsDialog> {


  @override
  Widget build(BuildContext context) {

    List<MangePersonaEntityVariants?> variants = widget.data.variants??[];

    return ManageDialogBoxWidget(
      title: "选择变体",
      width: 1500.wMin,
      onCancel: () => Get.back(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
        height: 700.wMin,
        child: GridView.builder(
          itemCount: variants.length,
          padding: EdgeInsets.symmetric(vertical: 24.wMin),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16.wMin,
            crossAxisSpacing: 16.wMin,
            childAspectRatio: 30 / 10,
          ),
          itemBuilder: (context, index) {
            return _buildActorWidget(variants[index]);
          },
        ),
      ),
    );
  }

  Widget _buildActorWidget(MangePersonaEntityVariants? item){
    String imageUrl = "";
    List<MangePersonaEntityVariantsImages?> images = item?.images??[];
    if(images.isNotEmpty){
      imageUrl = images.firstWhereOrNull((e) => e?.isCore == true)?.imageUrl??"";
    }

    bool isinit = widget.initVariantNid?.contains(item?.nid)??false;

    return Opacity(
      opacity: isinit ? 0.5 : 1,
      child: IgnorePointer(
        ignoring: isinit,
        child: TapScaleWidget(
          onTap: () {
            if(item == null) return;
            Get.back(result: item);
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
                        item?.name??"",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        item?.nid??"",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: AppTheme.cTextSecondary.color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        item?.description?.firstWhereOrNull((e) => e?.lang == "zh")?.text??"",
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
        ),
      ),
    );
  }
}