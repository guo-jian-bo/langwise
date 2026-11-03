import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../common/commons.dart';
import '../../enums/enums.dart';
import '../../utils/utils.dart';

/// 巡检 工单
class ManageInspectionTicketDialog{

  /// 工单列表
  static Future<void> show({
    required BuildContext context,
    required ManageEmployeeConsoleMemberEntity data,
  }) async{
    return await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ManageInspectionTicketDialogWidget(data: data);
      },
    );
  }

  /// 工单详情
  static Future<TicketRecordStatusEnum?> showDetail({
    required BuildContext context,
    required ManageTicketRecordEntity data,
  }) async{
    return await showCupertinoDialog<TicketRecordStatusEnum?>(
      context: context,
      builder: (context) {
        return ManageInspectionTicketDialogDetailsWidget(data: data);
      },
    );
  }


}

class ManageInspectionTicketDialogWidget extends StatefulWidget {
  final ManageEmployeeConsoleMemberEntity data;
  const ManageInspectionTicketDialogWidget({super.key, required this.data});

  @override
  State<ManageInspectionTicketDialogWidget> createState() => _ManageInspectionTicketDialogWidgetState();
}

class _ManageInspectionTicketDialogWidgetState extends State<ManageInspectionTicketDialogWidget> {

  List<ManageTicketRecordEntity> ticketRecordList = [];

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
        if(!isLoading && ticketRecordList.length < total){
          offset += limit;
          _queryUserList();
        }
      }
    });
  }

  /// 刷新列表
  Future<void> refreshList() async{
    ticketRecordList.clear();
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
        "order": "-submit",
      };
      Map<String, dynamic> reqData = {
        "userId": widget.data.userId,
        "memberId": widget.data.memberId,
      };

      ListResponseEntity<ManageTicketRecordEntity>? res = await AccountConsoleRequest.getTicketRecordList(params: params, data: reqData);
      if(res == null) return;

      ticketRecordList.addAll(res.datas ?? []);

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
      title: "查看工单·${widget.data.name??''}",
      width: 960.wMin,
      child: SizedBox(
        height: 900.wMin,
        child: _buildListWidget(),
      ),
    );
  }

  Widget _buildListWidget(){
    if(ticketRecordList.isEmpty && !isLoading){
      return NotDataWidget(
        message: "暂无工单",
      );
    }

    return ListView.separated(
      itemCount: ticketRecordList.length,
      padding: EdgeInsets.only(bottom: 24.wMin, left: 32.wMin, right: 32.wMin),
      separatorBuilder: (context, index){
        return SizedBox(height: 24.wMin);
      },
      itemBuilder: (context, index){
        return _buildItemWidget(ticketRecordList[index]);
      },
    );
  }

  Widget _buildItemWidget(ManageTicketRecordEntity item){
    return TapScaleWidget(
      onTap: () async{
        if(!ManageAuthUtils.isAuth(ManageAuthCode.channelTicketRecordDetail)) return;
        TicketRecordStatusEnum? res = await ManageInspectionTicketDialog.showDetail(context: context, data: item);
        if(res == null) return;
        // 返回后需要刷新状态
        for (var element in ticketRecordList) {
          if(element.uid == item.uid){
            element.status = res.value;
          }
        }
        if(mounted) setState(() {});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.name??"",
                    style: TextStyle(
                      color: AppTheme.cTextPrimary.color,
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 10.wMin),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: item.statusEnum.color.withValues(alpha: 0.2),
                    border: Border.all(
                      color: item.statusEnum.color.withValues(alpha: 0.2),
                      width: 0.8.wMin,
                    ),
                  ),
                  child: Text(
                    item.statusEnum.text,
                    style: TextStyle(
                      color: item.statusEnum.color,
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.wMin),
            Text(
              DateFormatUtil.formatStrtoStr(item.submit, newPattern: "yyyy-MM-dd HH:mm:ss"),
              style: TextStyle(
                color: AppTheme.cTextTertiary.color,
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
              ),
            ), 
            ManageAuthBoxWidget(
              authCodes: [ManageAuthCode.channelTicketRecordDetail],
              child: Row(
                spacing: 8.wMin,
                children: [
                    
                  const Spacer(),
                    
                  ButtonWidget(
                    text: "查看工单详情 >",
                    color: Colors.transparent,
                    fontColor: AppTheme.cSurfaceBrand.color,
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                  
                ],
              ),
            ),
      
          ],
        ),
      ),
    );
  }
}


class ManageInspectionTicketDialogDetailsWidget extends StatefulWidget {
  final ManageTicketRecordEntity data;
  const ManageInspectionTicketDialogDetailsWidget({super.key, required this.data});

  @override
  State<ManageInspectionTicketDialogDetailsWidget> createState() => _ManageInspectionTicketDialogDetailsWidgetState();
}

class _ManageInspectionTicketDialogDetailsWidgetState extends State<ManageInspectionTicketDialogDetailsWidget> {

  ManageTicketDetailEntity detailData = ManageTicketDetailEntity();

  @override
  void initState() {
    super.initState();
    queryTicketDetail();
  }

  /// 查询工单详情
  Future<void> queryTicketDetail() async{
    if(widget.data.uid == null) return;
    try {
      ToastUtils.showLoading();

      ManageTicketDetailEntity? detail = await AccountConsoleRequest.getTicketDetail(ticketRecordId: widget.data.uid!);
      if(detail == null) return;
      detailData = detail;
      if(mounted) setState(() {});

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 工单需要修改
  Future<void> modifyTicket() async{
    if(widget.data.uid == null) return ToastUtils.showToast(text: "工单ID不能为空");

    String? remark = await InputDialog.show(
      context: context,
      title: "工单需要修改",
      content: "请输入工单修改的原因",
      hintText: "请输入原因",
      confirmText: "确认提交",
    );
    if(remark == null) return;

    try {
      ToastUtils.showLoading();

      bool res = await AccountConsoleRequest.modifyTicket(uid: widget.data.uid!, data: {"handleRemark": remark});
      if(!res) return;
      ToastUtils.showToast(text: "提交成功", type: ToastType.success);

      Get.back(result: TicketRecordStatusEnum.revision_required);

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 完成工单
  Future<void> completeTicket() async{
    if(widget.data.uid == null) return ToastUtils.showToast(text: "工单ID不能为空");

    String? remark = await InputDialog.show(
      context: context,
      title: "完成工单",
      content: "请输入完成工单的备注",
      hintText: "请输入备注（可选）",
      confirmText: "确认完成",
      required: false,
    );
    if(remark == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "handleRemark": remark,
      };
      bool res = await AccountConsoleRequest.ticketRecordComplete(ticketRecordId: widget.data.uid!, data: reqData);
      if(!res) return;

      ToastUtils.showToast(text: "提交成功", type: ToastType.success);

      Get.back(result: TicketRecordStatusEnum.completed);

    } finally{
      ToastUtils.hideLoading();
    }
  }

  String getDownloadZipName(ManageTicketDetailEntityFields? item){
    return "工单详情_${detailData.name ?? ""}_${item?.name??''}_${item?.uid??''}_附件.zip";
  }

  /// 下载文件
  Future<void> downloadFileZip(ManageTicketDetailEntityFields? item, List<ManageTicketDetailEntityFieldAttachment> attachmentList) async{
    String? selectDirectory = await FilePicker.getDirectoryPath();
    if (selectDirectory == null) return;
    String zipPath = "$selectDirectory${Platform.pathSeparator}${getDownloadZipName(item)}";
    Archive archive = Archive();
    try{
      ToastUtils.showLoading();

      for(int i = 0; i < attachmentList.length; i++){
        if(attachmentList[i].url == null) continue;

        List<int>? bytes = await _loadFileBytes(attachmentList[i]);
        if(bytes == null || bytes.isEmpty) continue;

        Uri uri = Uri.parse(attachmentList[i].url!);
        String suff = uri.pathSegments.last.split(".").last;
        String numberStr = i.toString().padLeft(3, '0');

        String fileName = "${numberStr}_${attachmentList[i].key}.$suff";
        if(fileName.isEmpty) continue;

        archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
      }

      if(archive.files.isEmpty){
        ToastUtils.showToast(text: "资源获取失败");
        return;
      }

      List<int> zipBytes = ZipEncoder().encode(archive);
      if(zipBytes.isEmpty){
        ToastUtils.showToast(text: "压缩失败");
        return;
      }

      File zipFile = File(zipPath);
      if(await zipFile.exists()){
        await zipFile.delete();
      }
      await zipFile.writeAsBytes(zipBytes, flush: true);
      ToastUtils.showToast(text: "下载成功", type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 获取视频字节：优先读取本地缓存，缓存不存在时回退网络下载
  Future<List<int>?> _loadFileBytes(ManageTicketDetailEntityFieldAttachment data) async{
    String? url = data.url;
    if(url == null || url.isEmpty) return null;

    HttpClient httpClient = HttpClient();
    try{
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      HttpClientResponse response = await request.close();
      if(response.statusCode != HttpStatus.ok){
        return null;
      }
      return await response.fold<List<int>>([], (previous, element){
        previous.addAll(element);
        return previous;
      });
    } catch (_) {
      return null;
    } finally{
      httpClient.close(force: true);
    }

  }


  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "工单详情·${widget.data.userNickname??''}",
      width: 960.wMin,
      child: SizedBox(
        height: 900.wMin,
        child: Column(
          children: [
            Expanded(child: _buildListWidget()),
            _buildButtonsWidget(),
            SizedBox(height: 16.wMin),
          ],
        ),
      ),
    );
  }

  ManageTicketDetailEntityFields? _findFieldByType(TicketFormTypeEnum type) {
    for (final field in detailData.fields ?? const <ManageTicketDetailEntityFields>[]) {
      if (field == null) continue;
      if (field.formTypeEnum == type) return field;
    }
    return null;
  }

  String? _findDisplayTextByType(TicketFormTypeEnum type) {
    final value = _findFieldByType(type)?.displaySingleText;
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? _findFirstAttachmentUrlByType(TicketFormTypeEnum type) {
    final field = _findFieldByType(type);
    if (field == null) return null;
    for (final item in field.displayAttachmentList) {
      final url = item.url;
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  String? _findAttachmentUrlByType(TicketFormTypeEnum type, int index) {
    final field = _findFieldByType(type);
    if (field == null) return null;
    int currentIndex = 0;
    for (final item in field.displayAttachmentList) {
      final url = item.url;
      if (url == null || url.isEmpty) continue;
      if (currentIndex == index) return url;
      currentIndex += 1;
    }
    return null;
  }

  Future<Map<String, String>?> _showGenerateCustomBookDialog({
    required String isbn,
    required String frontUrl,
    required String backUrl,
    required String grade,
  }) async{
    return await showCupertinoDialog<Map<String, String>?>(
      context: context,
      builder: (context) {
        return _GenerateCustomBookDialogWidget(
          isbn: isbn,
          frontUrl: frontUrl,
          backUrl: backUrl,
          grade: grade,
        );
      },
    );
  }

  Future<void> generateCustomBook() async {
    final isbn = _findDisplayTextByType(TicketFormTypeEnum.ISBN);
    final frontUrl = _findFirstAttachmentUrlByType(TicketFormTypeEnum.TEXTBOOK_IMG);
    final backUrl = _findAttachmentUrlByType(TicketFormTypeEnum.TEXTBOOK_IMG, 1);
    final grade = _findDisplayTextByType(TicketFormTypeEnum.GRADE_LIST);
    final userId = detailData.userId;
    final teamId = detailData.teamId;

    if (frontUrl == null || grade == null || userId == null || teamId == null) {
      ToastUtils.showToast(text: '生成参数缺失');
      return;
    }

    final Map<String, String>? params = await _showGenerateCustomBookDialog(
      isbn: isbn ?? '',
      frontUrl: frontUrl,
      backUrl: backUrl ?? '',
      grade: grade,
    );
    if(params == null) return;

    try {
      ToastUtils.showLoading();
      final Map<String, String> data = {
        "frontUrl": params["frontUrl"] ?? "",
        "grade": params["grade"] ?? "",
        "userId": '$userId',
        "teamId": '$teamId',
      };
      final String isbnText = (params["isbn"] ?? "").trim();
      final String backUrlText = (params["backUrl"] ?? "").trim();
      if (isbnText.isNotEmpty) data["isbn"] = isbnText;
      if (backUrlText.isNotEmpty) data["backUrl"] = backUrlText;
      final success = await AccountConsoleRequest.createUserCourseModule(
        data: data,
      );
      if (!success) return;
      ToastUtils.showToast(text: '生成成功', type: ToastType.success);
      Get.back();
      Get.back();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Widget _buildButtonsWidget(){
    if(widget.data.statusEnum == TicketRecordStatusEnum.no_submit) return Container();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.wMin, horizontal: 32.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (detailData.module == 'ADD_TEXTBOOK')
            ManageAuthBoxWidget(
              authCodes: [ManageAuthCode.bookCreate],
              margin: EdgeInsets.only(right: 16.wMin),
              child: ButtonWidget(
                text: "一键生成自定义教材",
                height: 56.wMin,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.1),
                borderRadius: 8.wMin,
                border: Border.all(
                  color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                  width: 1.wMin,
                ),
                fontColor: AppTheme.cSurfaceBrand.color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: () {
                  generateCustomBook();
                },
              ),
            ),
          ManageAuthBoxWidget(
            authCodes: [ManageAuthCode.channelTicketRecordRevision],
            child: ButtonWidget(
              text: "工单需要修改",
              height: 56.wMin,
              padding: EdgeInsets.symmetric(horizontal: 24.wMin),
              color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.1),
              borderRadius: 8.wMin,
              border: Border.all(
                color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                width: 1.wMin,
              ),
              fontColor: AppTheme.cSurfaceWarning.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.03,
              onTap: () {
                modifyTicket();
              },
            ),
          ),
          ManageAuthBoxWidget(
            authCodes: [ManageAuthCode.channelTicketRecordComplete],
            margin: EdgeInsets.only(left: 16.wMin),
            child: ButtonWidget(
              text: "完成工单",
              height: 56.wMin,
              padding: EdgeInsets.symmetric(horizontal: 24.wMin),
              color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.1),
              borderRadius: 8.wMin,
              border: Border.all(
                color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
                width: 1.wMin,
              ),
              fontColor: AppTheme.cSurfaceSuccess.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.03,
              onTap: () {
                completeTicket();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListWidget(){
    List<ManageTicketDetailEntityFields?> fields = detailData.fields??[];
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24.wMin, left: 32.wMin, right: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detailData.name??"",
            style: TextStyle(
              color: AppTheme.cTextPrimary.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            detailData.introduce??"",
            style: TextStyle(
              color: AppTheme.cTextTertiary.color,
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 16.wMin),
          Column(
            spacing: 16.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(fields.length, (index){
              return _buildItemWidget(fields[index], index);
            }),
          ),

        ],
      ),
    );
  }

  Widget _buildItemWidget(ManageTicketDetailEntityFields? item, int index){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.wMin, horizontal: 16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerElevated2.color,
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60.wMin,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: item?.must??false,
                  child: Text(
                    "*",
                    style: TextStyle(
                      color: AppTheme.cSurfaceError.color,
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  "${(index + 1).toString().padLeft(2, "0")}. ",
                  style: TextStyle(
                    color: AppTheme.cTextPrimary.color,
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  item?.name??"",
                  style: TextStyle(
                    color: AppTheme.cTextPrimary.color,
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Visibility(
                  visible: item?.introduce?.isNotEmpty??false,
                  child: Container(
                    margin: EdgeInsets.only(top: 4.wMin),
                    child: SelectableText(
                      item?.introduce??"",
                      style: TextStyle(
                        color: AppTheme.cTextSecondary.color,
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: item?.tip?.isNotEmpty??false,
                  child: Container(
                    margin: EdgeInsets.only(top: 4.wMin),
                    child: SelectableText(
                      item?.tip??"",
                      style: TextStyle(
                        color: AppTheme.cTextSecondary.color,
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                 SizedBox(height: 6.wMin),
                 _buildUserContent(item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserContent(ManageTicketDetailEntityFields? item){
    if(item == null) return Container();

    TextStyle textStyle = TextStyle(
      color: AppTheme.cTextPrimary.color,
      fontSize: 20.wMin,
      fontWeight: FontWeight.w600,
    );

    if(item.isSingleDisplayTextType){
      return Row(
        children: [
          Visibility(
            visible: item.formTypeEnum == TicketFormTypeEnum.RADIO,
            child: Container(
              margin: EdgeInsets.only(right: 10.wMin),
              child: SvgPicture.asset(
                "assets/svg/public/icon_radio.svg",
                height: 24.wMin,
              ),
            ),
          ),
          SelectableText(item.displaySingleText??"", style: textStyle),
        ],
      );
    }else if(item.isMultiDisplayTextType){
      item.displayTextList;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4.wMin,
        children: List.generate(item.displayTextList.length, (index){
          return Row(
            children: [
              Visibility(
                visible: item.formTypeEnum == TicketFormTypeEnum.CHECKBOX,
                child: Container(
                  margin: EdgeInsets.only(right: 10.wMin),
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_check_b.svg",
                    height: 24.wMin,
                  ),
                ),
              ),
              SelectableText(item.displayTextList[index], style: textStyle),
            ],
          );
        }),
      );
    }else if(item.isAttachmentDisplayTypeFile){
      return _buildUserContentFileWidget(item);
    }else if(item.isAttachmentDisplayTypeImage){
      return _buildUserContentImgWidget(item);
    }

    return SelectableText(item.displayValue?.toString()??"", style: textStyle);
  }

  /// 文件
  Widget _buildUserContentFileWidget(ManageTicketDetailEntityFields? item){
    List<ManageTicketDetailEntityFieldAttachment> displayAttachmentList = item?.displayAttachmentList??[];
    if(displayAttachmentList.isEmpty) return Container();
    TextStyle textStyle = TextStyle(
      color: AppTheme.cTextPrimary.color,
      fontSize: 20.wMin,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(displayAttachmentList.length, (index){
            return SelectableText(displayAttachmentList[index].key??"} ", style: textStyle);
          }),
        ),
        Container(
          alignment: Alignment.centerRight,
          child: TapScaleWidget(
            onTap: () {
              downloadFileZip(item, displayAttachmentList);
            },
            sclae: 1.03,
            child: Text(
              "全部下载",
              style: TextStyle(
                color: AppTheme.cTextBrand.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 图片
  Widget _buildUserContentImgWidget(ManageTicketDetailEntityFields? item){
    List<ManageTicketDetailEntityFieldAttachment> displayAttachmentList = item?.displayAttachmentList??[];
    if(displayAttachmentList.isEmpty) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.wMin,
          runSpacing: 8.wMin,
          children: List.generate(displayAttachmentList.length, (index){
            return TapScaleWidget(
              onTap: () {
                List<String> imageUrls = [];
                for(int i = 0; i < displayAttachmentList.length; i++){
                  imageUrls.add(displayAttachmentList[i].url??"");
                }
                ShowBigResourceDialog.showImage(
                  context: context, 
                  imageUrls: imageUrls,
                  index: index,
                );
              },
              sclae: 1,
              child: SizedBox(
                width: 190.wMin,
                child: AspectRatio(
                  aspectRatio: item?.formTypeEnum == TicketFormTypeEnum.IMAGE ? 1 : 3/4,
                  child: CachedImageWidget(
                    displayAttachmentList[index].url??"",
                    errorWidget: buildEmptyWidget(),
                    placeholder: buildEmptyWidget(),
                  ),
                ),
              ),
            );
          }),
        ),
        Container(
          alignment: Alignment.centerRight,
          child: TapScaleWidget(
            onTap: () {
              downloadFileZip(item, displayAttachmentList);
            },
            sclae: 1.03,
            child: Text(
              "全部下载",
              style: TextStyle(
                color: AppTheme.cTextBrand.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );

  }

}

class _GenerateCustomBookDialogWidget extends StatefulWidget {
  final String isbn;
  final String frontUrl;
  final String backUrl;
  final String grade;

  const _GenerateCustomBookDialogWidget({
    required this.isbn,
    required this.frontUrl,
    required this.backUrl,
    required this.grade,
  });

  @override
  State<_GenerateCustomBookDialogWidget> createState() => _GenerateCustomBookDialogWidgetState();
}

class _GenerateCustomBookDialogWidgetState extends State<_GenerateCustomBookDialogWidget> {
  late final TextEditingController isbnController;
  late final TextEditingController frontUrlController;
  late final TextEditingController backUrlController;
  late final TextEditingController gradeController;

  @override
  void initState() {
    super.initState();
    isbnController = TextEditingController(text: widget.isbn);
    frontUrlController = TextEditingController(text: widget.frontUrl);
    backUrlController = TextEditingController(text: widget.backUrl);
    gradeController = TextEditingController(text: widget.grade);
  }

  @override
  void dispose() {
    isbnController.dispose();
    frontUrlController.dispose();
    backUrlController.dispose();
    gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> pickAndUploadImage(TextEditingController controller) async {
      File? file = await ImagePickerUtils.pickImage(context);
      if(!context.mounted) return;
      if(file == null) return;
      try {
        ToastUtils.showLoading();
        final uploadRes = await OssUploadFileUtils.uploadManageFile(
          filePath: file.path,
          fileModule: OssFileManageModule.book,
          fileType: OssFileManageType.image,
        );
        if(!context.mounted) return;
        if(uploadRes == null) return;
        if((uploadRes.url ?? "").isEmpty) return;
        controller.text = uploadRes.url!.trim();
        ToastUtils.showToast(text: "上传成功", type: ToastType.success);
      } finally{
        ToastUtils.hideLoading();
      }
    }

    Widget buildFieldTitle(String title, {required bool required}){
      return Container(
        margin: EdgeInsets.only(bottom: 12.wMin),
        child: Text.rich(
          TextSpan(
            children: [
              if (required)
                TextSpan(
                  text: '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              TextSpan(
                text: title,
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: const Color(0xffEBEEF3),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildImagePicker({
      required String title,
      required TextEditingController controller,
      bool required = true,
    }){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildFieldTitle(title, required: required),
          TapScaleWidget(
            onTap: () async {
              await pickAndUploadImage(controller);
            },
            sclae: 1,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                final String url = value.text.trim();
                return SizedBox(
                  width: 190.wMin,
                  child: AspectRatio(
                    aspectRatio: 3/4,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.wMin),
                        color: Colors.transparent,
                        border: Border.all(
                          width: 1.wMin,
                          color: AppTheme.cBorderDefault.color,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: url.isEmpty
                          ? Center(
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 28.wMin,
                                color: AppTheme.cTextTertiary.color,
                              ),
                            )
                          : CachedImageWidget(
                              url,
                              errorWidget: buildEmptyWidget(),
                              placeholder: buildEmptyWidget(),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return DialogUserWidget(
      title: "生成自定义教材",
      width: 860.wMin,
      child: Container(
        padding: EdgeInsets.only(left: 32.wMin, right: 32.wMin, bottom: 32.wMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ManageTitleInputWidget(
              title: "ISBN",
              hintText: "请输入ISBN",
              required: false,
              controller: isbnController,
              readOnly: false,
            ),
            SizedBox(height: 16.wMin),
            ManageSelectWidget(
              title: "年级",
              hintText: "请选择年级",
              required: true,
              value: gradeController.text,
              readOnly: false,
              options: CommonUtil.grades,
              onChanged: (value, index) {
                setState(() {
                  gradeController.text = value;
                });
              },
            ),
            SizedBox(height: 16.wMin),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildImagePicker(title: "封面", controller: frontUrlController),
                SizedBox(width: 16.wMin),
                Expanded(
                  child: buildImagePicker(title: "封底", controller: backUrlController, required: false),
                ),
              ],
            ),
            SizedBox(height: 24.wMin),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ButtonWidget(
                  text: "取消",
                  height: 44.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                  borderRadius: 8.wMin,
                  color: Colors.transparent,
                  border: Border.all(
                    color: AppTheme.cBorderDefault.color,
                    width: 1.wMin,
                  ),
                  fontSize: 18.wMin,
                  fontColor: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                  onTap: () {
                    Get.back();
                  },
                ),
                SizedBox(width: 12.wMin),
                ButtonWidget(
                  text: "确定",
                  height: 44.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                  borderRadius: 8.wMin,
                  color: AppTheme.cSurfaceBrand.color,
                  fontSize: 18.wMin,
                  fontColor: Colors.white,
                  fontWeight: FontWeight.w500,
                  onTap: () {
                    final String isbnText = isbnController.text.trim();
                    final String frontUrlText = frontUrlController.text.trim();
                    final String backUrlText = backUrlController.text.trim();
                    final String gradeText = gradeController.text.trim();

                    if (frontUrlText.isEmpty || gradeText.isEmpty) {
                      ToastUtils.showToast(text: "请完善生成信息");
                      return;
                    }
                    if (isbnText.isEmpty && backUrlText.isEmpty) {
                      ToastUtils.showToast(text: "ISBN和封底至少填写一个");
                      return;
                    }
                    if (isbnText.isNotEmpty && !RegExp(r'^\d{13}$').hasMatch(isbnText)) {
                      ToastUtils.showToast(text: "ISBN必须为13位数字");
                      return;
                    }
                    Get.back(result: {
                      "isbn": isbnText,
                      "frontUrl": frontUrlText,
                      "backUrl": backUrlText,
                      "grade": gradeText,
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
