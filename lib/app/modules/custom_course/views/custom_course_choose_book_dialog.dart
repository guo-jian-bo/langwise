import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/custom_course_book_entity.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class CustomCourseChooseBookDialog {
  static Future<CustomCourseBookEntity?> show({
    required BuildContext context,
    required CustomCourseBookListEntity bookList,
  }) async {
    return await showCupertinoDialog<CustomCourseBookEntity?>(
      context: context,
      builder: (context) => CustomCourseChooseBookDialogWidget(
        bookList: bookList,
      ),
    );
  }
}

class CustomCourseChooseBookDialogWidget extends StatefulWidget {
  final CustomCourseBookListEntity bookList;
  const CustomCourseChooseBookDialogWidget({super.key, required this.bookList});

  @override
  State<CustomCourseChooseBookDialogWidget> createState() => _CustomCourseChooseBookDialogWidgetState();
}

class _CustomCourseChooseBookDialogWidgetState extends State<CustomCourseChooseBookDialogWidget> {
  int selectedBookIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.ww, vertical: 30.wh),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            color: AppTheme.cBgTertiary,
          ),
          width: 700.ww,
          height: 650.wh,
          child: Padding(
            padding: EdgeInsets.all(15.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '发现多本教材',
                    style: TextStyle(
                      fontSize: 36.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 50.wMin),
                Text(
                  "该ISBN码对应了以下教材，请选择您正在使用的一本。",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 40.wMin),
                Expanded(
                  child: ListView.separated(
                    itemCount: widget.bookList.list?.length ?? 0,
                    separatorBuilder: (context, index) => SizedBox(height: 20.wMin),
                    itemBuilder: (context, index) => buildBookItem(widget.bookList.list?[index] ?? CustomCourseBookEntity(), index),
                  ),
                ),
                SizedBox(height: 50.wMin),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          height: 72.wMin,
                          decoration: BoxDecoration(
                            color: AppTheme.cBgQuaternary,
                            borderRadius: BorderRadius.circular(12.wMin),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.0.wMin),
                          child: Center(
                            child: Text(
                              "取消",
                              style: TextStyle(
                                fontSize: 24.wMin,
                                color: AppTheme.cTextSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.wMin),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (selectedBookIndex != -1) {
                            Get.back(
                              result: widget.bookList.list?[selectedBookIndex],
                            );
                          }
                        },
                        child: Container(
                          height: 72.wMin,
                          decoration: BoxDecoration(
                            color: AppTheme.cBgBrand,
                            borderRadius: BorderRadius.circular(12.wMin),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.0.wMin),
                          child: Center(
                            child: Text(
                              "确认这本，继续添加",
                              style: TextStyle(
                                fontSize: 24.wMin,
                                color: AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBookItem(CustomCourseBookEntity book, int index) {
    return GestureDetector(
      onTap: () {
        selectedBookIndex = index;
        setState(() {});
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 10.0.wMin),
        child: Row(
          children: [
            SizedBox(
              width: 550.ww,
              child: Text(
                book.title ?? '',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Spacer(),
            SvgPicture.asset(
              selectedBookIndex == index ? Assets.publicIconRadio : Assets.publicIconRadioUn,
              width: 32.wMin,
              colorFilter: selectedBookIndex == index ? const ColorFilter.mode(AppTheme.cBgBrand, BlendMode.srcIn) : null,
            ),
          ],
        ),
      ),
    );
  }
}
