
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/application/controllers/application_controller.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
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

    bool couponRes = await couponActivateStart(context, res);
    return couponRes;
  }

  /// 兑换信息弹窗
  static Future<bool> confirmVerifyDialog({
    required BuildContext context,
    required RedemptionCodeInfoEntity infoEntity,
  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ExchangeCouponsConfirmVerifyDialogWidget(infoEntity: infoEntity);
      },
    );

    return res??false;
  }

  /// 选择学员弹窗
  static Future<List<RedemptionCodeInfoEntityTraineeList>?> showSelectStudentDialog({
    required BuildContext context,
    required RedemptionCodeInfoEntity infoEntity,
  }) async{
    List<RedemptionCodeInfoEntityTraineeList>? res = await showCupertinoDialog<List<RedemptionCodeInfoEntityTraineeList>?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return SelectStudentDialogWidget(
          infoEntity: infoEntity,
        );
      },
    );
    return res;
  }

  /// 兑换
  static Future<bool> couponActivateStart(BuildContext context, String code) async{
    FocusScope.of(context).requestFocus(FocusNode());

    Map<String, dynamic> reqData = {
      "code": code,
    };

    RedemptionCodeInfoEntity? infoEntity;
    try {
      ToastUtils.showLoading();
      infoEntity = await CouponsRequest.couponActivateStartInfo(reqData);
    
    } finally{
      ToastUtils.hideLoading();
    }

    if(infoEntity == null) return false;

    if(infoEntity.confirmJump == null) return false;

    bool isConfirm = await confirmVerifyDialog(
      context: context,
      infoEntity: infoEntity,
    );

    if(!isConfirm) return false;

    if(infoEntity.confirmJump == null) return false;

    if(infoEntity.confirmJump?.code == FunctionLockMethod.confirmVerify){
      // 直接兑换
      bool res = await couponActivate(code);
      return res;
    }

    if(infoEntity.confirmJump?.code != FunctionLockMethod.dialog) return false;
    // 需要弹窗
    String? jumpCode = infoEntity.confirmJump?.params?.jump?.code;
    if(jumpCode == null) return false;

    if(jumpCode == FunctionJumpCode.choiceStudent){
      // 选择学员 然后兑换
      bool res = await selectStudentCouponActivate(context, code, infoEntity);
      return res;
    }

    return false;

  }

  /// 选择学员兑换
  static Future<bool> selectStudentCouponActivate(BuildContext context, String code, RedemptionCodeInfoEntity infoEntity) async {
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
    bool res = await couponActivate(code, traineeIds: traineeIds);
    return res;
  }


  /// 兑换优惠券
  static Future<bool> couponActivate(String code, {List<int>? traineeIds}) async {
    try {
      Map<String, dynamic> reqData = {
        "code": code,
      };
      if(traineeIds != null){
        reqData["traineeIds"] = traineeIds;
      }

      ToastUtils.showLoading();
      bool res = await CouponsRequest.couponActivate(reqData);
      if(!res) return false;

      UserStore.to.getUserInfo(showLoading: false);

      if(Get.isRegistered<UserCenterController>()){
        Get.find<UserCenterController>().initServiceData(showLoading: false);
      }

      if(Get.isRegistered<ApplicationController>()){
        Get.find<ApplicationController>().refreshHomePages();
      }

      if(Get.isRegistered<MemberCenterController>()){
        Get.find<MemberCenterController>().getMemberPackageList(showLoading: false);
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
          child: Container(
            width: 640.wMin,
            padding: EdgeInsets.all(40.wMin),
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
                    fontSize: 16.wMin,
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
                        color: AppTheme.cBgTertiary,
                        borderRadius: 8.wMin,
                        height: 56.wMin,
                        fontSize: 20.wMin,
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
                        fontSize: 20.wMin,
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
        ),
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
  
  Timer? timer;
  int countdown = 3;
  bool deleteButtonFlag = false;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown--;
      if(mounted) setState(() {});
      if(countdown <= 0){
        timer.cancel();
        deleteButtonFlag = true;
      }
    });
  }
  

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
 

  @override
  Widget build(BuildContext context) {

    List<RedemptionCodeInfoEntityJumping?> showTexts = [];

    showTexts.add(widget.infoEntity.traineeContent);

    List<RedemptionCodeInfoEntityJumping?> items = widget.infoEntity.items??[];

    showTexts.addAll(items);
    

    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Container(
          width: 640.wMin,
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
                    return Row(
                      children: [
                        Text(
                          showTexts[index]?.name?.text??"",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              showTexts[index]?.desc?.text??"",
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
                  }),
                ),
              ),
              SizedBox(height: 24.wMin),

              Visibility(
                visible: widget.infoEntity.remark != null,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.wMin),
                    color: AppTheme.cFeedbackErrorBackground,
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
                            color: AppTheme.cFeedbackErrorText,
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
                      color: AppTheme.cBgTertiary,
                      fontColor: AppTheme.cTextPrimary,
                      fontSize: 20.wMin,
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
                      color: countdown != 0 ? AppTheme.cFeedbackErrorBackground : AppTheme.cFeedbackErrorIcon,
                      fontColor: AppTheme.cStaticWhite,
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      sclae: 1.02,
                      onTap: countdown != 0 ? null : () {
                        Get.back(result: true);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SelectStudentDialogWidget extends StatefulWidget {
  final RedemptionCodeInfoEntity infoEntity;
  const SelectStudentDialogWidget({
    super.key,
    required this.infoEntity,
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
                colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
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
    if(member.traineeId == null || member.traineeId == 0){
      name = "待激活席位";
    }else if(member.memberUserId == null){
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
      child: ButtonWidget(
        text: selectedIndexs.length != maxStudentCount ? "可选择${maxStudentCount - selectedIndexs.length}个席位" : "确认选择并激活",
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