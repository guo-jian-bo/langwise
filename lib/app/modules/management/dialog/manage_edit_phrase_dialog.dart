import 'package:api/api.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/static/static_data.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../generated/assets.dart';
import '../../management/dialog/manage_select_semantic_table/view.dart';
import '../common/commons.dart';


/// 编辑短语
class ManageEditPhraseDialog{
  static Future<EnKnowledgeEntity?> show({
    required BuildContext context,
    required EnKnowledgeEntity knowledge,
  }) async{

    EnPhraseEntity entity = EnPhraseEntity.fromJson(knowledge.toJson());


    return await showCupertinoDialog<EnKnowledgeEntity?>(
      context: context,
      builder: (context) {
        return ManageEditPhraseDialogWidget(knowledge: entity);
      },
    );
  }

}


class ManageEditPhraseDialogWidget extends GetView<ManageEditPhraseController> {
  final EnPhraseEntity knowledge;
  const ManageEditPhraseDialogWidget({super.key, required this.knowledge});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ManageEditPhraseController(knowledge),
      id: "manage_edit_phrase",
      builder: (controller) {
        return DialogBoxWidget(
          title: "编辑短语",
          width: 1200.wMin,
          onCancel: () => Get.back(),
          onDefine: () => controller.onCreatePhrase(),
          child: SizedBox(
            height: 800.wMin,
            child: _buildContentWidget(context),
            
          ),
        );
      }
    );
  }

  /// 主视图
  Widget _buildContentWidget(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Column(
        children: [
          ManageTitleInputWidget(
            title: "短语",
            hintText: '请填写短语(以空格分割)',
            required: true,
            controller: controller.wordController,
            readOnly: false,
          ),
          Gaps.getHeight(24.wh),
          ManageTitleInputWidget(
            title: "释义",
            hintText: '请填写释义',
            required: false,
            controller: controller.definitionController,
            readOnly: false,
          ),
          Gaps.getHeight(24.wh),
          _buildExtraWidget(title: "选择语义"),
          _buildSemanticWidget(context),
          Gaps.getHeight(24.wh),
          ManageSelectWidget(
            title: "词性",
            hintText: '请选择词性',
            value: controller.posTitle,
            readOnly: false,
            required: true,
            options: controller.poses.map((element) => element.title ?? '').toList(),
            onChanged: (String value, int index) {
              controller.setPos(index);
            },
          ),
          Gaps.getHeight(24.wh),
          ManageSelectWidget(
            title: "语法形式",
            hintText: '请选择语法形式',
            value: controller.formTitle,
            readOnly: false,
            required: true,
            options: controller.forms.map((element) => element.title ?? '').toList(),
            onChanged: (String value, int index) {
              controller.setForm(index);
            },
          ),
          Gaps.getHeight(24.wh),
          ManageSelectWidget(
            title: "上架状态",
            hintText: '请选择上架状态',
            value: controller.newAccessName,
            readOnly: false,
            required: true,
            options: StaticData.getOnOffShelfForCreateOrEditNames,
            onChanged: (String value, int index) {
              controller.setAccess(index);
            },
          ),
          Gaps.getHeight(24.wh),
        ],
      ),
    );
  }

  // 语义
  Widget _buildSemanticWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 188,
      alignment: Alignment.centerLeft,
      child: ListView.builder(
        // 缓存键
        key: const PageStorageKey<String>("semantic"),
        itemCount: controller.semantics.length + 1,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext c, int index) {
          if (index == 0) {
            return AspectRatio(
                aspectRatio: 160 / 188,
                child: buildAddButton(context, "添加语义", () {
                  controller.toAddSemantic(context, controller.semantics);
                }));
          }
          final EnEntitySemantics entitySemantics = controller.semantics[index - 1];
          return CombinedSemanticsWidget(
            key: PageStorageKey(entitySemantics.uid),
            entitySemantics: entitySemantics,
            index: index - 1,
            onDeleteTap: (int i, EnEntitySemantics semantics) {
              controller.onRemoveSemantic(semantics);
            },
          );
        },
      ),
    );
  }

  Widget _buildExtraWidget({required String title}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.wh),
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          children: [
            // 红色星号
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

  // 添加知识点
  Widget buildAddButton(BuildContext context, String title, VoidCallback onTap) {
    return TapScaleWidget(
      onTap: OptimizeUtils.noneThrottle(() {
        onTap.call();
      }, 100),
      sclae: 1.03,
      child: DottedBorder(
        radius: Radius.circular(8.wMin),
        borderType: BorderType.RRect,
        padding: EdgeInsets.zero,
        color: const Color(0xff444B5F),
        dashPattern: const [1, 2],
        strokeWidth: 1.wMin,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildImage(Assets.managerAdd, width: 40.wMax, height: 40.wMax),
              Gaps.getHeight(10.wh),
              Text(
                title,
                style: TextStyleExtension.ts_12_w400_ACB4C0,
              ),
            ],
          ),
        ),
      ),
    );
  }


}



class ManageEditPhraseController extends GetxController {
  final EnPhraseEntity entity;

  ManageEditPhraseController(this.entity);

  /// 上传所有信息按钮
  bool get uploadButtonFlag => (wordController.text.trim().isNotEmpty && posIndex != -1 && (selectAccessIndex != -1));

  /// word
  final TextEditingController wordController = TextEditingController(text: '');

  /// 释义
  final TextEditingController definitionController = TextEditingController(text: '');

  // 上下架
  final RxInt _selectAccessIndex = (-1).obs;

  set selectAccessIndex(value) => _selectAccessIndex.value = value;

  int get selectAccessIndex => _selectAccessIndex.value;

  // 词性
  final RxInt _posIndex = (-1).obs;

  set posIndex(value) => _posIndex.value = value;

  int get posIndex => _posIndex.value;

  // 语法形式
  final RxInt _formIndex = (-1).obs;

  set formIndex(value) => _formIndex.value = value;

  int get formIndex => _formIndex.value;

  // 词性
  List<PosResponseEntity> poses = <PosResponseEntity>[];

  // 语法形式
  List<FormResponseEntity> forms = <FormResponseEntity>[];

  // 语义list
  final List<EnEntitySemantics> semantics = <EnEntitySemantics>[];

  final GlobalKey dialogKey = GlobalKey();


  @override
  void onInit() {
    super.onInit();
    wordController.text = entity.content ?? '';
    definitionController.text = entity.definition ?? '';


    // 语义
    if (entity.semantics != null && entity.semantics!.isNotEmpty) {
      semantics.addAll(entity.semantics! as Iterable<EnEntitySemantics>);
    }

    // 上下架
    try {
      selectAccessIndex = StaticData.getOnOffShelfForCreateOrEditIndex(entity.access) ?? 0;
    } catch (e) {
      print(e);
    }
    onGetPos();
    onGetForm();
    _onListener();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(['manage_edit_phrase']);
  }

  void _onListener() {
    wordController.addListener(() {
      _initData();
    });
    definitionController.addListener(() {
      _initData();
    });
  }

  // 获取词性列表
  void onGetPos() async {
    try {
      final response = await LanguageUtil.pos(config: RequestConfig(requireToken: true));
      if (response.data != null) {
        poses = response.data?.list ?? [];
        // 词性
        if (entity.pos != null) {
          for (int i = 0; i < poses.length; i++) {
            final PosResponseEntity r = poses[i];
            if (r.pos == entity.pos) {
              posIndex = i;
            }
          }
        }
      } else {
        ToastUtils.showManageToast(text: response.message ?? '获取词性列表失败');
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "获取词性列表失败");
    } finally {
      _initData();
    }
  }

// 获取语法形式列表
  void onGetForm() async {
    try {
      final response = await LanguageUtil.form(config: RequestConfig(requireToken: true));
      if (response.data != null) {
        forms = response.data?.list ?? [];
        // 词性
        if (entity.pos != null) {
          for (int i = 0; i < forms.length; i++) {
            final FormResponseEntity r = forms[i];
            if (r.form == entity.form) {
              formIndex = i;
            }
          }
        }
      } else {
        ToastUtils.showManageToast(text: response.message ?? '获取语法形式列表失败');
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "获取语法形式列表失败");
    } finally {
      _initData();
    }
  }

  // 创建短语
  void onCreatePhrase() async {
    try {
      final String content = wordController.text.trim();
      if (content.isEmpty) {
        ToastUtils.showManageToast(text: "请填写短语", containerKey: dialogKey);
        return;
      }

      final String definition = definitionController.text.trim();
      if (definition.isEmpty) {
        ToastUtils.showManageToast(text: "请填写释义");
        return;
      }

      if (selectAccessIndex == -1) {
        ToastUtils.showManageToast(text: "请选择上架状态", containerKey: dialogKey);
        return;
      }


      if (posIndex == -1) {
        ToastUtils.showManageToast(text: "请选择词性");
        return;
      }

      // 词性/语法形式
      String? pos, form;
      try {
        pos = poses[posIndex].pos;
      } catch (e) {
        print('---词性e:$e---');
      }

      try {
        form = forms[formIndex].form;
      } catch (e) {
        print('---语法形式e:$e---');
      }

      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "content": content,
        "definition": definition,
        "semanticIds": semantics.map((element) => element.uid).toList(),
        "access": StaticData.onOffShelfForCreateOrEdit[selectAccessIndex].value,
        "pos": pos,
        "form": form,
      };

      var response = await LanguageConsoleRequest.editPhrase(entity.uid, data: reqData);
      if(response == null) return;
      Get.back(result: response);

    } finally{
      ToastUtils.hideLoading();
    }
  }


  // 添加语义
  Future<void> toAddSemantic(BuildContext context, List<EnEntitySemantics> existList) async {
    var value = await ManageSelectSemanticTableManager.show(
        context: context,
        defaultDessert: [],
        dataDisableCallback: (EnEntitySemantics targetEntity) {
          bool isDisable = false;
          for (final EnEntitySemantics exist in existList) {
            if (exist == targetEntity) {
              isDisable = true;
              break;
            }
          }
          return isDisable;
        });
    if (value != null) {
      semantics.addAll(value);
      _initData();
    }
  }


  // 分割单词
  List<String> get wordSplit => wordController.text.trim().split(' ');

  // 获取单词所在位置
  String getWordByIndex(int index) {
    final List<String> words = wordSplit;
    if (index >= 0 && index < words.length) {
      return words[index];
    }
    return '';
  }



  // 移除语义
  void onRemoveSemantic(EnEntitySemantics entity) {
    if (semantics.isNotEmpty) {
      semantics.remove(entity);
      _initData();
    }
  }

  // 上下架
  void setAccess(int index) {
    selectAccessIndex = index;
    _initData();
  }

  // 上下架title
  String get newAccessName {
    return StaticData.getOnOffShelfForCreateOrEdit(selectAccessIndex);
  }

  // 词性
  String get posTitle {
    String title = '';
    try {
      title = poses.map((element) => element.title ?? '').toList()[posIndex];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    print(title);

    return title;
  }

// 设置词性
  void setPos(int index) {
    posIndex = index;
    _initData();
  }

// 语法形式
  String get formTitle {
    String title = '';
    try {
      title = forms.map((element) => element.title ?? '').toList()[formIndex];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    print(title);

    return title;
  }

// 语法形式
  void setForm(int index) {
    formIndex = index;
    _initData();
  }


  @override
  void onClose() {
    super.onClose();
    wordController.dispose();
  }
}
