import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';

class LearningPointDetailsController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  LearningPointDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.LEARNING_POINT_DETAILS;

  @override
  String get breadcrumbTitle => "交易明细";

  final RxList<TransactionDetailsEntityTransactions> transactionList = <TransactionDetailsEntityTransactions>[].obs;
  final RxList<TransactionDetailsEntityExpireWrongs> expireWrongs = <TransactionDetailsEntityExpireWrongs>[].obs;
  
  int count = 0;
  int limit = 50;
  int offset = 0;
  bool isLoading = true;
  final ScrollController scrollController = ScrollController();

  final RxString tabbarStatus = "all".obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    refreshListData();
    scrollController.addListener((){
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100 && !scrollController.position.outOfRange) {
        if(transactionList.length < count && !isLoading) {
          isLoading = true;
          offset += limit;
          getDetilList();
        }
      }
    });
  }

  void changeTabbar(String status){
    tabbarStatus.value = status;
    offset = 0;
    refreshListData();
  }

  Future<void> refreshListData() async{
    offset = 0;
    count = 0;
    isLoading = false;
    transactionList.clear();
    await getDetilList();
  }

  Future<void> getDetilList() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqParameters = {
        "limit": limit,
        "offset": offset,
        "status": tabbarStatus.value,
      };
      TransactionDetailsEntity? res = await PayRequest.getTransactionDetails(reqParameters);
      if(res == null) return;
      count = res.count??0;
      List<TransactionDetailsEntityTransactions?> list = res.transactions??[];
      for(int i = 0; i < list.length; i++){
        if(list[i] == null) continue;
        transactionList.add(list[i]!);
      }
      
      if(expireWrongs.isEmpty){
        List<TransactionDetailsEntityExpireWrongs?> expires = res.expireWrongs??[];
        expireWrongs.clear();
        for(int i = 0; i < expires.length; i++){
          if(expires[i] == null) continue;
          expireWrongs.add(expires[i]!);
        }
      }
      
      
      isLoading = false;
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 跳转
  Future<void> jumpTo(BuildContext context, TransactionDetailsEntityTransactions data) async{
    bool student = await LockUtils.checkStudent(context);
    if(!student) return;
    if(data.jump == null) return;
    PushMessageEntity entity = PushMessageEntity(
      jump: data.jump,
      category: JumpPageUtils.userType,
    );
    JumpPageUtils.jumpPage(entity);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

}
