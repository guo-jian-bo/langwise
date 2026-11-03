import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/widgets.dart';

/// 管理风格弹窗
class UserManagementStyleDialog{

  /// * teamStyeData 如果为null 弹窗内自行请求数据
  static Future<bool> show({
    required BuildContext context,
    TeamStyleEntity? teamStyeData,
  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return UserManagementStyleDialogWidget(
          teamStyeData: teamStyeData,
        );
      },
    );

    return res??false;
  }

}

class UserManagementStyleDialogWidget extends StatefulWidget {
  final TeamStyleEntity? teamStyeData;
  const UserManagementStyleDialogWidget({super.key, this.teamStyeData});

  @override
  State<UserManagementStyleDialogWidget> createState() => _UserManagementStyleDialogWidgetState();
}

class _UserManagementStyleDialogWidgetState extends State<UserManagementStyleDialogWidget> {

  final List<ResourceTypeEnum> resourceTypeList = [];

  /// 原始数据
  TeamStyleEntity? teamStyeData;

  /// 选择的资源类型
  ResourceTypeEnum resourceType = ResourceTypeEnum.image;

  /// 图片风格列表
  List<TeamStyleEntityStyleItems> imageStyleList = <TeamStyleEntityStyleItems>[];
  /// 视频风格列表
  List<TeamStyleEntityStyleItems> videoStyleList = <TeamStyleEntityStyleItems>[];

  /// 当前生效的风格列表code
  Set<String> takeEffectCodeList = <String>{};

  @override
  void initState() {
    super.initState();
    if(widget.teamStyeData == null){
      getStyleList();
    }else{
      teamStyeData = widget.teamStyeData;
      initData();
    }
  }

  Future<void> initData() async{
    if(teamStyeData == null) return;
    resourceType = teamStyeData?.mediaModeUse == 1 ? ResourceTypeEnum.video : ResourceTypeEnum.image;

    List<TeamStyleEntityStyleItems?> styleItems = teamStyeData?.styleItems??[];
    List<String?> imageStyleUses = teamStyeData?.imageStyleUses??[];

    imageStyleList.clear();
    videoStyleList.clear();

    for(int i = 0; i < imageStyleUses.length; i++){
      if(imageStyleUses[i] == null) return;
      takeEffectCodeList.add(imageStyleUses[i]!);
    }

    for(int i = 0; i < styleItems.length; i++){
      if(styleItems[i] == null) continue;
      if(styleItems[i]?.imageRights == 1){
        imageStyleList.add(styleItems[i]!);
      }
      if(styleItems[i]?.videoRights == 1){
        videoStyleList.add(styleItems[i]!);
      }
    }

    if(imageStyleList.isNotEmpty){
      resourceTypeList.add(ResourceTypeEnum.image);
    }
    if(videoStyleList.isNotEmpty){
      resourceTypeList.add(ResourceTypeEnum.video);
    }

    if(videoStyleList.isEmpty){
      resourceType = ResourceTypeEnum.image;
    }


  }

  /// 获取视觉风格
  Future<void> getStyleList() async{
    try {
      ToastUtils.showLoading();
      TeamStyleEntity? res = await AccountUtil.getTeamStyle();
      if(res == null) return;
      teamStyeData = res;
      initData();
    } finally{
      ToastUtils.hideLoading();
    }
  }


  List<TeamStyleEntityStyleItems> _getCurrentStyleList(ResourceTypeEnum type){
    if(type == ResourceTypeEnum.video){
      return videoStyleList;
    }
    return imageStyleList;
  }

  void _switchResourceType(ResourceTypeEnum targetType){
    if(resourceType == targetType) return;

    List<TeamStyleEntityStyleItems> list = _getCurrentStyleList(targetType);

    Set<String> validCodeList = list.map((item) => item.style).whereType<String>().toSet();

    takeEffectCodeList.removeWhere((code) => !validCodeList.contains(code));
    resourceType = targetType;

    if(mounted) {
      setState(() {});
    }
  }


  /// 确认使用
  Future<void> confirmUsage() async{
    if(takeEffectCodeList.isEmpty) return ToastUtils.showToast(text: "请选择风格");

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "imageStyleUses": takeEffectCodeList.toList(),
        "mediaModeUse": resourceType == ResourceTypeEnum.image ? 0 : 1,
      };
      bool res = await AccountUtil.teamConfigStyleEdit(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "设置成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }


  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 1400.wMin,
              padding: EdgeInsets.all(32.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.wMin),
                color: AppTheme.cSurfaceSecondary.color,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  _buildTitleWidget(),

                  _buildModeWidget(),

                  _buildStyleWidget(),

                  _buildButtonsWidget(),

                ],
              ),
            ),

            Positioned(
              top: 16.wMin,
              right: 16.wMin,
              child: TapScaleWidget(
                sclae: 1.05,
                onTap: () => Get.back(),
                child: Container(
                  width: 56.wMin,
                  height: 56.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cSurfaceQuaternary.color,
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/public/x.svg",
                    width: 32.wMin,
                    height: 32.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }


  Widget _buildTitleWidget(){
    return Container(
      alignment: Alignment.center,
      child: Text(
        "选择使用风格",
        style: TextStyle(
          fontSize: 32.wMin,
          color: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 模式选择
  Widget _buildModeWidget(){
    return Container(
      margin: EdgeInsets.only(top: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "选择模式",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.wMin),
          Row(
            spacing: 8.wMin,
            children: List.generate(resourceTypeList.length, (index){

              bool selected = resourceTypeList[index] == resourceType;

              return Expanded(
                child: TapScaleWidget(
                  onTap: () {
                    _switchResourceType(resourceTypeList[index]);
                  },
                  sclae: 1,
                  child: Container(
                    height: 64.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.wMin),
                      color: selected ? resourceTypeList[index].color.withValues(alpha: 0.2) : AppTheme.cSurfaceTertiary.color,
                      border: Border.all(
                        width: 1.wMin,
                        color: selected ? resourceTypeList[index].color : AppTheme.cSurfaceTertiary.color,
                      ),
                    ),
                    child: Row(
                      spacing: 8.wMin,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          resourceTypeList[index].svg,
                          width: 28.wMin,
                          colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                        ),
                        Text(
                          resourceTypeList[index].name,
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

            }),
          ),
        ],
      ),
    );
  }


  /// 选择风格
  Widget _buildStyleWidget(){
    return Container(
      margin: EdgeInsets.only(top: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Text(
                "${resourceType.name}模式",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "（可多选）",
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(),

              Text.rich(TextSpan(
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(text: "已选择 "),
                  TextSpan(
                    text: "${takeEffectCodeList.length}",
                    style: TextStyle(
                      color: resourceType.color,
                    ),
                  ),
                  const TextSpan(text: " 个风格"),
                ],
              )),

            ],
          ),

          SizedBox(height: 4.wMin),

          Visibility(
            visible: resourceType == ResourceTypeEnum.image,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 16.wMin,
                children: List.generate(imageStyleList.length, (index){
                  return _buildStyleListItemWidget(imageStyleList[index]);
                }),
              ),
            ),
          ),

          Visibility(
            visible: resourceType == ResourceTypeEnum.video,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 16.wMin,
                children: List.generate(videoStyleList.length, (index){
                  return _buildStyleListItemWidget(videoStyleList[index]);
                }),
              ),
            ),
          ),

        ],
      ),
    );
  }


  Widget _buildStyleListItemWidget(TeamStyleEntityStyleItems data){

    bool selected = takeEffectCodeList.contains(data.style);

    String? imageUrl = data.image?.imageUrl??"";
    if(resourceType == ResourceTypeEnum.video){
      imageUrl = data.video?.firstFrameUrl;
    }

    LanguageText? localText = LearningLangUtils.getLocalLang(data.styleTitle??[]);

    return TapScaleWidget(
      onTap: () {
        if(data.style == null) return;
        
        if(selected){
          takeEffectCodeList.remove(data.style);
        }else{
          takeEffectCodeList.add(data.style!);
        }
        if(mounted) setState(() {});

      },
      sclae: 1.01,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.wMin),
        child: Container(
          width: 251.wMin,
          color: AppTheme.cSurfaceTertiary.color,
          child: Column(
            children: [
              
              AspectRatio(
                aspectRatio: 1,
                child: CachedImageWidget(
                  imageUrl??"",
                  errorWidget: buildEmptyWidget(),
                  placeholder: buildLoadingWidget(),
                ),
              ),

              SizedBox(height: 12.wMin),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                child: Row(
                  children: [
                
                    Expanded(
                      child: Text(
                        localText?.text??"",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                
                    SvgPicture.asset(
                      selected ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
                      width: 32.wMin,
                    ),
                
                  ],
                ),
              ),
              SizedBox(height: 16.wMin),
            ],
          ),
        ),
      ),
    );

  }


  /// 按钮
  Widget _buildButtonsWidget(){
    return Container(
      margin: EdgeInsets.only(top: 48.wMin),
      child: Row(
        spacing: 12.wMin,
        children: [
          Expanded(
            child: ButtonWidget(
              text: "取消",
              height: 72.wMin,
              color: AppTheme.cSurfaceTertiary.color,
              fontColor: AppTheme.cTextTertiary.color,
              fontSize: 28.wMin,
              borderRadius: 12.wMin,
              sclae: 1.01,
              onTap: () {
                Get.back();
              },
            ),
          ),

          Expanded(
            child: ButtonWidget(
              text: "确认使用",
              height: 72.wMin,
              color: resourceType.color,
              fontSize: 28.wMin,
              borderRadius: 12.wMin,
              sclae: 1.01,
              onTap: () {
                confirmUsage();
              },
            ),
          ),

        ],
      ),
    );
  }



}