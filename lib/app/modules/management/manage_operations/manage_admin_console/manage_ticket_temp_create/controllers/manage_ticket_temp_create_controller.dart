import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/static/static_data.dart';
import '../../../../../../../common/widgets/date_time_picker_widget.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../enums/enums.dart';
import '../../../../utils/utils.dart';
import '../../../common/manage_select_notice_temp_dialog.dart';
import '../models/manage_ticket_form_model.dart';

class ManageTicketTempCreateController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageTicketTempCreateController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_TICKET_TEMP_CREATE;

  @override
  String get breadcrumbTitle => '新建工单模版';

  // 传进来的参数
  /// 工单模版数据 如果不为null则为编辑
  ManageTicketTempEntity? ticketTemp;

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();

  /// 是否启用
  final RxBool isEnable = true.obs;

  /// 模版名称 输入框
  final TextEditingController tempNameController = TextEditingController();

  /// 模版说明 输入框
  final TextEditingController tempDescController = TextEditingController();

  /// 开始时间
  final Rx<DateTime?> startTime = Rx(null);

  /// 结束时间
  final Rx<DateTime?> endTime = Rx(null);

  /// 是否在APP内打开
  final RxBool isOpenInApp = true.obs;

  /// 是否必须登录
  final RxBool isMustLogin = true.obs;

  /// 是否允许多次提交
  final RxBool isAllowMultipleSubmit = false.obs;
  
  /// 工单处理完成通知模版
  final Rx<NotifyTempEntity?> completeNotifyTemp = Rx(null);

  /// 工单要求修改通知模版
  final Rx<NotifyTempEntity?> modifyNotifyTemp = Rx(null);


  /// 基础表单类型
  final List<TicketFormTypeEnum> baseFormTypes = [
    TicketFormTypeEnum.TEXT,
    TicketFormTypeEnum.TEXTAREA,
    TicketFormTypeEnum.NUMBER,
    TicketFormTypeEnum.PHONE,
  ];

  /// 选择表单类型
  final List<TicketFormTypeEnum> selectedFormType = [
    TicketFormTypeEnum.RADIO,
    TicketFormTypeEnum.CHECKBOX,
    TicketFormTypeEnum.SELECT,
  ];

  /// 时间表单类型
  final List<TicketFormTypeEnum> timeFormType = [
    TicketFormTypeEnum.DATE,
  ];

  /// 附件表单类型
  final List<TicketFormTypeEnum> attachmentFormType = [
    TicketFormTypeEnum.IMAGE,
    // TicketFormTypeEnum.FILE,
  ];

  /// 业务表单类型
  final List<TicketFormTypeEnum> businessFormType = [
    TicketFormTypeEnum.ISBN,
    TicketFormTypeEnum.GRADE_LIST,
    TicketFormTypeEnum.TEXTBOOK_IMG,
  ];



  /// 已经添加的表单列表
  final RxList<ManageTicketFormModel> formList = <ManageTicketFormModel>[].obs;


  @override
  void onInit() {
    super.onInit();
    if(Get.arguments != null){
      ticketTemp = Get.arguments["ticketTemp"];
      getTicketTempDetail();
    }
    initBreadcrumb(tag, title: ticketTemp == null ? "新建工单模版" : "编辑工单模版");
  }

  /// 查询工单模版详情
  Future<void> getTicketTempDetail() async{
    if(ticketTemp == null) return;
    ManageTicketTempEntity temp = ticketTemp!;
    tempNameController.text = temp.name??"";
    tempDescController.text = temp.introduce??"";
    completeNotifyTemp.value = NotifyTempEntity(
      uid: temp.notifyTemplateId,
      name: temp.notifyTemplateId?.toString(),
    );
    modifyNotifyTemp.value = NotifyTempEntity(
      uid: temp.revisionNotifyTemplateId,
      name: temp.revisionNotifyTemplateId?.toString(),
    );
    startTime.value = DateFormatUtil.tryParseDate(temp.startTime)?.toLocal();
    endTime.value = DateFormatUtil.tryParseDate(temp.endTime)?.toLocal();
    isOpenInApp.value = temp.openApp??false;
    isMustLogin.value = temp.mustLogin??false;
    isAllowMultipleSubmit.value = temp.isAllowMultiUpload??false;

    isEnable.value = temp.access == AccessEnum.NORMAL.value;
    List<ManageTicketTempEntityOptions?> options = temp.options??[];

    for(int i = 0; i < options.length; i++){
      ManageTicketTempEntityOptions? item = options[i];
      if(item == null) continue;
      if(item.formTypeEnum == null) continue;

      List<TextEditingController> optionInputs = [];
      List<ManageTicketTempEntityOptionsOptions?> itemOptions = item.options??[];
      for(int j = 0; j < itemOptions.length; j++){
        ManageTicketTempEntityOptionsOptions? option = itemOptions[j];
        if(option == null) continue;
        optionInputs.add(TextEditingController(text: option.title??""));
      }

      formList.add(ManageTicketFormModel(
        titleController: TextEditingController(text: item.name),
        hintController: TextEditingController(text: item.tip),
        formType: item.formTypeEnum!,
        isRequired: item.must??false,
        key: GlobalKey(),
        optionInputs: optionInputs,
        updateOptions: item.formTypeEnum != TicketFormTypeEnum.GRADE_LIST,
        deleteOptions: item.formTypeEnum != TicketFormTypeEnum.GRADE_LIST,
        addOptions: item.formTypeEnum != TicketFormTypeEnum.GRADE_LIST,
      ));
    }

  }

  /// 切换是否在APP内打开
  void toggleIsInApp(bool value){
    isOpenInApp.value = value;
    // 如果不在APP内打开 不能登录 和 多次提交
    if(!isOpenInApp.value){
      isMustLogin.value = false;
      isAllowMultipleSubmit.value = false;
    }
  }

  /// 切换是否必须登录
  void toggleIsMustLogin(bool value){
    // 如果打开的话 需要判断是否是在app内打开 如果不是不让打开
    if(value && !isOpenInApp.value){
      return ToastUtils.showToast(text: "此选项要求在APP内打开");
    }
    isMustLogin.value = value;
  }

  /// 切换是否允许多次提交
  void toggleIsAllowMultipleSubmit(bool value){
    // 如果打开的话 需要判断是否是在app内打开 如果不是不让打开
    if(value && !isOpenInApp.value){
      return ToastUtils.showToast(text: "此选项要求在APP内打开");
    }
    isAllowMultipleSubmit.value = value;
  }


  /// 选择 可提交开始时间
  Future<void> selectStartTime(BuildContext context) async{
    DateTimePickerUtils.showStartEndCalender(
      context: context,
      initialStartDate: startTime.value,
      initialEndDate: endTime.value,
      minDate: DateTime.now().subtract(Duration(days: 60)),
      maxDate: DateTime.now().add(Duration(days: 365)),
      onTap: (start, end) {
        startTime.value = start;
        endTime.value = end;
      },
    );
  }

  /// 选择 工单处理完成通知模版
  Future<void> selectCompleteNotify(BuildContext context) async{
    NotifyTempEntity? resTemp = await ManageSelectNoticeTempDialog.show(
      context: context,
      title: "选择工单处理完成通知模版",
      initUid: completeNotifyTemp.value?.uid,
    );
    if(resTemp == null) return;
    completeNotifyTemp.value = resTemp;
  }

  /// 选择 工单要求修改通知模版
  Future<void> selectModifyNotify(BuildContext context) async{
    NotifyTempEntity? resTemp = await ManageSelectNoticeTempDialog.show(
      context: context,
      title: "选择工单要求修改通知模版",
      initUid: modifyNotifyTemp.value?.uid,
    );
    if(resTemp == null) return;
    modifyNotifyTemp.value = resTemp;
  }


  /// 增加表单项
  void addFormModel(TicketFormTypeEnum formType){
    
    List<TextEditingController>? optionInputs;
    if(formType.hasOptions){
      if(formType == TicketFormTypeEnum.GRADE_LIST){
        optionInputs = StaticData.gradeList.map((e) => TextEditingController(text: e.name)).toList();
      }else{
        optionInputs = [
          TextEditingController(text: "选项1"),
          TextEditingController(text: "选项2"),
        ];
      }
    }

    ManageTicketFormModel model = ManageTicketFormModel(
      key: GlobalKey(),
      formType: formType,
      titleController: TextEditingController(text: formType.name),
      hintController: TextEditingController(),
      optionInputs: optionInputs,
      updateOptions: formType != TicketFormTypeEnum.GRADE_LIST,
      deleteOptions: formType != TicketFormTypeEnum.GRADE_LIST,
      addOptions: formType != TicketFormTypeEnum.GRADE_LIST,
    );

    formList.add(model);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToFormModel(model);
    });
  }

  /// 切换是否必填
  void toggleIsRequired(ManageTicketFormModel item){
    item.isRequired = !item.isRequired;
    formList.refresh();
  }

  /// 删除表单项
  void deleteFormModel(int index){
    formList.removeAt(index);
  }

  /// 上移表单项
  void moveUpFormModel(int index){
    if(index == 0) return;
    ManageTicketFormModel item = formList[index];
    formList.removeAt(index);
    formList.insert(index - 1, item);
    formList.refresh();
  }

  /// 下移表单项
  void moveDownFormModel(int index){
    if(index == formList.length - 1) return;
    ManageTicketFormModel item = formList[index];
    formList.removeAt(index);
    formList.insert(index + 1, item);
    formList.refresh();
  }

  /// 添加选项
  void addOption(ManageTicketFormModel item){
    item.optionInputs ??= [];
    item.optionInputs!.add(TextEditingController(text: "选项${item.optionInputs!.length + 1}"));
    formList.refresh();
  }

  /// 删除选项
  void deleteOption(ManageTicketFormModel item, int index){
    item.optionInputs?.removeAt(index);
    formList.refresh();
  }

  /// 滚动到指定表单项
  void scrollToFormModel(ManageTicketFormModel item){
    BuildContext? ctx = item.key.currentContext;
    if(ctx == null) return;
    // 滚动到该表单项
    Scrollable.ensureVisible(ctx, duration: Duration(milliseconds: 200));
  }

  /// 组装参数
  Map<String, dynamic>? getReqData(){
    if(tempNameController.text.isEmpty){
      ToastUtils.showToast(text: "请输入模版名称");
      scrollController.animateTo(
        scrollController.position.minScrollExtent, 
        duration: Duration(milliseconds: 200), 
        curve: Curves.ease,
      );
      return null;
    }

    if(formList.isEmpty){
      ToastUtils.showToast(text: "请添加表单项");
      return null;
    }

    List<Map<String, dynamic>> formItems = [];

    for(int i = 0; i < formList.length; i++){
      ManageTicketFormModel item = formList[i];
      if(item.titleController.text.isEmpty){
        ToastUtils.showToast(text: "请输入第 ${i + 1} 个表单项的标题");
        scrollToFormModel(item);
        return null;
      }
      List<Map<String, dynamic>> options = [];
      if(item.formType.hasOptions){
        List<TextEditingController> optionInputs = item.optionInputs??[];
        if(optionInputs.isEmpty){
          ToastUtils.showToast(text: "请添加第 ${i + 1} 个表单项的选项");
          scrollToFormModel(item);
          return null;
        }

        for(int j = 0; j < optionInputs.length; j++){
          if(optionInputs[j].text.isNotEmpty) {
            options.add({
              "title": optionInputs[j].text,
            });
            continue;
          }
          ToastUtils.showToast(text: "请输入第 ${i + 1} 个表单项的 选项${j + 1}");
          scrollToFormModel(item);
          
          return null;
        }
        
      }

      formItems.add({
        "fieldType": item.formType.value,
        "must": item.isRequired,
        "order": i,
        "name": item.titleController.text,
        "tip": item.hintController.text,
        "options": options,
      });
    }

    Map<String, dynamic> data = {
      "name": tempNameController.text,
      "openApp": isOpenInApp.value,
      "mustLogin": isMustLogin.value,
      "isAllowMultiUpload": isAllowMultipleSubmit.value,
      "access": isEnable.value ? AccessEnum.NORMAL.value : AccessEnum.INTERNAL.value,
      "options": formItems,
    };
    if(tempDescController.text.trim().isNotEmpty){
      data["introduce"] = tempDescController.text;
    }
    if(startTime.value != null && endTime.value != null){
      data["startTime"] = DateFormatUtil.formatStr(DateFormatUtil.toUtcTime(startTime.value!));
      data["endTime"] = DateFormatUtil.formatStr(DateFormatUtil.toUtcTime(endTime.value!));
    }
    if(completeNotifyTemp.value != null){
      data["notifyTemplateId"] = completeNotifyTemp.value?.uid;
    }
    if(modifyNotifyTemp.value != null){
      data["revisionNotifyTemplateId"] = modifyNotifyTemp.value?.uid;
    }

    return data;
  }

  /// 创建模版
  Future<void> createTicketTemp() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic>? data = getReqData();
      print(data);
      if(data == null) return;
      bool success = await AccountConsoleRequest.createManageTicketTemp(data: data);
      if(!success) return;
      ToastUtils.showToast(text: "创建成功", type: ToastType.success);
      Get.back(result: true);
      
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 编辑模版
  Future<void> editTicketTemp() async{
    if(ticketTemp?.uid == null) return ToastUtils.showToast(text: "模版uid为空");
    try {
      ToastUtils.showLoading();
      Map<String, dynamic>? data = getReqData();
      if(data == null) return;
      ManageTicketTempEntity? res = await AccountConsoleRequest.editManageTicketTemp(tempId: ticketTemp!.uid!, data: data);
      if(res == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      Get.back(result: res);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 删除模版
  Future<void> deleteTicketTemp(BuildContext context) async{
    if(ticketTemp?.uid == null) return ToastUtils.showToast(text: "模版uid为空");
    bool? askRes = await AskDialog.showUserCancelAsk(
      context: context,
      title: "确认删除",
      content: "确认删除此模版吗？",
    );
    if(askRes != true) return;

    try {
      ToastUtils.showLoading();
      bool success = await AccountConsoleRequest.deleteManageTicketTemp(tempId: ticketTemp!.uid!);
      if(!success) return;
      ToastUtils.showToast(text: "删除模版成功");
      Get.back(result: -1);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
