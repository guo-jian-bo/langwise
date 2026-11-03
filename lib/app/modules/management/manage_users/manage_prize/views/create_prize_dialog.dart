import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/prize.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';


class CreatePrizeDialog {
  static Future<String> show(BuildContext context) async {
    String? res = await showCupertinoDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CreatePrizeDialogWidget();
      },
    );
    return res ?? '';
  }
}

class CreatePrizeDialogWidget extends StatefulWidget {
  const CreatePrizeDialogWidget({Key? key}) : super(key: key);

  @override
  State<CreatePrizeDialogWidget> createState() => _CreatePrizeDialogWidgetState();
}

class _CreatePrizeDialogWidgetState extends State<CreatePrizeDialogWidget> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  PrizeType prizeType = PrizeType.CREDIT;
  DurationType durationType = DurationType.DAY;
  bool isReturnVal = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.cOverlayBackground,
        resizeToAvoidBottomInset: true,
        body: Center(
            child: Container(
          width: 480.wMin,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.wMin), border: Border.all(color: Color(0xFF444B5F)), color: Color(0xFF22293C)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.wMin),
              Row(children: [
                SizedBox(width: 16.wMin),
                Text('创建任务奖励', style: TextStyle(color: Color(0xFFEBEEF3), fontSize: 20.wMin, fontWeight: FontWeight.w500)),
                Spacer(),
                GestureDetector(onTap: () => Get.back(), child: SvgPicture.asset('assets/svg/public/x.svg', width: 24.wMin, height: 24.wMin)),
                SizedBox(width: 16.wMin),
              ]),
              SizedBox(height: 18.wMin),
              Container(
                height: 0.5.wMin,
                color: Color(0xFF4B5268),
              ),
              Padding(
                padding: EdgeInsets.all(16.wMin),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16.wMin,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('奖励名称', style: TextStyle(color: Color(0xFFEBEEF3), fontSize: 16.wMin, fontWeight: FontWeight.w400)),
                            Text("*", style: TextStyle(fontSize: 14.wMin, color: Color(0xFFFF2D46))),
                          ],
                        ),
                        SizedBox(height: 6.wMin),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.wMin),
                            border: Border.all(color: Color(0xFF4B5268)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 14.wMin),
                          child: TextField(
                              controller: nameController,
                              style: TextStyle(fontSize: 14.wMin, color: Colors.white),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                hintText: '请输入奖励名称',
                                hintStyle: TextStyle(color: Color(0x66FFFFFF), fontSize: 14.wMin),
                              )),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('奖励描述', style: TextStyle(color: const Color(0xFFEBEEF3), fontSize: 16.wMin, fontWeight: FontWeight.w400)),
                        SizedBox(height: 6.wMin),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.wMin),
                            border: Border.all(color: const Color(0xFF4B5268)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 14.wMin),
                          child: TextField(
                              controller: descriptionController,
                              style: TextStyle(fontSize: 14.wMin, color: Colors.white),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                hintText: '请输入奖励描述',
                                hintStyle: TextStyle(color: const Color(0x66FFFFFF), fontSize: 14.wMin),
                              )),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('奖励类型', style: TextStyle(color: Color(0xFFEBEEF3), fontSize: 16.wMin, fontWeight: FontWeight.w400)),
                          ],
                        ),
                        SizedBox(height: 6.wMin),
                        DropdownMenu(
                            width: 448.wMin,
                            inputDecorationTheme: InputDecorationTheme(
                                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF4B5268))),
                                border: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF4B5268))),
                                contentPadding: EdgeInsets.symmetric(horizontal: 11.wMin),
                                isDense: true),
                            textStyle: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w400),
                            dropdownMenuEntries: PrizeType.values.map<DropdownMenuEntry<PrizeType>>((e) {
                              return DropdownMenuEntry(value: e, label: e.name);
                            }).toList(),
                            onSelected: (val) {
                              setState(() {
                                prizeType = val!;
                                isReturnVal = PrizeType.isReturnVal(val.value);
                              });
                            },
                            initialSelection: prizeType)
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('奖励数值', style: TextStyle(color: Color(0xFFEBEEF3), fontSize: 16.wMin, fontWeight: FontWeight.w400)),
                            Text("*", style: TextStyle(fontSize: 14.wMin, color: Color(0xFFFF2D46))),
                          ],
                        ),
                        SizedBox(height: 6.wMin),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.wMin),
                            border: Border.all(color: Color(0xFF4B5268)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 14.wMin),
                          child: TextField(
                              controller: valueController,
                              style: TextStyle(fontSize: 14.wMin, color: Colors.white),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                hintText: '请输入整数值',
                                hintStyle: TextStyle(color: Color(0x66FFFFFF), fontSize: 14.wMin),
                              )),
                        )
                      ],
                    ),
                    if (!isReturnVal)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('奖励单位', style: TextStyle(color: Color(0xFFEBEEF3), fontSize: 16.wMin, fontWeight: FontWeight.w400)),
                            ],
                          ),
                          SizedBox(height: 6.wMin),
                          DropdownMenu(
                              width: 448.wMin,
                              inputDecorationTheme: InputDecorationTheme(
                                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF4B5268))),
                                  border: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF4B5268))),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 11.wMin),
                                  isDense: true),
                              textStyle: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w400),
                              dropdownMenuEntries: DurationType.values.map<DropdownMenuEntry<DurationType>>((e) {
                                return DropdownMenuEntry(value: e, label: e.name);
                              }).toList(),
                              onSelected: (value) {
                                setState(() {
                                  durationType = value!;
                                });
                              },
                              initialSelection: durationType)
                        ],
                      )
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(16.wMin),
                  child: Row(children: [
                    Expanded(
                        child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                          height: 40.wMin,
                          child: Text('取消', style: TextStyle(color: Colors.white, fontSize: 14.wMin, fontWeight: FontWeight.w400)),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.wMin), color: Color(0xFF353E5C))),
                    )),
                    SizedBox(width: 32.wMin),
                    Expanded(
                        child: GestureDetector(
                      onTap: () => createPrize(),
                      child: Container(
                          height: 40.wMin,
                          child: Text('创建奖励', style: TextStyle(color: Colors.white, fontSize: 14.wMin, fontWeight: FontWeight.w400)),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.wMin), color: Color(0xFF2388FF))),
                    ))
                  ]))
            ],
          ),
        )));
  }

  void createPrize() {
    if (nameController.text.isEmpty) {
      ToastUtils.showToast(text: '请输入奖励名称');
      return;
    }
    if (valueController.text.isEmpty) {
      ToastUtils.showToast(text: '请输入奖励数值');
      return;
    }
    // controller.createPrize(
    //     name: nameController.text, description: descriptionController.text, type: prizeType.value, value: int.parse(valueController.text), duration: int.parse(valueController.text), durationType: durationType.value);
  }
}
