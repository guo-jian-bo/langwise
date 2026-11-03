import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/prize.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../common/commons.dart';
import '../bindings/manage_prize_binding.dart';
import '../controllers/manage_prize_controller.dart';
import 'create_prize_dialog.dart';

class ManagePrizeView extends GetView<ManagePrizeController> {
  final String tagText;
  const ManagePrizeView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_PRIZE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManagePrizeView(tagText: tag),
      binding: ManagePrizeBinding(tag: tag),
      routeName: Routes.MANAGE_PRIZE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      backgroundColor: const Color(0xFF050916),
      body: Padding(
        padding: EdgeInsets.all(24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('任务奖励',style: TextStyle(color: Color(0xFFEDF0F4), fontSize: 18.wMin, fontWeight: FontWeight.w400)),
            SizedBox(height: 16.wMin),
            Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    CreatePrizeDialog.show(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2388FF),
                      borderRadius: BorderRadius.circular(6.wMin),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10.wMin,vertical: 6.wMin),
                    child: Text(
                      '创建奖励',
                      style: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.wMin),
            Expanded(
                child: Obx(
              () => GridView.builder(
                  itemCount: controller.prizeList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 509 / 234, mainAxisSpacing: 24.wMin, crossAxisSpacing: 24.wMin),
                  itemBuilder: (BuildContext context, int index) {
                    var prize = controller.prizeList[index];
                    var vText = "";
                    if (PrizeType.isReturnVal(prize.type.value)) {
                      vText = prize.value.toString();
                    } else {
                      vText = "${prize.duration} ${DurationType.fromString(prize.durationType).name}";
                    }
                    return Container(
                      padding: EdgeInsets.all(16.wMin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prize.name,
                                style: TextStyle(color: const Color(0xFFEBEFF5), fontSize: 20.wMin, fontWeight: FontWeight.w500),
                              ),
                              SvgPicture.asset('assets/svg/public/icon_delete.svg', width: 24.wMin, height: 24.wMin),
                            ],
                          ),
                          SizedBox(height: 4.wMin),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(4.wMin),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF23283D),
                                  borderRadius: BorderRadius.circular(4.wMin),
                                ),
                                child: Text(
                                  "UID:${prize.uid}",
                                  style: TextStyle(color: Color(0xFFBAC0CC), fontSize: 12.wMin, fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                          Container(decoration: const BoxDecoration(color:  Color(0xFF353E5C)),margin: EdgeInsets.symmetric(vertical: 8.wMin),height: 0.5.wMin,),
                          Text(
                            '奖励',
                            style: TextStyle(color: const Color(0xFFBAC0CC), fontSize: 14.wMin, fontWeight: FontWeight.w400),
                          ),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(
                                "${prize.type.name}",
                                style: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w400),
                              ),
                              Text(
                                vText,
                                style: TextStyle(color: Colors.white, fontSize: 20.wMin, fontWeight: FontWeight.w400),
                              ),
                            ]),
                          ),
                          Divider(height: 0.wMin,color: const Color(0xFF353E5C),thickness: 0.5.wMin),
                          SizedBox(height: 16.wMin),
                          Row(children: [
                            Text('创建时间:${DateFormatUtil.formatStr(prize.created,newPattern: 'yyyy-MM-dd')}',style: TextStyle(color: const Color(0xFFBAC0CC), fontSize: 14.wMin, fontWeight: FontWeight.w400),),
                            Spacer(),
                            GestureDetector(onTap: (){
                              //todo:查看详情
                            }, child: Container(width: 80.wMin,height: 40.wMin,alignment: Alignment.center,decoration: BoxDecoration(color: Colors.transparent,borderRadius: BorderRadius.circular(6.wMin),border: Border.all(color: const Color(0xFF353E5C), width: 0.5.wMin)),child: Text('详情',style: TextStyle(color: const Color(0xFFBAC0CC), fontSize: 14.wMin, fontWeight: FontWeight.w400),))),
                            SizedBox(width: 13.wMin),
                            GestureDetector(onTap: (){
                              //todo:编辑
                            }, child: Container(width: 80.wMin,height: 40.wMin,alignment: Alignment.center,decoration: BoxDecoration(color: Color(0xFF2388FF),borderRadius: BorderRadius.circular(6.wMin)),child: Text('编辑',style: TextStyle(color: Colors.white, fontSize: 14.wMin, fontWeight: FontWeight.w400),)))
                          ])
                          
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x8019213D),
                        borderRadius: BorderRadius.circular(12.wMin),
                        border: Border.all(color: const Color(0x4D444B5F), width: 0.5.wMin),
                      ),
                    );
                  }),
            )),
          ],
        ),
      ),
    );
  }
}
