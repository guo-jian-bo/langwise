import 'package:data_table_2/data_table_2.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/knowledge.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../utils/utils.dart';

class ManageKnowledgeCreateHistoryController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageKnowledgeCreateHistoryController({required this.tag});

  String? contentType;

  // table控制器
  AsyncDataTableSource? tableController;

  @override
  String get breadcrumbRoute => Routes.MANAGE_KNOWLEDGE_CREATE_HISTORY;
  
  @override
  String get breadcrumbTitle => '添加记录';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      contentType = Get.arguments['contentType'];
    }
  }


  /// 查询添加记录
  Future<DesertsFakeWebServiceResponse<KnowledgeCreateHistoryEntity>> getCreateHistory(int offset, int limit) async {
    if(contentType == null) {
      return DesertsFakeWebServiceResponse<KnowledgeCreateHistoryEntity>(0, []);
    }
    Map<String, dynamic> parameters = {
      "offset": offset,
      "limit": limit,
    };
    Map<String, dynamic> reqData = {
      'contentType': contentType,
    };
    ListResponseEntity<KnowledgeCreateHistoryEntity>? res = await KnowledgeUtil.getKnowledgeCreateHistory(parameters, reqData);
    if(res == null) {
      return DesertsFakeWebServiceResponse<KnowledgeCreateHistoryEntity>(0, []);
    }
    return DesertsFakeWebServiceResponse<KnowledgeCreateHistoryEntity>(res.count!, res.datas??[]);
  }

  void onSetDataSourceAsync(AsyncDataTableSource source){
    tableController = source;
  }


  /// 点击uid返回上级页面
  void onUidClick(int? uid) {
    if(uid == null) return;
    Get.back(result: uid);
  }
  


  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
