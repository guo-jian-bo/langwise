import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker_plus/picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/date_time_picker_widget.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import 'package:langwise/common/widgets/guide_engine/guide_manager.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/entities/location.dart';
import '../../../../common/https/https.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/oss_upload_file_utils/oss_update_response_entity.dart';
import '../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../../utils/utils.dart';

class CreateStudentDialog {
  static Future<bool> show(
    BuildContext context, {
    UserTeamEntityMembers? editData,
    bool? showCancel,
    int? traineeId,
  }) async {
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CreateStudentDialogWidget(editData: editData, showCancel: showCancel, traineeId: traineeId);
      },
    );
    return res ?? false;
  }
}

class CreateStudentDialogWidget extends StatefulWidget {
  final int? traineeId;
  final UserTeamEntityMembers? editData;
  final bool? showCancel;
  const CreateStudentDialogWidget({super.key, this.traineeId, this.editData, this.showCancel = true});

  @override
  State<CreateStudentDialogWidget> createState() => _CreateStudentDialogWidgetState();
}

class _CreateStudentDialogWidgetState extends State<CreateStudentDialogWidget> {
  final TextEditingController nameController = TextEditingController();
  String birthday = "";

  int? selectYear;
  int? selectMonth;
  int? selectDay;

  String avatarFile = "";
  String avatarUrl = "";

  CityPickersData? cityPickersData;
  int? age;

  /// 年级选择索引
  int gradeIndex = -1;

  @override
  void initState() {
    super.initState();

    if (widget.editData != null) {
      nameController.text = widget.editData!.nickname ?? "";
      DateTime? birthdayDate = DateFormatUtil.tryParseDate(widget.editData!.birthday ?? "");
      if (birthdayDate != null) {
        birthday = DateFormatUtil.formatStr(birthdayDate, locale: Get.locale);
        age = calculateAge(birthdayDate);

        selectYear = birthdayDate.year;
        selectMonth = birthdayDate.month;
        selectDay = birthdayDate.day;
      }

      if (widget.editData!.avatarUrl != null) {
        avatarUrl = widget.editData!.avatarUrl!;
      }

      cityPickersData = CityPickersData(
        citys: widget.editData!.address ?? "",
        districtCode: widget.editData!.addressCode?.toString() ?? "",
      );

      if (widget.editData!.grade != null) {
        gradeIndex = StaticData.gradeList.indexWhere((element) => element.value == widget.editData!.grade);
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        getCurrentLocation(context);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  DateTime get _birthdayMinDate => DateTime(1900);
  DateTime get _birthdayMaxDate => DateTime.now();

  int _daysInMonth(int year, int month) {
    final DateTime firstDayNextMonth = (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    return firstDayNextMonth.subtract(const Duration(days: 1)).day;
  }

  Future<int?> _showIntPicker(
    BuildContext ctx, {
    required String title,
    required List<int> items,
    int? initialValue,
  }) async {
    if (items.isEmpty) return null;
    final int initIndex = (initialValue != null) ? items.indexOf(initialValue) : -1;
    int selectedIndex = (initIndex >= 0) ? initIndex : 0;

    return await showCupertinoDialog<int?>(
      context: ctx,
      builder: (context) {
        return DateTimePickerBox(
          title: title,
          child: SizedBox(
            height: 300.wMin,
            child: Picker(
              height: 300.wMin,
              itemExtent: 60.wMin,
              hideHeader: true,
              looping: false,
              containerColor: Colors.transparent,
              onBuilderItem: (context, text, child, selected, col, index) {
                final style = selected
                    ? TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w400,
                      )
                    : TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextQuaternary,
                        fontWeight: FontWeight.w400,
                      );

                return Center(
                  child: DefaultTextStyle.merge(
                    style: style,
                    textAlign: TextAlign.center,
                    child: child ?? Text(text ?? ''),
                  ),
                );
              },
              adapter: PickerDataAdapter<int>(
                data: items
                    .map(
                      (e) => PickerItem<int>(
                        text: Text(e.toString(), textAlign: TextAlign.center),
                        value: e,
                      ),
                    )
                    .toList(),
              ),
              selecteds: [selectedIndex],
              onSelect: (picker, index, selected) {
                selectedIndex = selected.isNotEmpty ? selected.first : 0;
              },
            ).makePicker(),
          ),
          onTap: () {
            Get.back(result: items[selectedIndex]);
          },
        );
      },
    );
  }

  Future<void> _selectBirthdayYear(BuildContext ctx) async {
    final DateTime min = _birthdayMinDate;
    final DateTime max = _birthdayMaxDate;

    final List<int> years = List<int>.generate(max.year - min.year + 1, (i) => min.year + i);
    final int? y = await _showIntPicker(
      ctx,
      title: "选择年份",
      items: years,
      initialValue: selectYear ?? DateFormatUtil.tryParseDate(birthday)?.year ?? DateTime.now().year,
    );
    if (y == null) return;

    setState(() {
      selectYear = y;
      selectMonth = null;
      selectDay = null;
      birthday = '';
      age = null;
      gradeIndex = -1;
    });
  }

  Future<void> _selectBirthdayMonth(BuildContext ctx) async {
    if (selectYear == null) {
      ToastUtils.showToast(text: "请先选择年份");
      return;
    }

    final DateTime min = _birthdayMinDate;
    final DateTime max = _birthdayMaxDate;

    final int year = selectYear!;
    final int startMonth = (year == min.year) ? min.month : 1;
    final int endMonth = (year == max.year) ? max.month : 12;
    final List<int> months = List<int>.generate(endMonth - startMonth + 1, (i) => startMonth + i);

    final int? m = await _showIntPicker(
      ctx,
      title: "选择月份",
      items: months,
      initialValue: selectMonth,
    );
    if (m == null) return;

    setState(() {
      selectMonth = m;
      selectDay = null;
      birthday = '';
      age = null;
      gradeIndex = -1;
    });
  }

  Future<void> _selectBirthdayDay(BuildContext ctx) async {
    if (selectYear == null) {
      ToastUtils.showToast(text: "请先选择年份");
      return;
    }
    if (selectMonth == null) {
      ToastUtils.showToast(text: "请先选择月份");
      return;
    }

    final DateTime min = _birthdayMinDate;
    final DateTime max = _birthdayMaxDate;

    final int year = selectYear!;
    final int month = selectMonth!;
    final int monthDays = _daysInMonth(year, month);

    int startDay = 1;
    int endDay = monthDays;

    if (year == min.year && month == min.month) {
      startDay = min.day;
    }
    if (year == max.year && month == max.month) {
      endDay = max.day;
    }
    if (startDay > endDay) {
      ToastUtils.showToast(text: "该月份不可选");
      return;
    }

    final List<int> days = List<int>.generate(endDay - startDay + 1, (i) => startDay + i);
    final int? d = await _showIntPicker(
      ctx,
      title: "选择日期",
      items: days,
      initialValue: selectDay,
    );
    if (d == null) return;

    final DateTime picked = DateTime(year, month, d);
    if (picked.isBefore(min) || picked.isAfter(max)) {
      ToastUtils.showToast(text: "日期超出范围");
      return;
    }

    setState(() {
      selectDay = d;
      birthday = DateFormatUtil.formatStr(picked, locale: Get.locale);
      age = calculateAge(picked);
      gradeIndex = calculateGrade();
    });
  }

  ///获取位置
  Future<void> getCurrentLocation(BuildContext context) async {
    bool isLocationPermission = await PermissionUtils.location(context);
    if (!isLocationPermission) return;

    try {
      // 获取当前经纬度
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.lowest,
        ),
      );
      //根据经纬度获取城市编码
      Map<String, dynamic> reqData = {
        "longitude": position.longitude,
        "latitude": position.latitude,
      };
      LocationResponseEntity? cityCode = await CustomizedCoursesRequest.getCityCode(reqData);
      if (cityCode == null) return;
      cityPickersData = CityPickersData(
        citys: cityCode.district ?? "",
        districtCode: cityCode.addressCode,
      );
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> selectBirthday(BuildContext ctx) async {
    DateTimePickerUtils.showDateCalender(
      context: ctx,
      initialDate: DateFormatUtil.tryParseDate(birthday),
      minDate: DateTime(1900),
      maxDate: DateTime.now(),
      onTap: (date) {
        setState(() {
          birthday = DateFormatUtil.formatStr(date, locale: Get.locale);
          age = calculateAge(date);
          gradeIndex = calculateGrade();
        });
      },
    );
  }

  /// * 计算年级
  /// * 年龄小于7岁 = 学龄前
  /// * 一年级 到 高三
  /// * 年龄大于18岁 = 成人
  /// * 考虑上半年和下半年 7周岁上半年出生的一年级
  /// * 按照9月一号划分，如果下半年出生的实际上是不满7周岁的
  int calculateGrade() {
    if (birthday.isEmpty) return -1;
    DateTime? birthdayDate = DateFormatUtil.tryParseDate(birthday);
    if (birthdayDate == null) return -1;

    // 映射到静态年级列表并提示（便于验证）
    final List<StaticDataEntity> gradeList = StaticData.gradeList;

    // 当前学年（参考日期默认为现在）
    final DateTime now = DateTime.now();
    final int currentAcademicYear = now.month >= 9 ? now.year : now.year - 1;
    final DateTime currentSep1 = DateTime(currentAcademicYear, 9, 1);

    // 计算当前学年9月1日的周岁年龄
    int ageOnCurrentSep1 = currentSep1.year - birthdayDate.year;
    final DateTime birthdayInCurrentYear = DateTime(currentSep1.year, birthdayDate.month, birthdayDate.day);
    if (birthdayInCurrentYear.isAfter(currentSep1)) {
      ageOnCurrentSep1--;
    }

    // 学龄前与成人判断
    StaticDataEntity gradeValue;
    if (ageOnCurrentSep1 < 6) {
      gradeValue = gradeList.first; // 学龄前
    } else if (ageOnCurrentSep1 >= 18) {
      gradeValue = gradeList.last; // 成人
    } else {
      // 入学学年（在入学学年的9月1日必须满6周岁）
      final bool birthdayOnOrBeforeSep1 = (birthdayDate.month < 9) || (birthdayDate.month == 9 && birthdayDate.day <= 1);
      final int entranceAcademicYear = birthdayDate.year + (birthdayOnOrBeforeSep1 ? 6 : 7);

      // 当前年级 = (当前学年 - 入学学年) + 1
      final int gradeNumber = (currentAcademicYear - entranceAcademicYear) + 1;

      if (gradeNumber < 1) {
        gradeValue = gradeList.first; // 未到入学学年 -> 学龄前
      } else if (gradeNumber > 12) {
        gradeValue = gradeList.last; // 超过高三 -> 成人
      } else {
        gradeValue = gradeList.firstWhere((e) => e.value == gradeNumber.toString()); // 1..12
      }
    }

    final StaticDataEntity? result = gradeList.firstWhereOrNull((e) => e.value == gradeValue.value);
    if (result != null) {
      gradeIndex = gradeList.indexOf(result);
      return gradeIndex;
    }
    return -1;
  }

  int calculateAge(DateTime birthDate) {
    final now = DateTime.now();

    int age = now.year - birthDate.year;

    // 如果还没过生日，减去一岁
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  Future<void> selectAvatar(BuildContext context) async {
    File? file = await ImagePickerUtils.selectPicture(
      context: context,
      withCircleUi: true,
    );

    // File? file = await ImagePickerUtils.pickImage(context);
    if (file == null) return;
    setState(() {
      avatarFile = file.path;
    });
  }

  Future<void> createTeamMember() async {
    if (nameController.text.isEmpty) {
      ToastUtils.showToast(text: "请输入学员姓名");
      return;
    }
    if (birthday.isEmpty) {
      ToastUtils.showToast(text: "请选择出生日期");
      return;
    }
    if (gradeIndex == -1) {
      ToastUtils.showToast(text: "请选择年级");
      return;
    }
    if (cityPickersData == null || cityPickersData!.districtCode.isEmpty) {
      ToastUtils.showToast(text: "请选择所在地区");
      return;
    }
    if (avatarFile.isEmpty && avatarUrl.isEmpty) {
      ToastUtils.showToast(text: "请选择头像");
      return;
    }
    try {
      ToastUtils.showLoading();
      OssUpdateResponseEntity? uploadRes;
      if (avatarFile.isNotEmpty) {
        uploadRes = await OssUploadFileUtils.uploadUserFile(filePath: avatarFile);
        if (uploadRes == null) {
          ToastUtils.showToast(text: "上传头像失败");
          return;
        }
      }

      Map<String, dynamic> data = {
        "traineeId": widget.traineeId,
        "nickname": nameController.text,
        "birthday": birthday,
        "avatar": uploadRes?.key,
        "addressCode": cityPickersData?.districtCode,
        "address": cityPickersData?.citys,
        "grade": StaticData.gradeList[gradeIndex].value,
      };
      bool res = false;
      if (widget.editData != null && widget.editData?.memberId != null) {
        res = await UserRequest.editTeamStudent(data, widget.editData!.memberId!);
      } else {
        res = await UserRequest.createTeamMember(data);
      }

      if (!res) return;
      Get.back(result: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 退出登录
  Future<void> signOut(BuildContext context) async {
    bool askRes = await AskDialog.showUserAsk(context: context, title: "温馨提示", content: "您确定要退出此账号吗？");
    if (!askRes) return;
    try {
      ToastUtils.showLoading();
      await UserStore.to.onLogout("");
      GuideManager.instance.clearTask();
      UmengUtils.signOut();
    } finally {
      ToastUtils.hideLoading();
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    Widget headWidget = Center(
      child: SvgPicture.asset(
        "assets/svg/public/icon_user.svg",
        width: 120.wMin,
        height: 120.wMin,
      ),
    );
    if (avatarFile != "") {
      headWidget = Image.file(
        File(avatarFile),
        fit: BoxFit.cover,
      );
    } else if (avatarUrl.isNotEmpty) {
      headWidget = CachedImageWidget(
        avatarUrl,
        errorWidget: Center(
          child: SvgPicture.asset(
            "assets/svg/public/icon_user.svg",
            width: 120.wMin,
            height: 120.wMin,
          ),
        ),
      );
    }

    return Material(
      color: AppTheme.cOverlayBackground,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Center(
          child: Container(
            width: 1440.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16.wMin)),
                      gradient: const LinearGradient(colors: [
                        Color(0x4D38BDF8),
                        Color(0x0038BDF8),
                      ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  width: 1440.wMin,
                  height: 238.wMin,
                ),
                Padding(
                  padding: EdgeInsets.all(32.wMin),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.editData?.birthday == null ? "创建新学员档案" : "编辑学员档案",
                          style: TextStyle(
                            fontSize: 36.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.wMin),
                        Text('完善信息，开启专属学习计划',
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: AppTheme.cTextTertiary,
                              fontWeight: FontWeight.w400,
                            )),
                        SizedBox(height: 24.wMin),
                        Container(
                          width: 142.wMin,
                          height: 142.wMin,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 4.wMin, color: AppTheme.cBorderBrand),
                          ),
                          padding: EdgeInsets.all(11.wMin),
                          child: ClipOval(
                            child: headWidget,
                          ),
                        ),
                        SizedBox(height: 8.wMin),
                        GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              selectAvatar(context);
                            },
                            child: Text("更换头像",
                                style: TextStyle(
                                  fontSize: 22.wMin,
                                  color: AppTheme.cTextBrand,
                                  fontWeight: FontWeight.w600,
                                ))),
                        CardInputWidget(
                          title: "学员姓名",
                          hintText: "请输入学员姓名",
                          controller: nameController,
                          maxLength: 10,
                          onClean: () {
                            nameController.clear();
                          },
                        ),
                        SizedBox(height: 16.wMin),
                        Row(
                          spacing: 24.wMin,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 12.wMin),
                                    child: Text(
                                      "生日",
                                      style: TextStyle(
                                        fontSize: 24.wMin,
                                        color: AppTheme.cTextPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    spacing: 12.wMin,
                                    children: [
                                      Expanded(
                                        child: TapScaleWidget(
                                          sclae: 1.01,
                                          onTap: () {
                                            FocusScope.of(context).requestFocus(FocusNode());
                                            _selectBirthdayYear(context);
                                          },
                                          child: _buildItemWidget(
                                            "年",
                                            selectYear == null ? "" : "${selectYear}年",
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Opacity(
                                          opacity: selectYear == null ? 0.5 : 1,
                                          child: TapScaleWidget(
                                            sclae: 1.01,
                                            onTap: () {
                                              FocusScope.of(context).requestFocus(FocusNode());
                                              _selectBirthdayMonth(context);
                                            },
                                            child: _buildItemWidget(
                                              "月",
                                              selectMonth == null ? "" : "${selectMonth}月",
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Opacity(
                                          opacity: (selectYear == null || selectMonth == null) ? 0.5 : 1,
                                          child: TapScaleWidget(
                                            sclae: 1.01,
                                            onTap: () {
                                              FocusScope.of(context).requestFocus(FocusNode());
                                              _selectBirthdayDay(context);
                                            },
                                            child: _buildItemWidget(
                                              "日",
                                              selectDay == null ? "" : "${selectDay}日",
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '年龄',
                                    style: TextStyle(
                                      fontSize: 28.wMin,
                                      color: AppTheme.cTextSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4.wMin),
                                  Container(
                                      height: 72.wMin,
                                      width: double.infinity,
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                                      decoration: BoxDecoration(
                                        color: AppTheme.cSurfaceTertiary.color,
                                        borderRadius: BorderRadius.circular(12.wMin),
                                        border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
                                      ),
                                      child: Text(
                                        age == null ? "自动计算" : "$age岁",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 28.wMin,
                                          color: age == null ? AppTheme.cTextQuaternary : AppTheme.cTextPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ))
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 12.wMin),
                                    child: Text(
                                      "年级",
                                      style: TextStyle(
                                        fontSize: 24.wMin,
                                        color: AppTheme.cTextPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  IconDropdownCheckWidget(
                                    items: StaticData.gradeList
                                        .map((e) => IconDropdownCheckData(
                                              title: e.name,
                                              value: e.value,
                                            ))
                                        .toList(),
                                    sclae: 1.01,
                                    selectIndex: gradeIndex,
                                    child: _buildItemWidget(
                                      "请选择年级",
                                      gradeIndex == -1 ? "" : StaticData.gradeList[gradeIndex].name,
                                    ),
                                    onTap: (data, index) async {
                                      if (birthday.isEmpty || age == null) {
                                        gradeIndex = index;
                                      } else {
                                        if (calculateGrade() != index) {
                                          var res = await AskDialog.showUserAsk(context: Get.context!, 
                                          define: '确认无误',
                                          cancel: '返回修改',
                                          title: '温馨提示', content: '系统检测到学员年龄与所选年级跨度较大，是否确认无误？');
                                          if (res) {
                                            gradeIndex = index;
                                          } else {
                                            return;
                                          }
                                        }
                                      }
                                      if (mounted) setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.wMin),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "孩子上学地区",
                              style: TextStyle(
                                fontSize: 28.wMin,
                                color: AppTheme.cTextSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.wMin),
                            CityCascadePickerWidget(
                              initDistrictCode: cityPickersData?.districtCode,
                              onConfirm: (data) {
                                FocusScope.of(context).requestFocus(FocusNode());
                                cityPickersData = data;
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 32.wMin),
                        GuideAnchor(
                          id: 'save_btn',
                          route: Routes.USER_CENTER,
                          child: ButtonWidget(
                            text: "${widget.editData?.birthday == null ? '创建' : '保存'}学员档案",
                            height: 56.wMin,
                            borderRadius: 8.wMin,
                            color: AppTheme.cSurfaceBrand.color,
                            fontColor: AppTheme.cStaticWhite,
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w500,
                            sclae: 1.02,
                            onTap: () {
                              createTeamMember();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.editData?.birthday != null || (widget.traineeId != null && widget.traineeId != 0))
                  Positioned(
                      right: 20.wMin,
                      top: 20.wMin,
                      child: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: SvgPicture.asset("assets/svg/public/x.svg", width: 32.wMin, height: 32.wMin))),
                if (widget.editData?.birthday == null && widget.traineeId == null)
                  Positioned(
                      left: 20.wMin,
                      top: 20.wMin,
                      child: GestureDetector(
                          onTap: () {
                            signOut(context);
                          },
                          child: Text(
                            '退出登录',
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: AppTheme.cTextPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          )))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemWidget(String hit, String value) {
    return Container(
      height: 72.wMin,
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTertiary.color,
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
      ),
      child: Row(
        children: [
          Visibility(
            visible: value.isEmpty,
            child: Expanded(
              child: Text(
                hit,
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Visibility(
            visible: value.isNotEmpty,
            child: Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SvgPicture.asset(
            "assets/svg/public/icon_arrow_down.svg",
            width: 32.wMin,
            height: 32.wMin,
          ),
        ],
      ),
    );
  }
}
