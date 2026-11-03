
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/elements/utils/elements_page_utils.dart';
import '../../../app/modules/management/common/commons.dart';
import '../../../app/modules/management/utils/utils.dart';
import '../../../app/routes/routes.dart';
import '../../../theme/theme.dart';
import '../../enum/enum.dart';
import '../widgets.dart';

class SetExpansionButtonsWidget extends StatelessWidget {
  final void Function()? onRefresh;
  final bool isManagement;
  final int? contentId;
  final String? contentType;
  final String? content;
  final int? unitId;
  /// 是否上架
  final bool isNormal;
  /// 是否显示强制分析按钮
  final void Function()? onForceAnalysis;
  /// 上下架回调
  final void Function()? onShelf;
  /// 是否显示拓展
  final bool showExpand;

  /// 上下架 视觉 题目 拓展 按钮
  const SetExpansionButtonsWidget({
    super.key, 
    this.onRefresh, 
    this.isManagement = false, 
    this.contentId, 
    this.contentType,
    this.content, 
    this.isNormal = false, 
    this.onShelf,
    this.onForceAnalysis,
    this.showExpand = true,
    this.unitId,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.wMin,
      runSpacing: 8.wMin,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if(isManagement) ...[
          if(onForceAnalysis != null) ...[
            _buildButtonWidget(
              text: "强制分析",
              showArrow: false,
              color:  AppTheme.cSurfaceWarning,
              onTap: (){
                onForceAnalysis?.call();
              },
            ),
          ],

          if(onShelf != null) ...[
            _buildButtonWidget(
              text: isNormal ? "下架" : "上架",
              color: isNormal ? AppTheme.cSurfaceSuccess : AppTheme.cSurfaceWarning,
              onTap: (){
                onShelf?.call();
              },
            ),
          ],
          _buildButtonWidget(
            text: "内容",
            onTap: _jumpToContent,
          ),
          _buildButtonWidget(
            text: "视觉",
            onTap: () async{
              await ManagePageRegistry.jumpTo(
                Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
                arguments: {
                  'type': contentType,
                  'uid': contentId,
                  "quizOrImage": 1,
                },
              );
              onRefresh?.call();
            },
          ),
          // _buildButtonWidget(
          //   text: "声音",
          // ),
          _buildButtonWidget(
            text: "题目",
            onTap: () async{
              await ManagePageRegistry.jumpTo(
                Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
                arguments: {
                  'type': contentType,
                  'uid': contentId,
                  "quizOrImage": 0,
                },
              );
              // onRefresh?.call(binding);
            },
          ),

        ],
        
        if(showExpand) ...[
          _buildButtonWidget(
            text: "拓展",
            onTap: () {
              ElementsPageUtils.jumpElementsPage(
                contentId: contentId, 
                contentType: contentType, 
                semanticId: null, 
                content: content??'',
                styleId: null, 
                dialect: null,
                isManagement: isManagement,
              );
            },
          ),
        ],
        

      ],
    );

  }

  /// 跳转至内容页
  Future<void> _jumpToContent() async {
    if (contentId == null || contentType == null) return;
    final KnowledgeTypeEnum? contentTypeEnum = KnowledgeTypeEnum.fromRawValue(contentType??"");
    String routes = "";
    if (contentTypeEnum == KnowledgeTypeEnum.EN_WORD) {
      routes = Routes.MANAGE_WORD;
    } else if (contentTypeEnum == KnowledgeTypeEnum.EN_PHRASE) {
      routes = Routes.MANAGE_PHRASE;
    } else if (contentTypeEnum == KnowledgeTypeEnum.EN_SENTENCE) {
      routes = Routes.MANAGE_SENTENCE;
    } else if (contentTypeEnum == KnowledgeTypeEnum.EN_TEXT) {
      routes = Routes.MANAGE_ARTICLE;
    } else if (contentTypeEnum == KnowledgeTypeEnum.EN_SONG) {
      routes = Routes.MANAGE_SONG;
    } else if(contentTypeEnum == KnowledgeTypeEnum.EN_COMPOSITION){
      routes = Routes.ZHENXIE_COMPOSITION_INSTANCES;
    }
    if (routes.isEmpty) return;

    await ManagePageRegistry.jumpTo(
      routes,
      arguments: {
        "uid": contentId!,
        "isManagement": isManagement,
        "unitId": unitId,
      },
    );
    onRefresh?.call();
  }

  Widget _buildButtonWidget({
    required String text,
    void Function()? onTap,
    bool showArrow = true,
    Color color = AppTheme.cSurfaceBrand,
  }){
    return ButtonWidget(
      text: text,
      sclae: 1.03,
      onTap: onTap,
      padding: EdgeInsets.only(
        left: showArrow ? 8.wMin : 0,
      ),
      height: 38.wMin,
      width: 84.wMin,
      borderRadius: 99,
      color: color.withValues(alpha: 0.2),
      border: Border.all(
        color: color.withValues(alpha: 0.3),
        width: 1.wMin,
      ),
      fontSize: 16.wMin,
      fontColor: AppTheme.cTextPrimary.color,
      fontWeight: FontWeight.w500,
      rightIcon: !showArrow ? null : SvgPicture.asset(
        "assets/svg/public/icon_w_arrow_right.svg",
        width: 20.wMin,
        colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
      ),
    );
  }

}


class ManageIpDownEditDelWidget extends StatelessWidget {
  /// 是否上架
  final bool isNormal;
  /// 上下架回调
  final void Function()? onShelf;
  /// 编辑按钮回调
  final void Function()? onEdit;
  /// 删除按钮回调
  final void Function()? onDelete;

  const ManageIpDownEditDelWidget({
    super.key, 
    this.isNormal = false,
    this.onShelf,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTertiary.color,
        borderRadius: BorderRadius.circular(6.wMin),
      ),
      child: Row(
        children: [
          Visibility(
            visible: onShelf != null,
            child: ListingAndDelistingWidget(
              value: isNormal,
              showBorder: onEdit != null || onDelete != null,
              onChange: () {
                onShelf?.call();
              },
            ),
          ),
          Visibility(
            visible: onEdit != null,
            child: Container(
              margin: EdgeInsets.only(left: 8.wMin),
              child: TapScaleWidget(
                onTap: () async {
                  onEdit?.call();
                },
                sclae: 1,
                borderRadius: 8.wMin,
                backColor: AppTheme.cSurfaceTertiary.color,
                child: Container(
                  width: 50.wMin,
                  height: 40.wMin,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    "assets/svg/manage/icon_edit.svg",
                    width: 24.wMin,
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: onDelete != null,
            child: Container(
              margin: EdgeInsets.only(left: 8.wMin),
              child: TapScaleWidget(
                onTap: () async {
                  onDelete?.call();
                },
                sclae: 1,
                borderRadius: 8.wMin,
                backColor: AppTheme.cSurfaceTertiary.color,
                child: Container(
                  width: 50.wMin,
                  height: 40.wMin,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_delete.svg",
                    width: 24.wMin,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
