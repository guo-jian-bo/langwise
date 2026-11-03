import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';

class ManageBookCreateController extends BaseController {
  /// 上传所有信息按钮
  bool get uploadButtonFlag => (isbnController.text.trim().isNotEmpty &&
      courseNameController.text.trim().isNotEmpty &&
      versionController.text.trim().isNotEmpty);

  /// 学习语言
  final RxInt importLearningLanguages = 0.obs;

  /// 选择文件的路径
  final RxString importFilePath = "".obs;

  /// 按钮
  final RxBool importButtonFlag = false.obs;

  // ------- 手动 -------
  /// 课程ID
  final TextEditingController courseIdController = TextEditingController();

  /// isbn
  final TextEditingController isbnController = TextEditingController(text: '');

  /// 次要isbn列表
  List<TextEditingController> isbnList = [];

  /// 书名-义务教育教科书（三年级下册）
  final TextEditingController courseNameController =
      TextEditingController(text: '');

  // 出版社
  final TextEditingController publishingHouseController =
      TextEditingController(text: '');

  // 作者-[中国] 人民教育出版社，（加拿大）灵通教育有限公司 编
  final TextEditingController authorController =
      TextEditingController(text: '');

  // 出版时间-2013-1
  final TextEditingController publishingDateController =
      TextEditingController(text: '');

  // 版次
  final TextEditingController versionController =
      TextEditingController(text: '');

  /// 学习语言
  final RxInt handMovementLearningLanguages = 0.obs;

  /// 封面
  final RxString handMovementCover = "".obs;

  /// 出版日期
  final Rx<DateTime> _publishingDate = DateTime.now().obs;

  set publishingDate(value) => _publishingDate.value = value;

  DateTime get publishingDate => _publishingDate.value;

  final RxInt _subjectIndex = (-1).obs;

  set subjectIndex(value) => _subjectIndex.value = value;

  int get subjectIndex => _subjectIndex.value;

  // 年级key
  final RxInt _gradeIndex = (-1).obs;

  set gradeIndex(value) => _gradeIndex.value = value;

  int get gradeIndex => _gradeIndex.value;

  // 学期key
  final RxInt _schoolTermIndex = (-1).obs;

  set schoolTermIndex(value) => _schoolTermIndex.value = value;

  int get schoolTermIndex => _schoolTermIndex.value;

  String? _coverKey;
  int? _pageCount;

  @override
  void onInit() {
    super.onInit();
    _onListener();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(['bottom_button']);
  }

  void _onListener() {
    isbnController.addListener(() {
      _initData();
    });
    courseNameController.addListener(() {
      _initData();
    });
    versionController.addListener(() {
      _initData();
    });
  }

  // 创建Book
  void onCreateBook() async {
    try {
      final String isbn = isbnController.text.trim();
      if (ObjectUtil.isEmpty(isbn)) {
        ToastUtils.showManageToast(text: "请填写ISBN");
        return;
      }

      for (var contro in isbnList) {
        if (ObjectUtil.isEmpty(contro.text)) {
          ToastUtils.showManageToast(text: "请填写补充ISBN");
          return;
        }
      }

      final String courseName = courseNameController.text.trim();
      final String publishingHouse = publishingHouseController.text.trim();
      final String author = authorController.text.trim();
      final String publishingDate = publishingDateController.text.trim();

      final String version = versionController.text.trim();
      if (ObjectUtil.isEmpty(version)) {
        ToastUtils.showManageToast(text: "请填写版次");
        return;
      }

      // 学科/年级/学期
      String? subject;
      int? grade, semester;
      try {
        subject = CommonUtil.subjectKeys[subjectIndex];
      } catch (e) {
        print('---学科e:$e---');
      }

      if (gradeIndex != -1) {
        grade = gradeIndex + 1;
      }

      if (schoolTermIndex != -1) {
        semester = schoolTermIndex + 1;
      }

      final BookRequestEntity requestEntity = BookRequestEntity(
          title: courseName,
          cover: _coverKey,
          isbn: isbn,
          isbns: isbnList.map((e) => e.text).toList(),
          publisher: publishingHouse,
          author: author,
          pubDate: publishingDate,
          subject: subject,
          grade: grade.toString(),
          semester: semester.toString(),
          type: 'TEXTBOOK',
          pageCount: _pageCount,
          version: version);
      var response = await BookUtil.create(
          config: RequestConfig(
              data: requestEntity.toJson(),
              requireToken: true,
              cancelToken: cancelToken));

      if (ObjectUtil.isEmpty(response.data)) {
        throw response.message ?? '创建教材信息失败';
      }

      Get.back(result: response.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(
          text: e.source.message ?? '创建教材信息失败', type: ManageToastType.error);
    } catch (e) {
      ToastUtils.showManageToast(text: '创建教材信息失败', type: ManageToastType.error);
    }
  }

  /// 添加ISBN
  void addISBN() {
    isbnList.add(TextEditingController(text: ''));
    update();
  }

  /// 删除ISBN
  void removeISBN(int index) {
    isbnList.removeAt(index);
    update();
  }

  // 设置日期
  void setPublishingDate(DateTime dateTime) {
    publishingDate = dateTime;
    publishingDateController.text = "${dateTime.year}-${dateTime.month}";
  }

  // 添加封面
  Future<String?> onAddCover(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (_) => Container(),
    );

    final String? path = await onPickFile(context: context);

    if (path == null) {
      Get.back();
      return null;
    }

    Get.back();

    onGetToken(path, callback: (String? key, int? size) {
      _coverKey = key;
      debugPrint('--key: $key--');
      // 更新UI
      _initData();
    });
    return path;
  }

  // 获取教材信息
  void onGetCourseInfo() async {
    try {
      final String isbn = isbnController.text.trim();
      if (ObjectUtil.isEmpty(isbn)) {
        ToastUtils.showManageToast(text: "请填写ISBN");
        return;
      }
      final response = await BookUtil.fetchIsbn(
          config: RequestConfig(
              parameters: {"isbn": isbn},
              requireToken: true,
              cancelToken: cancelToken));
      if (response.data != null) {
        courseNameController.text = response.data?.title ?? '';
        publishingHouseController.text = response.data?.publisher ?? '';
        publishingDateController.text = response.data?.pubDate ?? '';
        authorController.text = response.data?.author ?? '';
        isbnController.text = response.data?.isbn ?? '';
        _pageCount = response.data?.pageCount;
      } else {
        ToastUtils.showManageToast(text: response.message ?? '');
      }
    } catch (e) {
      print('获取教材信息error: $e');
      ToastUtils.showManageToast(text: "获取教材信息失败");
    }
  }

  // 学科title
  String get subjectTitle {
    String title = '';
    try {
      title = CommonUtil.subjectValues[subjectIndex];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    return title;
  }

  // 设置学科
  void setSubject(int index) {
    subjectIndex = index;
    handMovementLearningLanguages();
  }

  // 年级title
  String get gradeTitle {
    String title = '';
    try {
      title = CommonUtil.grades[gradeIndex];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    return title;
  }

  // 设置年级
  void setGrade(int index) {
    gradeIndex = index;
    handMovementLearningLanguages();
  }

  // 学期title
  String get schoolTermTitle {
    String title = '';
    try {
      title = CommonUtil.schoolTerms[schoolTermIndex];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    print(title);

    return title;
  }

  // 设置学期
  void setSchoolTerm(int index) {
    schoolTermIndex = index;
  }

  @override
  void onClose() {
    super.onClose();
    cancelToken.cancel("取消创建");
    isbnController.dispose();
    for (var controller in isbnList) {
      controller.dispose();
    }
    courseNameController.dispose();
    courseIdController.dispose();
    publishingHouseController.dispose();
    authorController.dispose();
    publishingDateController.dispose();
  }
}
