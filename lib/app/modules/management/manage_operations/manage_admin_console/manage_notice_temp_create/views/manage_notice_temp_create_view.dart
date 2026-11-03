import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:json_editor_2/json_editor.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../enums/enums.dart';
import '../../../../utils/utils.dart';
import '../bindings/manage_notice_temp_create_binding.dart';
import '../controllers/manage_notice_temp_create_controller.dart';

class ManageNoticeTempCreateView extends GetView<ManageNoticeTempCreateController> {
  final String tagText;
  const ManageNoticeTempCreateView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_NOTICE_TEMP_CREATE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageNoticeTempCreateView(tagText: tag),
      binding: ManageNoticeTempCreateBinding(tag: tag),
      routeName: Routes.MANAGE_NOTICE_TEMP_CREATE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ManageScaffold(
        showCollectButton: false,
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 70.wMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleWidget(),
              SizedBox(height: 24.wMin),
              _buildBodyWidget(context),
            ],
          ),
        ),
        bottomNavigationBar: _buildButtonsWidget(context),
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      margin: EdgeInsets.only(top: 10.wMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6.wMin,
            children: [
              Text(
                controller.noticeTemp != null ? "编辑通知模版" : "新建通知模板",
                style: TextStyle(
                  fontSize: 32.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              Text(
                "一个模板包含三块：push 固有字段、跳进 APP的 Markdown 详情、跳转配置。",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyWidget(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBasicInfoWidget(context),
        SizedBox(height: 16.wMin),
        _buildInherentWidget(),
        SizedBox(height: 16.wMin),
        _buildMarkdownWidget(context),
        SizedBox(height: 16.wMin),
        _buildJumpSettingWidget(context),
        SizedBox(height: 100.wMin),
      ],
    );
  }

  /// 基础信息
  Widget _buildBasicInfoWidget(BuildContext context){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderNone.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBodyTitleWidget(title: "基础信息", subTitle: "模板内部名称与分组，仅管理用，不展示给用户。"),
              const Spacer(),
              Obx((){
                return Row(
                  children: [
                    CardSwitchWidget(
                      value: controller.isEnable.value,
                      // switchActiveColor: AppTheme.cSwitchSuccess.color,
                      onChanged: (value){
                        controller.isEnable.value = value;
                      },
                    ),
                    SizedBox(width: 8.wMin),
                    Text(
                      controller.isEnable.value ? "已启用" : "已停用",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          SizedBox(height: 16.wMin),
          Row(
            spacing: 16.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInputWidget(
                  title: "模板名称",
                  hintText: "例如：提醒设置计划",
                  controller: controller.tempNameController,
                  maxLength: 200,
                ),
              ),
              Expanded(
                child: Obx((){
                  String tips = "";
                  String notifyTempType = controller.notifyTempType.value;
                  List<NotifyTempTypeEntityDataFields?> dataFields = controller.notifyTempTypeList.firstWhereOrNull((element) => element.type == notifyTempType)?.dataFields??[];
                  if(dataFields.isNotEmpty){
                    tips = "该分组下可以填写动态字段，使用方法 ‘ 已经学习了{{code}}天 ’";
                    for(int i = 0; i < dataFields.length; i++){
                      tips += "\n${i + 1}. 名称：${dataFields[i]?.name??''}， code：{{${dataFields[i]?.code??''}}}";
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _buildSelectWidget(
                        title: "分组",
                        value: notifyTempType,
                        items: List.generate(controller.notifyTempTypeList.length, (index){
                          return IconDropdownCheckData(
                            title: controller.notifyTempTypeList[index].title??"",
                            value: controller.notifyTempTypeList[index].type,
                          );
                        }),
                        onChanged: (value, index) {
                          controller.notifyTempType.value = value.value;
                        },
                      ),
                      Visibility(
                        visible: tips.isNotEmpty,
                        child: Container(
                          margin: EdgeInsets.only(top: 6.wMin),
                          child: SelectableText(
                            tips,
                            style: TextStyle(
                              fontSize: 16.wMin,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.cTextTertiary.color,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: notifyTempType == "wordAssistance",
                        child: Container(
                          margin: EdgeInsets.only(top: 16.wMin),
                          child: _buildTapWidget(
                            title: "关联工单模版",
                            hintText: "请选择关联的工单模版",
                            value: controller.selectedTicketTemp.value?.name ?? (controller.selectedTicketTemp.value?.uid?.toString()),
                            onTap: () {
                              controller.selectWorkOrderTemp(context);
                            },
                          ),
                        ),
                      ),



                    ],
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 固有字段
  Widget _buildInherentWidget(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderNone.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBodyTitleWidget(title: "1、Push 固有字段", subTitle: "系统推送时展示的标题与内容。"),
          SizedBox(height: 16.wMin),
          _buildInputWidget(
            title: "Push 标题",
            hintText: "推送通知的标题",
            controller: controller.pushTitleController,
            maxLength: 200,
          ),
          SizedBox(height: 16.wMin),
          _buildInputWidget(
            title: "Push 内容",
            hintText: "推送通知的正文内容",
            controller: controller.pushContentController,
            maxLines: 3,
            height: 120.wMin,
            maxLength: 500,
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownWidget(BuildContext context){
    OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.wMin),
      borderSide: BorderSide(
        color: AppTheme.cBorderNone.color,
        width: 1.wMin,
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderNone.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildBodyTitleWidget(
                  title: "2、跳进 APP 的更多内容（Markdown）", 
                  subTitle: "用户点击通知进入 APP 后展示的详情，支持标题、粗体、列表。",
                ),
              ),
              TapScaleWidget(
                onTap: () {
                  controller.showFullMdDialog(context);
                },
                sclae: 1.1,
                child: Container(
                  child: Icon(Icons.fullscreen, color: AppTheme.cTextPrimary.color),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.wMin),
          Row(
            spacing: 16.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Obx((){
                  return _buildSelectWidget(
                    title: "通知内容类型",
                    value: controller.noticeContentType.value,
                    items: List.generate(NoticeContentTypeEnum.values.length, (index){
                      return IconDropdownCheckData(
                        title: NoticeContentTypeEnum.values[index].name,
                        value: NoticeContentTypeEnum.values[index],
                      );
                    }),
                    onChanged: (value, index) {
                      controller.noticeContentType.value = value.value;
                    },
                  );
                }),
              ),
              Expanded(child: SizedBox()),
            ],
          ),
          SizedBox(height: 16.wMin),
          Row(
            spacing: 16.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx((){
                      return _buildFormTitleWidget(
                        title: controller.noticeContentType.value == NoticeContentTypeEnum.md ? "Markdown 编辑" : "文本编辑", 
                        isRequired: false,
                      );
                    }),
                    SizedBox(height: 8.wMin),
                    IntrinsicHeight(
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: 250.wMin,
                          maxHeight: 500.wMin,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.wMin),
                          color: AppTheme.cSurfaceLayerBase.color,
                          border: Border.all(
                            color: AppTheme.cBorderNone.color,
                            width: 1.wMin,
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Obx((){
                            return TextField(
                              controller: controller.markdownController,
                              maxLines: 5,
                              style: TextStyle(
                                fontSize: 24.wMin,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.cTextPrimary.color,
                              ),
                              decoration: InputDecoration(
                                hintText: controller.noticeContentType.value == NoticeContentTypeEnum.txt ? "请输入文本内容" :
                                '''##标题
  正文段落，可以使用**加粗**
  - 列表项 1
  - 列表项 2''',
                                hintStyle: TextStyle(
                                  fontSize: 24.wMin,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.cTextTertiary.color,
                                ),
                                border: outlineInputBorder,
                                focusedBorder: outlineInputBorder,
                                disabledBorder: outlineInputBorder,
                                enabledBorder: outlineInputBorder,
                                focusedErrorBorder: outlineInputBorder,
                              ),
                              onChanged: (value){
                                controller.markdownPreview.value = value;
                              },
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormTitleWidget(title: "实时预览", isRequired: false),
                    SizedBox(height: 8.wMin),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 250.wMin,
                        maxHeight: 500.wMin,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                        color: AppTheme.cSurfaceLayerBase.color,
                        border: Border.all(
                          color: AppTheme.cBorderNone.color,
                          width: 1.wMin,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Obx((){
                          if(controller.noticeContentType.value == NoticeContentTypeEnum.md){
                            return AppMarkdownWidget(data: controller.markdownPreview.value);
                          }
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
                            width: double.infinity,
                            child: Text(
                              controller.markdownPreview.value,
                              style: TextStyle(
                                fontSize: 28.wMin,
                                color: AppTheme.cTextPrimary.color,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                          
                        }),
                      ),
                    ),
                  ],
                ),
              ),
          
            ],
          ),
        ],
      ),
    );
  }

  /// 跳转配置
  Widget _buildJumpSettingWidget(BuildContext context){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderNone.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBodyTitleWidget(title: "3、跳转配置", subTitle: "点击通知后的跳转目标。"),
          SizedBox(height: 16.wMin),
          Row(
            spacing: 16.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Obx((){
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _buildFormTitleWidget(title: "跳转类型"),
                      SizedBox(height: 8.wMin),

                      IconDropdownNestedSelectWidget<AppRoutesGroupData>(
                        selectValue: controller.selectedJumpType.value,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(8.wMin),
                        borderColor: AppTheme.cBorderNone.color,
                        fillColor: AppTheme.cSurfaceLayerElevated2.color,
                        itemFontSize: 24.wMin,
                        itemHeight: 72.wMin,
                        valueStyle: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w400,
                        ),
                        onChanged: (data, indexes) {
                          controller.switchJumpType(data.value);
                        },
                        items: [
                          IconDropdownNestedData(
                            title: "无跳转",
                          ),
                          IconDropdownNestedData(
                            title: "H5链接",
                            value: AppRoutesGroup.webViewMap[AppRoutesCode.webView],
                          ),
                          IconDropdownNestedData(
                            title: "学习",
                            children: List.generate(AppRoutesGroup.learningMap.length, (index) => IconDropdownNestedData(
                              title: AppRoutesGroup.learningMap.values.toList()[index].title??"",
                              value: AppRoutesGroup.learningMap.values.toList()[index],
                            )),
                          ),
                          IconDropdownNestedData(
                            title: "内容",
                            children: List.generate(AppRoutesGroup.contentMap.length, (index) => IconDropdownNestedData(
                              title: AppRoutesGroup.contentMap.values.toList()[index].title??"",
                              value: AppRoutesGroup.contentMap.values.toList()[index],
                            )),
                          ),
                          IconDropdownNestedData(
                            title: "用户",
                            children: List.generate(AppRoutesGroup.userMap.length, (index) => IconDropdownNestedData(
                              title: AppRoutesGroup.userMap.values.toList()[index].title??"",
                              value: AppRoutesGroup.userMap.values.toList()[index],
                            )),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.wMin),
                      Visibility(
                        visible: controller.selectedJumpType.value?.appCode == null,
                        child: Text(
                          "无跳转：用户点击仅查看详情内容，不进行任何跳转。",
                          style: TextStyle(
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextTertiary.color,
                          ),
                        ),
                      ),

                    ],
                  );
                }),
              ),
              Expanded(
                child: Obx((){
                  if(controller.selectedJumpType.value?.appCode == null) return Container();
                  if(controller.selectedJumpType.value?.appCode == AppRoutesCode.webView){
                    return _buildJumpSettingH5Widget();
                  }else {
                    return _buildJumpSettingDeepLinkWidget(context);
                  }
                }),
              ),

            ],
          ),
        ],
      ),
    );
  }

  JsonEditorThemeData _buildJsonEditorThemeData() {
    final style = TextStyle(
      fontSize: 24.wMin,
      fontWeight: FontWeight.w400,
    );
    final jsonTheme = JsonTheme(
      defaultStyle: style.copyWith(color: AppTheme.cTextPrimary.color),
      bracketStyle: style.copyWith(color: AppTheme.cTextSecondary.color),
      numberStyle: style.copyWith(color: AppTheme.cTextLink.color),
      stringStyle: style.copyWith(color: AppTheme.cFeedbackSuccessText.color),
      boolStyle: style.copyWith(color: AppTheme.cFeedbackWarningText.color),
      keyStyle: style.copyWith(color: AppTheme.cTextTertiary.color),
      commentStyle: style.copyWith(color: AppTheme.cTextQuaternary.color),
      errorStyle: style.copyWith(
        color: AppTheme.cFeedbackErrorText.color,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        decoration: TextDecoration.underline,
      ),
    );
    return JsonEditorThemeData(
      lightTheme: jsonTheme,
      darkTheme: jsonTheme,
    );
  }

  /// deeplink 配置参数
  Widget _buildJumpSettingDeepLinkWidget(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormTitleWidget(title: "跳转参数", subTitle: ""),
        SizedBox(height: 8.wMin),
        Container(
          height: 500.wMin,
          padding: EdgeInsets.all(12.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: AppTheme.cSurfaceLayerBase.color,
            border: Border.all(
              color: AppTheme.cBorderNone.color,
              width: 1.wMin,
            ),
          ),
          child: JsonEditorTheme(
            themeData: _buildJsonEditorThemeData(),
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: AppTheme.cTextBrand.color,
                  selectionColor: AppTheme.cBgBrand.color.withValues(alpha: 0.25),
                  selectionHandleColor: AppTheme.cBgBrand.color,
                ),
                scrollbarTheme: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(
                    AppTheme.cTextTertiary.color.withValues(alpha: 0.25),
                  ),
                  trackColor: WidgetStateProperty.all(
                    AppTheme.cTextTertiary.color.withValues(alpha: 0.12),
                  ),
                ),
              ),
              child: JsonEditor.string(
                jsonString: controller.jsonEditorController.text,
                controller: controller.jsonEditorController,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// h5配置参数
  Widget _buildJumpSettingH5Widget(){
    return Obx((){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputWidget(
            title: "链接地址",
            subTitle: "填写完整 H5 链接，例如 https://...",
            hintText: "请输入链接地址",
            controller: controller.h5LinkController,
          ),
          SizedBox(height: 8.wMin),
          Row(
            spacing: 10.wMin,
            children: [
              _buildJumpSettingH5FullWidget(
                "工单链接",
                "https://www.timelywise.cn/app/ticket/survey",
              ),
            ],
          ),
          SizedBox(height: 8.wMin),
          CardTitleSwitchWidget(
            title: "H5是否竖屏",
            titleStyle: TextStyle(
              fontSize: 22.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
            value: controller.isH5Portrait.value,
            onChanged: (value){
              controller.isH5Portrait.value = value;
            },
          ),
          SizedBox(height: 8.wMin),
          CardTitleSwitchWidget(
            title: "H5是否跳转外部浏览器",
            titleStyle: TextStyle(
              fontSize: 22.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
            value: controller.isH5OpenExternalBrowser.value,
            onChanged: (value){
              controller.isH5OpenExternalBrowser.value = value;
            },
          ),
        ],
      );
    });
  }

  Widget _buildJumpSettingH5FullWidget(String name, String url){
    return TapScaleWidget(
      onTap: () {
        controller.h5LinkController.text = url;
      },
      sclae: 1.03,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          color: AppTheme.cSurfaceSecondary.color,
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
      ),
    );
  }



  

  /// 按钮
  Widget _buildButtonsWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70.wMin, vertical: 24.wMin),
      color: AppTheme.cBgPrimary.color,
      child: Row(
        children: [
          Visibility(
            visible: controller.noticeTemp != null,
            child: ManageAuthBoxWidget(
              authCodes: [ManageAuthCode.notifyTemplateRemove],
              child: ButtonWidget(
                text: "删除模版",
                height: 54.wMin,
                padding: EdgeInsets.symmetric(horizontal: 32.wMin),
                borderRadius: 99,
                color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
                fontColor: AppTheme.cSurfaceError.color,
                fontWeight: FontWeight.w500,
                fontSize: 24.wMin,
                sclae: 1.03,
                onTap: () {
                  controller.deleteNoticeTemp(context);
                },
              ),
            ),
          ),
          const Spacer(),
          ButtonWidget(
            text: "返回列表",
            height: 54.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            borderRadius: 99,
            color: AppTheme.cSurfaceLayerElevated.color,
            fontColor: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w500,
            fontSize: 24.wMin,
            sclae: 1.03,
            onTap: () {
              Get.back();
            },
          ),
          SizedBox(width: 24.wMin),
          ButtonWidget(
            text: controller.noticeTemp == null ? "创建模版" : "保存修改",
            height: 54.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            borderRadius: 99,
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
            fontColor: AppTheme.cSurfaceBrand.color,
            fontWeight: FontWeight.w500,
            fontSize: 24.wMin,
            sclae: 1.03,
            onTap: () {
              if(controller.noticeTemp != null){
                controller.editNoticeTemp();
              }else{
                controller.createNoticeTemp();
              }
            },
          ),
        ],
      ),
    );
  }





  Widget _buildBodyTitleWidget({
    required String title,
    required String subTitle,
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        Text(
          subTitle,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      ],
    );
  }

  Widget _buildFormTitleWidget({
    required String title,
    String? subTitle,
    bool isRequired = true,
  }){
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        Visibility(
          visible: isRequired,
          child: Text(
            "*",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cSurfaceError.color,
            ),
          ),
        ),
        const Spacer(),
        Visibility(
          visible: subTitle != null,
          child: SelectableText(
            subTitle??"",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputWidget({
    required String title,
    String? subTitle,
    bool isRequired = true,
    required String hintText,
    required TextEditingController controller,
    double? height,
    int? maxLength,
    int? maxLines = 1,
    void Function(String value)? onChanged,
    Widget? suffixWidget,
    Widget? prefixWidget,
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormTitleWidget(title: title, subTitle: subTitle, isRequired: isRequired),
        SizedBox(height: 8.wMin),
        Row(
          children: [
            Expanded(
              child: CardInputWidget(
                hintText: hintText,
                controller: controller,
                height: height ?? 72.wMin,
                maxLines: maxLines,
                maxLength: maxLength,
                borderRadius: BorderRadius.circular(8.wMin),
                borderWidth: 1.wMin,
                borderColor: AppTheme.cBorderNone.color,
                fillColor: AppTheme.cSurfaceLayerElevated2.color,
                hintStyle: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
                valueStyle: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
                prefixIcon: prefixWidget,
                onChanged: onChanged,
              ),
            ),
            Visibility(
              visible: suffixWidget != null,
              child: Container(
                margin: EdgeInsets.only(left: 8.wMin),
                child: suffixWidget,
              ),
            ),
          ],
        ),
        
      ],
    );
  }

  Widget _buildSelectWidget({
    required String title,
    String? subTitle,
    bool isRequired = true,
    dynamic value,
    required List<IconDropdownCheckData<dynamic>> items,
    void Function(IconDropdownCheckData<dynamic>, int)? onChanged,
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormTitleWidget(title: title, subTitle: subTitle, isRequired: isRequired),
        SizedBox(height: 8.wMin),
        IconDropdownSelectWidget(
          items: items,
          selectValue: value,
          borderRadius: BorderRadius.circular(8.wMin),
          borderColor: AppTheme.cBorderNone.color,
          fillColor: AppTheme.cSurfaceLayerElevated2.color,
          itemFontSize: 24.wMin,
          itemHeight: 72.wMin,
          valueStyle: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextPrimary.color,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// 选择组件
  Widget _buildTapWidget({
    required String title,
    String? subTitle,
    bool isRequired = true,
    required String hintText,
    String? value,
    double? height,
    void Function()? onTap,
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormTitleWidget(title: title, subTitle: subTitle, isRequired: isRequired),
        SizedBox(height: 8.wMin),
        TapScaleWidget(
          onTap: onTap,
          sclae: 1,
          child: Container(
            height: height ?? 72.wMin,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceLayerElevated2.color,
              border: Border.all(
                color: AppTheme.cBorderNone.color,
                width: 1.wMin,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: value != null && value.isNotEmpty ? Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ) : Text(
                    hintText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  "assets/svg/public/icon_w_arrow_right.svg",
                  width: 28.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  


}
