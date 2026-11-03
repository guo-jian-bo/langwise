import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';

/// 选择渠道员工
class ManageSelectChannelUserDialog{
  static Future<ManagePermissionUserEntity?> show({
    required BuildContext context,
    String? title,
    String? buttonText,
  }) async{
    return await showCupertinoDialog<ManagePermissionUserEntity?>(
      context: context,
      builder: (context) {
        return ManageSelectChannelUserDialogWidget(title: title, buttonText: buttonText);
      },
    );
  }
}

class ManageSelectChannelUserDialogWidget extends StatefulWidget {
  final String? title;
  final String? buttonText;
  const ManageSelectChannelUserDialogWidget({super.key, this.title, this.buttonText});

  @override
  State<ManageSelectChannelUserDialogWidget> createState() => _ManageSelectChannelUserDialogWidgetState();
}

class _ManageSelectChannelUserDialogWidgetState extends State<ManageSelectChannelUserDialogWidget> {

  /// 搜索输入框
  final TextEditingController searchController = TextEditingController();

  List<ManagePermissionUserEntity> userList = [];

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
  void initState() {
    super.initState();
    listenScroll();
    refreshList();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange){
        if(!isLoading && userList.length < total){
          offset += limit;
          _queryUserList();
        }
      }
    });
  }

  /// 刷新列表
  Future<void> refreshList() async{
    userList.clear();
    offset = 0;
    total = 0;
    _queryUserList();
  }


  Future<void> _queryUserList() async{
    try {
      isLoading = true;
      ToastUtils.showLoading();

      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      Map<String, dynamic> reqData = {
        // "access": AccessEnum.NORMAL.value,
      };

      if(searchController.text.trim().isNotEmpty){
        reqData["keyWord"] = searchController.text.trim();
      }

      ListResponseEntity<ManagePermissionUserEntity>? res = await AccountConsoleRequest.getManagePermissionUserList(params: params, data: reqData);
      if(res == null) return;

      userList.addAll(res.datas ?? []);

      if(mounted) setState(() {});
    } finally{
      isLoading = false;
      if(mounted) setState(() {});
      ToastUtils.hideLoading();
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: widget.title ?? "选择员工",
      width: 960.wMin,
      child: SizedBox(
        height: 900.wMin,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 32.wMin),
              child: CardInputWidget(
                controller: searchController,
                hintText: "搜索 名称 / 用户ID",
                onSubmitted: (value) {
                  refreshList();
                },
                onClean: () {
                  searchController.clear();
                  refreshList();
                },
              ),
            ),
            SizedBox(height: 16.wMin),
            Expanded(child: _buildListWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildListWidget(){
    return ListView.separated(
      itemCount: userList.length,
      controller: scrollController,
      padding: EdgeInsets.only(bottom: 24.wMin, left: 32.wMin, right: 32.wMin),
      separatorBuilder: (context, index){
        return SizedBox(height: 16.wMin);
      },
      itemBuilder: (context, index){
        return _buildItemWidget(userList[index]);
      },
    );
  }

  Widget _buildItemWidget(ManagePermissionUserEntity item){
    String roleNamesText = item.roleNames?.join("、")??"";

    return TapScaleWidget(
      onTap: () {
        Get.back(result: item);
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderTranslucentNone.color,
            width: 1.wMin,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Visibility(
                        visible: item.realName != null,
                        child: SelectableText(
                          item.realName??"",
                          style: TextStyle(
                            color: AppTheme.cTextPrimary.color,
                            fontSize: 28.wMin,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SelectableText(
                        "(${item.userId??""})",
                        style: TextStyle(
                          color: AppTheme.cTextSecondary.color,
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: item.departmentName != null,
                    child: Container(
                      margin: EdgeInsets.only(top: 6.wMin),
                      child: SelectableText(
                        item.departmentName??'',
                        style: TextStyle(
                          color: AppTheme.cTextSecondary.color,
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: roleNamesText.isNotEmpty,
                    child: Container(
                      margin: EdgeInsets.only(top: 6.wMin),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 10.wMin),
                            padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 2.wMin),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.wMin),
                              color: AppTheme.cSurfaceLayerElevated.color,
                              border: Border.all(
                                width: 0.8.wMin,
                                color: AppTheme.cBorderSecondary.color,
                              ),
                            ),
                            child: Text(
                              item.adminGroupEnum?.name??"",
                              style: TextStyle(
                                color: AppTheme.cTextPrimary.color,
                                fontSize: 16.wMin,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SelectableText(
                            roleNamesText,
                            style: TextStyle(
                              color: AppTheme.cTextTertiary.color,
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.wMin),
            ButtonWidget(
              text: widget.buttonText ?? "选择TA",
              padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.1),
              border: Border.all(
                color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                width: 1.wMin,
              ),
              fontColor: AppTheme.cTextBrand.color,
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

}
