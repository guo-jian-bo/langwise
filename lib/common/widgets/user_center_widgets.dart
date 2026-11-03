import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../app/modules/user_center/common/recommended_tags_widget.dart';
import '../../theme/theme.dart';
import '../entities/user_info_entity.dart';
import '../enum/enum.dart';
import 'widgets.dart';

class UserBalanceIcon extends StatelessWidget {
  /// 0=卡券 1=学点 2=乃币
  final int type;
  final double? boxSize;
  final double? iconSize;
  final double bgColorOption;
  final Color? iconColor;
  const UserBalanceIcon({super.key, this.type = 0, this.boxSize, this.iconSize, this.bgColorOption = 0.2, this.iconColor});

  @override
  Widget build(BuildContext context) {
    Color? backColor;
    String? title;
    String? svg;
    if (type == 0) {
      backColor = AppTheme.cCardCouponsBg;
      title = "卡券";
      svg = "assets/svg/user_center/icon_voucher.svg";
    } else if (type == 1) {
      backColor = AppTheme.cLearnSomethingBg;
      title = "学点";
      svg = "assets/svg/user_center/icon_points.svg";
    } else if (type == 2) {
      backColor = AppTheme.cNsCoinBg;
      title = "乃币";
      svg = "assets/svg/user_center/icon_ncurrency.svg";
    }
    if (backColor == null || title == null || svg == null) return Container();
    return Container(
      width: boxSize ?? 47.wMin,
      height: boxSize ?? 47.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backColor.withValues(alpha: bgColorOption),
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        svg,
        width: iconSize ?? 32.wMin,
        height: iconSize ?? 32.wMin,
        colorFilter: iconColor != null ? ColorFilter.mode(iconColor!, BlendMode.srcIn) : null,
      ),
    );
  }
}


class UserLearnPointsWidget extends StatelessWidget {
  final int points;
  final double? iconSize;
  /// 学点
  const UserLearnPointsWidget({super.key, required this.points, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 3.wMin,
        top: 2.wMin,
        bottom: 2.wMin,
        right: 16.wMin,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppTheme.cInverseOverlay.color,
      ),
      child: Row(
        spacing: 8.wMin,
        children: [
          Image.asset(
            "assets/images/public/icon_learn_point.png",
            width: iconSize ?? 40.wMin,
            height: iconSize ?? 40.wMin,
          ),
          Text(
            NumberUtils.formatNumberWithCommas(points.toDouble()),
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
      
        ],
      ),
    );
  }
}


class UserNaiCoinWidget extends StatelessWidget {
  final int coins;
  final double? iconSize;
  /// 乃币
  const UserNaiCoinWidget({super.key, required this.coins, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 3.wMin,
        top: 2.wMin,
        bottom: 2.wMin,
        right: 16.wMin,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppTheme.cInverseOverlay.color,
      ),
      child: Row(
        spacing: 8.wMin,
        children: [
          Image.asset(
            "assets/images/public/icon_nai_coin.png",
            width: iconSize ?? 40.wMin,
            height: iconSize ?? 40.wMin,
          ),
          Text(
            NumberUtils.formatNumberWithCommas(coins.toDouble() / 100),
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
      
        ],
      ),
    );
  }
}

class UserMemberIconWidget extends StatelessWidget {
  final String? member;
  final int? day;
  final double? iconHeight;
  /// 会员
  const UserMemberIconWidget({super.key, this.member, this.day, this.iconHeight});

  @override
  Widget build(BuildContext context) {
    if(day == null || (day??0) <= 0) return Container();

    MemberEnum memberEnum = MemberEnum.from(member);
    
    String iconPath = "";
    if(memberEnum == MemberEnum.Free){

    }else if(memberEnum == MemberEnum.Plus){
      iconPath = "assets/images/public/icon_plus.png";
    }else if(memberEnum == MemberEnum.Pro){
      iconPath = "assets/images/public/icon_pro.png";
    }else if(memberEnum == MemberEnum.Max){
      iconPath = "assets/images/public/icon_max.png";
    }

    if(iconPath.isEmpty) return Container();

    return Container(
      padding: EdgeInsets.only(
        left: 3.wMin,
        top: 2.wMin,
        bottom: 2.wMin,
        right: 16.wMin,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppTheme.cInverseOverlay.color,
      ),
      child: Row(
        spacing: 8.wMin,
        children: [
          Image.asset(
            iconPath,
            height: iconHeight ?? 40.wMin,
          ),
          Text(
            "${day??0}天",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
      
        ],
      ),
    );
  }
}



class UserMemberBorderButton extends StatelessWidget {
  final String? member;
  final String? vipEnd;
  final String? avatarUrl;
  final List<UserInfoEntityVipConfigs?>? vipConfigs;
  final void Function()? onTap;
  const UserMemberBorderButton({super.key, this.member, this.vipEnd, this.onTap, this.avatarUrl, this.vipConfigs});

  @override
  Widget build(BuildContext context) {
    MemberLevelColor colors = StatusUtils.getMemberColorsByVipConfigs(vipConfigs, member);

    int days = 0;
    DateTime? vipEndDate = DateFormatUtil.tryParseDate(vipEnd);
    DateTime nowDate = DateTime.now();
    if (vipEndDate != null) {
      days = vipEndDate.difference(nowDate).inDays;
    }

    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.03,
      child: Container(
        height: 56.wMin,
        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          border: Border.all(width: 1.wMin, color: colors.deep),
          color: colors.pale.withValues(alpha: 0.2),
        ),
        child: Row(
          children: [
            ClipOval(
              child: Container(
                width: 32.wMin,
                height: 32.wMin,
                color: AppTheme.cBlackAlpha10,
                child: CachedImageWidget(
                  avatarUrl ?? "",
                  placeholder: Container(),
                  errorWidget: Center(
                    child: SvgPicture.asset(
                      "assets/svg/user_center/icon_head.svg",
                      height: 18.wMin,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.wMin),
            Text(
              "${member ?? ''} 会员",
              style: TextStyle(
                fontSize: 24.wMin,
                color: colors.deep,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 16.wMin),
            Visibility(
              visible: days != 0,
              child: Text(
                "$days天",
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: colors.deep,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SvgPicture.asset(
              "assets/svg/user_center/icon_chevron_right.svg",
              width: 24.wMin,
              height: 24.wMin,
              colorFilter: const ColorFilter.mode(AppTheme.cTextPrimary, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}

class UserStudentCard extends StatelessWidget {
  /// 头像
  final String? userHardPath;

  /// 名字
  final String? name;
  final String? content;

  /// 进度百分比
  final int? progressPercentage;
  final bool selected;
  final bool isAddCard;
  final void Function()? onTap;
  final void Function()? onAdd;
  final void Function()? onEdit;
  const UserStudentCard({
    super.key,
    this.userHardPath,
    this.name,
    this.content,
    this.progressPercentage,
    this.selected = false,
    this.onTap,
    this.isAddCard = false,
    this.onAdd,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (isAddCard) {
      return TapScaleWidget(
        onTap: onAdd,
        sclae: 1.01,
        child: Container(
          width: 320.wMin,
          height: 394.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cBgSecondary,
          ),
          child: Column(
            spacing: 16.wMin,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/svg/user_center/icon_add_circle.svg",
                width: 48.wMin,
                height: 48.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
              ),
              Text(
                "添加学员",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      width: 320.wMin,
      height: 394.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cBgSecondary,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              SizedBox(height: 20.wMin),
              Container(
                width: 145.wMin,
                height: 145.wMin,
                decoration: BoxDecoration(
                  color: AppTheme.cBlackAlpha10,
                  shape: BoxShape.circle,
                  border: !selected ? null : Border.all(width: 6.wMin, color: AppTheme.cBgBrand.color),
                ),
                child: ClipOval(
                  child: CachedImageWidget(
                    userHardPath ?? "",
                    errorWidget: Center(
                      child: SvgPicture.asset(
                        "assets/svg/public/icon_user.svg",
                        width: 145.wMin,
                        height: 145.wMin,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.wMin),
              Text(
                name ?? "",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.wMin),
              Text(
                content ?? "",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20.wMin),
              // SizedBox(
              //   width: 280.wMin,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Container(
              //         width: 230.wMin,
              //         height: 8.wMin,
              //         alignment: Alignment.centerLeft,
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(10.wMin),
              //           color: AppTheme.cBlackAlpha10,
              //         ),
              //         child: AnimatedContainer(
              //           duration: const Duration(milliseconds: 100),
              //           width: 230.wMin * ((progressPercentage??0) / 100),
              //           height: 8.wMin,
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(10.wMin),
              //             color: AppTheme.cBgBrand,
              //           ),
              //         ),
              //       ),
              //       Text(
              //         "${progressPercentage??0}%",
              //         style: TextStyle(
              //           fontSize: 16.wMin,
              //           color: AppTheme.cTextTertiary,
              //           fontWeight: FontWeight.w400,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const Spacer(),
              TapScaleWidget(
                onTap: onTap,
                sclae: 1.05,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 288.wMin,
                  height: 56.wMin,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: selected ? AppTheme.cBgBrand.color : AppTheme.cBgTertiary.color,
                  ),
                  child: Row(
                    spacing: 4.wMin,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        selected ? "assets/svg/user_center/icon_head.svg" : "assets/svg/user_center/icon_switcher.svg",
                        height: 24.wMin,
                      ),
                      Text(
                        selected ? "当前学员" : "切换学员",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: selected ? AppTheme.cStaticWhite : AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.wMin),
            ],
          ),
          Visibility(
            visible: onEdit != null,
            child: Positioned(
              right: 0,
              top: 0,
              child: TapScaleWidget(
                onTap: onEdit,
                sclae: 1.05,
                child: Container(
                  padding: EdgeInsets.all(16.wMin),
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_edit.svg",
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

class UserSettingOpenTitleWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final String svg;
  final bool isOpen;
  final void Function()? onTap;
  const UserSettingOpenTitleWidget({
    super.key,
    required this.title,
    required this.subTitle,
    this.isOpen = false,
    this.onTap,
    required this.svg,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1,
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50.wMin,
              height: 50.wMin,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cFeedbackInfoBackground,
              ),
              child: SvgPicture.asset(
                svg,
                width: 30.wMin,
                height: 30.wMin,
              ),
            ),
            SizedBox(width: 8.wMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.wMin,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subTitle,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.wMin),
            AnimatedRotation(
              duration: const Duration(milliseconds: 100),
              turns: isOpen ? 0.5 : 0,
              child: SvgPicture.asset(
                "assets/svg/user_center/icon_caret_down.svg",
                width: 32.wMin,
                height: 32.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserSettingSelectCardWidget extends StatefulWidget {
  final String title;
  final String subTitle;
  final String value;
  final String? audio;
  final bool selected;
  final bool showRecommendedTags;
  final void Function()? onTap;
  final double width;
  const UserSettingSelectCardWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.value,
    this.audio,
    this.selected = false,
    this.showRecommendedTags = false,
    this.onTap,
    this.width = 755/2,
  });

  @override
  State<UserSettingSelectCardWidget> createState() => _UserSettingSelectCardWidgetState();
}

class _UserSettingSelectCardWidgetState extends State<UserSettingSelectCardWidget> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width.wMin,
      child: TapScaleWidget(
        onTap: widget.onTap,
        sclae: 1.02,
        child: Container(
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cSurfaceTertiary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 4.wMin,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary,
                    ),
                  ),
                  Visibility(
                    visible: widget.showRecommendedTags,
                    child: const RecommendedTagsWidget(),
                  ),
                  const Spacer(),
                  CardSelectDot1Widget(isSelected: widget.selected),
                ],
              ),
              Text(
                widget.subTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: AppTheme.cTextTertiary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 114.wMin,
                child: TapScaleWidget(
                  onTap: () async {
                    isPlaying = true;
                    if (mounted) setState(() {});
                    await PlayAudioUtils.instance.playSingle(widget.audio);
                    isPlaying = false;
                    if (mounted) setState(() {});
                  },
                  sclae: 1.03,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.wMin),
                      color: AppTheme.cSurfaceSecondary,
                    ),
                    child: Column(
                      spacing: 8.wMin,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.value,
                          style: TextStyle(
                            fontSize: 28.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Visibility(
                          visible: widget.audio != null,
                          child: AnimationPlayIconWidget(
                            isPlaying: isPlaying,
                            size: 29.wMin,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserSettingExampleModel {
  final String title;
  final String? subTitle;
  List<UserSettingExampleDataModel> example;
  UserSettingExampleModel({
    required this.title,
    this.subTitle,
    required this.example,
  });
}

class UserSettingExampleDataModel {
  final String? image;
  final String text;
  final String? audio;
  UserSettingExampleDataModel({
    this.image,
    required this.text,
    this.audio,
  });
}

class UserSettingExampleWidget extends StatefulWidget {
  final String title;
  final List<UserSettingExampleModel> datas;
  const UserSettingExampleWidget({super.key, required this.title, required this.datas});

  @override
  State<UserSettingExampleWidget> createState() => _UserSettingExampleWidgetState();
}

class _UserSettingExampleWidgetState extends State<UserSettingExampleWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12.wMin),
        Container(
          width: double.infinity,
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cBgTertiary,
          ),
          child: IntrinsicHeight(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.datas.length, (index) {
                  UserSettingExampleModel data = widget.datas[index];
                  return _buildTableItemWidget(data.title, data.subTitle, data.example, index);
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableItemWidget(String titleText, String? subTitleText, List<UserSettingExampleDataModel> example, int index) {
    return Container(
      width: 770.wMin / 2,
      decoration: BoxDecoration(
        border: index == 0
            ? null
            : Border(
                left: BorderSide(color: AppTheme.cBorderPrimary, width: 0.5.wMin),
              ),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: 80.wMin,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titleText,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Visibility(
                  visible: subTitleText != null && subTitleText.isNotEmpty,
                  child: Text(
                    subTitleText ?? "",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: AppTheme.cTextSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 0.5.wMin, color: AppTheme.cBorderPrimary),
          Container(
            padding: EdgeInsets.all(16.wMin),
            child: Column(
              spacing: 16.wMin,
              children: List.generate(example.length, (index) {
                return UserSettingExampleItemWidget(example: example[index]);
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class UserSettingExampleItemWidget extends StatefulWidget {
  final UserSettingExampleDataModel example;
  const UserSettingExampleItemWidget({super.key, required this.example});

  @override
  State<UserSettingExampleItemWidget> createState() => _UserSettingExampleItemWidgetState();
}

class _UserSettingExampleItemWidgetState extends State<UserSettingExampleItemWidget> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: widget.example.audio == null
          ? null
          : () async {
              isPlaying = true;
              if (mounted) setState(() {});
              await PlayAudioUtils.instance.playSingle(widget.example.audio);
              isPlaying = false;
              if (mounted) setState(() {});
            },
      sclae: 1.02,
      child: Container(
        width: 274.wMin,
        padding: EdgeInsets.symmetric(vertical: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cBgTertiary,
        ),
        child: Column(
          spacing: 16.wMin,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.wMin),
              child: Container(
                color: AppTheme.cBlackAlpha10,
                width: 140.wMin,
                height: 140.wMin,
                child: CachedImageWidget(
                  widget.example.image ?? "",
                  errorWidget: Container(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8.wMin,
              children: [
                Visibility(
                  visible: widget.example.audio != null,
                  child: AnimationPlayIconWidget(isPlaying: isPlaying, size: 24.wMin),
                ),
                Text(
                  widget.example.text,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cTextSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserTapTitleWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final String svg;
  final String value;
  final void Function()? onTap;
  const UserTapTitleWidget({
    super.key,
    required this.title,
    required this.subTitle,
    this.value = "",
    this.onTap,
    required this.svg,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.01,
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50.wMin,
              height: 50.wMin,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cFeedbackInfoBackground,
              ),
              child: SvgPicture.asset(
                svg,
                width: 30.wMin,
                height: 30.wMin,
              ),
            ),
            SizedBox(width: 8.wMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.wMin,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subTitle,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.wMin),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SvgPicture.asset(
                  "assets/svg/user_center/icon_chevron_right1.svg",
                  width: 32.wMin,
                  height: 32.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MemberCardWidget extends StatefulWidget {
  final String? member;

  /// 学员数量
  final int studentNumber;

  /// 到期时间
  final String? vipEnd;
  final List<UserInfoEntityVipConfigs?>? vipConfigs;
  const MemberCardWidget({
    super.key,
    this.member,
    this.studentNumber = 0,
    this.vipEnd,
    this.vipConfigs,
  });

  @override
  State<MemberCardWidget> createState() => _MemberCardWidgetState();
}

class _MemberCardWidgetState extends State<MemberCardWidget> {
  @override
  Widget build(BuildContext context) {
    MemberLevelColor memberColors = StatusUtils.getMemberColorsByVipConfigs(widget.vipConfigs, widget.member);

    String expireDate = "";
    int day = 0;
    DateTime? vipEndDate = DateFormatUtil.tryParseDate(widget.vipEnd);
    DateTime nowDate = DateTime.now().toLocal();
    if (vipEndDate != null) {
      day = vipEndDate.difference(nowDate).inDays;
      expireDate = DateFormatUtil.formatStr(vipEndDate, locale: Get.locale);
    } else {
      expireDate = "永久有效";
    }

    return Container(
      width: 386.wMin,
      height: 220.wMin,
      padding: EdgeInsets.only(left: 16.wMin, right: 16.wMin, bottom: 23.wMin, top: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(width: 0.6.wMin, color: AppTheme.cWhiteAlpha20.color),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            memberColors.pale,
            memberColors.deep,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.member ?? "",
                style: TextStyle(
                  fontSize: 48.wMin,
                  color: AppTheme.cStaticWhite,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              Visibility(
                visible: widget.studentNumber != 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 2.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.wMin),
                    color: AppTheme.cBlackAlpha10,
                    border: Border.all(width: 1.wMin, color: memberColors.deep),
                  ),
                  child: Row(
                    spacing: 4.wMin,
                    children: [
                      SvgPicture.asset(
                        "assets/svg/user_center/icon_user_circle_plus.svg",
                        width: 20.wMin,
                        height: 20.wMin,
                      ),
                      Text(
                        "${widget.studentNumber}个学员",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: AppTheme.cWhiteAlpha70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Text(
            "会员用户",
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cStaticWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Visibility(
            visible: day != 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: 8.wMin,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.wMin),
                    color: AppTheme.cBlackAlpha10,
                    border: Border.all(width: 0.5.wMin, color: AppTheme.cWhiteAlpha20.color),
                  ),
                  child: Container(
                    width: 50.wMin,
                    height: 8.wMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.wMin),
                      color: AppTheme.cWhiteAlpha70,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8.wMin),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "到期时间：$expireDate",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cStaticWhite,
                  fontSize: 14.wMin,
                ),
              ),
              Visibility(
                visible: day != 0,
                child: Text(
                  "还剩$day天",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cStaticWhite,
                    fontSize: 14.wMin,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserArrowTiele extends StatelessWidget {
  final String title;
  final double? iconSize;
  final double? fontSize;
  final FontWeight? fontWeight;
  const UserArrowTiele({super.key, required this.title, this.iconSize, this.fontSize, this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize ?? 24.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: fontWeight ?? FontWeight.w500,
          ),
        ),
        SvgPicture.asset(
          "assets/svg/user_center/icon_chevron_right1.svg",
          width: iconSize ?? 24.wMin,
          height: iconSize ?? 24.wMin,
        ),
      ],
    );
  }
}

class UserAssetsInfoModel {
  final String title;

  /// 0=卡券 1=学点 2=乃币
  final int type;
  final String balance;
  final String balanceDesc;

  UserAssetsInfoModel({
    required this.title,
    required this.type,
    required this.balance,
    required this.balanceDesc,
  });
}

class UserAssetsInfoCertificateModel {
  final String value;
  final String name;
  UserAssetsInfoCertificateModel({
    required this.value,
    required this.name,
  });
}

class UserAssetsInfoCardWidget extends StatelessWidget {
  final UserAssetsInfoModel infoData;
  final Widget child;
  final Widget? buttons;
  final void Function()? onTap;
  const UserAssetsInfoCardWidget({
    super.key,
    required this.infoData,
    required this.child,
    this.buttons,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.015,
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.wMin),
          color: AppTheme.cBgSecondary,
        ),
        child: Column(
          children: [
            UserArrowTiele(title: infoData.title),
            SizedBox(height: 16.wMin),
            Container(
              padding: EdgeInsets.all(16.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: AppTheme.cBgTertiary,
              ),
              child: Column(
                spacing: 16.wMin,
                children: [
                  Row(
                    spacing: 12.wMin,
                    children: [
                      UserBalanceIcon(type: infoData.type, boxSize: 74.wMin, iconSize: 50.wMin),
                      Column(
                        spacing: 2.wMin,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            infoData.balance,
                            style: TextStyle(
                              fontSize: 40.wMin,
                              color: AppTheme.cTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            infoData.balanceDesc,
                            style: TextStyle(
                              fontSize: 20.wMin,
                              color: AppTheme.cTextTertiary,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: 104.wMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.wMin),
                      color: AppTheme.cBgQuaternary,
                    ),
                    child: child,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.wMin),
            SizedBox(
              child: buttons,
            ),
          ],
        ),
      ),
    );
  }
}
