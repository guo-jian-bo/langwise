
import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/application/controllers/application_controller.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/public_controller/manage_sandbox_controller.dart';
import '../../../../common/values/values.dart';
import '../controllers/user_center_controller.dart';
import '../member_center/controllers/member_center_controller.dart';

class ExchangeCouponsDialog{

  static Future<bool> show({
    required BuildContext context,
  }) async{

    String? res = await showCupertinoDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return const ExchangeCouponsDialogWidget();
      },
    );

    if(res == null) return false;

    bool couponRes = await couponActivateStart(Get.context ?? context, res);
    return couponRes;
  }

  /// 使用优惠券兑换弹窗
  static Future<bool> showDiscountexchangeCoupons({
    required BuildContext context,
    required CouponEntityDatas data,
  }) async{
    String? res = await showCupertinoDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ExchangeCouponsDiscountDialogWidget(data: data);
      },
    );
    if(res == null) return false;
    bool couponRes = await couponActivateStart(Get.context ?? context, res, couponId: data.couponId);
    return couponRes;
  }

  /// 兑换信息弹窗 不使用优惠券返回-1
  static Future<int?> confirmVerifyDialog({
    required BuildContext context,
    required RedemptionCodeInfoEntity infoEntity,
  }) async{
    int? res = await showCupertinoDialog<int?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ExchangeCouponsConfirmVerifyDialogWidget(infoEntity: infoEntity);
      },
    );

    return res;
  }

  /// 选择学员弹窗
  static Future<List<RedemptionCodeInfoEntityTraineeList>?> showSelectStudentDialog({
    required BuildContext context,
    required RedemptionCodeInfoEntity infoEntity,
    String? buttonText,
  }) async{
    List<RedemptionCodeInfoEntityTraineeList>? res = await showCupertinoDialog<List<RedemptionCodeInfoEntityTraineeList>?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return SelectStudentDialogWidget(
          infoEntity: infoEntity,
          buttonText: buttonText,
        );
      },
    );
    return res;
  }

  /// 选择优惠券弹窗
  /// [isSingle] 是否单选
  static Future<int?> showUseCouponsDialog({
    required BuildContext context,
    List<CouponEntityDatas?>? couponList,
    int? selectedCouponId,
  }) async{
    if(couponList == null || couponList.isEmpty) return -1;
    return await showCupertinoDialog<int?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return UseCouponsDialogWidget(couponList: couponList, selectedCouponId: selectedCouponId);
      },
    );
  }

  /// 兑换
  static Future<bool> couponActivateStart(BuildContext context, String code, {int? couponId}) async{
    FocusScope.of(context).requestFocus(FocusNode());

    Map<String, dynamic> reqData = {
      "code": code,
      "defaultCoupon": couponId == null ? true : false,
    };
    if(couponId != null){
      reqData["discountCoupons"] = [couponId];
    }

    RedemptionCodeInfoEntity? infoEntity;
    try {
      ToastUtils.showLoading();
      infoEntity = await CouponsRequest.couponActivateStartInfo(reqData);
    
    } finally{
      ToastUtils.hideLoading();
    }

    if(infoEntity == null) return false;

    if(infoEntity.confirmJump == null) return false;

    int? resCouponId = await confirmVerifyDialog(
      context: Get.context ?? context,
      infoEntity: infoEntity,
    );

    if(resCouponId == null) return false;

    if(infoEntity.confirmJump == null) return false;

    if(infoEntity.confirmJump?.code == FunctionLockMethod.confirmVerify){
      // 直接兑换
      bool res = await couponActivate(code, couponId: resCouponId == -1 ? null : resCouponId);
      return res;
    }

    if(infoEntity.confirmJump?.code != FunctionLockMethod.dialog) return false;
    // 需要弹窗
    String? jumpCode = infoEntity.confirmJump?.params?.jump?.code;
    if(jumpCode == null) return false;

    if(jumpCode == FunctionJumpCode.choiceStudent){
      // 选择学员 然后兑换
      bool res = await selectStudentCouponActivate(Get.context ?? context, code, infoEntity, couponId: resCouponId == -1 ? null : resCouponId);
      return res;
    }

    return false;

  }


  /// 选择学员兑换
  static Future<bool> selectStudentCouponActivate(BuildContext context, String code, RedemptionCodeInfoEntity infoEntity, {int? couponId}) async {
    List<RedemptionCodeInfoEntityTraineeList>? selectedMembers = await showSelectStudentDialog(
      context: context,
      infoEntity: infoEntity,
    );
    if(selectedMembers == null) return false;
    if(selectedMembers.isEmpty){
      ToastUtils.showToast(text: "请选择学员");
      return false;
    }
    List<int> traineeIds = [];
    for(RedemptionCodeInfoEntityTraineeList member in selectedMembers){
      if(member.traineeId == null) continue;
      traineeIds.add(member.traineeId!);
    }
    if(traineeIds.isEmpty) return false;

    // 如果有优惠券 需要选择优惠券
    // int? selectedCouponId = await showUseCouponsDialog(
    //   context: Get.context ?? context,
    //   couponList: infoEntity.couponList,
    // );
    // if(selectedCouponId == null) return false;

    bool res = await couponActivate(code, traineeIds: traineeIds, couponId: couponId);
    return res;
  }


  /// 兑换优惠券
  static Future<bool> couponActivate(String code, {List<int>? traineeIds, int? couponId}) async {
    try {
      Map<String, dynamic> reqData = {
        "code": code,
      };
      if(traineeIds != null){
        reqData["traineeIds"] = traineeIds;
      }
      if(couponId != null){
        reqData["discountCoupons"] = [couponId];
      }

      ToastUtils.showLoading();
      bool res = await CouponsRequest.couponActivate(reqData);
      if(!res) return false;

      if(!ManageSandboxController.to.isSimulate) { // 模拟登录情况下不用刷新
        UserStore.to.getUserInfo(showLoading: false);

        final userCenterControllers = TagRoutes.finds<UserCenterController>(Routes.USER_CENTER);
        for (final c in userCenterControllers) {
          await c.initServiceData(showLoading: false);
        }

        if (Get.isRegistered<ApplicationController>()) {
          Get.find<ApplicationController>().refreshHomePages();
        }

        final memberCenterControllers = TagRoutes.finds<MemberCenterController>(Routes.MEMBER_CENTER);
        for (final c in memberCenterControllers) {
          await c.getMemberPackageList(showLoading: false);
        }
      }

      ToastUtils.showToast(text: "兑换成功", type: ToastType.success);
      return true;
    } finally{
      ToastUtils.hideLoading();
    }

  }


}

class ExchangeCouponsDialogWidget extends StatefulWidget {
  const ExchangeCouponsDialogWidget({super.key});

  @override
  State<ExchangeCouponsDialogWidget> createState() => _ExchangeCouponsDialogWidgetState();
}

class _ExchangeCouponsDialogWidgetState extends State<ExchangeCouponsDialogWidget> {
  final TextEditingController exchangeCode = TextEditingController();

  @override
  void dispose(){
    super.dispose();
    exchangeCode.dispose();
  }

  /// 兑换
  Future<void> couponActivateStart() async{
    FocusScope.of(context).requestFocus(FocusNode());

    String code = exchangeCode.text.replaceAll("-", "");
    if(code.isEmpty || code.length != 16){
      return ToastUtils.showToast(text: "请输入共16位字母或数字的兑换码");
    }

    Get.back(result: code);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cOverlayBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: 640.wMin,
                padding: EdgeInsets.all(32.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  color: AppTheme.cBgSecondary,
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "兑换卡券",
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16.wMin),
                    Text(
                      "兑换码",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12.wMin),
                    CardInputWidget(
                      hintText: "XXXX-XXXX-XXXX-XXXX",
                      controller: exchangeCode,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        MaskTextInputFormatter(
                          mask: '####-####-####-####',
                          filter: {"#": RegExp(r'[0-9a-zA-Z]')},
                        ),
                      ],
                      maxLength: 19,
                      fillColor: Colors.transparent,
                      onClean: () {
                        exchangeCode.clear();
                      },
                    ),
                    SizedBox(height: 8.wMin),
                    Text(
                      "请输入共16位字母或数字的兑换码",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextTertiary,
                      ),
                    ),
                    SizedBox(height: 32.wMin),
                    Row(
                      spacing: 18.wMin,
                      children: [
                        Expanded(
                          child: ButtonWidget(
                            text: "取消",
                            sclae: 1.03,
                            color: AppTheme.cSurfaceLayerElevated,
                            borderRadius: 8.wMin,
                            height: 56.wMin,
                            fontSize: 24.wMin,
                            fontColor: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w500,
                            onTap: () => Get.back(),
                          ),
                        ),
                        Expanded(
                          child: ButtonWidget(
                            text: "确认兑换",
                            sclae: 1.03,
                            color: AppTheme.cSurfaceBrand,
                            borderRadius: 8.wMin,
                            height: 56.wMin,
                            fontSize: 24.wMin,
                            fontColor: AppTheme.cStaticWhite,
                            fontWeight: FontWeight.w500,
                            onTap: () {
                              couponActivateStart();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16.wMin,
                top: 16.wMin,
                child: TapScaleWidget(
                  sclae: 1.05,
                  onTap: () => Get.back(),
                  child: Container(
                    width: 48.wMin,
                    height: 48.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cSurfaceLayerElevated.color,
                      border: Border.all(width: 1.wMin, color: AppTheme.cBorderDefault.color),
                    ),
                    child: SvgPicture.asset(
                      "assets/svg/public/x.svg",
                      width: 24.wMin,
                      height: 24.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
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

class ExchangeCouponsDiscountDialogWidget extends StatefulWidget {
  final CouponEntityDatas data;
  const ExchangeCouponsDiscountDialogWidget({super.key, required this.data});

  @override
  State<ExchangeCouponsDiscountDialogWidget> createState() => _ExchangeCouponsDiscountDialogWidgetState();
}

class _ExchangeCouponsDiscountDialogWidgetState extends State<ExchangeCouponsDiscountDialogWidget> {
  final TextEditingController exchangeCode = TextEditingController();

  @override
  void dispose(){
    super.dispose();
    exchangeCode.dispose();
  }

  /// 兑换
  Future<void> couponActivateStart() async{
    FocusScope.of(context).requestFocus(FocusNode());

    String code = exchangeCode.text.replaceAll("-", "");
    if(code.isEmpty || code.length != 16){
      return ToastUtils.showToast(text: "请输入共16位字母或数字的兑换码");
    }

    Get.back(result: code);

  }

  @override
  Widget build(BuildContext context) {
    Color couponColor = StatusUtils.getCouponColor(widget.data.type);
    return Scaffold(
      backgroundColor: AppTheme.cOverlayBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 760.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cBgSecondary,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitleWidget(),
                SizedBox(height: 24.wMin),
                _buildCouponInfoWidget(),
                SizedBox(height: 24.wMin),
                _buildCodeFromWidget(),
                SizedBox(height: 24.wMin),
                Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
                SizedBox(height: 40.wMin),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 32.wMin),
                  child: Row(
                    spacing: 18.wMin,
                    children: [
                      Expanded(
                        child: ButtonWidget(
                          text: "用乃币购买",
                          sclae: 1.03,
                          color: AppTheme.cSurfaceLayerElevated.color,
                          borderRadius: 8.wMin,
                          height: 56.wMin,
                          fontSize: 24.wMin,
                          fontColor: AppTheme.cTextBrand.color,
                          fontWeight: FontWeight.w500,
                          onTap: () {
                            Get.back();
                            TagRoutes.toNamed(Routes.MEMBER_CENTER);
                          },
                        ),
                      ),
                      Expanded(
                        child: ButtonWidget(
                          text: "确认兑换",
                          sclae: 1.03,
                          color: couponColor,
                          borderRadius: 8.wMin,
                          height: 56.wMin,
                          fontSize: 24.wMin,
                          fontColor: AppTheme.cStaticWhite.color,
                          fontWeight: FontWeight.w500,
                          onTap: () {
                            couponActivateStart();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.wMin),
                Center(
                  child: TapScaleWidget(
                    onTap: () {
                      Get.back();
                    },
                    sclae: 1.05,
                    child: Container(
                      padding: EdgeInsets.all(6.wMin),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8.wMin),
                      ),
                      child: Text(
                        "暂不兑换，返回",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 24.wMin,
                          color: AppTheme.cTextSecondary.color,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.wMin),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 32.wMin),
          padding: EdgeInsets.symmetric(horizontal: 32.wMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "使用折扣券兑换",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 32.wMin,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SizedBox(height: 8.wMin),
              Text(
                "请输入您的兑换码，我们将为您自动使用折扣券，您也可以选择用乃币购买。",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 20.wMin,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
            ],
          ),
        ),

        Positioned(
          right: 16.wMin,
          top: 16.wMin,
          child: TapScaleWidget(
            sclae: 1.05,
            onTap: () => Get.back(),
            child: Container(
              width: 48.wMin,
              height: 48.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cSurfaceLayerElevated.color,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderDefault.color),
              ),
              child: SvgPicture.asset(
                "assets/svg/public/x.svg",
                width: 24.wMin,
                height: 24.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
              ),
            ),
          ),
        ),

      ],
    );
  }

  /// 优惠券信息
  Widget _buildCouponInfoWidget(){
    Color couponColor = StatusUtils.getCouponColor(widget.data.type);
    String expiredText = "";
    if(widget.data.expired != null){
      expiredText = DateFormatUtil.formatStrtoStr(widget.data.expired, locale: Get.locale);
    }
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 32.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.data.title??"",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 24.wMin,
                    color: couponColor,
                  ),
                ),
              ),
              SvgPicture.asset(
                "assets/svg/public/icon_radio.svg",
                width: 24.wMin,
                height: 24.wMin,
                colorFilter: ColorFilter.mode(couponColor, BlendMode.srcIn),
              )

            ],
          ),
          Text(
            widget.data.describe??"",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20.wMin,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 12.wMin),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceTertiary.color,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: widget.data.benefits?.isNotEmpty??false,
                  child: Column(
                    children: List.generate(widget.data.benefits?.length??0, (index){
                      if(widget.data.benefits![index] == null) return Container();
                      return _buildRowTextWidget(
                        widget.data.benefits?[index]?.category??"", 
                        widget.data.benefits?[index]?.items,
                      );
                    }),
                  ),
                ),
                Visibility(
                  visible: widget.data.tip?.isNotEmpty??false,
                  child: Container(
                    margin: EdgeInsets.only(top: 6.wMin),
                    child: Text(
                      widget.data.tip??"",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: AppTheme.cFeedbackErrorText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.data.expired?.isNotEmpty??false,
                  child: Container(
                    margin: EdgeInsets.only(top: 6.wMin),
                    child: Text(
                      "$expiredText 到期",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: AppTheme.cTextTertiary,
                        fontWeight: FontWeight.w400,
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

  Widget _buildRowTextWidget(String name, List<String?>? values){
    return Row(
      spacing: 10.wMin,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: Text(
              values?.join("，")??"",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 兑换码输入框
  Widget _buildCodeFromWidget(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "输入兑换码应用此券",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.wMin),
          CardInputWidget(
            hintText: "XXXX-XXXX-XXXX-XXXX",
            controller: exchangeCode,
            keyboardType: TextInputType.text,
            inputFormatters: [
              MaskTextInputFormatter(
                mask: '####-####-####-####',
                filter: {"#": RegExp(r'[0-9a-zA-Z]')},
              ),
            ],
            maxLength: 19,
            fillColor: AppTheme.cBgTertiary.color,
            borderColor: AppTheme.cBorderPrimary.color,
            onClean: () {
              exchangeCode.clear();
            },
          ),
          SizedBox(height: 8.wMin),
          Text(
            "请输入共16位字母或数字的兑换码",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary,
            ),
          ),
        ],
      ),
    );
  }


}



class ExchangeCouponsConfirmVerifyDialogWidget extends StatefulWidget {
  final RedemptionCodeInfoEntity infoEntity;
  const ExchangeCouponsConfirmVerifyDialogWidget({super.key, required this.infoEntity});

  @override
  State<ExchangeCouponsConfirmVerifyDialogWidget> createState() => _ExchangeCouponsConfirmVerifyDialogWidgetState();
}

class _ExchangeCouponsConfirmVerifyDialogWidgetState extends State<ExchangeCouponsConfirmVerifyDialogWidget> {
  int selectedCouponId = -1;
  
  Timer? timer;
  int countdown = 3;
  bool deleteButtonFlag = false;

  @override
  void initState() {
    super.initState();
    initCouponInfo();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown--;
      if(mounted) setState(() {});
      if(countdown <= 0){
        timer.cancel();
        deleteButtonFlag = true;
      }
    });
  }
  
  /// 初始化优惠券信息
  void initCouponInfo(){
    List<int?> discountCouponIds = widget.infoEntity.discountCouponIds??[];
    if(discountCouponIds.isEmpty) return;
    int? discountCouponId = discountCouponIds.first;
    if(discountCouponId == null) return;
    selectedCouponId = discountCouponId;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /// 去选择优惠券
  Future<void> _navigateToSelectCouponPage() async{
    int? res = await ExchangeCouponsDialog.showUseCouponsDialog(
      context: Get.context ?? context,
      couponList: widget.infoEntity.couponList,
      selectedCouponId: selectedCouponId,
    );
    if(res == null) return;
    selectedCouponId = res;
    if(mounted) setState(() {});
  }
 

  @override
  Widget build(BuildContext context) {

    List<RedemptionCodeInfoEntityJumping?> showTexts = [];

    if(widget.infoEntity.traineeContent != null){
      showTexts.add(widget.infoEntity.traineeContent);
    }

    List<RedemptionCodeInfoEntityJumping?> items = widget.infoEntity.items??[];

    showTexts.addAll(items);

    CouponEntityDatas? coupon;
    List<CouponEntityDatas?> couponList = widget.infoEntity.couponList??[];
    if(couponList.isNotEmpty){
      coupon = couponList.firstWhereOrNull((element) => element?.couponId == selectedCouponId);
    }

    Color couponColor = StatusUtils.getCouponColor(coupon?.type);

    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 960.wMin,
              padding: EdgeInsets.all(32.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cBgSecondary,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      widget.infoEntity.title?.text??"",
                      style: TextStyle(
                        fontSize: 32.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.wMin),
            
                  Visibility(
                    visible: showTexts.isNotEmpty,
                    child: Column(
                      spacing: 10.wMin,
                      children: List.generate(showTexts.length, (index) {
                        return _buildRowText(
                          showTexts[index]?.name?.text,
                          showTexts[index]?.desc?.text,
                        );
                      }),
                    ),
                  ),
            
                  _buildCouponWidget(), 
                  SizedBox(height: 24.wMin),
            
                  Visibility(
                    visible: widget.infoEntity.remark != null,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.wMin),
                        color: AppTheme.cSurfaceError.withValues(alpha: 0.12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: widget.infoEntity.remark?.name?.text != null,
                            child: Text(
                              widget.infoEntity.remark?.name?.text??"",
                              style: TextStyle(
                                fontSize: 24.wMin,
                                color: AppTheme.cSurfaceError.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: widget.infoEntity.remark?.desc?.text != null,
                            child: Container(
                              margin: EdgeInsets.only(top: 8.wMin),
                              child: Text(
                                widget.infoEntity.remark?.desc?.text??"",
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: AppTheme.cFeedbackErrorText,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                    
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 32.wMin),
                  Row(
                    spacing: 24.wMin,
                    children: [
                      Expanded( 
                        child: ButtonWidget(
                          text: widget.infoEntity.couponVerify??"取消",
                          height: 56.wMin,
                          borderRadius: 8.wMin,
                          color: AppTheme.cSurfaceLayerElevated,
                          fontColor: AppTheme.cTextPrimary,
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w500,
                          sclae: 1.02,
                          onTap: () {
                            Get.back();
                          },
                        ),
                      ),
                      Expanded( 
                        child: ButtonWidget(  
                          text: "${widget.infoEntity.confirmText??'确定'}${countdown == 0 ? '' : '(${countdown}s)'}",
                          height: 56.wMin,
                          borderRadius: 8.wMin,
                          // color: countdown != 0 ? AppTheme.cFeedbackErrorBackground : AppTheme.cSurfaceError.color,
                          color: couponColor.withValues(alpha: countdown != 0 ? 0.5 : 1),
                          fontColor: AppTheme.cStaticWhite,
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w500,
                          sclae: 1.02,
                          onTap: countdown != 0 ? null : () {
                            Get.back(result: selectedCouponId);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16.wMin,
              top: 16.wMin,
              child: TapScaleWidget(
                sclae: 1.05,
                onTap: () => Get.back(),
                child: Container(
                  width: 48.wMin,
                  height: 48.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cSurfaceLayerElevated.color,
                    border: Border.all(width: 1.wMin, color: AppTheme.cBorderDefault.color),
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/public/x.svg",
                    width: 24.wMin,
                    height: 24.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  /// 优惠券部分
  Widget _buildCouponWidget(){
    List<CouponEntityDatas?> couponList = widget.infoEntity.couponList??[];
    if(couponList.isEmpty) return Container();

    // selectedCouponId == -1 时，不展示优惠券

    CouponEntityDatas? coupon = widget.infoEntity.couponList?.firstWhereOrNull((element) => element?.couponId == selectedCouponId);

    List<CouponEntityDatasItem?> items = coupon?.items??[];
    
    return TapScaleWidget(
      onTap: () {
        _navigateToSelectCouponPage();
      },
      sclae: 1,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 24.wMin),
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceThin.color,
        ),
        child: Column(
          children: [
            selectedCouponId == -1 ? _buildNoCouponNameWidget() : _buildCouponNameWidget(coupon),
            Visibility(
              visible: items.isNotEmpty,
              child: Container(
                margin: EdgeInsets.only(top: 10.wMin),
                child: Column(
                  spacing: 10.wMin,
                  children: List.generate(items.length, (index){
                    return _buildRowText(items[index]?.name?.text, items[index]?.desc?.text);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 使用优惠券的名称
  Widget _buildCouponNameWidget(CouponEntityDatas? coupon){
    if(coupon == null) return Container();
    Color couponColor = StatusUtils.getCouponColor(coupon.type);
    return Row(
      children: [
        Text(
          "优惠券名称",
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(width: 8.wMin),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: Text(
              coupon.title??"",
              style: TextStyle(
                fontSize: 28.wMin,
                color:couponColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(width: 6.wMin),
        SvgPicture.asset(
          "assets/svg/public/icon_w_arrow_right.svg",
          width: 24.wMin,
          colorFilter: ColorFilter.mode(couponColor, BlendMode.srcIn),
        ),
      ],
    );
  }

  /// 不使用优惠券的名称
  Widget _buildNoCouponNameWidget(){
    return Row(
      children: [
        Text(
          "不使用优惠券",
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(width: 8.wMin),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: Text(
              "选择优惠券",
              style: TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cSurfaceWarning.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(width: 6.wMin),
        SvgPicture.asset(
          "assets/svg/public/icon_w_arrow_right.svg",
          width: 24.wMin,
          colorFilter: ColorFilter.mode(AppTheme.cSurfaceWarning.color, BlendMode.srcIn),
        ),
      ],
    );
  }
  
  Widget _buildRowText(String? name, String? value){
    if(value == null) return Container();
    return Row(
      children: [
        Text(
          name??"",
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 28.wMin,
                color:AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }


}


class SelectStudentDialogWidget extends StatefulWidget {
  final RedemptionCodeInfoEntity infoEntity;
  final String? buttonText;
  const SelectStudentDialogWidget({
    super.key,
    required this.infoEntity,
    this.buttonText,
  });

  @override
  State<SelectStudentDialogWidget> createState() => _SelectStudentDialogWidgetState();
}

class _SelectStudentDialogWidgetState extends State<SelectStudentDialogWidget> {
  List<RedemptionCodeInfoEntityTraineeList> traineeList = [];

  int maxStudentCount = 0;

  List<int> selectedIndexs = []; /// 已选择学员列表下标

  @override
  void initState() {
    super.initState();
    maxStudentCount = widget.infoEntity.activateTraineesSize ?? 0;
    List<RedemptionCodeInfoEntityTraineeList?>? list = widget.infoEntity.traineeList??[];
    for(RedemptionCodeInfoEntityTraineeList? item in list){
      if(item  == null) continue;
      traineeList.add(item);
    }

    if(maxStudentCount == traineeList.length){
      selectedIndexs = List.generate(traineeList.length, (index) => index);
    }
  }

  /// 选择学员
  void selectStudent(int index){
    if(selectedIndexs.contains(index)){
      selectedIndexs.remove(index);
      if(mounted) setState(() {});
    }else{
      if(selectedIndexs.length + 1 > maxStudentCount){
        ToastUtils.showToast(text: "最多选择$maxStudentCount个席位");
        return;
      }
      if(mounted) selectedIndexs.add(index);
    }
    if(mounted) setState(() {});
  }


  /// 提交选择学员
  void submitSelectStudent(){
    if(selectedIndexs.isEmpty){
      ToastUtils.showToast(text: "请选择席位");
      return;
    }

    if(maxStudentCount >= traineeList.length){// 选择人数大于等于总人数
      if(selectedIndexs.length != traineeList.length){
        ToastUtils.showToast(text: "请选择所有席位");
        return;
      }
    }else{
      if(selectedIndexs.length != maxStudentCount){
        ToastUtils.showToast(text: "请选择$maxStudentCount个席位");
        return;
      }
    }

    List<RedemptionCodeInfoEntityTraineeList> selectedMembers = [];
    for(int index in selectedIndexs){
      RedemptionCodeInfoEntityTraineeList member = traineeList[index];
      selectedMembers.add(member);
    }
    Get.back(result: selectedMembers);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Container(
          width: 640.wMin,
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceSecondary.color,
            borderRadius: BorderRadius.circular(24.wMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleWidget(),
              _buildListWidget(),
              _buildButtonWidget(),
            ],
          ),
        ),
      ),   
    );
  }


  Widget _buildTitleWidget(){
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
          child: Column(
            children: [
              Text(
                widget.infoEntity.afterJumping?.name?.text??"选择学员",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 32.wMin,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SizedBox(height: 8.wMin),
              Visibility(
                visible: widget.infoEntity.afterJumping?.desc?.text?.isNotEmpty??false,
                child: Text(
                  widget.infoEntity.afterJumping?.desc?.text??"",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 24.wMin,
                    color: AppTheme.cTextBrand.color,
                  ),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          right: 16.wMin,
          top: 16.wMin,
          child: TapScaleWidget(
            sclae: 1.05,
            onTap: () => Get.back(),
            child: Container(
              width: 48.wMin,
              height: 48.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cSurfaceLayerElevated.color,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderDefault.color),
              ),
              child: SvgPicture.asset(
                "assets/svg/public/x.svg",
                width: 24.wMin,
                height: 24.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
              ),
            ),
          ),
        ),

      ],
    );
  }


  Widget _buildListWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      constraints: BoxConstraints(
        minHeight: 400.wMin,
      ),
      child: Column(
        spacing: 10.wMin,
        children: List.generate(traineeList.length, (index){
          return _buildListItemWidget(traineeList[index], index);
        }),
      ),
    );
  }


  Widget _buildListItemWidget(RedemptionCodeInfoEntityTraineeList member, int index){

    String? name = member.nickname;
    // if(member.expired == null || member.expired?.end == null || (member.isExpired??true) == true){ 
    //   name = "待激活席位";
    // }else 
    if(member.memberUserId == null){
      name = "待分配席位";
    }

    String expired = DateFormatUtil.formatStrtoStr(member.expired?.end);

    return TapScaleWidget(
      onTap: () {
        selectStudent(index);
      },
      sclae: 1.005,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(
            width: 1.wMin,
            color: selectedIndexs.contains(index) ? AppTheme.cBorderBrand.color : AppTheme.cBorderSecondary.color,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 64.wMin,
              height: 64.wMin,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2.wMin,
                  color: AppTheme.cStaticWhite.color,
                ),
              ),
              child: ClipOval(
                child: CachedImageWidget(
                  member.avatarUrl??"",
                  fit: BoxFit.cover,
                  errorWidget: Center(
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_user.svg",
                      width: 64.wMin,
                      height: 64.wMin,
                    ),
                  ),
                  placeholder: SvgPicture.asset(
                    "assets/svg/public/icon_user.svg",
                    width: 64.wMin,
                    height: 64.wMin,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.wMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name??"",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                  Visibility(
                    visible: expired.isNotEmpty,
                    child: Text(
                      member.isExpired??false ? "已于 $expired 过期" : "到期时间：$expired",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 20.wMin,
                        color: member.isExpired??false ? AppTheme.cFeedbackErrorText.color : AppTheme.cTextTertiary.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.wMin),
            SvgPicture.asset(
              selectedIndexs.contains(index) ? "assets/svg/public/icon_check_b.svg" : "assets/svg/public/icon_uncheck_box.svg",
              width: 32.wMin,
              height: 32.wMin,
            )
      
          ],
        ),
      ),
    );
  }

  Widget _buildButtonWidget(){
    String buttonText = widget.buttonText ?? "确认选择并激活";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
      child: ButtonWidget(
        text: selectedIndexs.length != maxStudentCount ? "可选择${maxStudentCount - selectedIndexs.length}个席位" : buttonText,
        width: double.infinity,
        height: 72.wMin,
        borderRadius: 12.wMin,
        color: AppTheme.cSurfaceInfo.color.withValues(alpha: selectedIndexs.length == maxStudentCount ? 1 : 0.5),
        fontSize: 28.wMin,
        fontWeight: FontWeight.w500,
        fontColor: AppTheme.cInverseTextLight.color,
        sclae: 1.005,
        onTap: () {
          submitSelectStudent();
        },
      ),
    );
  }


}


class UseCouponsDialogWidget extends StatefulWidget {
  final List<CouponEntityDatas?> couponList;
  final int? selectedCouponId;
  const UseCouponsDialogWidget({super.key, required this.couponList, this.selectedCouponId});

  @override
  State<UseCouponsDialogWidget> createState() => _UseCouponsDialogWidgetState();
}

class _UseCouponsDialogWidgetState extends State<UseCouponsDialogWidget> {
  int selectedCouponId = -1;

  @override
  void initState(){
    super.initState();
    if(widget.selectedCouponId != null){
      selectedCouponId = widget.selectedCouponId!;
    }else{
      if(widget.couponList.isNotEmpty){
        selectedCouponId = widget.couponList.first?.couponId?? (-1);
      }
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Container(
          width: 1300.wMin,
          height: 850.wMin,
          decoration: BoxDecoration(
            color: AppTheme.cBgSecondary.color,
            borderRadius: BorderRadius.circular(24.wMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleWidget(),
              _buildCouponsList(context),
              _buildButtonWidget(),
            ],
          ),
        ),
      ),   
    );
  }

  Widget _buildTitleWidget(){
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
          child: Text(
            "我的优惠券",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 32.wMin,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ),
    
        Positioned(
          right: 16.wMin,
          top: 16.wMin,
          child: TapScaleWidget(
            sclae: 1.05,
            onTap: () => Get.back(),
            child: Container(
              width: 48.wMin,
              height: 48.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cSurfaceLayerElevated.color,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderDefault.color),
              ),
              child: SvgPicture.asset(
                "assets/svg/public/x.svg",
                width: 24.wMin,
                height: 24.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
              ),
            ),
          ),
        ),
    
      ],
    );
  }

  Widget _buildCouponsList(BuildContext context) {
    List<CouponEntityDatas> couponList = widget.couponList.whereType<CouponEntityDatas>().toList();

    if(couponList.isEmpty) return Container();

    return Expanded(
      child: GridView.builder(
        itemCount: couponList.length,
        padding: EdgeInsets.symmetric(horizontal: 32.wMin),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.wMin,
          crossAxisSpacing: 16.wMin,
          childAspectRatio: 480 / 290,
        ),
        itemBuilder: (context, index) {
          return UseCouponsDialogCardWidget(
            data: couponList[index],
            isSelected: selectedCouponId == couponList[index].couponId,
            onTap: () {
              if(couponList[index].couponId == null) return;
              selectedCouponId = couponList[index].couponId!;
              if(mounted) setState(() {});
            },
          );
        },
      ),
    );
  }

  Widget _buildButtonWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
      child: Row(
        spacing: 24.wMin,
        children: [
          ButtonWidget(
            text: "不使用优惠",
            width: 300.wMin,
            height: 72.wMin,
            borderRadius: 12.wMin,
            color: AppTheme.cSurfaceTertiary.color,
            fontSize: 26.wMin,
            fontWeight: FontWeight.w500,
            fontColor: AppTheme.cTextSecondary.color,
            sclae: 1.01,
            onTap: () {
              Get.back(result: -1);
            },
          ),
          Expanded(
            child: ButtonWidget(
              text: "确认使用",
              width: double.infinity,
              height: 72.wMin,
              borderRadius: 12.wMin,
              color: AppTheme.cSurfaceInfo.color.withValues(alpha: selectedCouponId == -1 ? 0.6 : 1),
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              fontColor: AppTheme.cInverseTextLight.color,
              sclae: 1.005,
              onTap: OptimizeUtils.noneThrottle(() {
                if(selectedCouponId == -1) {
                  ToastUtils.showToast(text: "请选择优惠券");
                  return;
                }
                Get.back(result: selectedCouponId);
              }, 1000),
            ),
          ),
        ],
      ),
    );
  }

}







class UseCouponsDialogCardWidget extends StatefulWidget {
  final void Function()? onTap;
  final CouponEntityDatas data;
  final bool isSelected;

  const UseCouponsDialogCardWidget({super.key, this.onTap, required this.data, this.isSelected = false});

  @override
  State<UseCouponsDialogCardWidget> createState() => _UseCouponsDialogCardWidgetState();
}

class _UseCouponsDialogCardWidgetState extends State<UseCouponsDialogCardWidget> {
  

  @override
  Widget build(BuildContext context) {
    Color couponColor = StatusUtils.getCouponColor(widget.data.type);
    String? expired = widget.data.expired;
    String expiredText = "";
    if(expired != null){
      expiredText = DateFormatUtil.formatStrtoStr(expired, locale: Get.locale);
    }

    return TapScaleWidget(
      onTap: OptimizeUtils.noneThrottle(() {
        widget.onTap?.call();
      }, 300),
      sclae: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(
            color: widget.isSelected ? couponColor : Colors.transparent,
            width: 1.wMin,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: AppTheme.cSurfaceSecondary.color,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.wMin),
                      Text(
                        widget.data.title??"",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: couponColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Visibility(
                        visible: widget.data.ad?.isNotEmpty??false,
                        child: Text(
                          widget.data.ad??"",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: couponColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.data.describe?.isNotEmpty??false,
                        child: Text(
                          widget.data.describe??"",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: AppTheme.cTextSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.data.items?.isNotEmpty??false,
                        child: Container(
                          margin: EdgeInsets.only(top: 6.wMin),
                          padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 8.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.wMin),
                            color: couponColor.withValues(alpha: 0.1),
                          ),
                          child: Column(
                            children: List.generate(widget.data.items?.length??0, (index){
                              if(widget.data.items![index] == null) return Container();
                              return _buildRowTextWidget(
                                widget.data.items?[index]?.name?.text??"", 
                                [widget.data.items?[index]?.desc?.text??""],
                              );
                            }),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.data.benefits?.isNotEmpty??false,
                        child: Container(
                          margin: EdgeInsets.only(top: 10.wMin),
                          child: Column(
                            children: List.generate(widget.data.benefits?.length??0, (index){
                              if(widget.data.benefits![index] == null) return Container();
                              return _buildRowTextWidget(
                                widget.data.benefits?[index]?.category??"", 
                                widget.data.benefits?[index]?.items,
                              );
                            }),
                          ),
                        ),
                      ),

                      Visibility(
                        visible: widget.data.tip?.isNotEmpty??false,
                        child: Container(
                          margin: EdgeInsets.only(top: 6.wMin),
                          child: Text(
                            widget.data.tip??"",
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: AppTheme.cFeedbackErrorText,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.data.expired?.isNotEmpty??false,
                        child: Container(
                          margin: EdgeInsets.only(top: 6.wMin),
                          child: Text(
                            "$expiredText 到期",
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: AppTheme.cTextTertiary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ),
            ),
            DottedBorder(
              borderType: BorderType.RRect,
              borderPadding: EdgeInsets.symmetric(horizontal: 24.wMin),
              padding: EdgeInsets.zero,
              color: AppTheme.cTextDisabled,
              strokeWidth: 1.wMin,
              dashPattern: [6.wMin, 6.wMin],
              customPath: (size) => Path()..moveTo(0, size.height)..relativeLineTo(size.width, 0),
              child: Container(),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 19.wMin, vertical: 16.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                color: AppTheme.cSurfaceSecondary.color,
              ),
              child: _buildButtonsWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowTextWidget(String name, List<String?>? values){
    return Row(
      spacing: 10.wMin,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: Text(
              values?.join("，")??"",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildButtonsWidget(){
    Color couponColor = StatusUtils.getCouponColor(widget.data.type);

    return ButtonWidget(
      text: widget.isSelected ?  "当前使用" : "选择优惠券",
      height: 56.wMin,
      color: couponColor.withValues(alpha: widget.isSelected ? 0.2 : 0.1),
      borderRadius: 8.wMin,
      fontColor: couponColor,
      fontSize: 24.wMin,
      fontWeight: FontWeight.w600,
    );
  }


}
