import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/stores/stores.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';

class MissionSpecialCardWidget extends StatefulWidget {
  final int index;
  final TaskMissionMenuListEntityList data;
  final void Function(TaskMissionMenuListEntityList value)? onTap;
  const MissionSpecialCardWidget({super.key, required this.index, required this.data, this.onTap});

  @override
  State<MissionSpecialCardWidget> createState() => _MissionSpecialCardWidgetState();
}

class _MissionSpecialCardWidgetState extends State<MissionSpecialCardWidget> {

  bool _hover = false;
  
  @override
  Widget build(BuildContext context) {
    LSRWStatusColor colors = StatusUtils.getLSRWStatusColor(widget.data.type??"");

    return MouseRegion(
      onEnter: (event){
        setState(() {
          _hover = true;
        });
      },
      onExit: (event){
        setState(() {
          _hover = false;
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _hover ? 1.01 : 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.wMin),
          child: Container(
            color: AppTheme.cSurfaceSecondary.color,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    left: 16.wMin,
                    right: 16.wMin,
                    top: 20.wMin,
                    bottom: 16.wMin,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.wMin),
                    border: Border(
                      top: BorderSide(
                        color: colors.primary, 
                        width: 3.wMin,
                      ),
                    ),
                  ),
                  child: _buildContentWidget(),
                ),
                Positioned(
                  right: -30.wMin,
                  top: -5.wMin,
                  child: _buildNewTagWidget(),
                ),
                Positioned(
                  right: -30.wMin,
                  top: -5.wMin,
                  child: _buildCompleteTagWidget(),
                ),
                Visibility(
                  visible: !widget.data.isNormal,
                  child: Container(
                    color: AppTheme.cInverseOverlay.color,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      "assets/svg/mission/icon_lock.svg",
                      fit: BoxFit.cover,
                      height: 56.wMin,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  /// 完成标签
  Widget _buildCompleteTagWidget(){
    if(!widget.data.learned) return Container();
    LSRWStatusColor colors = StatusUtils.getLSRWStatusColor(widget.data.type??"");
    return Transform.rotate(
      angle: 0.7,
      child: Container(
        width: 100.wMin,
        height: 40.wMin,
        padding: EdgeInsets.only(top: 6.wMin),
        alignment: Alignment.center,
        color: colors.primary,
        child: Transform.rotate(
          angle: -0.7,
          child: SvgPicture.asset(
            "assets/svg/public/icon_check_w.svg",
            fit: BoxFit.cover,
            height: 32.wMin,
          ),
        ),
      ),
    );
  }

  /// new 标签
  Widget _buildNewTagWidget(){
    if(!widget.data.notYetLearned) return Container();
    return Transform.rotate(
      angle: 0.7,
      child: Container(
        width: 100.wMin,
        height: 40.wMin,
        alignment: Alignment.bottomCenter,
        color: AppTheme.cSurfaceError.color,
        child: Text(
          "New",
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cInverseTextLight.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 会员标签
  Widget _buildVipTagWidget(){
    if(widget.data.vipType == null) return Container();
    List<UserInfoEntityVipConfigs?>? vipConfigs = UserStore.to.userInfo.value.vipConfigs;
    MemberLevelColor colors = StatusUtils.getMemberColorsByVipConfigs(vipConfigs, widget.data.vipType);

    return Container(
      height: 26.wMin,
      padding: EdgeInsets.symmetric(horizontal: 8.wMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: colors.pale,
      ),
      child: Text(
        widget.data.vipType??"",
        style: TextStyle(
          fontSize: 16.wMin,
          color: AppTheme.cInverseTextLight.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 内容
  Widget _buildContentWidget(){
    LSRWStatusColor colors = StatusUtils.getLSRWStatusColor(widget.data.type??"");

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: _hover ? 1.02 : 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.wMin),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                    ),
                    child: CachedImageWidget(
                      widget.data.iconUrl??"",
                      fadeInDuration: Duration.zero,
                      placeholder: Container(),
                      errorWidget: Center(
                        child: SvgPicture.asset(
                          colors.svg,
                          width: 80.wMin,
                          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8.wMin,
                  top: 8.wMin,
                  child: _buildVipTagWidget(),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.wMin),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data.title??"",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 32.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.wMin),
              Text(
                widget.data.describe??"",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Visibility(
                      visible: widget.data.tags != null,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          scrollbars: false, // 隐藏滚动条
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: 6.wMin,
                            children: List.generate((widget.data.tags?.length)??0, (index){
                              return _buildTagItemWidget(tag: widget.data.tags?[index]);
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildButtonWidget(),
                ],
              ),
          
            ],
          ),
        ),
      ],
    );
  }

    /// 标签item
  Widget _buildTagItemWidget({
    required TaskMissionMenuListEntityListTags? tag,
  }){
    if(tag == null) return Container();
    tag.gloss;
    LanguageText? gloss = LearningLangUtils.getShowLList(tag.gloss);
    ThemeTextStyleEntity? currentThemeText = StyleUtils.getCurrentThemeText(tag.style);
    TextStyle? textStyle = StyleUtils.getTextStyle(tag.style, defaultSize: 28);
    
    Color? bgColor = ColorUtils.parseColor(currentThemeText?.backgroundColor);
    Color? borderColor = ColorUtils.parseColor(currentThemeText?.borderColor);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.wMin),
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: 1.wMin,
        ),
      ),
      child: Text(
        gloss?.text??"",
        style: textStyle,
      ),
    );
  }


  /// 按钮
  Widget _buildButtonWidget(){
    LSRWStatusColor colors = StatusUtils.getLSRWStatusColor(widget.data.type??"");

    Color buttonBgColor = colors.primary;
    String buttonText = "开始";
    if(!widget.data.isNormal){
      buttonText = "未解锁";
    }
    // else if(widget.data.learned){
    //   buttonBgColor = AppTheme.cInverseOverlay.color;
    //   buttonText = "已完成";
    // }

    return ButtonWidget(
      text: buttonText,
      color: buttonBgColor,
      fontColor: AppTheme.cInverseTextLight.color,
      height: 56.wMin,
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      borderRadius: 8.wMin,
      fontWeight: FontWeight.w600,
      fontSize: 28.wMin,
      sclae: 1.01,
      onTap: !widget.data.isNormal ? null : () {
        widget.onTap?.call(widget.data);
      },
    );
  }


}