
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:archive/archive.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../../common/manage_zhendu_widgets.dart';

/// 查看prompt弹窗
class ManageVisualViewPromptDialog{

  static Future<void> show({
    required BuildContext context,
    required int projectId,
    required ManageVisualProjectEntitySceneRelations data,
  }) async{
    
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ManageVisualViewPromptDialogWidget(
          projectId: projectId,
          data: data, 
        );
      },
    );

  }

}


class ManageVisualViewPromptDialogWidget extends StatefulWidget {
  final int projectId;
  final ManageVisualProjectEntitySceneRelations data;
  const ManageVisualViewPromptDialogWidget({
    super.key, 
    required this.data, 
    required this.projectId,
  });

  @override
  State<ManageVisualViewPromptDialogWidget> createState() => _ManageVisualViewPromptDialogWidgetState();
}

class _ManageVisualViewPromptDialogWidgetState extends State<ManageVisualViewPromptDialogWidget> {

  final TextEditingController promptInput = TextEditingController();

  ManageVisualProjectPromptEntity promptEntity = ManageVisualProjectPromptEntity();

  /// 是否编辑提示词
  bool isEditPrompt = false;

  int? promptId;

  @override
  void initState() {
    super.initState();
    promptId = widget.data.promptId;
    getPromptInfo();
  }

  /// 查询提示词信息
  Future<void> getPromptInfo() async{
    if(promptId == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "promptId": widget.data.promptId,
      };
      ManageVisualProjectPromptEntity? res = await LanguageConsoleDramaRequest.getVisualProjectPromptInfo(data: reqData);
      if(res == null) return;
      promptEntity = res;
      promptInput.text = res.prompt??"";
      if(mounted) setState(() {});
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 保存提示词
  Future<void> savePrompt() async{
    if(promptInput.text == promptEntity.prompt){
      ToastUtils.showToast(text: "提示词未改变");
      isEditPrompt = false;
      if(mounted) setState(() {});
      return;
    }
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "promptId": widget.data.promptId,
        "prompt": promptInput.text,
      };
      bool response = await LanguageConsoleRequest.editImagePrompt(data: reqData);
      if(!response) return;
      ToastUtils.showToast(text: '修改成功', type: ToastType.success);
      promptEntity.prompt = promptInput.text;
      isEditPrompt = false;
      if(mounted) setState(() {});
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 打包下载
  Future<void> downloadPromptImages() async{
    if(promptEntity.referenceImages?.isEmpty == true){
      ToastUtils.showToast(text: "暂无可下载资源");
      return;
    }

    String? selectDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectDirectory == null) return;

    String zipPath = "$selectDirectory${Platform.pathSeparator}${getSceneName()}.zip";
    List<ManageVisualProjectPromptEntityReferenceImages?> referenceImages = promptEntity.referenceImages ?? [];
    Archive archive = Archive();

    try{
      ToastUtils.showLoading();

      for(final image in referenceImages){
        if(image?.url == null || image!.url!.isEmpty) continue;

        List<int>? bytes = await _loadPromptImageBytes(image);
        if(bytes == null || bytes.isEmpty) continue;

        String imageName = getImageName(image);
        if(imageName.isEmpty) continue;

        archive.addFile(ArchiveFile(imageName, bytes.length, bytes));
      }

      if(archive.files.isEmpty){
        ToastUtils.showToast(text: "图片资源获取失败");
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

  /// 获取图片字节：优先读取本地缓存，缓存不存在时回退网络下载
  Future<List<int>?> _loadPromptImageBytes(ManageVisualProjectPromptEntityReferenceImages image) async{
    String? url = image.url;
    if(url == null || url.isEmpty) return null;

    String? localFilePath = await CacheManagerUtils.instance.getFile(url, ResourceType.image);
    if(localFilePath != null){
      File localFile = File(localFilePath);
      if(await localFile.exists()){
        return await localFile.readAsBytes();
      }
    }

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

  ///获取资源类型后缀
  String getKnowledgePointFileExtension(String url){
    Uri uri = Uri.parse(url);
    return uri.pathSegments.last.split(".").last;
  }

  /// 获取文件夹分镜名称
  String getSceneName(){
    return "${widget.data.sceneTitle??''}_scene${widget.data.index??''}";
  }

  /// 获取图片文件名
  String getImageName(ManageVisualProjectPromptEntityReferenceImages? image){
    if(image?.url == null) return "";
    String ext = getKnowledgePointFileExtension(image!.url!);
    return "${getSceneName()}_image${image.refNo??''}.$ext";
  }

  /// 生成提示词
  Future<void> generatePrompt() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "projectId": widget.projectId,
        "sceneId": widget.data.sceneId,
      };
      String? res = await LanguageConsoleDramaRequest.createVisualProjectPromptGenerate(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "Prompt 数据 · Scene ${widget.data.index??''} - ${widget.data.sceneTitle??""}",
      width: 1600.wMin,
      child: SizedBox(
        width: double.infinity,
        height: 950.wMin,
        child: Column(
          children: [
            Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
                child: Column(
                  children: [
                    
                    _buildPromptWidget(),
              
                    SizedBox(height: 10.wMin),
              
                    _buildReferenceImageWidget(),

                    _buildNotWidget(),
                
                  ],
                ),
              ),
            ),
            Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
            SizedBox(height: 10.wMin),
            _buildButtonsWidget(),
            SizedBox(height: 10.wMin),
          ],
        ),
      ),
    );
  }

  Widget _buildNotWidget(){
    if(promptId != null) return Container();

    return Container(
      margin: EdgeInsets.only(top: 150.wMin),
      child: NotDataWidget(
        message: "请先生成提示词",
        other: SizedBox(
          width: 300.wMin,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaVisualProjectStoryboardSheetPromptGenerate],
            margin: EdgeInsets.only(right: 24.wMin),
            child: ButtonWidget(
              text: "生成提示词",
              padding: EdgeInsets.symmetric(horizontal: 48.wMin, vertical: 8.wMin),
              borderRadius: 8.wMin,
              sclae: 1.03,
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
              fontColor: AppTheme.cSurfaceBrand.color,
              fontSize: 20.wMin,
              onTap: OptimizeUtils.noneThrottle(() {
                generatePrompt();
              }, 300),
            ),
          ),
        ),
      ),
    );

  }

  Widget _buildPromptWidget(){
    if(promptId == null) return Container();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        children: [

          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
            child: Row(
              children: [
                Text(
                  "Prompt文本",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                const Spacer(),
                ButtonWidget(
                  text: "复制提示词",
                  height: 40.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                  color: Colors.transparent,
                  borderRadius: 6.wMin,
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderTertiary.color),
                  fontColor: AppTheme.cTextPrimary.color,
                  fontSize: 18.wMin,
                  sclae: 1.03,
                  onTap: (){
                    if(promptEntity.prompt == null) return ToastUtils.showToast(text: "提示词为空，复制失败");
                    Clipboard.setData(ClipboardData(text: promptEntity.prompt??""));
                    ToastUtils.showToast(text: "复制成功", type: ToastType.success);
                  },
                ),
                SizedBox(width: 16.wMin),
                Visibility(
                  visible: !isEditPrompt,
                  child: ButtonWidget(
                    text: "修改提示词",
                    height: 40.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    color: Colors.transparent,
                    borderRadius: 6.wMin,
                    border: Border.all(width: 1.wMin, color: AppTheme.cBorderTertiary.color),
                    fontColor: AppTheme.cTextPrimary.color,
                    fontSize: 18.wMin,
                    sclae: 1.03,
                    onTap: (){
                      isEditPrompt = true;
                      if(mounted) setState(() {});
                    },
                  ),
                ),
                Visibility(
                  visible: isEditPrompt,
                  child: ButtonWidget(
                    text: "保存提示词",
                    height: 40.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
                    borderRadius: 6.wMin,
                    border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSuccess.color),
                    fontColor: AppTheme.cSurfaceSuccess.color,
                    fontSize: 18.wMin,
                    sclae: 1.03,
                    onTap: (){
                      savePrompt();
                    },
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            child: ManageZhenduInputHeightWidget(
              hintText: "输入Prompt文本",
              height: 420.wMin,
              maxLines: 20,
              controller: promptInput,
              readOnly: !isEditPrompt,
              fillColor: !isEditPrompt ? Colors.transparent : AppTheme.cSurfaceTertiary.color,
              borderColor: !isEditPrompt ? Colors.transparent : AppTheme.cBorderSecondary.color,
            ),
          ),
          
          SizedBox(height: 10.wMin),

        ],
      ),
    );
  }

  /// 参考图片
  Widget _buildReferenceImageWidget(){
    if(promptId == null) return Container();
    List<ManageVisualProjectPromptEntityReferenceImages?> referenceImages = promptEntity.referenceImages??[];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
            child: Row(
              children: [
                Text(
                  "参考图片 (${referenceImages.length})",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                const Spacer(),
                ButtonWidget(
                  text: "打包下载 · ${getSceneName()}.zip",
                  height: 40.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                  color: Colors.transparent,
                  borderRadius: 6.wMin,
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderBrand.color),
                  fontColor: AppTheme.cTextBrand.color,
                  fontSize: 18.wMin,
                  sclae: 1.01,
                  onTap: (){
                    downloadPromptImages();
                  },
                ),
              ],
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(
              left: 16.wMin,
              right: 16.wMin,
              top: 10.wMin,
              bottom: 10.wMin,
            ),
            child: IntrinsicHeight(
              child: Row(
                spacing: 16.wMin,
                children: List.generate(referenceImages.length, (index){
                  return _buildReferenceImageItemWidget(referenceImages[index]);
                }),
              ),
            ),
          ),

        ],
      ),
    );
  }


  Widget _buildReferenceImageItemWidget(ManageVisualProjectPromptEntityReferenceImages? data){
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.wMin),
      child: Container(
        width: 200.wMin,
        color: AppTheme.cSurfaceSecondary.color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            SizedBox(
              width: 200.wMin,
              height: 200.wMin,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: TapScaleWidget(
                      onTap: () {
                        if(data?.url == null) return;
                        ShowBigResourceDialog.showImage(context: context, imageUrls: [data!.url!]);
                      },
                      sclae: 1,
                      child: CachedImageWidget(
                        data?.url??"",
                        fit: BoxFit.cover,
                        placeholder: buildEmptyWidget(),
                        errorWidget: buildEmptyWidget(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 4.wMin,
                    top: 4.wMin,
                    child: ManageTagFS16Widget(
                      tag: "ref_${data?.refNo??''}",
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 10.wMin),
              child: Text(
                getImageName(data),
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
            ),
      
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaVisualProjectStoryboardSheetPromptGenerate],
          margin: EdgeInsets.only(right: 24.wMin),
          child: ButtonWidget(
            text: "生成提示词",
            padding: EdgeInsets.symmetric(horizontal: 48.wMin, vertical: 8.wMin),
            borderRadius: 8.wMin,
            sclae: 1.03,
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
            border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
            fontColor: AppTheme.cSurfaceBrand.color,
            fontSize: 20.wMin,
            onTap: OptimizeUtils.noneThrottle(() {
              generatePrompt();
            }, 300),
          ),
        ),

        ButtonWidget(
          text: "关闭",
          padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 8.wMin),
          onTap: () => Get.back(),
          borderRadius: 8.wMin,
          sclae: 1.05,
          color: Colors.transparent,
          border: Border.all(width: 2.wMin, color: AppTheme.cBorderPrimary.color),
          fontColor: AppTheme.cTextSecondary.color,
          fontSize: 20.wMin,
        ),

      ],
    );
  }

}
