import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../common/entities/entities.dart';
import '../common/values/values.dart';
import '../common/widgets/widgets.dart';
import '../theme/theme.dart';

class LockUtils {

  /// 是否弹出了学点支付弹窗
  static bool get showPlayLearnDialog => _showPlayLearnDialog;
  static bool _showPlayLearnDialog = false;



  /// * 判断锁
  /// * 如果锁住就返回true
  /// * hintStorageKey: 自动扣除的提示储存key 按照功能模块分类
  /// * onPlaySucces: 支付成功后的调用 可以用作刷新业务
  static Future<bool> checkLock(
    LockEntity? lockEntity, 
    BuildContext context, {
    String? hintStorageKey,
    Future<void> Function()? onPlaySuccess,
  }) async {
    if (lockEntity == null) return true;

    if (lockEntity.access == null || lockEntity.rights == null) return true;

    // 有权限 并且 没锁
    if (!lockEntity.isNoRights && !lockEntity.isLock) {
      return false;
    }

    String? message = lockEntity.message;
    String? code = lockEntity.jump?.code;
    String confirmText = lockEntity.jump?.params?.confirmText ?? "确定";

    if (code == FunctionLockMethod.dialog) {
      bool askRes = await AskDialog.showUserAsk(
        context: context,
        title: "温馨提示",
        content: message,
        define: confirmText,
      );
      if (!askRes) return true;

      bool? needPwd = lockEntity.jump?.params?.jump?.needPwd;
      if (needPwd == true) {
        // 需要密码
        bool isPwdRight = await ParentPasswordialog.show(context: context, isCheckHasPassword: false);
        if (!isPwdRight) return true;
        String? routeCode = lockEntity.jump?.params?.jump?.code;
        Map<String, dynamic>? params = lockEntity.jump?.params?.jump?.params;
        if (routeCode == null) return true;
        JumpPageUtils.jumpUserPages(routeCode, params);
      }

      return true;
    } else if (code == FunctionLockMethod.upgradeAppDialog) {
      AppCheckVersionDialog.checkVersion(checkTodayShow: false);
      return true;
    } else if (code == FunctionLockMethod.learnPayDialog) {
      bool res = await showDeductingLearningPointsDialog(
        context: context,
        lockEntity: lockEntity,
        hintStorageKey: hintStorageKey,
      );
      if(res){
        await onPlaySuccess?.call();
      }
      return !res;
    } else if (code == FunctionLockMethod.openWebDialog) {
      bool askRes = await AskDialog.showUserAsk(
        context: context,
        title: "温馨提示",
        content: message,
        define: confirmText,
      );
      if (!askRes) return true;
      bool? needPwd = lockEntity.jump?.params?.jump?.needPwd;
      if (needPwd == true) {
        // 需要密码
        bool isPwdRight = await ParentPasswordialog.show(context: context, isCheckHasPassword: false);
        if (!isPwdRight) return true;
        Map<String, dynamic>? params = lockEntity.jump?.params?.jump?.params;
        if (params == null) return true;
        String? url = params['url'];
        if (url == null) return true;
        WebViewUtils.openWebView(url: url);
      }
      return true;
    } else if (code == FunctionLockMethod.toast || code == null) {
      ToastUtils.showToast(text: message ?? "权限错误");
      return true;
    }

    return true;
  }

  /// 判断是否是体验APP 如果是体验提醒去登录
  static Future<bool> checkExperienceApp(BuildContext context) async {
    bool experience = checkExperienceAppStorage();
    if (!experience) return false;
    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "需要登录才可以查看此内容",
      define: "去登录",
    );
    if (!ask) return true;
    Get.offAllNamed(Routes.SPLASH);
    return true;
  }

  /// 获取是否是体验APP 如果是体验则不进行任何操作
  static bool checkExperienceAppStorage() {
    bool experience = StorageUtil().getBool(EXPERIENCE_APP_KEY);
    return experience;
  }

    /// 判断是否有学员
  static Future<bool> checkStudent(BuildContext context) async {
    if(UserStore.to.userInfo.value.memberId != null) return true;
    bool res = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "请先创建学员",
      define: "去创建",
    );
    if (!res) return false;
    bool isPwdRight = await ParentPasswordialog.show(context: context, isCheckHasPassword: false);
    if (!isPwdRight) return true;

    Get.offNamedUntil(Routes.USER_CENTER, ModalRoute.withName(Routes.APPLICATION));
    return false;
  }

  /// * 扣除学点弹窗
  /// * hintStorageKey 以后自动扣除 xx学点 直接学习，不再提示
  /// * 返回 true=成功支付 false=关闭或失败
  static Future<bool> showDeductingLearningPointsDialog({
    required BuildContext context,
    LockEntity? lockEntity,
    String? hintStorageKey,
  }) async {
    if (lockEntity == null) return false;

    

    PackageShopDetailEntity? pageageInfo;
    try {
      ToastUtils.showLoading();
      pageageInfo = await deductingLearningPointsGetPageageInfo(context, lockEntity);
    } finally {
      ToastUtils.hideLoading();
    }

    if (pageageInfo == null) return false;

    bool notRemindUnLockTask = false;

    if (hintStorageKey != null) {
      notRemindUnLockTask = StorageUtil().getBool(hintStorageKey);
    }

    if (!notRemindUnLockTask) {
      // 判断是否需要密码
      LockEntityJumpLearnPayParams? params = lockEntity.jump?.learnPayParams;
      bool needPwd = params?.needPwd ?? false;
      if (needPwd) {
        _showPlayLearnDialog = true;
        bool isPwdRight = await ParentPasswordialog.show(context: context, isCheckHasPassword: false);
        _showPlayLearnDialog = false;
        if (!isPwdRight) return false;
      }

      //没有提示key 直接去支付
      bool res = await showDeductingLearningPointsInfoDialog(
        context: context,
        lockEntity: lockEntity,
        pageageInfo: pageageInfo,
        hintStorageKey: hintStorageKey,
      );
      // true=支付成功
      return res;
    }

    // StorageUtil().remove(hintStorageKey);
    // 本地储存标识 不再提示的key 如果不为空判断是否需要提示
    // 不需要提示 直接去支付
    try {
      ToastUtils.showLoading();
      PackageShopDetailEntity? pageageInfo = await deductingLearningPointsGetPageageInfo(context, lockEntity);
      if (pageageInfo == null) return false;
      if (!pageageInfo.isAffordable) {
        bool res = await showDeductingLearningPointsInfoDialog(
          context: context,
          lockEntity: lockEntity,
          pageageInfo: pageageInfo,
          hintStorageKey: hintStorageKey,
        );
        // true=支付成功
        return res;
      }
      bool payRes = await deductingLearningPointsPay(context: context, pageageInfo: pageageInfo);
      // 根据支付结果来判断返回
      if (payRes) {
        int? points = pageageInfo.servicePackage?.price;
        if (points != null) {
          String pointsStr = NumberUtils.formatNumberWithCommas(points.toDouble());
          ToastUtils.showToast(text: "扣除 $pointsStr 学点成功", type: ToastType.success);
        }
      }
      return payRes;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 弹出学点支付信息弹窗
  static Future<bool> showDeductingLearningPointsInfoDialog({
    required BuildContext context,
    required LockEntity lockEntity,
    required PackageShopDetailEntity pageageInfo,
    String? hintStorageKey,
  }) async {
    _showPlayLearnDialog = true;
    bool? res = await showCupertinoDialog(
      context: context,
      builder: (context) {
        return DeductingLearningPointsDialogWidget(
          lockEntity: lockEntity,
          pageageInfo: pageageInfo,
          hintStorageKey: hintStorageKey,
        );
      },
    );
    _showPlayLearnDialog = false;
    // true=支付成功
    return res ?? false;
  }

  /// 扣除学点 支付
  static Future<bool> deductingLearningPointsPay({
    required BuildContext context,
    required PackageShopDetailEntity pageageInfo,
  }) async {
    Map<String, dynamic> reqData = {
      "servicePkgId": pageageInfo.servicePackage?.servicePackageId,
      "serviceVersion": pageageInfo.servicePackage?.servicePackageVersion,
      "payChannel": pageageInfo.servicePackage?.payMethod,
      "resource": {
        "uid": pageageInfo.servicePackage?.resource?.uid,
        "type": pageageInfo.servicePackage?.resource?.type,
      },
    };
    bool payRes = await PayRequest.buyMemberSettlement(reqData);
    if (payRes) {
      UserStore.to.getUserInfo();
    }
    return payRes;
  }

  /// 扣除学点获取支付信息
  static Future<PackageShopDetailEntity?> deductingLearningPointsGetPageageInfo(BuildContext context, LockEntity lockEntity) async {
    LockEntityJumpLearnPayParams? params = lockEntity.jump?.learnPayParams;

    if (params == null || params.contentId == null || params.contentType == null || params.servicePackageId == null || params.servicePackageVersion == null) {
      ToastUtils.showLoading(text: "获取支付信息失败，请稍后再试～");
      return null;
    }

    Map<String, dynamic> reqData = {
      "servicePackageId": params.servicePackageId,
      "servicePackageVersion": params.servicePackageVersion,
      "resource": {
        "uid": params.contentId,
        "type": params.contentType,
      },
    };
    PackageShopDetailEntity? packageInfo = await PayRequest.getPackageShopDetail(reqData);
    if (packageInfo == null) return null;
    return packageInfo;
  }
}

class LockOverlayWidget extends StatefulWidget {
  final Widget child;
  final LockEntity? rights;
  final bool showBack;
  const LockOverlayWidget({super.key, required this.child, this.rights, this.showBack = true});

  @override
  State<LockOverlayWidget> createState() => _LockOverlayWidgetState();
}

class _LockOverlayWidgetState extends State<LockOverlayWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.rights == null) return widget.child;
    if (!(widget.rights?.isLock ?? true) && !(widget.rights?.isNoRights ?? true)) return widget.child;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          Container(
            color: AppTheme.cBlackAlpha70,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  widget.rights?.message ?? "",
                  textAlign: TextAlign.center,
                  minFontSize: 10,
                  style: TextStyle(
                    color: AppTheme.cInverseTextLight.color,
                    fontSize: 48.wMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Visibility(
                  visible: widget.rights?.jump?.params?.confirmText != null,
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 32.wMin),
                      child: ButtonWidget(
                        text: widget.rights?.jump?.params?.confirmText ?? "",
                        color: AppTheme.cBgBrand,
                        alignment: null,
                        padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 16.wMin),
                        borderRadius: 12.wMin,
                        fontColor: AppTheme.cStaticWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 32.wMin,
                        sclae: 1.01,
                        onTap: () {
                          LockUtils.checkLock(widget.rights, context);
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.wMin),
                Visibility(
                  visible: widget.showBack,
                  child: TapScaleWidget(
                    onTap: () => Get.back(),
                    sclae: 1.05,
                    child: Text(
                      "返回",
                      style: TextStyle(
                        color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.8),
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DeductingLearningPointsDialogWidget extends StatefulWidget {
  final LockEntity lockEntity;
  final PackageShopDetailEntity pageageInfo;
  final String? hintStorageKey;
  const DeductingLearningPointsDialogWidget({
    super.key,
    required this.lockEntity,
    required this.pageageInfo,
    this.hintStorageKey,
  });

  @override
  State<DeductingLearningPointsDialogWidget> createState() => _DeductingLearningPointsDialogWidgetState();
}

class _DeductingLearningPointsDialogWidgetState extends State<DeductingLearningPointsDialogWidget> {
  PackageShopDetailEntity? pageageInfo;

  bool checkNextNotTip = true;

  @override
  void initState() {
    super.initState();
    pageageInfo = widget.pageageInfo;
  }

  /// 支付
  Future<void> pay() async {
    if (pageageInfo == null) return;
    if (!pageageInfo!.isAffordable) {
      ToastUtils.showToast(text: "余额不足");
      return;
    }

    try {
      ToastUtils.showLoading();
      bool res = await LockUtils.deductingLearningPointsPay(
        context: context,
        pageageInfo: pageageInfo!,
      );
      if (!res) return;
      ToastUtils.showToast(text: "支付成功", type: ToastType.success);
      if (widget.hintStorageKey != null) {
        if (checkNextNotTip) {
          StorageUtil().setBool(widget.hintStorageKey!, checkNextNotTip);
        }
      }
      Get.back(result: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 去充值
  Future<void> toRecharge() async {
    await Get.toNamed(
      Routes.RECHARGE_NAIBI,
      arguments: {
        "pageType": 1,
      },
    );
    try {
      ToastUtils.showLoading();
      PackageShopDetailEntity? entity = await LockUtils.deductingLearningPointsGetPageageInfo(context, widget.lockEntity);
      if (entity == null) return;
      pageageInfo = entity;
      if (mounted) setState(() {});
    } finally {
      ToastUtils.hideLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Container(
          width: 640.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            color: AppTheme.cSurfaceSecondary.color,
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 72.wMin, vertical: 24.wMin),
                    child: Text(
                      pageageInfo?.servicePackage?.title ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildAssetsWidget(),
                  SizedBox(height: 24.wMin),
                  _buildProductServiceWidget(),
                  SizedBox(height: 24.wMin),
                  _buildPayMethodInfoWidget(),
                  _buildAutoDeductingWidget(),
                  _buildButtonsWidget(),
                  SizedBox(height: 24.wMin),
                ],
              ),
              Positioned(
                top: 24.wMin,
                right: 24.wMin,
                child: TapScaleWidget(
                  sclae: 1.05,
                  onTap: () => Get.back(),
                  child: Container(
                    width: 42.wMin,
                    height: 42.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cSurfaceTertiary.color,
                    ),
                    child: SvgPicture.asset(
                      "assets/svg/public/x.svg",
                      width: 24.wMin,
                      height: 24.wMin,
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

  Widget _buildAssetsWidget() {
    String pointsStr = NumberUtils.formatNumberWithCommas(pageageInfo?.userPoints?.toDouble() ?? 0.0);

    int credit = pageageInfo?.userCredit ?? 0;
    String creditStr = NumberUtils.formatNumberWithCommas(credit.toDouble() / 100);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.wMin),
      padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6.wMin,
        children: [
          Row(
            children: [
              _buildAssetBalanceItemWidget(
                1,
                "学点余额",
                pointsStr,
              ),
              SizedBox(width: 24.wMin),
              _buildAssetBalanceItemWidget(
                2,
                "乃币余额",
                creditStr,
              ),
            ],
          ),
          Text(
            "每月赠送 ${UserStore.to.userInfo.value.vipPointsStr} 学点",
            style: TextStyle(
              fontSize: 22.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cLearnSomethingPrimary.color,
            ),
          ),
        ],
      ),
    );
  }

  /// 商品服务
  Widget _buildProductServiceWidget() {
    String points = NumberUtils.formatNumberWithCommas(pageageInfo?.servicePackage?.price?.toDouble() ?? 0.0);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            pageageInfo?.servicePackage?.describe ?? "",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          Text(
            "$points 学点",
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetBalanceItemWidget(int type, String name, String value) {
    return Expanded(
      child: Row(
        children: [
          UserBalanceIcon(type: type, boxSize: 74.wMin, iconSize: 50.wMin),
          SizedBox(width: 12.wMin),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextQuaternary.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 以后自动扣除 xxx学点 直接学习，不再提示
  Widget _buildAutoDeductingWidget() {
    if (widget.hintStorageKey == null) return Container(height: 24.wMin);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
      alignment: Alignment.centerLeft,
      child: TapScaleWidget(
        onTap: () {
          setState(() {
            checkNextNotTip = !checkNextNotTip;
          });
        },
        sclae: 1,
        child: Container(
          color: Colors.transparent,
          child: Row(
            spacing: 8.wMin,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                checkNextNotTip ? "assets/svg/manage/icon_check_box.svg" : "assets/svg/manage/icon_uncheck_box.svg",
                width: 24.wMin,
                height: 24.wMin,
              ),
              Text(
                "以后解锁自动扣除学点，不再提示",
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 支付方式
  Widget _buildPayMethodInfoWidget() {
    String pointsStr = NumberUtils.formatNumberWithCommas((pageageInfo?.orderPoints ?? 0).toDouble());
    String creditStr = NumberUtils.formatNumberWithCommas((pageageInfo?.orderCredit ?? 0) / 100);

    bool? affordable = pageageInfo?.affordable;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "支付方式",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          _buildRowColorTextWidget(
            "学点支付",
            "$pointsStr 点",
            AppTheme.cLearnSomethingPrimary.color,
          ),
          SizedBox(height: 8.wMin),
          Visibility(
            visible: (pageageInfo?.orderCredit ?? 0) != 0,
            child: _buildRowColorTextWidget(
              "乃币支付",
              "$creditStr 乃币",
              affordable == true ? AppTheme.cNsCoinBgPrimary.color : AppTheme.cFeedbackErrorText.color,
            ),
          ),
          Visibility(
            visible: affordable != true,
            child: Container(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8.wMin,
                children: [
                  Text(
                    "乃币余额不足",
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cFeedbackErrorText.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ButtonWidget(
                    text: "充值",
                    width: 80.wMin,
                    padding: EdgeInsets.symmetric(vertical: 4.wMin),
                    borderRadius: 8.wMin,
                    color: Colors.transparent,
                    border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackErrorBorder.color),
                    fontSize: 24.wMin,
                    fontColor: AppTheme.cFeedbackErrorText.color,
                    fontWeight: FontWeight.w600,
                    sclae: 1.01,
                    onTap: () {
                      toRecharge();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowColorTextWidget(String name, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 20.wMin,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.wMin,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        spacing: 12.wMin,
        children: [
          Expanded(
            child: ButtonWidget(
              text: "取消",
              height: 72.wMin,
              borderRadius: 12.wMin,
              color: AppTheme.cSurfaceQuaternary.color,
              fontColor: AppTheme.cTextPrimary,
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.02,
              onTap: () {
                Get.back();
              },
            ),
          ),
          Expanded(
            child: ButtonWidget(
              text: "确定",
              height: 72.wMin,
              borderRadius: 12.wMin,
              color: AppTheme.cSurfaceBrand.color,
              fontColor: AppTheme.cStaticWhite,
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.02,
              onTap: OptimizeUtils.noneThrottle(() {
                pay();
              }, 200),
            ),
          ),
        ],
      ),
    );
  }
}
