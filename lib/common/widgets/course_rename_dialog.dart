import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 课程重命名对话框组件
/// 提供课程名称修改功能的弹框界面
class CourseRenameDialog extends StatefulWidget {
  final String title;

  /// 当前课程名称
  final String currentName;

  /// 确认回调
  final ValueChanged<String>? onConfirm;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 最大输入长度
  final int? maxLength;

  const CourseRenameDialog({
    Key? key,
    required this.title,
    required this.currentName,
    this.onConfirm,
    this.onCancel,
    this.maxLength,
  }) : super(key: key);

  /// 显示课程重命名对话框
  static Future<String?> show({
    required BuildContext context,
    required String title,
    required String currentName,
    int? maxLength,
  }) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CourseRenameDialog(
        title: title,
        currentName: currentName,
        maxLength: maxLength,
        onConfirm: (newName) {
          Navigator.of(context).pop(newName);
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  State<CourseRenameDialog> createState() => _CourseRenameDialogState();
}

class _CourseRenameDialogState extends State<CourseRenameDialog> with SafeSetStateMixin {
  late TextEditingController _textController;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.currentName);
    _textController.addListener(_validateInput);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          // 点击空白区域收起键盘
          FocusScope.of(context).unfocus();
        },
        child: Material(
            color: Colors.transparent,
            child: Center(
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  width: 640.ww,
                  padding: EdgeInsets.all(16.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cBgSecondary,
                    borderRadius: BorderRadius.circular(12.wMin),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          '${widget.title}重命名',
                          style: TextStyle(
                            color: AppTheme.cTextPrimary,
                            fontSize: 32.wMin,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Gaps.getHeight(24.wh),
                      Text(
                        '新${widget.title}名称',
                        style: TextStyle(
                          color: AppTheme.cTextPrimary,
                          fontSize: 28.wMin,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Gaps.getHeight(8.wh),
                      _buildTextField(),
                      Gaps.getHeight(40.wh),
                      _buildButtons(),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  /// 构建输入框
  Widget _buildTextField() {
    return Container(
      padding: EdgeInsets.only(left: 16.wMax, top: 16.wMax, right: 16.wMax, bottom: 16.wMax),
      decoration: BoxDecoration(
        color: AppTheme.cBgTertiary,
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(
          color: AppTheme.cBorderPrimary,
          width: 1.wMin,
        ),
      ),
      child: TextField(
        controller: _textController,
        autofocus: true,
        style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 24.wMin, fontWeight: FontWeight.w400),
        maxLength: widget.maxLength,
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          // important 用于编辑框对齐
          isDense: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintText: '请输入${widget.title}名称',
          hintStyle: TextStyle(color: const Color(0xff98A4AD), fontSize: 24.wMin, fontWeight: FontWeight.w400),
        ),
        onSubmitted: (_) {
          if (_isValid) {
            _handleConfirm();
          }
        },
      ),
    );
  }

  /// 构建按钮组
  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildCancelButton()),
        SizedBox(width: 24.ww),
        Expanded(child: _buildConfirmButton()),
      ],
    );
  }

  /// 构建取消按钮
  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: OptimizeUtils.noneThrottle(() {
        _handleCancel();
      }, 200),
      child: Container(
        height: 68.wh,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.cBgTertiary,
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        child: Text(
          '取消',
          style: TextStyle(
            color: AppTheme.cTextPrimary,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 构建确认按钮
  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: _isValid
          ? OptimizeUtils.noneThrottle(() {
              _handleConfirm();
            }, 200)
          : null,
      child: Container(
        height: 68.wh,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isValid ? AppTheme.cSurfaceBrand : AppTheme.cBgDisabled,
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        child: Text(
          '确认',
          style: TextStyle(
            color: AppTheme.cStaticWhite,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 验证输入内容
  void _validateInput() {
    final text = _textController.text.trim();
    safeSetState(() {
      _isValid = text.isNotEmpty;
    });
  }

  /// 处理确认操作
  void _handleConfirm() {
    final newName = _textController.text.trim();
    if (newName.isNotEmpty) {
      widget.onConfirm?.call(newName);
    } else {
      ToastUtils.showToast(text: "请输入${widget.title}名称", type: ToastType.success);
    }
  }

  /// 处理取消操作
  void _handleCancel() {
    widget.onCancel?.call();
  }

  @override
  void dispose() {
    _textController.removeListener(_validateInput);
    _textController.dispose();
    super.dispose();
  }
}
